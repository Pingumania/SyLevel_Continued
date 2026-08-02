local _, ns = ...
local SyLevel = ns.SyLevel

local colorFunc
local typeface, size, align, reference, offsetx, offsety, flags
local Media = SyLevel.media

local function CreateText(self)
	local tc = self.SyLevelText
	if (not tc) then
		if (not self:IsObjectType("Frame")) then
			tc = self:GetParent():CreateFontString(nil, "OVERLAY")
		else
			tc = self:CreateFontString(nil, "OVERLAY")
		end
		self.SyLevelText = tc
	end
	return tc
end

local styleVersion = 0

local function UpdateFont()
	typeface, size, align, reference, offsetx, offsety, flags = SyLevel:GetFontSettings()
	styleVersion = styleVersion + 1
end

local function UpdateColorFunc()
	colorFunc = SyLevel:GetColorFunc()
end

local function TextDisplay(frame, value, quality)
	if not frame then return end
	if value then
		local tc = CreateText(frame)
		if not typeface then UpdateFont() end
		if not colorFunc then UpdateColorFunc() end

		if tc.syLevelStyle ~= styleVersion then
			tc:SetFont(Media:Fetch("font", typeface), size, flags)
			tc:SetJustifyH("CENTER")
			tc:ClearAllPoints()
			tc:SetPoint(align, frame, reference, offsetx, offsety)
			tc.syLevelStyle = styleVersion
		end

		tc:SetTextColor(1, 1, 1, 1)
		if quality then
			tc:SetTextColor(colorFunc(value, quality))
		end
		tc:SetText(value)
		tc:Show()
	elseif (frame.SyLevelText) then
		frame.SyLevelText:Hide()
	end
end

SyLevel:RegisterOptionCallback(UpdateFont)
SyLevel:RegisterOptionCallback(UpdateColorFunc)
SyLevel:RegisterDisplay("ItemLevelText", TextDisplay)
