

/*
	TODO:
		- Make a macro script with an included icon that people can add to a toolbar?
			- The macro would merely call the script itself
			- If they made the script itself a button, would script updates apply to the script that button calls?
				- If the script gets baked into the button, then the macro to call the real script is what should get baked in

	USEFUL LINKS:
		https://davewortley.wordpress.com/2013/04/21/lesson-12-returning-from-functions/
		https://help.autodesk.com/view/3DSMAX/2017/ENU/?guid=__files_GUID_B48DA525_F64B_480C_A6E1_3A05D09007F7_htm
		https://help.autodesk.com/view/3DSMAX/2016/ENU/?guid=__files_GUID_6CF536D8_B90A_4998_AA16_71F23E710B47_htm
*/


-- Information about the script
global CBScriptVersion = "0.9.9"

-- Get relative paths
global CBScriptLocation = PathConfig.RemovePathLeaf (GetSourceFileName()) + "\\"
global CBSupportScripts = CBScriptLocation + "SupportScripts\\"
global CBAssetsLocation = CBScriptLocation + "..\\CinematicsBuddyAssets\\"
global CBImageAssets = CBAssetsLocation + "Images\\"
global CBModelAssets = CBAssetsLocation + "Models\\"

-- Include and evaluate support files
FileIn(CBSupportScripts + "MetadataDummy.ms")
FileIn(CBSupportScripts + "CarDummy.ms")
FileIn(CBSupportScripts + "KeyframeParser.ms")
FileIn(CBSupportScripts + "HeaderParser.ms")

-- Close any existing windows
try(DestroyDialog CinematicsBuddyUI)
catch()

-- MAIN UI CONTAINER --
rollout CinematicsBuddyUI "" width:235 height:315
(	
	-- Add banner image
	local BannerImageBitmap = OpenBitMap(CBImageAssets + "CinematicsBuddyBanner.jpg")
	imgtag BannerImage bitmap:BannerImageBitmap pos:[5,5] width:225 height:30.7 opacity:1.0
	
	-- Create a subrollout that contains all the other subrollouts
	subrollout RolloutContainer "Rollout Container" pos:[0,35] width:239 height:255
	
	-- Add colored label showing script version
	local VersionText = "Version: " + CBScriptVersion
	hyperlink VersionLabel VersionText color:[125,200,175] enabled:false align:#center --pos:[83,32]
)

-- File importing and scene creation --
rollout Initialize "Import Animation File"
(	
	-- Choose which items should be included in the import. If a scene already exists, only allow camera importing
	groupbox GroupboxImportTypes "" pos:[3,-3] width:71 height:76
	label LabelImportTypes "Import" pos:[20,5] enabled:false
	checkbox CheckboxCamera "Camera" checked:true pos:[8,20] enabled:false
	checkbox CheckboxBall "Ball" checked:true pos:[8,37] enabled:false
	checkbox CheckboxCars "Cars" checked:true pos:[8,54] enabled:false
	
	-- Buttons to choose file and confirm or cancel import
	local TooltipFileImport = "Select a Cinematics Buddy animation file that was exported from Rocket League"
	local TooltipConfirm = "Clicking this button will parse the chosen file and import the objects selected by the Import checkboxes. It will also set the FPS to 60 and set the system and display units to centimeters."
	button ButtonFileImport "Choose File" pos:[78,3] width:71 height:28 tooltip:TooltipFileImport
	button ButtonConfirmImport "Confirm" pos:[152,3] width:71 height:28 enabled:false tooltip:TooltipConfirm
	
	-- Give the camera a name. It will be automatically pulled from the file when it is chosen, but the user can override it here
	groupbox GroupboxCameraName "" pos:[78,28] width:145 height:45
	label LabelCameraName "Camera Name" pos:[120,35] enabled:false
	edittext TextboxCameraName "" pos:[80,51] width:137 enabled:false
	
	-- LOCAL STORAGE --
	local ImportedFile
	local HeaderData
	
	-- BUTTON METHODS --
	on ButtonFileImport pressed do
	(
		local ChosenFile = GetOpenFileName caption:"Select file to import"
		if ChosenFile != undefined do
		(
			-- Open file and read header lines
			ImportedFile = OpenFile ChosenFile
			HeaderData = GetHeaderData(ImportedFile)
			
			if HeaderData != undefined do
			(
				--Assign camera name to textbox so user can edit it if they want
				TextboxCameraName.text = HeaderData.RecordingMetadata.CameraName
				
				-- Enable the rest of the UI
				LabelImportTypes.enabled = true
				CheckboxCamera.enabled = true
				CheckboxBall.enabled = true
				CheckboxCars.enabled = true
				ButtonConfirmImport.enabled = true
				LabelCameraName.enabled = true
				TextboxCameraName.enabled = true
			)
		)
	)
	
	on ButtonConfirmImport pressed do
	(
		-- Configure unit and timeline settings
		frameRate = 60
		units.DisplayType = #metric
		units.SystemType = #Centimeters
		
		-- Create MetadataDummy to store scene information
		local MetadataDummy = CreateMetadataDummy(HeaderData)
		
		-- Create scene objects
		local SceneObjects = CreateSceneObjects MetadataDummy TextboxCameraName.text
		
		-- Loop through all keyframes and apply them
		local NumKeyframesFound = 0
		while ApplyNextKeyframe ImportedFile SceneObjects &NumKeyframesFound do ()
		format "NumKeyframesFound: %\n" NumKeyframesFound
	)
)

-- Export selected camera's animation to Rocket League --
rollout ExportCamera "Export Camera To Rocket League"
(
	-- @TODO: Keep the export button disabled unless there is text in the textbox and a SINGLE camera is selected
		-- Check every time the textbox value changes and every time a selection changes?
		-- If multiple objects selected, grey out box
		-- This seems helpful: https://forums.cgsociety.org/t/maxscript-detecting-selectionset-change/663841/3
	-- @TODO: Bake camera animation down if it has any constraints
	
	local TooltipExportCamera = "File will export to /bakkesmod/data/CinematicsBuddy/AnimationImports/"
	label LabelInstructions1 "1. Select a camera" pos:[3,1]
	label LabelInstructions2 "2. Provide a file name" pos:[3,14]
	edittext TextboxFileName "" pos:[0,30] width:148
	button ButtonExportCamera "3. Export" pos:[152,3] width:70 height:45 enabled:false tooltip:TooltipExportCamera
	
	on ButtonExportCamera pressed do
	(
		
	)
)

-- Export all mesh and camera animations to an external software --
rollout ExportAll "Export All To Other 3D Program"
(
	-- @TODO: Bake all car body and camera animations down
	
	local TooltipChooseDirectory = "Opens a file explorer for you to choose the output directory. The file will be saved as FBX. The cars, ball, and all cameras will be exported"
	button ButtonChooseDirectory "Export" pos:[152,3] width:70 height:35 tooltip:TooltipChooseDirectory
	label LabelUpAxis "Up Axis" pos:[60,2]
	dropdownlist DropdownUpAxis "" items:#("Y-Up", "Z-Up") pos:[3,17] width:145
	
	on ButtonChooseDirectory pressed do
	(
		
	)
)

-- Create the window and add the subrollouts
CreateDialog  CinematicsBuddyUI style: #(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox)
AddSubrollout CinematicsBuddyUI.RolloutContainer Initialize
AddSubrollout CinematicsBuddyUI.RolloutContainer ExportCamera
AddSubrollout CinematicsBuddyUI.RolloutContainer ExportAll
