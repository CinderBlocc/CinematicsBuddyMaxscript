-- Create the following objects:
	-- Arena
	-- Ball
	-- Car dummies
		-- Dummy holds the data, car mesh is parented to dummy (boosts parented to car mesh?), car mesh has no data
	-- Camera
	
-- MetadataDummy is stored in here to easily pass into the "ApplyNextKeyframe" function

-- When "Arena" and "Ball" are spawned, assign their names to MetadataDummy
	
struct StructSceneObjects
(
	MetadataDummy,
	ArenaMesh,
	BallMesh,
	CameraObject,
	CarDummies = #()
)
	
function CreateSceneObjects MetadataDummy CameraName = 
(
	SceneObjects = StructSceneObjects()
	SceneObjects.MetadataDummy = MetadataDummy
	
	return SceneObjects
)
