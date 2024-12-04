-----------------------------------------------------------------
-- File     :  /cdimage/units/BAB4209/BAB4209_script.lua
-- Author(s):  John Comes, Dave Tomandl, Jessica St. Croix
-- Summary  :  Aeon Power Generator Script
-- Copyright © 1205 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local AStructureUnit = import('/lua/aeonunits.lua').AStructureUnit

-- upvalue for performance
local TrashBagAdd = TrashBag.Add

---@class BAB4209 : AStructureUnit
BAB4209 = Class(AStructureUnit) {

    AntiTeleportEffects = {
        '/effects/emitters/aeon_gate_02_emit.bp',
        '/effects/emitters/aeon_gate_03_emit.bp',
    },

    AmbientEffects = {
        '/effects/emitters/aeon_shield_generator_t3_04_emit.bp',
    },

    ---@param self BAB4209
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        AStructureUnit.OnStopBeingBuilt(self,builder,layer)
        local trash = self.Trash

        self:SetScriptBit('RULEUTC_ShieldToggle', true)

        -- only used to show anti-teleport range
        self:DisableIntel('CloakField')

        self.AmbientEffectsBag = {}
        self.antiteleportEmitterTable = {}
        TrashBagAdd(trash, ForkThread(self.ResourceThread, self))

        TrashBagAdd(trash, CreateRotator(self, 'Sphere', 'x', nil, 0, 15, 80 + Random(0, 20)))
        TrashBagAdd(trash, CreateRotator(self, 'Sphere', 'y', nil, 0, 15, 80 + Random(0, 20)))
        TrashBagAdd(trash, CreateRotator(self, 'Sphere', 'z', nil, 0, 15, 80 + Random(0, 20)))

    end,

    ---@param self BAB4209
    ---@param bit integer
    OnScriptBitSet = function(self, bit)
        AStructureUnit.OnScriptBitSet(self, bit)
        local trash = self.Trash

        if bit == 0 then
            TrashBagAdd(trash, ForkThread(self.antiteleportEmitter, self))
            TrashBagAdd(trash, ForkThread(self.AntiteleportEffects, self))
            self:SetMaintenanceConsumptionActive()
        end
    end,

    ---@param self BAB4209
    AntiteleportEffects = function(self)
        if self.AmbientEffectsBag then
            for _, v in self.AmbientEffectsBag do
                v:Destroy()
            end
            self.AmbientEffectsBag = {}
        end
        for _, v in self.AmbientEffects do
            table.insert(self.AmbientEffectsBag, CreateAttachedEmitter(self, 'BAB4209', self.Army, v):ScaleEmitter(0.4))
        end
    end,

    ---@param self BAB4209
    ---@param bit number
    OnScriptBitClear = function(self, bit)
        AStructureUnit.OnScriptBitClear(self, bit)
        local trash = self.Trash

        if bit == 0 then
            TrashBagAdd(trash, ForkThread(self.KillantiteleportEmitter, self))
            self:SetMaintenanceConsumptionInactive()
            if self.AmbientEffectsBag then
                for _, v in self.AmbientEffectsBag do
                    v:Destroy()
                end
                self.AmbientEffectsBag = {}
            end
        end
    end,

    ---@param self BAB4209
    antiteleportEmitter = function(self)
        local trash = self.Trash
        -- Are we dead yet, if not then wait 0.5 second
        if not self.Dead then
            WaitSeconds(0.5)
            -- Are we dead yet, if not spawn antiteleportEmitter
            if not self.Dead then

                -- Gets the platforms current orientation
                local platOrient = self:GetOrientation()

                -- Gets the current position of the platform in the game world
                local location = self:GetPosition('BAB4209')

                -- Creates our antiteleportEmitter over the platform with a ranomly generated Orientation
                local antiteleportEmitter = CreateUnit('bab0004', self.Army, location[1], location[2], location[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Land')

                -- Adds the newly created antiteleportEmitter to the parent platforms antiteleportEmitter table
                table.insert (self.antiteleportEmitterTable, antiteleportEmitter)

                -- Sets the platform unit as the antiteleportEmitter parent
                antiteleportEmitter:SetParent(self, 'bab4209')
                antiteleportEmitter:SetCreator(self)
                TrashBagAdd(trash, antiteleportEmitter)
            end
        end
    end,

    ---@param self BAB4209
    ---@param instigator Unit
    ---@param type string
    ---@param overkillRatio number
    KillantiteleportEmitter = function(self, instigator, type, overkillRatio)
        -- Small bit of table manipulation to sort thru all of the avalible rebulder bots and remove them after the platform is dead
        if table.getn({self.antiteleportEmitterTable}) > 0 then
            for k, _ in self.antiteleportEmitterTable do
                IssueClearCommands({self.antiteleportEmitterTable[k]})
                IssueKillSelf({self.antiteleportEmitterTable[k]})
            end
        end
    end,

    ---@param self BAB4209
    ResourceThread = function(self)
        local trash = self.Trash
        if not self.Dead then
            local energy = self.AIBrain.GetEconomyStored('Energy')
            if  energy <= 10 then
                self:SetScriptBit('RULEUTC_ShieldToggle', false)
                TrashBagAdd(trash, ForkThread(self.ResourceThread2, self))
            else
                TrashBagAdd(trash, ForkThread(self.EconomyWaitUnit, self))
            end
        end
    end,

    ---@param self BAB4209
    EconomyWaitUnit = function(self)
        local trash = self.Trash

        if not self.Dead then
        WaitSeconds(2)
            if not self.Dead then
                TrashBagAdd(trash, ForkThread(self.ResourceThread, self))
            end
        end
    end,

    ---@param self BAB4209
    ResourceThread2 = function(self)
        local trash = self.Trash

        if not self.Dead then
            local energy = self.AIBrain.GetEconomyStored('Energy')
            if  energy >= 3000 then
                self:SetScriptBit('RULEUTC_ShieldToggle', true)
                TrashBagAdd(trash, ForkThread(self.ResourceThread, self))
            else
                TrashBagAdd(trash, ForkThread(self.EconomyWaitUnit2, self))
            end
        end
    end,

    ---@param self BAB4209
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

TypeClass = BAB4209
