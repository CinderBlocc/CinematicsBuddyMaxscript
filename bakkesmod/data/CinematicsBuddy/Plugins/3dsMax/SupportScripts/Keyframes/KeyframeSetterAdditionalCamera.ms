-- KeyframeSetterAdditionalCamera handles importing an additional camera and attempts to sync it with the rest of the scene


-- STRUCT DEFINITIONS --
struct StructSyncData
(
	FirstValidKeyframe = undefined,
	AnimationStartTime = -1
)

-- SUPPORT FUNCTION DEFINITIONS --
function FindSyncData FirstKeyframeData MetadataDummy = 
(
	local SyncData = StructSyncData()

	return SyncData
)

-- MAIN FUNCTION DEFINITION --
function ApplyCameraOnlyKeyframe KeyframeData SceneObjects = 
(
	-- Get keyframe time as a factor of frames at 60 fps
	local KeyframeTime = KeyframeData.TimeKeyframe.RealTime * 60
	
	set animate on
	
	set animate off
)
