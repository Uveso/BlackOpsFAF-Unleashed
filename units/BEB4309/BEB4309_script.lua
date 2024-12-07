-----------------------------------------------------------------
-- File     :  /cdimage/units/XEB4309/XEB4309_script.lua
-- Author(s):  David Tomandl, Jessica St. Croix
-- Summary  :  UEF Radar Jammer Script
-- Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit
local TrashBadAdd = TrashBag.Add

---@class BEB4309 : TStructureUnit
BEB4309 = Class(TStructureUnit) {
    AntiTeleport = {
        '/effects/emitters/seraphim_shield_generator_t3_03_emit.bp',
        '/effects/emitters/seraphim_shield_generator_t2_03_emit.bp',
    },

    ---@param self BEB4309
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        TStructureUnit.OnStopBeingBuilt(self,builder,layer)
        local trash = self.Trash

        self:SetScriptBit('RULEUTC_ShieldToggle', true)
        -- only used to show anti-teleport range
        self:DisableIntel('CloakField')
        self.antiteleportEmitterTable = {}
        self.AntiTeleportBag = {}

        TrashBadAdd(trash, ForkThread(self.ResourceThread, self))
    end,

    ---@param self BEB4309
    ---@param bit number
    OnScriptBitSet = function(self, bit)
        TStructureUnit.OnScriptBitSet(self, bit)
        local trash = self.Trash

        if bit == 0 then
            TrashBadAdd(trash, ForkThread(self.antiteleportEmitter, self))
            TrashBadAdd(trash, ForkThread(self.AntiteleportEffects, self))
            self:SetMaintenanceConsumptionActive()

            if not self.Rotator1 then
                self.Rotator1 = CreateRotator(self, 'Spinner_Upper', 'y')
                TrashBadAdd(trash, self.Rotator1)
            end

            self.Rotator1:SetTargetSpeed(-70)
            self.Rotator1:SetAccel(30)

            if not self.Rotator2 then
                self.Rotator2 = CreateRotator(self, 'Spinner_middle', 'y')
                TrashBadAdd(trash, self.Rotator2)
            end

            self.Rotator2:SetTargetSpeed(500)
            self.Rotator2:SetAccel(100)

            if not self.Rotator3 then
                self.Rotator3 = CreateRotator(self, 'Spinner_lower', 'y')
                TrashBadAdd(trash, self.Rotator3)
            end

            self.Rotator3:SetTargetSpeed(-70)
            self.Rotator3:SetAccel(30)
        end
    end,

    ---@param self BEB4309
    AntiteleportEffects = function(self)
        local army = self.Army

        if self.AntiTeleportBag then
            for _, v in self.AntiTeleportBag do
                v:Destroy()
            end
            self.AntiTeleportBag = {}
        end
        for _, v in self.AntiTeleport do
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect01', army, v):ScaleEmitter(0.1))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect01', army, v):ScaleEmitter(0.1):OffsetEmitter(0, -0.5, 0))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect01', army, v):ScaleEmitter(0.1):OffsetEmitter(0, 0.5, 0))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect02', army, v):ScaleEmitter(0.1))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect02', army, v):ScaleEmitter(0.1):OffsetEmitter(0, -0.5, 0))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect02', army, v):ScaleEmitter(0.1):OffsetEmitter(0, 0.5, 0))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect03', army, v):ScaleEmitter(0.1))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect03', army, v):ScaleEmitter(0.1):OffsetEmitter(0, 0.5, 0))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect04', army, v):ScaleEmitter(0.1))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect04', army, v):ScaleEmitter(0.1):OffsetEmitter(0, -0.5, 0))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect05', army, v):ScaleEmitter(0.1))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect05', army, v):ScaleEmitter(0.1):OffsetEmitter(0, 0.5, 0))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect06', army, v):ScaleEmitter(0.1))
            table.insert(self.AntiTeleportBag, CreateAttachedEmitter(self, 'Effect06', army, v):ScaleEmitter(0.1):OffsetEmitter(0, -0.5, 0))
        end
    end,

    ---@param self BEB4309
    ---@param bit number
    OnScriptBitClear = function(self, bit)
        TStructureUnit.OnScriptBitClear(self, bit)
        local trash = self.Trash

        if bit == 0 then
            TrashBadAdd(trash, ForkThread(self.KillantiteleportEmitter, self))
            self:SetMaintenanceConsumptionInactive()

            if not self.Rotator1 then
                self.Rotator1 = CreateRotator(self, 'Spinner_Upper', 'y')
                TrashBadAdd(trash, self.Rotator1)
            end

            self.Rotator1:SetTargetSpeed(0)
            self.Rotator1:SetAccel(30)

            if not self.Rotator2 then
                self.Rotator2 = CreateRotator(self, 'Spinner_middle', 'y')
                TrashBadAdd(trash, self.Rotator2)
            end

            self.Rotator2:SetTargetSpeed(0)
            self.Rotator2:SetAccel(100)

            if not self.Rotator3 then
                self.Rotator3 = CreateRotator(self, 'Spinner_lower', 'y')
                TrashBadAdd(trash, self.Rotator3)
            end

            self.Rotator3:SetTargetSpeed(0)
            self.Rotator3:SetAccel(30)

            if self.AntiTeleportBag then
                for _, v in self.AntiTeleportBag do
                    v:Destroy()
                end
                self.AntiTeleportBag = {}
            end
        end
    end,

    ---@param self BEB4309
    antiteleportEmitter = function(self)
        local trash = self.Trash

        if not self.Dead then
            WaitSeconds(0.5)
            if not self.Dead then
                -- Gets the platforms current orientation
                local platOrient = self:GetOrientation()

                -- Gets the current position of the platform in the game world
                local location = self:GetPosition('XEB4309')

                -- Creates our antiteleportEmitter over the platform with a ranomly generated Orientation
                local antiteleportEmitter = CreateUnit('beb0003', self.Army, location[1], location[2], location[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Land')

                -- Adds the newly created antiteleportEmitter to the parent platforms antiteleportEmitter table
                table.insert (self.antiteleportEmitterTable, antiteleportEmitter)

                -- Sets the platform unit as the antiteleportEmitter parent
                antiteleportEmitter:SetParent(self, 'beb4309')
                antiteleportEmitter:SetCreator(self)
                TrashBadAdd(trash, antiteleportEmitter)
            end
        end
    end,

    ---@param self BEB4309
    KillantiteleportEmitter = function(self)
        -- Small bit of table manipulation to sort thru all of the avalible rebulder bots and remove them after the platform is dead
        if table.getn({self.antiteleportEmitterTable}) > 0 then
            for k, _ in self.antiteleportEmitterTable do
                IssueClearCommands({self.antiteleportEmitterTable[k]})
                IssueKillSelf({self.antiteleportEmitterTable[k]})
            end
        end
    end,

    ---@param self BEB4309
    ResourceThread = function(self)
        local trash = self.Trash
        local aibrain = self.AIBrain

        if not self.Dead then
            local energy = aibrain:GetEconomyStored('Energy')

            -- Check to see if the player has enough mass / energy
            if  energy <= 10 then
                self:SetScriptBit('RULEUTC_ShieldToggle', false)
                TrashBadAdd(trash, ForkThread(self.ResourceThread2, self))
            else
                -- If the above conditions are not met we check again
                TrashBadAdd(trash, ForkThread(self.EconomyWaitUnit, self))
            end
        end
    end,

    ---@param self BEB4309
    EconomyWaitUnit = function(self)
        local trash = self.Trash

        if not self.Dead then
        WaitSeconds(2)
            if not self.Dead then
                TrashBadAdd(trash, ForkThread(self.ResourceThread, self))
            end
        end
    end,

    ---@param self BEB4309
    ResourceThread2 = function(self)
        local trash = self.Trash
        local aibrain = self.AIBrain

        if not self.Dead then
            local energy = aibrain:GetEconomyStored('Energy')

            -- Check to see if the player has enough mass / energy
            if  energy >= 3000 then
                self:SetScriptBit('RULEUTC_ShieldToggle', true)
                TrashBadAdd(trash, ForkThread(self.ResourceThread, self))
            else
                -- If the above conditions are not met we kill this unit
                TrashBadAdd(trash, ForkThread(self.EconomyWaitUnit2, self))
            end
        end
    end,

    ---@param self BEB4309
    EconomyWaitUnit2 = function(self)
        local trash = self.Trash
        if not self.Dead then
        WaitSeconds(2)
            if not self.Dead then
                TrashBadAdd(trash, ForkThread(self.ResourceThread2, self))
            end
        end
    end,
}

TypeClass = BEB4309
