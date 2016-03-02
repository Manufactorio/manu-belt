--[[---------------------------------------------------------------------
This part is a trivial "why would I want to ever update this" approach.

In the event of a name change, or a few other things, we'll have to fix
it, but essentially what we do is mirror out the main keys, then mirror
out interior keys, change a couple of values, and install them.
---------------------------------------------------------------------]]--

-- Table of tables to go into data:extend
local dataEntries = {}

-- Belt variants
local beltModifications = {
	-- 11+1 tiles long
	{
		distance = 11,
		coefficient = 2,
		complexity = 2,
	},

	-- 17+1 tiles long
	{
		distance = 17,
		coefficient = 3,
		complexity = 3,
	}, 
	
	-- 23+1 tiles long
	{
		distance = 23,
		coefficient = 4,
		complexity = 5,
	},
	
	-- 29+1 tiles long
	{
		distance = 29,
		coefficient = 5,
		complexity = 7,
	},
}

-- Mining coefficient for time (we don't want *crazy* scaling)
local coefficient_mining_time = 0.85

local technologyCache = {}

-- Search for the tech which unlocks the target
local function ScanForTechContaining(name)
	if technologyCache[name] ~= nil then
		return technologyCache[name]
	end

	local function scanEffects(effects, name)
		for k,v in pairs(effects) do
			if type(v) == "table" then
				if v.type == "unlock-recipe" then
					if v.recipe == name then
						return true
					end
				end
			end
		end
		return false
	end

	for k,v in pairs(data.raw.technology) do
		if type(v.effects) == "table" then
			if scanEffects(v.effects, name) then
				technologyCache[name] = k
				return k
			end
		end
	end
	return ""
end

local function InsertRecipeUnlock(tech, insertedRecipe)
	table.insert(data.raw.technology[tech].effects, {
		type = "unlock-recipe",
		recipe = insertedRecipe
	})
end

local function SetTableValue(t, k, v)
	if t == nil or k == nil or v == nil then
		return
	end

	if type(k) == "string" then
		t[k] = v
	else 
		if type(k) == "table" then
			if #k == 1 then
				t[k[1]] = v
			else
				local K = {}
				for i = 2, #k do
					table.insert(K, k[i])
				end
				if not not t[k] then
					t[k] = {}
				end
				SetTableValue(t[k],K,v)
			end
		end
	end 
end

-- Trivial recursive copy
local function blindCopy(tbl)
	if tbl == nil then
		return tbl
	end

	local t = {}
	for k,v in pairs(tbl) do
		if type(v) == "table" then
			t[k] = blindCopy(v)
		else
			t[k] = v
		end
	end
	return t
end

local function GetCoefficientBasedName(t, mod)
	return t.name .. "-" .. tostring(mod.coefficient)
end

-- Performs *basic* modifications to a prototype using mod data which
-- must contain the field 'coefficient'
local function BaseModifyPrototype(t, mod)
	-- Uniquify the name 
	t.name = GetCoefficientBasedName(t, mod)
end

-- This function takes the base (copied) table and then modifies it
-- based on some fixed values.
local function PerformModificationOfBeltType(t, mod)
	BaseModifyPrototype(t, mod)

	-- Use the mod distance
	t.max_distance = mod.distance

	-- Mining needs to be updated to reflect complexity.
	t.minable.hardness = t.minable.hardness * mod.coefficient
	t.minable.mining_time = t.minable.mining_time * (coefficient_mining_time * mod.complexity)
	t.minable.result = t.name

	-- todo: images
end

local function InstallBeltRecipeVariants(src)
	for _,mod in pairs(beltModifications) do
		local t = blindCopy(src)
		t.name = GetCoefficientBasedName(t, mod)
		t.result = t.name

		for _, cost in pairs(t.ingredients) do
			cost[2] = cost[2] * mod.coefficient
		end

		local curTech = ScanForTechContaining(t.name)
		if curTech == "" then
			oldTech = ScanForTechContaining(src.name)
			if oldTech ~= "" then
				InsertRecipeUnlock(oldTech, t.name)
			end
		end

		table.insert(dataEntries, t)
	end
end

-- This function is used by belts
local function InstallBeltPrototypeVariants(src)
	for _,mod in pairs(beltModifications) do
		local t = blindCopy(src)
		PerformModificationOfBeltType(t, mod)
		table.insert(dataEntries, t)
	end
end

local function InstallBeltItemVariants(src)
	for _,mod in pairs(beltModifications) do
		local t = blindCopy(src)
		t.name = GetCoefficientBasedName(t, mod)
		-- todo: icon
		-- flags seem fine
		-- subgroup is fine
		t.order = ("b[%s]-a[%s]"):format(t.name, t.name)
		t.place_result = t.name
		-- stack_size is fine
		table.insert(dataEntries, t)
	end
end

local keys = {
	prototypes = {
		["transport-belt-to-ground"] = {
			["basic-transport-belt-to-ground"] = InstallBeltPrototypeVariants,
			["express-transport-belt-to-ground"] = InstallBeltPrototypeVariants,
			["fast-transport-belt-to-ground"] = InstallBeltPrototypeVariants
		}
	},
	items = {
		["basic-transport-belt-to-ground"] = InstallBeltItemVariants,
		["express-transport-belt-to-ground"] = InstallBeltItemVariants,
		["fast-transport-belt-to-ground"] = InstallBeltItemVariants
	},
	recipes = {
		["basic-transport-belt-to-ground"] = InstallBeltRecipeVariants,
		["express-transport-belt-to-ground"] = InstallBeltRecipeVariants,
		["fast-transport-belt-to-ground"] = InstallBeltRecipeVariants
	}
}


-- ScanForTechContaining

-- This function checks if a subtable should be mirrored and then
-- either returns the pointer/table or a copy based on the check.
local function safeMirror(k, v, lookupTable)
	if v == nil then
		return nil
	end

	-- This function mirrors a subtable non-recursively.
	local function mirror(tbl)
		local t = {}
		for k,v in pairs(tbl) do
			t[k] = v
		end
		return t
	end

	-- Start with the default assumption that we'll return v.
	local check = lookupTable[k]
	if not not check then 
		if check == "recursive" then
			return blindCopy(v)
		else
			if check == true then
				return mirror(v)
			end
		end
	end

	-- Don't mirror, keep the pointer
	return v
end

-- Nothing fancy here (for now)
local function MirrorRecipe(source)
	return blindCopy(source)
end

-- Nothing fancy here (for now)
local function MirrorItem(source)
	return blindCopy(source)
end

-- This function mirrors a prototype.
local function MirrorPrototype(source)

	-- Int checks are typically faster in the VM.
	local recursive = 2

	-- List of "safe" tables to mirror out.
	-- 'true' indicates it should be copied;
	-- 'recursive' indicates it should be recursively copied.
	local safeMirrorTables = {
		flags = true,
		minable = true,
		underground_sprite = true,
		resistances = recursive,
		collision_box = recursive,
		selection_box = recursive,
		structure = recursive,
	}

	-- This is the output table we yield.
	local t = {}

	-- This is the main walker, we assume there's nothing but
	-- bool, string, int, and tables here.  If it's a cfunction
	-- or similar we probably want it cloned.
	for k,v in pairs(source) do
		if type(v) == "table" then
			t[k] = safeMirror(k, v, safeMirrorTables)
		else
			t[k] = v
		end
	end
	return t
end

-- Step through prototypes
if keys.prototypes ~= nil then
	for key, subkeys in pairs(keys.prototypes) do
		if type(data.raw[key]) == "table" then
			for subkey, target in pairs(subkeys) do
				target(MirrorPrototype(data.raw[key][subkey]))
			end
		end
	end
end

-- Now items
if keys.items ~= nil then
	for key, target in pairs(keys.items) do
		local src = data.raw.item[key]
		if type(src) == "table" then
			target(MirrorItem(src))
		end
	end
end

-- Now recipes
if keys.recipes ~= nil then
	for key, target in pairs(keys.recipes) do
		local src = data.raw.recipe[key]
		if type(src) == "table" then
			target(MirrorRecipe(src))
		end
	end
end

-- Install all the prototypes
data:extend(
	dataEntries
)