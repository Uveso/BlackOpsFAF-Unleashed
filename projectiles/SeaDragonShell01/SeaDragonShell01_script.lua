local SeaDragonShell = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsProjectiles.lua').SeaDragonShell

-- Cybran Artillery Projectile
---@class SeaDragonShell01 : SeaDragonShell
SeaDragonShell01 = Class(SeaDragonShell) {

    ---@param self SeaDragonShell01
    ---@param targetType string
    ---@param targetEntity Entity
    OnImpact = function(self, targetType, targetEntity)
        local army = self.Army
        CreateLightParticle(self, -1, army, 24, 5, 'glow_03', 'ramp_red_10')
        CreateLightParticle(self, -1, army, 8, 16, 'glow_03', 'ramp_antimatter_02')
        SeaDragonShell.OnImpact(self, targetType, targetEntity)
    end,

    ---@param self SeaDragonShell01
    ---@param army Army
    ---@param EffectTable table
    ---@param EffectScale number
    CreateImpactEffects = function(self, army, EffectTable, EffectScale)
        local emit = nil
        for _, v in EffectTable do
            emit = CreateEmitterAtEntity(self,army,v)
            if emit and EffectScale ~= 1 then
                emit:ScaleEmitter(EffectScale or 1)
            end
        end
    end,
}

TypeClass = SeaDragonShell01