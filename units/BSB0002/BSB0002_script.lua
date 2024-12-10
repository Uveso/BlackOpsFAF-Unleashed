-----------------------------------------------------------------
-- File     :  /cdimage/units/XSB0002/XSB0002_script.lua
-- Author(s):  John Comes, David Tomandl
-- Summary  :  UEF Wall Piece Script
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local SLandFactoryUnit = import('/lua/seraphimunits.lua').SLandFactoryUnit

---@class BSB0002 : SLandFactoryUnit
BSB0002 = Class(SLandFactoryUnit) {
    Parent = nil,

    ---@param self BSB0002
    ---@param built Unit
    ---@param order string
    OnStartBuild = function(self, built, order)
        SLandFactoryUnit.OnStartBuild(self, built, order)

        local bp = built:GetBlueprint()
        local massDrain = bp.Economy.BuildCostMass
        local energyDrain = bp.Economy.BuildCostEnergy

        -- Set resource drain to amounts derived from unit blueprints
        self:SetConsumptionPerSecondMass(massDrain / 100)
        self:SetConsumptionPerSecondEnergy(energyDrain * 3)
    end,

    ---@param self BSB0002
    ---@param built Unit
    OnStopBuild = function(self, built)
        SLandFactoryUnit.OnStopBuild(self, built)

        built:SetVeterancy(5)
    end,

    -- Make this unit invulnerable
    OnDamage = function()
    end,
}

TypeClass = BSB0002
