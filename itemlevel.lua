local _, ns = ...
local SyLevel = ns.SyLevel

local tipCache, getItemInfoInstantCache, getHyperlinkCache = {}, {}, {}
local itemLevelPattern = gsub(ITEM_LEVEL, '%%d', '(%%d+).?%%(?(%%d*)%%)?')

local function CachedGetItemInfoInstant(hyperlink)
	if not getItemInfoInstantCache[hyperlink] then
		local _, itemType, itemSubType, _, _, classID, subClassID = GetItemInfoInstant(hyperlink)
		getItemInfoInstantCache[hyperlink] = {}
		getItemInfoInstantCache[hyperlink].itemType = itemType
		getItemInfoInstantCache[hyperlink].itemSubType = itemSubType
		getItemInfoInstantCache[hyperlink].classID = classID
		getItemInfoInstantCache[hyperlink].subClassID = subClassID
	end
	return getItemInfoInstantCache[hyperlink]
end

local function CachedGetHyperlink(hyperlink)
	if not getHyperlinkCache[hyperlink] then
		getHyperlinkCache[hyperlink] = C_TooltipInfo.GetHyperlink(hyperlink)
	end
	return getHyperlinkCache[hyperlink]
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

local function IsEquipment(hyperlink)
	local info = CachedGetItemInfoInstant(hyperlink)
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

do
	local itemLoc = ItemLocation:CreateEmpty()

	local function GetHyperlinkItemLevel(hyperlink)
		local data = CachedGetHyperlink(hyperlink)
		if not data then return end
		TooltipUtil.SurfaceArgs(data)

		if hyperlink and not IsEquipment(hyperlink) then return end

		if not tipCache[hyperlink] then
			CreateCacheForItem(hyperlink)
		end

		local cache = tipCache[hyperlink]
		if not cache.cached then
			-- Unfortunately GetDetailedItemLevelInfo returns garbage for max level chars
			-- cache.ilevel = GetDetailedItemLevelInfo(hyperlink)
			for _, line in ipairs(data.lines) do
				TooltipUtil.SurfaceArgs(line)
				local text = line.leftText
				local normal, timewalking = strmatch(text, itemLevelPattern)
				if timewalking and timewalking ~= "" then
					cache.ilevel = tonumber(timewalking)
					break
				elseif normal then
					cache.ilevel = tonumber(normal)
					break
				end
			end
			cache.quality = C_Item.GetItemQualityByID(hyperlink)
			cache.bindType = select(14, GetItemInfo(hyperlink))
			cache.cached = true
		end

		return cache.ilevel, cache.quality, cache.bindType
	end

	local function GetLocationItemLevel(id, slot)
		itemLoc:Clear()
		if id >= -1 and slot then
			itemLoc:SetBagAndSlot(id, slot)
		elseif id then
			itemLoc:SetEquipmentSlot(id)
		end

		local guid
		if itemLoc:HasAnyLocation() and itemLoc:IsValid() then
			guid = C_Item.GetItemGUID(itemLoc)
		end
		if not guid then return end

		local hyperlink = C_Item.GetItemLink(itemLoc)
		if hyperlink and not IsEquipment(hyperlink) then return end

		if not tipCache[guid] then
			CreateCacheForItem(guid)
		end

		local cache = tipCache[guid]
		if not cache.cached then
			cache.ilevel = C_Item.GetCurrentItemLevel(itemLoc)
			cache.quality = C_Item.GetItemQuality(itemLoc)
			cache.cached = true
		end

		-- Don't cache Artifact Weapons
		if cache.quality == Enum.ItemQuality.Artifact then
			cache.cached = nil
		end

		-- Don't cache unbound items
		if not cache.isBound then
			cache.isBound = C_Item.IsBound(itemLoc)
			cache.bindType = select(14, GetItemInfo(hyperlink))
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

local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("ITEM_CHANGED")
EventFrame:SetScript("OnEvent", function()
	wipe(tipCache)
end)