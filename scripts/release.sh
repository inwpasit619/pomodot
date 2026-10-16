#!/usr/bin/env bash
# Release Pomodot: build with scripts/build-app.sh, check everything a friend's Mac depends
# on, and only then tag and upload to GitHub Releases. Any failed check stops the script
# before anything is uploaded.
#
#   scripts/release.sh <release-notes.md>   on main, after merging release/X.Y.Z or hotfix/X.Y.Z
#                                           (keep the notes outside the repo, or committed)
#   scripts/release.sh --check              any branch: steps 2–6 only, never tags or uploads
set -euo pipefail

usage() {
    echo "usage: scripts/release.sh <release-notes.md> | --check" >&2
    exit 2
}

[[ $# -eq 1 ]] || usage
check_only=false
notes=""
if [[ "$1" == "--check" ]]; then
    check_only=true
else
    [[ -f "$1" ]] || { echo "error: no release notes at $1" >&2; exit 2; }
    # Absolute before moving to the repo root, so a path relative to anywhere works.
    notes="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
fi

cd "$(dirname "$0")/.."

version="$(tr -d '[:space:]' < VERSION)"
tag="v$version"
app="dist/Pomodot.app"
zip="dist/Pomodot-$version.zip"
repo="inwpasit619/pomodot"

step() { printf '\n== %s\n' "$1"; }
fail() { echo "STOP: $1" >&2; echo "Nothing was tagged or uploaded." >&2; exit 1; }
sha256() { shasum -a 256 "$1" | cut -d' ' -f1; }

scratch=()
cleanup() { [[ ${#scratch[@]} -eq 0 ]] || rm -rf "${scratch[@]}"; }
trap cleanup EXIT

if ! $check_only; then
    step "1. On main, merged from release/$version or hotfix/$version, nothing uncommitted, no $tag yet"
    branch="$(git rev-parse --abbrev-ref HEAD)"
    [[ "$branch" == "main" ]] || fail "on branch '$branch', not main"
    merged=""
    for source in "release/$version" "hotfix/$version" "origin/release/$version" "origin/hotfix/$version"; do
        if git rev-parse -q --verify "$source" >/dev/null && git merge-base --is-ancestor "$source" HEAD; then
            merged="$source"
        fi
    done
    [[ -n "$merged" ]] || fail "main has no release/$version or hotfix/$version merged in"
    # Step 7 pushes develop too: it must already have the release merged back (spec A9).
    git merge-base --is-ancestor "$merged" develop || fail "develop doesn't have $merged merged back yet"
    [[ -z "$(git status --porcelain)" ]] || fail "there is uncommitted work (see git status)"
    [[ -z "$(git tag -l "$tag")" ]] || fail "tag $tag already exists on this Mac"
    # Captured first: an offline or failed lookup must stop here, not read as "no tag".
    remote_tag="$(git ls-remote --tags origin "refs/tags/$tag")" || fail "can't reach GitHub to look for $tag"
    [[ -z "$remote_tag" ]] || fail "tag $tag already exists on GitHub"
    # A read-only gh login would fail only after the tag is pushed (spec A9).
    permission="$(gh repo view "$repo" --json viewerPermission --jq .viewerPermission)" \
        || fail "gh can't read $repo (run gh auth login)"
    [[ "$permission" == "ADMIN" || "$permission" == "WRITE" ]] \
        || fail "gh is logged in with $permission on $repo; it needs WRITE or ADMIN"
    echo "ok"
fi

step "2. Done conditions (spec A8): tests, universal build, no new warnings, Core imports, signed .app"
# This Mac's Command Line Tools sometimes fail to load the Swift Testing macros on the first
# try ("TestingMacros ... not found"); only that is retried. Any other failure stops here.
tests_passed=false
for attempt in 1 2 3 4 5 6 7 8; do
    if test_output="$(swift test 2>&1)"; then
        tests_passed=true
        break
    fi
    grep -q "TestingMacros" <<<"$test_output" || { echo "$test_output" | tail -30; fail "swift test failed"; }
    echo "swift test: Swift Testing macros didn't load (attempt $attempt), trying again"
done
$tests_passed || fail "swift test kept failing to load the Swift Testing macros"
echo "$test_output" | grep -E "Test run with" || true

# From clean, so every warning is printed again rather than hidden by a cached build.
swift package clean
build_output="$(scripts/build-app.sh 2>&1)" || { echo "$build_output" | tail -30; fail "scripts/build-app.sh failed"; }
# Known and harmless (spec A4): the Command Line Tools lack two linker search folders,
# .../Developer/usr/lib and .../Developer/Library/Frameworks, and x86_64 is deprecated for
# the SDK's own deployment target. Anything else stops.
new_warnings="$(grep -i "warning:" <<<"$build_output" \
    | grep -vE "ld: warning: search path '[^']*/Developer/(usr/lib|Library/Frameworks)' not found" \
    | grep -v "The x86_64 architecture is deprecated for your deployment target" || true)"
[[ -z "$new_warnings" ]] || { echo "$new_warnings"; fail "the build has new warnings"; }
echo "ok (opening the app and the Thai report, A8 6–7, are confirmed by hand in step 7)"

step "3. The executable has both arm64 and x86_64"
archs="$(lipo -archs "$app/Contents/MacOS/Pomodot")"
echo "$archs"
[[ " $archs " == *" arm64 "* && " $archs " == *" x86_64 "* ]] || fail "missing an architecture: $archs"

step "4. The whole bundle's signature verifies"
codesign --verify --strict --deep "$app" || fail "codesign --verify failed for $app"
echo "ok"

step "5. Zipped and unzipped, the signature still verifies"
rm -f "$zip"
ditto -c -k --keepParent "$app" "$zip"
unzipped="$(mktemp -d)"
scratch+=("$unzipped")
ditto -x -k "$zip" "$unzipped"
# A broken signature here is the "damaged" message with no Open Anyway on a friend's Mac.
codesign --verify --strict --deep "$unzipped/Pomodot.app" || fail "the unzipped app doesn't verify"
echo "ok: $zip"

# 6. spctl --assess is deliberately not used: an app that isn't notarized is always
#    "rejected", so it can't tell a good build from a bad one.

if $check_only; then
    printf '\nAll checks passed for %s. --check never tags or uploads.\n' "$zip"
    exit 0
fi

step "7. Release notes, then tag and upload"
echo "------------------------------------------------------------"
cat "$notes"
echo "------------------------------------------------------------"
echo "This publishes Pomodot $version to the public repo $repo."
echo "Confirm the app was opened and screenshotted and the Thai report was given (A8 6–7)."
# Only a person at the keyboard can approve: piped input (yes | …) never counts.
[[ -t 0 ]] || fail "approval needs a person at the keyboard; run this in a terminal"
read -r -p "Type yes to tag $tag and upload: " answer || fail "not approved"
[[ "$answer" == "yes" ]] || fail "not approved"

git tag "$tag"
# All or nothing: main, develop and the tag reach GitHub together, or none of them do.
git push --atomic origin main develop "$tag" || {
    echo "STOP: the push was refused, so nothing reached GitHub." >&2
    echo "Remove the local tag with: git tag -d $tag, fix the branches, and run this again." >&2
    exit 1
}
# Not --prerelease, so releases/latest always points at the newest version.
gh release create "$tag" "$zip" --repo "$repo" --title "Pomodot $version" --notes-file "$notes" || {
    echo "STOP: $tag is on GitHub but the release wasn't created." >&2
    echo "Create it with: gh release create $tag $zip --repo $repo --title \"Pomodot $version\" --notes-file $notes" >&2
    exit 1
}

downloaded="$(mktemp -d)"
scratch+=("$downloaded")
gh release download "$tag" --repo "$repo" --pattern "$(basename "$zip")" --dir "$downloaded"
local_sum="$(sha256 "$zip")"
uploaded_sum="$(sha256 "$downloaded/$(basename "$zip")")"
[[ "$local_sum" == "$uploaded_sum" ]] || {
    echo "STOP: Pomodot $version is already public, but its zip differs from $zip ($uploaded_sum vs $local_sum)." >&2
    echo "Upload the right one with: gh release upload $tag $zip --repo $repo --clobber, then check again." >&2
    exit 1
}
echo "Released Pomodot $version: https://github.com/$repo/releases/tag/$tag (sha256 $local_sum)"
