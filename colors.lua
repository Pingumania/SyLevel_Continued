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

local ilvls = {
	395, -- 1
	380, -- 2
	365, -- 3
	350, -- 4
	335, -- 5
	320, -- 6
	305, -- 7
	250, -- 8
	200, -- 9
	150, -- 10
	100, -- 11
	50, -- 12
	1 -- 13
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
		ilvl = (ilvl / MAX_ITEM_LEVEL)
		local r, g, b
		if ilvl < .5 then
			r = ilvl*2
			g = 1
			b = 0
		else
			r = 1
			g = 1-(ilvl-0.5)*2
			b = 0
		end
		return r, g, b
	end,
	[2] = function(ilvl)
		argcheck(ilvl, 2, "number")
		ilvl = (ilvl / MAX_ITEM_LEVEL)
		local r, g, b
		if ilvl < .5 then
			r = 1
			g = ilvl*2
			b = 0
		else
			r = 1-(ilvl-0.5)*2
			g = 1
			b = 0
		end
		return r, g, b
	end,
	[3] = function(ilvl)
		argcheck(ilvl, 2, "number")
		for i=1,#ilvls do
			if ilvl >= ilvls[i] then
				return unpack(colors[i] or {0.3, 0.3, 0.3})
			end
		end
	end,
	[4] = function(ilvl)
		argcheck(ilvl, 2, "number")
		local _, e = GetAverageItemLevel()
		local relative = BuildRelative(e)
		return ColorFunction(relative[12], relative[1], PINK, YELLOW, ilvl)
	end,
	[5] = function(ilvl)
		argcheck(ilvl, 2, "number")
		local r, g, b
		if ilvl <= 450 then
			r = 0.55
			g = 0.55
			b = 0.55
		elseif ilvl > 450 then
			ilvl = (ilvl - 450) / 260
			if ilvl < 0.5 then
				r = ilvl*2
				g = 1
				b = 0
			else

				r = 1
				g = 1-(ilvl-0.5)*2
				b = 0
			end
		end
		return r, g, b
	end,
	[6] = function(ilvl)
		argcheck(ilvl, 2, "number")
		local r, g, b
		if ilvl <= 450 then
			r = 0.55
			g = 0.55
			b = 0.55
		elseif ilvl > 450 then
			ilvl = (ilvl - 450) / 260
			if ilvl < .5 then
				r = 1
				g = ilvl*2
				b = 0
			else
				r = 1-(ilvl-0.5)*2
				g = 1
				b = 0
			end
		end
		return r, g, b
	end,
	[7] = function()
		local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
		return color.r, color.g, color.b
	end,
	[8] = function(_, quality)
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