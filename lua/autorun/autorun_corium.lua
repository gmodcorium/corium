Corium = {}
Corium.__start = SysTime()
Corium.author = "gmodcorium"
Corium.url = "https://github.com/gmodcorium/corium"
Corium.version = 1.2
Corium.main_folder = "corium"
Corium.modules_folder = Corium.main_folder .. "/modules"

function Corium.use(t, f, ...)
	if t and t[f] then
		t[f](...)
	end
end

function Corium.check(c, fn)
	if c then
		fn()
	end
end

color_purple = Color(238,130,238)
local function get_path(p) return p .. "/*.lua" end
function console_log(...) MsgC(color_purple, "> ", color_white, ...) MsgN() end -- msgn нужен потому-что в msgc \n не работает

-- modules
-- all modules is shared by default

do
	local path = Corium.modules_folder
	local files = file.Find(get_path(path), "LUA")

	for _, file_name in ipairs(files) do
		local path_to_file = path .. "/" .. file_name
		if SERVER then
			AddCSLuaFile(path_to_file)
		end

		include(path_to_file)
	end
end

console_log("Corium initialized for ", color_purple, math.Round(SysTime() - Corium.__start, 3), color_white, "s")