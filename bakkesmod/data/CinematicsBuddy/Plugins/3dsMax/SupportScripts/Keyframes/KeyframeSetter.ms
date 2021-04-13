-- KeyframeSetter applies data from a keyframe to the CinematicsBuddy objects in the scene.



-- MetadataDummy values to set per frame:
	-- ReplayCurrentFrame
	-- ReplayStartFrame (set on the first frame, then lower it if for some reason they rewound to an earlier frame while recording)
	-- ReplayEndFrame (same as StartFrame, set it every time there is a higher frame number than the current EndFrame)
	
-- CarDummy values to set per frame PER CAR:
	-- IsBoosting
	-- Wheel0_SteerAmount
	-- Wheel0_SuspensionDist
	-- Wheel0_SpinSpeed
	-- Wheel1_SteerAmount
	-- Wheel1_SuspensionDist
	-- Wheel1_SpinSpeed
	-- Wheel2_SteerAmount
	-- Wheel2_SuspensionDist
	-- Wheel2_SpinSpeed
	-- Wheel3_SteerAmount
	-- Wheel3_SuspensionDist
	-- Wheel3_SpinSpeed
	
-- Camera values to set per frame:
	-- FOV
	
-- ALL OTHER DATA CAN BE APPLIED DIRECTLY TO AN OBJECT INSTEAD OF THROUGH ITS CUSTOM ATTRIBUTES
	-- i.e. Location and Rotation



-- Import UtilityFunctions script so its functions can be called
FileIn(CBSupportScripts + "UtilityFunctions.ms")

-- SUPPORT FUNCTION DEFINITIONS --
function ApplyMetadataDummyAnimation KeyframeData MetadataDummy = 
(
	
)

function ApplyBallAnimation KeyframeData BallMesh = 
(
	
)

function ApplyCameraAnimation KeyframeData CameraObject = 
(
	
)

function ApplyCarAnimation KeyframeData CarDummy = 
(
	
)

function ApplyCarAnimations KeyframeData CarDummies = 
(
	
)

-- MAIN FUNCTION DEFINITION --
function ApplyKeyframe KeyframeData SceneObjects = 
(
	ApplyMetadataDummyAnimation KeyframeData SceneObjects.MetadataDummy
	ApplyBallAnimation          KeyframeData SceneObjects.BallMesh
	ApplyCameraAnimation        KeyframeData SceneObjects.CameraObject
	ApplyCarAnimations          KeyframeData SceneObjects.CarDummies
)
