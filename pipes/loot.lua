local hook
local _E

local function update()
	if (not LootFrame:IsVisible()) then return end
	LootFrame.ScrollBox:ForEachFrame(function(frame)
		local itemLink = GetLootSlotLink(frame:GetSlotIndex())
		SyLevel:CallFilters("loot", frame.Item.IconBorder, _E and itemLink)
	end)
end

local function enable(self)
	_E = true

	if (not hook) then
		hook = true
	end

	self:RegisterEvent("LOOT_OPENED", update)
	self:RegisterEvent("LOOT_SLOT_CLEARED", update)
	self:RegisterEvent("LOOT_SLOT_CHANGED", update)
end

local function disable(self)
	_E = nil

	self:UnregisterEvent("LOOT_OPENED", update)
	self:UnregisterEvent("LOOT_SLOT_CLEARED", update)
	self:UnregisterEvent("LOOT_SLOT_CHANGED", update)
end

SyLevel:RegisterPipe("loot", enable, disable, update, "Loot Window", nil)
