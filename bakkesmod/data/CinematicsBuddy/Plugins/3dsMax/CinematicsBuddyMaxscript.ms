

/*
	TODO:
		- Make a macro script with an included icon that people can add to a toolbar?
			- The macro would merely call the script itself
			- If they made the script itself a button, would script updates apply to the script that button calls?
				- If the script gets baked into the button, then the macro to call the real script is what should get baked in
				
		- Get rid of image banner from UI?
			- Avoids potential licensing issues by using RL logo, and avoids weird gamma issues in 2016 version of 3ds max
			- Or replace it with a transparent png with only white text that says CinematicsBuddy in bold?
				- Just having it be pure black and pure white would fix gamma issues
*/


-- Information about the script
ScriptVersion = "0.9.9"

-- Get relative paths
ScriptLocation = pathConfig.removePathLeaf (getSourceFileName()) + "\\"
AssetsLocation = ScriptLocation + "..\\CinematicsBuddyAssets\\"
ImageAssets = AssetsLocation + "Images\\"
ModelAssets = AssetsLocation + "Models\\"
SupportScripts = ScriptLocation + "SupportScripts\\"

-- Include and evaluate support files
fileIn(SupportScripts + "MetadataDummy.ms")
fileIn(SupportScripts + "CarDummy.ms")

-- Close any existing windows
try(destroyDialog CinematicsBuddyUI)
catch()

-- MAIN UI CONTAINER --
rollout CinematicsBuddyUI "" width:235 height:500
(	
	-- Add banner image
	--@TODO: Make file path relative, and choose image 1 or 2 based on 3ds max version (2016 has gamma issues)
	local BannerImageFilename = ImageAssets + "CinematicsBuddyBanner.jpg"
	local BannerImageBitmap = openBitMap(BannerImageFilename)
	imgTag BannerImage bitmap:BannerImageBitmap pos:[5,9] width:225 height:30.7 opacity:1.0
	
	-- Add colored label showing script version
	local VersionText = "Version: " + ScriptVersion
	hyperlink VersionLabel VersionText pos:[83,45] color:[125,200,175] enabled:false
	
	-- Create a subrollout that contains all the other subrollouts
	subrollout RolloutContainer "Rollout Container" pos:[0,80] width:239 height:425
)

-- File importing and scene creation --
rollout Initialize "Import Animation File"
(
	-- Buttons to choose file and confirm or cancel import
	local TooltipFileImport = "Select a CinematicsBuddy animation file that was exported from Rocket League"
	local TooltipConfirm = "Clicking this button will set FPS to 60 and set system and display units to centimeters. Then it will parse the chosen file."
	button ButtonFileImport "Choose File" pos:[3,3] width:71 height:28 tooltip:TooltipFileImport
	button ButtonConfirmImport "Confirm" pos:[77,3] width:71 height:28 enabled:false tooltip:TooltipConfirm
	
	-- Choose which items should be included in the import. If a scene already exists, only allow camera importing
	groupbox GroupboxImportTypes "" pos:[151,-3] width:71 height:76
	label LabelImportTypes "Import" pos:[170,5] enabled:false
	checkbox CheckboxCamera "Camera" checked:true pos:[158,20] enabled:false
	checkbox CheckboxBall "Ball" checked:true pos:[158,37] enabled:false
	checkbox CheckboxCars "Cars" checked:true pos:[158,54] enabled:false
	
	-- Give the camera a name. It will be automatically pulled from the file when it is chosen, but the user can override it here
	groupbox GroupboxCameraName "" pos:[3,28] width:145 height:45
	label LabelCameraName "Camera Name" pos:[45,35] enabled:false
	edittext TextboxCameraName "" pos:[5,51] width:137 enabled:false
	
	-- BUTTON METHODS --
	on ButtonFileImport pressed do
	(
		
	)
	
	on ButtonConfirmImport pressed do
	(
		-- Configure unit and timeline settings
		frameRate = 60
		units.DisplayType = #metric
		units.SystemType = #Centimeters
	)
)

-- Export selected camera's animation to Rocket League --
rollout ExportCamera "Export Camera To Rocket League"
(
	-- @TODO: Bake camera animation down if it has any constraints
	
	local TooltipExportCamera = "Provide a name for the file in the textbox above.\nThe file will export to /bakkesmod/data/CinematicsBuddy/AnimationImports/"
	label Instructions "Select a camera and provide a file name" align:#center
	edittext TextboxFileName "" pos:[3,25] width:215
	button ButtonExportCamera "Export camera to Rocket League" pos:[7,45] width:210 height:22 tooltip:TooltipExportCamera
	
	on ButtonExportCamera pressed do
	(
		
	)
)

-- Export all mesh and camera animations to an external software --
rollout ExportAll "Export All To Other 3D Program"
(
	-- @TODO: Bake all car body and camera animations down
	-- Add a few of the FBX settings directly to the 
)

-- Create the window and add the subrollouts
createdialog  CinematicsBuddyUI style: #(#style_titlebar, #style_border, #style_sysmenu, #style_minimizebox)
addsubrollout CinematicsBuddyUI.RolloutContainer Initialize
addsubrollout CinematicsBuddyUI.RolloutContainer ExportCamera
addsubrollout CinematicsBuddyUI.RolloutContainer ExportAll
