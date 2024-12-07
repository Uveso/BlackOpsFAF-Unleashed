-----------------------------------------------------------------
-- File     :  /cdimage/units/XRB4309/XRB4309_script.lua
-- Author(s):  David Tomandl, Greg Kohne
-- Summary  :  Cybran Shield Generator lvl 5 Script
-- Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local CStructureUnit = import('/lua/cybranunits.lua').CStructureUnit
local TrashBagAdd = TrashBag.Add

---@class BRB4309 : CStructureUnit
BRB4309 = Class(CStructureUnit) {

    ---@param self BRB4309
    OnCreate = function(self)
        CStructureUnit.OnCreate(self)
        self.ExtractionAnimManip = CreateAnimator(self)
    end,

    ---@param self BRB4309
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        CStructureUnit.OnStopBeingBuilt(self,builder,layer)
        local trash = self.Trash
        self:SetScriptBit('RULEUTC_ShieldToggle', true)
        -- only used to show anti-teleport range
        self:DisableIntel('CloakField')
        self.antiteleportEmitterTable = {}
        TrashBagAdd(trash, ForkThread(self.ResourceThread, self))
    end,

    ---@param self BRB4309
    ---@param bit number
    OnScriptBitSet = function(self, bit)
           CStructureUnit.OnScriptBitSet(self, bit)
           local trash = self.Trash
           if bit == 0 then
            TrashBagAdd(trash, ForkThread(self.antiteleportEmitter, self))
            self:SetMaintenanceConsumptionActive()
               if(not self.Rotator1) then
                self.Rotator1 = CreateRotator(self, 'Shaft', 'y')
                TrashBagAdd(trash, self.Rotator1)
            end
            self.Rotator1:SetTargetSpeed(30)
            self.Rotator1:SetAccel(30)
        end
    end,

    ---@param self BRB4309
    ---@param bit number
    OnScriptBitClear = function(self, bit)
        CStructureUnit.OnScriptBitClear(self, bit)
        local trash = self.Trash
        if bit == 0 then
            TrashBagAdd(trash, ForkThread(self.KillantiteleportEmitter, self))
            self:SetMaintenanceConsumptionInactive()
            if(not self.Rotator1) then
                self.Rotator1 = CreateRotator(self, 'Shaft', 'y')
                TrashBagAdd(trash, self.Rotator1)
            end
            self.Rotator1:SetTargetSpeed(0)
            self.Rotator1:SetAccel(30)
        end
    end,

    ---@param self BRB4309
    antiteleportEmitter = function(self)
        local trash = self.Trash
        if not self.Dead then
            WaitSeconds(0.5)
            if not self.Dead then
                local platOrient = self:GetOrientation()
                -- Gets the current position of the platform in the game world
                local location = self:GetPosition('Shaft')

                -- Creates our antiteleportEmitter over the platform with a ranomly generated Orientation
                local antiteleportEmitter = CreateUnit('brb0006', self.Army, location[1], location[2], location[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Land')

                -- Adds the newly created antiteleportEmitter to the parent platforms antiteleportEmitter table
                table.insert (self.antiteleportEmitterTable, antiteleportEmitter)

                antiteleportEmitter:AttachTo(self, 'Shaft')

                -- Sets the platform unit as the antiteleportEmitter parent
                antiteleportEmitter:SetParent(self, 'brb4309')
                antiteleportEmitter:SetCreator(self)
                TrashBagAdd(trash , antiteleportEmitter)
            end
        end
    end,

    ---@param self BRB4309
    KillantiteleportEmitter = function(self)
        -- Small bit of table manipulation to sort thru all of the avalible rebulder bots and remove them after the platform is dead
        if table.getn({self.antiteleportEmitterTable}) > 0 then
            for k, _ in self.antiteleportEmitterTable do
                IssueClearCommands({self.antiteleportEmitterTable[k]})
                IssueKillSelf({self.antiteleportEmitterTable[k]})
            end
        end
    end,

    ---@param self BRB4309
    ResourceThread = function(self)
        local trash = self.Trash
        if not self.Dead then
            local energy = self.AIBrain:GetEconomyStored('Energy')

            -- Check to see if the player has enough mass / energy
            if  energy <= 10 then
                self:SetScriptBit('RULEUTC_ShieldToggle', false)
                TrashBagAdd(trash, ForkThread(self.ResourceThread2, self))
            else
                TrashBagAdd(trash, ForkThread(self.EconomyWaitUnit, self))
            end
        end
    end,

    ---@param self BRB4309
    EconomyWaitUnit = function(self)
        local trash = self.Trash
        if not self.Dead then
        WaitSeconds(2)
            if not self.Dead then
                TrashBagAdd(trash, ForkThread(self.ResourceThread, self))
            end
        end
    end,

    ---@param self BRB4309
    ResourceThread2 = function(self)
        local trash = self.Trash
        if not self.Dead then
            local energy = self.AIBrain:GetEconomyStored('Energy')

            -- Check to see if the player has enough mass / energy
            if  energy >= 3000 then
                self:SetScriptBit('RULEUTC_ShieldToggle', true)
                TrashBagAdd(trash, ForkThread(self.ResourceThread, self))
            else
                TrashBagAdd(trash, ForkThread(self.EconomyWaitUnit2, self))
            end
        end
    end,

    ---@param self BRB4309
    EconomyWaitUnit2 = function(self)
        local trash = self.Trash
        if not self.Dead then
        WaitSeconds(2)
            if not self.Dead then
                TrashBagAdd(trash, ForkThread(self.ResourceThread2, self))
            end
        end
    end,
}

TypeClass = BRB4309
