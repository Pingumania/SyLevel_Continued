local BINDING = {
	NONE = "None",
	SOULBOUND = "Soulbound",
	BOE = "BoE",
	BOU = "BoU",
	QUEST = "Quest",
	NOBANK = "NoBank",
	UNKNOWN = "Unknown",
	ACCOUNT = "Warbound",
	BNET = "BNet",
	WUE = HEIRLOOM_BLUE_COLOR_CODE.."WuE",
}

local BINDINGID = {
	NONE = 0,
	SOULBOUND = 1,
	BOE = 2,
	BOU = 3,
	QUEST = 4,
	NOBANK = 5,
	UNKNOWN = 6,
	ACCOUNT = 7,
	BNET = 8,
	WUE = 9,
}

local BINDINGSTRING = {
	[BINDINGID.NONE] = BINDING.NONE,
	[BINDINGID.SOULBOUND] = BINDING.SOULBOUND,
	[BINDINGID.BOE] = BINDING.BOE,
	[BINDINGID.BOU] = BINDING.BOU,
	[BINDINGID.QUEST] = BINDING.QUEST,
	[BINDINGID.NOBANK] = BINDING.NOBANK,
	[BINDINGID.UNKNOWN] = BINDING.UNKNOWN,
	[BINDINGID.ACCOUNT] = BINDING.ACCOUNT,
	[BINDINGID.BNET] = BINDING.BNET,
	[BINDINGID.WUE] = BINDING.WUE,
}

local function binds(...)
	if not select(1, ...) then return end
	local _, _, bind = SyLevel:GetItemLevel(...)

	if bind and (bind == 2 or bind == 9) then
		return BINDINGSTRING[bind] or ""
	end
end

SyLevel:RegisterFilter("Bind text", "BindsOnText", binds, [[Adds bind on text that the items have.]])