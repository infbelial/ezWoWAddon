ezWoW = 
{
    account = "",
    memberId = 0,
    options = {},
    rates = {},
    subscriptions = {},
    muteId = 0,
    muteEnd = 0,
    premiumSpec = {},
    dataHandlers = {},
    eventHandlers = {},
}

local function AppendData(array, data)
    for i = 1, #data do
        array[#array + 1] = data[i]
    end
end

function ezWoW:Init()
    ezWoWCache = nil
    if ezWoWCache == nil then
        ezWoWCache = {}
        ezWoWCache.version = 0
    end

    ezWoWCharCache = nil
    if ezWoWCharCache == nil then
        ezWoWCharCache = {}
        ezWoWCharCache.version = 0
    end

    self.muteHistory = ezWoWCache.muteHistory
    self.bgSeason = ezWoWCache.bgSeason
    self.bgHistory = ezWoWCharCache.bgHistory
    self.arenaHistory = ezWoWCharCache.arenaHistory

    self.rates["RATE_XP_KILL_MIN"] = 0.0
    self.rates["RATE_XP_KILL_MAX"] = 1.0
    self.rates["RATE_XP_KILL_PREMIUM"] = 1.0
    self.rates["RATE_XP_QUEST_MIN"] = 0.0
    self.rates["RATE_XP_QUEST_MAX"] = 1.0
    self.rates["RATE_XP_QUEST_PREMIUM"] = 1.0
    self.rates["RATE_REPUTATION_MIN"] = 1.0
    self.rates["RATE_REPUTATION_MAX"] = 1.0
    self.rates["RATE_REPUTATION_PREMIUM"] = 1.0
    self.rates["RATE_HONOR_MIN"] = 0.0
    self.rates["RATE_HONOR_MAX"] = 1.0
    self.rates["RATE_HONOR_PREMIUM"] = 1.0

    self:RegisterHandler("BG_SEASON_INFO", function(data)
        ezWoWCache.bgSeason = data
        self.bgSeason = data
    end)

    self:RegisterHandler("BG_LADDER_INFO", function(data)
        self.bgLadderInfo = data
    end)

    self:RegisterHandler("BG_HISTORY", function(data, append)
        if append then
            AppendData(self.bgHistory, data)
        else
            ezWoWCharCache.bgHistory = data
            self.bgHistory = data
        end
    end)

    self:RegisterHandler("ARENA_SEASON_INFO", function(data)
        ezWoWCache.arenaSeason = data
        self.arenaSeason = data
    end)

    self:RegisterHandler("ARENA_LADDER_INFO", function(data)
        self.arenaInfo = data
    end)

    self:RegisterHandler("ARENA_HISTORY", function(data, append)
        if append then
            AppendData(self.arenaHistory, data)
        else
            ezWoWCharCache.arenaHistory = data
            self.arenaHistory = data
        end
    end)

    self:RegisterHandler("CONFIG", function(data)
        self.serverConfig = data
    end)
end

function ezWoW:CreateOption(optionKey, category)
    local option = {}
    option.value = 0            -- actual value from the server
    option.defaultValue = 0     -- default value
    option.clientValue = 0      -- just for UI
    option.category = category  -- also just for UI
    self.options[optionKey] = option
end

function ezWoW:HasPremium()
    local endDate = self.subscriptions["PREMIUM"]
    if endDate then
        return time() < endDate
    end
    return false
end

function ezWoW:HasEzPlus()
    local endDate = self.subscriptions["EZPLUS"]
    if endDate then
        return time() < endDate
    end
    return false
end

function ezWoW:RegisterHandler(event, handler)
    local handlers = self.eventHandlers[event]
    if handlers == nil then
        handlers = {}
        self.eventHandlers[event] = handlers
    end
    handlers[#handlers + 1] = handler
end

function ezWoW:UnregisterHandler(event, handler)
    local handlers = self.eventHandlers[event]
    if handlers ~= nil then
        for i = 1, #handlers do
            if handlers[i] == handler then
                table.remove(handlers, i)
                return
            end
        end
    end
end

function ezWoW:CallHandlers(event, ...)
    self.event = event
    local handlers = self.eventHandlers[event]
    if handlers ~= nil then
        for i = 1, #handlers do
            handlers[i](...)
        end
    end
    self.event = nil
end