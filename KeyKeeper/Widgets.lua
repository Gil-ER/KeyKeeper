--ns namespace variable
local addon, ns = ...;


--	Creates a Dropdown (Example)
--	local opts = {
--		name = nil,				--globally unique, only change if you need it
--		title = "Title"
--		anchor = "TOPCENTER", 
--		parent = MainFrame,
--		relFrame = MainFrame,
--		relPoint = "TOPCENTER",
--		xOff = 0,
--		yOff = -100,
--		items = {},
--		defaultVal (String): String value for the dropdown to default to (empty otherwise).
--		ttip = "Optional tooltip.",
---     changeFunc = function(dropdown_frame, dropdown_val) ManFrame.dung = dropdown_val; end
--	}
--	ns:createDropdown(opts)
--[[opts:
		name (string)			GLOBAL Unique name for the dropdown, leave nil if you don't need the name
		title (string)			String caption for the dropdown
		anchor (string)			anchor point of this dropdown (TOPLEFT)
		parent (Frame)			parent frame of the dropdown
		relFrame (Frame)		position dropdown relative to this frame
		relPoint (string)		position this dropdown relative to this point (TOPLEFT)
		xOff (number)			x offset
		yOff (number)			y Offset
		items (table)			List to be displayed in the dropdown
		defaultVal (String)		String value for the dropdown to default to (empty otherwise).
		ttip (string)			tooltip to show when the dropdown is moused over (optional)
		changeFunc (Function)	A custom function to be called, after selecting a dropdown option.
			
		returns the dropdown
]]
local dropdownCount = 0;
function ns:createDropdown(opts)
	dropdownCount = dropdownCount + 1;
	if opts.name == nil or opts.name == "" then
		opts.name = addon .. "GeneratedDropdownNumber" .. dropdownCount;
	end;
	local menu_items = opts['items'] or {};
    local title_text = opts['title'] or "";
    local dropdown_width = 0;
    local default_val = opts['defaultVal'] or "";
    local change_func = opts['changeFunc'] or function (dropdown_val) end;

    local dropdown = CreateFrame("Frame", opts.name, opts['parent'], 'UIDropDownMenuTemplate');	
	dropdown:SetPoint(opts.anchor, opts.relFrame, opts.relPoint, opts.xOff, opts.yOff);
    
	local dd_title = dropdown:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal');
    dd_title:SetPoint("TOPLEFT", 20, 10);

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
	if (opts.ttip ~= nil) or (opts.ttip ~= "") then 
		dropdown:SetScript("OnEnter", function()
			GameTooltip:SetOwner(dropdown, "LEFT");
			GameTooltip:AddLine(opts.ttip);
			GameTooltip:Show();
		end);
		dropdown:SetScript("OnLeave", function() GameTooltip:Hide(); end);
	end;

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


local buttonCount = 0;
function ns:createButton(opts)
	buttonCount = buttonCount + 1;
	if opts.name == nil or opts.name == "" then
		opts.name = addon .. "GeneratedButtonNumber" .. buttonCount;
	end;	
	local b = CreateFrame("Button",  opts.name, opts.parent, "GameMenuButtonTemplate");
	b:SetSize(opts.width, opts.height);
	b:SetText(opts.caption);
	b:SetNormalFontObject("GameFontNormalLarge");
	b:SetHighlightFontObject("GameFontHighlightLarge");
	b:SetPoint(opts.anchor, opts.relFrame, opts.relPoint, opts.xOff, opts.yOff);
	if (opts.ttip ~= nil) or (opts.ttip ~= "") then 
		b:SetScript("OnEnter", function()
			GameTooltip:SetOwner(b, "LEFT");
			GameTooltip:AddLine(opts.ttip);
			GameTooltip:Show();
		end);
		b:SetScript("OnLeave", function() GameTooltip:Hide(); end);
	end;
	if opts.pressFunc ~= nil then 
		b:SetScript("OnClick", function(self, button, down)
			opts.pressFunc(self, button)
		end)
	end;
	return b;	
end;

local frameCount = 0;
function ns:createFrame(opts)
--Create Frame
	frameCount = frameCount + 1;
	if opts.name == nil or opts.name == "" then
		opts.name = addon .. "GeneratedFrameNumber" .. frameCount;
	end;
	local f = CreateFrame("Frame", opts.name, opts.parent, "UIPanelDialogTemplate"); 
	f:SetWidth(opts.width);
	f:SetHeight(opts.height);
	f:SetPoint(opts.anchor, opts.relFrame, opts.relPoint, opts.xOff, opts.yOff);
	if opts.title ~= nil then
	--Add the title
		f.Title:SetJustifyH("CENTER");
		f.Title:SetText( opts.title );
	end;
	if opts.isMovable then
	--Make dragable
		f:EnableMouse(true);
		f:SetMovable(true);
		f:SetUserPlaced(true); 
		f:RegisterForDrag("LeftButton");
		f:SetScript("OnDragStart", function(self) self:StartMoving() end);
		f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); end);
	end;
	if opts.isResizable then
	--Make frame Resizable
		f:SetResizable(true);
		f:SetScript("OnMouseDown", function()
			f:StartSizing("BOTTOMRIGHT")
		end);
		f:SetScript("OnMouseUp", function()
			f:StopMovingOrSizing()
		end);
		f:SetScript("OnSizeChanged", OnSizeChanged);
	end;
	return f
end;
