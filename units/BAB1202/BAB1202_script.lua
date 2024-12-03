-----------------------------------------------------------------
-- File     :  /cdimage/units/UAB1102/UAB1102_script.lua
-- Author(s):  Jessica St. Croix, John Comes
-- Summary  :  Aeon Hydrocarbon Power Plant Script
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local AEnergyCreationUnit = import('/lua/aeonunits.lua').AEnergyCreationUnit

-- upvalue for performance
local TrashBagAdd = TrashBag.Add

---@class BAB1202 : AEnergyCreationUnit
BAB1202 = Class(AEnergyCreationUnit) {
    AirEffects = {'/effects/emitters/hydrocarbon_smoke_01_emit.bp',},
    AirEffectsBones = {'Extension02'},
    WaterEffects = {'/effects/emitters/underwater_idle_bubbles_01_emit.bp',},
    WaterEffectsBones = {'Extension02'},

    ---@param self BAB1202
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        AEnergyCreationUnit.OnStopBeingBuilt(self,builder,layer)
        local effects = {}
        local bones = {}
        local scale = 0.75
        local trash = self.Trash

        if self:GetCurrentLayer() == 'Land' then
            effects = self.AirEffects
            bones = self.AirEffectsBones
        elseif self:GetCurrentLayer() == 'Seabed' then
            effects = self.WaterEffects
            bones = self.WaterEffectsBones
            scale = 3
        end
        for _, values in effects do
            for _, valuesbones in bones do
                TrashBagAdd(trash, CreateAttachedEmitter(self, valuesbones, self.Army, values):ScaleEmitter(scale):OffsetEmitter(0,-0.2,1))
            end
        end
    end,
}

TypeClass = BAB1202
