local _, ns = ...
local SyLevel = ns.SyLevel

local scanningTooltip
local tipCache, getItemInfoInstantCache, getHyperlinkCache, setHyperlinkCache = {}, {}, {}, {}
local itemLevelPattern = gsub(ITEM_LEVEL, '%%d', '(%%d+).?%%(?(%%d*)%%)?')

local function CachedGetItemInfoInstant(itemLink)
	if not getItemInfoInstantCache[itemLink] then
		local _, itemType, itemSubType, _, _, classID, subClassID = C_Item.GetItemInfoInstant(itemLink)
		getItemInfoInstantCache[itemLink] = {}
		getItemInfoInstantCache[itemLink].itemType = itemType
		getItemInfoInstantCache[itemLink].itemSubType = itemSubType
		getItemInfoInstantCache[itemLink].classID = classID
		getItemInfoInstantCache[itemLink].subClassID = subClassID
	end
	return getItemInfoInstantCache[itemLink]
end

local function CachedGetHyperlink(itemLink)
	if not getHyperlinkCache[itemLink] then
		local data = C_TooltipInfo.GetHyperlink(itemLink)
		getHyperlinkCache[itemLink] = data.lines
	end
	return getHyperlinkCache[itemLink]
end

local function CachedSetHyperlink(itemLink)
	if not setHyperlinkCache[itemLink] then
		if not scanningTooltip then
			scanningTooltip = CreateFrame("GameTooltip", "SyLevelScanTooltip", nil, "GameTooltipTemplate")
			scanningTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		end

		scanningTooltip:ClearLines()
		local rc = pcall(scanningTooltip.SetHyperlink, scanningTooltip, itemLink)
		if not rc then return nil end

		local lines = {}
		local lineData = {}
		for i = 1, 5 do
			local label = _G["SyLevelScanTooltipTextLeft"..i]
			if label then
				local text = label:GetText()
				if text then
					lineData.leftText = text
				end
			end
			if next(lineData) then
				table.insert(lines, lineData)
			end
		end
		setHyperlinkCache[itemLink] = lines
	end
	return setHyperlinkCache[itemLink]
end

local function CreateCacheForItem(guid)
	tipCache[guid] = {
		ilevel = nil,
		quality = nil,
		isBound = nil,
		bindType = nil,
		cached = nil
	}
end

local function IsEquipment(itemLink)
	local info = CachedGetItemInfoInstant(itemLink)
	if info.classID == Enum.ItemClass.Armor then
		return true
	elseif info.classID == Enum.ItemClass.Weapon then
		return true
	elseif info.classID == Enum.ItemClass.Gem and (info.subClassID == Enum.ItemGemSubclass.Artifactrelic or info.subClassID == Enum.ItemGemSubclass.Other) then
		return true
	else
		return false
	end
end

local function IsWarboundUntilEquipped(itemLink)
	local wue = false

	if C_Item.IsItemBindToAccountUntilEquip(itemLink) then
		wue = true
	end

	return wue
end

local function GetBindType(itemLink)
	if not itemLink or itemLink == "" or not IsEquipment(itemLink) then
		return
	end

	local bindType = select(14, C_Item.GetItemInfo(itemLink))
	if bindType == 2 and IsWarboundUntilEquipped(itemLink) then
		bindType = 9
	end

	return bindType
end

do
	local itemLocation = ItemLocation:CreateEmpty()

	local function GetHyperlinkItemLevel(itemLink)
		local lines = C_TooltipInfo and CachedGetHyperlink(itemLink) or CachedSetHyperlink(itemLink)
		if not lines then return end

		if itemLink and not IsEquipment(itemLink) then return end

		if not tipCache[itemLink] then
			CreateCacheForItem(itemLink)
		end

		local cache = tipCache[itemLink]
		if not cache.cached then
			-- Unfortunately C_Item.GetDetailedItemLevelInfo returns garbage for max level chars
			-- cache.ilevel = C_Item.GetDetailedItemLevelInfo(hyperlink)
			for _, line in ipairs(lines) do
				local normal, timewalking = strmatch(line.leftText, itemLevelPattern)
				if timewalking and timewalking ~= "" then
					cache.ilevel = tonumber(timewalking)
					break
				elseif normal then
					cache.ilevel = tonumber(normal)
					break
				end
			end
			cache.quality = C_Item.GetItemQualityByID(itemLink)
			cache.bindType = GetBindType(itemLink)
			cache.cached = true
		end

		return cache.ilevel, cache.quality, cache.bindType
	end

	local function GetLocationItemLevel(id, slot)
		itemLocation:Clear()
		if id >= -1 and slot then
			itemLocation:SetBagAndSlot(id, slot)
		elseif id then
			itemLocation:SetEquipmentSlot(id)
		end

		local guid
		if itemLocation:HasAnyLocation() and itemLocation:IsValid() then
			guid = C_Item.GetItemGUID(itemLocation)
		end
		if not guid then return end

		if not tipCache[guid] then
			CreateCacheForItem(guid)
		end

		local cache = tipCache[guid]

		local itemLink = C_Item.GetItemLink(itemLocation)
		if itemLink and not IsEquipment(itemLink) then
			cache.ilevel = 0
			cache.quality = nil
			cache.cached = true
			return cache.ilevel, cache.quality
		end

		if not cache.cached then
			cache.ilevel = C_Item.GetCurrentItemLevel(itemLocation)
			cache.quality = C_Item.GetItemQuality(itemLocation)
			cache.cached = true
		end

		-- Don't cache Artifact Weapons
		if cache.quality == Enum.ItemQuality.Artifact then
			cache.cached = nil
		end

		-- Don't cache unbound items
		if not cache.isBound then
			cache.isBound = C_Item.IsBound(itemLocation)
			cache.bindType = itemLink and GetBindType(itemLink)
		end

		return cache.ilevel, cache.quality, not cache.isBound and cache.bindType
	end

	function SyLevel:GetItemLevel(arg1, arg2)
		if not arg1 then return end
		if type(arg1) == "string" then
			return GetHyperlinkItemLevel(arg1)
		else
			return GetLocationItemLevel(arg1, arg2)
		end
	end
end

if ns.Retail then
	local EventFrame = CreateFrame("Frame")
	EventFrame:RegisterEvent("ITEM_CHANGED")
	EventFrame:SetScript("OnEvent", function()
		wipe(tipCache)
	end)
end