function Print(...)
	for _, content in ipairs({...}) do
		local call = istable(content) and PrintTable or print
		call(content)
	end
end

function CreateCVar(n, d, m)
	return CreateClientConVar(n, d, true, false, nil, 0, m or 1)
end

--[[function net.Incoming( len, client )

	local i = net.ReadHeader()
	local strName = util.NetworkIDToString(i)

	if not strName then return end

	local strName = strName:lower()
	local func = net.Receivers[strName]

	if not func then return end

	local g = table.Copy(_G)

	g["Reply"] = function(...)
		local args = {...}

		net.Start(strName)

		if #args > 0 then
			net.WriteType(args)
		end

		net[CLIENT and "SendToServer" or "Send"](client)
	end

	setfenv(func, g)

	--
	-- len includes the 16 bit int which told us the message name
	--
	len = len - 16

	func( len, client )
end]]