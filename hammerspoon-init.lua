local simpleCmd = false
local map = hs.keycodes.map
local hiraganaGoogleIME = 'Hiragana (Google)'
local alphanumGoogleIME = 'Alphanumeric (Google)'
local function switchImeEvent(event)
    local c = event:getKeyCode()
    local f = event:getFlags()
    if event:getType() == hs.eventtap.event.types.keyDown then
        if f['cmd'] then
            simpleCmd = true
        end
    elseif event:getType() == hs.eventtap.event.types.flagsChanged then
        if not f['cmd'] then
            if simpleCmd == false then
                if c == map['rightcmd'] then
                    if hs.keycodes.currentMethod() == hiraganaGoogleIME then
                        hs.keycodes.setMethod(alphanumGoogleIME)
                    else
                        hs.keycodes.setMethod(hiraganaGoogleIME)
                    end
                end
            end
            simpleCmd = false
        end
    end
end

switchIme = hs.eventtap.new({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.flagsChanged}, switchImeEvent)
switchIme:start()