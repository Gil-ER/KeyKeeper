--ns namespace variable
local _, ns = ...;

local t = {};		--table of FontStrings placed on the frame
--ns.button = {};		--array of buttons created at the bottom of the output frame


--Create strings and position for form info
local CreateStringTable = function ()
	for i = 1, 15 do
		local row = -18 + (-15 * i);		--row spacing
		t[i] = {	[1] = ns.Output:CreateFontString("kkText_" .. i .."1", "OVERLAY", "GameFontNormal"), 
					[2] = ns.Output:CreateFontString(nil, "OVERLAY", "GameFontNormal"),
					[3] = ns.Output:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				};
		t[i][1]:SetPoint("TOPLEFT", 15, row);
		t[i][1]:SetWidth(75);
		t[i][1]:SetJustifyH("RIGHT");
		
		t[i][2]:SetPoint("TOPLEFT", t[i][1], "TOPRIGHT", 10, 0);	
		t[i][2]:SetWidth(25);
		t[i][2]:SetJustifyH("LEFT");
		
		t[i][3]:SetPoint("TOPLEFT", t[i][2], "TOPRIGHT", 0, 0);
		t[i][3]:SetWidth(225);
		t[i][3]:SetJustifyH("LEFT");		
	end;
end 

--**************************************************************************
-- Output frame
--**************************************************************************
local params = {
	name = "kkOutputFrame",
	title = "Key Keeper",
	anchor = "CENTER", 		--anchor point of this form
	parent = UIParent,		--parent frame
	relFrame = UIParent,	--relative control for positioning
	relPoint = "CENTER",	--relative point for positioning
	xOff = 0,				--x offset from relative point
	yOff = 0,				--y offset from relative point
	width = 325,			--frame width
	height = 300,			--frame height
	isMovable = true,		--make the frame movable
	isSizable = false		--make the frame resizable
}
ns.Output = ns:createFrame(params)
CreateStringTable();
--Add the buttons and handlers
local w = (ns.Output:GetWidth() - 16 ) / 2;
params = {
	anchor = "BOTTOMLEFT",
	parent = ns.Output,
	relFrame = ns.Output,
	relPoint = "BOTTOMLEFT",
	xOff = 8,
	yOff = 10,
	width = w,
	height = 25,
	caption	= "List Keys",
	ttip = "Lists the keys in party chat.",
	pressFunc = function(self) ns:SendKeys(); ns:SendData("refresh"); ns:ChatKeys(); end;
}
ns:createButton(params);
params = {
	anchor = "BOTTOMRIGHT",
	parent = ns.Output,
	relFrame = ns.Output,
	relPoint = "BOTTOMRIGHT",
	xOff = -8,
	yOff = 10,
	width = w,
	height = 25,
	caption	= "Update Data",
	ttip = "Sends out your data and collects\nanything updated by other users.\nThis should be folowed up by\nclicking the 'Update Chart'button.\nIt will take a few seconds to finish\nthe update process.",
	pressFunc = function(self) ns:SendKeys(); ns:SendData("refresh"); end;
}
ns:createButton(params);
params = nil;
ns.Output:Hide();

local function ClearAllText()
	--Clears all strings in the chart
	for i = 1, 15 do		--15 lines
		for j = 1, 3 do		--3 positions
			t[i][j]:SetText("");
		end
	end
end

function ns:ShowKeys()
	--Displays the key data you currently have
	ClearAllText();
	if KeyKeeper ~= nil then 
		local i = 1;
		for index,value in pairs(KeyKeeper["Toons"]) do 
			t[i][1]:SetText(index);
			t[i][2]:SetText(KeyKeeper["Toons"][index]["Level"]);
			t[i][3]:SetText(KeyKeeper["Toons"][index]["Key"]);
			i = i + 1;
			if i == 16 then ns.Output:Show(); return; end;
		end;
	end;
	ns.Output:Show();
end;

