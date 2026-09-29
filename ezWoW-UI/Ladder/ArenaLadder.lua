function EzWoWArenaLadderPanel_OnShow(self)
    local now = time()
    local endTime = ezWoW.arenaSeason.endDate
    local seasonEnd = ""
    if endTime > 0 and endTime > now then
        local duration = endTime - now
        local days = math.floor(duration / 86400)
        local hours = math.floor((duration / 86400) / 3600)
        local minutes = math.floor((duration % 3600) / 60)
        local seconds = duration % 60
        seasonEnd = string.format(" (%d дней)", days)
    end
    self:GetParent().title:SetFormattedText("Сезон %d", ezWoW.arenaSeason.id)
	self.seasonEnd:SetFormattedText("Закончится %s%s", date("%d-%m-%Y", ezWoW.arenaSeason.endDate), seasonEnd)
end

function EzWoWArenaLadderTab_OnLoad(self)
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

function EzWoWArenaLadderTab_OnClick(self)
    local id = self:GetID()
    if id == 1 then
        EzWoWArenaLadder:Show()
        EzWoWArenaHistory:Hide()
    elseif id == 2 then
        EzWoWArenaLadder:Hide()
        EzWoWArenaHistory:Show()
    end
    EzWoWLadder_SetInnerTab(self:GetParent(), id)
end

function EzWoWArenaLadder_OnLoad(self)
    self.currentPage = 1
    self.pageSize = 20
    self.type = "ARENA"
    EzWoWArenaLadderTableHeaderWinsLosses:SetText("Победы /\nПоражения")
    EzWoWArenaLadderCharacterRow.background:SetBlendMode("BLEND")
end

function EzWoWArenaLadder_OnShow(self)
    self.pageNum:SetText(string.format("%d", self.currentPage))
    EzWoWLadder_SendRequest(self)
end

function EzWoWArenaLadderTable_OnLoad(self)
    self.update = EzWoWArenaLadderTable_Update
    HybridScrollFrame_CreateButtons(self, "EzWoWArenaLadderRowTemplate", 0, 0)
end

local function GetRankWidth(rank)
    if rank >= 1000 then
        return 48
    elseif rank >= 100 then
        return 32
    end
    return 24
end

function EzWoWArenaLadderTable_Update()
    local scrollFrame = EzWoWArenaLadderTableRows
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons
    local numButtons = #buttons

    local numPlayers = 0
    local ladder = EzWoWArenaLadder.ladder
    if ladder then
        numPlayers = #ladder
    end

    local rankWidth = GetRankWidth(ezWoW.arenaInfo and ezWoW.arenaInfo.rank or 0)

    for i = numPlayers, 1, -1 do
        local rank = ladder[i].rank
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
            local player = ladder[playerIndex]
            row.index = playerIndex
            if player.guid ~= row.guid then
                row.guid = player.guid
                row.playerRank:SetWidth(rankWidth)
                EzWoWArenaLadderTable_DisplayPlayer(row, player, selectionId)
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

    local totalHeight = 24 * numPlayers

    HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)

    local header = EzWoWArenaLadderTableHeaderWinsLosses;

    if EzWoWArenaLadderTableRowsScrollBar:IsShown() then
        scrollFrame:SetPoint("BOTTOMRIGHT", -26, 4)
        header:SetPoint("TOPRIGHT", -30, 0) -- we do not have inset here so additional 4
    else
        scrollFrame:SetPoint("BOTTOMRIGHT", -4, 4)
        header:SetPoint("TOPRIGHT", -8, 0)
    end

    local buttonWidth = EzWoWArenaLadderTableRows:GetWidth()

    for i = 1, numButtons do
        playerIndex = i + offset
        if playerIndex <= numPlayers then
            buttons[i]:SetWidth(buttonWidth)
        end
    end

    EzWoWArenaLadderTableHeaderRank:SetWidth(rankWidth)

    EzWoWArenaLadderCharacterRow.playerRank:SetWidth(rankWidth)
    if EzWoWArenaLadderTableRowsScrollBar:IsShown() then
        EzWoWArenaLadderCharacterRow.playerWinRate:SetPoint("TOPRIGHT", -26, 0)
    else
        EzWoWArenaLadderCharacterRow.playerWinRate:SetPoint("TOPRIGHT", -4, 0)
    end
    EzWoWArenaLadderTable_DisplayPlayer(EzWoWArenaLadderCharacterRow, ezWoW.arenaInfo)
end

function EzWoWArenaLadderTable_DisplayPlayer(row, player)
    if player.rank ~= 0 then
        row.playerRank:SetFormattedText("%d", player.rank)
    else
        row.playerRank:SetText("-")
    end
    row.playerName:SetText(player.name)
    row.playerRating:SetFormattedText("%d", player.rating)
    row.playerMatchMakerRating:SetFormattedText("%d", player.mmr)
    row.playerWinsLosses:SetFormattedText("%d / %d", player.wins, player.losses)
    if player.wins + player.losses > 0 then
        row.playerWinRate:SetFormattedText("(%d%%)", 100 * player.wins / (player.wins + player.losses))
    else
        row.playerWinRate:SetText("(0%)")
    end
    local class = bit.band(player.crg, 255)
    local race = bit.band(bit.rshift(player.crg, 8), 255)
    local gender = bit.band(bit.rshift(player.crg, 16), 255)
    EzWoWLadder_DisplayIcons(row, race, gender, class)
end


-------------- History --------------
function EzWoWArenaHistory_OnLoad(self)
    self.content.update = EzWoWArenaHistory_Update
    HybridScrollFrame_CreateButtons(self.content, "EzWoWArenaHistoryEntryTemplate", 0, 0)
end

local function GetMapName(id)
    if id == 559 then
        return "Арена Награнда"
    elseif id == 562 then
        return "Арена Острогорья"
    elseif id == 572 then
        return "Руины Лордерона"
    elseif id == 617 then
        return "Стоки Даларана"
    elseif id == 618 then
        return "Арена Доблести"
    elseif id == 980 then
        return "Арена Тол'вир"
    elseif id == 1134 then
        return "Пик Тигра"
    end
    return tostring(id)
end

function EzWoWArenaHistory_Update()
    local scrollFrame = EzWoWArenaHistoryContent
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons
    local numButtons = #buttons

    local numEntries = 0
    local history = ezWoW.arenaHistory
    if history then
        numEntries = #history
    end

    local entryIndex = 0
    local displayedHeight = 0

    for i = 1, numButtons do
        local row = buttons[i]
        entryIndex = i + offset
        if entryIndex > numEntries then
            row:Hide()
        else
            local entry = history[numEntries + 1 - entryIndex]
            local fmt;

            row.col1:SetText(date("|cFFFFD200[%d/%m %H:%M]|r", entry.time))

            local playerNum = #entry.players / 2
            local players = entry.players
            if playerNum == 3 then
                row.p1:ClearAllPoints()
                row.p1:SetPoint("LEFT", row.col1, "RIGHT", 5, 0)
                row.p1:Show()
                EzWoWLadder_DisplayClass(row.p1, bit.band(players[1].crg, 255))

                row.p2:ClearAllPoints()
                row.p2:SetPoint("LEFT", row.p1, "RIGHT")
                row.p2:Show()
                EzWoWLadder_DisplayClass(row.p2, bit.band(players[2].crg, 255))

                row.p3:ClearAllPoints()
                row.p3:SetPoint("LEFT", row.p2, "RIGHT")
                row.p3:Show()
                EzWoWLadder_DisplayClass(row.p3, bit.band(players[3].crg, 255))
                ---------------------------------------------------------------
                row.p4:ClearAllPoints()
                row.p4:SetPoint("LEFT", row.col2, "RIGHT", 5, 0)
                row.p4:Show()
                EzWoWLadder_DisplayClass(row.p4, bit.band(players[4].crg, 255))
                
                row.p5:ClearAllPoints()
                row.p5:SetPoint("LEFT", row.p4, "RIGHT")
                row.p5:Show()
                EzWoWLadder_DisplayClass(row.p5, bit.band(players[5].crg, 255))

                row.p6:ClearAllPoints()
                row.p6:SetPoint("LEFT", row.p5, "RIGHT")
                row.p6:Show()
                EzWoWLadder_DisplayClass(row.p6, bit.band(players[6].crg, 255))

                row.col3:ClearAllPoints()
                row.col3:SetPoint("LEFT", row.p6, "RIGHT", 5, 0)
                
            elseif playerNum == 2 then
                row.p1:ClearAllPoints()
                row.p1:Hide()

                row.p2:ClearAllPoints()
                row.p2:SetPoint("LEFT", row.col1, "RIGHT", 5, 0)
                row.p2:Show()
                EzWoWLadder_DisplayClass(row.p2, bit.band(players[1].crg, 255))

                row.p3:ClearAllPoints()
                row.p3:SetPoint("LEFT", row.p2, "RIGHT")
                row.p3:Show()
                EzWoWLadder_DisplayClass(row.p3, bit.band(players[2].crg, 255))
                ---------------------------------------------------------------
                row.p4:ClearAllPoints()
                row.p4:SetPoint("LEFT", row.col2, "RIGHT", 5, 0)
                row.p4:Show()
                EzWoWLadder_DisplayClass(row.p4, bit.band(players[3].crg, 255))
                
                row.p5:ClearAllPoints()
                row.p5:SetPoint("LEFT", row.p4, "RIGHT")
                row.p5:Show()
                EzWoWLadder_DisplayClass(row.p5, bit.band(players[4].crg, 255))

                row.p6:ClearAllPoints()
                row.p6:Hide()

                row.col3:ClearAllPoints()
                row.col3:SetPoint("LEFT", row.p5, "RIGHT", 5, 0)
            else
                row.p1:ClearAllPoints()
                row.p1:Hide()

                row.p2:ClearAllPoints()
                row.p2:Hide()

                row.p3:ClearAllPoints()
                row.p3:SetPoint("LEFT", row.col1, "RIGHT", 5, 0)
                row.p3:Show()
                EzWoWLadder_DisplayClass(row.p3, bit.band(players[1].crg, 255))
                ---------------------------------------------------------------
                row.p4:ClearAllPoints()
                row.p4:SetPoint("LEFT", row.col2, "RIGHT", 5, 0)
                row.p4:Show()

                EzWoWLadder_DisplayClass(row.p4, bit.band(players[2].crg, 255))

                row.p5:ClearAllPoints()
                row.p5:Hide()

                row.p6:ClearAllPoints()
                row.p6:Hide()

                row.col3:SetPoint("LEFT", row.p4, "RIGHT", 5, 0)
            end

            if entry.players[1].win then
                fmt = "|cFFFFFFFF%s|r - |cFFFFD200%d|r (|cFF00FF00+%d|r)"
            elseif entry.players[1].change == 0 then
                fmt = "|cFFFFFFFF%s|r - |cFFFFD200%d|r (|cFFFF0000-%d|r)"
            else
                fmt = "|cFFFFFFFF%s|r - |cFFFFAA44%d|r (|cFFFF0000%d|r)"
            end

            row.col3:SetFormattedText(fmt, GetMapName(entry.map), entry.players[1].rating, entry.players[1].change)
            row:Show()
            displayedHeight = displayedHeight + buttons[i]:GetHeight()
        end
    end

    local totalHeight = 24 * numEntries

    HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)
end