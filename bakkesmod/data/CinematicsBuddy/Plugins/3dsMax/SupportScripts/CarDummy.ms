-- Script to create car dummy object
-- Dummy object will have the car mesh as a child, and will contain all the special data
	-- i.e. suspension distance animation, boost toggle, etc.
	
function CreateCarDummy MetadataDummy CarIndex CarMesh =
(
	-- Use MetadataDummy to collect the information about the car
		-- CarIndex is passed in from the loop in SceneObjectCreator to indicate which car's information to take from MetadataDummy
	-- CarMesh is the single mesh that was imported. Make a clone and make it a child of the dummy object
	
	
)
	