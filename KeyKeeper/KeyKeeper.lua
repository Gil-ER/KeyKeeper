local _, ns = ...;	

ns.debug = false;
ns.Version = "010209"

--sets up arrow key navigation in chat edit box
for i = 1, NUM_CHAT_WINDOWS do
	_G["ChatFrame" ..i.. "EditBox"]:SetAltArrowKeyMode(false);
end;

--reload shortcut
SLASH_RELOADUI1 = "/rl"; 
SLASH_RELOADUI2 = "/rload";	
SlashCmdList.RELOADUI = ReloadUI();	

--key data frame
SLASH_KEYKEEPER1 = "/kk"; 
SLASH_KEYKEEPER2 = "/keykeeper";	
SlashCmdList.KEYKEEPER = function(arg)
	arg = arg:lower();
	if arg == "input" then
		ns:ManInput ();
		return;
	end;
	if arg == "reset" then 
		--resets window position
		ns.Output:ClearAllPoints();
		ns.Output:SetPoint("CENTER",UIParent);
	end;
	if (arg == "debug") or (arg == "d") then
		ns.debug = not ns.debug;
		KeyKeeper["settings"]["debug"] = ns.debug;
		if ns.debug then print("Debug mode on"); else print("Debug mode off"); end;
	else 
		ns:ShowKeys();
	end;
end;

local function KK_Tooltip(tt)
	tt:AddLine("             Key Keeper");
	tt:AddLine(" ");
	tt:AddLine("     Left Click - Show Keys.     ");		
	tt:AddLine("     Right Click - Update Data.     ");
	tt:AddLine("     <CTRL> Left Click - Center Window     ");
	tt:AddLine(" ");
	tt:Show();
end;

--Mini map button stuff
local function KeyKeeperMiniMap(button)
	if button == "LeftButton" then
		if IsShiftKeyDown() then
			
		elseif IsControlKeyDown() then
			--resets window position
			ns.Output:ClearAllPoints();
			ns.Output:SetPoint("CENTER",UIParent);
			ns:ShowKeys();
		else
			ns:ShowKeys();
		end;
	elseif button == "RightButton" then
		ns:SendKeys();
	end;
end
local kkLDB = LibStub("LibDataBroker-1.1"):NewDataObject("key!", {
	type = "data source",
	text = "key",
	icon = "Interface\\Icons\\inv_misc_key_05",
	OnClick = function(_, button) KeyKeeperMiniMap(button) end,
})

function kkLDB:OnTooltipShow()
	KK_Tooltip(self)
end
function kkLDB:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT");
	GameTooltip:ClearLines();
	kkLDB:OnTooltipShow(GameTooltip);
end
function kkLDB:OnLeave()
	GameTooltip:Hide();
end
--/ Mini map button stuff

--Global Addon Compartment functions
 AddonCompartmentFrame:RegisterAddon({
	text = "Key Keeper",
	icon = "Interface\\Icons\\inv_misc_key_05",
	notCheckable = true,
	func = function(arg1)
		ns:ShowKeys();
	end,
	funcOnEnter = function()
		GameTooltip:SetOwner(AddonCompartmentFrame, "ANCHOR_NONE");
		GameTooltip:SetPoint("BOTTOMRIGHT", AddonCompartmentFrame, "TOPRIGHT");
		KK_Tooltip(GameTooltip);
	end,
	funcOnLeave = function()
		GameTooltip:Hide();
	end,
 })

--event frame
local frame = CreateFrame("FRAME");
frame:RegisterEvent("CHALLENGE_MODE_MEMBER_INFO_UPDATED");


--Run these once then unregister
frame:RegisterEvent("ZONE_CHANGED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
--Looking form new keys
frame:RegisterEvent("BAG_UPDATE_DELAYED");
--addon messages
frame:RegisterEvent("CHAT_MSG_ADDON");
--For linked keys
frame:RegisterEvent("CHAT_MSG_CHANNEL");
frame:RegisterEvent("CHAT_MSG_GUILD");
frame:RegisterEvent("CHAT_MSG_OFFICER");
frame:RegisterEvent("CHAT_MSG_PARTY");
frame:RegisterEvent("CHAT_MSG_WHISPER");

local refreshFlag = true;

function frame:OnEvent(event, ...)
	if event == "ZONE_CHANGED" then
		--Runs once to initialize data after loading is done
		ns.keyID = C_MythicPlus.GetOwnedKeystoneChallengeMapID();
		if ns.keyID ~= nil then 
			ns.key = C_ChallengeMode.GetMapUIInfo(ns.keyID);
			ns.level = format("%s", C_MythicPlus.GetOwnedKeystoneLevel());
			--update the table and send data out (true flag)
			ns:UpdateKey(ns.player, ns.key, ns.level, date("%Y %m %d %H:%M"), true);			
		end;	
		ns:SendKeys();				--Send out our keys(will be updated here too)
		ns:SendData("refresh");		--Request refresh(needed if someone has a key that we don't have)		
		refreshFlag = false;
		frame:UnregisterEvent("ZONE_CHANGED");
	end;
		
	if event == "PLAYER_ENTERING_WORLD" then 
		local icon = LibStub("LibDBIcon-1.0", true);
		if not KeyKeeperLDBIconDB then KeyKeeperLDBIconDB = {} end;
		icon:Register("KeyKeeper", kkLDB, KeyKeeperLDBIconDB)
		if ns:GetSaveResetTime() < time() then
			--if we have passed the reset time then reset
			ns:ResetDataFile();
		end;
		--ns:GetSaveResetTime() will ensure KeyKeeper["settings"] is valid
		if KeyKeeper["settings"]["debug"] == nil then KeyKeeper["settings"]["debug"] = false; end;
		ns.debug = KeyKeeper["settings"]["debug"];
		if ns.debug then print("KeyKeeper: Debug mode active."); end;
		frame:UnregisterEvent("PLAYER_ENTERING_WORLD");
	end;
	
	if event == "BAG_UPDATE_DELAYED" then
		--check key, if different update local data
		local id = C_MythicPlus.GetOwnedKeystoneChallengeMapID();
		if id ~= nil then
			local lvl = format("%s", C_MythicPlus.GetOwnedKeystoneLevel());			
			if ns:IsKeyDifferent(ns.player,  C_ChallengeMode.GetMapUIInfo(id), lvl) then 
				if ns.debug then print("Old Key ", ns.keyID, ns.level, " - New Key ", id, lvl); end;
				ns.keyID = id;
				ns.key = C_ChallengeMode.GetMapUIInfo(ns.keyID);
				ns.level = lvl;
				--update the table and send data out (true flag)
				if ns.debug then print("Updating Keystone."); end;
				ns:UpdateKey(ns.player, ns.key, ns.level, date("%Y %m %d %H:%M"), true);
				local msg = "New keystone, " .. ns.level .. " - " .. ns.key;
				if (IsInGroup()) and (not IsInRaid()) then
					SendChatMessage(msg ,"PARTY");
				else
					print(msg);
				end;
			end;
		end;
	end; 

	if event == "CHAT_MSG_ADDON" or event == "CHAT_MSG_GUILD" or event == "CHAT_MSG_PARTY" then
		--fires when an addon message is received
		local Addon, Message, Stream, Source,_,_,_, ChannelName  = ...; 
		--watching for KeyKeeper
		if Addon ~= ns.prefix then return;	end;	
		--Ignore messages from yourself
		local n = strsplit("-", Source);
		if n ~= ns.player then
			if Message == "refresh" then
				--another user requested a refresh, send your data
				if ns.debug then print(n, " requested a refresh."); end;
				ns:SendKeys();						
			else
				--another user sent data, just update our data 
				--false flag prevents sending out again
				--parse out variables from message
				local toon, stone, level, dt, ver = strsplit( "#", Message );
				--if string didn't include a version then set it to 010205 anyone with this functionality is higher
				-- if ver == nil or strfind(ver, ".") ~= nil then ver = "010205"; end;
				-- if ns.Version < ver then
					-- ns.Info:SetText("New update available"); 
				-- end;
				if ns.debug then print(n, " sent ", Message); end;
				ns:UpdateKey(toon, stone, level, dt, false);	
			end;
			if refreshFlag then
				ns:SendData("refresh");
				refreshFlag = false;
			end;			
		end;
	end;	
end	
frame:SetScript("OnEvent", frame.OnEvent); 

