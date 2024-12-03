-----------------------------------------------------------------------------------
-- File     :  /data/projectiles/BasiliskNukeEffect01/CybranNukeEffect05_script.lua
-- Author(s):  Matt Vainio
-- Summary  :  Seraphim experimental nuke effect script, non-damaging
-- Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------------

local BlackOpsUnleashedEffectTemplate = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsEffectTemplates.lua')

---@class BasiliskNukeEffect05 : EmitterProjectile
BasiliskNukeEffect05 = Class(import('/lua/sim/defaultprojectiles.lua').EmitterProjectile) {
    FxTrails = BlackOpsUnleashedEffectTemplate.BasiliskNukePlumeFxTrails01,
    FxTrailScale = 0.5,
}

TypeClass = BasiliskNukeEffect05
