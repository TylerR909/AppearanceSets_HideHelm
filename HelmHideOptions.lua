local AddOn_Name, ns = ...
local friendlyName = GetAddOnMetadata(AddOn_Name,"Title")

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

function ASHH:InitOps()
    self.db = LibStub("AceDB-3.0"):New("ASHHDB",defaultOptions,true)
    self:SetupOptions()
    LibStub("AceConfig-3.0"):RegisterOptionsTable(AddOn_Name,optionsTable,nil)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOn_Name,friendlyName,nil)
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
    self.db.char.hideHelm = self.db.global.hideHelm 
    self.db.char.hideShoulders = self.db.global.hideShoulders
    self.db.char.hideBack = self.db.global.hideBack
    self.db.char.hideBelt = self.db.global.hideBelt
    self.db.char.useCharSettings = false
end