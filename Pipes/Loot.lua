local hook
local _E

local function Update(_, frame)
	if not frame then return end
	local link = GetLootSlotLink(frame:GetSlotIndex())
	SyLevel:CallFilters("loot", frame.Item, _E and link)
end

local function Enable(self)
	_E = true

	if (not hook) then
		hook = true
		ScrollUtil.AddInitializedFrameCallback(LootFrame.ScrollBox, Update, nil, false)
	end
end

local function Disable(self)
	_E = nil
end

SyLevel:RegisterPipe("loot", Enable, Disable, Update, "Loot Window", nil)
