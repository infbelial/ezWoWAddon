function ezWoW:SendMessage(msg)
    ezLog:Messages("SEND", msg)
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

function EzWoW_OnDataReceived(key, data, append)
    ezLog:Messages("DATA", key)
    ezWoW:CallHandlers(key, data, append)
end

function ezWoW:HandleInit(msg)
    local version   = ReadIdentifier(msg, ",")
    local acc       = ReadIdentifier(msg, ",")
    local memberId  = ReadNumber(msg, ";")

    if version == nil or acc == nil or memberId == nil then
        return false
    end

    if ezWoWCache.version ~= version then
        ezWoWCache = {}
        ezWoWCache.version = version
    end
    if ezWoWCharCache.version ~= version then
        ezWoWCharCache = {}
        ezWoWCharCache.version = version
    end

    self.account = acc
    self.memberId = memberId

    self:CallHandlers("INIT")
    return true
end

function ezWoW:HandleMuteUpdate(msg)
    local id    = ReadNumber(msg, ",")
    local time  = ReadNumber(msg, ";")
    if not id or mute then
        return false
    end

    self.muteId = id
    self.muteEnd = time
    return true
end

function ezWoW:HandleOptions(msg)
    repeat
        local key, value = ReadKeyValue(msg, ";")
        if not key or not value then
            return false
        end
        -- ezLog:Debug("HandleOptions: "..key..":"..value)
        local option = self.options[key]
        if option then
            option.value = value;
        end
    until msg.startpos >= msg.endpos

    return true
end

function ezWoW:HandleDefaultOptions(msg)
    repeat
        local key, value = ReadKeyValue(msg, ";")
        if not key or not value then
            return false
        end
        -- ezLog:Debug("HandleDefaultOptions: "..key..":"..value)
        local option = self.options[key]
        if option then
            option.defaultValue = value;
        end
    until msg.startpos >= msg.endpos
    return true
end

function ezWoW:HandleRates(msg)
    repeat
        local key, value = ReadKeyValue(msg, ";")
        if not key then
            return false
        end
        -- ezLog:Debug("HandleRates: "..key..":"..value)
        self.rates[key] = tonumber(value);
    until msg.startpos >= msg.endpos

    return true
end

function ezWoW:HandleSubscriptions(msg)
    repeat
        local key, value = ReadKeyValue(msg, ";")
        if not key then
            return false
        end
        -- ezLog:Debug("HandleSubscriptions: "..key..":"..value)
        self.subscriptions[key] = tonumber(value);
    until msg.startpos >= msg.endpos

    self:CallHandlers("SUBSCRIPTIONS")
    return true
end

local handlers =
{
    ["INIT"]            = ezWoW.HandleInit,
    ["MUTE_UPDATE"]     = ezWoW.HandleMuteUpdate,
    ["SET_OPT"]         = ezWoW.HandleOptions,
    ["SET_OPT_DEF"]     = ezWoW.HandleDefaultOptions,
    ["SET_RATE"]        = ezWoW.HandleRates,
    ["SET_SUB"]         = ezWoW.HandleSubscriptions,
}

function ezWoW:HandleMessage(message)
    ezLog:Messages("RECV", message)

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
        ezLog:Debug("Unhandled message: ", message)
    end
end
