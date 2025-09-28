-- MythicSurvivor: Database Management
-- Handles ability data and survival calculations

local addonName, MS = ...

-- Ability database organized by dungeon
MS.AbilityDB = {
    -- Tazavesh: Streets of Wonder (4062727)
    [4062727] = {
        [345770] = { name = "Impound Contraband", damage = 3640000, type = "magic", source = "boss", isAOE = false },
        [346967] = { name = "Money Order", damage = 5460000, type = "physical", source = "boss", isAOE = true },
        [1240811] = { name = "Energized Slam", damage = 3640000, type = "magic", source = "trash", isAOE = true },
        [347903] = { name = "Junk Mail", damage = 3640000, type = "physical", source = "trash", isAOE = false },
        [347822] = { name = "Mail Shoot", damage = 3640000, type = "physical", source = "trash", isAOE = true }
    },

    -- Tazavesh: So'leah's Gambit (4062728)
    [4062728] = {
        [353312] = { name = "Purifying Blast", damage = 3900000, type = "magic", source = "boss", isAOE = true },
        [350885] = { name = "Hyperlight Jolt", damage = 4180000, type = "magic", source = "boss", isAOE = true },
        [355429] = { name = "Tidal Stomp", damage = 3640000, type = "magic", source = "trash", isAOE = true },
    },

    -- Eco-Dome Al'dani (6921877)
    [6921877] = {
        [1249985] = { name = "Whispers of Fate", damage = 2790000, type = "magic", source = "boss", isAOE = false },
        [1225308] = { name = "Dread of the Unknown", damage = 2790000, type = "magic", source = "boss", isAOE = false },
        [1224868] = { name = "Splinters of Fate", damage = 2790000, type = "magic", source = "boss", isAOE = false },
        [1226165] = { name = "Volatile Ejection", damage = 3640000, type = "magic", source = "trash", isAOE = true },
        [1231252] = { name = "Unstable Core", damage = 2420000, type = "magic", source = "trash", isAOE = false }
    },

    -- Halls of Atonement (3601526)
    [3601526] = {
        [319592] = { name = "Stone Shattering Leap", damage = 3350000, type = "magic", source = "boss", isAOE = true },
        [1237642] = { name = "Telekinetic Onslaught (x4)", damage = 5580000, type = "physical", source = "boss", ignoreArmor = true, isAOE = true },
        [325879] = { name = "Curse of Obliteration", damage = 3760000, type = "magic", source = "trash", isAOE = true },
        [326829] = { name = "Wicked Bolt", damage = 4360000, type = "magic", source = "trash", isAOE = false },
        [1235326] = { name = "Disrupting Screech", damage = 2420000, type = "physical", source = "trash", isAOE = true }
    },

    -- Ara-Kara, City of Echoes (5899326)
    [5899326] = {
        [433731] = { name = "Burrow Charge", damage = 6061123, type = "physical", source = "boss", isAOE = true },
        [434786] = { name = "Web Bolt", damage = 2100000, type = "magic", source = "trash", isAOE = false },
    },

    -- The Dawnbreaker (5899330)
    [5899330] = {
        [453310] = { name = "Obsidian Beam", damage = 2420000, type = "magic", source = "boss", isAOE = true },
        [426826] = { name = "Dark Orb", damage = 3650000, type = "magic", source = "boss", isAOE = true },
        [448888] = { name = "Erosive Spray", damage = 1940000, type = "magic", source = "boss", isAOE = true },
        [434093] = { name = "Spinneret's Strands", damage = 3030000, type = "magic", source = "boss", isAOE = true },
        [451104] = { name = "Bursting Cocoon", damage = 3430000, type = "magic", source = "trash", isAOE = true }
    },

    -- Operation: Floodgate (6392629)
    [6392629] = {
        [460602] = { name = "Quick Shot", damage = 4000000, type = "physical", source = "boss", isAOE = false },
        [460814] = { name = "Deflagration", damage = 4360000, type = "magic", source = "boss", isAOE = true },
        [468815] = { name = "Gigazap", damage = 3640000, type = "magic", source = "boss", isAOE = true },
        [1216611] = { name = "Battery Discharge", damage = 1570000, type = "magic", source = "trash", isAOE = true }
    },

    -- Priory Sacred Flame (5899331)
    [5899331] = {
        [1238780] = { name = "Earthshattering Spear", damage = 2430000, type = "magic", source = "boss", isAOE = true },
        [424421] = { name = "Fireball (Taener Boss)", damage = 4360000, type = "magic", source = "boss", isAOE = false },
        [446649] = { name = "Castigator's Shield", damage = 3530000, type = "magic", source = "boss", isAOE = false },
        [428170] = { name = "Blinding Light", damage = 2430000, type = "magic", source = "boss", isAOE = true },
        [427621] = { name = "Impale", damage = 2430000, type = "physical", source = "trash", isAOE = false },
        [462859] = { name = "Pot Shot", damage = 1940000, type = "physical", source = "trash", isAOE = false },
        [448492] = { name = "Thunderclap", damage = 3400000, type = "magic", source = "trash", isAOE = true },
        [424426] = { name = "Lunging Strike", damage = 3400000, type = "physical", source = "trash", isAOE = true },
        [427897] = { name = "Heat Wave", damage = 1700000, type = "magic", source = "trash", isAOE = true },
        [448791] = { name = "Sacred Toll", damage = 3400000, type = "magic", source = "trash", isAOE = true },
        [427469] = { name = "Fireball (Conjurer)", damage = 2910000, type = "magic", source = "trash", isAOE = false },
        [427357] = { name = "Holy Smite", damage = 2420000, type = "magic", source = "trash", isAOE = false }
    }
}

MS.externalsDB = {
    { name = "Blessing of Sacrifice", spellID = 6940,   reduction = 0.3,  tooltip = "DR" },
    { name = "Pain Suppression",      spellID = 33206,  reduction = 0.4,  tooltip = "DR" },
    { name = "Ironbark",              spellID = 102342, reduction = 0.2,  tooltip = "DR" },
    { name = "Life Cocoon",           spellID = 116849, reduction = 0.48, tooltip = "HP Absorb" },
    { name = "Time Dilation",         spellID = 357170, reduction = 0.5,  tooltip = "DR" },
    { name = "Spirit Link Totem",     spellID = 98008,  reduction = 0.1,  tooltip = "DR" },
    { name = "Earthen Harmony",       spellID = 382020, reduction = 0.03, tooltip = "DR" },
    { name = "Rescue",                spellID = 370665, reduction = 0.3,  tooltip = "HP Absorb" }
}

MS.personalsDB = {
    -- Warrior
    { name = "Defensive Stance",        spellID = 386208, reduction = 0.15, tooltip = "DR",                       class = "WARRIOR" },
    { name = "Spell Reflection",        spellID = 23920,  type = "magic",   reduction = 0.2,                      tooltip = "Magic DR",  class = "WARRIOR" },
    { name = "Die by the Sword",        spellID = 118038, reduction = 0.3,  tooltip = "DR",                       class = "WARRIOR" },
    { name = "Enraged Regeneration",    spellID = 184364, reduction = 0.3,  tooltip = "DR",                       class = "WARRIOR" },

    -- Death Knight
    { name = "Anti-Magic Shell",        spellID = 48707,  type = "magic",   reduction = 0.48,                     tooltip = "Magic DR",  class = "DEATHKNIGHT" },
    { name = "Lichborne",               spellID = 49039,  reduction = 0.15, tooltip = "DR",                       class = "DEATHKNIGHT" },
    { name = "Icebound Fortitude",      spellID = 48792,  reduction = 0.3,  tooltip = "DR",                       class = "DEATHKNIGHT" },

    -- Demon Hunter
    { name = "Blur",                    spellID = 198589, reduction = 0.2,  tooltip = "DR",                       class = "DEMONHUNTER" },
    { name = "Deflecting Dance",        spellID = 427776, reduction = 0.15, tooltip = "HP Absorb",                class = "DEMONHUNTER" },
    { name = "Army Unto Oneself",       spellID = 442714, reduction = 0.1,  tooltip = "DR",                       class = "DEMONHUNTER" },

    -- Druid
    { name = "Survival Instincts",      spellID = 61336,  reduction = 0.5,  tooltip = "DR",                       class = "DRUID" },
    { name = "Barkskin",                spellID = 22812,  reduction = 0.2,  tooltip = "DR",                       class = "DRUID" },
    { name = "Ursine Vigor",            spellID = 377842, reduction = 0.15, tooltip = "HP & Armor",               class = "DRUID" },
    { name = "Bear Form",               spellID = 5487,   reduction = 0.25, tooltip = "Stamina",                  class = "DRUID" },

    -- Evoker
    { name = "Obsidian Scales",         spellID = 363916, reduction = 0.3,  tooltip = "DR",                       class = "EVOKER" },
    { name = "Nimble Flyer",            spellID = 441253, reduction = 0,    aoe_reduction = 0.1,                  tooltip = "DR",        class = "EVOKER" },

    -- Hunter
    { name = "Aspect of the Turtle",    spellID = 186265, reduction = 0.3,  tooltip = "DR",                       class = "HUNTER" },
    { name = "Fortitude of the Bear",   spellID = 272679, reduction = 0.2,  tooltip = "HP",                       class = "HUNTER" },
    { name = "Survival of the Fittest", spellID = 264735, reduction = 0.3,  tooltip = "HP",                       class = "HUNTER" },

    -- Mage
    { name = "Ice Cold",                spellID = 414658, reduction = 0.7,  tooltip = "DR",                       class = "MAGE" },
    { name = "Greater Invisibility",    spellID = 110959, reduction = 0.6,  tooltip = "DR",                       class = "MAGE" },
    { name = "Mirror Image",            spellID = 55342,  reduction = 0.2,  tooltip = "DR",                       class = "MAGE" },
    { name = "Prismatic Barrier",       spellID = 235450, reduction = 0.2,  tooltip = "HP Absorb + 25% Magic DR", class = "MAGE" },
    { name = "Blazing Barrier",         spellID = 235313, reduction = 0.2,  tooltip = "HP Absorb",                class = "MAGE" },
    { name = "Ice Barrier",             spellID = 11426,  reduction = 0.24, tooltip = "HP Absorb",                class = "MAGE" },

    -- Monk
    { name = "Fortifying Brew",         spellID = 115203, reduction = 0.4,  tooltip = "DR + 20% HP",              class = "MONK" },
    { name = "Diffuse Magic",           spellID = 122783, type = "magic",   reduction = 0.6,                      tooltip = "Magic DR",  class = "MONK" },
    { name = "Touch of Karma",          spellID = 122470, type = "magic",   reduction = 0.5,                      tooltip = "HP Absorb", class = "MONK" },

    -- Paladin
    { name = "Shield of Vengeance",     spellID = 184662, reduction = 0.3,  tooltip = "DR",                       class = "PALADIN" },
    { name = "Divine Protection",       spellID = 498,    reduction = 0.3,  tooltip = "DR",                       class = "PALADIN" },

    -- Priest
    { name = "Fade",                    spellID = 586,    reduction = 0.1,  tooltip = "DR",                       class = "PRIEST" },
    { name = "Protective Light",        spellID = 193063, reduction = 0.1,  tooltip = "DR",                       class = "PRIEST" },
    { name = "Desperate Prayer",        spellID = 19236,  reduction = 0.25, tooltip = "HP",                       class = "PRIEST" },
    { name = "Dispersion",              spellID = 47585,  reduction = 0.75, tooltip = "DR",                       class = "PRIEST" },

    -- Rogue
    { name = "Evasion",                 spellID = 292230, reduction = 0.2,  tooltip = "DR",                       class = "ROGUE" },
    { name = "Feint",                   spellID = 1966,   reduction = 0.2,  aoe_reduction = 0.4,                  tooltip = "DR",        class = "ROGUE" },

    -- Shaman
    { name = "Astral Shift",            spellID = 108271, reduction = 0.3,  tooltip = "DR",                       class = "SHAMAN" },
    { name = "Earth Elemental",         spellID = 198103, reduction = 0.15, tooltip = "HP",                       class = "SHAMAN" },
    { name = "Primordial Bond",         spellID = 381764, reduction = 0.05, tooltip = "DR",                       class = "SHAMAN" },
    { name = "Stone Bulwark Totem",     spellID = 108270, reduction = 0.3,  tooltip = "HP",                       class = "SHAMAN" },
    { name = "Spirit Wolf (x4)",        spellID = 260878, reduction = 0.2,  tooltip = "DR",                       class = "SHAMAN" },

    -- Warlock
    { name = "Unending Resolve",        spellID = 104773, reduction = 0.4,  tooltip = "DR",                       class = "WARLOCK" },
    { name = "Dark Pact",               spellID = 108416, reduction = 0.4,  tooltip = "HP Absorb",                class = "WARLOCK" },
}

MS.groupbuffsDB = {
    { name = "Mark of the Wild",      spellID = 1126,   reduction = 0.015, tooltip = "DR" },
    { name = "Power Word: Fortitude", spellID = 21562,  reduction = 0.05,  tooltip = "Stamina" },
    { name = "Black Attunement",      spellID = 403295, reduction = 0.02,  tooltip = "HP" },
    { name = "Rallying Cry",          spellID = 97462,  reduction = 0.1,   tooltip = "HP" },
    { name = "Devotion Aura",         spellID = 465,    reduction = 0.03,  tooltip = "DR" },
    { name = "Aura Mastery",          spellID = 31821,  reduction = 0.09,  tooltip = "DR" },
    { name = "Lenience",              spellID = 238063, reduction = 0.02,  tooltip = "DR" },
    { name = "Zephyr",                spellID = 374227, reduction = 0,     aoe_reduction = 0.2,  tooltip = "DR" },
    { name = "Atrophic Poison",       spellID = 381637, reduction = 0.036, tooltip = "DR" },
    { name = "Anti-Magic Zone",       spellID = 51052,  type = "magic",    reduction = 0.2,      tooltip = "Magic DR" },
    { name = "Power Word: Barrier",   spellID = 62618,  reduction = 0.2,   tooltip = "DR" },
    { name = "Ancestral Vigor",       spellID = 207400, reduction = 0.1,   tooltip = "HP" },
    { name = "Downpour",              spellID = 207778, reduction = 0.1,   tooltip = "HP" },
    { name = "Mass Barrier",          spellID = 414660, reduction = 0.2,   tooltip = "HP Absorb" }
}

function MS:InitializeDatabase()
    -- This will be expanded to load ability data from various sources
    self.playerClass = select(2, UnitClass("player"))
    self.playerSpec = GetSpecialization()
    self.playerLevel = UnitLevel("player")

    -- Initialize tracking variables
    self.currentTarget = nil
    self.incomingAbilities = {}
    self.activeDefensives = {}
end

function MS:GetAbilityData(spellID)
    -- Search through all dungeons for the ability
    for dungeonID, abilities in pairs(self.AbilityDB) do
        if abilities[spellID] then
            return abilities[spellID]
        end
    end
    return nil
end

function MS:GetDungeonAbilities(dungeonID)
    return self.AbilityDB[dungeonID] or {}
end

function MS:UpdatePlayerStats()
    -- Get current player stats for survival calculations
    local health = UnitHealth("player")
    local maxHealth = UnitHealthMax("player")
    local absorb = UnitGetTotalAbsorbs("player") or 0

    return {
        health = health,
        maxHealth = maxHealth,
        absorb = absorb,
        healthPercent = health / maxHealth
    }
end

function MS:AddAbilityThreat(spellID, sourceGUID, castTime)
    -- Add an incoming ability threat
    local abilityData = self:GetAbilityData(spellID)
    if not abilityData then return end

    local threat = {
        spellID = spellID,
        sourceGUID = sourceGUID,
        castTime = castTime,
        eta = GetTime() + castTime,
        data = abilityData
    }

    table.insert(self.incomingAbilities, threat)

    -- Trigger GUI update
    MS:UpdateMainFrame()
end

function MS:RemoveExpiredThreats()
    local currentTime = GetTime()
    for i = #self.incomingAbilities, 1, -1 do
        if self.incomingAbilities[i].eta < currentTime then
            table.remove(self.incomingAbilities, i)
        end
    end
end
