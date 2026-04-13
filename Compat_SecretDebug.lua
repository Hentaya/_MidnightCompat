local unpack = unpack or table.unpack

MidnightCompatDebugDB = MidnightCompatDebugDB or {}
MidnightCompatDebugDB.enabled = MidnightCompatDebugDB.enabled or false
MidnightCompatDebugDB.verbose = MidnightCompatDebugDB.verbose or false
MidnightCompatDebugDB.maxEvents = MidnightCompatDebugDB.maxEvents or 300
MidnightCompatDebugDB.scrubEvents = MidnightCompatDebugDB.scrubEvents or {}

local function pack(...)
	return { n = select("#", ...), ... }
end

local function getIsSecret(value)
	if type(_G.issecretvalue) ~= "function" then
		return false, false
	end

	local ok, result = pcall(_G.issecretvalue, value)
	if not ok then
		return false, false
	end

	return result and true or false, true
end

local function safePreview(value, isSecret)
	if isSecret then
		return "<secret>"
	end

	local valueType = type(value)
	if valueType == "nil" then
		return "nil"
	elseif valueType == "boolean" or valueType == "number" then
		return tostring(value)
	elseif valueType == "string" then
		local preview = value:gsub("\r", "\\r"):gsub("\n", "\\n")
		if #preview > 120 then
			preview = preview:sub(1, 117) .. "..."
		end
		return preview
	else
		return tostring(value)
	end
end

local function describeValue(value, includePreview)
	local isSecret, secretCheckSupported = getIsSecret(value)
	local info = {
		luaType = type(value),
		isSecret = isSecret,
		secretCheckSupported = secretCheckSupported,
	}

	if includePreview and not isSecret then
		info.preview = safePreview(value, isSecret)
	end

	return info
end

local function buildEvent(inputArgs, outputArgs)
	local event = {
		time = date("%Y-%m-%d %H:%M:%S"),
		argc = inputArgs.n,
		outc = outputArgs.n,
		stack = debugstack(4, 12, 12),
		args = {},
		results = {},
		scrubbedIndexes = {},
		anyScrub = false,
	}

	local verbose = MidnightCompatDebugDB and MidnightCompatDebugDB.verbose
	local maxCount = math.max(inputArgs.n, outputArgs.n)

	for index = 1, maxCount do
		if index <= inputArgs.n then
			event.args[index] = describeValue(inputArgs[index], verbose)
		end

		if index <= outputArgs.n then
			event.results[index] = describeValue(outputArgs[index], verbose)
		end

		local argInfo = event.args[index]
		local resultInfo = event.results[index]

		if argInfo and argInfo.isSecret and resultInfo and resultInfo.luaType == "nil" then
			event.scrubbedIndexes[#event.scrubbedIndexes + 1] = index
			event.anyScrub = true
		end
	end

	return event
end

local function logEvent(event)
	local db = MidnightCompatDebugDB
	if not db or not db.enabled then
		return
	end

	local events = db.scrubEvents
	events[#events + 1] = event

	local maxEvents = db.maxEvents or 300
	while #events > maxEvents do
		table.remove(events, 1)
	end
end

do
	local original = _G.scrubsecretvalues
	local inHook = false

	if type(original) == "function" and not _G.MidnightCompatScrubWrapped then
		_G.MidnightCompatScrubWrapped = true
		_G.MidnightCompatScrubOriginal = original

		_G.scrubsecretvalues = function(...)
			local outputArgs = pack(original(...))
			local db = MidnightCompatDebugDB

			if inHook or not db or not db.enabled then
				return unpack(outputArgs, 1, outputArgs.n)
			end

			local inputArgs = pack(...)
			local shouldLog = false

			for index = 1, inputArgs.n do
				local isSecret = select(1, getIsSecret(inputArgs[index]))
				if isSecret then
					shouldLog = true
					break
				end
			end

			if shouldLog then
				inHook = true
				local ok, event = pcall(buildEvent, inputArgs, outputArgs)
				if ok and event then
					pcall(logEvent, event)
				end
				inHook = false
			end

			return unpack(outputArgs, 1, outputArgs.n)
		end
	end
end

SLASH_MIDNIGHTSCRUB1 = "/mscrub"
SlashCmdList["MIDNIGHTSCRUB"] = function(msg)
	msg = msg or ""
	local command, argument = msg:match("^(%S*)%s*(.-)$")
	command = string.lower(command or "")
	argument = string.lower(argument or "")

	local db = MidnightCompatDebugDB

	if command == "on" then
		db.enabled = true
		print("MidnightCompat scrub logging: ON")
	elseif command == "off" then
		db.enabled = false
		print("MidnightCompat scrub logging: OFF")
	elseif command == "clear" then
		db.scrubEvents = {}
		print("MidnightCompat scrub log cleared")
	elseif command == "verbose" then
		if argument == "on" or argument == "1" or argument == "true" then
			db.verbose = true
			print("MidnightCompat scrub verbose logging: ON")
		elseif argument == "off" or argument == "0" or argument == "false" then
			db.verbose = false
			print("MidnightCompat scrub verbose logging: OFF")
		else
			print("Usage: /mscrub verbose on|off")
		end
	elseif command == "status" or command == "" then
		local count = #(db.scrubEvents or {})
		print(
			"MidnightCompat scrub logging is "
				.. (db.enabled and "ON" or "OFF")
				.. "; verbose is "
				.. (db.verbose and "ON" or "OFF")
				.. "; events logged: "
				.. count
		)
	else
		print("Usage: /mscrub on | off | clear | status | verbose on|off")
	end
end
