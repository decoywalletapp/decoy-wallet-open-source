import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

from verify_android_permissions import (
    ANDROID_NAME,
    REQUIRED_LOCATION,
    verify_manifest,
)


class AndroidPermissionTests(unittest.TestCase):
    def manifest(self, extra=()):
        root = ET.Element("manifest")
        for permission in REQUIRED_LOCATION | set(extra):
            ET.SubElement(root, "uses-permission", {ANDROID_NAME: permission})
        return root

    def test_preserves_normal_location_access(self):
        verify_manifest(self.manifest())

    def test_rejects_unused_service_and_background_permissions(self):
        for name in ("FOREGROUND_SERVICE_LOCATION", "FOREGROUND_SERVICE",
                     "ACCESS_BACKGROUND_LOCATION"):
            with self.subTest(permission=name), self.assertRaises(ValueError):
                verify_manifest(self.manifest(["android.permission." + name]))

    def test_rejects_missing_in_app_location_permissions(self):
        with self.assertRaises(ValueError):
            verify_manifest(ET.Element("manifest"))

    def test_source_removes_only_the_unused_service_permission(self):
        root = ET.parse(Path(__file__).resolve().parents[1]
                        / "android/app/src/main/AndroidManifest.xml").getroot()
        permissions = {element.get(ANDROID_NAME): element
                       for element in root.findall("uses-permission")}
        tools_node = "{http://schemas.android.com/tools}node"
        self.assertEqual(permissions[
            "android.permission.FOREGROUND_SERVICE_LOCATION"
        ].get(tools_node), "remove")
        for name in REQUIRED_LOCATION:
            self.assertIsNone(permissions[name].get(tools_node))


if __name__ == "__main__":
    unittest.main()
