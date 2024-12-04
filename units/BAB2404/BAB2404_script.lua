-----------------------------------------------------------------
-- File     :  /cdimage/units/BAB2404/BAB2404_script.lua
-- Author(s):  David Tomandl
-- Summary  :  Aeon Land Factory Tier 3 Script
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local ALandFactoryUnit = import('/lua/aeonunits.lua').ALandFactoryUnit

-- upvalue for performance
local TrashBagAdd = TrashBag.Add

---@class BAB2404 : ALandFactoryUnit
BAB2404 = Class(ALandFactoryUnit) {
    DeathThreadDestructionWaitTime = 8,
    BuildingEffect01 = {
        '/effects/emitters/light_blue_blinking_01_emit.bp',
    },

    BuildingEffect02 = {
        '/effects/emitters/light_red_03_emit.bp',
    },

    ---@param self BAB2404
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        ALandFactoryUnit.OnStopBeingBuilt(self,builder,layer)
        local trash = self.Trash
        
        self.BuildingEffect01Bag = {}
        self.BuildingEffect02Bag = {}

        for i = 1, 16 do
            local fxname
            if i < 10 then
                fxname = 'Light0' .. i
            else
                fxname = 'Light' .. i
            end
            local fx = CreateAttachedEmitter(self, fxname, self.Army, '/effects/emitters/light_yellow_02_emit.bp'):OffsetEmitter(0, 0, 0.01):ScaleEmitter(3)
            TrashBagAdd(trash, fx)
        end
    end,

    ---@param self BAB2404
    ---@param unitBeingBuilt Unit
    ---@param order string
    OnStartBuild = function(self, unitBeingBuilt, order)
        ALandFactoryUnit.OnStartBuild(self, unitBeingBuilt, order)
        local drone = unitBeingBuilt
        local army = self.Army
        self.PetDrone = drone
        self.PetDrone.Parent = self

        -- Drone clean up scripts
        if self.BuildingEffect01Bag then
            for _, v in self.BuildingEffect01Bag do
                v:Destroy()
            end
            self.BuildingEffect01Bag = {}
        end
        for _, v in self.BuildingEffect01 do
            table.insert(self.BuildingEffect01Bag, CreateAttachedEmitter(self, 'BlinkyLight01', army, v):OffsetEmitter(0, 0, 0.01):ScaleEmitter(1.00))
            table.insert(self.BuildingEffect01Bag, CreateAttachedEmitter(self, 'BlinkyLight02', army, v):OffsetEmitter(0, 0, 0.01):ScaleEmitter(1.00))
            table.insert(self.BuildingEffect01Bag, CreateAttachedEmitter(self, 'BlinkyLight03', army, v):OffsetEmitter(0, 0, 0.01):ScaleEmitter(1.00))
            table.insert(self.BuildingEffect01Bag, CreateAttachedEmitter(self, 'BlinkyLight04', army, v):OffsetEmitter(0, 0, 0.01):ScaleEmitter(1.00))
            table.insert(self.BuildingEffect01Bag, CreateAttachedEmitter(self, 'BlinkyLight05', army, v):OffsetEmitter(0, 0, 0.01):ScaleEmitter(1.00))
            table.insert(self.BuildingEffect01Bag, CreateAttachedEmitter(self, 'BlinkyLight06', army, v):OffsetEmitter(0, 0, 0.01):ScaleEmitter(1.00))
            table.insert(self.BuildingEffect01Bag, CreateAttachedEmitter(self, 'BlinkyLight07', army, v):OffsetEmitter(0, 0, 0.01):ScaleEmitter(1.00))
            table.insert(self.BuildingEffect01Bag, CreateAttachedEmitter(self, 'BlinkyLight08', army, v):OffsetEmitter(0, 0, 0.01):ScaleEmitter(1.00))
        end
        if self.BuildingEffect02Bag then
            for _, v in self.BuildingEffect02Bag do
                v:Destroy()
            end
            self.BuildingEffect02Bag = {}
        end
        for _, v in self.BuildingEffect02 do
            table.insert(self.BuildingEffect02Bag, CreateAttachedEmitter(self, 'BlinkyLight09', army, v):OffsetEmitter(0, 0, 0.01):ScaleEmitter(1.00))
            table.insert(self.BuildingEffect02Bag, CreateAttachedEmitter(self, 'BlinkyLight10', army, v):OffsetEmitter(0, 0, 0.01):ScaleEmitter(1.00))
            table.insert(self.BuildingEffect02Bag, CreateAttachedEmitter(self, 'BlinkyLight11', army, v):OffsetEmitter(0, 0, 0.01):ScaleEmitter(1.00))
            table.insert(self.BuildingEffect02Bag, CreateAttachedEmitter(self, 'BlinkyLight12', army, v):OffsetEmitter(0, 0, 0.01):ScaleEmitter(1.00))
            table.insert(self.BuildingEffect02Bag, CreateAttachedEmitter(self, 'BlinkyLight13', army, v):OffsetEmitter(0, 0, 0.01):ScaleEmitter(1.00))
            table.insert(self.BuildingEffect02Bag, CreateAttachedEmitter(self, 'BlinkyLight14', army, v):OffsetEmitter(0, 0, 0.01):ScaleEmitter(1.00))
            table.insert(self.BuildingEffect02Bag, CreateAttachedEmitter(self, 'BlinkyLight15', army, v):OffsetEmitter(0, 0, 0.01):ScaleEmitter(1.00))
            table.insert(self.BuildingEffect02Bag, CreateAttachedEmitter(self, 'BlinkyLight16', army, v):OffsetEmitter(0, 0, 0.01):ScaleEmitter(1.00))
        end
    end,

    ---@param self BAB2404
    ---@param unitBeingBuilt Unit
    ---@param order string
    OnStopBuild = function(self, unitBeingBuilt, order)
        ALandFactoryUnit.OnStopBuild(self, unitBeingBuilt, order)
        if self.BuildingEffect01Bag then
            for _, v in self.BuildingEffect01Bag do
                v:Destroy()
            end
            self.BuildingEffect01Bag = {}
        end
        if self.BuildingEffect02Bag then
            for _, v in self.BuildingEffect02Bag do
                v:Destroy()
            end
            self.BuildingEffect02Bag = {}
        end
    end,

    ---@param self BAB2404
    ---@param unitBeingBuilt Unit
    ---@param order string
    FinishBuildThread = function(self, unitBeingBuilt, order)
        ALandFactoryUnit.FinishBuildThread(self, unitBeingBuilt, order)
        self:PlayUnitSound('LaunchSat')
        self:AddBuildRestriction(categories.BUILTBYARTEMIS)
    end,

    ---@param self BAB2404
    NotifyOfDroneDeath = function(self)
        -- Remove build restriction if sat has been lost
        self.PetDrone = nil
        if self and not self.Dead then
            self:RemoveBuildRestriction(categories.BUILTBYARTEMIS)
        end
    end,

    ---@param self BAB2404
    ---@param instigator Unit
    ---@param type string
    ---@param overkillRatio number
    OnKilled = function(self, instigator, type, overkillRatio)
        if self.PetDrone then
            self.PetDrone:Kill(self, 'Normal', 0)
            self.PetDrone = nil
        end
        ALandFactoryUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
}

TypeClass = BAB2404
