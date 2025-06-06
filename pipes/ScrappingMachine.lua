local _, ns = ...
if not ns.Retail then return end

local _E

local function update()
	if not ScrappingMachineFrame then return end
	for button in ScrappingMachineFrame.ItemSlots.scrapButtons:EnumerateActive() do
		local slotFrame = button.Icon
		local pending = C_ScrappingMachineUI.GetCurrentPendingScrapItemLocationByIndex(button.SlotNumber)
		local bag = pending and pending.bagID
		local slot = pending and pending.slotIndex
		SyLevel:CallFilters("scrapper", slotFrame, _E and bag, slot)
	end
end

local function dispatch(self, event, id)
	if id == Enum.PlayerInteractionType.ScrappingMachine then
		update()
	end
end

local function ADDON_LOADED(self, event, addon)
	if (addon == "Blizzard_ScrappingMachineUI") then
		SyLevel:RegisterEvent("SCRAPPING_MACHINE_PENDING_ITEM_CHANGED", update)
		SyLevel:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", dispatch)
		SyLevel:UnregisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function enable(self)
	_E = true

	if C_AddOns.IsAddOnLoaded("Blizzard_ScrappingMachineUI") then
		SyLevel:RegisterEvent("SCRAPPING_MACHINE_PENDING_ITEM_CHANGED", update)
		SyLevel:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", dispatch)
	else
		SyLevel:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function disable(self)
	_E = nil
	SyLevel:UnregisterEvent("SCRAPPING_MACHINE_PENDING_ITEM_CHANGED", update)
end

SyLevel:RegisterPipe("scrapper", enable, disable, update, "Scrapping Machine", nil)