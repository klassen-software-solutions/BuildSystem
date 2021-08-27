#!/usr/bin/env bash

# Search for Info.plist files and update the build version "Bundle versions string, short"
# in each of them. Note that we ignore directories in the Build and that end with "Tests".
#
# The build version is defined as the number of commits+1 on the current branch since
# the original. (The reason for the +1 is for the commit that will include this change.)

set -e

versionFromGit=$(BuildSystem/common/revision.sh)
#echo "Version from GIT: $versionFromGit"

build=$(git rev-list --count HEAD)
build=$((build+1))
#echo "Build number: $build"

plists=$(find . -name Info.plist | grep --invert-match "/Build/" | grep --invert-match "Tests/")
for plist in $plists; do
    echo "In $plist..."
    buildFromPlist=$(plutil -extract CFBundleVersion xml1 -o - "$plist" | xpath "plist/string/text()" 2> /dev/null)
    if [ "$buildFromPlist" == "$build" ]; then
        echo "   not changed, is already at '$buildFromPlist'"
    else
        plutil -replace CFBundleVersion -string "$build" "$plist"
        echo "   changed from '$buildFromPlist' to '$build'"
    fi

    versionFromPlist=$(plutil -extract CFBundleShortVersionString xml1 -o - "$plist" | xpath "plist/string/text()" 2> /dev/null)
    if [ "$versionFromGit" != "$versionFromPlist" ]; then
        echo "   current version is $versionFromPlist, from GIT tag is $versionFromGit"
    fi
done
