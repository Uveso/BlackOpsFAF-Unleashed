--- 
## v26 (21.Apr.2025)

- Added Annotations (MrRowey)
- Speed up functions (MrRowey)
- Fixed CreateProjectileAtMuzzle hooks by returning the projectile to parent function
- Unit bea0402 (Experimental Aerial Fortress) now has a dummy weapon to attack enemies directly below.
- Unit bea0402 (Experimental Aerial Fortress) UISelection from tank tp air unit (thanks to DJ_Calaco)

---

## v25 (02.Nov.2024)

Fixes by Basilisk3:
- Unit bes0402 (Experimental Dreadnaught) Hitbox enlarged downwards so that torpedoes can hit the unit more effectively
- Unit uaa0310 (Experimental Aircraft Carrier) Add switch and fix animation for Superweapon

Fixes by Uveso:
- fixed SorianDefenseBuilders.lua (removed dependency for sorian buildconditions)
- fixed TransportClass on several units
- GargEMPWarhead01_proj.bp fix DesiredShooterCap not matching health
- ArtemisCannon02_proj.bp fix DesiredShooterCap not matching health
- Unit eeb0402 (Stellar Generator) Hitbox enlarged downwards so that torpedoes can hit the unit more effectively
- Unit uaa0310 (Experimental Aircraft Carrier) Add shield from FAF CZAR
- Unit bal0206 (Medium Assault Tank) fix collision box
- Unit bel9010 (Jammer Crystal) fix collision box

---

## v24 (21.Aug.2023)

Fixes by Uveso:
- fixed an issue where drones where able to target non unit entities

Fixes by Jip:
- Unit bel0402 (Experimental Assault Bot) fixed issue with drones
- Unit uas0401 (Experimental Battleship) fixed issue with drones
- Unit bsl0401 (Experimental Hover Tank) fixed issue with drones

Fixes by Balthazar:
- Unit xsb1102 (Hydrocarbon Power Plant) was not buildable on tech 1
- Unit urb1102 (Hydrocarbon Power Plant) was not buildable on tech 1
- Unit uab1102 (Hydrocarbon Power Plant) was not buildable on tech 1
- Unit ueb1102 (Hydrocarbon Power Plant) was not buildable on tech 1

---

## v23 (05.May.2023)

- fixed a incompatibility with BrewLAN (Thanks to Balthazar)
- fixed a bug in case a air weapon has no RangeCategory UWRC_AntiAir

---

## v22 (03.May.2023)
Thanks to Balthazar who provided this patch.

- fixed a incompatibility with BrewLAN (missing SizeZ on units)

---

## v21 (24.Apr.2023)
Thanks to Jip who provided this patch.

- Unit baa0309 Illuminate - (T3 Air Transport) fix for cloak
- Unit beb4209 ATF-205 Preventer - (Anti-Teleport Field Tower) fix for cloak
- Unit bab4309 Quantum Wake Generator - (Anti-Teleport Generator) fix for cloak
- Unit brb4309 Shroud - (Anti-Teleport Tower) fix for cloak
- Unit bsb4309 Haazthue-Uhthena - (Anti-Teleport Tower) fix for cloak
- Unit beb4309 ATF-305 Preventer - (Anti-Teleport Field Tower) fix for cloak
- Unit brb4209 Mist - (Anti-Teleport Tower) fix for cloak
- Unit bsb4209 Haazthue-Uhthena - (Anti-Teleport Tower) fix for cloak
- Unit bab4209 Quantum Wake Generator - (Anti-Teleport Generator) fix for cloak
- drones no longer checks for target.Dead ~= nil; (it is sometimes false, not nil)

---

## v20 (21.Aug.2022)

- added missing translation tags in tooltip.lua
- added german translation (translation by John kobo)
- Unit bsl0310 (Lambda Equipped Assault Bot) Added StandUpright = true,
- Unit bsb2402 (Seraphim Quantum Rift Archway) Changed General.TechLevel from "RULEUTL_Basic" to "RULEUTL_Experimental"
- Unit bab1302 (Hydrocarbon Power Plant) Changed General.TechLevel from "RULEUTL_Basic" to "RULEUTL_Secret"
- Unit beb4309 (Anti-Teleport Field Tower) Changed General.TechLevel from "RULEUTL_Advanced" to "RULEUTL_Secret"
- Unit bab2404 (Artemis Satelite Control) Changed General.TechLevel from "RULEUTL_Secret" to "RULEUTL_Experimental"
- Unit beb1302 (Hydrocarbon Power Plant) Changed General.TechLevel from "RULEUTL_Basic" to "RULEUTL_Secret"
- Unit brb5205 (Advanced Air Staging Facility) Fixed Display.Abilities.
- Unit bss0401 (Experimental Dreadnought) Changed Damage for weapon (Hu Strategic Missile Defense) from 30 to 30000.
- Unit bra0309 (T3 Air Transport) Added missing transport capacity variable (Class1Capacity = 16,)
- Unit bsa0309 (Tech3 Air Transport) Added missing transport capacity variable (Class1Capacity = 32,)
- Unit bra0409 (Experimental Assault Transport) Added missing transport capacity variable (Class1Capacity = 20,)
- Unit baa0309 (T3 Air Transport) Added missing transport capacity variable (Class1Capacity = 24,)
- Unit bab2308 (Tactical Missile Launcher) fixed no damage on AMissileSerpentineProjectile

---

## v19 (22.Dec.2020)

- Unit UAA0310 Added VeteranMassMult = 0.5, to blueprint for propper veterancy calculation
- Unit UAS0401 Added VeteranMassMult = 0.5, to blueprint for propper veterancy calculation

- Unit BAA0309 Added TeleportDelay = 10, to blueprint to match FAF patch
- Unit BSB4209 Added TeleportDelay = 10, to blueprint to match FAF patch
