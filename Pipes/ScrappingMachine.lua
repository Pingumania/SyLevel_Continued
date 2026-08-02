local _, ns = ...
if not ns.Retail then return end

local _E

local function Update()
	if not ScrappingMachineFrame then return end
	for button in ScrappingMachineFrame.ItemSlots.scrapButtons:EnumerateActive() do
		local slotFrame = button.Icon
		local pending = C_ScrappingMachineUI.GetCurrentPendingScrapItemLocationByIndex(button.SlotNumber)
		local bag = pending and pending.bagID
		local slot = pending and pending.slotIndex
		SyLevel:CallFilters("scrapper", slotFrame, _E and bag, slot)
	end
end

local function Dispatch(self, event, id)
	if id == Enum.PlayerInteractionType.ScrappingMachine then
		Update()
	end
end

local function ADDON_LOADED(self, event, addon)
	if (addon == "Blizzard_ScrappingMachineUI") then
		SyLevel:RegisterEvent("SCRAPPING_MACHINE_PENDING_ITEM_CHANGED", Update)
		SyLevel:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", Dispatch)
		SyLevel:UnregisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function Enable(self)
	_E = true

	if C_AddOns.IsAddOnLoaded("Blizzard_ScrappingMachineUI") then
		SyLevel:RegisterEvent("SCRAPPING_MACHINE_PENDING_ITEM_CHANGED", Update)
		SyLevel:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE", Dispatch)
	else
		SyLevel:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function Disable(self)
	_E = nil
	SyLevel:UnregisterEvent("SCRAPPING_MACHINE_PENDING_ITEM_CHANGED", Update)
end

SyLevel:RegisterPipe("scrapper", Enable, Disable, Update, "Scrapping Machine", nil)
