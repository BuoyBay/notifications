#!/usr/bin/env python3
"""Rebuild the tiny macOS Objective-C block bridge before sealing this package."""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess
import sys
ROOT = Path(__file__).resolve().parent
if sys.platform != 'darwin':
    raise SystemExit('Rebuilding the notification bridge requires macOS and Xcode command-line tools.')
output = ROOT / 'runtime/arm64-apple-macos/libbuoy_notifications.dylib'
output.parent.mkdir(parents=True, exist_ok=True)
subprocess.run(['xcrun','clang','-dynamiclib','-fobjc-arc','-arch','arm64','-arch','x86_64',
                '-mmacosx-version-min=11.0','-framework','Foundation','-framework','UserNotifications',
                '-install_name','@rpath/libbuoy_notifications.dylib',str(ROOT/'native/bridge.m'),'-o',str(output)],check=True)
other = ROOT / 'runtime/x86_64-apple-macos/libbuoy_notifications.dylib'
other.parent.mkdir(parents=True, exist_ok=True)
shutil.copy2(output,other)
receipt = {'schema': 1,
           'inputs': {name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
                      for name in ['native/bridge.m', 'build_native.py']},
           'outputs': {p.relative_to(ROOT).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
                       for p in [output, other]}}
(ROOT / 'native-build.json').write_text(json.dumps(receipt, indent=2) + '\n')
print('Built universal arm64/x86_64 notification bridge')
