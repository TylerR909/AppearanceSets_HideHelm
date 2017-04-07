local AddOn_Name, ns = ...
local elap_buffer = 0.05

ASHH = LibStub("AceAddon-3.0"):NewAddon(AddOn_Name,"AceEvent-3.0","AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(AddOn_Name,true)

local defaultOptions = {
    global = {
        hideHelm = true,
        hideShoulders = false,
        hideBack = false,
        expandVariants = true
    },
    char = {
        hideHelm = true,
        hideShoulders = false,
        hideBack = false,
        useCharSettings = false
    }
}

local optionsTable = {
    name = AddOn_Name,
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
        globalHeader = {
            name = "Global Settings",
            type = "header",
            order = 2
        },
        helmDefault_G = {
            name = "Hide Helm",
            type = "toggle",
            order = 3,
            set = function(_, val) ASHH.db.global.hideHelm = val end,
            get = function() return ASHH.db.global.hideHelm end
        },
        shoulderDefault_G = {
            name = "Hide Shoulders",
            type = "toggle",
            order = 4,
            set = function(_,val) ASHH.db.global.hideShoulders = val end,
            get = function() return ASHH.db.global.hideShoulders end
        },
        backDefault_G = {
            name = "Hide Back",
            type = "toggle",
            order = 5,
            set = function(_,val) ASHH.db.global.hideBack = val end,
            get = function() return ASHH.db.global.hideBack end
        },
        expandVariants_G = {
            name = "Expand Variants",
            type = "toggle",
            order = 6,
            desc = "Coming soon!",
            descStyle = "inline",
            disabled = true,
            set = function(_,val) ASHH.db.global.expandVariants = val end,
            get = function() return ASHH.db.global.expandVariants end
        },
        charHeader = {
            name = "Character Settings",
            type = "header",
            order = 7,
        },
        helmDefault_C = {
            name = "Hide Helm",
            type = "toggle",
            order = 8,
            set = function(_,val) 
                ASHH.db.char.hideHelm = val
                ASHH.db.char.useCharSettings = true
            end,
            get = function() return ASHH.db.char.hideHelm end
        },
        shoulderDefault_C = {
            name = "Hide Shoulders",
            type = "toggle",
            order = 9,
            set = function(_,val) 
                ASHH.db.char.hideShoulders = val
                ASHH.db.char.useCharSettings = true
            end,
            get = function() return ASHH.db.char.hideShoulders end
        },
        backDefault_C = {
            name = "Hide Back",
            type = "toggle",
            order = 10,
            set = function(_,val) 
                    ASHH.db.char.hideBack = val
                    ASHH.db.char.useCharSettings = true
                end,
            get = function() return ASHH.db.char.hideBack end
        },
        resetToDefault = {
            name = "Use Default",
            type = "execute",
            order = 11,
            hidden = function() return not ASHH.db.char.useCharSettings end,
            func = "ResetCharOptions" -- Hope this works!
        }
            -- TODO: Way in the future, just add this as a setting to the dressing room to remove any helms tried on "anywhere"
    }
}


-- event: TRANSMOG_COLLECTION_UPDATED
-- event: TRANSMOG_SEARCH_UPDATED
-- frame: CollectionsJournal -> WardrobeCollectionFrame
-- WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame

function ASHH:HideHelm() 
    WardrobeCollectionFrame.SetsCollectionFrame.Model:UndressSlot(1)
end

function ASHH:HideShoulders()
    WardrobeCollectionFrame.SetsCollectionFrame.Model:UndressSlot(3)
end

function ASHH:HideBack()
    WardrobeCollectionFrame.SetsCollectionFrame.Model:UndressSlot(15)
end

function ASHH:CreateButtons()
    -- Build button, etc
    ASHH.buttons = ASHH.buttons or {}

    ASHH.buttons.hideHelm = ASHH:buildButton_Helm()
    ASHH.buttons.hideShoulders = ASHH:buildButton_Shoulders()
    ASHH.buttons.hideBack = ASHH:buildButton_Back()
end

function ASHH:buildButton_Helm() 
    local hh = CreateFrame("CheckButton",nil,WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame,"UICheckButtonTemplate")
    hh:SetPoint("TOPLEFT",5,0)
    hh:SetChecked(self.db.char.hideHelm) -- TODO: Default
    hh.tooltip = "Hides the helm when you load a new set"
    -- TODO: Click works, but Arrow Keys to select fails to trigger
    hh:SetScript("OnClick", function(self,button,down) 
        if self:GetChecked() then 
            ASHH:HideHelm()
        else 
            if ASHH.lastClicked then
                ASHH.lastClicked:Click() -- Not working as intended
            end
        end
    end)

    hh:SetScript("OnEnter", function() ASHH.SetTooltip(hh) end)
    hh:SetScript("OnLeave", function() ASHH.DropTooltip() end)
--[[
    hh:SetScript("OnShow", function(self)
        -- When the collections frame is re-opened
        if self:GetChecked() then -- Redundant with model:OnShow()
            ASHH:HideHelm()
        end
    end)
--]]
    return hh
end

function ASHH:buildButton_Shoulders()
    local hs = CreateFrame("CheckButton",nil,WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame,"UICheckButtonTemplate")
    hs:SetPoint("TOPLEFT",ASHH.buttons.hideHelm,"TOPRIGHT",5,0)
    hs:SetChecked(self.db.char.hideShoulders)
    hs.tooltip = "Hide shoulders when you load a new set"

    hs:SetScript("OnClick", function(self)
        if self:GetChecked() then
            ASHH:HideShoulders()
        else
            if ASHH.lastClicked then 
                ASHH.lastClicked:Click() 
            end
        end
    end)

    hs:SetScript("OnEnter", function() ASHH.SetTooltip(hs) end)
    hs:SetScript("OnLeave", function() ASHH.DropTooltip() end)

--[[
    hs:SetScript("OnShow",function(self)
        if self:GetChecked() then 
            ASHH:HideShoulders()
        end
    end)
--]]
    return hs 
end

function ASHH:buildButton_Back() 
    local hb = CreateFrame("CheckButton",nil,WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame,"UICheckButtonTemplate")
    hb:SetPoint("TOPLEFT",ASHH.buttons.hideShoulders,"TOPRIGHT",5,0)
    hb:SetChecked(self.db.char.hideBack)
    hb:SetText("Hide Back")
    hb.tooltip = "Hides the back/cape when you load a new set"
    -- TODO: Click works, but Arrow Keys to select fails to trigger
    hb:SetScript("OnClick", function(self,button,down) 
        if self:GetChecked() then 
            ASHH:HideBack()
        else 
            if ASHH.lastClicked then
                ASHH.lastClicked:Click() -- Not working as intended
            end
        end
    end)

    hb:SetScript("OnEnter", function() ASHH.SetTooltip(hb) end)
    hb:SetScript("OnLeave", function() ASHH.DropTooltip() end)

--[[
    hb:SetScript("OnShow", function(self)
        -- When the collections frame is re-opened
        if self:GetChecked() then -- Redundant with model:OnShow()
            ASHH:HideBack()
        end
    end)
--]]
    return hb
end

function ASHH:HookScripts()
    ASHH:HookSetButtons()
    ASHH:HookModel()
end

function ASHH:HookSetButtons()
    --Hook to Set Buttons
    local btn_h = "WardrobeCollectionFrameScrollFrameButton"
    local count = 1
    local hh = ASHH.buttons.hideHelm
    local hs = ASHH.buttons.hideShoulders 
    local hb = ASHH.buttons.hideBack 

    local btn = _G["WardrobeCollectionFrameScrollFrameButton"..count]

    while btn do
        btn:HookScript("OnClick", function(self, button)
            if hh:GetChecked() then ASHH:HideHelm() end
            if hs:GetChecked() then ASHH:HideShoulders() end 
            if hb:GetChecked() then ASHH:HideBack() end 
            ASHH.lastClicked = self;
        end)

        count = count + 1
        btn = _G["WardrobeCollectionFrameScrollFrameButton"..count]
    end

end

function ASHH:HookModel()
   -- Hook to Model Frame
    WardrobeCollectionFrame.SetsCollectionFrame.Model:HookScript("OnShow",function(self)
        local elap = 0

        ASHH.buttons.hideHelm:SetScript("OnUpdate",function (self, elapsed)
            elap = elap + elapsed
            if elap > elap_buffer then
                if ASHH.buttons.hideHelm:GetChecked() then
                    ASHH:HideHelm()
                    self:SetScript("OnUpdate",nil)
                end
                if ASHH.buttons.hideShoulders:GetChecked() then 
                    ASHH:HideShoulders()
                    self:SetScript("OnUpdate",nil)
                end 
                if ASHH.buttons.hideBack:GetChecked() then 
                    ASHH:HideBack() 
                    self:SetScript("OnUpdate",nil)
                end
            end
        end)
    end)
end

function ASHH:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ASHHDB",defaultOptions,true)
    ASHH:SetupOptions()
    LibStub("AceConfig-3.0"):RegisterOptionsTable(AddOn_Name,optionsTable,nil)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOn_Name,AddOn_Name,nil)

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

    ASHH:RegisterChatCommand("ashh",function()
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame);
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame);
    end)


    -- self:RegisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE",function (self, ...) print (...) end)
    -- Start looking for variants?
end

function ASHH:CollectionsInit()
    ASHH:CreateButtons()
    ASHH:HookScripts()
end

function ASHH:OnEnable()
    -- Attach checkbox
    -- Start looking to convert variants
end

function ASHH:OnDisable()
    -- Disable checkbox
    -- Stop looking for variants
end

function ASHH:SetupOptions()
    -- if usecharsettings false, then use global settings
    if self.db.char.useCharSettings ~= true then 
        self.db.char.hideHelm = self.db.global.hideHelm
        self.db.char.hideShoulders = self.db.global.hideShoulders
        self.db.char.hideBack = self.db.global.hideBack
    end
end

function ASHH:ResetOptions() 
    self.db:ResetDB(defaultOptions)
end

function ASHH:ResetCharOptions()
    -- self may be wrong. Could switch to ASHH.*
    self.db.char.hideHelm = self.db.global.hideHelm 
    self.db.char.hideShoulders = self.db.global.hideShoulders
    self.db.char.hideBack = self.db.global.hideBack
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