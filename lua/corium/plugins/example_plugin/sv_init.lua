local plugin = plugin -- кэшируем plugin для использования на 9 строке

plugin:Include {"sh_init.lua"} -- инклюдим общий файл
plugin:RegisterNetworks { -- регистрируем нетстринги
	"Example"
}

plugin:Hook("PlayerSpawn", function(pl) -- добавляем хук
	plugin:Send("Example", pl) -- отправляем net игроку pl
end)