-- KeyframeManager handles reading keyframes from an imported file and applying them to scene objects

-- Import Keyframe Getter and Setter scripts so their functions can be called
FileIn(CBSupportScripts + "Keyframes\\KeyframeGetter.ms")
FileIn(CBSupportScripts + "Keyframes\\KeyframeSetter.ms")

-- MAIN FUNCTION DEFINITION --
function ApplyNextKeyframe ImportedFile SceneObjects &NumKeyframesFound =
(
	-- Get the keyframe
	local KeyframeData = GetKeyframe(ImportedFile)
	if KeyframeData == undefined do
	(
		return false
	)
	
	-- Keyframe successfully found
	NumKeyframesFound += 1
	
	-- Apply the keyframe
	ApplyKeyframe KeyframeData SceneObjects
	return true
)
