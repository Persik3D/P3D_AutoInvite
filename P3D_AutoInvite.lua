local aiEnable = false;
function AutoInvite_Command(msg, editbox) 
	aiEnable = not aiEnable
	print("AutoInvite:", aiEnable)
end

SLASH_AUTOINVITE1 = "/autoinvite"
SLASH_AUTOINVITE1 = "/ai"
SlashCmdList["AUTOINVITE"] = AutoInvite_Command

local queueToInvite = {}
local lastInviteTime = 0
local messageForInvite = "+"
local promoteLevel = -1
local index = 1
local autoConvertToRaid = true

function P3D_AddInQueue(name)
	if UnitInParty(name) or UnitInRaid(name) then return false end
	if not UnitIsInMyGuild(name) then return end
	for _,v in pairs(queueToInvite) do
		if v == name then
			return
		end
	end
	table.insert(queueToInvite, name)
end

local function TryInvite(name)
	if UnitInParty(name) or UnitInRaid(name) then return false end
	InviteUnit(name)
	return true
end

function AutoInvite_OnEvent(self,event,...)
	if aiEnable and (UnitIsRaidOfficer("player") or GetNumRaidMembers() == 0) then
		if event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_GUILD" then 
			local msg, name = ...
			if string.match(msg, messageForInvite) then
				P3D_AddInQueue(name)
			end
		end
		if event == "PARTY_MEMBERS_CHANGED" then
			if GetNumRaidMembers() < GetNumPartyMembers() then
				ConvertToRaid()
			end
-- 			if GetNumRaidMembers() > 0 then
-- 				local i, j = 1, 1
-- 				for i = 1, GetNumRaidMembers() do
-- 					name = UnitName("raid"..i)
-- 					for j = 1, GetNumGuildMembers() do
-- 						local gName, _, gRank = GetGuildRosterInfo(j)
-- 						if gName == name and gRank <= promoteLevel then
-- 							if not UnitIsRaidOfficer("raid"..i) then
-- 								PromoteToAssistant("raid"..i)
-- 							end
-- 						end
-- 						j = j + 1
-- 					end
-- 					i = i + 1
-- 				end
-- 			end
		end
	end
end

function AutoInvite_OnUpdate(self,event,...)
	if aiEnable and (UnitIsRaidOfficer("player") or GetNumRaidMembers() == 0) then
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


