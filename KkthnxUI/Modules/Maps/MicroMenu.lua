local K, C, L, _ = select(2, ...):unpack()
if C.Minimap.Enable ~= true then return end

local match = string.match
local CreateFrame, UIParent = CreateFrame, UIParent
local ToggleFrame = ToggleFrame
local ToggleDropDownMenu = ToggleDropDownMenu

local MicroMenu = CreateFrame("Frame", "MicroButtonsDropDown", UIParent, "UIDropDownMenuTemplate")

MicroMenu.Buttons = {
	{text = CHARACTER_BUTTON,
		func = function()
			ToggleCharacter("PaperDollFrame")
		end,
	notCheckable = true},

	{text = SPELLBOOK_ABILITIES_BUTTON,
		func = function()
			if not SpellBookFrame:IsShown() then ShowUIPanel(SpellBookFrame) else HideUIPanel(SpellBookFrame) end
		end,
	notCheckable = true},

	{text = TALENTS_BUTTON,
		func = function()
			if not PlayerTalentFrame then
				TalentFrame_LoadUI()
			end

			if not PlayerTalentFrame:IsShown() then
				ShowUIPanel(PlayerTalentFrame)
			else
			HideUIPanel(PlayerTalentFrame) end
		end,
	notCheckable = true},

	{text = ACHIEVEMENT_BUTTON,
		func = function()
			ToggleAchievementFrame()
		end,
	notCheckable = true},

	{text = WORLD_MAP.." / "..QUESTLOG_BUTTON,
		func = function()
			ShowUIPanel(WorldMapFrame)
		end,
	notCheckable = true},

	{text = MOUNTS,
		func = function()
			ToggleCollectionsJournal(1)
		end,
	notCheckable = true},

	{text = PETS,
		func = function()
			ToggleCollectionsJournal(2)
		end,
	notCheckable = true},

	{text = TOY_BOX,
		func = function() ToggleCollectionsJournal(3) end,
	notCheckable = true},

	{text = HEIRLOOMS,
		func = function()
			ToggleCollectionsJournal(4)
		end,
	notCheckable = true},

	{text = SOCIAL_BUTTON,
		func = function()
			ToggleFriendsFrame(1)
		end,
	notCheckable = true},

	{text = COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVE.." / "..COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVP,
		func = function()
			PVEFrame_ToggleFrame()
		end,
	notCheckable = true},

	{text = ACHIEVEMENTS_GUILD_TAB,
		func = function()
			if IsInGuild() then
				if (not GuildFrame) then
					GuildFrame_LoadUI()
				end

				GuildFrame_Toggle()
			else
				if (not LookingForGuildFrame) then
					LookingForGuildFrame_LoadUI()
				end

				LookingForGuildFrame_Toggle()
			end
		end,
	notCheckable = true},

	{text = RAID,
		func = function()
			ToggleFriendsFrame(4)
		end,
	notCheckable = true},

	{text = HELP_BUTTON,
		func = function()
			ToggleHelpFrame()
		end,
	notCheckable = true},

	{text = CALENDAR_VIEW_EVENT,
		func = function()
			if (not CalendarFrame) then
				LoadAddOn("Blizzard_Calendar")
			end

			Calendar_Toggle()
		end,
	notCheckable = true},

	{text = ENCOUNTER_JOURNAL,
		func = function()
			ToggleEncounterJournal()
		end,
	notCheckable = true},

	{text = GARRISON_LANDING_PAGE_TITLE,
		func = function()
			GarrisonLandingPageMinimapButton_OnClick()
		end,
	notCheckable = true},

	{text = SOCIAL_TWITTER_COMPOSE_NEW_TWEET,
		func = function()
			if not SocialPostFrame then
				LoadAddOn("Blizzard_SocialUI")
			end

			local IsTwitterEnabled = C_Social.IsSocialEnabled()

			if IsTwitterEnabled then
				Social_SetShown(true)
			else
				K.Print(SOCIAL_TWITTER_TWEET_NOT_LINKED)
			end
		end,
	notCheckable = true},

	{text = MAINMENU_BUTTON,
		func = function()
			if (not GameMenuFrame:IsShown()) then
				if (VideoOptionsFrame:IsShown()) then
					VideoOptionsFrameCancel:Click()
				elseif (AudioOptionsFrame:IsShown()) then
					AudioOptionsFrameCancel:Click()
				elseif (InterfaceOptionsFrame:IsShown()) then
					InterfaceOptionsFrameCancel:Click()
				end
				CloseMenus()
				CloseAllWindows()
				PlaySound("igMainMenuOpen")
				ShowUIPanel(GameMenuFrame)
			else
				PlaySound("igMainMenuQuit")
				HideUIPanel(GameMenuFrame)
				MainMenuMicroButton_SetNormal()
			end
		end,
	notCheckable = true},
}

--if(C_StorePublic.IsEnabled()) then
tinsert(MicroMenu.Buttons, {text = BLIZZARD_STORE, func = function() StoreMicroButton:Click() end, notCheckable = true})
--end

Minimap:SetScript("OnMouseUp", function(self, button)
	local position = MinimapAnchor:GetPoint()
	if button == "RightButton" then
		if position:match("LEFT") then
			EasyMenu(MicroMenu.Buttons, MicroMenu, "cursor", 0, 0, "MENU")
		else
			EasyMenu(MicroMenu.Buttons, MicroMenu, "cursor", K.Scale(-160), 0, "MENU", 2)
		end
	elseif button == "MiddleButton" then
		if position:match("LEFT") then
			ToggleDropDownMenu(nil, nil, MiniMapTrackingDropDown, "cursor", 0, 0, "MENU", 2)
		else
			ToggleDropDownMenu(nil, nil, MiniMapTrackingDropDown, "cursor", -160, 0, "MENU", 2)
		end
	elseif button == "LeftButton" then
		Minimap_OnClick(self)
	end
end)