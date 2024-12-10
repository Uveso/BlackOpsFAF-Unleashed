local SShieldLandUnit = import('/lua/seraphimunits.lua').SShieldLandUnit

---@class BSB0003 : SShieldLandUnit
BSB0003 = Class(SShieldLandUnit) {
    Parent = nil,

    ShieldEffects = {
       '/effects/emitters/op_seraphim_quantum_jammer_tower_emit.bp',
    },

    ---@param self BSB0003
    ---@param parent Unit
    ---@param droneName string
    SetParent = function(self, parent, droneName)
        self.Parent = parent
        self.Drone = droneName
    end,

    ---@param self BSB0003
    ---@param builder Unit
    ---@param layer string
    OnCreate = function(self, builder, layer)
        SShieldLandUnit.OnCreate(self, builder, layer)
    end,

    -- Make this unit invulnerable
    OnDamage = function()
    end,

    ---@param self BSB0003
    DeathThread = function(self)
        self:Destroy()
    end,
}

TypeClass = BSB0003
