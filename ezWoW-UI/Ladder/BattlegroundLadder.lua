local T = ezText

function EzWoWBattlegroundLadderPanel_OnShow(self)
    if not self.initialized then
        local lastGameId = 0
        if ezWoW.bgHistory and #ezWoW.bgHistory > 0 then
            lastGameId = ezWoW.bgHistory[#ezWoW.bgHistory].id
        end
        ezWoW:SendMessage(string.format("INIT_MODULE:battleground;%d;", lastGameId))

        ezWoW:RegisterHandler("BG_LADDER", function(data)
            EzWoWBattlegroundLadder.data = data.content
            EzWoWLadder_Refresh(EzWoWBattlegroundLadder, data.startPos, data.endPos, data.totalSize)
        end)

        ezWoW:RegisterHandler("BG_LADDER_INFO", function(data)
            EzWoWBattlegroundLadder.ladderInfo = data
            EzWoWBattlegroundLadder_Update()
        end)

        self.initialized = true
    end

    local now = time()
    local endTime = ezWoW.bgSeason.endDate
    local seasonEnd = ""
    if endTime > 0 and endTime > now then
        local duration = endTime - now
        local days = math.floor(duration / 86400)
        local hours = math.floor((duration / 86400) / 3600)
        local minutes = math.floor((duration % 3600) / 60)
        local seconds = duration % 60
        seasonEnd = string.format(" (%d дней)", days)
    end

    self:GetParent().title:SetFormattedText("Сезон %d", ezWoW.bgSeason.id)
	self.seasonEnd:SetFormattedText("Закончится %s%s", date("%d-%m-%Y", ezWoW.bgSeason.endDate), seasonEnd)
end

function EzWoWBattlegroundLadderTab_OnClick(self)
    local id = self:GetID()
    if id == 1 then
        EzWoWBattlegroundLadder:Show()
        EzWoWBattlegroundHistory:Hide()
    elseif id == 2 then
        EzWoWBattlegroundLadder:Hide()
        EzWoWBattlegroundHistory:Show()
    elseif id == 3 then
        EzWoWBattlegroundLadder:Hide()
        EzWoWBattlegroundHistory:Hide()
    end
    EzWoWLadder_SetInnerTab(self:GetParent(), id)
end

function EzWoWBattlegroundLadder_OnLoad(self)
    self.currentPage = 1
    self.pageSize = 20
    self.type = "BG"

    self.ladderInfo = ezWoW.bgLadderInfo
    self.displayPlayer = EzWoWBattlegroundLadder_DisplayPlayer
    self.mostRightHeader = EzWoWBattlegroundLadderTableHeaderDeaths
    
    local characterRow = EzWoWBattlegroundLadderCharacterRow
    characterRow.mostRightColumn = characterRow.playerDeaths
    characterRow.background:SetBlendMode("BLEND")

    local scrollFrame = EzWoWBattlegroundLadderTableRows
    scrollFrame.update = EzWoWBattlegroundLadder_Update
    HybridScrollFrame_CreateButtons(scrollFrame, "EzWoWBattlegroundLadderRowTemplate", 0, 0)
end

function EzWoWBattlegroundLadder_OnShow(self)
    self.pageNum:SetText(string.format("%d", self.currentPage))
    EzWoWBattlegroundLadder_Update()
    EzWoWLadder_SendRequest(self)
end

function EzWoWBattlegroundLadder_Update()
    EzWoWLadder_Update(EzWoWBattlegroundLadder)
end

function EzWoWBattlegroundLadder_DisplayPlayer(row, player)
    if player.rank ~= 0 then
        row.playerRank:SetFormattedText("%d", player.rank)
    else
        row.playerRank:SetText("-")
    end
    row.playerName:SetText(player.name)
    row.playerRating:SetFormattedText("%d", player.rating)
    row.playerWinsLosses:SetFormattedText("%d / %d", player.wins, player.losses)
    if player.wins + player.losses > 0 then
        row.playerWinRate:SetFormattedText("(%d%%)", 100 * player.wins / (player.wins + player.losses))
    else
        row.playerWinRate:SetText("(0%)")
    end
    row.playerLeaves:SetFormattedText("%d", player.leaves)
    row.playerDraws:SetFormattedText("%d", player.draws)
    row.playerKills:SetFormattedText("%d", player.kills)
    row.playerAssists:SetFormattedText("%d", player.assists)
    row.playerDeaths:SetFormattedText("%d", player.deaths)

    local class = bit.band(player.crg, 255)
    local race = bit.band(bit.rshift(player.crg, 8), 255)
    local gender = bit.band(bit.rshift(player.crg, 16), 255)

    EzWoWLadder_DisplayIcons(row, race, gender, class)
end

-------------- History --------------
function EzWoWBattlegroundHistory_OnLoad(self)
    self.content.update = EzWoWBattlegroundHistory_Update
    HybridScrollFrame_CreateButtons(self.content, "EzWoWLadderHistoryEntryTemplate", 0, 0)
end

function EzWoWBattlegroundHistory_Update()
    local scrollFrame = EzWoWBattlegroundHistoryContent
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons
    local numButtons = #buttons

    local numEntries = 0
    local history = ezWoW.bgHistory
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

            local status = ""

            if entry.result == 'W' then
                fmt = "|cFFFFD200[%s]|r |cFFFFFFFF%s|r |cFFFFAA44%d|r (|cFF00FF00+%d|r)"
            elseif entry.result == 'L' then
                fmt = "|cFFFFD200[%s]|r |cFFFFFFFF%s|r |cFFFFAA44%d|r (|cFFFF0000%d|r)"
            elseif entry.result == 'D' then
                fmt = "|cFFFFD200[%s]|r |cFFFFFFFF%s|r |cFFFFAA44%d|r (|cFFFFD200Ничья|r)"
                status = T.GAME_DRAW
            else
                fmt = "|cFFFFD200[%s]|r |cFFFFFFFF%s|r |cFFFFAA44%d|r (|cFF808080Покинуто|r)"
                status = T.GAME_ABANDONED
            end

            row.text:SetFormattedText(fmt, date("%d/%m %H:%M", entry.time), T:GetBattlegroundName(entry.map), entry.rating, entry.change, status)
            row:Show()
            displayedHeight = displayedHeight + buttons[i]:GetHeight()
        end
    end

    local totalHeight = 24 * numEntries

    HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)
end