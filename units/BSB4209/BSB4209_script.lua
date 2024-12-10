-----------------------------------------------------------------
-- File     :  /data/units/BSB4209/BSB4209_script.lua
-- Author(s):  Jessica St. Croix
-- Summary  :  Seraphim T3 Radar Tower Script
-- Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit

---@class BSB4209 : SStructureUnit
BSB4209 = Class(SStructureUnit) {

    AntiTeleport = {
       '/effects/emitters/op_seraphim_quantum_jammer_tower_emit.bp',
    },

    ---@param self BSB4209
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        SStructureUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetScriptBit('RULEUTC_ShieldToggle', true)
        -- only used to show anti-teleport range
        self:DisableIntel('CloakField')
        self.antiteleportEmitterTable = {}
        self.AntiTeleportBag = {}
        self:ForkThread(self.ResourceThread)
    end,

    ---@param self BSB4209
    ---@param bit number
    OnScriptBitSet = function(self, bit)
        SStructureUnit.OnScriptBitSet(self, bit)
        if bit == 0 then
        self.FieldActive = true
        self:ForkThread(self.antiteleportEmitter)
        self:ForkThread(self.AntiteleportEffects)
        self:SetMaintenanceConsumptionActive()

            if(not self.Rotator1) then
                self.Rotator1 = CreateRotator(self, 'Array01', 'y')
                self.Trash:Add(self.Rotator1)
            end
            self.Rotator1:SetTargetSpeed(-70)
            self.Rotator1:SetAccel(30)
        end
    end,

    ---@param self BSB4209
    AntiteleportEffects = function(self)
        if self.AntiTeleportBag then
            for k, v in self.AntiTeleportBag do
                v:Destroy()
            end
            self.AntiTeleportBag = {}
        end
        for k, v in self.AntiTeleport do
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Light01', self:GetArmy(), v):ScaleEmitter(0.5))
        end
    end,

    ---@param self BSB4209
    ---@param bit number
    OnScriptBitClear = function(self, bit)
        SStructureUnit.OnScriptBitClear(self, bit)
        if bit == 0 then
        self.FieldActive = false
        self:ForkThread(self.KillantiteleportEmitter)
        self:SetMaintenanceConsumptionInactive()

            if(not self.Rotator1) then
                self.Rotator1 = CreateRotator(self, 'Array01', 'y')
                self.Trash:Add(self.Rotator1)
            end
            self.Rotator1:SetTargetSpeed(0)
            self.Rotator1:SetAccel(30)

            if self.AntiTeleportBag then
                for k, v in self.AntiTeleportBag do
                    v:Destroy()
                end
                self.AntiTeleportBag = {}
            end
        end
    end,

    ---@param self BSB4209
    antiteleportEmitter = function(self)
        if not self.Dead then
            WaitSeconds(0.5)
            if not self.Dead then
                local platOrient = self:GetOrientation()
                -- Gets the current position of the platform in the game world
                local location = self:GetPosition('BSB4209')

                -- Creates our antiteleportEmitter over the platform with a ranomly generated Orientation
                local antiteleportEmitter = CreateUnit('bsb0006', self:GetArmy(), location[1], location[2], location[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Land')

                -- Adds the newly created antiteleportEmitter to the parent platforms antiteleportEmitter table
                table.insert (self.antiteleportEmitterTable, antiteleportEmitter)

                -- Sets the platform unit as the antiteleportEmitter parent
                antiteleportEmitter:SetParent(self, 'bsb4209')
                antiteleportEmitter:SetCreator(self)
                self.Trash:Add(antiteleportEmitter)
            end
        end
    end,

    ---@param self BSB4209
    KillantiteleportEmitter = function(self)
        -- Small bit of table manipulation to sort thru all of the avalible rebulder bots and remove them after the platform is dead
        if table.getn({self.antiteleportEmitterTable}) > 0 then
            for k, v in self.antiteleportEmitterTable do
                IssueClearCommands({self.antiteleportEmitterTable[k]})
                IssueKillSelf({self.antiteleportEmitterTable[k]})
            end
        end
    end,

    ---@param self BSB4209
    ResourceThread = function(self)
        if not self.Dead then
            local energy = self:GetAIBrain():GetEconomyStored('Energy')
            if  energy <= 10 then
                self:SetScriptBit('RULEUTC_ShieldToggle', false)
                self:ForkThread(self.ResourceThread2)

            else
                -- If the above conditions are not met we check again
                self:ForkThread(self.EconomyWaitUnit)

            end
        end
    end,

    ---@param self BSB4209
    EconomyWaitUnit = function(self)
        if not self.Dead then
        WaitSeconds(2)
            if not self.Dead then
                self:ForkThread(self.ResourceThread)
            end
        end
    end,

    ---@param self BSB4209
    ResourceThread2 = function(self)
        if not self.Dead then
            local energy = self:GetAIBrain():GetEconomyStored('Energy')

            -- Check to see if the player has enough mass / energy
            if  energy >= 3000 then
                self:SetScriptBit('RULEUTC_ShieldToggle', true)
                self:ForkThread(self.ResourceThread)
            else
                self:ForkThread(self.EconomyWaitUnit2)
            end
        end
    end,

    ---@param self BSB4209
    EconomyWaitUnit2 = function(self)
        if not self.Dead then
        WaitSeconds(2)
            if not self.Dead then
                self:ForkThread(self.ResourceThread2)
            end
        end
    end,
}

TypeClass = BSB4209
