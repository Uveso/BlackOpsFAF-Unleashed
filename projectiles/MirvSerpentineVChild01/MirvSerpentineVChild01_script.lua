local MIRVChild01Projectile = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsProjectiles.lua').MIRVChild01Projectile
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

-- Aeon Serpentine Missile
---@class MIRVChild01 : MIRVChild01Projectile
MIRVChild01 = Class(MIRVChild01Projectile) {

    ---@param self MIRVChild01
    OnCreate = function(self)
        MIRVChild01Projectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2)
    end,

    ---@param self MIRVChild01
    ---@param TargetType string
    ---@param targetEntity Entity
    OnImpact = function(self, TargetType, targetEntity)
        local rotation = RandomFloat(0,2*math.pi)

        CreateDecal(self:GetPosition(), rotation, 'scorch_004_albedo', '', 'Albedo', 13, 13, 300, 15, self.Army)

        MIRVChild01Projectile.OnImpact(self, TargetType, targetEntity)
    end,
}

TypeClass = MIRVChild01
