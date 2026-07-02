local addon = CreateFrame("Frame", nil, UIParent)
ezWoWConfig = 
{
    elvui = false,
}

function EzWoW_OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        if ezWoWConfig.elvui then
            local elvui = LibStub("AceAddon-3.0"):GetAddon("ElvUI", true)
            if elvui then
                local module = elvui:GetModule("Skins")
                if module then
                    module:HandleTab(LFDParentFrameTab1)
                    module:HandleTab(LFDParentFrameTab2)
                end
            end
        end
    elseif event == "ADDON_LOADED" then
        local name = ...
        if name == "ElvUI" then
            ezWoWConfig.elvui = true
        end
    end
end

addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("ADDON_LOADED")
addon:SetScript("OnEvent", EzWoW_OnEvent)