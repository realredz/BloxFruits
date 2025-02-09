local CustomFunctions = function(self)
  local ScriptFunctions = self.ScriptFunctions
  local Functions = self.Functions
  local Managers = self.Managers
  local Module = self.Module
  
  local IslandManager = Managers.IslandManager
  local QuestManager = Managers.QuestManager
  local FarmManager = Managers.FarmManager
  local RaidManager = Managers.RaidManager
  local ItemsQuests = Managers.ItemsQuests
  local SeaManager = Managers.SeaManager
  local Tween = Managers.PlayerTeleport
  
  local MaxMastery: number = Module.GameData.MaxMastery
  local MaxLevel: number = Module.GameData.MaxLevel
  local CurrentSea: number = Module.GameData.Sea
  
  local IsAlive: (Character: Model) -> boolean = Module.IsAlive
  local EquipTool: (ToolName: string, ByType: boolean?) -> (nil) = Module.EquipTool
  
  local Inventory: table = Module.Inventory
  local FireRemote: (... any?) -> any? = Module.FireRemote
  
  local Unlocked: { [string]: boolean? } = Inventory.Unlocked
  local ItemCount: { [string]: number } = Inventory.Count
  local ItemMastery: { [string]: number } = Inventory.Mastery
  
  local IsSpawned: (Enemy: string) -> boolean? = Module.Enemies.IsSpawned
  local GetEnemy: (Enemy: string|table) -> Model = Module.EnemySpawned
  local EnemyLocations: { [string]: { CFrame } } = Module.EnemyLocations
  
  local Elites = FarmManager.Enemies.Elites
  local Bones = FarmManager.Enemies.Bones
  local Katakuri = FarmManager.Enemies.Katakuri
  local Ectoplasm = FarmManager.Enemies.Ectoplasm
  
  local IsBoss: (Enemy: string) -> boolean = Module.IsBoss
  local Bosses: { [string]: table } = Module.Bosses
  
  local GetEnemy: (Enemy: string|table) -> Model = Module.EnemySpawned
  local Attack: (Enemy: Model, BringMobs: boolean?, MultiBring: boolean?, FarmMode: string?) -> (nil) = FarmManager.attack
  local MoveTo: (cframe: CFrame, speed: number?, noLog: boolean?, linearTween: boolean?) -> (nil) = Tween.new
  
  local KillBossByInfo: (Information: table, Name: string, IgnoreQuest: boolean) -> any? = Functions.KillBossByInfo
  
  local EliteQuest = CFrame.new(-5417, 313, -2822)
  
  local Custom = {}
  
  function Custom.EliteHunter()
    local Quest = QuestManager:VerifyQuest(Elites)
    
    if Quest then
      local Elite = Enemies(Quest)
      if Elite and Elite.PrimaryPart then
        Attack(Elite)
        return `Killing Elite Hunter: {Quest}`
      end
    else
      local EliteHunter = Module.Enemies:GetEnemyByTag("Elite")
      
      if EliteHunter then
        MoveTo(EliteQuest)
        Tween:talkNpc(EliteQuest, "EliteHunter")
        return `Getting Elite Quest: {EliteHunter.Name}`
      end
    end
  end
  
  function Custom.Level()
    local Quest = QuestManager:GetQuest()
    
    if not Quest then
      return nil
    end
    
    local Target = Quest.Enemy.Name
    local Position = Quest.Enemy.Position
    
    local EnemyName = QuestManager:VerifyQuest(Target)
    
    if EnemyName and IsBoss(EnemyName) then
      return KillBossByInfo(Bosses[EnemyName], EnemyName, false)
    end
    
    if EnemyName then
      local Enemy = GetEnemy(EnemyName)
      
      if Enemy and Enemy.PrimaryPart then
        Attack(Enemy, true)
        return `Custom Killing: {EnemyName}`
      else
        local QuestPosition = QuestManager:GetQuestPosition(Quest.Name)
        
        if #Position > 0 then
          Tween:NPCs(Position)
        elseif QuestPosition then
          MoveTo(QuestPosition + QuestManager._Position)
        end
        
        return `Custom Waiting for: {EnemyName}`
      end
    else
      return QuestManager:StartQuest(Quest.Name, Quest.Count, QuestManager:GetQuestPosition(Quest.Name))
    end
  end
  
  return Custom
end

local Settings = {
  ModuleUrl: string? = "https://raw.githubusercontent.com/realredz/BloxFruits/refs/heads/main/Utils/Module.lua",
  LibraryUrl: string? = "https://raw.githubusercontent.com/realredz/RedzLibV5/refs/heads/main/Source.lua",
  
  JoinTeam: string? = "Pirates",
  Translator: boolean? = true,
  
  CustomFunctions: (self: ScriptAPI) -> table = CustomFunctions,
  
  EspColors = {
    Players = Color3.fromRGB(220, 220, 220),
    Fruits = Color3.fromRGB(255, 25, 25),
    Islands = Color3.fromRGB(170, 170, 170),
    Berries = Color3.fromRGB(255, 255, 0),
    Chests = {
      Chest1 = Color3.fromRGB(150, 150, 150),  -- Basic
      Chest2 = Color3.fromRGB(255, 255, 0),    -- Golden
      Chest3 = Color3.fromRGB(0, 255, 255),    -- Diamond
      Null = Color3.fromRGB(150, 0, 255)       -- Any
    }
  }
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/realredz/BloxFruits/refs/heads/main/Source.lua"))(Settings)
