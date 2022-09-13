local _, ns = ...
local SyLevel = ns.SyLevel

-- Tooltip Scanning stuff
local scanTooltip = CreateFrame("GameTooltip", "SyLevelScanTooltip", nil, "GameTooltipTemplate")
local tooltipOwner = CreateFrame("Frame")
local itemLoc = ItemLocation:CreateEmpty()
local getItemInfoCache = {}
local tipCache = {}
local itemLevelPattern = gsub(ITEM_LEVEL, '%%d', '(%%d+).?%%(?(%%d*)%%)?')
local bindPatterns = {
	[ITEM_BIND_ON_EQUIP] = "BoE",
	[ITEM_BIND_TO_BNETACCOUNT] = "BoA",
	[ITEM_BNETACCOUNTBOUND] = "BoA",
}

local function CachedGetItemInfo(key)
	if not key then return end
	if not getItemInfoCache[key] then
		getItemInfoCache[key] = select(2, GetItemInfo(key))
	end
	return getItemInfoCache[key]
end

local function CreateCacheForItem(item)
	tipCache[item] = {
		ilevel = nil,
		bound = nil,
		bindType = nil,
		quality = itemLoc:HasAnyLocation() and itemLoc:IsValid() and C_Item.GetItemQuality(itemLoc) or select(3, GetItemInfo(item)),
		cached = nil
	}
end

local function ScanTooltip(item, id, slot)
	if not item then return end
	if not tipCache[item].ilevel or tipCache[item].cached == false then
		scanTooltip:SetOwner(tooltipOwner, "ANCHOR_NONE")
		scanTooltip:ClearLines()

		if id and id > -1 and slot then
			scanTooltip.SetBagItem(scanTooltip, id, slot)
		elseif id then
			scanTooltip.SetInventoryItem(scanTooltip, "player", (id == -1) and BankButtonIDToInvSlotID(slot) or id)
		else
			local itemString = strmatch(item, "|H(.-)|h")
			scanTooltip.SetHyperlink(scanTooltip, itemString)
		end
		scanTooltip:Show()

		tipCache[item].cached = true
		tipCache[item].bindType = nil

		for i = 2, 4 do
			local label = _G["SyLevelScanTooltipTextLeft"..i]
			local text = label and label:GetText()
			if text then
				local normal, timewalking = strmatch(text, itemLevelPattern)
				if timewalking and timewalking ~= "" then
					tipCache[item].ilevel = tonumber(timewalking)
					tipCache[item].cached = false
				elseif normal then
					tipCache[item].ilevel = tonumber(normal)
				end

				if text == ITEM_SOULBOUND then
					tipCache[item].bound = true
				end

				if not tipCache[item].bound or tipCache[item].bound == false then
					for pattern, key in pairs(bindPatterns) do
						if strfind(text, pattern) then
							tipCache[item].bound = false
							tipCache[item].bindType = key
							tipCache[item].cached = false
						end
					end
				end
			end
		end

		-- Don't cache Artifact Weapons
		if tipCache[item].quality == Enum.ItemQuality.Artifact then
			tipCache[item].cached = false
		end

		tipCache[item].ilevel = tipCache[item].ilevel or 1
		scanTooltip:Hide()
	end

	return tipCache[item].ilevel, tipCache[item].quality, tipCache[item].bindType
end

function SyLevel:GetItemLevel(itemString, id, slot)
	if type(itemString) ~= "string" then return end

	local itemLink = CachedGetItemInfo(itemString)
	if not itemLink then return end

	if id and id > -1 and slot then
		itemLoc:SetBagAndSlot(id, slot)
	elseif id then
		itemLoc:SetEquipmentSlot(id)
	end
	
	local guid
	if itemLoc:HasAnyLocation() and itemLoc:IsValid() then
		guid = C_Item.GetItemGUID(itemLoc)
	end
	
	local item = guid and guid..itemLink or itemLink
	if not item then return end

	if not tipCache[item] then
		CreateCacheForItem(item)
	end

	itemLoc:Clear()

	return ScanTooltip(item, id, slot)
end