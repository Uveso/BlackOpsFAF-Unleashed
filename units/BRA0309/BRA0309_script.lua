-----------------------------------------------------------------
-- File     :  /cdimage/units/BRA0309/BRA0309_script.lua
-- Author(s):  John Comes, David Tomandl
-- Summary  :  Cybran T2 Air Transport Script
-- Copyright � 2006 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local AirTransport = import('/lua/defaultunits.lua').AirTransport

local explosion = import('/lua/defaultexplosions.lua')
local util = import('/lua/utilities.lua')
local cWeapons = import('/lua/cybranweapons.lua')
local CAAAutocannon = cWeapons.CAAAutocannon
local CEMPAutoCannon = cWeapons.CEMPAutoCannon

local TrashBagAdd = TrashBag.Add

---@class BRA0309 : AirTransport
BRA0309 = Class(AirTransport) {
    Weapons = {
        AAAutocannon = Class(CAAAutocannon) {},
        EMPCannon = Class(CEMPAutoCannon) {},
    },

    AirDestructionEffectBones = {
        'Left_Exhaust', 'Right_Exhaust', 'Char04', 'Char03', 'Char02', 'Char01',
        'Front_Left_Leg03_B02', 'Front_Right_Leg03_B02', 'Front_Left_Leg01_B02', 'Front_Right_Leg01_B02',
        'Right_AttachPoint01', 'Right_AttachPoint02', 'Right_AttachPoint03', 'Right_AttachPoint04',
        'Left_AttachPoint01', 'Left_AttachPoint02', 'Left_AttachPoint03', 'Left_AttachPoint04',
    },

    BeamExhaustIdle = '/effects/emitters/missile_exhaust_fire_beam_05_emit.bp',
    BeamExhaustCruise = '/effects/emitters/missile_exhaust_fire_beam_04_emit.bp',

    ---@param self BRA0309
    OnCreate = function(self)
        AirTransport.OnCreate(self)
        local trash = self.Trash

        if not self.OpenAnim then
            self.OpenAnim = CreateAnimator(self)
            self.OpenAnim:PlayAnim(self.Blueprint.Display.AnimationOpen, false):SetRate(0)
            TrashBagAdd(trash, self.OpenAnim)
        end
    end,

    ---@param self BRA0309
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        AirTransport.OnStopBeingBuilt(self,builder,layer)
        local trash = self.Trash

        self:SetMaintenanceConsumptionInactive()
        self:SetScriptBit('RULEUTC_IntelToggle', true)
        self:RequestRefreshUI()
        self.AnimManip = CreateAnimator(self)
        TrashBagAdd(trash, self.AnimManip)
        if not self.OpenAnim then
            self.OpenAnim = CreateAnimator(self)
            TrashBagAdd(trash, self.OpenAnim)
        end
        self.OpenAnim:PlayAnim(self.Blueprint.Display.AnimationOpen, false):SetRate(1)
    end,

    -- When one of our attached units gets killed, detach it
    ---@param attached Unit
    OnAttachedKilled = function(attached)
        attached:DetachFrom()
    end,

    ---@param self BRA0309
    ---@param instigator Unit
    ---@param type string
    ---@param overkillRatio number
    OnKilled = function(self, instigator, type, overkillRatio)
        self:TransportDetachAllUnits(true)
        AirTransport.OnKilled(self, instigator, type, overkillRatio)
    end,


    -- Override air destruction effects so we can do something custom here
    ---@param self BRA0309
    CreateUnitAirDestructionEffects = function(self)
        local trash = self.Trash
        TrashBagAdd(trash, self:ForkThread(self.AirDestructionEffectsThread, self))
    end,

    ---@param self BRA0309
    AirDestructionEffectsThread = function(self)
        local numExplosions = math.floor(table.getn(self.AirDestructionEffectBones) * 0.5)
        for i = 0, numExplosions do
            explosion.CreateDefaultHitExplosionAtBone(self, self.AirDestructionEffectBones[util.GetRandomInt(1, numExplosions)], 0.5)
            WaitSeconds(util.GetRandomFloat(0.2, 0.9))
        end
    end,
}

TypeClass = BRA0309
