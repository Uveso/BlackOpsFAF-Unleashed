-----------------------------------------------------------------------------------
-- File     :  /data/Projectiles/ADFReactonCannnon01/ADFReactonCannnon01_script.lua
-- Author(s): Jessica St.Croix, Gordon Duclos
-- Summary  : Aeon Reacton Cannon Area of Effect Projectile
-- Copyright � 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------------
local ArtemisCannonProjectile = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsProjectiles.lua').ArtemisCannonProjectile

---@class ADFReactonCannon01 : ArtemisCannonProjectile
ADFReactonCannon01 = Class(ArtemisCannonProjectile) {

    ---@param self ADFReactonCannon01
    ---@param TargetType string
    ---@param TargetEntity Entity
    OnImpact = function(self, TargetType, TargetEntity)
        if not TargetEntity or not EntityCategoryContains(categories.PROJECTILE, TargetEntity) then
            -- Play the explosion sound
            local myBlueprint = self.Blueprint
            if myBlueprint.Audio.Explosion then
                self:PlaySound(myBlueprint.Audio.Explosion)
            end

            nukeProjectile = self:CreateProjectile('/mods/BlackOpsFAF-Unleashed/effects/entities/ArtemisBombEffectController01/ArtemisBombEffectController01_proj.bp', 0, 0, 0, 0, 0, 0):SetCollision(false)
            local pos = self:GetPosition()
            pos[2] = pos[2] + 10
            Warp(nukeProjectile, pos)
            nukeProjectile:PassData(self.Data)
        end
        ArtemisCannonProjectile.OnImpact(self, TargetType, TargetEntity)
    end,

    ---@param self ADFReactonCannon01
    ---@param instigator Unit
    ---@param amount number
    ---@param vector Vector
    ---@param damageType DamageType
    DoTakeDamage = function(self, instigator, amount, vector, damageType)
        if self.ProjectileDamaged then
            -- Play the explosion sound
            local myBlueprint = self.Blueprint
            if myBlueprint.Audio.Explosion then
                self:PlaySound(myBlueprint.Audio.Explosion)
            end

            nukeProjectile = self:CreateProjectile('/mods/BlackOpsFAF-Unleashed/projectiles/ArtemisWarhead02/ArtemisWarhead02_proj.bp', 0, 0, 0, nil, nil, nil):SetCollision(false)
            nukeProjectile:PassData(self.Data)
        end
        ArtemisCannonProjectile.DoTakeDamage(self, instigator, amount, vector, damageType)
    end,

    ---@param self ADFReactonCannon01
    OnCreate = function(self)
        ArtemisCannonProjectile.OnCreate(self)
        local launcher = self.Launcher
        if launcher and not launcher.Dead and launcher.EventCallbacks.ProjectileDamaged then
            self.ProjectileDamaged = {}
            for _, v in launcher.EventCallbacks.ProjectileDamaged do
                table.insert(self.ProjectileDamaged, v)
            end
        end
    end,
}
TypeClass = ADFReactonCannon01
