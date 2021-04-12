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

-- QUATERNIONS --
