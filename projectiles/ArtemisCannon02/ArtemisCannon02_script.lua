-----------------------------------------------------------------------------------
-- File     :  /data/Projectiles/ADFReactonCannnon01/ADFReactonCannnon01_script.lua
-- Author(s): Jessica St.Croix, Gordon Duclos
-- Summary  : Aeon Reacton Cannon Area of Effect Projectile
-- Copyright � 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------------
local DummyArtemisCannonProjectile = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsProjectiles.lua').DummyArtemisCannonProjectile

---@class ADFReactonCannon01 : DummyArtemisCannonProjectile
ADFReactonCannon01 = Class(DummyArtemisCannonProjectile) {

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

            nukeProjectile = self:CreateProjectile('/mods/BlackOpsFAF-Unleashed/projectiles/ArtemisWarhead03/ArtemisWarhead03_proj.bp', 0, 0, 0, nil, nil, nil):SetCollision(false)
            nukeProjectile:PassData(self.Data)
        end
        DummyArtemisCannonProjectile.OnImpact(self, TargetType, TargetEntity)
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

            nukeProjectile = self:CreateProjectile('/mods/BlackOpsFAF-Unleashed/projectiles/ArtemisWarhead03/ArtemisWarhead03_proj.bp', 0, 0, 0, nil, nil, nil):SetCollision(false)
            nukeProjectile:PassData(self.Data)
        end
        DummyArtemisCannonProjectile.DoTakeDamage(self, instigator, amount, vector, damageType)
    end,

    ---@param self ADFReactonCannon01
    OnCreate = function(self)
        DummyArtemisCannonProjectile.OnCreate(self)
        local launcher = self.Launcher
        if launcher and not launcher.Dead and launcher.EventCallbacks.ProjectileDamaged then
            self.ProjectileDamaged = {}
            for k, v in launcher.EventCallbacks.ProjectileDamaged do
                table.insert(self.ProjectileDamaged, v)
            end
        end
        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)
        self.KillThread = self:ForkThread(self.KillSelfThread)
    end,

    ---@param self ADFReactonCannon01
    KillSelfThread = function(self)
        WaitSeconds(2)
        self:Destroy()
    end,
}
TypeClass = ADFReactonCannon01
