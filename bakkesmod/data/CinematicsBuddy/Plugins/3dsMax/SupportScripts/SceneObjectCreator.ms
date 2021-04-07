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
	local CarMesh = $RL_OCTANE_PROXY
	CarMesh.scale = [1,1,1]
	
	-- Loop through car names from MetadataDummy and create dummies that hold their respective car data
	local CarNamesArray = FilterString MetadataModifier.CarNames "\n"
	local CarIndex = 1
	while CarIndex <= CarNamesArray.count do
	(
		CreateCarDummy MetadataDummy CarIndex CarMesh
		CarIndex += 1
	)
	
	-- Delete original car mesh as all the dummies made their own clones
	delete CarMesh
	
	return SceneObjects
)
