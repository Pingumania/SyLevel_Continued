local hook
local _E

local function update(_, frame)
	local link = GetLootSlotLink(frame:GetSlotIndex())
	SyLevel:CallFilters("loot", frame.Item, _E and link)
end

local function enable(self)
	_E = true

	if (not hook) then
		hook = true
	end

	ScrollUtil.AddInitializedFrameCallback(LootFrame.ScrollBox, update, nil, false)
end

local function disable(self)
	_E = nil
end

SyLevel:RegisterPipe("loot", enable, disable, update, "Loot Window", nil)
