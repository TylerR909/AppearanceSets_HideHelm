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

]]