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
			edittext TextboxReplayName         "Name: "           pos:[5,5]  width:152 readonly:true
			edittext TextboxReplayID           "ID:      "        pos:[5,27] width:152 readonly:true
			edittext TextboxReplayDate         "Date:  "          pos:[5,49] width:152 readonly:true
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
			edittext TextboxCarName          "Name"               width:152 height:100 pos:[5,2]   readonly:true labelontop:true
			edittext TextboxCarBodyID        "Body ID"            width:152 height:100 pos:[5,125] readonly:true labelontop:true
			edittext TextboxBackWheelRadius  "Back Wheel Radius"  width:152 height:100 pos:[5,250] readonly:true labelontop:true
			edittext TextboxFrontWheelRadius "Front Wheel Radius" width:152 height:100 pos:[5,375] readonly:true labelontop:true
		)
		
		-- Arena and ball metadata
		parameters otherassets rollout:ro_otherassets
		(
			OtherArenaName type:#string ui:TextboxArenaName
			OtherBallName  type:#string ui:TextboxBallName
		)
		rollout ro_otherassets "Other Assets"
		(
			edittext TextboxArenaName "Arena"    pos:[5,5]  width:152 readonly:true
			edittext TextboxBallName  "Ball    " pos:[5,27] width:152 readonly:true
		)
	)
	CustAttributes.add TheModifier MetadataModifier
	
	-- Assign HeaderData information to the fields in the modifier
	TheModifier.CarNames = "0\n1\n2\n3\n4\n5\n6\n7\n8\n9\n10"
	
	
	
	
	select MetadataDummy -- REMOVE WHEN DONE
	/*
	deselect MetadataDummy
	freeze MetadataDummy
	hide MetadataDummy
	*/

	
	return MetadataDummy
)
	