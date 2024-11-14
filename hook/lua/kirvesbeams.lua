---@class TargetingCollisionBeamBO : EmptyCollisionBeam
TargetingCollisionBeamBO = Class(EmptyCollisionBeam) {
    FxBeam = {
        '/effects/emitters/particle_cannon_beam_01_emit.bp',
        '/effects/emitters/particle_cannon_beam_02_emit.bp'
    },
}

---@class UnstablePhasonLaserCollisionBeam3 : UnstablePhasonLaserCollisionBeam2
UnstablePhasonLaserCollisionBeam3 = Class(UnstablePhasonLaserCollisionBeam2) {
    TerrainImpactScale = 0.2,
}
