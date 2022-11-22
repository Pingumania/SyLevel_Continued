local function binds(...)
	if not select(1, ...) then return end
	local _, _, bind = SyLevel:GetItemLevel(...)

	if bind == 2 then
		return "BoE"
	else
		return ""
	end
end

SyLevel:RegisterFilter("Bind text", "BindsOnText", binds, [[Adds bind on text that the items have.]])