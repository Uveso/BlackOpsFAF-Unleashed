CAANanoDartProjectile = import('/lua/cybranprojectiles.lua').CAANanoDartProjectile

-- Cybran Anti Air Projectile
---@class CAANanoDart01 : CAANanoDartProjectile
CAANanoDart01 = Class(CAANanoDartProjectile) {

    ---@param self CAANanoDart01
    OnCreate = function(self)
        CAANanoDartProjectile.OnCreate(self)
        self:ForkThread(self.UpdateThread)
    end,

    ---@param self CAANanoDart01
    UpdateThread = function(self)
        local army = self.Army

        WaitSeconds(0.1)
        self:SetBallisticAcceleration(-0.5)

        for i in self.FxTrails do
            CreateEmitterOnEntity(self,army,self.FxTrails[i])
        end

        WaitSeconds(0.2)
        self:SetMesh('/projectiles/CAANanoDart01/CAANanoDartUnPacked01_mesh')
    end,
}
TypeClass = CAANanoDart01
