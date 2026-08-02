local _E
local hook

local capturedOutputIcon, capturedTransaction, capturedOutputItemInfo

local function Update(outputIcon, transaction, outputItemInfo)
	if not outputIcon then return end
	if not transaction then return end
	if not outputItemInfo then return end
	local itemIDOrLink = outputItemInfo.hyperlink
	if not capturedOutputItemInfo or outputItemInfo == capturedOutputItemInfo then
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

local function DoHook()
	if (not hook) then
		hook = function(...)
			if (_E) then return Update(...) end
		end
		hooksecurefunc(Professions, "SetupOutputIcon", hook)
		EventRegistry:RegisterCallback("Professions.TransactionUpdated", function()
			Update(capturedOutputIcon, capturedTransaction, capturedOutputItemInfo)
		end)
	end
end

local function ADDON_LOADED(self, event, addon)
	if (addon == "Blizzard_Professions") then
		DoHook()
		self:UnregisterEvent(event, ADDON_LOADED)
	end
end

local function Enable(self)
	_E = true

	if (C_AddOns.IsAddOnLoaded("Blizzard_Professions")) then
		DoHook()
	else
		self:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function Disable(self)
	_E = nil
	self:UnregisterEvent("ADDON_LOADED", ADDON_LOADED)
end

SyLevel:RegisterPipe("tradeskill", Enable, Disable, Update, "Profession Window", nil)
