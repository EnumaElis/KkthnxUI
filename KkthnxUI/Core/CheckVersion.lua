local K, C = unpack(select(2, ...))
local Module = K:NewModule("VersionCheck")

local _G = _G
local string_format = _G.string.format
local string_gsub = _G.string.gsub
local string_split = _G.string.split

local Ambiguate = _G.Ambiguate
local C_ChatInfo_RegisterAddonMessagePrefix = _G.C_ChatInfo.RegisterAddonMessagePrefix
local C_ChatInfo_SendAddonMessage = _G.C_ChatInfo.SendAddonMessage
local GetTime = _G.GetTime
local IsInGroup = _G.IsInGroup
local IsInGuild = _G.IsInGuild

local isVCInit
local lastVCTime = 0

function Module:VersionCheck_Compare(new, old)
	local new1, new2 = string_split(".", new)
	new1, new2 = tonumber(new1), tonumber(new2)

	local old1, old2 = string_split(".", old)
	old1, old2 = tonumber(old1), tonumber(old2)

	if new1 > old1 or (new1 == old1 and new2 > old2) then
		return "IsNew"
	elseif new1 < old1 or (new1 == old1 and new2 < old2) then
		return "IsOld"
	end
end

function Module:VersionCheck_Create(text)
	local frame = CreateFrame("Frame", nil, nil, "MicroButtonAlertTemplate")
	frame:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 20, 70)
	frame.Text:SetText(text)

	frame:CreateBorder(nil, nil, nil, true)

	frame.CloseButton:ClearAllPoints()
	frame.CloseButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 2, 2)
	frame.CloseButton:SkinCloseButton()

	frame.Arrow:ClearAllPoints()
	frame.Arrow:SetPoint("TOP", frame, "BOTTOM", 0, -2)

	frame:Show()
end

function Module:VersionCheck_Init()
	if not isVCInit then
		local status = Module:VersionCheck_Compare(KkthnxUIData[K.Realm][K.Name].DetectVersion, K.Version)
		if status == "IsNew" then
			local release = string_gsub(KkthnxUIData[K.Realm][K.Name].DetectVersion, "(%d+)$", "0")
			Module:VersionCheck_Create(string_format("|cff669dffKkthnxUI|r is out of date, the latest release is |cff70C0F5%s|r", release))
		elseif status == "IsOld" then
			KkthnxUIData[K.Realm][K.Name].DetectVersion = K.Version
		end

		isVCInit = true
	end
end

function Module:VersionCheck_Send(channel)
	if GetTime() - lastVCTime >= 10 then
		C_ChatInfo_SendAddonMessage("KKUIVersionCheck", KkthnxUIData[K.Realm][K.Name].DetectVersion, channel)
		lastVCTime = GetTime()
	end
end

function Module:VersionCheck_Update(...)
	local prefix, msg, distType, author = ...
	if prefix ~= "KKUIVersionCheck" then
		return
	end

	if Ambiguate(author, "none") == K.Name then
		return
	end

	local status = Module:VersionCheck_Compare(msg, KkthnxUIData[K.Realm][K.Name].DetectVersion)
	if status == "IsNew" then
		KkthnxUIData[K.Realm][K.Name].DetectVersion = msg
	elseif status == "IsOld" then
		Module:VersionCheck_Send(distType)
	end

	Module:VersionCheck_Init()
end

function Module:VersionCheck_UpdateGroup()
	if not IsInGroup() then
		return
	end

	Module:VersionCheck_Send(K.CheckChat())
end

function Module:OnEnable()
	Module:VersionCheck_Init()
	C_ChatInfo_RegisterAddonMessagePrefix("KKUIVersionCheck")
	K:RegisterEvent("CHAT_MSG_ADDON", Module.VersionCheck_Update)

	if IsInGuild() then
		C_ChatInfo_SendAddonMessage("KKUIVersionCheck", K.Version, "GUILD")
		lastVCTime = GetTime()
	end

	Module:VersionCheck_UpdateGroup()
	K:RegisterEvent("GROUP_ROSTER_UPDATE", Module.VersionCheck_UpdateGroup)
end