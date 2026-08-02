local _E

local function Update()
	if (not GuildBankFrame) then return end
	if (not GuildBankFrame:IsVisible()) then return end
	local tab = GetCurrentGuildBankTab()
	for i = 1, MAX_GUILDBANK_SLOTS_PER_TAB or 98 do
		local index = math.fmod(i, 14)
		if (index == 0) then
			index = 14
		end
		local column = math.ceil((i-0.5)/14)

		local slotLink = GetGuildBankItemLink(tab, i)
		local slotFrame = _G["GuildBankColumn"..column.."Button"..index]

		SyLevel:CallFilters("gbank", slotFrame, _E and slotLink)
	end
end

local function Dispatch(self, event, id)
	if id == Enum.PlayerInteractionType.GuildBanker then
		Update()
	end
end

local function ADDON_LOADED(self, event, addon)
	if (addon == "Blizzard_GuildBankUI") then
		self:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED", Update)
		self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", Dispatch)
		self:UnregisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function Enable(self)
	_E = true
	if C_AddOns.IsAddOnLoaded("Blizzard_GuildBankUI") then
		self:RegisterEvent("GUILDBANKBAGSLOTS_CHANGED", Update)
		self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", Dispatch)
	else
		self:RegisterEvent("ADDON_LOADED", ADDON_LOADED)
	end
end

local function Disable(self)
	_E = nil
	self:UnregisterEvent("GUILDBANKBAGSLOTS_CHANGED", Update)
	self:UnregisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", Dispatch)
end

SyLevel:RegisterPipe("gbank", Enable, Disable, Update, "Guild Bank Window", nil)
