
local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit
local BaseTransport = import('/lua/defaultunits.lua').BaseTransport
local AirDroneCarrier = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsunits.lua').AirDroneCarrier
local Weapons2 = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsweapons.lua')
local HawkGaussCannonWeapon = Weapons2.HawkGaussCannonWeapon
local GoliathTMDGun = Weapons2.GoliathTMDGun
local DeathNukeWeapon = import('/lua/sim/defaultweapons.lua').DeathNukeWeapon
local GoliathRocket = Weapons2.GoliathRocket
local TDFGoliathShoulderBeam = Weapons2.TDFGoliathShoulderBeam
local utilities = import('/lua/utilities.lua')
local Util = import('/lua/utilities.lua')
local RandomFloat = utilities.GetRandomFloat
local EffectTemplate = import('/lua/EffectTemplates.lua')
local explosion = import('/lua/defaultexplosions.lua')
local CreateDeathExplosion = explosion.CreateDefaultHitExplosionAtBone

local TrashBagAdd = TrashBag.Add

---@class BEL0402 : BaseTransport, TWalkingLandUnit, AirDroneCarrier
BEL0402 = Class(BaseTransport, TWalkingLandUnit, AirDroneCarrier) {
    FlamerEffects = '/mods/BlackOpsFAF-Unleashed/effects/emitters/ex_flamer_torch_01.bp',

    Weapons = {
        MissileWeapon = Class(GoliathRocket) {},
        HeavyGuassCannon = Class(HawkGaussCannonWeapon) {},
        TMDTurret = Class(GoliathTMDGun) {},
        Laser = Class(TDFGoliathShoulderBeam) {},
        GoliathDeathNuke = Class(DeathNukeWeapon) {},
    },

    ---@param self BEL0402
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        local bp = self.Blueprint
        local trash = self.Trash
        local army = self.Army

        -- First, animate to stand up, and wait for it
        if not self.AnimationManipulator then
            self.AnimationManipulator = CreateAnimator(self)
            TrashBagAdd(self ,self.AnimationManipulator)
        end

        self:SetUnSelectable(true)
        self.AnimationManipulator:PlayAnim(bp.Display.AnimationActivate, false):SetRate(1)
        TrashBagAdd(trash, self:ForkThread(function()
            WaitSeconds(self.AnimationManipulator:GetAnimationDuration())
            self:SetUnSelectable(false)
            self.AnimationManipulator:Destroy()
        end))

        -- Create drones
        AirDroneCarrier.InitDrones(self)

        -- Enable intel? Give it jamming :)
        --self:SetScriptBit('RULEUTC_IntelToggle', false)

        -- Turn on flamethrower pilot lights
        self.FlamerEffectsBag = {}
        table.insert(self.FlamerEffectsBag, CreateAttachedEmitter(self, 'Right_Pilot_Light', army, self.FlamerEffects):ScaleEmitter(0.0625))
        table.insert(self.FlamerEffectsBag, CreateAttachedEmitter(self, 'Left_Pilot_Light', army, self.FlamerEffects):ScaleEmitter(0.0625))

        TWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
    end,

    -- Places the Goliath's first drone-targetable attacker into a global
    ---@param self BEL0402
    ---@param instigator Unit
    ---@param amount number
    ---@param vector Vector
    ---@param damagetype DamageType
    OnDamage = function(self, instigator, amount, vector, damagetype)
        if not self.Dead and self.DroneTarget == nil and self:IsValidDroneTarget(instigator) then
            AirDroneCarrier.SetAttacker(self, instigator)
        end
        TWalkingLandUnit.OnDamage(self, instigator, amount, vector, damagetype)
    end,

    -- Drone control buttons
    ---@param self BEL0402
    ---@param bit number
    OnScriptBitSet = function(self, bit)
        -- Drone assist toggle, on
        if bit == 1 then
            self.DroneAssist = false
        elseif bit == 3 then
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('Radar')
            self:DisableUnitIntel('RadarStealth')
        -- Drone recall button
        elseif bit == 7 then
            self:RecallDrones()
            -- Pop button back up, as it's not actually a toggle
            self:SetScriptBit('RULEUTC_SpecialToggle', false)
        else
            TWalkingLandUnit.OnScriptBitSet(self, bit)
        end
    end,

    ---@param self BEL0402
    ---@param bit number
    OnScriptBitClear = function(self, bit)
        -- Drone assist toggle, off
        if bit == 1 then
            self.DroneAssist = true
        elseif bit == 3 then
            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Radar')
            self:EnableUnitIntel('RadarStealth')
        -- Recall button reset, do nothing
        elseif bit == 7 then
            return
        else
            TWalkingLandUnit.OnScriptBitClear(self, bit)
        end
    end,

    -- Cleans up threads and drones on death
    ---@param self BEL0402
    ---@param instigator Unit
    ---@param type string
    ---@param overkillRatio number
    OnKilled = function(self, instigator, type, overkillRatio)
        if self:GetFractionComplete() == 1 then
            -- Kill our heartbeat thread
            KillThread(self.HeartBeatThread)
            -- Clean up any in-progress construction
            ChangeState(self, self.DeadState)
            -- Immediately kill existing drones
            self:KillAllDrones()
        end
        TWalkingLandUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    -- Set on unit death, ends production and consumption immediately
    DeadState = State {
        Main = function(self)
            if self:GetFractionComplete() == 1 then
                self:CleanupDroneMaintenance(nil, true)
            end
        end,
    },

    DestructionEffectBones = {
        'Left_Arm_Muzzle',
    },

    ---@param self BEL0402
    ---@param bone Bone
    ---@param army Army
    CreateDamageEffects = function(self, bone, army)
        for _, v in EffectTemplate.DamageFireSmoke01 do
            CreateAttachedEmitter(self, bone, army, v):ScaleEmitter(3.0)
        end
    end,

    ---@param self BEL0402
    ---@param bone Bone
    ---@param Army Army
    CreateExplosionDebris = function(self, bone, Army)
        for _, v in EffectTemplate.ExplosionEffectsSml01 do
            CreateAttachedEmitter(self, bone, Army, v):ScaleEmitter(2.0)
        end
    end,

    ---@param self BEL0402
    CreateDeathExplosionDustRing = function(self)
        local blanketSides = 18
        local blanketAngle = (2*math.pi) / blanketSides
        local blanketVelocity = 2.8

        for i = 0, (blanketSides-1) do
            local blanketX = math.sin(i*blanketAngle)
            local blanketZ = math.cos(i*blanketAngle)

            self:CreateProjectile('/effects/entities/DestructionDust01/DestructionDust01_proj.bp', blanketX, 1.5, blanketZ + 4, blanketX, 0, blanketZ):SetVelocity(blanketVelocity):SetAcceleration(-0.3)
        end
    end,

    ---@param self BEL0402
    ---@param bones Bone[]
    ---@param yBoneOffset number
    CreateAmmoCookOff = function(self, bones, yBoneOffset)
        -- Fire plume effects
        local basePosition = self:GetPosition()
        local trash = self.Trash
        for _, vBone in bones do
            local position = self:GetPosition(vBone)
            local offset = utilities.GetDifferenceVector(position, basePosition)
            velocity = utilities.GetDirectionVector(position, basePosition)
            velocity.x = velocity.x + RandomFloat(-0.45, 0.45)
            velocity.z = velocity.z + RandomFloat(-0.45, 0.45)
            velocity.y = velocity.y + RandomFloat(0.0, 0.65)

            -- Ammo Cookoff projectiles and damage
            self.DamageData = {
                BallisticArc = 'RULEUBA_LowArc',
                UseGravity = true,
                CollideFriendly = true,
                DamageFriendly = true,
                Damage = 500,
                DamageRadius = 3,
                DoTPulses = 15,
                DoTTime = 2.5,
                DamageType = 'Normal',
                }
            ammocookoff = self:CreateProjectile('/mods/BlackOpsFAF-Unleashed/projectiles/NapalmProjectile01/Napalm01_proj.bp', offset.x, offset.y + yBoneOffset, offset.z, velocity.x, velocity.y, velocity.z)
            ammocookoff:SetVelocity(Random(2,5))
            ammocookoff:SetLifetime(20)
            ammocookoff:PassDamageData(self.DamageData)
            TrashBagAdd(self, ammocookoff)
        end
    end,

    ---@param self BEL0402
    ---@param army Army
    CreateGroundPlumeConvectionEffects = function(self,army)
        for _, v in EffectTemplate.TNukeGroundConvectionEffects01 do
              CreateEmitterAtEntity(self, army, v)
        end

        local sides = 10
        local angle = (2*math.pi) / sides
        local outer_lower_limit = 2
        local outer_upper_limit = 2
        local outer_lower_height = 2
        local outer_upper_height = 3

        sides = 8
        angle = (2*math.pi) / sides
        for i = 0, (sides-1)
        do
            local magnitude = RandomFloat(outer_lower_limit, outer_upper_limit)
            local x = math.sin(i*angle+RandomFloat(-angle/2, angle/4)) * magnitude
            local z = math.cos(i*angle+RandomFloat(-angle/2, angle/4)) * magnitude
            local velocity = RandomFloat(1, 3) * 3
            self:CreateProjectile('/effects/entities/UEFNukeEffect05/UEFNukeEffect05_proj.bp', x, RandomFloat(outer_lower_height, outer_upper_height), z, x, 0, z)
                :SetVelocity(x * velocity, 0, z * velocity)
        end
    end,

    ---@param self BEL0402
    CreateInitialFireballSmokeRing = function(self)
        local sides = 12
        local angle = (2*math.pi) / sides
        local velocity = 5
        local OffsetMod = 8

        for i = 0, (sides-1) do
            local X = math.sin(i*angle)
            local Z = math.cos(i*angle)
            self:CreateProjectile('/effects/entities/UEFNukeShockwave01/UEFNukeShockwave01_proj.bp', X * OffsetMod , 1.5, Z * OffsetMod, X, 0, Z)
                :SetVelocity(velocity):SetAcceleration(-0.5)
        end
    end,

    ---@param self BEL0402 
    CreateOuterRingWaveSmokeRing = function(self)
        local sides = 32
        local angle = (2*math.pi) / sides
        local velocity = 7
        local OffsetMod = 8
        local projectiles = {}

        for i = 0, (sides-1) do
            local X = math.sin(i*angle)
            local Z = math.cos(i*angle)
            local proj =  self:CreateProjectile('/effects/entities/UEFNukeShockwave02/UEFNukeShockwave02_proj.bp', X * OffsetMod , 2.5, Z * OffsetMod, X, 0, Z)
                :SetVelocity(velocity)
            table.insert(projectiles, proj)
        end
        WaitSeconds(3)

        -- Slow projectiles down to normal speed
        for k, v in projectiles do
            v:SetAcceleration(-0.45)
        end
    end,

    ---@param self BEL0402
    CreateFlavorPlumes = function(self)
        local numProjectiles = 8
        local angle = (2*math.pi) / numProjectiles
        local angleInitial = RandomFloat(0, angle)
        local angleVariation = angle * 0.75
        local projectiles = {}

        local xVec = 0
        local yVec = 0
        local zVec = 0
        local velocity = 0

        -- Launch projectiles at semi-random angles away from the sphere, with enough
        -- initial velocity to escape sphere core
        for i = 0, (numProjectiles -1) do
            xVec = math.sin(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))
            yVec = RandomFloat(0.2, 1)
            zVec = math.cos(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))
            velocity = 3.4 + (yVec * RandomFloat(2,5))
            table.insert(projectiles, self:CreateProjectile('/effects/entities/UEFNukeFlavorPlume01/UEFNukeFlavorPlume01_proj.bp', 0, 0, 0, xVec, yVec, zVec):SetVelocity(velocity))
        end

        WaitSeconds(3)

        -- Slow projectiles down to normal speed
        for _, v in projectiles do
            v:SetVelocity(2):SetBallisticAcceleration(-0.15)
        end
    end,

    ---@param self BEL0402
    CreateHeadConvectionSpinners = function(self)
        local sides = 8
        local angle = (2*math.pi) / sides
        local HeightOffset = 0
        local velocity = 1
        local OffsetMod = 10
        local projectiles = {}

        for i = 0, (sides-1) do
            local x = math.sin(i*angle) * OffsetMod
            local z = math.cos(i*angle) * OffsetMod
            local proj = self:CreateProjectile('/mods/BlackOpsFAF-Unleashed/effects/entities/GoliathNukeEffect03/GoliathNukeEffect03_proj.bp', x, HeightOffset, z, x, 0, z)
                :SetVelocity(velocity)
            table.insert(projectiles, proj)
        end

        WaitSeconds(1)
        for i = 0, (sides-1) do
            local x = math.sin(i*angle)
            local z = math.cos(i*angle)
            local proj = projectiles[i+1]
        proj:SetVelocityAlign(false)
        proj:SetOrientation(OrientFromDir(Util.Cross(Vector(x,0,z), Vector(0,1,0))),true)
        proj:SetVelocity(0,3,0)
          proj:SetBallisticAcceleration(-0.05)
        end
    end,

    ---@param self BEL0402
    DeathThread = function(self)
        self:PlayUnitSound('Destroyed')
        local army = self.Army
        local position = self:GetPosition()
        local numExplosions =  math.floor(table.getn(self.DestructionEffectBones) * Random(0.4, 1.0))

        -- Create small explosions effects all over
        local ranBone = utilities.GetRandomInt(1, numExplosions)
        CreateDeathExplosion(self, 'Torso', 6)
        CreateAttachedEmitter(self, 'Torso', army, '/effects/emitters/destruction_explosion_concussion_ring_03_emit.bp'):OffsetEmitter(0, 0, 0)
        self:ShakeCamera(20, 2, 1, 1)
        WaitSeconds(3)
        explosion.CreateDefaultHitExplosionAtBone(self, 'Torso', 5.0)
        WaitSeconds(1)
        explosion.CreateDefaultHitExplosionAtBone(self, 'Missile_Hatch_B', 5.0)
        self:CreateDamageEffects('Missile_Hatch_B', army)
        self:ShakeCamera(20, 2, 1, 1.5)
        WaitSeconds(1)
        CreateDeathExplosion(self, 'Left_Arm_Extra', 1.0)
        WaitSeconds(0.5)
        CreateDeathExplosion(self, 'Left_Arm_Muzzle', 1.0)
        WaitSeconds(0.2)
        CreateDeathExplosion(self, 'Left_Arm_Pitch', 1.0)
        self:CreateDamageEffects('Left_Arm_Pitch', army)
        WaitSeconds(0.2)
        CreateDeathExplosion(self, 'Left_Leg_B', 1.0)
        self:CreateDamageEffects('Left_Leg_B', army)
        WaitSeconds(0.6)
        CreateDeathExplosion(self, 'Right_Arm_Extra', 1.0)
        CreateDeathExplosion(self, 'Left_Arm_Yaw', 1.0)
        WaitSeconds(0.2)
        CreateDeathExplosion(self, 'Right_Leg_B', 1.0)
        WaitSeconds(1)
        CreateDeathExplosion(self, 'Pelvis', 1.0)
        CreateDeathExplosion(self, 'Beam_Barrel', 1.0)
        WaitSeconds(0.2)
        CreateDeathExplosion(self, 'Head', 1.0)
        WaitSeconds(0.5)
        CreateDeathExplosion(self, 'AttachSpecial01', 1.0)
        self:CreateDamageEffects('AttachSpecial01', army)
        WaitSeconds(0.3)
        CreateDeathExplosion(self, 'TMD_Turret', 1.0)
        self:CreateDamageEffects('TMD_Turret', army)
        WaitSeconds(0.3)
        CreateDeathExplosion(self, 'Left_Leg_C', 1.0)
        self:CreateDamageEffects('Left_Leg_C', army)
        WaitSeconds(0.2)
        CreateDeathExplosion(self, 'L_FootFall', 1.0)
        CreateDeathExplosion(self, 'Left_Foot', 1.0)
        WaitSeconds(0.1)
        CreateDeathExplosion(self, 'Right_Foot', 1.0)
        WaitSeconds(0.7)
        CreateDeathExplosion(self, 'Beam_Turret', 2.0)
        self:CreateDamageEffects('Beam_Turret', army)
        self:CreateDamageEffects('Right_Arm_Extra', army)
        WaitSeconds(0.7)
        CreateDeathExplosion(self, 'Torso', 1.0)
        WaitSeconds(0.2)
        CreateDeathExplosion(self, 'Right_Leg_B', 1.0)
        self:CreateDamageEffects('Right_Leg_B', army)
        WaitSeconds(0.4)
        CreateDeathExplosion(self, 'Right_Arm_Pitch', 1.0)
        self:CreateDamageEffects('Right_Arm_Pitch', army)
        WaitSeconds(2)

        local x, y, z = unpack(self:GetPosition())
        z = z + 3
        -- Knockdown force rings
        CreateLightParticle(self, -1, army, 35, 4, 'glow_02', 'ramp_red_02')
        WaitSeconds(0.25)
        CreateLightParticle(self, -1, army, 80, 20, 'glow_03', 'ramp_fire_06')
        self:PlayUnitSound('NukeExplosion')
        local FireballDomeYOffset = -7
        self:CreateProjectile('/mods/BlackOpsFAF-Unleashed/effects/entities/GoliathNukeEffect01/GoliathNukeEffect01_proj.bp',0,FireballDomeYOffset,0,0,0,1)
        local PlumeEffectYOffset = 1
        self:CreateProjectile('/effects/entities/UEFNukeEffect02/UEFNukeEffect02_proj.bp',0,PlumeEffectYOffset,0,0,0,1)
        DamageRing(self, position, 0.1, 18, 1, 'Force', true)
        WaitSeconds(0.8)
        DamageRing(self, position, 0.1, 18, 1, 'Force', true)
        local bp = self:GetBlueprint()
        for i, numWeapons in bp.Weapon do
            if(bp.Weapon[i].Label == 'GoliathDeathNuke') then
                DamageArea(self, self:GetPosition(), bp.Weapon[i].DamageRadius, bp.Weapon[i].Damage, bp.Weapon[i].DamageType, bp.Weapon[i].DamageFriendly)
                break
            end
        end

        for k, v in EffectTemplate.TNukeRings01 do
            CreateEmitterAtEntity(self, army, v)
        end

        self:CreateInitialFireballSmokeRing()
        self:ForkThread(self.CreateOuterRingWaveSmokeRing)
        self:ForkThread(self.CreateHeadConvectionSpinners)
        self:ForkThread(self.CreateFlavorPlumes)

        CreateLightParticle(self, -1, army, 200, 150, 'glow_03', 'ramp_nuke_04')
        WaitSeconds(1)
        WaitSeconds(0.1)
        WaitSeconds(0.1)
        WaitSeconds(0.5)
        WaitSeconds(0.2)
        WaitSeconds(0.5)
        WaitSeconds(0.5)
        self:CreateGroundPlumeConvectionEffects(army)

        local army = self:GetArmy()
        CreateDecal(self:GetPosition(), RandomFloat(0,2*math.pi), 'nuke_scorch_003_albedo', '', 'Albedo', 40, 40, 500, 0, army)
        self:CreateWreckage(0.1)
        self.Trash:Destroy()
        self:Destroy()
    end,

    -- Handles drone docking
    ---@param self BEL0402
    ---@param bone Bone
    ---@param unit Unit
    OnTransportAttach = function(self, bone, unit)
        BaseTransport.OnTransportAttach(self, bone, unit)
        TWalkingLandUnit.OnTransportAttach(self, bone, unit)

        self.DroneData[unit.Name].Docked = bone
        unit:SetDoNotTarget(true)
    end,

    -- Handles drone undocking, also called when docked drones die
    ---@param self BEL0402
    ---@param bone Bone
    ---@param unit Unit
    OnTransportDetach = function(self, bone, unit)
        BaseTransport.OnTransportDetach(self, bone, unit)
        TWalkingLandUnit.OnTransportDetach(self, bone, unit)

        self.DroneData[unit.Name].Docked = false
        unit:SetDoNotTarget(false)
        if unit.Name == self.BuildingDrone then
            self:CleanupDroneMaintenance(self.BuildingDrone)
        end
    end,

    ---@param self BEL0402
    ---@param attached Unit
    OnAttachedKilled = function(self, attached)
        BaseTransport.OnAttachedKilled(self, attached)
        TWalkingLandUnit.OnAttachedKilled(self, attached)
    end,

    ---@param self BEL0402
    OnStartTransportLoading = function(self)
        BaseTransport.OnStartTransportLoading(self)
        TWalkingLandUnit.OnStartTransportLoading(self)
    end,

    ---@param self BEL0402
    OnStopTransportLoading = function(self)
        BaseTransport.OnStopTransportLoading(self)
        TWalkingLandUnit.OnStopTransportLoading(self)
    end,

    ---@param self BEL0402
    DestroyedOnTransport = function(self)
        BaseTransport.DestroyedOnTransport(self)
        TWalkingLandUnit.DestroyedOnTransport(self)
    end,
}

TypeClass = BEL0402
