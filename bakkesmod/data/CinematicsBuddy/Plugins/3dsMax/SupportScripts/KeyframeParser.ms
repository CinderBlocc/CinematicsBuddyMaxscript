-- Create the structs necessary for parsing keyframes
	-- Create a function that generates a single "Keyframe" struct holding all keyframe data
		-- This function reads lines until its brace stack match level reaches 0, then it parses those lines
		

-- DONT STORE THE DATA, JUST READ AND APPLY IT
		
		
function ApplyNextKeyframe ImportedFile SceneObjects &NumKeyframesFound =
(
	NumKeyframesFound += 1
	
	if NumKeyframesFound < 5 then (return true)
	else (return false)
)
