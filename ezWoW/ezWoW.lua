local addon = CreateFrame("Frame", nil, UIParent)

ezWoWConfig = 
{
    elvui = false,
}

ezLog = 
{
    enableDebug = false,
    enableMessages = false,

    Debug = function(self, msg, ...)
        if self.enableDebug then
            print("[DEBUG]: ", msg, ...)
        end
    end,
    Messages = function(self, source, msg)
        if self.enableMessages then
            print(string.format("[%s]: %s", source, msg))
        end
    end
}

function EzWoW_OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        ezWoW:SendMessage(string.format('INIT:%d;', ezWoWCache.version or 0))
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
        elseif name == "ezWoW" then
            ezWoW:Init()
        end
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, message, channel, sender = ...
        if prefix == "ezWoW" then
            ezWoW:HandleMessage(message)
        end
    end
end

addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("ADDON_LOADED")
addon:RegisterEvent("CHAT_MSG_ADDON")
addon:SetScript("OnEvent", EzWoW_OnEvent)
