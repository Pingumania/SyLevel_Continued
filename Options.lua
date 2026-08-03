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

local function IsFilterActive(pipe, filterName)
	local enabled = SyLevelDB.EnabledFilters[filterName]
	return not not (enabled and enabled[pipe])
end

local function SeedKeys()
	for _, entry in ipairs(pipeNames) do
		local pipeKey = PipeKey(entry.pipe)
		if SyLevelDB[pipeKey] == nil then
			SyLevelDB[pipeKey] = SyLevel:IsPipeEnabled(entry.pipe)
		end

		for _, filterName in ipairs(filterNames) do
			local filterKey = FilterKey(entry.pipe, filterName)
			if SyLevelDB[filterKey] == nil then
				SyLevelDB[filterKey] = IsFilterActive(entry.pipe, filterName)
			end
		end
	end
end

SyLevel:RegisterEvent("ADDON_LOADED", function(_, _, addon)
	if addon == "SyLevel_Continued" then
		SeedKeys()
	end
end)

local pipeSections = {}

for _, entry in ipairs(pipeNames) do
	local pipe = entry.pipe
	local pipeKey = PipeKey(pipe)

	local function RefreshPipe()
		SyLevel:UpdatePipe(pipe)
	end

	ns:RegisterOptionCallback(pipeKey, function(value)
		if value then
			local ok, err = pcall(SyLevel.EnablePipe, SyLevel, pipe)
			if not ok then
				print(("SyLevel: failed to Enable pipe '%s': %s"):format(pipe, tostring(err)))
			end
		else
			SyLevel:DisablePipe(pipe)
		end

		RefreshPipe()
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

			RefreshPipe()
		end)

		table.insert(filterToggles, {
			key = filterKey,
			type = "toggle",
			title = filterName,
			default = true,
		})
	end

	table.insert(pipeSections, {
		type = "section",
		title = entry.name,
		key = pipeKey,
		default = true,
		expanded = false,
		columns = 2,
		settings = {
			{
				type = "toggles",
				settings = filterToggles,
			},
		},
	})
end

local BULK_BUTTON_WIDTH = 96
local BULK_BUTTON_HEIGHT = 22
local BULK_BUTTON_GAP = 8

local function SetOnAllPipes(GetKey, value)
	for _, entry in ipairs(pipeNames) do
		ns:SetOption(GetKey(entry.pipe), value)
	end
end

local function CreateBulkButtons(rowFrame, GetKey)
	local container = CreateFrame("Frame", nil, rowFrame)
	container:SetSize(BULK_BUTTON_WIDTH * 2 + BULK_BUTTON_GAP, BULK_BUTTON_HEIGHT)

	local enable = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
	enable:SetSize(BULK_BUTTON_WIDTH, BULK_BUTTON_HEIGHT)
	enable:SetPoint("LEFT")
	enable:SetText("Enable All")
	enable:SetScript("OnClick", function()
		SetOnAllPipes(GetKey, true)
	end)

	local disable = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
	disable:SetSize(BULK_BUTTON_WIDTH, BULK_BUTTON_HEIGHT)
	disable:SetPoint("LEFT", enable, "RIGHT", BULK_BUTTON_GAP, 0)
	disable:SetText("Disable All")
	disable:SetScript("OnClick", function()
		SetOnAllPipes(GetKey, false)
	end)

	return container
end

local rootSettings = {
	{
		type = "custom",
		title = "Pipes",
		tooltip = "Turns every pipe on or off at once.",
		createControl = function(rowFrame)
			return CreateBulkButtons(rowFrame, PipeKey)
		end,
	},
}

for _, filterName in ipairs(filterNames) do
	table.insert(rootSettings, {
		type = "custom",
		title = filterName,
		tooltip = ("Turns %s on or off for every pipe at once."):format(filterName:lower()),
		createControl = function(rowFrame)
			return CreateBulkButtons(rowFrame, function(pipe)
				return FilterKey(pipe, filterName)
			end)
		end,
	})
end

for _, section in ipairs(pipeSections) do
	table.insert(rootSettings, section)
end

ns:RegisterSettings("SyLevelDB", rootSettings)
ns:RegisterSettingsSlash("/sylevel")

------------------------------------------------------------------------
-- Font Settings
------------------------------------------------------------------------

local previews = {}

local function RefreshPreviews()
	for _, Refresh in ipairs(previews) do
		Refresh()
	end
end

local PREVIEW_HEIGHT = 84
local PREVIEW_ICON_SIZE = 37
local PREVIEW_ICON = "Interface\\Icons\\INV_Sword_04"
local PREVIEW_ILEVEL = 415
local PREVIEW_QUALITY = Enum.ItemQuality.Epic
local PREVIEW_BIND = "BoE"

-- dbKey: "FontSettings" or "FontSettingsBind"
local function CreateFontSection(title, dbKey)
	local isBind = dbKey == "FontSettingsBind"
	local previewIcon, previewText

	local function GetDB()
		return SyLevelDB[dbKey]
	end

	local function RefreshPreview()
		if not previewText then return end

		local typeface, size, align, reference, offsetx, offsety, flags = SyLevel:GetFontSettings(isBind)

		previewText:SetFont(SyLevel.media:Fetch("font", typeface), size, flags)
		previewText:SetJustifyH("CENTER")
		previewText:ClearAllPoints()
		previewText:SetPoint(align, previewIcon, reference, offsetx, offsety)

		if isBind then
			previewText:SetTextColor(1, 1, 1, 1)
			previewText:SetText(PREVIEW_BIND)
		else
			previewText:SetTextColor(SyLevel:GetColorFunc()(PREVIEW_ILEVEL, PREVIEW_QUALITY))
			previewText:SetText(PREVIEW_ILEVEL)
		end
	end

	local function CreatePreview(row)
		previewIcon = row:CreateTexture(nil, "ARTWORK")
		previewIcon:SetSize(PREVIEW_ICON_SIZE, PREVIEW_ICON_SIZE)
		previewIcon:SetPoint("CENTER")
		previewIcon:SetTexture(PREVIEW_ICON)

		previewText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")

		table.insert(previews, RefreshPreview)
		RefreshPreview()
	end

	local function ApplyFont()
		SyLevel:SetFontSettings()
		RefreshPreviews()
	end

	local function ResetField(field)
		return function()
			GetDB()[field] = SyLevel.Defaults[dbKey][field]
			ApplyFont()
		end
	end

	local function FontField(key, minValue, maxValue)
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
				type = "preview",
				height = PREVIEW_HEIGHT,
				createPreview = CreatePreview,
			},
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
				RefreshPreviews()
			end)
		end,
	},
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
