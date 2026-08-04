local _, ns = ...
local SyLevel = ns.SyLevel

local argcheck = SyLevel.argcheck

local GREY = {0.55, 0.55, 0.55}
local RED = {1, 0, 0}
local ORANGE = {1, 0.7, 0}
local YELLOW = {1, 1, 0}
local GREEN = {0, 1, 0}
local LIGHTBLUE = {0, 1, 1}
local BLUE = {0.2, 0.2, 1}
local DARKBLUE = {0, 0.5, 1}
local PURPLE = {0.7, 0, 1}
local PINK = {1, 0, 1}
local WHITE = {1, 1, 1}
-- local HEIRLOOM = {0.9, 0.8, 0.5}
local UnitClass = UnitClass
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

-- BFA Season 2 = 425
local MAX_ITEM_LEVEL = 425
SyLevel.MAX_ITEM_LEVEL = MAX_ITEM_LEVEL

--[[ Do not edit beyond this point ]]--

local colors = {
	WHITE, 				-- 1
	PINK, 				-- 2
	PURPLE, 			-- 3
	DARKBLUE, 			-- 4
	BLUE, 				-- 5
	LIGHTBLUE, 			-- 6
	GREEN, 				-- 7
	YELLOW, 			-- 8
	ORANGE, 			-- 9
	RED, 				-- 10
	{0.8, 0.8, 0.8}, 	-- 11
	{0.66, 0.66, 0.66}, -- 12
	{0.55, 0.55, 0.55}, -- 13
}

local function BuildRelative(e)
	local t = {}
	local start = (e / 12)
	local increment = (start / 6)
	for i=1,12 do
		start = start - increment
		if (start + e) > 1 then
			t[i] = start + e
		else
			t[i] = 1
		end
	end
	t[13] = 1 -- Always make level 1 items grey.
	return t
end

local relative

local function UpdateRelative()
	local _, equipped = GetAverageItemLevel()

	relative = BuildRelative(equipped)
	return relative
end

local function GetRelative()
	return relative or UpdateRelative()
end

local function RelativePosition(ilvl)
	local t = GetRelative()
	local low, high = t[12], t[1]

	if (high <= low) then return 1 end

	return max(0, min(1, (ilvl - low) / (high - low)))
end

local CS = CreateFrame("ColorSelect")

function CS:GetSmudgeColorRGB(lc, hc, perc)
	self:SetColorRGB(lc[1], lc[2], lc[3])
	local h1, s1, v1 = self:GetColorHSV()
	self:SetColorRGB(hc[1], hc[2], hc[3])
	local h2, s2, v2 = self:GetColorHSV()
	local h3 = floor(h1-(h1-h2)*perc)
	if abs(h1-h2) > 180 then
		local radius = (360-abs(h1-h2))*perc
		if h1 < h2 then
			h3 = floor(h1-radius)
			if h3 < 0 then
				h3 = 360-h3
			end
		else
			h3 = floor(h2+radius)
			if h3 > 360 then
				h3 = h3-360
			end
		end
	end
	local s3 = s1-(s1-s2)*perc
	local v3 = v1-(v1-v2)*perc
	self:SetColorHSV(h3, s3, v3)
	local r, g, b = self:GetColorRGB()
	return r, g, b
end

local function ColorFunction(l, h, lc, hc, ilvl)
	if ilvl <= l then
		return unpack(GREY)
	elseif ilvl >= h then
		return unpack(WHITE)
	else
		local p = (ilvl-l)/(h-l)
		return CS:GetSmudgeColorRGB(lc, hc, p)
	end
end

local colorFunctions = {
	[1] = function(ilvl)
		argcheck(ilvl, 2, "number")
		local perc = RelativePosition(ilvl)
		local r, g, b
		if perc < .5 then
			r = perc*2
			g = 1
			b = 0
		else
			r = 1
			g = 1-(perc-0.5)*2
			b = 0
		end
		return r, g, b
	end,
	[2] = function(ilvl)
		argcheck(ilvl, 2, "number")
		local perc = RelativePosition(ilvl)
		local r, g, b
		if perc < .5 then
			r = 1
			g = perc*2
			b = 0
		else
			r = 1-(perc-0.5)*2
			g = 1
			b = 0
		end
		return r, g, b
	end,
	[3] = function(ilvl)
		argcheck(ilvl, 2, "number")
		local t = GetRelative()
		for i=1,#t do
			if ilvl >= t[i] then
				return unpack(colors[i] or {0.3, 0.3, 0.3})
			end
		end
	end,
	[4] = function(ilvl)
		argcheck(ilvl, 2, "number")
		local t = GetRelative()
		return ColorFunction(t[12], t[1], PINK, YELLOW, ilvl)
	end,
	[5] = function()
		local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
		return color.r, color.g, color.b
	end,
	[6] = function(_, quality)
		if not quality then return 1, 1, 1 end
		local color = ITEM_QUALITY_COLORS[quality]
		return color.r, color.g, color.b
	end
}

function SyLevel:SetColorFunc(index)
	SyLevelDB.ColorFunc = index
	SyLevel:UpdateAllPipes()
end

function SyLevel:GetColorFunc()
	return colorFunctions[SyLevelDB.ColorFunc]
end

--[[ SyLevel:WithItemLevel(_equipped_, _func_)
Runs _func_ with the colour scale built from _equipped_ rather than the player's own gear, then puts
the player's scale back.
--]]
function SyLevel:WithItemLevel(equipped, func)
	argcheck(equipped, 2, "number")
	argcheck(func, 3, "function")

	local saved = relative
	relative = BuildRelative(equipped)

	func()

	relative = saved
end

local function Refresh()
	UpdateRelative()

	if (SyLevelDB) then
		SyLevel:UpdateAllPipes()
	end
end

SyLevel:RegisterEvent("PLAYER_LOGIN", function()
	C_Timer.After(0, Refresh)
end)

SyLevel:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE", Refresh)
