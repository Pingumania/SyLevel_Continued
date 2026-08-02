local _, ns = ...
if not ns.Retail then return end

local _E
local hook

local function Update(self, rewards)
	if (rewards and #rewards > 0) then
		local index = 1
		for _, reward in pairs(rewards) do
			local Reward = self.Rewards[index]
			local itemLink = reward.itemID and select(2, C_Item.GetItemInfo(reward.itemID))
			SyLevel:CallFilters("missionreward", Reward.IconBorder, _E and itemLink)
			index = index + 1
		end
	end
end

local function DoHook()
	if (not hook) then
		hook = function(...)
			if (_E) then return Update(...) end
		end
		hooksecurefunc("GarrisonMissionButton_SetRewards", Update)
	end
end

local function ADDON_LOADED(self, event, addon)
	if (addon == "Blizzard_GarrisonUI") then
		DoHook()
		SyLevel:UnregisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function Enable()
	_E = true
	if C_AddOns.IsAddOnLoaded("Blizzard_GarrisonUI") then
		DoHook()
	else
		SyLevel:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function Disable()
	_E = nil
end

SyLevel:RegisterPipe("missionreward", Enable, Disable, Update, "Mission Reward Frame", nil)
