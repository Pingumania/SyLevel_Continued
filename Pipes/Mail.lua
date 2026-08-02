local _E
local hook
local stack = {}

local function Send()
	for i = 1, ATTACHMENTS_MAX_SEND do
		local slotLink = GetSendMailItemLink(i)
		local slotFrame = _G["SendMailAttachment"..i]
		SyLevel:CallFilters("mail", slotFrame, _E and slotLink)
	end
end

local function Inbox()
	local numItems = GetInboxNumItems()
	local index = ((InboxFrame.pageNum - 1) * INBOXITEMS_TO_DISPLAY) + 1

	for i = 1, INBOXITEMS_TO_DISPLAY do
		local slotFrame = _G["MailItem"..i.."Button"]
		if (index <= numItems) then
			for j = 1, ATTACHMENTS_MAX_RECEIVE do
				local attachLink = GetInboxItemLink(index, j)
				if (attachLink) then
					tinsert(stack, attachLink)
				end
			end
		end

		SyLevel:CallFilters("mail", slotFrame, _E and unpack(stack))
		wipe(stack)

		index = index + 1
	end
end

local function Letter()
	if (not InboxFrame.openMailID) then return end

	for i = 1, ATTACHMENTS_MAX_RECEIVE do
		local itemLink = GetInboxItemLink(InboxFrame.openMailID, i)
		local slotFrame = _G["OpenMailAttachmentButton"..i]
		SyLevel:CallFilters("mail", slotFrame, _E and itemLink)
	end
end

local function Update()
	Send()
	Inbox()
	Letter()
end

local function Dispatch(self, event, id)
	if id == Enum.PlayerInteractionType.MailInfo then
		Send()
	end
end

local function HookLetter(...)
	if (_E) then return Letter(...) end
end

local function HookInbox(...)
	if (_E) then return Inbox(...) end
end

local function Enable(self)
	_E = true

	self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", Dispatch)
	self:RegisterEvent("MAIL_SEND_INFO_UPDATE", Send)
	self:RegisterEvent("MAIL_SEND_SUCCESS", Send)

	if (not hook) then
		hooksecurefunc("OpenMail_Update", HookLetter)
		hooksecurefunc("InboxFrame_Update", HookInbox)
		hook = true
	end
end

local function Disable(self)
	_E =  nil

	self:UnregisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", Dispatch)
	self:UnregisterEvent("MAIL_SEND_INFO_UPDATE", Send)
	self:UnregisterEvent("MAIL_SEND_SUCCESS", Send)
end

SyLevel:RegisterPipe("mail", Enable, Disable, Update, "Mail Window", nil)
