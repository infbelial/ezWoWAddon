local addon = CreateFrame("Frame", nil, UIParent)

local T = ezText

local function HandlePopupMenuClick(self)
    if self.value == "EZWOW_LADDER_BG" then
        EzWoWLadderFrame:SetTab(1)
        ShowUIPanel(EzWoWLadderFrame)
        DropDownList1:Hide()
    elseif self.value == "EZWOW_LADDER_ARENA" then
        EzWoWLadderFrame:SetTab(2)
        ShowUIPanel(EzWoWLadderFrame)
        DropDownList1:Hide()
    elseif self.value == "EZWOW_ACCOUNT_SETTINGS" then
        ShowUIPanel(EzWoWAccountOptionsFrame)
        DropDownList1:Hide()
    end
end

function EzWoWUI_OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        ezWoW:RegisterHandler("INIT", function()
            ezWoW:SendMessage(string.format("INIT_MODULE:main;%d;", ezWoW.bgSeason and ezWoW.bgSeason.id or 0))

            hooksecurefunc("UnitPopup_OnClick", HandlePopupMenuClick)
            
            UnitPopupButtons["EZWOW_MENU"] = { text = T.PLAYER_MENU_ITEM, dist = 0, nested = 1 }
            UnitPopupButtons["EZWOW_LADDER_BG"] = { text = T.LADDER_BG, dist = 0 }
            UnitPopupButtons["EZWOW_LADDER_ARENA"] = { text = T.LADDER_ARENA, dist = 0 }
            UnitPopupButtons["EZWOW_ACCOUNT_SETTINGS"] = { text = T.ACCOUNT_SETTINGS_HEADER, dist = 0 }
            UnitPopupMenus["EZWOW_MENU"] = { "EZWOW_LADDER_BG", "EZWOW_LADDER_ARENA", "EZWOW_ACCOUNT_SETTINGS", "CANCEL" }

            tinsert(UnitPopupMenus["SELF"], #UnitPopupMenus["SELF"] - 1, "EZWOW_MENU")

            EzWoWAccountOptionsFrame_Init()
            EzWoWMultispecMenu_Init()
        end)
    end
end

addon:RegisterEvent("PLAYER_LOGIN")
addon:SetScript("OnEvent", EzWoWUI_OnEvent)
