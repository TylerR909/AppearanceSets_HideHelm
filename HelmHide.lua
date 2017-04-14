local AddOn_Name, ns = ...
local friendlyName = GetAddOnMetadata(AddOn_Name,"Title")

-- TODO: Pull variant table option into its own row?
-- TODO: Clean up . : notation
-- TODO: Icons per armor class(cloth, leather, mail, plate)
-- Keepsake: https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/AddOns/Blizzard_Collections/Blizzard_Wardrobe.lua

ASHH = LibStub("AceAddon-3.0"):NewAddon(AddOn_Name,"AceEvent-3.0","AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(AddOn_Name,true)
local model, setsFrame

---------------------------------------------------------------
----------------- The Stars of This Show ----------------------
---------------------------------------------------------------

function ASHH.HideHelm() model:UndressSlot(1) end
function ASHH.HideShoulders() model:UndressSlot(3) end
function ASHH.HideBack() model:UndressSlot(15) end
function ASHH.HideBelt() model:UndressSlot(6) end

function ASHH:EvalButtons()
    if self.buttons.hideHelm:GetChecked() then self:HideHelm() end
    if self.buttons.hideShoulders:GetChecked() then self:HideShoulders() end
    if self.buttons.hideBack:GetChecked() then self:HideBack() end
    if self.buttons.hideBelt:GetChecked() then self:HideBelt() end
    -- NEVER Refresh here or we'll hit a recursive loop
end

---------------------------------------------------------------
---------------------------- Init -----------------------------
---------------------------------------------------------------

function ASHH:OnInitialize()
    ASHH:InitOps()

    self:RegisterChatCommand("ashh",function()
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
    -- Build button, etc
    self.buttons = self.buttons or {}

    self.buttons.hideHelm = self:buildButton(nil,self.db.char.hideHelm,L["Hide Helm"],"Interface\\Icons\\inv_helmet_03",ASHH.HideHelm)
    self.buttons.hideShoulders = self:buildButton(self.buttons.hideHelm,self.db.char.hideShoulders,L["Hide Shoulders"],"Interface\\Icons\\inv_misc_desecrated_clothshoulder",ASHH.HideShoulders)
    self.buttons.hideBack = self:buildButton(self.buttons.hideShoulders,self.db.char.hideBack,L["Hide Back"],"Interface\\Icons\\inv_misc_cape_20",ASHH.HideBack)
    self.buttons.hideBelt = self:buildButton(self.buttons.hideBack,self.db.char.hideBelt,L["Hide Belt"],"Interface\\Icons\\inv_belt_03",ASHH.HideBelt)
end

function ASHH:buildButton(attachTo,checkVal,tooltip,texturePath,hideFunc)
    local btn = CreateFrame("CheckButton",nil,WardrobeCollectionFrame.SetsCollectionFrame.DetailsFrame,"UICheckButtonTemplate")

    if not attachTo then 
        btn:SetPoint("topleft",7,-5)
    else 
        btn:SetPoint("TOPLEFT",attachTo,"TOPRIGHT",5,0)
    end

    btn:SetChecked(checkVal)
    btn.tooltip = tooltip
    self:SetTexture(btn,texturePath)

    btn:SetScript("OnClick", function(self) 
        if self:GetChecked() then 
            hideFunc()
        else
            ASHH:Refresh()
        end
    end)

    btn:SetScript("OnEnter", function() self.SetTooltip(btn) end)
    btn:SetScript("OnLeave", function() self.DropTooltip() end)

    return btn
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

function ASHH:Refresh()
    setsFrame:Refresh()
    -- setsFrame:SelectSet(setsFrame:GetSelectedSetID())
    -- TODO: Re-equipping an item is a bit jittery (Shoulder particle effects will reset and it's jarring). Fix this.
end

---------------------------------------------------------------
------------------- Vestigial Ace Stuff -----------------------
---------------------------------------------------------------

function ASHH:OnEnable() end
function ASHH:OnDisable() end