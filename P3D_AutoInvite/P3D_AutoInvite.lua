local UnitInParty, UnitInRaid, UnitIsRaidOfficer,GetNumRaidMembers, UnitIsInMyGuild  = UnitInParty, UnitInRaid, UnitIsRaidOfficer,GetNumRaidMembers, UnitIsInMyGuild
local GetTime = GetTime
local aiEnable = false;
local queueToInvite = {}
local lastInviteTime = 0
local messageForInvite = "+"
local promoteLevel = 3
local index = 1
local autoConvertToRaid = true
local smatch = string.match
local tinsert = table.insert

local function AutoInvite_Command(msg, editbox)
	aiEnable = not aiEnable
	print("AutoInvite:", aiEnable)
end

local function P3D_AddInQueue(name)
	if UnitInParty(name) or UnitInRaid(name) then return end
	if not UnitIsInMyGuild(name) then return end
	for _,v in pairs(queueToInvite) do
		if v == name then
			return
		end
	end
	tinsert(queueToInvite, name)
end

local function TryInvite(name)
	if UnitInParty(name) or UnitInRaid(name) then
		return false
	end
	InviteUnit(name)
	return true
end

local function AutoInvite_OnEvent(self,event,...)
	if aiEnable and (UnitIsRaidOfficer("player") or GetNumRaidMembers() == 0) then
		if event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_GUILD" then
			local msg, name = ...
			if smatch(msg, messageForInvite) then
				P3D_AddInQueue(name)
			end
		end
		if event == "PARTY_MEMBERS_CHANGED" then
			if GetNumRaidMembers() < GetNumPartyMembers() then
				ConvertToRaid()
			end
		end
	end
end

function AutoInvite_OnUpdate(self,event,...)
	if aiEnable and not InCombatLockdown() and (UnitIsRaidOfficer("player") or GetNumRaidMembers() == 0) then
		if lastInviteTime + 3 < GetTime() then
			if index <= #queueToInvite then
				if TryInvite(queueToInvite[index]) then
					lastInviteTime = GetTime()
				end
				index = index + 1
			else
				queueToInvite = {}
				index = 1
			end
		end
	end
end

AutoInvite_Frame = CreateFrame("Frame")
AutoInvite_Frame:SetScript("OnUpdate", AutoInvite_OnUpdate)
AutoInvite_Frame:SetScript("OnEvent", AutoInvite_OnEvent)
AutoInvite_Frame:RegisterEvent("CHAT_MSG_WHISPER");
AutoInvite_Frame:RegisterEvent("CHAT_MSG_GUILD");
AutoInvite_Frame:RegisterEvent("PARTY_MEMBERS_CHANGED");

SLASH_AUTOINVITE2 = "/autoinvite"
SLASH_AUTOINVITE1 = "/ai"
SlashCmdList["AUTOINVITE"] = AutoInvite_Command