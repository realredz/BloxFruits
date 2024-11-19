local _env = getgenv and getgenv() or {}
local _spawn, _find, _insert = task.spawn, table.find, table.insert
local m_clamp, m_huge, _wait = math.clamp, math.huge, task.wait
local Vector3_new = Vector3.new
local CFrame_new = CFrame.new

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local LogService = game:GetService("LogService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local function WaitChilds(path, ...)
  local last = path
  for _,child in ({...}) do
    last = last:FindFirstChild(child) or last:WaitForChild(child, 10)
  end
  return last
end

local CombatFramework = WaitChilds(Player, "PlayerScripts", "CombatFramework")
local RigControllerEvent = ReplicatedStorage:WaitForChild("RigControllerEvent")
local CFWReplicated = ReplicatedStorage:WaitForChild("CombatFramework")
local RigLib = CFWReplicated:WaitForChild("RigLib")

local WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Characters = workspace:WaitForChild("Characters")
local Enemies = workspace:WaitForChild("Enemies")
local NPCs = workspace:WaitForChild("NPCs")

local EnemySpawns = WorldOrigin:WaitForChild("EnemySpawns")
local Locations = WorldOrigin:WaitForChild("Locations")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Validator = Remotes:WaitForChild("Validator")
local CommF_ = Remotes:WaitForChild("CommF_")

local sethiddenproperty = sethiddenproperty or (function()end)
local setupvalue = setupvalue or getupvalues and (function(f, i, v) getupvalues(f)[i] = v end) or (function()end)
local getupvalue = getupvalue or getupvalues and (function(f, i) return getupvalues(f)[i] end) or (function()end)

local Module = {} do
  Module.__index = Module
  Module.WaitPart = WaitChilds
  Module.MaxLevel = 2550
  Module.EnemySpawns = {}
  Module.Bosses = {
    -- Bosses Sea 1
    ["Saber Expert"] = {
      NoQuest = true,
      Position = CFrame_new(-1461, 30, -51)
    },
    ["The Saw"] = {
      RaidBoss = true,
      Position = CFrame_new(-690, 15, 1583)
    },
    ["Greybeard"] = {
      RaidBoss = true,
      Position = CFrame_new(-4807, 21, 4360)
    },
    ["The Gorilla King"] = {
      IsBoss = true,
      Level = 20,
      Position = CFrame_new(-1128, 6, -451),
      Quest = {"JungleQuest", CFrame_new(-1598, 37, 153)}
    },
    ["Bobby"] = {
      IsBoss = true,
      Level = 55,
      Position = CFrame_new(-1131, 14, 4080),
      Quest = {"BuggyQuest1", CFrame_new(-1140, 4, 3829)}
    },
    ["Yeti"] = {
      IsBoss = true,
      Level = 105,
      Position = CFrame_new(1185, 106, -1518),
      Quest = {"SnowQuest", CFrame_new(1385, 87, -1298)}
    },
    ["Vice Admiral"] = {
      IsBoss = true,
      Level = 130,
      Position = CFrame_new(-4807, 21, 4360),
      Quest = {"MarineQuest2", CFrame_new(-5035, 29, 4326), 2}
    },
    ["Swan"] = {
      IsBoss = true,
      Level = 240,
      Position = CFrame_new(5230, 4, 749),
      Quest = {"ImpelQuest", CFrame_new(5191, 4, 692)}
    },
    ["Chief Warden"] = {
      IsBoss = true,
      Level = 230,
      Position = CFrame_new(5230, 4, 749),
      Quest = {"ImpelQuest", CFrame_new(5191, 4, 692), 2}
    },
    ["Warden"] = {
      IsBoss = true,
      Level = 220,
      Position = CFrame_new(5230, 4, 749),
      Quest = {"ImpelQuest", CFrame_new(5191, 4, 692), 1}
    },
    ["Magma Admiral"] = {
      IsBoss = true,
      Level = 350,
      Position = CFrame_new(-5694, 18, 8735),
      Quest = {"MagmaQuest", CFrame_new(-5319, 12, 8515)}
    },
    ["Fishman Lord"] = {
      IsBoss = true,
      Level = 425,
      Position = CFrame_new(61350, 31, 1095),
      Quest = {"FishmanQuest", CFrame_new(61122, 18, 1567)}
    },
    ["Wysper"] = {
      IsBoss = true,
      Level = 500,
      Position = CFrame_new(-7927, 5551, -637),
      Quest = {"SkyExp1Quest", CFrame_new(-7861, 5545, -381)}
    },
    ["Thunder God"] = {
      IsBoss = true,
      Level = 575,
      Position = CFrame_new(-7751, 5607, -2315),
      Quest = {"SkyExp2Quest", CFrame_new(-7903, 5636, -1412)}
    },
    ["Cyborg"] = {
      IsBoss = true,
      Level = 675,
      Position = CFrame_new(6138, 10, 3939),
      Quest = {"FountainQuest", CFrame_new(5258, 39, 4052)}
    },
    
    -- Bosses Sea 2
    ["Don Swan"] = {
      RaidBoss = true,
      Position = CFrame_new(2289, 15, 808)
    },
    ["Cursed Captain"] = {
      RaidBoss = true,
      Position = CFrame_new(912, 186, 33591)
    },
    ["Darkbeard"] = {
      RaidBoss = true,
      Position = CFrame_new(3695, 13, -3599)
    },
    ["Diamond"] = {
      IsBoss = true,
      Level = 750,
      Position = CFrame_new(-1569, 199, -31),
      Quest = {"Area1Quest", CFrame_new(-427, 73, 1835)}
    },
    ["Jeremy"] = {
      IsBoss = true,
      Level = 850,
      Position = CFrame_new(2316, 449, 787),
      Quest = {"Area2Quest", CFrame_new(635, 73, 919)}
    },
    ["Fajita"] = {
      IsBoss = true,
      Level = 925,
      Position = CFrame_new(-2086, 73, -4208),
      Quest = {"MarineQuest3", CFrame_new(-2441, 73, -3219)}
    },
    ["Smoke Admiral"] = {
      IsBoss = true,
      Level = 1150,
      Position = CFrame_new(-5078, 24, -5352),
      Quest = {"IceSideQuest", CFrame_new(-6061, 16, -4904)}
    },
    ["Awakened Ice Admiral"] = {
      IsBoss = true,
      Level = 1400,
      Position = CFrame_new(6473, 297, -6944),
      Quest = {"FrostQuest", CFrame_new(5668, 28, -6484)}
    },
    ["Tide Keeper"] = {
      IsBoss = true,
      Level = 1475,
      Position = CFrame_new(-3711, 77, -11469),
      Quest = {"ForgottenQuest", CFrame_new(-3056, 240, -10145)}
    },
    
    -- Bosses Sea 3
    ["Cake Prince"] = {
      RaidBoss = true,
      Position = CFrame_new(-2103, 70, -12165)
    },
    ["Dough King"] = {
      RaidBoss = true,
      Position = CFrame_new(-2103, 70, -12165)
    },
    ["rip_indra True Form"] = {
      RaidBoss = true,
      Position = CFrame_new(-5333, 424, -2673)
    },
    ["Stone"] = {
      IsBoss = true,
      Level = 1550,
      Position = CFrame_new(-1049, 40, 6791),
      Quest = {"PiratePortQuest", CFrame_new(-291, 44, 5580)}
    },
    ["Island Empress"] = {
      IsBoss = true,
      Level = 1675,
      Position = CFrame_new(5730, 602, 199),
      Quest = {"AmazonQuest2", CFrame_new(5448, 602, 748)}
    },
    ["Kilo Admiral"] = {
      IsBoss = true,
      Level = 1750,
      Position = CFrame_new(2889, 424, -7233),
      Quest = {"MarineTreeIsland", CFrame_new(2180, 29, -6738)}
    },
    ["Captain Elephant"] = {
      IsBoss = true,
      Level = 1875,
      Position = CFrame_new(-13393, 319, -8423),
      Quest = {"DeepForestIsland", CFrame_new(-13233, 332, -7626)}
    },
    ["Beautiful Pirate"] = {
      IsBoss = true,
      Level = 1950,
      Position = CFrame_new(5241, 23, 129),
      Quest = {"DeepForestIsland2", CFrame_new(-12682, 391, -9901)}
    },
    ["Cake Queen"] = {
      IsBoss = true,
      Level = 2175,
      Position = CFrame_new(-710, 382, -11150),
      Quest = {"IceCreamIslandQuest", CFrame_new(-818, 66, -10964)}
    },
    ["Longma"] = {
      NoQuest = true,
      Position = CFrame_new(-10218, 333, -9444)
    }
  }
  Module.FruitsID = {
    ["rbxassetid://15060012861"] = "Rocket-Rocket",
    ["rbxassetid://15057683975"] = "Spin-Spin",
    ["rbxassetid://15104782377"] = "Chop-Chop",
    ["rbxassetid://15105281957"] = "Spring-Spring",
    ["rbxassetid://15116740364"] = "Bomb-Bomb",
    ["rbxassetid://15116696973"] = "Smoke-Smoke",
    ["rbxassetid://15107005807"] = "Spike-Spike",
    ["rbxassetid://15111584216"] = "Flame-Flame",
    ["rbxassetid://15112469964"] = "Falcon-Falcon",
    ["rbxassetid://15100433167"] = "Ice-Ice",
    ["rbxassetid://15111517529"] = "Sand-Sand",
    ["rbxassetid://15111553409"] = "Dark-Dark",
    ["rbxassetid://15112600534"] = "Diamond-Diamond",
    ["rbxassetid://15100283484"] = "Light-Light",
    ["rbxassetid://15104817760"] = "Rubber-Rubber",
    ["rbxassetid://15100485671"] = "Barrier-Barrier",
    ["rbxassetid://15112333093"] = "Ghost-Ghost",
    ["rbxassetid://15105350415"] = "Magma-Magma",
    ["rbxassetid://15057718441"] = "Quake-Quake",
    ["rbxassetid://15100313696"] = "Buddha-Buddha",
    ["rbxassetid://15116730102"] = "Love-Love",
    ["rbxassetid://15116967784"] = "Spider-Spider",
    ["rbxassetid://14661873358"] = "Sound-Sound",
    ["rbxassetid://15100246632"] = "Phoenix-Phoenix",
    ["rbxassetid://15112215862"] = "Portal-Portal",
    ["rbxassetid://15116747420"] = "Rumble-Rumble",
    ["rbxassetid://15116721173"] = "Pain-Pain",
    ["rbxassetid://15100384816"] = "Blizzard-Blizzard",
    ["rbxassetid://15100299740"] = "Gravity-Gravity",
    ["rbxassetid://14661837634"] = "Mammoth-Mammoth",
    ["rbxassetid://15708895165"] = "T-Rex-T-Rex",
    ["rbxassetid://15100273645"] = "Dough-Dough",
    ["rbxassetid://15112263502"] = "Shadow-Shadow",
    ["rbxassetid://15100184583"] = "Control-Control",
    ["rbxassetid://15106768588"] = "Leopard-Leopard",
    ["rbxassetid://15482881956"] = "Kitsune-Kitsune",
    ["https://assetdelivery.roblox.com/v1/asset/?id=10395893751"] = "Venom-Venom",
    ["https://assetdelivery.roblox.com/v1/asset/?id=10537896371"] = "Dragon-Dragon"
  }
  Module.Shop = {
    {"Frags", { {"Race Rerol", {"BlackbeardReward", "Reroll", "2"}}, {"Reset Stats", {"BlackbeardReward", "Refund", "2"}} }},
    {"Fighting Style", {
      {"Buy Black Leg", {"BuyBlackLeg"}},
      {"Buy Electro", {"BuyElectro"}},
      {"Buy Fishman Karate", {"BuyFishmanKarate"}},
      {"Buy Dragon Claw", {"BlackbeardReward", "DragonClaw", "2"}},
      {"Buy Superhuman", {"BuySuperhuman"}},
      {"Buy Death Step", {"BuyDeathStep"}},
      {"Buy Sharkman Karate", {"BuySharkmanKarate"}},
      {"Buy Electric Claw", {"BuyElectricClaw"}},
      {"Buy Dragon Talon", {"BuyDragonTalon"}},
      {"Buy GodHuman", {"BuyGodhuman"}},
      {"Buy Sanguine Art", {"BuySanguineArt"}}
    }},
    {"Ability Teacher", {
      {"Buy Geppo", {"BuyHaki", "Geppo"}},
      {"Buy Buso", {"BuyHaki", "Buso"}},
      {"Buy Soru", {"BuyHaki", "Soru"}},
      {"Buy Ken", {"KenTalk", "Buy"}}
    }},
    {"Sword", {
      {"Buy Katana", {"BuyItem", "Katana"}},
      {"Buy Cutlass", {"BuyItem", "Cutlass"}},
      {"Buy Dual Katana", {"BuyItem", "Dual Katana"}},
      {"Buy Iron Mace", {"BuyItem", "Iron Mace"}},
      {"Buy Triple Katana", {"BuyItem", "Triple Katana"}},
      {"Buy Pipe", {"BuyItem", "Pipe"}},
      {"Buy Dual-Headed Blade", {"BuyItem", "Dual-Headed Blade"}},
      {"Buy Soul Cane", {"BuyItem", "Soul Cane"}},
      {"Buy Bisento", {"BuyItem", "Bisento"}}
    }},
    {"Gun", {
      {"Buy Musket", {"BuyItem", "Musket"}},
      {"Buy Slingshot", {"BuyItem", "Slingshot"}},
      {"Buy Flintlock", {"BuyItem", "Flintlock"}},
      {"Buy Refined Slingshot", {"BuyItem", "Refined Slingshot"}},
      {"Buy Refined Flintlock", {"BuyItem", "Refined Flintlock"}},
      {"Buy Cannon", {"BuyItem", "Cannon"}},
      {"Buy Kabucha", {"BlackbeardReward", "Slingshot", "2"}}
    }},
    {"Accessories", {
      {"Buy Black Cape", {"BuyItem", "Black Cape"}},
      {"Buy Swordsman Hat", {"BuyItem", "Swordsman Hat"}},
      {"Tomoe Ring", {"BuyItem", "Tomoe Ring"}}
    }},
    {"Race", {{"Ghoul Race", {"Ectoplasm", "Change", 4}}, {"Cyborg Race", {"CyborgTrainer", "Buy"}}, }}
  }
  
  -- //////////// --
  
  function EquipToolName(TName)
    local Char = Player.Character
    if Module:IsAlive(Char) and Player.Backpack:FindFirstChild(TName) then
      Char.Humanoid:EquipTool(Player.Backpack[TName])
    end
  end
  
  function EnableBuso()
    local Char = Player.Character
    if _env.AutoHaki and Module:IsAlive(Char) and not Char:FindFirstChild("HasBuso") then
      Module:FireRemote("Buso")
    end
  end
  
  function EquipTool()
    for _,tool in pairs(Player.Backpack:GetChildren()) do
      if tool.ToolTip == _env.FarmTool then
        EquipToolName(tool.Name)
      end
    end
  end
  
  -- //////////// -- 
  
  function Module:IsAlive(Char)
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    return Hum and Hum.Health > 0
  end
  
  function Module:FireRemote(...)
    return CommF_:InvokeServer(...)
  end
  
  function Module:ServerHop(Region, MaxPlayers)
    MaxPlayers = MaxPlayers or self.SH_MaxPlrs or 8
    Region = Region or self.SH_Region or "Singapore"
    for i = 1, 100 do
      pcall(function()
        Player.PlayerGui.ServerBrowser.Frame.Filters.SearchRegion.TextBox.Text = Region
      end)
      local Servers = ReplicatedStorage.__ServerBrowser:InvokeServer(i)
      for id,info in pairs(Servers) do
        if id ~= game.JobId and info["Count"] <= MaxPlayers then
          spawn(function() ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", id) end)
				end
      end
    end
  end
  
  function Module:VerifyEnemy(EName)
    local EnemySpawn = self.EnemySpawns[EName]
    if EnemySpawn then
      for path, Pos in pairs(EnemySpawn) do
        if path:GetAttribute("Active") then return true end
      end
    else
      for _,Enemy in ipairs(Enemies:GetChildren()) do
        if Enemy.Name == EName and self:IsAlive(Enemy) then return true end
      end
      return self:IsAlive(ReplicatedStorage:FindFirstChild(EName)) and ReplicatedStorage[EName]
    end
  end
  
  function Module:GetEnemies(EName, One)
    if One == true then
      for _,v in ipairs(EName) do
        local Enemy = ReplicatedStorage:FindFirstChild(v) or Enemies:FindFirstChild(v)
        if self:IsAlive(Enemy) then
          return Enemy
        end
      end
      return false
    end
    
    local Distance = One or m_huge
    return self:GetAllEnemies(function(Enemy)
      if _find(EName, Enemy.Name) then
        local PP = Enemy.PrimaryPart
        if PP and Player:DistanceFromCharacter(PP.Position) < Distance then
          Distance = Player:DistanceFromCharacter(PP.Position)
          return true
        end
      end
    end)[1]
  end
  
  function Module:BringEnemies(_Enemy)
    if not self:IsAlive(_Enemy) then return end
    
    if _env.BringMobs then
      for _,Enemy in ipairs(Enemies:GetChildren()) do
        if Enemy.Name == _Enemy.Name and Enemy ~= _Enemy and self:IsAlive(Enemy) then
          local PP, Hum = Enemy.PrimaryPart, Enemy.Humanoid
          if PP and (PP.Position - _Enemy.PrimaryPart.Position).Magnitude < _env.BringMobsDistance then
            Hum.WalkSpeed = 0
            Hum:ChangeState(14)
            PP.CanCollide = false
            PP.Size = Vector3_new(50, 50, 50)
            PP.CFrame = _Enemy.PrimaryPart.CFrame
          end
        end
      end
      pcall(sethiddenproperty, Player, "SimulationRadius",  m_huge)
    else
      local PP, Hum = _Enemy.PrimaryPart, _Enemy.Humanoid
      if PP then
        PP.CanCollide = false
        PP.Size = Vector3_new(50, 50, 50)
        Hum.WalkSpeed = 0
        Hum:ChangeState(14)
      end
    end
  end
  
  function Module:GetAllEnemies(Func)
    local List = {}
    for _,Enemy in ipairs(Enemies:GetChildren()) do
      if self:IsAlive(Enemy) and (not Func or Func(Enemy)) then _insert(List, Enemy) end
    end
    for _,Enemy in ipairs(ReplicatedStorage:GetChildren()) do
      if self:IsAlive(Enemy) and (not Func or Func(Enemy)) then _insert(List, Enemy) end
    end
    return List
  end
  
  function Module:KillAura(Distance)
    Distance = Distance or 1500
    for _,Enemy in ipairs(Enemies:GetChildren()) do
      local PP = Enemy.PrimaryPart
      if self:IsAlive(Enemy) and PP and Player:DistanceFromCharacter(PP.Position) < Distance then
        PP.CanCollide = false
        PP.Size = Vector3_new(60, 60, 60)
        Humanoid:ChangeState(15)
        Humanoid.Health = 0
      end
    end
    pcall(sethiddenproperty, Player, "SimulationRadius", m_huge)
  end
  
  function Module:JoinTeam(Team)
    local _team = Team:lower() or "pirates"
    local MainGui = WaitChilds(Player, "PlayerGui", "Main")
    
    local FireButton = function(Button)
      for _,val in next, getconnections(Button.Activated) do
        _spawn(pcall, val.Function)
      end
    end
    
    if MainGui:FindFirstChild("ChooseTeam") and Player.Team == nil then
      for i = 1, 25 do _wait()
        if not MainGui:FindFirstChild("ChooseTeam") or Player.Team ~= nil then
          break
        else
          if _team:find("pirate") then
            pcall(FireButton, WaitChilds(MainGui, "ChooseTeam", "Container", "Pirates", "Frame", "ViewportFrame", "TextButton"))
          else
            pcall(FireButton, WaitChilds(MainGui, "ChooseTeam", "Container", "Marines", "Frame", "ViewportFrame", "TextButton"))
          end
        end
      end
    end
  end
  
  function Module:VerifyMoon(assetid)
    return (Lighting.Sky.MoonTextureId == ("http://www.roblox.com/asset/?id=" .. assetid))
  end
  
  local _SavedName = {}
  function Module:GetRealFruitName(Fruit)
    if Fruit.Name ~= "Fruit " then return Fruit.Name end
    if _SavedName[Fruit] then return _SavedName[Fruit] end
    
    local FruitHandle = WaitChilds(Fruit, "Fruit", "Fruit")
    
    if FruitHandle and FruitHandle:IsA("MeshPart") then
      local FruitName = self.RealFruitName[tostring(FruitHandle.MeshId)]
      
      if FruitName and type(FruitName) == "string" then
        local FruitName = ("Fruit [ " .. FruitName .. " ]")
        SaveList[Fruit] = FruitName
        return FruitName
      end
    end
    
    SaveList[Fruit] = ("Fruit [ ??? ]")
    return ("Fruit [ ??? ]")
  end
  
  _spawn(function()
    --[[local OldHook
    OldHook = hookmetamethod(Player, "__newindex", function(self, index, Value)
      if tostring(self) == "Humanoid" and index == "WalkSpeed" then
        return OldHook(self, index, WalkSpeedBypass or Value)
      end
      return OldHook(self, index, Value)
    end)]]
  end)
  
  _spawn(function()
    --[[for _,Connection in pairs(getconnections(LogService.MessageOut)) do
      Connection:Disconnect()
    end]]
  end)
  
  _spawn(function()
    local DeathM = require(WaitChilds(ReplicatedStorage, "Effect", "Container", "Death"))
    local CameraShaker = require(WaitChilds(ReplicatedStorage, "Util", "CameraShaker"))
    
    CameraShaker:Stop()
    hookfunction(DeathM, function()end)
  end)
  
  _spawn(function()
    local AimBotPart
    local MouseModule = WaitChilds(ReplicatedStorage, "Mouse")
    local Skills = {"Z", "X", "C", "V", "F"}
    
    Module.AimBotPart = function(RootPart)
      local Mouse = require(MouseModule)
      Mouse.Hit = CFrame_new(RootPart.Position)
      Mouse.Target = RootPart
      AimBotPart = ({ RootPart, RootPart.Position })
    end
    
    local CheckTeam = function(plr)
      return plr.Team and plr.Team.Name == "Pirates" or plr.Team ~= Player.Team
    end
    
    local GetNearestPlayer = function()
      local Distance, Nearest = m_huge
      for _,plr in ipairs(Players:GetPlayers()) do
        local Char = plr.Character
        if plr ~= Player and Module:IsAlive(Char) and CheckTeam(plr) then
          local Mag = Char.PrimaryPart and Player:DistanceFromCharacter(Char.PrimaryPart.Position)
          if Mag and Mag < Distance then
            Distance, Nearest = Mag, plr.Character
          end
        end
      end
      _env.NearestPlayer = Nearest and { PrimaryPart = Nearest.PrimaryPart, Position = Nearest.PrimaryPart.Position }
    end
    
    _spawn(function()
      local OldHook
      OldHook = hookmetamethod(game, "__namecall", function(self, V1, V2, ...)
        local Method = getnamecallmethod():lower()
        if tostring(self) == "RemoteEvent" and Method == "fireserver" then
          if typeof(V1) == "Vector3" then
            if AimBotPart then
              if AutoFarmSea or AutoWoodPlanks or Sea2_AutoFarmSea or AutoFarmMastery then
                if SeaAimBotSkill or AimBotSkill then
                  local part = AimBotPart[1]
                  return OldHook(self, part and part.Position or AimBotPart[2], V2, ...)
                end
              end
            end
            local NearP = _env.NearestPlayer
            if AimbotPlayer and NearP then
              local pp = NearP.PrimaryPart
              return OldHook(self, pp and pp.Position or NearP.Position, V2, ...)
            end
          end
        elseif Method == "invokeserver" then
          if type(V1) == "string" then
            if V1 == "TAP" and typeof(V2) == "Vector3" then
              local NearP = _env.NearestPlayer
              if AimbotTap and NearP then
                local pp = NearP.PrimaryPart
                return OldHook(self, "TAP", pp and pp.Postion or NearP.Position, ...)
              end
            else
              local Enemie = ...
              if table.find(Skills, V1) and typeof(V2) == "Vector3" and not Enemie then
                if AimBotPart then
                  if AutoFarmSea or AutoWoodPlanks or Sea2_AutoFarmSea or AutoFarmMastery then
                    if SeaAimBotSkill or AimBotSkill then
                      local part = AimBotPart[1]
                      return OldHook(self, part and part.Position or AimBotPart[2], V2, ...)
                    end
                  end
                end
                local NearP = _env.NearestPlayer
                if AimbotPlayer and NearP then
                  local pp = NearP.PrimaryPart
                  if pp then
                    return OldHook(self, V1, pp.Position, pp, ...)
                  end
                end
              end
            end
          end
        end
        return OldHook(self, V1, V2, ...)
      end)
    end)
    
    RunService.Stepped:Connect(GetNearestPlayer)
  end)
  
  _spawn(function()
    local EnemyList = Module.EnemySpawns
    
    local function CheckEnemieName(string)
      return string:find("Lv. ") and string:gsub(" %pLv. %d+%p", "") or string
    end
    
    for _,Enemy in next, EnemySpawns:GetChildren() do
      if Enemy:GetAttribute("DisplayName") then
        local EName = CheckEnemieName(Enemy.Name)
        if not EnemyList[EName] then EnemyList[EName] = {} end
        EnemyList[EName][Enemy] = CFrame_new(Enemy.Position + Vector3_new(0, 30, 0))
      end
    end
  end)
  
  Module.FastAttack = (function()
    local _FastAttack = {}
    local CbtModule = getupvalue(require(CombatFramework), 2)
    
    local function CheckStun()
    	return Player.Character:FindFirstChild("Stun") and Player.Character.Stun.Value ~= 0
    end
    
    local function getBladeHitsEnemy(Distance)
      local Hits = {}
      for _,Enemy in ipairs(Enemies:GetChildren()) do
        local PP = Enemy.PrimaryPart
        if Module:IsAlive(Enemy) and PP and Player:DistanceFromCharacter(PP.Position) < Distance then
          _insert(Hits, PP)
        end
      end
      return Hits
    end
    
    local function getBladeHitsPlayer(Distance)
      local Hits = {}
      for _,Char in pairs(Characters:GetChildren()) do
        local PP = Char.PrimaryPart
        if Module:IsAlive(Char) and Char ~= Player.Character then
          if PP and Player:DistanceFromCharacter(PP.Position) < Distance then
            _insert(Hits, PP)
          end
        end
      end
      return Hits
    end
    
    local function getAllBladeHits(...)
      local Hits = getBladeHitsEnemy(...)
      for _,v in ipairs(getBladeHitsPlayer(...)) do
        _insert(Hits, v)
      end
      return Hits
    end
    
    function _FastAttack.BladeHitAttack()
      if not Module:IsAlive(Player.Character) then return end
      if not _env.FastAttack then
        return VirtualUser:CaptureController(), VirtualUser:Button1Down(Vector2.new(1e4, 1e4))
      end
      
      local AC = CbtModule.activeController
      if AC.equipped and not CheckStun() then
        local BladeHits = getAllBladeHits(AttackDistance and 60 or AC.hitboxMagnitude)
        
        if #BladeHits > 0 then
          local Val1 = getupvalue(AC.attack, 5) -- A
          local Val2 = getupvalue(AC.attack, 6) -- B
          local Val3 = getupvalue(AC.attack, 4) -- C
          local Val4 = getupvalue(AC.attack, 7) -- D
          local Val5 = ((Val1 * 798405 + Val3 * 727595) % Val2)
          local Val6 = (Val3 * 798405)
          
          Val5 = ((Val5 * Val2 + Val6) % 1099511627776)
          Val1 = (math.floor(Val5 / Val2))
          Val3 = (Val5 - Val1 * Val2)
          Val4 = (Val4 + 1)
          
          setupvalue(AC.attack, 5, Val1)
          setupvalue(AC.attack, 6, Val2)
          setupvalue(AC.attack, 4, Val3)
          setupvalue(AC.attack, 7, Val4)
          
          local Blade = AC.currentWeaponModel
          if typeof(Blade) == "Instance" then
            AC.animator.anims.basic[1]:Play()
            RigControllerEvent:FireServer("weaponChange", Blade.Name)
            Validator:FireServer(math.floor(Val5 / 1099511627776 * 16777215), Val4)
            RigControllerEvent:FireServer("hit", BladeHits, 1, "")
          end
        end
      end
    end
    
    function _FastAttack.CanClick()
      if not _env.AutoClick or not _env.ClickRequest then return end
      if Module:IsAlive(Player.Character) and Player.Character:FindFirstChildOfClass("Tool") then
        for _,Enemy in ipairs(Enemies:GetChildren()) do
          local PP = Enemy.PrimaryPart
          if Module:IsAlive(Enemy) and PP and Player:DistanceFromCharacter(PP.Position) < 60 then
            return Module:FirePlayerClick()
          end
        end
      end
    end
    
    local db
    function Module:FirePlayerClick()
      if not db or (tick() - db) >= m_clamp(_env.AutoClickDelay, 0.125, 1) then
        _spawn(_FastAttack.BladeHitAttack)db = tick()
      end
    end
  
    RunService.Heartbeat:Connect(_FastAttack.CanClick)
    
    return _FastAttack
  end)()
  Module.FarmCheck = (function()
    local _Farm = {}
    _Farm.PR_Pos = Vector3_new(-5556, 314, -2988)
    local bl_Enemies = {"rip_indra True Form", "Blank Buddy"}
    
    _spawn(function()
      local lTick
      local function IsPirateRaidEnemy(Enemy)
        local PP = Enemy.PrimaryPart
        if Module:IsAlive(Enemy) and (PP.Position - _Farm.PR_Pos).Magnitude < 700 and not _find(bl_Enemies, Enemy.Name) then
          _Farm.PirateRaid = lTick and (tick() - lTick) <= 10
        end
      end
      
      Enemies.ChildAdded:Connect(IsPirateRaidEnemy)
      ReplicatedStorage.ChildAdded:Connect(IsPirateRaidEnemy)
    end)
    
    function Module:VerifyFactory(Method)
      return Method and self:VerifyEnemy("Core")
    end
    
    function Module:VerifyPirateRaid(Method)
      return Method and _Farm.PirateRaid
    end
    
    function Module:GetPirateRaidEnemy()
      for _,Enemy in pairs(Enemies:GetChildren()) do
        if self:IsAlive(Enemy) and not _find(bl_Enemies, Enemy.Name) then
          local PP = Enemy.PrimaryPart
          if PP and (PP.Position - _Farm.PR_Pos).Magnitude < 700 then
            return npc
          end
        end
      end
    end
    
    return _Farm
  end)()
  Module.Inventory = (function()
    local _inv = {}
    local _Inventory = WaitChilds(Player, "PlayerGui", "Main", "UIController", "Inventory")
    
    function _inv:VerifyItem(IName, Type)
      Type = Type or "Sword"
      for _,Item in ipairs(require(_Inventory).Items) do
        local details = Item.details
        if details.Type == Type and details.Name == IName then
          return details
        end
      end
    end
    
    function _inv:ItemMastery(...)
      local Item = self:VerifyItem(...)
      if Item then return Item.Mastery end
      return 0
    end
    
    function _inv:GetMaterial(MName)
      local Item = self:VerifyItem(MName, "Material")
      if Item then return Item.Count end
      return 0
    end
    
    function _inv:GetUnlockedItems()
      local AllItems = {}
      for _,item in ipairs(require(_Inventory).Items) do
        local details = item.details
        if details and details.Name then
          AllItems[details.Name] = details
        end
      end
      return AllItems
    end
    
    return _inv
  end)()
  Module.TweenBlock = (function()
    if _env.BlockTween then
      _env.BlockTween:Destroy()
    end
    
    local Block = Instance.new("Part")
    Block.Size = Vector3_new(1, 1, 1)
    Block.Name = tostring(Player.UserId) .. "_Block"
    Block.Anchored = true
    Block.CanCollide = false
    Block.CanTouch = false
    Block.Transparency = 1
    
    local Velocity = Instance.new("BodyVelocity")
    Velocity.Name = "BV_Player"
    Velocity.MaxForce = Vector3_new(m_huge, m_huge, m_huge)
    Velocity.Velocity = Vector3_new()
    
    local _Noclip;_Noclip = RunService.Stepped:Connect(function()
      local Char = Player.Character
      if OnFarm and Module:IsAlive(Char) then
        for _,Part in pairs(Char:GetChildren()) do
          if Part:IsA("BasePart") then Part.CanCollide = false end
        end
      end
    end)
    local _Connection;_Connection = RunService.Heartbeat:Connect(function()
      if not Block or not Velocity then
        return _Connection:Disconnect(), _Noclip:Disconnect()
      end
      
      local Char = Player.Character
      if OnFarm and Module:IsAlive(Char) then
        local plrPP = Char.PrimaryPart
        if plrPP then
          if (plrPP.Position - Block.Position).Magnitude < 150 then
            plrPP.CFrame = Block.CFrame
          else
            Block.CFrame = plrPP.CFrame
          end
        end
        if Velocity.Parent ~= plrPP then
          Velocity.Parent = plrPP
        end
      elseif Velocity.Parent then
        Velocity.Parent = nil
      end
    end)
    
    _env.BlockTween = Block
    return Block
  end)()
end

return Module
