local Settings = ...

local _ENV = (getgenv or getrenv or getfenv)()

local function WaitChilds(path, ...)
  local last = path
  for _,child in {...} do
    last = last:FindFirstChild(child) or last:WaitForChild(child)
  end
  return last
end

local VirtualInputManager = game:GetService("VirtualInputManager")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Validator = Remotes:WaitForChild("Validator")
local CommF = Remotes:WaitForChild("CommF_")
local CommE = Remotes:WaitForChild("CommE")

local ChestModels = workspace:WaitForChild("ChestModels")
local WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Characters = workspace:WaitForChild("Characters")
local Enemies = workspace:WaitForChild("Enemies")
local Map = workspace:WaitForChild("Map")

local EnemySpawns = WorldOrigin:WaitForChild("EnemySpawns")
local Locations = WorldOrigin:WaitForChild("Locations")

local RenderStepped = RunService.RenderStepped
local Heartbeat = RunService.Heartbeat
local Stepped = RunService.Stepped
local Player = Players.LocalPlayer

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Net = Modules:WaitForChild("Net")

local sethiddenproperty = sethiddenproperty or (function(...) return ... end)
local setupvalue = setupvalue or (debug and debug.setupvalue)
local getupvalue = getupvalue or (debug and debug.getupvalue)

local function GetEnemyName(string)
  return (string:find("Lv. ") and string:gsub(" %pLv. %d+%p", "") or string):gsub(" %pBoss%p", "")
end

local Module = {} do
  local CachedBaseParts = {}
  local ChachedToolTip = {}
  local CachedEnemies = {}
  local CachedBring = {}
  local CachedChars = {}
  local CachedTools = {}
  local Items = {}
  
  local placeId = game.PlaceId
  local HitBoxSize = Vector3.new(50, 50, 50)
  local SeaList = {"TravelMain", "TravelDressrosa", "TravelZou"}
  
  Module.Sea = (placeId == 2753915549 and 1) or (placeId == 4442272183 and 2) or (placeId == 7449423635 and 3) or 0
  
  Module.AttackCooldown = tick()
  Module.MaxLevel = 2600
  Module.Progress = {}
  Module.SpawnedFruits = {}
  Module.EnemyPosition = {}
  Module.BossesName = {}
  Module.AllMobs = { __RaidBoss = {}, __Bones = {}, __Elite = {}, __CakePrince = {} }
  
  Module.FruitsId = {
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
  Module.Bosses = {
    -- Bosses Sea 1
    ["Saber Expert"] = {
      NoQuest = true,
      Position = CFrame.new(-1461, 30, -51)
    },
    ["The Saw"] = {
      RaidBoss = true,
      Position = CFrame.new(-690, 15, 1583)
    },
    ["Greybeard"] = {
      RaidBoss = true,
      Position = CFrame.new(-4807, 21, 4360)
    },
    ["The Gorilla King"] = {
      IsBoss = true,
      Level = 20,
      Position = CFrame.new(-1128, 6, -451),
      Quest = {"JungleQuest", CFrame.new(-1598, 37, 153)}
    },
    ["Bobby"] = {
      IsBoss = true,
      Level = 55,
      Position = CFrame.new(-1131, 14, 4080),
      Quest = {"BuggyQuest1", CFrame.new(-1140, 4, 3829)}
    },
    ["Yeti"] = {
      IsBoss = true,
      Level = 105,
      Position = CFrame.new(1185, 106, -1518),
      Quest = {"SnowQuest", CFrame.new(1385, 87, -1298)}
    },
    ["Vice Admiral"] = {
      IsBoss = true,
      Level = 130,
      Position = CFrame.new(-4807, 21, 4360),
      Quest = {"MarineQuest2", CFrame.new(-5035, 29, 4326), 2}
    },
    ["Swan"] = {
      IsBoss = true,
      Level = 240,
      Position = CFrame.new(5230, 4, 749),
      Quest = {"ImpelQuest", CFrame.new(5191, 4, 692)}
    },
    ["Chief Warden"] = {
      IsBoss = true,
      Level = 230,
      Position = CFrame.new(5230, 4, 749),
      Quest = {"ImpelQuest", CFrame.new(5191, 4, 692), 2}
    },
    ["Warden"] = {
      IsBoss = true,
      Level = 220,
      Position = CFrame.new(5230, 4, 749),
      Quest = {"ImpelQuest", CFrame.new(5191, 4, 692), 1}
    },
    ["Magma Admiral"] = {
      IsBoss = true,
      Level = 350,
      Position = CFrame.new(-5694, 18, 8735),
      Quest = {"MagmaQuest", CFrame.new(-5319, 12, 8515)}
    },
    ["Fishman Lord"] = {
      IsBoss = true,
      Level = 425,
      Position = CFrame.new(61350, 31, 1095),
      Quest = {"FishmanQuest", CFrame.new(61122, 18, 1567)}
    },
    ["Wysper"] = {
      IsBoss = true,
      Level = 500,
      Position = CFrame.new(-7927, 5551, -637),
      Quest = {"SkyExp1Quest", CFrame.new(-7861, 5545, -381)}
    },
    ["Thunder God"] = {
      IsBoss = true,
      Level = 575,
      Position = CFrame.new(-7751, 5607, -2315),
      Quest = {"SkyExp2Quest", CFrame.new(-7903, 5636, -1412)}
    },
    ["Cyborg"] = {
      IsBoss = true,
      Level = 675,
      Position = CFrame.new(6138, 10, 3939),
      Quest = {"FountainQuest", CFrame.new(5258, 39, 4052)}
    },
    
    -- Bosses Sea 2
    ["Don Swan"] = {
      RaidBoss = true,
      Position = CFrame.new(2289, 15, 808)
    },
    ["Cursed Captain"] = {
      RaidBoss = true,
      Position = CFrame.new(912, 186, 33591)
    },
    ["Darkbeard"] = {
      RaidBoss = true,
      Position = CFrame.new(3695, 13, -3599)
    },
    ["Diamond"] = {
      IsBoss = true,
      Level = 750,
      Position = CFrame.new(-1569, 199, -31),
      Quest = {"Area1Quest", CFrame.new(-427, 73, 1835)}
    },
    ["Jeremy"] = {
      IsBoss = true,
      Level = 850,
      Position = CFrame.new(2316, 449, 787),
      Quest = {"Area2Quest", CFrame.new(635, 73, 919)}
    },
    ["Fajita"] = {
      IsBoss = true,
      Level = 925,
      Position = CFrame.new(-2086, 73, -4208),
      Quest = {"MarineQuest3", CFrame.new(-2441, 73, -3219)}
    },
    ["Smoke Admiral"] = {
      IsBoss = true,
      Level = 1150,
      Position = CFrame.new(-5078, 24, -5352),
      Quest = {"IceSideQuest", CFrame.new(-6061, 16, -4904)}
    },
    ["Awakened Ice Admiral"] = {
      IsBoss = true,
      Level = 1400,
      Position = CFrame.new(6473, 297, -6944),
      Quest = {"FrostQuest", CFrame.new(5668, 28, -6484)}
    },
    ["Tide Keeper"] = {
      IsBoss = true,
      Level = 1475,
      Position = CFrame.new(-3711, 77, -11469),
      Quest = {"ForgottenQuest", CFrame.new(-3056, 240, -10145)}
    },
    
    -- Bosses Sea 3
    ["Cake Prince"] = {
      RaidBoss = true,
      Position = CFrame.new(-2103, 70, -12165)
    },
    ["Dough King"] = {
      RaidBoss = true,
      Position = CFrame.new(-2103, 70, -12165)
    },
    ["rip_indra True Form"] = {
      RaidBoss = true,
      Position = CFrame.new(-5333, 424, -2673)
    },
    ["Stone"] = {
      IsBoss = true,
      Level = 1550,
      Position = CFrame.new(-1049, 40, 6791),
      Quest = {"PiratePortQuest", CFrame.new(-291, 44, 5580)}
    },
    ["Island Empress"] = {
      IsBoss = true,
      Level = 1675,
      Position = CFrame.new(5730, 602, 199),
      Quest = {"AmazonQuest2", CFrame.new(5448, 602, 748)}
    },
    ["Kilo Admiral"] = {
      IsBoss = true,
      Level = 1750,
      Position = CFrame.new(2904, 509, -7349),
      Quest = {"MarineTreeIsland", CFrame.new(2485, 74, -6788)}
    },
    ["Captain Elephant"] = {
      IsBoss = true,
      Level = 1875,
      Position = CFrame.new(-13393, 319, -8423),
      Quest = {"DeepForestIsland", CFrame.new(-13233, 332, -7626)}
    },
    ["Beautiful Pirate"] = {
      IsBoss = true,
      Level = 1950,
      Position = CFrame.new(5241, 23, 129),
      Quest = {"DeepForestIsland2", CFrame.new(-12682, 391, -9901)}
    },
    ["Cake Queen"] = {
      IsBoss = true,
      Level = 2175,
      Position = CFrame.new(-710, 382, -11150),
      Quest = {"IceCreamIslandQuest", CFrame.new(-818, 66, -10964)}
    },
    ["Longma"] = {
      NoQuest = true,
      Position = CFrame.new(-10218, 333, -9444)
    }
  }
  Module.Shop = {
    {"Frags", {{"Race Rerol", {"BlackbeardReward", "Reroll", "2"}}, {"Reset Stats", {"BlackbeardReward", "Refund", "2"}}}},
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
      -- {"Buy Divine Art", {"BuyDivineArt"}}
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
      {"Buy Tomoe Ring", {"BuyItem", "Tomoe Ring"}}
    }},
    {"Race", {{"Ghoul Race", {"Ectoplasm", "Change", 4}}, {"Cyborg Race", {"CyborgTrainer", "Buy"}}}}
  }
  
  function EnableBuso()
    local Char = Player.Character
    if Settings.AutoBuso and Module.IsAlive(Char) and not Char:FindFirstChild("HasBuso") then
      Module.FireRemote("Buso")
    end
  end
  
  function VerifyTool(Name: string): boolean
    local cached = CachedTools[Name]
    if cached and cached.Parent then
      return true
    end
    
    local Char = Player.Character
    local Bag = Player.Backpack
    
    if Char then
      local Tool = Char:FindFirstChild(Name) or Bag:FindFirstChild(Name)
      
      if Tool then
        CachedTools[Name] = Tool
        return true
      end
    end
    
    return false
  end
  
  function VerifyToolTip(Type: string): Instance?
    local cached = ChachedToolTip[Type]
    if cached and cached.Parent then
      return cached
    end
    
    for _,tool in Player.Backpack:GetChildren() do
      if tool:IsA("Tool") and tool.ToolTip == Type then
        ChachedToolTip[Type] = tool
        return tool
      end
    end
    
    if not Module.IsAlive(Player.Character) then
      return nil
    end
    
    for _,tool in Player.Character:GetChildren() do
      if tool:IsA("Tool") and tool.ToolTip == Type then
        ChachedToolTip[Type] = tool
        return tool
      end
    end
    
    return nil
  end
  
  function noSit()
    local Char = Player.Character
    if Module.IsAlive(Char) and Char.Humanoid.Sit then
      Char.Humanoid.Sit = false
    end
  end
  
  local function ToDictionary(tab: table): table
    for _, String in ipairs(tab) do
      tab[String] = true
      table.remove(tab, _)
    end
    return tab
  end
  
  function Module.TravelTo(Sea: number?): (nil)
    if SeaList[Sea] then
      Module.FireRemote(SeaList[Sea])
    end
  end
  
  function Module.newCachedEnemy(Name, Enemy)
    CachedEnemies[Name] = Enemy
  end
  
  function Module.Rejoin(): (nil)
    task.spawn(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, game.JobId, Player)
  end
  
  function Module.IsAlive(Char: Model?): boolean
    if not Char then
      return nil
    end
    
    if CachedChars[Char] then
      return CachedChars[Char].Health > 0
    end
    
    local Hum = Char:FindFirstChildOfClass("Humanoid")
    CachedChars[Char] = Hum
    return Hum and Hum.Health > 0
  end
  
  function Module.FireRemote(...): any
    return CommF:InvokeServer(...)
  end
  
  function Module.IsFruit(Part: BasePart): Instance?
    return (Part.Name == "Fruit " or Part:GetAttribute("OriginalName")) and Part:FindFirstChild("Handle")
  end
  
  function Module.IsBoss(Name: string): boolean
    return Module.Bosses[Name] and true
  end
  
  function Module.UseSkills(Target: BasePart, Skills: table?): (nil)
    if Player:DistanceFromCharacter(Target.Position) >= 120 then
      return nil
    end
    
    Module.Hooking:SetTarget(Target)
    
    for Skill, Enabled in Skills do
      if Enabled then
        VirtualInputManager:SendKeyEvent(true, Skill, false, game)
        VirtualInputManager:SendKeyEvent(false, Skill, false, game)
      end
    end
  end
  
  function Module.KillAura(Distance: number?): (nil)
    Distance = Distance or 1500
    
    for _, Enemy in ipairs(Enemies:GetChildren()) do
      local PrimaryPart = Enemy.PrimaryPart
      
      if Module.IsAlive(Enemy) and PrimaryPart and Player:DistanceFromCharacter(PrimaryPart.Position) < Distance then
        PrimaryPart.CanCollide = false
        PrimaryPart.Size = Vector3.new(60, 60, 60)
        Enemy.Humanoid:ChangeState(15)
        Enemy.Humanoid.Health = 0
      end
    end
    
    pcall(sethiddenproperty, Player, "SimulationRadius", math.huge)
  end
  
  function Module:ServerHop(Region: string?, MaxPlayers: number?): (nil)
    MaxPlayers = MaxPlayers or self.SH_MaxPlrs or 8
    -- Region = Region or self.SH_Region or "Singapore"
    
    local ServerBrowser = ReplicatedStorage.__ServerBrowser
    
    for i = 1, 100 do
      local Servers = ServerBrowser:InvokeServer(i)
      for id,info in pairs(Servers) do
        if id ~= game.JobId and info["Count"] <= MaxPlayers then
          task.spawn(ServerBrowser.InvokeServer, ServerBrowser, "teleport", id)
        end
      end
    end
  end
  
  function Module:GetEnemy(Name: string): Instance?
    return self.EnemySpawned[Name]
  end
  
  function Module:GetClosestEnemy(Name: string): Instance?
    local Cached = CachedEnemies[Name]
    local Mobs = self.AllMobs[Name]
    
    if self.IsAlive(Cached) or (not Mobs) then
      return Cached
    end
    
    local Position = (Player.Character or Player.CharacterAdded:Wait()).PrimaryPart.Position
    local Distance, Nearest = math.huge
    
    for _, Enemy in Mobs do
      if self.IsAlive(Enemy) and Enemy.PrimaryPart then
        local Magnitude = (Enemy.PrimaryPart.Position - Position).Magnitude
        if Magnitude < Distance then
          Distance, Nearest = Magnitude, Enemy
        end
      end
    end
    
    if Nearest then
      self.newCachedEnemy(Name, Nearest)
      return Nearest
    end
  end
  
  function Module:GetEnemyByList(List: table): Instance?
    for _, Name in List do
      local Cached = CachedEnemies[Name]
      
      if self.IsAlive(Cached) then
        return Cached
      end
      
      local Mobs = self.AllMobs[Name]
      
      if Mobs then
        for _, Enemy in Mobs do
          if self.IsAlive(Enemy) then
            self.newCachedEnemy(Name, Enemy)
            return Enemy
          end
        end
      end
    end
  end
  
  function Module:BringEnemies(ToEnemy: Instance): (nil)
    if not self.IsAlive(ToEnemy) or not ToEnemy.PrimaryPart then
      return nil
    end
    
    pcall(sethiddenproperty, Player, "SimulationRadius", math.huge)
    
    if Settings.BringMobs then
      local Target = CachedBring[ToEnemy] or ToEnemy.PrimaryPart.CFrame
      
      if not CachedBring[ToEnemy] then
        CachedBring[ToEnemy] = Target
      end
      
      for _, Enemy in self.AllMobs[ToEnemy.Name] do
        local PrimaryPart = Enemy.PrimaryPart
        if self.IsAlive(Enemy) and PrimaryPart then
          if (PrimaryPart.Position - Target.Position).Magnitude < Settings.BringDistance then
            PrimaryPart.CFrame = Target
            PrimaryPart.CanCollide = false
            PrimaryPart.Size = HitBoxSize
            Enemy.Humanoid.WalkSpeed = 0
            Enemy.Humanoid:ChangeState(14)
          end
        end
      end
    else
      if not CachedBring[ToEnemy] then
        CachedBring[ToEnemy] = ToEnemy:GetPivot()
      end
      
      ToEnemy:PivotTo(CachedBring[ToEnemy])
    end
  end
  
  function Module:GetRaidIsland(): Instance?
    if self.RaidIsland then
      return self.RaidIsland
    end
    
    local list = {}
    
    for _,Island in ipairs(Locations:GetChildren()) do
      if Island:IsA("BasePart") and Player:DistanceFromCharacter(Island.Position) < 3000 then
        list[Island.Name] = Island
      end
    end
    
    local Island = list["Island 5"] or list["Island 4"] or list["Island 3"] or list["Island 2"] or list["Island 1"]
    
    self.RaidIsland = Island
    return Island
  end
  
  function Module:GetProgress(Tag, ...)
    local Progress = self.Progress
    local entry = Progress[Tag]
    
    if entry and (tick() - entry.debounce) < 1.6 then
      return entry.result
    end
    
    local result = self.FireRemote(...)
    
    if entry then
      entry.result = result
      entry.debounce = tick()
    else
      Progress[Tag] = {
        debounce = tick(),
        result = result
      }
    end
    
    return result
  end
  
  Module.EnemySpawned = setmetatable({}, {
    __index = function(self, index)
      return Module:GetClosestEnemy(index)
    end,
    __call = function(self, index)
      if type(index) == "table" then
        return Module:GetEnemyByList(index)
      end
      
      local Cached = CachedEnemies[index]
      
      if Module.IsAlive(Cached) then
        return Cached
      end
      
      return self[index]
    end
  })
  
  Module.EnemyLocations = setmetatable({ void = {} }, {
    __index = function(self, index)
      if typeof(index) == "Instance" then
        return rawget(self, index.Name) or self.void
      end
      return rawget(self, index) or self.void
    end,
    __call = function(self, Location)
      if Location and Location:IsA("BasePart") and Location:GetAttribute("DisplayName") then
        local Name = GetEnemyName(Location.Name)
        
        if not rawget(self, Name) then self[Name] = {} end
        table.insert(self[Name], (Location.CFrame + Vector3.new(0, 30, 0)))
      end
    end
  })
  
  Module.IsSpawned = setmetatable({}, {
    __call = function(self, Enemy)
      local Cached = rawget(self, Enemy)
      
      if Cached then
        return Cached:GetAttribute("Active") or Module:GetEnemyByTag(Enemy)
      end
      
      if Module:GetEnemyByTag(Enemy) then
        return true
      end
      
      for _, Spawn in ipairs(EnemySpawns:GetChildren()) do
        if GetEnemyName(Spawn.Name) == Enemy and Spawn:GetAttribute("Active") then
          rawset(self, Enemy, Spawn)
          return true
        end
      end
    end
  })
  
  Module.FruitsName = setmetatable({}, {
    __index = function(self, Fruit)
      local Ids = Module.FruitsId
      local Name = Fruit.Name
      
      if Name ~= "Fruit " then
        rawset(self, Fruit, Name)
        return Name
      end
      
      local FruitHandle = WaitChilds(Fruit, "Fruit", "Fruit")
      
      if FruitHandle and FruitHandle:IsA("MeshPart") then
        local RealName = Ids[FruitHandle.MeshId]
        
        if RealName and type(RealName) == "string" then
          rawset(self, Fruit, "Fruit [ " .. RealName .. " ]")
          return rawget(self, Fruit)
        end
      end
      
      rawset(self, Fruit, "Fruit [ ??? ]")
      return "Fruit [ ??? ]"
    end
  })
  
  Module.MoonId = setmetatable({}, {
    __index = function(self, index)
      return (Lighting.Sky.MoonTextureId == "http://www.roblox.com/asset/?id=" .. index)
    end
  })
  
  Module.EquipTool = setmetatable({}, {
    __call = function(self, Name, byTip)
      local Char = Player.Character
      if Module.IsAlive(Char) then
        local Equipped = self.Equipped
        
        if Equipped and Equipped.Parent and Equipped[byTip and "ToolTip" or "Name"] == Name then
          if Equipped.Parent ~= Char then
            Char:WaitForChild("Humanoid"):EquipTool(Equipped)
          end
          return nil
        end
        
        if Name and not byTip then
          local Tool = Player.Backpack:FindFirstChild(Name)
          if Tool then
            self.Equipped = Tool
            Char:WaitForChild("Humanoid"):EquipTool(Tool)
          end
          return nil
        end
        
        local ToolTip = (byTip and Name) or Settings.FarmTool
        for _,Tool in Player.Backpack:GetChildren() do
          if Tool:IsA("Tool") and Tool.ToolTip == ToolTip then
            self.Equipped = Tool
            Char:WaitForChild("Humanoid"):EquipTool(Tool)
            break
          end
        end
      end
    end
  })
  
  Module.Chests = setmetatable({}, {
    __call = function(self, Tier)
      if self.Chest and not self.Chest:GetAttribute("IsDisabled")  then
        return self.Chest
      end
      
      if not Module.IsAlive(Player.Character) then
        return nil
      end
      
      local Chests = CollectionService:GetTagged("_ChestTagged")
      local Position = Player.Character.PrimaryPart.Position
      
      local Distance, Nearest = math.huge
      
      for _, Chest in ipairs(Chests) do
        local Magnitude = (Chest:GetPivot().Position - Position).Magnitude
        if not Chest:GetAttribute("IsDisabled") and Magnitude < Distance then
          Distance, Nearest = Magnitude, Chest
        end
      end
      
      self.Chest = Nearest
      return Nearest
    end
  })
  
  Module.PirateRaid = 0 do
    Module.PirateRaidEnemies = {}
    
    local Spawn = Vector3.new(-5556, 314, -2988)
    local BlackList = ToDictionary({"rip_indra True Form", "Blank Buddy"})
    
    local IsPirateRaidEnemy = function(Enemy)
      local PrimaryPart = Enemy.PrimaryPart
      
      if Module.IsAlive(Enemy) and not BlackList[Enemy.Name] then
        if PrimaryPart and (PrimaryPart.Position - Spawn).Magnitude < 700 then
          table.insert(Module.PirateRaidEnemies, Enemy)
          Module.PirateRaid = tick()
        end
      end
    end
    
    CollectionService:GetInstanceAddedSignal("BasicMob"):Connect(IsPirateRaidEnemy)
    for _, Mob in CollectionService:GetTagged("BasicMob") do IsPirateRaidEnemy(Mob) end
  end
  
  task.spawn(function()
    local AllMobs = Module.AllMobs
    
    local Elites = ToDictionary({"Deandre", "Diablo", "Urban"})
    local Bones = ToDictionary({"Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy"})
    local CakePrince = ToDictionary({"Head Baker", "Baking Staff", "Cake Guard", "Cookie Crafter"})
    
    function Module:GetEnemyByTag(Tag)
      if not Tag or not AllMobs[Tag] then
        return nil
      end
      
      for _, Enemy in AllMobs[Tag] do
        if self.IsAlive(Enemy) then
          return Enemy
        end
      end
    end
    
    local function newEnemy(Enemy)
      local EnemyName = Enemy.Name
      
      if Enemy:GetAttribute("RaidBoss") then
        table.insert(AllMobs.__RaidBoss, Enemy)
      elseif Elites[EnemyName] then
        table.insert(AllMobs.__Elite, Enemy)
      elseif Bones[EnemyName] then
        table.insert(AllMobs.__Bones, Enemy)
      elseif CakePrince[EnemyName] then
        table.insert(AllMobs.__CakePrince, Enemy)
      end
      
      if not AllMobs[EnemyName] then
        AllMobs[EnemyName] = {}
      end
      
      table.insert(AllMobs[EnemyName], Enemy)
    end
    
    for _, Enemy in CollectionService:GetTagged("BasicMob") do
      newEnemy(Enemy)
    end
    
    CollectionService:GetInstanceAddedSignal("BasicMob"):Connect(newEnemy)
  end)
  
  task.spawn(function()
    local BossesName = Module.BossesName
    local Fruits = Module.SpawnedFruits
    
    workspace.ChildAdded:Connect(function(Part)
      if Module.IsFruit(Part) then
        table.insert(Fruits, Part)
        Part:GetPropertyChangedSignal("Parent"):Once(function()
          table.remove(Fruits, table.find(Fruits, Part))
        end)
      end
    end)
    
    for Name, _ in Module.Bosses do
      table.insert(BossesName, Name)
    end
    
    for _, Part in workspace:GetChildren() do
      if Module.IsFruit(Part) then
        table.insert(Fruits, Part)
        Part:GetPropertyChangedSignal("Parent"):Once(function()
          table.remove(Fruits, table.find(Fruits, Part))
        end)
      end
    end
  end)
  
  task.spawn(function()
    local EnemyLocations = Module.EnemyLocations
    
    for i,v in EnemySpawns:GetChildren() do EnemyLocations(v) end
    
    Locations.ChildAdded:Connect(function(part)
      if string.find(part.Name, "Island") then
        Module.RaidIsland = nil
      end
    end)
  end)
  
  task.spawn(function()
    local Inventory = WaitChilds(Player, "PlayerGui", "Main", "UIController", "Inventory")
    local ItemList = getupvalue(require(Inventory).UpdateSort, 2)
    
    function Module:GetMaterial(index: string?): number
      local Material = self.Inventory[index]
      return (Material and Material.details.Count) or 0
    end
    
    function Module:ItemMastery(index: string?): number
      local Item = self.Inventory[index]
      return (Item and Item.details.Mastery) or 0
    end
    
    function Module:UpdateItem(Item: table): (nil)
      local Details = Item.details
      
      if Details and Details.Name then
        local Name = Details.Name
        
        self.Inventory[Name] = Item
        
        if not self.Unlocked[Name] then
          self.Unlocked[Name] = true
        end
        
        if Details.Mastery then
          self.ItemsMastery[Name] = Details.Mastery
        end
      end
    end
    
    local function OnClientEvent(Method, ...)
      if Method == "ItemChanged" then
        Module:UpdateItem(...)
      end
    end
    
    Module.ItemsMastery = {}
    Module.Inventory = {}
    Module.Unlocked = {}
    
    for _, Item in ipairs(ItemList) do
      Module:UpdateItem(Item)
    end
    
    CommE.OnClientEvent:Connect(OnClientEvent)
  end)
  
  task.spawn(function()
    local DeathM = require(WaitChilds(ReplicatedStorage, "Effect", "Container", "Death"))
    local CameraShaker = require(WaitChilds(ReplicatedStorage, "Util", "CameraShaker"))
    
    CameraShaker:Stop()
    if hookfunction then
      hookfunction(DeathM, function(...) return ... end)
    end
  end)
  
  Module.Hooking = (function()
    local module = {}
    
    local Enabled = _ENV.rz_EnabledOptions;
    local IsAlive = Module.IsAlive;
    local NextTarget = nil;
    
    local GetPlayers = Players.GetPlayers
    local GetChildren = Enemies.GetChildren
    local Skills = ToDictionary({"Z", "X", "C", "V", "F"})
    
    local function CheckTeam(player)
      return player.Team and (player.Team.Name == "Pirates" or player.Team ~= Player.Team)
    end
    
    local function GetEnemyTarget()
      local Distance, Nearest = 750
      
      local Position = Player.Character.PrimaryPart.Position
      
      for _, player in GetPlayers(Players) do
        local Character = player.Character
        
        if player ~= Player and IsAlive(Character) and CheckTeam(player) and Character.Parent == Characters then
          local PrimaryPart = Character.PrimaryPart
          local Magnitude = (Position - PrimaryPart.Position).Magnitude
          
          if Magnitude < Distance then
            Distance, Nearest = Magnitude, PrimaryPart
          end
        end
      end
      
      return Nearest
    end
    
    local function GetNextTarget(Mode)
      if Enabled.Mastery or Enabled.Sea or Enabled.WoodPlanks then
        return NextTarget
      end
      
      if (Mode and _ENV[Mode]) then
        return GetEnemyTarget()
      end
    end
    
   --[[local function HookEvent(Hook, Method, self, ...)
      local Name = self.Name
      
      if Name == "RE/ShootGunEvent" then
        local Position, Enemies = ...
        
        if typeof(Position) == "Vector3" and type(Enemies) == "table" then
          local Target = GetNextTarget("AimBot_Gun")
          
          if Target and Target.Parent:FindFirstChild("Head") then
            table.insert(Enemies, Target.Parent.Head)
            Position = Target.Position
          end
          
          return Hook(self, Position, Enemies)
        end
        
        return Hook(self, ...)
      end
      
      if Name == "RemoteEvent" and self:IsDescendantOf(Player.Character) then
        local Position, Enemy = ...
        
        if typeof(Position) == "Vector3" then
          local Target = GetNextTarget("AimBot_Skills")
          
          if Target then
            return Hook(self, Target.Position)
          end
        end
        
        return Hook(self, ...)
      end
      
      if Method == "invokeserver" then
        local Tag, Position = ...
        
        if typeof(Position) == "Vector3" and (Tag == "TAP" or not Position and Skills[Tag]) then
          local Target = GetNextTarget("AimBot_Tap")
          
          if Tag == "TAP" and Target then
            return Hook(self, Tag, Target.Position)
          elseif Target then
            return Hook(self, Tag, Target.Position, Target)
          end
        end
        
        return Hook(self, ...)
      end
      
      return Hook(self, ...)
    end]]
    
    function module:SpeedBypass()
      if _ENV._Enabled_Speed_Bypass then
        return nil
      end
      
      _ENV._Enabled_Speed_Bypass = true
      
      local oldHook;
      oldHook = hookmetamethod(Player, "__newindex", function(self, index, value)
        if self.Name == "Humanoid" and index == "WalkSpeed" then
          return oldHook(self, index, _ENV.WalkSpeedBypass or value)
        end
        return oldHook(self, index, value)
      end)
    end
    
    function module:SetTarget(RootPart)
      NextTarget = RootPart
    end
    
    if not _ENV.loaded_aimbot then
      _ENV.loaded_aimbot = true
      
      --[[local old;old = hookmetamethod(game, "__namecall", newcclosure(function(...)
        local Method = getnamecallmethod():lower()
        
        if Method == "fireserver" or Method == "invokeserver" then
          return HookEvent(old, Method, ...)
        end
        return old(...)
      end))]]
    end
    
    return module
  end)()
  
  Module.FastAttack = (function()
    if _ENV.rz_FastAttack then
      return _ENV.rz_FastAttack
    end
    
    local module = {
      NextAttack = 0,
      Distance = 55,
      attackMobs = true,
      attackPlayers = true
    }
    
    local RegisterAttack = Net:WaitForChild("RE/RegisterAttack")
    local RegisterHit = Net:WaitForChild("RE/RegisterHit")
    
    function module:AttackEnemy(EnemyHead)
      if EnemyHead and Player:DistanceFromCharacter(EnemyHead.Position) < self.Distance then
        if not self.FirstAttack then
          RegisterAttack:FireServer(Settings.ClickDelay or 0.125)
          self.FirstAttack = true
        end
        RegisterHit:FireServer(EnemyHead, {})
      end
    end
    
    function module:AttackNearest()
      for _, Enemy in Enemies:GetChildren() do
        self:AttackEnemy(Enemy:FindFirstChild("UpperTorso"))
      end
      for _, Enemy in Characters:GetChildren() do
        if Enemy ~= Player.Character then
          self:AttackEnemy(Enemy:FindFirstChild("UpperTorso"))
        end
      end
      
      if not self.FirstAttack then
        task.wait(0.5)
      end
    end
    
    function module:BladeHits()
      self:AttackNearest()
      self.FirstAttack = false
    end
    
    task.spawn(function()
      while task.wait(Settings.ClickDelay or 0.125) do
        if (tick() - Module.AttackCooldown) < 1 then continue end
        if not Settings.AutoClick then continue end
        if not Module.IsAlive(Player.Character) then continue end
        if not Player.Character:FindFirstChildOfClass("Tool") then continue end
        
        module:BladeHits()
      end
    end)
    
    _ENV.rz_FastAttack = module
    return module
  end)()
  
  Module.Tween = (function()
    if _ENV.TweenVelocity then
      return _ENV.TweenVelocity
    end
    
    local IsAlive = Module.IsAlive
    local Velocity = Instance.new("BodyVelocity", workspace)
    Velocity.Name = "hidden_user_folder_ :)"
    Velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    Velocity.Velocity = Vector3.zero
    
    _ENV.TweenVelocity = Velocity
    
    Stepped:Connect(function()
      local Character = Player.Character
      
      if _ENV.OnFarm and Velocity.Parent ~= nil and Character then
        for _, Part in Character:GetDescendants() do
          if Part:IsA("BasePart") and Part.CanCollide then
            Part.CanCollide = false
          end
        end
      end
    end)
    
    Heartbeat:Connect(function()
      local Character = Player.Character
      local isAlive = IsAlive(Character)
      
      if isAlive and Velocity ~= Vector3.zero and (not Character.Humanoid.SeatPart or not _ENV.OnFarm) then
        Velocity.Velocity = Vector3.zero
      end
      
      if _ENV.OnFarm and isAlive then
        if Velocity.Parent == nil then
          Velocity.Parent = Character.PrimaryPart
        end
      elseif Velocity.Parent ~= nil then
        Velocity.Parent = nil
      end
    end)
    
    return Velocity
  end)()
  
  Module.RaidList = (function()
    local Raids = require(ReplicatedStorage:WaitForChild("Raids"))
    local list = {}
    
    for _,chip in ipairs(Raids.advancedRaids) do table.insert(list, chip) end
    for _,chip in ipairs(Raids.raids) do table.insert(list, chip) end
    
    return list
  end)()
end
