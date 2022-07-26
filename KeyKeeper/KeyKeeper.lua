local _, ns = ...;	

ns.debug = false;

--sets up arrow key navigation in chat edit box
for i = 1, NUM_CHAT_WINDOWS do
	_G["ChatFrame" ..i.. "EditBox"]:SetAltArrowKeyMode(false);
end;

--reload shortcut
if SLASH_RELOADUI1 == nil then	
	SLASH_RELOADUI1 = "/rl"; 
	SLASH_RELOADUI2 = "/rload";	
	SlashCmdList.RELOADUI = ReloadUI();	
end;

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


--Mini map button stuff
local function KeyKeeperMiniMap(button)
	if button == "LeftButton" then
		if IsShiftKeyDown() then
			-- ns:ManInput();
		elseif IsControlKeyDown() then
			--resets window position
			ns.Output:ClearAllPoints();
			ns.Output:SetPoint("CENTER",UIParent);
		else
			ns:ShowKeys();
		end;
	elseif button == "MiddleButton" then
		SendChatMessage("KAANDEW..." ,"Yell");
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
	self:AddLine("             Key Keeper");
	self:AddLine(" ");
	self:AddLine("     Left Click - Show Keys.     ");	
	self:AddLine("     <CTRL> Left Click - Center Window     ");	
	self:AddLine("     ");	
	self:AddLine("     Middle Click - Kaandew...     ");
	self:AddLine("     Right Click - Update Data.     ");
	self:AddLine(" ");
end
function kkLDB:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT");
	GameTooltip:ClearLines();
	kkLDB:OnTooltipShow(GameTooltip);
	GameTooltip:Show();
end
function kkLDB:OnLeave()
	GameTooltip:Hide();
end
--/ Mini map button stuff

--event frame
local frame = CreateFrame("FRAME");
frame:RegisterEvent("ZONE_CHANGED");
frame:RegisterEvent("BAG_UPDATE");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("CHAT_MSG_ADDON");

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
		ns:SendKeys();
		ns:SendData("refresh");
		refreshFlag = false;
		frame:UnregisterEvent("ZONE_CHANGED");
	end;
	
	if event == "BAG_UPDATE" then
		--check key, if different update local data
		local id = C_MythicPlus.GetOwnedKeystoneChallengeMapID();
		if id ~= nil then
			local lvl = format("%s", C_MythicPlus.GetOwnedKeystoneLevel());
			if ns.debug and IsInInstance() then print("BAG_UPDATE: lvl = ",lvl, " id = ", id ); end;
			if ((ns.keyID ~= id) or (ns.level ~= lvl)) then 
				if ns.debug then print("Old Key ", ns.keyID, ns.level, " - New Key ", id, lvl); end;
				ns.keyID = id;
				ns.key = C_ChallengeMode.GetMapUIInfo(ns.keyID);
				ns.level = lvl;
				--update the table and send data out (true flag)
				if ns.debug then print("Updating Keystone."); end;
				ns:UpdateKey(ns.player, ns.key, ns.level, date("%Y %m %d %H:%M"), true);
			end;
		end;
	end;
	
	if event == "PLAYER_ENTERING_WORLD" then 
		local icon = LibStub("LibDBIcon-1.0", true);
		if not KeyKeeperLDBIconDB then KeyKeeperLDBIconDB = {} end;
		icon:Register("KeyKeeper", kkLDB, KeyKeeperLDBIconDB)
		if GetRealmName() == "Earthen Ring" then
			if ns:GetSaveResetTime() < time() then
				--if we have passed the reset time then reset
				ns:ResetDataFile();
			end;
			--ns:GetSaveResetTime() will ensure KeyKeeper["settings"] is valid
			if KeyKeeper["settings"]["debug"] == nil then KeyKeeper["settings"]["debug"] = false; end;
			ns.debug = KeyKeeper["settings"]["debug"];
			if ns.debug then print("KeyKeeper: Debug mode active."); end;
			--only allow this to run the first time then stop monitoring
			frame:UnregisterEvent("PLAYER_ENTERING_WORLD");
		else
			--Don't monitor events if your not on Earthen Ring
			frame:UnregisterEvent("ZONE_CHANGED");
			frame:UnregisterEvent("BAG_UPDATE");
			frame:UnregisterEvent("PLAYER_ENTERING_WORLD");
			frame:UnregisterEvent("CHAT_MSG_ADDON");
		end;
	end; 
	
	if event == "CHAT_MSG_ADDON" then
		--fires when an addon message is received
		local Addon, Message, Stream, Source,_,_,_, ChannelName  = ...; 
		--watching for KeyKeeper
		if Addon ~= ns.prefix then return;	end;	
		--Ignore messages from ourself
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

