--ns namespace variable
local _, ns = ...;
local Export;

local t = {};		--table of FontStrings placed on the frame

--Create strings and position for form info
local CreateStringTable = function (f)
	local row = 0;		--row spacing
	for i = 1, 15 do
		t[i] = {	[1] = f:CreateFontString(nil, "OVERLAY", "GameFontNormal"), 
					[2] = f:CreateFontString(nil, "OVERLAY", "GameFontNormal"),
					[3] = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
				};
		t[i][1]:SetPoint("TOPLEFT", 15, row);
		t[i][1]:SetWidth(75);
		t[i][1]:SetJustifyH("RIGHT");
		
		t[i][2]:SetPoint("TOPLEFT", t[i][1], "TOPRIGHT", 10, 0);	
		t[i][2]:SetWidth(25);
		t[i][2]:SetJustifyH("LEFT");
		
		t[i][3]:SetPoint("TOPLEFT", t[i][2], "TOPRIGHT", 0, 0);
		t[i][3]:SetJustifyH("LEFT");
		row = row - 15;
	end;
end 

--**************************************************************************
-- Output frame
--**************************************************************************
ns.Output = CreateFrame("Frame", "kkOutputFrame", UIParent, "ButtonFrameTemplate"); 
ns.Output:SetSize(400, 310);
ns.Output:SetPoint("CENTER", UIParent, "CENTER");
ns.Output.TitleContainer.TitleText:SetText("Key Keeper");
ns.Output.PortraitContainer.portrait:SetTexture("Interface\\Icons\\inv_misc_key_05");
--Make dragable										Interface\Icons\inv_misc_key_05
ns.Output:EnableMouse(true);
ns.Output:SetMovable(true);
ns.Output:SetUserPlaced(true); 
ns.Output:RegisterForDrag("LeftButton");
ns.Output:SetScript("OnDragStart", function(self) self:StartMoving() end);
ns.Output:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); ns.Output:EnableMouse(true); end);
ns.Output:SetFrameStrata("DIALOG");
tinsert(UISpecialFrames, "kkOutputFrame");
--Add a scroll frame
local sFrame = CreateFrame("ScrollFrame", nil, ns.Output, "ScrollFrameTemplate");
sFrame:SetSize(ns.Output:GetWidth() - 45, ns.Output:GetHeight() - 100);
sFrame:SetPoint("TOPLEFT", ns.Output, "TOPLEFT", 15, -70);
sChild = CreateFrame("Frame");
sChild:SetSize(sFrame:GetWidth(), sFrame:GetHeight() * 2);
sFrame:SetScrollChild(sChild);	
CreateStringTable(sChild);

ns.Info = CreateFrame("EditBox", nil, ns.Output, "InputBoxTemplate");
ns.Info:SetPoint("BOTTOMLEFT", ns.Output, "BOTTOMLEFT", 13, 10);
ns.Info:SetSize(ns.Output:GetWidth()-30, 10);
ns.Info:SetEnabled(false);
ns.Info:SetJustifyH("LEFT");
ns.Info:SetScript("OnEnter", function(self)
	if self:GetText() == "" then return; end;
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT");
	GameTooltip:AddLine("Click for link");
	GameTooltip:Show();
end);
ns.Info:SetScript("OnMouseDown", function(self)	if self:GetText() == "" then return; end; exportFrame(); end);
ns.Info:SetScript("OnLeave", function() GameTooltip:Hide(); end);


--Add the buttons and handlers
local bList = CreateFrame("Button",  nil, ns.Output, "GameMenuButtonTemplate");
bList:SetSize(100, 25);
bList:SetText("List Keys")
bList:SetNormalFontObject("GameFontNormalLarge");
bList:SetHighlightFontObject("GameFontHighlightLarge");
bList:SetPoint("TOPRIGHT", ns.Output, "TOPLEFT", ns.Output:GetWidth()/2, -30);
bList:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "LEFT");
	GameTooltip:AddLine("Lists the keys in party chat.");
	GameTooltip:Show();
end);
bList:SetScript("OnLeave", function() GameTooltip:Hide(); end);
bList:SetScript("OnClick", function(self, button, down)
	ns:SendKeys(); 
	ns:SendData("refresh"); 
	ns:ChatKeys();
end)
local bUpdate = CreateFrame("Button",  nil, ns.Output, "GameMenuButtonTemplate");
bUpdate:SetSize(100, 25);
bUpdate:SetText("Update")
bUpdate:SetNormalFontObject("GameFontNormalLarge");
bUpdate:SetHighlightFontObject("GameFontHighlightLarge");
bUpdate:SetPoint("TOPLEFT", bList, "TOPRIGHT");
bUpdate:SetScript("OnEnter", function()
	GameTooltip:SetOwner(bUpdate, "LEFT");
	GameTooltip:AddLine("Sends out your data and collects\nanything updated by other users.");
	GameTooltip:Show();
end);
bUpdate:SetScript("OnLeave", function() GameTooltip:Hide(); end);
bUpdate:SetScript("OnClick", function(self, button, down)
	ns:SendKeys(); 
	ns:SendData("refresh"); 
end)
ns.Output:SetScript("OnSizeChanged", function (self)
	local topMiddle = self:GetWidth()/2 + 10;
	bList:SetPoint("TOPRIGHT", self, "TOPLEFT", topMiddle, -30);	
	sFrame:SetWidth(ns.Output:GetWidth() - 45);
	ns.Info:SetWidth(ns.Output:GetWidth()-20);
end)
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
	local maxWidth = 100;		--100 will keep the frame width at least 300
	if KeyKeeper ~= nil then 
		local i = 1;
		for index,value in pairs(KeyKeeper["Toons"]) do 
			t[i][1]:SetText(index);
			t[i][2]:SetText(KeyKeeper["Toons"][index]["Level"]);
			t[i][3]:SetText(KeyKeeper["Toons"][index]["Key"]);
			local w = floor(t[i][3]:GetWidth());
			if w > maxWidth then maxWidth = w; end;
			i = i + 1;
			if i == 16 then ns.Output:SetWidth(maxWidth + 200); ns.Output:Show(); return; end;
		end;
	end;
	ns.Output:SetWidth(maxWidth + 200);
	ns.Output:Show();
end;

function exportFrame ()
	if Export == nil then
		Export = CreateFrame("Frame", nil, UIParent, "UIPanelDialogTemplate"); 
		Export:SetSize(350,125)		
		Export.eb = CreateFrame("EditBox", nil, Export)
		Export.eb:SetPoint("TOPLEFT", Export, "TOPLEFT", 20, -80)
		Export.eb:SetMultiLine(true)
		Export.eb:SetFontObject(ChatFontNormal)
		Export.eb:SetWidth(460)
		local s = Export:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		s:ClearAllPoints();
		s:SetPoint("TOPLEFT", Export, "TOPLEFT", 40, -40)
		s:SetText("Press Ctrl + C");
	end;
	Export:ClearAllPoints()
	if ns.Output:GetLeft() > 500 then Export:SetPoint("BOTTOMRIGHT", ns.Output,"BOTTOMLEFT");
	else Export:SetPoint("BOTTOMLEFT", ns.Output,"BOTTOMRIGHT"); end;
	Export.eb:SetText("www.github.com/Gil-ER/KeyKeeper/releases/latest/")					--place it the editbox
	Export.eb:HighlightText();
	Export:Show();
end;