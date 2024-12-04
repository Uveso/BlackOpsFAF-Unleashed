-----------------------------------------------------------------
-- File     :  /units/BEB0005/BEB0005_script.lua
-- Author(s):  Dru Staltman
-- Summary  :  UEF Engineering tower
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local TPodTowerUnit = import('/lua/terranunits.lua').TPodTowerUnit

---@class BEB0005 : TPodTowerUnit
BEB0005 = Class(TPodTowerUnit) {

    Parent = nil,

    ---@param self BEB0005
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        TPodTowerUnit.OnStopBeingBuilt(self,builder,layer)
        if not self.OpenAnim then
            self.OpenAnim = CreateAnimator(self)
            self.Trash:Add(self.OpenAnim)
        end
        self.OpenAnim:PlayAnim(self.Blueprint.Display.AnimationOpen, false):SetRate(0.4)
    end,

    ---@param self BEB0005
    ---@param parent Unit
    ---@param droneName string
    SetParent = function(self, parent, droneName)
        self.Parent = parent
        self.Drone = droneName
    end,

    -- Make this unit invulnerable
    OnDamage = function()
    end,
}

TypeClass = BEB0005
