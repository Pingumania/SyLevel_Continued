local hook
local _E

local function update(_, frame)
	-- if (not LootFrame:IsVisible()) then return end
	-- LootFrame.ScrollBox:ForEachFrame(function(frame)
	-- 	local itemLink = GetLootSlotLink(frame:GetSlotIndex())
	-- 	SyLevel:CallFilters("loot", frame.Item.IconBorder, _E and itemLink)
	-- end)
	SyLevel:CallFilters("loot", frame.item, _E and frame.link)
end

local function enable(self)
	_E = true

	if (not hook) then
		hook = true
	end

	ScrollUtil.AddInitializedFrameCallback(LootFrame.ScrollBox, update, nil, false)
	-- self:RegisterEvent("LOOT_OPENED", update)
	-- self:RegisterEvent("LOOT_SLOT_CLEARED", update)
	-- self:RegisterEvent("LOOT_SLOT_CHANGED", update)
end

local function disable(self)
	_E = nil

	self:UnregisterEvent("LOOT_OPENED", update)
	self:UnregisterEvent("LOOT_SLOT_CLEARED", update)
	self:UnregisterEvent("LOOT_SLOT_CHANGED", update)
end

SyLevel:RegisterPipe("loot", enable, disable, update, "Loot Window", nil)
