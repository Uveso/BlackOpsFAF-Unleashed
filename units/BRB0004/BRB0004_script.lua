-----------------------------------------------------------------
-- File     :  /cdimage/units/XRB0304/XRB0304_script.lua
-- Author(s):  Dru Staltman, Gordon Duclos
-- Summary  :  Cybran Engineering tower
-- Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local CConstructionStructureUnit = import('/lua/cybranunits.lua').CConstructionStructureUnit
local TrashBagAdd = TrashBag.Add

---@class BRB0004 : CConstructionStructureUnit
BRB0004 = Class(CConstructionStructureUnit) {

    ---@param self BRB0004
    ---@param unitBeingBuilt Unit
    ---@param order string
    OnStartBuild = function(self, unitBeingBuilt, order)
        CConstructionStructureUnit.OnStartBuild(self, unitBeingBuilt, order)
        local trash = self.Trash

        if not self.AnimationManipulator then
            self.AnimationManipulator = CreateAnimator(self)
            TrashBagAdd(trash, self.AnimationManipulator)
        end
        self.AnimationManipulator:PlayAnim(self.Blueprint.Display.AnimationOpen, false):SetRate(1)
    end,

    ---@param self BRB0004
    ---@param unitBeingBuilt Unit
    OnStopBuild = function(self, unitBeingBuilt)
        CConstructionStructureUnit.OnStopBuild(self, unitBeingBuilt)
        local trash = self.Trash

        if not self.AnimationManipulator then
            self.AnimationManipulator = CreateAnimator(self)
            TrashBagAdd(trash, self.AnimationManipulator)
        end
        self.AnimationManipulator:SetRate(-1)
    end,
    Parent = nil,

    ---@param self BRB0004
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

TypeClass = BRB0004
