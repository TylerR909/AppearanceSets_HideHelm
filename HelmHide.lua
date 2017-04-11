local AddOn_Name, ns = ...
local OnUpdate_Buffer = 0.05
local friendlyName = GetAddOnMetadata(AddOn_Name,"Title")

-- TODO: Pull variant table option into its own row?
-- TODO: Clean up . : notation
-- TODO: Clean up ASHH v self
-- TODO: Icons per armor class(cloth, leather, mail, plate)

ASHH = LibStub("AceAddon-3.0"):NewAddon(AddOn_Name,"AceEvent-3.0","AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(AddOn_Name,true)

local defaultOptions = {
    global = {
        hideHelm = true,
        hideShoulders = false,
        hideBack = false,
        hideBelt = false,
        expandVariants = true
    },
    char = {
        hideHelm = true,
        hideShoulders = false,
        hideBack = false,
        hideBelt = false,
        useCharSettings = false
    }
}

local optionsTable = {
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

function ASHH:HideBelt()
    WardrobeCollectionFrame.SetsCollectionFrame.Model:UndressSlot(6)
end

function ASHH:EvalButtons()
    if ASHH.buttons.hideHelm:GetChecked() then ASHH:HideHelm() end
    if ASHH.buttons.hideShoulders:GetChecked() then ASHH:HideShoulders() end
    if ASHH.buttons.hideBack:GetChecked() then ASHH:HideBack() end
    if ASHH.buttons.hideBelt:GetChecked() then ASHH:HideBelt() end
end


function ASHH:CreateButtons()
    -- Build button, etc
    ASHH.buttons = ASHH.buttons or {}

    ASHH.buttons.hideHelm = ASHH:buildButton_Helm()
    ASHH.buttons.hideShoulders = ASHH:buildButton_Shoulders()
    ASHH.buttons.hideBack = ASHH:buildButton_Back()
    ASHH.buttons.hideBelt = ASHH:buildButton_Belt()
end

function ASHH:buildButton_Helm() 
    local hh = CreateFrame("CheckButton",nil,WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame,"UICheckButtonTemplate")
    hh:SetPoint("TOPLEFT",7,-5)
    hh:SetChecked(self.db.char.hideHelm)
    hh.tooltip = L["Hide Helm"]
    ASHH:SetTexture(hh,"Interface\\Icons\\inv_helmet_03")
    -- hh:SetNormalTexture("Interface\\Icons\\inv_helmet_03")
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

    return hh
end

function ASHH:buildButton_Shoulders()
    local hs = CreateFrame("CheckButton",nil,WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame,"UICheckButtonTemplate")
    hs:SetPoint("TOPLEFT",ASHH.buttons.hideHelm,"TOPRIGHT",5,0)
    hs:SetChecked(self.db.char.hideShoulders)
    hs.tooltip = L["Hide Shoulders"]
    ASHH:SetTexture(hs,"Interface\\Icons\\inv_misc_desecrated_clothshoulder")

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

    return hs 
end

function ASHH:buildButton_Back() 
    local hb = CreateFrame("CheckButton",nil,WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame,"UICheckButtonTemplate")
    hb:SetPoint("TOPLEFT",ASHH.buttons.hideShoulders,"TOPRIGHT",5,0)
    hb:SetChecked(self.db.char.hideBack)
    hb.tooltip = L["Hide Back"]
    ASHH:SetTexture(hb,"Interface\\Icons\\inv_misc_cape_20")
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

    return hb
end

function ASHH:buildButton_Belt()
    local hw = CreateFrame("CheckButton",nil,WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame,"UICheckButtonTemplate")
    hw:SetPoint("TOPLEFT",ASHH.buttons.hideBack,"TOPRIGHT",5,0)
    hw:SetChecked(self.db.char.hideBelt)
    hw.tooltip = L["Hide Belt"]
    ASHH:SetTexture(hw,"Interface\\Icons\\inv_belt_03")
    hw:SetScript("OnClick", function(self,button,down)
        if self:GetChecked() then
            ASHH:HideBelt()
        else
            if ASHH.lastClicked then
                ASHH.lastClicked:Click()
            end
        end
    end)

    hw:SetScript("OnEnter", function() ASHH.SetTooltip(hw) end)
    hw:SetScript("OnLeave", function() ASHH.DropTooltip() end)

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

function ASHH:HookScripts()
    ASHH:HookSetButtons()
    ASHH:HookModel()
    ASHH:HookVariants()
end

function ASHH:HookSetButtons()
    --Hook to Set Buttons
    local btn_h = "WardrobeCollectionFrameScrollFrameButton"
    local count = 1
    local btn = _G["WardrobeCollectionFrameScrollFrameButton"..count]

    while btn do
        btn:HookScript("OnClick", function(self, button)
            ASHH:EvalButtons()
            ASHH.lastClicked = self;
        end)

        count = count + 1
        btn = _G["WardrobeCollectionFrameScrollFrameButton"..count]
    end

end

function ASHH:HookModel()
    -- Hook to Model Frame
    -- When model is shown (Window open, tab opened, etc) evaluate buttons (after a buffer period) 
    WardrobeCollectionFrame.SetsCollectionFrame.Model:HookScript("OnShow",function(self)
        local elap = 0

        ASHH.buttons.hideHelm:SetScript("OnUpdate",function (self, elapsed)
            elap = elap + elapsed
            if elap > OnUpdate_Buffer then
                ASHH:EvalButtons()
                self:SetScript("OnUpdate",nil)
            end
        end)
    end)

end

function ASHH:HookVariants() 
    -- WardrobeCollectionFrame.SetsCollectionFrame.Model:HookScript("OnUpdateModel")
    if not ASHH.buffers then ASHH.buffers = {} end
    ASHH.buffers.Model = 0

    -- Future: If I hide the Variant button to generate my own, this will break
    WardrobeSetsCollectionVariantSetsButton:HookScript("OnUpdate",function(dropdown,elapsed)
        ASHH.buffers.Model = ASHH.buffers.Model + elapsed
        if (ASHH.buffers.Model > OnUpdate_Buffer) then
            ASHH:EvalButtons()
            ASHH.buffers.Model = 0
        end
    end)
end

function ASHH:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ASHHDB",defaultOptions,true)
    ASHH:SetupOptions()
    LibStub("AceConfig-3.0"):RegisterOptionsTable(AddOn_Name,optionsTable,nil)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOn_Name,friendlyName,nil)

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
        self.db.char.hideBelt = self.db.global.hideBelt
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