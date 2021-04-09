-- Script to create car dummy object
-- Dummy object will have the car mesh as a child, and will contain all the special data
	-- i.e. suspension distance animation, boost toggle, etc.
	
CreateCarDummy undefined 1 undefined
	
function CreateCarDummy MetadataDummy CarIndex CarMeshBase =
(
	-- Use MetadataDummy to collect the information about the car
		-- CarIndex is passed in from the loop in SceneObjectCreator to indicate which car's information to take from MetadataDummy
	-- CarMesh is the single mesh that was imported. Make a clone and make it a child of the dummy object
	
	/*
	-- Get information about this car from MetadataDummy
	local CarInfo = GetCarInfo MetadataDummy CarIndex
	local CarIndexString = CarIndex as string
	local CarNameBase = CarIndexString + ":" + CarInfo.CarName
	*/local CarNameBase = "CarNameBase"
	
	-- Create DummyObject
	local DummyObjectName = CarNameBase + " DUMMY"
	local DummyObject = PointHelperObj name:DummyObjectName cross: true box: false size: 100 wirecolor:[14,255,2]
	
	-- Add custom attributes
	AddModifier DummyObject (EmptyModifier())
	local TheModifier = DummyObject.modifiers[1]
	TheModifier.name = "Car Data"
	CarDataModifier = attributes CarDataAttributes
	(
		-- Metadata
		parameters metadataparams rollout:ro_metadata
		(
			CarName             type:#string  ui:TextBoxCarName
			CarBodyID           type:#integer ui:SpinnerCarBodyID
			CarBackWheelRadius  type:#float   ui:SpinnerBackWheelRadius
			CarFrontWheelRadius type:#float   ui:SpinnerFrontWheelRadius
		)
		rollout ro_metadata "Metadata"
		(
			edittext TextboxCarName          "Name"               width:152 pos:[5,2]    readonly:true
			spinner  SpinnerCarBodyID        "Body ID"            width:179 pos:[-22,23] type:#integer enabled:false
			spinner  SpinnerBackWheelRadius  "Back Wheel Radius " width:142 pos:[15,43]  type:#float   enabled:false
			spinner  SpinnerFrontWheelRadius "Front Wheel Radius" width:140 pos:[17,63]  type:#float   enabled:false
		)
		
		-- Animation data
		parameters animationparams rollout:ro_animation
		(
			IsBoosting            type:#boolean ui:CheckboxIsBoosting
			Wheel0_SteerAmount    type:#float   ui:Spinner_W0_SteerAmount
			Wheel0_SuspensionDist type:#float   ui:Spinner_W0_SuspensionDist
			Wheel0_SpinSpeed      type:#float   ui:Spinner_W0_SpinSpeed
			/*Wheel1_SteerAmount    type:#float   ui:Spinner_W1_SteerAmount
			Wheel1_SuspensionDist type:#float   ui:Spinner_W1_SuspensionDist
			Wheel1_SpinSpeed      type:#float   ui:Spinner_W1_SpinSpeed
			Wheel2_SteerAmount    type:#float   ui:Spinner_W2_SteerAmount
			Wheel2_SuspensionDist type:#float   ui:Spinner_W2_SuspensionDist
			Wheel2_SpinSpeed      type:#float   ui:Spinner_W2_SpinSpeed
			Wheel3_SteerAmount    type:#float   ui:Spinner_W3_SteerAmount
			Wheel3_SuspensionDist type:#float   ui:Spinner_W3_SuspensionDist
			Wheel3_SpinSpeed      type:#float   ui:Spinner_W3_SpinSpeed*/
		)
		rollout ro_animation "Animation Data"
		(
			checkbox CheckboxIsBoosting "Boosting" align:#center
			label LabelWheel0 "------------- WHEEL 0 ------------- " align:#center
			spinner Spinner_W0_SteerAmount    "Steer Amount"
			spinner Spinner_W0_SuspensionDist "Suspension Distance"
			spinner Spinner_W0_SpinSpeed      "Spin Speed" pos:[5, 200]
			label LabelWheel1 "------------- WHEEL 1 ------------- " align:#center
		)
	)
	CustAttributes.Add TheModifier CarDataModifier
	
	/*
	-- Clone car mesh and parent it to DummyObject. CarMeshNode is created in the CloneNodes call
	MaxOps.CloneNodes CarMeshBase cloneType:#copy newNodes:&CarMeshNode #nodialog
	local CarMesh = CarMeshNode[1]
	CarMesh.name = CarNameBase + " MESH"
	CarMesh.parent = DummyObject
	
	DummyObject.pos = [150 * CarIndex, 0, 17] -- REMOVE WHEN DONE
	
	return DummyObject
	*/select DummyObject
)

-- INFORMATION FROM METADATADUMMY --
struct StructCarInfo
(
	CarName,
	BodyID,
	BackWheelRadius,
	FrontWheelRadius
)

function GetCarInfo MetadataDummy CarIndex =
(
	local CarInfo = StructCarInfo()
	
	local MetadataModifier = MetadataDummy.modifiers[1]
	local CarNames = FilterString MetadataModifier.CarNames "\n"
	local BodyIDs = FilterString MetadataModifier.CarBodyIDs "\n"
	local BackWheelRadii = FilterString MetadataModifier.CarBackWheelRadii "\n"
	local FrontWheelRadii = FilterString MetadataModifier.CarFrontWheelRadii "\n"
	
	CarInfo.CarName = CarNames[CarIndex]
	CarInfo.BodyID = BodyIDs[CarIndex] as integer
	CarInfo.BackWheelRadius = BackWheelRadii[CarIndex] as float
	CarInfo.FrontWheelRadius = FrontWheelRadii[CarIndex] as float
	
	return CarInfo
)
	