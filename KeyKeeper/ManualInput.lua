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

--	Creates a frame
local params = {
	title = "Add/Update A Key",
	anchor = "CENTER", 
	parent = UIParent,
	relFrame = UIParent,
	relPoint = "CENTER",
	xOff = 0,
	yOff = 0,
	width = 325,
	height = 310,
	isMovable = false,
	isSizable = false
}
local ManFrame = ns:createFrame(params)
ManFrame.dung = Dungeons[1];
ManFrame.lvl = "14";
ManFrame.char = "Tem";

-- Creates a Dropdown (Example)
params = {	--Dungeons
	title = "Dungeon",
	anchor = "TOPLEFT", 
	parent = ManFrame,
	relFrame = ManFrame,
	relPoint = "TOPLEFT",
	xOff = 20,
	yOff = -50,
	items = Dungeons,
	defaultVal = ManFrame.dung,
	caption	= "Save",
    changeFunc = function(dropdown_frame, dropdown_val) ManFrame.dung = dropdown_val; end
}
ManFrame.DungDD = ns:createDropdown(params);

params = {	--Level
	title = "Level",
	anchor = "BOTTOMRIGHT", 
	parent = ManFrame,
	relFrame = ManFrame.DungDD,
	relPoint = "BOTTOMRIGHT",
	xOff = 0,
	yOff = -50,
	items = {"2         ","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"},
	defaultVal = ManFrame.lvl,
    changeFunc = function(dropdown_frame, dropdown_val) ManFrame.lvl = dropdown_val; end
}
ManFrame.LvlDD = ns:createDropdown(params);

params = {	--Toons
	title = "Toon",
	anchor = "BOTTOMLEFT", 
	parent = ManFrame,
	relFrame = ManFrame.DungDD,
	relPoint = "BOTTOMLEFT",
	xOff = 0,
	yOff = -50,
	items = Toons,
	defaultVal ="Tem",
    changeFunc = function(dropdown_frame, dropdown_val) ManFrame.char = dropdown_val; end
}
ManFrame.ToonDD = ns:createDropdown(params);
ManFrame:SetWidth(ManFrame.DungDD:GetWidth() + 40);
ManFrame:SetHeight( ManFrame:GetTop() - ManFrame.DungDD:GetBottom() + 125);


--Add the buttons and handlers
local w = ManFrame.DungDD:GetWidth() / 2 - 13;
params = {
	anchor = "BOTTOMRIGHT", 
	parent = ManFrame,
	relFrame = ManFrame.LvlDD,
	relPoint = "BOTTOMRIGHT",
	xOff = -11,
	yOff = -50,
	width = w,
	height = 35,
	caption	= "OK",
	ttip = "Add the key defined in\nthe form above to the list.", 	
	pressFunc = (function (self) ns:UpdateKey(ManFrame.char, ManFrame.dung, ManFrame.lvl, date("%Y %m %d %H:%M"), true); ManFrame:Hide(); end);
}
ManFrame.OK = ns:createButton( params );
local params = {
	anchor = "BOTTOMRIGHT",
	parent = ManFrame,
	relFrame = ManFrame.OK,
	relPoint = "BOTTOMLEFT",
	xOff = 0,
	yOff = 0,
	width = w,
	height = 35,
	caption	= "Cancel", 
	ttip = "Close this dialogue\nand discard any changes.",
	pressFunc = (function (self) ManFrame:Hide(); end);
}
ManFrame.Cancel = ns:createButton( params );
params = nil;


ManFrame:Hide();
function ns:DL ()
	ManFrame:Show();
end;


