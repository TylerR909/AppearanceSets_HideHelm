local AddOn_Name, ns = ...

ASHH = LibStub("AceAddon-3.0"):NewAddon(AddOn_Name,"AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(AddOn_Name,true)

local defaultOptions = {
    name = AddOn_Name,
    handler = ASHH,
    type = 'group',
    args = {
        enable = {
            name = "Enable",
            desc = "Enables/Disables the addon",
            type = 'toggle',
            hidden = true,
            set = function(info, val) end,
            get = function(info) return end
        },
        helmDefault = {
            name = "Hide Helm Default",
            desc = "Hide helm by default?",
            type = 'toggle',
            order = 0,
            set = function(info, val) end, -- do something?
            get = function(info) end -- return something here
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

function ASHH:HookButtons()
    -- Build button, etc
end

function ASHH:OnInitialize()
    -- self.db = LibStub("AceDB-3.0"):New("ASHHDB")
    -- LibStub("AceConfig-3.0"):RegisterOptionsTable(AddOn_Name,defaultOptions) -- options is wrong?
    -- self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOn_Name,AddOn_Name)
    self:RegisterEvent("ADDON_LOADED", function (self, addon, ...)
        if addon == "Blizzard_Collections" then
            ASHH:HookButtons()
            ASHH:UnregisterEvent("ADDON_LOADED")
        end
    end)
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
