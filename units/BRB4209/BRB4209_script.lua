-----------------------------------------------------------------
-- File     :  /cdimage/units/XRB4309/XRB4309_script.lua
-- Author(s):  David Tomandl, Greg Kohne
-- Summary  :  Cybran Shield Generator lvl 5 Script
-- Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local CStructureUnit = import('/lua/cybranunits.lua').CStructureUnit
local TrashBagAdd = TrashBag.Add

---@class BRB4209 : CStructureUnit
BRB4209 = Class(CStructureUnit) {

    ---@param self BRB4209
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        CStructureUnit.OnStopBeingBuilt(self,builder,layer)
        local trash = self.Trash

        self:SetScriptBit('RULEUTC_ShieldToggle', true)
        -- only used to show anti-teleport range
        self:DisableIntel('CloakField')
        self.antiteleportEmitterTable = {}
        TrashBagAdd(trash , self:ForkThread(self.ResourceThread, self))
    end,


    ---@param self BRB4209
    ---@param bit number
    OnScriptBitSet = function(self, bit)
        CStructureUnit.OnScriptBitSet(self, bit)
        local trash = self.Trash

        if bit == 0 then
            TrashBagAdd(trash , self:ForkThread(self.antiteleportEmitter, self))
            self:SetMaintenanceConsumptionActive()
        end
    end,

    ---@param self BRB4209
    ---@param bit number
    OnScriptBitClear = function(self, bit)
        CStructureUnit.OnScriptBitClear(self, bit)
        local trash = self.Trash

        if bit == 0 then
            TrashBagAdd(trash , self:ForkThread(self.KillantiteleportEmitter, self))
            self:SetMaintenanceConsumptionInactive()
        end
    end,

    ---@param self BRB4209
    antiteleportEmitter = function(self)
        local trash = self.Trash
        if not self.Dead then
            WaitSeconds(0.5)
            if not self.Dead then
                -- Gets the platforms current orientation
                local platOrient = self:GetOrientation()

                -- Gets the current position of the platform in the game world
                local location = self:GetPosition('Shaft')

                -- Creates our antiteleportEmitter over the platform with a ranomly generated Orientation
                local antiteleportEmitter = CreateUnit('brb0007', self.Army, location[1], location[2], location[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Land')

                -- Adds the newly created antiteleportEmitter to the parent platforms antiteleportEmitter table
                table.insert (self.antiteleportEmitterTable, antiteleportEmitter)

                antiteleportEmitter:AttachTo(self, 'Shaft')

                -- Sets the platform unit as the antiteleportEmitter parent
                antiteleportEmitter:SetParent(self, 'brb4209')
                antiteleportEmitter:SetCreator(self)
                TrashBagAdd(trash, antiteleportEmitter)
            end
        end
    end,

    ---@param self BRB4209
    KillantiteleportEmitter = function(self)
        -- Small bit of table manipulation to sort thru all of the avalible rebulder bots and remove them after the platform is dead
        if table.getn({self.antiteleportEmitterTable}) > 0 then
            for k, _ in self.antiteleportEmitterTable do
                IssueClearCommands({self.antiteleportEmitterTable[k]})
                IssueKillSelf({self.antiteleportEmitterTable[k]})
            end
        end
    end,

    ---@param self BRB4209
    ResourceThread = function(self)
        local trash = self.Trash

        if not self.Dead then
            local energy = self.AIBrain:GetEconomyStored('Energy')

            -- Check to see if the player has enough mass / energy
            if  energy <= 10 then
                self:SetScriptBit('RULEUTC_ShieldToggle', false)
                TrashBagAdd(trash , self:ForkThread(self.ResourceThread2, self))
            else
                TrashBagAdd(trash , self:ForkThread(self.EconomyWaitUnit, self))
            end
        end
    end,

    ---@param self BRB4209
    EconomyWaitUnit = function(self)
        local trash = self.Trash
        if not self.Dead then
        WaitSeconds(2)
            if not self.Dead then
                TrashBagAdd(trash , ForkThread(self.ResourceThread, self))
            end
        end
    end,

    ---@param self BRB4209
    ResourceThread2 = function(self)
        local trash = self.Trash
        if not self.Dead then
            local energy = self.AIBrain:GetEconomyStored('Energy')

            -- Check to see if the player has enough mass / energy
            if  energy >= 3000 then
                self:SetScriptBit('RULEUTC_ShieldToggle', true)
                TrashBagAdd(trash , self:ForkThread(self.ResourceThread, self))
            else
                TrashBagAdd(trash , ForkThread(self.EconomyWaitUnit2, self))
            end
        end
    end,

    ---@param self BRB4209
    EconomyWaitUnit2 = function(self)
        local trash = self.Trash
        if not self.Dead then
        WaitSeconds(2)
            if not self.Dead then
                TrashBagAdd(trash , ForkThread(self.ResourceThread2, self))
            end
        end
    end,
}

TypeClass = BRB4209
