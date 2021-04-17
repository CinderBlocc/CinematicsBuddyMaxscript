-- KeyframeManager handles reading keyframes from an imported file and applying them to scene objects

-- Import Keyframe Getter and Setter scripts so their functions can be called
FileIn(CBSupportScripts + "Keyframes\\KeyframeGetter.ms")
FileIn(CBSupportScripts + "Keyframes\\KeyframeSetter.ms")
FileIn(CBSupportScripts + "Keyframes\\KeyframeSetterAdditionalCamera.ms")

-- MAIN FUNCTION DEFINITION --
function ApplyNextKeyframe ImportedFile SceneObjects ImportTypes &NumKeyframesFound &MaxAnimationRange =
(
	-- Get the keyframe
	local KeyframeData = GetKeyframe(ImportedFile)
	if KeyframeData == undefined do
	(
		return false
	)
	
	-- Keyframe successfully found
	NumKeyframesFound += 1
	local bFirstKeyframe = false
	if NumKeyframesFound == 1 do
	(
		bFirstKeyframe = true
	)
	
	-- Apply the keyframe
	ApplyKeyframe KeyframeData SceneObjects ImportTypes bFirstKeyframe
	MaxAnimationRange = KeyframeData.TimeKeyframe.RealTime
	return true
)

-- CAMERA ONLY FUNCTION DEFINITION --
function ApplyNextCameraKeyframe ImportedFile SceneObjects &SyncData = 
(
	-- Pass in an empty keyframe for "FirstValidKeyframe"
		-- When the first keyframe within the ReplayFrame range is found, set that as FirstValidKeyframe
		-- If FVK is null, skip the "ApplyCameraOnlyKeyframe" call
	
	-- FirstValidKeyframe: The first keyframe imported from the file that sits within the range of MetadataDummy's replay frames
	-- AnimationStartTime: The time on the timeline that this first frame was found
	
	-- Get the keyframe
	local KeyframeData = GetKeyframe(ImportedFile)
	if KeyframeData == undefined do
	(
		return false
	)
	
	-- Find the sync points for MetadataDummy and the start of this file
	if SyncData.bFirstKeyframe == true do
	(
		SyncData = FindSyncPoint KeyframeData SceneObjects
		if SyncData.FirstValidKeyframe == undefined do
		(
			MessageBox("Cannot sync camera. No keyframes found within MetadataDummy's replay animation range.")
			return false
		)
	)
	
	-- Find the first valid keyframe, and the time that it was valid
	if FirstValidKeyframe == undefined do
	(
		if IsValidKeyframe KeyframeData SceneObjects.MetadataDummy do
		(
			FirstValidKeyframe = KeyframeData
			AnimationStartTime = 0 					-- TODO: Actually find the first timeline time that the ReplayFrame range syncs with new camera
		)
	)
	
	-- Apply the keyframe as a time difference from the first valid keyframe
	if FirstValidKeyframe != undefined do
	(
		-- Check if this keyframe's animation has gone past the end of the animation range stored in MetadataDummy
		if IsValidKeyframe KeyframeData SceneObjects.MetadataDummy do
		(
			ApplyCameraOnlyKeyframe KeyframeData SceneObjects FirstValidKeyframe AnimationStartTime
		)
	)
		
	return true
)

/*
- Check the first keyframe of the animation to find its first ReplayFrame value
	- Assume that this first value is the absolute lowest value
- IF THE NEW CAMERA'S LOWEST IS BELOW METADATADUMMY'S LOWEST:
	- Loop through new camera's keyframes until the replay frame equals the lowest metadata frame
	- AnimationStartTime would be 0 - it might not actually be 0 in all cases, but it'll be easier to assume that
- IF THE NEW CAMERA'S LOWEST IS ABOVE METADATADUMMY'S LOWEST:
	- Loop through MetadataDummy's keyframes to find the moment in time that the ReplayFrame matches the lowest frame from new camera
	- AnimationStartTime would be the time of that keyframe
*/
