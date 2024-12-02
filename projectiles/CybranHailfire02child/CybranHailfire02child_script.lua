-------------------------------------------------------------------------------
-- File     :  /projectiles/CIFNeutronClusterBomb02/CIFNeutronClusterBomb02.lua
-- Author(s):  Gordon Duclos
-- Summary  :  Cybran Neutron Cluster bomb
-- Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
-------------------------------------------------------------------------------
local CybranHailfire01ChildProjectile = import('/mods/BlackOpsFAF-Unleashed/lua/BlackOpsProjectiles.lua').CybranHailfire01ChildProjectile

---@class CybranHailfire02child : CybranHailfire01ChildProjectile
CybranHailfire02child = Class(CybranHailfire01ChildProjectile) {}
TypeClass = CybranHailfire02child
