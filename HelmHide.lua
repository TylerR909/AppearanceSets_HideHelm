local AddOn_Name, ns = ...
local elap_buffer = 0.05

ASHH = LibStub("AceAddon-3.0"):NewAddon(AddOn_Name,"AceEvent-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(AddOn_Name,true)

local defaultOptions = {
    global = {
        hideHelm = true,
        hideShoulders = false,
        hideBack = false
    },
    char = {
        hideHelm = true,
        hideShoulders = false,
        hideBack = false
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
            hidden = true,
            set = function(self, val) end,
            get = function(self) return end
        },
        helmDefault = {
            name = "Hide Helm Default",
            desc = "Hide helm by default?",
            type = 'toggle',
            order = 0,
            set = function(self, val) ASHH.db.char.hideHelm = self:GetChecked() end, -- do something?
            get = function(self) return ASHH.db.char.hideHelm end -- return something here
        },
        shoulderDefault = {
            name = "Shoulder Hide Default",
            desc = "Hide shoulder by default?",
            type = 'toggle',
            set = function(self, val) ASHH.db.char.hideShoulder = self:GetChecked() end,
            get = function(self) return ASHH.db.char.hideShoulder end
        },
        backDefault = {
            name = "Back Hide Default",
            desc = "Hide back by default?",
            type = 'toggle',
            set = function(self, val) ASHH.db.char.hideBack = self:GetChecked() end,
            get = function(self) return ASHH.db.char.hideBack end
        },
        expandVariants = {
            name = "Expand Variants",
            desc = "Expand variants from dropdown to buttons?",
            type = 'toggle',
            set = function(info, val) end, -- definitely do something 
            get = function(info) end
        }
            -- TODO: Differentiate between global setting and per-character setting. Some toons may actually like helms.
            -- TODO: Add shoulders because people hate those too I guess -_-
            -- TODO: Way in the future, just add this as a setting to the dressing room to remove any helms tried on "anywhere"
    }
}


-- event: TRANSMOG_COLLECTION_UPDATED
-- event: TRANSMOG_SEARCH_UPDATED
-- frame: CollectionsJournal -> WardrobeCollectionFrame
-- WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame

--[[
local chk = CreateFrame("CheckButton","ASHH_Check",WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame,"UICheckButtonTemplate")
chk:SetPoint("TOPLEFT",10,-5);
chk:SetText("Hide Helm");
chk.tooltip = "Hide helm from apperance sets viewer."
chk:SetScript("OnClick",
   function()
      self:Hide();
   end
);

chk:Show() --]]

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

    local hh = CreateFrame("CheckButton",nil,WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame,"UICheckButtonTemplate")
    hh:SetPoint("TOPLEFT",5,0)
    hh:SetChecked(self.db.char.hideHelm) -- TODO: Default
    hh:SetText("Hide Helm")
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

    hh:SetScript("OnShow", function(self)
        if self:GetChecked() then
            ASHH:HideHelm()
        end
    end)


    ASHH.buttons.hideHelm = hh
end

function ASHH:HookScripts()
    --Hook to Set Buttons
    local btn_h = "WardrobeCollectionFrameScrollFrameButton"
    local count = 1
    local keepGoing = true
    local hh = ASHH.buttons.hideHelm

    local btn = _G["WardrobeCollectionFrameScrollFrameButton"..count]

    if not btn then keepGoing = false end

    while keepGoing do
        btn:HookScript("OnClick", function(self, button)
            if hh:GetChecked() then
                ASHH:HideHelm()
            end
            ASHH.lastClicked = self;
        end)

        count = count + 1
        btn = _G["WardrobeCollectionFrameScrollFrameButton"..count]
        if not btn then keepGoing = false end
    end

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
            end
        end)
        --register ASHH.buttons.hideHelm for onUpdate
    end)
end

function ASHH:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ASHHDB",defaultOptions,true)
    -- LibStub("AceConfig-3.0"):RegisterOptionsTable(AddOn_Name,defaultOptions) -- options is wrong?
    -- self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOn_Name,AddOn_Name)
    self:RegisterEvent("ADDON_LOADED", function (self, addon, ...)
        if addon == "Blizzard_Collections" then
            ASHH:CreateButtons()
            ASHH:UnregisterEvent("ADDON_LOADED")
            ASHH:HookScripts()
        end
    end)

    -- self:RegisterEvent("TRANSMOG_COLLECTION_ITEM_UPDATE",function (self, ...) print (...) end)
    -- Start looking for variants?
end

function ASHH:OnEnable()
    -- Attach checkbox
    -- Start looking to convert variants
end

function ASHH:OnDisable()
    -- Disable checkbox
    -- Stop looking for variants
end
