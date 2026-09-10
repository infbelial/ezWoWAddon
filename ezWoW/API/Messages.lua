function ezWoWAPI:SendMessage(msg)
    self.log:Messages("SEND", msg)
    SendAddonMessage("ezWoW", msg, "WHISPER", GetUnitName("player"))
end

-- Read digits and if 'term' is specified check for terminal symbol at the end of the number
local function ReadNumber(view, term)
    local startpos, endpos = view.str:find("[-+]?%d*%.?%d+", view.startpos)
    if not startpos or startpos ~= view.startpos then
        return nil
    end

    local result = view.str:sub(startpos, endpos)
    view.startpos = endpos + 1

    if term then
        local startpos, endpos = view.str:find(term, view.startpos)
        if startpos ~= view.startpos then
            return nil
        end
        view.startpos = endpos + 1
    end

    return tonumber(result)
end

-- Reads till terminal symbol 'term' is found
local function ReadIdentifier(view, term)
    local startpos = view.startpos
    local termstartpos, termendpos = view.str:find(term, view.startpos)
    if not termstartpos then
        return nil
    end

    local result = view.str:sub(startpos, termstartpos - 1)
    view.startpos = termendpos + 1
    return result, termstartpos
end

-- Reads key=value expression. Value, obviouly, should not contain 'term'.
local function ReadKeyValue(view, term)
    local key = ReadIdentifier(view, "=")
    local value, termpos = ReadIdentifier(view, term)

    if not key or not value then
        return nil, nil
    end
    return key, value
end

function ezWoWAPI:HandleInit(msg)
    local version   = ReadNumber(msg, ",")
    local acc       = ReadIdentifier(msg, ",")
    local memberId  = ReadNumber(msg, ";")

    if version == nil or acc == nil or memberId == nil then
        return false
    end

    -- This is just for the client, server controls everything that's needed
    self.account = acc
    ezWoWCache.version = version
    ezWoWCache.memberId = memberId
    return true
end

function ezWoWAPI:HandleMuteUpdate(msg)
    local id    = ReadNumber(msg, ",")
    local time  = ReadNumber(msg, ";")
    if not id or mute then
        return false
    end

    self.muteId = id
    self.muteEnd = time
    return true
end

function ezWoWAPI:HandleMuteHistory(msg)
    local last = ReadNumber(msg, ";")
    if last == nil then
        return false
    end

    self.muteHistory.entries = C_ezAPI.getBucketData("MUTE_HISTORY")
    self.muteHistory.lastId = last;
    return true
end


function ezWoWAPI:HandleOptions(msg)
    repeat
        local key, value = ReadKeyValue(msg, ";")
        if not key or not value then
            return false
        end
        -- self.Log:Debug("HandleOptions: "..key..":"..value)
        local option = self.options[key]
        if option then
            option.value = value;
        end
    until msg.startpos >= msg.endpos

    return true
end

function ezWoWAPI:HandleDefaultOptions(msg)
    repeat
        local key, value = ReadKeyValue(msg, ";")
        if not key or not value then
            return false
        end
        -- self.Log:Debug("HandleDefaultOptions: "..key..":"..value)
        local option = self.options[key]
        if option then
            option.defaultValue = value;
        end
    until msg.startpos >= msg.endpos
    return true
end

function ezWoWAPI:HandleRates(msg)
    repeat
        local key, value = ReadKeyValue(msg, ";")
        if not key then
            return false
        end
        -- self.Log:Debug("HandleRates: "..key..":"..value)
        self.rates[key] = tonumber(value);
    until msg.startpos >= msg.endpos

    return true
end

function ezWoWAPI:HandleSubscriptions(msg)
    repeat
        local key, value = ReadKeyValue(msg, ";")
        if not key then
            return false
        end
        -- self.Log:Debug("HandleSubscriptions: "..key..":"..value)
        self.subscriptions[key] = tonumber(value);
    until msg.startpos >= msg.endpos

    return true
end

function ezWoWAPI:HandlePremiumSpec(msg)
    self.premiumSpec = C_ezAPI.getBucketData("PREMIUM_SPEC")
    return true
end


local handlers =
{
    ["INIT"]            = ezWoWAPI.HandleInit,
    ["MUTE_UPDATE"]     = ezWoWAPI.HandleMuteUpdate,
    ["MUTE_HISTORY"]    = ezWoWAPI.HandleMuteHistory,
    ["SET_OPT"]         = ezWoWAPI.HandleOptions,
    ["SET_OPT_DEF"]     = ezWoWAPI.HandleDefaultOptions,
    ["SET_RATE"]        = ezWoWAPI.HandleRates,
    ["SET_SUB"]         = ezWoWAPI.HandleSubscriptions,
    ["PREMIUM_SPEC"]    = ezWoWAPI.HandlePremiumSpec,
}

function ezWoWAPI:HandleMessage(message)
    self.log:Messages("RECV", message)

    local handled = false

    local pos = string.find(message, ":")
    local cmd = message
    local args = message

    if pos then
        cmd = string.sub(message, 1, pos - 1)
        args = string.sub(message, pos + 1)
    end

    local handler = handlers[cmd]

    if handler then
        view = { str = args, startpos = 1, endpos = #args }
        handled = handler(self, view)
    end
    
    if not handled then
        self.log:Debug("Unhandled message: ", message)
    end
end
