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
	if arg == "debug" then
		ns.debug = not ns.debug;
		if ns.debug then print("Debug mode on"); else print("Debug mode off"); end;
	else 
		ns:ShowKeys();
	end;
end;

--Mini map button stuff
local function KeyKeeperMiniMap(button)
	if button == "LeftButton" then
		ns:ShowKeys();
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
local icon = LibStub("LibDBIcon-1.0");
icon:Register("key!", kkLDB, false)

function kkLDB:OnTooltipShow()
	self:AddLine("             Key Keeper");
	self:AddLine(" ");
	self:AddLine("     Left Click - Show Keys.     ");	
	self:AddLine("     Middle Click - Kaandew...     ");
	self:AddLine("     Right Click - Update Data.     ");
end
function kkLDB:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT");
	GameTooltip:ClearLines();
	kkLDB.OnTooltipShow(GameTooltip);
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
	
	if event == "BAG_UPDATE"then
		--check key, if different update local data
		local id = C_MythicPlus.GetOwnedKeystoneChallengeMapID();
		if id ~= nil and ns.keyID ~= id then 
			ns.keyID = id;
			ns.key = C_ChallengeMode.GetMapUIInfo(ns.keyID);
			ns.level = format("%s", C_MythicPlus.GetOwnedKeystoneLevel());	
			--update the table and send data out (true flag)
			ns:UpdateKey(ns.player, ns.key, ns.level, date("%Y %m %d %H:%M"), true);			
		end;
	end;
	
	if event == "PLAYER_ENTERING_WORLD" then 
		if GetRealmName() == "Earthen Ring" then
			if ns:GetSaveResetTime() < time() then
				--if we have passed the reset time then reset
				ns:ResetDataFile();
			end;
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
		--fires when an addon message is recieved
		local Addon, Message, Stream, Source,_,_,_, ChannelName  = ...; 
		--watching for KeyKeeper
		if Addon ~= ns.prefix then return;	end;	
		--Ingore messages from ourself
		local n = strsplit("-", Source);
		if n ~= ns.player then
			if Message == "refresh" then
				--another user requested a refresh, send your data
				if ns.debug then print("Requested a refresh."); end;
				ns:SendKeys();						
			else
				--another user sent data, just update our data 
				--false flag prevents sending out again
				--parse out variables from message
				local toon, stone, level, dt, ver = strsplit( "#", Message );
				if ver ~= nil then
					if ns.debug then print(n, " is using version ", ver); end;
				else
					if ns.debug then print(n, " is using an old version."); end;
				end;
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

