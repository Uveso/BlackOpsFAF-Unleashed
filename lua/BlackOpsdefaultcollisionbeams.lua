-----------------------------------------------------------------
-- File     :  /lua/BlackOpsDefaultCollisionBeams.lua
-- Author(s):  Lt_hawkeye
-- Summary  :  Custom definitions collision beams
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local CollisionBeam = import('/lua/sim/CollisionBeam.lua').CollisionBeam
local EffectTemplate = import('/lua/EffectTemplates.lua')
local Util = import('/lua/utilities.lua')
local BlackOpsEffectTemplate = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsEffectTemplates.lua')

-- Base class that defines supreme commander specific defaults
---@class HawkCollisionBeam : CollisionBeam
HawkCollisionBeam = Class(CollisionBeam) {
    FxImpactUnit = EffectTemplate.DefaultProjectileLandUnitImpact,
    FxImpactLand = {},
    FxImpactWater = EffectTemplate.DefaultProjectileWaterImpact,
    FxImpactUnderWater = EffectTemplate.DefaultProjectileUnderWaterImpact,
    FxImpactAirUnit = EffectTemplate.DefaultProjectileAirUnitImpact,
    FxImpactProp = {},
    FxImpactShield = {},
    FxImpactNone = {},
}

-- Section including code for the ACUs Expansion Mod
---@class PDLaserCollisionBeam : HawkCollisionBeam
PDLaserCollisionBeam = Class(HawkCollisionBeam) {
    FxBeam = {'/effects/emitters/em_pdlaser_beam_01_emit.bp'},
    FxBeamEndPoint = {
        '/effects/emitters/quantum_generator_end_01_emit.bp',
        '/effects/emitters/quantum_generator_end_03_emit.bp',
        '/effects/emitters/quantum_generator_end_04_emit.bp',
    },

    FxBeamStartPoint = {
        '/effects/emitters/quantum_generator_01_emit.bp',
        '/effects/emitters/quantum_generator_02_emit.bp',
        '/effects/emitters/quantum_generator_04_emit.bp',
    },

    FxBeamStartPointScale = 0.05,
    FxBeamEndPointScale = 0.05,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 0.5,

    ---@param self PDLaserCollisionBeam
    ---@param impactType string
    ---@param targetEntity Entity
    OnImpact = function(self, impactType, targetEntity)
        if impactType == 'Terrain' then
            if self.Scorching == nil then
                self.Scorching = self:ForkThread(self.ScorchThread)
            end
        elseif not impactType == 'Unit' then
            KillThread(self.Scorching)
            self.Scorching = nil
        end
        CollisionBeam.OnImpact(self, impactType, targetEntity)
    end,

    ---@param self PDLaserCollisionBeam
    OnEnable = function(self)
        CollisionBeam.OnEnable(self)
        if self.Scorching == nil then
            self.Scorching = self:ForkThread(self.ScorchThread)
        end
    end,

    ---@param self PDLaserCollisionBeam
    OnDisable = function(self)
        CollisionBeam.OnDisable(self)
        KillThread(self.Scorching)
        self.Scorching = nil
    end,

    ---@param self PDLaserCollisionBeam
    ScorchThread = function(self)
    end,
}

---@class PDLaser2CollisionBeam : HawkCollisionBeam
PDLaser2CollisionBeam = Class(CollisionBeam) {
    FxBeamStartPoint = EffectTemplate.TDFHiroGeneratorMuzzle01,
    FxBeam = EffectTemplate.TDFHiroGeneratorBeam,
    FxBeamEndPoint = EffectTemplate.TDFHiroGeneratorHitLand,
    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 0.25,
    FxBeamStartPointScale = 0.75,
    FxBeamEndPointScale = 0.75,

    ---@param self PDLaser2CollisionBeam
    ---@param impactType string
    ---@param targetEntity Entity
    OnImpact = function(self, impactType, targetEntity)
        if impactType == 'Terrain' then
            if self.Scorching == nil then
                self.Scorching = self:ForkThread(self.ScorchThread)
            end
        elseif not impactType == 'Unit' then
            KillThread(self.Scorching)
            self.Scorching = nil
        end
        CollisionBeam.OnImpact(self, impactType, targetEntity)
    end,

    ---@param self PDLaser2CollisionBeam
    OnDisable = function(self)
        CollisionBeam.OnDisable(self)
        KillThread(self.Scorching)
        self.Scorching = nil
    end,

    ---@param self PDLaser2CollisionBeam
    ScorchThread = function(self)
    end,
}

-- SEADRAGON & REAPER BEAMS
---@class MiniMicrowaveLaserCollisionBeam01 : HawkCollisionBeam
MartyrMicrowaveLaserCollisionBeam01 = Class(HawkCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.2,
    FxBeamStartPointScale = 0.2,
    FxBeamStartPoint = EffectTemplate.CMicrowaveLaserMuzzle01,
    FxBeam = {'/mods/BlackOpsFAF-Unleashed/effects/emitters/mini_microwave_laser_beam_01_emit.bp'},
    FxBeamEndPoint = EffectTemplate.CMicrowaveLaserEndPoint01,
    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 0.25,
}

-- Mini QUANTUM BEAM GENERATOR COLLISION BEAM
---@class MiniQuantumBeamGeneratorCollisionBeam : HawkCollisionBeam
MiniQuantumBeamGeneratorCollisionBeam = Class(HawkCollisionBeam) {
    TerrainImpactType = 'LargeBeam02',
    TerrainImpactScale = 0.2,

    FxBeam = {'/mods/BlackOpsFAF-Unleashed/effects/emitters/mini_quantum_generator_beam_01_emit.bp'},
    FxBeamEndPoint = {
        '/effects/emitters/quantum_generator_end_01_emit.bp',
        '/effects/emitters/quantum_generator_end_03_emit.bp',
        '/effects/emitters/quantum_generator_end_04_emit.bp',
    },
    FxBeamEndPointScale = 0.2,
    FxBeamStartPoint = {
        '/effects/emitters/quantum_generator_01_emit.bp',
        '/effects/emitters/quantum_generator_02_emit.bp',
        '/effects/emitters/quantum_generator_04_emit.bp',
    },
    FxBeamStartPointScale = 0.2,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 0.5,

    ---@param self MiniQuantumBeamGeneratorCollisionBeam
    ---@param impactType string
    ---@param targetEntity Entity
    OnImpact = function(self, impactType, targetEntity)
        if impactType == 'Terrain' then
            if self.Scorching == nil then
                self.Scorching = self:ForkThread(self.ScorchThread)
            end
        elseif not impactType == 'Unit' then
            KillThread(self.Scorching)
            self.Scorching = nil
        end
        CollisionBeam.OnImpact(self, impactType, targetEntity)
    end,

    ---@param self MiniQuantumBeamGeneratorCollisionBeam
    OnEnable = function(self)
        CollisionBeam.OnEnable(self)
        if self.Scorching == nil then
            self.Scorching = self:ForkThread(self.ScorchThread)
        end
    end,

    ---@param self MiniQuantumBeamGeneratorCollisionBeam
    OnDisable = function(self)
        CollisionBeam.OnDisable(self)
        KillThread(self.Scorching)
        self.Scorching = nil
    end,

    ---@param self MiniQuantumBeamGeneratorCollisionBeam
    ScorchThread = function(self)
        local army = self.Army
        local size = 3.5 + (Random() * 3.5)
        local CurrentPosition = self:GetPosition(1)
        local LastPosition = Vector(0,0,0)
        local skipCount = 1
        while true do
            if Util.GetDistanceBetweenTwoVectors(CurrentPosition, LastPosition) > 0.25 or skipCount > 100 then
                CreateSplat(CurrentPosition, Util.GetRandomFloat(0,2*math.pi), self.SplatTexture, size, size, 250, 250, army)
                LastPosition = CurrentPosition
                skipCount = 1
            else
                skipCount = skipCount + self.ScorchSplatDropTime
            end

            WaitSeconds(self.ScorchSplatDropTime)
            size = 3.2 + (Random() * 3.5)
            CurrentPosition = self:GetPosition(1)
        end
    end,
}

-- Super QUANTUM BEAM GENERATOR COLLISION BEAM
---@class SuperQuantumBeamGeneratorCollisionBeam : HawkCollisionBeam
SuperQuantumBeamGeneratorCollisionBeam = Class(HawkCollisionBeam) {
    TerrainImpactType = 'LargeBeam02',
    TerrainImpactScale = 1,

    FxBeam = {'/mods/BlackOpsFAF-Unleashed/effects/emitters/super_quantum_generator_beam_01_emit.bp'},
    FxBeamEndPoint = {
        '/effects/emitters/quantum_generator_end_01_emit.bp',
        '/effects/emitters/quantum_generator_end_03_emit.bp',
        '/effects/emitters/quantum_generator_end_04_emit.bp',
        '/effects/emitters/quantum_generator_end_05_emit.bp',
        '/effects/emitters/quantum_generator_end_06_emit.bp',
    },
    FxBeamEndPointScale = 0.6,
    FxBeamStartPoint = {
        '/effects/emitters/quantum_generator_01_emit.bp',
        '/effects/emitters/quantum_generator_02_emit.bp',
        '/effects/emitters/quantum_generator_04_emit.bp',
    },
    FxBeamStartPointScale = 0.6,

    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 0.5,

    ---@param self SuperQuantumBeamGeneratorCollisionBeam
    ---@param impactType string
    ---@param targetEntity Entity
    OnImpact = function(self, impactType, targetEntity)
        if impactType == 'Terrain' then
            if self.Scorching == nil then
                self.Scorching = self:ForkThread(self.ScorchThread)
            end
        elseif not impactType == 'Unit' then
            KillThread(self.Scorching)
            self.Scorching = nil
        end
        CollisionBeam.OnImpact(self, impactType, targetEntity)
    end,

    ---@param self SuperQuantumBeamGeneratorCollisionBeam
    OnEnable = function(self)
        CollisionBeam.OnEnable(self)
        if self.Scorching == nil then
            self.Scorching = self:ForkThread(self.ScorchThread)
        end
    end,

    ---@param self SuperQuantumBeamGeneratorCollisionBeam
    OnDisable = function(self)
        CollisionBeam.OnDisable(self)
        KillThread(self.Scorching)
        self.Scorching = nil
    end,

    ---@param self SuperQuantumBeamGeneratorCollisionBeam
    ScorchThread = function(self)
        local army = self.Army
        local size = 3.5 + (Random() * 3.5)
        local CurrentPosition = self:GetPosition(1)
        local LastPosition = Vector(0,0,0)
        local skipCount = 1
        while true do
            if Util.GetDistanceBetweenTwoVectors(CurrentPosition, LastPosition) > 0.25 or skipCount > 100 then
                CreateSplat(CurrentPosition, Util.GetRandomFloat(0,2*math.pi), self.SplatTexture, size, size, 250, 250, army)
                LastPosition = CurrentPosition
                skipCount = 1
            else
                skipCount = skipCount + self.ScorchSplatDropTime
            end

            WaitSeconds(self.ScorchSplatDropTime)
            size = 3.2 + (Random() * 3.5)
            CurrentPosition = self:GetPosition(1)
        end
    end,
}

---@class MiniPhasonLaserCollisionBeam : HawkCollisionBeam
MiniPhasonLaserCollisionBeam = Class(HawkCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.5,
    FxBeamStartPoint = EffectTemplate.APhasonLaserMuzzle01,
    FxBeam = {'/mods/BlackOpsFAF-Unleashed/effects/emitters/mini_phason_laser_beam_01_emit.bp'},
    FxBeamStartPointScale = 0.2,
    FxBeamEndPoint = EffectTemplate.APhasonLaserImpact01,
    FxBeamEndPointScale = 0.4,
    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 0.25,

    ---@param self MiniPhasonLaserCollisionBeam
    ---@param impactType string
    ---@param targetEntity Entity
    OnImpact = function(self, impactType, targetEntity)
        if impactType == 'Terrain' then
            if self.Scorching == nil then
                self.Scorching = self:ForkThread(self.ScorchThread)
            end
        elseif not impactType == 'Unit' then
            KillThread(self.Scorching)
            self.Scorching = nil
        end
        CollisionBeam.OnImpact(self, impactType, targetEntity)
    end,

    ---@param self MiniPhasonLaserCollisionBeam
    OnEnable = function(self)
        CollisionBeam.OnEnable(self)
        if self.Scorching == nil then
            self.Scorching = self:ForkThread(self.ScorchThread)
        end
    end,

    ---@param self MiniPhasonLaserCollisionBeam
    OnDisable = function(self)
        CollisionBeam.OnDisable(self)
        KillThread(self.Scorching)
        self.Scorching = nil
    end,

    ---@param self MiniPhasonLaserCollisionBeam
    ScorchThread = function(self)
        local army = self.Army
        local size = 1.5 + (Random() * 1.5)
        local CurrentPosition = self:GetPosition(1)
        local LastPosition = Vector(0,0,0)
        local skipCount = 1
        while true do
            if Util.GetDistanceBetweenTwoVectors(CurrentPosition, LastPosition) > 0.25 or skipCount > 100 then
                CreateSplat(CurrentPosition, Util.GetRandomFloat(0,2*math.pi), self.SplatTexture, size, size, 100, 100, army)
                LastPosition = CurrentPosition
                skipCount = 1
            else
                skipCount = skipCount + self.ScorchSplatDropTime
            end

            WaitSeconds(self.ScorchSplatDropTime)
            size = 1.2 + (Random() * 1.5)
            CurrentPosition = self:GetPosition(1)
        end
    end,
}

---@class MiniMicrowaveLaserCollisionBeam01 : HawkCollisionBeam
MiniMicrowaveLaserCollisionBeam01 = Class(HawkCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.2,
    FxBeamStartPoint = EffectTemplate.CMicrowaveLaserMuzzle01,
    FxBeamStartPointScale = 0.2,
    FxBeam = {'/mods/BlackOpsFAF-Unleashed/effects/emitters/mini_microwave_laser_beam_01_emit.bp'},
    FxBeamEndPoint = EffectTemplate.CMicrowaveLaserEndPoint01,
    FxBeamEndPointScale = 0.2,
    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 0.25,

    ---@param self MiniMicrowaveLaserCollisionBeam01
    ---@param impactType string
    ---@param targetEntity Entity
    OnImpact = function(self, impactType, targetEntity)
        if impactType == 'Terrain' then
            if self.Scorching == nil then
                self.Scorching = self:ForkThread(self.ScorchThread)
            end
        elseif not impactType == 'Unit' then
            KillThread(self.Scorching)
            self.Scorching = nil
        end
        CollisionBeam.OnImpact(self, impactType, targetEntity)
    end,

    ---@param self MiniMicrowaveLaserCollisionBeam01
    OnEnable = function(self)
        CollisionBeam.OnEnable(self)
        if self.Scorching == nil then
            self.Scorching = self:ForkThread(self.ScorchThread)
        end
    end,

    ---@param self MiniMicrowaveLaserCollisionBeam01
    OnDisable = function(self)
        CollisionBeam.OnDisable(self)
        KillThread(self.Scorching)
        self.Scorching = nil
    end,

    ---@param self MiniMicrowaveLaserCollisionBeam01
    ScorchThread = function(self)
        local army = self.Army
        local size = 1.5 + (Random() * 1.5)
        local CurrentPosition = self:GetPosition(1)
        local LastPosition = Vector(0,0,0)
        local skipCount = 1
        while true do
            if Util.GetDistanceBetweenTwoVectors(CurrentPosition, LastPosition) > 0.25 or skipCount > 100 then
                CreateSplat(CurrentPosition, Util.GetRandomFloat(0,2*math.pi), self.SplatTexture, size, size, 100, 100, army)
                LastPosition = CurrentPosition
                skipCount = 1
            else
                skipCount = skipCount + self.ScorchSplatDropTime
            end

            WaitSeconds(self.ScorchSplatDropTime)
            size = 1.2 + (Random() * 1.5)
            CurrentPosition = self:GetPosition(1)
        end
    end,
}

---@class HawkTractorClawCollisionBeam : HawkCollisionBeam
HawkTractorClawCollisionBeam = Class(HawkCollisionBeam) {
    FxBeam = {EffectTemplate.TTransportBeam01},
    FxBeamEndPoint = {EffectTemplate.TTransportGlow01},
    FxBeamEndPointScale = 1.0,
    FxBeamStartPoint = {EffectTemplate.TTransportGlow01},
}

-- Juggernaut LASERS
---@class JuggLaserCollisionBeam : HawkCollisionBeam
JuggLaserCollisionBeam = Class(HawkCollisionBeam) {
    TerrainImpactType = 'LargeBeam02',
    TerrainImpactScale = 0.02,

    FxBeam = {'/mods/BlackOpsFAF-Unleashed/effects/emitters/jugg_laser_beam_01_emit.bp'},
    FxBeamEndPoint = {
        '/effects/emitters/quantum_generator_end_01_emit.bp',
        '/effects/emitters/quantum_generator_end_03_emit.bp',
        '/effects/emitters/quantum_generator_end_04_emit.bp',
    },
    FxBeamEndPointScale = 0.02,
    FxBeamStartPoint = {
        '/effects/emitters/quantum_generator_01_emit.bp',
        '/effects/emitters/quantum_generator_02_emit.bp',
        '/effects/emitters/quantum_generator_04_emit.bp',
    },
    FxBeamStartPointScale = 0.02,
}

-- ShadowCat beam
---@class RailLaserCollisionBeam01 : HawkCollisionBeam
RailLaserCollisionBeam01 = Class(HawkCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.2,
    FxBeamStartPoint = EffectTemplate.CMicrowaveLaserMuzzle01,
    FxBeamStartPointScale = 0.2,
    FxBeam = {'/mods/BlackOpsFAF-Unleashed/effects/emitters/rail_microwave_laser_beam_01_emit.bp'},
    FxBeamEndPoint = EffectTemplate.CMicrowaveLaserEndPoint01,
    FxBeamEndPointScale = 0.2,
    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 0.25,

    ---@param self RailLaserCollisionBeam01
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpactDestroy = function(self, targetType, targetEntity)
       if targetEntity and not IsUnit(targetEntity) then
          RailLaserCollisionBeam01.OnImpactDestroy(self, targetType, targetEntity)
          return
       end

       if self.counter then
          if self.counter >= 3 then
             RailLaserCollisionBeam01.OnImpactDestroy(self, targetType, targetEntity)
             return
          else
             self.counter = self.counter + 1
          end
           else
              self.counter = 1
           end
           if targetEntity then
            self.lastimpact = targetEntity:GetEntityId()
        end
    end,
}

-- ZAPPER STUN BEAM
---@class EMCHPRFDisruptorBeam : HawkCollisionBeam
EMCHPRFDisruptorBeam = Class(HawkCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.3,
    FxBeamStartPoint = EffectTemplate.CMicrowaveLaserMuzzle01,
    FxBeamStartPointScale = 0.3,
    FxBeam = {'/mods/BlackOpsFAF-Unleashed/effects/emitters/manticore_microwave_laser_beam_01_emit.bp'},
    FxBeamEndPoint = EffectTemplate.CMicrowaveLaserEndPoint01,
    FxBeamEndPointScale = 0.3,
    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 0.25,

    ---@param self EMCHPRFDisruptorBeam
    ---@param impactType string
    ---@param targetEntity Entity
    OnImpact = function(self, impactType, targetEntity)
        if targetEntity then
            if EntityCategoryContains(categories.TECH1, targetEntity) then
                targetEntity:SetStunned(0.2)
            elseif EntityCategoryContains(categories.TECH2, targetEntity) then
                targetEntity:SetStunned(0.2)
            elseif EntityCategoryContains(categories.TECH3, targetEntity) and not EntityCategoryContains(categories.SUBCOMMANDER, targetEntity) then--SUBCOMS HAVE SUMCOM ADDED IN MOD
                targetEntity:SetStunned(0.2)
            end
        end

        HawkCollisionBeam.OnImpact(self, impactType, targetEntity)
    end,
}

-- HIRO LASER COLLISION BEAM
---@class TDFGoliathCollisionBeam : HawkCollisionBeam
TDFGoliathCollisionBeam = Class(HawkCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 1,
    FxBeamEndPoint = {
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/goliath_death_laser_end_01_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/goliath_death_laser_end_02_emit.bp',
        '/effects/emitters/uef_orbital_death_laser_end_03_emit.bp',
        '/effects/emitters/uef_orbital_death_laser_end_04_emit.bp',
        '/effects/emitters/uef_orbital_death_laser_end_05_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/goliath_death_laser_end_06_emit.bp',
        '/effects/emitters/uef_orbital_death_laser_end_07_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/goliath_death_laser_end_08_emit.bp',
        '/effects/emitters/uef_orbital_death_laser_end_distort_emit.bp',
    },
    FxBeamStartPointScale = 1,
    FxBeam = {'/mods/BlackOpsFAF-Unleashed/effects/emitters/goliath_death_laser_beam_01_emit.bp'},
    FxBeamStartPoint = {
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/goliath_death_laser_muzzle_01_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/goliath_death_laser_muzzle_02_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/goliath_death_laser_muzzle_03_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/goliath_death_laser_muzzle_04_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/goliath_death_laser_muzzle_05_emit.bp',
    },
    FxBeamEndPointScale = 1,
    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 0.25,

    ---@param self TDFGoliathCollisionBeam
    ---@param impactType string
    ---@param targetEntity Entity
    OnImpact = function(self, impactType, targetEntity)
        if impactType == 'Terrain' then
            if self.Scorching == nil then
                self.Scorching = self:ForkThread(self.ScorchThread)
            end
        elseif not impactType == 'Unit' then
            KillThread(self.Scorching)
            self.Scorching = nil
        end
        CollisionBeam.OnImpact(self, impactType, targetEntity)
    end,

    ---@param self TDFGoliathCollisionBeam
    OnDisable = function(self)
        CollisionBeam.OnDisable(self)
        KillThread(self.Scorching)
        self.Scorching = nil
    end,

    ---@param self TDFGoliathCollisionBeam
    ScorchThread = function(self)
        local army = self.Army
        local size = 0.75 + (Random() * 0.75)
        local CurrentPosition = self:GetPosition(1)
        local LastPosition = Vector(0,0,0)
        local skipCount = 1
        while true do
            if Util.GetDistanceBetweenTwoVectors(CurrentPosition, LastPosition) > 0.25 or skipCount > 100 then
                CreateSplat(CurrentPosition, Util.GetRandomFloat(0,2*math.pi), self.SplatTexture, size, size, 100, 100, army)
                LastPosition = CurrentPosition
                skipCount = 1
            else
                skipCount = skipCount + self.ScorchSplatDropTime
            end

            WaitSeconds(self.ScorchSplatDropTime)
            size = 1.2 + (Random() * 1.5)
            CurrentPosition = self:GetPosition(1)
        end
    end,
}

-- MGAALaser CANNON COLLISION BEAM
---@class MGAALaserCollisionBeam : HawkCollisionBeam
MGAALaserCollisionBeam = Class(HawkCollisionBeam) {
    FxBeam = {
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/aa_cannon_beam_01_emit.bp',
    },
    FxBeamEndPoint = {
        '/effects/emitters/particle_cannon_end_01_emit.bp',
        '/effects/emitters/particle_cannon_end_02_emit.bp',
    },
    FxBeamEndPointScale = 1,
}

-- Aeon t4 beam
---@class GoldenLaserCollisionBeam01 : HawkCollisionBeam
GoldenLaserCollisionBeam01 = Class(HawkCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 0.2,
    FxBeamStartPointScale = 0.2,
    FxBeamStartPoint = BlackOpsEffectTemplate.GLaserMuzzle01,
    FxBeam = {'/mods/BlackOpsFAF-Unleashed/effects/emitters/mini_golden_laser_beam_01_emit.bp'},
    FxBeamEndPoint = BlackOpsEffectTemplate.GLaserEndPoint01,
    FxBeamEndPointScale = 0.2,
    SplatTexture = 'czar_mark01_albedo',
    ScorchSplatDropTime = 0.25,
}

---@class YenaothaExperimentalLaserCollisionBeam : HawkCollisionBeam
YenaothaExperimentalLaserCollisionBeam = Class(HawkCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 1,
    FxBeamStartPoint = EffectTemplate.SExperimentalPhasonLaserMuzzle01,
    FxBeam = EffectTemplate.SExperimentalPhasonLaserBeam,
    FxBeamEndPoint = EffectTemplate.SExperimentalPhasonLaserHitLand,
    SplatTexture = 'scorch_004_albedo',
    ScorchSplatDropTime = 0.1,

    ---@param self YenaothaExperimentalLaserCollisionBeam
    ---@param impactType string
    ---@param targetEntity Entity
    OnImpact = function(self, impactType, targetEntity)
        if impactType == 'Terrain' then
            if self.Scorching == nil then
                self.Scorching = self:ForkThread(self.ScorchThread)
            end
        elseif not impactType == 'Unit' then
            KillThread(self.Scorching)
            self.Scorching = nil
        end
        CollisionBeam.OnImpact(self, impactType, targetEntity)
    end,

    ---@param self YenaothaExperimentalLaserCollisionBeam
    OnDisable = function(self)
        CollisionBeam.OnDisable(self)
        KillThread(self.Scorching)
        self.Scorching = nil
    end,

    ---@param self YenaothaExperimentalLaserCollisionBeam
    ScorchThread = function(self)
        local army = self.Army
        local size = 4.0 + (Random() * 1.0)
        local CurrentPosition = self:GetPosition(1)
        local LastPosition = Vector(0,0,0)
        local skipCount = 1
        while true do
            if Util.GetDistanceBetweenTwoVectors(CurrentPosition, LastPosition) > 0.25 or skipCount > 100 then
                CreateSplat(CurrentPosition, Util.GetRandomFloat(0,2*math.pi), self.SplatTexture, size, size, 100, 100, army)
                LastPosition = CurrentPosition
                skipCount = 1
            else
                skipCount = skipCount + self.ScorchSplatDropTime
            end

            WaitSeconds(self.ScorchSplatDropTime)
            size = 4.0 + (Random() * 1.0)
            CurrentPosition = self:GetPosition(1)
        end
    end,
}

---@class YenaothaExperimentalLaser02CollisionBeam : HawkCollisionBeam
YenaothaExperimentalLaser02CollisionBeam = Class(HawkCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 1,
    FxBeamStartPoint = EffectTemplate.SExperimentalPhasonLaserMuzzle01,
    FxBeamStartPointScale = 0.2,
    FxBeam = BlackOpsEffectTemplate.SExperimentalDronePhasonLaserBeam,
    FxBeamEndPoint = EffectTemplate.SExperimentalPhasonLaserHitLand,
    FxBeamEndPointScale = 0.2,
    SplatTexture = 'scorch_004_albedo',
    ScorchSplatDropTime = 0.1,

    ---@param self YenaothaExperimentalLaser02CollisionBeam
    ---@param impactType string
    ---@param targetEntity Entity
    OnImpact = function(self, impactType, targetEntity)
        if impactType == 'Terrain' then
            if self.Scorching == nil then
                self.Scorching = self:ForkThread(self.ScorchThread)
            end
        elseif not impactType == 'Unit' then
            KillThread(self.Scorching)
            self.Scorching = nil
        end
        CollisionBeam.OnImpact(self, impactType, targetEntity)
    end,

    ---@param self YenaothaExperimentalLaser02CollisionBeam
    OnDisable = function(self)
        CollisionBeam.OnDisable(self)
        KillThread(self.Scorching)
        self.Scorching = nil
    end,

    ---@param self YenaothaExperimentalLaser02CollisionBeam
    ScorchThread = function(self)
        local army = self.Army
        local size = 4.0 + (Random() * 1.0)
        local CurrentPosition = self:GetPosition(1)
        local LastPosition = Vector(0,0,0)
        local skipCount = 1
        while true do
            if Util.GetDistanceBetweenTwoVectors(CurrentPosition, LastPosition) > 0.25 or skipCount > 100 then
                CreateSplat(CurrentPosition, Util.GetRandomFloat(0,2*math.pi), self.SplatTexture, size, size, 100, 100, army)
                LastPosition = CurrentPosition
                skipCount = 1
            else
                skipCount = skipCount + self.ScorchSplatDropTime
            end

            WaitSeconds(self.ScorchSplatDropTime)
            size = 4.0 + (Random() * 1.0)
            CurrentPosition = self:GetPosition(1)
        end
    end,
}

---@class YenaothaExperimentalChargeLaserCollisionBeam : HawkCollisionBeam
YenaothaExperimentalChargeLaserCollisionBeam = Class(HawkCollisionBeam) {
    TerrainImpactType = 'LargeBeam01',
    TerrainImpactScale = 1,
    FxBeamStartPoint = EffectTemplate.SExperimentalPhasonLaserMuzzle01,
    FxBeamStartPointScale = 0.5,
    FxBeam = BlackOpsEffectTemplate.SExperimentalChargePhasonLaserBeam,
    FxBeamEndPoint = EffectTemplate.SExperimentalPhasonLaserHitLand,
    FxBeamEndPointScale = 0.5,
}
