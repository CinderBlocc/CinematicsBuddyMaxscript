-- UtilityFunctions contains functions that are used throughout the script

-- EXTRACTING DATA --
struct StructSplitDataLine
(
	LineLabel,
	LineValue = undefined
)

function GetSplitDataLine DataLine =
(
	local SplitDataLine = StructSplitDataLine()
	
	local TrimmedLine = TrimLeft DataLine
	local SplitLine = FilterString TrimmedLine ":"
	
	SplitDataLine.LineLabel = SplitLine[1]
	if SplitLine.count > 1 do
	(
		SplitDataLine.LineValue = TrimLeft SplitLine[2]
	)
	
	return SplitDataLine
)

-- 3D SPACE --
function GetLocation3D VectorString =
(
	local OutputVector = Point3 0 0 0
	
	local SplitValues = FilterString VectorString ","
	OutputVector.x = SplitValues[1] as float
	OutputVector.y = SplitValues[2] as float
	OutputVector.z = SplitValues[3] as float
	
	return OutputVector
)

/*
-- Pseudo enum in case each rotation needs to be converted differently for some dumb reason
global EQuatType_Camera = 0
global EQuatType_Ball   = 1
global EQuatType_Car    = 2
*/
function GetRotationFromQuat QuatString /*QuatType*/ = 
(
	local OutputEuler = EulerAngles 0 0 0
	local InputQuat = Quat 0 0 0 1
	
	local SplitValues = FilterString QuatString ","
	InputQuat.w = SplitValues[1] as float
	InputQuat.x = SplitValues[2] as float
	InputQuat.y = SplitValues[3] as float
	InputQuat.z = SplitValues[4] as float
	
	/* FROM OLD CINEMATICSBUDDY SCRIPT FOR THE CAMERA
	InputQuat.w = SplitValues[1]
	InputQuat.x = -SplitValues[3]
	InputQuat.y = -SplitValues[2]
	InputQuat.z = -SplitValues[4]
	*/
	
	/* FROM OLD CINEMATICSBUDDY SCRIPT FOR THE BALL AND CARS
	InputQuat.w = SplitValues[1]
	InputQuat.x = -SplitValues[2]
	InputQuat.y = SplitValues[3]
	InputQuat.z = -SplitValues[4]
	-- then rotated by " ball.transform *= rotateZmatrix 30"
	*/
	
	OutputEuler = InputQuat as eulerangles
	return OutputEuler
)
