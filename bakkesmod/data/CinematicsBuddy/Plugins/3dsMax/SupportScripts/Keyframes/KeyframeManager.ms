-- KeyframeManager handles reading keyframes from an imported file and applying them to scene objects

-- Import Keyframe Getter and Setter scripts so their functions can be called
FileIn(CBSupportScripts + "Keyframes\\KeyframeGetter.ms")
FileIn(CBSupportScripts + "Keyframes\\KeyframeSetter.ms")

-- MAIN FUNCTION DEFINITION --
function ApplyNextKeyframe ImportedFile SceneObjects &NumKeyframesFound &MaxAnimationRange =
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
	ApplyKeyframe KeyframeData SceneObjects bFirstKeyframe
	MaxAnimationRange = KeyframeData.TimeKeyframe.RealTime
	return true
)

-- CAMERA ONLY FUNCTION DEFINITION --
function ApplyNextCameraKeyframe ImportedFile SceneObjects = 
(
	
	
	
									-- NEED TO ONLY START APPLYING ANIMATION ONCE THE EARLIEST "ReplayFrame" FROM NEW CAMERA MATCHES THE EARLIEST FROM MetadataDummy --
	
	
	
	-- Get the keyframe
	local KeyframeData = GetKeyframe(ImportedFile)
	if KeyframeData == undefined do
	(
		return false
	)
	
	-- Apply the keyframe
	ApplyCameraOnlyKeyframe KeyframeData SceneObjects
	return true
)
