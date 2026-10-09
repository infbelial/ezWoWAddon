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

    self.responseTimer = 1
end

function EzWoWLadder_UpdateNaviagtion(self)
    if self.totalPages == 1 then
        self.navigation:Hide()
        self.table:SetPoint("BOTTOMRIGHT", -8, 8)
    else
        self.navigation:Show()
        self.table:SetPoint("BOTTOMRIGHT", -8, 38)
    end

    if self.currentPage <= 1 then
        self.navigation.prev:Disable()
        self.navigation.first:Disable()
    else
        self.navigation.prev:Enable()
        self.navigation.first:Enable()
    end
    if self.currentPage >= self.totalPages then
        self.navigation.next:Disable()
        self.navigation.last:Disable()
    else
        self.navigation.next:Enable()
        self.navigation.last:Enable()
    end
end

function EzWoWLadder_OpenPage(self, currentPage)
    if currentPage > self.totalPages or currentPage < 1 then
        return
    end
    self.currentPage = currentPage
    self.navigation.pageNum:SetText(string.format("%d", currentPage))
    EzWoWLadder_UpdateNaviagtion(self)
    _G[self:GetName().."TableRowsScrollBar"]:SetValue(0)

    self.table.content:Hide()

    -- Server's limiting messages at a rate of 5 per 2 seconds (on a moment this comment was written)
    -- So we need to do atleast something to be in this rate or UI will be unresponsive
    local timenow = GetTime()

    if self.lastRequest + 0.3 < timenow then
        EzWoWLadder_SendRequest(self)
    else
        self.requestTimer = 0.2
        self.table.loading:Show()
    end
    self.lastRequest = timenow
end

function EzWoWLadderButtonNext_OnClick(self)
    local ladder = self:GetParent():GetParent()
    if ladder.currentPage >= ladder.totalPages then
        return
    end

    EzWoWLadder_OpenPage(ladder, ladder.currentPage + 1)
end

function EzWoWLadderButtonPrev_OnClick(self)
    local ladder = self:GetParent():GetParent()
    if ladder.currentPage > ladder.totalPages then
        return
    end

    EzWoWLadder_OpenPage(ladder, ladder.currentPage - 1)
end

function EzWoWLadderPageNum_OnFocusLost(self)
    local ladder = self:GetParent():GetParent()
    local num = tonumber(self:GetText())
    if num == nil or num < 1 then
        self:SetText(string.format("%d", ladder.currentPage))
    elseif num > ladder.totalPages then
        self:SetText(string.format("%d", ladder.totalPages))
    end
end

function EzWoWLadderPageNum_OnEnterPressed(self)
    local ladder = self:GetParent():GetParent()
    self:ClearFocus()
    local num = tonumber(self:GetText())
    if num == nil or num < 1 or num > ladder.totalPages then
        return
    end
    EzWoWLadder_OpenPage(ladder, num)
end

function EzWoWLadderPageNum_OnEscapePressed(self)
    self:ClearFocus()
    self:SetText(string.format("%d", self:GetParent():GetParent().currentPage))
end

-- This is OnUpdate UI script
function EzWoWLadder_OnUpdate(self, diff)
    if self.requestTimer > 0 then
        if self.requestTimer <= diff then
            EzWoWLadder_SendRequest(self)
            self.requestTimer = 0
        else
            self.requestTimer = self.requestTimer - diff
        end
    end

    -- Even with the client tricks it's possible that server gonna cut packet because of the limit
    -- So just re-send request on a watchdog timer
    if self.responseTimer > 0 then
        if self.responseTimer <= diff then
            EzWoWLadder_SendRequest(self)
        else
            self.responseTimer = self.responseTimer - diff
        end
    end
end

local function GetRankWidth(rank)
    if rank >= 1000 then
        return 48
    elseif rank >= 100 then
        return 32
    end
    return 24
end

-- This is when we need to manually update UI (scrolling, switching panels)
function EzWoWLadder_Update(self, forceUpdate)
    local scrollFrame = _G[self:GetName().."TableRows"]
    local offset = HybridScrollFrame_GetOffset(scrollFrame)

    local buttons = scrollFrame.buttons
    local numButtons = #buttons

    local numPlayers = 0
    local players = self.data
    if players then
        numPlayers = #players
    end

    local ladderInfo = self.ladderInfo
    local displayPlayer = self.displayPlayer

    local rankWidth = GetRankWidth(ladderInfo and ladderInfo.rank or 0)

    for i = numPlayers, 1, -1 do
        local rank = players[i].rank
        if rank ~= 0 then
            local newWidth = GetRankWidth(rank)
            if newWidth > rankWidth then
                rankWidth = newWidth
            end
            break
        end
    end

    local playerIndex = 0
    local displayedHeight = 0

    for i = 1, numButtons do
        local row = buttons[i]
        playerIndex = i + offset
        if playerIndex > numPlayers then
            row:Hide()
        else
            local player = players[playerIndex]
            row.index = playerIndex
            if player.guid ~= row.guid or forceUpdate then
                row.guid = player.guid
                row.playerRank:SetWidth(rankWidth)
                displayPlayer(row, player, selectionId)
                if playerIndex % 2 ~= 0 then
                    row.background:SetBlendMode("BLEND")
                else
                    row.background:SetBlendMode("ADD")
                end
            end
            row:Show()
            displayedHeight = displayedHeight + buttons[i]:GetHeight()
        end
    end

    local totalHeight = 22 * numPlayers

    HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)

    local mostRightHeader = self.mostRightHeader
    local scrollBar = _G[scrollFrame:GetName().."ScrollBar"]

    if scrollBar:IsShown() then
        scrollFrame:SetPoint("BOTTOMRIGHT", -26, 4)
        mostRightHeader:SetPoint("TOPRIGHT", -30, 0) -- we do not have inset here so additional 4
    else
        scrollFrame:SetPoint("BOTTOMRIGHT", -4, 4)
        mostRightHeader:SetPoint("TOPRIGHT", -8, 0)
    end

    local buttonWidth = scrollFrame:GetWidth()

    for i = 1, numButtons do
        playerIndex = i + offset
        if playerIndex <= numPlayers then
            buttons[i]:SetWidth(buttonWidth)
        end
    end

    local characterRow = _G[self:GetName().."CharacterRow"]

    if ladderInfo == nil then
        characterRow:Hide()
    else
        characterRow:Show()
        _G[self:GetName().."TableHeaderRank"]:SetWidth(rankWidth)

        characterRow.playerRank:SetWidth(rankWidth)
        if scrollBar:IsShown() then
            characterRow.mostRightColumn:SetPoint("TOPRIGHT", -26, 0)
        else
            characterRow.mostRightColumn:SetPoint("TOPRIGHT", -4, 0)
        end
        displayPlayer(characterRow, ladderInfo)
    end
end

-- And this is when server responded on our request
function EzWoWLadder_Refresh(self, startPos, endPos, total)
    ezLog:Debug("EzWoWLadder_Refresh")
    self.totalPages = math.ceil(total / self.pageSize)
    self.navigation.last:SetFormattedText("%d", self.totalPages)
    self.table.content:Show()
    self.table.loading:Hide()
    if self:IsVisible() then
        EzWoWLadder_UpdateNaviagtion(self)
        EzWoWLadder_Update(self, true)
    end
    self.responseTimer = 0
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


