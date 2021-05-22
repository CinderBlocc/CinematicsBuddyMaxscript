/*
	An example script for linking a car model's rig to the CinematicsBuddy car dummy
	
	For the most part you should only need to edit the RigCustomization struct at the top to fit the needs of your car model
	
	A few general notes:
		- In order for this script to work, the MESH that you are trying to replace should be selected, not the dummy parent
		- Maxscript works best if all functions are defined before they are called
			- The actual functionality of this script is at the bottom of this file
			- Start from ProxyOctaneRigMain and trace through the functions called in that function
		- The script is filled with basic comments to help those with limited programming experience tailor the script to their needs
		- All mesh files are assumed to be in the /CinematicsBuddyAssets/Models/ folder
			- You can change that in the ProxyOctaneRigMain function if you want to use a different folder
		- Wheels indices are as follows:
			- 1 (0 in UI): Front left
			- 2 (1 in UI): Front right
			- 3 (2 in UI): Back left
			- 4 (3 in UI): Back right
*/


-- This should be most of what you edit per car script
struct RigCustomization
(
	-- Create local variables (not global) to easily access models folder relative to script location
	-- If you don't want to use relative paths, you could define the full path to your models' locations
	ScriptLocation = PathConfig.RemovePathLeaf (GetSourceFileName()) + "\\",
	ModelsLocation = ScriptLocation + "..\\..\\CinematicsBuddyAssets\\Models\\",
	
	-- Which car file to import
	CarFile = "OctaneProxyBody.FBX",
	ImportedCarName = "RL_OCTANE_PROXY_BODY",
	LowerSuspensionRodName = "??????????????????????????",
	UpperSuspensionRodName = "??????????????????????????",
	
	-- Which wheel file to import
	WheelFile = "WheelProxy.FBX",
	ImportedWheelName = "RL_WHEEL_PROXY",
	
	-- Color of dummies
	DummyColor = [14,255,2],
	
	-- Locations of rig pieces (symmetric, so only define left side)
	FrontWheelLocation           = [ 52.5, 27.5, -5.5],
	BackWheelLocation            = [-34.0, 30.5, -4.0],
	FrontSuspensionLowerLocation = [ 52.5,  4.5, -5.5],
	BackSuspensionLowerLocation  = [-34.0,  6.0, -4.0],
	FrontSuspensionUpperLocation = [ 52.5,  7.0,  7.0],
	BackSuspensionUpperLocation  = [-34.0, 17.5, 16.5],
	
	-- Boost emitter info
	BoostEmitterLocation = [-47.0,  7.0,  8.0],
	bIsDoubleEmitter = true
)


------------------
-- DUMMY PARENT --
------------------
struct ProxyRigCarInfo
(
	CarName = "UNDEFINED NAME",
	CarFrontWheelRadius = -1.0,
	CarBackWheelRadius  = -1.0
)
function GetDummyParentAndDeleteSelectedMesh =
(
	-- Make sure an object is selected
	if selection.count < 1 do
	(
		MessageBox("Nothing is selected. Please select the car mesh you want to replace.")
		return undefined
	)
	
	-- Get a reference to the first object in the selection
	local SelectedObject = selection[1]
	local DummyParent = SelectedObject.parent
	
	-- Ensure the mesh is selected and not the dummy
	if SuperClassOf SelectedObject != GeometryClass do
	(
		MessageBox("Selection is not geometry. Please select the car mesh you want to replace.")
		return undefined
	)
	
	-- Ensure the mesh has a dummy as its parent
	if DummyParent != undefined then
	(
		if SuperClassOf DummyParent != Helper do
		(
			MessageBox("Selection's parent is not a dummy. Please select a valid CinematicsBuddy imported car mesh.")
			return undefined
		)
	)
	else
	(
		MessageBox("Selection has no parent object. Please select a valid CinematicsBuddy imported car mesh.")
		return undefined
	)
	
	-- Ensure dummy has a valid metadata modifier
	local TheModifier = DummyParent.Modifiers[1]
	if TheModifier != undefined then
	(
		if TheModifier.CarName == undefined do -- Chances are the script will stop executing here if it tries accessing a nonexistant CarName variable
		(
			MessageBox("DummyParent has no metadata modifier. Please select a valid CinematicsBuddy imported car mesh.")
			return undefined
		)
	)
	else
	(
		MessageBox("DummyParent has no modifiers. Please select a valid CinematicsBuddy imported car mesh.")
		return undefined
	)
	
	-- Delete the mesh and return a reference to the parent object
	delete SelectedObject
	return DummyParent
)
function GetCarInfo DummyParent =
(
	local CarInfo = ProxyRigCarInfo()
	
	local TheModifier = DummyParent.Modifiers[1]
	CarInfo.CarName = TheModifier.CarName
	CarInfo.CarFrontWheelRadius = TheModifier.CarFrontWheelRadius
	CarInfo.CarBackWheelRadius  = TheModifier.CarBackWheelRadius
	
	return CarInfo
)


--------------------
-- MESH IMPORTING --
--------------------
struct ProxyRigImportedModels
(
	BodyMesh  = undefined,
	WheelMesh = undefined
)
function ImportProxyMeshes =
(
	local CustomizationInfo = RigCustomization()
	
	-- Create empty struct that will be filled with the models and returned so other functions can access the models
	local TheMeshes = ProxyRigImportedModels()
	
	-- Import the Octane proxy body mesh and assign it to the output struct
	local BodyMeshLocation = CustomizationInfo.ModelsLocation + CustomizationInfo.CarFile
	ImportFile BodyMeshLocation #noPrompt
	TheMeshes.BodyMesh = GetNodeByName(CustomizationInfo.ImportedCarName)
	
	-- Import the proxy wheel mesh and assign it to the output struct
	local WheelMeshLocation = CustomizationInfo.ModelsLocation + CustomizationInfo.WheelFile
	ImportFile WheelMeshLocation #noPrompt
	TheMeshes.WheelMesh = GetNodeByName(CustomizationInfo.ImportedWheelName)
	
	-- Ensure both objects are at full scale. Warn if either is invalid.
	if TheMeshes.BodyMesh != undefined then TheMeshes.BodyMesh.scale = [1,1,1]
	else MessageBox("TheMeshes.BodyMesh is undefined")
	if TheMeshes.WheelMesh != undefined then TheMeshes.WheelMesh.scale = [1,1,1]
	else MessageBox("TheMeshes.WheelMesh is undefined")
	
	-- Return the struct so the calling function can use the objects
	return TheMeshes
)


--------------------
-- RIG GENERATION --
--------------------
struct ProxyRigOctane
(
	RootObject = undefined,
	BodyMesh   = undefined,
	WheelMeshes       = #(),
	BoostEmitters     = #(),
	SteeringDummies   = #(),
	SpinningDummies   = #(),
	SuspensionLowerDummies = #(),
	SuspensionUpperDummies = #()
)
function ProxyRigMirrorObject ObjectToMirror OriginalObject bInvertScale =
(
	ObjectToMirror.transform = OriginalObject.transform
	ObjectToMirror.pos.y *= -1
	
	if bInvertScale do ObjectToMirror.scale.y *= -1
)
function ProxyRigPlaceWheels TheMeshes TheRig CarInfo = 
(
	-- Clone the wheels
	for i = 1 to 4 do
	(
		MaxOps.CloneNodes TheMeshes.WheelMesh cloneType:#copy newNodes:&WheelMeshNode #nodialog
		local NewWheel = WheelMeshNode[1]
		NewWheel.name = CarInfo.CarName + " WHEEL " + ((i - 1) as string)
		Append TheRig.WheelMeshes NewWheel
	)
	
	-- Delete the original wheel mesh
	delete TheMeshes.WheelMesh
	
	-- Location and scale variables
	local CustomizationInfo = RigCustomization()
	local BackScaleRatio = CarInfo.CarBackWheelRadius / CarInfo.CarFrontWheelRadius
	
	-- Transform the front wheels
	TheRig.WheelMeshes[1].pos = CustomizationInfo.FrontWheelLocation
	ProxyRigMirrorObject TheRig.WheelMeshes[2] TheRig.WheelMeshes[1] true
	
	-- Transform the back wheels
	TheRig.WheelMeshes[3].pos = CustomizationInfo.BackWheelLocation
	ProxyRigMirrorObject TheRig.WheelMeshes[4] TheRig.WheelMeshes[3] true
	TheRig.WheelMeshes[3].scale *= [BackScaleRatio, 1, BackScaleRatio]
	TheRig.WheelMeshes[4].scale *= [BackScaleRatio, 1, BackScaleRatio]
)
function GenerateProxyOctaneRigDummies TheRig CarInfo = 
(
	local CustomizationInfo = RigCustomization()
	
	-- Create the root object that all elements will be bound to
	local RootObjectName = CarInfo.CarName + " ROOT"
	TheRig.RootObject = PointHelperObj name:RootObjectName cross:false box:true size:100 wirecolor:CustomizationInfo.DummyColor
	
	-- Create arrays of transforms to iterate dummy creation
	local WheelLocations = #()
	local SuspensionLowerLocations = #()
	local SuspensionUpperLocations = #()
	local Scales = #()
	append WheelLocations  CustomizationInfo.FrontWheelLocation
	append WheelLocations (CustomizationInfo.FrontWheelLocation * [1, -1, 1])
	append WheelLocations  CustomizationInfo.BackWheelLocation
	append WheelLocations (CustomizationInfo.BackWheelLocation * [1, -1, 1])
	append SuspensionLowerLocations  CustomizationInfo.FrontSuspensionLowerLocation
	append SuspensionLowerLocations (CustomizationInfo.FrontSuspensionLowerLocation * [1, -1, 1])
	append SuspensionLowerLocations  CustomizationInfo.BackSuspensionLowerLocation
	append SuspensionLowerLocations (CustomizationInfo.BackSuspensionLowerLocation * [1, -1, 1])
	append SuspensionUpperLocations  CustomizationInfo.FrontSuspensionUpperLocation
	append SuspensionUpperLocations (CustomizationInfo.FrontSuspensionUpperLocation * [1, -1, 1])
	append SuspensionUpperLocations  CustomizationInfo.BackSuspensionUpperLocation
	append SuspensionUpperLocations (CustomizationInfo.BackSuspensionUpperLocation * [1, -1, 1])
	local BackScaleRatio = CarInfo.CarBackWheelRadius / CarInfo.CarFrontWheelRadius
	append Scales 1
	append Scales 1
	append Scales BackScaleRatio
	append Scales BackScaleRatio
	
	-- Create the dummies
	for i = 1 to 4 do
	(		
		local SteeringName  = TheRig.WheelMeshes[i].name + " STEERING"
		local SteeringDummy = PointHelperObj name:SteeringName cross:false box:true axistripod:false size:15 wirecolor:CustomizationInfo.DummyColor
		SteeringDummy.pos   = WheelLocations[i]
		append TheRig.SteeringDummies SteeringDummy
		
		local SpinningName  = TheRig.WheelMeshes[i].name + " SPINNING"
		local SpinningDummy = PointHelperObj name:SpinningName cross:false box:true axistripod:false size:(35*Scales[i]) wirecolor:CustomizationInfo.DummyColor
		SpinningDummy.pos   = WheelLocations[i]
		append TheRig.SpinningDummies SpinningDummy
		
		local SuspensionLowerName   = TheRig.WheelMeshes[i].name + " SUSPENSION LOWER"
		local SuspensionLowerDummy = PointHelperObj name:SuspensionLowerName cross:false box:true axistripod:false size:10 wirecolor:CustomizationInfo.DummyColor
		SuspensionLowerDummy.pos    = SuspensionLowerLocations[i]
		append TheRig.SuspensionLowerDummies SuspensionLowerDummy
		
		local SuspensionUpperName   = TheRig.WheelMeshes[i].name + " SUSPENSION UPPER"
		local SuspensionUpperDummy = PointHelperObj name:SuspensionUpperName cross:false box:true axistripod:false size:10 wirecolor:CustomizationInfo.DummyColor
		SuspensionUpperDummy.pos    = SuspensionUpperLocations[i]
		append TheRig.SuspensionUpperDummies SuspensionUpperDummy
	)
)
function GenerateProxyOctaneBoostEmitters TheRig CarInfo = 
(
	local CustomizationInfo = RigCustomization()
	
	-- Create first boost source
	local BoostBaseName = CarInfo.CarName + " Boost"
	local BoostLeftName = BoostBaseName
	if CustomizationInfo.bIsDoubleEmitter do (BoostLeftName = BoostBaseName + " Left")
	local BoostLeft = PF_Source name:BoostLeftName pos:CustomizationInfo.BoostEmitterLocation Logo_Size:5 Emitter_Length:6 Emitter_Width:20 X_Coord:20 Y_Coord:0 Quantity_Viewport:100
	
	particleFlow.beginEdit()
	-- EVENT 1: EMISSION
	Event1 = Event name:(CarInfo.CarName + " Boost Birth")
	Event1.SetPViewLocation (BoostLeft.X_Coord) (BoostLeft.Y_Coord + 100)
	
	-- EVENT 2: DESIGN AND DISPLAY
	Event2 = Event name:(CarInfo.CarName + " Standard Boost")
	Event2.SetPViewLocation (BoostLeft.X_Coord) (BoostLeft.Y_Coord + 210)
	
	-- EVENT 3: DELETE
	Event3 = Event name:(CarInfo.CarName + " Age Delete Boost")
	Event3.SetPViewLocation (BoostLeft.X_Coord) (BoostLeft.Y_Coord + 400)
	particleFlow.endEdit()
	
	-- EVENT 1
		-- Emitter operator to spawn particles. As soon as they spawn, throw to next event (design and display)
		particleFlow.beginEdit()
		OpEmitter     = Birth Type:1 Rate:300 Emit_Start:(AnimationRange.Start as integer) Emit_Stop:(AnimationRange.End as integer)
		ThrowToEvent2 = Age_Test Test_Value:0 Variation:0
		particleFlow.endEdit()
		
		ThrowToEvent2.SetNextActionList Event2 ThrowToEvent2
		
		Event1.AppendAction OpEmitter
		Event1.AppendAction ThrowToEvent2
	
	-- EVENT 2
		--Design and display particles. After a certain age, throw to next event (delete)
		particleFlow.beginEdit()
		OpPosition         = Position_Icon()
		OpSpeed            = Speed speed:10
		OpParticleShape    = ShapeLibrary Type_3D:14 size:5
		ThrowToEvent3      = Age_Test Test_Value:4000 Variation:800
		OpDisplayParticles = DisplayParticles type:6 color:[255,255,85]
		particleFlow.endEdit()
		
		ThrowToEvent3.SetNextActionList Event3 ThrowToEvent3
		
		Event2.AppendAction OpPosition
		Event2.AppendAction OpSpeed
		Event2.AppendAction OpParticleShape
		Event2.AppendAction ThrowToEvent3
		Event2.AppendAction OpDisplayParticles
	
	-- EVENT 3
		particleFlow.beginEdit()
		OpDelete = DeleteParticles()
		particleFlow.endEdit()
		Event3.AppendAction OpDelete
	
	-- Create renderers and caches
	particleFlow.beginEdit()
	RendererLeft = RenderParticles name:(CarInfo.CarName + " Render Left")
	CacheLeft = Cache Use_At:0
	particleFlow.endEdit()
	
	BoostLeft.AppendAction RendererLeft
	BoostLeft.AppendAction CacheLeft
	BoostLeft.AppendInitialActionList Event1
	BoostLeft.rotation.y_rotation = 90
	append TheRig.BoostEmitters BoostLeft
	
	if CustomizationInfo.bIsDoubleEmitter do
	(
		local BoostRight = PF_Source name:(BoostBaseName + " Right") pos:(CustomizationInfo.BoostEmitterLocation * [1,-1,1]) Logo_Size:5 Emitter_Length:6 Emitter_Width:20 X_Coord:50 Y_Coord:0 Quantity_Viewport:100
		
		particleFlow.beginEdit()
		RendererRight = RenderParticles name:(CarInfo.CarName + " Render Right")
		CacheRight = Cache Use_At:0
		particleFlow.endEdit()
		
		BoostRight.AppendAction RendererRight
		BoostRight.AppendAction CacheRight
		BoostRight.AppendInitialActionList Event1
		BoostRight.rotation.y_rotation = 90
		append TheRig.BoostEmitters BoostRight
	)
)
function GenerateProxyOctaneRig TheMeshes CarInfo = 
(
	local TheRig = ProxyRigOctane()
	
	-- Assign the car mesh to the rig and rename it
	TheRig.BodyMesh = TheMeshes.BodyMesh
	TheRig.BodyMesh.name = CarInfo.CarName + " BODY MESH"
	
	-- Put the wheel meshes in the right places and name them
	ProxyRigPlaceWheels TheMeshes TheRig CarInfo
	
	-- Generate all of the necessary dummy objects
	GenerateProxyOctaneRigDummies TheRig CarInfo
	
	-- Generate boost emitters
	GenerateProxyOctaneBoostEmitters TheRig CarInfo
)


-----------------
-- RIG BINDING --
-----------------
function ConstrainProxyOctaneRig TheRig = 
(
	
)
function MoveProxyOctaneRigToParent TheRig DummyParent =
(
	-- Move the rig's root object to the DummyParent's location
	-- Make the rig's root object a child of DummyParent
)
function WireProxyOctaneRigParameters TheRig DummyParent = 
(
	
)
function BindProxyOctaneRig TheRig DummyParent =
(
	-- Apply all the internal contstraints before moving to the parent
	ConstrainProxyOctaneRig TheRig
	
	-- Move the rig to the location of DummyParent and set DummyParent as the overall parent object
	MoveProxyOctaneRigToParent TheRig DummyParent
	
	-- Wire all of the rig elements to the metadata modifier
	WireProxyOctaneRigParameters TheRig DummyParent
)


------------------------
-- MAIN FUNCTIONALITY --
------------------------
-- Note the main function is actually a function instead of loose code
-- This lets us keep all of our variables local instead of global to prevent namespace pollution
-- ProxyOctaneRigMain is called just below its definition
function ProxyOctaneRigMain = 
(
	-- Obtain selected mesh's parent and delete the mesh
	-- If the selected object was not a mesh or had no parent with a valid modifier, it will be undefined
	local DummyParent = GetDummyParentAndDeleteSelectedMesh()
	if DummyParent == undefined do return false
	
	-- Get car name and wheel sizes from parent
	local CarInfo = GetCarInfo(DummyParent)
	
	-- Get meshes and make sure theyre valid before continuing
	local TheMeshes = ImportProxyMeshes()
	if TheMeshes.BodyMesh == undefined or TheMeshes.WheelMesh == undefined do return false
	
	-- Create rig dummies and wheel set
	local TheRig = GenerateProxyOctaneRig TheMeshes CarInfo
	
	-- Bind the new dummy objects to the dummy parent
	BindProxyOctaneRig TheRig DummyParent
	
	return true
)

--- Run the full script ----
ProxyOctaneRigMain() ----
----------------------------




/*
function importCar carNum = 
(
	deselect selection
	ImportFile "F:\\_YouTube\\04_Extra_Assets\\3D_Models_and_Scenes\\Rocket_League_Models\\Car_Octane_Rigged.FBX" #noPrompt
	for obj in selection do
	(
		obj.scale = [1, 1, 1]
		carNumString = carNum as string
		baseName = obj.name
		newName = "TEMPIMPORT_" + baseName
		obj.name = newName
	)
	
	--HELPER CREATION
	tempHelpers = #()
	tempHelperName = "TEMPHELPER"
	helperName = tempHelperName + 1 as string
	tempHelpers[1] = PointHelperObj name:helperName cross: true box: false size: 100 wirecolor:[14,255,2] --core helper
	for j=2 to 5 do (
		helperName = tempHelperName + j as string
		tempHelpers[j] = PointHelperObj name:helperName cross: false box: true size: 10 wirecolor:[14,255,2]
	) --axel helper
	for j=6 to 9 do (
		helperName = tempHelperName + j as string
		tempHelpers[j] = PointHelperObj name:helperName cross: false box: true size: 7.5 wirecolor:[14,255,2]
	) --spring helper
	for j=10 to 13 do (
		helperName = tempHelperName + j as string
		tempHelpers[j] = PointHelperObj name:helperName cross: true box: false size: 5 wirecolor:[14,255,2]
	) --cup helper
	for j=14 to 17 do (
		helperName = tempHelperName + j as string
		tempHelpers[j] = PointHelperObj name:helperName cross: false box: true size: 30 wirecolor:[14,255,2]
	) --wheel helper
	append carHelpers tempHelpers
	--format "carHelpers.count = %\n" carHelpers.count as string
	
	--CAR PART STORING
	tempParts = #()
	tempParts[1] = $TEMPIMPORT_RL_OCTANE_CLEAN
	tempParts[2] = $TEMPIMPORT_FL_Axel
	tempParts[3] = $TEMPIMPORT_FR_Axel
	tempParts[4] = $TEMPIMPORT_BL_Axel
	tempParts[5] = $TEMPIMPORT_BR_Axel
	tempParts[6] = $TEMPIMPORT_FL_Spring
	tempParts[7] = $TEMPIMPORT_FR_Spring
	tempParts[8] = $TEMPIMPORT_BL_Spring
	tempParts[9] = $TEMPIMPORT_BR_Spring
	tempParts[10] = $TEMPIMPORT_FL_Cup
	tempParts[11] = $TEMPIMPORT_FR_Cup
	tempParts[12] = $TEMPIMPORT_BL_Cup
	tempParts[13] = $TEMPIMPORT_BR_Cup
	tempParts[14] = $TEMPIMPORT_FL_Brakes
	tempParts[15] = $TEMPIMPORT_FR_Brakes
	tempParts[16] = $TEMPIMPORT_BL_Brakes
	tempParts[17] = $TEMPIMPORT_BR_Brakes
	tempParts[18] = $TEMPIMPORT_FL_Wheel
	tempParts[19] = $TEMPIMPORT_FR_Wheel
	tempParts[20] = $TEMPIMPORT_BL_Wheel
	tempParts[21] = $TEMPIMPORT_BR_Wheel
	append carParts tempParts
	
	--MAKING PFLOW
	--(
	individualCarBoosts = #()
	tempBoost = PF_Source name:"TEMPBOOST1" pos:[-48,9,9] Logo_Size:5 Emitter_Length:6 Emitter_Width:20 X_Coord:20 Y_Coord:0 Quantity_Viewport:100
	append individualCarBoosts tempBoost
	tempBoost = PF_Source name:"TEMPBOOST2" pos:[-48,-9,9] Logo_Size:5 Emitter_Length:6 Emitter_Width:20 X_Coord:50 Y_Coord:0 Quantity_Viewport:100
	append individualCarBoosts tempBoost
	individualCarBoosts[1].rotation.y_rotation = 90
	individualCarBoosts[2].rotation.y_rotation = 90
	individualCarBoosts[1].parent = tempParts[1]
	individualCarBoosts[2].parent = tempParts[1]
	particleFlow.BeginEdit()
	cache1 = Cache Use_At:0
	cache2 = Cache Use_At:0
	op1 = Birth Type:1 Rate:300 Emit_Start:(animationRange.start as integer) Emit_Stop:(animationRange.end as integer)
	swapOp = Age_Test Test_Value:0 Variation:0
	op2 = Position_Icon()
	op3 = Speed speed:10
	op4 = ShapeLibrary Type_3D:14 size:5
	renderer1 = RenderParticles name:"Render Car 1 Boost 1"
	renderer2 = RenderParticles name:"Render Car 1 Boost 2"
	op5 = Age_Test Test_Value:4000 Variation:800
	op6 = DisplayParticles type:6 color:[255,255,85]
	ev1 = Event name:"Boost Birth"
	ev1.SetPViewLocation (individualCarBoosts[1].X_Coord) (individualCarBoosts[1].Y_Coord+100)
	ev2 =Event name:"Standard Boost"
	ev2.SetPViewLocation (individualCarBoosts[1].X_Coord) (individualCarBoosts[1].Y_Coord+210)
	ev3 = Event name:"Age Delete Boost"
	ev3.SetPViewLocation (individualCarBoosts[1].X_Coord) (individualCarBoosts[1].Y_Coord+400)
	ev3op1 = deleteParticles()
	particleFlow.EndEdit()
	
	--ev1.AppendAction op0
	ev1.AppendAction op1
	ev1.AppendAction swapOp
	ev2.AppendAction op2
	ev2.AppendAction op3
	ev2.AppendAction op4
	ev2.AppendAction op5
	ev2.AppendAction op6
	swapOp.setNextActionList ev2 swapOp
	ev3.AppendAction ev3op1
	op5.setNextActionList ev3 op5
	
	individualCarBoosts[1].AppendAction renderer1
	individualCarBoosts[1].AppendAction cache1
	individualCarBoosts[1].AppendInitialActionList ev1
	individualCarBoosts[2].AppendAction renderer2
	individualCarBoosts[2].AppendAction cache2
	individualCarBoosts[2].AppendInitialActionList ev1
	
	append carBoosts individualCarBoosts
	
	--)

	--MAKING CUSTOM BOOST ATTRIBUTES
	--(
	BoostControls = attributes boostControlAttributes
	(
		parameters params rollout:ro_BoostControls
		(
			isBoosting type:#integer ui:boostctrlActive
			boostRate type:#integer ui:boostctrlRate
			hasJumped type:#integer ui:boostctrlJumped
		)
		rollout ro_BoostControls "Boost and Jump Controls"
		(
			spinner boostctrlRate "Boost rate: " pos:[-7,5] range:[0,1000000,60] type:#integer width:160
			slider boostctrlActive "Is Boosting" pos:[2,25] range:[0,1,0] type:#integer width:165
			slider boostctrlJumped "Has Jumped" pos:[2,77] range:[0,1,0] type:#integer width:165
		)
	)

	custAttributes.add tempHelpers[1] BoostControls --BaseObject:true
	tempHelpers[1].boostControlAttributes.boostRate.controller = bezier_float()
	tempHelpers[1].boostControlAttributes.boostRate.controller.value = 300
	tempHelpers[1].boostControlAttributes.isBoosting.controller = boolean_float()
	tempHelpers[1].boostControlAttributes.hasJumped.controller = boolean_float()
	
	
	
	SuspensionControls = attributes suspensionControlAttributes
	(
		parameters params rollout:ro_SuspensionControls
		(
			suspensionMaxAmount type:#integer ui:susMaxAmount
			suspensionPitch type:#float ui:susPitch
			suspensionRoll type:#float ui:susRoll
		)
		rollout ro_SuspensionControls "Suspension Controls"
		(
			spinner susMaxAmount "Max Suspension: " pos:[7,5] range:[0,10,0] type:#float width:150
			slider susPitch "Pitch" pos:[2,25] range:[-1,1,0] type:#float width:165
			slider susRoll "Roll" pos:[2,77] range:[-1,1,0] type:#float width:165
		)
	)

	custAttributes.add tempHelpers[1] SuspensionControls --BaseObject:true
	tempHelpers[1].suspensionControlAttributes.suspensionMaxAmount.controller = bezier_float()
	tempHelpers[1].suspensionControlAttributes.suspensionMaxAmount.controller.value = 0
	tempHelpers[1].suspensionControlAttributes.suspensionPitch.controller = bezier_float()
	tempHelpers[1].suspensionControlAttributes.suspensionRoll.controller = bezier_float()
	--)



	
	-- Align and parent helper objects to individual parts
	for p=1 to carHelpers[carNum].count do
	(
		carHelpers[carNum][p].pos = carParts[carNum][p].pos
		carParts[carNum][p].parent = carHelpers[carNum][p]
	)
	for p=2 to 5 do (carHelpers[carNum][p].parent = carHelpers[carNum][1]) -- Parent axel helpers to core helper
	for p=10 to 13 do (carHelpers[carNum][p].parent = carHelpers[carNum][1]) -- Parent cup helpers to core helper
	for p=6 to 9 do(carHelpers[carNum][p].parent = carHelpers[carNum][p-4]) -- Parent spring helpers to corresponding axel helper
	for p=14 to 17 do (carHelpers[carNum][p].parent = carHelpers[carNum][p-12]) -- Parent wheel helpers to corresponding axel helper
	for p=18 to 21 do (carParts[carNum][p].parent = carHelpers[carNum][p-4]) -- Parent wheels to corresponding wheel helpers
	
	-- Assign lookat to cup models
	for p=10 to 13 do
	(
		carParts[carNum][p].rotation.controller = LookAt_Constraint()
		carParts[carNum][p].rotation.controller.appendTarget carHelpers[carNum][p-4] 100
		carParts[carNum][p].rotation.controller.lookat_vector_length = 0
		carParts[carNum][p].rotation.controller.target_axis = 2
		carParts[carNum][p].rotation.controller.target_axisFlip = true
	)
	
	-- Assign lookat to spring models
	for p=6 to 9 do
	(
		carParts[carNum][p].rotation.controller = LookAt_Constraint()
		carParts[carNum][p].rotation.controller.appendTarget carHelpers[carNum][p+4] 100
		carParts[carNum][p].rotation.controller.lookat_vector_length = 0
		carParts[carNum][p].rotation.controller.target_axis = 2
	)
	
	for obj in carParts[carNum] do
	(
		baseName = obj.name
		--format "baseName: % -- " obj.name
		newName = replace baseName 1 10 ("Car_" + carNum as string)
		obj.name = newName
		--format "newName: %\n" newName
	)
	
	for p=1 to carHelpers[carNum].count do
	(
		carHelpers[carNum][p].name = carParts[carNum][p].name + "_Helper"
		--format "helper name: %\n" carHelpers[carNum][p].name
	)
	
	carBoosts[carNum][1].name = ("Car_" + carNum as string + "Boost_1")
	carBoosts[carNum][2].name = ("Car_" + carNum as string + "Boost_2")
	
	deselect selection
	
	--carNum += 1
)
*/