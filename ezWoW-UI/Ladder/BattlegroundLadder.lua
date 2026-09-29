function EzWoWBattlegroundLadderPanel_OnShow(self)
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
    EzWoWBattlegroundLadderTableHeaderWinsLosses:SetText("Победы /\nПоражения")
    EzWoWBattlegroundLadderCharacterRow.background:SetBlendMode("BLEND")
end

function EzWoWBattlegroundLadder_OnShow(self)
    self.pageNum:SetText(string.format("%d", self.currentPage))
    EzWoWLadder_SendRequest(self)
end

function EzWoWBattlegroundLadderTable_OnLoad(self)
    self.update = EzWoWBattlegroundLadderTable_Update
    HybridScrollFrame_CreateButtons(self, "EzWoWBattlegroundLadderRowTemplate", 0, 0)
end

local function GetRankWidth(rank)
    if rank >= 1000 then
        return 48
    elseif rank >= 100 then
        return 32
    end
    return 24
end

function EzWoWBattlegroundLadderTable_Update()
    local scrollFrame = EzWoWBattlegroundLadderTableRows
    local offset = HybridScrollFrame_GetOffset(scrollFrame)
    local buttons = scrollFrame.buttons
    local numButtons = #buttons

    local numPlayers = 0
    local ladder = EzWoWBattlegroundLadder.ladder
    if ladder then
        numPlayers = #ladder
    end

    local rankWidth = GetRankWidth(ezWoW.bgLadderInfo and ezWoW.bgLadderInfo.rank or 0)

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
                EzWoWBattlegroundLadderTable_DisplayPlayer(row, player, selectionId)
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

    local header = EzWoWBattlegroundLadderTableHeaderDeaths;

    if EzWoWBattlegroundLadderTableRowsScrollBar:IsShown() then
        scrollFrame:SetPoint("BOTTOMRIGHT", -26, 4)
        header:SetPoint("TOPRIGHT", -30, 0) -- we do not have inset here so additional 4
    else
        scrollFrame:SetPoint("BOTTOMRIGHT", -4, 4)
        header:SetPoint("TOPRIGHT", -8, 0)
    end

    local buttonWidth = EzWoWBattlegroundLadderTableRows:GetWidth()

    for i = 1, numButtons do
        playerIndex = i + offset
        if playerIndex <= numPlayers then
            buttons[i]:SetWidth(buttonWidth)
        end
    end

    EzWoWBattlegroundLadderTableHeaderRank:SetWidth(rankWidth)

    EzWoWBattlegroundLadderCharacterRow.playerRank:SetWidth(rankWidth)
    if EzWoWBattlegroundLadderTableRowsScrollBar:IsShown() then
        EzWoWBattlegroundLadderCharacterRow.playerDeaths:SetPoint("TOPRIGHT", -26, 0) -- same here
    else
        EzWoWBattlegroundLadderCharacterRow.playerDeaths:SetPoint("TOPRIGHT", -4, 0)
    end
    EzWoWBattlegroundLadderTable_DisplayPlayer(EzWoWBattlegroundLadderCharacterRow, ezWoW.bgLadderInfo)
end

function EzWoWBattlegroundLadderTable_DisplayPlayer(row, player)
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

-------------- Stats --------------
function EzWoWBattlegroundHistory_OnLoad(self)
    self.content.update = EzWoWBattlegroundHistory_Update
    HybridScrollFrame_CreateButtons(self.content, "EzWoWLadderHistoryEntryTemplate", 0, 0)
end

local function GetMapName(id)
    if id == 30 then
        return "Альтеракская долина"
    elseif id == 489 then
        return "Ущелье Песни Войны"
    elseif id == 529 then
        return "Низина Арати"
    elseif id == 566 then
        return "Око Бури"
    elseif id == 607 then
        return "Берег Древних"
    elseif id == 628 then
        return "Остров Завоеваний"
    elseif id == 726 then
        return "Два Пика"
    elseif id == 727 then
        return "Сверкающие копи"
    elseif id == 761 then
        return "Битва за Гилнеас"
    elseif id == 998 then
        return "Храм Котмогу"
    elseif id == 1105 then
        return "Каньое Суровых Ветров"
    end
    return "UNKNOWN"
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

            if entry.result == 'W' then
                fmt = "|cFFFFD200[%s]|r |cFFFFFFFF%s|r |cFFFFAA44%d|r (|cFF00FF00+%d|r)"
            elseif entry.result == 'L' then
                fmt = "|cFFFFD200[%s]|r |cFFFFFFFF%s|r |cFFFFAA44%d|r (|cFFFF0000%d|r)"
            elseif entry.result == 'D' then
                fmt = "|cFFFFD200[%s]|r |cFFFFFFFF%s|r |cFFFFAA44%d|r |cFFFFD200Ничья|r"
            else
                fmt = "|cFFFFD200[%s]|r |cFFFFFFFF%s|r |cFFFFAA44%d|r |cFF808080Покинуто|r"
            end

            row.text:SetFormattedText(fmt, date("%d/%m %H:%M", entry.time), GetMapName(entry.map), entry.rating, entry.change)
            row:Show()
            displayedHeight = displayedHeight + buttons[i]:GetHeight()
        end
    end

    local totalHeight = 24 * numEntries

    HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)
end