Corium.commands = {}

local commands_list
commands_list = {
	info = {
		fn = function()
			console_log("Information about Corium\n  Version: " .. Corium.version .. "\n  Author: " .. Corium.author .. "\n  GitHub: " .. Corium.url)
		end,
	},

	check = {
		fn = function()
			http.Fetch("https://github.com/smokingplaya/corium/version.txt", function()
				-- проверка
			end, function(err)
				console_log("Failed to get version via github.", err)
			end)
		end,
	},

	help = {
		fn = function()
			local cmds = ""

			for k in pairs(commands_list) do
				cmds = cmds .. k .. " | "
			end

			cmds = cmds:Left(#cmds-3)

			console_log("Usage:\n  corium (" .. cmds .. ")")
		end
	}

	--execute_lua = function(args)
	--	if (#args <= 0) or (#args > 1) then console_log("Syntax error") return end
	--	RunString(args[1])
	--end,
}

function Corium.commands.Add(name, fn, superadmin_only) commands_list[name] = {fn = fn, superadmin_only = superadmin_only or false} end

concommand.Add("corium", function(pl, _, args)
	local command = args[1]
	if not command then console_log("There is no arguments") return end
	local command_fn = commands_list[command]
	if not command_fn or not command_fn.fn then console_log("Unknown command") return end
	if command_fn.superadmin_only and IsValid(pl) and not pl:IsSuperAdmin() then console_log("This command is superadmin only!") return end

	table.remove(args, 1)

	commands_list[command].fn(args)
end, function(cmd, args)
	args = args:Right(#args-1):Split(" ")

	local t = {}
	for n in pairs(commands_list) do
		if n:find(args[1]) then
			t[#t+1] = n
		end
	end

	return t
end)