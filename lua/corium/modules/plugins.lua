Corium.plugins = {}
Corium.plugins.list = {}
Corium.plugins_folder = Corium.main_folder .. "/plugins"

local plugin_file = "corium_plugins.json"

local is_plugin_disabled, plugin_set
Corium.check(SERVER, function()
	if not file.Exists(plugin_file, "DATA") then
		file.Append(plugin_file, "[]")
	end

	function is_plugin_disabled(n)
		local content = util.JSONToTable(file.Read(plugin_file, "DATA"))
		return content[n] == false
	end

	function plugin_set(n, b)
		local content = util.JSONToTable(file.Read(plugin_file, "DATA"))
		content[n] = b
		file.Write(plugin_file, util.TableToJSON(content))
	end
end)

local plugin_mt = {}
plugin_mt.__index = plugin_mt

function Corium.plugins.new(path)
	local id = string.GetFileFromFilename(path)
	if Corium.plugins.list[id] then return end

	local plugin_obj = {
		path = path,
		id = id,
		title = "",
		hooks = {},
		networks = {},
		is_loaded = false
	}

	setmetatable(plugin_obj, plugin_mt)

	Corium.plugins.list[id] = plugin_obj

	return plugin_obj
end

--function plugin_mt:SetID(id)
--	self.id = id
--	Corium.plugins[id] = self
--
--	return self
--end

function plugin_mt:SetTitle(title)
	self.title = title

	return self
end

local function find_n_load(path, n) n = path .. "/" .. n; if file.Exists(n, "LUA") then print(n) Corium.loader.include(n) end end

function plugin_mt:Load()
	plugin = self
	find_n_load(self.path, "cl_init.lua")
	find_n_load(self.path, "sv_init.lua")
	plugin = nil

	self.is_loaded = true
end

function plugin_mt:Reload()
	if not self.is_loaded then
		plugin:Load()

		return
	end

	self.is_loaded = false

	for k, v in pairs(self.hooks) do
		hook.Remove(k, v)
	end

	table.Empty(self.hooks)
	table.Empty(self.networks)

	self:Load()

	-- todo
end

function plugin_mt:Require(tab)
	for _, name in ipairs(tab) do
		local n = Corium.plugins_folder .. "/" .. name
		local p = Corium.plugins.list[name]
		if p and p.is_loaded then continue end

		Corium.plugins.new(Corium.plugins_folder .. "/" .. name):Load()
	end
end

function plugin_mt:Include(tab)
	for _, n in ipairs(tab) do
		Corium.loader.include(n)
	end
end

function plugin_mt:FormatName(n)
	return self.id .. "_" .. n
end

if SERVER then
	function plugin_mt:RegisterNetworks(tab)
		for _, n in ipairs(tab) do
			self.networks[#self.networks+1] = n
			util.AddNetworkString(self:FormatName(n))
		end
	end
end

function plugin_mt:Send(n, fn, pl)
	net.Start(self:FormatName(n))

	pl = IsEntity(fn) and fn:IsPlayer() and fn or pl

	if isfunction(fn) then
		fn()
	end

	net[SERVER and "Send" or "SendToServer"](pl)
end

function plugin_mt:Receive(n, f)
	net.Receive(self:FormatName(n), f)
end

function plugin_mt:Hook(n, f)
	self.hooks[n] = f
	hook.Add(n, self:FormatName(n), f)
end

-- Loader, Commands etc

Corium.check(Corium.loader, function()
	local _, folder = file.Find(Corium.plugins_folder .. "/*", "LUA")

	for _, f in ipairs(folder) do
		--if SERVER and is_plugin_disabled(f) then continue end
		local n = Corium.plugins_folder .. "/" .. f
		local p = Corium.plugins.list[f]
		if p and p.is_loaded then continue end

		local plug = Corium.plugins.new(Corium.plugins_folder .. "/" .. f)
		if (SERVER and not is_plugin_disabled(f)) or CLIENT then
			plug:Load()
		end
	end
end)

-- cli: reload
Corium.use(Corium.commands, "Add", "reload", function(args)
	if (#args <= 0) or (#args > 1) then console_log("Syntax error") return end
	local plugin = Corium.plugins.list[args[1]]

	if not plugin then
		console_log("Failed to get plugin \"" .. args[1] .. "\": Not loaded.")

		return
	end

	plugin:Reload() -- ЭТО ГЕНИАЛЬНО Б###Ь
end, true)

local color_loaded = Color(51, 255, 87)
local color_notloaded = Color(255, 87, 51)

-- cli: plugin_list
Corium.use(Corium.commands, "Add", "plugin_list", function(args)
	local pls = {}

	for n, p in pairs(Corium.plugins.list) do
		pls[#pls+1] = "["
		pls[#pls+1] = p.is_loaded and color_loaded or color_notloaded
		pls[#pls+1] = "•"
		pls[#pls+1] = color_white
		pls[#pls+1] = "] " .. n .. " - " .. (p.is_loaded and "loaded" or "not loaded") .. "\n  "
	end

	--pls = pls:Left(#pls-3)

	console_log("Current plugin list:\n  ", unpack(pls))
end)

-- cli: disable_plugin
Corium.use(Corium.commands, "Add", "disable_plugin", function(args)
	if (#args <= 0) or (#args > 1) then console_log("Syntax error") return end

	plugin_set(args[1], false)
end, true)

-- cli: enable_plugin
Corium.use(Corium.commands, "Add", "enable_plugin", function(args)
	if (#args <= 0) or (#args > 1) then console_log("Syntax error") return end

	plugin_set(args[1], true)
end, true)