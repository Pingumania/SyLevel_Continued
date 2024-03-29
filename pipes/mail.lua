local _E
local hook
local stack = {}

local function send()
	for i = 1, ATTACHMENTS_MAX_SEND do
		local slotLink = GetSendMailItemLink(i)
		local slotFrame = _G["SendMailAttachment"..i]
		SyLevel:CallFilters("mail", slotFrame, _E and slotLink)
	end
end

local function inbox()
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

local function letter()
	if (not InboxFrame.openMailID) then return end

	for i = 1, ATTACHMENTS_MAX_RECEIVE do
		local itemLink = GetInboxItemLink(InboxFrame.openMailID, i)
		local slotFrame = _G["OpenMailAttachmentButton"..i]
		SyLevel:CallFilters("mail", slotFrame, _E and itemLink)
	end
end

local function update()
	send()
	inbox()
	letter()
end

local function dispatch(self, event, id)
	if id == Enum.PlayerInteractionType.MailInfo then
		send()
	end
end

local function hookLetter(...)
	if (_E) then return letter(...) end
end

local function hookInbox(...)
	if (_E) then return inbox(...) end
end

local function enable(self)
	_E = true

	self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", dispatch)
	self:RegisterEvent("MAIL_SEND_INFO_UPDATE", send)
	self:RegisterEvent("MAIL_SEND_SUCCESS", send)

	if (not hook) then
		hooksecurefunc("OpenMail_Update", hookLetter)
		hooksecurefunc("InboxFrame_Update", hookInbox)
		hook = true
	end
end

local function disable(self)
	_E =  nil

	self:UnregisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW", dispatch)
	self:UnregisterEvent("MAIL_SEND_INFO_UPDATE", send)
	self:UnregisterEvent("MAIL_SEND_SUCCESS", send)
end

SyLevel:RegisterPipe("mail", enable, disable, update, "Mail Window", nil)
