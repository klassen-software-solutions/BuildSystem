#!/usr/bin/env bash

if [ ! $# -eq 2 ]; then
    echo "usage: update_init.sh <prefix> <package>"
    exit 255
fi
prefix="$1"
package="$2"
filename="${prefix}/${package}/__init__.py"
if [ ! -f "$filename" ]; then
    # Not an error, this is simply not a package, hence will not be versioned.
    exit 0
fi

if [ ! -f REVISION ]; then
    # Not an error, this package is just not versioned.
    exit 0
fi

currentversion=$(grep "__version__ = " "$filename" | sed 's/__version__ = //' | sed "s/'//g")
correctversion=$(cat REVISION)
echo "Setting version into $filename"
echo "   Current version: $currentversion"
echo "   Correct version: $correctversion"

if [ "$currentversion" == "" ]; then
    echo "   No version set, appending $correctversion"
    echo "__version__ = '$correctversion'" >> "$filename"
    exit 0
fi

if [ "$currentversion" != "$correctversion" ]; then
    echo "   Updating version to $correctversion"
    mv "$filename" "${filename}.bak"
    sed "s/^__version__ = .*$/__version__ = '$correctversion'/" < "${filename}.bak" > "$filename"
    exit 0
fi

echo "   Version is already correct, no change needed"
