-- Create the following objects:
	-- Arena
	-- Ball
	-- Car dummies
		-- Dummy holds the data, car mesh is parented to dummy (boosts parented to car mesh?), car mesh has no data
	-- Camera
	
struct StructSceneObjects
(
	ArenaMesh,
	BallMesh,
	CameraObject,
	CarDummies = #()
)
	
function CreateSceneObjects MetadataDummy CameraName = 
(
	SceneObjects = StructSceneObjects()
	
	return SceneObjects
)
