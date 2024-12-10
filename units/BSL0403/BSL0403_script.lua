--****************************************************************************
--**
-- File     :  /cdimage/units/XSL0403/XSL0403_script.lua
-- Author(s):  Drew Staltman, Jessica St. Croix, Gordon Duclos, Greg Kohne
--**
-- Summary  :  Seraphim Unidentified Residual Energy Signature Script
--**
-- Copyright � 2007 Gas Powered Games, Inc.  All rights reserved.
--****************************************************************************
local SEnergyBallUnit = import('/lua/seraphimunits.lua').SEnergyBallUnit
local SDFUnstablePhasonBeam = import('/lua/seraphimweapons.lua').SDFUnstablePhasonBeam
local EffectTemplate = import('/lua/EffectTemplates.lua')

---@class BSL0403 : SEnergyBallUnit
BSL0403 = Class(SEnergyBallUnit) {
    Weapons = {
        PhasonBeam = Class(SDFUnstablePhasonBeam) {},
    },

    ---@param self BSL0403
    OnCreate = function(self)
        SEnergyBallUnit.OnCreate(self)
        for k, v in EffectTemplate.OthuyAmbientEmanation do
            ------XSL0403
            CreateAttachedEmitter(self,'Outer_Tentaclebase', self:GetArmy(), v)
        end
        self:HideBone(0,true)
    end,
}
TypeClass = BSL0403