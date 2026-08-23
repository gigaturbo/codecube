#!/usr/bin/env bash
#
# Integration checks for the Codecube game.
#
# These verify that the game *assembles* - that the pieces are present, declare
# themselves properly, and refer only to things that exist. Linting and unit
# testing of the codeblock mod belong to that mod's own repository and CI; this
# script deliberately does not duplicate them.
#
# Usage: scripts/check_game.sh   (from the repository root)

set -uo pipefail

cd "$(dirname "$0")/.."

fail=0
note() { printf '  %s\n' "$*"; }
err() {
    printf '  FAIL: %s\n' "$*"
    if [ -n "${GITHUB_ACTIONS:-}" ]; then echo "::error::$*"; fi
    fail=1
}

echo "== game.conf =="
if [ ! -f game.conf ]; then
    err "game.conf is missing"
else
    # title is the only key Luanti actually requires of a game.
    if grep -qE '^title[[:space:]]*=' game.conf; then
        note "title present"
    else
        err "game.conf has no title"
    fi
    if grep -qE '^max_minetest_version' game.conf; then
        err "game.conf still declares max_minetest_version; ContentDB will hide the package from current releases"
    else
        note "no version ceiling"
    fi
    min=$(sed -nE 's/^min_minetest_version[[:space:]]*=[[:space:]]*(.*)$/\1/p' game.conf)
    note "min_minetest_version = ${min:-<unset>}"
fi

echo "== submodules checked out =="
for m in codeblock vector3 formspecs; do
    if [ -n "$(ls -A "mods/$m" 2>/dev/null)" ]; then
        note "mods/$m populated"
    else
        err "mods/$m is empty - run: git submodule update --init --recursive"
    fi
done

echo "== every mod declares itself =="
declare -A names=()
for d in mods/*/; do
    m=${d%/}
    m=${m#mods/}
    if [ ! -f "$d/mod.conf" ]; then
        err "mods/$m has no mod.conf"
        continue
    fi
    n=$(sed -nE 's/^name[[:space:]]*=[[:space:]]*([A-Za-z0-9_]+).*$/\1/p' "$d/mod.conf" | head -1)
    if [ -z "$n" ]; then
        err "mods/$m/mod.conf has no name"
        continue
    fi
    if [ "$n" != "$m" ]; then
        err "mods/$m declares name = $n (directory and name should match)"
    fi
    if [ -n "${names[$n]:-}" ]; then
        err "duplicate mod name '$n' (mods/$m and mods/${names[$n]})"
    fi
    names[$n]=$m
done
note "${#names[@]} mods declared"

echo "== declared dependencies resolve =="
for d in mods/*/; do
    m=${d%/}
    m=${m#mods/}
    [ -f "$d/mod.conf" ] || continue
    deps=$(sed -nE 's/^depends[[:space:]]*=[[:space:]]*(.*)$/\1/p' "$d/mod.conf" | head -1)
    [ -n "$deps" ] || continue
    IFS=',' read -ra list <<< "$deps"
    for dep in "${list[@]}"; do
        dep=$(echo "$dep" | tr -d '[:space:]')
        [ -n "$dep" ] || continue
        if [ -z "${names[$dep]:-}" ]; then
            err "mods/$m depends on '$dep', which this game does not ship"
        fi
    done
done
note "all hard dependencies present"

echo "== every bundled mod's licence is accounted for =="
# formspecs is a submodule of a repository we do not control, so a licence file
# placed in it would be untracked and would vanish from a fresh clone. Its text
# lives in THIRD-PARTY-LICENSES.md instead, and this check insists on that
# rather than letting the gap pass silently.
documented_elsewhere="formspecs"
for d in mods/*/; do
    m=${d%/}
    m=${m#mods/}
    if ls "$d" 2>/dev/null | grep -qiE '^(license|licence|copying)'; then
        note "mods/$m carries its own licence"
    elif [[ " $documented_elsewhere " == *" $m "* ]]; then
        if [ -f THIRD-PARTY-LICENSES.md ] && grep -q "mods/$m" THIRD-PARTY-LICENSES.md; then
            note "mods/$m licensed via THIRD-PARTY-LICENSES.md"
        else
            err "mods/$m has no licence file and is not covered by THIRD-PARTY-LICENSES.md"
        fi
    else
        err "mods/$m has no licence file"
    fi
done
if [ -f LICENSE ]; then note "root LICENSE present"; else err "root LICENSE missing"; fi
if [ -f THIRD-PARTY-LICENSES.md ]; then
    note "THIRD-PARTY-LICENSES.md present"
else
    err "THIRD-PARTY-LICENSES.md missing"
fi

echo "== .cdb.json is up to date =="
if [ -f scripts/gen_cdb_json.sh ]; then
    cp .cdb.json /tmp/cdb_before.json 2>/dev/null || true
    bash scripts/gen_cdb_json.sh
    if diff -q /tmp/cdb_before.json .cdb.json >/dev/null 2>&1; then
        note ".cdb.json matches README"
    else
        err ".cdb.json is stale - run scripts/gen_cdb_json.sh and commit the result"
        cp /tmp/cdb_before.json .cdb.json 2>/dev/null || true
    fi
fi

echo
if [ "$fail" -eq 0 ]; then
    echo "all game integration checks passed"
else
    echo "game integration checks FAILED"
fi
exit "$fail"
