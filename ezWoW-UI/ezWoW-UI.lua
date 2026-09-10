local addon = CreateFrame("Frame", nil, UIParent)

function EzWoWUI_OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        EzWoWAccountOptionsFrame_Init()
        ezWoWAPI:SendInit()
    end
end

addon:RegisterEvent("PLAYER_LOGIN")
addon:SetScript("OnEvent", EzWoWUI_OnEvent)