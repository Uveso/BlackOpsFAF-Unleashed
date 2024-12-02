-- Terran Anti Air Missile
local CitadelHVM01Projectile = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsProjectiles.lua').CitadelHVM01Projectile

---@class CitadelHVM01 : CitadelHVM01Projectile
CitadelHVM01 = Class(CitadelHVM01Projectile) {

    ---@param self CitadelHVM01
    ---@param TargetType string
    ---@param TargetEntity Entity
    OnImpact = function(self, TargetType, TargetEntity)
        if EntityCategoryContains(categories.EXPERIMENTAL, TargetEntity) then
            self.DamageData.DamageAmount = self.Launcher.Blueprint.ExperimentalDamage.DamageAmount
        end
        CitadelHVM01Projectile.OnImpact(self, TargetType, TargetEntity)
    end,
}
TypeClass = CitadelHVM01
