-- Script AppleScript pour ouvrir DevTools avec Device Emulation dans Comet
-- Utilisation: osascript scripts/open_comet_devtools.applescript
-- Version améliorée avec gestion d'erreurs et retry

on run
    try
        -- Vérifier que Comet est installé
        tell application "System Events"
            if not (exists process "Comet") then
                -- Essayer de lancer Comet si pas déjà lancé
                try
                    tell application "Comet" to activate
                    delay 3
                on error
                    return false
                end try
            end if
        end tell
        
        -- Activer Comet
        tell application "Comet"
            activate
        end tell
        
        -- Attendre que Comet soit complètement chargé
        delay 2
        
        -- S'assurer que Comet est au premier plan
        tell application "System Events"
            tell process "Comet"
                set frontmost to true
                delay 0.5
                
                -- Essayer d'ouvrir DevTools avec Cmd+Option+I
                -- Faire plusieurs tentatives si nécessaire
                repeat 3 times
                    try
                        keystroke "i" using {command down, option down}
                        delay 2
                        exit repeat
                    on error
                        delay 1
                    end try
                end repeat
                
                -- Attendre que DevTools s'ouvre
                delay 1.5
                
                -- Activer Device Emulation avec Cmd+Shift+M
                -- Faire plusieurs tentatives si nécessaire
                repeat 3 times
                    try
                        keystroke "m" using {command down, shift down}
                        delay 1.5
                        exit repeat
                    on error
                        delay 0.5
                    end try
                end repeat
                
                -- Attendre que le device emulation s'active
                delay 1
            end tell
        end tell
        
        return true
    on error errorMessage
        -- En cas d'erreur, retourner false
        return false
    end try
end run

