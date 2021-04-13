-- KeyframeGetter reads data from ImportedFile to extract a keyframe.

-- Import UtilityFunctions script so its functions can be called
FileIn(CBSupportScripts + "UtilityFunctions.ms")
	
-- STRUCT DEFINITIONS --
struct StructTimeKeyframe
(
	RealTime,
	ReplayFrame
)

struct StructCameraKeyframe
(
	CameraLocation,
	CameraRotation,
	CameraFieldOfView
)

struct StructBallKeyframe
(
	BallLocation,
	BallRotation
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

struct StructKeyframeData
(
	TimeKeyframe,
	CameraKeyframe,
	BallKeyframe,
	CarKeyframes = #()
)

-- SUPPORT FUNCTION DEFINITIONS --
function GetTimeKeyframe ImportedFile = 
(
	local TimeKeyframe = StructTimeKeyframe()
	
	while not eof ImportedFile do
	(
		local ThisLine = ReadLine ImportedFile
		if ThisLine.count == 0 do exit
		
		local SplitLine = GetSplitDataLine(ThisLine)
		case SplitLine.LineLabel of
		(
			"T":  TimeKeyframe.RealTime    = SplitLine.LineValue as float
			"RF": TimeKeyframe.ReplayFrame = SplitLine.LineValue as integer
			"}": exit
		)
	)
	
	return TimeKeyframe
)

function GetCameraKeyframe ImportedFile = 
(
	local CameraKeyframe = StructCameraKeyframe()
	
	while not eof ImportedFile do
	(
		local ThisLine = ReadLine ImportedFile
		if ThisLine.count == 0 do exit
		
		local SplitLine = GetSplitDataLine(ThisLine)
		case SplitLine.LineLabel of
		(
			"L": CameraKeyframe.CameraLocation    = GetLocation3D(SplitLine.LineValue)
			"R": CameraKeyframe.CameraRotation    = GetRotationFromQuat(SplitLine.LineValue)
			"F": CameraKeyframe.CameraFieldOfView = SplitLine.LineValue as float
			"}": exit
		)
	)
	
	return CameraKeyframe
)

function GetBallKeyframe ImportedFile =
(
	local BallKeyframe = StructBallKeyframe()
	
	while not eof ImportedFile do
	(
		local ThisLine = ReadLine ImportedFile
		if ThisLine.count == 0 do exit
		
		local SplitLine = GetSplitDataLine(ThisLine)
		case SplitLine.LineLabel of
		(
			"L": BallKeyframe.BallLocation = GetLocation3D(SplitLine.LineValue)
			"R": BallKeyframe.BallRotation = GetRotationFromQuat(SplitLine.LineValue)
			"}": exit
		)
	)
	
	return BallKeyframe
)

function GetWheelKeyframe ImportedFile = 
(
	local WheelKeyframe = StructWheelKeyframe()
	
	local ThisLine = ReadLine ImportedFile
	
	-- Check if line is empty or is the closing line of the wheel array
	local bIsClosingBracket = MatchPattern ThisLine pattern:"]"
	if bIsClosingBracket == true return undefined
	if ThisLine.count == 0 return undefined
	
	-- Get the wheel data
	local SplitLine = GetSplitDataLine(ThisLine)
	local SplitData = FilterString SplitLine.LineValue ","
	WheelKeyframe.WheelIndex         = SplitLine.LineLabel as integer
	WheelKeyframe.SteerAmount        = SplitData[1] as float
	WheelKeyframe.SuspensionDistance = SplitData[2] as float
	WheelKeyframe.SpinSpeed          = SplitData[3] as float
	
	return WheelKeyframe
)

function GetBoostBool BoostString = 
(
	-- Maxscript doesn't seem to have an "as boolean" conversion
	local BoostAsInt = BoostString as integer
	
	if BoostAsInt == 1 do
	(
		return true
	)
	
	return false
)

function GetCarKeyframe ImportedFile = 
(	
	local CarKeyframe = StructCarKeyframe()
	
	-- Pull the car seen index from the first line
	local CarIndexLine = ReadLine ImportedFile
	local CarIndexSplit = GetSplitDataLine(CarIndexLine)
	if CarIndexSplit.LineLabel == "}" then
	(
		-- The end of the array has been reached
		return undefined
	)
	else
	(
		CarKeyframe.CarSeenIndex = CarIndexSplit.LineLabel as integer
	)
	
	-- Parse the car data. Wheels are handled differently, hence the boolean
	local bIsGettingWheels = false
	while not eof ImportedFile do
	(		
		if bIsGettingWheels == true then
		(
			-- Let the "GetWheelKeyframe" function handle file parsing until all wheels have been parsed
			local ThisWheel = GetWheelKeyframe(ImportedFile)
			if ThisWheel == undefined then
			(
				bIsGettingWheels = false
			)
			else
			(
				append CarKeyframe.WheelKeyframes ThisWheel
			)
		)
		else
		(
			-- Parse the rest of the car normally
			local ThisLine = ReadLine ImportedFile
			if ThisLine.count == 0 do exit
			
			local SplitLine = GetSplitDataLine(ThisLine)
			case SplitLine.LineLabel of
			(
				"L": CarKeyframe.BallLocation = GetLocation3D(SplitLine.LineValue)
				"R": CarKeyframe.BallRotation = GetRotationFromQuat(SplitLine.LineValue)
				"B": CarKeyframe.bIsBoosting  = GetBoostBool(SplitLine.LineValue)
				"W": bIsGettingWheels = true
				"}": exit
			)
		)
	)
	
	return CarKeyframe
)

function GetCarsKeyframes ImportedFile = 
(
	local CarKeyframes = #()
	
	while true do
	(
		local ThisCar = GetCarKeyframe(ImportedFile)
		if ThisCar == undefined then
		(
			exit
		)
		else
		(
			append CarKeyframes ThisCar
		)
	)
	
	return CarKeyframes
)

-- MAIN FUNCTION DEFINITION --
function GetKeyframe ImportedFile = 
(
	-- Check if the filestream is already finished
	local bIsFileFinished = eof ImportedFile
	if bIsFileFinished do
	(
		return undefined
	)
	
	-- Check if the first line of the keyframe is empty. If it is, that's the last line of the file
	-- Don't really need to do anything with the first line as it is just the number of the keyframe
	local FirstLine = ReadLine ImportedFile
	if FirstLine.count == 0 do
	(
		return undefined
	)
	
	-- Both checks above passed. Extract data from keyframe
	local KeyframeData = StructKeyframeData()
	while not eof ImportedFile do
	(
		local ThisLine = ReadLine ImportedFile
		if ThisLine.count == 0 do exit
		
		local SplitLine = GetSplitDataLine(ThisLine)
		case SplitLine.LineLabel of
		(
			"T":  KeyframeData.TimeData   = GetTimeKeyframe(ImportedFile)
			"CM": KeyframeData.CameraData = GetCameraKeyframe(ImportedFile)
			"B":  KeyframeData.BallData   = GetBallKeyframe(ImportedFile)
			"CR": KeyframeData.CarsData   = GetCarsKeyframes(ImportedFile)
			"}":  exit
		)
	)
	
	return KeyframeData
)