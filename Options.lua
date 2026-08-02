local _, ns = ...
local SyLevel = ns.SyLevel

local ALIGN_POINTS = {
	{ value = "TOP", label = "Top" },
	{ value = "BOTTOM", label = "Bottom" },
	{ value = "LEFT", label = "Left" },
	{ value = "RIGHT", label = "Right" },
	{ value = "CENTER", label = "Center" },
	{ value = "TOPLEFT", label = "Top Left" },
	{ value = "TOPRIGHT", label = "Top Right" },
	{ value = "BOTTOMLEFT", label = "Bottom Left" },
	{ value = "BOTTOMRIGHT", label = "Bottom Right" },
}

local FONT_FLAGS = {
	{ value = "", label = "None" },
	{ value = "OUTLINE", label = "Outline" },
	{ value = "THICKOUTLINE", label = "Thick Outline" },
	{ value = "MONOCHROME", label = "Monochrome" },
	{ value = "OUTLINE, MONOCHROME", label = "Outline, Monochrome" },
	{ value = "THICKOUTLINE, MONOCHROME", label = "Thick Outline, Monochrome" },
}

local COLOR_METHODS = {
	"Low Green, Yellow, Red High",
	"Low Red, Yellow, Green High",
	"Predefined Colors",
	"Current Item Level Comparison",
	"Low Green, Yellow, Red High > 450",
	"Red Green, Yellow, Green High > 450",
	"Class Coloring",
	"Quality Coloring",
}

------------------------------------------------------------------------
-- Pipes and filters
------------------------------------------------------------------------

-- every row here is a real Huddle setting, so Huddle draws and positions all of it - no
-- hand-anchored frames, which is the only way this page matches the others exactly
local function PipeKey(pipe)
	return "PipeEnabled_"..pipe
end

local function FilterKey(pipe, filterName)
	return "FilterEnabled_"..pipe.."_"..filterName
end

local pipeNames = {}
do
	for pipe, _, name in SyLevel.IteratePipes() do
		table.insert(pipeNames, { pipe = pipe, name = name })
	end
	table.sort(pipeNames, function(a, b) return a.name < b.name end)
end

local filterNames = {}
for filterName in SyLevel.IterateFilters() do
	table.insert(filterNames, filterName)
end
table.sort(filterNames)

-- reads SyLevelDB directly rather than SyLevel.IterateFiltersOnPipe, which builds a coroutine per
-- call
local function IsFilterActive(pipe, filterName)
	local enabled = SyLevelDB.EnabledFilters[filterName]
	return not not (enabled and enabled[pipe])
end

-- a typed setting needs a flat savedvariable key, but the real state lives in the nested
-- EnabledPipes/EnabledFilters tables SyLevel.lua reads at login. These mirror keys exist only for
-- Huddle to bind to, seeded from the real state here and written back through the option callbacks
local function SeedKeys()
	for _, entry in ipairs(pipeNames) do
		SyLevelDB[PipeKey(entry.pipe)] = SyLevel:IsPipeEnabled(entry.pipe)

		for _, filterName in ipairs(filterNames) do
			SyLevelDB[FilterKey(entry.pipe, filterName)] = IsFilterActive(entry.pipe, filterName)
		end
	end
end

-- chains onto Event.lua's frame, which SyLevel.lua already registered for ADDON_LOADED early in
-- the toc, so this runs right after SyLevel's own handler has populated EnabledPipes - and well
-- before Huddle's separate listener, which only registers once RegisterSettings is called below
SyLevel:RegisterEvent("ADDON_LOADED", function(_, _, addon)
	if addon == "SyLevel_Continued" then
		SeedKeys()
	end
end)

local pipeSections = {}

for _, entry in ipairs(pipeNames) do
	local pipe = entry.pipe
	local pipeKey = PipeKey(pipe)

	ns:RegisterOptionCallback(pipeKey, function(value)
		if value then
			local ok, err = pcall(SyLevel.EnablePipe, SyLevel, pipe)
			if not ok then
				print(("SyLevel: failed to enable pipe '%s': %s"):format(pipe, tostring(err)))
			end
		else
			SyLevel:DisablePipe(pipe)
		end
	end)

	local filterToggles = {}

	for _, filterName in ipairs(filterNames) do
		local filterKey = FilterKey(pipe, filterName)

		ns:RegisterOptionCallback(filterKey, function(value)
			if value then
				SyLevel:RegisterFilterOnPipe(pipe, filterName)
			else
				SyLevel:UnregisterFilterOnPipe(pipe, filterName)
			end
		end)

		table.insert(filterToggles, {
			key = filterKey,
			type = "toggle",
			title = filterName,
			default = false,
		})
	end

	local settings = {
		{
			key = pipeKey,
			type = "toggle",
			title = "Enabled",
			default = false,
		},
		{
			type = "toggles",
			title = "Filters",
			settings = filterToggles,
			gatedBy = pipeKey,
		},
	}

	table.insert(pipeSections, {
		type = "section",
		title = entry.name,
		expanded = false,
		settings = settings,
	})
end

ns:RegisterSettings("SyLevelDB", pipeSections)
ns:RegisterSettingsSlash("/sylevel")

------------------------------------------------------------------------
-- Font Settings
------------------------------------------------------------------------

-- dbKey: "FontSettings" or "FontSettingsBind"
local function CreateFontSection(title, dbKey)
	local function GetDB()
		return SyLevelDB[dbKey]
	end

	local function ApplyFont()
		SyLevel:SetFontSettings()
	end

	local function ResetField(field)
		return function()
			GetDB()[field] = SyLevel.Defaults[dbKey][field]
			ApplyFont()
		end
	end

	local function FontField(key, minValue, maxValue)
		-- Huddle's own defaults handling only refreshes dropdowns automatically (GenerateMenu);
		-- a slider's own onDefaults has to push the reset value into the widget itself, or the
		-- slider keeps showing its pre-reset position even though the underlying value changed
		local slider

		return {
			type = "custom",
			title = key == "size" and "Font Size" or key == "offsetx" and "Horizontal Offset" or "Vertical Offset",
			onDefaults = function()
				local value = SyLevel.Defaults[dbKey][key]
				GetDB()[key] = value
				ApplyFont()
				if slider then
					slider:SetValue(value)
				end
			end,
			createControl = function(rowFrame)
				slider = ns:CreateSlider(rowFrame, minValue, maxValue, 1, function()
					return GetDB()[key]
				end, function(value)
					GetDB()[key] = value
					ApplyFont()
				end)
				return slider
			end,
		}
	end

	return {
		type = "section",
		title = title,
		expanded = true,
		settings = {
			{
				type = "custom",
				title = "Typeface",
				onDefaults = ResetField("typeface"),
				createControl = function(rowFrame)
					return ns:CreateMediaDropdown(rowFrame, "font", function()
						return GetDB().typeface
					end, function(value)
						GetDB().typeface = value
						ApplyFont()
					end)
				end,
			},
			{
				type = "custom",
				title = "Align",
				tooltip = "Which side of the text region the text is drawn from.",
				onDefaults = ResetField("align"),
				createControl = function(rowFrame)
					return ns:CreateDropdown(rowFrame, ALIGN_POINTS, function()
						return GetDB().align
					end, function(value)
						GetDB().align = value
						ApplyFont()
					end)
				end,
			},
			{
				type = "custom",
				title = "Reference Point",
				tooltip = "Which point of the item slot the text is anchored to.",
				onDefaults = ResetField("reference"),
				createControl = function(rowFrame)
					return ns:CreateDropdown(rowFrame, ALIGN_POINTS, function()
						return GetDB().reference
					end, function(value)
						GetDB().reference = value
						ApplyFont()
					end)
				end,
			},
			{
				type = "custom",
				title = "Outline",
				onDefaults = ResetField("flags"),
				createControl = function(rowFrame)
					return ns:CreateDropdown(rowFrame, FONT_FLAGS, function()
						return GetDB().flags
					end, function(value)
						GetDB().flags = value
						ApplyFont()
					end)
				end,
			},
			FontField("size", 2, 60),
			FontField("offsetx", -64, 64),
			FontField("offsety", -64, 64),
		},
	}
end

ns:RegisterSubSettings("Font Settings", {
	CreateFontSection("Item Level Text", "FontSettings"),
	CreateFontSection("Bind Text", "FontSettingsBind"),
})

------------------------------------------------------------------------
-- Colors
------------------------------------------------------------------------

ns:RegisterSubSettings("Colors", {
	{
		type = "custom",
		title = "Coloring Method",
		tooltip = "Sets the mode of coloring.",
		onDefaults = function()
			SyLevel:SetColorFunc(SyLevel.Defaults.ColorFunc)
		end,
		createControl = function(rowFrame)
			local options = {}
			for i, label in ipairs(COLOR_METHODS) do
				options[i] = { value = i, label = label }
			end

			return ns:CreateDropdown(rowFrame, options, function()
				return SyLevelDB.ColorFunc
			end, function(value)
				SyLevel:SetColorFunc(value)
			end)
		end,
	},
})

------------------------------------------------------------------------
-- Filters (item level / quality thresholds)
------------------------------------------------------------------------

local ilevelSlider

ns:RegisterSubSettings("Filters", {
	{
		type = "custom",
		title = "Item Level Threshold",
		tooltip = "Only show item level text on items at or above this item level.",
		onDefaults = function()
			local value = SyLevel.Defaults.FilterSettings.ilevel
			SyLevelDB.FilterSettings.ilevel = value
			SyLevel:UpdateAllPipes()
			if ilevelSlider then
				ilevelSlider:SetValue(value)
			end
		end,
		createControl = function(rowFrame)
			ilevelSlider = ns:CreateSlider(rowFrame, 0, SyLevel.MAX_ITEM_LEVEL, 1, function()
				return SyLevelDB.FilterSettings.ilevel
			end, function(value)
				SyLevelDB.FilterSettings.ilevel = value
				SyLevel:UpdateAllPipes()
			end)
			return ilevelSlider
		end,
	},
	{
		type = "custom",
		title = "Item Quality Threshold",
		tooltip = "Only show item level text on items at or above this quality.",
		onDefaults = function()
			SyLevelDB.FilterSettings.quality = SyLevel.Defaults.FilterSettings.quality
			SyLevel:UpdateAllPipes()
		end,
		createControl = function(rowFrame)
			local options = {}
			for _, quality in ipairs({
				Enum.ItemQuality.Poor, Enum.ItemQuality.Common, Enum.ItemQuality.Uncommon,
				Enum.ItemQuality.Rare, Enum.ItemQuality.Epic, Enum.ItemQuality.Legendary,
				Enum.ItemQuality.Artifact, Enum.ItemQuality.Heirloom,
			}) do
				local label = _G["ITEM_QUALITY"..quality.."_DESC"]
				table.insert(options, { value = quality, label = ITEM_QUALITY_COLORS[quality].hex..label.."|r" })
			end

			return ns:CreateDropdown(rowFrame, options, function()
				return SyLevelDB.FilterSettings.quality
			end, function(value)
				SyLevelDB.FilterSettings.quality = value
				SyLevel:UpdateAllPipes()
			end)
		end,
	},
})

