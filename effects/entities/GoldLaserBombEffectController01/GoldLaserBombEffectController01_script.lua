----------------------------------------------------------------------------------------------------------------
-- File     :  \data\effects\Entities\GoldLaserBombEffectController01\GoldLaserBombEffectController01_script.lua
-- Author(s):  Greg Kohne
-- Summary  :  Ohwalli Bomb effect controller script, non-damaging
-- Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.
----------------------------------------------------------------------------------------------------------------

local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local BlackOpsEffectTemplate = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsEffectTemplates.lua')
local GoldLaserBombEffect01 = '/mods/BlackOpsFAF-Unleashed/effects/Entities/GoldLaserBombEffect01/GoldLaserBombEffect01_proj.bp'

-- upvale for performance
local TrashBagAdd = TrashBag.Add
local MathPi = math.pi
local MathSin = math.sin
local MathCos = math.cos

---@class GoldLaserBombEffectController01 : NullShell
GoldLaserBombEffectController01 = Class(NullShell) {
    NukeInnerRingDamage = 2000,
    NukeInnerRingRadius = 2,
    NukeInnerRingTicks = 1,
    NukeInnerRingTotalTime = 0,
    NukeOuterRingDamage = 800,
    NukeOuterRingRadius = 5,
    NukeOuterRingTicks = 1,
    NukeOuterRingTotalTime = 0,

    ---@param self GoldLaserBombEffectController01
    OnCreate = function(self)
        NullShell.OnCreate(self)
        local army = self.Army
        local trash = self.Trash

        TrashBagAdd(trash, ForkThread(self.MainBlast, self, army))
        TrashBagAdd(trash, ForkThread(self.InnerRingDamage, self))
        TrashBagAdd(trash, ForkThread(self.OuterRingDamage, self))
    end,

    ---@param self GoldLaserBombEffectController01
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
    end,

    ---@param self GoldLaserBombEffectController01
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

    ---@param self GoldLaserBombEffectController01
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

    ---@param self GoldLaserBombEffectController01
    ---@param army Army
    MainBlast = function(self, army)
        -- Create a light for this thing's flash.
        CreateLightParticle(self, -1, army, 40, 7, 'flare_lens_add_03', 'ramp_white_07')

        -- Create our decals
        CreateDecal(self:GetPosition(), RandomFloat(0.0,6.28), 'Scorch_012_albedo', '', 'Albedo', 30, 30, 500, 0, army)

        -- Create explosion effects
        for _, v in BlackOpsEffectTemplate.GoldLaserBombDetonate01 do
            CreateEmitterAtEntity(self,army,v):ScaleEmitter(0.2)
        end

        self:CreatePlumes()
        self:ShakeCamera(7, 2.5, 0, 0.7)

        WaitSeconds(0.3)
    end,

    ---@param self GoldLaserBombEffectController01
    CreatePlumes = function(self)
        -- Create fireball plumes to accentuate the explosive detonation
        local num_projectiles = 12
        local horizontal_angle = (2*MathPi) / num_projectiles
        local angleInitial = RandomFloat(0, horizontal_angle)
        local xVec, yVec, zVec
        local angleVariation = 0.5
        local px, py, pz

        for i = 0, (num_projectiles -1) do
            xVec = MathSin(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation))
            yVec = RandomFloat(0.7, 2.8) + 2.0
            zVec = MathCos(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation))
            px = RandomFloat(0.5, 1.0) * xVec
            py = RandomFloat(0.5, 1.0) * yVec
            pz = RandomFloat(0.5, 1.0) * zVec

            local proj = self:CreateProjectile(GoldLaserBombEffect01, px, py, pz, xVec, yVec, zVec)
            proj:SetVelocity(RandomFloat(2, 10))
            proj:SetBallisticAcceleration(-4.8)
        end
    end,
}

TypeClass = GoldLaserBombEffectController01
