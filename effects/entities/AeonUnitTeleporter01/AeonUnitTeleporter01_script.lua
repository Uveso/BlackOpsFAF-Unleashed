-------------------------------------------------------------------------
-- File     :  /effects/entities/UnitTeleport01/UnitTeleport01_script.lua
-- Author(s):  Gordon Duclos
-- Summary  :  Unit Teleport effect entity
-- Copyright � 2006 Gas Powered Games, Inc.  All rights reserved.
-------------------------------------------------------------------------
local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local EffectTemplate = import('/lua/EffectTemplates.lua')

-- Upvalue for performance
local TrashBagAdd = TrashBag.Add
local MathPi = math.pi
local MathSin = math.sin
local MathCos = math.cos

---@class AeonUnitTeleporterEffect01 : NullShell
AeonUnitTeleporterEffect01 = Class(NullShell) {

    ---@param self AeonUnitTeleporterEffect01
    OnCreate = function(self)
        NullShell.OnCreate(self)

        local trash = self.Trash

        TrashBagAdd(trash, ForkThread(self.CreateEnergySpinner, self))
    end,

    ---@param self AeonUnitTeleporterEffect01
    TeleportEffectThread = function(self)
        local army = self.Army
        local pos = self:GetPosition()

        pos[2] = GetSurfaceHeight(pos[1], pos[3]) - 2

        self:CreateQuantumEnergy(army)

        -- Smoke ring, explosion effects
        CreateLightParticleIntel(self, -1, army, 35, 10, 'glow_02', 'ramp_blue_13')
        DamageRing(self, pos, 0.1, 5, 50, 'Force', false, false)

        for _, v in EffectTemplate.CommanderTeleport01 do
            CreateEmitterOnEntity(self, army, v):ScaleEmitter(0.5)
        end

        WaitSeconds(0.1)
        DamageRing(self, pos, .1, 5, 50, 'Force', false, false)

        -- Knockdown force rings
        WaitSeconds(0.39)
        DamageRing(self, pos, 5, 10, 1, 'Force', false, false)
        WaitSeconds(0.1)
        DamageRing(self, pos, 5, 10, 1, 'Force', false, false)
        WaitSeconds(0.5)

        -- Scorch decal and light some trees on fire
        WaitSeconds(0.3)
        DamageRing(self, pos, 10, 14, 1, 'Fire', false, false)
    end,

    ---@param self AeonUnitTeleporterEffect01
    CreateEnergySpinner = function(self)
        self:CreateProjectile('/effects/entities/TeleportSpinner01/TeleportSpinner01_proj.bp', 0, 0, 0, nil, nil, nil):SetCollision(false)
        self:CreateProjectile('/effects/entities/TeleportSpinner02/TeleportSpinner02_proj.bp', 0, 0, 0, nil, nil, nil):SetCollision(false)
        self:CreateProjectile('/effects/entities/TeleportSpinner03/TeleportSpinner03_proj.bp', 0, 0, 0, nil, nil, nil):SetCollision(false)
    end,

    ---@param self AeonUnitTeleporterEffect01
    ---@param army Army
    CreateQuantumEnergy = function(self, army)
        for _, v in EffectTemplate.CommanderQuantumGateInEnergy do
            CreateEmitterOnEntity(self, army, v):ScaleEmitter(0.5)
        end
    end,

    ---@param self AeonUnitTeleporterEffect01
    ---@param army Army
    CreateFlares = function(self, army)
        local numFlares = 45
        local angle = (2*MathPi) / numFlares
        local angleInitial = 0.0
        local angleVariation = (2*MathPi)

        local emit, x, y, z = nil,nil,nil,nil
        local DirectionMul = 0.02
        local OffsetMul = 1

        for i = 0, (numFlares - 1) do
            x = MathSin(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))
            y = 0.5
            z = math.cos(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))

            for _, v in EffectTemplate.CloudFlareEffects01 do
                emit = CreateEmitterAtEntity(self, army, v)
                emit:OffsetEmitter(x * OffsetMul, y * OffsetMul, z * OffsetMul)
                emit:SetEmitterCurveParam('XDIR_CURVE', x * DirectionMul, 0.01)
                emit:SetEmitterCurveParam('YDIR_CURVE', y * DirectionMul, 0.01)
                emit:SetEmitterCurveParam('ZDIR_CURVE', z * DirectionMul, 0.01)
                emit:ScaleEmitter(0.25)
            end

            WaitSeconds(RandomFloat(0.1, 0.15))
        end
    end,

    ---@param self AeonUnitTeleporterEffect01
    CreateSmokeRing = function(self)
        local blanketSides = 36
        local blanketAngle = (2*MathPi) / blanketSides
        local blanketVelocity = 8
        local projectileList = {}

        for i = 0, (blanketSides-1) do
            local blanketX = MathSin(i*blanketAngle)
            local blanketZ = MathCos(i*blanketAngle)
            local proj = self:CreateProjectile('/effects/Nuke/Shockwave01_proj.bp', blanketX * 6, 0.35, blanketZ * 6, blanketX, 0, blanketZ)
                :SetVelocity(blanketVelocity):SetAcceleration(-3)
            table.insert(projectileList, proj)
        end

        WaitSeconds(2.5)

        for _, v in projectileList do
            v:SetAcceleration(0)
        end
    end,
}

TypeClass = AeonUnitTeleporterEffect01
