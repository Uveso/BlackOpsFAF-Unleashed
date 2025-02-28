------------------------------------------------------------------------------
-- File     :  /projectiles/CIFEMPFluxWarhead02/CIFEMPFluxWarhead02_script.lua
-- Author(s):  Gordon Duclos
-- Summary  :  EMP Flux Warhead Impact effects projectile
-- Copyright � 2005,2006 Gas Powered Games, Inc.  All rights reserved.
------------------------------------------------------------------------------
local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local BlackOpsEffectTemplate = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsEffectTemplates.lua')

---@class ArtemisWarhead02 : NullShell
ArtemisWarhead02 = Class(NullShell) {
    NukeInnerRingDamage = 0,
    NukeInnerRingRadius = 0,
    NukeInnerRingTicks = 0,
    NukeInnerRingTotalTime = 0,
    NukeOuterRingDamage = 0,
    NukeOuterRingRadius = 0,
    NukeOuterRingTicks = 0,
    NukeOuterRingTotalTime = 0,

    NukeMeshScale = 8.5725,
    PlumeVelocityScale = 0.1,

    NormalEffects = {'/mods/BlackOpsFAF-Unleashed/effects/emitters/artemis_warhead_01_emit.bp',},
    ArtemisCloudFlareEffects = BlackOpsEffectTemplate.ArtemisCloudFlareEffects01,

    ---@param self ArtemisWarhead02
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

    ---@param self ArtemisWarhead02
    CreateNuclearExplosion = function(self)
        local army = self.Army
        CreateLightParticle(self, -1, army, 75, 200, 'beam_white_01', 'ramp_yellow_05')

        self:ForkThread(self.ShakeAndBurnMe, army)
        self:ForkThread(self.InnerCloudFlares, army)
        self:ForkThread(self.DistortionField)

        for k, v in self.NormalEffects do
            CreateEmitterAtEntity(self, army, v)
        end

        self:ForkThread(self.InnerRingDamage)
        self:ForkThread(self.OuterRingDamage)
        self:ForkThread(self.ForceThread)
    end,

    ---@param self ArtemisWarhead02
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

    ---@param self ArtemisWarhead02
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

    -- Knocks down trees
    ---@param self ArtemisWarhead02
    ForceThread = function(self)
        local pos = self:GetPosition()
        pos[2] = GetSurfaceHeight(pos[1], pos[3]) + 1
        DamageArea(self, pos, 5, 1, 'Force', true)
        WaitSeconds(0.5)
        DamageRing(self, pos, 4, 15, 1, 'Force', true)
        WaitSeconds(0.5)
        DamageArea(self, pos, 15, 1, 'Force', true)
    end,

    ---@param self ArtemisWarhead02
    ---@param army Army
    ShakeAndBurnMe = function(self, army)
        self:ShakeCamera(75, 3, 0, 10)
        WaitSeconds(0.5)
        local orientation = RandomFloat(0,2*math.pi)
        CreateDecal(self:GetPosition(), orientation, 'Crater01_albedo', '', 'Albedo', 50, 50, 1200, 0, army)
        CreateDecal(self:GetPosition(), orientation, 'Crater01_normals', '', 'Normals', 50, 50, 1200, 0, army)
        self:ShakeCamera(105, 10, 0, 2)
        WaitSeconds(2)
        self:ShakeCamera(75, 1, 0, 15)
    end,

    ---@param self ArtemisWarhead02
    ---@param army Army
    InnerCloudFlares = function(self, army)
        local numFlares = 100
        local angle = (2*math.pi) / numFlares
        local angleInitial = 0.0
        local angleVariation = (2*math.pi)

        local emit, x, y, z = nil
        local DirectionMul = 0.06
        local OffsetMul = 10

        for i = 0, (numFlares - 1) do
            x = math.sin(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))
            y = 0.5
            z = math.cos(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))

            for k, v in self.ArtemisCloudFlareEffects do
                emit = CreateEmitterAtEntity(self, army, v)
                emit:OffsetEmitter(x * OffsetMul, y * OffsetMul, z * OffsetMul)
                emit:SetEmitterCurveParam('XDIR_CURVE', x * DirectionMul, 0.01)
                emit:SetEmitterCurveParam('YDIR_CURVE', y * DirectionMul, 0.01)
                emit:SetEmitterCurveParam('ZDIR_CURVE', z * DirectionMul, 0.01)
            end

            WaitSeconds(RandomFloat(0.05, 0.15))
        end

        CreateLightParticle(self, -1, army, 13, 3, 'beam_white_01', 'ramp_quantum_warhead_flash_01')
        CreateEmitterAtEntity(self, army, '/mods/BlackOpsFAF-Unleashed/effects/emitters/artemis_warhead_ring_01_emit.bp')
    end,

    ---@param self ArtemisWarhead02
    DistortionField = function(self)
        local proj = self:CreateProjectile('/mods/BlackOpsFAF-Unleashed/effects/ArtemisWarhead/ArtemisWarheadEffect01_proj.bp')
        local scale = proj.Blueprint.Display.UniformScale

        proj:SetScaleVelocity(0.123 * scale,0.123 * scale,0.123 * scale)
        WaitSeconds(17.0)
        proj:SetScaleVelocity(0.01 * scale,0.01 * scale,0.01 * scale)
    end,
}
TypeClass = ArtemisWarhead02
