--ns namespace variable
local _, ns = ...;

local t = {};		--table of FontStrings placed on the frame
ns.button = {};		--array of buttons created at the bottom of the output frame

local ButtonFactory = function (text, ttip)
	--text: caption for the button
	--creates a new button and places it in an array then sizes and positions it 
	local bCount = #ns.button + 1;
	ns.button[bCount] = CreateFrame("Button", "kkButton" .. bCount, ns.Output)
	local b = ns.button[bCount];
	if bCount == 1 then
		b:SetPoint("BOTTOMRIGHT", ns.Output, "BOTTOMRIGHT",-5, 5)
	else
		b:SetPoint("BOTTOMRIGHT", ns.button[bCount - 1], "BOTTOMLEFT", 0, 0)
	end
	b:SetWidth((ns.Output:GetWidth() - 5 ) / 2);
	b:SetHeight(25);        
	b:SetNormalFontObject("GameFontNormal")
	b:SetText(text);
	
	local ntex = b:CreateTexture()
	ntex:SetTexture("Interface/Buttons/UI-Panel-Button-Up")
	ntex:SetTexCoord(0, 0.625, 0, 0.6875)
	ntex:SetAllPoints()	
	b:SetNormalTexture(ntex)
	
	local htex = b:CreateTexture()
	htex:SetTexture("Interface/Buttons/UI-Panel-Button-Highlight")
	htex:SetTexCoord(0, 0.625, 0, 0.6875)
	htex:SetAllPoints()
	b:SetHighlightTexture(htex)
	
	local ptex = b:CreateTexture()
	ptex:SetTexture("Interface/Buttons/UI-Panel-Button-Down")
	ptex:SetTexCoord(0, 0.625, 0, 0.6875)
	ptex:SetAllPoints()
	b:SetPushedTexture(ptex)
	
	b:SetScript("OnEnter", function (self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP");
		GameTooltip:AddLine(ttip)
		GameTooltip:Show();
	end);
	b:SetScript("OnLeave", function(self) GameTooltip:Hide(); end);	
end

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
--Create Frame
ns.Output = CreateFrame("Frame", "kkOutputFrame", UIParent, "BasicFrameTemplate");
ns.Output:SetPoint("CENTER",UIParent);
--Make dragable
ns.Output:EnableMouse(true);
ns.Output:SetMovable(true);
ns.Output:SetUserPlaced(true); 
ns.Output:RegisterForDrag("LeftButton");
ns.Output:SetScript("OnDragStart", function(self) self:StartMoving() end);
ns.Output:SetScript("OnDragStart", function(self) self:StartMoving() end);
ns.Output:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); end);
--Size (width, height)
ns.Output:SetSize(300, 300);
ns.Output:SetPoint("TOPLEFT");

CreateStringTable();

--Add the buttons and handlers
ButtonFactory("Update Chart", "Refresh the chart from the data\nin your database incase the data\nhas been updated by another user.");
ButtonFactory("Update Data", "Sends out your data and collects\nanything updated by other users.\nThis should be folowed up by\nclicking the 'Update Chart'button.\nIt will take a few seconds to finish\nthe update process.");
ns.button[1]:SetScript("OnClick", function(self) ns:ShowKeys(); end);
ns.button[2]:SetScript("OnClick", function(self) ns:SendKeys(); ns:SendData("refresh"); end);

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

