local ilevelThreshold, qualityThreshold

local function ilevel(...)
	if not select(1, ...) then return end
	local ilvl, quality = SyLevel:GetItemLevel(...)

	if ilvl and (ilvl >= ilevelThreshold) and (quality >= qualityThreshold) then
		return ilvl, quality
	end
end

SyLevel:RegisterOptionCallback(function(db)
	local filters = db.FilterSettings
	if (filters and filters.ilevel) then
		ilevelThreshold = filters.ilevel
	else
		ilevelThreshold = 1
	end
	if (filters and filters.quality) then
		qualityThreshold = filters.quality
	else
		qualityThreshold = 0
	end
end)

SyLevel:RegisterFilter("Item level text", "ItemLevelText", ilevel, [[Adds item level text that the items have.]])