#!/bin/bash
# aur-checks.sh - shared deterministic checks for AUR PKGBUILD review.
#
# Sourced by `aur-gate` (paru PreBuildCommand backstop) and `aur-review`
# (batched pre-flight). Every check maps to a technique observed in the
# 2025-2026 AUR supply-chain waves, and every one is deterministic: no model is
# involved, so nothing in a PKGBUILD can talk its way past them.
#
# Design rule: a check that cannot run must say so loudly. Silent fail-open is
# the worst outcome here - it reports "clean" and the user builds the payload.

AUR_RPC="${AUR_RPC:-https://aur.archlinux.org/rpc/?v=5&type=info}"
AUR_STATE="${AUR_STATE:-${CUSTOM_CONFIG_HOME:-$HOME/.custom_config/configs}/package_info/aur_maintainers.json}"

# Payload names used in the July 2026 wave.
AUR_PAYLOAD_NAMES='^(linter|hasher|minifier|validator|assembler|optimizer)$'

# Paths are read NUL-delimited with quotePath disabled. Without this, git
# renders a path containing non-ASCII bytes as "caf\303\251.install" - with
# literal quotes - which defeats both the anchored payload-name match and the
# *.install glob, letting an attacker bypass two hard blocks by naming a file
# with one accented character.
_git_q() { git -c core.quotePath=false -C "$1" "${@:2}"; }

# ---------------------------------------------------------------------------
# aur_baseline_ref <clonedir> <pkgbase>  -> commit to diff FROM, or empty
# ---------------------------------------------------------------------------
aur_baseline_ref() {
	local d=$1 pkg=$2 ref iv
	# --verify --quiet prints nothing on failure. Plain `rev-parse ORIG_HEAD`
	# echoes its own argument back on stdout when the ref is missing, which
	# previously produced base="ORIG_HEAD" and silently disabled every
	# diff-dependent check.
	for r in AUR_SEEN ORIG_HEAD; do
		ref=$(git -C "$d" rev-parse --verify --quiet "$r" 2>/dev/null) && [ -n "$ref" ] && {
			echo "$ref"
			return 0
		}
	done
	iv=$(pacman -Q "$pkg" 2>/dev/null | awk '{print $2}' | sed 's/-[0-9]*$//; s/^[0-9]*://')
	if [ -n "$iv" ]; then
		ref=$(git -C "$d" log --format=%H -S"pkgver=$iv" --all -- PKGBUILD 2>/dev/null | head -1)
		[ -n "$ref" ] && echo "$ref"
	fi
}

# ---------------------------------------------------------------------------
# State. Values are passed via argv, never interpolated into the program text:
# $m and $co come straight from AUR RPC JSON and $pkg from PKGBASE, so string
# interpolation here was a code-execution sink inside the component whose job
# is preventing code execution.
# ---------------------------------------------------------------------------
# -> prints maintainer, or nothing. Exit 2 means the state file is unreadable
#    or corrupt, which must NOT be conflated with "no entry yet".
aur_recorded_maintainer() {
	python3 -c '
import json,sys,os
p,pkg=sys.argv[1],sys.argv[2]
if not os.path.exists(p): sys.exit(0)
try: d=json.load(open(p))
except Exception: sys.exit(2)
if not isinstance(d,dict): sys.exit(2)
print(d.get(pkg,{}).get("maintainer","") or "")
' "$AUR_STATE" "$1"
}

aur_record_maintainer() {
	mkdir -p "$(dirname "$AUR_STATE")" || return 1
	python3 -c '
import json,os,sys
p,pkg,m,co=sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4]
try: d=json.load(open(p))
except Exception: d={}
if not isinstance(d,dict): d={}
d[pkg]={"maintainer":m,"comaintainers":co}
tmp=p+".tmp"
with open(tmp,"w") as f: json.dump(d,f,indent=1,sort_keys=True)
os.replace(tmp,p)
' "$AUR_STATE" "$1" "$2" "$3"
}

# aur_fetch_maintainer <pkgbase>
#   "maintainer|comaintainers"  ok      | "NOTFOUND|"  genuinely not on the AUR
#   ""  + exit 1                RPC unreachable OR returned an error document
# The AUR RPC answers malformed/failed queries with HTTP 200 and
# {"type":"error","results":[]}, which curl -f accepts. Treating that as
# NOTFOUND would silently retire the adoption check, so the body is inspected.
aur_fetch_maintainer() {
	local body
	body=$(curl -sf --max-time 15 "${AUR_RPC}&arg[]=$1" 2>/dev/null) || return 1
	[ -z "$body" ] && return 1
	printf '%s' "$body" | python3 -c '
import json,sys
try: d=json.load(sys.stdin)
except Exception: sys.exit(1)
if d.get("type")=="error" or d.get("error"): sys.exit(1)
if "results" not in d: sys.exit(1)
r=d["results"]
if not r:
    print("NOTFOUND|"); sys.exit(0)
r=r[0]
print((r.get("Maintainer") or "ORPHAN")+"|"+",".join(sorted(r.get("CoMaintainers") or [])))
' || return 1
}

# ---------------------------------------------------------------------------
# Source identity. makepkg builds from PKGBUILD; .SRCINFO is generated metadata
# that nothing forces to agree with it. Reading only .SRCINFO let an attacker
# swap source= and the checksums in PKGBUILD while leaving .SRCINFO untouched.
# Both files are read, and the union compared.
#
# Identity is scheme://host plus the first two path segments: on github.com and
# friends the owner/repo segments are the meaningful identity, not the host.
# ---------------------------------------------------------------------------
# .SRCINFO is fully expanded - no shell variables - so it is the only
# reliably parseable statement of what will be downloaded. PKGBUILD cannot be
# parsed without executing it, and executing it is precisely what we are
# gating. So identity comes from .SRCINFO, and the risk that .SRCINFO lies is
# handled separately by _aur_desync below.
#
# Only source= / *sums= fields are read. An earlier version scanned every URL
# and every hex string in both files, which flagged ordinary edits to the
# `url=` homepage field and to validpgpkeys fingerprints.
_aur_sources_at() {
	_git_q "$1" show "$2:.SRCINFO" 2>/dev/null |
		command grep -oE '^[[:space:]]*source(_[a-z0-9_]+)? = .*' |
		sed -E 's/^[[:space:]]*source(_[a-z0-9_]+)? = //' |
		sed -E 's/^[^:]*:://' |
		command grep -oE '[a-z+]+://[^"'"'"' )]+' |
		sed -E 's/#.*$//' |
		sed -E 's#^([a-z+]+://[^/]+(/[^/]*){0,2}).*#\1#' |
		sed -E 's/[0-9]+/N/g' | sort -u
}

_aur_sums_at() {
	_git_q "$1" show "$2:.SRCINFO" 2>/dev/null |
		command grep -oE '^[[:space:]]*[a-z0-9]*sums(_[a-z0-9_]+)? = .*' |
		sed -E 's/^[[:space:]]*[a-z0-9]*sums(_[a-z0-9_]+)? = //' | sort -u
}

# Raw source=/`*sums=` assignment text from PKGBUILD, unexpanded.
_aur_pkgbuild_srcblock() {
	_git_q "$1" show "$2:PKGBUILD" 2>/dev/null |
		awk '/^[[:space:]]*(source|[a-z0-9]*sums)(_[a-z0-9_]+)?=/{f=1}
		     f{print}
		     f && /\)[[:space:]]*$/{f=0}' |
		# Normalise cosmetic shell churn: ${var} vs $var, quote style, spacing.
		# Without this, a pure reformat reads as a source change.
		sed -E 's/\$\{[^}]*\}/$V/g; s/\$[A-Za-z_][A-Za-z0-9_]*/$V/g' |
		tr -d '"'"'"' \t' | command grep -v '^$'
}

# The F2 attack: change what PKGBUILD downloads while leaving .SRCINFO
# untouched, so any .SRCINFO-based check sees nothing. Detected as a desync -
# PKGBUILD's source/sums text changed but .SRCINFO's did not.
_aur_desync() {
	local d=$1 base=$2 head=$3 pb_o pb_n si_o si_n
	# Needs .SRCINFO at both ends to mean anything. Without it there is nothing
	# to be out of sync WITH, and the comparison would fire on every change.
	_git_q "$d" cat-file -e "$base:.SRCINFO" 2>/dev/null || return 1
	_git_q "$d" cat-file -e "$head:.SRCINFO" 2>/dev/null || return 1
	pb_o=$(_aur_pkgbuild_srcblock "$d" "$base")
	pb_n=$(_aur_pkgbuild_srcblock "$d" "$head")
	[ "$pb_o" = "$pb_n" ] && return 1
	si_o="$(_aur_sources_at "$d" "$base")|$(_aur_sums_at "$d" "$base")"
	si_n="$(_aur_sources_at "$d" "$head")|$(_aur_sums_at "$d" "$head")"
	[ "$si_o" = "$si_n" ] && return 0
	return 1
}

_aur_pkgver_at() {
	local d=$1 rev=$2 v
	v=$(_git_q "$d" show "$rev:.SRCINFO" 2>/dev/null | awk -F' = ' '/^\tpkgver/{print $2; exit}')
	[ -z "$v" ] && v=$(_git_q "$d" show "$rev:PKGBUILD" 2>/dev/null |
		command grep -m1 -oE '^pkgver=.*' | cut -d= -f2- | tr -d "\"'")
	printf '%s' "$v"
}


# An .install script runs as root via pacman, so it always deserves scrutiny -
# but most are benign (echo a note, rebuild a mime cache). Hard-blocking every
# first install of a package that ships one would train the user to reach for
# the bypass, which is worse than no gate. So: a MODIFIED .install always
# blocks (change is the signal), while a first-seen one blocks only if its
# contents do something an .install has no business doing.
_AUR_INSTALL_DANGER='(curl|wget|/dev/tcp|nc |netcat|base64[[:space:]]+-d|xxd[[:space:]]+-r|eval|\|[[:space:]]*(ba)?sh|sh[[:space:]]+-c|chmod[[:space:]]+[ug]?\+s|setcap|useradd|usermod|crontab|systemctl[[:space:]]+enable|update-rc.d)'

# _aur_install_danger <clonedir> <blobsha> -> prints matching line, exit 0 if dangerous
_aur_install_danger() {
	git -C "$1" cat-file blob "$2" 2>/dev/null |
		command grep -nE "$_AUR_INSTALL_DANGER" | head -1
}

# ---------------------------------------------------------------------------
# aur_run_checks <clonedir> <pkgbase> <base_ref> [head_ref]
# Prints BLOCK:/NOTE:/WARN: lines. Returns 1 if any BLOCK was emitted.
# ---------------------------------------------------------------------------
aur_run_checks() {
	local d=$1 pkg=$2 base=$3 head=${4:-}
	local blocked=0 needs_review=0 f mode type sha raw stripped danger hit meta line
	[ -z "$head" ] && head=$(git -C "$d" rev-parse --verify --quiet HEAD 2>/dev/null)
	[ -z "$head" ] && {
		echo "WARN: $pkg has no resolvable HEAD - no checks could run"
		return 1
	}

	# --- absolute checks: run against the tree at $head, with or without a diff

	while IFS= read -r -d '' line; do
		meta=${line%%$'\t'*}
		f=${line#*$'\t'}
		read -r mode type sha <<<"$meta"
		[ "$mode" = "120000" ] && continue # symlink, not a committed payload

		if printf '%s' "${f##*/}" | command grep -qE "$AUR_PAYLOAD_NAMES"; then
			echo "BLOCK: file named '${f##*/}' committed (July 2026 payload name)"
			blocked=1
		fi

		# git's own definition of binary: a NUL byte in the first 8000 bytes.
		raw=$(git -C "$d" cat-file blob "$sha" 2>/dev/null | head -c 8000 | wc -c)
		stripped=$(git -C "$d" cat-file blob "$sha" 2>/dev/null | head -c 8000 | tr -d '\0' | wc -c)
		if [ "$raw" -ne "$stripped" ]; then
			echo "BLOCK: binary file committed to repo: $f (June 2026 embedded-ELF technique)"
			blocked=1
		fi

		# .install runs as root via pacman. Checked against the TREE, not just
		# the diff, so a first-time install is covered too.
		case "$f" in
		*.install)
			if [ -n "$base" ] && _git_q "$d" cat-file -e "$base:$f" 2>/dev/null; then
				# Seen before: any change to it is the signal.
				if ! _git_q "$d" diff --quiet "$base".."$head" -- "$f" 2>/dev/null; then
					echo "BLOCK: .install script modified: $f (runs as root)"
					blocked=1
				fi
			else
				# First time we have seen it: judge on contents.
				danger=$(_aur_install_danger "$d" "$sha")
				if [ -n "$danger" ]; then
					echo "BLOCK: new .install script $f runs as root and does something unusual: $(printf '%s' "$danger" | cut -c1-80)"
					blocked=1
				else
					echo "NOTE: $f is new and runs as root; contents look inert (no network/eval/privilege calls)"
				fi
			fi
			;;
		esac

		# sudo in any committed shell/build script, not only PKGBUILD.
		case "$f" in
		PKGBUILD | *.sh | *.install | *.bash)
			hit=$(git -C "$d" cat-file blob "$sha" 2>/dev/null |
				command grep -nE '(^|[^[:alnum:]_])sudo([^[:alnum:]_]|$)' | head -1)
			if [ -n "$hit" ]; then
				echo "BLOCK: 'sudo' in $f: $(printf '%s' "$hit" | cut -c1-80)"
				blocked=1
			fi
			;;
		esac
	done < <(_git_q "$d" ls-tree -r -z "$head" 2>/dev/null)

	# --- maintainer / adoption check: the common thread in all three waves ----
	local rpc now_m now_co prev_m prc
	if rpc=$(aur_fetch_maintainer "$pkg"); then
		now_m=${rpc%%|*}
		now_co=${rpc#*|}
		if [ "$now_m" = "NOTFOUND" ]; then
			echo "NOTE: $pkg is not on the AUR (repo package or deleted) - maintainer check n/a"
		else
			prev_m=$(aur_recorded_maintainer "$pkg")
			prc=$?
			if [ "$prc" -eq 2 ]; then
				echo "BLOCK: maintainer state file is unreadable or corrupt ($AUR_STATE) - the adoption check cannot run"
				blocked=1
			elif [ -z "$prev_m" ]; then
				echo "NOTE: no maintainer baseline for $pkg (will record '$now_m' if this run passes)"
			elif [ "$prev_m" != "$now_m" ]; then
				echo "BLOCK: maintainer changed: '$prev_m' -> '$now_m' (adoption takeover is the common thread in all 2026 AUR waves)"
				blocked=1
			fi
			[ "$now_m" = "ORPHAN" ] && echo "NOTE: $pkg is ORPHANED on the AUR - adoption-takeover target"
		fi
	else
		echo "WARN: AUR RPC unreachable or returned an error for $pkg - the maintainer/adoption check DID NOT RUN"
	fi

	if ! _git_q "$d" cat-file -e "$head:.SRCINFO" 2>/dev/null; then
		echo "REVIEW: $pkg has no .SRCINFO - source and checksum checks cannot run"
		needs_review=1
	fi

	# --- diff-dependent checks ------------------------------------------------
	if [ -n "$base" ] && [ "$base" != "$head" ]; then
		# Binary added in this diff.
		while IFS=$'\t' read -r a b f; do
			[ "$a" = "-" ] && [ "$b" = "-" ] && {
				echo "BLOCK: binary blob added/changed in diff: $f"
				blocked=1
			}
		done < <(_git_q "$d" diff --numstat "$base".."$head" 2>/dev/null)

		local old_src new_src old_ver new_ver old_sums new_sums old_rel new_rel
		old_src=$(_aur_sources_at "$d" "$base")
		new_src=$(_aur_sources_at "$d" "$head")
		if [ -n "$old_src" ] && [ "$old_src" != "$new_src" ]; then
			echo "REVIEW: source origin changed - verify this is a legitimate upstream move:"
			diff <(echo "$old_src") <(echo "$new_src") | sed 's/^/         /'
			needs_review=1
		fi

		# Payload swapped under an unchanged version: same sources, same
		# pkgver AND pkgrel, but different checksums. Requiring the source set
		# and pkgrel to be unchanged too avoids flagging the ordinary case of a
		# maintainer adding a patch file and bumping pkgrel.
		old_ver=$(_aur_pkgver_at "$d" "$base")
		new_ver=$(_aur_pkgver_at "$d" "$head")
		old_rel=$(_git_q "$d" show "$base:.SRCINFO" 2>/dev/null | awk -F' = ' '/^\tpkgrel/{print $2; exit}')
		new_rel=$(_git_q "$d" show "$head:.SRCINFO" 2>/dev/null | awk -F' = ' '/^\tpkgrel/{print $2; exit}')
		old_sums=$(_aur_sums_at "$d" "$base")
		new_sums=$(_aur_sums_at "$d" "$head")
		local vanished
		vanished=$(comm -23 <(printf '%s\n' "$old_sums") <(printf '%s\n' "$new_sums") 2>/dev/null)
		if [ "$old_ver" = "$new_ver" ] && [ "$old_rel" = "$new_rel" ] &&
			[ "$old_src" = "$new_src" ] && [ -n "$old_sums" ] && [ -n "$vanished" ]; then
			echo "BLOCK: checksums changed but pkgver/pkgrel and sources did not ($new_ver-$new_rel) - payload swapped under an unchanged version"
			blocked=1
		fi

		if _aur_desync "$d" "$base" "$head"; then
			echo "BLOCK: PKGBUILD source/checksum lines changed but .SRCINFO did not - makepkg builds from PKGBUILD, so .SRCINFO-based review would miss this"
			blocked=1
		fi
	elif [ -z "$base" ]; then
		echo "NOTE: no baseline commit for $pkg (first install: change-checks not applicable)"
	fi

	# Advance the baseline ONLY on a fully clean run. Recording it earlier let a
	# run that blocked on some other check still consume the takeover signal,
	# so the adoption check could never fire for that package again.
	if [ "$blocked" -eq 0 ] && [ "$needs_review" -eq 0 ] && [ -n "${now_m:-}" ] && [ "${now_m:-}" != "NOTFOUND" ]; then
		aur_record_maintainer "$pkg" "$now_m" "$now_co" ||
			echo "WARN: could not persist maintainer baseline for $pkg"
	fi

	[ "$blocked" -ne 0 ] && return 1
	[ "$needs_review" -ne 0 ] && return 2
	return 0
}

aur_is_devel() {
	case "$1" in
	*-git | *-svn | *-hg | *-bzr | *-cvs | *-darcs | *-fossil | *-nightly) return 0 ;;
	*) return 1 ;;
	esac
}
