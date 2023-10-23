local cached_packages = {}
function loadpkg(name) -- you can use this function on clientside
  local package_in_cache = cached_packages[name]
  if package_in_cache then return package_in_cache end
  if not name then error("There is no argument") end
  if not file.Exists("cpm/" .. name .. ".lua", "LUA") then error("Package \"" .. name .. "\" not installed.") end

  local arg = include("cpm/" .. name .. ".lua")

  if not arg or not istable(arg) then error("\"" .. name .. "\" library did not return the table.") end

  cached_packages[name] = arg

  return arg
end

if not SERVER then return end

require("gm_filesystem")

local github_repo = "gmodium/packages"
local sql_table = "cpm"
local function get_in_db(name)
  local query = sql.Query("SELECT * FROM " .. sql_table .. " WHERE name = " .. SQLStr(name))

  return istable(query) and query[1] or query
end

if not filesystem.Exists("lua/cpm") then
  filesystem.DirCreate("lua/cpm")
end

if not sql.TableExists(sql_table) then
  sql.Query("CREATE TABLE IF NOT EXISTS " .. sql_table .. " (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, allow_cl INTEGER)")
end

--

local files = file.Find("cpm/*.lua", "LUA")

for _, name in ipairs(files) do
  local d = get_in_db(name:Left(#name-4))

  if not d then continue end

  if d.allow_cl == "1" then
    AddCSLuaFile("cpm/" .. name)
  end
end

--

Corium.commands.Add("install", function(args)
  local name = args[1]
  if not name then console_log("There is no arguments") return end

  http.Fetch("https://raw.githubusercontent.com/" .. github_repo .. "/" .. (args[2] or "main") .. "/" .. name .. "/lib.lua", function(b)
    http.Fetch("https://raw.githubusercontent.com/" .. github_repo .. "/" .. (args[2] or "main") .. "/" .. name .. "/lib.json", function(json_b)
      local lib_info = util.JSONToTable(json_b)
      local allow_cl = lib_info.allow_clientside and lib_info.allow_clientside == "true"
      local path = "lua/cpm/" .. name .. ".lua"

      if filesystem.Exists(path) then
        filesystem.Remove(path)
      end
  
      filesystem.Create(path, b)

      if allow_cl then
        AddCSLuaFile("cpm/" .. name .. ".lua")
      end
  
      if not get_in_db(name) then
        sql.Query("INSERT INTO cpm(name, allow_cl) VALUES(" .. SQLStr(name).. ", " .. (allow_cl and 1 or 0) .. ")")
      end
    end, function(msg)
      console_log("Unable to install package \"" .. name .. "\", server response: " .. (msg "none"))
    end)
  end, function(msg)
    console_log("Unable to install package \"" .. name .. "\", server response: " .. (msg "none"))
  end)
end)

Corium.commands.Add("remove", function(args)
  local name = args[1]
  if not name then console_log("There is no arguments") return end

  if not get_in_db(name) then console_log("Didn't find the \"" .. name .. "\" in the database") return end

  local path = "lua/cpm/" .. name .. ".lua"

  if filesystem.Exists(path) then
    filesystem.Remove(path)
  else
    console_log("Strange: the mention of \"" .. name .. "\" is in the database, but the file itself is not.")
  end

  sql.Query("DELETE FROM cpm WHERE name = " .. SQLStr(name))
end)