-- Migration based on install.  No entity changes, no graphics, etc.

local tech_to_unlock = {
	["logistics"] = {
		"basic-transport-belt-to-ground-2",
		"basic-transport-belt-to-ground-3",
		"basic-transport-belt-to-ground-4",
		"basic-transport-belt-to-ground-5",
	},

	["logistics-2"] = {
		"fast-transport-belt-to-ground-2",
		"fast-transport-belt-to-ground-3",
		"fast-transport-belt-to-ground-4",
		"fast-transport-belt-to-ground-5",
	},

	["logistics-3"] = {
		"express-transport-belt-to-ground-2",
		"express-transport-belt-to-ground-3",
		"express-transport-belt-to-ground-4",
		"express-transport-belt-to-ground-5",
	}
}


for i, force in pairs(game.forces) do 
	for tech, unlocks in pairs(tech_to_unlock) do
		if force.technologies[tech].researched then 
			for _, unlock in pairs(unlocks) do
				force.recipes[unlock].enabled = true
			end
		end
	end
end