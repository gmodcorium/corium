function loadpkg(name) -- you can use this function on clientside
  if not name then error("There is no argument") end
  if not filesystem.Exists("lua/cpm/" .. name .. ".lua") then error("Package \"" .. name .. "\n not installed.") end

  local args = {include("cpm")}

  if #args == 0 then error("\"" .. name .. "\"library did not return the arguments.") end

  return unpack(args)
end

if not SERVER then return end

require("gm_filesystem")

-- continue

local function get_in_db(name) local query = sql.Query("SELECT * FROM cpm WHERE name = " .. SQLStr(name)) return istable(query) and query[1] or query end

local github_repo = "gmodcorium/packages" -- не советую трогать
local sql_table = "cpm" -- не трогать!

if not filesystem.Exists("lua/cpm") then
  filesystem.DirCreate("lua/cpm")
end

if not sql.TableExists(sql_table) then
  sql.Query("CREATE TABLE IF NOT EXISTS " .. sql_table .. " (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)")
end

// local lib = loadpkg("luandum")
// lib.create_class(...)

-- corium install test main
local has_installation_currently = false
Corium.commands.Add("install", function(args)
  if has_installation_currently then console_log("You're already installing a different package!") return end
  has_installation_currently = true
  local name = args[1]
  if not name then console_log("There is no arguments") has_installation_currently = false return end

  http.Fetch("https://raw.githubusercontent.com/" .. github_repo .. "/" .. (args[2] or "main") .. "/" .. name .. ".lua", function(b)
    local path = "lua/cpm/" .. name .. ".lua"
  
    if filesystem.Exists(path) then
      filesystem.Remove(path)
    end

    filesystem.Create(path, b)

    has_installation_currently = false

    if not get_in_db(name) then
      sql.Query("INSERT INTO cpm(name) VALUES(" .. SQLStr(name).. ")")
    end
  end, function(msg)
    has_installation_currently = false
    console_log("Unable to install package \"" .. name .. "\", server response: " .. (msg "none"))
  end)
end)

Corium.commands.Add("remove", function(args)
  local name = args[1]
  if not name then console_log("There is no arguments") return end

  if not get_in_db(name) then console_log("Didn't find the \"" .. name .. "\" in the database") return end

  http.Fetch("https://raw.githubusercontent.com/" .. github_repo .. "/" .. (args[2] or "main") .. "/" .. name .. ".lua", function(b)
    local path = "lua/cpm/" .. name .. ".lua"

    if filesystem.Exists(path) then
      filesystem.Remove(path)
    else
      console_log("Strange: the mention of \"" .. name .. "\" is in the database, but the file itself is not.")
    end

    sql.Query("DELETE FROM cpm WHERE name = " .. SQLStr(name))
  end, function(msg)
    console_log("Unable to install package \"" .. name .. "\", server response: " .. (msg "none"))
  end)
end)