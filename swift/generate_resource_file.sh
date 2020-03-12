#!/usr/bin/env bash

# Read an input file, base64 encode it, then write an output swift file that will
# present it as an input stream.
#
# Usage: generate_resource_file.sh <inputfile> <outputfile> <streamName>
#
# The <streamName> is the name presented for the resulting InputStream. So, for example,
#   generate_resource_file.sh Resources/logo.png Sources/Logo.swift logoInputStream
# will generate a file Sources/Logo.swift that will contain a computed variable
# that will look like the following:
#   var logoInputStream: InputStream { ...blah...
#

set -e

if [ $# -ne 3 ]; then
    echo "Usage: generate_resource_file.sh <inputfile> <outputfile> <streamName>"
    exit 255
fi

inFile=$1
outFile=$2
streamName=$3

echo "Generating $outFile from $inFile"
echo "Stream name will be $streamName"

if [ ! -f "$inFile" ]; then
    echo "Could not read $inFile"
    exit 255
fi

{
    echo "// This file is automatically generated by generate_resource_file.sh. DO NOT EDIT!"
    echo ""
    echo "import Foundation"
    echo ""
    echo "fileprivate let encodedString = \"\"\""
    base64 --break=80 -i "$inFile"
    echo "\"\"\""
    echo ""
    echo "var $streamName: InputStream {"
    echo "    get {"
    echo "        let decodedData = Data(base64Encoded: encodedString, options: .ignoreUnknownCharacters)!"
    echo "        return InputStream(data: decodedData)"
    echo "    }"
    echo "}"
} > "$outFile"

echo "Rebuilt $outFile"