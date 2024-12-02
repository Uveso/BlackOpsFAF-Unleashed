local BlackOpsEffectTemplate = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsEffectTemplates.lua')

---@class oldUnit
local oldUnit = Unit

---@class Unit : oldUnit
Unit = Class(oldUnit) {

    -----------------------------------------------------------
    -- First, all the functions which are hooking the originals
    -----------------------------------------------------------

    ---@param self Unit
    OnCreate = function(self)
        oldUnit.OnCreate(self)
        self.StunEffectsBag = {}
    end,

    ---@param self Unit
    ---@param builder Unit
    ---@param layer Layer
    OnStopBeingBuilt = function(self,builder,layer)
        oldUnit.OnStopBeingBuilt(self,builder,layer)
        self.EXPhaseShieldPercentage = 0
        self.EXPhaseEnabled = false
        self.EXTeleportCooldownCharge = false
        self.EXPhaseCharge = 0
    end,

    ---@param self Unit
    CleanupTeleportChargeEffects = function(self)
        self.TeleportCostPaid = false
        oldUnit.CleanupTeleportChargeEffects(self)
    end,

    ---@param self Unit
    ---@param teleporter any
    ---@param location Vector
    ---@param orientation Vector
    OnTeleportUnit = function(self, teleporter, location, orientation)
        local id = self:GetEntityId()

        -- Teleport Cooldown Charge
        -- Range Check to location
        local maxRange = self.Blueprint.Defense.MaxTeleRange
        local myposition = self:GetPosition()
        local destRange = VDist2(location[1], location[3], myposition[1], myposition[3])
        if maxRange and destRange > maxRange then
            FloatingEntityText(id,'Destination Out Of Range')
            return
        end

        -- Teleport Blocker Check
        for _, brain in ArmyBrains do
            local unitList = brain:GetListOfUnits(categories.ANTITELEPORT, false)
            for _, unit in unitList do
                -- If it's an ally, then we skip.
                if IsEnemy(self.Army, unit.Army) then
                    local blockerRange = unit.Blueprint.Defense.NoTeleDistance
                    if blockerRange then
                        local blockerPosition = unit:GetPosition()
                        local targetDest = VDist2(location[1], location[3], blockerPosition[1], blockerPosition[3])
                        local sourceCheck = VDist2(myposition[1], myposition[3], blockerPosition[1], blockerPosition[3])
                        if blockerRange and blockerRange >= targetDest then
                            FloatingEntityText(id, 'Teleport Destination Scrambled')
                            return
                        elseif blockerRange and blockerRange >= sourceCheck then
                            FloatingEntityText(id, 'Teleport Source Location Scrambled')
                            return
                        end
                    end
                end
            end
        end

        -- Economy Check and Drain
        local bp = self.Blueprint
        local telecost = bp.Economy.TeleportBurstEnergyCost or 0
        local mybrain = self:GetAIBrain()
        local storedenergy = mybrain:GetEconomyStored('ENERGY')
        if telecost > 0 and not self.TeleportCostPaid then
            if storedenergy >= telecost then
                mybrain:TakeResource('ENERGY', telecost)
                self.TeleportCostPaid = true
            else
                FloatingEntityText(id,'Insufficient Energy For Teleportation')
                return
            end
        end

        oldUnit.OnTeleportUnit(self, teleporter, location, orientation)
    end,

    ---@param self Unit
    ---@param location Vector
    PlayTeleportChargeEffects = function(self, location)
        oldUnit.PlayTeleportChargeEffects(self, location)
        if not self.Dead and self.EXPhaseEnabled == false then
            self.EXTeleportChargeEffects(self)
        end
    end,

    ---@param self Unit
    OnFailedTeleport = function(self)
        oldUnit.OnFailedTeleport(self)
        if not self.Dead and self.EXPhaseEnabled == true then
            self.EXPhaseEnabled = false
            self.EXPhaseCharge = 0
            self.EXPhaseShieldPercentage = 0

            local bpDisplay = self.Blueprint.Display
            self:SetMesh(bpDisplay.MeshBlueprint, true)
        end
    end,

    ---@param self Unit
    PlayTeleportInEffects = function(self)
        oldUnit.PlayTeleportInEffects(self)
        if not self.Dead and self.EXPhaseEnabled == true then
            self.EXTeleportCooldownEffects(self)
        end
    end,

    ---@param self Unit
    ---@param other Unit
    ---@param firingWeapon Weapon
    ---@return boolean
    OnCollisionCheck = function(self, other, firingWeapon)
        if self.DisallowCollisions then
            return false
        end
        -- Run a modified CollideFriendly check first that allows for allied phasing
        if EntityCategoryContains(categories.PROJECTILE, other) then
            if not self:GetShouldCollide(other:GetCollideFriendly(), self.Army, other.Army) then
                return false
            end
        end

        if other.lastimpact and other.lastimpact == self:GetEntityId() then
            return false
        end

        if not self.Dead and self.EXPhaseEnabled == true then
            if EntityCategoryContains(categories.PROJECTILE, other) then
                local random = Random(1,100)
                -- Allows % of projectiles to pass
                if random <= self.EXPhaseShieldPercentage then
                    -- Returning false allows the projectile to pass thru
                    return false
                else
                    -- Projectile impacts normally
                    return true
                end
            end
        end

        return oldUnit.OnCollisionCheck(self, other, firingWeapon)
    end,

    ---@param self Unit
    ---@param firingWeapon Weapon
    ---@return boolean
    OnCollisionCheckWeapon = function(self, firingWeapon)
        if self.DisallowCollisions then
            return false
        end

        -- Run a modified CollideFriendly check first that allows for allied phasing
        if not self:GetShouldCollide(firingWeapon.Blueprint.CollideFriendly, self.Army, firingWeapon.unit.Army) then
            return false
        end

        return oldUnit.OnCollisionCheckWeapon(self, firingWeapon)
    end,

    -------------------------------------------------------
    -- The rest of the functions are added anew by BlackOps
    -------------------------------------------------------

    ---@param self Unit
    EXTeleportChargeEffects = function(self)
        if not self.Dead then
            local bpe = self.Blueprint.Economy
            self.EXPhaseEnabled = true
            self.EXPhaseCharge = 1
            self.EXPhaseShieldPercentage = 0
            if bpe then
                local mass = bpe.BuildCostMass * (bpe.TeleportMassMod or 0.01)
                local energy = bpe.BuildCostEnergy * (bpe.TeleportEnergyMod or 0.01)
                energyCost = mass + energy
                EXTeleTime = energyCost * (bpe.TeleportTimeMod or 0.01)
                self.EXTeleTimeMod1 = (EXTeleTime * 10) * 0.2
                self.EXTeleTimeMod2 = self.EXTeleTimeMod1 * 2
                self.EXTeleTimeMod3 = (EXTeleTime * 10) - ((self.EXTeleTimeMod1 * 2) + self.EXTeleTimeMod2)
                self.EXTeleTimeMod4 = (self.EXTeleTimeMod3) - 7
                local bp = self.Blueprint
                local bpDisplay = bp.Display
                if self.EXPhaseCharge == 1 then
                    WaitTicks(self.EXTeleTimeMod1)
                end
                if self.EXPhaseCharge == 1 then
                    self:SetMesh(bpDisplay.Phase1MeshBlueprint, true)
                    self.EXPhaseShieldPercentage = 33
                    WaitTicks(self.EXTeleTimeMod2)
                end
                if self.EXPhaseCharge == 1 then
                    self.EXPhaseShieldPercentage = 66
                    WaitTicks(self.EXTeleTimeMod1)
                end
                if self.EXPhaseCharge == 1 then
                    self.EXPhaseShieldPercentage = 100
                    if self.EXTeleTimeMod3 >= 7 then
                        WaitTicks(self.EXTeleTimeMod4)
                    end
                end
                if self.EXPhaseCharge == 1 then self:SetMesh(bpDisplay.Phase2MeshBlueprint, true) end
            end
        end
    end,

    ---@param self Unit
    EXTeleportCooldownEffects = function(self)
        if not self.Dead then
            local bp = self.Blueprint
            local bpDisplay = bp.Display
            self.EXPhaseCharge = 0
            if self.EXPhaseCharge == 0 then
                self.EXPhaseShieldPercentage = 100
                WaitTicks(5)
            end
            if self.EXPhaseCharge == 0 then
                self.EXPhaseShieldPercentage = 100
                self:SetMesh(bpDisplay.Phase1MeshBlueprint, true)
                WaitTicks(8)
            end
            if self.EXPhaseCharge == 0 then
                self.EXPhaseShieldPercentage = 75
                self:SetMesh(bpDisplay.Phase1MeshBlueprint, true)
                WaitTicks(25)
            end
            if self.EXPhaseCharge == 0 then
                self.EXPhaseShieldPercentage = 50
                self:SetMesh(bpDisplay.MeshBlueprint, true)
                WaitTicks(10)
                self.EXPhaseShieldPercentage = 0
                self.EXPhaseEnabled = false
            end
        end
    end,

    ---@param self Unit Unused
    ---@param collidefriendly boolean
    ---@param army1 Army
    ---@param army2 Army
    ---@return boolean
    GetShouldCollide = function(self, collidefriendly, army1, army2)
        if not collidefriendly then
            if army1 == army2 or IsAlly(army1, army2) then
                return false
            end
        end
        return true
    end,
}