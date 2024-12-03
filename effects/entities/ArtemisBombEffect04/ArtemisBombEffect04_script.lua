-----------------------------------------------------------------------------------
-- File     :  /data/projectiles/ArtemisBombEffect04/ArtemisBombEffect04_script.lua
-- Author(s):  Greg Kohne, Gordon Duclos
-- Summary  :  Seraphim Experimental Nuke effect script, non-damaging
-- Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------------

local BlackOpsEffectTemplate = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsEffectTemplates.lua')

---@class ArtemisBombEffect04 : EmitterProjectile
ArtemisBombEffect04 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
    FxTrails = BlackOpsEffectTemplate.ArtemisBombPlumeFxTrails03,
    FxTrailScale = 0.5,
}
TypeClass = ArtemisBombEffect04
