---------------------------------------------------------------------------------------------
-- File     :  /data/projectiles/SBOKhamaseenBombEffect04/SBOKhamaseenBombEffect04_script.lua
-- Author(s):  Greg Kohne
-- Summary  :  Ohwalli Strategic Bomb effect script, non-damaging
-- Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.
---------------------------------------------------------------------------------------------

local BlackOpsEffectTemplate = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsEffectTemplates.lua')

---@class GoldLaserBombEffect04 : EmitterProjectile
GoldLaserBombEffect04 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
    FxTrails = BlackOpsEffectTemplate.GoldLaserBombHitRingProjectileFxTrails04,
}

TypeClass = GoldLaserBombEffect04
