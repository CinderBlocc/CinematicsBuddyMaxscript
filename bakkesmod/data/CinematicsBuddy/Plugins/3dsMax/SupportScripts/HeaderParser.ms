-- STRUCT DEFINITIONS --
struct StructRecordingMetadata
(
	PluginVersion,
	CameraName,
	FPS,
	Frames,
	Duration
)

struct StructReplayMetadata
(
	ReplayName,
	ID,
	Date,
	FPS,
	Frames
)

struct StructCarSeen
(
	CarIndex,
	PlayerID,
	BodyID,
	FrontWheelRadius,
	BackWheelRadius
)

struct StructHeaderData
(
	RecordingMetadata = StructRecordingMetadata(),
	ReplayMetadata = StructReplayMetadata(),
	CarsSeen = #()
)


-- MAIN FUNCTION DEFINITION --
function GetHeaderData ImportedFile = 
(
	local HeaderData = StructHeaderData()
	HeaderData.RecordingMetadata = GetRecordingMetadata(ImportedFile)
	HeaderData.ReplayMetadata = GetReplayMetadata(ImportedFile)
	HeaderData.CarsSeen = GetCarsSeen(ImportedFile)
	
	return HeaderData
)


-- SUPPORT FUNCTION DEFINITIONS --
function GetRecordingMetadata ImportedFile =
(
	local RecordingMetadata = StructRecordingMetadata()
	
	-- Skip "RECORDING METADATA" header
	ReadLine ImportedFile
	
	while not eof ImportedFile do
	(
		local ThisLine = ReadLine ImportedFile
		if ThisLine.count == 0 do exit
		
		local SplitLine = GetSplitHeaderLine(ThisLine)
		case SplitLine.LineLabel of
		(
			"Version":     RecordingMetadata.PluginVersion = SplitLine.LineValue
			"Camera":      RecordingMetadata.CameraName    = SplitLine.LineValue
			"Average FPS": RecordingMetadata.FPS           = SplitLine.LineValue as float
			"Frames":      RecordingMetadata.Frames        = SplitLine.LineValue as integer
			"Duration":    RecordingMetadata.Duration      = SplitLine.LineValue as float
		)
	)
	
	return RecordingMetadata
)

function GetReplayMetadata ImportedFile =
(
	local ReplayMetadata = StructReplayMetadata()
	
	-- Skip "REPLAY METADATA" header
	ReadLine ImportedFile
	
	while not eof ImportedFile do
	(
		local ThisLine = ReadLine ImportedFile
		if ThisLine.count == 0 do exit
		
		local SplitLine = GetSplitHeaderLine(ThisLine)
		case SplitLine.LineLabel of
		(
			"Name":   ReplayMetadata.ReplayName = SplitLine.LineValue
			"ID":     ReplayMetadata.ID         = SplitLine.LineValue
			"Date":   ReplayMetadata.Date       = SplitLine.LineValue
			"FPS":    ReplayMetadata.FPS        = SplitLine.LineValue as float
			"Frames": ReplayMetadata.Frames     = SplitLine.LineValue as integer
		)
	)
	
	return ReplayMetadata
)

function GetCarsSeen ImportedFile =
(
	local CarsSeen = #()
	
	-- Skip "CARS SEEN" header and opening brace
	ReadLine ImportedFile
	ReadLine ImportedFile
	
	while true do
	(
		local CarSeen = GetCarSeen(ImportedFile)
		if CarSeen == undefined do exit
		append CarsSeen CarSeen
	)
	
	return CarsSeen
)

function GetCarSeen ImportedFile = 
(
	local CarSeen = StructCarSeen()
	
	-- Get the CarsSeen index for this car. Return if it is past the last car in the list
	local IndexLine = ReadLine ImportedFile
	local bIsEndOfList = MatchPattern IndexLine pattern:"}"
	if bIsEndOfList then
	(
		return undefined
	)
	else
	(
		local SplitIndexLine = GetSplitHeaderLine(IndexLine)
		CarSeen.CarIndex = SplitIndexLine.LineLabel as integer
	)
	
	-- Get the other data for this car
	while not eof ImportedFile do
	(
		local ThisLine = ReadLine ImportedFile
		if ThisLine.count == 0 do exit
		
		local SplitLine = GetSplitHeaderLine(ThisLine)
		case SplitLine.LineLabel of
		(
			"ID":                 CarSeen.PlayerID         = SplitLine.LineValue
			"Body":               CarSeen.BodyID           = SplitLine.LineValue as integer
			"Front Wheel Radius": CarSeen.FrontWheelRadius = SplitLine.LineValue as float
			"Back Wheel Radius":  CarSeen.BackWheelRadius  = SplitLine.LineValue as float
			"}": exit
		)
	)
	
	return CarSeen
)


-- UTILITY DEFINITIONS --
struct StructSplitHeaderLine
(
	LineLabel,
	LineValue = undefined
)

function GetSplitHeaderLine HeaderLine =
(
	local SplitHeaderLine = StructSplitHeaderLine()
	
	local TrimmedLine = TrimLeft HeaderLine
	local SplitLine = FilterString TrimmedLine ":"
	
	SplitHeaderLine.LineLabel = SplitLine[1]
	if SplitLine.count > 1 do
	(
		SplitHeaderLine.LineValue = TrimLeft SplitLine[2]
	)
	
	return SplitHeaderLine
)
