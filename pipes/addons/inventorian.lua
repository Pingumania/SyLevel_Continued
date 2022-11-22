local hook
local _E
if (not IsAddOnLoaded("Inventorian")) then return end

local function ToIndex(bag, slot) -- copied from inside Inventorian
	return (bag < 0 and bag * 100 - slot) or (bag * 100 + slot)
end

local function update(self, bag, slot)
	SyLevel:CallFilters("Inventorian", self.items[ToIndex(bag, slot)], _E and bag, slot)
end

local function doHook()
	if (not hook) then
		hook = function(...)
			if (_E) then return update(...) end
		end

		local inv = LibStub("AceAddon-3.0", true):GetAddon("Inventorian", true)

		local function hookInventorian()
			hooksecurefunc(inv.bag.itemContainer, "UpdateSlot", update)
			hooksecurefunc(inv.bank.itemContainer, "UpdateSlot", update)
		end

		if inv.bag then
			hookInventorian()
		else
			hooksecurefunc(inv, "OnEnable", function()
				hookInventorian()
			end)
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

SyLevel:RegisterPipe("Inventorian", enable, disable, update, "Inventorian", nil)
