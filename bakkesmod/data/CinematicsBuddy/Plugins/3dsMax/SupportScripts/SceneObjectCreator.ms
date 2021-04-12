-- SceneObjectCreator creates the objects necessary to rebuild the Rocket League scene inside 3ds Max.

-- Import CarDummy script so its functions can be called
FileIn(CBSupportScripts + "CarDummy.ms")
	
-- STRUCT DEFINITION --
struct StructSceneObjects
(
	MetadataDummy,
	ArenaMesh,
	BallMesh,
	CameraObject,
	CarDummies = #()
)
	
-- FUNCTION DEFINITION --
function CreateSceneObjects MetadataDummy CameraName = 
(
	SceneObjects = StructSceneObjects()
	
	-- Store MetadataDummy in SceneObjects so it can be easily passed around in functions
	SceneObjects.MetadataDummy = MetadataDummy
	local MetadataModifier = MetadataDummy.modifiers[1]
	
	-- Import arena mesh
	local ArenaLocation = CBModelAssets + "StadiumProxy.FBX"
	ImportFile ArenaLocation #noPrompt
	SceneObjects.ArenaMesh = $RL_STADIUM_PROXY
	SceneObjects.ArenaMesh.scale = [1,1,1]
	
	-- Import ball mesh
	local BallLocation = CBModelAssets + "BallProxy.FBX"
	ImportFile BallLocation #noPrompt
	SceneObjects.BallMesh = $RL_BALL_PROXY
	SceneObjects.BallMesh.scale = [1,1,1]
	
	-- Assign ball and arena names to MetadataDummy
	MetadataModifier.OtherArenaName = SceneObjects.ArenaMesh.name
	MetadataModifier.OtherBallName  = SceneObjects.BallMesh.name
	
	-- Import car mesh to assign to car dummies
	local CarLocation = CBModelAssets + "OctaneProxy.FBX"
	ImportFile CarLocation #noPrompt
	local CarMeshBase = $RL_OCTANE_PROXY
	CarMeshBase.scale = [1,1,1]
	
	-- Loop through car names from MetadataDummy and create dummies that hold their respective car data
	-- IMPORTANT: Maxscript starts with index 1, but the CarsSeen array starts at 0. This is handled internally in CreateCarDummy
	local CarNamesArray = FilterString MetadataModifier.CarNames "\n"
	local CarIndex = 1
	while CarIndex <= CarNamesArray.count do
	(
		local NewCarDummy = CreateCarDummy MetadataDummy CarIndex CarMeshBase
		
		
		
		NewCarDummy.pos = [0, 150 * CarIndex, 17] -- REMOVE WHEN DONE
		
		
		
		append SceneObjects.CarDummies NewCarDummy
		CarIndex += 1
	)
	
	-- Delete original car mesh as all the dummies made their own clones
	delete CarMeshBase
	
	return SceneObjects
)
