local hook
local _E
local conflictingAddons = {
	"LiteBag",
	"Bagnon",
	"Inventorian",
	"Baganator"
}

local function UpdateContainer(frame)
	if not frame.GetID then return end
	local id = frame:GetID()
	local name = frame:GetName()
	local size = frame.size

	for i=1, size do
		local bid = size - i + 1
		local slotFrame = _G[name.."Item"..bid]
		SyLevel:CallFilters("bags", slotFrame, _E and id, i)
	end
end

local function UpdateCombinedContainer(frame)
	if not frame.EnumerateValidItems then return end
	for _, button in frame:EnumerateValidItems() do
		local bagId = button:GetBagID()
		local buttonId = button:GetID()
		SyLevel:CallFilters("bags", button, _E and bagId, buttonId)
	end
end

local function Update(frame)
	if ContainerFrameSettingsManager and ContainerFrameSettingsManager:IsUsingCombinedBags() then
		UpdateCombinedContainer(frame)
	else
		UpdateContainer(frame)
	end
end

local function doHook()
	if (not hook) then
		hook = function(...)
			if (_E) then return Update(...) end
		end

		local id = 1
		local frame = _G["ContainerFrame"..id]
		while (frame and frame.UpdateItems) do
			hooksecurefunc(frame, "UpdateItems", Update)
			id = id + 1
			frame = _G["ContainerFrame"..id]
		end

		if ContainerFrameCombinedBags then
			hooksecurefunc(ContainerFrameCombinedBags, "UpdateItems", Update)
		else
			hooksecurefunc("ContainerFrame_Update", Update)
		end
	end
end

local function enable(self)
	_E = true
	doHook()
end

local function disable(self)
	_E = nil
end

SyLevel:RegisterPipe("bags", enable, disable, Update, "Bags", nil, conflictingAddons)
