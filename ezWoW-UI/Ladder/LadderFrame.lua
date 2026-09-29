local RACE_HUMAN    = 1
local RACE_ORC      = 2
local RACE_DWARF    = 3
local RACE_NIGHTELF = 4
local RACE_UNDEAD   = 5
local RACE_TAUREN   = 6
local RACE_GNOME    = 7
local RACE_TROLL    = 8
local RACE_BLOODELF = 10
local RACE_DRAENEI  = 11

local CLASS_WARRIOR = 1
local CLASS_PALADIN = 2
local CLASS_HUNTER  = 3
local CLASS_ROGUE   = 4
local CLASS_PRIEST  = 5
local CLASS_DK      = 6
local CLASS_SHAMAN  = 7
local CLASS_MAGE    = 8
local CLASS_WARLOCK = 9
local CLASS_DRUID   = 11

local TABS_MAX_WIDTH = 400

function EzWoWLadderInnerTab_OnLoad(self)
    self.minWidth = 57;
    PanelTemplates_TabResize(self, 0, nil);
    local tab = self;
    local tabName = tab:GetName();
    local buttonMiddle = tab.Middle or _G[tabName.."Middle"];
    local buttonMiddleDisabled = tab.MiddleDisabled or _G[tabName.."MiddleDisabled"];
    local sideWidths = tab.Left and 2 * tab.Left:GetWidth() or 2 * _G[tabName.."Left"]:GetWidth();
    if self:GetWidth() - sideWidths < self.minWidth then
        local width = self.minWidth;
        local tabWidth = width + sideWidths;
        if buttonMiddle then
            buttonMiddle:SetWidth(width);
        end
        if buttonMiddleDisabled then
            buttonMiddleDisabled:SetWidth(width);
        end

        tab:SetWidth(tabWidth);

        local highlightTexture = _G[self:GetName().."HighlightTexture"];
        if highlightTexture then
            highlightTexture:SetWidth(tabWidth);
        end
    end
end

function EzWoWLadder_SetInnerTab(self, tab)
    PanelTemplates_SetTab(self, tab);
	PanelTemplates_ResizeTabsToFit(self, TABS_MAX_WIDTH);
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function EzWoWLadder_DisplayIcons(row, race, gender, class)

    if race == RACE_HUMAN or race == RACE_DWARF or race == RACE_NIGHTELF or race == RACE_GNOME or race == RACE_DRAENEI then
        row.playerFaction:SetTexCoord(0.0, 0.5, 0.0, 1.0)
    else
        row.playerFaction:SetTexCoord(0.5, 1.0, 0.0, 1.0)
    end

    if race == RACE_HUMAN then
        row.playerRace:SetTexCoord(0.125 * 0, 0.125 * 1, gender * 0.5, 0.25 + gender * 0.5)
    elseif race == RACE_DWARF then
        row.playerRace:SetTexCoord(0.125 * 1, 0.125 * 2, gender * 0.5, 0.25 + gender * 0.5)
    elseif race == RACE_GNOME then
        row.playerRace:SetTexCoord(0.125 * 2, 0.125 * 3, gender * 0.5, 0.25 + gender * 0.5)
    elseif race == RACE_NIGHTELF then
        row.playerRace:SetTexCoord(0.125 * 3, 0.125 * 4, gender * 0.5, 0.25 + gender * 0.5)
    elseif race == RACE_DRAENEI then
        row.playerRace:SetTexCoord(0.125 * 4, 0.125 * 5, gender * 0.5, 0.25 + gender * 0.5) 
    elseif race == RACE_TAUREN then
        row.playerRace:SetTexCoord(0.125 * 0, 0.125 * 1, 0.25 + gender * 0.5, 0.5 + gender * 0.5)  
    elseif race == RACE_UNDEAD then
        row.playerRace:SetTexCoord(0.125 * 1, 0.125 * 2, 0.25 + gender * 0.5, 0.5 + gender * 0.5)
    elseif race == RACE_TROLL then
        row.playerRace:SetTexCoord(0.125 * 2, 0.125 * 3, 0.25 + gender * 0.5, 0.5 + gender * 0.5)
    elseif race == RACE_ORC then
        row.playerRace:SetTexCoord(0.125 * 3, 0.125 * 4, 0.25 + gender * 0.5, 0.5 + gender * 0.5)
    elseif race == RACE_BLOODELF then
        row.playerRace:SetTexCoord(0.125 * 4, 0.125 * 5, 0.25 + gender * 0.5, 0.5 + gender * 0.5)
    end

    EzWoWLadder_DisplayClass(row.playerClass, class)
end

function EzWoWLadder_DisplayClass(texture, class)
    if class == CLASS_WARRIOR then
        texture:SetTexCoord(0.0, 0.25, 0.0, 0.25)
    elseif class == CLASS_PALADIN then
        texture:SetTexCoord(0.0, 0.25, 0.5, 0.75)
    elseif class == CLASS_HUNTER then
        texture:SetTexCoord(0.0, 0.25, 0.25, 0.5)
    elseif class == CLASS_ROGUE then
        texture:SetTexCoord(0.5, 0.75, 0.0, 0.25)
    elseif class == CLASS_PRIEST then
        texture:SetTexCoord(0.5, 0.75, 0.25, 0.5)
    elseif class == CLASS_DK then
        texture:SetTexCoord(0.25, 0.5, 0.5, 0.75)
    elseif class == CLASS_SHAMAN then
        texture:SetTexCoord(0.25, 0.5, 0.25, 0.5)
    elseif class == CLASS_MAGE then
        texture:SetTexCoord(0.25, 0.5, 0.0, 0.25)
    elseif class == CLASS_WARLOCK then
        texture:SetTexCoord(0.75, 1, 0.25, 0.5)
    elseif class == CLASS_DRUID then
        texture:SetTexCoord(0.75, 1, 0.0, 0.25)
    end
end

function EzWoWLadder_SendRequest(self)
    local startPos = self.pageSize * (self.currentPage - 1)
    local endPos = self.pageSize * self.currentPage

    ezWoW:SendMessage(string.format("%s_LADDER:%d,%d;", self.type, startPos, endPos))
end

function EzWoWLadder_UpdateButtons(self)
    if self.currentPage <= 1 then
        self.buttonPrev:Disable()
        self.buttonFirst:Disable()
    else
        self.buttonPrev:Enable()
        self.buttonFirst:Enable()
    end
    if self.currentPage >= self.totalPages then
        self.buttonNext:Disable()
        self.buttonLast:Disable()
    else
        self.buttonNext:Enable()
        self.buttonLast:Enable()
    end
end

function EzWoWLadder_OpenPage(self, currentPage)
    if currentPage > self.totalPages or currentPage < 1 then
        return
    end
    self.currentPage = currentPage
    self.pageNum:SetText(string.format("%d", currentPage))
    EzWoWLadder_UpdateButtons(self)
    _G[self:GetName().."TableRowsScrollBar"]:SetValue(0)
    EzWoWLadder_SendRequest(self)
end

function EzWoWLadderButtonNext_OnClick(self)
    local ladder = self:GetParent()
    if ladder.currentPage >= ladder.totalPages then
        return
    end

    EzWoWLadder_OpenPage(ladder, ladder.currentPage + 1)
end

function EzWoWLadderButtonPrev_OnClick(self)
    local ladder = self:GetParent()
    if ladder.currentPage > ladder.totalPages then
        return
    end

    EzWoWLadder_OpenPage(ladder, ladder.currentPage - 1)
end

function EzWoWLadderPageNum_OnFocusLost(self)
    local ladder = self:GetParent()
    local num = tonumber(self:GetText())
    if num == nil or num < 1 then
        self:SetText(string.format("%d", ladder.currentPage))
    elseif num > ladder.totalPages then
        self:SetText(string.format("%d", ladder.totalPages))
    end
end

function EzWoWLadderPageNum_OnEnterPressed(self)
    local ladder = self:GetParent()
    self:ClearFocus()
    local num = tonumber(self:GetText())
    if num == nil or num < 1 or num > ladder.totalPages then
        return
    end
    EzWoWLadder_OpenPage(ladder, num)
end

function EzWoWLadderPageNum_OnEscapePressed(self)
    self:ClearFocus()
    self:SetText(string.format("%d", self:GetParent().currentPage))
end

function EzWoWLadder_Update(self, startPos, endPos, total)
    self.totalPages = math.ceil(total / self.pageSize)
    self.buttonLast:SetFormattedText("%d", self.totalPages)
    if self:IsVisible() then
        EzWoWLadder_UpdateButtons(self)
        _G[self:GetName().."TableRows"].update()
    end
end

local function SetLadderTab(self, tab)
    if tab == 1 then
        EzWoWBattlegroundLadderPanel:Show()
        EzWoWArenaLadderPanel:Hide()
    elseif tab == 2 then
        EzWoWBattlegroundLadderPanel:Hide()
        EzWoWArenaLadderPanel:Show()
    end
    PanelTemplates_SetTab(self, tab)
end

function EzWoWLadderFrame_OnLoad(self)
    self.SetTab = SetLadderTab
    self.numTabs = 2
    table.insert(UISpecialFrames, self:GetName())
    PanelTemplates_SetTab(self, 1)
    SetPortraitToTexture(self:GetName().."Portrait", "Interface\\ICONS\\Ability_Warrior_Challange")
end

function EzWoWLadder_Init()
    ezWoW:SendMessage(string.format("INIT_MODULE:battleground;%d;", ezWoW.bgHistory and ezWoW.bgHistory[#ezWoW.bgHistory].id or 0))
    ezWoW:SendMessage(string.format("INIT_MODULE:arena;%d;", ezWoW.arenaHistory and ezWoW.arenaHistory[#ezWoW.arenaHistory].id or 0))

    ezWoW:RegisterHandler("BG_LADDER_INFO", EzWoWBattlegroundStatsSummary_Update)

    ezWoW:RegisterHandler("BG_LADDER", function(data)
        EzWoWBattlegroundLadder.ladder = data.content
        EzWoWLadder_Update(EzWoWBattlegroundLadder, data.startPos, data.endPos, data.totalSize)
    end)

    ezWoW:RegisterHandler("ARENA_LADDER", function(data)
        EzWoWArenaLadder.ladder = data.content
        EzWoWLadder_Update(EzWoWArenaLadder, data.startPos, data.endPos, data.totalSize)
    end)    
end

