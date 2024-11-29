local CAAMissileNaniteProjectile = import('/lua/cybranprojectiles.lua').CAAMissileNaniteProjectile

-- AA Missile for Cybrans
---@class CAAMissileNanite02 : CAAMissileNaniteProjectile
CAAMissileNanite02 = Class(CAAMissileNaniteProjectile) {

    ---@param self CAAMissileNanite02
    OnCreate = function(self)
        CAAMissileNaniteProjectile.OnCreate(self)
        self:ForkThread(self.UpdateThread)
    end,

    ---@param self CAAMissileNanite02
    UpdateThread = function(self)
        WaitSeconds(1.5)
        self:SetMaxSpeed(80)
        self:SetAcceleration(10 + Random() * 8)
        self:ChangeMaxZigZag(5)
        self:ChangeZigZagFrequency(2)
        self:SetTurnRate(8)
        WaitSeconds(2)
        self:SetTurnRate(180)
    end,
}

TypeClass = CAAMissileNanite02
