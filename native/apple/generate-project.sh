#!/bin/sh
set -eu
cd "$(dirname "$0")"
if ! command -v xcodegen >/dev/null 2>&1; then
  echo 'Install XcodeGen on your Mac with: brew install xcodegen'
  exit 1
fi
xcodegen generate --spec project.yml
echo 'Open Moment.xcodeproj in Xcode, set your team and bundle identifiers, then run Moment or MomentWatch.'
