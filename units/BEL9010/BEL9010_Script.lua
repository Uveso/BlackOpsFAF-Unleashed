-----------------------------------------------------------------
-- File     :  /cdimage/units/XSC9002/XSC9002_script.lua
-- Author   :  Greg Kohne
-- Summary  :  Jamming Crystal
--
-- Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local SLandUnit = import('/lua/seraphimunits.lua').SLandUnit

--@class BEL9010 : SLandUnit
BEL9010 = Class(SLandUnit) {

    ---@param self BEL9010
    OnCreate = function(self)
        SLandUnit.OnCreate(self)
    end,
}

TypeClass = BEL9010
