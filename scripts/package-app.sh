#!/bin/zsh
set -euo pipefail

project_root="${0:A:h:h}"
configuration="${1:-release}"
app_bundle="$project_root/build/Lamina.app"
icon_source="$project_root/Support/AppIcon.svg"
icon_work="$project_root/build/icon-work"

cd "$project_root"
swift build -c "$configuration"
binary_directory="$(swift build -c "$configuration" --show-bin-path)"

rm -rf "$app_bundle"
mkdir -p "$app_bundle/Contents/MacOS" "$app_bundle/Contents/Resources"
cp "$project_root/Support/Info.plist" "$app_bundle/Contents/Info.plist"
cp "$binary_directory/Lamina" "$app_bundle/Contents/MacOS/Lamina"

if [[ -d "$binary_directory/Lamina_Lamina.bundle" ]]; then
    cp -R "$binary_directory/Lamina_Lamina.bundle" "$app_bundle/Contents/Resources/"
fi

rm -rf "$icon_work"
mkdir -p "$icon_work/AppIcon.iconset"
qlmanage -t -s 1024 -o "$icon_work" "$icon_source" >/dev/null 2>&1
master_icon="$icon_work/AppIcon.svg.png"

for size in 16 32 128 256 512; do
    sips -z "$size" "$size" "$master_icon" --out "$icon_work/AppIcon.iconset/icon_${size}x${size}.png" >/dev/null
    retina=$((size * 2))
    sips -z "$retina" "$retina" "$master_icon" --out "$icon_work/AppIcon.iconset/icon_${size}x${size}@2x.png" >/dev/null
done

iconutil -c icns "$icon_work/AppIcon.iconset" -o "$app_bundle/Contents/Resources/AppIcon.icns"
rm -rf "$icon_work"

codesign --force --deep --sign - "$app_bundle"
echo "$app_bundle"
