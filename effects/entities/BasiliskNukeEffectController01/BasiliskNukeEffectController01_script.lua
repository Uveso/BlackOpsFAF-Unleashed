--------------------------------------------------------------------------------------------------------------
-- File     :  \data\effects\Entities\CybranNukeEffectController0101\CybranNukeEffectController0101_script.lua
-- Author(s):  Greg Kohne
-- Summary  :  Ohwalli Bomb effect controller script, non-damaging
-- Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.
--------------------------------------------------------------------------------------------------------------

local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local BasiliskNukeEffect04 = '/mods/BlackOpsFAF-Unleashed/projectiles/MGQAIPlasmaArty01/MGQAIPlasmaArty01_proj.bp'
local BasiliskNukeEffect05 = '/mods/BlackOpsFAF-Unleashed/effects/Entities/BasiliskNukeEffect05/CybranNukeEffect05_proj.bp'

-- Upvalue for performance
local TrashBagAdd = TrashBag.Add
local MathPi = math.pi
local MathSin = math.sin
local MathCos = math.cos
local RandomFloat = RandomFloat

---@class BasiliskNukeEffectController01 : NullShell
BasiliskNukeEffectController01 = Class(NullShell) {

    ---@param self BasiliskNukeEffectController01
    ---@param Data table unused
    PassData = function(self, Data)
        self:CreateNuclearExplosion()
    end,

    ---@param self BasiliskNukeEffectController01
    CreateNuclearExplosion = function(self)
        local army = self.Army
        local trash = self.Trash

        CreateLightParticle(self, -1, army, 50, 100, 'beam_white_01', 'ramp_blue_16')
        self:ShakeCamera(75, 3, 0, 10)

        TrashBagAdd(trash, ForkThread(self.EffectThread, self))
        TrashBagAdd(trash, ForkThread(self.CreateEffectInnerPlasma, self))
    end,

    ---@param self BasiliskNukeEffectController01
    OuterRingDamage = function(self)
        local myPos = self:GetPosition()
        local launcher = self.Launcher

        if self.NukeOuterRingTotalTime == 0 then
            DamageArea(slauncher, myPos, self.NukeOuterRingRadius, self.NukeOuterRingDamage, 'Normal', true, true)
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

    ---@param self BasiliskNukeEffectController01
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
    ---@param self BasiliskNukeEffectController01
    CreateEffectInnerPlasma = function(self)
        local num_projectiles = 20
        local horizontal_angle = (2*MathPi) / num_projectiles
        local angleInitial = RandomFloat(0, horizontal_angle)
        local xVec, zVec
        local offsetMultiple = 5.0
        local px, pz

        for i = 0, (num_projectiles -1) do
            xVec = (MathSin(angleInitial + (i*horizontal_angle)))
            zVec = (MathCos(angleInitial + (i*horizontal_angle)))
            px = (offsetMultiple*xVec)
            pz = (offsetMultiple*zVec)

            local proj = self:CreateProjectile(BasiliskNukeEffect05, px, -10, pz, xVec, 0, zVec)
            proj:SetLifetime(4.0)
            proj:SetVelocity(8.0)
            proj:SetAcceleration(-0.35)
        end
    end,

    ---@param wait number
    ---@param angle number
    PlumeGenerate = function(wait, angle)
        local num_projectiles = 3
        local horizontal_angle = (2*MathPi) / num_projectiles
        local angleInitial = RandomFloat(0, horizontal_angle)
        local xVec, yVec, zVec
        local px, pz
        local py = -10

        for i = 0, (num_projectiles -1) do
            xVec = MathSin(angleInitial + (i*horizontal_angle) + RandomFloat(-angle, angle))
            yVec = RandomFloat(0.5, 1.7) + 1.2
            zVec = MathSin(angleInitial + (i*horizontal_angle) + RandomFloat(-angle, angle))
            px = RandomFloat(0.5, 1.0) * xVec
            pz = RandomFloat(0.5, 1.0) * zVec

            local proj = self:CreateProjectile(BasiliskNukeEffect04, px, py, pz, xVec, yVec, zVec)
            proj:SetVelocity(RandomFloat(20, 30))
            proj:SetBallisticAcceleration(-9.8)
        end

        WaitSeconds(wait)
    end,

    ---@param self BasiliskNukeEffectController01
    EffectThread = function(self)
        local army = self.Army
        local position = self:GetPosition()

        -- Knockdown force rings
        DamageRing(self, position, 0.1, 45, 1, 'Force', true, true)
        WaitSeconds(0.8)
        DamageRing(self, position, 0.1, 45, 1, 'Force', true, true)

        -- Create initial fireball dome effect
        local FireballDomeYOffset = -20
        self:CreateProjectile('/mods/BlackOpsFAF-Unleashed/effects/entities/BasiliskNukeEffect01/BasiliskNukeEffect01_proj.bp',0,FireballDomeYOffset,0,0,0,1)
        WaitSeconds(1.1)

        -- These include waits
        PlumeGenerate(0.1, 0.1)
        PlumeGenerate(1.5, 0.3)
        PlumeGenerate(0.2, 0.5)
        PlumeGenerate(0.5, 0.7)
        PlumeGenerate(0.5, 0.2)

        CreateDecal(position, RandomFloat(0,2*math.pi), 'nuke_scorch_001_albedo', '', 'Albedo', 60, 60, 500, 0, army)

    end,
}

TypeClass = BasiliskNukeEffectController01
