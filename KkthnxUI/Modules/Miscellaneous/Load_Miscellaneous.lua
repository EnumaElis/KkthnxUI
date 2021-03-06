local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Miscellaneous")

local _G = _G
local math_ceil = _G.math.ceil
local math_floor = _G.math.floor
local pairs = _G.pairs
local select = _G.select
local string_gsub = _G.string.gsub
local string_match = _G.string.match
local tDeleteItem = _G.tDeleteItem
local tonumber = _G.tonumber

local BID = _G.BID
local BNGetGameAccountInfoByGUID = _G.BNGetGameAccountInfoByGUID
local C_BattleNet_GetGameAccountInfoByGUID = _G.BNGetGameAccountInfoByGUID
local C_FriendList_IsFriend = _G.C_FriendList.IsFriend
local C_Timer_After = _G.C_Timer.After
local CreateFrame = _G.CreateFrame
local FRIEND = _G.FRIEND
local GUILD = _G.GUILD
local GetAuctionItemInfo = _G.GetAuctionItemInfo
local GetAutoCompleteRealms = _G.GetAutoCompleteRealms
local GetCursorInfo = _G.GetCursorInfo
local GetItemInfo = _G.GetItemInfo
local GetItemQualityColor = _G.GetItemQualityColor
local GetMerchantItemLink = _G.GetMerchantItemLink
local GetMerchantItemMaxStack = _G.GetMerchantItemMaxStack
local GetNumAuctionItems = _G.GetNumAuctionItems
local GetScreenHeight = _G.GetScreenHeight
local GetScreenWidth = _G.GetScreenWidth
local GetSpellInfo = _G.GetSpellInfo
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local IsCharacterFriend = _G.IsCharacterFriend
local IsGuildMember = _G.IsGuildMember
local IsMounted = _G.IsMounted
local NO = _G.NO
local PVPReadyDialog = _G.PVPReadyDialog
local PlaySound = _G.PlaySound
local SlashCmdList = _G.SlashCmdList
local StaticPopupDialogs = _G.StaticPopupDialogs
local StaticPopup_Show = _G.StaticPopup_Show
local UIParent = _G.UIParent
local UnitGUID = _G.UnitGUID
local YES = _G.YES
local hooksecurefunc = _G.hooksecurefunc
local time = _G.time

local connectedRealms = GetAutoCompleteRealms() or nil
local RealmFound = false
local total = 0
local shifted = false
local ShiftTime = time()
local NextShiftTime = ShiftTime + 1
local LFGMessage = "Thank you for the group everyone! <3"

local IsMountedMessages = {
	[_G.ERR_ATTACK_MOUNTED] = true,
	[_G.ERR_MOUNT_ALREADYMOUNTED] = true,
	[_G.ERR_NOT_WHILE_MOUNTED] = true,
	[_G.ERR_TAXIPLAYERALREADYMOUNTED] = true,
	[_G.SPELL_FAILED_NOT_MOUNTED] = true,
}

-- Repoint Vehicle
do
	function Module:CreateVehicleSeatMover()
		local vehicleSeatFrame = CreateFrame("Frame", "KkthnxUIVehicleSeatMover", UIParent)
		vehicleSeatFrame:SetSize(120, 120)
		K.Mover(vehicleSeatFrame, "VehicleSeat", "VehicleSeat", {"BOTTOM", UIParent, -364, 4})

		hooksecurefunc(_G.VehicleSeatIndicator, "SetPoint", function(self, _, parent)
			if parent == "MinimapCluster" or parent == _G.MinimapCluster then
				self:ClearAllPoints()
				self:SetPoint("CENTER", vehicleSeatFrame)
				self:SetScale(0.9)
			end
		end)
	end
end

do
	local function CheckMountedErrorMessages(_, _, _, msg)
		if IsMountedMessages[msg] then
			if not IsMounted() then
				return
			end

			_G.Dismount()
			K.Print("has auto dismounted you!")
		end
	end
	K:RegisterEvent("UI_ERROR_MESSAGE", CheckMountedErrorMessages)
end

-- Grids
do
	local grid
	local boxSize = 32
	local function Grid_Create()
		grid = CreateFrame("Frame", nil, UIParent)
		grid.boxSize = boxSize
		grid:SetAllPoints(UIParent)

		local size = 2
		local width = GetScreenWidth()
		local ratio = width / GetScreenHeight()
		local height = GetScreenHeight() * ratio

		local wStep = width / boxSize
		local hStep = height / boxSize

		for i = 0, boxSize do
			local tx = grid:CreateTexture(nil, "BACKGROUND")
			if i == boxSize / 2 then
				tx:SetColorTexture(1, 0, 0, .5)
			else
				tx:SetColorTexture(0, 0, 0, .5)
			end
			tx:SetPoint("TOPLEFT", grid, "TOPLEFT", i * wStep - (size / 2), 0)
			tx:SetPoint("BOTTOMRIGHT", grid, "BOTTOMLEFT", i * wStep + (size / 2), 0)
		end
		height = GetScreenHeight()

		do
			local tx = grid:CreateTexture(nil, "BACKGROUND")
			tx:SetColorTexture(1, 0, 0, .5)
			tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height / 2) + (size / 2))
			tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height / 2 + size / 2))
		end

		for i = 1, math_floor((height/2)/hStep) do
			local tx = grid:CreateTexture(nil, "BACKGROUND")
			tx:SetColorTexture(0, 0, 0, .5)

			tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height / 2 + i * hStep) + (size / 2))
			tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height / 2 + i * hStep + size / 2))

			tx = grid:CreateTexture(nil, "BACKGROUND")
			tx:SetColorTexture(0, 0, 0, .5)

			tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height / 2 - i * hStep) + (size / 2))
			tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height / 2 - i * hStep + size / 2))
		end
	end

	local function Grid_Show()
		if not grid then
			Grid_Create()
		elseif grid.boxSize ~= boxSize then
			grid:Hide()
			Grid_Create()
		else
			grid:Show()
		end
	end

	local isAligning = false
	SlashCmdList["KKUI_TOGGLEGRID"] = function(arg)
		if isAligning or arg == "1" then
			if grid then
				grid:Hide()
			end

			isAligning = false
		else
			boxSize = (math_ceil((tonumber(arg) or boxSize) / 32) * 32)
			if boxSize > 256 then
				boxSize = 256
			end

			Grid_Show()
			isAligning = true
		end
	end

	_G.SLASH_KKUI_TOGGLEGRID1 = "/showgrid"
	_G.SLASH_KKUI_TOGGLEGRID2 = "/align"
	_G.SLASH_KKUI_TOGGLEGRID3 = "/grid"
end

-- TradeFrame hook
function Module:CreateTradeTargetInfo()
	local tradeTargetInfoText = _G.TradeFrame:CreateFontString(nil, "OVERLAY")
	tradeTargetInfoText:SetFont(C["Media"].Font, 14, "")
	tradeTargetInfoText:SetShadowOffset(1.25, -1.25)
	tradeTargetInfoText:SetWordWrap(false)
	tradeTargetInfoText:ClearAllPoints()
	tradeTargetInfoText:SetPoint("TOP", _G.TradeFrameRecipientNameText, "BOTTOM", 0, -8)

	local function updateColor()
		local r, g, b = K.UnitColor("NPC")
		_G.TradeFrameRecipientNameText:SetTextColor(r, g, b)

		local guid = UnitGUID("NPC")
		if not guid then
			return
		end

		local text = "|cffff0000"..L["Stranger"]
		if BNGetGameAccountInfoByGUID(guid) or IsCharacterFriend(guid) then
			text = "|cffffff00"..FRIEND
		elseif IsGuildMember(guid) then
			text = "|cff00ff00"..GUILD
		end
		tradeTargetInfoText:SetText(text)
	end
	hooksecurefunc("TradeFrame_Update", updateColor)
end

-- ALT+RightClick to buy a stack
do
	local cache = {}
	local itemLink, id

	StaticPopupDialogs["BUY_STACK"] = {
		text = "Stack Buying Check",
		button1 = YES,
		button2 = NO,

		OnAccept = function()
			if not itemLink then
				return
			end

			_G.BuyMerchantItem(id, GetMerchantItemMaxStack(id))
			cache[itemLink] = true
			itemLink = nil
		end,

		hideOnEscape = 1,
		hasItemFrame = 1,
	}

	local _MerchantItemButton_OnModifiedClick = _G.MerchantItemButton_OnModifiedClick
	function MerchantItemButton_OnModifiedClick(self, ...)
		if IsAltKeyDown() then
			id = self:GetID()
			itemLink = GetMerchantItemLink(id)
			if not itemLink then return end
			local name, _, quality, _, _, _, _, maxStack, _, texture = GetItemInfo(itemLink)
			if maxStack and maxStack > 1 then
				if not cache[itemLink] then
					local r, g, b = GetItemQualityColor(quality or 1)
					StaticPopup_Show("BUY_STACK", " ", " ", {
						["texture"] = texture,
						["name"] = name,
						["color"] = {r, g, b, 1},
						["link"] = itemLink,
						["index"] = id,
						["count"] = maxStack
					})
				else
					_G.BuyMerchantItem(id, GetMerchantItemMaxStack(id))
				end
			end
		end
		_MerchantItemButton_OnModifiedClick(self, ...)
	end
end

-- Fix Drag Collections taint
do
	local isSetupDone
	local function setupCollectionsTaint(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_Collections" then
			_G.CollectionsJournal:HookScript("OnShow", function()
				if not isSetupDone then
					if InCombatLockdown() then
						K:RegisterEvent("PLAYER_REGEN_ENABLED", setupCollectionsTaint)
					else
						K.CreateMoverFrame(_G.CollectionsJournal)
					end
					isSetupDone = true
				end
			end)
			K:UnregisterEvent(event, setupCollectionsTaint)
		elseif event == "PLAYER_REGEN_ENABLED" then
			K.CreateMoverFrame(_G.CollectionsJournal)
			K:UnregisterEvent(event, setupCollectionsTaint)
		end
	end
	K:RegisterEvent("ADDON_LOADED", setupCollectionsTaint)
end

-- Select target when click on raid units
do
	local function fixRaidGroupButton()
		for i = 1, 40 do
			local bu = _G["RaidGroupButton"..i]
			if bu and bu.unit and not bu.clickFixed then
				bu:SetAttribute("type", "target")
				bu:SetAttribute("unit", bu.unit)

				bu.clickFixed = true
			end
		end
	end

	local function setupFixRaidGroup(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_RaidUI" then
			if not InCombatLockdown() then
				fixRaidGroupButton()
			else
				K:RegisterEvent("PLAYER_REGEN_ENABLED", setupFixRaidGroup)
			end
			K:UnregisterEvent(event, setupFixRaidGroup)
		elseif event == "PLAYER_REGEN_ENABLED" then
			if _G.RaidGroupButton1 and _G.RaidGroupButton1:GetAttribute("type") ~= "target" then
				fixRaidGroupButton()
				K:UnregisterEvent(event, setupFixRaidGroup)
			end
		end
	end
	K:RegisterEvent("ADDON_LOADED", setupFixRaidGroup)
end

do
	hooksecurefunc("ChatEdit_InsertLink", function(text) -- shift-clicked
		if text and _G.TradeSkillFrame and _G.TradeSkillFrame:IsShown() then -- change from SearchBox:HasFocus to :IsShown again
			local spellId = string_match(text, "enchant:(%d+)")
			local spell = GetSpellInfo(spellId)
			local item = GetItemInfo(string_match(text, "item:(%d+)") or 0)
			local search = spell or item
			if not search then
				return
			end

			-- search needs to be lowercase for .SetRecipeItemNameFilter
			_G.TradeSkillFrame.SearchBox:SetText(search)

			-- jump to the recipe
			if spell then -- can only select recipes on the learned tab
				if _G.PanelTemplates_GetSelectedTab(_G.TradeSkillFrame.RecipeList) == 1 then
					_G.TradeSkillFrame:SelectRecipe(tonumber(spellId))
				end
			elseif item then
				C_Timer_After(.1, function() -- wait a bit or we cant select the recipe yet
					for _, v in pairs(_G.TradeSkillFrame.RecipeList.dataList) do
						if v.name == item then
							-- TradeSkillFrame.RecipeList:RefreshDisplay() -- didnt seem to help
							_G.TradeSkillFrame:SelectRecipe(v.recipeID)
							return
						end
					end
				end)
			end
		end
	end)

	-- make it only split stacks with shift-rightclick if the TradeSkillFrame is open
	-- shift-leftclick should be reserved for the search box
	local function hideSplitFrame(_, button)
		if _G.TradeSkillFrame and _G.TradeSkillFrame:IsShown() then
			if button == "LeftButton" then
				_G.StackSplitFrame:Hide()
			end
		end
	end
	hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", hideSplitFrame)
	hooksecurefunc("MerchantItemButton_OnModifiedClick", hideSplitFrame)
end

-- Fix blizz guild news hyperlink error
do
	local function fixGuildNews(event, addon)
		if addon ~= "Blizzard_GuildUI" then
			return
		end

		local _GuildNewsButton_OnEnter = _G.GuildNewsButton_OnEnter
		function _G.GuildNewsButton_OnEnter(self)
			if not (self.newsInfo and self.newsInfo.whatText) then
				return
			end

			_GuildNewsButton_OnEnter(self)
		end

		K:UnregisterEvent(event, fixGuildNews)
	end

	local function fixCommunitiesNews(event, addon)
		if addon ~= "Blizzard_Communities" then
			return
		end

		local _CommunitiesGuildNewsButton_OnEnter = _G.CommunitiesGuildNewsButton_OnEnter
		function _G.CommunitiesGuildNewsButton_OnEnter(self)
			if not (self.newsInfo and self.newsInfo.whatText) then
				return
			end

			_CommunitiesGuildNewsButton_OnEnter(self)
		end
		K:UnregisterEvent(event, fixCommunitiesNews)
	end
	K:RegisterEvent("ADDON_LOADED", fixGuildNews)
	K:RegisterEvent("ADDON_LOADED", fixCommunitiesNews)
end

-- Show BID and highlight price
do
	local function setupBidHighlightPrice(event, addon)
		if addon == "Blizzard_AuctionUI" then
			hooksecurefunc("AuctionFrameBrowse_Update", function()
				local numBatchAuctions = GetNumAuctionItems("list")
				local offset = _G.FauxScrollFrame_GetOffset(_G.BrowseScrollFrame)
				local name, buyoutPrice, bidAmount, hasAllInfo, _
				for i = 1, _G.NUM_BROWSE_TO_DISPLAY do
					local index = offset + i + (_G.NUM_AUCTION_ITEMS_PER_PAGE * _G.AuctionFrameBrowse.page)
					local shouldHide = index > (numBatchAuctions + (_G.NUM_AUCTION_ITEMS_PER_PAGE * _G.AuctionFrameBrowse.page))
					if not shouldHide then
						name, _, _, _, _, _, _, _, _, buyoutPrice, bidAmount, _, _, _, _, _, _, hasAllInfo = GetAuctionItemInfo("list", offset + i)
						if not hasAllInfo then
							shouldHide = true
						end
					end

					if not shouldHide then
						local alpha = 0.5
						local color = "yellow"
						local buttonName = "BrowseButton"..i
						local itemName = _G[buttonName.."Name"]
						local moneyFrame = _G[buttonName.."MoneyFrame"]
						local buyoutMoney = _G[buttonName.."BuyoutFrameMoney"]

						if buyoutPrice >= 5 * 1e7 then
							color = "red"
						end

						if bidAmount > 0 then
							name = name.." |cffffff00"..BID.."|r"
							alpha = 1.0
						end

						itemName:SetText(name)
						moneyFrame:SetAlpha(alpha)
						_G.SetMoneyFrameColor(buyoutMoney:GetName(), color)
					end
				end
			end)
			K:UnregisterEvent(event, setupBidHighlightPrice)
		end
	end
	K:RegisterEvent("ADDON_LOADED", setupBidHighlightPrice)
end

do
	-- Instant delete
	local function deleteItemConfirm()
		if _G.StaticPopup1EditBox:IsShown() then
			_G.StaticPopup1EditBox:Hide()
			_G.StaticPopup1Button1:Enable()

			local isLink = select(3, GetCursorInfo())

			Module.isLink:SetText(isLink)
			Module.isLink:Show()
		end
	end

	local function isKkthnxUILoaded(_, addon)
		if addon ~= "KkthnxUI" then
			return
		end

		-- create item link container
		Module.isLink = _G.StaticPopup1:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		Module.isLink:SetPoint("CENTER", _G.StaticPopup1EditBox)
		Module.isLink:Hide()

		_G.StaticPopup1:HookScript("OnHide", function()
			Module.isLink:Hide()
		end)
	end

	K:RegisterEvent("ADDON_LOADED", isKkthnxUILoaded)
	K:RegisterEvent("DELETE_ITEM_CONFIRM", deleteItemConfirm)
end

do
	local function soundOnResurrect()
		if C["Unitframe"].ResurrectSound then
			PlaySound("72978", "Master")
		end
	end

	K:RegisterEvent("RESURRECT_REQUEST", soundOnResurrect)
end

function Module:CreateBlockStrangerInvites()
	K:RegisterEvent("PARTY_INVITE_REQUEST", function(_, _, _, _, _, _, _, guid)
		if C["Automation"].AutoBlockStrangerInvites and not (C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) or IsGuildMember(guid)) then
			_G.DeclineGroup()
			_G.StaticPopup_Hide("PARTY_INVITE")
			K.Print("Blocked a 'Party Invite' from player "..guid)
		end
	end)
end

-- Override default settings for AngryWorldQuests
function Module:CreateOverrideAWQ()
	if not _G.IsAddOnLoaded("AngryWorldQuests") then
		return
	end

	_G.AngryWorldQuests_Config = _G.AngryWorldQuests_Config or {}
	_G.AngryWorldQuests_CharacterConfig = _G.AngryWorldQuests_CharacterConfig or {}

	local settings = {
		hideFilteredPOI = true,
		showContinentPOI = true,
		sortMethod = 2,
	}

	local function overrideOptions(_, key)
		local value = settings[key]
		if value then
			_G.AngryWorldQuests_Config[key] = value
			_G.AngryWorldQuests_CharacterConfig[key] = value
		end
	end
	hooksecurefunc(_G.AngryWorldQuests.Modules.Config, "Set", overrideOptions)
end

do
	local function PhaseAlertCheckRealm()
		RealmFound = false
		connectedRealms = GetAutoCompleteRealms()
		if connectedRealms then
			tDeleteItem(connectedRealms, string_gsub(K.Realm, "[%s%-]", ""))
			if #connectedRealms > 0 then
				RealmFound = true
			end
		end

		if RealmFound == false then
			K.Print(K.SystemColor..">> Phasing!")
		end
	end

	local function PhaseAlertOnUpdate(_, elapsed)
		total = total + elapsed
		if total >= 0.1 then
			if C["Chat"].PhasingAlert then
				if not _G.GarrisonLandingPageMinimapButton:IsShown() then
					ShiftTime = time()
					NextShiftTime = ShiftTime + 1
					if shifted == false then
						PhaseAlertCheckRealm()
						shifted = true
					end
				end

				if shifted == true then
					if time() >= NextShiftTime then
						shifted = false
					end
				end

				total = 0
			end
		end
	end
	local PhasingAlertFrame = CreateFrame("frame")
	PhasingAlertFrame:SetScript("OnUpdate", PhaseAlertOnUpdate)
end

do
	local function CreateAutoDungeonThanks()
		if not C["Automation"].AutoDungeonThanks then
			return
		end

		local isLFG = _G.IsPartyLFG()

		_G.C_Timer.After(1.5, function() -- Give this more time to say thanks.
			if isLFG then
				_G.SendChatMessage(LFGMessage, "INSTANCE_CHAT")
			end
		end)
	end
	K:RegisterEvent("LFG_COMPLETION_REWARD", CreateAutoDungeonThanks)
end

function Module:OnEnable()
	self:CreateBlockStrangerInvites()
	self:CreateChatBubbles()
	self:CreateDurabilityFrame()
	self:CreateImprovedMail()
	self:CreateImprovedStats()
	self:CreateKillingBlow()
	self:CreateMerchantItemLevel()
	self:CreateNoTalkingHead()
	self:CreateOverrideAWQ()
	self:CreatePulseCooldown()
	self:CreatePvPEmote()
	self:CreateQuestNotifier()
	self:CreateQueueTimer()
	self:CreateRaidMarker()
	self:CreateSlotDurability()
	self:CreateSlotItemLevel()
	self:CreateAFKCam()
	self:CreateTradeTabs()
	self:CreateTradeTargetInfo()
	self:CreateVehicleSeatMover()

	do
		StaticPopupDialogs.ADDON_ACTION_FORBIDDEN.button1 = nil
		StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = nil
		StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = nil
		StaticPopupDialogs.PARTY_INVITE.hideOnEscape = nil
		StaticPopupDialogs.RESURRECT.hideOnEscape = nil
		StaticPopupDialogs.TOO_MANY_LUA_ERRORS.button1 = nil

		_G.PetBattleQueueReadyFrame.hideOnEscape = nil

		if (PVPReadyDialog) then
			PVPReadyDialog.leaveButton:Hide()
			PVPReadyDialog.enterButton:ClearAllPoints()
			PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)
		end
	end
end