---------------------------------------------------------------------------------------------------
-- INITIALISATIONS
---------------------------------------------------------------------------------------------------

-- Settings MOOSE

_SETTINGS:SetPlayerMenuOff()
RAT.ATCswitch = false

-- Inits

EnvProd = false

-- Border Zones

local BORDER = {}
BORDER.Blue = {}
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

-- SAM Systems

local SAM = {}
SAM.Blue        = {}
SAM.Red         = {}
SAM.Blue.Israel = {}
SAM.Blue.Syria  = {}
SAM.Blue.Turkey = {}
SAM.Red.Lebanon = {}
SAM.Red.Syria   = {}

SAM.Blue.Israel.HatzorHaglilit_Patriot = GROUP:FindByName("SAM_Blue_Israel_HatzorHaglilit_Patriot"):Activate()
SAM.Blue.Israel.Tuberias_Patriot = GROUP:FindByName("SAM_Blue_Israel_Tuberias_Patriot"):Activate()
-- SAM.Blue.Syria.AbuAlDuhur_Hawk = GROUP:FindByName("SAM_Blue_Syria_AbuAlDuhur_Hawk"):Activate()
-- SAM.Blue.Syria.EinElkorum_S300 = GROUP:FindByName("SAM_Blue_Syria_EinElkorum_S300"):Activate()
-- SAM.Blue.Syria.Idlib_Hawk = GROUP:FindByName("SAM_Blue_Syria_Idlib_Hawk"):Activate()
-- SAM.Blue.Syria.KuweiresJirah_Hawk = GROUP:FindByName("SAM_Blue_Syria_KuweiresJirah_Hawk"):Activate()
-- SAM.Blue.Syria.Minakh_S300 = GROUP:FindByName("SAM_Blue_Syria_Minakh_S300"):Activate()
-- SAM.Blue.Syria.Palmyra_Hawk = GROUP:FindByName("SAM_Blue_Syria_Palmyra_Hawk"):Activate()
-- SAM.Blue.Syria.Raqqa_Hawk = GROUP:FindByName("SAM_Blue_Syria_Raqqa_Hawk"):Activate()
-- SAM.Blue.Syria.Tabqa_S300 = GROUP:FindByName("SAM_Blue_Syria_Tabqa_S300"):Activate()
SAM.Blue.Turkey.CB22_S300 = GROUP:FindByName("SAM_Blue_Turkey_CB22_S300"):Activate()
SAM.Blue.Turkey.DB30_S300 = GROUP:FindByName("SAM_Blue_Turkey_DB30_S300"):Activate()
SAM.Blue.Turkey.IF25_S300 = GROUP:FindByName("SAM_Blue_Turkey_IF25_S300"):Activate()
-- SAM.Red.Lebanon.Beirut_S300 = GROUP:FindByName("SAM_Red_Lebanon_Beirut_S300"):Activate()
-- SAM.Red.Lebanon.Tripoli_S300 = GROUP:FindByName("SAM_Red_Lebanon_Tripoli_S300"):Activate()
-- SAM.Red.Syria.AnNasiriyah_S300 = GROUP:FindByName("SAM_Red_Syria_AnNasiriyah_S300"):Activate()
-- SAM.Red.Syria.AsSanamayn_S300 = GROUP:FindByName("SAM_Red_Syria_AsSanamayn_S300"):Activate()
-- SAM.Red.Syria.Homs_Hawk = GROUP:FindByName("SAM_Red_Syria_Homs_Hawk"):Activate()
-- SAM.Red.Syria.Mezzeh_S300 = GROUP:FindByName("SAM_Red_Syria_Mezzeh_S300"):Activate()

-- NAVAL

local NAVAL = {}
NAVAL.Blue  = {}
NAVAL.Red   = {}

NAVAL.Blue.Cyprus_FlotteOTAN = GROUP:FindByName("NAVAL_Blue_Cyprus_FlotteOTAN"):Activate()

-- Air

local AIR = {}

BlueAIR = SET_GROUP:New():FilterCoalitions( "blue" ):FilterCategoryAirplane():FilterStart()
RedAIR = SET_GROUP:New():FilterCoalitions( "red" ):FilterCategoryAirplane():FilterStart()

---------------------------------------------------------------------------------------------------
-- BORDER SAM LOGIC
---------------------------------------------------------------------------------------------------

-- ■ Défenses bleues

-- Défense ISRAEL
-- PATRIOT x2 => tirent si on passe la frontière israelienne.
-- + Interception 2/3 F16 ou F15 (Fox-3) - Reviennent chez eux si on se casse de la zone.

-- Défense TURQUIE
-- S300 x3 : tirent si on passe la frontière turque.
-- + Interception 2/3 F16 (Fox-3) (Reviennent chez eux si on se casse de la zone)

-- Défense OTAN :
-- Flotte : Tire si on passe la frontière des eaux territoriales.
-- + Interception 2/3 F16 (Fox-3) (Reviennent chez eux si on se casse de la zone)

-- Défense ISIS+OPPOSITON SYRIENNE :
-- S300 + HAWK : tirent sans limite de frontière.
-- + Interception (Fox-2 max) - appareils et nombre à définir.

-- ■ Défense ROUGES :

-- Vs Israel :
-- S300 + HAWK : tirent si ils passent la frontière.

-- Vs OTAN :
-- S300 + HAWK : tirent si ils passent la frontière.

-- Vs Turquie :
-- S300 + HAWK : tirent sans limite de frontière.

-- Vs ISIS+OPPOSITION :
-- S300 + HAWK : tirent sans limite de frontière.

SchedulerBorderDefense = SCHEDULER:New( nil,
    function()
        -- Autorisation de tir pour les SAM/Naval en fonction de la présence de bandits à l'intérieur de la frontière
        local function samBorderDefense(sam, border, bandits)
            if sam then
                if bandits:AnyInZone(border) then
                    sam:OptionROEOpenFire()
                else
                    sam:OptionROEHoldFire()
                end
            end
        end
        -- BORDER Blues
        if RedAIR:CountAlive() >= 1 then
            samBorderDefense(SAM.Blue.Israel.HatzorHaglilit_Patriot, BORDER.Blue.Israel, RedAIR)
            samBorderDefense(SAM.Blue.Israel.Tuberias_Patriot, BORDER.Blue.Israel, RedAIR)
            samBorderDefense(SAM.Blue.Turkey.CB22_S300, BORDER.Blue.Turkey, RedAIR)
            samBorderDefense(SAM.Blue.Turkey.DB30_S300, BORDER.Blue.Turkey, RedAIR)
            samBorderDefense(SAM.Blue.Turkey.IF25_S300, BORDER.Blue.Turkey, RedAIR)
            samBorderDefense(NAVAL.Blue.Cyprus_FlotteOTAN, BORDER.Blue.OTAN_Fleet, RedAIR)
        end
        -- BORDER Reds
        if BlueAIR:CountAlive() >= 1 then
            samBorderDefense(SAM.Red.Lebanon.Beirut_S300, BORDER.Red, BlueAIR)
            samBorderDefense(SAM.Red.Lebanon.Tripoli_S300, BORDER.Red, BlueAIR)
            samBorderDefense(SAM.Red.Syria.AnNasiriyah_S300, BORDER.Red, BlueAIR)
            samBorderDefense(SAM.Red.Syria.AsSanamayn_S300, BORDER.Red, BlueAIR)
            samBorderDefense(SAM.Red.Syria.Homs_Hawk, BORDER.Red, BlueAIR)
            samBorderDefense(SAM.Red.Syria.Mezzeh_S300, BORDER.Red, BlueAIR)
        end
	end, {}, 1, 10
)