---------------------------------------------------------------------------------------------
-- File     :  /data/projectiles/AANTorpedoClusterSplit01/AANTorpedoClusterSplit01_script.lua
-- Author(s):  Gordon Duclos
-- Summary  :  Aeon Torpedo Cluster Projectile script, XAA0306
-- Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.
---------------------------------------------------------------------------------------------
local AMTorpedoCluster = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsProjectiles.lua').AMTorpedoCluster
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

---@class AANTorpedoClusterSplit01 : AMTorpedoCluster
AANTorpedoCluster01 = Class(AMTorpedoCluster) {
    CountdownLength = 10,
    FxEnterWater= {'/effects/emitters/water_splash_ripples_ring_01_emit.bp',
                    '/effects/emitters/water_splash_plume_01_emit.bp',},
    FxExitWater= {'/effects/emitters/water_splash_ripples_ring_01_emit.bp',
                    '/effects/emitters/water_splash_plume_01_emit.bp',},

    ---@param self AANTorpedoClusterSplit01
    OnCreate = function(self)
        AMTorpedoCluster.OnCreate(self)
        self.HasImpacted = false
        self:ForkThread(self.CountdownExplosion)
        CreateTrail(self, -1, self.Army, import('/lua/EffectTemplates.lua').ATorpedoPolyTrails01)
    end,

    ---@param self AANTorpedoClusterSplit01
    CountdownExplosion = function(self)
        WaitSeconds(self.CountdownLength)

        if not self.HasImpacted then
            self.OnImpact(self, 'Underwater', nil)
        end
    end,

    ---@param self AANTorpedoClusterSplit01
    OnEnterWater = function(self)
        AMTorpedoCluster.OnEnterWater(self)
        local army = self.Army
        for i in self.FxEnterWater do
            CreateEmitterAtEntity(self,army,self.FxEnterWater[i])
        end
        self:ForkThread(self.EnterWaterMovementThread)
    end,

    ---@param self AANTorpedoClusterSplit01
    OnExitWater = function(self)
        AMTorpedoCluster.OnExitWater(self)
        local army = self.Army
        for i in self.FxExitWater do
            CreateEmitterAtEntity(self,army,self.FxExitWater[i])
        end
    end,

    ---@param self AANTorpedoClusterSplit01
    EnterWaterMovementThread = function(self)
        self:SetAcceleration(2.5)
        self:TrackTarget(true)
        self:StayUnderwater(true)
        self:SetTurnRate(180)
        self:SetStayUpright(false)
    end,

    ---@param self AANTorpedoClusterSplit01
    OnLostTarget = function(self)
        self:SetMaxSpeed(2)
        self:SetAcceleration(-0.6)
        self:ForkThread(self.CountdownMovement)
    end,

    ---@param self AANTorpedoClusterSplit01
    CountdownMovement = function(self)
        WaitSeconds(3)
        self:SetMaxSpeed(0)
        self:SetAcceleration(0)
        self:SetVelocity(0)
    end,

    ---@param self AANTorpedoClusterSplit01
    ---@param TargetType string
    ---@param TargetEntity Entity
    OnImpact = function(self, TargetType, TargetEntity)
        self.HasImpacted = true
        AMTorpedoCluster.OnImpact(self, TargetType, TargetEntity)
    end,
}

TypeClass = AANTorpedoCluster01
