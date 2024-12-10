-----------------------------------------------------------------
-- File     :  /cdimage/units/XSB2210/XSB2210_script.lua
-- Author(s):  John Comes, David Tomandl
-- Summary  :  UEF Wall Piece Script
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit
local SeraMineExplosion = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsWeapons.lua').SeraMineExplosion
local SeraMineDeathExplosion = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsWeapons.lua').SeraMineDeathExplosion

---@class BSB2210 : TStructureUnit
BSB2211 = Class(TStructureUnit) {
    Weapons = {
        DeathWeapon = Class(SeraMineDeathExplosion) {},
        Suicide = Class(SeraMineExplosion) {
            OnFire = function(self)
                self.unit:SetDeathWeaponEnabled(false)
                SeraMineExplosion.OnFire(self)
            end,
        },
    },

    ---@param self BSB2210
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        TStructureUnit.OnStopBeingBuilt(self,builder,layer)
        self.DelayedCloakThread = self:ForkThread(self.CloakDelayed)
    end,

    ---@param self BSB2210
    CloakDelayed = function(self)
        if not self.Dead then
            WaitSeconds(2)
            self.IntelDisables['RadarStealth']['ToggleBit5'] = true
            self.IntelDisables['Cloak']['ToggleBit3'] = true
            self:EnableUnitIntel('ToggleBit5', 'RadarStealth')
            self:EnableUnitIntel('ToggleBit3', 'Cloak')
        end
        KillThread(self.DelayedCloakThread)
        self.DelayedCloakThread = nil
    end,

    ---@param self BSB2210
    ---@param builder Unit
    ---@param layer Layer
    OnCreate = function(self,builder,layer)
        TStructureUnit.OnCreate(self,builder,layer)
        self:SetMaintenanceConsumptionActive()
        self:ForkThread(self.LifeThread)
    end,

    ---@param self BSB2210
    LifeThread = function(self)
        WaitSeconds(300)
        self:Destroy()
    end,
}

TypeClass = BSB2211
