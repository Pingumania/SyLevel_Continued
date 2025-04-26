local _, ns = ...
if not ns.Retail then return end

local _E
local hook

local function update(lootframe, data)
	if not data then return end
	local itemLink = data.itemLink
	local slotFrame = lootframe.IconHitBox
	SyLevel:CallFilters("bossbanner", slotFrame, _E and itemLink)
end

local function enable()
	_E = true

	if (not hook) then
		hooksecurefunc("BossBanner_ConfigureLootFrame", update)
		hook = true
	end
end

local function disable()
	_E = nil
end

SyLevel:RegisterPipe("bossbanner", enable, disable, update, "Boss Banner", nil)