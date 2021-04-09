-- Create the structs necessary for parsing keyframes
	-- Create a function that generates a single "Keyframe" struct holding all keyframe data
		-- This function reads lines until its brace stack match level reaches 0, then it parses those lines
		

-- DONT STORE THE DATA, JUST READ AND APPLY IT


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
	
function ApplyNextKeyframe ImportedFile SceneObjects &NumKeyframesFound =
(
	NumKeyframesFound += 1
	
	if NumKeyframesFound < 5 then
	(
		return true
	)
	else
	(
		format "NumKeyframesFound: %\n" NumKeyframesFound
		return false
	)
)
