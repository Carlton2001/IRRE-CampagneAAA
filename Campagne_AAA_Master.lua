---------------------------------------------------------------------------------------------------
-- INITIALISATIONS
---------------------------------------------------------------------------------------------------

-- Settings MOOSE

_SETTINGS:SetPlayerMenuOff()
RAT.ATCswitch = false

-- Inits

EnvProd = false

if EnvProd == false then
    MessageToAll("DEVELOPPEMENT", 120)
    TacticalDisplay = true
end

local DangerZone = {}
DangerZone.S300 = 125000
DangerZone.Hawk = 50000

local Country = {}
Country.IsraelOTAN = {"USA", "ISRAEL"}
Country.IsisOpposition = {"TURQEY", "CJTF_BLUE"}

-- Border Zones

local BORDER    = {}
BORDER.Blue     = {}

BORDER.Red              = ZONE_POLYGON:New("BORDER_Red", GROUP:FindByName("BORDER_Red"))
BORDER.Blue.Israel      = ZONE_POLYGON:New("BORDER_Blue_Israel", GROUP:FindByName("BORDER_Blue_Israel"))
BORDER.Blue.Syria       = ZONE_POLYGON:New("BORDER_Blue_Syria", GROUP:FindByName("BORDER_Blue_Syria"))
BORDER.Blue.Turkey      = ZONE_POLYGON:New("BORDER_Blue_Turkey", GROUP:FindByName("BORDER_Blue_Turkey"))
BORDER.Blue.OTAN        = ZONE_POLYGON:New("BORDER_Blue_OTAN", GROUP:FindByName("BORDER_Blue_OTAN"))

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
AIR.Blue    = {}

AIR.Red                 = SET_GROUP:New():FilterCoalitions("red"):FilterCategoryAirplane():FilterStart()
AIR.Blue.All            = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterStart()
AIR.Blue.IsraelOTAN     = SET_GROUP:New():FilterCoalitions("blue"):FilterCountries(Country.IsraelOTAN):FilterCategoryAirplane():FilterStart()
AIR.Blue.IsisOpposition = SET_GROUP:New():FilterCoalitions("blue"):FilterCountries(Country.IsisOpposition):FilterCategoryAirplane():FilterStart()

-- GCI Detection Sets

local EWR = {}

EWR.Red             = SET_GROUP:New():FilterPrefixes({"SAM_Red"}):FilterStart()
EWR.Israel          = SET_GROUP:New():FilterPrefixes({"SAM_Blue_Israel"}):FilterStart()
EWR.OTAN            = SET_GROUP:New():FilterPrefixes({"NAVAL_Blue_Cyprus_OTAN", "AWACS_Blue_OTAN"}):FilterStart()
EWR.Turkey          = SET_GROUP:New():FilterPrefixes({"SAM_Blue_Turkey"}):FilterStart()
EWR.IsisOpposition  = SET_GROUP:New():FilterPrefixes({"SAM_Blue_Syria"}):FilterStart()

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

SchedulerBorderDefense = SCHEDULER:New( nil,
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

        if AIR.Red:CountAlive() >= 1 then
            BlueSamBorderDefense(SAM.Blue.Israel.Haifa_Patriot, BORDER.Blue.Israel, AIR.Red)
            BlueSamBorderDefense(SAM.Blue.Israel.Megiddo_Patriot, BORDER.Blue.Israel, AIR.Red)
            BlueSamBorderDefense(SAM.Blue.Turkey.CB22_S300, BORDER.Blue.Turkey, AIR.Red)
            BlueSamBorderDefense(SAM.Blue.Turkey.DB30_S300, BORDER.Blue.Turkey, AIR.Red)
            BlueSamBorderDefense(SAM.Blue.Turkey.IF25_S300, BORDER.Blue.Turkey, AIR.Red)
            BlueSamBorderDefense(NAVAL.Blue.Cyprus_OTAN, BORDER.Blue.OTAN, AIR.Red)
        end

        -- BORDER Reds
        local function RedSamBorderDefense(sam, zonesam)
            -- Autorisation de tir pour les SAM rouges en fonction de la présence de bandits à l'intérieur de la frontière
            -- ou de la nationalité des bandits à l'intérieur de la zone de tir du SAM
            if sam then
                if AIR.Blue.IsraelOTAN:AnyInZone(BORDER.Red) or AIR.Blue.IsisOpposition:AnyInZone(zonesam) then
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
-- BORDER CAP GCI LOGIC
---------------------------------------------------------------------------------------------------

-- ISRAEL

    ZoneCAPIsrael = ZONE_POLYGON:New("WPT_CAP_Israel", GROUP:FindByName("WPT_CAP_Israel"))
    DetectionIsrael = DETECTION_AREAS:New(EWR.Israel, 150000)

    -- CAP/GCI Israel

    A2ADispatcherIsrael = AI_A2A_DISPATCHER:New(DetectionIsrael)

    A2ADispatcherIsrael:SetBorderZone({BORDER.Blue.Israel})
    A2ADispatcherIsrael:SetDefaultFuelThreshold(0.4)
    A2ADispatcherIsrael:SetDefaultGrouping(2)
    A2ADispatcherIsrael:SetDefaultOverhead(2)
    A2ADispatcherIsrael:SetDefaultLandingAtRunway()
    A2ADispatcherIsrael:SetTacticalDisplay(TacticalDisplay)
    -- CAP
    A2ADispatcherIsrael:SetSquadron("Ramat David CAP", AIRBASE.Syria.Ramat_David, {"CAP_Blue_Israel"}, 4)
    A2ADispatcherIsrael:SetSquadronTakeoffFromRunway("Ramat David CAP")
    --A2ADispatcherIsrael:SetSquadronCap("Ramat David CAP", ZoneCAPIsrael, 2000, 10000, 50, 400, 1000, 2000)
    A2ADispatcherIsrael:SetSquadronCap2("Ramat David CAP", 1000, 2000, 2000, 10000, "BARO", ZoneCAPIsrael, 600, 800, 4000, 8000, "RADIO")
    A2ADispatcherIsrael:SetSquadronCapInterval("Ramat David CAP", 1, 60, 120, 1)
    A2ADispatcherIsrael:SetSquadronGrouping("Ramat David CAP", 2)
    A2ADispatcherIsrael:SetSquadronGci("Ramat David CAP", 1000, 2000)
    -- GCI
    A2ADispatcherIsrael:SetSquadron("Ramat David GCi", AIRBASE.Syria.Ramat_David, {"GCI_Blue_Israel"}, 2)
    A2ADispatcherIsrael:SetSquadronTakeoffFromRunway("Ramat David GCi")
    A2ADispatcherIsrael:SetSquadronGrouping("Ramat David GCi", 2)
    A2ADispatcherIsrael:SetSquadronGci("Ramat David GCi", 1000, 2000)

-- OTAN

    ZoneCAPOTAN = ZONE_POLYGON:New("WPT_CAP_OTAN", GROUP:FindByName("WPT_CAP_OTAN"))
    DetectionOTAN = DETECTION_AREAS:New(EWR.OTAN, 150000)

    -- AUFTRAG AWACS

    local AuftragAWACSOTAN = AUFTRAG:NewAWACS(ZONE:New("ZONE_AWACS_OTAN"):GetCoordinate(), 35000, 350, 25, 20)
    local AuftragAWACSOTANFG = FLIGHTGROUP:New("AWACS_Blue_OTAN")
    AuftragAWACSOTANFG:AddMission(AuftragAWACSOTAN)

    -- AUFTRAG Tanker

    local AuftragTankerSOTAN = AUFTRAG:NewTANKER(ZONE:New("ZONE_Tanker_OTAN"):GetCoordinate(), 6000, 350, 25, 20)
    AuftragTankerSOTAN:SetTime(30)
    AuftragTankerSOTAN:SetRepeat(99)
    local AuftragTankerSOTANFG = FLIGHTGROUP:New("TANKER_Blue_OTAN")
    AuftragTankerSOTANFG:AddMission(AuftragTankerSOTAN)

    -- CAP/GCI OTAN

    A2ADispatcherOTAN = AI_A2A_DISPATCHER:New(DetectionOTAN)

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
    --A2ADispatcherOTAN:SetSquadronCap("OTAN CAP1", ZoneCAPOTAN, 2000, 10000, 50, 400, 1000, 2000)
    A2ADispatcherOTAN:SetSquadronCap2("OTAN CAP1", 1000, 2000, 2000, 10000, "BARO", ZoneCAPOTAN, 600, 800, 4000, 8000, "RADIO")
    A2ADispatcherOTAN:SetSquadronCapInterval("OTAN CAP1", 1, 60, 120, 1)
    A2ADispatcherOTAN:SetSquadronGrouping("OTAN CAP1", 2)
    A2ADispatcherOTAN:SetSquadronGci("OTAN CAP1", 1000, 2000)
    -- CAP 2
    A2ADispatcherOTAN:SetSquadron("OTAN CAP2", "NAVAL_Blue_Cyprus_OTAN_Carrier", {"CAP_Blue_OTAN"}, 4)
    A2ADispatcherOTAN:SetSquadronTakeoffFromParkingHot("OTAN CAP2")
    --A2ADispatcherOTAN:SetSquadronCap("OTAN CAP2", ZoneCAPOTAN, 2000, 10000, 50, 400, 1000, 2000)
    A2ADispatcherOTAN:SetSquadronCap2("OTAN CAP2", 1000, 2000, 2000, 10000, "BARO", ZoneCAPOTAN, 600, 800, 4000, 8000, "RADIO")
    A2ADispatcherOTAN:SetSquadronCapInterval("OTAN CAP2", 1, 600, 660, 1)
    A2ADispatcherOTAN:SetSquadronGrouping("OTAN CAP2", 2)
    A2ADispatcherOTAN:SetSquadronGci("OTAN CAP2", 1000, 2000)
    -- GCI
    A2ADispatcherOTAN:SetSquadron("OTAN GCi", "NAVAL_Blue_Cyprus_OTAN_Carrier", {"GCI_Blue_OTAN"}, 2)
    A2ADispatcherOTAN:SetSquadronTakeoffFromParkingHot("OTAN GCi")
    A2ADispatcherOTAN:SetSquadronGrouping("OTAN GCi", 2)
    A2ADispatcherOTAN:SetSquadronGci("OTAN GCi", 1000, 2000)