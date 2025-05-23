---------------------------------------------------------------------------------------------
-- File     :  /data/projectiles/SBOKhamaseenBombEffect05/SBOKhamaseenBombEffect05_script.lua
-- Author(s):  Greg Kohne
-- Summary  :  Ohwalli Strategic Bomb effect script, non-damaging
-- Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.
---------------------------------------------------------------------------------------------
local BlackOpsEffectTemplate = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsEffectTemplates.lua')

---@class GoldLaserBombEffect06 : EmitterProjectile
GoldLaserBombEffect06 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
    FxTrails = BlackOpsEffectTemplate.GoldLaserBombHitRingProjectileFxTrails06,
    FxTrailScale = 0.1,
}

TypeClass = GoldLaserBombEffect06
