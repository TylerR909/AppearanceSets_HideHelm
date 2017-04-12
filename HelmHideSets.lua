-- C_TransmogSets.GetAllSets()
-- C_TransmogSets.GetBaseSets()
-- http://wow.gamepedia.com/World_of_Warcraft_API 

-- I really need to know what kind of returns I can expect before I can start doing anything with these. 
--[[
    Class-based
        Still need a name of the set, and the name of the last-clicked button to apply the right helm
        The arrow key issue comes up though if I don't save the correct name for the set. I should ask about that.
    All sets
        Filter out what sets are for player class, then continue with the other mapping

        At the end of the day all I have is one thing, the name of the set from the button. Somehow I need to get from the name of the set to item IDs, and then call evalbuttons

a set from C_TransmogSets.GetAllSets() looks like
    description: Heroic
    label: Tomb of Sargeras
    hiddenUntilCollected: false
    setID: 1328 (variant specific)
    expansionID: 6
    name: Wildstalker Armor
    classMask: 4 (druid?)
    collected: false
    uiOrder: 8902
    favorite: false
    baseSetID: 1325

C_TransmogSets.GetBaseSets() looks like
    description: Normal
    label: Bastion of Twilight
    hiddenUntilCollected: false
    setID: 349
    expansionID: 2
    name: Velen's Regalia
    requiredFaction: Alliance
    collected: false
    uiOrder: 2320
    favorite: false
    classMask: 16

GetBaseSets() seems to filter out for the player class, and maps a set name to a setID

{
    name = "Vestments of Blind Absolution"
    baseSetID = "1309"
    variants = {
        {
            description = "Raid Finder",
            setID = 1342
        },
        {
            description = 
        }
    }
}


------- TEST ONE ---------
local sets = C_TransmogSets.GetAllSets()
classSets = {}

local function tprint (tbl, indent)
   if not indent then indent = 0 end
   for k, v in pairs(tbl) do
      formatting = string.rep("  ", indent) .. k .. ": "
      if type(v) == "table" then
         print(formatting)
         tprint(v, indent+1)
      elseif type(v) == 'boolean' then
         print(formatting .. tostring(v))      
      else
         print(formatting .. v)
      end
   end
end

local function setNames()
   for i=1, #sets do
      local set = sets[i]
      if set.classMask == 16 then
         tinsert(classSets,set.name)
      end
   end
   
   for i=1,#classSets do
      print(classSets[i])
   end
end   

local function printNames(table,name)
   for  k,v in pairs(table) do
      if v.name == name then
         print(v.name, v.description, v.baseSetID, v.setID)
      end
   end
end


-- tprint(sets)
local set = "Vestments of Blind Absolution"
local setID = 1310
-- printNames(sets,set)
-- print(tContains(classSets,set))
tprint(C_TransmogSets.GetSourceIDsForSlot(setID,1))
print("---done---")






------ TEST 2 --------
local sets = {}
local baseSets = C_TransmogSets.GetBaseSets()

for i=1,#baseSets do
    set = baseSets[i]
    if sets[set.name] then continue end
    sets[set.name] = {
        name = set.name,
        setID = set.setID
    }
end


]]