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
        ezWoWAPI:SendMessage(string.format("INIT:%d,%d,%d;", ezWoWCache.version or 0, ezWoWCache.memberId or 0, ezWoWCache.muteHistory.lastId or 0))
    elseif event == "ADDON_LOADED" then
        local name = ...
        if name == "ElvUI" then
            ezWoWConfig.elvui = true
        elseif name == "ezWoW" then
            ezWoWAPI:Init()
            EzWoWAccountOptionsFrame_OnAddonLoaded()
        end
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, message, channel, sender = ...
        if prefix == "ezWoW" then
            ezWoWAPI:HandleMessage(message)
        end
    end
end

addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("CHAT_MSG_ADDON")
addon:SetScript("OnEvent", EzWoW_OnEvent)