-- Terran Anti Air Missile
CAANanoDartProjectile = import('/lua/cybranprojectiles.lua').CAANanoDartProjectile

---@class BaaMissile01 : CAANanoDartProjectile
BaaMissile01 = Class(CAANanoDartProjectile) {
    FxBeam = {'/mods/BlackOpsFAF-Unleashed/effects/emitters/mini_microwave_laser_beam_01_emit.bp'},

    ---@param self BaaMissile01
    OnCreate = function(self)
        CAANanoDartProjectile.OnCreate(self)
        self:ForkThread(self.WaitThread)
        self:ForkThread(self.UpdateThread)
    end,

    ---@param self BaaMissile01
    UpdateThread = function(self)
        local army = self.Army

        WaitSeconds(0.35)
        self:SetMaxSpeed(8)
        self:SetBallisticAcceleration(-0.5)

        for i in self.FxTrails do
            CreateEmitterOnEntity(self,army,self.FxTrails[i])
        end

        WaitSeconds(0.5)
        self:SetMesh('/projectiles/CAANanoDart01/CAANanoDartUnPacked01_mesh')
        self:SetMaxSpeed(100)
        self:SetAcceleration(20 + Random() * 5)

        WaitSeconds(0.3)
        self:SetTurnRate(360)
    end,

    ---@param self BaaMissile01
    WaitThread = function(self)
        while(true) do
            local currentTarget = self:GetTrackingTarget()

            if not currentTarget then
                return
            end

            if currentTarget.GetSource then
                currentTarget = currentTarget:GetSource()
            end

            if VDist3(currentTarget:GetPosition(), self:GetPosition()) < 10 then
                self.Lasering = true

                if self.hasOKC then
                    self.OKCData.dontOKCheck = true
                end

                self:PlaySound(self.Blueprint.Audio['Arc'])
                -- Just in case there's lots of stuff in FxBeam, we'll loop through it.
                for id, fx in self.FxBeam do
                    local effectEnt = AttachBeamEntityToEntity(currentTarget, -1, self, -1, self.Army, fx)    --    the -2 is worrying.

                    self.Trash:Add(effectEnt)
                end

                self:DoDamage(self:GetLauncher(), self.DamageData, currentTarget)
                WaitSeconds(self.DamageData.DoTTime)
                self:Destroy()
            end
            WaitTicks(1)
        end

    end,
}
TypeClass = BaaMissile01
