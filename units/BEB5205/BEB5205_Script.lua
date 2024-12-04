-----------------------------------------------------------------
-- File     :  /cdimage/units/UEB5202/UEB5202_script.lua
-- Author(s):  John Comes, David Tomandl
-- Summary  :  UEF Air Staging Platform
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

local TAirStagingPlatformUnit = import('/lua/terranunits.lua').TAirStagingPlatformUnit
local TANTorpedoLandWeapon = import('/lua/terranweapons.lua').TANTorpedoLandWeapon
local TAAFlakArtilleryCannon = import('/lua/terranweapons.lua').TAAFlakArtilleryCannon
local TrashBagAdd = TrashBag.Add

---@class BEB5205 : TAirStagingPlatformUnit
BEB5205 = Class(TAirStagingPlatformUnit) {
    Weapons = {
        FlakGun01 = Class(TAAFlakArtilleryCannon) {},
        FlakGun02 = Class(TAAFlakArtilleryCannon) {},
        FlakGun03 = Class(TAAFlakArtilleryCannon) {},
        FlakGun04 = Class(TAAFlakArtilleryCannon) {},
        TorpedoTurret01 = Class(TANTorpedoLandWeapon) {},
        TorpedoTurret02 = Class(TANTorpedoLandWeapon) {},
        TorpedoTurret03 = Class(TANTorpedoLandWeapon) {},
        TorpedoTurret04 = Class(TANTorpedoLandWeapon) {},
    },

    ShieldEffects = {
        '/effects/emitters/terran_shield_generator_t2_01_emit.bp',
        '/effects/emitters/terran_shield_generator_t2_02_emit.bp',
    },

    ---@param self BEB5205
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        TAirStagingPlatformUnit.OnStopBeingBuilt(self,builder,layer)
        local trash = self.Trash

        -- Drone Globals
        self.Side = 0
        self.DroneTable = {}

        TrashBagAdd(trash, ForkThread(self.InitialDroneSpawn, self))

        if not self.OpenAnim then
            self.OpenAnim = CreateAnimator(self)
            TrashBagAdd(trash, self.OpenAnim)

            self.Rotator1 = CreateRotator(self, 'Spinner', 'y', nil, 10, 5, 10)
            self.Rotator2 = CreateRotator(self, 'B01', 'z', nil, -10, 5, -10)

            TrashBagAdd(trash, self.Rotator1)
            TrashBagAdd(trash, self.Rotator2)

            self.ShieldEffectsBag = {}

            local layer = self:GetCurrentLayer()

            -- If created with F2 on land
            if(layer == 'Land') then
                -- Disable Naval weapons
                self:SetWeaponEnabledByLabel('TorpedoTurret01', false)
                self:SetWeaponEnabledByLabel('TorpedoTurret02', false)
                self:SetWeaponEnabledByLabel('TorpedoTurret03', false)
                self:SetWeaponEnabledByLabel('TorpedoTurret04', false)
            elseif (layer == 'Water') then
                -- Enable Naval Weapons
                self:SetWeaponEnabledByLabel('TorpedoTurret01', true)
                self:SetWeaponEnabledByLabel('TorpedoTurret02', true)
                self:SetWeaponEnabledByLabel('TorpedoTurret03', true)
                self:SetWeaponEnabledByLabel('TorpedoTurret04', true)
            end
        end

        self.OpenAnim:PlayAnim(self.Blueprint.Display.AnimationOpen, false):SetRate(0.4)
    end,

    ---@param self BEB5205
    InitialDroneSpawn = function(self)
        local numcreate = 4
        local trash = self.Trash

        -- Randomly determines which launch bay will be the first to spawn a drone
        self.Side = Random(1,4)

        -- Short delay after the carrier has been built
        WaitSeconds(2)

        for i = 0, (numcreate -1) do
            TrashBagAdd(trash, ForkThread(self.SpawnDrone, self))
            -- Short delay between spawns to spread them out
            WaitSeconds(2)
        end
    end,

    ---@param self BEB5205
    SpawnDrone = function(self)
        local trash = self.Trash
        local army = self.Army

        WaitSeconds(5)
        -- Sets up local Variables used and spawns a drone at the parents location
        if self.Side == 1 then
            -- Gets the current position of the carrier launch bay in the game world
            local position = self:GetPosition('Station_01')

            -- Creates our drone in the left launch bay and directs the unit to face the same direction as its parent unit
            local drone = CreateUnitHPR('beb0005', army, position.x, position.y, position.z, 0, 0, 0)
            drone:AttachTo(self, 'Station_01')
            -- Adds the newly created drone to the parent carriers drone table
            table.insert (self.DroneTable, drone)

            -- Sets the Carrier unit as the drones parent
            drone:SetParent(self, 'beb5205')
            drone:SetCreator(self)

            -- Flips to the next spawn point
            self.Side = 2
            self:HideBone('Station_01', true)

            -- Drone clean up scripts
            TrashBagAdd(trash, drone)
        elseif self.Side == 2 then
            -- Gets the current position of the carrier launch bay in the game world
            local position = self:GetPosition('Station_02')

            -- Creates our drone in the right launch bay and directs the unit to face the same direction as its parent unit
            local drone = CreateUnitHPR('beb0005', army, position.x, position.y, position.z, 0, 0, 0)
            drone:AttachTo(self, 'Station_02')

            -- Adds the newly created drone to the parent carriers drone table
            table.insert (self.DroneTable, drone)

            -- Sets the Carrier unit as the drones parent
            drone:SetParent(self, 'beb5205')
            drone:SetCreator(self)

            -- Flips from the right to the left self.Side after a drone has been spawned
            self.Side = 3
            self:HideBone('Station_02', true)

            -- Drone clean up scripts
            TrashBagAdd(trash, drone)
        elseif self.Side == 3 then
            -- Gets the current position of the carrier launch bay in the game world
            local position = self:GetPosition('Station_03')

            -- Creates our drone in the right launch bay and directs the unit to face the same direction as its parent unit
            local drone = CreateUnitHPR('beb0005', army, position.x, position.y, position.z, 0, 0, 0)
            drone:AttachTo(self, 'Station_03')

            -- Adds the newly created drone to the parent carriers drone table
            table.insert (self.DroneTable, drone)

            -- Sets the Carrier unit as the drones parent
            drone:SetParent(self, 'beb5205')
            drone:SetCreator(self)

            -- Flips to the next spawn point
            self.Side = 4
            self:HideBone('Station_03', true)

            -- Drone clean up scripts
            TrashBagAdd(trash, drone)
        elseif self.Side == 4 then
            -- Gets the current position of the carrier launch bay in the game world
            local position = self:GetPosition('Station_04')

            -- Creates our drone in the right launch bay and directs the unit to face the same direction as its parent unit
            local drone = CreateUnitHPR('beb0005', army, position.x, position.y, position.z, 0, 0, 0)
            drone:AttachTo(self, 'Station_04')

            -- Adds the newly created drone to the parent carriers drone table
            table.insert (self.DroneTable, drone)

            -- Sets the Carrier unit as the drones parent
            drone:SetParent(self, 'beb5205')
            drone:SetCreator(self)

            -- Flips back to the first spawn point
            self.Side = 1
            self:HideBone('Station_04', true)

            -- Drone clean up scripts
            TrashBagAdd(trash, drone)
        end
    end,

    ---@param self BEB5205
    OnShieldEnabled = function(self)
        TAirStagingPlatformUnit.OnShieldEnabled(self)
        if self.Rotator1 then
            self.Rotator1:SetTargetSpeed(10)
        end
        if self.Rotator2 then
            self.Rotator2:SetTargetSpeed(-10)
        end

        if self.ShieldEffectsBag then
            for _, v in self.ShieldEffectsBag do
                v:Destroy()
            end
            self.ShieldEffectsBag = {}
        end
        for _, v in self.ShieldEffects do
            table.insert(self.ShieldEffectsBag, CreateAttachedEmitter(self, 'Shield_Base', self.Army, v) )
        end
    end,

    ---@param self any
    OnShieldDisabled = function(self)
        TAirStagingPlatformUnit.OnShieldDisabled(self)
        self.Rotator1:SetTargetSpeed(0)
        self.Rotator2:SetTargetSpeed(0)

        if self.ShieldEffectsBag then
            for _, v in self.ShieldEffectsBag do
                v:Destroy()
            end
            self.ShieldEffectsBag = {}
        end
    end,

    ---@param self BEB5205
    ---@param instigator Unit
    ---@param damagetype DamageType
    ---@param overkillRatio number
    OnKilled = function(self, instigator, damagetype, overkillRatio)
        self:HideBone('Station_01', false)
        self:HideBone('Station_02', false)
        self:HideBone('Station_03', false)
        self:HideBone('Station_04', false)
        if table.getn({self.DroneTable}) > 0 then
            for k, _ in self.DroneTable do
                IssueClearCommands({self.DroneTable[k]})
                IssueKillSelf({self.DroneTable[k]})
            end
        end
        TAirStagingPlatformUnit.OnKilled(self, instigator, damagetype, overkillRatio)
    end,
}

TypeClass = BEB5205
