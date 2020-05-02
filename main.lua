local ThreatLib = LibStub:GetLibrary("LibThreatClassic2")

local RED_HEX = '#800000';
local GREEN_HEX = '#005B00';
local YELLOW_HEX = '#ffff00';
local GOOD_THREAT = 6000;
local BAD_THREAT = 3000


local _UnitThreatSituation = function (unit, mob)
    return ThreatLib:UnitThreatSituation (unit, mob)
end

local _UnitDetailedThreatSituation = function (unit, mob)
    return ThreatLib:UnitDetailedThreatSituation (unit, mob)
end

local function getThreatCompare()
	local userIsTanking, userStatus, userthreatpct, userrawthreatpct, userthreatvalue =  _UnitDetailedThreatSituation("player", "target")
	local tankIsTanking, tankStatus, tankthreatpct, tankrawthreatpct, tankthreatvalue =  _UnitDetailedThreatSituation("targettarget", "target")
	return tankthreatvalue - userthreatvalue;
end

local function hex2rgb(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)) / 255, tonumber("0x"..hex:sub(3,4)) / 255, tonumber("0x"..hex:sub(5,6)) / 255
end

local function hex2rgb2(hex, alpha) 
	hex = string.sub(hex, 2)
	local redColor,greenColor,blueColor=hex:match('(..)(..)(..)')
	redColor, greenColor, blueColor = tonumber(redColor, 16), tonumber(greenColor, 16), tonumber(blueColor, 16)
	return redColor/255, greenColor/255, blueColor/255
end

local frame = CreateFrame("Frame", "DragFrame2", UIParent)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetScript("OnMouseDown", function(self, button)
  if button == "LeftButton" and not self.isMoving then
   self:StartMoving();
   self.isMoving = true;
  end
end)
frame:SetScript("OnMouseUp", function(self, button)
  if button == "LeftButton" and self.isMoving then
   self:StopMovingOrSizing();
   self.isMoving = false;
  end
end)
frame:SetScript("OnHide", function(self)
  if ( self.isMoving ) then
   self:StopMovingOrSizing();
   self.isMoving = false;
  end
end)

frame:SetPoint("CENTER"); 
frame:SetWidth(160); 
frame:SetHeight(40);
local tex = frame:CreateTexture();
tex:SetAllPoints();
texString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
texString:SetPoint("CENTER")


local function updateFrame()
	local userIsTanking, userStatus, userthreatpct, userrawthreatpct, userthreatvalue =  _UnitDetailedThreatSituation("player", "target");
	local tankIsTanking, tankStatus, tankthreatpct, tankrawthreatpct, tankthreatvalue =  _UnitDetailedThreatSituation("targettarget", "target");
	local compare = tankthreatvalue - userthreatvalue;

	if (tankthreatvalue > 0) then
		texString:SetText(tostring(compare) .. " (" .. tostring(floor(((tankthreatvalue or 1) - userthreatvalue) / tankthreatvalue * 100)) .. "%)")
	else
		texString:SetText(tostring(compare) .. " (0%)")
	end

	

	if compare >= GOOD_THREAT then 
		tex:SetColorTexture(hex2rgb(GREEN_HEX))
	elseif compare >=BAD_THREAT and compare < GOOD_THREAT then
		tex:SetColorTexture(hex2rgb(YELLOW_HEX))
	elseif compare < BAD_THREAT then
		tex:SetColorTexture(hex2rgb(RED_HEX))
	end
end

frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("UNIT_COMBAT")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_POWER_UPDATE")
frame:SetScript("OnEvent", function(self, event, ...) 
	updateFrame()
end)
