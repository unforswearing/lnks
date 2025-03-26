#!/usr/bin/osascript

# Get all urls from all tabs of all open windows in Chrome.
tell application "Google Chrome"
    get URL of tabs of windows
end tell
