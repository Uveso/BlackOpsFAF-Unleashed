local AirDroneUnit = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsunits.lua').AirDroneUnit
local TSAMLauncher = import('/lua/terranweapons.lua').TSAMLauncher

local TrashBagAdd = TrashBag.Add

-- Goliath Drone
---@class BEA0006 : AirDroneUnit
BEA0005 = Class(AirDroneUnit) {

    Weapons = {
       Cannon01 = Class(TSAMLauncher) {},
       Cannon02 = Class(TSAMLauncher) {},
    },

    ---@param self BEA0005
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self, builder, layer)
        AirDroneUnit.OnStopBeingBuilt(self, builder, layer)
        local trash = self.Trash
        self.EngineManipulators = {}
        -- Create the engine thrust manipulators
        self.EngineRotateBones = {'Engines1'}
        for _, value in self.EngineRotateBones do
            table.insert(self.EngineManipulators, CreateThrustController(self, "thruster", value))
        end
        -- Set up the thursting arcs for the engines
        for _,value in self.EngineManipulators do
            value:SetThrustingParam(-0.0, 0.0, -0.25, 0.25, -0.1, 0.1, 1.0, 0.25)
        end
        for _, v in self.EngineManipulators do
            TrashBagAdd(trash,v)
        end
    end,

}

TypeClass = BEA0005
