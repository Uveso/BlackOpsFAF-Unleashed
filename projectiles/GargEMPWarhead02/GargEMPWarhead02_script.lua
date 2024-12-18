------------------------------------------------------------------------------
-- File     :  /projectiles/CIFEMPFluxWarhead02/CIFEMPFluxWarhead02_script.lua
-- Author(s):  Gordon Duclos
-- Summary  :  EMP Flux Warhead Impact effects projectile
-- Copyright � 2005,2006 Gas Powered Games, Inc.  All rights reserved.
------------------------------------------------------------------------------
local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell

---@class GargEMPWarhead02 : NullShell
GargEMPWarhead02 = Class(NullShell) {

    NukeMeshScale = 8.5725,
    PlumeVelocityScale = 0.1,

    -- Effects attached to moving nuke projectile plume
    PlumeEffects = {'/effects/emitters/empfluxwarhead_concussion_ring_02_emit.bp',},

    -- Effects not attached but created at the position of CIFEMPFluxWarhead02
    NormalEffects = {'/effects/emitters/empfluxwarhead_fallout_01_emit.bp'},

    ---@param self GargEMPWarhead02
    EffectThread = function(self)
        -- Mesh effects
        self.Plumeproj = self:CreateProjectile('/mods/BlackOpsFAF-Unleashed/effects/GargEMPWarHead/GargEMPWarHeadEffect01_proj.bp')

        -- Emitter Effects
        self:ForkThread(self.EmitterEffectsThread, self.Plumeproj)
    end,

    ---@param self GargEMPWarhead02
    ---@param plume string
    EmitterEffectsThread = function(self, plume)
        local army = self.Army

        for _, v in self.PlumeEffects do
            CreateAttachedEmitter(plume, -1, army, v)
        end

        for _, v in self.NormalEffects do
            CreateEmitterAtEntity(self, army, v)
        end
    end,
}

TypeClass = GargEMPWarhead02
