std = "lua51"
max_line_length = 150
ignore = {
    "11./SLASH_.*", -- Setting an undefined (Slash handler) global variable
    "11./BINDING_.*", -- Setting an undefined (Keybinding header) global variable
    "113/LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
    "113/NUM_LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
    "211/L", -- Unused local variable "L"
    "212", -- Unused argument.
    "411", -- Redefining a local variable.
    "421", -- Shadowing a local variable.
    "412", -- Redefining a local variable.
    "43.", -- Shadowing an upvalue, an upvalue argument, an upvalue loop variable.
    "542", -- An empty if branch
}
globals = {
    "abs",
    "ATTACHMENTS_MAX_RECEIVE",
    "ATTACHMENTS_MAX_SEND",
    "BackdropTemplateMixin",
    "Bagnon",
    "BankFrame",
    "BUYBACK_ITEMS_PER_PAGE",
    "C_Item",
    "C_ScrappingMachineUI",
    "C_TradeSkillUI",
    "CharacterFrame",
    "CharacterNeckSlot",
    "ContainerFrame1",
    "CreateFrame",
    "debugstack",
    "EncounterJournal",
    "EQUIPMENTFLYOUT_FIRST_SPECIAL_LOCATION",
    "EquipmentFlyoutFrame",
    "EquipmentManager_UnpackLocation",
    "floor",
    "GameFontHighlight",
    "GameTooltip_Hide",
    "GameTooltip_SetDefaultAnchor",
    "GameTooltip",
    "GarrisonMissionFrame",
    "GetAddOnInfo",
    "GetAddOnMetadata",
    "GetAverageItemLevel",
    "GetBuybackItemLink",
    "GetContainerItemLink",
    "GetContainerNumSlots",
    "GetCurrentGuildBankTab",
    "GetDetailedItemLevelInfo",
    "geterrorhandler",
    "GetGuildBankItemLink",
    "GetInboxItemLink",
    "GetInboxNumItems",
    "GetInventoryItemLink",
    "GetInventoryItemTexture",
    "GetItemInfo",
    "GetItemInfoFromHyperlink",
    "GetItemInfoInstant",
    "GetLocale",
    "GetLootSlotLink",
    "GetMerchantItemLink",
    "GetNumBuybackItems",
    "GetNumQuestChoices",
    "GetNumQuestLogChoices",
    "GetNumQuestLogRewards",
    "GetNumQuestRewards",
    "GetQuestItemLink",
    "GetQuestLogItemLink",
    "GetSendMailItemLink",
    "GetTradePlayerItemLink",
    "GetTradeTargetItemLink",
    "GetVoidItemInfo",
    "GetVoidTransferDepositInfo",
    "GetVoidTransferWithdrawalInfo",
    "hooksecurefunc",
    "InboxFrame",
    "INBOXITEMS_TO_DISPLAY",
    "InspectFrame",
    "InterfaceOptions_AddCategory",
    "InterfaceOptionsFrame_OpenToCategory",
    "InterfaceOptionsFramePanelContainer",
    "IsAddOnLoaded",
    "ITEM_QUALITY_COLORS",
    "Item",
    "ItemLocation",
    "LE_ITEM_ARMOR_IDOL",
    "LE_ITEM_ARMOR_RELIC",
    "LE_ITEM_CLASS_ARMOR",
    "LE_ITEM_CLASS_WEAPON",
    "LE_ITEM_QUALITY_ARTIFACT",
    "LibStub",
    "LOOTFRAME_NUMBUTTONS",
    "LootFrame",
    "LootFrameDownButton",
    "LootFrameUpButton",
    "MAX_GUILDBANK_SLOTS_PER_TAB",
    "MAX_NUM_ITEMS",
    "MAX_TRADE_ITEMS",
    "MERCHANT_ITEMS_PER_PAGE",
    "MerchantBuyBackItemItemButton",
    "MerchantFrame",
    "NUM_BANKGENERIC_SLOTS",
    "OpenColorPicker",
    "QuestInfo_GetRewardButton",
    "QuestInfo_ShowRewards",
    "QuestInfoFrame",
    "QuestInfoRewardsFrame",
    "RAID_CLASS_COLORS",
    "ScrappingMachineFrame",
    "SendMailFrame",
    "SLASH_SyLevel_UI1",
    "SlashCmdList",
    "strjoin",
    "strmatch",
    "strsplit",
    "SyLevel",
    "SyLevelDB",
    "table",
    "TradeSkillFrame",
    "UIDropDownMenu_AddButton",
    "UIDropDownMenu_CreateInfo",
    "UIDropDownMenu_Initialize",
    "UIDropDownMenu_Refresh",
    "UIDropDownMenu_SetSelectedID",
    "UIDropDownMenu_SetWidth",
    "UnitClass",
    "VOID_DEPOSIT_MAX",
    "VOID_WITHDRAW_MAX",
    "VoidStorageFrame",
}