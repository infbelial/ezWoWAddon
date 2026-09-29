local addon = CreateFrame("Frame", nil, UIParent)

local function HandlePopupMenuClick(self)
    if self.value == "EZWOW_LADDER_BG" then
        EzWoWLadderFrame:SetTab(1)
        ShowUIPanel(EzWoWLadderFrame)
        DropDownList1:Hide()
    elseif self.value == "EZWOW_LADDER_ARENA" then
        EzWoWLadderFrame:SetTab(2)
        ShowUIPanel(EzWoWLadderFrame)
        DropDownList1:Hide()
    end
end

function EzWoWUI_OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        ezWoW:RegisterHandler("INIT", function()
            ezWoW:SendMessage(string.format("INIT_MODULE:main;%d;", ezWoW.bgSeason and ezWoW.bgSeason.id or 0))

            hooksecurefunc("UnitPopup_OnClick", HandlePopupMenuClick)
            
            UnitPopupButtons["EZWOW_MENU"] = { text = "Дополнительно", dist = 0, nested = 1 }
            UnitPopupButtons["EZWOW_LADDER_BG"] = { text = "Ладдер полей боя", dist = 0 }
            UnitPopupButtons["EZWOW_LADDER_ARENA"] = { text = "Ладдер арены", dist = 0 }
            UnitPopupMenus["EZWOW_MENU"] = { "EZWOW_LADDER_BG", "EZWOW_LADDER_ARENA", "CANCEL" }

            tinsert(UnitPopupMenus["SELF"], #UnitPopupMenus["SELF"] - 1, "EZWOW_MENU")

            EzWoWAccountOptionsFrame_Init()
            EzWoWMultispecMenu_Init()
            EzWoWLadder_Init()
        end)
    end
end

addon:RegisterEvent("PLAYER_LOGIN")
addon:SetScript("OnEvent", EzWoWUI_OnEvent)
