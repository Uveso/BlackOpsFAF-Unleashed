---------------------------------------------------------------------------------------------
-- File     :  /data/projectiles/SBOKhamaseenBombEffect05/SBOKhamaseenBombEffect05_script.lua
-- Author(s):  Greg Kohne
-- Summary  :  Ohwalli Strategic Bomb effect script, non-damaging
-- Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.
---------------------------------------------------------------------------------------------
local BlackOpsEffectTemplate = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsEffectTemplates.lua')

---@class GoldLaserBombEffect05 : EmitterProjectile
GoldLaserBombEffect05 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
    FxTrails = BlackOpsEffectTemplate.GoldLaserBombHitRingProjectileFxTrails05,
}

TypeClass = GoldLaserBombEffect05
