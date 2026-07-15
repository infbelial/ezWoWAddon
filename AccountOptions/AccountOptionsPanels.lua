local T = ezWoWText

function EzWoWAccountOptionsBaseCheckButtonTemplate_OnClick(self)
	if self:GetChecked() then
	    PlaySound("igMainMenuOptionCheckBoxOn")
	else
	    PlaySound("igMainMenuOptionCheckBoxOff")
	end
    EzWoWAccountOptionsFrameApply:Enable()
end


function EzWoWOptionsCheckButton_OnLoad(self, key, category)
    self.optionKey = key
    textKey = "OPT_"..key;

    local text = _G[self:GetName().."Text"]
    text:SetJustifyH("LEFT")
    text:SetWidth(350)

    self.tooltipText = ezWoWText[textKey.."_TOOLTIP"]
    local buttonText = _G[self:GetName().."Text"]
    buttonText:SetText(ezWoWText[textKey])
    self:SetHitRectInsets(0, -(buttonText:GetWidth() + 15), 0, 0)

    EzWoWAccountOptionsFrame_RegisterCheckBox(self, category)
end


function EzWoWOptionsDropDown_OnLoad(self, key, category, width)
    self.optionKey = key
    _G[self:GetName().."Label"]:SetText(T["OPT_"..key])

    if width then
        UIDropDownMenu_SetWidth(self, width)
    end
    EzWoWAccountOptionsFrame_RegisterDropDown(self, category)
end

local function UpdateStatus(self, name, text)
    local parent = self:GetName()
    _G[parent.."Name"]:SetText(name)
    _G[parent.."Status"]:SetText(text)
end

function EzWoWAccountOptionsInformationPanel_OnShow(self)
    EzWoWAccountOptionsInformationPanelTitle:SetText(T.INFO_ACCOUNT:format(ezWoWAPI.account))
    EzWoWSubscriptionsPanelTitle:SetText(T.INFO_SUBSCRIPTIONS)

    EzWoWAccountOptionsInformationPanel_UpdateUI(self, 0)
    
end

local function UpdateSubscriptionStatus(panel, name, endTime, now)
    local status = T.INFO_SUB_NOT_ACTIVE
    if endTime > 0 and endTime > now then
        local duration = endTime - now
        local days = math.floor(duration / 86400)
        local hours = math.floor((duration / 86400) / 3600)
        local minutes = math.floor((duration % 3600) / 60)
        local seconds = duration % 60

        if days > 0 then
            status = string.format(T.INFO_SUB_STATUS_DAYS, days)
        elseif hours > 0 then
            status = string.format(T.INFO_SUB_STATUS_HOURS_MINUTES, hours, minutes)
        elseif minutes > 0 then
            status = string.format(T.INFO_SUB_STATUS_MINUTES_SECONDS, minutes, seconds)
        else
            status = string.format(T.INFO_SUB_STATUS_MINUTES_SECONDS, seconds)
        end

        status = string.format(T.INFO_SUB_ACTIVE, date("%d-%m-%Y", endTime), status)

    end
    UpdateStatus(panel, name, status)
end

function EzWoWAccountOptionsInformationPanel_UpdateUI(self, elapsed)
    local now = time()

    if self.lastUpdate == now then
        return
    end

    self.lastUpdate = now

    local muteStatus = T.INFO_NO_MUTE;
    if ezWoWAPI.muteEnd > 0 then
        local timeInSeconds = ezWoWAPI.muteEnd - now
        local hours = math.floor(timeInSeconds / 3600)
        local minutes = math.floor((timeInSeconds % 3600) / 60)
        local seconds = timeInSeconds % 60
        if hours > 0 then
            muteStatus = string.format("|cFFFF0000%u |4час:часа:часов; %u |4минута:минуты:минут; %u |4секунда:секунды:секунд;|r", hours, minutes, seconds)
        elseif minutes > 0 then
            muteStatus = string.format("|cFFFF0000%u |4минута:минуты:минут; %u |4секунда:секунды:секунд;|r", minutes, seconds)
        else
            muteStatus = string.format("|cFFFF0000%u |4секунда:секунды:секунд;|r", seconds)
        end
    end

    UpdateStatus(EzWoWAccountInfoChatMute, T.INFO_MUTE, muteStatus)

    UpdateSubscriptionStatus(EzWoWAccountInfoPremium, T.INFO_PREMIUM, ezWoWAPI.subscriptions["PREMIUM"], now)
    UpdateSubscriptionStatus(EzWoWAccountInfoEzPlus, T.INFO_EZPLUS, ezWoWAPI.subscriptions["EZPLUS"], now)
    UpdateSubscriptionStatus(EzWoWAccountInfoMountsSub, T.INFO_SUB_PETS_MOUNTS_TOYS, ezWoWAPI.subscriptions["PETS_MOUNTS_TOYS"], now)
    UpdateSubscriptionStatus(EzWoWAccountInfoTransmogSub, T.INFO_SUB_TRANSMOG, ezWoWAPI.subscriptions["TRANSMOG"], now)
    UpdateSubscriptionStatus(EzWoWAccountInfoSkinsSub, T.INFO_SUB_SKINS, ezWoWAPI.subscriptions["SKINS"], now)
end


local function DisableCheckButton(button)
    button:Disable()
    _G[button:GetName().."Text"]:SetTextColor(0.5, 0.5, 0.5)
end

local function EnableCheckButton(button)
    button:Enable()
    _G[button:GetName().."Text"]:SetTextColor(1, 0.82, 0)
end


function EzWoWOptionLootPartial_OnClick(self)
    EzWoWAccountOptionsBaseCheckButtonTemplate_OnClick(self)
    EzWoWAccountOptionsLootPanel_UpdateUI()
end


function EzWoWOptionLootAoE_OnClick(self)
    EzWoWAccountOptionsBaseCheckButtonTemplate_OnClick(self)
    EzWoWAccountOptionsLootPanel_UpdateUI()
end


function EzWoWAccountOptionsLootPanel_UpdateUI()
    if EzWoWOptionLootPartial:GetChecked() then
        EnableCheckButton(EzWoWOptionLootAoE)
        if EzWoWOptionLootAoE:GetChecked() then
            EnableCheckButton(EzWoWOptionLootAoERadius)
            EnableCheckButton(EzWoWOptionLootAoEVisual)
        else
            DisableCheckButton(EzWoWOptionLootAoERadius)
            DisableCheckButton(EzWoWOptionLootAoEVisual)
        end
    else
        DisableCheckButton(EzWoWOptionLootAoE)
        DisableCheckButton(EzWoWOptionLootAoERadius)
        DisableCheckButton(EzWoWOptionLootAoEVisual)
    end
end


function EzWoWAccountOptionsDisplayPanel_UpdateUI()
    if EzWoWOptionShowTransmog:GetChecked() then
        EnableCheckButton(EzWoWOptionShowTransmogMixed)
    else
        DisableCheckButton(EzWoWOptionShowTransmogMixed)
    end
end


function EzWoWBGRaceDropDown_OnLoad(self)
    self.optionKey = "BG_RACE_MODE"
    _G[self:GetName().."Label"]:SetText(T.OPT_BG_RACE_MODE)

    UIDropDownMenu_SetWidth(self, 150)

    EzWoWAccountOptionsFrame_RegisterDropDown(self, "DISPLAY")
end


local function SelectDropDownValue(dropDown, value)
    UIDropDownMenu_SetSelectedValue(dropDown, value, false)
    EzWoWAccountOptionsFrameApply:Enable()
end


function EzWoWBGRaceDropDown_Init(self)
    local info = UIDropDownMenu_CreateInfo()
    info.text = T.BG_RACE_DONT_CHANGE
    info.value = 0
    info.func = function() SelectDropDownValue(self, 0) end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = T.BG_RACE_RELATIVE_TO_ME
    info.value = 1
    info.func = function() SelectDropDownValue(self, 1) end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = T.BG_RACE_RELATIVE_TO_BG_TEAM_EXCLUDING_ME
    info.value = 2
    info.func = function() SelectDropDownValue(self, 2) end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = T.BG_RACE_RELATIVE_TO_BG_TEAM_INCLUDING_ME
    info.value = 3
    info.func = function() SelectDropDownValue(self, 3) end
    UIDropDownMenu_AddButton(info)
end


function EzWoWPrivacy_InitDropDown(self)
    local info = UIDropDownMenu_CreateInfo()
    info.text = ezWoWText.PRIVACY_ALL
    info.value = 0
    info.func = function() SelectDropDownValue(self, 0) end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = ezWoWText.PRIVACY_FRIENDS
    info.value = 1
    info.func = function() SelectDropDownValue(self, 1) end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = ezWoWText.PRIVACY_NOBODY
    info.value = 2
    info.func = function() SelectDropDownValue(self, 2) end
    UIDropDownMenu_AddButton(info)
end


function EzWoWRateControl_OnLoad(self, key, category)
    self.optionKey = key
    local name = self:GetName()

    _G[name.."Text"]:SetText(ezWoWText["OPT_"..key])

    local slider = _G[name.."Slider"]
    slider.optionKey = key

    local edit = _G[name.."Edit"]
    edit.optionKey = key
    edit:SetAutoFocus(false)

    EzWoWAccountOptionsFrame_RegisterRateSlider(self, category)

    EzWoWRatesSlider_InitRates(slider)

    self:SetBackdropBorderColor(0.5, 0.5, 0.5);
	self:SetBackdropColor(0.15, 0.15, 0.15);
end


function EzWoWRateControl_UpdateUI(self)
    local option = ezWoWAPI.options[self.optionKey]

    local value = tonumber(option.value)

    local slider = _G[self:GetName().."Slider"]
    local dropDown = _G[self:GetName().."DropDown"]

    EzWoWRatesSlider_InitRates(slider)

    local _, max = slider:GetMinMaxValues()

    if value == -1 then
        UIDropDownMenu_SetSelectedID(dropDown, 1)
        value = max
    else
        UIDropDownMenu_SetSelectedID(dropDown, 2)
    end

    -- set slider value and realValue
    EzWoWRateSlider_SetValue(self, value)
    EzWoWRateControl_UpdateDropDown(self)
end


function EzWoWRateControl_UpdateDropDown(self)
    local sliderName = self:GetName().."Slider"
    local slider = _G[sliderName]
    local edit = _G[self:GetName().."Edit"]
    local dropDown = _G[self:GetName().."DropDown"]

    if UIDropDownMenu_GetSelectedID(dropDown) == 1 then 
        slider:Disable()
        _G[sliderName.."Low"]:SetTextColor(0.5, 0.5, 0.5)
        _G[sliderName.."High"]:SetTextColor(0.5, 0.5, 0.5)
        _G[sliderName.."Thumb"]:Hide()
        local _, max = slider:GetMinMaxValues()
        edit:SetText(max)
        edit:SetTextColor(0.5, 0.5, 0.5)
        edit:EnableMouse(false)
        PlaySound("igMainMenuOptionCheckBoxOff")
    else
        slider:Enable()
        _G[sliderName.."Low"]:SetTextColor(1, 1, 1)
        _G[sliderName.."High"]:SetTextColor(1, 1, 1)
        _G[sliderName.."Thumb"]:Show()
        edit:SetText(tostring(self.realValue))
        edit:SetTextColor(1, 1, 1)
        edit:EnableMouse(true)
        PlaySound("igMainMenuOptionCheckBoxOn")
    end

    EzWoWAccountOptionsFrameApply:Enable()
end


local function SetMaxRate(dropDown)
    UIDropDownMenu_SetSelectedID(dropDown, 1)
    EzWoWRateControl_UpdateDropDown(dropDown:GetParent())
    if EzWoWAccountOptionsFrame.currentFocus then
        EzWoWAccountOptionsFrame.currentFocus:ClearFocus()
        EzWoWAccountOptionsFrame.currentFocus = nil
    end
end


local function SetFixedRate(dropDown)
    UIDropDownMenu_SetSelectedID(dropDown, 2)
    EzWoWRateControl_UpdateDropDown(dropDown:GetParent())
    if EzWoWAccountOptionsFrame.currentFocus then
        EzWoWAccountOptionsFrame.currentFocus:ClearFocus()
        EzWoWAccountOptionsFrame.currentFocus = nil
    end
end


function EzWoWRateDropDown_OnLoad(self)
    local info  = UIDropDownMenu_CreateInfo()
    info.text   = ezWoWText.MENU_RATES_MAXIMUM
    info.value  = ezWoWText.MENU_RATES_MAXIMUM
    info.func   = function() SetMaxRate(self) end 
    UIDropDownMenu_AddButton(info);

    info        = UIDropDownMenu_CreateInfo()
    info.text   = ezWoWText.MENU_RATES_FIXED
    info.value  = ezWoWText.MENU_RATES_FIXED
    info.func   = function() SetFixedRate(self) end 
    UIDropDownMenu_AddButton(info);
end


function EzWoWRateSlider_OnValueChanged(self, value)
    if self.changingText then
        return
    end

    -- This is draging the slider
    local parent = self:GetParent()
    parent.realValue = value
    if value % 1 < 1e-06 then
        _G[parent:GetName().."Edit"]:SetText(tostring(value))
    else
        _G[parent:GetName().."Edit"]:SetText(string.format("%.2f",value))
    end
    EzWoWAccountOptionsFrameApply:Enable()
end


function EzWoWRateSlider_OnTextChanged(self, edit)
    if not edit then
        return
    end

    -- This is entering into the edit
    local value = tonumber(self:GetText())
    if not value then
        return
    end

    local min, max = _G[self:GetParent():GetName().."Slider"]:GetMinMaxValues()
    if value < min then
        value = min
    end
    if value > max then
        value = max
    end

    EzWoWRateSlider_SetValue(self:GetParent(), value)
    EzWoWAccountOptionsFrameApply:Enable()
end


function EzWoWRateSlider_OnEditFocusGained(self)
    EzWoWAccountOptionsFrame.currentFocus = self
end


function EzWoWRateSlider_OnEditFocusLost(self)
    local parent = self:GetParent()
    local slider = _G[parent:GetName().."Slider"]
    local min, max = slider:GetMinMaxValues()

    -- Validate and reset to previos valid value if needed
    local value = tonumber(self:GetText())
    if not value or value < min or value > max then
        self:SetText(parent.realValue)
    end

    EzWoWAccountOptionsFrame.currentFocus = nil
end


function EzWoWRatesSlider_InitRates(self)
    local key = self.optionKey

    local min = ezWoWAPI.rates[key.."_MIN"] or 0.0
    local max = ezWoWAPI.rates[key.."_MAX"] or 1.0
    local premium = ezWoWAPI.rates[key.."_PREMIUM"] or 1.0

    local endTime = ezWoWAPI.subscriptions["PREMIUM"]
    local hasPremium = endTime and endTime > time()

    if hasPremium then
        min = min * premium
        max = max * premium
    end

    self:SetMinMaxValues(min, max)
    self:SetValueStep(0.01)

    _G[self:GetName().."Low"]:SetText(tostring(min))
    _G[self:GetName().."High"]:SetText(tostring(max))
end


function EzWoWRateSlider_SetValue(self, value)
    self.realValue = value
    local slider = _G[self:GetName().."Slider"]
    slider.changingText = true
    slider:SetValue(value)
    slider.changingText = false
end


function EzWoWOptionArenaBrackets_InitDropDown(self)
    local info  = UIDropDownMenu_CreateInfo()
    info.text   = T.BRACKETS_ALL
    info.value  = 0
    info.func   = function() SelectDropDownValue(self, 0) end 
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text   = T.BRACKETS_3_2
    info.value  = 1
    info.func   = function() SelectDropDownValue(self, 1) end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text   = T.BRACKETS_3_1
    info.value  = 2
    info.func   = function() SelectDropDownValue(self, 2) end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text   = T.BRACKETS_3
    info.value  = 3
    info.func   = function() SelectDropDownValue(self, 3) end
    UIDropDownMenu_AddButton(info)
end


function EzWoWOptionArenaPlayAgainstGroups_InitDropDown(self)
    local info  = UIDropDownMenu_CreateInfo()
    info.text   = T.GROUPS_ALWAYS
    info.value  = 0
    info.func   = function() SelectDropDownValue(self, 0) end
    UIDropDownMenu_AddButton(info)

    info  = UIDropDownMenu_CreateInfo()
    info.text   = T.GROUPS_2
    info.value  = 2
    info.func   = function() SelectDropDownValue(self, 2) end
    UIDropDownMenu_AddButton(info)

    info  = UIDropDownMenu_CreateInfo()
    info.text   = T.GROUPS_3
    info.value  = 3
    info.func   = function() SelectDropDownValue(self, 3) end
    UIDropDownMenu_AddButton(info)
end


function EzWoWOptionArenaAnnouncements_InitDropDown(self)
    local info  = UIDropDownMenu_CreateInfo()
    info.text   = T.ANNOUNCE_WHEN_IN_QUEUE
    info.value  = 1
    info.func   = function() SelectDropDownValue(self, 1) end
    UIDropDownMenu_AddButton(info)

    info  = UIDropDownMenu_CreateInfo()
    info.text   = T.ANNOUNCE_NEVER
    info.value  = 0
    info.func   = function() SelectDropDownValue(self, 0) end 
    UIDropDownMenu_AddButton(info)

    info  = UIDropDownMenu_CreateInfo()
    info.text   = T.ANNOUNCE_ALWAYS
    info.value  = 3
    info.func   = function() SelectDropDownValue(self, 3) end
    UIDropDownMenu_AddButton(info)
end
