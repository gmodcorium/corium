Corium.loader = {
	include_cl = function(path)
		if SERVER then
			AddCSLuaFile(path)
		else
			include(path)
		end
	end,

	include_sh = function(path)
		if SERVER then
			AddCSLuaFile(path)
		end

		include(path)
	end,

	include_sv = function(path)
		if SERVER then
			include(path)
		end
	end,

	include = function(path)
		Corium.loader["include_" .. string.GetFileFromFilename(path):Left(2)](path)
	end
}