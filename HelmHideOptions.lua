local AddOn_Name, ns = ...
local friendlyName = GetAddOnMetadata(AddOn_Name,"Title")

local L = LibStub("AceLocale-3.0"):GetLocale(AddOn_Name,true)

local defaultOptions = {
    global = {
        [GetInventorySlotInfo("HEADSLOT")] = true,
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
        charHeader = {
            name = L["Character Defaults"],
            type = "header",
            order = 7,
        },
        resetToDefault = {
            name = L["Use Global"],
            type = "execute",
            order = 11,
            disabled = function() return not ASHH.db.char.useCharSettings end,
            func = "ResetCharOptions" -- Hope this works!
        },
        removeOptionsHeader = {
            name = L["Remove Options"],
            type = "header",
            order = 12,
        },
        removeOptionsMessage = {
            type = "description",
            name = L["RemoveOptionsMsg"],
            order = 12
        },
    }
}

function ASHH:GenerateOptionsTable()
    for slotKey, slotId, slotName in ASHH:WalkHideable() do
        optionsTable.args[slotName.."Default_G"] = {
            name = "Hide "..slotName,
            type = "toggle",
            order = 3,
            set = function(_,val)
                    ASHH.db.global[slotId] = val

                    if not ASHH.db.char.useCharSettings then
                        ASHH.db.char[slotId] = val
                    end
                end,
            get = function() return ASHH.db.global[slotId] end
        }
        optionsTable.args[slotName.."Default_C"] = {
            name = "Hide "..slotName,
            type = "toggle",
            order = 8,
            set = function(_,val)
                    ASHH.db.char[slotId] = val
                    ASHH.db.char.useCharSettings = true
                end,
            get = function() return ASHH.db.char[slotId] end
        }
        optionsTable.args[slotName.."RemoveOption"] = {
            name = "Remove "..slotName,
            type = "toggle",
            order = 13,
            set = function(_,val)
                    ASHH.db.global["Remove"..slotName] = val
                    ASHH:DropButtons()
                    ASHH:CreateButtons()
                end,
            get = function() return ASHH.db.global["Remove"..slotName] end
        }
    end

    return optionsTable
end

function ASHH:InitOps()
    self.db = LibStub("AceDB-3.0"):New("ASHHDB",defaultOptions,true)
    local optionsTable = self:GenerateOptionsTable()
    self:SetupOptions()
    LibStub("AceConfig-3.0"):RegisterOptionsTable(AddOn_Name,optionsTable,nil)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOn_Name,friendlyName,nil)
end

function ASHH:SetupOptions()
    -- if usecharsettings false, then use global settings
    if self.db.char.useCharSettings ~= true then 
        for _, slotId in ASHH:WalkHideable() do
            self.db.char[slotId] = self.db.global[slotId]
        end
    end
end

function ASHH:ResetOptions() 
    self.db:ResetDB(defaultOptions)
end

function ASHH:ResetCharOptions()
    self.db.char.useCharSettings = false
    ASHH:SetupOptions()
end