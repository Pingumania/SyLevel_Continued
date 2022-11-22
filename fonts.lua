local _, ns = ...
local SyLevel = ns.SyLevel

function SyLevel:SetFontSettings()
	SyLevel:UpdateAllPipes()
end

function SyLevel:GetFontSettings(bind)
	local db
	if not bind then
		db = SyLevelDB.FontSettings
	else
		db = SyLevelDB.FontSettingsBind
	end
	return db.typeface, db.size, db.align, db.reference, db.offsetx, db.offsety, db.flags
end