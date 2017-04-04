local addon_name, ns = ...
ASSH = LibStuc("AceAddon-3.0"):NewAddon(addon_name)
local L = LibStub("AceLocale-3.0"):GetLocale("MyAddon",true)
local defaultOptions = {
    name = addon_name,
    handler = ASSH,
    type = "group",
    args = {
        enable = {
            name = "Enable",
            desc = "Enables/Disables the addon",
            type = "toggle",
            set = function(info, val) MyAddon.enable end,
            get = function(info) return MyAddon.enabled end
        }
        moreOptions = {
            name = "More options",
            type = "group",
            args = {
                helmDefault = {
                    name = "Hide Helm Default",
                    desc = "Hide helm by default?",
                    type = "toggle",
                    set = function(info, val) end; -- do something?
                    get = function(info) end -- return something here
                }
                expandVariants = {
                    name = "Expand Variants",
                    desc = "Expand variants from dropdown to buttons?"
                    type = "toggle",
                    set = function(info, val) end; -- definitely do something 
                    get = function(info) end
                }
                -- TODO: Differentiate between global setting and per-character setting. Some toons may actually like helms.
                -- TODO: Add shoulders because people hate those too I guess -_-
                -- TODO: Way in the future, just add this as a setting to the dressing room to remove any helms tried on "anywhere"
            }
        }
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

function ASSH:HideHelm() 
    WardrobeCollectionFrame.SetsCollectionFrame.Model:UndressSlot(1)
end

function ASSH:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ASHHDB",defaultOptions)
    -- Build CheckButton
    -- Start looking for variants?
end

function ASSH:OnEnable()
    -- Attach checkbox
    -- Start looking to convert variants
end

function ASSH:OnDisable()
    -- Disable checkbox
    -- Stop looking for variants
end
