local MGHeadshotProjectile = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsProjectiles.lua').MGHeadshotProjectile

-- Aeon Artillery Projectile
---@class AeonTeleHarb01 : MGHeadshotProjectile
AeonTeleHarb01 = Class(MGHeadshotProjectile) {

    ---@param self AeonTeleHarb01
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpact = function(self, targetType, targetEntity)
        MGHeadshotProjectile.OnImpact(self, targetType, targetEntity)

        local myBlueprint = self.Blueprint
        self:PlaySound(myBlueprint.Audio.CommanderArrival)
        self:CreateProjectile('/effects/entities/AeonUnitTeleporter01/AeonUnitTeleporter01_proj.bp', 0, 1, 0, nil, nil, nil):SetCollision(false)
    end,

}
TypeClass = AeonTeleHarb01
