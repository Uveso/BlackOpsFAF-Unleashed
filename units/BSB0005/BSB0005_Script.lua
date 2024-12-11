-----------------------------------------------------------------
-- File     :  /cdimage/units/XSB0005/XSB0005_script.lua
-- Author(s):  John Comes, David Tomandl
-- Summary  :  UEF Wall Piece Script
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local SShieldLandUnit = import('/lua/seraphimunits.lua').SShieldLandUnit
local SeraLambdaFieldDestroyer = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsDefaultAntiProjectile.lua').SeraLambdaFieldDestroyer

---@class BSB0005 : SShieldLandUnit
BSB0005 = Class(SShieldLandUnit) {
    -- Sets up parent call backs between drone and parent
    Parent = nil,

    ---@param self BSB0005
    ---@param parent Unit
    ---@param droneName string
    SetParent = function(self, parent, droneName)
        self.Parent = parent
        self.Drone = droneName
    end,

    ---@param self BSB0005
    ---@param builder Unit
    ---@param layer Layer
    OnCreate = function(self, builder, layer)
        SShieldLandUnit.OnCreate(self, builder, layer)
        local bp = self:GetBlueprint().Defense.LambdaField
        local field = SeraLambdaFieldDestroyer {
            Owner = self,
            Radius = bp.Radius,
            AttachBone = bp.AttachBone,
            Probability = bp.Probability
        }
        self.Trash:Add(field)
        self.UnitComplete = true
    end,

    -- Make this unit invulnerable
    OnDamage = function()
    end,

    ---@param self BSB0005
    DeathThread = function(self)
        self:Destroy()
    end,
}

TypeClass = BSB0005
