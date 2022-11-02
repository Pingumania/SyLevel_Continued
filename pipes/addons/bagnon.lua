local hook
local _E
if (not IsAddOnLoaded("Bagnon")) then return end

local function update(self)
	SyLevel:CallFilters("Bagnon", self, _E and self:GetItem())
end

local item = Bagnon.ItemSlot or Bagnon.Item
local function doHook()
	if (not hook) then
		hook = function(...)
			if (_E) then return update(...) end
		end
		hooksecurefunc(item, "Update", update)
	end
end

local function enable(self)
	_E = true
	doHook()
end

local function disable(self)
	_E = nil
end

SyLevel:RegisterPipe("Bagnon", enable, disable, update, "Bagnon", nil)
