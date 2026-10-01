local multispecButton = nil
local backdropR = 0
local backdropG = 0
local backdropB = 0
local backdropA = 0

local MENU_ITEM_APPLY = 1
local MENU_ITEM_SAVE = 2

local SPEC_MAX = 7
local SPEC_MAX_NO_EZPLUS = 5

local T = ezText

function EzWoWMultispecMenu_UpdateState()
    if ezWoW:HasPremium() then
        multispecButton:Show()
    elseif multispecButton then
        multispecButton:Hide()
    end
end

function EzWoWMultispecMenu_Init()  
    TalentFrame_LoadUI()
    if not multispecButton then
        multispecButton = CreateFrame("Button", "EzWoWPremiumSpecButton", PlayerTalentFrameScrollFrame, "EzWoWPremiumSpecButton")
        multispecButton.menuShown = false
        UIDropDownMenu_Initialize(EzWoWMultispecDropDownMenu, EzWoWMultispecDropDownMenu_Init)
        -- TODO: elvui
    end
    EzWoWMultispecMenu_UpdateState()
    ezWoW:RegisterHandler("SUBSCRIPTIONS", EzWoWMultispecMenu_UpdateState)
end

function EzWoWMultispecMenu_ToggleContextMenu(self)
    ToggleDropDownMenu(1, nil, EzWoWMultispecDropDownMenu, self:GetName(), 0, 0)
end

StaticPopupDialogs["EZWOW_MULTIPSEC_SAVE"] =
{
    text = T.MULTISPEC_POPUP_SAVE,
	button1 = OKAY,
	button2 = NO,
	OnAccept = function(self)
        ezWoW:SendMessage(string.format("SPEC_SAVE:%d=%s;", self.data, _G[self:GetName().."EditBox"]:GetText()))
    end,
    EditBoxOnEnterPressed = function(self)
        ezWoW:SendMessage(string.format("SPEC_SAVE:%d=%s;", self:GetParent().data, self:GetText()))
        self:GetParent():Hide()
    end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
    hasEditBox = true,
}

StaticPopupDialogs["EZWOW_MULTIPSEC_RESAVE"] =
{
    text = T.MULTISPEC_POPUP_RESAVE,
	button1 = OKAY,
	button2 = NO,
	OnAccept = function(self)
        local spec = ezWoW.premiumSpec[self.data]
        StaticPopup_Show("EZWOW_MULTIPSEC_SAVE", "", "", self.data)
        if spec then
            StaticPopup1EditBox:SetText(spec.name)
        end
    end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
}

StaticPopupDialogs["EZWOW_MULTISPEC_RENAME"] =
{
    text = T.MULTISPEC_POPUP_RENAME,
	button1 = OKAY,
	button2 = NO,
	OnAccept = function(self)
        ezWoW:SendMessage(string.format("SPEC_RENAME:%d=%s;", self.data, _G[self:GetName().."EditBox"]:GetText()))
    end,
    EditBoxOnEnterPressed = function(self)
        ezWoW:SendMessage(string.format("SPEC_RENAME:%d=%s;", self:GetParent().data, self:GetText()))
        self:GetParent():Hide()
    end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
    hideOnEscape = true,
    hasEditBox = true,
}

StaticPopupDialogs["EZWOW_MULTISPEC_REMOVE"] =
{
    text = T.MULTIPSEC_POPUP_REMOVE,
	button1 = OKAY,
	button2 = NO,
	OnAccept = function(self)
        ezWoW:SendMessage(string.format("SPEC_REMOVE:%d;", self.data))
    end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
    hideOnEscape = true,
}

function EzWoWMultispecDropDownMenu_Init()

    if UIDROPDOWNMENU_MENU_LEVEL == 2 then
        local info; 

        local specIndex = UIDROPDOWNMENU_MENU_VALUE
        local spec = ezWoW.premiumSpec[specIndex]
        info = UIDropDownMenu_CreateInfo()

        if spec ~= nil then
            info.text = string.format("[%d] %s", specIndex + 1, spec.name)
        else
            info.text = string.format("[%d] (Пусто)", specIndex + 1)
        end

        info.notClickable = 1
        info.notCheckable = 1
        info.isTitle = true
        UIDropDownMenu_AddButton(info, 2)

        info = UIDropDownMenu_CreateInfo()
        info.text = T.MULTISPEC_APPLY
        info.notCheckable = 1
        info.func = function()
            DropDownList1:Hide()
            ezWoW:SendMessage(string.format("SPEC_APPLY:%d;", specIndex))
        end
        if spec == nil then
            info.disabled = true
        end
        UIDropDownMenu_AddButton(info, 2)

        info = UIDropDownMenu_CreateInfo()
        info.text = T.MULTISPEC_SAVE
        info.notCheckable = 1
        info.func = function() 
            DropDownList1:Hide()
            local spec = ezWoW.premiumSpec[specIndex]
            if spec then
                StaticPopup_Show("EZWOW_MULTIPSEC_RESAVE", spec.name, "", specIndex)
            else
                StaticPopup_Show("EZWOW_MULTIPSEC_SAVE", "", "", specIndex)
            end
        end
        UIDropDownMenu_AddButton(info, 2)

        info = UIDropDownMenu_CreateInfo()
        info.text = T.MULTISPEC_RENAME
        info.notCheckable = 1
        if spec == nil then
            info.disabled = true
        end
        info.func = function()
            DropDownList1:Hide()
            StaticPopup_Show("EZWOW_MULTISPEC_RENAME", "", "", specIndex)
        end
        UIDropDownMenu_AddButton(info, 2)

        info = UIDropDownMenu_CreateInfo()
        info.text = T.MULTISPEC_REMOVE
        info.notCheckable = 1
        if spec == nil then
            info.disabled = true
        end
        info.func = function()
            DropDownList1:Hide()
            StaticPopup_Show("EZWOW_MULTISPEC_REMOVE", spec.name, "", specIndex)
        end
        UIDropDownMenu_AddButton(info, 2)
    else
        local ezPlusActive = ezWoW:HasEzPlus()
        for i = 0, SPEC_MAX do
            local info = UIDropDownMenu_CreateInfo()
            local spec = ezWoW.premiumSpec[i]
            if spec ~= nil then
                info.text = string.format("[%d] %s (%d/%d/%d)", i + 1, spec.name, spec.tabs[1], spec.tabs[2], spec.tabs[3]) 
            else
                info.text = string.format("[%d] (%s)", i + 1, T.MULTISPEC_EMPTY)
            end
            info.value = i
            info.hasArrow = 1
            info.notCheckable = 1

            if i > SPEC_MAX_NO_EZPLUS and not ezPlusActive then
                info.disabled = true
                info.tooltipWhileDisabled = 1
                info.tooltipTitle = "Требуется ezPlus+"
                info.tooltipText = "Для использования слотов 7 и 8 требуется подписка ezPlus+"
            end

            UIDropDownMenu_AddButton(info, 1)
        end

        local info = UIDropDownMenu_CreateInfo()
        info.text = T.MULTISPEC_RESET_TALENTS
        info.notCheckable = 1
        info.func = function(self)
            ezWoW:SendMessage("RESET_TALENTS;")
        end
        UIDropDownMenu_AddButton(info, 1)

        info = UIDropDownMenu_CreateInfo()
        info.notCheckable = 1
        info.text = CANCEL
        info.func = function(self)
            self:GetParent():Hide()
        end
        UIDropDownMenu_AddButton(info, 1)
    end
end


function EzWoWMultispecDropDownMenu_OnLoad()
    EzWoWMultispecDropDownMenu_Init()
end
