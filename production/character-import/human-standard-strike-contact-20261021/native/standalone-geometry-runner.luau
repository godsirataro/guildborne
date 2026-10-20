local run=require("../production/character-import/local-contact-geometry-check")
local geometry=require("../src/shared/Presentation/ModularAppearance/LocalContactGeometry")
local result=run(geometry,false)
print("Geometry assertions passed:",result.passed,"Native cases:",result.nativeCases)
