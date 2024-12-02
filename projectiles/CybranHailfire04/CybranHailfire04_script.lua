local CybranHailfire04Projectile = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsProjectiles.lua').CybranHailfire04Projectile

-- Cybran Anti Air Projectile
---@class CAANanoDart02 : CybranHailfire04Projectile
CAANanoDart02 = Class(CybranHailfire04Projectile) {

    ---@param self CAANanoDart02
    OnCreate = function(self)
        CybranHailfire04Projectile.OnCreate(self)
        for _, v in self.FxTrails do
            CreateEmitterOnEntity(self,self.Army,v)
        end
   end,

}

TypeClass = CAANanoDart02
