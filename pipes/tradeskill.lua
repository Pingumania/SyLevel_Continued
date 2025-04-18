local _E
local hook

local capturedOutputIcon, capturedTransaction, capturedOutputItemInfo

local function update(outputIcon, transaction, outputItemInfo)
	if not outputIcon then return end
	local itemIDOrLink = outputItemInfo.hyperlink
	if outputItemInfo == capturedOutputItemInfo then
		local reagents = transaction:CreateCraftingReagentInfoTbl()
		local recipeSchematic = transaction:GetRecipeSchematic()
		local info = C_TradeSkillUI.GetRecipeOutputItemData(recipeSchematic.recipeID, reagents, transaction:GetAllocationItemGUID())
		itemIDOrLink = info.hyperlink
	end
	capturedOutputIcon = outputIcon
	capturedTransaction = transaction
	capturedOutputItemInfo = outputItemInfo
	SyLevel:CallFilters("tradeskill", outputIcon, _E and itemIDOrLink)
end

local function doHook()
	if (not hook) then
		hook = function(...)
			if (_E) then return update(...) end
		end
		hooksecurefunc(Professions, "SetupOutputIcon", hook)
		EventRegistry:RegisterCallback("Professions.AllocationUpdated", function()
			update(capturedOutputIcon, capturedTransaction, capturedOutputItemInfo)
		end)
	end
end

local function ADDON_LOADED(self, event, addon)
	if (addon == "Blizzard_Professions") then
		doHook()
		self:UnregisterEvent(event, ADDON_LOADED)
	end
end

local function enable(self)
	_E = true

	if (C_AddOns.IsAddOnLoaded("Blizzard_Professions")) then
		doHook()
	else
		self:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function disable(self)
	_E = nil
	self:UnregisterEvent("ADDON_LOADED", ADDON_LOADED)
end

SyLevel:RegisterPipe("tradeskill", enable, disable, update, "Profession Window", nil)