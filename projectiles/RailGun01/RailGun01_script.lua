-----------------------------------------------------------------------------------------------------------
-- File     :  /data/projectiles/TDFIonizedPlasmaGatlingCannon01/TDFIonizedPlasmaGatlingCannon01_script.lua
-- Author(s):  Gordon Duclos
-- Summary  :  UEF Ionized Plasma Gatling Cannon Projectile script, XEL0305
-- Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------------------------------------------------
local RailGun01Projectile = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsProjectiles.lua').RailGun01Projectile

---@class RailGun01 : RailGun01Projectile
RailGun01 = Class(RailGun01Projectile) {

    ---@param self RailGun01
    ---@param TargetType string
    ---@param TargetEntity Entity
    OnImpact = function(self, TargetType, TargetEntity)
        self:ShakeCamera(15, 0.25, 0, 0.2)
        RailGun01Projectile.OnImpact (self, TargetType, TargetEntity)
    end,

    ---@param self RailGun01
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpactDestroy = function(self, targetType, targetEntity)
        if targetEntity and not IsUnit(targetEntity) then
                RailGun01Projectile.OnImpactDestroy(self, targetType, targetEntity)
            return
        end

        if self.counter then
            if self.counter >= 1 then
                RailGun01Projectile.OnImpactDestroy(self, targetType, targetEntity)
                return
            else
                self.counter = self.counter + 1
            end
        else
            self.counter = 1
        end

        if targetEntity then
            self.lastimpact = targetEntity:GetEntityId()
        end
    end,
}

TypeClass = RailGun01
