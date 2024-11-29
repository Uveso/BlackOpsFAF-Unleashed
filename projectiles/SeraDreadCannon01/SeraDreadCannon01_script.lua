-------------------------------------------------------------------------------------
-- File     :  /data/projectiles/SDFSinnuntheWeapon01/SDFSinnuntheWeapon01_script.lua
-- Author(s):  Matt Vainio
-- Summary  :  Sinn-Uthe Projectile script, XSL0401
-- Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.
-------------------------------------------------------------------------------------
local SDFSinnuntheWeaponProjectile = import('/lua/seraphimprojectiles.lua').SDFSinnuntheWeaponProjectile
local utilities = import('/lua/utilities.lua')

---@class SDFSinnuntheWeapon01 : SDFSinnuntheWeaponProjectile
SDFSinnuntheWeapon01 = Class(SDFSinnuntheWeaponProjectile) {
    AttackBeams = {'/effects/emitters/seraphim_othuy_beam_01_emit.bp'},
    SpawnEffects = {
        '/effects/emitters/seraphim_othuy_spawn_01_emit.bp',
        '/effects/emitters/seraphim_othuy_spawn_02_emit.bp',
        '/effects/emitters/seraphim_othuy_spawn_03_emit.bp',
        '/effects/emitters/seraphim_othuy_spawn_04_emit.bp',
    },

    ---@param self SDFSinnuntheWeapon01
    OnCreate = function(self)
        SDFSinnuntheWeaponProjectile.OnCreate(self)
    end,

    ---@param self SDFSinnuntheWeapon01
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpact = function(self, targetType, targetEntity)
        SDFSinnuntheWeaponProjectile.OnImpact(self, targetType, targetEntity)
        local army = self.Army

        local position = self:GetPosition()
        local spiritUnit = CreateUnitHPR('BSL0404', army, position[1], position[2], position[3], 0, 0, 0)

        -- Create effects for spawning of energy being
        for k, v in self.SpawnEffects do
            CreateAttachedEmitter(spiritUnit, -1, army, v):ScaleEmitter(0.5)
        end
    end,

    ---@param self SDFSinnuntheWeapon01
    targetThread = function(self)
        local beams = {}
        while true do
            local instigator = self.Launcher
            local targets = {}
            targets = utilities.GetEnemyUnitsInSphere(self, self:GetPosition(), self.DamageData.DamageRadius)
            if targets then
                for _, v in targets do
                    DamageArea(instigator,self:GetPosition(),self.DamageData.DamageRadius,self.DamageData.DamageAmount,self.DamageData.DamageType,self.DamageData.DamageFriendly)
                    local target = v
                    for _, v in self.AttackBeams do
                        local beam = AttachBeamEntityToEntity(target, -1, self, -2, self.Army, v)
                        table.insert(beams, beam)
                        self.Trash:Add(beam)
                    end
                end
            end
            WaitTicks(1)
            for _, v in beams do
                v:Destroy()
            end
        end
    end,
}

TypeClass = SDFSinnuntheWeapon01
