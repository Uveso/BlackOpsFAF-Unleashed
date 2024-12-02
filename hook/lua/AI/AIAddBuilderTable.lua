local OLDAddGlobalBaseTemplate = AddGlobalBaseTemplate

---@param aiBrain AIBrain
---@param locationType string
---@param baseBuilderName string
function AddGlobalBaseTemplate(aiBrain, locationType, baseBuilderName)
    SPEW('BlackOpsFAF-Unleashed: Injecting BuilderGroup "BO-HydroCarbonUpgrade"')
    AddGlobalBuilderGroup(aiBrain, locationType, 'BO-HydroCarbonUpgrade')
    OLDAddGlobalBaseTemplate(aiBrain, locationType, baseBuilderName)
end
