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
	
	return undefined -- REMOVE WHEN DONE
	return HeaderData
)


-- SUPPORT FUNCTION DEFINITIONS --
function GetRecordingMetadata ImportedFile =
(
	local RecordingMetadata = StructRecordingMetadata()
	
	return RecordingMetadata
)

function GetRecordingMetadata ImportedFile =
(
	local ReplayMetadata = StructReplayMetadata()
	
	return ReplayMetadata
)

function GetCarsSeen ImportedFile =
(
	local CarsSeen = #()
	
	while true do
	(
		local CarSeen = GetCarSeen(ImportedFile)
		if CarSeen != undefined do exit
		append CarsSeen CarSeen
	)
	
	return CarsSeen
)

function GetCarSeen ImportedFile = 
(
	local CarSeen = StructCarSeen()
	
	return undefined -- REMOVE WHEN DONE
	return CarSeen
)


-- UTILITY DEFINITIONS --
struct StructSplitHeaderLine
(
	LineLabel,
	LineValue
)

function GetSplitHeaderLine HeaderLine =
(
	-- Split line based on ':' and remove leading whitespace from value
	-- Return a StructSplitHeaderLine object
)
