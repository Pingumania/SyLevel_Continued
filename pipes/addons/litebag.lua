local _E
local hook
if (not IsAddOnLoaded("LiteBag")) then return end

local function update(button)
	if not button.GetID then return end
	local slot = button:GetID()
	local bag = button:GetParent():GetID()
	local slotFrame = _G[button:GetName()]
	SyLevel:CallFilters("litebag", slotFrame, _E and bag, slot)
end

local function enable()
	_E = true
	if (not hook) then
		hook = function(...)
			if (_E) then return update(...) end
		end
		LiteBag_RegisterHook("LiteBagItemButton_Update", update)
	end
end

local function disable()
	_E = nil
end

SyLevel:RegisterPipe("litebag", enable, disable, update, "LiteBag", nil)