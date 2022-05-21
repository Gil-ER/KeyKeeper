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
	"Hezikhan"
}
sort(Toons);

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

--Create a frame
local ManFrame = CreateFrame("Frame", "kkManualInputFrame", UIParent, "BasicFrameTemplate");
ManFrame:SetSize(325, 300);
ManFrame:SetPoint("CENTER", UIParent, "CENTER");

--Add the title
ManFrame.Title = ManFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal");
ManFrame.Title:SetPoint("TOPLEFT",0,-5);
ManFrame.Title:SetWidth(275);
ManFrame.Title:SetJustifyH("CENTER");
ManFrame.Title:SetText( "Add/Update A Key" );
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
    ['items']= {"2     ","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"},
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
ManFrame.LvlDD:SetPoint("TOPLEFT", ManFrame, "TOPLEFT", 20, -100);
ManFrame.LvlDD:SetWidth(50);
ManFrame.ToonDD = createDropdown(toon_opts);
ManFrame.ToonDD:SetPoint("TOPLEFT", ManFrame, "TOPLEFT", 20, -150);
--Add the buttons and handlers




--ManFrame.ButtonFactory("List Keys", "Lists the keys in party chat.");
--ManFrame.ButtonFactory("Update Data", "Sends out your data and collects\nanything updated by other users.\nThis should be folowed up by\nclicking the 'Update Chart'button.\nIt will take a few seconds to finish\nthe update process.");
--ManFrame.button[1]:SetScript("OnClick", function(self) end);
--ManFrame.button[2]:SetScript("OnClick", function(self) end);

--ManFrame:Hide();
function ns:DL ()
	ManFrame:Show();
end;


