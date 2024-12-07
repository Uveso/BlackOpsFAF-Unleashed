-----------------------------------------------------------------
-- File     :  /cdimage/units/URB1106/URB1106_script.lua
-- Author(s):  Jessica St. Croix, David Tomandl
-- Summary  :  Cybran Mass Storage
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local CMassStorageUnit = import('/lua/cybranunits.lua').CMassStorageUnit

local TrashBagAdd = TrashBag.Add

---@class BRB1106 : CMassStorageUnit
BRB1106 = Class(CMassStorageUnit) {

    ---@param self BRB1106
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        CMassStorageUnit.OnStopBeingBuilt(self,builder,layer)
        local trash = self.Trash
        local bp = self.Blueprint

        TrashBagAdd(trash , self:ForkThread(self.AnimThread, self))

        if bp.Audio.Activate then
            self:PlaySound(bp.Audio.Activate)
        end
    end,

    ---@param self BRB1106
    AnimThread = function(self)
        CreateStorageManip(self, 'Mass', 'MASS', 0, 0, 0, 0, 0, .55)
        CreateStorageManip(self, 'Energy', 'ENERGY', 0, 0, 0, 0, 0, 0.6)
    end,
}

TypeClass = BRB1106
