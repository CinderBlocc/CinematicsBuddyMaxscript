-- KeyframeManager handles reading keyframes from an imported file and applying them to scene objects

-- Import Keyframe Getter and Setter scripts so their functions can be called
FileIn(CBSupportScripts + "Keyframes\\KeyframeGetter.ms")
FileIn(CBSupportScripts + "Keyframes\\KeyframeSetter.ms")

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
function ApplyNextCameraKeyframe ImportedFile SceneObjects &FirstValidKeyframe &AnimationStartTime = 
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
