-- KeyframeParser reads through all of the keyframe data and applies that data to the CinematicsBuddy scene objects.




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


-- STRUCT DEFINITIONS --
struct StructBallKeyframe
(
	BallLocation,
	BallRotation
)

struct StructCameraKeyframe
(
	CameraLocation,
	CameraRotation,
	CameraFieldOfView
)

struct StructWheelKeyframe
(
	WheelIndex,
	SteerAmount,
	SuspensionDistance,
	SpinSpeed
)

struct StructCarKeyframe
(
	CarSeenIndex,
	CarLocation,
	CarRotation,
	bIsBoosting,
	WheelKeyframes = #()
)

struct StructTimeKeyframe
(
	RealTime,
	ReplayFrame
)

struct StructKeyframeData
(
	TimeKeyframe,
	CameraKeyframe,
	BallKeyframe,
	CarKeyframes = #()
)


-- SUPPORT FUNCTION DEFINITIONS --


-- MAIN FUNCTION DEFINITION --
function ApplyNextKeyframe ImportedFile SceneObjects &NumKeyframesFound =
(
	-- Check if the filestream is already finished
	local bIsFileFinished = eof ImportedFile
	if bIsFileFinished do
	(
		return false
	)
	
	-- Check if the first line of the keyframe is empty. If it is, that's the last line of the file
	-- Don't really need to do anything with the first line as it is just the number of the keyframe
	local FirstLine = ReadLine ImportedFile
	if FirstLine.count == 0 do
	(
		return false
	)
	
	-- Both checks above passed. Extract data from keyframe
	NumKeyframesFound += 1
	local KeyframeData = StructKeyframeData()
	while not eof ImportedFile do
	(
		local ThisLine = ReadLine ImportedFile
		if ThisLine.count == 0 do exit
		
		local SplitLine = GetSplitDataLine(ThisLine)
		case SplitLine.LineLabel of
		(
			"B":  KeyframeData.BallData   = GetBallData(ImportedFile)
			"CM": KeyframeData.CameraData = GetCameraData(ImportedFile)
			
			-- IMPORTANT: When getting the car, its index starts at 0 in the animation file. Add 1 to the index to access the car from SceneObjects by index
			-- Maxscript starts at index 1
			"CR": KeyframeData.CarsData   = GetCarsData(ImportedFile)
			
			"T":  KeyframeData.TimeData   = GetTimeData(ImportedFile)
			"}":  exit
		)
	)
	
	-- Apply the keyframe
	ApplyKeyframe KeyframeData SceneObjects
	return true
)
