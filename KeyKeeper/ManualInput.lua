local _, ns = ...;

local Dungeons = {
	"De Other Side",
	"Mists of Tirna Scithe",
	"The Necrotic Wake",
	"Spires of Ascension",
	"Theater of Pain",	
	"Plaguefall",
	"Halls of Atonement",
	"Sanguine Depths",
	"Tazavesh: Streets of Wonder",
	"Tazavesh: So'leah's Gambit"
}
sort(Dungeons);

local Toons = {
	"Gildina",
	"Tem",
	"Junpa",
	"Kaandew",
	"Hezzakan"
}
sort(Toons);
-------------------------------------------------------------------------
-- ToolTip functions
-- 		The show function relies on the tooltip being saved in the control 
--		so it can be accessed as self.ttip
-------------------------------------------------------------------------
function ns.TT_Show(self, position)
	--self - the control that called the function
	--position 	- The orientation of the tooltip in relation to the control ie:"LEFT"
	--Usage		- 'control':SetScript("OnEnter", function() addon.TT_Show('control', "LEFT"); end);
	if position == nil then position = "LEFT"; end;
	GameTooltip:SetOwner(self, position);
	GameTooltip:AddLine(self.ttip);
	GameTooltip:Show();
end;
function ns.TT_Hide()
	GameTooltip:Hide();
end;

--[[	opts:
			name (string)			name of button (lowercase)
			anchor (string)			anchor point of this button (TOPLEFT)
			parent (Frame)			parent frame of the button
			relFrame (Frame)		position button relative to this frame
			relPoint (string)		position this button relative to this point (TOPLEFT)
			xOff (number)			x offset
			yOff (number)			y Offset
			width (number)			button width
			height (number)			button height
			caption	(string)		Text to appear on the button
			ttip (string)			tooltip to show when the button is moused over (optional)
			pressFunc (Function)	A custom function to be called when the button id pressed (optional).
			
		returns the button
]]
function ns:CreateButton(opts)
	local btn = CreateFrame("Button", nil, opts.parent, "GameMenuButtonTemplate");
	btn:SetSize(opts.width, opts.height);
	btn:SetText(opts.caption);
	btn:SetNormalFontObject("GameFontNormalLarge");
	btn:SetHighlightFontObject("GameFontHighlightLarge");
	btn:SetPoint(opts.anchor, opts.relFrame, opts.relPoint, opts.xOff, opts.yOff);
	if (opts.ttip ~= nil) or (opts.ttip ~= "") then 
		btn.ttip = opts.ttip;
		btn:SetScript("OnEnter", ns.TT_Show);
		btn:SetScript("OnLeave", ns.TT_Hide);
	end;
	if opts.pressFunc ~= nil then 
		btn:SetScript("OnClick", function(self, button, down)
			opts.pressFunc(self, button)
		end)
	end;
	return btn;	
end;

--[[
	local btn = CreateFrame("Button", nil, relativeFrame, "GameMenuButtonTemplate");
	btn:SetSize(width, height);
	btn:SetText(caption);
	btn:SetNormalFontObject("GameFontNormalLarge");
	btn:SetHighlightFontObject("GameFontHighlightLarge");
	btn:SetPoint(point, relativeFrame, relativePoint, xOff, yOff);
	btn.ttip = ttip;
	btn:SetScript("OnEnter", ns.TT_Show);
	btn:SetScript("OnLeave", ns.TT_Hide);
	return btn;
end;

]]

--- Opts:
---     name (string): Name of the dropdown (lowercase)
---     parent (Frame): Parent frame of the dropdown.
---     items (Table): String table of the dropdown options.
---     defaultVal (String): String value for the dropdown to default to (empty otherwise).
---     changeFunc (Function): A custom function to be called, after selecting a dropdown option.
local function createDropdown(opts)
    local dropdown_name = '$parent_' .. opts['name'] .. '_dropdown'
    local menu_items = opts['items'] or {}
    local title_text = opts['title'] or ''
    local dropdown_width = 0
    local default_val = opts['defaultVal'] or ''
    local change_func = opts['changeFunc'] or function (dropdown_val) end

    local dropdown = CreateFrame("Frame", dropdown_name, opts['parent'], 'UIDropDownMenuTemplate')
    local dd_title = dropdown:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal')
    dd_title:SetPoint("TOPLEFT", 20, 10)

    for _, item in pairs(menu_items) do -- Sets the dropdown width to the largest item string width.
        dd_title:SetText(item)
        local text_width = dd_title:GetStringWidth() + 20
        if text_width > dropdown_width then
            dropdown_width = text_width
        end
    end

    UIDropDownMenu_SetWidth(dropdown, dropdown_width)
    UIDropDownMenu_SetText(dropdown, default_val)
    dd_title:SetText(title_text)

    UIDropDownMenu_Initialize(dropdown, function(self, level, _)
        local info = UIDropDownMenu_CreateInfo()
        for key, val in pairs(menu_items) do
            info.text = val;
            info.checked = false
            info.menuList= key
            info.hasArrow = false
            info.func = function(b)
                UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
                UIDropDownMenu_SetText(dropdown, b.value)
                b.checked = true
                change_func(dropdown, b.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    return dropdown
end

--	Creates a frame
local opts = {
	title = "Add/Update A Key",
	anchor = "CENTER", 
	parent = UIParent,
	relFrame = UIParent,
	relPoint = "CENTER",
	xOff = 0,
	yOff = 0,
	width = 325,
	height = 300,
	isMovable = false,
	isSizable = false
}
local ManFrame = ns:createFrame(opts)
ManFrame.dung = Dungeons[1];
ManFrame.lvl = "12";
ManFrame.char = "Tem";

local dung_opts = {
    ['name']='dungeon',
    ['parent']=ManFrame,
    ['title']='Dungeon',
    ['items']= Dungeons,
    ['defaultVal']=ManFrame.dung, 
    ['changeFunc']=function(dropdown_frame, dropdown_val)
        ManFrame.dung = dropdown_val;
		print(ManFrame.char, "  ", ManFrame.lvl, "  ", ManFrame.dung);
    end
}

local lvl_opts = {
    ['name']='lvl',
    ['parent']=ManFrame,
    ['title']='Key Level',
    ['items']= {"2         ","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"},
    ['defaultVal']=ManFrame.lvl, 
    ['changeFunc']=function(dropdown_frame, dropdown_val)
        ManFrame.lvl = dropdown_val;
		print(ManFrame.char, "  ", ManFrame.lvl, "  ", ManFrame.dung);
    end
}

local toon_opts = {
    ['name']='toon',
    ['parent']=ManFrame,
    ['title']='Toon',
    ['items']= Toons,
    ['defaultVal']='Tem', 
    ['changeFunc']=function(dropdown_frame, dropdown_val)
        ManFrame.char = dropdown_val;
		print(ManFrame.char, "  ", ManFrame.lvl, "  ", ManFrame.dung);
    end
}

ManFrame.DungDD = createDropdown(dung_opts);
ManFrame.DungDD:SetPoint("TOPLEFT", ManFrame, "TOPLEFT", 20, -50);
ManFrame.LvlDD = createDropdown(lvl_opts);
ManFrame.LvlDD:SetPoint("BOTTOMRIGHT", ManFrame.DungDD, "BOTTOMRIGHT", 0,  -60);
ManFrame.ToonDD = createDropdown(toon_opts);
ManFrame.ToonDD:SetPoint("BOTTOMLEFT", ManFrame.DungDD, "BOTTOMLEFT", 0, -60);
ManFrame:SetWidth(ManFrame.DungDD:GetWidth() + 40);
ManFrame:SetHeight( ManFrame:GetTop() - ManFrame.DungDD:GetBottom() + 125);
--Add the buttons and handlers
local w = ManFrame.DungDD:GetWidth() / 2 - 13;
local okButton = {
			name = "ok",
			anchor = "BOTTOMRIGHT",
			parent = ManFrame,
			relFrame = ManFrame.LvlDD,
			relPoint = "BOTTOMRIGHT",
			xOff = -11,
			yOff = -50,
			width = w,
			height = 40,
			caption	= "OK",
			ttip = "Add the key defined in\nthe form above to the list.", 			
			pressFunc = (function (self) ns:UpdateKey(ManFrame.char, ManFrame.dung, ManFrame.lvl, date("%Y %m %d %H:%M"), true); ManFrame:Hide(); end);
}
ManFrame.OK = ns:CreateButton( okButton );
local cancelButton = {
			name = "cancel",
			anchor = "BOTTOMRIGHT",
			parent = ManFrame,
			relFrame = ManFrame.OK,
			relPoint = "BOTTOMLEFT",
			xOff = 0,
			yOff = 0,
			width = w,
			height = 40,
			caption	= "Cancel", 
			ttip = "Close this dialogue\nand discard any changes.",
			pressFunc = (function (self) ManFrame:Hide(); end);
}
ManFrame.Cancel = ns:CreateButton( cancelButton );
opts = nil;
ManFrame:Hide();
function ns:DL ()
	ManFrame:Show();
end;


