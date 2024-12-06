-----------------------------------------------------------------
-- File     :  /cdimage/units/XRB0005/XRB0005_script.lua
-- Author(s):  John Comes, David Tomandl
-- Summary  :  UEF Wall Piece Script
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local CStructureUnit = import('/lua/cybranunits.lua').CStructureUnit
local CybranWeaponsFile2 = import('/lua/BlackOpsWeapons.lua')
local MGAALaserWeapon = CybranWeaponsFile2.MGAALaserWeapon

---@class BRB0005 : CStructureUnit
BRB0005 = Class(CStructureUnit) {
    Weapons = {
        AAGun01 = Class(MGAALaserWeapon) {},
    },

    -- Sets up parent call backs between drone and parent
    Parent = nil,

    ---@param self BRB0005
    ---@param parent Unit
    ---@param droneName string
    SetParent = function(self, parent, droneName)
        self.Parent = parent
        self.Drone = droneName
    end,

    ---@param self BRB0005
    OnCreate = function(self)
        CStructureUnit.OnCreate(self)
        self:HideBone('XSB0001', true)
    end,

    -- Make this unit invulnerable
    OnDamage = function()
    end,

    ---@param self BRB0005
    DeathThread = function(self)
        self:Destroy()
    end,
}

TypeClass = BRB0005
