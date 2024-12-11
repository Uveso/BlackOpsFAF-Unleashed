-----------------------------------------------------------------
-- File     :  /cdimage/units/URB4203/URB4203_script.lua
-- Author(s):  David Tomandl, Jessica St. Croix
-- Summary  :  Cybran Radar Jammer Script
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local CRadarJammerUnit = import('/lua/cybranunits.lua').CRadarJammerUnit
local TrashBadAdd = TrashBad.Add

---@class BRB4401 : CRadarJammerUnit
BRB4401 = Class(CRadarJammerUnit) {
    IntelEffects = {
        {
            Bones = {
                'Emitter',
            },
            Offset = {
                0,
                3,
                0,
            },
            Type = 'Jammer01',
        },
    },

    ---@param self BRB4401
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        CRadarJammerUnit.OnStopBeingBuilt(self,builder,layer)
        local trash = self.Trash
        self.AnimManip = CreateAnimator(self)
        TrashBadAdd(trash,self.AnimManip)
        self.DelayedCloakThread = TrashBadAdd(trash, ForkThread(self.CloakDelayed,self))
    end,

    ---@param self BRB4401
    CloakDelayed = function(self)
        if not self.Dead then
            WaitSeconds(2)
            self.IntelDisables['RadarStealth']['ToggleBit5'] = true
            self.IntelDisables['CloakField']['ToggleBit3'] = true
            self:EnableUnitIntel('ToggleBit5', 'RadarStealth')
            self:EnableUnitIntel('ToggleBit3', 'CloakField')
        end
        KillThread(self.DelayedCloakThread)
        self.DelayedCloakThread = nil
    end,

}

TypeClass = BRB4401
