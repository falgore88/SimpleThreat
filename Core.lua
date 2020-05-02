local ThreatLib = LibStub:GetLibrary("LibThreatClassic2")
SimpleThreat = LibStub("AceAddon-3.0"):NewAddon("SimpleThreat", "AceConsole-3.0");

local AceGUI = LibStub("AceGUI-3.0")

local _UnitThreatSituation = function (unit, mob)
    return ThreatLib:UnitThreatSituation (unit, mob)
end

local _UnitDetailedThreatSituation = function (unit, mob)
    return ThreatLib:UnitDetailedThreatSituation (unit, mob)
end

local defaults = {
    profile = {
        isLock = false,
        isShowOnNotBattle = true,
        dangerThreat = 3000,
        sageThreat = 6000,
        dangerThreatColor = {
            r = 1,
            g = 0.1,
            b = 0.1,
            a = 1
        },
        warningThreatColor = {
            r = 0.2,
            g = 0.3,
            b = 0.6,
            a = 1
        },
        safeTheatColor = {
            r = 0.2,
            g = 0.5,
            b = 0.1,
            a = 1
        },
        width = 100,
        height = 50,
        pos = {
            x = 100,
            y = 0,
        }
    }
}

local options = {
    name = "SimpleThreat",
    handler = SimpleThreat,
    type = 'group',
    args = {
        isLock = {
            name = 'Lock',
            type = "toggle",
            width = 'full',
            order = 100,
            set = 'setIsLock',
            get = 'isLock'

        },
        isShowOnNotBattle = {
            name = 'Показывать вне боя',
            type = "toggle",
            width = 'full',
            order = 100,
            set = 'setIsShowOnNotBattle',
            get = 'isShowOnNotBattle'

        },
        posX = {
            name = 'Позиция X',
            type = "range",
            width = '50',
            order = 110,
            step = 1,
            width = 1.5,
            softMax = math.floor(GetScreenWidth() / 2),
            softMin = -(math.floor(GetScreenWidth() / 2)),
            set = 'setXPosition',
            get = 'getXPosition'
        },
        posY = {
            name = 'Позиция Y',
            type = "range",
            width = '50',
            order = 120,
            width = 1.5,
            step = 1,
            softMax = math.floor(GetScreenHeight() / 2),
            softMin = -(math.floor(GetScreenHeight() / 2)),
            set = 'setYPosition',
            get = 'getYPosition'
        },
        width = {
            name = 'Ширина',
            type = "range",
            width = '50',
            order = 130,
            width = 1.5,
            step = 1,
            softMax = 1000,
            softMin = 1,
            set = 'setWidth',
            get = 'getWidth'
        },
        height = {
            name = 'Высота',
            type = "range",
            width = '50',
            order = 130,
            width = 1.5,
            step = 1,
            softMax = 1000,
            softMin = 1,
            set = 'setHeight',
            get = 'getHeight'
        },
        dangerThreatColor = {
            type = "color",
            name = "Цвет опазной зоны (красная зона)",
            get = "getDangerThreatColor",
            set = "setDangerThreatColor",
            order = 200,
            width = 1
        },
        warningThreatColor = {
            type = "color",
            name = "Цвет зоны внимания (желтая зона)",
            get = "getWarningThreatColor",
            set = "setWarningThreatColor",
            width = 1,
            order = 300
        },
        safeTheatColor = {
            type = "color",
            name = "Цвет безопасной зоны (зеленая зона)",
            get = "getSafeTheatColor",
            set = "setSafeTheatColor",
            width = 1,
            order = 400
        },
        dangerThreat = {
            type = "input",
            name = "Значение красной зоны",
            desc = 'Кол-во агро, меньше которого будет считаться опасной зоной',
            get = "getDangerThreat",
            set = "setDangerThreat",
            width = 1.5,
            order = 500
        },
        safeThreat = {
            type = "input",
            name = "Значение зеленой зоны",
            desc = 'Кол-во агро, больше которого будет считаться безопасной зоной',
            get = "getSafeThreat",
            set = "setSafeThreat",
            width = 1.5,
            order = 600
        }
    }
}

function SimpleThreat:OnInitialize()
    -- Called when the addon is loaded

    self.db = LibStub("AceDB-3.0"):New("SimpleThreatDB", defaults, true)

    LibStub("AceConfig-3.0"):RegisterOptionsTable("SimpleThreat", options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(
                            "SimpleThreat", "SimpleThreat")
    self:RegisterChatCommand("st", "openConfig")

    self.isInBattle = false;
    self.frame = self:createFrame();

    self.Print("SimpleThreat", 'initialize')

end

function SimpleThreat:openConfig()
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
end

function SimpleThreat:OnEnable()
    -- Called when the addon is enabled
end

function SimpleThreat:OnDisable()
    -- Called when the addon is disabled
end

function SimpleThreat:setWidth(info, value)
    self.db.profile.width = tonumber(value);
    if self.frame then
        self.frame:SetWidth(self.db.profile.width);
    end
end

function SimpleThreat:getWidth(info, value)
    return self.db.profile.width
end

function SimpleThreat:setHeight(info, value)
    self.db.profile.height = tonumber(value);
    if self.frame then
        self.frame:SetHeight(self.db.profile.height);
    end
end

function SimpleThreat:getHeight(info, value)
    return self.db.profile.height
end

function SimpleThreat:getDangerThreatColor(info)
    return self.db.profile.dangerThreatColor.r,
           self.db.profile.dangerThreatColor.g,
           self.db.profile.dangerThreatColor.b,
           self.db.profile.dangerThreatColor.a
end

function SimpleThreat:setDangerThreatColor(info, r, g, b, a)
    self.db.profile.dangerThreatColor.r = r;
    self.db.profile.dangerThreatColor.g = g;
    self.db.profile.dangerThreatColor.b = b;
    self.db.profile.dangerThreatColor.a = a;
    
    if (self.frame) then
        self:update()
    end
end

function SimpleThreat:getWarningThreatColor(info)
    return self.db.profile.warningThreatColor.r,
           self.db.profile.warningThreatColor.g,
           self.db.profile.warningThreatColor.b,
           self.db.profile.warningThreatColor.a
end

function SimpleThreat:setWarningThreatColor(info, r, g, b, a)
    self.db.profile.warningThreatColor.r = r;
    self.db.profile.warningThreatColor.g = g;
    self.db.profile.warningThreatColor.b = b;
    self.db.profile.warningThreatColor.a = a;
    
    if (self.frame) then
        self:update()
    end
end

function SimpleThreat:getSafeTheatColor(info)
    return self.db.profile.safeTheatColor.r, self.db.profile.safeTheatColor.g,
           self.db.profile.safeTheatColor.b, self.db.profile.safeTheatColor.a
end

function SimpleThreat:setSafeTheatColor(info, r, g, b, a)
    self.db.profile.safeTheatColor.r = r;
    self.db.profile.safeTheatColor.g = g;
    self.db.profile.safeTheatColor.b = b;
    self.db.profile.safeTheatColor.a = a;

    if (self.frame) then
        self:update()
    end

end

function SimpleThreat:setIsLock(info, value)
    self.db.profile.isLock = not self.db.profile.isLock;
    self.frame:SetMovable(not self.db.profile.isLock)
    self.frame:EnableMouse(not self.db.profile.isLock)
    if self.db.profile.isLock then
        self.Print("SimpleThreat", "is locked")
    else
        self.Print("SimpleThreat", "is unlocked")
    end
end

function SimpleThreat:isLock(info) return self.db.profile.isLock end

function SimpleThreat:setIsShowOnNotBattle(info, value)
    self.db.profile.isShowOnNotBattle = not self.db.profile.isShowOnNotBattle;
    if (self.frame) then
        self:update()
    end
end

function SimpleThreat:isShowOnNotBattle(info)
    return self.db.profile.isShowOnNotBattle
end

function SimpleThreat:getDangerThreat(info)
    return tostring(self.db.profile.dangerThreat)
end

function SimpleThreat:setDangerThreat(info, value)
    value = tonumber(value);
    if (type(value) == "number") then
        self.db.profile.dangerThreat = value
    else
        self.Print("SimpleThreat",
                   'Поддерживаются только цифры')
    end
end

function SimpleThreat:getXPosition(info)
    return self.db.profile.pos.x
end

function SimpleThreat:setXPosition(info, value)
    self.db.profile.pos.x = tonumber(value);
    if (self.frame) then
        self:updatePosition(self.db.profile.pos.x, self.db.profile.pos.y)
    end
end

function SimpleThreat:getYPosition(info)
    return self.db.profile.pos.y
end

function SimpleThreat:setYPosition(info, value)
    self.db.profile.pos.y = tonumber(value);
    if (self.frame) then
        self:updatePosition(self.db.profile.pos.x, self.db.profile.pos.y)
    end
end

function SimpleThreat:updatePosition(x, y)
    self.frame:ClearAllPoints()
    self.frame:SetPoint("CENTER", "UIParent", x, y);
end


function SimpleThreat:getSafeThreat(info)
    return tostring(self.db.profile.safeThreat)
end

function SimpleThreat:setSafeThreat(info, value)
    value = tonumber(value);
    if (type(value) == "number") then
        self.db.profile.safeThreat = value
    else
        self.Print("SimpleThreat",
                   'Поддерживаются только цифры')
    end
end

function SimpleThreat:update()

    if (not self.db.profile.isShowOnNotBattle and not self.isInBattle) then
        self.frame:Hide()
        return
    else
        self.frame:Show()
    end

    local userIsTanking, userStatus, userthreatpct, userrawthreatpct, userthreatvalue =  _UnitDetailedThreatSituation("player", "target");
	local tankIsTanking, tankStatus, tankthreatpct, tankrawthreatpct, tankthreatvalue =  _UnitDetailedThreatSituation("targettarget", "target");
	local compare = tankthreatvalue - userthreatvalue;

	if (tankthreatvalue > 0) then
		self.frame.texture.text:SetText(tostring(compare) .. " (" .. tostring(floor(((tankthreatvalue or 1) - userthreatvalue) / tankthreatvalue * 100)) .. "%)")
	else
		self.frame.texture.text:SetText(tostring(compare) .. " (0%)")
	end

	

	if compare >= self.db.profile.safeThreat then 
		self.frame.texture:SetColorTexture(
            self.db.profile.safeTheatColor.r,
            self.db.profile.safeTheatColor.g,
            self.db.profile.safeTheatColor.b,
            self.db.profile.safeTheatColor.a
        )
	elseif compare >= self.db.profile.dangerThreat and compare < self.db.profile.safeThreat then
		self.frame.texture:SetColorTexture(
            self.db.profile.warningThreatColor.r,
            self.db.profile.warningThreatColor.g,
            self.db.profile.warningThreatColor.b,
            self.db.profile.warningThreatColor.a
        )
	elseif compare < self.db.profile.dangerThreat then
		self.frame.texture:SetColorTexture(
            self.db.profile.dangerThreatColor.r,
            self.db.profile.dangerThreatColor.g,
            self.db.profile.dangerThreatColor.b,
            self.db.profile.dangerThreatColor.a
        )
	end
end

function SimpleThreat:createFrame()
    self.frame = CreateFrame("Frame", "DragFrame2", UIParent)
    self.frame:SetMovable(not self.db.profile.isLock)
    self.frame:EnableMouse(not self.db.profile.isLock)

    self.frame:SetScript("OnMouseDown", function(this, button)
        if button == "LeftButton" and not this.isMoving and not self.db.profile.isLock then
            this:StartMoving();
            this.isMoving = true;
        end
    end)

    self.frame:SetScript("OnMouseUp", function(this, button)
        if button == "LeftButton" and this.isMoving and not self.db.profile.isLock then
            this:StopMovingOrSizing();
            this.isMoving = false;
            local _, _, _, xOfs, yOfs = self.frame:GetPoint()
            self.db.profile.pos.x = xOfs;
            self.db.profile.pos.y = yOfs;
            self:updatePosition(self.db.profile.pos.x, self.db.profile.pos.y)
        end
    end)
    
    self:updatePosition(
        self.db.profile.pos.x,
        self.db.profile.pos.y
    )

    self.frame:SetWidth(self.db.profile.width);
    self.frame:SetHeight(self.db.profile.height);

    self.frame.texture = self.frame:CreateTexture();
    self.frame.texture:SetAllPoints();
    self.frame.texture.text = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.frame.texture.text:SetPoint("CENTER")

    self.frame:RegisterEvent("UNIT_TARGET")
    self.frame:RegisterEvent("PLAYER_TARGET_CHANGED")
    self.frame:RegisterEvent("ADDON_LOADED")
    self.frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.frame:RegisterEvent("UNIT_HEALTH")
    self.frame:RegisterEvent("UNIT_POWER_UPDATE")
    self.frame:SetScript('OnEvent', function(this, event, ...)
        if (event == 'PLAYER_REGEN_ENABLED') then
            self.isInBattle = false;
        elseif (event == 'PLAYER_REGEN_DISABLED') then
            self.isInBattle = true;
        end

        self:update()
    end)

    return self.frame
end
