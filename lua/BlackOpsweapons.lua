-----------------------------------------------------------------
-- File     :  /cdimage/lua/BlackOpsWeapons.lua
-- Author(s):  Lt_hawkeye
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------
local WeaponFile = import('/lua/sim/defaultweapons.lua')
local CollisionBeams = import('/lua/defaultcollisionbeams.lua')
local CollisionBeamFile = import('/lua/defaultcollisionbeams.lua')
local BlackOpsCollisionBeamFile = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsDefaultCollisionBeams.lua')
local HawkTractorClawCollisionBeam = BlackOpsCollisionBeamFile.HawkTractorClawCollisionBeam
local JuggLaserCollisionBeam = BlackOpsCollisionBeamFile.JuggLaserCollisionBeam
local KamikazeWeapon = WeaponFile.KamikazeWeapon
local BareBonesWeapon = WeaponFile.BareBonesWeapon
local DefaultProjectileWeapon = WeaponFile.DefaultProjectileWeapon
local DefaultBeamWeapon = WeaponFile.DefaultBeamWeapon
local EffectTemplate = import('/lua/EffectTemplates.lua')
local BlackOpsEffectTemplate = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsEffectTemplates.lua')

---@class HawkNapalmWeapon : DefaultProjectileWeapon
HawkNapalmWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.TGaussCannonFlash,
}

---@class HawkNapalmWeapon02 : DefaultProjectileWeapon
RebelArtilleryProtonWeapon = Class(DefaultProjectileWeapon) {}

---@class MiniQuantumBeamGenerator : DefaultBeamWeapon
MiniQuantumBeamGenerator = Class(DefaultBeamWeapon) {
    BeamType = BlackOpsCollisionBeamFile.MiniQuantumBeamGeneratorCollisionBeam,

    FxUpackingChargeEffects = {},
    FxUpackingChargeEffectScale = 0.2,

    ---@param self MiniQuantumBeamGenerator
    PlayFxWeaponUnpackSequence = function(self)
        local army = self.unit.Army
        local bp = self.Blueprint
        for _, v in self.FxUpackingChargeEffects do
            for _, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale):ScaleEmitter(0.2)
            end
        end
        DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
    end,
}

---@class SuperQuantumBeamGenerator : DefaultBeamWeapon
SuperQuantumBeamGenerator = Class(DefaultBeamWeapon) {
    BeamType = BlackOpsCollisionBeamFile.SuperQuantumBeamGeneratorCollisionBeam,

    FxUpackingChargeEffects = {},
    FxUpackingChargeEffectScale = 1,

    ---@param self SuperQuantumBeamGenerator
    PlayFxWeaponUnpackSequence = function(self)
        local army = self.unit.Army
        local bp = self.Blueprint
        for _, v in self.FxUpackingChargeEffects do
            for _, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale):ScaleEmitter(1)
            end
        end
        DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
    end,
}

---@class MiniPhasonLaser : DefaultBeamWeapon
MiniPhasonLaser = Class(DefaultBeamWeapon) {
    BeamType = BlackOpsCollisionBeamFile.MiniPhasonLaserCollisionBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 0.002,

    PlayFxWeaponUnpackSequence = function(self)
        if not self.ContBeamOn then
            local army = self.unit:GetArmy()
            local bp = self.Blueprint
            for k, v in self.FxUpackingChargeEffects do
                for ek, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                    CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale):ScaleEmitter(0.002)
                end
            end
            DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
        end
    end,
}

-- SPIDER BOT WEAPON!
---@class MiniHeavyMicrowaveLaserGenerator : DefaultBeamWeapon
MiniHeavyMicrowaveLaserGenerator = Class(DefaultBeamWeapon) {
    BeamType = BlackOpsCollisionBeamFile.MiniMicrowaveLaserCollisionBeam01,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 1,

    IdleState = State(DefaultBeamWeapon.IdleState) {
        Main = function(self)
            if self.RotatorManip then
                self.RotatorManip:SetSpeed(0)
            end
            if self.SliderManip then
                self.SliderManip:SetGoal(0,0,0)
                self.SliderManip:SetSpeed(2)
            end
            DefaultBeamWeapon.IdleState.Main(self)
        end,
    },

    ---@param self MiniHeavyMicrowaveLaserGenerator
    ---@param muzzle string
    CreateProjectileAtMuzzle = function(self, muzzle)
        if not self.SliderManip then
            self.SliderManip = CreateSlider(self.unit, 'Center_Turret_Barrel')
            self.unit.Trash:Add(self.SliderManip)
        end
        if not self.RotatorManip then
            self.RotatorManip = CreateRotator(self.unit, 'Center_Turret_Barrel', 'z')
            self.unit.Trash:Add(self.RotatorManip)
        end
        self.RotatorManip:SetSpeed(180)
        self.SliderManip:SetPrecedence(11)
        self.SliderManip:SetGoal(0, 0, -1)
        self.SliderManip:SetSpeed(-1)
        return DefaultBeamWeapon.CreateProjectileAtMuzzle(self, muzzle)
    end,

    ---@param self MiniHeavyMicrowaveLaserGenerator
    PlayFxWeaponUnpackSequence = function(self)
        if not self.ContBeamOn then
            local army = self.unit.Army
            local bp = self.Blueprint
            for _, v in self.FxUpackingChargeEffects do
                for _, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                    CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale):ScaleEmitter(0.2)
                end
            end
            DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
        end
    end,
}

---@class HawkTractorClaw : DefaultBeamWeapon
HawkTractorClaw = Class(DefaultBeamWeapon) {
    BeamType = HawkTractorClawCollisionBeam,
    FxMuzzleFlash = {},

    ---@param self HawkTractorClaw
    ---@param muzzle string
    PlayFxBeamStart = function(self, muzzle)
        local target = self:GetCurrentTarget()
        if not target or
            EntityCategoryContains(categories.STRUCTURE, target) or
            EntityCategoryContains(categories.COMMAND, target) or
            EntityCategoryContains(categories.EXPERIMENTAL, target) or
            EntityCategoryContains(categories.NAVAL, target) or
            EntityCategoryContains(categories.SUBCOMMANDER, target) or
           EntityCategoryContains(categories.TECH3, target) or
            not EntityCategoryContains(categories.ALLUNITS, target) then
            return
        end
        DefaultBeamWeapon.PlayFxBeamStart(self, muzzle)

        self.TT1 = self:ForkThread(self.TractorThread, target)
        self:ForkThread(self.TractorWatchThread, target)
    end,

    ---@param self HawkTractorClaw
    OnLostTarget = function(self)
        self:AimManipulatorSetEnabled(true)
        DefaultBeamWeapon.OnLostTarget(self)
    end,

    ---@param self HawkTractorClaw
    ---@param target Entity
    TractorThread = function(self, target)
        self.unit.Trash:Add(target)
        local beam = self.Beams[1].Beam
        if not beam then return end


        local muzzle = self.Blueprint.MuzzleSpecial
        if not muzzle then return end


        local pos0 = beam:GetPosition(0)
        local pos1 = beam:GetPosition(1)

        local dist = VDist3(pos0, pos1)

        self.Slider = CreateSlider(self.unit, muzzle, 0, 0, dist, -1, true)

        WaitFor(self.Slider)

        target:AttachBoneTo(-1, self.unit, muzzle)

        self.AimControl:SetResetPoseTime(10)
        target:SetDoNotTarget(true)

        self.Slider:SetSpeed(15)
        self.Slider:SetGoal(0,0,0)

        WaitFor(self.Slider)

        if not target.Dead then
            target:Kill()
        end
        self.AimControl:SetResetPoseTime(2)
    end,

    ---@param self HawkTractorClaw
    ---@param target Entity
    TractorWatchThread = function(self, target)
        while not target.Dead do
            WaitTicks(1)
        end
        KillThread(self.TT1)
        self.TT1 = nil
        if self.Slider then
            self.Slider:Destroy()
            self.Slider = nil
        end
        self.unit:DetachAll(self.Blueprint.MuzzleSpecial or 0)
        self:ResetTarget()
        self.AimControl:SetResetPoseTime(2)
    end,
}

-- SeaDragon Battleship WEAPON!
---@class MartyrHeavyMicrowaveLaserGenerator : DefaultBeamWeapon
MartyrHeavyMicrowaveLaserGenerator = Class(DefaultBeamWeapon) {
    BeamType = BlackOpsCollisionBeamFile.MartyrMicrowaveLaserCollisionBeam01,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 1,
}

-- ShadowCat WEAPON!
---@class RailLaserGenerator : DefaultBeamWeapon
RailLaserGenerator = Class(DefaultBeamWeapon) {
    BeamType = BlackOpsCollisionBeamFile.RailLaserCollisionBeam01,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 1,
}

--UEF heavy tank railgun and laser
---@class RailGunWeapon01 : DefaultProjectileWeapon
RailGunWeapon01 = Class(DefaultProjectileWeapon) {
    FxChargeMuzzleFlash = {
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/x_cannon_charge_test_01_emit.bp',
    },
    FxMuzzleFlash = {
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/xcannon_cannon_muzzle_01_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/x_cannon_fire_test_01_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/jugg_rail_cannon_muzzle_07_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/jugg_rail_cannon_muzzle_08_emit.bp',
    },
    FxMuzzleFlashScale = 0.25,
    FxChargeMuzzleFlashScale = 0.25,
}

---@class RailGunWeapon02 : DefaultProjectileWeapon
RailGunWeapon02 = Class(DefaultProjectileWeapon) {
    FxChargeMuzzleFlash = {
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/x_cannon_charge_test_01_emit.bp',
    },
    FxMuzzleFlash = {
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/xcannon_cannon_muzzle_01_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/x_cannon_fire_test_01_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/jugg_rail_cannon_muzzle_07_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/jugg_rail_cannon_muzzle_08_emit.bp',
    },
    FxMuzzleFlashScale = 0.75,
    FxChargeMuzzleFlashScale = 0.75,
}

---@class JuggLaserweapon : DefaultBeamWeapon
JuggLaserweapon = Class(DefaultBeamWeapon) {
    BeamType = JuggLaserCollisionBeam,

    FxUpackingChargeEffects = {},
    FxUpackingChargeEffectScale = 0.2,

    PlayFxWeaponUnpackSequence = function(self)
        local army = self.unit:GetArmy()
        local bp = self.Blueprint
        for k, v in self.FxUpackingChargeEffects do
            for ek, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale):ScaleEmitter(0.2)
            end
        end
        DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
    end,
}

-- SeaDragon Weapon
---@class XCannonWeapon01 : DefaultProjectileWeapon
XCannonWeapon01 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlashScale = 1.2,
    FxChargeMuzzleFlashScale = 5,
}

-- Cybran Hailfire
---@class HailfireLauncherWeapon : DefaultProjectileWeapon
HailfireLauncherWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = BlackOpsEffectTemplate.HailfireLauncherExhaust,
}

---@class ShadowCannonWeapon01 : DefaultProjectileWeapon
ShadowCannonWeapon01 = Class(DefaultProjectileWeapon) {
    FxChargeMuzzleFlash = {
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadow_muzzle_charge_01_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadow_muzzle_charge_02_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadow_muzzle_charge_05_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadow_muzzle_charge_04_emit.bp',
    },

    FxMuzzleFlash = {
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadow_cannon_muzzle_01_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadow_cannon_muzzle_02_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadow_cannon_muzzle_05_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadow_cannon_muzzle_06_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadow_cannon_muzzle_07_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadow_cannon_muzzle_08_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadow_hit_10_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadow_muzzle_flash_01_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadow_muzzle_flash_02_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadow_muzzle_flash_03_emit.bp',
    },

    FxMuzzleFlashScale = 0.5,
    FxChargeMuzzleFlashScale = 1,
}

---@class BassieCannonWeapon01 : DefaultProjectileWeapon
BassieCannonWeapon01 = Class(DefaultProjectileWeapon) {
    FxChargeMuzzleFlash = {
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadow_muzzle_charge_01_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadow_muzzle_charge_02_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadow_muzzle_charge_05_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/shadow_muzzle_charge_04_emit.bp',
    },

    FxMuzzleFlash = {
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/bassie_cannon_muzzle_01_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/bassie_cannon_muzzle_02_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/bassie_cannon_muzzle_05_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/bassie_cannon_muzzle_06_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/bassie_cannon_muzzle_07_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/bassie_cannon_muzzle_08_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/bassie_hit_10_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/bassie_muzzle_flash_01_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/bassie_muzzle_flash_02_emit.bp',
        '/mods/BlackOpsFAF-Unleashed/effects/emitters/bassie_muzzle_flash_03_emit.bp',
    },
    FxMuzzleFlashScale = 0.5,
    FxChargeMuzzleFlashScale = 1,
}

-- T3 PD stun weapon Cybran
---@class StunZapperWeapon : DefaultBeamWeapon
StunZapperWeapon = Class(DefaultBeamWeapon) {
    BeamType = BlackOpsCollisionBeamFile.EMCHPRFDisruptorBeam,
    FxMuzzleFlash = {'/effects/emitters/cannon_muzzle_flash_01_emit.bp',},
    FxMuzzleFlashScale = 2,
}

---@class ZCannonWeapon : DefaultProjectileWeapon
ZCannonWeapon = Class(DefaultProjectileWeapon) {
    FxChargeMuzzleFlash = BlackOpsEffectTemplate.ZCannonChargeMuzzleFlash,
    FxMuzzleFlash = BlackOpsEffectTemplate.ZCannonMuzzleFlash,
    FxMuzzleFlashScale = 2.5,
    Version = 1,

    PlayFxRackSalvoReloadSequence = function(self)
        for i = 1, 40 do
        local fxname
            if i < 10 then
                fxname = 'AMC' .. self.Cannon .. 'Steam0' .. i
            else
                fxname = 'AMC' .. self.Cannon .. 'Steam' .. i
            end
            for k, v in self.unit.SteamEffects do
                table.insert(self.unit.SteamEffectsBag, CreateAttachedEmitter(self.unit, fxname, self.unit:GetArmy(), v))
            end
        end
        ZCannonWeapon.PlayFxRackSalvoChargeSequence(self)
    end,
}

---@class YCannonWeapon : DefaultProjectileWeapon
YCannonWeapon = Class(DefaultProjectileWeapon) {
    FxChargeMuzzleFlash = BlackOpsEffectTemplate.YCannonMuzzleChargeFlash,
    FxMuzzleFlash = BlackOpsEffectTemplate.YCannonMuzzleFlash,
    FxMuzzleFlashScale = 2,
}

---@class ScorpDisintegratorWeapon : DefaultProjectileWeapon
ScorpDisintegratorWeapon = Class(DefaultProjectileWeapon) {
    FxChargeMuzzleFlash = {},
    FxMuzzleFlash = {
        '/effects/emitters/disintegratorhvy_muzzle_flash_01_emit.bp',
        '/effects/emitters/disintegratorhvy_muzzle_flash_02_emit.bp',
        '/effects/emitters/disintegratorhvy_muzzle_flash_03_emit.bp',
        '/effects/emitters/disintegratorhvy_muzzle_flash_04_emit.bp',
        '/effects/emitters/disintegratorhvy_muzzle_flash_05_emit.bp',
    },
    FxMuzzleFlashScale = 0.2,
}

---@class HawkMissileTacticalSerpentineWeapon : DefaultProjectileWeapon
HawkMissileTacticalSerpentineWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {'/effects/emitters/aeon_missile_launch_02_emit.bp',},
}

---@class LambdaWeapon : DefaultProjectileWeapon
LambdaWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SDFExperimentalPhasonProjMuzzleFlash,
    FxChargeMuzzleFlash = EffectTemplate.SDFExperimentalPhasonProjChargeMuzzleFlash,
}

---@class ArtemisWeapon : DefaultProjectileWeapon
ArtemisWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = BlackOpsEffectTemplate.ArtemisMuzzleFlash,
    FxChargeMuzzleFlash = BlackOpsEffectTemplate.ArtemisMuzzleChargeFlash,
    FxMuzzleFlashScale = 2,
    FxChargeMuzzleFlashScale = 2,
}

---@class TDFGoliathShoulderBeam : DefaultBeamWeapon
TDFGoliathShoulderBeam = Class(DefaultBeamWeapon) {
    BeamType = BlackOpsCollisionBeamFile.TDFGoliathCollisionBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = {},
    FxUpackingChargeEffectScale = 1,

    PlayFxWeaponUnpackSequence = function(self)
        if not self.ContBeamOn then
            local army = self.unit:GetArmy()
            local bp = self.Blueprint
            for k, v in self.FxUpackingChargeEffects do
                for ek, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                    CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale)
                end
            end
            DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
        end
    end,
}

---@class HawkGaussCannonWeapon : DefaultProjectileWeapon
HawkGaussCannonWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.TGaussCannonFlash,
}

---@class UEFNavyMineWeapon : KamikazeWeapon
UEFNavyMineWeapon = Class(KamikazeWeapon){
    FxDeath = BlackOpsEffectTemplate.NavalMineHit01,

    OnFire = function(self)
        local army = self.unit:GetArmy()
        for k, v in self.FxDeath do
            CreateEmitterAtBone(self.unit,-2,army,v)
        end
        KamikazeWeapon.OnFire(self)
    end,
}

---@class UEFNavyMineDeathWeapon : BareBonesWeapon
UEFNavyMineDeathWeapon = Class(BareBonesWeapon) {
    FxDeath = BlackOpsEffectTemplate.NavalMineHit01,

    OnCreate = function(self)
        BareBonesWeapon.OnCreate(self)
        self:SetWeaponEnabled(false)
    end,

    OnFire = function(self)
    end,

    Fire = function(self)
        local army = self.unit:GetArmy()
        for k, v in self.FxDeath do
            CreateEmitterAtBone(self.unit,-2,army,v)
        end
        local myBlueprint = self.Blueprint
        DamageArea(self.unit, self.unit:GetPosition(), myBlueprint.DamageRadius, myBlueprint.Damage, myBlueprint.DamageType or 'Normal', myBlueprint.DamageFriendly or false)
    end,
}

---@class AeonMineDeathWeapon : DefaultProjectileWeapon
AeonMineDeathWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {
        '/effects/emitters/default_muzzle_flash_01_emit.bp',
        '/effects/emitters/default_muzzle_flash_02_emit.bp',
        '/effects/emitters/torpedo_underwater_launch_01_emit.bp',
    },
    OnWeaponFired = function(self)
        self.unit:Kill()
    end,
}

---@class SeraNavyMineWeapon : KamikazeWeapon
SeraNavyMineWeapon = Class(KamikazeWeapon){
    FxDeath = BlackOpsEffectTemplate.SDFExperimentalPhasonProjHit01,

    OnFire = function(self)
        local army = self.unit:GetArmy()
        for k, v in self.FxDeath do
            CreateEmitterAtBone(self.unit,-2,army,v)
        end
        KamikazeWeapon.OnFire(self)
    end,
}

---@class SeraNavyMineDeathWeapon : BareBonesWeapon
SeraNavyMineDeathWeapon = Class(BareBonesWeapon) {
    FxDeath = BlackOpsEffectTemplate.MineExplosion01,

    OnCreate = function(self)
        BareBonesWeapon.OnCreate(self)
        self:SetWeaponEnabled(false)
    end,


    OnFire = function(self)
    end,

    Fire = function(self)
        local army = self.unit:GetArmy()
        for k, v in self.FxDeath do
            CreateEmitterAtBone(self.unit,-2,army,v)
        end
        local myBlueprint = self.Blueprint
        DamageArea(self.unit, self.unit:GetPosition(), myBlueprint.DamageRadius, myBlueprint.Damage, myBlueprint.DamageType or 'Normal', myBlueprint.DamageFriendly or false)
    end,
}

---@class SeraMineDeathExplosion : BareBonesWeapon
SeraMineDeathExplosion = Class(BareBonesWeapon) {
    FxDeath = BlackOpsEffectTemplate.MineExplosion01,

    OnCreate = function(self)
        BareBonesWeapon.OnCreate(self)
        self:SetWeaponEnabled(false)
    end,


    OnFire = function(self)
    end,

    Fire = function(self)
        local army = self.unit:GetArmy()
        for k, v in self.FxDeath do
            CreateEmitterAtBone(self.unit,-2,army,v)
        end
        local myBlueprint = self.Blueprint
        DamageArea(self.unit, self.unit:GetPosition(), myBlueprint.DamageRadius, myBlueprint.Damage, myBlueprint.DamageType or 'Normal', myBlueprint.DamageFriendly or false)
    end,
}

---@class SeraMineExplosion : KamikazeWeapon
SeraMineExplosion = Class(KamikazeWeapon){
    FxDeath = BlackOpsEffectTemplate.MineExplosion01,

    OnFire = function(self)
        local army = self.unit:GetArmy()
        for k, v in self.FxDeath do
            CreateEmitterAtBone(self.unit,-2,army,v)
        end
        KamikazeWeapon.OnFire(self)
    end,
}

---@class MGAALaserWeapon : DefaultBeamWeapon
MGAALaserWeapon = Class(DefaultBeamWeapon) {
    BeamType = BlackOpsCollisionBeamFile.MGAALaserCollisionBeam,
    FxMuzzleFlash = {'/effects/emitters/particle_cannon_muzzle_01_emit.bp'},
}

---@class GoldenLaserGenerator : DefaultBeamWeapon
GoldenLaserGenerator = Class(DefaultBeamWeapon) {
    BeamType = BlackOpsCollisionBeamFile.GoldenLaserCollisionBeam01,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
}

---@class RedHeavyTurboLaserWeapon : DefaultProjectileWeapon
RedHeavyTurboLaserWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = BlackOpsEffectTemplate.RedLaserMuzzleFlash01,
}

---@class ArtemisLaserGenerator : DefaultBeamWeapon
ArtemisLaserGenerator = Class(DefaultBeamWeapon) {
    BeamType = BlackOpsCollisionBeamFile.GoldenLaserCollisionBeam01,
    FxMuzzleFlash = BlackOpsEffectTemplate.ArtemisMuzzleFlash,
    FxMuzzleFlashEffectScale = 0.5,
    FxChargeMuzzleFlash = {},
}

---@class BOHellstormGun : DefaultProjectileWeapon
BOHellstormGun = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.TIFArtilleryMuzzleFlash,
    FxShellEject  = BlackOpsEffectTemplate.HellStormGunShells,

    PlayFxMuzzleSequence = function(self, muzzle)
        DefaultProjectileWeapon.PlayFxMuzzleSequence(self, muzzle)
        for k, v in self.FxShellEject do
            CreateAttachedEmitter(self.unit, 'Spew', self.unit:GetArmy(), v)
        end
    end,
}

---@class GoliathTMDGun : DefaultProjectileWeapon
GoliathTMDGun = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.TPhalanxGunMuzzleFlash,
    FxShellEject  = EffectTemplate.TPhalanxGunShells,

    PlayFxMuzzleSequence = function(self, muzzle)
        DefaultProjectileWeapon.PlayFxMuzzleSequence(self, muzzle)
        for k, v in self.FxShellEject do
            CreateAttachedEmitter(self.unit, 'TMD_Barrel', self.unit:GetArmy(), v)
        end
    end,
}

---@class YenzothaExperimentalLaser : DefaultBeamWeapon
YenzothaExperimentalLaser = Class(DefaultBeamWeapon) {
    BeamType = BlackOpsCollisionBeamFile.YenaothaExperimentalLaserCollisionBeam,
    FxUpackingChargeEffects = EffectTemplate.SDFExperimentalPhasonProjChargeMuzzleFlash,
    FxUpackingChargeEffectScale = 1,

    PlayFxWeaponUnpackSequence = function(self)
        if not self.ContBeamOn then
            local army = self.unit:GetArmy()
            local bp = self.Blueprint
            for k, v in self.FxUpackingChargeEffects do
                for ek, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                    CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale)
                end
            end
            DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
        end
    end,
}

---@class YenzothaExperimentalLaser02 : DefaultBeamWeapon
YenzothaExperimentalLaser02 = Class(DefaultBeamWeapon) {
    BeamType = BlackOpsCollisionBeamFile.YenaothaExperimentalLaser02CollisionBeam,
    FxUpackingChargeEffects = EffectTemplate.SDFExperimentalPhasonProjChargeMuzzleFlash,
    FxUpackingChargeEffectScale = 0.2,

    PlayFxWeaponUnpackSequence = function(self)
        if not self.ContBeamOn then
            local army = self.unit:GetArmy()
            local bp = self.Blueprint
            for k, v in self.FxUpackingChargeEffects do
                for ek, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                    CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale)
                end
            end
            DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
        end
    end,
}

---@class GoliathRocket02 : DefaultProjectileWeapon
GoliathRocket02 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.TIFCruiseMissileLaunchSmoke,
}

-- Goliath rocket script from the Nomads mod
---@class GoliathRocket : DefaultProjectileWeapon
GoliathRocket = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.TIFCruiseMissileLaunchSmoke,

    CreateProjectileForWeapon = function(self, bone)
        local f_count = table.getn(self.Blueprint.RackBones[1].MuzzleBones)
        if not self.FireCounter or self.FireCounter == f_count then self.FireCounter = 0 end
        if not self.TargetTable then self.TargetTable = {} end
        if self.FireCounter == 0 then
            if self:GetCurrentTarget() then
                local PossibleTargetTable
                local aiBrain = self.unit:GetAIBrain()

                if self:GetCurrentTarget() then
                    PossibleTargetTable = aiBrain:GetUnitsAroundPoint(categories.LAND + (categories.STRUCTURE) , self.unit:GetPosition(), self.Blueprint.MaxRadius ,'ENEMY')
                    self.TargetTable = nil
                end

                if not self.TargetTable then self.TargetTable = {} end

                local targetcount = table.getn(PossibleTargetTable)
                local tablecounter = 0

                if targetcount >= f_count then
                    local max_targets = table.getn(PossibleTargetTable)
                    local ran_values = {}
                    repeat
                        local ra = Random(1, max_targets)
                        repeat
                            if table.find(ran_values, ra) then ra = Random(1, max_targets) end
                        until not table.find(ran_values, ra)

                        table.insert(ran_values, ra)
                    until table.getn(ran_values) >= f_count

                    for k, v in ran_values do
                        table.insert(self.TargetTable, PossibleTargetTable[v])
                        tablecounter = tablecounter + 1
                        if tablecounter >= f_count then
                            break
                        end
                    end
                else
                    for k, v in PossibleTargetTable do
                        table.insert(self.TargetTable, v)
                        tablecounter = tablecounter + 1
                        if tablecounter >= targetcount then
                        break
                        end
                    end
                end
            end
        end

        self.FireCounter = self.FireCounter + 1
        local TableSize = table.getn(self.TargetTable)
        local n = self.FireCounter
        if self.TargetTable then
            if TableSize >= 1 then
                if TableSize == f_count then
                    local tar = self.TargetTable[n]
                    if not tar:BeenDestroyed() and not tar.Dead then
                        self:SetTargetEntity(tar)
                        CreateAttachedEmitter(tar, 0, tar:GetArmy(), '/mods/BlackOpsFAF-Unleashed/effects/emitters/targeted_effect_01_emit.bp'):OffsetEmitter(0, 0.5,0)
                    end
                else
                    local ran = Random(1, TableSize)
                    local tar = self.TargetTable[ran]
                    if not tar:BeenDestroyed() and not tar.Dead then
                        self:SetTargetEntity(tar)
                        if tar.Pointed ~= true then
                            CreateAttachedEmitter(tar, 0, tar:GetArmy(), '/mods/BlackOpsFAF-Unleashed/effects/emitters/targeted_effect_01_emit.bp'):OffsetEmitter(0, 0.5,0)
                            tar.Pointed = true
                            tar:ForkThread(self.PointedThread, self)
                        end
                    end
                end
            end
        end
        GoliathRocket02.CreateProjectileForWeapon(self, bone)
    end,

    OnWeaponFired = function(self)
        self.FireCounter = 0
        GoliathRocket02.OnWeaponFired(self)
    end,

    PointedThread = function(tar, self)
        WaitSeconds(5)
        tar.Pointed = false
    end,
}

---@class BasiliskAAMissile02 : DefaultProjectileWeapon
BasiliskAAMissile02 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {
        '/effects/emitters/cannon_muzzle_flash_04_emit.bp',
        '/effects/emitters/cannon_muzzle_smoke_11_emit.bp',
    },
}

---@class BasiliskAAMissile01 : DefaultProjectileWeapon
BasiliskAAMissile01 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {
        '/effects/emitters/cannon_muzzle_flash_04_emit.bp',
        '/effects/emitters/cannon_muzzle_smoke_11_emit.bp',
    },

    CreateProjectileForWeapon = function(self, bone)
            local f_count = table.getn(self.Blueprint.RackBones[1].MuzzleBones)
            if not self.FireCounter or self.FireCounter == f_count then self.FireCounter = 0 end
            if not self.TargetTable then self.TargetTable = {} end

            if self.FireCounter == 0 then
                if self:GetCurrentTarget() then
                    local PossibleTargetTable
                    local aiBrain = self.unit:GetAIBrain()

                    if self:GetCurrentTarget() then
                        PossibleTargetTable = aiBrain:GetUnitsAroundPoint(categories.AIR , self.unit:GetPosition(), self.Blueprint.MaxRadius ,'ENEMY')
                        self.TargetTable = nil
                    end

                    if not self.TargetTable then self.TargetTable = {} end

                    local targetcount = table.getn(PossibleTargetTable)
                    local tablecounter = 0

                    if targetcount >= f_count then
                        local max_targets = table.getn(PossibleTargetTable)
                        local ran_values = {}
                        repeat
                            local ra = Random(1, max_targets)
                            repeat
                                if table.find(ran_values, ra) then ra = Random(1, max_targets) end
                            until not table.find(ran_values, ra)

                            table.insert(ran_values, ra)
                        until table.getn(ran_values) >= f_count

                        for k, v in ran_values do
                            table.insert(self.TargetTable, PossibleTargetTable[v])
                            tablecounter = tablecounter + 1
                            if tablecounter >= f_count then
                                break
                            end
                        end

                    else
                        for k, v in PossibleTargetTable do
                            table.insert(self.TargetTable, v)
                            tablecounter = tablecounter + 1
                            if tablecounter >= targetcount then
                                break
                            end
                        end
                    end
                end
            end

            self.FireCounter = self.FireCounter + 1
            local TableSize = table.getn(self.TargetTable)
            local n = self.FireCounter
            if self.TargetTable then
                if TableSize >= 1 then
                    if TableSize == f_count then
                        local tar = self.TargetTable[n]
                        if not tar:BeenDestroyed() and not tar.Dead then
                            self:SetTargetEntity(tar)
                        end
                    else
                        local ran = Random(1, TableSize)
                        local tar = self.TargetTable[ran]
                        if not tar:BeenDestroyed() and not tar.Dead then
                            self:SetTargetEntity(tar)
                            if tar.Pointed ~= true then
                                tar.Pointed = true
                                tar:ForkThread(self.PointedThread, self)
                            end
                        end
                    end
                end
            end
        BasiliskAAMissile02.CreateProjectileForWeapon(self, bone)
    end,

    OnWeaponFired = function(self)
        self.FireCounter = 0
        BasiliskAAMissile02.OnWeaponFired(self)
    end,

    PointedThread = function(tar, self)
        WaitSeconds(5)
        tar.Pointed = false
    end,
}

---@class ATeleWeapon : DefaultProjectileWeapon
ATeleWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.TIFArtilleryMuzzleFlash
}

---@class JuggPlasmaGatlingCannonWeapon : DefaultProjectileWeapon
JuggPlasmaGatlingCannonWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = BlackOpsEffectTemplate.JuggPlasmaGatlingCannonMuzzleFlash,
    FxShellEject  = BlackOpsEffectTemplate.JuggPlasmaGatlingCannonShells,
    FxMuzzleFlashScale = 0.5,

    PlayFxMuzzleSequence = function(self, muzzle)
        DefaultProjectileWeapon.PlayFxMuzzleSequence(self, muzzle)
        for k, v in self.FxShellEject do
            CreateAttachedEmitter(self.unit, 'Left_Shells', self.unit:GetArmy(), v):ScaleEmitter(0.5)
            CreateAttachedEmitter(self.unit, 'Right_Shells', self.unit:GetArmy(), v):ScaleEmitter(0.5)
        end
    end,
}

---@class CitadelHVMWeapon02 : DefaultProjectileWeapon
CitadelHVMWeapon02 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.TAAMissileLaunch,
}

---@class CitadelHVMWeapon : DefaultProjectileWeapon
CitadelHVMWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.TAAMissileLaunch,

    CreateProjectileForWeapon = function(self, bone)
        local f_count = table.getn(self.Blueprint.RackBones[1].MuzzleBones)
        if not self.FireCounter or self.FireCounter == f_count then self.FireCounter = 0 end
        if not self.TargetTable then self.TargetTable = {} end

        if self.FireCounter == 0 then
            if self:GetCurrentTarget() then
                local PossibleTargetTable
                local aiBrain = self.unit:GetAIBrain()

                if self:GetCurrentTarget() then
                    PossibleTargetTable = aiBrain:GetUnitsAroundPoint(categories.AIR , self.unit:GetPosition(), self.Blueprint.MaxRadius ,'ENEMY')
                    self.TargetTable = nil
                end

                if not self.TargetTable then self.TargetTable = {} end

                local targetcount = table.getn(PossibleTargetTable)
                local tablecounter = 0

                if targetcount >= f_count then
                    local max_targets = table.getn(PossibleTargetTable)
                    local ran_values = {}
                    repeat
                        local ra = Random(1, max_targets)
                        repeat
                            if table.find(ran_values, ra) then ra = Random(1, max_targets) end
                        until not table.find(ran_values, ra)

                        table.insert(ran_values, ra)
                    until table.getn(ran_values) >= f_count

                    for k, v in ran_values do
                        table.insert(self.TargetTable, PossibleTargetTable[v])
                        tablecounter = tablecounter + 1
                        if tablecounter >= f_count then
                            break
                        end
                    end

                else
                    for k, v in PossibleTargetTable do
                        table.insert(self.TargetTable, v)
                        tablecounter = tablecounter + 1
                        if tablecounter >= targetcount then
                            break
                        end
                    end
                end
            end
        end

        self.FireCounter = self.FireCounter + 1
        local TableSize = table.getn(self.TargetTable)
        local n = self.FireCounter
        if self.TargetTable then
            if TableSize >= 1 then
                if TableSize == f_count then
                    local tar = self.TargetTable[n]
                    if not tar:BeenDestroyed() and not tar.Dead then
                        self:SetTargetEntity(tar)
                    end
                else
                    local ran = Random(1, TableSize)
                    local tar = self.TargetTable[ran]
                    if not tar:BeenDestroyed() and not tar.Dead then
                        self:SetTargetEntity(tar)
                        if tar.Pointed ~= true then
                            tar.Pointed = true
                            tar:ForkThread(self.PointedThread, self)
                        end
                    end
                end
            end
        end
        CitadelHVMWeapon02.CreateProjectileForWeapon(self, bone)
    end,

    OnWeaponFired = function(self)
        self.FireCounter = 0
        CitadelHVMWeapon02.OnWeaponFired(self)
    end,

    PointedThread = function(tar, self)
        WaitSeconds(5)
        tar.Pointed = false
    end,
}

---@class CitadelPlasmaGatlingCannonWeapon : DefaultProjectileWeapon
CitadelPlasmaGatlingCannonWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = BlackOpsEffectTemplate.JuggPlasmaGatlingCannonMuzzleFlash,
    FxShellEject  = BlackOpsEffectTemplate.JuggPlasmaGatlingCannonShells,
    FxMuzzleFlashScale = 0.5,

    PlayFxMuzzleSequence = function(self, muzzle)
        DefaultProjectileWeapon.PlayFxMuzzleSequence(self, muzzle)
        for k, v in self.FxShellEject do
            CreateAttachedEmitter(self.unit, 'Gat_Shells', self.unit:GetArmy(), v):ScaleEmitter(0.5)
        end
    end,
}
