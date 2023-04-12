local _, ns = ...
local SyLevel = ns.SyLevel

local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame:Hide()
frame.name = "Font Settings"
frame.parent = ns.TrivName

frame:SetScript("OnShow", function(self)
	self:CreateOptions()
	self:SetScript("OnShow", nil)
end)

function frame:CreateOptions()
	local title = ns.createFontString(self, "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText(ns.TrivName..": Font Settings")

	-- Item Level

	local fontsLabel = ns.createFontString(self, "GameFontNormalSmall")
	fontsLabel:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
	fontsLabel:SetText("Typeface")

	local font = SyLevelDB.FontSettings

	local fontsDDown = CreateFrame("Button", ns.Name.."_FontsDropdown", self, "UIDropDownMenuTemplate")
	fontsDDown:SetPoint("TOPLEFT", fontsLabel, "BOTTOMLEFT", -6, -4)
	UIDropDownMenu_SetWidth(fontsDDown, 200)
	UIDropDownMenu_SetText(fontsDDown, font.typeface)

	local fontsLabelAlign = ns.createFontString(self, "GameFontNormalSmall")
	fontsLabelAlign:SetPoint("TOPLEFT", fontsLabel, "BOTTOMLEFT", 0, -48)
	fontsLabelAlign:SetText("Align")

	local fontsDDownAlign = CreateFrame("Button", ns.Name.."_AlignDropdown", self, "UIDropDownMenuTemplate")
	fontsDDownAlign:SetPoint("TOPLEFT", fontsLabelAlign, "BOTTOMLEFT", -6, -4)
	UIDropDownMenu_SetWidth(fontsDDownAlign, 200)
	UIDropDownMenu_SetText(fontsDDownAlign, font.reference)

	local fontsLabelRef = ns.createFontString(self, "GameFontNormalSmall")
	fontsLabelRef:SetPoint("TOPLEFT", fontsLabelAlign, "BOTTOMLEFT", 0, -48)
	fontsLabelRef:SetText("Reference")

	local fontsDDownRef = CreateFrame("Button", ns.Name.."_ReferenceDropdown", self, "UIDropDownMenuTemplate")
	fontsDDownRef:SetPoint("TOPLEFT", fontsLabelRef, "BOTTOMLEFT", -6, -4)
	UIDropDownMenu_SetWidth(fontsDDownRef, 200)
	UIDropDownMenu_SetText(fontsDDownRef, font.align)

	local regionPoints = {"TOP", "BOTTOM", "LEFT", "RIGHT", "CENTER", "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"}

	do
		local function DropDown_OnClick(info)
			local t = SyLevel.media:List("font")
			font.typeface = t[info.value]
			SyLevel:SetFontSettings()
			UIDropDownMenu_SetText(fontsDDown, font.typeface)
		end

		local function DropDownRef_OnClick(info)
			local t = regionPoints
			font.reference = t[info.value]
			SyLevel:SetFontSettings()
			UIDropDownMenu_SetText(fontsDDownRef, font.reference)
		end

		local function DropDownAlign_OnClick(info)
			local t = regionPoints
			font.align = t[info.value]
			SyLevel:SetFontSettings()
			UIDropDownMenu_SetText(fontsDDownAlign, font.align)
		end

		local function DropDown_OnEnter()
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
			GameTooltip:SetText("Set your preferred font for text display.", nil, nil, nil, nil, 1)
		end

		local DropDown_OnLeave = GameTooltip_Hide

		local function DropDown_init()
			local info
			local t = SyLevel.media:List("font")
			for i=1,#t do
				info = UIDropDownMenu_CreateInfo()
				info.text = t[i]
				info.value = i
				info.func = DropDown_OnClick
				info.checked = t[i] == font.typeface
				UIDropDownMenu_AddButton(info)
			end
		end

		local function DropDownRef_init()
			local info
			local t = regionPoints
			for i=1,#t do
				info = UIDropDownMenu_CreateInfo()
				info.text = t[i]
				info.value = i
				info.func = DropDownRef_OnClick
				info.checked = t[i] == font.reference
				UIDropDownMenu_AddButton(info)
			end
		end

		local function DropDownAlign_init()
			local info
			local t = regionPoints
			for i=1,#t do
				info = UIDropDownMenu_CreateInfo()
				info.text = t[i]
				info.value = i
				info.func = DropDownAlign_OnClick
				info.checked = t[i] == font.align
				UIDropDownMenu_AddButton(info)
			end
		end

		fontsDDown:SetScript("OnEnter", DropDown_OnEnter)
		fontsDDown:SetScript("OnLeave", DropDown_OnLeave)

		function frame.refresh()
			UIDropDownMenu_Initialize(fontsDDown, DropDown_init)
			UIDropDownMenu_Initialize(fontsDDownAlign, DropDownAlign_init)
			UIDropDownMenu_Initialize(fontsDDownRef, DropDownRef_init)
		end

		self:refresh()
	end

	local s1 = ns.createSlider(frame, "Font Size", 2, 60, 1)
	s1:SetPoint("TOPLEFT", fontsDDownRef, "BOTTOMLEFT", 10, -32)
	s1:SetValue(font.size)
	s1:Show()

	local e1 = ns.createEditBox(self, "Font Size", 40, 20, true, 2)
	e1:SetPoint("TOP", s1, "BOTTOM", 0, -7)
	e1:SetNumber(font.size)
	e1.Update = function()
		e1:SetNumber(font.size)
		s1:SetValue(font.size)
		e1:ClearFocus()
		SyLevel:SetFontSettings()
	end
	e1:SetScript("OnEnterPressed", function(self)
		local value = tonumber(self:GetText())
		if not value then
			value = font.size
		elseif value < 2 then
			value = 2
		elseif value > 60 then
			value = 60
		end
		font.size = value
		e1.Update()
	end)
	s1:SetScript("OnValueChanged", function(self)
		font.size = self:GetValue()
		e1.Update()
	end)

	local s2 = ns.createSlider(frame, "X Offset", -64, 64, 1)
	s2:SetPoint("LEFT", s1, "RIGHT", 10, 0)
	s2:SetValue(font.offsetx)
	s2:Show()
	local e2 = ns.createEditBox(self, "X Offset", 40, 20, false, 4)
	e2:SetPoint("TOP", s2, "BOTTOM", 0, -7)
	e2:SetText(font.offsetx or 0)
	e2.Update = function()
		e2:SetText(font.offsetx)
		s2:SetValue(font.offsetx)
		e2:ClearFocus()
		SyLevel:SetFontSettings()
	end
	e2:SetScript("OnEnterPressed", function(self)
		local value = tonumber(self:GetText())
		if not value then
			value = font.offsetx
		elseif value < -64 then
			value = -64
		elseif value > 64 then
			value = 64
		end
		font.offsetx = value
		e2.Update()
	end)
	s2:SetScript("OnValueChanged", function(self)
		font.offsetx = self:GetValue()
		e2.Update()
	end)

	local s3 = ns.createSlider(frame, "Y Offset", -64, 64, 1)
	s3:SetPoint("LEFT", s2, "RIGHT",10,0)
	s3:SetValue(font.offsety)
	s3:Show()
	local e3 = ns.createEditBox(self, "Y Offset", 40, 20, false, 4)
	e3:SetPoint("TOP", s3, "BOTTOM", 0, -7)
	e3:SetText(font.offsety or 0)
	e3.Update = function()
		e3:SetText(font.offsety)
		s3:SetValue(font.offsety)
		e3:ClearFocus()
		SyLevel:SetFontSettings()
	end
	e3:SetScript("OnEnterPressed", function(self)
		local value = tonumber(self:GetText())
		if not value then
			value = font.offsety
		elseif value < -64 then
			value = -64
		elseif value > 64 then
			value = 64
		end
		font.offsety = value
		e3.Update()
	end)
	s3:SetScript("OnValueChanged", function(self)
		font.offsety = self:GetValue()
		e3.Update()
	end)

	-- Bind

	local fontsLabel2 = ns.createFontString(self, "GameFontNormalSmall")
	fontsLabel2:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16 -280)
	fontsLabel2:SetText("Typeface")

	local font2 = SyLevelDB.FontSettingsBind

	local fontsDDown2 = CreateFrame("Button", ns.Name.."_FontsDropdown", self, "UIDropDownMenuTemplate")
	fontsDDown2:SetPoint("TOPLEFT", fontsLabel2, "BOTTOMLEFT", -6, -4)
	UIDropDownMenu_SetWidth(fontsDDown2, 200)
	UIDropDownMenu_SetText(fontsDDown2, font2.typeface)

	local fontsLabelAlign2 = ns.createFontString(self, "GameFontNormalSmall")
	fontsLabelAlign2:SetPoint("TOPLEFT", fontsLabel2, "BOTTOMLEFT", 0, -48)
	fontsLabelAlign2:SetText("Align")

	local fontsDDownAlign2 = CreateFrame("Button", ns.Name.."_AlignDropdown", self, "UIDropDownMenuTemplate")
	fontsDDownAlign2:SetPoint("TOPLEFT", fontsLabelAlign2, "BOTTOMLEFT", -6, -4)
	UIDropDownMenu_SetWidth(fontsDDownAlign2, 200)
	UIDropDownMenu_SetText(fontsDDownAlign2, font2.reference)

	local fontsLabelRef2 = ns.createFontString(self, "GameFontNormalSmall")
	fontsLabelRef2:SetPoint("TOPLEFT", fontsLabelAlign2, "BOTTOMLEFT", 0, -48)
	fontsLabelRef2:SetText("Reference")

	local fontsDDownRef2 = CreateFrame("Button", ns.Name.."_ReferenceDropdown", self, "UIDropDownMenuTemplate")
	fontsDDownRef2:SetPoint("TOPLEFT", fontsLabelRef2, "BOTTOMLEFT", -6, -4)
	UIDropDownMenu_SetWidth(fontsDDownRef2, 200)
	UIDropDownMenu_SetText(fontsDDownRef2, font2.align)

	local regionPoints2 = {"TOP", "BOTTOM", "LEFT", "RIGHT", "CENTER", "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"}

	do
		local function DropDown_OnClick(info)
			local t = SyLevel.media:List("font")
			font2.typeface = t[info.value]
			SyLevel:SetFontSettings()
			UIDropDownMenu_SetText(fontsDDown2, font2.typeface)
		end

		local function DropDownRef_OnClick(info)
			local t = regionPoints2
			font2.reference = t[info.value]
			SyLevel:SetFontSettings()
			UIDropDownMenu_SetText(fontsDDownRef2, font2.reference)
		end

		local function DropDownAlign_OnClick(info)
			local t = regionPoints2
			font2.align = t[info.value]
			SyLevel:SetFontSettings()
			UIDropDownMenu_SetText(fontsDDownAlign2, font2.align)
		end

		local function DropDown_OnEnter()
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
			GameTooltip:SetText("Set your preferred font for text display.", nil, nil, nil, nil, 1)
		end

		local DropDown_OnLeave = GameTooltip_Hide

		local function DropDown_init()
			local info
			local t = SyLevel.media:List("font")
			for i=1,#t do
				info = UIDropDownMenu_CreateInfo()
				info.text = t[i]
				info.value = i
				info.func = DropDown_OnClick
				info.checked = t[i] == font2.typeface
				UIDropDownMenu_AddButton(info)
			end
		end

		local function DropDownRef_init()
			local info
			local t = regionPoints
			for i=1,#t do
				info = UIDropDownMenu_CreateInfo()
				info.text = t[i]
				info.value = i
				info.func = DropDownRef_OnClick
				info.checked = t[i] == font2.reference
				UIDropDownMenu_AddButton(info)
			end
		end

		local function DropDownAlign_init()
			local info
			local t = regionPoints
			for i=1,#t do
				info = UIDropDownMenu_CreateInfo()
				info.text = t[i]
				info.value = i
				info.func = DropDownAlign_OnClick
				info.checked = t[i] == font2.align
				UIDropDownMenu_AddButton(info)
			end
		end

		fontsDDown2:SetScript("OnEnter", DropDown_OnEnter)
		fontsDDown2:SetScript("OnLeave", DropDown_OnLeave)

		function frame.refresh()
			UIDropDownMenu_Initialize(fontsDDown2, DropDown_init)
			UIDropDownMenu_Initialize(fontsDDownAlign2, DropDownAlign_init)
			UIDropDownMenu_Initialize(fontsDDownRef2, DropDownRef_init)
		end

		self:refresh()
	end

	local s4 = ns.createSlider(frame, "Font Size", 2, 60, 1)
	s4:SetPoint("TOPLEFT", fontsDDownRef2, "BOTTOMLEFT", 10, -32)
	s4:SetValue(font2.size)
	s4:Show()

	local e4 = ns.createEditBox(self, "Font Size", 40, 20, true, 2)
	e4:SetPoint("TOP", s4, "BOTTOM", 0, -7)
	e4:SetNumber(font2.size)
	e4.Update = function()
		e4:SetNumber(font2.size)
		s4:SetValue(font2.size)
		e4:ClearFocus()
		SyLevel:SetFontSettings()
	end
	e4:SetScript("OnEnterPressed", function(self)
		local value = tonumber(self:GetText())
		if not value then
			value = font2.size
		elseif value < 2 then
			value = 2
		elseif value > 60 then
			value = 60
		end
		font2.size = value
		e4.Update()
	end)
	s4:SetScript("OnValueChanged", function(self)
		font2.size = self:GetValue()
		e4.Update()
	end)

	local s5 = ns.createSlider(frame, "X Offset", -64, 64, 1)
	s5:SetPoint("LEFT", s4, "RIGHT", 10, 0)
	s5:SetValue(font2.offsetx)
	s5:Show()
	local e5 = ns.createEditBox(self, "X Offset", 40, 20, false, 4)
	e5:SetPoint("TOP", s5, "BOTTOM", 0, -7)
	e5:SetText(font2.offsetx or 0)
	e5.Update = function()
		e5:SetText(font2.offsetx)
		s5:SetValue(font2.offsetx)
		e5:ClearFocus()
		SyLevel:SetFontSettings()
	end
	e5:SetScript("OnEnterPressed", function(self)
		local value = tonumber(self:GetText())
		if not value then
			value = font2.offsetx
		elseif value < -64 then
			value = -64
		elseif value > 64 then
			value = 64
		end
		font2.offsetx = value
		e5.Update()
	end)
	s5:SetScript("OnValueChanged", function(self)
		font2.offsetx = self:GetValue()
		e5.Update()
	end)

	local s6 = ns.createSlider(frame, "Y Offset", -64, 64, 1)
	s6:SetPoint("LEFT", s5, "RIGHT",10,0)
	s6:SetValue(font2.offsety)
	s6:Show()
	local e6 = ns.createEditBox(self, "Y Offset", 40, 20, false, 4)
	e6:SetPoint("TOP", s6, "BOTTOM", 0, -7)
	e6:SetText(font2.offsety or 0)
	e6.Update = function()
		e6:SetText(font2.offsety)
		s6:SetValue(font2.offsety)
		e6:ClearFocus()
		SyLevel:SetFontSettings()
	end
	e6:SetScript("OnEnterPressed", function(self)
		local value = tonumber(self:GetText())
		if not value then
			value = font2.offsety
		elseif value < -64 then
			value = -64
		elseif value > 64 then
			value = 64
		end
		font2.offsety = value
		e6.Update()
	end)
	s6:SetScript("OnValueChanged", function(self)
		font2.offsety = self:GetValue()
		e6.Update()
	end)
end

InterfaceOptions_AddCategory(frame)