local _, ns = ...
if not ns.Retail then return end

local _E
local hook

local function Update(lootframe, data)
	if not data then return end
	local itemLink = data.itemLink
	local slotFrame = lootframe.IconHitBox
	SyLevel:CallFilters("bossbanner", slotFrame, _E and itemLink)
end

local function Enable()
	_E = true

	if (not hook) then
		hooksecurefunc("BossBanner_ConfigureLootFrame", Update)
		hook = true
	end
end

local function Disable()
	_E = nil
end

SyLevel:RegisterPipe("bossbanner", Enable, Disable, Update, "Boss Banner", nil)
