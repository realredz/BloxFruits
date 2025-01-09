local Settings = select(1, ...) or {
  Translator = true,
  JoinTeam = "Pirates",
  Kaitun = false
}

local Owner = "realredz"
local Repository = `https://raw.githubusercontent.com/{ Owner }/BloxFruits/`
local SourceName = if Settings.Kaitun then "Kaitun" else "Main"

loadstring(game:HttpGet(`{ Repository }refs/heads/main/Scripts/{ SourceName }.lua`))(Settings)
