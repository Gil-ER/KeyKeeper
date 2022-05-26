--ns namespace variable
local addon, ns = ...;
local frameCount = 0;

--[[	opts:
			name (string)			GLOBAL Unique name for the frame, leave nil if you don't need the name
			title (string)			Caption for top of this frame
			anchor (string)			anchor point of this frame (TOPLEFT)
			parent (Frame)			parent frame of the frame
			relFrame (Frame)		position frame relative to this frame
			relPoint (string)		position this frame relative to this point (TOPLEFT)
			xOff (number)			x offset
			yOff (number)			y Offset
			width (number)			frame width
			height (number)			frame height
			isMovable (boolean)
			isResizable (boolean)		
			
		returns the frame
]]

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
