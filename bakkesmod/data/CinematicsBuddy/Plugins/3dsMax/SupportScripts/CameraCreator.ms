-- CameraCreator creates a camera with the "Sync Shift" modifier

function CreateCamera CameraName = 
(
	local TheCamera = FreeCamera name:CameraName
	
	-- Add custom attributes
	AddModifier TheCamera (EmptyModifier())
	local TheModifier = TheCamera.modifiers[1]
	TheModifier.name = "Sync Shift"
	SyncShiftModifier = attributes SyncShiftAttributes
	(
		-- Sync Shift rollout
		parameters metadataparams rollout:ro_metadata
		(
			ShiftAmount type:#float ui:SpinnerShiftAmount
		)
		rollout ro_metadata "Sync Shift"
		(
			local    ApplyShiftTooltip = "This modifier lets you shift the keyframes in time so you can sync additional cameras to the main camera.\nShift Amount is measured in seconds."
			spinner  SpinnerShiftAmount "Shift Amount " width:162 pos:[-5,5] range:[-1000,1000,0] type:#float
			button   ButtonApplyShift "Apply Shift" width:152 pos:[5,25] tooltip:ApplyShiftTooltip
			
			on ButtonApplyShift pressed do
			(
				MessageBox "Implement this you dumdum"
				SpinnerShiftAmount.value = 0
			)
		)
	)
	CustAttributes.Add TheModifier SyncShiftModifier
	
	return TheCamera
)
