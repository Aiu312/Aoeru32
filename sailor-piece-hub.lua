-- Sailor Piece Hub | v47
-- Rayfield через HttpGet; хаб использует Luau (continue). Если всё серым — см. Developer Console F9.
--
-- ► Лоадер с GitHub: при необходимости подставь raw URL ниже только в ЛОКАЛЬНОЙ копии или в маленьком лоадере.
--    В файле на GitHub переменную оставь "" иначе хаб может уйти в рекурсию (качать себя снова).
--    Однострочник в экзекутор: loadstring(game:HttpGet("RAW_URL",true))()
--
-- Raw (коммит, как у тебя): https://raw.githubusercontent.com/Aiu312/Aoeru32/a2b6e27284d7e8f5b56dafbb2b5dc4eba67af684/sailor-piece-hub.lua
-- Raw (ветка main, обновляется при push): https://raw.githubusercontent.com/Aiu312/Aoeru32/refs/heads/main/sailor-piece-hub.lua
-- Если репозиторий на master — замени main на master в ссылке.
local SAILOR_HUB_LOAD_FROM_URL=""
if type(SAILOR_HUB_LOAD_FROM_URL)=="string" and SAILOR_HUB_LOAD_FROM_URL~="" then
	local ok,h=pcall(function()
		return game:HttpGet(SAILOR_HUB_LOAD_FROM_URL,true)
	end)
	if not ok or type(h)~="string" or #h<500 then
		warn("[Sailor Piece Hub] не скачан скрипт с URL (raw GitHub?). Проверь ссылку и что репозиторий Public. Ответ:",tostring(h))
		return
	end
	local fn,estr=loadstring(h,"SailorHubGithub")
	if not fn then
		warn("[Sailor Piece Hub] loadstring после HttpGet:",estr)
		return
	end
	local okRun,errRun=pcall(fn)
	if not okRun then
		warn("[Sailor Piece Hub] ошибка выполнения подгруженного хаба:",errRun)
	end
	return
end

local Rayfield
do
    local errs={}
    local src

    local okHttp,body=pcall(function()
        return game:HttpGet("https://sirius.menu/rayfield",true)
    end)
    if okHttp and type(body)=="string" and #body>80 then src=body
    else errs[#errs+1]="HttpGet: "..tostring((not okHttp) and body or "короткий/пустой ответ")
    end

    if not src then
        pcall(function()
            local rq=syn and syn.request or http_request or request
            if type(rq)~="function" then
                errs[#errs+1]="нет syn.request/http_request/request"
                return
            end
            local res=rq({Url="https://sirius.menu/rayfield",Method="GET"})
            local b=res and (res.Body or res.body)
            if type(b)=="string" and #b>80 then src=b
            else errs[#errs+1]="syn.request без тела или короткий ответ"
            end
        end)
    end

    if not src then
        warn("[Sailor Piece Hub] Rayfield не загрузился. Открой F9:")
        warn(table.concat(errs," | "))
        return
    end

    local chunk,estr=loadstring(src)
    if not chunk then
        warn("[Sailor Piece Hub] loadstring Rayfield:",estr)
        return
    end
    local okRun,rf=pcall(chunk)
    if not okRun or rf==nil then
        warn("[Sailor Piece Hub] ошибка выполнения Rayfield:",rf)
        return
    end
    Rayfield=rf
end
if Rayfield==nil then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local CollectionService = game:GetService("CollectionService")
local lp = Players.LocalPlayer

local npcPositions = {
    ["GojoMovesetNPC"]=Vector3.new(1741,157,514),
    ["SukunaMovesetNPC"]=Vector3.new(1325,162,-35),
    ["AizenMovesetNPC"]=Vector3.new(-347,12,1402),
    ["JinwooMovesetNPC"]=Vector3.new(91,2,1097),
    ["StrongestofTodayBuyerNPC"]=Vector3.new(94,151,-2638),
    ["StrongestinHistoryBuyerNPC"]=Vector3.new(756,89,-1953),
    ["GojoMasteryNPC"]=Vector3.new(55,41,-2067),
    ["SukunaMasteryNPC"]=Vector3.new(598,30,-2055),
    ["BlessedMaidenMasteryNPC"]=Vector3.new(940,5,-1067),
    ["RimuruMasteryNPC"]=Vector3.new(-1325,15,527),
    ["SaberAlterMasteryNPC"]=Vector3.new(694,1,-1227),
    ["StrongestShinobiMasteryNPC"]=Vector3.new(-1981,6,-384),
    ["HakiQuestNPC"]=Vector3.new(-499,23,-1253),
    ["ObservationBuyer"]=Vector3.new(-714,12,-528),
    ["ConquerorHakiNPC"]=Vector3.new(1942,144,-25),
    ["Katana"]=Vector3.new(106,10,-271),
    ["DarkBladeNPC"]=Vector3.new(-133,13,-1092),
    ["GryphonBuyerNPC"]=Vector3.new(1430,8,277),
    ["RagnaBuyer"]=Vector3.new(-278,46,-1346),
    ["IchigoBuyer"]=Vector3.new(-793,5,1019),
    ["RimuruBuyer"]=Vector3.new(-1540,3,66),
    ["ShadowMonarchBuyerNPC"]=Vector3.new(1463,49,-901),
    ["GilgameshBuyerNPC"]=Vector3.new(842,64,-1003),
    ["YamatoBuyerNPC"]=Vector3.new(-1288,91,-999),
    ["TrueAizenBuyerNPC"]=Vector3.new(-1461,1604,1855),
    ["GojoCraftNPC"]=Vector3.new(-123,1,-2095),
    ["SukunaCraftNPC"]=Vector3.new(697,1,-2043),
    ["SlimeCraftNPC"]=Vector3.new(-1168,2,173),
    ["GrailCraftNPC"]=Vector3.new(606,69,-1243),
    ["BabylonCraftNPC"]=Vector3.new(599,68,-1236),
    ["SummonBossNPC"]=Vector3.new(651,-4,-1022),
    ["StrongestBossSummonerNPC"]=Vector3.new(392,-3,-2178),
    ["RimuruSummonerNPC"]=Vector3.new(-1236,16,279),
    ["AnosBossSummonerNPC"]=Vector3.new(901,1,1293),
    ["AtomicBossSummonerNPC"]=Vector3.new(127,2,1879),
    ["MerchantNPC"]=Vector3.new(368,2,783),
    ["StorageNPC"]=Vector3.new(329,2,764),
    ["ExchangeNPC"]=Vector3.new(732,-5,-922),
    ["AscendNPC"]=Vector3.new(252,4,715),
    ["TraitNPC"]=Vector3.new(337,2,813),
    ["RerollStatNPC"]=Vector3.new(373,2,810),
    ["GemFruitDealer"]=Vector3.new(400,2,752),
    ["CoinFruitDealer"]=Vector3.new(408,2,802),
    ["TitlesNPC"]=Vector3.new(364,2,755),
    ["GroupRewardNPC"]=Vector3.new(-31,-4,-301),
    ["BossRushPortalNPC"]=Vector3.new(106,6,840),
    ["BossRushMerchantNPC"]=Vector3.new(108,6,853),
    ["BossRushShopNPC"]=Vector3.new(104,6,826),
    ["EnchantNPC"]=Vector3.new(1402,8,8),
    ["BlessingNPC"]=Vector3.new(1420,8,11),
    ["ArtifactMilestoneNPC"]=Vector3.new(-424,1,-1103),
    ["ArtifactsUnlocker"]=Vector3.new(-441,1,-1096),
    ["SkillTreeNPC"]=Vector3.new(-1142,6,212),
    ["SpecPassivesNPC"]=Vector3.new(-1103,5,-1239),
    ["PowerNPC"]=Vector3.new(170,-1,1804),
    ["DungeonMerchantNPC"]=Vector3.new(1376,2,-890),
    ["DungeonPortalsNPC"]=Vector3.new(1426,2,-930),
    ["InfiniteTowerPortalNPC"]=Vector3.new(1344,1,-1470),
    ["InfiniteTowerMerchantNPC"]=Vector3.new(1355,0,-1457),
    ["InfiniteTowerStatShopNPC"]=Vector3.new(1336,1,-1483),
    ["HogyokuQuestNPC"]=Vector3.new(-380,8,1529),
    ["AizenQuestlineBuff"]=Vector3.new(-893,24,1229),
    ["TrueAizenFUnlockNPC"]=Vector3.new(-1221,1692,1864),
    ["ShadowQuestlineBuff"]=Vector3.new(335,25,-378),
    ["ShadowMonarchQuestlineBuff"]=Vector3.new(243,26,-84),
    ["RagnaQuestlineBuff"]=Vector3.new(-273,-5,-1354),
    ["MoonSlayerBuff"]=Vector3.new(831,57,-984),
    ["MoonSlayerSeller"]=Vector3.new(824,9,-1242),
    ["IceQueenBuff"]=Vector3.new(875,52,-1030),
    ["IceQueenSeller"]=Vector3.new(932,10,-1140),
    ["AnosQuestNPC"]=Vector3.new(727,-2,1273),
    ["AlucardBuyer"]=Vector3.new(476,2,1037),
    ["YujiBuyerNPC"]=Vector3.new(1240,136,408),
    ["AnosBuyerNPC"]=Vector3.new(974,74,1511),
    ["SaberAlterBuyerNPC"]=Vector3.new(860,59,-1014),
    ["QinShiBuyer"]=Vector3.new(760,14,-1267),
    ["StrongestShinobiBuyerNPC"]=Vector3.new(-1775,6,-384),
    ["CidBuyer"]=Vector3.new(1428,49,-977),
    ["AtomicBuyer"]=Vector3.new(-177,3,1973),
    ["QuestNPC1"]=Vector3.new(171,16,-215),
    ["QuestNPC2"]=Vector3.new(-8,-3,-203),
    ["QuestNPC3"]=Vector3.new(-520,-2,-434),
    ["QuestNPC4"]=Vector3.new(-468,18,480),
    ["QuestNPC5"]=Vector3.new(-688,-3,-461),
    ["QuestNPC6"]=Vector3.new(-864,-5,-386),
    ["QuestNPC7"]=Vector3.new(-389,-2,-946),
    ["QuestNPC8"]=Vector3.new(-551,22,-1026),
    ["QuestNPC9"]=Vector3.new(1419,8,372),
    ["QuestNPC10"]=Vector3.new(1604,8,429),
    ["QuestNPC11"]=Vector3.new(-286,-4,1038),
    ["QuestNPC12"]=Vector3.new(626,1,-1610),
    ["QuestNPC13"]=Vector3.new(-20,1,-1986),
    ["QuestNPC14"]=Vector3.new(-1188,17,338),
    ["QuestNPC15"]=Vector3.new(1028,1,1241),
    ["QuestNPC16"]=Vector3.new(-1165,2,-1190),
    ["QuestNPC17"]=Vector3.new(-1409,1603,1642),
    ["QuestNPC18"]=Vector3.new(-1787,6,-745),
    ["QuestNPC19"]=Vector3.new(67,2,1758),
}

local islandMap = {
    QuestNPC1="Starter",   QuestNPC2="Starter",
    QuestNPC3="Jungle",    QuestNPC4="Jungle",
    QuestNPC5="Desert",    QuestNPC6="Desert",
    QuestNPC7="Snow",      QuestNPC8="Snow",
    QuestNPC9="Shibuya",   QuestNPC10="Shibuya",
    QuestNPC11="HollowIsland",
    QuestNPC12="Shinjuku", QuestNPC13="Shinjuku",
    QuestNPC14="Slime",    QuestNPC15="Academy",
    QuestNPC16="Judgement",QuestNPC17="SoulDominion",
    QuestNPC18="Ninja",    QuestNPC19="Lawless",
    HogyokuQuestNPC="HollowIsland",
    AnosQuestNPC="Academy",
}

local mobIslandMap = {
    Thief="Starter",       Bunny="Starter",
    Monkey="Jungle",       DesertBandit="Desert",
    FrostRogue="Snow",     Sorcerer="Shibuya",
    Curse="Shinjuku",      Hollow="HollowIsland",
    StrongSorcerer="Shinjuku", Slime="Slime",
    AcademyTeacher="Academy",  Swordsman="Judgement",
    Quincy="SoulDominion", Ninja="Ninja",
    ArenaFighter="Lawless",ThiefBoss="Starter",
    MonkeyBoss="Jungle",   DesertBoss="Desert",
    SnowBoss="Snow",       PandaMiniBoss="Shibuya",
}

local allIslands = {
    {name="Starter",      label="Starter Island"},
    {name="Jungle",       label="Jungle Island"},
    {name="Desert",       label="Desert Island"},
    {name="Snow",         label="Snow Island"},
    {name="Shibuya",      label="Shibuya Station"},
    {name="HollowIsland", label="Hollow Island"},
    {name="Sailor",       label="Sailor Island"},
    {name="Shinjuku",     label="Shinjuku Island"},
    {name="Slime",        label="Slime Island"},
    {name="Dungeon",      label="Dungeon Island"},
    {name="Boss",         label="Boss Island"},
    {name="Academy",      label="Academy Island"},
    {name="Judgement",    label="Judgement Island"},
    {name="SoulDominion", label="Soul Dominion"},
    {name="Ninja",        label="Ninja Island"},
    {name="Lawless",      label="Lawless Island"},
    {name="Tower",        label="Tower Island"},
}

local npcCategories = {
    {
        section="⚔️ Trainers — Fighting Styles",
        npcs={
            {name="GojoMovesetNPC",             label="Gojo Trainer  |  Unlock Gojo style  |  Shibuya"},
            {name="SukunaMovesetNPC",           label="Sukuna Trainer  |  Unlock Sukuna style  |  Shibuya"},
            {name="AizenMovesetNPC",            label="Aizen Trainer  |  Unlock Aizen style  |  Hollow Island"},
            {name="JinwooMovesetNPC",           label="Jinwoo Trainer  |  Unlock Solo Hunter style  |  Sailor Island"},
            {name="StrongestofTodayBuyerNPC",   label="Strongest of Today Trainer  |  Boss Island rooftop"},
            {name="StrongestinHistoryBuyerNPC", label="Strongest in History Trainer  |  Shinjuku Island"},
        }
    },
    {
        section="💪 Mastery NPCs",
        npcs={
            {name="GojoMasteryNPC",             label="Gojo Mastery  |  +30% DMG Gojo  |  Shibuya"},
            {name="SukunaMasteryNPC",           label="Sukuna Mastery  |  +30% DMG Sukuna  |  Shibuya"},
            {name="BlessedMaidenMasteryNPC",    label="Blessed Maiden Mastery  |  +30% DMG  |  Dungeon Island"},
            {name="RimuruMasteryNPC",           label="Rimuru Mastery  |  +30% DMG Rimuru  |  Dungeon Island"},
            {name="SaberAlterMasteryNPC",       label="Saber Alter Mastery  |  +30% DMG  |  Dungeon Island"},
            {name="StrongestShinobiMasteryNPC", label="Strongest Shinobi Mastery  |  +30% DMG  |  Ninja Island"},
        }
    },
    {
        section="🥊 Haki Trainers",
        npcs={
            {name="HakiQuestNPC",    label="Armament Haki  |  Unlock Armament Haki  |  Snow Island"},
            {name="ObservationBuyer",label="Observation Haki  |  Unlock Observation Haki  |  Desert Island"},
            {name="ConquerorHakiNPC",label="Conqueror Haki  |  Unlock Conqueror Haki  |  Shibuya rooftop"},
        }
    },
    {
        section="🗡️ Weapon Sellers",
        npcs={
            {name="Katana",                label="Katana Seller  |  2,500 coins  |  Starter Island"},
            {name="DarkBladeNPC",          label="Dark Blade Seller  |  250K + 150 gems  |  Snow Island"},
            {name="GryphonBuyerNPC",       label="Gryphon Seller  |  Buy Gryphon  |  Shibuya"},
            {name="RagnaBuyer",            label="Ragna Seller  |  1M + 4500 gems + mats  |  Snow Island"},
            {name="IchigoBuyer",           label="Ichigo Seller  |  5M + 8500 gems + mats  |  Hollow Island"},
            {name="RimuruBuyer",           label="Rimuru Seller  |  30M + 20K gems (Demon Lord title)  |  Slime"},
            {name="ShadowMonarchBuyerNPC", label="Shadow Monarch Seller  |  Dungeon Island"},
            {name="GilgameshBuyerNPC",     label="Gilgamesh Buyer  |  Boss Island"},
            {name="YamatoBuyerNPC",        label="Yamato Seller  |  Judgement Island"},
            {name="TrueAizenBuyerNPC",     label="True Aizen Seller  |  Soul Dominion"},
        }
    },
    {
        section="🔨 Crafting NPCs",
        npcs={
            {name="GojoCraftNPC",    label="Shrine Domain Shard Crafter  |  Shinjuku Island"},
            {name="SukunaCraftNPC",  label="Infinity Domain Shard Crafter  |  Shinjuku Island"},
            {name="SlimeCraftNPC",   label="Slime Key Crafter  |  2x Slime Shard  |  Slime Island"},
            {name="GrailCraftNPC",   label="Divine Grail Crafter  |  3x Broken Sword  |  Boss Island"},
            {name="BabylonCraftNPC", label="Babylon Key Crafter  |  Servant Race needed  |  Boss Island"},
        }
    },
    {
        section="👑 Boss Summoners",
        npcs={
            {name="SummonBossNPC",           label="Boss Summoner  |  Saber/Qin Shi/Ichigo/Gilgamesh  |  Boss Island"},
            {name="StrongestBossSummonerNPC",label="Strongest Boss Summoner  |  Today/History  |  Boss Island"},
            {name="RimuruSummonerNPC",       label="Rimuru Summoner  |  Slime Island"},
            {name="AnosBossSummonerNPC",     label="Anos Boss Summoner  |  Calamity Seal  |  Academy Island"},
            {name="AtomicBossSummonerNPC",   label="Atomic Boss Summoner  |  Lawless Island"},
        }
    },
    {
        section="⚙️ Utility — Sailor Island",
        npcs={
            {name="MerchantNPC",         label="Merchant  |  Buy general items  |  Sailor Island"},
            {name="StorageNPC",          label="Storage  |  Store inventory  |  Sailor Island"},
            {name="ExchangeNPC",         label="Exchange  |  Exchange items  |  Sailor Island"},
            {name="AscendNPC",           label="Ascension NPC  |  Ascend character  |  Sailor Island"},
            {name="TraitNPC",            label="Trait NPC  |  Reroll traits  |  Sailor Island"},
            {name="RerollStatNPC",       label="Stat Reroll  |  Reroll build stats  |  Sailor Island"},
            {name="GemFruitDealer",      label="Gem Fruit Dealer  |  50 gems per roll  |  Sailor Island"},
            {name="CoinFruitDealer",     label="Coin Fruit Dealer  |  15K coins per roll  |  Sailor Island"},
            {name="TitlesNPC",           label="Titles NPC  |  View and change titles  |  Sailor Island"},
            {name="GroupRewardNPC",      label="Group Reward  |  Claim group rewards  |  Sailor Island"},
            {name="BossRushPortalNPC",   label="Boss Rush Portal  |  Enter Boss Rush  |  Sailor Island"},
            {name="BossRushMerchantNPC", label="Boss Rush Merchant  |  Boss Rush shop  |  Sailor Island"},
            {name="BossRushShopNPC",     label="Boss Rush Shop  |  Buy Boss Rush rewards  |  Sailor Island"},
        }
    },
    {
        section="⚙️ Utility — Other Islands",
        npcs={
            {name="EnchantNPC",               label="Enchanter  |  Enchant accessories E1-E10  |  Shibuya"},
            {name="BlessingNPC",              label="Blessing NPC  |  Bless swords/styles  |  Shibuya"},
            {name="ArtifactMilestoneNPC",     label="Artifact Milestone  |  Claim rewards  |  Snow Island"},
            {name="ArtifactsUnlocker",        label="Artifacts Unlocker  |  Unlock artifacts  |  Snow Island"},
            {name="SkillTreeNPC",             label="Skill Tree  |  Unlock at Lv 7000  |  Slime Island"},
            {name="SpecPassivesNPC",          label="Spec Passives  |  Reroll passives  |  Judgement Island"},
            {name="PowerNPC",                 label="Power NPC  |  Power System  |  Lawless Island"},
            {name="DungeonMerchantNPC",       label="Dungeon Merchant  |  Dungeon Island"},
            {name="DungeonPortalsNPC",        label="Dungeon Portals  |  Enter dungeons  |  Dungeon Island"},
            {name="InfiniteTowerPortalNPC",   label="Infinite Tower Portal  |  Lv 8500+  |  Tower Island"},
            {name="InfiniteTowerMerchantNPC", label="Infinite Tower Merchant  |  Tower Island"},
            {name="InfiniteTowerStatShopNPC", label="Infinite Tower Stat Shop  |  Tower Island"},
        }
    },
    {
        section="📜 Questlines & Buffs",
        npcs={
            {name="HogyokuQuestNPC",          label="Hogyoku Quest  |  6 fragments — unlock Soul Dominion  |  Hollow"},
            {name="AizenQuestlineBuff",        label="Aizen Questline  |  Worthiness Fragment — Aizen Sword  |  Hollow"},
            {name="TrueAizenFUnlockNPC",       label="True Aizen Unlock  |  Soul Dominion"},
            {name="ShadowQuestlineBuff",       label="Shadow Questline  |  Dungeon Island"},
            {name="ShadowMonarchQuestlineBuff",label="Shadow Monarch Buff  |  Dungeon Island"},
            {name="RagnaQuestlineBuff",        label="Ragna Buff  |  Snow Island"},
            {name="MoonSlayerBuff",            label="Moon Slayer Buff  |  Boss Island"},
            {name="MoonSlayerSeller",          label="Moon Slayer Seller  |  Boss Island"},
            {name="IceQueenBuff",              label="Ice Queen Buff  |  Boss Island"},
            {name="IceQueenSeller",            label="Ice Queen Seller  |  Boss Island"},
            {name="AnosQuestNPC",              label="Anos Quest  |  Academy Island"},
        }
    },
    {
        section="💰 Buyers",
        npcs={
            {name="AlucardBuyer",            label="Alucard Buyer  |  Sailor Island"},
            {name="YujiBuyerNPC",            label="Yuji Buyer  |  Shibuya"},
            {name="AnosBuyerNPC",            label="Anos Buyer  |  Academy Island"},
            {name="SaberAlterBuyerNPC",      label="Saber Alter Buyer  |  Boss Island"},
            {name="QinShiBuyer",             label="Qin Shi Buyer  |  Boss Island"},
            {name="StrongestShinobiBuyerNPC",label="Strongest Shinobi Buyer  |  Ninja Island"},
            {name="CidBuyer",                label="Cid Buyer  |  Lawless Island"},
            {name="AtomicBuyer",             label="Atomic Buyer  |  Lawless Island"},
        }
    },
}

local mobQuestList={
    {name="QuestNPC1",  label="QuestNPC1  |  Thief Hunter  |  Lv 0-99  |  x5"},
    {name="QuestNPC3",  label="QuestNPC3  |  Monkey Hunter  |  Lv 250-499  |  x5"},
    {name="QuestNPC5",  label="QuestNPC5  |  Desert Bandit  |  Lv 750-999  |  x5"},
    {name="QuestNPC7",  label="QuestNPC7  |  Frost Rogue  |  Lv 1500-1999  |  x5"},
    {name="QuestNPC9",  label="QuestNPC9  |  Sorcerer  |  Lv 3000-3999  |  x5"},
    {name="QuestNPC11", label="QuestNPC11  |  Hollow  |  Lv 5000-6250  |  x5"},
    {name="QuestNPC12", label="QuestNPC12  |  Strong Sorcerer  |  Lv 6250-7000  |  x5"},
    {name="QuestNPC13", label="QuestNPC13  |  Curse  |  Lv 7000-8000  |  x5"},
    {name="QuestNPC14", label="QuestNPC14  |  Slime  |  Lv 8000-9000  |  x5"},
    {name="QuestNPC15", label="QuestNPC15  |  Academy  |  Lv 9000-10000  |  x5"},
    {name="QuestNPC16", label="QuestNPC16  |  Swordsman  |  Lv 10000-10750  |  x5"},
    {name="QuestNPC17", label="QuestNPC17  |  Quincy  |  Lv 10750-11500  |  x5"},
    {name="QuestNPC18", label="QuestNPC18  |  Ninja  |  Lv 11500-12000  |  x5"},
    {name="QuestNPC19", label="QuestNPC19  |  Arena Fighter  |  Lv 12000+  |  x5"},
}

local bossQuestList={
    {name="QuestNPC2",  label="QuestNPC2  |  Thief Boss  |  Lv 100-249  |  x1"},
    {name="QuestNPC4",  label="QuestNPC4  |  Monkey Boss  |  Lv 500-749  |  x1"},
    {name="QuestNPC6",  label="QuestNPC6  |  Desert Boss  |  Lv 1000-1499  |  x1"},
    {name="QuestNPC8",  label="QuestNPC8  |  Winter Warden  |  Lv 2000-2999  |  x1"},
    {name="QuestNPC10", label="QuestNPC10  |  Panda Boss  |  Lv 4000-5000  |  x1"},
}

local Window=Rayfield:CreateWindow({
    Name="Sailor Piece Hub",
    LoadingTitle="Sailor Piece Hub",
    LoadingSubtitle="by Script",
    ConfigurationSaving={Enabled=false},
    KeySystem=false,
})

local currentWalkSpeed=16
local flying=false
local mobFarming=false
local bossFarming=false
local antiAfkRunning=false
local floorHiding=false
local autoMobQuestEnabled=false
local autoBossQuestEnabled=false
local autoQuestEnabled=false
local selectedMobPrefix="Thief"
local selectedBossPrefix="ThiefBoss"
local selectedMobQuestNPC="QuestNPC1"
local selectedBossQuestNPC="QuestNPC2"
local selectedQuestNPC="QuestNPC1"
local flyConnection,bodyVelocity,bodyGyro
local lastZ=-math.huge
local isInteracting=false
local killCount=0
local requiredKills=5
local trackedConnections={}
local currentQuestMobPrefix="Thief"
local forceQuestChange=false
local hasActiveQuest=false
local killCountReached=false
local currentSkills={}
local currentTools={}
local autoSkillEnabled={}
local autoSkillCD={}
local autoSkillLastUsed={}
local autoSkillLoopRunning=false
local selectedSkills={}
local selectedStyle1=nil
local selectedStyle2=nil
local farmingGUI=nil
local lastHotbarSnapshot=""
local lastSkillSnapshot=""
local autoStyleSwitch=false
local styleSwitch_CD=5
local selectedIsland="Starter"
local selectedNPCData=npcCategories[1].npcs[1]
local worldBossFarming=false
local autoWorldBossEnabled=false
local selectedWorldBossName="All"
local worldBossTargetName=nil
local worldBossSpawnDelay=0.3
local worldBossCycleDelay=1.2

-- Auto Progress: drives mob quest tier from HUD level, sword buys, stat clicks (see loop below).
local autoLevelProgressEnabled=false
local AUTO_PROGRESS_LEVEL_STOP=16000
local AUTO_STAT_SOFT_CAP=16000
local SWORD_KATANA_COINS=2500
local SWORD_DARK_COINS=250000
local SWORD_DARK_GEMS=150
local SWORD_GRYPHON_COINS=650000
local SWORD_GRYPHON_GEMS=650
-- true: печатает в Output (F9) имена тулзов, тир и ремоут — скопируй блок и пришли, если меч не экипируется.
local DEBUG_SWORD_EQUIP=false
local SWORD_EQUIP_REMOTE_PATH=nil
local STAT_SPEND_REMOTE_PATH=nil
local STAT_SPEND_REMOTE_SWORD_KEY="Sword"
local STAT_SPEND_REMOTE_DEFENSE_KEY="Defense"

local TWEEN_NPC_STUDS_PER_SEC=3600
local TWEEN_NPC_HANG_SECONDS=0.30
-- Extra height above NPC waypoint (XZ offset unchanged: +3 Z toward NPC).
local TWEEN_NPC_EXTRA_HEIGHT_STUDS=8

-- After tween (often mid-air): dash via Q on PC/gamepad; on touch-only, optional HUD tap.
local DASH_KEY_AFTER_ARRIVE=Enum.KeyCode.Q
-- Viewport fractions 0–1 (dash/skill HUD hit target); tune for your layout.
local DASH_MOBILE_HUD_TX=0.88
local DASH_MOBILE_HUD_TY=0.74
-- True: also tap HUD spot when TouchEnabled if keyboard dash is flaky.
local DASH_FORCE_HUD_TAP_ON_TOUCH=false

local questKillCount={
    QuestNPC1=5,  QuestNPC2=1,  QuestNPC3=5,  QuestNPC4=1,
    QuestNPC5=5,  QuestNPC6=1,  QuestNPC7=5,  QuestNPC8=1,
    QuestNPC9=5,  QuestNPC10=1, QuestNPC11=5, QuestNPC12=5,
    QuestNPC13=5, QuestNPC14=5, QuestNPC15=5, QuestNPC16=5,
    QuestNPC17=5, QuestNPC18=5, QuestNPC19=5,
}

local questMobMap={
    QuestNPC1={mob="Thief",boss=false},
    QuestNPC2={mob="ThiefBoss",boss=true},
    QuestNPC3={mob="Monkey",boss=false},
    QuestNPC4={mob="MonkeyBoss",boss=true},
    QuestNPC5={mob="DesertBandit",boss=false},
    QuestNPC6={mob="DesertBoss",boss=true},
    QuestNPC7={mob="FrostRogue",boss=false},
    QuestNPC8={mob="SnowBoss",boss=true},
    QuestNPC9={mob="Sorcerer",boss=false},
    QuestNPC10={mob="PandaMiniBoss",boss=true},
    QuestNPC11={mob="Hollow",boss=false},
    QuestNPC12={mob="StrongSorcerer",boss=false},
    QuestNPC13={mob="Curse",boss=false},
    QuestNPC14={mob="Slime",boss=false},
    QuestNPC15={mob="AcademyTeacher",boss=false},
    QuestNPC16={mob="Swordsman",boss=false},
    QuestNPC17={mob="Quincy",boss=false},
    QuestNPC18={mob="Ninja",boss=false},
    QuestNPC19={mob="ArenaFighter",boss=false},
}

local bossWaitMob={
    ThiefBoss="Thief",    MonkeyBoss="Monkey",
    DesertBoss="DesertBandit", SnowBoss="FrostRogue",
    PandaMiniBoss="Sorcerer",
}

local worldBossList={
    {name="AizenBoss",            island="HollowIsland", label="AizenBoss  |  Hollow Island"},
    {name="GojoBoss",             island="Shibuya",      label="GojoBoss  |  Shibuya Station"},
    {name="JinwooBoss",           island="Sailor",       label="JinwooBoss  |  Sailor Island"},
    {name="SukunaBoss",           island="Shibuya",      label="SukunaBoss  |  Shibuya Station"},
    {name="StrongestShinobiBoss", island="Ninja",        label="StrongestShinobiBoss  |  Ninja Island"},
    {name="YamatoBoss",           island="Judgement",    label="YamatoBoss  |  Judgement Island"},
    {name="YujiBoss",             island="Shibuya",      label="YujiBoss  |  Shibuya Station"},
}

local worldBossIslandProbe={
    HollowIsland=Vector3.new(-286,-4,1038),
    Shibuya=Vector3.new(1419,8,372),
    Ninja=Vector3.new(-1787,6,-745),
    Sailor=Vector3.new(368,2,783),
    Judgement=Vector3.new(-1165,2,-1190),
    Starter=Vector3.new(171,16,-215),
}

-- Hogyoku / Demonite: Studio anchors; ProximityPrompts live under workspace models.
local HOGYOKU_FRAGMENT_CF={
    [1]=CFrame.new(-424.589447, 56.6024628, -1235.32568, 0.289153755, 0.168311402, 0.942370117, -0.00750803947, 0.984790444, -0.173584118, -0.957253277, 0.0431171507, 0.286019504),
    [2]=CFrame.new(1636.70898, 85.5206757, 247.291901, 0.989795089, -0, -0.142497987, 0, 1, -0, 0.142497987, 0, 0.989795089),
    [3]=CFrame.new(-636.008423, 22.5490417, 1206.28113, 0.923217237, -0.345339119, 0.16855523, 0.381866992, 0.873522758, -0.301886827, -0.0429835021, 0.343072802, 0.938324809),
    [4]=CFrame.new(648.099976, 137.94455, -2069.59741, 0.772088885, -0.631137073, 0.0744634345, 0.628663361, 0.775662899, 0.0559423678, -0.0930658206, 0.00361994654, 0.995653391),
    [5]=CFrame.new(-1206.52283, 30.8849335, 463.206787, 0.993406057, -0.0171359815, 0.113360971, -0.00357546285, 0.983655572, 0.180024818, -0.114593059, -0.179243073, 0.977108181),
    [6]=CFrame.new(-906.39801, 15.7299957, -1260.2478, 0.990366459, -0, -0.138471082, 0, 1, -0, 0.138471082, 0, 0.990366459),
}
local DEMONITE_CORE_CF={
    [1]=CFrame.new(1006.00696, 11.7496796, 1130.03369, 0.427069724, -0.161284894, 0.889718413, -0.00357355922, 0.983654857, 0.180028737, -0.90421176, -0.0800643042, 0.419512808),
    [2]=CFrame.new(920.795715, 70.3931427, 1478.13025, 0.725795209, -0.576960802, 0.374616534, 0.622277141, 0.782796979, -7.01099634e-06, -0.29324463, 0.233120382, 0.927179873),
}

-- =====================
--   TELEPORT TO ISLAND — portal (for auto quest/farm)
-- =====================
-- Methods on Impl: stays under Luau ~200 locals per chunk limit
local Impl={}

function Impl.teleportToIsland(islandName)
    local ok,err=pcall(function()
        local rs=game:GetService("ReplicatedStorage")
        local remote=rs.Remotes.TeleportToPortal
        remote:FireServer(islandName)
    end)
    if not ok then print("teleportToIsland error: "..tostring(err)) end
    task.wait(1.5)
end

-- =====================
--   TWEEN to NPC (speed + hang + no collision during move)
-- =====================
function Impl.restoreCharacterCollision(saved)
    if not saved then return end
    for part,wasCollide in pairs(saved) do
        pcall(function()
            if part.Parent and part:IsA("BasePart") then part.CanCollide=wasCollide end
        end)
    end
end

function Impl.snapshotAndDisableCharacterCollision(char)
    local saved={}
    for _,inst in ipairs(char:GetDescendants()) do
        if inst:IsA("BasePart") then
            saved[inst]=inst.CanCollide
            inst.CanCollide=false
        end
    end
    return saved
end

function Impl.pressDashKeyboard()
    VIM:SendKeyEvent(true,DASH_KEY_AFTER_ARRIVE,false,game)
    task.wait(0.06)
    VIM:SendKeyEvent(false,DASH_KEY_AFTER_ARRIVE,false,game)
end

function Impl.pressDashHudTap()
    local cam=workspace.CurrentCamera
    if not cam then return end
    local v=cam.ViewportSize
    if v.X<=0 or v.Y<=0 then return end
    local x=math.clamp(DASH_MOBILE_HUD_TX,0,1)*v.X
    local y=math.clamp(DASH_MOBILE_HUD_TY,0,1)*v.Y
    VIM:SendMouseButtonEvent(x,y,0,true,game,1)
    task.wait(0.04)
    VIM:SendMouseButtonEvent(x,y,0,false,game,1)
end

function Impl.triggerDashOnceAfterArrival()
    pcall(Impl.pressDashKeyboard)
    local mobileLike=UIS.TouchEnabled and not UIS.KeyboardEnabled
    local alsoTap=DASH_FORCE_HUD_TAP_ON_TOUCH and UIS.TouchEnabled
    if mobileLike or alsoTap then
        pcall(Impl.pressDashHudTap)
    end
end

function Impl.tweenToPosition(targetCFrame)
    local char=lp.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    local savedCollision=Impl.snapshotAndDisableCharacterCollision(char)
    hrp.AssemblyLinearVelocity=Vector3.zero
    hrp.AssemblyAngularVelocity=Vector3.zero

    local dist=(hrp.Position-targetCFrame.Position).Magnitude
    local duration=math.max(dist/TWEEN_NPC_STUDS_PER_SEC,0.05)
    hum.PlatformStand=true

    pcall(function()
        local tween=TweenService:Create(hrp,TweenInfo.new(
            duration,Enum.EasingStyle.Linear,Enum.EasingDirection.Out
        ),{CFrame=targetCFrame})
        tween:Play()
        tween.Completed:Wait()
        -- Mid-air: one dash attempt (Q and/or HUD tap on touch).
        if hrp.Parent then
            Impl.triggerDashOnceAfterArrival()
            -- Hold arrival pose for TWEEN_NPC_HANG_SECONDS (pin CFrame + zero velocity).
            local untilT=tick()+TWEEN_NPC_HANG_SECONDS
            while tick()<untilT do
                if not hrp.Parent then break end
                hum.PlatformStand=true
                hrp.CFrame=targetCFrame
                hrp.AssemblyLinearVelocity=Vector3.zero
                hrp.AssemblyAngularVelocity=Vector3.zero
                RunService.Heartbeat:Wait()
            end
        end
    end)

    pcall(function() hum.PlatformStand=false end)
    Impl.restoreCharacterCollision(savedCollision)
end

function Impl.tweenToNPC(npcName)
    local pos=npcPositions[npcName]
    if not pos then return false end
    Impl.tweenToPosition(CFrame.new(pos+Vector3.new(0,TWEEN_NPC_EXTRA_HEIGHT_STUDS,3)))
    return true
end

function Impl.tweenToQuestNPCSimple(npcName)
    local pos=npcPositions[npcName]
    if not pos then return false end
    Impl.tweenToPosition(CFrame.new(pos+Vector3.new(0,0,3)))
    return true
end

local fireproximityprompt_exploit=nil
pcall(function() fireproximityprompt_exploit=fireproximityprompt end)

function Impl.fireProximityPromptCompat(pp)
    if not pp or not pp:IsA("ProximityPrompt") then return end
    local hold=pp.HoldDuration
    pp.HoldDuration=0
    pcall(function()
        if type(fireproximityprompt_exploit)=="function" then
            fireproximityprompt_exploit(pp)
        else
            pp:InputHoldBegin()
            task.wait(0.04)
            pp:InputHoldEnd()
        end
    end)
    pp.HoldDuration=hold
end

-- Collect targets: same base as Impl.tweenToNPC(), then nudge toward dumped anchor (fixes small undershoot).
local SPECIAL_COLLECT_EXTRA_Y_STUDS=-1
local SPECIAL_COLLECT_CLOSER_XZ_STUDS=7

function Impl.findHogyokuPrompt(index)
    local name="HogyokuFragment"..tostring(index)
    local inst=workspace:FindFirstChild(name,true)
    if not inst then return nil end
    local p=inst:FindFirstChild("HogyokuCollectPrompt",true)
    if p and p:IsA("ProximityPrompt") then return p end
    return nil
end

function Impl.findDemonitePrompt(index)
    local name="DemoniteCore"..tostring(index)
    local inst=workspace:FindFirstChild(name,true)
    if not inst then return nil end
    local p=inst:FindFirstChild("DemoniteCollectPrompt",true)
    if p and p:IsA("ProximityPrompt") then return p end
    return nil
end

function Impl.firePromptRepeat(pp,times)
    if not pp then return end
    for _=1,times or 4 do
        Impl.fireProximityPromptCompat(pp)
        task.wait(0.22)
    end
end

local SPECIAL_COLLECT_VERIFY_ATTEMPTS=3

function Impl.tweenAndAcceptNpcQuest(npcKey)
    local isl=islandMap[npcKey]
    if isl then
        Impl.teleportToIsland(isl)
        task.wait(0.55)
    end
    if not Impl.tweenToQuestNPCSimple(npcKey) then return false end
    task.wait(0.3)
    local npcHrp=Impl.findNPCHRP(npcKey)
    local npcModel=npcHrp and npcHrp.Parent
    if not npcModel then return false end
    local prompted=false
    for _,desc in ipairs(npcModel:GetDescendants()) do
        if desc:IsA("ProximityPrompt") then
            Impl.fireProximityPromptCompat(desc)
            prompted=true
            task.wait(0.15)
            break
        end
    end
    if not prompted then
        Impl.pressE()
        task.wait(0.15)
    end
    task.wait(0.2)
    return true
end

-- Props often stay on the map — do not rely on Instance removal. Use prompt state first, then
-- distance from HRP to prompt or to the dumped anchor (you should still be on spot after tween).
local SPECIAL_VERIFY_PROMPT_DISTANCE_SLACK_STUDS=14
local SPECIAL_VERIFY_ANCHOR_SUCCESS_RADIUS_STUDS=38

function Impl.verifySpecialCollectAfterFire(index,findPrompt,anchorWorldPos)
    for _s=1,18 do
        task.wait(0.08)
        local now=findPrompt(index)
        if now==nil then return true end
        if now.Parent==nil then return true end
        local okd,inside=pcall(function() return now:IsDescendantOf(workspace) end)
        if okd and not inside then return true end
        if now:IsA("ProximityPrompt") and not now.Enabled then return true end
    end
    local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local pp=findPrompt(index)
    if pp and pp:IsA("ProximityPrompt") then
        local mx=(pp.MaxActivationDistance and pp.MaxActivationDistance>0 and pp.MaxActivationDistance) or 10
        local wp=nil
        local pa=pp.Parent
        if pa and pa:IsA("Attachment") then
            wp=pa.WorldPosition
        elseif pa and pa:IsA("BasePart") then
            wp=pa.Position
        end
        if wp and (hrp.Position-wp).Magnitude<=mx+SPECIAL_VERIFY_PROMPT_DISTANCE_SLACK_STUDS then
            return true
        end
    end
    if anchorWorldPos then
        if (hrp.Position-anchorWorldPos).Magnitude<=SPECIAL_VERIFY_ANCHOR_SUCCESS_RADIUS_STUDS then
            return true
        end
    end
    return false
end

-- NPC-style offset first, then slide on XZ toward anchor (only Position from dump is used).
function Impl.tweenToSpecialCollect(worldCf)
    local anchor=worldCf.Position
    local p=anchor+Vector3.new(
        0,
        TWEEN_NPC_EXTRA_HEIGHT_STUDS+SPECIAL_COLLECT_EXTRA_Y_STUDS,
        3
    )
    local xz=Vector3.new(anchor.X-p.X,0,anchor.Z-p.Z)
    if xz.Magnitude>0.05 and SPECIAL_COLLECT_CLOSER_XZ_STUDS~=0 then
        p=p+xz.Unit*math.min(SPECIAL_COLLECT_CLOSER_XZ_STUDS,xz.Magnitude)
    end
    Impl.tweenToPosition(CFrame.new(p))
end

-- "collected" | "skipped" (no fragment in world) | "fail"
function Impl.collectHogyokuFragmentIndex(index)
    local fragmentCf=HOGYOKU_FRAGMENT_CF[index]
    if not fragmentCf then return "fail" end
    local fragName="HogyokuFragment"..tostring(index)
    for verifyTry=1,SPECIAL_COLLECT_VERIFY_ATTEMPTS do
        Impl.tweenToSpecialCollect(fragmentCf)
        task.wait(0.45)
        if workspace:FindFirstChild(fragName,true)==nil then
            return "skipped"
        end
        local pp=Impl.findHogyokuPrompt(index)
        if not pp then
            if verifyTry<SPECIAL_COLLECT_VERIFY_ATTEMPTS then task.wait(0.35) continue end
            warn("HogyokuFragment"..index.." or HogyokuCollectPrompt missing after tween.")
            return "fail"
        end
        Impl.firePromptRepeat(pp,6)
        if Impl.verifySpecialCollectAfterFire(index,findHogyokuPrompt,fragmentCf.Position) then
            return "collected"
        end
        if verifyTry<SPECIAL_COLLECT_VERIFY_ATTEMPTS then task.wait(0.4) end
    end
    return "fail"
end

function Impl.collectDemoniteCoreIndex(index)
    local coreCf=DEMONITE_CORE_CF[index]
    if not coreCf then return "fail" end
    local coreName="DemoniteCore"..tostring(index)
    for verifyTry=1,SPECIAL_COLLECT_VERIFY_ATTEMPTS do
        Impl.tweenToSpecialCollect(coreCf)
        task.wait(0.45)
        if workspace:FindFirstChild(coreName,true)==nil then
            return "skipped"
        end
        local pp=Impl.findDemonitePrompt(index)
        if not pp then
            if verifyTry<SPECIAL_COLLECT_VERIFY_ATTEMPTS then task.wait(0.35) continue end
            warn("DemoniteCore"..index.." or DemoniteCollectPrompt missing after tween.")
            return "fail"
        end
        Impl.firePromptRepeat(pp,6)
        if Impl.verifySpecialCollectAfterFire(index,findDemonitePrompt,coreCf.Position) then
            return "collected"
        end
        if verifyTry<SPECIAL_COLLECT_VERIFY_ATTEMPTS then task.wait(0.4) end
    end
    return "fail"
end

function Impl.runAutoHogyokuCollect()
    task.spawn(function()
        if isInteracting then
            Rayfield:Notify({Title="Busy",Content="Wait for the current action.",Duration=2})
            return
        end
        isInteracting=true
        floorHiding=false floorHidePivot=nil
        Rayfield:Notify({Title="Hogyoku",Content="Quest NPC → fragments",Duration=2})
        if not Impl.tweenAndAcceptNpcQuest("HogyokuQuestNPC") then
            Rayfield:Notify({Title="Hogyoku",Content="Quest NPC failed.",Duration=3})
            isInteracting=false
            return
        end
        Rayfield:Notify({Title="Hogyoku",Content="Fragments 1-6",Duration=2})
        local collected,skipped,failures=0,0,0
        for i=1,6 do
            if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then break end
            local st=Impl.collectHogyokuFragmentIndex(i)
            local text="retry"
            if st=="collected" then text="OK" collected=collected+1
            elseif st=="skipped" then text="skipped" skipped=skipped+1
            elseif st=="fail" then text="fail" failures=failures+1
            end
            Rayfield:Notify({Title="Hogyoku "..i.."/6",Content=text,Duration=1.8})
            task.wait(0.38)
        end
        isInteracting=false
        Rayfield:Notify({
            Title="Hogyoku done",
            Content=string.format("ok %d • skip %d • fail %d",collected,skipped,failures),
            Duration=3,
        })
    end)
end

function Impl.runAutoDemoniteCollect()
    task.spawn(function()
        if isInteracting then
            Rayfield:Notify({Title="Busy",Content="Wait for the current action.",Duration=2})
            return
        end
        isInteracting=true
        floorHiding=false floorHidePivot=nil
        Rayfield:Notify({Title="Demonite",Content="NPC quest (Academy portal)",Duration=2})
        Impl.teleportToIsland("Academy")
        task.wait(0.58)
        if not Impl.tweenAndAcceptNpcQuest("AnosQuestNPC") then
            Rayfield:Notify({Title="Demonite",Content="AnosQuestNPC failed — try manually.",Duration=3})
            isInteracting=false
            return
        end
        Rayfield:Notify({Title="Demonite",Content="Cores",Duration=2})
        local collected,skipped,failures=0,0,0
        for idx=1,2 do
            if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then break end
            local st=Impl.collectDemoniteCoreIndex(idx)
            local text=""
            if st=="collected" then text="OK" collected=collected+1
            elseif st=="skipped" then text="skipped" skipped=skipped+1
            elseif st=="fail" then text="fail" failures=failures+1
            end
            Rayfield:Notify({Title="Demonite "..idx.."/2",Content=text,Duration=1.8})
            task.wait(0.38)
        end
        isInteracting=false
        Rayfield:Notify({
            Title="Demonite done",
            Content=string.format("ok %d • skip %d • fail %d",collected,skipped,failures),
            Duration=3,
        })
    end)
end

-- =====================
--   FLOOR HIDE
-- =====================
function Impl.breakVelocity()
    local char=lp.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.AssemblyLinearVelocity=Vector3.zero
        hrp.AssemblyAngularVelocity=Vector3.zero
    end
end

local floorHidePivot=nil

coroutine.resume(coroutine.create(function()
    while RunService.Heartbeat:Wait() do
        if not floorHiding then continue end
        if isInteracting then continue end
        if floorHidePivot==nil then continue end
        local char=lp.Character
        if not char then continue end
        char:PivotTo(CFrame.new(
            floorHidePivot.Position-Vector3.yAxis*4,
            floorHidePivot.Position
        ))
        Impl.breakVelocity()
    end
end))

-- =====================
--   FIND NPC
-- =====================
function Impl.findNPCHRP(npcName)
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name==npcName then
            local hrp=obj:FindFirstChild("HumanoidRootPart")
                or obj:FindFirstChild("RootPart")
                or obj.PrimaryPart
            if hrp then return hrp end
            for _,part in ipairs(obj:GetDescendants()) do
                if part:IsA("BasePart") then return part end
            end
        end
    end
    return nil
end

-- =====================
--   SCANNER
-- =====================
function Impl.cleanText(t)
    if not t then return "?" end
    return t:gsub("<[^>]+>",""):match("^%s*(.-)%s*$")
end

function Impl.scanSkills()
    local skills={}
    local pg=lp:FindFirstChild("PlayerGui")
    if not pg then return skills end
    local cdUI=pg:FindFirstChild("CD Ability UI")
    if not cdUI then return skills end
    local spec=cdUI:FindFirstChild("SpecInfoFrame")
    if not spec then return skills end
    local sm=spec:FindFirstChild("SkillMainHolder")
    if not sm then return skills end
    for _,h in ipairs(sm:GetChildren()) do
        if h.Name=="SkillHolder" and h.Visible then
            local nl=h:FindFirstChild("SkillName")
            local kl=h:FindFirstChild("SkillKeybind")
            if nl and kl then
                local key=(kl.Text:match("%[(.-)%]") or kl.Text):match("^%s*(.-)%s*$")
                local raw=Impl.cleanText(nl.Text)
                local name=(raw:match("^(.-)%s*%-") or raw):match("^%s*(.-)%s*$")
                if key~="" then skills[#skills+1]={key=key,name=name} end
            end
        end
    end
    return skills
end

function Impl.scanTools()
    local tools={}
    local char=lp.Character
    if char then
        for _,t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then tools[#tools+1]={name=t.Name,equipped=true} end
        end
    end
    for _,t in ipairs(lp.Backpack:GetChildren()) do
        if t:IsA("Tool") then tools[#tools+1]={name=t.Name,equipped=false} end
    end
    return tools
end

function Impl.getHotbarSnapshot()
    local p={} local char=lp.Character
    if char then
        for _,t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then p[#p+1]="E:"..t.Name end
        end
    end
    for _,t in ipairs(lp.Backpack:GetChildren()) do p[#p+1]="B:"..t.Name end
    table.sort(p) return table.concat(p,",")
end

function Impl.getSkillSnapshot()
    local skills=Impl.scanSkills() local p={}
    for _,s in ipairs(skills) do p[#p+1]=s.key..":"..s.name end
    return table.concat(p,",")
end

task.spawn(function()
    while true do
        task.wait(1)
        local hs=Impl.getHotbarSnapshot()
        if hs~=lastHotbarSnapshot then lastHotbarSnapshot=hs currentTools=Impl.scanTools() end
        local ss=Impl.getSkillSnapshot()
        if ss~=lastSkillSnapshot then lastSkillSnapshot=ss currentSkills=Impl.scanSkills() end
    end
end)

task.spawn(function()
    while true do
        RunService.Heartbeat:Wait()
        if not autoSkillLoopRunning then continue end
        if not mobFarming and not bossFarming and not worldBossFarming and not autoQuestEnabled then continue end
        if isInteracting and not mobFarming and not bossFarming and not worldBossFarming then continue end
        local char=lp.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then continue end
        local now=tick()
        for key,enabled in pairs(autoSkillEnabled) do
            if not enabled then continue end
            local hasSkill=false
            for _,s in ipairs(currentSkills) do if s.key==key then hasSkill=true break end end
            if not hasSkill then continue end
            local cd=autoSkillCD[key] or 6
            local last=autoSkillLastUsed[key] or -999
            if now-last>=cd then
                autoSkillLastUsed[key]=now
                local kc=Enum.KeyCode[key]
                if kc then
                    task.spawn(function()
                        VIM:SendKeyEvent(true,kc,false,game)
                        task.wait(0.05)
                        VIM:SendKeyEvent(false,kc,false,game)
                    end)
                end
            end
        end
    end
end)

-- =====================
--   FARMING GUI
-- =====================
function Impl.createFarmingGUI()
    local existing=lp.PlayerGui:FindFirstChild("FarmingHub")
    if existing then existing:Destroy() end
    local sg=Instance.new("ScreenGui")
    sg.Name="FarmingHub" sg.ResetOnSpawn=false
    sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling sg.Parent=lp.PlayerGui
    local main=Instance.new("Frame")
    main.Size=UDim2.new(0,400,0,520) main.Position=UDim2.new(0.5,-200,0.5,-260)
    main.BackgroundColor3=Color3.fromRGB(22,22,32) main.BorderSizePixel=0
    main.Active=true main.Draggable=true main.Parent=sg
    Instance.new("UICorner",main).CornerRadius=UDim.new(0,12)
    local stroke=Instance.new("UIStroke",main)
    stroke.Color=Color3.fromRGB(80,80,140) stroke.Thickness=1.5
    local titleBar=Instance.new("Frame",main)
    titleBar.Size=UDim2.new(1,0,0,42) titleBar.BackgroundColor3=Color3.fromRGB(32,32,52)
    titleBar.BorderSizePixel=0 Instance.new("UICorner",titleBar).CornerRadius=UDim.new(0,12)
    local titleLbl=Instance.new("TextLabel",titleBar)
    titleLbl.Size=UDim2.new(1,-50,1,0) titleLbl.Position=UDim2.new(0,14,0,0)
    titleLbl.BackgroundTransparency=1 titleLbl.Text="⚔️  Farming Hub"
    titleLbl.TextColor3=Color3.fromRGB(255,255,255) titleLbl.TextSize=15
    titleLbl.Font=Enum.Font.GothamBold titleLbl.TextXAlignment=Enum.TextXAlignment.Left
    local closeBtn=Instance.new("TextButton",titleBar)
    closeBtn.Size=UDim2.new(0,28,0,28) closeBtn.Position=UDim2.new(1,-36,0.5,-14)
    closeBtn.BackgroundColor3=Color3.fromRGB(200,55,55) closeBtn.Text="✕"
    closeBtn.TextColor3=Color3.fromRGB(255,255,255) closeBtn.TextSize=13
    closeBtn.Font=Enum.Font.GothamBold closeBtn.BorderSizePixel=0
    Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,6)
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() farmingGUI=nil end)
    local scroll=Instance.new("ScrollingFrame",main)
    scroll.Size=UDim2.new(1,-12,1,-50) scroll.Position=UDim2.new(0,6,0,46)
    scroll.BackgroundTransparency=1 scroll.BorderSizePixel=0
    scroll.ScrollBarThickness=3 scroll.ScrollBarImageColor3=Color3.fromRGB(100,100,180)
    scroll.CanvasSize=UDim2.new(0,0,0,0) scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    local ll=Instance.new("UIListLayout",scroll) ll.Padding=UDim.new(0,5)
    local ps=Instance.new("UIPadding",scroll)
    ps.PaddingLeft=UDim.new(0,6) ps.PaddingRight=UDim.new(0,6) ps.PaddingTop=UDim.new(0,4)
    local function makeSection(txt)
        local f=Instance.new("Frame",scroll) f.Size=UDim2.new(1,0,0,26)
        f.BackgroundColor3=Color3.fromRGB(40,40,65) f.BorderSizePixel=0
        Instance.new("UICorner",f).CornerRadius=UDim.new(0,7)
        local l=Instance.new("TextLabel",f) l.Size=UDim2.new(1,-10,1,0)
        l.Position=UDim2.new(0,10,0,0) l.BackgroundTransparency=1 l.Text=txt
        l.TextColor3=Color3.fromRGB(170,170,255) l.TextSize=12 l.Font=Enum.Font.GothamBold
        l.TextXAlignment=Enum.TextXAlignment.Left return f
    end
    local function makeInfoLabel(txt)
        local l=Instance.new("TextLabel",scroll) l.Size=UDim2.new(1,0,0,18)
        l.BackgroundTransparency=1 l.Text=txt l.TextColor3=Color3.fromRGB(190,190,190)
        l.TextSize=11 l.Font=Enum.Font.Gotham l.TextXAlignment=Enum.TextXAlignment.Left
        return l
    end
    makeSection("  🗡️  Your Hotbar")
    local toolsInfoLbl=makeInfoLabel("Scanning...")
    makeSection("  Slot 1 — Primary Style  (Blue)")
    local slot1Lbl=makeInfoLabel("Selected: None")
    makeSection("  Slot 2 — Secondary Style  (Purple)")
    local slot2Lbl=makeInfoLabel("Selected: None")
    local toolGrid=Instance.new("Frame",scroll)
    toolGrid.Name="ToolGrid" toolGrid.Size=UDim2.new(1,0,0,10)
    toolGrid.BackgroundTransparency=1 toolGrid.AutomaticSize=Enum.AutomaticSize.Y
    local tgl=Instance.new("UIGridLayout",toolGrid)
    tgl.CellSize=UDim2.new(0.47,0,0,34) tgl.CellPadding=UDim2.new(0.04,0,0,4)
    makeSection("  ⚡  Current Skills  (auto-updates)")
    local skillsInfoLbl=makeInfoLabel("Scanning...")
    local skillFrame=Instance.new("Frame",scroll)
    skillFrame.Name="SkillFrame" skillFrame.Size=UDim2.new(1,0,0,10)
    skillFrame.BackgroundTransparency=1 skillFrame.AutomaticSize=Enum.AutomaticSize.Y
    Instance.new("UIListLayout",skillFrame).Padding=UDim.new(0,4)
    local function updateGUI()
        local tools=Impl.scanTools() currentTools=tools
        local tText=""
        for _,t in ipairs(tools) do tText=tText..(t.equipped and "★ " or "• ")..t.name.."  " end
        toolsInfoLbl.Text=tText~="" and tText or "No tools"
        slot1Lbl.Text="Selected: "..(selectedStyle1 or "None — click [1] below")
        slot2Lbl.Text="Selected: "..(selectedStyle2 or "None — click [2] below")
        for _,c in ipairs(toolGrid:GetChildren()) do
            if not c:IsA("UIGridLayout") then c:Destroy() end
        end
        for _,t in ipairs(tools) do
            local b1=Instance.new("TextButton",toolGrid)
            b1.BackgroundColor3=selectedStyle1==t.name and Color3.fromRGB(55,110,220) or Color3.fromRGB(40,40,60)
            b1.Text="[1] "..t.name..(t.equipped and " ★" or "")
            b1.TextColor3=Color3.fromRGB(255,255,255) b1.TextSize=11
            b1.Font=Enum.Font.Gotham b1.BorderSizePixel=0
            Instance.new("UICorner",b1).CornerRadius=UDim.new(0,6)
            b1.MouseButton1Click:Connect(function()
                selectedStyle1=(selectedStyle1==t.name) and nil or t.name updateGUI()
            end)
            local b2=Instance.new("TextButton",toolGrid)
            b2.BackgroundColor3=selectedStyle2==t.name and Color3.fromRGB(140,55,210) or Color3.fromRGB(40,40,60)
            b2.Text="[2] "..t.name..(t.equipped and " ★" or "")
            b2.TextColor3=Color3.fromRGB(255,255,255) b2.TextSize=11
            b2.Font=Enum.Font.Gotham b2.BorderSizePixel=0
            Instance.new("UICorner",b2).CornerRadius=UDim.new(0,6)
            b2.MouseButton1Click:Connect(function()
                selectedStyle2=(selectedStyle2==t.name) and nil or t.name updateGUI()
            end)
        end
        local skills=Impl.scanSkills() currentSkills=skills
        local sText=""
        for _,s in ipairs(skills) do sText=sText.."["..s.key.."] "..s.name.."  " end
        skillsInfoLbl.Text=sText~="" and sText or "No skills — equip a style"
        for _,c in ipairs(skillFrame:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        for _,s in ipairs(skills) do
            local isOn=selectedSkills[s.key] or false
            local row=Instance.new("TextButton",skillFrame)
            row.Size=UDim2.new(1,0,0,36)
            row.BackgroundColor3=isOn and Color3.fromRGB(45,140,75) or Color3.fromRGB(40,40,60)
            row.Text=(isOn and "✅" or "⬜").."  Auto ["..s.key.."]  —  "..s.name
            row.TextColor3=Color3.fromRGB(255,255,255) row.TextSize=12
            row.Font=Enum.Font.Gotham row.TextXAlignment=Enum.TextXAlignment.Left
            row.BorderSizePixel=0
            Instance.new("UICorner",row).CornerRadius=UDim.new(0,7)
            local rp=Instance.new("UIPadding",row) rp.PaddingLeft=UDim.new(0,10)
            local cdLbl=Instance.new("TextLabel",row)
            cdLbl.Size=UDim2.new(0,60,1,0) cdLbl.Position=UDim2.new(1,-65,0,0)
            cdLbl.BackgroundTransparency=1 cdLbl.Text="CD: "..(autoSkillCD[s.key] or 6).."s"
            cdLbl.TextColor3=Color3.fromRGB(180,180,180) cdLbl.TextSize=10
            cdLbl.Font=Enum.Font.Gotham cdLbl.TextXAlignment=Enum.TextXAlignment.Right
            row.MouseButton1Click:Connect(function()
                selectedSkills[s.key]=not (selectedSkills[s.key] or false)
                autoSkillEnabled[s.key]=selectedSkills[s.key]
                autoSkillLastUsed[s.key]=-999
                local anyOn=false
                for _,v in pairs(autoSkillEnabled) do if v then anyOn=true break end end
                autoSkillLoopRunning=anyOn updateGUI()
            end)
            row.MouseButton2Click:Connect(function()
                local presets={1,3,6,10,15,30}
                local current=autoSkillCD[s.key] or 6
                local next_cd=presets[1]
                for _,p in ipairs(presets) do if p>current then next_cd=p break end end
                autoSkillCD[s.key]=next_cd
                Rayfield:Notify({Title="["..s.key.."] CD set",Content=next_cd.."s",Duration=2})
                updateGUI()
            end)
        end
        if #skills>0 then
            local hint=Instance.new("TextLabel",skillFrame)
            hint.Size=UDim2.new(1,0,0,16) hint.BackgroundTransparency=1
            hint.Text="💡 Right-click skill to cycle CD: 1→3→6→10→15→30s"
            hint.TextColor3=Color3.fromRGB(130,130,130) hint.TextSize=10
            hint.Font=Enum.Font.Gotham hint.TextXAlignment=Enum.TextXAlignment.Left
        end
    end
    task.spawn(function()
        while sg.Parent~=nil do task.wait(1.5) if sg.Parent then updateGUI() end end
    end)
    updateGUI() farmingGUI=sg
end

-- =====================
--   CORE FUNCTIONS
-- =====================
function Impl.abandonQuest()
    local ok,err=pcall(function()
        local rs=game:GetService("ReplicatedStorage")
        local re=rs:WaitForChild("RemoteEvents",5)
        if not re then return end
        local qa=re:WaitForChild("QuestAbandon",5)
        if not qa then return end
        qa:FireServer("repeatable")
        hasActiveQuest=false
    end)
    if not ok then print("abandonQuest error: "..tostring(err)) end
    task.wait(0.3)
end

function Impl.clearTrackedConnections()
    for _,c in ipairs(trackedConnections) do c:Disconnect() end
    trackedConnections={}
end

function Impl.fullReset()
    mobFarming=false bossFarming=false worldBossFarming=false floorHiding=false floorHidePivot=nil
    isInteracting=false killCount=0 killCountReached=false
    hasActiveQuest=false forceQuestChange=false
    Impl.clearTrackedConnections()
end

function Impl.startKillTracking(mobPrefix)
    Impl.clearTrackedConnections()
    killCount=0 killCountReached=false currentQuestMobPrefix=mobPrefix
    local pattern="^"..mobPrefix.."%d*$"
    local function hookMob(obj)
        if not obj:IsA("Model") then return end
        if not obj.Name:match(pattern) then return end
        local hum=obj:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then return end
        local conn=hum.Died:Connect(function()
            if not autoQuestEnabled then return end
            if killCountReached then return end
            if killCount>=requiredKills then killCountReached=true return end
            killCount=killCount+1
            Rayfield:Notify({Title="Kill "..killCount.."/"..requiredKills,Content=currentQuestMobPrefix,Duration=1})
            if killCount>=requiredKills then killCountReached=true end
        end)
        table.insert(trackedConnections,conn)
    end
    for _,obj in ipairs(workspace:GetDescendants()) do hookMob(obj) end
    local sc=workspace.DescendantAdded:Connect(function(obj) task.wait(0.1) hookMob(obj) end)
    table.insert(trackedConnections,sc)
end

function Impl.findByPrefix(prefix)
    local found={} local pattern="^"..prefix.."%d*$"
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:match(pattern) then
            local hum=obj:FindFirstChildOfClass("Humanoid")
            local hrp=obj:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health>0 and hrp then found[#found+1]={hum=hum,hrp=hrp} end
        end
    end
    return found
end

function Impl.findByContains(nameToken)
    local found={}
    local token=(nameToken or ""):lower()
    if token=="" then return found end
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Name:lower():find(token,1,true) then
            local hum=obj:FindFirstChildOfClass("Humanoid")
            local hrp=obj:FindFirstChild("HumanoidRootPart")
                or obj:FindFirstChild("RootPart")
                or obj.PrimaryPart
            if hum and hum.Health>0 and hrp and hrp:IsA("BasePart") then
                found[#found+1]={hum=hum,hrp=hrp}
            end
        end
    end
    return found
end

function Impl.getNearest(targets,pos)
    local nearest,best=nil,math.huge
    for _,t in ipairs(targets) do
        if t.hum.Health>0 then
            local d=(pos-t.hrp.Position).Magnitude
            if d<best then nearest=t best=d end
        end
    end
    return nearest
end

function Impl.equipTool(toolName)
    local char=lp.Character if not char then return end
    local hum=char:FindFirstChildOfClass("Humanoid") if not hum then return end
    for _,t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and t.Name==toolName then return end
    end
    local bp=lp:FindFirstChild("Backpack")
    if bp then
        for _,t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t.Name==toolName then hum:EquipTool(t) task.wait(0.1) return end
        end
    end
end

function Impl.equipCombat()
    local char=lp.Character if not char then return end
    for _,t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():find("combat") then return end
    end
    local bp=lp:FindFirstChild("Backpack")
    if bp then
        for _,t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find("combat") then
                char.Humanoid:EquipTool(t) task.wait(0.1) return
            end
        end
    end
end

-- Для авто-квестов/фарма: Combat в руке заменяет меч → сначала пробуем меч, затем базовый стиль только если меч не экипнулся.
function Impl.equipFarmingLoadout()
    Impl.equipBestOwnedSword()
    if Impl.characterHasSwordEquipped(1) then return end
    Impl.equipCombat()
end

function Impl.stopFly()
    flying=false
    if flyConnection then flyConnection:Disconnect() flyConnection=nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity=nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro=nil end
    local char=lp.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand=false end
end

function Impl.stopAll()
    autoMobQuestEnabled=false autoBossQuestEnabled=false autoQuestEnabled=false
    autoWorldBossEnabled=false worldBossFarming=false
    antiAfkRunning=false autoStyleSwitch=false
    Impl.fullReset() Impl.stopFly()
    local char=lp.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed=16 end
end

function Impl.pressM1()
    VIM:SendMouseButtonEvent(0,0,0,true,game,1)
    VIM:SendMouseButtonEvent(0,0,0,false,game,1)
end

function Impl.vimKeyE(pressed)
    pcall(function() VIM:SendKeyEvent(pressed,Enum.KeyCode.E,false,game) end)
    pcall(function() VIM:SendKeyEvent(pressed,Enum.KeyCode.E,false) end)
end

function Impl.pressE()
    Impl.vimKeyE(true)
    task.wait(0.1)
    Impl.vimKeyE(false)
end

-- acceptQuest: same flow as classic hub — first ProximityPrompt once, else single E
function Impl.acceptQuest()
    if isInteracting then return false end
    isInteracting=true floorHiding=false floorHidePivot=nil
    task.wait(0.2)
    local char=lp.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 then isInteracting=false return false end
    local island=islandMap[selectedQuestNPC]
    if island then
        Impl.teleportToIsland(island)
        task.wait(0.5)
        local found=Impl.tweenToQuestNPCSimple(selectedQuestNPC)
        if not found then isInteracting=false return false end
    end
    task.wait(0.1)
    char=lp.Character
    hum=char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 then isInteracting=false return false end
    local npcHRP=Impl.findNPCHRP(selectedQuestNPC)
    if not npcHRP then isInteracting=false return false end
    local npcModel=npcHRP.Parent
    local prompted=false
    if npcModel then
        for _,desc in ipairs(npcModel:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                Impl.fireProximityPromptCompat(desc)
                prompted=true
                task.wait(0.15)
                break
            end
        end
    end
    if not prompted then Impl.pressE() task.wait(0.15) end
    task.wait(0.2)
    hasActiveQuest=true
    isInteracting=false
    return true
end

-- ========== AUTO PROGRESS (mob quest ladder + buys + stats) ==========
local MOB_QUEST_LADDER={
    {"QuestNPC1",0},
    {"QuestNPC3",250},
    {"QuestNPC5",750},
    {"QuestNPC7",1500},
    {"QuestNPC9",3000},
    {"QuestNPC11",5000},
    {"QuestNPC12",6250},
    {"QuestNPC13",7000},
    {"QuestNPC14",8000},
    {"QuestNPC15",9000},
    {"QuestNPC16",10000},
    {"QuestNPC17",10750},
    {"QuestNPC18",11500},
    {"QuestNPC19",12000},
}

function Impl.parseNumberLoose(s)
    if not s or s=="" then return nil end
    local t=s:gsub(",",""):gsub("%s","")
    local lower=string.lower(t)
    -- "Lv. 110" / "Level: 1,234" — иначе [%d%.]+ ловит ".110" и tonumber ломается
    local stripped=lower:gsub("^[^%d]*","")
    if stripped=="" then stripped=lower end
    local mult=1
    if stripped:match("k$") then mult=1000 stripped=stripped:gsub("k$","") end
    if stripped:match("m$") then mult=1000000 stripped=stripped:gsub("m$","") end
    local chunk=stripped:match("^[%d%.]+") or stripped:match("[%d%.]+")
    local num=chunk and tonumber(chunk) or nil
    if not num then return nil end
    return math.floor(num*mult+0.5)
end

function Impl.readMoneyGemsHud()
    local pg=lp:FindFirstChild("PlayerGui")
    if not pg then return nil,nil end
    local root=pg:FindFirstChild("BasicStatsCurrencyAndButtonsUI",true)
    if not root then return nil,nil end
    local mf=root:FindFirstChild("MainFrame",true)
    if not mf then mf=root end
    local mgf=mf and mf:FindFirstChild("MoneyAndGemsFrame",true)
    if not mgf then return nil,nil end
    local coins,gems=nil,nil
    local moneyFrame=mgf:FindFirstChild("MoneyFrame",true)
    if moneyFrame then
        local ind=moneyFrame:FindFirstChild("MoneyIndicator",true)
        local cur=ind and ind:FindFirstChild("CurrencyIndicator",true)
        if cur and cur:IsA("GuiObject") then coins=Impl.parseNumberLoose(cur.Text) end
    end
    local gemsFrame=mgf:FindFirstChild("GemsFrame",true)
    if gemsFrame then
        local ind=gemsFrame:FindFirstChild("GemsIndicator",true)
        local cur=ind and ind:FindFirstChild("CurrencyIndicator",true)
        if cur and cur:IsA("GuiObject") then gems=Impl.parseNumberLoose(cur.Text) end
    end
    return coins,gems
end

function Impl.readMoneyGemsFromLeaderstats()
    local ls=lp:FindFirstChild("leaderstats")
    if not ls then return nil,nil end
    local coins,gems=nil,nil
    local function takeVal(inst)
        if not inst then return nil end
        if inst:IsA("IntValue") or inst:IsA("NumberValue") or inst:IsA("DoubleConstrainedValue") then
            return tonumber(inst.Value)
        end
        if inst:IsA("StringValue") then return tonumber(inst.Value) end
        return nil
    end
    for _,nm in ipairs({"Coins","Gold","Money","Cash","Yen","Berries","Coin"}) do
        local v=ls:FindFirstChild(nm)
        local n=takeVal(v)
        if n then coins=math.floor(n) break end
    end
    for _,nm in ipairs({"Gems","Gem","Crystals","Crystal"}) do
        local v=ls:FindFirstChild(nm)
        local n=takeVal(v)
        if n then gems=math.floor(n) break end
    end
    for _,ch in ipairs(ls:GetChildren()) do
        local ln=string.lower(ch.Name)
        if coins==nil and (string.find(ln,"coin",1,true) or string.find(ln,"gold",1,true) or string.find(ln,"money",1,true) or ln=="cash") then
            local n=takeVal(ch)
            if n then coins=math.floor(n) end
        end
        if gems==nil and string.find(ln,"gem",1,true) then
            local n=takeVal(ch)
            if n then gems=math.floor(n) end
        end
    end
    return coins,gems
end

function Impl.readMoneyGemsForAutoBuy()
    local cHud,gHud=Impl.readMoneyGemsHud()
    local cLs,gLs=Impl.readMoneyGemsFromLeaderstats()
    local coins=cHud~=nil and cHud or cLs
    local gems=gHud~=nil and gHud or gLs
    if gems==nil then gems=0 end
    return coins,gems
end

function Impl.readLevelFromHud()
    local pg=lp:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local best=nil
    local function takeLevelNumber(n)
        if n and n>=1 and n<=1e9 then
            if not best or n>best then best=math.floor(n) end
        end
    end
    local function takeLabelText(raw)
        local n=Impl.parseNumberLoose(raw)
        takeLevelNumber(n)
    end
    local roots={}
    local r1=pg:FindFirstChild("BasicStatsCurrencyAndButtonsUI",true)
    if r1 then roots[#roots+1]=r1 end
    local r2=pg:FindFirstChild("HUD New",true) or pg:FindFirstChild("HUDNew",true)
    if r2 then roots[#roots+1]=r2 end
    for _,root in ipairs(roots) do
        local mf=root:FindFirstChild("MainFrame",true)
        local li=(mf and mf:FindFirstChild("LevelInfo",true)) or root:FindFirstChild("LevelInfo",true)
        if li then
            local lvDirect=li:FindFirstChild("Level",true)
            if lvDirect and (lvDirect:IsA("TextLabel") or lvDirect:IsA("TextButton")) then
                takeLabelText(lvDirect.Text)
            end
            for _,d in ipairs(li:GetDescendants()) do
                if d:IsA("TextLabel") or d:IsA("TextButton") then takeLabelText(d.Text) end
            end
        end
    end
    if not best then
        local root=roots[1]
        if not root then return nil end
        -- pattern mode: Lv/Lvl/Level + digits
        for _,d in ipairs(root:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                local raw=d.Text or ""
                local low=string.lower(raw)
                local use=false
                if string.find(low,"level",1,true) or string.find(low,"lvl",1,true) then use=true end
                if not use then
                    if string.match(low,"^%s*lv[l%.]?%s*%d")
                        or string.match(low,"lvl%s*%d")
                        or string.match(raw,"[Ll][Vv]%.?%s*%d") then
                        use=true
                    end
                end
                if use then
                    local m=string.match(raw,"[Ll][Vv][Ll]?%.?%s*:?%s*([%d,]+[%d%.]*[kKmM]?)")
                        or string.match(raw,"[Ll][Ee][Vv][Ee][Ll]%.?%s*:?%s*([%d,]+[%d%.]*[kKmM]?)")
                    if m then takeLevelNumber(Impl.parseNumberLoose(m)) else takeLabelText(raw) end
                end
            end
        end
    end
    return best
end

-- Грубый поиск по всему PlayerGui (если путь к BasicStats сменился).
function Impl.readLevelFromPlayerGuiDeepScan()
    local pg=lp:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local best=nil
    local scanned=0
    local maxScan=3500
    local function consider(raw,parentName)
        if not raw or raw=="" then return end
        local low=string.lower(raw)
        if string.find(low,"gem",1,true) or string.find(low,"coin",1,true) or string.find(low,"money",1,true) then return end
        local hint=false
        local pl=parentName and string.lower(parentName) or ""
        if string.find(pl,"level",1,true) or string.find(pl,"lvl",1,true) or string.find(pl,"rank",1,true) then hint=true end
        if string.find(low,"level",1,true) or string.find(low,"lvl",1,true) or string.match(low,"^%s*lv%.?%s*%d") then hint=true end
        if not hint and not string.match(low,"^%s*[%d,]+%s*$") then return end
        local n=Impl.parseNumberLoose(raw)
        if n and n>=1 and n<=1e9 then
            if not best or n>best then best=math.floor(n) end
        end
    end
    for _,d in ipairs(pg:GetDescendants()) do
        scanned=scanned+1
        if scanned>maxScan then break end
        if d:IsA("TextLabel") or d:IsA("TextButton") then
            local p=d.Parent and d.Parent.Name or ""
            consider(d.Text,p)
        end
    end
    return best
end

function Impl.readLevelFromLeaderstats()
    local ls=lp:FindFirstChild("leaderstats")
    if not ls then
        pcall(function()
            ls=lp:WaitForChild("leaderstats",0.35)
        end)
    end
    if not ls then return nil end
    local function valNumber(v)
        if not v then return nil end
        local ok,val=pcall(function() return v.Value end)
        if not ok then return nil end
        return tonumber(val)
    end
    local tryNames={"Level","Lvl","LV","Lv","LEVEL","LevelValue","CombatLevel","PlayerLevel","rank","Rank"}
    for _,nm in ipairs(tryNames) do
        local v=ls:FindFirstChild(nm)
        if v and (v:IsA("IntValue") or v:IsA("NumberValue") or v:IsA("StringValue") or v:IsA("DoubleConstrainedValue")) then
            local n=valNumber(v)
            if n and n>=1 and n<=1e9 then return math.floor(n) end
        end
    end
    for _,ch in ipairs(ls:GetChildren()) do
        if ch:IsA("IntValue") or ch:IsA("NumberValue") or ch:IsA("DoubleConstrainedValue") or ch:IsA("StringValue") then
            local ln=string.lower(ch.Name)
            if string.find(ln,"level",1,true) or ln=="lvl" or ln=="lv" or string.find(ln,"rank",1,true) then
                local n=valNumber(ch)
                if n and n>=1 and n<=1e9 then return math.floor(n) end
            end
        end
    end
    return nil
end

function Impl.readLevelForAutoProgress()
    local a=lp:GetAttribute("Level")
    if typeof(a)=="number" and a>=1 and a<=1e9 then return math.floor(a) end
    if typeof(a)=="string" then
        local n=tonumber(a)
        if n and n>=1 and n<=1e9 then return math.floor(n) end
    end
    return Impl.readLevelFromHud()
        or Impl.readLevelFromLeaderstats()
        or Impl.readLevelFromPlayerGuiDeepScan()
end

function Impl.swordTierFromUiName(name)
    if not name or name=="" then return 0 end
    local low=string.lower(name)
    if string.find(low,"gryphon",1,true) then return 3 end
    if string.find(low,"dark blade",1,true) or string.find(low,"darkblade",1,true) then return 2 end
    if string.find(low,"katana",1,true) then return 1 end
    if string.find(low,"dark",1,true) and string.find(low,"blade",1,true) then return 2 end
    -- Starter / shop naming that does not include "katana"
    if string.find(low,"wooden",1,true) and string.find(low,"sword",1,true) then return 1 end
    if string.find(low,"starter",1,true) and string.find(low,"sword",1,true) then return 1 end
    if string.find(low,"broken",1,true) then return 0 end
    if string.find(low,"sword",1,true) then return 1 end
    if string.find(low,"cutlass",1,true) or string.find(low,"saber",1,true)
        or string.find(low,"sabre",1,true) or string.find(low,"scimitar",1,true)
        or string.find(low,"rapier",1,true) or string.find(low,"katana+",1,true)
        or string.find(low,"nodachi",1,true) then return 1 end
    if string.find(low,"blade",1,true) then return 1 end
    return 0
end

-- По экземпляру Tool: имя + теги игры (часто название без Katana/Gryphon).
function Impl.toolSwordTier(tool)
    if not tool or not tool:IsA("Tool") then return 0 end
    local tr=Impl.swordTierFromUiName(tool.Name)
    if tr>0 then return tr end
    pcall(function()
        local wt=tostring(tool:GetAttribute("WeaponType") or ""):lower()
        if wt:find("sword",1,true) or wt:find("blade",1,true) then tr=math.max(tr,1) end
        if tool:GetAttribute("IsSword") or tool:GetAttribute("SwordTier")~=nil or tool:GetAttribute("Weapon")==true then
            tr=math.max(tr,1)
        end
        if CollectionService:HasTag(tool,"Sword") or CollectionService:HasTag(tool,"Weapon")
            or CollectionService:HasTag(tool,"Melee") or CollectionService:HasTag(tool,"MeleeWeapon")
            or CollectionService:HasTag(tool,"Bladed") then
            tr=math.max(tr,1)
        end
    end)
    local st=tool:GetAttribute("SwordTier")
    if type(st)=="number" and st>=1 then tr=math.max(tr,math.floor(st))
    elseif type(st)=="string" then
        local n=tonumber(st)
        if n and n>=1 then tr=math.max(tr,math.floor(n)) end
    end
    return tr
end

function Impl.getInventoryPanelStorage()
    local pg=lp:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local inv=pg:FindFirstChild("InventoryPanelUI") or pg:FindFirstChild("InventoryPanelUI",true)
    if not inv then return nil end
    local mf=inv:FindFirstChild("MainFrame") or inv:FindFirstChild("MainFrame",true)
    local fr=mf and (mf:FindFirstChild("Frame") or mf:FindFirstChild("Frame",true))
    local content=fr and (fr:FindFirstChild("Content") or fr:FindFirstChild("Content",true))
    local holder=content and (content:FindFirstChild("Holder") or content:FindFirstChild("Holder",true))
    local sh=holder and (holder:FindFirstChild("StorageHolder") or holder:FindFirstChild("StorageHolder",true))
    local storage=sh and (sh:FindFirstChild("Storage") or sh:FindFirstChild("Storage",true))
    if storage then return storage end
    return inv:FindFirstChild("Storage",true)
end

function Impl.scanInventoryStorageForSwordTier(storage,best)
    if not storage then return best end
    for _,ch in ipairs(storage:GetChildren()) do
        if string.sub(ch.Name,1,5)~="Item_" then continue end
        local t=Impl.swordTierFromUiName(ch.Name)
        if t>0 then best=math.max(best,t) end
        for _,d in ipairs(ch:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                local tt=Impl.swordTierFromUiName(d.Text)
                if tt>0 then best=math.max(best,tt) end
            end
        end
    end
    return best
end

function Impl.getOwnedSwordTier()
    local best=0
    local function scanTools(container)
        if not container then return end
        local function walk(inst)
            for _,t in ipairs(inst:GetChildren()) do
                if t:IsA("Tool") then
                    local tr=Impl.toolSwordTier(t)
                    if tr>0 then best=math.max(best,tr) end
                elseif t:IsA("Folder") or t:IsA("Model") then
                    walk(t)
                end
            end
        end
        walk(container)
    end
    scanTools(lp:FindFirstChild("Backpack"))
    scanTools(lp.Character)
    scanTools(lp:FindFirstChild("StarterGear"))
    best=Impl.scanInventoryStorageForSwordTier(Impl.getInventoryPanelStorage(),best)
    return best
end

function Impl.resolveChildChain(root,segments)
    local cur=root
    for _,seg in ipairs(segments) do
        cur=cur and cur:FindFirstChild(seg)
    end
    return cur
end

function Impl.debugSwordEquipSnapshot(tag)
    if not DEBUG_SWORD_EQUIP then return end
    print("[SailorHub SwordDebug] ---------- "..tostring(tag).." ----------")
    print("[SailorHub SwordDebug] PlaceId="..tostring(game.PlaceId))
    local r=Impl.getSwordEquipRemote()
    print("[SailorHub SwordDebug] EquipWeapon="..(r and r:GetFullName() or "nil"))
    print("[SailorHub SwordDebug] Impl.getOwnedSwordTier()="..tostring(Impl.getOwnedSwordTier()))
    local function dumpTools(where,container)
        if not container then
            print("[SailorHub SwordDebug] "..where..": (no container)")
            return
        end
        local n=0
        local function walk(inst)
            for _,ch in ipairs(inst:GetChildren()) do
                if ch:IsA("Tool") then
                    n=n+1
                    local par=ch.Parent and ch.Parent.Name or "?"
                    print("[SailorHub SwordDebug]   Tool["..where.."] name="..ch.Name.." tier="..tostring(Impl.toolSwordTier(ch)).." parent="..par)
                elseif ch:IsA("Folder") or ch:IsA("Model") then
                    walk(ch)
                end
            end
        end
        walk(container)
        if n==0 then print("[SailorHub SwordDebug]   (no Tool instances under "..where..")") end
    end
    dumpTools("Backpack",lp:FindFirstChild("Backpack"))
    local ch=lp.Character
    if ch then
        print("[SailorHub SwordDebug] Character tools:")
        for _,t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") then
                print("[SailorHub SwordDebug]   onChar name="..t.Name.." tier="..tostring(Impl.toolSwordTier(t)))
            end
        end
    else
        print("[SailorHub SwordDebug] Character=nil")
    end
    print("[SailorHub SwordDebug] ---------- end ----------")
end

function Impl.getSwordEquipRemote()
    if type(SWORD_EQUIP_REMOTE_PATH)=="table" then
        local r=Impl.resolveChildChain(game,SWORD_EQUIP_REMOTE_PATH)
        if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then return r end
    end
    local rs=game:GetService("ReplicatedStorage")
    local r=nil
    pcall(function()
        local rem=rs:FindFirstChild("Remotes")
        if rem then
            r=rem:FindFirstChild("EquipWeapon")
        end
    end)
    if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then return r end
    r=rs:FindFirstChild("EquipWeapon",true)
    if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then return r end
    return nil
end

-- Sailor-style: "Combat" через ремоут; мечи часто требуют несколько вызовов EquipWeapon + клиентский EquipTool + UpdateEquipped (см. Remotes.UpdateEquipped в игре).
function Impl.tryEquipCombatViaRemote()
    local r=Impl.getSwordEquipRemote()
    if not r then return end
    pcall(function()
        if r:IsA("RemoteEvent") then r:FireServer("Equip","Combat")
        elseif r:IsA("RemoteFunction") then r:InvokeServer("Equip","Combat") end
    end)
end

function Impl.tryAuxWeaponRemotesAfterEquip(tool)
    pcall(function()
        local rem=game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        if not rem then return end
        local u=rem:FindFirstChild("UpdateEquipped")
        if u and u:IsA("RemoteEvent") then
            u:FireServer()
            if tool then u:FireServer(tool.Name) end
        end
    end)
end

-- У части сборок Sword экипается только после UseItem / аналога.
function Impl.tryUseItemRemoteForTool(tool)
    if not tool then return end
    pcall(function()
        local rs=game:GetService("ReplicatedStorage")
        local rem=rs:FindFirstChild("Remotes")
        for _,nm in ipairs({"UseItem","ItemUse","UseTool","EquipItem"}) do
            local ev=rem and rem:FindFirstChild(nm)
            if not ev then ev=rs:FindFirstChild(nm,true) end
            if ev and ev:IsA("RemoteEvent") then
                ev:FireServer("Equip",tool.Name)
                ev:FireServer("Use",tool.Name)
                ev:FireServer(tool)
                ev:FireServer(tool.Name)
            elseif ev and ev:IsA("RemoteFunction") then
                ev:InvokeServer(tool)
                ev:InvokeServer(tool.Name)
            end
        end
    end)
end

function Impl.tryForceWeaponCleanupRemote()
    pcall(function()
        local rem=game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        local fc=rem and rem:FindFirstChild("ForceWeaponCleanup")
        if fc and fc:IsA("RemoteEvent") then fc:FireServer() end
    end)
end

function Impl.trySwordEquipRemote(tool)
    if not tool then return end
    local r=Impl.getSwordEquipRemote()
    if not r then return end
    local nm=tool.Name
    local function one(fn)
        pcall(fn)
    end
    one(function()
        if r:IsA("RemoteEvent") then r:FireServer("Equip",nm)
        elseif r:IsA("RemoteFunction") then r:InvokeServer("Equip",nm) end
    end)
    one(function()
        if r:IsA("RemoteEvent") then r:FireServer(nm)
        elseif r:IsA("RemoteFunction") then r:InvokeServer(nm) end
    end)
    one(function()
        if r:IsA("RemoteEvent") then r:FireServer("EquipTool",nm)
        elseif r:IsA("RemoteFunction") then r:InvokeServer("EquipTool",nm) end
    end)
    one(function()
        if r:IsA("RemoteEvent") then r:FireServer("Equip",tool)
        elseif r:IsA("RemoteFunction") then r:InvokeServer("Equip",tool) end
    end)
    one(function()
        if r:IsA("RemoteEvent") then r:FireServer("EquipTool",tool)
        elseif r:IsA("RemoteFunction") then r:InvokeServer("EquipTool",tool) end
    end)
end

function Impl.moveSwordToolToBackpack(tool)
    local bp=lp:FindFirstChild("Backpack")
    if not tool or not bp then return end
    if tool.Parent==bp then return end
    pcall(function() tool.Parent=bp end)
    task.wait(0.06)
end

function Impl.resetHandsForSwordEquip()
    local char=lp.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    Impl.tryEquipCombatViaRemote()
    task.wait(0.18)
    pcall(function() hum:UnequipTools() end)
    task.wait(0.1)
end

-- Сначала без сброса рук; агрессивные фазы (Cleanup / Combat+Unequip) только при options.aggressive~=false
-- Периодический auto progress вызывает с aggressive=false, чтобы не снимать меч с рук игрока.
function Impl.applySwordEquipPhases(tool,wantTierMin,options)
    wantTierMin=wantTierMin or 1
    options=options or {}
    local aggressive=options.aggressive~=false
    if not tool then return false end
    local function pulse()
        local char=lp.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then return false end
        Impl.moveSwordToolToBackpack(tool)
        hum=char:FindFirstChildOfClass("Humanoid")
        if not hum then return false end
        for _=1,3 do
            Impl.tryUseItemRemoteForTool(tool)
            task.wait(0.07)
        end
        for _=1,4 do
            Impl.trySwordEquipRemote(tool)
            task.wait(0.055)
        end
        hum=char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then return false end
        pcall(function() hum:EquipTool(tool) end)
        task.wait(0.14)
        Impl.tryUseItemRemoteForTool(tool)
        Impl.tryAuxWeaponRemotesAfterEquip(tool)
        Impl.trySwordEquipRemote(tool)
        task.wait(0.1)
        return Impl.characterHasSwordEquipped(wantTierMin)
    end
    if pulse() then return true end
    if not aggressive then return false end
    Impl.tryForceWeaponCleanupRemote()
    task.wait(0.15)
    if pulse() then return true end
    Impl.resetHandsForSwordEquip()
    task.wait(0.12)
    if pulse() then return true end
    return false
end

function Impl.collectSwordToolsFromBackpack()
    local bp=lp:FindFirstChild("Backpack")
    if not bp then return {} end
    local rows={}
    local function walk(inst)
        for _,t in ipairs(inst:GetChildren()) do
            if t:IsA("Tool") then
                local tr=Impl.toolSwordTier(t)
                if tr>0 then rows[#rows+1]={tool=t,tier=tr} end
            elseif t:IsA("Folder") or t:IsA("Model") then
                walk(t)
            end
        end
    end
    walk(bp)
    local sg=lp:FindFirstChild("StarterGear")
    if sg then walk(sg) end
    table.sort(rows,function(a,b) return a.tier>b.tier end)
    return rows
end

-- Лучший меч среди персонажа + рюкзака (только BP ломало ручной экип: в руках топ, в BP слабее — скрипт снимал всё).
function Impl.equipBestOwnedSword()
    local char=lp.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 then return end
    local bp=lp:FindFirstChild("Backpack")
    local best,bestTier=nil,0
    local function considerTool(t)
        if not t or not t:IsA("Tool") then return end
        local tr=Impl.toolSwordTier(t)
        if tr>bestTier then bestTier,best=tr,t end
    end
    local function scanBp(inst)
        if not inst then return end
        for _,t in ipairs(inst:GetChildren()) do
            if t:IsA("Tool") then considerTool(t)
            elseif t:IsA("Folder") or t:IsA("Model") then scanBp(t) end
        end
    end
    for _,t in ipairs(char:GetChildren()) do considerTool(t) end
    scanBp(bp)
    local sg=lp:FindFirstChild("StarterGear")
    if sg then scanBp(sg) end
    if not best or bestTier<=0 then return end
    if best.Parent==char then return end
    local equippedBest=0
    for _,t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then equippedBest=math.max(equippedBest,Impl.toolSwordTier(t)) end
    end
    if bestTier<=equippedBest and equippedBest>=1 then return end
    Impl.applySwordEquipPhases(best,1)
end

function Impl.characterHasSwordEquipped(minTier)
    local char=lp.Character
    if not char then return false end
    for _,t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then
            local tr=Impl.toolSwordTier(t)
            if tr>=minTier then return true end
        end
    end
    return false
end

function Impl.equipSwordUntilEquippedOrTimeout(wantTier)
    wantTier=wantTier or 1
    Impl.debugSwordEquipSnapshot("equip start wantTier="..tostring(wantTier))
    task.wait(0.08)
    for pass=1,22 do
        local rows=Impl.collectSwordToolsFromBackpack()
        local char=lp.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health>0 then
            for _,row in ipairs(rows) do
                if row.tier>=wantTier then
                    Impl.applySwordEquipPhases(row.tool,wantTier)
                    if Impl.characterHasSwordEquipped(wantTier) then return end
                end
            end
            Impl.equipBestOwnedSword()
        end
        task.wait(0.25)
        if Impl.characterHasSwordEquipped(wantTier) then return end
    end
    Impl.debugSwordEquipSnapshot("TIMEOUT still not equipped wantTier="..tostring(wantTier))
end

-- QuestNPC17 (Quincy / Soul Dominion island) is skipped — ladder jumps 16 → 18 when Lv allows.
function Impl.pickMobQuestForLevel(lv)
    local best=nil
    for _,row in ipairs(MOB_QUEST_LADDER) do
        local name,minLv=row[1],row[2]
        if lv>=minLv then
            if name=="QuestNPC17" then
                continue
            else
                best=name
            end
        end
    end
    return best or "QuestNPC1"
end

function Impl.holdKeyE(seconds)
    Impl.vimKeyE(true)
    task.wait(seconds or 2)
    Impl.vimKeyE(false)
end

function Impl.clickGuiCenter(gui)
    if not gui or not gui:IsA("GuiObject") then return end
    local absPos=gui.AbsolutePosition
    local absSize=gui.AbsoluteSize
    local x=absPos.X+absSize.X*0.5
    local y=absPos.Y+absSize.Y*0.5+GuiService:GetGuiInset().Y
    pcall(function()
        VIM:SendMouseButtonEvent(x,y,0,true,game,1)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(x,y,0,false,game,1)
    end)
end

function Impl.getStatsPanelContentFrame()
    local pg=lp:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local sp=pg:FindFirstChild("StatsPanelUI") or pg:FindFirstChild("StatsPanelUI",true)
    if not sp then return nil end
    local mf=sp:FindFirstChild("MainFrame") or sp:FindFirstChild("MainFrame",true)
    if mf then
        local fr=mf:FindFirstChild("Frame") or mf:FindFirstChild("Frame",true)
        local content=fr and (fr:FindFirstChild("Content") or fr:FindFirstChild("Content",true))
        if content then return content end
    end
    return sp:FindFirstChild("Content",true)
end

function Impl.getStatPointsLabel()
    local content=Impl.getStatsPanelContentFrame()
    if content then
        local info=content:FindFirstChild("InfoFrame") or content:FindFirstChild("InfoFrame",true)
        if info then
            local p=info:FindFirstChild("PointsAmount") or info:FindFirstChild("PointsAmount",true)
            if p then return p end
        end
    end
    local pg=lp:FindFirstChild("PlayerGui")
    local sp=pg and pg:FindFirstChild("StatsPanelUI",true)
    return sp and sp:FindFirstChild("PointsAmount",true)
end

function Impl.getStatHolderFrame()
    local content=Impl.getStatsPanelContentFrame()
    if content then
        local sf=content:FindFirstChild("StatsFrame") or content:FindFirstChild("StatsFrame",true)
        local holder=sf and (sf:FindFirstChild("Holder") or sf:FindFirstChild("Holder",true))
        if holder then return holder end
    end
    local pg=lp:FindFirstChild("PlayerGui")
    local sp=pg and pg:FindFirstChild("StatsPanelUI",true)
    return sp and sp:FindFirstChild("Holder",true)
end

function Impl.getStatAddButton(statFrameName,altNames)
    local holder=Impl.getStatHolderFrame()
    if not holder then return nil end
    local names={statFrameName}
    if altNames then for _,n in ipairs(altNames) do names[#names+1]=n end end
    local fr=nil
    for _,nm in ipairs(names) do
        fr=holder:FindFirstChild(nm) or holder:FindFirstChild(nm,true)
        if fr then break end
    end
    if not fr then return nil end
    local fc=fr:FindFirstChild("Content") or fr:FindFirstChild("Content",true)
    local upg=fc and (fc:FindFirstChild("UpgradeFrame") or fc:FindFirstChild("UpgradeFrame",true))
    return upg and (upg:FindFirstChild("AddPoints") or upg:FindFirstChild("AddPoints",true))
end

function Impl.getStatSpendRemote()
    if type(STAT_SPEND_REMOTE_PATH)=="table" then
        local r=Impl.resolveChildChain(game,STAT_SPEND_REMOTE_PATH)
        if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then return r end
    end
    local rs=game:FindFirstChild("ReplicatedStorage")
    if not rs then return nil end
    local r=rs:FindFirstChild("AllocateStat",true)
    if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then return r end
    return nil
end

function Impl.tryStatSpendRemote(statKey)
    local r=Impl.getStatSpendRemote()
    if not r or not statKey then return end
    pcall(function()
        if r:IsA("RemoteEvent") then r:FireServer(statKey,1)
        elseif r:IsA("RemoteFunction") then r:InvokeServer(statKey,1) end
    end)
end

function Impl.readStatPointsAvailable()
    local lb=Impl.getStatPointsLabel()
    if lb and lb:IsA("GuiObject") then
        return Impl.parseNumberLoose(lb.Text) or 0
    end
    return 0
end

function Impl.microWalkWhileSpendingStats(stepIndex)
    pcall(function()
        local char=lp.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 or hum.Sit then return end
        local ang=(stepIndex or 0)*0.85
        local v=Vector3.new(math.cos(ang),0,math.sin(ang))
        hum:Move(v,false)
    end)
end

function Impl.tryAutoSpendStats()
    if not autoLevelProgressEnabled then return end
    local useRemote=Impl.getStatSpendRemote()~=nil
    local safety=0
    while safety<150 and Impl.readStatPointsAvailable()>0 do
        safety=safety+1
        local phase=(safety-1)%3
        local isDef=(phase==2)
        local frameName=isDef and "DefenseStatFrame" or "SwordStatFrame"
        local alt=isDef and {"HealthStatFrame","HPStatFrame"} or nil
        local remoteKey=isDef and STAT_SPEND_REMOTE_DEFENSE_KEY or STAT_SPEND_REMOTE_SWORD_KEY
        if useRemote then Impl.tryStatSpendRemote(remoteKey)
        else
            local btn=Impl.getStatAddButton(frameName,alt)
            if btn and btn:IsA("GuiObject") and btn.AbsoluteSize.X>1 and btn.AbsoluteSize.Y>1 then
                Impl.clickGuiCenter(btn)
            elseif not useRemote then break end
        end
        Impl.microWalkWhileSpendingStats(safety)
        task.wait(0.09)
    end
end

function Impl.tryAutoBuySword()
    if not autoLevelProgressEnabled or isInteracting then return end
    local coins,gems=Impl.readMoneyGemsForAutoBuy()
    if coins==nil then return end
    gems=gems or 0
    local tier=Impl.getOwnedSwordTier()
    if tier>=3 then return end
    local npcName,islandName,holdT=nil,nil,2.1
    if tier==0 and coins>=SWORD_KATANA_COINS then
        npcName,islandName="Katana","Starter"
    elseif tier==1 and coins>=SWORD_DARK_COINS and gems>=SWORD_DARK_GEMS then
        npcName,islandName,holdT="DarkBladeNPC","Snow",2.2
    elseif tier==2 and coins>=SWORD_GRYPHON_COINS and gems>=SWORD_GRYPHON_GEMS then
        npcName,islandName,holdT="GryphonBuyerNPC","Shibuya",2.5
    end
    if not npcName then return end
    local wantTier=1
    if npcName=="DarkBladeNPC" then wantTier=2
    elseif npcName=="GryphonBuyerNPC" then wantTier=3 end
    isInteracting=true
    floorHiding=false floorHidePivot=nil
    pcall(function()
        Impl.teleportToIsland(islandName)
        task.wait(0.55)
        if Impl.tweenToNPC(npcName) then
            task.wait(0.3)
            local npcHRP=Impl.findNPCHRP(npcName)
            local npcModel=npcHRP and npcHRP.Parent
            local usedPrompt=false
            if npcModel then
                for _,desc in ipairs(npcModel:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        Impl.fireProximityPromptCompat(desc)
                        usedPrompt=true
                        task.wait(0.15)
                        break
                    end
                end
            end
            if not usedPrompt then Impl.pressE() task.wait(0.12) end
            Impl.pressE()
            task.wait(0.12)
            Impl.holdKeyE(holdT)
        end
        task.wait(0.35)
    end)
    isInteracting=false
    task.wait(0.35)
    Impl.equipSwordUntilEquippedOrTimeout(wantTier)
end

local autoProgressCapNotified=false
local autoProgressNoLevelNotified=false
local autoSpendStatsRunning=false
task.spawn(function()
    while true do
        task.wait(1.4)
        if not autoLevelProgressEnabled then continue end
        if isInteracting then continue end
        Impl.tryAutoBuySword()
        Impl.equipBestOwnedSword()
        if not autoSpendStatsRunning then
            autoSpendStatsRunning=true
            task.spawn(function()
                pcall(Impl.tryAutoSpendStats)
                autoSpendStatsRunning=false
            end)
        end
        if not autoMobQuestEnabled or not autoQuestEnabled then
            autoBossQuestEnabled=false
            autoMobQuestEnabled=true
            autoQuestEnabled=true
        end
        local lv=Impl.readLevelForAutoProgress()
        if not lv then
            if not autoProgressNoLevelNotified then
                autoProgressNoLevelNotified=true
                Rayfield:Notify({
                    Title="Auto Progress",
                    Content="Level not detected (HUD/leaderstats) — quests use current NPC; fix UI to unlock ladder.",
                    Duration=4,
                })
            end
            continue
        end
        autoProgressNoLevelNotified=false
        if lv>=AUTO_PROGRESS_LEVEL_STOP then
            if not autoProgressCapNotified then
                autoProgressCapNotified=true
                Rayfield:Notify({
                    Title="Auto Progress",
                    Content="Level "..AUTO_PROGRESS_LEVEL_STOP.." — quest targeting paused; stats/buy still run.",
                    Duration=3,
                })
            end
            continue
        end
        autoProgressCapNotified=false
        local target=Impl.pickMobQuestForLevel(lv)
        if target and target~=selectedQuestNPC then
            selectedMobQuestNPC=target
            selectedQuestNPC=target
            forceQuestChange=true
        end
    end
end)

task.spawn(function()
    local slot=1
    while true do
        task.wait(styleSwitch_CD)
        if not autoStyleSwitch or not selectedStyle1 then continue end
        if Impl.characterHasSwordEquipped(1) then continue end
        local char=lp.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then continue end
        local toolName=slot==1 and selectedStyle1 or selectedStyle2
        if toolName then Impl.equipTool(toolName) end
        slot=slot==1 and 2 or 1
        if slot==2 and not selectedStyle2 then slot=1 end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.3)
        if not autoQuestEnabled then continue end
        if forceQuestChange then Impl.abandonQuest() Impl.fullReset() task.wait(0.2) continue end
        local char=lp.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then task.wait(1) continue end
        local questInfo=questMobMap[selectedQuestNPC]
        if not questInfo then continue end
        requiredKills=questKillCount[selectedQuestNPC] or 5
        if autoLevelProgressEnabled then
            Impl.abandonQuest()
            task.wait(0.25)
        elseif hasActiveQuest then
            Impl.abandonQuest()
        end
        Rayfield:Notify({Title="Accepting Quest",Content=selectedQuestNPC.." — "..requiredKills.." kills",Duration=1})
        local ok=Impl.acceptQuest()
        if not ok then isInteracting=false task.wait(0.3) continue end
        -- Go to mob island via portal
        local mobIsland=mobIslandMap[questInfo.mob]
        if mobIsland then Impl.teleportToIsland(mobIsland) end
        killCount=0 killCountReached=false
        Impl.startKillTracking(questInfo.mob)
        if questInfo.boss then
            selectedBossPrefix=questInfo.mob bossFarming=true mobFarming=false
        else
            selectedMobPrefix=questInfo.mob mobFarming=true bossFarming=false
        end
        Impl.equipFarmingLoadout() lastZ=-math.huge isInteracting=false
        Rayfield:Notify({Title="Farming!",Content=questInfo.mob.." — 0/"..requiredKills,Duration=2})
        while autoQuestEnabled and not killCountReached and not forceQuestChange do
            task.wait(0.2)
            if killCount>=requiredKills then killCountReached=true break end
            local c=lp.Character
            local h=c and c:FindFirstChildOfClass("Humanoid")
            if not h or h.Health<=0 then
                floorHiding=false floorHidePivot=nil mobFarming=false bossFarming=false
                Rayfield:Notify({Title="Died!",Content="Waiting...",Duration=2})
                repeat task.wait(0.5) until (function()
                    local rc=lp.Character
                    local rh=rc and rc:FindFirstChildOfClass("Humanoid")
                    return rh and rh.Health>0
                end)()
                task.wait(1.5)
                if forceQuestChange then break end
                if mobIsland then Impl.teleportToIsland(mobIsland) end
                Impl.equipFarmingLoadout() lastZ=-math.huge
                local savedCount=killCount
                Impl.startKillTracking(questInfo.mob)
                killCount=savedCount
                if questInfo.boss then
                    selectedBossPrefix=questInfo.mob bossFarming=true mobFarming=false
                else
                    selectedMobPrefix=questInfo.mob mobFarming=true bossFarming=false
                end
                Rayfield:Notify({Title="Respawned!",Content=killCount.."/"..requiredKills,Duration=2})
            end
        end
        if forceQuestChange then Impl.abandonQuest() Impl.fullReset() task.wait(0.2) continue end
        if not autoQuestEnabled then Impl.fullReset() continue end
        Impl.clearTrackedConnections()
        mobFarming=false bossFarming=false floorHiding=false floorHidePivot=nil
        hasActiveQuest=false isInteracting=false
        Rayfield:Notify({Title="Quest Done! ✅",Content=killCount.."/"..requiredKills.." — next...",Duration=2})
        if autoLevelProgressEnabled then
            Impl.abandonQuest()
            task.wait(0.25)
        end
        local ok2=Impl.acceptQuest()
        if not ok2 then isInteracting=false end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.6)
        if not autoWorldBossEnabled then continue end
        if autoQuestEnabled then task.wait(0.5) continue end
        local options={}
        if selectedWorldBossName=="All" then
            for _,b in ipairs(worldBossList) do options[#options+1]=b end
        else
            for _,b in ipairs(worldBossList) do
                if b.name==selectedWorldBossName then options[1]=b break end
            end
        end
        if #options==0 then continue end

        for _,boss in ipairs(options) do
            if not autoWorldBossEnabled then break end
            isInteracting=true
            floorHiding=false floorHidePivot=nil
            worldBossFarming=false

            Rayfield:Notify({Title="World Boss Scan",Content=boss.name.." @ "..boss.island,Duration=1.5})
            Impl.teleportToIsland(boss.island)
            task.wait(worldBossSpawnDelay)

            local char=lp.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            local probe=worldBossIslandProbe[boss.island]
            if hrp and probe then
                char:PivotTo(CFrame.new(probe+Vector3.new(0,4,0)))
                Impl.breakVelocity()
                task.wait(0.25)
            end

            local target=Impl.getNearest(Impl.findByContains(boss.name),hrp and hrp.Position or Vector3.zero)
            if target then
                worldBossTargetName=boss.name
                worldBossFarming=true mobFarming=false bossFarming=false
                Impl.equipFarmingLoadout() lastZ=-math.huge
                isInteracting=false
                Rayfield:Notify({Title="Found!",Content=boss.name.." — attacking",Duration=2})

                local missCount=0
                while autoWorldBossEnabled and worldBossFarming do
                    task.wait(0.5)
                    local c=lp.Character
                    local r=c and c:FindFirstChild("HumanoidRootPart")
                    local h=c and c:FindFirstChildOfClass("Humanoid")
                    if not h or h.Health<=0 then
                        Rayfield:Notify({Title="Died on boss",Content="Respawning and returning to "..boss.name,Duration=2})
                        floorHiding=false floorHidePivot=nil
                        repeat
                            task.wait(0.4)
                            c=lp.Character
                            h=c and c:FindFirstChildOfClass("Humanoid")
                        until (not autoWorldBossEnabled) or (not worldBossFarming) or (h and h.Health>0)
                        if not autoWorldBossEnabled or not worldBossFarming then break end

                        Impl.teleportToIsland(boss.island)
                        task.wait(worldBossSpawnDelay)
                        c=lp.Character
                        r=c and c:FindFirstChild("HumanoidRootPart")
                        local returnProbe=worldBossIslandProbe[boss.island]
                        if c and r and returnProbe then
                            c:PivotTo(CFrame.new(returnProbe+Vector3.new(0,4,0)))
                            Impl.breakVelocity()
                            task.wait(0.25)
                        end
                        Impl.equipFarmingLoadout()
                        lastZ=-math.huge
                        missCount=0
                        continue
                    end
                    local alive=Impl.getNearest(Impl.findByContains(boss.name),r and r.Position or Vector3.zero)
                    if alive then
                        missCount=0
                    else
                        missCount=missCount+1
                        if missCount>=6 then
                            worldBossFarming=false
                            floorHiding=false floorHidePivot=nil
                            Rayfield:Notify({Title="Boss down / gone",Content=boss.name,Duration=2})
                        end
                    end
                end
            else
                isInteracting=false
            end
            task.wait(worldBossCycleDelay)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if isInteracting then floorHiding=false floorHidePivot=nil continue end
        if not mobFarming and not bossFarming and not worldBossFarming then floorHiding=false floorHidePivot=nil continue end
        local char=lp.Character
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health<=0 then
            floorHiding=false floorHidePivot=nil task.wait(1) continue
        end
        if isInteracting then floorHiding=false floorHidePivot=nil continue end
        local target=nil
        if bossFarming then
            local bt=Impl.findByPrefix(selectedBossPrefix)
            target=Impl.getNearest(bt,hrp.Position)
            if not target then
                local wm=bossWaitMob[selectedBossPrefix]
                if wm then target=Impl.getNearest(Impl.findByPrefix(wm),hrp.Position) end
            end
        end
        if not target and worldBossFarming then
            local worldTarget=worldBossTargetName or selectedWorldBossName
            target=Impl.getNearest(Impl.findByContains(worldTarget),hrp.Position)
        end
        if not target and mobFarming then
            target=Impl.getNearest(Impl.findByPrefix(selectedMobPrefix),hrp.Position)
        end
        if not target or target.hum.Health<=0 then floorHiding=false floorHidePivot=nil continue end
        if isInteracting then floorHiding=false floorHidePivot=nil continue end
        floorHidePivot=target.hrp.CFrame floorHiding=true
        task.wait(0.1)
        if isInteracting then floorHiding=false floorHidePivot=nil continue end
        if target.hum.Health<=0 then floorHiding=false floorHidePivot=nil continue end
        Impl.pressM1() Impl.pressM1() Impl.pressM1() Impl.pressM1()
        Impl.pressM1() Impl.pressM1() Impl.pressM1() Impl.pressM1()
    end
end)

lp.CharacterAdded:Connect(function(char)
    flying=false floorHiding=false floorHidePivot=nil isInteracting=false
    local hum=char:WaitForChild("Humanoid")
    hum.WalkSpeed=currentWalkSpeed
end)

-- ===================== PLAYER TAB =====================
local PlayerTab=Window:CreateTab("Player",4483362458)
PlayerTab:CreateSection("Movement")
PlayerTab:CreateSlider({
    Name="WalkSpeed",Range={1,100},Increment=1,Suffix="Speed",CurrentValue=16,Flag="WalkSpeed",
    Callback=function(Value)
        currentWalkSpeed=Value
        local char=lp.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=Value end
    end,
})
PlayerTab:CreateButton({
    Name="Reset WalkSpeed",
    Callback=function()
        currentWalkSpeed=16
        local char=lp.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=16 end
        Rayfield:Notify({Title="Reset",Content="WalkSpeed set to 16",Duration=3})
    end,
})
PlayerTab:CreateSection("Fly")
local flySpeed=50
PlayerTab:CreateSlider({
    Name="Fly Speed",Range={1,100},Increment=1,Suffix="Speed",CurrentValue=50,Flag="FlySpeed",
    Callback=function(Value) flySpeed=Value end,
})
PlayerTab:CreateToggle({
    Name="Fly",CurrentValue=false,Flag="FlyToggle",
    Callback=function(Value)
        flying=Value
        local char=lp.Character
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if flying and hrp and hum then
            hum.PlatformStand=true
            bodyVelocity=Instance.new("BodyVelocity")
            bodyVelocity.Velocity=Vector3.zero bodyVelocity.MaxForce=Vector3.new(1e5,1e5,1e5)
            bodyVelocity.Parent=hrp
            bodyGyro=Instance.new("BodyGyro")
            bodyGyro.MaxTorque=Vector3.new(1e5,1e5,1e5) bodyGyro.D=50 bodyGyro.Parent=hrp
            flyConnection=RunService.RenderStepped:Connect(function()
                if not flying then return end
                local cf=workspace.CurrentCamera.CFrame
                local dir=Vector3.zero
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir+=cf.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir-=cf.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir-=cf.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir+=cf.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir-=Vector3.new(0,1,0) end
                if dir.Magnitude>0 then dir=dir.Unit end
                bodyVelocity.Velocity=dir*flySpeed bodyGyro.CFrame=cf
            end)
        else Impl.stopFly() end
    end,
})
PlayerTab:CreateSection("Anti-AFK")
PlayerTab:CreateToggle({
    Name="Anti-AFK",CurrentValue=false,Flag="AntiAFK",
    Callback=function(Value)
        antiAfkRunning=Value
        if Value then
            task.spawn(function()
                while antiAfkRunning do lp:Move(Vector3.new(0,0,0)) task.wait(240) end
            end)
            Rayfield:Notify({Title="Anti-AFK ON",Content="Won't get kicked!",Duration=3})
        end
    end,
})
PlayerTab:CreateSection("System")
PlayerTab:CreateButton({
    Name="❌ Close Script",
    Callback=function()
        Impl.stopAll()
        Rayfield:Notify({Title="Closing...",Content="Stopping everything...",Duration=2})
        task.wait(2) Rayfield:Destroy()
    end,
})

-- ===================== MOBS TAB =====================
local MobTab=Window:CreateTab("Mobs",4483362458)
MobTab:CreateSection("Select Mob")
local mobList={
    {prefix="Thief",         label="Thief  |  Lv 10  |  Starter Island"},
    {prefix="Bunny",         label="Bunny  |  Starter Island"},
    {prefix="Monkey",        label="Monkey  |  Lv 250  |  Jungle Island"},
    {prefix="DesertBandit",  label="Desert Bandit  |  Lv 750  |  Desert Island"},
    {prefix="FrostRogue",    label="Frost Rogue  |  Lv 1500  |  Snow Island"},
    {prefix="Sorcerer",      label="Sorcerer  |  Lv 3000  |  Shibuya Station"},
    {prefix="Hollow",        label="Hollow  |  Lv 5000  |  Hollow Island"},
    {prefix="StrongSorcerer",label="Strong Sorcerer  |  Lv 6250  |  Shinjuku Island"},
    {prefix="Curse",         label="Curse  |  Lv 7000  |  Shinjuku Island"},
    {prefix="Slime",         label="Slime  |  Lv 8000  |  Slime Island"},
    {prefix="AcademyTeacher",label="Academy Teacher  |  Lv 9000  |  Academy Island"},
    {prefix="Swordsman",     label="Swordsman  |  Lv 10000  |  Judgement Island"},
    {prefix="Quincy",        label="Quincy  |  Lv 10750  |  Soul Dominion"},
    {prefix="Ninja",         label="Ninja  |  Lv 11500  |  Ninja Island"},
    {prefix="ArenaFighter",  label="Arena Fighter  |  Lv 12000  |  Lawless Island"},
}
local mobOptions={}
for _,v in ipairs(mobList) do mobOptions[#mobOptions+1]=v.label end
MobTab:CreateDropdown({
    Name="Choose Mob",Options=mobOptions,CurrentOption={mobOptions[1]},Flag="SelectedMob",
    Callback=function(Value)
        for _,v in ipairs(mobList) do
            if v.label==Value[1] then selectedMobPrefix=v.prefix
                Rayfield:Notify({Title="Mob Selected",Content=v.label,Duration=2}) break end
        end
    end,
})
MobTab:CreateSection("AutoFarm")
MobTab:CreateToggle({
    Name="🌾 AutoFarm Mobs",CurrentValue=false,Flag="MobFarm",
    Callback=function(Value)
        if Value then
            task.spawn(function()
                local island=mobIslandMap[selectedMobPrefix]
                if island then
                    Rayfield:Notify({Title="Teleporting",Content=island.."...",Duration=2})
                    Impl.teleportToIsland(island)
                end
                mobFarming=true Impl.equipFarmingLoadout() lastZ=-math.huge
                Rayfield:Notify({Title="Mob Farm ON",Content=selectedMobPrefix,Duration=2})
            end)
        else
            mobFarming=false floorHiding=false floorHidePivot=nil
            Rayfield:Notify({Title="Mob Farm OFF",Content="Stopped.",Duration=2})
        end
    end,
})
MobTab:CreateSection("Auto Quest — Mobs")
local mobQuestOptions={}
for _,v in ipairs(mobQuestList) do mobQuestOptions[#mobQuestOptions+1]=v.label end
MobTab:CreateDropdown({
    Name="Quest NPC",Options=mobQuestOptions,CurrentOption={mobQuestOptions[1]},Flag="QuestNPCMob",
    Callback=function(Value)
        for _,v in ipairs(mobQuestList) do
            if v.label==Value[1] then
                selectedMobQuestNPC=v.name
                if autoMobQuestEnabled then
                    selectedQuestNPC=selectedMobQuestNPC forceQuestChange=true
                end
                break
            end
        end
    end,
})
MobTab:CreateToggle({
    Name="📋 Auto Quest — Mobs",CurrentValue=false,Flag="AutoQuestMob",
    Callback=function(Value)
        autoMobQuestEnabled=Value
        if Value then
            autoBossQuestEnabled=false autoQuestEnabled=true
            selectedQuestNPC=selectedMobQuestNPC
            Impl.abandonQuest() Impl.fullReset()
            Rayfield:Notify({Title="Mob Quest ON",Content=selectedMobQuestNPC,Duration=2})
        else
            autoMobQuestEnabled=false
            autoQuestEnabled=autoBossQuestEnabled
            if not autoQuestEnabled then Impl.fullReset() end
            Rayfield:Notify({Title="Mob Quest OFF",Content="Stopped.",Duration=2})
        end
    end,
})

-- ===================== BOSSES TAB =====================
local BossTab=Window:CreateTab("Bosses",4483362458)
BossTab:CreateSection("Select Boss")
local bossList={
    {prefix="ThiefBoss",    label="Thief Boss  |  Starter Island"},
    {prefix="MonkeyBoss",   label="Monkey Boss  |  Jungle Island"},
    {prefix="DesertBoss",   label="Desert Boss  |  Desert Island"},
    {prefix="SnowBoss",     label="Snow Boss  |  Snow Island"},
    {prefix="PandaMiniBoss",label="Panda Boss  |  Shibuya Station"},
}
local bossOptions={}
for _,v in ipairs(bossList) do bossOptions[#bossOptions+1]=v.label end
BossTab:CreateDropdown({
    Name="Choose Boss",Options=bossOptions,CurrentOption={bossOptions[1]},Flag="SelectedBoss",
    Callback=function(Value)
        for _,v in ipairs(bossList) do
            if v.label==Value[1] then selectedBossPrefix=v.prefix
                Rayfield:Notify({Title="Boss Selected",Content=v.label,Duration=2}) break end
        end
    end,
})
BossTab:CreateSection("AutoFarm")
BossTab:CreateToggle({
    Name="🌾 AutoFarm Boss",CurrentValue=false,Flag="BossFarm",
    Callback=function(Value)
        if Value then
            task.spawn(function()
                local island=mobIslandMap[selectedBossPrefix]
                if island then
                    Rayfield:Notify({Title="Teleporting",Content=island.."...",Duration=2})
                    Impl.teleportToIsland(island)
                end
                bossFarming=true Impl.equipFarmingLoadout() lastZ=-math.huge
                Rayfield:Notify({Title="Boss Farm ON",Content=selectedBossPrefix,Duration=2})
            end)
        else
            bossFarming=false floorHiding=false floorHidePivot=nil
            Rayfield:Notify({Title="Boss Farm OFF",Content="Stopped.",Duration=2})
        end
    end,
})
BossTab:CreateSection("Auto Quest — Bosses")
local bossQuestOptions={}
for _,v in ipairs(bossQuestList) do bossQuestOptions[#bossQuestOptions+1]=v.label end
BossTab:CreateDropdown({
    Name="Quest NPC",Options=bossQuestOptions,CurrentOption={bossQuestOptions[1]},Flag="QuestNPCBoss",
    Callback=function(Value)
        for _,v in ipairs(bossQuestList) do
            if v.label==Value[1] then
                selectedBossQuestNPC=v.name
                if autoBossQuestEnabled then
                    selectedQuestNPC=selectedBossQuestNPC forceQuestChange=true
                end
                break
            end
        end
    end,
})
BossTab:CreateToggle({
    Name="📋 Auto Quest — Bosses",CurrentValue=false,Flag="AutoQuestBoss",
    Callback=function(Value)
        autoBossQuestEnabled=Value
        if Value then
            autoMobQuestEnabled=false autoQuestEnabled=true
            selectedQuestNPC=selectedBossQuestNPC
            Impl.abandonQuest() Impl.fullReset()
            Rayfield:Notify({Title="Boss Quest ON",Content=selectedBossQuestNPC,Duration=2})
        else
            autoBossQuestEnabled=false
            autoQuestEnabled=autoMobQuestEnabled
            if not autoQuestEnabled then Impl.fullReset() end
            Rayfield:Notify({Title="Boss Quest OFF",Content="Stopped.",Duration=2})
        end
    end,
})

BossTab:CreateSection("World Boss Hunt")
local worldBossOptions={"All"}
for _,v in ipairs(worldBossList) do worldBossOptions[#worldBossOptions+1]=v.label end
BossTab:CreateDropdown({
    Name="World Boss",Options=worldBossOptions,CurrentOption={worldBossOptions[1]},Flag="SelectedWorldBoss",
    Callback=function(Value)
        local picked=(type(Value)=="table" and Value[1]) or Value
        if picked=="All" then
            selectedWorldBossName="All"
        else
            for _,v in ipairs(worldBossList) do
                if v.label==picked then selectedWorldBossName=v.name break end
            end
        end
        if autoWorldBossEnabled then
            -- Retarget hunt immediately without toggle off/on
            worldBossFarming=false
            worldBossTargetName=nil
            floorHiding=false floorHidePivot=nil
            isInteracting=false
            Rayfield:Notify({Title="World Boss Target",Content=selectedWorldBossName,Duration=1.5})
        end
    end,
})
BossTab:CreateToggle({
    Name="🌍 Auto Hunt World Boss",CurrentValue=false,Flag="WorldBossHunt",
    Callback=function(Value)
        autoWorldBossEnabled=Value
        if Value then
            autoMobQuestEnabled=false autoBossQuestEnabled=false autoQuestEnabled=false
            mobFarming=false bossFarming=false worldBossFarming=false
            worldBossTargetName=nil
            floorHiding=false floorHidePivot=nil
            Rayfield:Notify({Title="World Boss Hunt ON",Content="Mode: "..selectedWorldBossName,Duration=2})
        else
            autoWorldBossEnabled=false worldBossFarming=false
            worldBossTargetName=nil
            floorHiding=false floorHidePivot=nil
            Rayfield:Notify({Title="World Boss Hunt OFF",Content="Stopped.",Duration=2})
        end
    end,
})

-- ===================== FARMING TAB =====================
local FarmingTab=Window:CreateTab("Farming",4483362458)
FarmingTab:CreateSection("Farming Hub Window")
FarmingTab:CreateButton({
    Name="🎮 Open / Close Farming Hub",
    Callback=function()
        if farmingGUI and farmingGUI.Parent then
            farmingGUI:Destroy() farmingGUI=nil
        else
            Impl.createFarmingGUI()
            Rayfield:Notify({Title="Farming Hub",Content="Right-click skill to cycle CD.",Duration=3})
        end
    end,
})
FarmingTab:CreateSection("Auto Style Switcher")
FarmingTab:CreateToggle({
    Name="🔄 Auto Switch Styles 1 → 2",CurrentValue=false,Flag="AutoStyleSwitch",
    Callback=function(Value)
        autoStyleSwitch=Value
        if Value then Rayfield:Notify({Title="Style Switch ON",Content="Every "..styleSwitch_CD.."s",Duration=2})
        else Rayfield:Notify({Title="Style Switch OFF",Content="Stopped.",Duration=2}) end
    end,
})
FarmingTab:CreateSlider({
    Name="Switch Interval (sec)",Range={1,60},Increment=1,Suffix="s",CurrentValue=5,Flag="StyleSwitchCD",
    Callback=function(Value) styleSwitch_CD=Value end,
})
-- ===================== NPCs TAB =====================
local NPCsTab=Window:CreateTab("NPCs",4483362458)
NPCsTab:CreateSection("👤 Quick NPC Teleport")

local npcFlatList={}
local npcLabelToData={}
for _,cat in ipairs(npcCategories) do
    for _,npc in ipairs(cat.npcs) do
        local entry={name=npc.name,label=npc.label}
        npcFlatList[#npcFlatList+1]=entry
        npcLabelToData[npc.label]=entry
    end
end

local npcDropOptions={}
for _,v in ipairs(npcFlatList) do npcDropOptions[#npcDropOptions+1]=v.label end

NPCsTab:CreateDropdown({
    Name="Select NPC",Options=npcDropOptions,CurrentOption={npcDropOptions[1]},Flag="SelectedNPCDrop",
    Callback=function(Value)
        if npcLabelToData[Value[1]] then selectedNPCData=npcLabelToData[Value[1]] end
    end,
})

NPCsTab:CreateButton({
    Name="👤 Teleport to Selected NPC",
    Callback=function()
        if isInteracting then
            Rayfield:Notify({Title="Busy!",Content="Wait for current action.",Duration=2})
            return
        end
        local npc=selectedNPCData
        Rayfield:Notify({Title="Going to "..npc.name,Content="Tweening...",Duration=1})
        task.spawn(function()
            isInteracting=true
            floorHiding=false floorHidePivot=nil
            local found=Impl.tweenToNPC(npc.name)
            if found then
                Rayfield:Notify({Title="Arrived!",Content=npc.name,Duration=2})
            else
                Rayfield:Notify({Title="No position",Content=npc.name,Duration=3})
            end
            isInteracting=false
        end)
    end,
})

for _,cat in ipairs(npcCategories) do
    NPCsTab:CreateSection(cat.section)
    for _,npc in ipairs(cat.npcs) do
        local npcRef=npc
        NPCsTab:CreateButton({
            Name=npc.label,
            Callback=function()
                if isInteracting then
                    Rayfield:Notify({Title="Busy!",Content="Wait for current action.",Duration=2})
                    return
                end
                Rayfield:Notify({Title="Going to "..npcRef.name,Content="Tweening...",Duration=1})
                task.spawn(function()
                    isInteracting=true
                    floorHiding=false floorHidePivot=nil
                    local found=Impl.tweenToNPC(npcRef.name)
                    if found then
                        Rayfield:Notify({Title="Arrived!",Content=npcRef.name,Duration=2})
                    else
                        Rayfield:Notify({Title="No position",Content=npcRef.name,Duration=3})
                    end
                    isInteracting=false
                end)
            end,
        })
    end
end

-- ===================== OTHERS TAB =====================
local OthersTab=Window:CreateTab("Others",4483362458)
OthersTab:CreateSection("🗺️ Island Teleporter")
local islandOptions={}
for _,v in ipairs(allIslands) do islandOptions[#islandOptions+1]=v.label end
OthersTab:CreateDropdown({
    Name="Select Island",Options=islandOptions,CurrentOption={islandOptions[1]},Flag="SelectedIsland",
    Callback=function(Value)
        for _,v in ipairs(allIslands) do
            if v.label==Value[1] then selectedIsland=v.name break end
        end
    end,
})
OthersTab:CreateButton({
    Name="🚀 Teleport to Island",
    Callback=function()
        Rayfield:Notify({Title="Teleporting",Content=selectedIsland.."...",Duration=2})
        task.spawn(function()
            Impl.teleportToIsland(selectedIsland)
            Rayfield:Notify({Title="Arrived!",Content=selectedIsland,Duration=2})
        end)
    end,
})
OthersTab:CreateSection("⚡ Quick Teleport")
local quickIslands={
    {name="Starter",      emoji="🏝️"},
    {name="Jungle",       emoji="🌿"},
    {name="Desert",       emoji="🏜️"},
    {name="Snow",         emoji="❄️"},
    {name="Shibuya",      emoji="🏙️"},
    {name="HollowIsland", emoji="💀"},
    {name="Sailor",       emoji="⚓"},
    {name="Shinjuku",     emoji="⚡"},
    {name="Slime",        emoji="🟢"},
    {name="Dungeon",      emoji="🗝️"},
    {name="Boss",         emoji="👑"},
    {name="Academy",      emoji="🏯"},
    {name="Judgement",    emoji="⚔️"},
    {name="SoulDominion", emoji="👻"},
    {name="Ninja",        emoji="🗡️"},
    {name="Lawless",      emoji="🔥"},
    {name="Tower",        emoji="🏰"},
}
for _,island in ipairs(quickIslands) do
    OthersTab:CreateButton({
        Name=island.emoji.." "..island.name,
        Callback=function()
            Rayfield:Notify({Title="Teleporting",Content=island.name.."...",Duration=2})
            task.spawn(function() Impl.teleportToIsland(island.name) end)
        end,
    })
end

do
    local Tab=Window:CreateTab("Auto NPCs",4483362458)
    Tab:CreateSection("Hogyoku")
    Tab:CreateButton({
        Name="Auto Hogyoku",
        Callback=function()
            Impl.runAutoHogyokuCollect()
        end,
    })
    Tab:CreateSection("Demonite")
    Tab:CreateButton({
        Name="Auto Demonite",
        Callback=function()
            Impl.runAutoDemoniteCollect()
        end,
    })
end

do
    local AutoProgressTab=Window:CreateTab("Auto Progress",4483362458)
    AutoProgressTab:CreateSection("Auto LvL")
    AutoProgressTab:CreateToggle({
        Name="Auto LvL progress",
        CurrentValue=false,
        Flag="AutoLevelProgress",
        Callback=function(Value)
            autoLevelProgressEnabled=Value
            autoProgressCapNotified=false
            if Value then
                Rayfield:Notify({
                    Title="Auto Progress",
                    Content="ON — ladder, sword, stats; QuestAbandon before new quest.",
                    Duration=2,
                })
            else
                Rayfield:Notify({Title="Auto Progress",Content="Off.",Duration=2})
            end
        end,
    })
end

Rayfield:Notify({
    Title="Sailor Piece Hub v45",
    Content="Portal + Tween "..TWEEN_NPC_STUDS_PER_SEC.." NPCs (+"
        ..TWEEN_NPC_EXTRA_HEIGHT_STUDS.."Y, "..(TWEEN_NPC_HANG_SECONDS*1000)
        .."ms hang, ghost during tween)!",
    Duration=4,
})
