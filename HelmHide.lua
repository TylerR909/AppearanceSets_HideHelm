local AddOn_Name, ns = ...

-- TODO: Pull variant table option into its own row?
-- TODO: Clean up . : notation
-- TODO: Icons per armor class(cloth, leather, mail, plate)
-- Keepsake: https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/AddOns/Blizzard_Collections/Blizzard_Wardrobe.lua

ASHH = LibStub("AceAddon-3.0"):NewAddon(AddOn_Name,"AceEvent-3.0","AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(AddOn_Name,true)
local model, setsFrame

ASHH.hideable = {
    { name = "HEADSLOT", texture = "Interface\\Icons\\inv_helmet_03"},
    { name = "SHOULDERSLOT", texture = "Interface\\Icons\\inv_misc_desecrated_clothshoulder"},
    { name = "CHESTSLOT", texture = 132631},
    { name = "WAISTSLOT", texture = "Interface\\Icons\\inv_belt_03"},
    { name = "FEETSLOT", texture = 132539 },
    { name = "WRISTSLOT", texture = 132606 },
    { name = "HANDSSLOT", texture = 132955 },
    { name = "BACKSLOT", texture = "Interface\\Icons\\inv_misc_cape_20"},
}

function ASHH:WalkHideable()
    local index = 1
    local function iter(table)
        local v = table[index]
        if not v then return end

        local slotKey = v.name or v
        local slotId, defaultTexture = GetInventorySlotInfo(slotKey)
        local slotName = _G[slotKey]
        local texture = v.texture or defaultTexture

        index = index + 1

        return slotKey, slotId, slotName, texture
    end
    return iter,self.hideable
end

function ASHH:EvalButtons()
    for _,v in pairs(self.buttons) do
        if v:GetChecked() then v.hideFunc() end
    end
    -- NEVER Refresh here or we'll hit a recursive loop
end

---------------------------------------------------------------
---------------------------- Init -----------------------------
---------------------------------------------------------------

function ASHH:OnInitialize()
    ASHH:InitOps()

    self:RegisterChatCommand("ashh",function()
        -- 2 calls to solve a bug where 1 call isn't opening it to the right frame
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame);
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame);
    end)

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
end

function ASHH:CollectionsInit()
    setsFrame = WardrobeCollectionFrame.SetsCollectionFrame
    model = setsFrame.Model
    self:CreateButtons()
    self:HookRefresh()
end

function ASHH:HookRefresh()
    hooksecurefunc(setsFrame,"Refresh",function()
        ASHH:EvalButtons()
    end)
end

---------------------------------------------------------------
------------------ Building the CheckButtons ------------------
---------------------------------------------------------------

function ASHH:CreateButtons()
    self.buttons = self.buttons or {}

    local previousButton = nil;
    for slotKey, slotId, slotName, texture in ASHH:WalkHideable() do
        previousButton = self:buildButton(
            previousButton,
            self.db.char[slotId],
            slotName,
            texture,
            function() model:UndressSlot(slotId) end
        )

        self.buttons[slotId] = previousButton;
    end
end

function ASHH:buildButton(attachTo,checkVal,slotName,texturePath,hideFunc)
    local btn = CreateFrame("CheckButton","ASHHCheckButton_"..slotName,setsFrame.DetailsFrame,"UICheckButtonTemplate")
    btn:SetChecked(checkVal)
    btn.tooltip = "Hide "..slotName
    btn.hideFunc = hideFunc
    self.SetTexture(btn,texturePath)

    if not attachTo then 
        btn:SetPoint("topleft",7,-5)
    else 
        btn:SetPoint("TOPLEFT",attachTo,"TOPRIGHT",5,0)
    end

    btn:SetScript("OnClick", function(self) 
        if self:GetChecked() then 
            self.hideFunc()
        else
            ASHH.Refresh()
        end
    end)

    btn:SetScript("OnEnter", function() self.SetTooltip(btn) end)
    btn:SetScript("OnLeave", function() self.DropTooltip() end)

    return btn
end

function ASHH.SetTexture(button,path)
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

function ASHH.SetTooltip(btn)
    GameTooltip:SetOwner(btn,"ANCHOR_RIGHT")
    GameTooltip:SetText(btn.tooltip,nil,nil,nil,nil,true)
    GameTooltip:Show()
end 

function ASHH.DropTooltip() 
    GameTooltip:Hide()
end

---------------------------------------------------------------
---------------- Couple Extra Lib Functions -------------------
---------------------------------------------------------------

function ASHH.Refresh()
    setsFrame:Refresh()
    -- setsFrame:SelectSet(setsFrame:GetSelectedSetID())
    -- TODO: Re-equipping an item is a bit jittery (Shoulder particle effects will reset and it's jarring). Fix this.
end

---------------------------------------------------------------
------------------- Vestigial Ace Stuff -----------------------
---------------------------------------------------------------

function ASHH:OnEnable() end
function ASHH:OnDisable() end