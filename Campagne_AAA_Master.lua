---------------------------------------------------------------------------------------------------
-- INITIALISATIONS
---------------------------------------------------------------------------------------------------

-- Settings MOOSE

_SETTINGS:SetPlayerMenuOff()
RAT.ATCswitch = false

-- Border Zones

local Border = {}

Border.Red              = ZONE_POLYGON:New("BORDER_Red", GROUP:FindByName("BORDER_Red"))
Border.Blue_Israel      = ZONE_POLYGON:New("BORDER_Blue_Israel", GROUP:FindByName("BORDER_Blue_Israel"))
Border.Blue_Syria       = ZONE_POLYGON:New("BORDER_Blue_Syria", GROUP:FindByName("BORDER_Blue_Syria"))
Border.Blue_Turkey      = ZONE_POLYGON:New("BORDER_Blue_Turkey", GROUP:FindByName("BORDER_Blue_Turkey"))
Border.Blue_OTAN_Fleet  = ZONE_POLYGON:New("BORDER_Blue_OTAN_Fleet", GROUP:FindByName("BORDER_Blue_OTAN_Fleet"))

-- SAM Systems

local SAM = {}
SAM.Blue = {}
SAM.Blue.Israel_HatzorHaglilit_Patriot  = GROUP:FindByName("AA_Blue_Israel_HatzorHaglilit_Patriot")
SAM.Blue.Israel_Tuberias_Patriot        = GROUP:FindByName("AA_Blue_Israel_Tuberias_Patriot")
SAM.Blue_Syria_AbuAlDuhur_Hawk          = GROUP:FindByName("AA_Blue_Syria_AbuAlDuhur_Hawk")
SAM.Blue_Syria_EinElkorum_S300          = GROUP:FindByName("AA_Blue_Syria_EinElkorum_S300")
SAM.Blue_Syria_Idlib_Hawk               = GROUP:FindByName("AA_Blue_Syria_Idlib_Hawk")
SAM.Blue_Syria_KuweiresJirah_Hawk       = GROUP:FindByName("AA_Blue_Syria_KuweiresJirah_Hawk")
SAM.Blue_Syria_Minakh_S300              = GROUP:FindByName("AA_Blue_Syria_Minakh_S300")
SAM.Blue_Syria_Palmyra_Hawk             = GROUP:FindByName("AA_Blue_Syria_Palmyra_Hawk")
SAM.Blue_Syria_Raqqa_Hawk               = GROUP:FindByName("AA_Blue_Syria_Raqqa_Hawk")
SAM.Blue_Syria_Tabqa_S300               = GROUP:FindByName("AA_Blue_Syria_Tabqa_S300")
SAM.Blue_Turkey_CB22_S300               = GROUP:FindByName("AA_Blue_Turkey_CB22_S300")
SAM.Blue_Turkey_DB30_S300               = GROUP:FindByName("AA_Blue_Turkey_DB30_S300")
SAM.Blue_Turkey_IF25_S300               = GROUP:FindByName("AA_Blue_Turkey_IF25_S300")
SAM.Red_Lebanon_Beirut_S300             = GROUP:FindByName("AA_Red_Lebanon_Beirut_S300")
SAM.Red_Lebanon_Tripoli_S300            = GROUP:FindByName("AA_Red_Lebanon_Tripoli_S300")
SAM.Red_Syria_AnNasiriyah_S300          = GROUP:FindByName("AA_Red_Syria_AnNasiriyah_S300")
SAM.Red_Syria_AsSanamayn_S300           = GROUP:FindByName("AA_Red_Syria_AsSanamayn_S300")
SAM.Red_Syria_Homs_Hawk                 = GROUP:FindByName("AA_Red_Syria_Homs_Hawk")
SAM.Red_Syria_Mezzeh_S300               = GROUP:FindByName("AA_Red_Syria_Mezzeh_S300")

SAM.Blue.Israel_HatzorHaglilit_Patriot:Spawn()
SAM.Blue.Israel_Tuberias_Patriot:Spawn()