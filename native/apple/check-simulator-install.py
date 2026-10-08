"""Verify simulator installation of the phone bundle and standalone Watch app."""
import json
import pathlib
import plistlib
import re
import subprocess


def simctl(*args, timeout=120):
    return subprocess.run(
        ["xcrun", "simctl", *map(str, args)], check=True, timeout=timeout
    )


devices = json.loads(subprocess.check_output(
    ["xcrun", "simctl", "list", "devices", "available", "--json"]
))["devices"]
iphone = pathlib.Path("build/apple/Build/Products/Debug-iphonesimulator/Moment.app")
watch = pathlib.Path("build/watch/Build/Products/Debug-watchsimulator/MomentWatch.app")
embedded = list(iphone.rglob("MomentWatch.app"))
if len(embedded) != 1:
    raise SystemExit(f"Expected one embedded Watch app; found: {embedded}")
print(f"Embedded Watch location: {embedded[0]}", flush=True)

for platform, name_prefix, app in [
    ("iOS", "iPhone", iphone),
    ("watchOS", "Apple Watch", watch),
]:
    candidates = [
        (tuple(map(int, re.findall(r"\d+", runtime.rsplit(".", 1)[-1]))), device)
        for runtime, entries in devices.items()
        if runtime.startswith(f"com.apple.CoreSimulator.SimRuntime.{platform}-")
        for device in entries
        if device.get("isAvailable") and device["name"].startswith(name_prefix)
    ]
    if not candidates:
        raise SystemExit(f"No available {platform} simulator on runner")
    version, device = max(candidates, key=lambda item: item[0])
    udid = device["udid"]
    with (app / "Info.plist").open("rb") as file:
        bundle_id = plistlib.load(file)["CFBundleIdentifier"]
    print(f"Installing {app} on {device['name']} / {version}", flush=True)
    try:
        simctl("bootstatus", udid, "-b", timeout=600)
        simctl("install", udid, app.resolve())
        simctl("get_app_container", udid, bundle_id, "app")
        simctl("launch", udid, bundle_id)
    finally:
        subprocess.run(["xcrun", "simctl", "shutdown", udid], check=False, timeout=60)
