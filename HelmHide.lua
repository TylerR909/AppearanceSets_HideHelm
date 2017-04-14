local AddOn_Name, ns = ...
local friendlyName = GetAddOnMetadata(AddOn_Name,"Title")

-- TODO: Pull variant table option into its own row?
-- TODO: Clean up . : notation
-- TODO: Clean up ASHH v self
-- TODO: Icons per armor class(cloth, leather, mail, plate)
-- TODO: Clean up by putting options in its own file
-- Keepsake: https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/AddOns/Blizzard_Collections/Blizzard_Wardrobe.lua

ASHH = LibStub("AceAddon-3.0"):NewAddon(AddOn_Name,"AceEvent-3.0","AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(AddOn_Name,true)
local model, setsFrame

local defaultOptions_off = {
    global = {
        hideHelm = true,
        hideShoulders = false,
        hideBack = false,
        hideBelt = false,
        expandVariants = true
    },
    char = {
        useCharSettings = false
    }
}

local optionsTable_off = {
    name = friendlyName,
    handler = ASHH,
    type = 'group',
    args = {
        enable = {
            name = "Enable",
            desc = "Enables/Disables the addon",
            type = 'toggle',
            order = 0,
            hidden = true,
            set = function(self, val) end,
            get = function(self) return end
        },
        reloadDialogue = {
            type = "description",
            name = L["ReloadMsg"],
            order = 1
        },
        globalHeader = {
            name = L["Global Defaults"],
            type = "header",
            order = 2
        },
        helmDefault_G = {
            name = L["Hide Helm"],
            type = "toggle",
            order = 3,
            set = function(_, val) 
                    ASHH.db.global.hideHelm = val 

                    if not ASHH.db.char.useCharSettings then
                        ASHH.db.char.hideHelm = val
                    end
                end,
            get = function() return ASHH.db.global.hideHelm end
        },
        shoulderDefault_G = {
            name = L["Hide Shoulders"],
            type = "toggle",
            order = 4,
            set = function(_,val) 
                    ASHH.db.global.hideShoulders = val 
                    
                    if not ASHH.db.char.useCharSettings then
                        ASHH.db.char.hideShoulders = val
                    end
                end,
            get = function() return ASHH.db.global.hideShoulders end
        },
        backDefault_G = {
            name = L["Hide Back"],
            type = "toggle",
            order = 5,
            set = function(_,val) 
                    ASHH.db.global.hideBack = val 

                    if not ASHH.db.char.useCharSettings then
                        ASHH.db.char.hideBack = val
                    end
                end,
            get = function() return ASHH.db.global.hideBack end
        },
        beltDefault_G = {
            name = L["Hide Belt"],
            type = "toggle",
            order = 5,
            set = function(_,val) 
                    ASHH.db.global.hideBelt = val 

                    if not ASHH.db.char.useCharSettings then
                        ASHH.db.char.hideBelt = val
                    end
                end,
            get = function() return ASHH.db.global.hideBelt end
        },
        expandVariants_G = {
            name = L["Expand Variants"],
            type = "toggle",
            order = 6,
            desc = L["Coming soon!"],
            descStyle = "inline",
            disabled = true,
            set = function(_,val) ASHH.db.global.expandVariants = val end,
            get = function() return ASHH.db.global.expandVariants end
        },
        charHeader = {
            name = L["Character Defaults"],
            type = "header",
            order = 7,
        },
        helmDefault_C = {
            name = L["Hide Helm"],
            type = "toggle",
            order = 8,
            set = function(_,val) 
                    ASHH.db.char.hideHelm = val
                    ASHH.db.char.useCharSettings = true
                end,
            get = function() return ASHH.db.char.hideHelm end
        },
        shoulderDefault_C = {
            name = L["Hide Shoulders"],
            type = "toggle",
            order = 9,
            set = function(_,val) 
                    ASHH.db.char.hideShoulders = val
                    ASHH.db.char.useCharSettings = true
                end,
            get = function() return ASHH.db.char.hideShoulders end
        },
        backDefault_C = {
            name = L["Hide Back"],
            type = "toggle",
            order = 10,
            set = function(_,val) 
                    ASHH.db.char.hideBack = val
                    ASHH.db.char.useCharSettings = true
                end,
            get = function() return ASHH.db.char.hideBack end
        },
        beltDefault_C = {
            name = L["Hide Belt"],
            type = "toggle",
            order = 10,
            set = function(_,val)
                    ASHH.db.char.hideBelt = val
                    ASHH.db.char.useCharSettings = true
                end,
            get = function() return ASHH.db.char.hideBelt end
        },
        resetToDefault = {
            name = L["Use Global"],
            type = "execute",
            order = 11,
            disabled = function() return not ASHH.db.char.useCharSettings end,
            func = "ResetCharOptions" -- Hope this works!
        }
            -- TODO: Way in the future, just add this as a setting to the dressing room to remove any helms tried on "anywhere"
    }
}

function ASHH:HideHelm()
    model:UndressSlot(1)
end

function ASHH:HideShoulders()
    model:UndressSlot(3)
end

function ASHH:HideBack()
    model:UndressSlot(15)
end

function ASHH:HideBelt()
    model:UndressSlot(6)
end

function ASHH:EvalButtons()
    if self.buttons.hideHelm:GetChecked() then self:HideHelm() end
    if self.buttons.hideShoulders:GetChecked() then self:HideShoulders() end
    if self.buttons.hideBack:GetChecked() then self:HideBack() end
    if self.buttons.hideBelt:GetChecked() then self:HideBelt() end
    -- NEVER Refresh here or we'll hit a recursive loop
end

function ASHH:CreateButtons()
    -- Build button, etc
    self.buttons = self.buttons or {}

    self.buttons.hideHelm = self:buildButton_Helm()
    self.buttons.hideShoulders = self:buildButton_Shoulders()
    self.buttons.hideBack = self:buildButton_Back()
    self.buttons.hideBelt = self:buildButton_Belt()
end

function ASHH:buildButton_Helm() 
    local hh = CreateFrame("CheckButton",nil,WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame,"UICheckButtonTemplate")
    hh:SetPoint("TOPLEFT",7,-5)
    hh:SetChecked(self.db.char.hideHelm)
    hh.tooltip = L["Hide Helm"]
    self:SetTexture(hh,"Interface\\Icons\\inv_helmet_03")

    hh:SetScript("OnClick", function(self) 
        if self:GetChecked() then 
            ASHH:HideHelm()
        else
            ASHH:Refresh()
        end
    end)

    hh:SetScript("OnEnter", function() self.SetTooltip(hh) end)
    hh:SetScript("OnLeave", function() self.DropTooltip() end)

    return hh
end

function ASHH:buildButton_Shoulders()
    local hs = CreateFrame("CheckButton",nil,WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame,"UICheckButtonTemplate")
    hs:SetPoint("TOPLEFT",ASHH.buttons.hideHelm,"TOPRIGHT",5,0)
    hs:SetChecked(self.db.char.hideShoulders)
    hs.tooltip = L["Hide Shoulders"]
    self:SetTexture(hs,"Interface\\Icons\\inv_misc_desecrated_clothshoulder")

    hs:SetScript("OnClick", function(self)
        if self:GetChecked() then
            ASHH:HideShoulders()
        else
            ASHH:Refresh()
        end
    end)

    hs:SetScript("OnEnter", function() self.SetTooltip(hs) end)
    hs:SetScript("OnLeave", function() self.DropTooltip() end)

    return hs 
end

function ASHH:buildButton_Back() 
    local hb = CreateFrame("CheckButton",nil,WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame,"UICheckButtonTemplate")
    hb:SetPoint("TOPLEFT",ASHH.buttons.hideShoulders,"TOPRIGHT",5,0)
    hb:SetChecked(self.db.char.hideBack)
    hb.tooltip = L["Hide Back"]
    self:SetTexture(hb,"Interface\\Icons\\inv_misc_cape_20")

    hb:SetScript("OnClick", function(self)
        if self:GetChecked() then 
            ASHH:HideBack()
        else
            ASHH:Refresh()
        end
    end)

    hb:SetScript("OnEnter", function() self.SetTooltip(hb) end)
    hb:SetScript("OnLeave", function() self.DropTooltip() end)

    return hb
end

function ASHH:buildButton_Belt()
    local hw = CreateFrame("CheckButton",nil,WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame,"UICheckButtonTemplate")
    hw:SetPoint("TOPLEFT",ASHH.buttons.hideBack,"TOPRIGHT",5,0)
    hw:SetChecked(self.db.char.hideBelt)
    hw.tooltip = L["Hide Belt"]
    self:SetTexture(hw,"Interface\\Icons\\inv_belt_03")
    hw:SetScript("OnClick", function(self)
        if self:GetChecked() then
            ASHH:HideBelt()
        else
            ASHH:Refresh()
        end
    end)

    hw:SetScript("OnEnter", function() self.SetTooltip(hw) end)
    hw:SetScript("OnLeave", function() self.DropTooltip() end)

    return hw
end

function ASHH:SetTexture(button,path)
    button:SetHeight(28)
    button:SetWidth(28)

    local texture = button:GetCheckedTexture()
    texture:SetTexture(path)
    texture:SetVertexColor(0.2,0.2,0.2,1)

    texture = button:GetNormalTexture()
    texture:SetTexture(path)
    texture:SetVertexColor(1,1,1,1)

    texture = button:GetHighlightTexture()
    texture:SetTexture(path)
    texture:SetVertexColor(1,1,1,0.5)

    texture = button:GetPushedTexture()
    texture:SetTexture(path)
    texture:SetVertexColor(1,1,1,0.5)
end

function ASHH:Refresh()
    setsFrame:SelectSet(setsFrame:GetSelectedSetID())
    -- TODO: Re-equipping an item is a bit jittery (Shoulder particle effects will reset and it's jarring). Fix this.
end

function ASHH:HookRefresh()
    hooksecurefunc(setsFrame,"Refresh",function()
        ASHH:EvalButtons()
    end)
end

function ASHH:OnInitialize()
    ASHH:InitOps()
    --self.db = LibStub("AceDB-3.0"):New("ASHHDB",defaultOptions,true)
    --self:SetupOptions()
    --LibStub("AceConfig-3.0"):RegisterOptionsTable(AddOn_Name,optionsTable,nil)
    --self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOn_Name,friendlyName,nil)

    if not IsAddOnLoaded("Blizzard_Collections") then 
        self:RegisterEvent("ADDON_LOADED", function (self, addon, ...)
            if addon == "Blizzard_Collections" then
                ASHH:CollectionsInit()
                ASHH:UnregisterEvent("ADDON_LOADED")
            end
        end)
    else 
        ASHH:CollectionsInit()
    end

    self:RegisterChatCommand("ashh",function()
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame);
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame);
    end)
end

function ASHH:CollectionsInit()
    setsFrame = WardrobeCollectionFrame.SetsCollectionFrame
    model = setsFrame.Model
    self:CreateButtons()
    self:HookRefresh()
end

function ASHH:OnEnable() end
function ASHH:OnDisable() end

function ASHH:SetupOptions_off()
    -- if usecharsettings false, then use global settings
    if self.db.char.useCharSettings ~= true then 
        self.db.char.hideHelm = self.db.global.hideHelm
        self.db.char.hideShoulders = self.db.global.hideShoulders
        self.db.char.hideBack = self.db.global.hideBack
        self.db.char.hideBelt = self.db.global.hideBelt
    end
end

function ASHH:ResetOptions_off() 
    self.db:ResetDB(defaultOptions)
end

function ASHH:ResetCharOptions_off()
    self.db.char.hideHelm = self.db.global.hideHelm 
    self.db.char.hideShoulders = self.db.global.hideShoulders
    self.db.char.hideBack = self.db.global.hideBack
    self.db.char.hideBelt = self.db.global.hideBelt
    self.db.char.useCharSettings = false
end

function ASHH.SetTooltip(btn)
    GameTooltip:SetOwner(btn,"ANCHOR_RIGHT")
    GameTooltip:SetText(btn.tooltip,nil,nil,nil,nil,true)
    GameTooltip:Show()
end 

function ASHH.DropTooltip() 
    GameTooltip:Hide()
end