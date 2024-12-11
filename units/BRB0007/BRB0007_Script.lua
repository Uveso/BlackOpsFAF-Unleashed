-----------------------------------------------------------------
-- File     :  /cdimage/units/XSB0003/XSB0003_script.lua
-- Author(s):  John Comes, David Tomandl
-- Summary  :  UEF Wall Piece Script
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit

---@class BRB0003 : SStructureUnit
BRB0003 = Class(SStructureUnit) {
    -- Sets up parent call backs between drone and parent
    Parent = nil,

    ShieldEffects = {
       '/effects/emitters/cybran_shield_03_generator_02_emit.bp',
       '/effects/emitters/cybran_shield_05_generator_01_emit.bp',
       '/effects/emitters/cybran_shield_05_generator_02_emit.bp',
       '/effects/emitters/cybran_shield_05_generator_03_emit.bp',
       '/effects/emitters/cybran_shield_02_generator_02_emit.bp',
       '/effects/emitters/cybran_shield_02_generator_03_emit.bp',
       '/effects/emitters/cybran_shield_01_generator_02_emit.bp',
       '/effects/emitters/cybran_shield_04_generator_02_emit.bp',
       '/effects/emitters/cybran_shield_04_generator_03_emit.bp',
    },

    ---@param self BRB0003
    ---@param parent Unit
    ---@param droneName string
    SetParent = function(self, parent, droneName)
        self.Parent = parent
        self.Drone = droneName
    end,

    ---@param self BRB0003
    ---@param builder any
    ---@param layer Layer
    OnCreate = function(self, builder, layer)
        SStructureUnit.OnCreate(self, builder, layer)
        self.ShieldEffectsBag = {}
        if self.ShieldEffectsBag then
            for _, v in self.ShieldEffectsBag do
                v:Destroy()
            end
            self.ShieldEffectsBag = {}
        end
        for _, v in self.ShieldEffects do
            table.insert(self.ShieldEffectsBag, CreateAttachedEmitter(self, 'Effect01', self.Army, v):ScaleEmitter(0.4))
        end
    end,

    -- Make this unit invulnerable
    OnDamage = function()
    end,

    ---@param self BRB0003
    ---@param instigator Unit
    ---@param type string
    ---@param overkillRatio number
    OnKilled = function(self, instigator, type, overkillRatio)
        if self.ShieldEffctsBag then
            for _, v in self.ShieldEffectsBag do
                v:Destroy()
            end
        end
        SStructureUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    ---@param self BRB0003
    DeathThread = function(self)
        self:Destroy()
    end,
}

TypeClass = BRB0003
