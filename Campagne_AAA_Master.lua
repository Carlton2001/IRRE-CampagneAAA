---------------------------------------------------------------------------------------------------
-- INITIALISATIONS
---------------------------------------------------------------------------------------------------

-- Settings MOOSE

_SETTINGS:SetPlayerMenuOff()
RAT.ATCswitch = false

-- Inits

local EnvProd = false

if EnvProd == false then
    MessageToAll("DEVELOPPEMENT", 120)
    TacticalDisplay = true
end

local DangerZone = {}
DangerZone.S300 = 125000
DangerZone.Hawk = 50000

local Country = {}
Country.IsraelOTAN = {"USA", "ISRAEL"}
Country.TurkeySyria = {"TURQEY", "CJTF_BLUE"}

local RadioGeneral = 305.00

local Tanker = {}
Tanker.Boom = 0 -- perche
Tanker.Probe = 1 -- panier

-- Border Zones

local BORDER    = {}
BORDER.Blue     = {}

BORDER.Red          = ZONE_POLYGON:New("BORDER_Red", GROUP:FindByName("BORDER_Red"))
BORDER.Blue.Israel  = ZONE_POLYGON:New("BORDER_Blue_Israel", GROUP:FindByName("BORDER_Blue_Israel"))
BORDER.Blue.Syria   = ZONE_POLYGON:New("BORDER_Blue_Syria", GROUP:FindByName("BORDER_Blue_Syria"))
BORDER.Blue.Turkey  = ZONE_POLYGON:New("BORDER_Blue_Turkey", GROUP:FindByName("BORDER_Blue_Turkey"))
BORDER.Blue.OTAN    = ZONE_POLYGON:New("BORDER_Blue_OTAN", GROUP:FindByName("BORDER_Blue_OTAN"))

-- Border Smoke pour rigoler
if EnvProd == false then
    BORDER.Red:SmokeZone(SMOKECOLOR.Red)
    BORDER.Blue.Israel:SmokeZone(SMOKECOLOR.Blue)
    BORDER.Blue.Syria:SmokeZone(SMOKECOLOR.Blue)
    BORDER.Blue.Turkey:SmokeZone(SMOKECOLOR.Blue)
    BORDER.Blue.OTAN:SmokeZone(SMOKECOLOR.Blue)
end

-- SAM Groups / Commenter un site SAM pour le désactiver

local SAM = {}
SAM.Blue        = {}
SAM.Red         = {}
SAM.Blue.Israel = {}
SAM.Blue.Syria  = {}
SAM.Blue.Turkey = {}
SAM.Red.Lebanon = {}
SAM.Red.Syria   = {}

SAM.Blue.Israel.Haifa_Patriot   = GROUP:FindByName("SAM_Blue_Israel_Haifa_Patriot"):Activate()
SAM.Blue.Israel.Megiddo_Patriot = GROUP:FindByName("SAM_Blue_Israel_Megiddo_Patriot"):Activate()
SAM.Blue.Syria.Idlib_Hawk       = GROUP:FindByName("SAM_Blue_Syria_Idlib_Hawk"):Activate()
SAM.Blue.Syria.Hama_Hawk        = GROUP:FindByName("SAM_Blue_Syria_Hama_Hawk"):Activate()
SAM.Blue.Syria.Aleppo_S300      = GROUP:FindByName("SAM_Blue_Syria_Aleppo_S300"):Activate()
SAM.Blue.Syria.Palmyra_Hawk     = GROUP:FindByName("SAM_Blue_Syria_Palmyra_Hawk"):Activate()
SAM.Blue.Syria.Tabqa_S300       = GROUP:FindByName("SAM_Blue_Syria_Tabqa_S300"):Activate()
SAM.Blue.Turkey.CB22_S300       = GROUP:FindByName("SAM_Blue_Turkey_CB22_S300"):Activate()
SAM.Blue.Turkey.DB30_S300       = GROUP:FindByName("SAM_Blue_Turkey_DB30_S300"):Activate()
SAM.Blue.Turkey.IF25_S300       = GROUP:FindByName("SAM_Blue_Turkey_IF25_S300"):Activate()
SAM.Red.Syria.AlQusayr_Hawk     = GROUP:FindByName("SAM_Red_Syria_AlQusayr_Hawk"):Activate()
SAM.Red.Syria.Damascus_S300     = GROUP:FindByName("SAM_Red_Syria_Damascus_S300"):Activate()
SAM.Red.Lebanon.Beirut_Hawk     = GROUP:FindByName("SAM_Red_Lebanon_Beirut_Hawk"):Activate()

-- SAM Zones

local SAMzone = {}

if SAM.Red.Syria.AlQusayr_Hawk then SAMzone.AlQusayr_Hawk = ZONE_GROUP:New("Zone_AlQusayr_Hawk", SAM.Red.Syria.AlQusayr_Hawk, DangerZone.Hawk) end
if SAM.Red.Syria.Damascus_S300 then SAMzone.Damascus_S300 = ZONE_GROUP:New("Zone_Damascus_S300", SAM.Red.Syria.Damascus_S300, DangerZone.S300) end
if SAM.Red.Lebanon.Beirut_Hawk then SAMzone.Beirut_Hawk = ZONE_GROUP:New("Zone_Beirut_Hawk", SAM.Red.Lebanon.Beirut_Hawk, DangerZone.Hawk) end

-- NAVAL Groups

local NAVAL = {}
NAVAL.Blue  = {}
NAVAL.Red   = {}

NAVAL.Blue.Cyprus_OTAN = GROUP:FindByName("NAVAL_Blue_Cyprus_OTAN"):Activate()

-- Air Groups

local AIR   = {}
AIR.Red     = {}
AIR.Blue    = {}

AIR.Red.All             = SET_GROUP:New():FilterCoalitions("red"):FilterCategoryAirplane():FilterStart()
AIR.Red.GCICAP          = SET_GROUP:New():FilterCoalitions("red"):FilterCategoryAirplane():FilterPrefixes{"CAP_Red", "GCI_Red"}:FilterStart()
AIR.Blue.All            = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterStart()
AIR.Blue.IsraelOTAN     = SET_GROUP:New():FilterCoalitions("blue"):FilterCountries(Country.IsraelOTAN):FilterCategoryAirplane():FilterStart()
AIR.Blue.TurkeySyria    = SET_GROUP:New():FilterCoalitions("blue"):FilterCountries(Country.TurkeySyria):FilterCategoryAirplane():FilterStart()

-- GCI Detection Sets

local EWR = {}

EWR.Red     = SET_GROUP:New():FilterPrefixes({"SAM_Red", "EWR_Red"}):FilterStart()
EWR.Israel  = SET_GROUP:New():FilterPrefixes({"SAM_Blue_Israel"}):FilterStart()
EWR.OTAN    = SET_GROUP:New():FilterPrefixes({"NAVAL_Blue_Cyprus_OTAN", "AWACS_Blue_OTAN"}):FilterStart()
EWR.Turkey  = SET_GROUP:New():FilterPrefixes({"SAM_Blue_Turkey"}):FilterStart()
EWR.Syria   = SET_GROUP:New():FilterPrefixes({"SAM_Blue_Syria"}):FilterStart()

---------------------------------------------------------------------------------------------------
-- BORDER SAM LOGIC
---------------------------------------------------------------------------------------------------

--[[

    ■ Blue SAMs

    OTAN / ISRAEL / TURKEY
    Border OpenFire

    ISIS / OPPOSITON :
    OpenFire ASAP

    ■ Red SAMs

    Vs OTAN / ISRAEL
    OpenFire ASAP

]]--

SchedulerBorderDefenses = SCHEDULER:New( nil,
    function()

        -- BORDER Blues
        local function BlueSamBorderDefense(sam, border, bandits)
            -- Autorisation de tir pour les SAM/Naval Bleus en fonction de la présence de bandits à l'intérieur de la frontière
            if sam then
                if bandits:AnyInZone(border) then
                    if EnvProd == false then MessageToRed("DANGER ZONE", 2) end
                    sam:OptionROEOpenFire()
                else
                    sam:OptionROEHoldFire()
                end
            end
        end

        if AIR.Red.All:CountAlive() >= 1 then
            BlueSamBorderDefense(SAM.Blue.Israel.Haifa_Patriot, BORDER.Blue.Israel, AIR.Red.All)
            BlueSamBorderDefense(SAM.Blue.Israel.Megiddo_Patriot, BORDER.Blue.Israel, AIR.Red.All)
            BlueSamBorderDefense(SAM.Blue.Turkey.CB22_S300, BORDER.Blue.Turkey, AIR.Red.All)
            BlueSamBorderDefense(SAM.Blue.Turkey.DB30_S300, BORDER.Blue.Turkey, AIR.Red.All)
            BlueSamBorderDefense(SAM.Blue.Turkey.IF25_S300, BORDER.Blue.Turkey, AIR.Red.All)
            BlueSamBorderDefense(NAVAL.Blue.Cyprus_OTAN, BORDER.Blue.OTAN, AIR.Red.All)
        end

        -- BORDER Reds
        local function RedSamBorderDefense(sam, zonesam)
            -- Autorisation de tir pour les SAM rouges en fonction de la présence de bandits à l'intérieur de la frontière
            -- ou de la nationalité des bandits à l'intérieur de la zone de tir du SAM
            if sam then
                if AIR.Blue.IsraelOTAN:AnyInZone(BORDER.Red) or AIR.Blue.TurkeySyria:AnyInZone(zonesam) then
                    if EnvProd == false then MessageToBlue("DANGER ZONE", 2) end
                    sam:OptionROEOpenFire()
                else
                    sam:OptionROEHoldFire()
                end
            end
        end

        if AIR.Blue.All:CountAlive() >= 1 then
            RedSamBorderDefense(SAM.Red.Syria.AlQusayr_Hawk, SAMzone.AlQusayr_Hawk)
            RedSamBorderDefense(SAM.Red.Syria.Damascus_S300, SAMzone.Damascus_S300)
            RedSamBorderDefense(SAM.Red.Lebanon.Beirut_Hawk, SAMzone.Beirut_Hawk)
        end
	end, {}, 1, 10
)

---------------------------------------------------------------------------------------------------
-- BREVITY RED GCICAP
---------------------------------------------------------------------------------------------------

function AIR.Red.GCICAP:OnAfterAdded(From, Event, To, ObjectName, Object)
    local NewGroup = GROUP:FindByName(ObjectName)
    NewGroup:HandleEvent(EVENTS.Shot)
    function NewGroup:OnEventShot(EventData)
        local Brevity = "none"
        local WeaponDesc = EventData.Weapon:getDesc() -- https://wiki.hoggitworld.com/view/DCS_enum_weapon
        if WeaponDesc.category == 3 then
            Brevity = "Pickle"
        elseif WeaponDesc.category == 1 then
            if WeaponDesc.guidance == 1 then
                if WeaponDesc.missileCategory == 4 then
                    Brevity = "LongRifle"
                elseif WeaponDesc.missileCategory == 6 then
                    Brevity = "Rifle"
                end
            elseif WeaponDesc.guidance == 2 then
                Brevity = "Fox2"
            elseif WeaponDesc.guidance == 3 then
                Brevity = "Fox3"
            elseif WeaponDesc.guidance == 4 then
                Brevity = "Fox1"
            elseif WeaponDesc.guidance == 5 and WeaponDesc.missileCategory == 6 then
                Brevity = "Magnum"
            elseif WeaponDesc.guidance == 7 then
                Brevity = "Rifle"
            end
        end
        if Brevity ~= "none"  then
            local BrevitySound = Brevity .. ".ogg"
            local GroupRadio = NewGroup:GetRadio()
            GroupRadio:SetFileName(BrevitySound)
            GroupRadio:SetFrequency(RadioGeneral)
            GroupRadio:SetModulation(radio.modulation.AM)
            GroupRadio:Broadcast()
        end
    end
end

---------------------------------------------------------------------------------------------------
-- BORDER CAP/GCI LOGIC
---------------------------------------------------------------------------------------------------

-- OTAN

    local ZoneCAPOTAN = ZONE_POLYGON:New("WPT_CAP_OTAN", GROUP:FindByName("WPT_CAP_OTAN"))
    local DetectionOTAN = DETECTION_AREAS:New(EWR.OTAN, 150000)

    -- AUFTRAG AWACS

    local AuftragAWACSOTAN = AUFTRAG:NewAWACS(ZONE:New("ZONE_AWACS_OTAN"):GetCoordinate(), 25000, 350, 25, 20)
    local AuftragAWACSOTANFG = FLIGHTGROUP:New("AWACS_Blue_OTAN")
    AuftragAWACSOTANFG:AddMission(AuftragAWACSOTAN)

    -- AUFTRAG Tanker

    local AuftragTankerSOTAN = AUFTRAG:NewTANKER(ZONE:New("ZONE_Tanker_OTAN"):GetCoordinate(), 6000, 350, 25, 20)
    AuftragTankerSOTAN:SetTime(30)
    AuftragTankerSOTAN:SetRepeat(99)
    local AuftragTankerSOTANFG = FLIGHTGROUP:New("TANKER_Blue_OTAN")
    AuftragTankerSOTANFG:AddMission(AuftragTankerSOTAN)

    -- CAP/GCI OTAN

    local A2ADispatcherOTAN = AI_A2A_DISPATCHER:New(DetectionOTAN)

    A2ADispatcherOTAN:SetBorderZone({BORDER.Blue.OTAN})
    A2ADispatcherOTAN:SetDefaultFuelThreshold(0.4)
    A2ADispatcherOTAN:SetDefaultGrouping(2)
    A2ADispatcherOTAN:SetDefaultOverhead(2)
    A2ADispatcherOTAN:SetDefaultLandingAtRunway()
    A2ADispatcherOTAN:SetDefaultTanker("TANKER_Blue_OTAN")
    A2ADispatcherOTAN:SetTacticalDisplay(TacticalDisplay)
    -- CAP 1
    A2ADispatcherOTAN:SetSquadron("OTAN CAP1", "NAVAL_Blue_Cyprus_OTAN_Carrier", {"CAP_Blue_OTAN"}, 4)
    A2ADispatcherOTAN:SetSquadronTakeoffFromParkingHot("OTAN CAP1")
    A2ADispatcherOTAN:SetSquadronCap2("OTAN CAP1", 1000, 2000, 2000, 10000, "BARO", ZoneCAPOTAN, 600, 800, 4000, 8000, "RADIO")
    A2ADispatcherOTAN:SetSquadronCapInterval("OTAN CAP1", 1, 60, 120, 1)
    A2ADispatcherOTAN:SetSquadronGrouping("OTAN CAP1", 2)
    A2ADispatcherOTAN:SetSquadronGci("OTAN CAP1", 1000, 2000)
    -- CAP 2
    A2ADispatcherOTAN:SetSquadron("OTAN CAP2", "NAVAL_Blue_Cyprus_OTAN_Carrier", {"CAP_Blue_OTAN"}, 4)
    A2ADispatcherOTAN:SetSquadronTakeoffFromParkingHot("OTAN CAP2")
    A2ADispatcherOTAN:SetSquadronCap2("OTAN CAP2", 1000, 2000, 2000, 10000, "BARO", ZoneCAPOTAN, 600, 800, 4000, 8000, "RADIO")
    A2ADispatcherOTAN:SetSquadronCapInterval("OTAN CAP2", 1, 600, 660, 1)
    A2ADispatcherOTAN:SetSquadronGrouping("OTAN CAP2", 2)
    A2ADispatcherOTAN:SetSquadronGci("OTAN CAP2", 1000, 2000)
    -- GCI
    A2ADispatcherOTAN:SetSquadron("OTAN GCI", "NAVAL_Blue_Cyprus_OTAN_Carrier", {"GCI_Blue_OTAN"}, 2)
    A2ADispatcherOTAN:SetSquadronTakeoffFromParkingHot("OTAN GCI")
    A2ADispatcherOTAN:SetSquadronGrouping("OTAN GCI", 2)
    A2ADispatcherOTAN:SetSquadronGci("OTAN GCI", 1000, 2000)

-- ISRAEL

    local ZoneCAPIsrael = ZONE_POLYGON:New("WPT_CAP_Israel", GROUP:FindByName("WPT_CAP_Israel"))
    local DetectionIsrael = DETECTION_AREAS:New(EWR.Israel, 150000)

    -- CAP/GCI Israel

    local A2ADispatcherIsrael = AI_A2A_DISPATCHER:New(DetectionIsrael)

    A2ADispatcherIsrael:SetBorderZone({BORDER.Blue.Israel})
    A2ADispatcherIsrael:SetDefaultFuelThreshold(0.4)
    A2ADispatcherIsrael:SetDefaultGrouping(2)
    A2ADispatcherIsrael:SetDefaultOverhead(2)
    A2ADispatcherIsrael:SetDefaultLandingAtRunway()
    A2ADispatcherIsrael:SetTacticalDisplay(TacticalDisplay)
    -- CAP
    A2ADispatcherIsrael:SetSquadron("Israel CAP", AIRBASE.Syria.Ramat_David, {"CAP_Blue_Israel"}, 4)
    A2ADispatcherIsrael:SetSquadronTakeoffFromRunway("Israel CAP")
    A2ADispatcherIsrael:SetSquadronCap2("Israel CAP", 1000, 2000, 2000, 10000, "BARO", ZoneCAPIsrael, 600, 800, 4000, 8000, "RADIO")
    A2ADispatcherIsrael:SetSquadronCapInterval("Israel CAP", 1, 60, 120, 1)
    A2ADispatcherIsrael:SetSquadronGrouping("Israel CAP", 2)
    A2ADispatcherIsrael:SetSquadronGci("Israel CAP", 1000, 2000)
    -- GCI
    A2ADispatcherIsrael:SetSquadron("Israel GCI", AIRBASE.Syria.Ramat_David, {"GCI_Blue_Israel"}, 2)
    A2ADispatcherIsrael:SetSquadronTakeoffFromRunway("Israel GCI")
    A2ADispatcherIsrael:SetSquadronGrouping("Israel GCI", 2)
    A2ADispatcherIsrael:SetSquadronGci("Israel GCI", 1000, 2000)

-- TURKEY

    local ZoneCAPTurkeyW = ZONE_POLYGON:New("WPT_CAP_TurkeyW", GROUP:FindByName("WPT_CAP_TurkeyW"))
    local ZoneCAPTurkeyE = ZONE_POLYGON:New("WPT_CAP_TurkeyE", GROUP:FindByName("WPT_CAP_TurkeyE"))
    local DetectionTurkey = DETECTION_AREAS:New(EWR.Turkey, 150000)

    -- CAP/GCI Turkey

    local A2ADispatcherTurkey = AI_A2A_DISPATCHER:New(DetectionTurkey)

    A2ADispatcherTurkey:SetBorderZone({BORDER.Blue.Turkey})
    A2ADispatcherTurkey:SetDefaultFuelThreshold(0.4)
    A2ADispatcherTurkey:SetDefaultGrouping(2)
    A2ADispatcherTurkey:SetDefaultOverhead(2)
    A2ADispatcherTurkey:SetDefaultLandingAtRunway()
    A2ADispatcherTurkey:SetTacticalDisplay(TacticalDisplay)
    -- CAP West
    A2ADispatcherTurkey:SetSquadron("Turkey CAPW", AIRBASE.Syria.Incirlik, {"CAP_Blue_Turkey"}, 4)
    A2ADispatcherTurkey:SetSquadronTakeoffFromRunway("Turkey CAPW")
    A2ADispatcherTurkey:SetSquadronCap2("Turkey CAPW", 1000, 2000, 2000, 10000, "BARO", ZoneCAPTurkeyW, 600, 800, 4000, 8000, "RADIO")
    A2ADispatcherTurkey:SetSquadronCapInterval("Turkey CAPW", 1, 60, 120, 1)
    A2ADispatcherTurkey:SetSquadronGrouping("Turkey CAPW", 2)
    A2ADispatcherTurkey:SetSquadronGci("Turkey CAPW", 1000, 2000)
    -- CAP East
    A2ADispatcherTurkey:SetSquadron("Turkey CAPE", AIRBASE.Syria.Incirlik, {"CAP_Blue_Turkey"}, 4)
    A2ADispatcherTurkey:SetSquadronTakeoffFromRunway("Turkey CAPE")
    A2ADispatcherTurkey:SetSquadronCap2("Turkey CAPE", 1000, 2000, 2000, 10000, "BARO", ZoneCAPTurkeyE, 600, 800, 4000, 8000, "RADIO")
    A2ADispatcherTurkey:SetSquadronCapInterval("Turkey CAPE", 1, 60, 120, 1)
    A2ADispatcherTurkey:SetSquadronGrouping("Turkey CAPE", 2)
    A2ADispatcherTurkey:SetSquadronGci("Turkey CAPE", 1000, 2000)
    -- GCI
    A2ADispatcherTurkey:SetSquadron("Turkey GCI", AIRBASE.Syria.Incirlik, {"GCI_Blue_Turkey"}, 2)
    A2ADispatcherTurkey:SetSquadronTakeoffFromRunway("Turkey GCI")
    A2ADispatcherTurkey:SetSquadronGrouping("Turkey GCI", 2)
    A2ADispatcherTurkey:SetSquadronGci("Turkey GCI", 1000, 2000)

-- SYRIA

    local ZoneCAPSyriaW = ZONE_POLYGON:New("WPT_CAP_SyriaW", GROUP:FindByName("WPT_CAP_SyriaW"))
    local ZoneCAPSyriaE = ZONE_POLYGON:New("WPT_CAP_SyriaE", GROUP:FindByName("WPT_CAP_SyriaE"))
    local DetectionSyria = DETECTION_AREAS:New(EWR.Syria, 150000)

    -- CAP/GCI Syria

    local A2ADispatcherSyria = AI_A2A_DISPATCHER:New(DetectionSyria)

    A2ADispatcherSyria:SetBorderZone({BORDER.Blue.Syria})
    A2ADispatcherSyria:SetDefaultFuelThreshold(0.4)
    A2ADispatcherSyria:SetDefaultGrouping(2)
    A2ADispatcherSyria:SetDefaultOverhead(2)
    A2ADispatcherSyria:SetDefaultLandingAtRunway()
    A2ADispatcherSyria:SetTacticalDisplay(TacticalDisplay)
    -- CAP West
    A2ADispatcherSyria:SetSquadron("Syria CAPW", AIRBASE.Syria.Hama, {"CAP_Blue_Syria"}, 4)
    A2ADispatcherSyria:SetSquadronTakeoffFromRunway("Syria CAPW")
    A2ADispatcherSyria:SetSquadronCap2("Syria CAPW", 1000, 2000, 2000, 10000, "BARO", ZoneCAPSyriaW, 600, 800, 4000, 8000, "RADIO")
    A2ADispatcherSyria:SetSquadronCapInterval("Syria CAPW", 1, 60, 120, 1)
    A2ADispatcherSyria:SetSquadronGrouping("Syria CAPW", 2)
    A2ADispatcherSyria:SetSquadronGci("Syria CAPW", 1000, 2000)
    -- CAP East
    A2ADispatcherSyria:SetSquadron("Syria CAPE", AIRBASE.Syria.Palmyra, {"CAP_Blue_Syria"}, 4)
    A2ADispatcherSyria:SetSquadronTakeoffFromRunway("Syria CAPE")
    A2ADispatcherSyria:SetSquadronCap2("Syria CAPE", 1000, 2000, 2000, 10000, "BARO", ZoneCAPSyriaE, 600, 800, 4000, 8000, "RADIO")
    A2ADispatcherSyria:SetSquadronCapInterval("Syria CAPE", 1, 60, 120, 1)
    A2ADispatcherSyria:SetSquadronGrouping("Syria CAPE", 2)
    A2ADispatcherSyria:SetSquadronGci("Syria CAPE", 1000, 2000)
    -- GCI West
    A2ADispatcherSyria:SetSquadron("Syria GCIW", AIRBASE.Syria.Abu_al_Duhur, {"GCI_Blue_Syria"}, 2)
    A2ADispatcherSyria:SetSquadronTakeoffFromRunway("Syria GCIW")
    A2ADispatcherSyria:SetSquadronGrouping("Syria GCIW", 2)
    A2ADispatcherSyria:SetSquadronGci("Syria GCIW", 1000, 2000)
    -- GCI Est
    A2ADispatcherSyria:SetSquadron("Syria GCIE", AIRBASE.Syria.Tabqa, {"GCI_Blue_Syria"}, 2)
    A2ADispatcherSyria:SetSquadronTakeoffFromRunway("Syria GCIE")
    A2ADispatcherSyria:SetSquadronGrouping("Syria GCIE", 2)
    A2ADispatcherSyria:SetSquadronGci("Syria GCIE", 1000, 2000)

-- RED

    local ZoneCAPRed = ZONE_POLYGON:New("WPT_CAP_Red", GROUP:FindByName("WPT_CAP_Red"))
    local DetectionRed = DETECTION_AREAS:New(EWR.Red, 150000)

    -- AUFTRAG Tanker

    local AuftragTankerRed = AUFTRAG:NewTANKER(ZONE:New("ZONE_Tanker_Red"):GetCoordinate(), 20000, 350, 105, 20)
    AuftragTankerRed:SetTime(10)
    AuftragTankerRed:SetRepeat(99)
    local AuftragTankerRedFG = FLIGHTGROUP:New("TANKER_Red_IL78")
    --AuftragTankerRedFG:SetHomebase(AIRBASE:FindByName(AIRBASE.Syria.Damascus))
    AuftragTankerRedFG:AddMission(AuftragTankerRed)
    function AuftragTankerRedFG:onafterSpawned(From, Event, To)
        local AuftragEscortTankerRed = AUFTRAG:NewESCORT(AuftragTankerRedFG:GetGroup())
        local AuftragEscortTankerRedFG = FLIGHTGROUP:New("Escort_Red")
        --AuftragEscortTankerRedFG:SetHomebase(AIRBASE:FindByName(AIRBASE.Syria.Mezzeh))
        AuftragEscortTankerRedFG:AddMission(AuftragEscortTankerRed)
    end

    -- CAP/GCI Red

    local A2ADispatcherRed = AI_A2A_DISPATCHER:New(DetectionRed)

    A2ADispatcherRed:SetBorderZone({BORDER.Red})
    A2ADispatcherRed:SetDefaultFuelThreshold(0.4)
    A2ADispatcherRed:SetDefaultGrouping(2)
    A2ADispatcherRed:SetDefaultOverhead(2)
    A2ADispatcherRed:SetDefaultLandingAtRunway()
    A2ADispatcherRed:SetDefaultTanker("TANKER_Red_IL78")
    A2ADispatcherRed:SetTacticalDisplay(TacticalDisplay)
    -- CAP
    A2ADispatcherRed:SetSquadron("Red CAP", AIRBASE.Syria.An_Nasiriyah, {"CAP_Red"}, 4)
    A2ADispatcherRed:SetSquadronTakeoffFromRunway("Red CAP")
    A2ADispatcherRed:SetSquadronCap2("Red CAP", 1000, 2000, 2000, 10000, "BARO", ZoneCAPRed, 600, 800, 4000, 8000, "RADIO")
    A2ADispatcherRed:SetSquadronCapInterval("Red CAP", 1, 60, 120, 1)
    A2ADispatcherRed:SetSquadronGrouping("Red CAP", 2)
    A2ADispatcherRed:SetSquadronGci("Red CAP", 1000, 2000)
    -- GCI Nord
    A2ADispatcherRed:SetSquadron("Red GCIN", AIRBASE.Syria.An_Nasiriyah, {"GCI_Red"}, 2)
    A2ADispatcherRed:SetSquadronTakeoffFromRunway("Red GCIN")
    A2ADispatcherRed:SetSquadronGrouping("Red GCIN", 2)
    A2ADispatcherRed:SetSquadronGci("Red GCIN", 1000, 2000)
    -- GCI Sud
    A2ADispatcherRed:SetSquadron("Red GCIS", AIRBASE.Syria.Mezzeh, {"GCI_Red"}, 2)
    A2ADispatcherRed:SetSquadronTakeoffFromRunway("Red GCIS")
    A2ADispatcherRed:SetSquadronGrouping("Red GCIS", 2)
    A2ADispatcherRed:SetSquadronGci("Red GCIS", 1000, 2000)
