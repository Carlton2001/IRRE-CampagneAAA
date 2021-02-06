-- Settings MOOSE

_SETTINGS:SetPlayerMenuOff()
RAT.ATCswitch = false

---------------------------------------------------------------------------------------------------
-- MISSION CONSTANTES
---------------------------------------------------------------------------------------------------

    --[[ POINTS D'ATTENTION

        CAP2 OTAN désactivée
        CAPE TURQUEY désactivée

    ]]

    -- A désactiver en PROD

    local EnvProd = true

    -- Fréquences Radio - Attention Callsigns & Radios du EWR et des GCI/CAP à paramétrer dans l'EM

    local RadioGeneral = 305.00
    local RadioTanker1 = 132.00 -- Texaco (KC130)
    local RadioTanker2 = 138.50 -- Arco (IL78)
    local RadioTanker3 = 134.50 -- Shell (KC135)
    local RadioTanker4 = 136.00 -- Texaco2 (KC135MPRS)

    -- Direction des vents (cf ME)

    local WIND = {}
    WIND.High   = 215   -- 26000 ft
    WIND.Medium = 210   -- 6600 ft
    WIND.Low    = 235   -- 1600 ft

---------------------------------------------------------------------------------------------------
-- INITIALISATIONS
---------------------------------------------------------------------------------------------------

    -- DEV

    if EnvProd == false then
        MessageToAll("DEVELOPPEMENT", 120)
        TacticalDisplay = true
    end

    -- COMMS
    local FunRadio = STATIC:FindByName("FunRadio"):GetRadio()
    FunRadio:SetFrequency(RadioGeneral)
    FunRadio:SetModulation(radio.modulation.AM)
    FunRadio:SetPower(1000)

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
    SAM.Blue.Syria.Tabqa_S300       = GROUP:FindByName("SAM_Blue_Syria_Tabqa_S300"):Activate()
    --SAM.Blue.Syria.Hama_SA15        = GROUP:FindByName("SAM_Blue_Syria_Hama_SA15"):Activate()
    SAM.Blue.Turkey.CB22_S300       = GROUP:FindByName("SAM_Blue_Turkey_CB22_S300"):Activate()
    SAM.Blue.Turkey.DB30_S300       = GROUP:FindByName("SAM_Blue_Turkey_DB30_S300"):Activate()
    SAM.Blue.Turkey.IF25_S300       = GROUP:FindByName("SAM_Blue_Turkey_IF25_S300"):Activate()
    SAM.Red.Syria.AlQusayr_Hawk     = GROUP:FindByName("SAM_Red_Syria_AlQusayr_Hawk"):Activate()
    SAM.Red.Syria.Damascus_S300     = GROUP:FindByName("SAM_Red_Syria_Damascus_S300"):Activate()
    SAM.Red.Syria.AnNasiriyah_SA15  = GROUP:FindByName("SAM_Red_Syria_AnNasiriyah_SA15"):Activate()
    SAM.Red.Syria.Mezzeh_SA15       = GROUP:FindByName("SAM_Red_Syria_Mezzeh_SA15"):Activate()
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

    NAVAL.Blue.Cyprus_OTAN = GROUP:FindByName("NAVAL_Blue_Cyprus_OTAN")

    -- Air Groups

    local AIR   = {}
    AIR.Red     = {}
    AIR.Blue    = {}

    AIR.Red.All             = SET_GROUP:New():FilterCoalitions("red"):FilterCategories({"plane"}):FilterStart()
    AIR.Red.GCICAP          = SET_GROUP:New():FilterCoalitions("red"):FilterCategoryAirplane():FilterPrefixes{"CAP_Red", "GCI_Red"}:FilterStart()
    AIR.Red.Players         = SET_GROUP:New():FilterCoalitions("red"):FilterCategories({"plane", "helicopter"}):FilterPrefixes{"Cli_"}:FilterStart()
    AIR.Red.PlayersHelos    = SET_GROUP:New():FilterCoalitions("red"):FilterCategories({"helicopter"}):FilterPrefixes{"Cli_"}:FilterStart()
    AIR.Blue.All            = SET_GROUP:New():FilterCoalitions("blue"):FilterCategories({"plane"}):FilterStart()
    AIR.Blue.IsraelOTAN     = SET_GROUP:New():FilterCoalitions("blue"):FilterCountries(COUNTRY.IsraelOTAN):FilterCategoryAirplane():FilterStart()
    AIR.Blue.TurkeySyria    = SET_GROUP:New():FilterCoalitions("blue"):FilterCountries(COUNTRY.TurkeySyria):FilterCategoryAirplane():FilterStart()

    -- GCI Detection Sets

    local EWR = {}

    EWR.Red     = SET_GROUP:New():FilterPrefixes({"SAM_Red", "EWR_Red"}):FilterStart():FilterStop()
    EWR.Israel  = SET_GROUP:New():FilterPrefixes({"SAM_Blue_Israel"}):FilterStart():FilterStop()
    EWR.OTAN    = SET_GROUP:New():FilterPrefixes({"NAVAL_Blue_Cyprus_OTAN", "AWACS_Blue_OTAN"}):FilterStart():FilterStop()
    EWR.Turkey  = SET_GROUP:New():FilterPrefixes({"SAM_Blue_Turkey"}):FilterStart():FilterStop()
    EWR.Syria   = SET_GROUP:New():FilterPrefixes({"SAM_Blue_Syria"}):FilterStart():FilterStop()

    -- WindsInverter

    local function WindsInverter (Wind)
        local result
        local test = Wind + 180
        if test >= 360 then result = Wind - 180 else result = test end
        return result
    end
    WIND.High   = WindsInverter(WIND.High)
    WIND.Medium = WindsInverter(WIND.Medium)
    WIND.Low    = WindsInverter(WIND.Low)

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
-- TANKER FUNCTIONS
---------------------------------------------------------------------------------------------------

    function LaunchTanker (GroupName, TANKERTYPE, PATTERN, COMMS, HomeBase, TACAN, FuelLow, DepartureTime, ESCORT)
        -- AUFTRAG TANKER
        local MissionTanker = AUFTRAG:NewTANKER(ZONE:New(PATTERN.ZoneName):GetCoordinate(), PATTERN.Altitude, PATTERN.Speed, PATTERN.Heading, PATTERN.Leg, TANKERTYPE.Type)
        if TACAN then MissionTanker:SetTACAN(TACAN.Channel, TACAN.Morse, nil, TACAN.Band) end
        MissionTanker:SetTime(DepartureTime)
        -- FLIGHTGROUP TANKER
        local Tanker = FLIGHTGROUP:New(GroupName)
        Tanker:SetHomebase(AIRBASE:FindByName(HomeBase))
        Tanker:SwitchRadio(COMMS.Frequency, radio.modulation.AM)
        --Tanker:SetDefaultCallsign(Callsign, 1) -- Suspiçion de bug Moose avec le SetDefaultCallsign des tankers
        Tanker:SetFuelLowThreshold(FuelLow)
        Tanker:AddMission(MissionTanker)
        function Tanker:OnAfterSpawned (From, Event, To)
            GROUP:FindByName(GroupName):CommandSetCallsign(COMMS.Callsign, 1) -- Contournement bug Moose avec le SetDefaultCallsign des tankers
            -- TANKER ESCORT
            if ESCORT then
                BASE:E(ESCORT.Name)
                local MissionEscort = AUFTRAG:NewESCORT(Tanker:GetGroup(), {x=-100, y=100, z=200}, 20)
                local Escort = FLIGHTGROUP:New(ESCORT.Name)
                Escort:SetDefaultFormation(ENUMS.Formation.FixedWing.FighterVic.Close)
                Escort:SetDefaultCallsign(ESCORT.Callsign, ESCORT.CallsignNumber)
                Escort:SwitchRadio(RadioGeneral, radio.modulation.AM)
                Escort:SetFuelLowThreshold(40)
                Escort:SetFuelLowRefuel(true)
                Escort:AddMission(MissionEscort)
            end
        end
        -- TANKER FUEL STATUS
        function Tanker:onafterAirborne (From, Event, To)
            local SchedulerTanker = SCHEDULER:New( nil, TankerFuelStatus, {GroupName, COMMS, TANKERTYPE.Fuel, FuelLow/100}, 1, 30)
        end
    end

    -- TANKER FUEL STATUS
    function TankerFuelStatus (GroupName, COMMS, FuelWeight, FuelLow)
        local Callsign = nil
        for key, value in pairs(CALLSIGN.Tanker) do
            if value == COMMS.Callsign then
                Callsign = key
            end
        end
        local Group = GROUP:FindByName(GroupName)
        local FuelLeft = math.floor(FuelWeight * (Group:GetFuel() - FuelLow))
        if FuelLeft > 0 then
            local GroupRadio = Group:GetRadio()
            GroupRadio:SetFileName("Blank.ogg")
            GroupRadio:SetFrequency(COMMS.Frequency)
            GroupRadio:SetModulation(radio.modulation.AM)
            GroupRadio:SetSubtitle(Callsign .. ", fuel left : " .. FuelLeft .. " lbs", 3)
            GroupRadio:Broadcast()
        end
    end

---------------------------------------------------------------------------------------------------
-- BORDER CAP/GCI LOGIC
---------------------------------------------------------------------------------------------------

    -- OTAN

        function CAPGCI_OTAN ()
            NAVAL.Blue.Cyprus_OTAN:Activate()
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
            local ZoneCAPOTAN = ZONE:New("ZONE_CAP_OTAN")
            local DetectionOTAN = DETECTION_AREAS:New(EWR.OTAN, 150000)
            local A2ADispatcherOTAN = AI_A2A_DISPATCHER:New(DetectionOTAN)
            A2ADispatcherOTAN:SetBorderZone({BORDER.Blue.OTAN})
            A2ADispatcherOTAN:SetDisengageRadius(130000)
            A2ADispatcherOTAN:SetDefaultGrouping(2)
            A2ADispatcherOTAN:SetDefaultOverhead(2)
            A2ADispatcherOTAN:SetDefaultTakeoffFromParkingHot()
            A2ADispatcherOTAN:SetTacticalDisplay(TacticalDisplay)
            -- CAP 1
            A2ADispatcherOTAN:SetSquadron("OTAN CAP1", "NAVAL_Blue_Cyprus_OTAN_Carrier", {"CAP_Blue_OTAN"}, 4)
            A2ADispatcherOTAN:SetSquadronCap2("OTAN CAP1", 800, 2000, 2000, 10000, "BARO", ZoneCAPOTAN, 600, 600, 8000, 9000, "BARO")
            A2ADispatcherOTAN:SetSquadronCapRacetrack("OTAN CAP1", 40000, 40000, 30, 30, 40*60, 40*60)
            A2ADispatcherOTAN:SetSquadronCapInterval("OTAN CAP1", 1, 60, 120, 1)
            A2ADispatcherOTAN:SetSquadronGrouping("OTAN CAP1", 2)
            -- CAP 2
            -- A2ADispatcherOTAN:SetSquadron("OTAN CAP2", "NAVAL_Blue_Cyprus_OTAN_Carrier", {"CAP_Blue_OTAN"}, 4)
            -- A2ADispatcherOTAN:SetSquadronCap2("OTAN CAP2", 800, 2000, 2000, 10000, "BARO", ZoneCAPOTAN, 600, 650, 8000, 9000, "BARO")
            -- A2ADispatcherOTAN:SetSquadronCapRacetrack("OTAN CAP2", 40000, 40000, 30, 30, 40*60, 40*60)
            -- A2ADispatcherOTAN:SetSquadronCapInterval("OTAN CAP2", 1, 60, 120, 1)
            -- A2ADispatcherOTAN:SetSquadronGrouping("OTAN CAP2", 2)
            -- GCI
            A2ADispatcherOTAN:SetSquadron("OTAN GCI", "NAVAL_Blue_Cyprus_OTAN_Carrier", {"GCI_Blue_OTAN"}, 4)
            A2ADispatcherOTAN:SetSquadronGrouping("OTAN GCI", 2)
            A2ADispatcherOTAN:SetSquadronGci("OTAN GCI", 800, 2000)
        end

    -- ISRAEL

        function CAPGCI_ISRAEL ()
            -- CAP/GCI Israel
            local ZoneCAPIsrael = ZONE:New("ZONE_CAP_Israel")
            local DetectionIsrael = DETECTION_AREAS:New(EWR.Israel, 150000)
            local A2ADispatcherIsrael = AI_A2A_DISPATCHER:New(DetectionIsrael)
            A2ADispatcherIsrael:SetBorderZone({BORDER.Blue.Israel})
            A2ADispatcherIsrael:SetDisengageRadius(90000)
            A2ADispatcherIsrael:SetDefaultGrouping(2)
            A2ADispatcherIsrael:SetDefaultOverhead(2)
            A2ADispatcherIsrael:SetDefaultTakeoffInAir()
            A2ADispatcherIsrael:SetDefaultLandingAtRunway()
            A2ADispatcherIsrael:SetTacticalDisplay(TacticalDisplay)
            -- CAP
            A2ADispatcherIsrael:SetSquadron("Israel CAP", AIRBASE.Syria.Ramat_David, {"CAP_Blue_Israel"}, 4)
            A2ADispatcherIsrael:SetSquadronCap2("Israel CAP", 800, 2000, 2000, 10000, "BARO", ZoneCAPIsrael, 600, 600, 8000, 9000, "BARO")
            A2ADispatcherIsrael:SetSquadronCapRacetrack("Israel CAP", 40000, 40000, 60, 60, 40*60, 40*60)
            A2ADispatcherIsrael:SetSquadronCapInterval("Israel CAP", 1, 60, 120, 1)
            A2ADispatcherIsrael:SetSquadronGrouping("Israel CAP", 2)
            -- GCI
            A2ADispatcherIsrael:SetSquadron("Israel GCI", AIRBASE.Syria.Ramat_David, {"GCI_Blue_Israel"}, 4)
            A2ADispatcherIsrael:SetSquadronGrouping("Israel GCI", 2)
            A2ADispatcherIsrael:SetSquadronGci("Israel GCI", 800, 2000)
        end

    -- TURKEY

        function CAPGCI_TURKEY ()
            -- CAP/GCI Turkey
            local ZoneCAPTurkeyW = ZONE:New("ZONE_CAP_TurkeyW")
            local ZoneCAPTurkeyE = ZONE:New("ZONE_CAP_TurkeyE")
            local DetectionTurkey = DETECTION_AREAS:New(EWR.Turkey, 150000)
            local A2ADispatcherTurkey = AI_A2A_DISPATCHER:New(DetectionTurkey)
            A2ADispatcherTurkey:SetBorderZone({BORDER.Blue.Turkey})
            A2ADispatcherTurkey:SetDefaultGrouping(2)
            A2ADispatcherTurkey:SetDefaultOverhead(2)
            A2ADispatcherTurkey:SetDefaultLandingAtRunway()
            A2ADispatcherTurkey:SetDefaultTakeoffInAir()
            A2ADispatcherTurkey:SetTacticalDisplay(TacticalDisplay)
            -- CAP West
            A2ADispatcherTurkey:SetSquadron("Turkey CAPW", AIRBASE.Syria.Incirlik, {"CAP_Blue_Turkey"}, 4)
            A2ADispatcherTurkey:SetSquadronCap2("Turkey CAPW", 800, 2000, 2000, 10000, "BARO", ZoneCAPTurkeyW, 600, 800, 8000, 9000, "BARO")
            A2ADispatcherTurkey:SetSquadronCapRacetrack("Turkey CAPW", 40000, 40000, 46, 46, 40*60, 40*60)
            A2ADispatcherTurkey:SetSquadronCapInterval("Turkey CAPW", 1, 60, 120, 1)
            A2ADispatcherTurkey:SetSquadronGrouping("Turkey CAPW", 2)
            -- -- CAP East
            -- A2ADispatcherTurkey:SetSquadron("Turkey CAPE", AIRBASE.Syria.Incirlik, {"CAP_Blue_Turkey"}, 4)
            -- A2ADispatcherTurkey:SetSquadronCap2("Turkey CAPE", 800, 2000, 2000, 10000, "BARO", ZoneCAPTurkeyE, 600, 600, 8000, 9000, "BARO")
            -- A2ADispatcherTurkey:SetSquadronCapRacetrack("Turkey CAPE", 40000, 40000, 70, 70, 40*60, 40*60)
            -- A2ADispatcherTurkey:SetSquadronCapInterval("Turkey CAPE", 1, 60, 120, 1)
            -- A2ADispatcherTurkey:SetSquadronGrouping("Turkey CAPE", 2)
            -- GCI
            A2ADispatcherTurkey:SetSquadron("Turkey GCI", AIRBASE.Syria.Incirlik, {"GCI_Blue_Turkey"}, 4)
            A2ADispatcherTurkey:SetSquadronGrouping("Turkey GCI", 2)
            A2ADispatcherTurkey:SetSquadronGci("Turkey GCI", 800, 2000)
        end

    -- SYRIA

        function CAPGCI_SYRIA ()
            -- CAP/GCI Syria
            local ZoneCAPSyriaW = ZONE:New("ZONE_CAP_SyriaW")
            local ZoneCAPSyriaE = ZONE:New("ZONE_CAP_SyriaE")
            local DetectionSyria = DETECTION_AREAS:New(EWR.Syria, 150000)
            local A2ADispatcherSyria = AI_A2A_DISPATCHER:New(DetectionSyria)
            A2ADispatcherSyria:SetBorderZone({BORDER.Blue.Syria})
            A2ADispatcherSyria:SetDisengageRadius(90000)
            A2ADispatcherSyria:SetDefaultGrouping(2)
            A2ADispatcherSyria:SetDefaultOverhead(1)
            A2ADispatcherSyria:SetDefaultTakeoffInAir()
            A2ADispatcherSyria:SetDefaultLandingAtRunway()
            A2ADispatcherSyria:SetTacticalDisplay(TacticalDisplay)
            -- CAP West
            A2ADispatcherSyria:SetSquadron("Syria CAPW", AIRBASE.Syria.Hama, {"CAP_Blue_Syria"}, 4)
            A2ADispatcherSyria:SetSquadronCap2("Syria CAPW", 800, 2000, 2000, 10000, "BARO", ZoneCAPSyriaW, 600, 600, 8000, 9000, "BARO")
            A2ADispatcherSyria:SetSquadronCapRacetrack("Syria CAPW", 40000, 40000, 100, 100, 40*60, 40*60)
            A2ADispatcherSyria:SetSquadronCapInterval("Syria CAPW", 1, 60, 120, 1)
            A2ADispatcherSyria:SetSquadronGrouping("Syria CAPW", 2)
            -- CAP East
            A2ADispatcherSyria:SetSquadron("Syria CAPE", AIRBASE.Syria.Tabqa, {"CAP_Blue_Syria"}, 4)
            A2ADispatcherSyria:SetSquadronCap2("Syria CAPE", 800, 2000, 2000, 10000, "BARO", ZoneCAPSyriaE, 600, 600, 8000, 9000, "BARO")
            A2ADispatcherSyria:SetSquadronCapRacetrack("Syria CAPE", 40000, 40000, 90, 90, 40*60, 40*60)
            A2ADispatcherSyria:SetSquadronCapInterval("Syria CAPE", 1, 60, 120, 1)
            A2ADispatcherSyria:SetSquadronGrouping("Syria CAPE", 2)
            -- GCI West
            A2ADispatcherSyria:SetSquadron("Syria GCIW", AIRBASE.Syria.Hama, {"GCI_Blue_Syria"}, 4)
            A2ADispatcherSyria:SetSquadronGrouping("Syria GCIW", 2)
            A2ADispatcherSyria:SetSquadronGci("Syria GCIW", 800, 2000)
            -- GCI Est
            A2ADispatcherSyria:SetSquadron("Syria GCIE", AIRBASE.Syria.Tabqa, {"GCI_Blue_Syria"}, 4)
            A2ADispatcherSyria:SetSquadronGrouping("Syria GCIE", 2)
            A2ADispatcherSyria:SetSquadronGci("Syria GCIE", 800, 2000)
        end

    -- RED

        function CAPGCI_RED ()
            -- CAP/GCI Red
            local ZoneCAPRed = ZONE:New("ZONE_CAP_Red")
            local DetectionRed = DETECTION_AREAS:New(EWR.Red, 150000)
            local A2ADispatcherRed = AI_A2A_DISPATCHER:New(DetectionRed)
            A2ADispatcherRed:SetBorderZone({BORDER.Red})
            A2ADispatcherRed:SetDisengageRadius(150000)
            A2ADispatcherRed:SetDefaultGrouping(2)
            A2ADispatcherRed:SetDefaultOverhead(1)
            A2ADispatcherRed:SetDefaultTakeoffInAir()
            A2ADispatcherRed:SetDefaultLandingAtRunway()
            A2ADispatcherRed:SetDefaultLandingAtRunway()
            A2ADispatcherRed:SetDefaultTanker("TANKER_Red_IL78")
            -- CAP
            A2ADispatcherRed:SetSquadron("Red CAP", AIRBASE.Syria.An_Nasiriyah, {"CAP_Red"}, 4)
            A2ADispatcherRed:SetSquadronCap2("Red CAP", 800, 2000, 2000, 10000, "BARO", ZoneCAPRed, 600, 600, 8000, 9000, "BARO")
            A2ADispatcherRed:SetSquadronCapRacetrack("Red CAP", 40000, 40000, 122, 122, 40*60, 40*60)
            A2ADispatcherRed:SetSquadronCapInterval("Red CAP", 1, 60, 120, 1)
            A2ADispatcherRed:SetSquadronGrouping("Red CAP", 2)
            -- GCI Nord
            A2ADispatcherRed:SetSquadron("Red GCIN", AIRBASE.Syria.An_Nasiriyah, {"GCI_Red"}, 2)
            A2ADispatcherRed:SetSquadronGrouping("Red GCIN", 2)
            A2ADispatcherRed:SetSquadronGci("Red GCIN", 800, 2000)
            -- GCI Sud
            A2ADispatcherRed:SetSquadron("Red GCIS", AIRBASE.Syria.Marj_Ruhayyil, {"GCI_Red"}, 2)
            A2ADispatcherRed:SetSquadronGrouping("Red GCIS", 2)
            A2ADispatcherRed:SetSquadronGci("Red GCIS", 800, 2000)
        end

---------------------------------------------------------------------------------------------------
-- MISSION 03
---------------------------------------------------------------------------------------------------

    -- RED Ambiance

            -- AUFTRAG ORBIT
            local auftragOrbitAmbiance = AUFTRAG:NewORBIT(ZONE:New("ZONE_Ambiance-1"):GetCoordinate(), 2700, 100)
            -- FLIGHTGROUP
            local Ambiance_Red_Mi8 = FLIGHTGROUP:New("Ambiance_Red_Huey")
            Ambiance_Red_Mi8:SetDefaultFormation(ENUMS.Formation.RotaryWing.EchelonRight.D70)
            Ambiance_Red_Mi8:AddMission(auftragOrbitAmbiance)
            Ambiance_Red_Mi8:Activate()

    -- RED EWR

        function Spawn_EWR_Red ()
            GROUP:FindByName("EWR_Red"):Activate()
        end

    -- RED Tankers

        function Auftrag_Red_Tankers ()

            -- -- Texaco KC130
            -- LaunchTanker (
            --     "TANKER_Red_KC130", -- GroupName
            --     TANKER.KC130, -- TANKERTYPE
            --     {["ZoneName"] = "ZONE_Tanker_Red-1", ["Altitude"] = 20000, ["Speed"] = 350, ["Heading"] = WIND.Low, ["Leg"] = 20}, -- PATTERN
            --     {["Frequency"] = RadioTanker1, ["Callsign"] = CALLSIGN.Tanker.Texaco}, -- COMMS
            --     AIRBASE.Syria.Damascus, -- HomeBase
            --     {["Channel"] = 28, ["Morse"] = "TEX", ["Band"] = "Y"}, -- TACAN
            --     10, -- FuelLow (%) Sert au calcul du carburant restant pour l'annonce radio
            --     10, -- DepartureTime (s)
            --     {["Name"] = "Escort_Red_Tanker1", ["Callsign"] = CALLSIGN.Aircraft.Springfield, ["CallsignNumber"] = 2} -- ESCORT
            -- )

            -- Arco IL78
            LaunchTanker (
                "TANKER_Red_IL78", -- GroupName
                TANKER.IL78, -- TANKERTYPE
                {["ZoneName"] = "ZONE_Tanker_Red-2", ["Altitude"] = 20000, ["Speed"] = 350, ["Heading"] = WIND.High, ["Leg"] = 20}, -- PATTERN
                {["Frequency"] = RadioTanker2, ["Callsign"] = CALLSIGN.Tanker.Arco}, -- COMMS
                AIRBASE.Syria.Damascus, -- HomeBase
                {["Channel"] = 25, ["Morse"] = "ARC", ["Band"] = "Y"}, -- TACAN
                10, -- FuelLow (%) Sert au calcul du carburant restant pour l'annonce radio
                10, -- DepartureTime (s)
                {["Name"] = "Escort_Red_Tanker2", ["Callsign"] = CALLSIGN.Aircraft.Springfield, ["CallsignNumber"] = 2} -- ESCORT
            )

            -- Shell KC135
            LaunchTanker (
                "TANKER_Red_KC135", -- GroupName
                TANKER.KC135, -- TANKERTYPE
                {["ZoneName"] = "ZONE_Tanker_Red-3", ["Altitude"] = 18000, ["Speed"] = 350, ["Heading"] = WIND.High, ["Leg"] = 20}, -- PATTERN
                {["Frequency"] = RadioTanker3, ["Callsign"] = CALLSIGN.Tanker.Shell}, -- COMMS
                AIRBASE.Syria.Damascus, -- HomeBase
                {["Channel"] = 34, ["Morse"] = "SHL", ["Band"] = "Y"}, -- TACAN
                10, -- FuelLow (%) Sert au calcul du carburant restant pour l'annonce radio
                10, -- DepartureTime (s)
                {["Name"] = "Escort_Red_Tanker3", ["Callsign"] = CALLSIGN.Aircraft.Springfield, ["CallsignNumber"] = 3} -- ESCORT
            )

            -- -- Texaco KC135MPRS
            -- LaunchTanker (
            --     "TANKER_Red_KC135MPRS", -- GroupName
            --     TANKER.KC135MPRS, -- TANKERTYPE
            --     {["ZoneName"] = "ZONE_Tanker_Red-4", ["Altitude"] = 20000, ["Speed"] = 350, ["Heading"] = WIND.High, ["Leg"] = 20}, -- PATTERN
            --     {["Frequency"] = RadioTanker4, ["Callsign"] = CALLSIGN.Tanker.Texaco}, -- COMMS
            --     AIRBASE.Syria.Damascus, -- HomeBase
            --     {["Channel"] = 39, ["Morse"] = "TEX", ["Band"] = "Y"}, -- TACAN
            --     10, -- FuelLow (%) Sert au calcul du carburant restant pour l'annonce radio
            --     10, -- DepartureTime (s)
            --     {["Name"] = "Escort_Red_Tanker4", ["Callsign"] = CALLSIGN.Aircraft.Springfield, ["CallsignNumber"] = 4} -- ESCORT
            -- )

        end

    -- Interception Général

        local CivilFlight = FLIGHTGROUP:New("M03_Neutral_General")

        function CivilRTB()
            local TimerVar = TIMER:New(
                function()
                    MessageToAll("OK, RTB ;(", 40)
                    CivilFlight:RTB(AIRBASE:FindByName(AIRBASE.Syria.Beirut_Rafic_Hariri))
                    MenuCivilRTB:Remove()
                    SchedulerRefreshMenus:Stop()
                end
            )
            TimerVar:Start(1)
        end

        SchedulerRefreshMenus = SCHEDULER:New( nil,
            function()
                if AIR.Red.Players:CountAlive() >= 1 then
                    local zone_CivilFlight = ZONE_GROUP:New("Zone_CivilFlight", CivilFlight, 400)
                    if AIR.Red.Players:AnyInZone(zone_CivilFlight) then
                        MessageToAll("In the zone", 2)
                        MenuCivilRTB = MENU_MISSION_COMMAND:New("ReturnToBase", nil, CivilRTB)
                    else
                        if MenuCivilRTB then MenuCivilRTB:Remove() end
                    end
                end
            end, {}, 1, 5
        )

    -- Récupération pilotes

        local ZoneFumiWest = ZONE:New("M03_Zone_FumiWest")
        local ZoneFumiEast = ZONE:New("M03_Zone_FumiEast")

        local ZoneFumiWest_Once = false
        local ZoneFumiEast_Once = false

        function RecupSmoke (ZoneFumi)
            if AIR.Red.PlayersHelos:AnyInZone(ZoneFumiWest) and ZoneFumiWest_Once == false then
                ZoneFumiWest:GetCoordinate():SmokeGreen()
                ZoneFumiWest_Once = true
            end
            if AIR.Red.PlayersHelos:AnyInZone(ZoneFumiEast) and ZoneFumiEast_Once == false then
                ZoneFumiEast:GetCoordinate():SmokeGreen()
                ZoneFumiEast_Once = true
            end
            if ZoneFumiWest_Once == true and ZoneFumiEast_Once == true then
                SchedulerStartSmoke:Stop()
            end
        end

        SchedulerStartSmoke = SCHEDULER:New(nil, RecupSmoke, {}, 1, 10)

    -- Executions

        -- Configuration Generale

            CAPGCI_TURKEY()
            CAPGCI_OTAN()
            CAPGCI_ISRAEL()
            CAPGCI_SYRIA()
            CAPGCI_RED()
            Spawn_EWR_Red()
            Auftrag_Red_Tankers()
