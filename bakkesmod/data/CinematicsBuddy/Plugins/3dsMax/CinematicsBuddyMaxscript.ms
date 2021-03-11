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
	GroupBox BannerOutline pos:[2,0] width:231 height:62.5
	local BannerImageBitmap = openBitMap(ImageAssets + "CinematicsBuddyMaxscriptBanner2.jpg")
	imgTag BannerImage bitmap:BannerImageBitmap pos:[5,9] width:225 height:51.12
	
	-- Add colored label showing script version
	local VersionText = "Version: " + ScriptVersion
	hyperlink VersionLabel VersionText pos:[83,62] color:[125,200,175] enabled:false
	
	-- Create a subrollout that contains all the other subrollouts
	subrollout RolloutContainer "Rollout Container" pos:[0,80] width:239 height:425
)

-- File importing and scene creation --
rollout Initialize "Import"
(
	-- Buttons to choose file and confirm or cancel import
	local TooltipFileImport = "Select a CinematicsBuddy animation file that was exported from Rocket League"
	local TooltipConfirm = "Clicking this button will set FPS to 60 and set system and display units to centimeters. Then it will parse the chosen file."
	button ButtonFileImport "Choose File" pos:[3,3] width:71 height:28 tooltip:TooltipFileImport
	button ButtonConfirmImport "Confirm" pos:[77,3] width:71 height:28 enabled:false tooltip:TooltipConfirm
	button ButtonCancelImport "Cancel" pos:[151,3] width:71 height:28 enabled:false
	
	-- Choose which items should be included in the import. If a scene already exists, only allow camera importing
	groupbox GroupboxImportTypes "" pos:[3,30] width:220 height:50
	label LabelImportTypes "Objects to import" pos:[70,40] enabled:false
	checkbox CheckboxCamera "Camera" checked:true pos:[20,60] enabled:false
	checkbox CheckboxBall "Ball" checked:true pos:[95,60] enabled:false
	checkbox CheckboxCars "Cars" checked:true pos:[155,60] enabled:false
	
	-- Give the camera a name. It will be automatically pulled from the file when it is chosen, but the user can override it here
	groupbox GroupboxCameraName "" pos:[3,80] width:220 height:50
	label LabelCameraName "Camera name" pos:[80,90] enabled:false
	edittext TextboxCameraName "" pos:[5,108] width:210 enabled:false
	
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
	
	on ButtonCancelImport pressed do
	(
		
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
