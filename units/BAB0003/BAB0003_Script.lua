-----------------------------------------------------------------
-- File     :  /cdimage/units/XSB0003/XSB0003_script.lua
-- Author(s):  John Comes, David Tomandl
-- Summary  :  UEF Wall Piece Script
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit

---@class BAB0003 : SStructureUnit
BAB0003 = Class(SStructureUnit) {
    -- Sets up parent call backs between drone and parent
    Parent = nil,

    ---@param self BAB0003
    ---@param parent Unit
    ---@param droneName string
    SetParent = function(self, parent, droneName)
        self.Parent = parent
        self.Drone = droneName
    end,

    ---@param self BAB0003
    ---@param builder Unit
    ---@param layer Layer
    OnCreate = function(self, builder, layer)
        SStructureUnit.OnCreate(self, builder, layer)
    end,

    -- Make this unit invulnerable
    OnDamage = function()
    end,

    ---@param self BAB0003
    ---@param instigator Unit
    ---@param type string
    ---@param overkillRatio number
    OnKilled = function(self, instigator, type, overkillRatio)
        SStructureUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    ---@param self BAB0003
    DeathThread = function(self)
        self:Destroy()
    end,
}

TypeClass = BAB0003
