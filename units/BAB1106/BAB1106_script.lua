-----------------------------------------------------------------
-- File     :  /cdimage/units/UAB1106/UAB1106_script.lua
-- Author(s):  Jessica St. Croix, David Tomandl, John Comes
-- Summary  :  Aeon Mass Storage
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local AMassStorageUnit = import('/lua/aeonunits.lua').AMassStorageUnit

-- upvalue for performance
local TrashBagAdd = TrashBag.Add

---@class BAB1106 : AMassStorageUnit
BAB1106 = Class(AMassStorageUnit) {

    ---@param self BAB1106
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        AMassStorageUnit.OnStopBeingBuilt(self,builder,layer)

        local trash = self.Trash

        TrashBagAdd(trash, CreateStorageManip(self, 'M_Storage_1', 'MASS', 0, 0, 0, 0, 0, .7))
        TrashBagAdd(trash, CreateStorageManip(self, 'M_Storage_2', 'MASS', 0, 0, 0, 0, 0, .41))
        TrashBagAdd(trash, CreateStorageManip(self, 'E_Storage', 'ENERGY', 0, 0, 0, 0, 0, .6))
        TrashBagAdd(trash, CreateRotator(self, 'Rotator', 'y', nil, 0, 15, 80))
    end,
}

TypeClass = BAB1106
