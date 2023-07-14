plugin:Include {"sh_init.lua"} -- инклюдим общий файл

plugin:Receive("Example", function() -- принимаем net
	print("ama here!!!") -- выводим текст для теста
end)