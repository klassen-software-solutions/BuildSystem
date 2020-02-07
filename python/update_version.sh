#!/usr/bin/env bash

# Check the command arguments and state of the project.

if [ ! $# -eq 2 ]; then
    echo "usage: update_init.sh <prefix> <package>"
    exit 255
fi
prefix="$1"
package="$2"

if [ ! -f REVISION ]; then
    # Not an error, this package is just not versioned.
    exit 0
fi

packagedir="$prefix/$package"
if [ ! -d "$packagedir" ]; then
    # Not an error, this project is not package based.
    exit 0
fi

# Check if the current version has changed.

versionfile="$packagedir/_version.py"
currentversion=""
if [ -f "$versionfile" ]; then
    currentversion=$(grep "_INTERNAL_VERSION = " "$versionfile" | sed 's/_INTERNAL_VERSION = //' | sed "s/'//g")
fi

correctversion=$(cat REVISION)
echo "Setting version into $versionfile"
echo "   Current version: $currentversion"
echo "   Correct version: $correctversion"

if [ "$currentversion" == "$correctversion" ]; then
    echo "   Version is already correct, no change needed"
else
    echo "   Updating version to $correctversion"
    echo "# pylint: disable=missing-module-docstring" > "$versionfile"
    echo "#   Justification: This is an auto-generated file that should not be referenced directly" >> "$versionfile"
    echo "_INTERNAL_VERSION = '$correctversion'" >> "$versionfile"
fi

# Check if the init file references the version.

initfile="$packagedir/__init__.py"
if [ ! -f "$initfile" ]; then
    echo "Creating $initfile"
    cp BuildSystem/python/_init_file.py-template "$initfile"
else
    if ! grep "__version__" "$initfile" > /dev/null; then
        echo "Adding version reference to $initfile"
        echo "" >> "$initfile"
        grep --invert-match "^#" BuildSystem/python/_init_file.py-template >> "$initfile"
    fi
fi
