----------------------------------------------------------------------------------------------------------------
-- File     :  \data\effects\Entities\ArtemisBombEffectController0101\ArtemisBombEffectController0101_script.lua
-- Author(s):  Greg Kohne
-- Summary  :  Ohwalli Bomb effect controller script, non-damaging
-- Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.
----------------------------------------------------------------------------------------------------------------

local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local BlackOpsEffectTemplate = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsEffectTemplates.lua')
local ArtemisBombEffect04 = '/mods/BlackOpsFAF-Unleashed/effects/Entities/ArtemisBombEffect04/ArtemisBombEffect04_proj.bp'
local ArtemisBombEffect05 = '/mods/BlackOpsFAF-Unleashed/effects/Entities/ArtemisBombEffect05/ArtemisBombEffect05_proj.bp'
local ArtemisBombEffect06 = '/mods/BlackOpsFAF-Unleashed/effects/Entities/ArtemisBombEffect06/ArtemisBombEffect06_proj.bp'

-- Upvalue for performance
local TrashBagAdd = TrashBag.Add
local MathPi = math.pi
local MathSin = math.sin
local MathCos = math.cos

---@class ArtemisBombEffectController01 : NullShell
ArtemisBombEffectController01 = Class(NullShell) {
    NukeInnerRingDamage = 70000,
    NukeInnerRingRadius = 15,
    NukeInnerRingTicks = 20,
    NukeInnerRingTotalTime = 0,
    NukeOuterRingDamage = 500,
    NukeOuterRingRadius = 25,
    NukeOuterRingTicks = 20,
    NukeOuterRingTotalTime = 0,

    ---@param self ArtemisBombEffectController01
    ---@param Data table
    PassData = function(self, Data)
        if Data.NukeOuterRingDamage then self.NukeOuterRingDamage = Data.NukeOuterRingDamage end
        if Data.NukeOuterRingRadius then self.NukeOuterRingRadius = Data.NukeOuterRingRadius end
        if Data.NukeOuterRingTicks then self.NukeOuterRingTicks = Data.NukeOuterRingTicks end
        if Data.NukeOuterRingTotalTime then self.NukeOuterRingTotalTime = Data.NukeOuterRingTotalTime end
        if Data.NukeInnerRingDamage then self.NukeInnerRingDamage = Data.NukeInnerRingDamage end
        if Data.NukeInnerRingRadius then self.NukeInnerRingRadius = Data.NukeInnerRingRadius end
        if Data.NukeInnerRingTicks then self.NukeInnerRingTicks = Data.NukeInnerRingTicks end
        if Data.NukeInnerRingTotalTime then self.NukeInnerRingTotalTime = Data.NukeInnerRingTotalTime end

        self:CreateNuclearExplosion()
    end,

    ---@param self ArtemisBombEffectController01
    CreateNuclearExplosion = function(self)
        local bp = self.Blueprint
        local trash = self.Trash

        -- Play the "NukeExplosion" sound
        if bp.Audio.NukeExplosion then
            self:PlaySound(bp.Audio.NukeExplosion)
        end

        -- Create Damage Threads only if damage is being delivered (prevents DamageArea script error for passing in 0 value)
        if (self.NukeInnerRingDamage ~= 0) then
            TrashBagAdd(trash, ForkThread(self.InnerRingDamage, self))
        end
        if (self.NukeOuterRingDamage ~= 0) then
            TrashBagAdd(trash, ForkThread(self.OuterRingDamage, self))
        end

        -- Create thread that spawns and controls effects
        TrashBagAdd(trash, ForkThread(self.EffectThread, self))
        TrashBagAdd(trash, ForkThread(self.CreateEffectInnerPlasma, self))
        TrashBagAdd(trash, ForkThread(self.CreateEffectElectricity, self))
    end,

    ---@param self ArtemisBombEffectController01
    OuterRingDamage = function(self)
        local myPos = self:GetPosition()
        local launcher = self.Launcher

        if self.NukeOuterRingTotalTime == 0 then
            DamageArea(launcher, myPos, self.NukeOuterRingRadius, self.NukeOuterRingDamage, 'Normal', true, true)
        else
            local ringWidth = (self.NukeOuterRingRadius / self.NukeOuterRingTicks)
            local tickLength = (self.NukeOuterRingTotalTime / self.NukeOuterRingTicks)
            -- Since we're not allowed to have an inner radius of 0 in the DamageRing function,
            -- I'm manually executing the first tick of damage with a DamageArea function.
            DamageArea(launcher, myPos, ringWidth, self.NukeOuterRingDamage, 'Normal', true, true)
            WaitSeconds(tickLength)
            for i = 2, self.NukeOuterRingTicks do
                DamageRing(launcher, myPos, ringWidth * (i - 1), ringWidth * i, self.NukeOuterRingDamage, 'Normal', true, true)
                WaitSeconds(tickLength)
            end
        end
    end,

    ---@param self ArtemisBombEffectController01
    InnerRingDamage = function(self)
        local myPos = self:GetPosition()
        local launcher = self.Launcher

        if self.NukeInnerRingTotalTime == 0 then
            DamageArea(launcher, myPos, self.NukeInnerRingRadius, self.NukeInnerRingDamage, 'Normal', true, true)
        else
            local ringWidth = (self.NukeInnerRingRadius / self.NukeInnerRingTicks)
            local tickLength = (self.NukeInnerRingTotalTime / self.NukeInnerRingTicks)

            -- Since we're not allowed to have an inner radius of 0 in the DamageRing function,
            -- I'm manually executing the first tick of damage with a DamageArea function.
            DamageArea(launcher, myPos, ringWidth, self.NukeInnerRingDamage, 'Normal', true, true)
            WaitSeconds(tickLength)
            for i = 2, self.NukeInnerRingTicks do
                DamageRing(launcher, myPos, ringWidth * (i - 1), ringWidth * i, self.NukeInnerRingDamage, 'Normal', true, true)
                WaitSeconds(tickLength)
            end
        end
    end,

    -- Create inner explosion plasma
    ---@param self ArtemisBombEffectController01
    CreateEffectInnerPlasma = function(self)
        local num_projectiles = 10
        local horizontal_angle = (2*MathPi) / num_projectiles
        local angleInitial = RandomFloat(0, horizontal_angle)
        local xVec, zVec
        local offsetMultiple = 10.0
        local px, pz

        for i = 0, (num_projectiles -1) do
            xVec = (MathSin(angleInitial + (i*horizontal_angle)))
            zVec = (MathCos(angleInitial + (i*horizontal_angle)))
            px = (offsetMultiple*xVec)
            pz = (offsetMultiple*zVec)

            local proj = self:CreateProjectile(ArtemisBombEffect05, px, -10, pz, xVec, 0, zVec)
            proj:SetLifetime(5.0)
            proj:SetVelocity(7.0)
            proj:SetAcceleration(-0.35)
        end
    end,

    -- Create random wavy electricity lines
    ---@param self ArtemisBombEffectController01
    CreateEffectElectricity = function(self)
        local num_projectiles = 12
        local horizontal_angle = (2*MathPi) / num_projectiles
        local angleInitial = RandomFloat(0, horizontal_angle)
        local xVec, zVec
        local offsetMultiple = 0.0
        local px, pz

        for i = 0, (num_projectiles -1) do
            xVec = (MathSin(angleInitial + (i*horizontal_angle)))
            zVec = (MathCos(angleInitial + (i*horizontal_angle)))
            px = (offsetMultiple*xVec)
            pz = (offsetMultiple*zVec)

            local proj = self:CreateProjectile(ArtemisBombEffect06, px, -8, pz, xVec, 0, zVec)
            proj:SetLifetime(3.0)
            proj:SetVelocity(RandomFloat(11, 20))
            proj:SetAcceleration(-0.35)
        end
    end,

    ---@param self ArtemisBombEffectController01
    EffectThread = function(self)
        local army = self.Army
        local position = self:GetPosition()

        -- Create a light for this thing's flash.
        CreateLightParticle(self, -1, army, 80, 14, 'flare_lens_add_03', 'ramp_white_07')

        -- Create ground decals
        local orientation = RandomFloat(0,2*math.pi)
        CreateDecal(position, orientation, 'Scorch_012_albedo', '', 'Albedo', 250, 250, 1200, 0, army)
        CreateDecal(position, orientation, 'Crater01_normals', '', 'Normals', 100, 100, 1200, 0, army)

        -- Knockdown force rings
        DamageRing(self, position, 0.1, 35, 1, 'Force', true, true)
        WaitSeconds(0.1)
        DamageRing(self, position, 0.1, 35, 1, 'Force', true, true)

        -- Create explosion effects
        for _, v in BlackOpsEffectTemplate.GoldLaserBombDetonate01 do
            CreateEmitterAtEntity(self,army,v):ScaleEmitter(1.5)
        end


        -- Create explosion effects
        for _, v in BlackOpsEffectTemplate.ArtemisBombHit01 do
            CreateEmitterAtEntity(self,army,v):ScaleEmitter(0.3)
        end

        self:ShakeCamera(15, 5, 0, 1.5)

        WaitSeconds(0.3)

        -- Create fireball plumes to accentuate the explosive detonation
        local num_projectiles = 25
        local horizontal_angle = (2*MathPi) / num_projectiles
        local angleInitial = RandomFloat(0, horizontal_angle)
        local xVec, yVec, zVec
        local angleVariation = 0.5
        local px, py, pz

        for i = 0, (num_projectiles -1) do
            xVec = MathSin(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation))
            yVec = RandomFloat(0.3, 1.5) + 1.2
            zVec = MathCos(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation))
            px = RandomFloat(0.5, 1.0) * xVec
            py = RandomFloat(0.5, 1.0) * yVec
            pz = RandomFloat(0.5, 1.0) * zVec

            local proj = self:CreateProjectile(ArtemisBombEffect04, px, py, pz, xVec, yVec, zVec)
            proj:SetVelocity(RandomFloat(10, 25))
            proj:SetBallisticAcceleration(-9.8)
        end
    end,
}

TypeClass = ArtemisBombEffectController01
