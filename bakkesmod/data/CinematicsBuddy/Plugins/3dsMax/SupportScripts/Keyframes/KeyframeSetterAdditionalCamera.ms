-- KeyframeSetterAdditionalCamera handles importing an additional camera and attempts to sync it with the rest of the scene

-- Import KeyframeSetter script so ApplyCameraAnimation can be called
FileIn(CBSupportScripts + "Keyframes\\KeyframeSetter.ms")

-- STRUCT DEFINITIONS --
struct StructSyncData
(
	FirstValidKeyframe,
	AnimationStartTime
)

-- SUPPORT FUNCTION DEFINITIONS --
function FindSyncData FirstKeyframe MetadataDummy = 
(
	local SyncData = StructSyncData()
	SyncData.FirstValidKeyframe = undefined
	SyncData.AnimationStartTime = -1
	
	/*
	- Check FirstKeyframe's ReplayFrame value
		- Assume that it is the absolute lowest value of the new camera's animation range
	- IF THE NEW CAMERA'S LOWEST IS BELOW METADATADUMMY'S LOWEST:
		- Loop through new camera's keyframes until the replay frame equals the lowest metadata frame
		- AnimationStartTime would be 0 - it might not actually be 0 in all cases, but it'll be easier to assume that
	- IF THE NEW CAMERA'S LOWEST IS ABOVE METADATADUMMY'S LOWEST:
		- Loop through MetadataDummy's keyframes to find the moment in time that the ReplayFrame matches the lowest frame from new camera
		- AnimationStartTime would be the time of that keyframe
	*/
	
	return SyncData
)

function IsValidKeyframe KeyframeData MetadataDummy = 
(
	local TheModifier = MetadataDummy.modifiers[1]
	
	if KeyframeData.TimeKeyframe.ReplayFrame < TheModifier.ReplayStartFrame do
	(
		return false
	)
	
	if KeyframeData.TimeKeyframe.ReplayFrame > TheModifier.ReplayEndFrame do
	(
		return false
	)
	
	return true
)

function GetKeyframeTime KeyframeData SyncData = 
(
	-- Get the real time gap in seconds between the current keyframe and the first keyframe
	local TimeGap = KeyframeData.TimeKeyframe.RealTime - SyncData.FirstValidKeyframe.TimeKeyframe.RealTime
	
	-- Get time as a factor of frames at 60 fps
	local Converted = TimeGap * 60
	
	-- Shift based on start time from SyncData
	local FinalTime = TimeGap + SyncData.AnimationStartTime
	
	return FinalTime
)

-- MAIN FUNCTION DEFINITION --
function ApplyCameraOnlyKeyframe KeyframeData SceneObjects SyncData = 
(
	-- Check if this keyframe's animation has gone past the end of the animation range stored in MetadataDummy
	if IsValidKeyframe KeyframeData SceneObjects.MetadataDummy do
	(
		local KeyframeTime = GetKeyframeTime KeyframeData SyncData
		
		set animate on
		ApplyCameraAnimation KeyframeTime KeyframeData SceneObjects.CameraObject
		set animate off
		
		return true
	)
	
	return false
)
