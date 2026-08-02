local _E

local function Player(index)
	local slotFrame = index and _G["TradePlayerItem"..index.."ItemButton"]
	local slotLink = index and GetTradePlayerItemLink(index)

	SyLevel:CallFilters("trade", slotFrame, _E and slotLink)
end

local function Target(index)
	local slotFrame = index and _G["TradeRecipientItem"..index.."ItemButton"]
	local slotLink = index and GetTradeTargetItemLink(index)

	SyLevel:CallFilters("trade", slotFrame, _E and slotLink)
end

local function Update()
	for i = 1, MAX_TRADE_ITEMS or 8 do
		Player(i)
		Target(i)
	end
end

local function Dispatch(self, event, id)
	if id == Enum.PlayerInteractionType.TradePartner then
		Update()
	end
end

local function TRADE_PLAYER_ITEM_CHANGED(self, event, index)
	Player(index)
end

local function TRADE_TARGET_ITEM_CHANGED(self, event, index)
	Target(index)
end

local function Enable(self)
	_E = true

	self:RegisterEvent("TRADE_UPDATE", Update)
	self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", Dispatch)
	self:RegisterEvent("TRADE_PLAYER_ITEM_CHANGED", TRADE_PLAYER_ITEM_CHANGED)
	self:RegisterEvent("TRADE_TARGET_ITEM_CHANGED", TRADE_TARGET_ITEM_CHANGED)
end

local function Disable(self)
	_E = nil

	self:UnregisterEvent("TRADE_UPDATE", Update)
	self:UnregisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", Dispatch)
	self:UnregisterEvent("TRADE_PLAYER_ITEM_CHANGED", Player)
	self:UnregisterEvent("TRADE_TARGET_ITEM_CHANGED", Target)
end

SyLevel:RegisterPipe("trade", Enable, Disable, Update, "Trade Window", nil)
