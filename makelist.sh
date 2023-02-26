#!/usr/bin/env bash

json=$(curl https://fdroid.gitlab.io/mirror-monitor/report.json)
timestamps=$(echo "($(echo $json | grep -o '"https://f-droid.org/repo": {[^\}]* "timestamp": [0-9]*' | grep -o '"timestamp": [0-9]*' | grep -o '[0-9]*' | tail -30 | tr "\n" "|" | sed -e "s/|$//"))")
res=$(echo $json | grep -Eo "\"https://[^\"]*\": {[^\}]* \"fingerprint\": \"43238D512C1E5EB2D6569F4A3AFBF5523418B82E0A3ED1552770ABB9A9C9CCAB\", [^\}]* \"timestamp\": $timestamps" | grep -o "^\"https://[^\"]*" | tr -d '"' | sort | uniq -c | sort -n | awk '{if ($1>=29) print $2}' | sort)

rm -rf QR
mkdir QR

echo "$res" > fdroidmirrors
echo "# f-droid-mirrorlist
Generator of list of f-droid mirror server urls. The script retrieves data from https://fdroid.gitlab.io/mirror-monitor/." > README.md

for mirror in $res
do
  name=$(echo $mirror | grep -o 'https://[^/]*' | sed -e "s%https://%%")
  qrencode -t UTF8 "${mirror}?fingerprint=43238D512C1E5EB2D6569F4A3AFBF5523418B82E0A3ED1552770ABB9A9C9CCAB" -o QR/$name.txt
  qrencode -t PNG "${mirror}?fingerprint=43238D512C1E5EB2D6569F4A3AFBF5523418B82E0A3ED1552770ABB9A9C9CCAB" -o QR/$name.png
  echo "
## ${mirror}" >>README.md
  echo "
![${name}](https://raw.githubusercontent.com/fuzmare/f-droid-mirrorlist/main/QR/${name}.png)" >> README.md
done

