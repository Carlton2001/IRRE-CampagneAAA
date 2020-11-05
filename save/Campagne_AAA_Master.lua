---------------------------------------------------------------------------------------------------
-- INITIALISATIONS
---------------------------------------------------------------------------------------------------

-- Settings MOOSE

_SETTINGS:SetPlayerMenuOff()
RAT.ATCswitch = false

-- Inits

EnvProd = false
if EnvProd == false then MessageToAll("DEVELOPPEMENT", 120) end

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
BORDER.Blue.OTAN_Fleet  = ZONE_POLYGON:New("BORDER_Blue_OTAN_Fleet", GROUP:FindByName("BORDER_Blue_OTAN_Fleet"))

-- Border Smoke pour rigoler
if EnvProd == false then
    BORDER.Red:SmokeZone(SMOKECOLOR.Red)
    BORDER.Blue.Israel:SmokeZone(SMOKECOLOR.Blue)
    BORDER.Blue.Syria:SmokeZone(SMOKECOLOR.Blue)
    BORDER.Blue.Turkey:SmokeZone(SMOKECOLOR.Blue)
    BORDER.Blue.OTAN_Fleet:SmokeZone(SMOKECOLOR.Blue)
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
SAM.Red.Lebanon.Beirut_Hawk       = GROUP:FindByName("SAM_Red_Lebanon_Beirut_Hawk"):Activate()

-- SAM Zones

local SAMzone = {}

if SAM.Red.Syria.AlQusayr_Hawk then SAMzone.AlQusayr_Hawk = ZONE_GROUP:New("Zone_AlQusayr_Hawk", SAM.Red.Syria.AlQusayr_Hawk, DangerZone.Hawk) end
if SAM.Red.Syria.Damascus_S300 then SAMzone.Damascus_S300 = ZONE_GROUP:New("Zone_Damascus_S300", SAM.Red.Syria.Damascus_S300, DangerZone.S300) end
if SAM.Red.Lebanon.Beirut_Hawk then SAMzone.Beirut_Hawk = ZONE_GROUP:New("Zone_Beirut_Hawk", SAM.Red.Lebanon.Beirut_Hawk, DangerZone.Hawk) end

-- NAVAL Groups

local NAVAL = {}
NAVAL.Blue  = {}
NAVAL.Red   = {}

NAVAL.Blue.Cyprus_FlotteOTAN = GROUP:FindByName("NAVAL_Blue_Cyprus_FlotteOTAN"):Activate()

-- Air Groups

local AIR   = {}
AIR.Blue    = {}

AIR.Red                 = SET_GROUP:New():FilterCoalitions("red"):FilterCategoryAirplane():FilterStart()
AIR.Blue.All            = SET_GROUP:New():FilterCoalitions("blue"):FilterCategoryAirplane():FilterStart()
AIR.Blue.IsraelOTAN     = SET_GROUP:New():FilterCoalitions("blue"):FilterCountries(Country.IsraelOTAN):FilterCategoryAirplane():FilterStart()
AIR.Blue.IsisOpposition = SET_GROUP:New():FilterCoalitions("blue"):FilterCountries(Country.IsisOpposition):FilterCategoryAirplane():FilterStart()

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
            BlueSamBorderDefense(NAVAL.Blue.Cyprus_FlotteOTAN, BORDER.Blue.OTAN_Fleet, AIR.Red)
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