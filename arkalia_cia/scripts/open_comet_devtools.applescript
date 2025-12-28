-- Script AppleScript pour ouvrir DevTools avec Device Emulation dans Comet
-- Utilisation: osascript scripts/open_comet_devtools.applescript

tell application "Comet"
    activate
    delay 1
    
    -- Ouvrir DevTools avec Cmd+Option+I
    tell application "System Events"
        keystroke "i" using {command down, option down}
        delay 1
        
        -- Activer Device Emulation avec Cmd+Shift+M
        keystroke "m" using {command down, shift down}
        delay 0.5
    end tell
end tell

