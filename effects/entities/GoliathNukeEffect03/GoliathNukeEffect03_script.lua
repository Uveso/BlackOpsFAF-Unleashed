--------------------------------------------------------------------------------
-- File     :  /effects/Entities/BasiliskNukeEffect03/UEFNukeEffect03_script.lua
-- Author(s):  Gordon Duclos
-- Summary  :  Nuclear explosion script
-- Copyright � 2005,2006 Gas Powered Games, Inc.  All rights reserved.
--------------------------------------------------------------------------------
local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local EffectTemplate = import('/lua/EffectTemplates.lua')

-- Upvalue for performance
local TrashBagAdd = TrashBag.Add

---@class BasiliskNukeEffect03 : NullShell
BasiliskNukeEffect03 = Class(NullShell) {

    ---@param self BasiliskNukeEffect03
    OnCreate = function(self)
        NullShell.OnCreate(self)
        local trash = self.Trash
        TrashBagAdd(trash, ForkThread(self.EffectThread, self))
    end,

    ---@param self BasiliskNukeEffect03
    EffectThread = function(self)
        local army = self.Army

        for _, v in EffectTemplate.TNukeHeadEffects03 do
            CreateAttachedEmitter(self, -1, army, v)
        end

        WaitSeconds(6)
        for _, v in EffectTemplate.TNukeHeadEffects02 do
            CreateAttachedEmitter(self, -1, army, v)
        end
    end,
}

TypeClass = BasiliskNukeEffect03
