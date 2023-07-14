# Corium 👾

Corium - это бесплатная библиотека для игры Garry's Mod с открытым кодом.

## Модули
Модуль - это файл дополняющий функционал Lua.

Модули, это единственное что загружается библиотекой по умолчанию, а дальше сами модули дополняют функционал библиотеки.

### Список модулей по умолчанию:

* **cli.lua**: Добавляет консольную команду corium, для удобного управления библиотекой из вашей командной строки в игре.
* **loader.lua**: Добавляет функции для удобного инклюда файлов.
* **other.lua**: Добавляет всякие полезные фичи.
* **plugins.lua**: Добавляет поддержку плагинов.

## Плагины
Плагины выполняют роль мини-аддонов в библиотеке.

По умолчанию система инклюдит только файлы **cl_init.lua** и **sv_init.lua**

[Пример того, как нужно писать плагины](https://github.com/smokingplaya/corium/tree/main/lua/corium/plugins/example_plugin)

### Список методов для плагинов:

```lua
plugin:SetTitle(string) -- Устанавливает заголовок плагина (unusual)
plugin:Load() -- Загружает плагин (internal)
plugin:Reload() -- Перезагружает плагин, или загружает его если он не был загружен.

plugin:Require(table) -- Загружает плагины из таблицы, если они не были загружены.
-- Нужно если один ваш плагин нуждается в функциях другого, но при этом другой плагин загружается после вашего.
-- Пример
plugin:Require {
  "plugin_name",
  ...
}

plugin:Include(table) -- Инклюдит файлы в папке вашего плагина.
-- Пример
plugin:Include {
  "sh_init.lua",
  ...
}

plugin:FormatName(string) -- Форматирует строку в вид pluginid_string (internal)
plugin:RegisterNetworks(table) -- Регистрирует NetworkString'и с названиями pluginid_name
-- Пример
plugin:RegisterNetworks {
  "Example" -- зарегистрирует NetworkString с названием pluginid_Example, где pluginid - название папки вашего плагина
  ...
}

plugin:Receive(name, function) -- Тоже самое что и функция net.Receive, но name здесь форматируется функцией plugin:FormatName()
-- Пример
plugin:RegisterNetworks {
  "Test"
}
plugin:Receive("Test", function() end)

plugin:Send(string, function or player, player) -- Отправляет net, где string - название net'а, function or player это функция между net.Start и net.Send* либо игрок, которому будет отправлен net, player - игрок
-- Пример
plugin:RegisterNetworks {
  "Test"
}
-- SERVER
plugin:Send("Test", function()
  net.WriteInt(1, 1)
end, Entity(1))

plugin:Send("Test", Entity(1))
-- CLIENT
plugin:Send("Test")
plugin:Send("Test", function()
  net.WriteInt(1, 1)
end)

plugin:Hook(string, function) -- Добавляет хук через hook.Add
-- Пример

plugin:Hook("PlayerSpawn", function(pl) end)
```
