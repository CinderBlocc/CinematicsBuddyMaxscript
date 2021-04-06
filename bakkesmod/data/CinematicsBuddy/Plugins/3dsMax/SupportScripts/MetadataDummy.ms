-- Script to create MetadataDummy object that contains information about the scene
	-- A list of cars, the ball, arena, etc.
	-- Replay ID, animation of replay frame, etc
	
--CreateMetadataDummy() -- REMOVE THIS WHEN DONE
	
function CreateMetadataDummy HeaderData =
(
	-- Delete any existing MetadataDummy objects
	if $MetadataDummy != undefined do
	(
		format "Deleting old MetadataDummy\n"
		delete $MetadataDummy
	)
	
	-- Create new dummy object
	MetadataDummy = Dummy name:"MetadataDummy" pos:[0,0,0]
	
	-- Add modifier to hold replay metadata
	AddModifier MetadataDummy (EmptyModifier())
	local TheModifier = MetadataDummy.modifiers[1]
	TheModifier.name = "Metadata"
	MetadataModifier = attributes Metadata
	(
		-- "About" button to describe MetadataDummy's purpose
		rollout ro_description "Description"
		(
			button ButtonDescription "About MetadataDummy" width:150
			
			on ButtonDescription pressed do
			(
				local DescriptionText = "METADATA DUMMY\n"
				DescriptionText += "\n"
				DescriptionText += "This object's purpose is to store information about the scene elements related to Cinematics Buddy.\n"
				DescriptionText += "The information stored in these fields was read from the imported file and should not be edited.\n"
				DescriptionText += "That is why all of the fields are disabled.\n"
				DescriptionText += "\n"
				DescriptionText += "-- DO NOT DELETE THIS OBJECT --\n"
				DescriptionText += "\n"
				DescriptionText += "This object is important for some aspects of the Cinematics Buddy script. If it is deleted, some functionality will break."
				
				MessageBox DescriptionText
			)
		)
		
		-- Replay metadata
		parameters metadataparams rollout:ro_metadata
		(
			ReplayName         type:#string  ui:TextboxReplayName
			ReplayID           type:#string  ui:TextboxReplayID
			ReplayDate         type:#string  ui:TextboxReplayDate
			ReplayFPS          type:#float   ui:SpinnerReplayFPS
			ReplayFrames       type:#integer ui:SpinnerReplayFrames
			ReplayCurrentFrame type:#integer ui:SpinnerReplayCurrentFrame
		)
		rollout ro_metadata "Replay Metadata"
		(
			edittext TextboxReplayName         "Name: "           pos:[5,5]  width: 152 enabled:false
			edittext TextboxReplayID           "ID:      "        pos:[5,27] width: 152 enabled:false
			edittext TextboxReplayDate         "Date:  "          pos:[5,49] width: 152 enabled:false
			spinner  SpinnerReplayFPS          "FPS:     "        pos:[-18,71]  range:[0,10000,0]   type:#float   width:175 enabled:false
			spinner  SpinnerReplayFrames       "Replay Frames:  " pos:[ 2, 93]  range:[0,1000000,0] type:#integer width:155 enabled:false
			spinner  SpinnerReplayCurrentFrame "Current frame: "  pos:[-3, 115] range:[0,1000000,0] type:#integer width:160 enabled:false
		)
		
		-- Cars metadata
		parameters carparams rollout:ro_cars
		(
			CarNames             type:#string ui:TextBoxCarName
			CarBodyIDs           type:#string ui:TextboxCarBodyID
			CarBackWheelRadii    type:#string ui:TextboxBackWheelRadius
			CarFrontWheelRadii   type:#string ui:TextboxFrontWheelRadius
		)
		rollout ro_cars "Car Metadata"
		(
			edittext TextboxCarName          "Name"               height:100 enabled:false
			edittext TextboxCarBodyID        "Body ID"            height:100 enabled:false
			edittext TextboxBackWheelRadius  "Back Wheel Radius"  height:100 enabled:false
			edittext TextboxFrontWheelRadius "Front Wheel Radius" height:100 enabled:false
		)
	)
	CustAttributes.add TheModifier MetadataModifier
	
	-- Assign HeaderData information to the fields in the modifier
	TheModifier.ReplayName = "Name of replay"

	
	return MetadataDummy
)
	