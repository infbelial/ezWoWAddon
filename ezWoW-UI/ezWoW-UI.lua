local addon = CreateFrame("Frame", nil, UIParent)

function EzWoWUI_OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        ezWoWAPI:SendInit()
        EzWoWAccountOptionsFrame_Init()
        EzWoWMultispecMenu_Init()
    end
end

addon:RegisterEvent("PLAYER_LOGIN")
addon:SetScript("OnEvent", EzWoWUI_OnEvent)
