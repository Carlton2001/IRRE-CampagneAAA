---------------------------------------------------------------------------------------------------
-- MISSION CONSTANTES
---------------------------------------------------------------------------------------------------

    -- A désactiver en PROD

    local EnvProd = true

    -- Fréquence Radio - Attention Callsigns & Radios du EWR et des GCI/CAP à paramétrer dans l'EM

    local RadioGeneral = 305.00
    local RadioTanker1 = 260.00 -- Texaco
    local RadioTanker2 = 265.00 -- Arco
    local RadioTanker3 = 266.00 -- Shell

    -- Provenances du vent

    local WIND = {}
    WIND.High   = 227   -- 26000 ft
    WIND.Medium = 223   -- 6600 ft
    WIND.Low    = 221   -- 1600 ft

---------------------------------------------------------------------------------------------------
-- INITIALISATIONS
---------------------------------------------------------------------------------------------------

    -- Settings MOOSE

    _SETTINGS:SetPlayerMenuOff()
    RAT.ATCswitch = false

    -- Inits

    if EnvProd == false then
        MessageToAll("DEVELOPPEMENT", 120)
        TacticalDisplay = true
    end

    local DANGERZONE = {}
    DANGERZONE.S300 = 125000
    DANGERZONE.Hawk = 50000

    local COUNTRY = {}
    COUNTRY.IsraelOTAN = {"USA", "ISRAEL"}
    COUNTRY.TurkeySyria = {"TURQEY", "CJTF_BLUE"}

    local TANKER = {} -- Type : perche = 0, panier = 1
    TANKER.IL78 = {}
    TANKER.KC130 = {}
    TANKER.KC135 = {}
    TANKER.KC135MPRS = {}
    TANKER.S3B = {}

    TANKER.IL78.Type        = 1
    TANKER.IL78.Fuel        = 198416
    TANKER.KC130.Type       = 1
    TANKER.KC130.Fuel       = 66139
    TANKER.KC135.Type       = 0
    TANKER.KC135.Fuel       = 199959
    TANKER.KC135MPRS.Type   = 1
    TANKER.KC135MPRS.Fuel   = 199959
    TANKER.S3B.Type         = 1
    TANKER.S3B.Fuel         = 17225

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

    if SAM.Red.Syria.AlQusayr_Hawk then SAMzone.AlQusayr_Hawk = ZONE_GROUP:New("Zone_AlQusayr_Hawk", SAM.Red.Syria.AlQusayr_Hawk, DANGERZONE.Hawk) end
    if SAM.Red.Syria.Damascus_S300 then SAMzone.Damascus_S300 = ZONE_GROUP:New("Zone_Damascus_S300", SAM.Red.Syria.Damascus_S300, DANGERZONE.S300) end
    if SAM.Red.Lebanon.Beirut_Hawk then SAMzone.Beirut_Hawk = ZONE_GROUP:New("Zone_Beirut_Hawk", SAM.Red.Lebanon.Beirut_Hawk, DANGERZONE.Hawk) end

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
    AIR.Blue.IsraelOTAN     = SET_GROUP:New():FilterCoalitions("blue"):FilterCountries(COUNTRY.IsraelOTAN):FilterCategoryAirplane():FilterStart()
    AIR.Blue.TurkeySyria    = SET_GROUP:New():FilterCoalitions("blue"):FilterCountries(COUNTRY.TurkeySyria):FilterCategoryAirplane():FilterStart()

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

    --[[ Rules

        ■ Blue SAMs

        OTAN/ISRAEL/TURKEY Vs RED : Border OpenFire
        SYRIA Vs RED : OpenFire ASAP

        ■ Red SAMs

        RED Vs OTAN/ISRAEL : Border OpenFire
        RED Vs SYRIA/TURQUEY : OpenFire ASAP               ]]--

    -- BORDER Blues
        local function BlueSamBorderDefense (sam, border, bandits)
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

    -- BORDER Reds
        local function RedSamBorderDefense (sam, zonesam)
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

    -- Scheduler
        SchedulerBorderDefenses = SCHEDULER:New( nil,
            function ()
                if AIR.Red.All:CountAlive() >= 1 then
                    BlueSamBorderDefense (SAM.Blue.Israel.Haifa_Patriot, BORDER.Blue.Israel, AIR.Red.All)
                    BlueSamBorderDefense (SAM.Blue.Israel.Megiddo_Patriot, BORDER.Blue.Israel, AIR.Red.All)
                    BlueSamBorderDefense (SAM.Blue.Turkey.CB22_S300, BORDER.Blue.Turkey, AIR.Red.All)
                    BlueSamBorderDefense (SAM.Blue.Turkey.DB30_S300, BORDER.Blue.Turkey, AIR.Red.All)
                    BlueSamBorderDefense (SAM.Blue.Turkey.IF25_S300, BORDER.Blue.Turkey, AIR.Red.All)
                    BlueSamBorderDefense (NAVAL.Blue.Cyprus_OTAN, BORDER.Blue.OTAN, AIR.Red.All)
                end
                if AIR.Blue.All:CountAlive() >= 1 then
                    RedSamBorderDefense (SAM.Red.Syria.AlQusayr_Hawk, SAMzone.AlQusayr_Hawk)
                    RedSamBorderDefense (SAM.Red.Syria.Damascus_S300, SAMzone.Damascus_S300)
                    RedSamBorderDefense (SAM.Red.Lebanon.Beirut_Hawk, SAMzone.Beirut_Hawk)
                end
            end, {}, 1, 10
        )

---------------------------------------------------------------------------------------------------
-- BREVITY RED GCICAP
---------------------------------------------------------------------------------------------------

    function AIR.Red.GCICAP:OnAfterAdded (From, Event, To, ObjectName, Object)
        local NewGroup = GROUP:FindByName(ObjectName)
        NewGroup:HandleEvent(EVENTS.Shot)
        NewGroup:HandleEvent(EVENTS.ShootingStart)
        local GroupRadio = NewGroup:GetRadio()
        GroupRadio:SetFrequency(RadioGeneral)
        GroupRadio:SetModulation(radio.modulation.AM)

        function NewGroup:OnEventShot (EventData)
            local Brevity = "none"
            local WeaponDesc = EventData.Weapon:getDesc() -- https://wiki.hoggitworld.com/view/DCS_enum_weapon
            if WeaponDesc.category == 3 then
                Brevity = "Pickle_" .. math.random(2) .. ".ogg"
            elseif WeaponDesc.category == 1 then
                if WeaponDesc.guidance == 1 then
                    if WeaponDesc.missileCategory == 4 then
                        Brevity = "LongRifle_" .. math.random(2) .. ".ogg"
                    elseif WeaponDesc.missileCategory == 6 then
                        Brevity = "Rifle_" .. math.random(2) .. ".ogg"
                    end
                elseif WeaponDesc.guidance == 2 then
                    Brevity = "Fox2_" .. math.random(2) .. ".ogg"
                elseif WeaponDesc.guidance == 3 then
                    Brevity = "Fox3_" .. math.random(2) .. ".ogg"
                elseif WeaponDesc.guidance == 4 then
                    Brevity = "Fox1_" .. math.random(2) .. ".ogg"
                elseif WeaponDesc.guidance == 5 and WeaponDesc.missileCategory == 6 then
                    Brevity = "Magnum_" .. math.random(2) .. ".ogg"
                elseif WeaponDesc.guidance == 7 then
                    Brevity = "Rifle_" .. math.random(2) .. ".ogg"
                end
            end
            if Brevity ~= "none"  then
                GroupRadio:SetFileName(Brevity)
                GroupRadio:Broadcast()
            end
        end

        function NewGroup:OnEventShootingStart (EventData)
            local Brevity = "Guns_" .. math.random(2) .. ".ogg"
            GroupRadio:SetFileName(Brevity)
            GroupRadio:Broadcast()
        end

    end

---------------------------------------------------------------------------------------------------
-- PLUMES & FIRES
---------------------------------------------------------------------------------------------------

    local ZonesDestruction = SET_ZONE:New():FilterPrefixes("Zone_Destroy"):FilterStart():FilterStop():ForEachZone(
        function (zone)
            -- Smoke + Fire : 1,2,3,4 - Smoke : 5,6,7,8
            local coords = zone:GetCoordinate()
            if      string.match(zone.ZoneName, "SmallFireSmoke")   then coords:BigSmokeAndFire(1, 0.5)
            elseif  string.match(zone.ZoneName, "MediumFireSmoke")  then coords:BigSmokeAndFire(2, 0.5)
            elseif  string.match(zone.ZoneName, "LargeFireSmoke")   then coords:BigSmokeAndFire(3, 0.5)
            elseif  string.match(zone.ZoneName, "HugeFireSmoke")    then coords:BigSmokeAndFire(4, 0.5)
            elseif  string.match(zone.ZoneName, "SmallSmoke")       then coords:BigSmokeAndFire(5, 0.5)
            elseif  string.match(zone.ZoneName, "MediumSmoke")      then coords:BigSmokeAndFire(6, 0.5)
            elseif  string.match(zone.ZoneName, "LargeSmoke")       then coords:BigSmokeAndFire(7, 0.5)
            elseif  string.match(zone.ZoneName, "HugeSmoke")        then coords:BigSmokeAndFire(8, 0.5)
            end
        end
    )

---------------------------------------------------------------------------------------------------
-- TANKER FUNCTIONS
---------------------------------------------------------------------------------------------------

    function LaunchTanker (GroupName, ZoneName, PATTERN, TANKERTYPE, FuelLow, Radio, Callsign, HomeBase, DepartureTime, TACAN)
        -- AUFTRAG TANKER
        local MissionTanker = AUFTRAG:NewTANKER(ZONE:New(ZoneName):GetCoordinate(), PATTERN.Altitude, PATTERN.Speed, PATTERN.Heading, PATTERN.Leg, TANKERTYPE.Type)
        if TACAN then MissionTanker:SetTACAN(TACAN.Channel, TACAN.Morse, nil, TACAN.Band) end
        MissionTanker:SetTime(DepartureTime)
        -- FLIGHTGROUP TANKER
        local Tanker = FLIGHTGROUP:New(GroupName)
        Tanker:SetHomebase(AIRBASE:FindByName(HomeBase))
        Tanker:SwitchRadio(Radio, radio.modulation.AM)
        --Tanker:SetDefaultCallsign(Callsign, 1) -- Suspiçion de bug Moose avec le SetDefaultCallsign des tankers
        Tanker:SetFuelLowThreshold(FuelLow)
        Tanker:AddMission(MissionTanker)
        function Tanker:onafterSpawned (From, Event, To)
            GROUP:FindByName(GroupName):CommandSetCallsign(Callsign, 1) -- Contournement bug Moose avec le SetDefaultCallsign des tankers
            -- TANKER DUEL STATUS
            local SchedulerTanker = SCHEDULER:New( nil, TankerFuelStatus, {GroupName, Callsign, TANKERTYPE.Fuel, FuelLow/100, Radio}, 1, 30)
        end
    end

    -- TANKER FUEL STATUS
    function TankerFuelStatus (GroupName, CallsignNumber, FuelWeight, FuelLow, Frequency)
        local Callsign = nil
        for key, value in pairs(CALLSIGN.Tanker) do
            if value == CallsignNumber then
                Callsign = key
            end
        end
        local Group = GROUP:FindByName(GroupName)
        local FuelLeft = math.floor(FuelWeight * (Group:GetFuel() - FuelLow))
        if FuelLeft > 0 then
            local GroupRadio = Group:GetRadio()
            GroupRadio:SetFileName("Blank.ogg")
            GroupRadio:SetFrequency(Frequency)
            GroupRadio:SetModulation(radio.modulation.AM)
            GroupRadio:SetSubtitle(Callsign .. ", fuel left : " .. FuelLeft .. " lbs", 3)
            GroupRadio:Broadcast()
        end
    end

---------------------------------------------------------------------------------------------------
-- BORDER CAP/GCI LOGIC
---------------------------------------------------------------------------------------------------

    -- OTAN

        -- RECOVERYTANKER
        local TankerOTAN = RECOVERYTANKER:New(UNIT:FindByName("NAVAL_Blue_Cyprus_OTAN_Carrier"), "TANKER_Blue_OTAN")
        TankerOTAN:SetAltitude(6000)
        TankerOTAN:SetSpeed(350)
        TankerOTAN:SetTakeoffHot()
        TankerOTAN:Start()

        -- RECOVERYAWACS
        local AwacsOTAN = RECOVERYTANKER:New("NAVAL_Blue_Cyprus_OTAN_Carrier", "AWACS_Blue_OTAN")
        AwacsOTAN:SetAWACS()
        AwacsOTAN:SetAltitude(20000)
        AwacsOTAN:SetTakeoffHot()
        AwacsOTAN:Start()

        -- CAP/GCI OTAN

        local ZoneCAPOTAN = ZONE_POLYGON:New("WPT_CAP_OTAN", GROUP:FindByName("WPT_CAP_OTAN"))
        local DetectionOTAN = DETECTION_AREAS:New(EWR.OTAN, 150000)
        local A2ADispatcherOTAN = AI_A2A_DISPATCHER:New(DetectionOTAN)
        A2ADispatcherOTAN:SetBorderZone({BORDER.Blue.OTAN})
        A2ADispatcherOTAN:SetDefaultFuelThreshold(0.4)
        A2ADispatcherOTAN:SetDefaultGrouping(2)
        A2ADispatcherOTAN:SetDefaultOverhead(2)
        A2ADispatcherOTAN:SetDefaultLandingAtRunway()
        A2ADispatcherOTAN:SetTacticalDisplay(TacticalDisplay)
        -- CAP 1
        A2ADispatcherOTAN:SetSquadron("OTAN CAP1", "NAVAL_Blue_Cyprus_OTAN_Carrier", {"CAP_Blue_OTAN"}, 4)
        A2ADispatcherOTAN:SetSquadronTakeoffFromParkingHot("OTAN CAP1")
        A2ADispatcherOTAN:SetSquadronCap2("OTAN CAP1", 1000, 2000, 2000, 10000, "BARO", ZoneCAPOTAN, 600, 800, 4000, 8000, "RADIO")
        A2ADispatcherOTAN:SetSquadronCapInterval("OTAN CAP1", 1, 60, 120, 1)
        A2ADispatcherOTAN:SetSquadronGrouping("OTAN CAP1", 2)
        -- CAP 2
        A2ADispatcherOTAN:SetSquadron("OTAN CAP2", "NAVAL_Blue_Cyprus_OTAN_Carrier", {"CAP_Blue_OTAN"}, 4)
        A2ADispatcherOTAN:SetSquadronTakeoffFromParkingHot("OTAN CAP2")
        A2ADispatcherOTAN:SetSquadronCap2("OTAN CAP2", 1000, 2000, 2000, 10000, "BARO", ZoneCAPOTAN, 600, 800, 4000, 8000, "RADIO")
        A2ADispatcherOTAN:SetSquadronCapInterval("OTAN CAP2", 1, 600, 660, 1)
        A2ADispatcherOTAN:SetSquadronGrouping("OTAN CAP2", 2)
        -- GCI
        A2ADispatcherOTAN:SetSquadron("OTAN GCI", "NAVAL_Blue_Cyprus_OTAN_Carrier", {"GCI_Blue_OTAN"}, 2)
        A2ADispatcherOTAN:SetSquadronTakeoffFromParkingHot("OTAN GCI")
        A2ADispatcherOTAN:SetSquadronGrouping("OTAN GCI", 2)
        A2ADispatcherOTAN:SetSquadronGci("OTAN GCI", 1000, 2000)

    -- ISRAEL

        -- CAP/GCI Israel

        local ZoneCAPIsrael = ZONE_POLYGON:New("WPT_CAP_Israel", GROUP:FindByName("WPT_CAP_Israel"))
        local DetectionIsrael = DETECTION_AREAS:New(EWR.Israel, 150000)
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
        -- GCI
        A2ADispatcherIsrael:SetSquadron("Israel GCI", AIRBASE.Syria.Ramat_David, {"GCI_Blue_Israel"}, 2)
        A2ADispatcherIsrael:SetSquadronTakeoffFromRunway("Israel GCI")
        A2ADispatcherIsrael:SetSquadronGrouping("Israel GCI", 2)
        A2ADispatcherIsrael:SetSquadronGci("Israel GCI", 1000, 2000)

    -- TURKEY

        -- CAP/GCI Turkey
        local ZoneCAPTurkeyW = ZONE_POLYGON:New("WPT_CAP_TurkeyW", GROUP:FindByName("WPT_CAP_TurkeyW"))
        local ZoneCAPTurkeyE = ZONE_POLYGON:New("WPT_CAP_TurkeyE", GROUP:FindByName("WPT_CAP_TurkeyE"))
        local DetectionTurkey = DETECTION_AREAS:New(EWR.Turkey, 150000)
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
        -- CAP East
        A2ADispatcherTurkey:SetSquadron("Turkey CAPE", AIRBASE.Syria.Incirlik, {"CAP_Blue_Turkey"}, 4)
        A2ADispatcherTurkey:SetSquadronTakeoffFromRunway("Turkey CAPE")
        A2ADispatcherTurkey:SetSquadronCap2("Turkey CAPE", 1000, 2000, 2000, 10000, "BARO", ZoneCAPTurkeyE, 600, 800, 4000, 8000, "RADIO")
        A2ADispatcherTurkey:SetSquadronCapInterval("Turkey CAPE", 1, 60, 120, 1)
        A2ADispatcherTurkey:SetSquadronGrouping("Turkey CAPE", 2)
        -- GCI
        A2ADispatcherTurkey:SetSquadron("Turkey GCI", AIRBASE.Syria.Incirlik, {"GCI_Blue_Turkey"}, 2)
        A2ADispatcherTurkey:SetSquadronTakeoffFromRunway("Turkey GCI")
        A2ADispatcherTurkey:SetSquadronGrouping("Turkey GCI", 2)
        A2ADispatcherTurkey:SetSquadronGci("Turkey GCI", 1000, 2000)

    -- SYRIA

        -- CAP/GCI Syria
        local ZoneCAPSyriaW = ZONE_POLYGON:New("WPT_CAP_SyriaW", GROUP:FindByName("WPT_CAP_SyriaW"))
        local ZoneCAPSyriaE = ZONE_POLYGON:New("WPT_CAP_SyriaE", GROUP:FindByName("WPT_CAP_SyriaE"))
        local DetectionSyria = DETECTION_AREAS:New(EWR.Syria, 150000)
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
        -- CAP East
        A2ADispatcherSyria:SetSquadron("Syria CAPE", AIRBASE.Syria.Palmyra, {"CAP_Blue_Syria"}, 4)
        A2ADispatcherSyria:SetSquadronTakeoffFromRunway("Syria CAPE")
        A2ADispatcherSyria:SetSquadronCap2("Syria CAPE", 1000, 2000, 2000, 10000, "BARO", ZoneCAPSyriaE, 600, 800, 4000, 8000, "RADIO")
        A2ADispatcherSyria:SetSquadronCapInterval("Syria CAPE", 1, 60, 120, 1)
        A2ADispatcherSyria:SetSquadronGrouping("Syria CAPE", 2)
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

        -- CAP/GCI Red

            -- Callsigns & Radios à paramétrer dans l'EM
            local ZoneCAPRed = ZONE_POLYGON:New("WPT_CAP_Red", GROUP:FindByName("WPT_CAP_Red"))
            local DetectionRed = DETECTION_AREAS:New(EWR.Red, 150000)
            local A2ADispatcherRed = AI_A2A_DISPATCHER:New(DetectionRed)
            A2ADispatcherRed:SetBorderZone({BORDER.Red})
            A2ADispatcherRed:SetDefaultFuelThreshold(0.4)
            A2ADispatcherRed:SetDefaultGrouping(2)
            A2ADispatcherRed:SetDefaultOverhead(2)
            A2ADispatcherRed:SetDefaultLandingAtRunway()
            A2ADispatcherRed:SetTacticalDisplay(TacticalDisplay)
            -- CAP
            A2ADispatcherRed:SetSquadron("Red CAP", AIRBASE.Syria.An_Nasiriyah, {"CAP_Red"}, 4)
            A2ADispatcherRed:SetSquadronTakeoffFromRunway("Red CAP")
            A2ADispatcherRed:SetSquadronCap2("Red CAP", 1000, 2000, 2000, 10000, "BARO", ZoneCAPRed, 600, 800, 4000, 8000, "RADIO")
            A2ADispatcherRed:SetSquadronCapInterval("Red CAP", 1, 60, 120, 1)
            A2ADispatcherRed:SetSquadronGrouping("Red CAP", 2)
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

---------------------------------------------------------------------------------------------------
-- MISSION 01
---------------------------------------------------------------------------------------------------

    -- RED EWR

        function Spawn_EWR_Red ()
            GROUP:FindByName("EWR_Red"):Activate()
        end

    -- RED Tankers

        function Auftrag_M01_Red_Tankers ()
            -- Arco
            LaunchTanker (
                "TANKER_Red_IL78", -- GroupName
                "ZONE_Tanker_Red", -- ZoneName
                {["Altitude"] = 20000, ["Speed"] = 350, ["Heading"] = WIND.High, ["Leg"] = 20}, -- PATTERN
                TANKER.IL78, -- TANKERTYPE
                10, -- FuelLow (%)
                RadioTanker2, -- Radio
                CALLSIGN.Tanker.Arco, -- Callsign
                AIRBASE.Syria.Damascus, -- HomeBase
                10, -- DepartureTime (s)
                {["Channel"] = 11, ["Morse"] = "ARC", ["Band"] = "Y"} -- TACAN
            )
        end

    -- RED Su-24

        function Auftrag_M01_Red_AttackConvoi ()
            -- TARGET
            local target = GROUP:FindByName("M01_Blue_Convoi"):GetCoordinate()
            -- AUFTRAG
            local auftrag = AUFTRAG:NewBOMBING(target)
            auftrag:SetROT(ENUMS.ROT.NoReaction)
            auftrag:SetWeaponExpend(AI.Task.WeaponExpend.ALL)
            auftrag:SetWeaponType(ENUMS.WeaponFlag.AnyUnguided)
            auftrag:SetMissionWaypointCoord(ZONE:New("M01_Zone_M01_IP"):GetCoordinate())
            auftrag:SetMissionAltitude(3000)
            auftrag:SetEngageAltitude(3000)
            auftrag:SetMissionSpeed(350)
              -- FLIGHTGROUP
            local bomber = FLIGHTGROUP:New("M01_Red_Su24")
            bomber:AddWaypoint(ZONE:New("M01_Zone_M01_WPT1"):GetCoordinate(), nil, nil, 12500)
            bomber:AddWaypoint(ZONE:New("M01_Zone_M01_WPT2"):GetCoordinate(), nil, nil, 12500)
            bomber:AddWaypoint(ZONE:New("M01_Zone_M01_WPT3"):GetCoordinate(), nil, nil, 6500)
            bomber:SwitchRadio(RadioGeneral, radio.modulation.AM)
            bomber:SetDefaultCallsign(CALLSIGN.Aircraft.Uzi, 9)
            bomber:SetDefaultFormation(ENUMS.Formation.FixedWing.FighterVic.Close)
            bomber:HandleEvent(EVENTS.Shot)
            bomber:AddMission(auftrag)
            bomber:Activate()

            -- BREVITY Su-24
            SET_UNIT:New():FilterPrefixes("M01_Red_Su24"):FilterStart():FilterStop():ForEachUnit(
                function (unit)
                    unit:HandleEvent(EVENTS.Shot)
                    function unit:OnEventShot (EventData)
                        local WeaponDesc = EventData.Weapon:getDesc()
                        if WeaponDesc.category == 3 then
                            local Brevity = "Ripple_" .. math.random(2) .. ".ogg"
                            local UnitRadio = unit:GetRadio()
                            UnitRadio:SetFileName(Brevity)
                            UnitRadio:SetFrequency(RadioGeneral)
                            UnitRadio:SetModulation(radio.modulation.AM)
                            UnitRadio:Broadcast()
                            unit:UnHandleEvent(EVENTS.Shot)
                        end
                    end
                end
            )

            function bomber:OnAfterPassingWaypoint (From, Event, To, Waypoint)
                if Waypoint.uid == 3 then bomber:SwitchFormation(ENUMS.Formation.FixedWing.Trail.Close) end
            end

            function auftrag:OnAfterDone (From,Event,To)
                for _,opsgroup in pairs(auftrag:GetOpsGroups()) do
                    local flightgroup = opsgroup
                    flightgroup:SwitchFormation(ENUMS.Formation.FixedWing.FighterVic.Close)
                    flightgroup:RTB(AIRBASE:FindByName(AIRBASE.Syria.Mezzeh))
                end
            end
        end

    -- Executions

        Spawn_EWR_Red ()
        Auftrag_M01_Red_Tankers ()
        Auftrag_M01_Red_AttackConvoi ()