#!/bin/bash -e

cd output/result

tar czv * > ../voice_pack.tar.gz

cd ../..

ls -l output/voice_pack.tar.gz
echo ""
echo "Generating MD5 hash for the voice pack"
md5sum output/voice_pack.tar.gz
echo ""
echo "Host the file with python3 -m http.server"
echo "Visit the Valetudo web interface"
echo "Select Hamburger menu / Robot settings / Misc Settings"
echo "Enter the hosted voice pack URL, GLaDOS language code, MD5 Hash from above"
