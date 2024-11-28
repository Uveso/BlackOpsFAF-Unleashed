local CybranHailfire03Projectile = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsProjectiles.lua').CybranHailfire03Projectile
local EffectTemplate = import('/lua/EffectTemplates.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

-- Cybran Anti Air Projectile
---@class CAANanoDart02 : CybranHailfire03Projectile
CAANanoDart02 = Class(CybranHailfire03Projectile) {

    ---@param self CAANanoDart02
    OnCreate = function(self)
        CybranHailfire03Projectile.OnCreate(self)
        for _, v in self.FxTrails do
            CreateEmitterOnEntity(self,self.Army,v)
        end
   end,

   ---@param self CAANanoDart02
    MovementThread = function(self)
        self.WaitTime = 0.1
        WaitSeconds(0.1)
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(self.WaitTime)
        end
    end,

    ---@param self CAANanoDart02
    SetTurnRateByDist = function(self)
        local dist = VDist3(self:GetPosition(), self:GetCurrentTargetPosition())
        if dist > 0 and dist <= 15 then
            WaitSeconds(0.1)
            local FxFragEffect = EffectTemplate.SThunderStormCannonProjectileSplitFx
            local ChildProjectileBP = '/mods/BlackOpsFAF-Unleashed/projectiles/CybranHailfire01child/CybranHailfire01child_proj.bp'

            for k, v in FxFragEffect do
                CreateEmitterAtEntity(self, self.Army, v)
            end

            local vx, vy, vz = self:GetVelocity()
            local velocity = 20

            -- Create several other projectiles in a dispersal pattern
            local numProjectiles = 5

            local angle = (2*math.pi) / numProjectiles
            local angleInitial = RandomFloat(0, angle)

            -- Randomization of the spread
            local angleVariation = angle * 3 -- Adjusts angle variance spread
            local spreadMul = 1.75 -- Adjusts the width of the dispersal

            local xVec = 0
            local yVec = vy
            local zVec = 0

            -- Launch projectiles at semi-random angles away from split location
            for i = 0, (numProjectiles -1) do
                xVec = vx + (math.sin(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
                zVec = vz + (math.cos(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
                local proj = self:CreateChildProjectile(ChildProjectileBP)
                proj:SetVelocity(xVec,yVec,zVec)
                proj:SetVelocity(velocity)
                proj:PassDamageData(self.ChildDamageData)
            end

            self:Destroy()
        end
    end,

    ---@param self CAANanoDart02
    ---@param damageData table
    PassDamageData = function(self, damageData)
        CybranHailfire03Projectile.PassDamageData(self,damageData)
        local launcherbp = self.Launcher.Blueprint
        self.ChildDamageData = table.copy(self.DamageData)
        self.ChildDamageData.DamageAmount = launcherbp.SplitDamage.DamageAmount or 0
        self.ChildDamageData.DamageRadius = launcherbp.SplitDamage.DamageRadius or 1
    end,
}

TypeClass = CAANanoDart02
