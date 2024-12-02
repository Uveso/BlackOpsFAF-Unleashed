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

        WaitSeconds(0.35)
        self:SetMaxSpeed(8)
        self:SetBallisticAcceleration(-0.5)

        for i in self.FxTrails do
            CreateEmitterOnEntity(self,army,self.FxTrails[i])
        end

        WaitSeconds(0.5)
        self:SetMesh('/projectiles/CAANanoDart01/CAANanoDartUnPacked01_mesh')
        self:SetMaxSpeed(100)
        self:SetAcceleration(20 + Random() * 5)

        WaitSeconds(0.3)
        self:SetTurnRate(360)

    end,
}
TypeClass = CAANanoDart01
