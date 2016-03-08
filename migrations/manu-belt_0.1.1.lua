-- Migration based on install.  No entity changes, no graphics, etc.

local tech_to_unlock = {
	["logistics"] = {
		"basic-transport-belt-to-ground-2",
		"basic-transport-belt-to-ground-3",
		"basic-transport-belt-to-ground-4",
		"basic-transport-belt-to-ground-5",
		"basic-transport-belt-to-ground-6",
		"basic-transport-belt-to-ground-7",
		"basic-transport-belt-to-ground-8",
		"basic-transport-belt-to-ground-9",
		"basic-transport-belt-to-ground-10",
	},

	["logistics-2"] = {
		"fast-transport-belt-to-ground-2",
		"fast-transport-belt-to-ground-3",
		"fast-transport-belt-to-ground-4",
		"fast-transport-belt-to-ground-5",
		"fast-transport-belt-to-ground-6",
		"fast-transport-belt-to-ground-7",
		"fast-transport-belt-to-ground-8",
		"fast-transport-belt-to-ground-9",
		"fast-transport-belt-to-ground-10",
	},

	["logistics-3"] = {
		"express-transport-belt-to-ground-2",
		"express-transport-belt-to-ground-3",
		"express-transport-belt-to-ground-4",
		"express-transport-belt-to-ground-5",
		"express-transport-belt-to-ground-6",
		"express-transport-belt-to-ground-7",
		"express-transport-belt-to-ground-8",
		"express-transport-belt-to-ground-9",
		"express-transport-belt-to-ground-10",
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