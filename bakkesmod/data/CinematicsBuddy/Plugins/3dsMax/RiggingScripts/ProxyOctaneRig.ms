/*
	An example script for linking a car model's rig to the CinematicsBuddy car dummy
	
	A few general notes:
		- In order for this script to work, the MESH that you are trying to replace should be selected, not the dummy parent
		- Maxscript works best if all functions are defined before they are called
			- The actual functionality of this script is at the bottom of this file
			- Start from ProxyOctaneRigMain and trace through the functions called in that function
		- The script is filled with basic comments to help those with limited programming experience tailor the script to their needs
		- All mesh files are assumed to be in the /CinematicsBuddyAssets/Models/ folder
			- You can change that in the ProxyOctaneRigMain function if you want to use a different folder
		- Wheels indices are as follows:
			- 1: Front left
			- 2: Front right
			- 3: Back left
			- 4: Back right
*/

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
	if selection == undefined do
	(
		MessageBox("Nothing is selected. Please select the car mesh you want to replace.")
		return undefined
	)
	
	-- Get a reference to the first object in the selection
	local SelectedObject = selection[1]
	local DummyParent = SelectedObject.parent
	
	-- Ensure the mesh is selected and not the dummy
	if SuperClassOf SelectedObject != Geometry do
	(
		MessageBox("Selection is not geometry. Please select the car mesh you want to replace.")
		return undefined
	)
	
	-- Ensure the mesh has a dummy as its parent
	if DummyParent != undefined then
	(
		if SuperClassOf DummyParent != Helpers do
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
	CarInfo.CarFrontWheelRadius = CarFrontWheelRadius
	CarInfo.CarBackWheelRadius  = CarBackWheelRadius
	
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
function ImportProxyMeshes ModelsLocation WheelFile =
(
	-- Create empty struct that will be filled with the models and returned so other functions can access the models
	local TheMeshes = ProxyRigImportedModels()
	
	-- Import the Octane proxy body mesh and assign it to the output struct
	-- Use the name of the imported mesh to get a handle to it. Unfortunately I don't know of a better way of accessing a newly imported mesh
	local BodyMeshLocation = ModelsLocation + "OctaneProxyBody.FBX"
	ImportFile BodyMeshLocation #noPrompt
	TheMeshes.BodyMesh = $RL_OCTANE_PROXY_BODY
	
	-- Import the chosen wheel mesh and assign it based on the name that was provided in WheelFile
	local WheelMeshLocation = ModelsLocation + WheelFile
	ImportFile WheelMeshLocation #noPrompt
	case WheelFile of
	(
		"WheelProxy.FBX": TheMeshes.WheelMesh = $RL_WHEEL_PROXY
		-- "OtherFile1.FBX": TheMeshes.WheelMesh = $OTHER_WHEEL_MESH_NAME_1
		-- "OtherFile2.FBX": TheMeshes.WheelMesh = $OTHER_WHEEL_MESH_NAME_2
		-- etc. for more wheel options
	)
	
	-- Make sure both objects are at full scale
	if TheMeshes.BodyMesh  != undefined do TheMeshes.BodyMesh.scale  = [1,1,1]
	if TheMeshes.WheelMesh != undefined do TheMeshes.WheelMesh.scale = [1,1,1]
	
	-- Return the struct so the calling function can use the objects
	return TheMeshes
)


--------------------
-- RIG GENERATION --
--------------------
struct ProxyRigOctane
(
	RootObject = undefined,
	CarMesh    = undefined,
	WheelMeshes       = #(),
	BoostEmitters     = #(),
	SuspensionDummies = #(),
	SteeringDummies   = #(),
	SpinningDummies   = #()
)
function ProxyRigPlaceWheels TheMeshes TheRig CarInfo = 
(
	-- Clone the wheels
	for i = 1 to 4 do
	(
		MaxOps.CloneNodes TheMeshes.WheelMesh cloneType:#copy newNodes:&WheelMeshNode #nodialog
		Append TheRig.WheelMeshes WheelMeshNode[1]
	)
	
	-- Delete the original wheel mesh
	delete TheMeshes.WheelMesh
	
	-- Location and scale variables
	local FrontLeftLocation = [ 52.5, 27.5, -5.5]
	local BackLeftLocation  = [-34.0, 30.5, -4.0]
	local BackScaleRatio = CarInfo.CarBackWheelRadius / CarInfo.CarFrontWheelRadius
	
	--Transform the wheels
	
)
function GenerateProxyOctaneRig TheMeshes CarInfo = 
(
	local TheRig = ProxyRigOctane()
	
	-- Create the root object that all elements will be bound to
	local RootObjectName = CarInfo.CarName + " ROOT"
	TheRig.RootObject = PointHelperObj name:RootObjectName cross:false box:true size:100 wirecolor:[14,255,2]
	
	-- Assign the car mesh to the rig and rename it
	TheRig.CarMesh = TheMeshes.CarMesh
	TheRig.CarMesh.name = CarInfo.CarName + " BODY MESH"
	TheRig.CarMesh.parent = TheRig.RootObject
	
	-- Put the wheel meshes in the right places
	ProxyRigPlaceWheels TheMeshes TheRig CarInfo
)


-----------------
-- RIG BINDING --
-----------------
function MoveRigToParent TheRig DummyParent =
(
	-- Move the rig's root object to the DummyParent's location
	-- Make the rig's root object a child of DummyParent
)
function BindProxyOctaneRig TheRig DummyParent =
(
	-- Move the rig to the location of DummyParent and set DummyParent as the overall parent object
	MoveRigToParent TheRig DummyParent
	
	-- Wire all of the rig elements to the metadata modifier
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
	if DummyParent == undefined do return
	
	-- Get car name and wheel sizes from parent
	local CarInfo = GetCarInfo(DummyParent)
	
	-- Create local variables (not global) to easily access models folder relative to script location
	-- Script should be left in RiggingScripts folder for this example to work
	local ThisScriptLocation = PathConfig.RemovePathLeaf (GetSourceFileName())
	local ModelsLocation = ThisScriptLocation + "..\\..\\CinematicsBuddyAssets\\Models\\"
	
	-- Get meshes and make sure theyre valid before continuing
	local TheMeshes = ImportProxyMeshes ModelsLocation "WheelProxy.FBX"
	if TheMeshes.BodyMesh == undefined or TheMeshes.WheelMesh == undefined do
	(
		MessageBox("Car body mesh or wheel mesh are invalid")
		return
	)
	
	-- Create rig dummies and wheel set
	local TheRig = GenerateProxyOctaneRig TheMeshes CarInfo
	
	-- Bind the new dummy objects to the dummy parent
	BindProxyOctaneRig TheRig DummyParent
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