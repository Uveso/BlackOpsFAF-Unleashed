local AirDroneUnit = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsunits.lua').AirDroneUnit
local WeaponsFile = import('/lua/aeonweapons.lua')
local AANDepthChargeBombWeapon = WeaponsFile.AANDepthChargeBombWeapon
local ADFQuantumAutogunWeapon = WeaponsFile.ADFQuantumAutogunWeapon

-- Upvalue for performance
local TrashBagAdd = TrashBag.Add

-- Tempest Drone
---@class BAA0001 : AirDroneUnit
BAA0001 = Class(AirDroneUnit) {

    Weapons = {
        MainGun = Class(import('/lua/aeonweapons.lua').ADFCannonOblivionWeapon) {
            FxMuzzleFlash = {
                '/effects/emitters/oblivion_cannon_flash_04_emit.bp',
                '/effects/emitters/oblivion_cannon_flash_05_emit.bp',
                '/effects/emitters/oblivion_cannon_flash_06_emit.bp',
            },
        },
        BlazeGun = Class(ADFQuantumAutogunWeapon) {},
        Depthcharge = Class(AANDepthChargeBombWeapon) {},
    },

    ---@param self BAA0001
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self, builder, layer)
        AirDroneUnit.OnStopBeingBuilt(self, builder, layer)

        local trash = self.Trash

        self.AnimManip = CreateAnimator(self)

        TrashBagAdd(trash, self.AnimManip)

        self.AnimManip:PlayAnim(self.Blueprint.Display.AnimationTakeOff, false):SetRate(1)
        if not self.OpenAnim then
            self.OpenAnim = CreateAnimator(self)
            TrashBagAdd(trash, self.OpenAnim)
        end
    end,

    ---@param self BAA0001
    ---@param new VerticalMovementState
    ---@param old VerticalMovementState
    OnMotionVertEventChange = function(self, new, old)
        AirDroneUnit.OnMotionVertEventChange(self, new, old)

        local bp = self.Blueprint

        -- Aborting a landing
        if ((new == 'Top' or new == 'Up') and old == 'Down') then
            self.AnimManip:SetRate(-1)
        elseif (new == 'Down') then
            self.AnimManip:PlayAnim(bp.Display.AnimationLand, false):SetRate(1)
        elseif (new == 'Up') then
            self.AnimManip:PlayAnim(bp.Display.AnimationTakeOff, false):SetRate(1)
        end
    end,

}

TypeClass = BAA0001
