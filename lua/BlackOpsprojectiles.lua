-----------------------------------------------------------------
-- File     : /cdimage/lua/BlackOpsProjectiles.lua
-- Author(s): Lt_Hawkeye
-- Summary  :
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------
local EffectTemplate = import('/lua/EffectTemplates.lua')
local util = import('/lua/utilities.lua')
local DefaultProjectileFile = import('/lua/sim/defaultprojectiles.lua')
local BlackOpsEffectTemplate = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsEffectTemplates.lua')
local Projectile = import('/lua/sim/projectile.lua').Projectile

local EmitterProjectile = DefaultProjectileFile.EmitterProjectile
local OnWaterEntryEmitterProjectile = DefaultProjectileFile.OnWaterEntryEmitterProjectile
local SingleBeamProjectile = DefaultProjectileFile.SingleBeamProjectile
local SinglePolyTrailProjectile = DefaultProjectileFile.SinglePolyTrailProjectile
local MultiPolyTrailProjectile = DefaultProjectileFile.MultiPolyTrailProjectile
local SingleCompositeEmitterProjectile = DefaultProjectileFile.SingleCompositeEmitterProjectile
local NukeProjectile = DefaultProjectileFile.NukeProjectile
local NullShell = DefaultProjectileFile.NullShell

-- Null Shell
---@class EXNullShell : Projectile
EXNullShell = Class(Projectile) {}

-- PROJECTILE WITH ATTACHED EFFECT EMITTERS
---@class EXEmitterProjectile : Projectile
EXEmitterProjectile = Class(Projectile) {
    FxTrails = {'/effects/emitters/missile_munition_trail_01_emit.bp',},
    FxTrailScale = 1,
    FxTrailOffset = 0,

    ---@param self EXEmitterProjectile
    OnCreate = function(self)
        Projectile.OnCreate(self)
        local army = self.Army
        for i in self.FxTrails do
            CreateEmitterOnEntity(self, army, self.FxTrails[i]):ScaleEmitter(self.FxTrailScale):OffsetEmitter(0, 0, self.FxTrailOffset)
        end
    end,
}

-- BEAM PROJECTILES
---@class EXBeamProjectile : EXEmitterProjectile
EXSingleBeamProjectile = Class(EXEmitterProjectile) {
    BeamName = '/effects/emitters/default_beam_01_emit.bp',
    FxTrails = {},

    ---@param self any
    OnCreate = function(self)
        EmitterProjectile.OnCreate(self)
        if self.BeamName then
            CreateBeamEmitterOnEntity(self, -1, self.Army, self.BeamName)
        end
    end,
}

---@class EXMultiBeamProjectile : EXEmitterProjectile
EXMultiBeamProjectile = Class(EXEmitterProjectile) {
    Beams = {'/effects/emitters/default_beam_01_emit.bp',},
    FxTrails = {},

    ---@param self EXMultiBeamProjectile
    OnCreate = function(self)
        EmitterProjectile.OnCreate(self)
        local army = self.Army
        for _, v in self.Beams do
            CreateBeamEmitterOnEntity(self, -1, army, v)
        end
    end,
}

-- POLY-TRAIL PROJECTILES
---@class EXSinglePolyTrailProjectile : EXEmitterProjectile
EXSinglePolyTrailProjectile = Class(EXEmitterProjectile) {
    PolyTrail = '/effects/emitters/test_missile_trail_emit.bp',
    PolyTrailOffset = 0,
    FxTrails = {},

    ---@param self EXSinglePolyTrailProjectile
    OnCreate = function(self)
        EmitterProjectile.OnCreate(self)
        if self.PolyTrail ~= '' then
            CreateTrail(self, -1, self.Army, self.PolyTrail):OffsetEmitter(0, 0, self.PolyTrailOffset)
        end
    end,
}

---@class EXMultiPolyTrailProjectile : EXEmitterProjectile
EXMultiPolyTrailProjectile = Class(EXEmitterProjectile) {
    PolyTrailOffset = {0},
    FxTrails = {},
    RandomPolyTrails = 0, -- Count of how many are selected randomly for PolyTrail table

    ---@param self EXMultiPolyTrailProjectile
    OnCreate = function(self)
        EmitterProjectile.OnCreate(self)
        if self.PolyTrails then
            local NumPolyTrails = table.getn(self.PolyTrails)
            local army = self.Army

            if self.RandomPolyTrails ~= 0 then
                local index = nil
                for i = 1, self.RandomPolyTrails do
                    index = math.floor(Random(1, NumPolyTrails))
                    CreateTrail(self, -1, army, self.PolyTrails[index]):OffsetEmitter(0, 0, self.PolyTrailOffset[index])
                end
            else
                for i = 1, NumPolyTrails do
                    CreateTrail(self, -1, army, self.PolyTrails[i]):OffsetEmitter(0, 0, self.PolyTrailOffset[i])
                end
            end
        end
    end,
}

-- COMPOSITE EMITTER PROJECTILES - MULTIPURPOSE PROJECTILES
-- THAT COMBINES BEAMS, POLYTRAILS, AND NORMAL EMITTERS

-- LIGHTWEIGHT VERSION THAT LIMITS USE TO 1 BEAM, 1 POLYTRAIL, AND STANDARD EMITTERS
---@class EXSingleCompositeEmitterProjectile : EXSinglePolyTrailProjectile
EXSingleCompositeEmitterProjectile = Class(EXSinglePolyTrailProjectile) {
    BeamName = '/effects/emitters/default_beam_01_emit.bp',
    FxTrails = {},

    ---@param self EXSingleCompositeEmitterProjectile
    OnCreate = function(self)
        SinglePolyTrailProjectile.OnCreate(self)
        if self.BeamName ~= '' then
            CreateBeamEmitterOnEntity(self, -1, self.Army, self.BeamName)
        end
    end,
}

-- HEAVYWEIGHT VERSION, ALLOWS FOR MULTIPLE BEAMS, POLYTRAILS, AND STANDARD EMITTERS
---@class EXMultiCompositeEmitterProjectile : EXMultiPolyTrailProjectile
EXMultiCompositeEmitterProjectile = Class(EXMultiPolyTrailProjectile) {
    Beams = {'/effects/emitters/default_beam_01_emit.bp',},
    PolyTrailOffset = {0},
    RandomPolyTrails = 0, -- Count of how many are selected randomly for PolyTrail table
    FxTrails = {},

    ---@param self EXMultiCompositeEmitterProjectile
    OnCreate = function(self)
        MultiPolyTrailProjectile.OnCreate(self)
        local army = self.Army
        for _, v in self.Beams do
            CreateBeamEmitterOnEntity(self, -1, army, v)
        end
    end,
}

---@class RailGun01Projectile : MultiPolyTrailProjectile
RailGun01Projectile = Class(MultiPolyTrailProjectile) {
    FxImpactWater = BlackOpsEffectTemplate.RailGunCannonHit,
    FxImpactLand = BlackOpsEffectTemplate.RailGunCannonHit,
    FxImpactNone = BlackOpsEffectTemplate.RailGunCannonHit,
    FxImpactProp = BlackOpsEffectTemplate.RailGunCannonUnitHit,
    FxImpactUnit = BlackOpsEffectTemplate.RailGunCannonUnitHit,

    FxTrails = BlackOpsEffectTemplate.RailGunFxTrails,
    PolyTrails = BlackOpsEffectTemplate.RailGunPolyTrails,
    FxImpactProjectile = {},
    FxImpactUnderWater = {},
}

---@class MiniRocketPRojectile : SingleBeamProjectile
MiniRocketPRojectile = Class(SingleBeamProjectile) {
    DestroyOnImpact = false,
    FxTrails = EffectTemplate.TMissileExhaust02,
    FxTrailOffset = -1,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',

    FxImpactUnit = EffectTemplate.TMissileHit01,
    FxImpactLand = EffectTemplate.TMissileHit01,
    FxImpactProp = EffectTemplate.TMissileHit01,
    FxImpactUnderWater = {},

    ---@param self MiniRocketPRojectile
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpact = function(self, targetType, targetEntity)
        SingleBeamProjectile.OnImpact(self, targetType, targetEntity)
    end,

    ---@param self MiniRocketPRojectile
    ---@param army Army
    ---@param EffectTable table
    ---@param EffectScale number
    CreateImpactEffects = function(self, army, EffectTable, EffectScale)
        local emit = nil
        for _, v in EffectTable do
            emit = CreateEmitterAtEntity(self,army,v)
            if emit and EffectScale ~= 1 then
                emit:ScaleEmitter(EffectScale or 1)
            end
        end
    end,
}

---@class MiniRocket02Projectile : SingleBeamProjectile
MiniRocket02Projectile = Class(SingleBeamProjectile) {
    DestroyOnImpact = false,
    FxTrails = EffectTemplate.TMissileExhaust02,
    FxTrailOffset = 0,
    BeamName = '/effects/emitters/missile_munition_exhaust_beam_01_emit.bp',

    -- Hit Effects
    FxImpactUnit = EffectTemplate.CMissileLOAHit01,
    FxImpactLand = EffectTemplate.CMissileLOAHit01,
    FxImpactProp = EffectTemplate.CMissileLOAHit01,
    FxImpactNone = EffectTemplate.CMissileLOAHit01,
    FxImpactUnderWater = {},

    ---@param self MiniRocket02Projectile
    ---@param army Army
    ---@param EffectTable table
    ---@param EffectScale number
    CreateImpactEffects = function(self, army, EffectTable, EffectScale)
        local emit = nil
        for _, v in EffectTable do
            emit = CreateEmitterAtEntity(self,army,v)
            if emit and EffectScale ~= 1 then
                emit:ScaleEmitter(EffectScale or 1)
            end
        end
    end,

    ---@param self MiniRocket02Projectile
    OnExitWater = function(self)
        EmitterProjectile.OnExitWater(self)
        local army = self.Army
        for _, v in self.FxExitWaterEmitter do
            CreateEmitterAtBone(self,-2,army,v)
        end
    end,
}

---@class MiniRocket03PRojectile : SingleBeamProjectile
MiniRocket03PRojectile = Class(SingleBeamProjectile) {
    DestroyOnImpact = false,
    FxTrails = EffectTemplate.TMissileExhaust02,
    FxTrailOffset = -0.25,

    BeamName = '/mods/BlackOpsFAF-Unleashed/effects/emitters/missile_munition_exhaust_beam_02_emit.bp',

    FxImpactUnit = EffectTemplate.TMissileHit01,
    FxImpactLand = EffectTemplate.TMissileHit01,
    FxImpactProp = EffectTemplate.TMissileHit01,
    FxImpactUnderWater = {},

    ---@param self MiniRocket03PRojectile
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpact = function(self, targetType, targetEntity)
        SingleBeamProjectile.OnImpact(self, targetType, targetEntity)
    end,

    ---@param self MiniRocket03PRojectile
    ---@param army Army
    ---@param EffectTable table
    ---@param EffectScale number
    CreateImpactEffects = function(self, army, EffectTable, EffectScale)
        local emit = nil
        for _, v in EffectTable do
            emit = CreateEmitterAtEntity(self,army,v)
            if emit and EffectScale ~= 1 then
                emit:ScaleEmitter(EffectScale or 1)
            end
        end
    end,
}

---@class MiniRocket04PRojectile : SingleBeamProjectile
MiniRocket04PRojectile = Class(SingleBeamProjectile) {
    DestroyOnImpact = false,
    BeamName = '/mods/BlackOpsFAF-Unleashed/effects/emitters/missile_munition_exhaust_beam_03_emit.bp',

    ---@param self MiniRocket04PRojectile
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpact = function(self, targetType, targetEntity)
        SingleBeamProjectile.OnImpact(self, targetType, targetEntity)
    end,

    ---@param self MiniRocket04PRojectile
    ---@param army Army
    ---@param EffectTable table
    ---@param EffectScale number
    CreateImpactEffects = function(self, army, EffectTable, EffectScale)
        local emit = nil
        for _, v in EffectTable do
            emit = CreateEmitterAtEntity(self,army,v)
            if emit and EffectScale ~= 1 then
                emit:ScaleEmitter(EffectScale or 1)
            end
        end
    end,
}

-- SeaDragon Projectiles
---@class SeaDragonShell : SinglePolyTrailProjectile
SeaDragonShell = Class(SinglePolyTrailProjectile) {

    PolyTrail = '/effects/emitters/default_polytrail_01_emit.bp',

    -- Hit Effects
    FxImpactUnit = EffectTemplate.CMolecularResonanceHitUnit01,
    FxUnitHitScale = 2,
    FxImpactProp = EffectTemplate.CMolecularResonanceHitUnit01,
    FxPropHitScale = 2,
    FxImpactLand = EffectTemplate.CMolecularResonanceHitUnit01,
    FxLandHitScale = 2,
    FxImpactUnderWater = {},
    DestroyOnImpact = false,

    ---@param self SeaDragonShell
    OnCreate = function(self)
        SinglePolyTrailProjectile.OnCreate(self)
        self.Impacted = false
    end,

    ---@param self SeaDragonShell
    DelayedDestroyThread = function(self)
        WaitSeconds(0.3)
        self.CreateImpactEffects(self, self.Army, self.FxImpactUnit, self.FxUnitHitScale)
        self:Destroy()
    end,

    ---@param self SeaDragonShell
    ---@param TargetType string
    ---@param TargetEntity Entity
    OnImpact = function(self, TargetType, TargetEntity)
        if self.Impacted == false then
            self.Impacted = true
            if TargetType == 'Terrain' then
                SinglePolyTrailProjectile.OnImpact(self, TargetType, TargetEntity)
                self:ForkThread(self.DelayedDestroyThread)
            else
                SinglePolyTrailProjectile.OnImpact(self, TargetType, TargetEntity)
                self:Destroy()
            end
        end
    end,
}

---@class XCannonProjectile : MultiPolyTrailProjectile
XCannonProjectile = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
        BlackOpsEffectTemplate.XCannonPolyTrail,
        '/effects/emitters/default_polytrail_01_emit.bp',
    },
    PolyTrailOffset = {0,0},

    FxTrails = BlackOpsEffectTemplate.XCannonFXTrail01,

    FxImpactUnit = EffectTemplate.CMobileKamikazeBombExplosion,
    FxImpactProp = EffectTemplate.CMobileKamikazeBombExplosion,
    FxImpactLand = EffectTemplate.CMobileKamikazeBombExplosion,
    FxImpactUnderWater = EffectTemplate.CHvyProtonCannonHit01,
    FxImpactWater = EffectTemplate.CHvyProtonCannonHit01,
    FxTrailOffset = 0,
    FxLandHitScale = 0.8,
    FxPropHitScale = 0.8,
    FxUnitHitScale = 0.8,
    FxUnderWaterHitScale = 0.8,
    FxWaterHitScale = 0.8,
}

-- Bismark Projectiles
---@class ZCannon01Projectile : MultiPolyTrailProjectile
ZCannon01Projectile = Class(MultiPolyTrailProjectile) {
    FxImpactTrajectoryAligned = false,
    PolyTrails = BlackOpsEffectTemplate.ZCannonPolytrail01,
    PolyTrailOffset = {0,0,0},
    FxTrails = BlackOpsEffectTemplate.ZCannonFxtrail01,

    -- Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.ZCannonHit01,
    FxImpactProp = BlackOpsEffectTemplate.ZCannonHit01,
    FxImpactLand = BlackOpsEffectTemplate.ZCannonHit01,
    FxImpactWater = BlackOpsEffectTemplate.ZCannonHit01,
    FxLandHitScale = 1.5,
    FxPropHitScale = 1.5,
    FxUnitHitScale = 1.5,
    FxImpactUnderWater = {},
    FxSplatScale = 9,

    ---@param self ZCannon01Projectile
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpact = function(self, targetType, targetEntity)
        local army = self.Army
        if targetType == 'Terrain' then
            CreateDecal(self:GetPosition(), util.GetRandomFloat(0,2*math.pi), 'nuke_scorch_001_normals', '', 'Alpha Normals', self.FxSplatScale, self.FxSplatScale, 150, 50, army)
            CreateDecal(self:GetPosition(), util.GetRandomFloat(0,2*math.pi), 'nuke_scorch_002_albedo', '', 'Albedo', self.FxSplatScale * 2, self.FxSplatScale * 2, 150, 50, army)
            self:ShakeCamera(20, 1, 0, 1)
        end
        local pos = self:GetPosition()
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
}

--  Cybran Dumb MISSILE PROJECTILES
---@class DumbRocketProjectile : SingleBeamProjectile
DumbRocketProjectile = Class(SingleBeamProjectile) {
    FxTrails = {'/effects/emitters/missile_cruise_munition_trail_01_emit.bp',},
    BeamName = '/effects/emitters/missile_exhaust_fire_beam_01_emit.bp',
    FxImpactUnit = EffectTemplate.CCorsairMissileUnitHit01,
    FxImpactProp = EffectTemplate.CCorsairMissileHit01,
    FxImpactLand = EffectTemplate.CCorsairMissileLandHit01,
    FxLandHitScale = 1.5,
    FxPropHitScale = 1.5,
    FxUnitHitScale = 1.5,
    FxImpactUnderWater = {},
}

---@class DumbRocketProjectile02 : EmitterProjectile
DumbRocketProjectile02 = Class(EmitterProjectile) {
    FxTrails = {'/effects/emitters/mortar_munition_01_emit.bp',},
    FxImpactUnit = EffectTemplate.CCorsairMissileUnitHit01,
    FxImpactProp = EffectTemplate.CCorsairMissileHit01,
    FxImpactLand = EffectTemplate.CCorsairMissileLandHit01,
    FxLandHitScale = 1.5,
    FxPropHitScale = 1.5,
    FxUnitHitScale = 1.5,
    FxImpactUnderWater = {},
}

-- Scorp Laser
---@class ScorpPulseLaser : MultiPolyTrailProjectile
ScorpPulseLaser = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
        EffectTemplate.CHvyProtonCannonPolyTrail,
        '/effects/emitters/electron_bolter_trail_01_emit.bp',
    },
    PolyTrailScale = 0.5,
    PolyTrailOffset = {0,0},

    FxImpactUnit = EffectTemplate.CHvyProtonCannonHitUnit,
    FxUnitHitScale = 0.5,
    FxImpactProp = EffectTemplate.CHvyProtonCannonHitUnit,
    FxPropHitScale = 0.5,
    FxImpactLand = EffectTemplate.CHvyProtonCannonHitLand,
    FxLandHitScale = 0.5,
    FxImpactUnderWater = EffectTemplate.CHvyProtonCannonHit01,
    FxUnderWarerHitScale = 0.5,
    FxImpactWater = EffectTemplate.CHvyProtonCannonHit01,
    FxWaterHitScale = 0.5,
    FxTrailOffset = 0,
}

--  AEON MIRV MISSILE PROJECTILES
---@class MIRVChild01Projectile : SingleCompositeEmitterProjectile
MIRVChild01Projectile = Class(SingleCompositeEmitterProjectile) {
    PolyTrail = '/effects/emitters/serpentine_missile_trail_emit.bp',
    BeamName = '/effects/emitters/serpentine_missle_exhaust_beam_01_emit.bp',
    PolyTrailOffset = -0.05,

    FxImpactUnit = BlackOpsEffectTemplate.Aeon_MirvHit,
    FxImpactProp = BlackOpsEffectTemplate.Aeon_MirvHit,
    FxImpactLand = BlackOpsEffectTemplate.Aeon_MirvHit,
    FxLandHitScale = 1,
    FxPropHitScale = 1,
    FxUnitHitScale = 1,
    FxImpactUnderWater = {},
}

-- Aira Projectiles
---@class SonicWaveProjectile : MultiPolyTrailProjectile
SonicWaveProjectile = Class(MultiPolyTrailProjectile) {
    FxImpactTrajectoryAligned = false,
    PolyTrails = BlackOpsEffectTemplate.WaveCannonPolytrail01,
    PolyTrailOffset = {0,0,0},
    FxTrails = BlackOpsEffectTemplate.WaveCannonFxtrail01,

    -- Hit Effects
    FxImpactUnit = EffectTemplate.AGravitonBolterHit01,
    FxImpactProp = EffectTemplate.AGravitonBolterHit01,
    FxImpactLand = EffectTemplate.AGravitonBolterHit01,
    FxLandHitScale = 1.5,
    FxPropHitScale = 1.5,
    FxUnitHitScale = 1.5,
    FxImpactUnderWater = {},
}

-- Seraphim Lambda Projectiles
---@class EyeBlast01Projectile : EmitterProjectile
EyeBlast01Projectile = Class(EmitterProjectile) {
    FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.SDFExperimentalPhasonProjFXTrails01,
    FxImpactUnit = BlackOpsEffectTemplate.SDFExperimentalPhasonProjHitUnit,
    FxImpactProp = BlackOpsEffectTemplate.SDFExperimentalPhasonProjHit01,
    FxImpactShield = BlackOpsEffectTemplate.SDFExperimentalPhasonProjHit01,
    FxImpactLand = BlackOpsEffectTemplate.SDFExperimentalPhasonProjHit01,
    FxImpactWater = BlackOpsEffectTemplate.SDFExperimentalPhasonProjHit01,
}

-- Seraphim LPD Projectiles
---@class SeraHeavyLightningCannonChildProjectile : EmitterProjectile
SeraHeavyLightningCannonChildProjectile = Class(EmitterProjectile) {
    FxImpactTrajectoryAligned = false,
    FxTrails = EffectTemplate.SDFExperimentalPhasonProjFXTrails01,
    FxImpactLand = EffectTemplate.SHeavyQuarnonCannonLandHit,
    FxImpactNone = EffectTemplate.SHeavyQuarnonCannonHit,
    FxImpactProp = EffectTemplate.SHeavyQuarnonCannonHit,
    FxImpactUnit = EffectTemplate.SHeavyQuarnonCannonUnitHit,
    FxOnKilled = EffectTemplate.SHeavyQuarnonCannonUnitHit,
}

-- CYBRAN SUB LAUNCHED TORPEDO
---@class AssaultTorpedoSubProjectile : EmitterProjectile
AssaultTorpedoSubProjectile = Class(EmitterProjectile) {
    FxTrails = {'/effects/emitters/torpedo_underwater_wake_02_emit.bp',},

    -- Hit Effects
    FxImpactUnit = EffectTemplate.CTorpedoUnitHit01,
    FxImpactProp = EffectTemplate.CTorpedoUnitHit01,
    FxImpactUnderWater = EffectTemplate.CTorpedoUnitHit01,
    FxImpactLand = EffectTemplate.CTorpedoUnitHit01,
    FxLandHitScale = 4,
    FxPropHitScale = 4,
    FxUnitHitScale = 4,
    FxNoneHitScale = 4,
    FxImpactNone = {},
}

---@class ShadowCannonProjectile : MultiPolyTrailProjectile
ShadowCannonProjectile = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadowcannon_polytrail_01_emit.bp',
    },
    PolyTrailOffset = {0,0},

    FxTrails = BlackOpsEffectTemplate.ShadowCannonFXTrail01,
    FxTrailScale = 0.5,
    FxImpactUnit = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxImpactProp = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxImpactLand = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxImpactUnderWater = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxImpactWater = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxNoneHitScale = 0.7,
    FxTrailOffset = 0,
}

---@class HellFireMissileProjectile : SingleCompositeEmitterProjectile
HellFireMissileProjectile = Class(SingleCompositeEmitterProjectile) {
    FxTrails = {'/effects/emitters/missile_cruise_munition_trail_01_emit.bp',},
    FxTrailScale = 0.25,
    BeamName = '/effects/emitters/missile_exhaust_fire_beam_01_emit.bp',
    FxImpactUnit = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactProp = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactLand = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactWater = EffectTemplate.TNapalmHvyCarpetBombHitWater01,
    FxImpactUnderWater = {},
}

---@class ACUShadowCannonProjectile : MultiPolyTrailProjectile
ACUShadowCannonProjectile = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
        '/effects/emitters/electron_bolter_trail_01_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadowcannon_polytrail_01_emit.bp',
    },
    PolyTrailOffset = {0,0},

    FxTrails = BlackOpsEffectTemplate.ShadowCannonFXTrail01,
    FxImpactUnit = BlackOpsEffectTemplate.ACUShadowCannonHit01,
    FxImpactProp = BlackOpsEffectTemplate.ACUShadowCannonHit01,
    FxImpactLand = BlackOpsEffectTemplate.ACUShadowCannonHit01,
    FxImpactUnderWater = BlackOpsEffectTemplate.ACUShadowCannonHit01,
    FxImpactWater = BlackOpsEffectTemplate.ACUShadowCannonHit01,
    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxNoneHitScale = 0.7,
    FxTrailOffset = 0,
}

-- TERRAN Heavy GAUSS CANNON PROJECTILES
---@class HawkGaussCannonProjectile : MultiPolyTrailProjectile
HawkGaussCannonProjectile = Class(MultiPolyTrailProjectile) {
    FxTrails = {},
    PolyTrails = EffectTemplate.TGaussCannonPolyTrail,
    PolyTrailOffset = {0,0},
    FxImpactUnit = EffectTemplate.TMissileHit01,
    FxImpactProp = EffectTemplate.TMissileHit01,
    FxImpactLand = EffectTemplate.TMissileHit01,
    FxTrailOffset = 0,
    FxImpactUnderWater = {},
}

-- AEON ARTILLERY PROJECTILES
---@class WraithProjectile : SinglePolyTrailProjectile
WraithProjectile = Class(SinglePolyTrailProjectile) {
    FxImpactLand = BlackOpsEffectTemplate.WraithCannonHit01,
    FxImpactNone = BlackOpsEffectTemplate.WraithCannonHit01,
    FxImpactProp = BlackOpsEffectTemplate.WraithCannonHit01,
    FxImpactUnit = BlackOpsEffectTemplate.WraithCannonHit01,
    FxImpactUnderWater = {},
    FxImpactProjectile = {},
    FxLandHitScale = 0.7,
    FxPropHitScale = 0.7,
    FxUnitHitScale = 0.7,
    FxNoneHitScale = 0.7,
    PolyTrail = BlackOpsEffectTemplate.WraithPolytrail01,
    FxTrails = BlackOpsEffectTemplate.WraithMunition01,
}

-- Fire test
---@class Juggfire01 : MultiPolyTrailProjectile
Juggfire01 = Class(MultiPolyTrailProjectile) {
    PolyTrails = BlackOpsEffectTemplate.HGaussCannonPolyTrail,
    FxTrails = {
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/Juggfire01_emit.bp',
        '/effects/emitters/napalm_hvy_thin_smoke_emit.bp',
    },
    PolyTrailOffset = {0,0,0},

    -- Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactProp = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactLand = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactWater = BlackOpsEffectTemplate.FlameThrowerHitWater01,
    FxLandHitScale = 0.5,
    FxPropHitScale = 0.5,
    FxUnitHitScale = 0.5,
    FxImpactUnderWater = {},
    FxTrailOffset = 0,
}

-- Flamethrower Projectile
---@class NapalmProjectile01 : EmitterProjectile
NapalmProjectile01 = Class(EmitterProjectile) {
    FxTrails = {'/mods/BlackOpsFAF-Unleashed/Effects/Emitters/NapalmTrailFX.bp',},

    FxImpactTrajectoryAligned = false,

    -- Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactProp = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactLand = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactWater = BlackOpsEffectTemplate.FlameThrowerHitWater01,
    FxImpactUnderWater = {},
}

---@class NapalmProjectile02 : EmitterProjectile
NapalmProjectile02 = Class(EmitterProjectile) {
    FxTrails = {'/mods/BlackOpsFAF-Unleashed/Effects/Emitters/NapalmTrailFX.bp',},
       FxTrailScale = 0.5,

    FxImpactTrajectoryAligned = false,

    -- Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactProp = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactLand = BlackOpsEffectTemplate.FlameThrowerHitLand01,
    FxImpactWater = BlackOpsEffectTemplate.FlameThrowerHitWater01,
    FxImpactUnderWater = {},
    FxLandHitScale = 0.5,
    FxPropHitScale = 0.5,
    FxUnitHitScale = 0.5,
    FxNoneHitScale = 0.5,
}

-- ARTEMIS CANNON PROJECTILES
---@class ArtemisCannonProjectile : SinglePolyTrailProjectile
ArtemisCannonProjectile = Class(SinglePolyTrailProjectile) {
    PolyTrail = BlackOpsEffectTemplate.ArtemisPolytrail01,
    FxTrails = BlackOpsEffectTemplate.ArtemisFXTrail,

    FxImpactUnit = EffectTemplate.AReactonCannonHitUnit01,
    FxImpactProp = EffectTemplate.AReactonCannonHitUnit01,
    FxImpactLand = EffectTemplate.AReactonCannonHitLand01,
}

---@class DummyArtemisCannonProjectile : MultiPolyTrailProjectile
DummyArtemisCannonProjectile = Class(MultiPolyTrailProjectile) {
    PolyTrail = BlackOpsEffectTemplate.DummyArtemisPolytrail01,
    FxTrails = BlackOpsEffectTemplate.DummyArtemisFXTrail,

    FxImpactUnit = EffectTemplate.AReactonCannonHitUnit01,
    FxImpactProp = EffectTemplate.AReactonCannonHitUnit01,
    FxImpactLand = EffectTemplate.AReactonCannonHitLand01,
}

-- AEON ABOVE WATER LAUNCHED TORPEDO
---@class AMTorpedoShipProjectile : OnWaterEntryEmitterProjectile
AMTorpedoShipProjectile = Class(OnWaterEntryEmitterProjectile) {
    FxInitial = {},
    FxTrails = {'/effects/emitters/torpedo_munition_trail_01_emit.bp',},
    FxTrailScale = 1,
    TrailDelay = 0,
    TrackTime = 0,

    FxUnitHitScale = 1.25,
    FxImpactLand = {},
    FxImpactUnit = EffectTemplate.ATorpedoUnitHit01,
    FxImpactProp = EffectTemplate.ATorpedoUnitHit01,
    FxImpactUnderWater = EffectTemplate.DefaultProjectileUnderWaterImpact,
    FxImpactProjectile = EffectTemplate.ATorpedoUnitHit01,
    FxImpactProjectileUnderWater = EffectTemplate.DefaultProjectileUnderWaterImpact,
    FxKilled = EffectTemplate.ATorpedoUnitHit01,
    FxImpactNone = {},

    ---@param self AMTorpedoShipProjectile
    ---@param inWater boolean
    OnCreate = function(self,inWater)
        OnWaterEntryEmitterProjectile.OnCreate(self,inWater)
        -- If we are starting in the water then immediately switch to tracking in water
        if inWater == true then
            self:TrackTarget(true):StayUnderwater(false)
            self:OnEnterWater(self)
        else
            self:TrackTarget(true)
        end
    end,
}

---@class AMTorpedoCluster : SingleCompositeEmitterProjectile
AMTorpedoCluster = Class(SingleCompositeEmitterProjectile) {
    FxInitial = {},
    PolyTrail = '/effects/emitters/serpentine_missile_trail_emit.bp',
    BeamName = '/effects/emitters/serpentine_missle_exhaust_beam_01_emit.bp',
    FxTrailScale = 1,
    TrailDelay = 0,
    TrackTime = 0,

    FxUnitHitScale = 1.25,
    FxImpactLand = {},
    FxImpactUnit = EffectTemplate.ATorpedoUnitHit01,
    FxImpactProp = EffectTemplate.ATorpedoUnitHit01,
    FxImpactUnderWater = EffectTemplate.ATorpedoUnitHitUnderWater01,
    FxImpactProjectile = EffectTemplate.ATorpedoUnitHit01,
    FxImpactProjectileUnderWater = EffectTemplate.ATorpedoUnitHitUnderWater01,
    FxKilled = EffectTemplate.ATorpedoUnitHit01,
    FxImpactNone = {},

    ---@param self AMTorpedoCluster
    ---@param inWater boolean
    OnCreate = function(self,inWater)
        SingleCompositeEmitterProjectile.OnCreate(self,inWater)
        -- If we are starting in the water then immediately switch to tracking in water
        if inWater == true then
            self:TrackTarget(true):StayUnderwater(false)
            self:OnEnterWater(self)
        else
            self:TrackTarget(true)
        end
    end,
}

-- AEON GUIDED AA PROJECTILES
---@class GoldAAProjectile : SinglePolyTrailProjectile
GoldAAProjectile = Class(SinglePolyTrailProjectile) {
    FxTrails =  BlackOpsEffectTemplate.GoldAAFxTrails,
    PolyTrail = BlackOpsEffectTemplate.GoldAAPolyTrail,

    FxImpactUnit = EffectTemplate.AMercyGuidedMissileSplitMissileHitUnit,
    FxImpactAirUnit = EffectTemplate.AMercyGuidedMissileSplitMissileHitUnit,
    FxImpactProp = EffectTemplate.AMercyGuidedMissileSplitMissileHit,
    FxImpactNone = EffectTemplate.AMercyGuidedMissileSplitMissileHit,
    FxImpactLand = EffectTemplate.AMercyGuidedMissileSplitMissileHitLand,
    FxImpactUnderWater = {},
}

-- SERAPHIM TAU CANNON
---@class ShieldTauCannonProjectile : MultiPolyTrailProjectile
ShieldTauCannonProjectile = Class(MultiPolyTrailProjectile) {
    FxImpactLand = EffectTemplate.STauCannonHit,
    FxImpactNone = EffectTemplate.STauCannonHit,
    FxImpactProp = EffectTemplate.STauCannonHit,
    FxImpactUnit = EffectTemplate.STauCannonHit,
    FxImpactShield = EffectTemplate.ADisruptorHitShield,
    FxTrails = EffectTemplate.STauCannonProjectileTrails,
    PolyTrailOffset = {0,0},
    PolyTrails = EffectTemplate.STauCannonProjectilePolyTrails,
}

---@class SOmegaCannonOverCharge : MultiPolyTrailProjectile
SOmegaCannonOverCharge = Class(MultiPolyTrailProjectile) {
    FxImpactTrajectoryAligned = false,
    FxImpactLand = BlackOpsEffectTemplate.OmegaOverChargeLandHit,
    FxImpactNone = BlackOpsEffectTemplate.OmegaOverChargeLandHit,
    FxImpactProp = BlackOpsEffectTemplate.OmegaOverChargeLandHit,
    FxImpactUnit = BlackOpsEffectTemplate.OmegaOverChargeUnitHit,
    FxLandHitScale = 4,
    FxPropHitScale = 4,
    FxUnitHitScale = 4,
    FxNoneHitScale = 4,
    FxTrails = BlackOpsEffectTemplate.OmegaOverChargeProjectileFxTrails,
    PolyTrails = BlackOpsEffectTemplate.OmegaOverChargeProjectileTrails,
    PolyTrailOffset = {0,0,0},
}

-- SERAPHIM LAANSE TACTICAL MISSILE
---@class SLaanseTacticalMissile : SinglePolyTrailProjectile
SLaanseTacticalMissile = Class(SinglePolyTrailProjectile) {
    FxImpactLand = EffectTemplate.SLaanseMissleHit,
    FxImpactProp = EffectTemplate.SLaanseMissleHitUnit,
    FxImpactUnderWater = {},
    FxImpactUnit = EffectTemplate.SLaanseMissleHitUnit,
    FxTrails = EffectTemplate.SLaanseMissleExhaust02,
    PolyTrail = EffectTemplate.SLaanseMissleExhaust01,
}

-- MGAI PROJECTILES
---@class MGHeadshotProjectile : MultiPolyTrailProjectile
MGHeadshotProjectile = Class(MultiPolyTrailProjectile) {
    FxImpactTrajectoryAligned = false,
    PolyTrails = BlackOpsEffectTemplate.MGHeadshotPolytrail01,
    PolyTrailOffset = {0,0,0},
    FxTrails = BlackOpsEffectTemplate.MGHeadshotFxtrail01,

    -- Hit Effects
    FxImpactLand = BlackOpsEffectTemplate.MGHeadshotHit01,
    FxImpactNone = BlackOpsEffectTemplate.MGHeadshotHit01,
    FxImpactProp = BlackOpsEffectTemplate.MGHeadshotHit01,
    FxImpactUnit = BlackOpsEffectTemplate.MGHeadshotHit01,
    FxLandHitScale = 1.5,
    FxPropHitScale = 1.5,
    FxUnitHitScale = 1.5,
    FxImpactUnderWater = {},
}

---@class MGQAIRocketProjectile : SingleBeamProjectile
MGQAIRocketProjectile = Class(SingleBeamProjectile) {
    BeamName = '/effects/emitters/missile_loa_munition_exhaust_beam_01_emit.bp',
    FxTrails = {'/effects/emitters/missile_cruise_munition_trail_01_emit.bp',},
    PolyTrailOffset = -0.05,

    FxImpactUnit = BlackOpsEffectTemplate.MissileUnitHit01,
    FxImpactProp = BlackOpsEffectTemplate.MissileLandHit01,
    FxImpactLand = BlackOpsEffectTemplate.MissileLandHit01,
    FxLandHitScale = 0.65,
    FxPropHitScale = 0.65,
    FxUnitHitScale = 0.65,
    FxNoneHitScale = 0.65,
    FxImpactUnderWater = {},
}

---@class MGQAIRocketChildProjectile : SingleCompositeEmitterProjectile
MGQAIRocketChildProjectile = Class(SingleCompositeEmitterProjectile) {
    PolyTrail = '/mods/BlackOpsFAF-Unleashed/effects/emitters/mgqai_missile_trail_emit.bp',
    BeamName = '/mods/BlackOpsFAF-Unleashed/effects/emitters/mgqai_missle_exhaust_beam_01_emit.bp',
    PolyTrailOffset = -0.05,

    FxImpactUnit = BlackOpsEffectTemplate.MissileUnitHit01,
    FxImpactProp = BlackOpsEffectTemplate.MissileLandHit01,
    FxImpactLand = BlackOpsEffectTemplate.MissileLandHit01,
    FxLandHitScale = 0.65,
    FxPropHitScale = 0.65,
    FxUnitHitScale = 0.65,
    FxNoneHitScale = 0.65,
    FxImpactUnderWater = {},
}

---@class MGQAIPlasmaArtyChildProjectile : EmitterProjectile
MGQAIPlasmaArtyChildProjectile = Class(EmitterProjectile) {
    FxTrails = BlackOpsEffectTemplate.MGQAIPlasmaArtyChildFxtrail01,

    -- Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.MGQAIPlasmaArtyHitLand01,
    FxImpactProp = BlackOpsEffectTemplate.MGQAIPlasmaArtyHitLand01,
    FxImpactLand = BlackOpsEffectTemplate.MGQAIPlasmaArtyHitLand01,
    FxImpactUnderWater = BlackOpsEffectTemplate.MGQAIPlasmaArtyHitLand01,
    FxImpactWater = BlackOpsEffectTemplate.MGQAIPlasmaArtyHitLand01,

    ---@param self MGQAIPlasmaArtyChildProjectile
    ---@param TargetType string
    ---@param TargetEntity Entity
    OnCreate = function(self, TargetType, TargetEntity)
        EmitterProjectile.OnCreate(self, TargetType, TargetEntity)
    end,

}

---@class MGQAIPlasmaArtyProjectile : EmitterProjectile
MGQAIPlasmaArtyProjectile = Class(EmitterProjectile) {
    FxTrails = BlackOpsEffectTemplate.MGQAIPlasmaArtyFxtrail01,

    -- Hit Effects
    FxImpactUnit = {},
    FxImpactLand = {},
    FxImpactUnderWater = {},
    ChildProjectile = '/mods/BlackOpsFAF-Unleashed/projectiles/MGQAIPlasmaArtyChild01/MGQAIPlasmaArtyChild01_proj.bp',

    ---@param self MGQAIPlasmaArtyProjectile
    OnCreate = function(self)
        EmitterProjectile.OnCreate(self)
        self.Impacted = false
    end,

    ---@param self MGQAIPlasmaArtyProjectile
    ---@param instigator Unit
    ---@param damageData table
    ---@param targetEntity Entity
    DoDamage = function(self, instigator, damageData, targetEntity)
        EmitterProjectile.DoDamage(self, instigator, damageData, targetEntity)
    end,

    ---@param self MGQAIPlasmaArtyProjectile
    ---@param TargetType string
    ---@param TargetEntity Entity
    OnImpact = function(self, TargetType, TargetEntity)
        if self.Impacted == false and TargetType ~= 'Air' then
            self.Impacted = true
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(0,Random(1,5),Random(1.5,5))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(Random(1,4),Random(1,5),Random(1,2))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(0,Random(1,5),-Random(1.5,5))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(Random(1.5,5),Random(1,5),0)
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(1,4),Random(1,5),-Random(1,2))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(1.5,4.5),Random(1,5),0)
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(1,4),Random(1,5),Random(2,4))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(1,2),Random(1,7),-Random(1,3))
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(2.5,3.5),Random(2,6),0)
            self:CreateChildProjectile(self.ChildProjectile):SetVelocity(-Random(2,3),Random(2,3),Random(3,5))
            EmitterProjectile.OnImpact(self, TargetType, TargetEntity)
        end
    end,

    -- Overriding Destruction
    ---@param self MGQAIPlasmaArtyProjectile
    ---@param TargetType string Unused
    ---@param TargetEntity Entity Unused
    OnImpactDestroy = function(self, TargetType, TargetEntity)
        self:ForkThread(self.DelayedDestroyThread)
    end,

    ---@param self MGQAIPlasmaArtyProjectile
    DelayedDestroyThread = function(self)
        WaitSeconds(0.5)
        self:Destroy()
    end,
}

---@class MGQAILaserHeavyProjectile : MultiPolyTrailProjectile
MGQAILaserHeavyProjectile = Class(MultiPolyTrailProjectile) {
    PolyTrails = {
        '/effects/emitters/electron_bolter_trail_01_emit.bp',
        '/effects/emitters/default_polytrail_03_emit.bp',
    },
    PolyTrailOffset = {0,0},
    FxTrails = {'/effects/emitters/electron_bolter_munition_01_emit.bp',},

    -- Hit Effects
    FxImpactUnit = EffectTemplate.CLaserHitUnit01,
    FxImpactProp = EffectTemplate.CLaserHitUnit01,
    FxImpactLand = EffectTemplate.CLaserHitLand01,
    FxImpactUnderWater = {},
}

---@class RedTurbolaser2Projectile : MultiPolyTrailProjectile
RedTurbolaser2Projectile = Class(MultiPolyTrailProjectile) {
    FxTrails = {'/effects/emitters/electron_bolter_munition_01_emit.bp',},
    PolyTrails = BlackOpsEffectTemplate.RedTurboLaser02,

    -- Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxUnitHitScale = 0.7,
    FxImpactProp = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxPropHitScale = 0.7,
    FxImpactAirUnit = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxAirUnitHitScale = 0.7,
    FxImpactLand = BlackOpsEffectTemplate.MGQAICannonHitUnit,
    FxLandHitScale = 0.7,
    FxImpactUnderWater = {},
}

-- AEON RAIDER CANNON PROJECTILES
---@class RaiderCannonProjectile : SinglePolyTrailProjectile
RaiderCannonProjectile = Class(SinglePolyTrailProjectile) {
    FxTrails = {
        '/effects/emitters/reacton_cannon_fxtrail_01_emit.bp',
        '/effects/emitters/reacton_cannon_fxtrail_02_emit.bp',
        '/effects/emitters/reacton_cannon_fxtrail_03_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/raider_cannon_01_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/raider_cannon_02_emit.bp',
    },
    PolyTrail = '/effects/emitters/aeon_commander_overcharge_trail_01_emit.bp',

    FxImpactUnit = EffectTemplate.AReactonCannonHitUnit01,
    FxImpactProp = EffectTemplate.AReactonCannonHitUnit01,
    FxImpactLand = EffectTemplate.AReactonCannonHitLand01,
}

---@class TAAHeavyFragmentationProjectile : SingleCompositeEmitterProjectile
TAAHeavyFragmentationProjectile = Class(SingleCompositeEmitterProjectile) {
    BeamName = '/effects/emitters/antiair_munition_beam_01_emit.bp',
    PolyTrail = '/effects/emitters/default_polytrail_01_emit.bp',
    PolyTrailOffset = 0,
    FxTrails = {'/effects/emitters/terran_flack_fxtrail_01_emit.bp'},
    FxImpactAirUnit = BlackOpsEffectTemplate.THeavyFragmentationShell01,
    FxImpactNone = BlackOpsEffectTemplate.THeavyFragmentationShell01,
    FxImpactUnderWater = {},
    FxAirHitScale = 1.5,
    FxNoneHitScale = 1.5,
}

-- UEF ACU Antimatter Cannon
---@class UEFACUAntiMatterProjectile01 : EXMultiCompositeEmitterProjectile
UEFACUAntiMatterProjectile01 = Class(EXMultiCompositeEmitterProjectile) {
    PolyTrails = BlackOpsEffectTemplate.ZCannonPolytrail02,
    PolyTrailOffset = {0,0,0},
    FxTrails = BlackOpsEffectTemplate.ZCannonFxtrail02,

    -- Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.ACUAntiMatter01,
    FxImpactProp = BlackOpsEffectTemplate.ACUAntiMatter01,
    FxImpactLand = BlackOpsEffectTemplate.ACUAntiMatter01,
    FxImpactWater = BlackOpsEffectTemplate.ACUAntiMatter01,
    FxImpactUnderWater = {},
    FxSplatScale = 8,

    ---@param self UEFACUAntiMatterProjectile01
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpact = function(self, targetType, targetEntity)
        local army = self.Army
        if targetType == 'Terrain' then
            CreateDecal(self:GetPosition(), util.GetRandomFloat(0.0,6.28), 'nuke_scorch_001_normals', '', 'Alpha Normals', self.FxSplatScale, self.FxSplatScale, 150, 30, army)
            CreateDecal(self:GetPosition(), util.GetRandomFloat(0.0,6.28), 'nuke_scorch_002_albedo', '', 'Albedo', self.FxSplatScale * 2, self.FxSplatScale * 2, 150, 30, army)
            self:ShakeCamera(20, 1, 0, 1)
        end
        local pos = self:GetPosition()
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        DamageArea(self, pos, self.DamageData.DamageRadius, 1, 'Force', true)
        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
}

-- AEON Disk TMD Projectile
---@class DiskTMD01 : SinglePolyTrailProjectile
DiskTMD01 = Class(SinglePolyTrailProjectile) {
    FxTrails = {
        '/effects/emitters/quantum_cannon_munition_03_emit.bp',
        '/effects/emitters/quantum_cannon_munition_04_emit.bp',
    },
    PolyTrail = '/effects/emitters/quantum_cannon_polytrail_01_emit.bp',

    -- Hit Effects
    FxImpactLand = EffectTemplate.ATemporalFizzHit01,
    FxImpactNone= EffectTemplate.ATemporalFizzHit01,
    FxImpactProjectile = EffectTemplate.ATemporalFizzHit01,
    FxImpactProp = EffectTemplate.ATemporalFizzHit01,
    FxImpactUnit = EffectTemplate.ATemporalFizzHit01,
    FxImpactUnderWater = {},
}

---@class NovaStunProjectile : NullShell
NovaStunProjectile = Class(NullShell) {
    FxImpactTrajectoryAligned = false,
    PolyTrails = BlackOpsEffectTemplate.MGHeadshotPolytrail01,
    PolyTrailOffset = {0,0,0},
    FxTrails = BlackOpsEffectTemplate.MGHeadshotFxtrail01,

    -- Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.NovaCannonHitUnit,
    FxImpactProp = BlackOpsEffectTemplate.NovaCannonHitUnit,
    FxImpactLand = BlackOpsEffectTemplate.NovaCannonHitUnit,
    FxImpactUnderWater = BlackOpsEffectTemplate.NovaCannonHitUnit,
    FxImpactWater = BlackOpsEffectTemplate.NovaCannonHitUnit,

    ---@param self NovaStunProjectile
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpact = function(self, targetType, targetEntity)
        local blanketSides = 12
        local blanketAngle = (2*math.pi) / blanketSides
        local blanketVelocity = 2

        for i = 0, (blanketSides-1) do
            local blanketX = math.sin(i*blanketAngle)
            local blanketZ = math.cos(i*blanketAngle)
            self:CreateProjectile('/effects/entities/EffectProtonAmbient01/EffectProtonAmbient01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
                :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
        end

        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
}

---@class GLaserProjectile : MultiPolyTrailProjectile
GLaserProjectile = Class(MultiPolyTrailProjectile) {
    FxTrails = BlackOpsEffectTemplate.GoldenTurboLaserShot01FXTrail,
    PolyTrails = BlackOpsEffectTemplate.GoldenTurboLaserShot01,
}

-- Garg Weapons
---@class RedTurbolaserProjectile : MultiPolyTrailProjectile
RedTurbolaserProjectile = Class(MultiPolyTrailProjectile) {
    FxTrails = {},
    PolyTrails = BlackOpsEffectTemplate.RedTurboLaser01,

    -- Hit Effects
    FxImpactUnit = EffectTemplate.TLandGaussCannonHit01,
    FxUnitHitScale = 2,
    FxImpactProp = EffectTemplate.TLandGaussCannonHit01,
    FxPropHitScale = 2,
    FxImpactAirUnit = EffectTemplate.TLandGaussCannonHit01,
    FxAirUnitHitScale = 2,
    FxImpactLand = EffectTemplate.TLandGaussCannonHit01,
    FxLandHitScale = 2,
    FxImpactUnderWater = {},
}

---@class GargEMPWarheadProjectile : NukeProjectile, SingleBeamProjectile
GargEMPWarheadProjectile = Class(NukeProjectile, SingleBeamProjectile) {
    BeamName = '/effects/emitters/missile_exhaust_fire_beam_01_emit.bp',
    FxTrailOffset = -0.5,

    -- LAUNCH TRAILS
    FxLaunchTrails = {},

    -- TRAILS
    FxTrails = {'/effects/emitters/missile_cruise_munition_trail_01_emit.bp',},

    -- Hit Effects

    FxImpactUnit = BlackOpsEffectTemplate.GargWarheadHitUnit,
    FxImpactProp = BlackOpsEffectTemplate.GargWarheadHitUnit,
    FxImpactLand = BlackOpsEffectTemplate.GargWarheadHitUnit,
    FxImpactUnderWater = BlackOpsEffectTemplate.GargWarheadHitUnit,
    FxImpactWater = BlackOpsEffectTemplate.GargWarheadHitUnit,
    FxImpactShield = BlackOpsEffectTemplate.GargWarheadHitUnit,
    FxLandHitScale = 3,
    FxPropHitScale = 3,
    FxUnitHitScale = 3,
    FxShieldHitScale = 3,

    ---@param self GargEMPWarheadProjectile
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpact = function(self, targetType, targetEntity)

        local blanketSides = 12
        local blanketAngle = (2*math.pi) / blanketSides
        local blanketVelocity = 2
        CreateLightParticle(self, -1, -1, 80, 200, 'flare_lens_add_02', 'ramp_red_10')

        for i = 0, (blanketSides-1) do
            local blanketX = math.sin(i*blanketAngle)
            local blanketZ = math.cos(i*blanketAngle)
            self:CreateProjectile('/mods/BlackOpsFAF-Unleashed/effects/entities/EffectEMPAmbient01/EffectEMPAmbient01_proj.bp', blanketX, 0.5, blanketZ, blanketX, 0, blanketZ)
                :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
        end

        EmitterProjectile.OnImpact(self, targetType, targetEntity)
    end,
}

-- Cybran Hailfire Projectiles
---@class CybranHailfire01ChildProjectile : SinglePolyTrailProjectile
CybranHailfire01ChildProjectile = Class(SinglePolyTrailProjectile) {
    PolyTrail = '/effects/emitters/default_polytrail_05_emit.bp',
    FxTrails = BlackOpsEffectTemplate.CybranHailfire02FXTrails,
    FxTrailOffset = -0.3,
    FxTrailScale = 0.005,

    -- Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.CybranHailfire01HitUnit01,
    FxImpactProp = BlackOpsEffectTemplate.CybranHailfire01HitUnit01,
    FxImpactLand = BlackOpsEffectTemplate.CybranHailfire01HitLand01,
    FxImpactWater = BlackOpsEffectTemplate.CybranHailfire01HitWater01,
    FxImpactUnderWater = {},
    FxLandHitScale = 2,
    FxUnitHitScale = 2,
    FxPropHitScale = 2,
    FxWaterHitScale = 2,
}

---@class CybranHailfire02Projectile : SinglePolyTrailProjectile
CybranHailfire02Projectile = Class(SinglePolyTrailProjectile) {
    FxTrails = BlackOpsEffectTemplate.CybranHailfire01FXTrails,
    FxTrailOffset = -0.3,
    FxTrailScale = 0.05,
    FxImpactTrajectoryAligned = false,

    PolyTrail = EffectTemplate.CNanoDartPolyTrail01,

    -- Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.CybranHailfire01HitUnit01,
    FxImpactProp = BlackOpsEffectTemplate.CybranHailfire01HitUnit01,
    FxImpactLand = BlackOpsEffectTemplate.CybranHailfire01HitLand01,
    FxImpactWater = BlackOpsEffectTemplate.CybranHailfire01HitWater01,
    FxImpactUnderWater = {},
    FxLandHitScale = 2,
    FxUnitHitScale = 2,
    FxPropHitScale = 2,
    FxWaterHitScale = 2,
}

---@class CybranHailfire04Projectile : SinglePolyTrailProjectile
CybranHailfire04Projectile = Class(SinglePolyTrailProjectile) {
    FxTrails = BlackOpsEffectTemplate.CybranHailfire03FXTrails,
    FxTrailOffset = -0.3,
    FxTrailScale = 0.05,
    FxImpactTrajectoryAligned = false,

    PolyTrail = EffectTemplate.CNanoDartPolyTrail01,

    -- Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.CybranHailfire01HitUnit01,
    FxImpactProp = BlackOpsEffectTemplate.CybranHailfire01HitUnit01,
    FxImpactLand = BlackOpsEffectTemplate.CybranHailfire01HitLand01,
    FxImpactWater = BlackOpsEffectTemplate.CybranHailfire01HitWater01,
    FxImpactUnderWater = {},
    FxLandHitScale = 2,
    FxUnitHitScale = 2,
    FxPropHitScale = 2,
    FxWaterHitScale = 2,
}

---@class CybranHailfire03Projectile : SinglePolyTrailProjectile
CybranHailfire03Projectile = Class(SinglePolyTrailProjectile) {
    FxTrails = BlackOpsEffectTemplate.CybranHailfire01FXTrails,
    FxTrailOffset = -0.3,
    FxTrailScale = 0.05,
    FxImpactTrajectoryAligned = false,

    PolyTrail = EffectTemplate.CNanoDartPolyTrail01,

    -- Hit Effects
    FxImpactUnit = BlackOpsEffectTemplate.CybranHailfire01HitUnit01,
    FxImpactProp = BlackOpsEffectTemplate.CybranHailfire01HitUnit01,
    FxImpactLand = BlackOpsEffectTemplate.CybranHailfire01HitLand01,
    FxImpactWater = BlackOpsEffectTemplate.CybranHailfire01HitWater01,
    FxImpactUnderWater = {},
    FxLandHitScale = 2.2,
    FxUnitHitScale = 2.2,
    FxPropHitScale = 2.2,
    FxWaterHitScale = 2.2,
}

---@class RapierNapalmShellProjectile : SinglePolyTrailProjectile
RapierNapalmShellProjectile = Class(SinglePolyTrailProjectile) {
    PolyTrail = '/effects/emitters/default_polytrail_07_emit.bp',

    -- Hit Effects
    FxImpactUnit = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactProp = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactLand = EffectTemplate.TNapalmHvyCarpetBombHitLand01,
    FxImpactWater = EffectTemplate.TNapalmHvyCarpetBombHitWater01,
    FxImpactUnderWater = {},
}

---@class GoliathTMDProjectile : MultiPolyTrailProjectile
GoliathTMDProjectile = Class(MultiPolyTrailProjectile) {
    PolyTrails = BlackOpsEffectTemplate.GoliathTMD01,
    FxImpactUnit = EffectTemplate.TRiotGunHitUnit01,
    FxImpactProp = EffectTemplate.TRiotGunHitUnit01,
    FxImpactNone = EffectTemplate.FireCloudSml01,
    FxImpactLand = EffectTemplate.TRiotGunHit01,
    FxImpactUnderWater = {},
    FxImpactProjectile = EffectTemplate.TMissileHit02,
    FxProjectileHitScale = 0.7,
}

---@class CitadelHVM01Projectile : EmitterProjectile
CitadelHVM01Projectile = Class(EmitterProjectile) {
    -- Emitter Values
    FxInitial = {},
    TrailDelay = 0.3,
    FxTrails = BlackOpsEffectTemplate.CitadelHVM01Trails,
    FxTrailOffset = -0.3,
    FxTrailScale = 4,

    FxAirUnitHitScale = 1,
    FxLandHitScale = 1,
    FxUnitHitScale = 1,
    FxPropHitScale = 1,
    FxImpactUnit = EffectTemplate.TMissileHit02,
    FxImpactAirUnit = EffectTemplate.TMissileHit02,
    FxImpactProp = EffectTemplate.TMissileHit02,
    FxImpactLand = EffectTemplate.TMissileHit02,
    FxImpactUnderWater = {},
}
