-----------------------------------------------------------------
-- File     :  /cdimage/units/XSB1106/XSB1106_script.lua
-- Author(s):  Dru Staltman
-- Summary  :  Seraphim Mass Storage
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local SMassStorageUnit = import('/lua/seraphimunits.lua').SMassStorageUnit

---@class BSB1106 : SMassStorageUnit
BSB1106 = Class(SMassStorageUnit) {

    ---@param self BSB1106
    ---@param builder Unit
    ---@param layer string
    OnStopBeingBuilt = function(self, builder, layer)
        SMassStorageUnit.OnStopBeingBuilt(self, builder, layer)
        self.Trash:Add(CreateStorageManip(self, 'Mass', 'MASS', 0, 0, 0, 0, 0, .41))
        self.Trash:Add(CreateStorageManip(self, 'energy', 'ENERGY', 0, 0, 0, 0, 0, .6))
    end,
}

TypeClass = BSB1106
