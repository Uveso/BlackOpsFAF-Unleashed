-----------------------------------------------------------------
-- File     :  /cdimage/units/UEB1106/UEB1106_script.lua
-- Author(s):  Jessica St. Croix
-- Summary  :  UEF Mass Storage
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local TMassStorageUnit = import('/lua/terranunits.lua').TMassStorageUnit

local TrashBagAdd = TrashBag.Add

---@class BEB1106 : TMassStorageUnit 
BEB1106 = Class(TMassStorageUnit) {
    OnStopBeingBuilt = function(self,builder,layer)
        TMassStorageUnit.OnStopBeingBuilt(self,builder,layer)
        local trash = self.Trash
        TrashBagAdd(trash, CreateStorageManip(self, 'Mass', 'MASS', 0, 0, 0, 0, 0, 0.6))
        TrashBagAdd(trash, CreateStorageManip(self, 'Energy', 'ENERGY', 0, 0, 0, 0, 0, 0.7))
    end,
}

TypeClass = BEB1106
