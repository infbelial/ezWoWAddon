function EzWoWArenaLadderPanel_OnShow(self)
    if not self.initialized then
        ezWoW:SendMessage(string.format("INIT_MODULE:arena;%d;", ezWoW.arenaHistory and ezWoW.arenaHistory[#ezWoW.arenaHistory].id or 0))

        ezWoW:RegisterHandler("ARENA_LADDER", function(data)
            EzWoWArenaLadder.data = data.content
            EzWoWLadder_Refresh(EzWoWArenaLadder, data.startPos, data.endPos, data.totalSize)
        end)

        ezWoW:RegisterHandler("ARENA_LADDER_INFO", function(data)
            EzWoWArenaLadder.ladderInfo = ezWoW.arenaInfo
            EzWoWArenaLadder_Update()
        end)

        self.initialized = true
    end

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

    self.ladderInfo = ezWoW.arenaInfo
    self.displayPlayer = EzWoWArenaLadder_DisplayPlayer
    self.mostRightHeader = EzWoWArenaLadderTableHeaderWinsLosses

    local characterRow = EzWoWArenaLadderCharacterRow
    characterRow.mostRightColumn = characterRow.playerWinRate
    characterRow.background:SetBlendMode("BLEND")

    local scrollFrame = EzWoWArenaLadderTableRows
    scrollFrame.update = EzWoWArenaLadder_Update
    HybridScrollFrame_CreateButtons(scrollFrame, "EzWoWArenaLadderRowTemplate", 0, 0)
end

function EzWoWArenaLadder_OnShow(self)
    self.pageNum:SetText(string.format("%d", self.currentPage))
    EzWoWArenaLadder_Update()
    EzWoWLadder_SendRequest(self)
end

function EzWoWArenaLadder_Update()
    EzWoWLadder_Update(EzWoWArenaLadder)
end

function EzWoWArenaLadder_DisplayPlayer(row, player)
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
                fmt = "|cFFFFFFFF%s|r |cFFFFD200%d|r (|cFF00FF00+%d|r)"
            elseif entry.players[1].change == 0 then
                fmt = "|cFFFFFFFF%s|r |cFFFFD200%d|r (|cFFFF0000-%d|r)"
            else
                fmt = "|cFFFFFFFF%s|r |cFFFFAA44%d|r (|cFFFF0000%d|r)"
            end

            row.col3:SetFormattedText(fmt, ezText:GetBattlegroundName(entry.map), entry.players[1].rating, entry.players[1].change)
            row:Show()
            displayedHeight = displayedHeight + buttons[i]:GetHeight()
        end
    end

    local totalHeight = 24 * numEntries

    HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)
end