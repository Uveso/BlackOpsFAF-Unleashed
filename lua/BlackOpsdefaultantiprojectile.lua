-----------------------------------------------------------------
-- File     :  /lua/defaultantimissile.lua
-- Author(s):  Gordon Duclos
-- Summary  :  Default definitions collision beams
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------
local Entity = import('/lua/sim/Entity.lua').Entity
local BlackOpsEffectTemplate = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsEffectTemplates.lua')

---@class SeraLambdaFieldDestroyer : Entity
SeraLambdaFieldDestroyer = Class(Entity) {
    EndPointEffects = {'/effects/emitters/particle_cannon_end_01_emit.bp',},
    LambdaEffects = BlackOpsEffectTemplate.LambdaDestroyer,

    ---@param self SeraLambdaFieldDestroyer
    ---@param spec table
    OnCreate = function(self, spec)
        Entity.OnCreate(self, spec)
        self.Owner = spec.Owner
        self.Probability = spec.Probability
        self:SetCollisionShape('Sphere', 0, 0, 0, spec.Radius)
        self:SetDrawScale(spec.Radius)
        self.AttachBone = spec.AttachBone
        self:AttachTo(spec.Owner, spec.AttachBone)
        ChangeState(self, self.WaitingState)
        self.LambdaEffectsBag = {}
        self.Army = self:GetArmy()
    end,

    ---@param self SeraLambdaFieldDestroyer
    OnDestroy = function(self)
        Entity.OnDestroy(self)
        ChangeState(self, self.DeadState)
    end,

    DeadState = State {
        Main = function(self)
        end,
    },

    -- Return true to process this collision, false to ignore it.
    WaitingState = State{

        ---@param self SeraLambdaFieldDestroyer
        ---@param other any
        ---@return boolean
        OnCollisionCheck = function(self, other)
            local army = self.Army

            if not EntityCategoryContains(categories.PROJECTILE, other) or EntityCategoryContains(categories.STRATEGIC, other) or EntityCategoryContains(categories.ANTINAVY, other) then
                return false
            end
            if not IsEnemy(army, other.Army) then return false end -- Don't affect non-enemies
            if other.LambdaDetect[self] then return false end

            local rand = math.random(0, 100)
            if rand >= 0 and rand <= self.Probability then

                -- Create Lambda FX
                for _, v in self.LambdaEffects do
                    table.insert(self.LambdaEffectsBag, CreateEmitterOnEntity(other, army, v):ScaleEmitter(0.2))
                end

                other:Destroy()

                -- Clean up FX
                for _, v in self.LambdaEffectsBag do
                    v:Destroy()
                end
                self.LambdaEffectsBag = {}
            end

            if not other.LambdaDetect then
                other.LambdaDetect = {}
            end
            other.LambdaDetect[self] = true

            return false
        end,
    },
}

---@class TorpRedirectField : Entity
TorpRedirectField = Class(Entity) {

    RedirectBeams = {'/mods/BlackOpsFAF-Unleashed/effects/emitters/Torp_beam_02_emit.bp'},
    EndPointEffects = {'/effects/emitters/particle_cannon_end_01_emit.bp',},

    ---@param self TorpRedirectField
    ---@param spec table
    OnCreate = function(self, spec)
        Entity.OnCreate(self, spec)
        self.Owner = spec.Owner
        self.Radius = spec.Radius
        self.RedirectRateOfFire = spec.RedirectRateOfFire or 1
        self:SetCollisionShape('Sphere', 0, 0, 0, self.Radius)
        self:SetDrawScale(self.Radius)
        self.AttachBone = spec.AttachBone
        self:AttachTo(spec.Owner, spec.AttachBone)
        ChangeState(self, self.WaitingState)
        self.LambdaEffectsBag = {}
        self.Army = self:GetArmy()
    end,

    ---@param self TorpRedirectField
    OnDestroy = function(self)
        Entity.OnDestroy(self)
        ChangeState(self, self.DeadState)
    end,

    DeadState = State {
        Main = function(self)
        end,
    },

    -- Return true to process this collision, false to ignore it.
    WaitingState = State{
        OnCollisionCheck = function(self, other)
            if EntityCategoryContains(categories.TORPEDO, other)
                and not EntityCategoryContains(categories.STRATEGIC, other)
                and other ~= self.EnemyProj
                and IsEnemy(self.Army, other.Army)
            then
                self.Enemy = other.Launcher
                self.EnemyProj = other
                self.EXFiring = false
                if self.Enemy and (not other.lastRedirector or other.lastRedirector ~= self.Army) then
                    other.lastRedirector = self.Army
                    local targetspeed = other:GetCurrentSpeed()
                    other:SetVelocity(targetspeed * 3)
                    other:SetNewTarget(self.Enemy)
                    other:TrackTarget(true)
                    other:SetTurnRate(720)
                    self.EXFiring = true
                end
                if self.EXFiring then
                    ChangeState(self, self.RedirectingState)
                end
            end
            return false
        end,
    },

    RedirectingState = State{
        Main = function(self)
            if not self or self:BeenDestroyed()
            or not self.EnemyProj or self.EnemyProj:BeenDestroyed()
            or not self.Owner or self.Owner.Dead then
                return
            end

            local beams = {}
            for _, v in self.RedirectBeams do
                table.insert(beams, AttachBeamEntityToEntity(self.EnemyProj, -1, self.Owner, self.AttachBone, self.Army, v))
            end
            if self.Enemy then
                -- Set collision to friends active so that when the missile reaches its source it can deal damage.
                self.EnemyProj.DamageData.CollideFriendly = true
                self.EnemyProj.DamageData.DamageFriendly = true
                self.EnemyProj.DamageData.DamageSelf = true
            end
            if self.Enemy and not self.Enemy:BeenDestroyed() then
                WaitTicks(self.RedirectRateOfFire)
                if not self.EnemyProj:BeenDestroyed() then
                     self.EnemyProj:TrackTarget(false)
                end
            else
                WaitTicks(self.RedirectRateOfFire)
                local vectordam = {}
                vectordam.x = 0
                vectordam.y = 1
                vectordam.z = 0
                self.EnemyProj:DoTakeDamage(self.Owner, 30, vectordam,'Fire')
            end
            for _, v in beams do
                v:Destroy()
            end
            ChangeState(self, self.WaitingState)
        end,

        OnCollisionCheck = function(self, other)
            return false
        end,
    },
}
