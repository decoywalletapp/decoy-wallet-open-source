"""Check the merged release manifest, including dependency permissions."""

import sys
import xml.etree.ElementTree as ET
from pathlib import Path

ANDROID_NAME = "{http://schemas.android.com/apk/res/android}name"
REQUIRED_LOCATION = {
    "android.permission.ACCESS_FINE_LOCATION",
    "android.permission.ACCESS_COARSE_LOCATION",
}


def verify_manifest(root):
    permissions = {
        element.get(ANDROID_NAME)
        for element in root
        if element.tag in {"uses-permission", "uses-permission-sdk-23"}
    }
    unexpected = {
        name for name in permissions if name and (
            name.startswith("android.permission.FOREGROUND_SERVICE")
            or name == "android.permission.ACCESS_BACKGROUND_LOCATION"
        )
    }
    if unexpected:
        raise ValueError("Unused background/service permissions: "
                         + ", ".join(sorted(unexpected)))
    missing = REQUIRED_LOCATION - permissions
    if missing:
        raise ValueError("Required in-app location permissions missing: "
                         + ", ".join(sorted(missing)))


if __name__ == "__main__":
    manifest_root = Path(sys.argv[1])
    manifests = sorted(manifest_root.rglob("AndroidManifest.xml"))
    if not manifests:
        raise SystemExit(f"No merged release manifest found in {manifest_root}")
    for manifest in manifests:
        verify_manifest(ET.parse(manifest).getroot())
        print(f"Android location permission check passed: {manifest}")
