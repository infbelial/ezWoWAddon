local T = ezWoWText

function ElvUIFixGameMenuButton(button)
    if button.isSkinned then
        return
    end

    if ezWoWConfig.elvui then
		local E = LibStub("AceAddon-3.0"):GetAddon("ElvUI", true)
		if E then
            local S = E:GetModule("Skins")
            if S then
                S:HandleButton(button)
            end
		end
	end

    button.isSkinned = true
end

-- floating point shenenigans
local function IsSameRateValue(a, b)
    return math.abs(a - b) < 1e-8
end

function EzWoWAccountOptionsFrame_OnLoad(self)
    OptionsFrame_OnLoad(self)
    
    _G[self:GetName().."HeaderText"]:SetText(T.ACCOUNT_SETTINGS_HEADER);
end

function EzWoWAccountOptionsFrame_UpdateUI()
    -- option.clientValue is state of UI on the moment of opening
    -- Because technically other account can change option while menu is opened

    local self = EzWoWAccountOptionsFrame

    for _, checkBox in pairs(self.checkBoxes) do
        local option = ezWoWAPI.options[checkBox.optionKey]
        checkBox:SetChecked(option.value)
        checkBox.clientValue = tonumber(option.value)
    end

    for _, control in pairs(self.rateSliders) do
        local option = ezWoWAPI.options[control.optionKey]
        control.clientValue = tonumber(option.value)

        EzWoWRateControl_UpdateUI(control)
    end

    for _, dropDown in pairs(self.dropDowns) do
        local value = tonumber(ezWoWAPI.options[dropDown.optionKey].value)
        dropDown.clientValue = value
        UIDropDownMenu_SetSelectedValue(dropDown, value, false)
    end

    EzWoWAccountOptionsLootPanel_UpdateUI()
    EzWoWAccountOptionsDisplayPanel_UpdateUI()

    -- Will be enabled because we set all the values
    EzWoWAccountOptionsFrameApply:Disable()
end

function EzWoWAccountOptionsFrame_OnShow(self)
    if self.previousFrame then
        HideUIPanel(self.previousFrame)
    end

    OptionsFrame_OnShow(self)

    EzWoWAccountOptionsFrame_UpdateUI(self)
end

function EzWoWAccountOptionsFrame_OnHide(self)
    OptionsFrame_OnHide(self);

    if self.previousFrame then
        ShowUIPanel(self.previousFrame)
        self.previousFrame = nil
    end
end

function EzWoWAccountOptionsFrame_OnMouseDown(self)
    if self.currentFocus then
        self.currentFocus:ClearFocus()
    end
end

function EzWoWAccountOptionsFrame_OnAddonLoaded()
    local self = EzWoWAccountOptionsFrame

    local button = CreateFrame("Button", "GameMenuButtonAccountOptions", GameMenuFrame, "GameMenuButtonTemplate")
    button:SetText(T.MENU_BUTTON_ACCOUNT)
    button:HookScript("OnShow", function() ElvUIFixGameMenuButton(button) end)

    -- GameMenuButtonOptions is anchored in that way and each menu button below anchored to one above.
    -- As per GameMenuFrame.xml
    button:SetPoint("CENTER", GameMenuFrame, "TOP", 0, -37)
    GameMenuButtonOptions:SetPoint("TOP", button, "BOTTOM", 0, -1)

    -- Resize game menu for button height + gap
    GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + button:GetHeight() + 1)
    button:SetScript("OnClick", function()
        PlaySound("igMainMenuOption");
        self.previousFrame = GameMenuFrame
		ShowUIPanel(self);
    end)
    table.insert(UISpecialFrames, self:GetName())

    -- Add panels (because we can easily change the order here)
    EzWoWAccountOptionsFrame_AddCategory(EzWoWAccountOptionsInformationPanel, "MENU_INFO")
    EzWoWAccountOptionsFrame_AddCategory(EzWoWAccountOptionsLootPanel, "MENU_LOOT")
    EzWoWAccountOptionsFrame_AddCategory(EzWoWAccountOptionsRatesPanel, "MENU_RATES")
    EzWoWAccountOptionsFrame_AddCategory(EzWoWAccountOptionsDisplayPanel, "MENU_DISPLAY")
    EzWoWAccountOptionsFrame_AddCategory(EzWoWAccountOptionsPrivacyPanel, "MENU_PRIVACY")
    EzWoWAccountOptionsFrame_AddCategory(EzWoWAccountOptionsCollectionsPanel, "MENU_COLLECTIONS")
    EzWoWAccountOptionsFrame_AddCategory(EzWoWAccountOptionsArenaPanel, "MENU_ARENA")
    EzWoWAccountOptionsFrame_AddCategory(EzWoWAccountOptionsSystemMessagesPanel, "MENU_SYS_MESSAGES")

end

function EzWoWAccountOptionsFrame_AddCategory(panel, key)
    local self = EzWoWAccountOptionsFrame

    panel.name = T[key.."_TITLE"]

    _G[panel:GetName().."Title"]:SetText(T[key.."_TITLE"])
    _G[panel:GetName().."SubText"]:SetText(T[key.."_SUB_TEXT"])

    OptionsFrame_AddCategory(self, panel)
end
    
function EzWoWAccountOptionsFrame_RegisterCheckBox(control, category)
    local self = EzWoWAccountOptionsFrame

    if not self.checkBoxes then
        self.checkBoxes = {}
    end
    table.insert(self.checkBoxes, control)
    ezWoWAPI:CreateOption(control.optionKey, category)
end

function EzWoWAccountOptionsFrame_RegisterRateSlider(control, category)
    local self = EzWoWAccountOptionsFrame

    if not self.rateSliders then
        self.rateSliders = {}
    end
    table.insert(self.rateSliders, control)
    ezWoWAPI:CreateOption(control.optionKey, category)
end

function EzWoWAccountOptionsFrame_RegisterDropDown(control, category)
    local self = EzWoWAccountOptionsFrame

    if not self.dropDowns then
        self.dropDowns = {}
    end
    table.insert(self.dropDowns, control)

    ezWoWAPI:CreateOption(control.optionKey, category)
end

function EzWoWAccountOptionsFrame_ApplyOptions(frame)
    -- option.clientValue is state of UI on the moment of opening, compare to it and not to option.value

    if frame.checkBoxes then
        for _, button in pairs(frame.checkBoxes) do
            local value = button:GetChecked() or 0
            if value ~= button.clientValue then
                button.clientValue = value
                ezWoWAPI:SetOption(button.optionKey, value)
            end
        end
    end

    if frame.dropDowns then
        for _, dropDown in pairs(frame.dropDowns) do
            local value = UIDropDownMenu_GetSelectedValue(dropDown)
            if value ~= dropDown.clientValue then
                dropDown.clientValue = value
                ezWoWAPI:SetOption(dropDown.optionKey, value)
            end
        end
    end

    if frame.rateSliders then
        for _, control in pairs(frame.rateSliders) do
            local dropDown = _G[control:GetName().."DropDown"]
            local slider = _G[control:GetName().."Slider"]
            local value = -1;

            if UIDropDownMenu_GetSelectedID(dropDown) == 2 then
                value = control.realValue
            end
            if not IsSameRateValue(value, control.clientValue) then
                control.clientValue = value
                ezWoWAPI:SetOption(control.optionKey, value)
            end
        end
    end
end


local function ResetAll()
    local msg = "SET_OPT:"
    for key, option in pairs(ezWoWAPI.options) do
        if key:find("RATE_") == 1 then
            msg = string.format("%s%s=%f;", msg, key, option.defaultValue)
        else
            msg = string.format("%s%s=%d;", msg, key, option.defaultValue)
        end
        option.value = option.defaultValue
    end
    ezWoWAPI:SendMessage(msg)
    EzWoWAccountOptionsFrame_UpdateUI()
end

local function ResetCrrentCategory()
    local category = EzWoWAccountOptionsFramePanelContainer.displayedPanel:GetAttribute("category")
    local msg = "SET_OPT:"
    for key, option in pairs(ezWoWAPI.options) do
        if option.category == category then
            if key:find("RATE_") == 1 then
                msg = string.format("%s%s=%f;", msg, key, option.defaultValue)
            else
                msg = string.format("%s%s=%d;", msg, key, option.defaultValue)
            end
            option.value = option.defaultValue
        end
    end
    ezWoWAPI:SendMessage(msg)
    EzWoWAccountOptionsFrame_UpdateUI()
end

StaticPopupDialogs["CONFIRM_RESET_ACCOUNT_SETTINGS"] =
{ 
	text = T.CONFIRM_RESET_ACCOUNT_SETTINGS,
	button1 = ALL_SETTINGS,
	button3 = CURRENT_SETTINGS,
	button2 = CANCEL,
	OnAccept = ResetAll,
	OnAlt = ResetCrrentCategory,
	OnCancel = function() end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
}

