local MiniRocketPRojectile = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsProjectiles.lua').MiniRocketPRojectile
local EffectTemplate = import('/lua/EffectTemplates.lua')

---@class AWMissileCruise01 : MiniRocketPRojectile
AWMissileCruise01 = Class(MiniRocketPRojectile) {
    FxTrails = EffectTemplate.TMissileExhaust01,
    FxImpactUnit = EffectTemplate.TMissileHit01,
    FxImpactLand = EffectTemplate.TMissileHit01,
    FxImpactProp = EffectTemplate.TMissileHit01,
    FxAirUnitHitScale = 1,
    FxLandHitScale = 1,
    FxNoneHitScale = 1,
    FxPropHitScale = 1,
    FxProjectileHitScale = 1,
    FxProjectileUnderWaterHitScale = 1,
    FxShieldHitScale = 01,
    FxUnderWaterHitScale = 1,
    FxUnitHitScale = 1,
    FxWaterHitScale = 1,
    FxOnKilledScale = 1,

    ---@param self AWMissileCruise01
    OnCreate = function(self)
        MiniRocketPRojectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 1.2)
        self:ForkThread(self.CruiseMissileThread)
    end,

    ---@param self AWMissileCruise01
    CruiseMissileThread = function(self)
        self:SetTurnRate(180)
        WaitSeconds(2)
        self:SetTurnRate(180)
        WaitSeconds(1)
        self:SetTurnRate(360)
    end,
}

TypeClass = AWMissileCruise01
