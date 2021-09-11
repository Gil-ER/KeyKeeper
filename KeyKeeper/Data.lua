local _, ns = ...;

ns.player = GetUnitName("player");				--toon name
ns.prefix = "KeyKeeper";						--for addon communication
ns.channel = "TurtleOverlords";					--communication channel
ns.keyID = 0;
ns.key = "";
ns.level = 0;

local function IsToonInTable(toon)
	--if the toon isn't in the DB add a blank record
	if KeyKeeper == nil then KeyKeeper = {}; end;
	if KeyKeeper["Toons"] == nil then KeyKeeper["Toons"] = {}; end;
	if KeyKeeper["Toons"][toon] == nil then KeyKeeper["Toons"][toon] = {}; end;
	--should be here by now but text and return true
	if KeyKeeper["Toons"][toon] ~= nil then return true; end;
	--shouldn't get here...
	return false;
end;

function ns:IsToonKeyValid(toon)
	--returns true if toon key is valid, otherwise false
	if KeyKeeper ~= nil then
		if KeyKeeper["Toons"] ~= nil then
			if KeyKeeper["Toons"][toon] ~= nil then return true; end;
		end;
	end;
	return false;
end;


local function IsDateMoreRecent(toon, dt)
	--Compare date, if nil or older then return true and update
	--date format YYYY MM DD HH:MM so string compare works
	if (KeyKeeper["Toons"][toon]["Date"] == nil) or (KeyKeeper["Toons"][toon]["Date"] < dt) then return true; end;
	return false;
end;

local function IsKeyDifferent(toon, key, level)
	--if nil its not in the DB so return true and add
	if (KeyKeeper["Toons"][toon] == nil) then return true; end;
	if (KeyKeeper["Toons"][toon]["Key"] == nil) or (KeyKeeper["Toons"][toon]["Level"] == nil) then return true; end;
	--We have data so compare
	if (KeyKeeper["Toons"][toon]["Key"] ~= key) or (KeyKeeper["Toons"][toon]["Level"] ~= level) then return true; end;
	--same key
	return false;
end;
 
 function ns:UpdateKey(toon, key, level, dt, sendFlag)
	--set sendFlag false if you are updating recieved data so don't send it out again
	if sendFlag == nil then sendFlag = true; end;
	--Tuesday at 9:00 is addon reset time so dont accept data earlier then tuesday @ 9:00
	if (date("%w") == 2) and (date("%H:%M") > "09:00")then
		--its past reset so look as the key date
		--if key date is prior to 9:00 today exit the function
		if dt < date("%Y %m %d 09:00") then return; end;
	end;
	--check if in DB and if the key is different
	if IsToonInTable(toon) then		--1
		--If this toon wasn't there it should be added by now
		if KeyKeeper["Toons"][toon] == nil then	--2
			--if no key is saved then add this one.
			KeyKeeper["Toons"][toon] = {["Key"] = key, ["Level"] = level, ["Date"] = dt}; 		
		else
			--toon is there, is there a keystone
			if KeyKeeper["Toons"][toon]["Key"] == nil then	--3
				--no key so add this one
				KeyKeeper["Toons"][toon] = {["Key"] = key, ["Level"] = level, ["Date"] = dt};
			else
				--there is a key, is it different
				if IsKeyDifferent(toon, key, level) then	--4
					--key is different, find newest one
					if IsDateMoreRecent(toon, dt) then	--5
						--Update the DB with newer data
						KeyKeeper["Toons"][toon] = {["Key"] = key, ["Level"] = level, ["Date"] = dt};
					else
						--we have newer data so send it out even if flag was false
						sendFlag = true;
					end;	--5
				else
					--key is the same so we are done
					return;
				end;	--4
			end;	--3
		end;	--2	
	end;	--1
	--key has been updated so send it out
	if sendFlag then 
		ns:SendOneKey(toon); 
	end;
	if ns.Output:IsShown() then ns:ShowKeys(); end;
end;	--UpdateKey
 
 function ns:SendOneKey(toon)
	--Send one toons data
	local msg = toon .. "#" .. KeyKeeper["Toons"]["Key"] .. "#" .. KeyKeeper["Toons"]["Level"] .. "#" .. KeyKeeper["Toons"]["Date"];
	ns:SendData(msg);
 end;

 function ns:SendKeys()	
	--Send out data for all toons in database
	if KeyKeeper == nil then return; end;
	if KeyKeeper["Toons"] == nil then return; end;
	local msg = "";	
	local cID = GetChannelName(ns.channel);
	if cID > 0 then
		for index,value in pairs(KeyKeeper["Toons"]) do 
			msg = index .. "#" .. KeyKeeper["Toons"][index]["Key"] .. "#" .. KeyKeeper["Toons"][index]["Level"] 
						.. "#" .. KeyKeeper["Toons"][index]["Date"];
			local r = C_ChatInfo.SendAddonMessage (ns.prefix, msg, "CHANNEL", cID);
		end;
	end;
 end; 
 
 function ns:GetSaveResetTime()
	--Gets the currently saved reset time from the table
	--if the value isn't in the table 0 is returned
	if KeyKeeper ~= nil then
		if KeyKeeper["settings"] ~= nil then
			if KeyKeeper["settings"]["reset"] ~= nil then 
				return KeyKeeper["settings"]["reset"]; 
			end;
		end;
	end;
	return 0;
end;

 local function GetNextReset()
	--using 9:00 as reset time to compensate for time zones
	local t = time();
	--in case its 9:00 on reset day add 1 minute so we don't return today
	if date("%M", t) == "00" then t = t + 60; end;
	--Advance to an even hour buy adding minutes
	while (date("%M", t) ~= "00") do 
		t = t + 60;
	end;
	--Advance to 09:00 by adding hours (60 * 60 = 3600 seconds)
	while (date("%H:%M", t) ~= "09:00") do
		t = t + 3600;
	end;
	--Advance to Tuesday by adding days (3600 * 24 = 86400 seconds)
	while (date("%w", t) ~= "2") do
		t = t + 86400;
	end;
	return t;
 end;

function ns:ResetDataFile()
	--Dump all data and setup an empty table
	KeyKeeper = {
		["settings"] = {
			["reset"] = GetNextReset();	
		},
		["Toons"] = {},
	};	
end;
			
function ns:SendData(msg)
	local cID = GetChannelName(ns.channel);
	if cID > 0 then C_ChatInfo.SendAddonMessage (ns.prefix, "refresh", "CHANNEL", cID); end;
end;
		
			