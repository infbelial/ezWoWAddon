ezWoWAPI = 
{
    account = "",
    options = {},
    rates = {},
    subscriptions = {},
    muteId = 0,
    muteEnd = 0,
    muteHistory = nil, -- { entries = list, lastId = number }
    premiumSpec = {},
    log =
    {
        Debug = function(self, msg, ...)
            if self.enableDebug then
                print("[DEBUG]: ", msg, ...)
            end
        end,
        Messages = function(self, source, msg)
            if self.enableMessages then
                print(string.format("[%s]: %s", source, msg))
            end
        end
    },
}

function ezWoWAPI:Init()
    -- ezWoWCache = nil
    if ezWoWCache == nil then
        ezWoWCache = {}
        ezWoWCache.version = version
        ezWoWCache.memberId = 0
        ezWoWCache.muteHistory = { entries = nil, lastId = 0 }
    end

    self.muteHistory = ezWoWCache.muteHistory

    self.log.enableDebug       = false
    self.log.enableMessages    = false

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
end

function ezWoWAPI:CreateOption(optionKey, category)
    local option = {}
    option.value = 0            -- actual value from the server
    option.defaultValue = 0     -- default value
    option.clientValue = 0      -- just for UI
    option.category = category  -- also just for UI
    self.options[optionKey] = option
end

function ezWoWAPI:HasPremium()
    local endDate = self.subscriptions["PREMIUM"]
    if endDate then
        return time() < endDate
    end
    return false
end

function ezWoWAPI:HasEzPlus()
    local endDate = self.subscriptions["EZPLUS"]
    if endDate then
        return time() < endDate
    end
    return false
end
