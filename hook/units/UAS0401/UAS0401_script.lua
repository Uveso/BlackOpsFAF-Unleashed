
local ASeaUnit = import('/lua/aeonunits.lua').ASeaUnit
local BaseTransport = import('/lua/defaultunits.lua').BaseTransport
local AirDroneCarrier = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsunits.lua').AirDroneCarrier
local WeaponsFile = import('/lua/aeonweapons.lua')
local ADFCannonOblivionWeapon = WeaponsFile.ADFCannonOblivionWeapon02
local AANChronoTorpedoWeapon = WeaponsFile.AANChronoTorpedoWeapon
local AIFQuasarAntiTorpedoWeapon = WeaponsFile.AIFQuasarAntiTorpedoWeapon

-- Upvalue for Blueprints
local TrashBagAdd = TrashBag.Add

---@class UAS0401 : BaseTransport, ASeaUnit, AirDroneCarrier
UAS0401 = Class(BaseTransport, ASeaUnit, AirDroneCarrier) {

    BuildAttachBone = 'Attachpoint01',

    Weapons = {
        MainGun = Class(ADFCannonOblivionWeapon) {},
        Torpedo01 = Class(AANChronoTorpedoWeapon) {},
        Torpedo02 = Class(AANChronoTorpedoWeapon) {},
        Torpedo03 = Class(AANChronoTorpedoWeapon) {},
        Torpedo04 = Class(AANChronoTorpedoWeapon) {},
        Torpedo05 = Class(AANChronoTorpedoWeapon) {},
        Torpedo06 = Class(AANChronoTorpedoWeapon) {},
        AntiTorpedo01 = Class(AIFQuasarAntiTorpedoWeapon) {},
        AntiTorpedo02 = Class(AIFQuasarAntiTorpedoWeapon) {},
    },

    ---@param self UAS0401
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        self:SetWeaponEnabledByLabel('MainGun', true)
        ASeaUnit.OnStopBeingBuilt(self,builder,layer)
        if layer == 'Water' then
            self:RestoreBuildRestrictions()
            self:RequestRefreshUI()
        else
            self:AddBuildRestriction(categories.ALLUNITS)
            self:RequestRefreshUI()
        end
        ChangeState(self, self.DroneMaintenanceState)
        AirDroneCarrier.InitDrones(self)
    end,

    ---@param self UAS0401
    ---@param unitBuilding Unit
    ---@param order string
    OnStartBuild = function(self, unitBuilding, order)
        ASeaUnit.OnStartBuild(self, unitBuilding, order)
        self.UnitBeingBuilt = unitBuilding
        ChangeState(self, self.BuildingState)
    end,

    ---@param self UAS0401
    ---@param unitBeingBuilt Unit
    OnStopBuild = function(self, unitBeingBuilt)
        ASeaUnit.OnStopBuild(self, unitBeingBuilt)
        ChangeState(self, self.FinishedBuildingState)
    end,

    ---@param self UAS0401
    OnFailedToBuild = function(self)
        ASeaUnit.OnFailedToBuild(self)
        ChangeState(self, self.DroneMaintenanceState)
    end,

    ---@param self UAS0401
    ---@param new VerticalMovementState
    ---@param old VerticalMovementState
    OnMotionVertEventChange = function(self, new, old)
        ASeaUnit.OnMotionVertEventChange(self, new, old)
        if new == 'Top' then
            self:RestoreBuildRestrictions()
            self:RequestRefreshUI()
            self:SetWeaponEnabledByLabel('MainGun', true)
            self:PlayUnitSound('Open')
            self.DroneAssist = true
        elseif new == 'Down' then
            self:SetWeaponEnabledByLabel('MainGun', false)
            self:AddBuildRestriction(categories.ALLUNITS)
            self:RequestRefreshUI()
            self:PlayUnitSound('Close')
            self:RecallDrones()
            self.DroneAssist = false
        end
    end,

    --Places the Goliath's first drone-targetable attacker into a global
    ---@param self UAS0401
    ---@param instigator Unit
    ---@param amount number
    ---@param vector Vector
    ---@param damagetype DamageType
    OnDamage = function(self, instigator, amount, vector, damagetype)
        ASeaUnit.OnDamage(self, instigator, amount, vector, damagetype)
        AirDroneCarrier.SetAttacker(self, instigator)
    end,

    --Drone control buttons
    ---@param self UAS0401
    ---@param bit number
    OnScriptBitSet = function(self, bit)
        --Drone assist toggle, on
        if bit == 1 then
            self.DroneAssist = false
        --Drone recall button
        elseif bit == 7 then
            self:RecallDrones()
            --Pop button back up, as it's not actually a toggle
            self:SetScriptBit('RULEUTC_SpecialToggle', false)
        else
            ASeaUnit.OnScriptBitSet(self, bit)
        end
    end,

    ---@param self UAS0401
    ---@param bit number
    OnScriptBitClear = function(self, bit)
        --Drone assist toggle, off
        if bit == 1 then
            self.DroneAssist = true
        --Recall button reset, do nothing
        elseif bit == 7 then
            return
        else
            ASeaUnit.OnScriptBitClear(self, bit)
        end
    end,

    --Handles drone docking
    ---@param self UAS0401
    ---@param attachBone string
    ---@param unit Unit
    OnTransportAttach = function(self, attachBone, unit)
        BaseTransport.OnTransportAttach(self, attachBone, unit)
        ASeaUnit.OnTransportAttach(self, attachBone, unit)

        self.DroneData[unit.Name].Docked = attachBone
        unit:SetDoNotTarget(true)
    end,

    --Handles drone undocking, also called when docked drones die
    ---@param self UAS0401
    ---@param attachBone string
    ---@param unit Unit
    OnTransportDetach = function(self, attachBone, unit)
        BaseTransport.OnTransportDetach(self, attachBone, unit)
        ASeaUnit.OnTransportDetach(self, attachBone, unit)

        self.DroneData[unit.Name].Docked = false
        unit:SetDoNotTarget(false)
        if unit.Name == self.BuildingDrone then
            self:CleanupDroneMaintenance(self.BuildingDrone)
        end
    end,

    ---@param self UAS0401
    ---@param attached Unit
    OnAttachedKilled = function(self, attached)
        BaseTransport.OnAttachedKilled(self, attached)
        ASeaUnit.OnAttachedKilled(self, attached)
    end,

    ---@param self UAS0401
    OnStartTransportLoading = function(self)
        BaseTransport.OnStartTransportLoading(self)
        ASeaUnit.OnStartTransportLoading(self)
    end,

    ---@param self UAS0401
    OnStopTransportLoading = function(self)
        BaseTransport.OnStopTransportLoading(self)
        ASeaUnit.OnStopTransportLoading(self)
    end,

    ---@param self UAS0401
    DestroyedOnTransport = function(self)
        BaseTransport.DestroyedOnTransport(self)
        ASeaUnit.DestroyedOnTransport(self)
    end,

    --Cleans up threads and drones on death
    ---@param self UAS0401
    ---@param instigator Unit
    ---@param type string
    ---@param overkillRatio number
    OnKilled = function(self, instigator, type, overkillRatio)
        --Kill our heartbeat thread
        KillThread(self.HeartBeatThread)
        --Clean up any in-progress construction
        ChangeState(self, self.DeadState)
        --Immediately kill existing drones
        self:KillAllDrones()

        local watchBone = self.Blueprint.WatchBone or 0
        local trash = self.Trash

        TrashBagAdd(trash, ForkThread(
            function()
                local pos = self:GetPosition()
                local seafloor = GetTerrainHeight(pos[1], pos[3]) + GetTerrainTypeOffset(pos[1], pos[3])
                while self:GetPosition(watchBone)[2] > seafloor do
                    WaitSeconds(0.1)
                end
                self:CreateWreckage(overkillRatio, instigator)
                self:Destroy()
            end
        ))

        local layer = self:GetCurrentLayer()
        self:DestroyIdleEffects()
        if (layer == 'Water' or layer == 'Seabed' or layer == 'Sub') then
            self.SinkExplosionThread = TrashBagAdd(trash, ForkThread(self.ExplosionThread,self))
            self.SinkThread = TrashBagAdd(trash, ForkThread(self.SinkThread,self))
        end
        ASeaUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    BuildingState = State {
        Main = function(self)
            local unitBuilding = self.UnitBeingBuilt
            local bone = self.BuildAttachBone
            self:DetachAll(bone)
            if not self.UnitBeingBuilt.Dead then
                unitBuilding:AttachBoneTo(-2, self, bone)
                if EntityCategoryContains(categories.ENGINEER + categories.uas0102 + categories.uas0103, unitBuilding) then
                    unitBuilding:SetParentOffset({0,0,1})
                elseif EntityCategoryContains(categories.TECH2 - categories.ENGINEER, unitBuilding) then
                    unitBuilding:SetParentOffset({0,0,3})
                elseif EntityCategoryContains(categories.uas0203, unitBuilding) then
                    unitBuilding:SetParentOffset({0,0,1.5})
                else
                    unitBuilding:SetParentOffset({0,0,2.5})
                end
            end
            self.UnitDoneBeingBuilt = false
        end,

    },

    FinishedBuildingState = State {
        Main = function(self)
            local unitBuilding = self.UnitBeingBuilt
            unitBuilding:DetachFrom(true)
            self:DetachAll(self.BuildAttachBone)
            local worldPos = self:CalculateWorldPositionFromRelative({0, 0, -20})
            IssueMoveOffFactory({unitBuilding}, worldPos)
            ChangeState(self, self.DroneMaintenanceState)
        end,
    },

    -- Set on unit death, ends production and consumption immediately
    DeadState = State {
        Main = function(self)
            if self.gettingBuilt == false then
                self:CleanupDroneMaintenance(nil, true)
            end
        end,
    },
}

TypeClass = UAS0401