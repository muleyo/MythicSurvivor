-- MythicSurvivor: Survival Calculator
-- Calculates survival chances based on incoming damage and player stats

local addonName, MS = ...

-- Define WoW API constants for compatibility
CR_VERSATILITY_DAMAGE_DONE = CR_VERSATILITY_DAMAGE_DONE or 29
CR_VERSATILITY_DAMAGE_TAKEN = CR_VERSATILITY_DAMAGE_TAKEN or 30
CR_AVOIDANCE = CR_AVOIDANCE or 13

function MS:CalculateSurvivalChance()
    -- If no threats, survival is 100%
    if #self.incomingAbilities == 0 then
        return 1.0
    end

    -- Get current player stats
    local playerStats = self:GetPlayerDefensiveStats()
    local effectiveHealth = playerStats.effectiveHealth

    -- Calculate total incoming damage
    local totalDamage = 0
    local mitigatedDamage = 0

    for _, threat in ipairs(self.incomingAbilities) do
        local baseDamage = threat.data.damage or 0
        local finalDamage = self:CalculateMitigatedDamage(baseDamage, threat.data, playerStats)

        totalDamage = totalDamage + baseDamage
        mitigatedDamage = mitigatedDamage + finalDamage
    end

    -- Simple survival calculation
    if mitigatedDamage <= 0 then
        return 1.0
    end

    if effectiveHealth <= mitigatedDamage then
        return 0.0
    end

    -- Calculate survival percentage
    local survivalHealth = effectiveHealth - mitigatedDamage
    return math.min(1.0, survivalHealth / effectiveHealth)
end

function MS:CalculateMitigatedDamage(baseDamage, abilityData, playerStats)
    local finalDamage = baseDamage

    -- Apply armor reduction for physical damage
    if abilityData.type == "physical" then
        local armorReduction = self:GetArmorReduction(playerStats)
        finalDamage = finalDamage * (1 - armorReduction)
    end

    -- Apply active defensive abilities
    local totalReduction = 0
    local activeDefensives = self:GetActiveDefensives()
    for _, defensive in ipairs(activeDefensives) do
        -- Check if defensive type matches ability damage type
        -- If no type is specified, treat as universal ("all") defensive
        -- Only type-specific defensives (like Anti-Magic Zone) are restricted
        local typeMatches = (not defensive.type or defensive.type == "all" or defensive.type == abilityData.type)

        if typeMatches then
            -- Check if this ability is AOE and the defensive has AOE-specific reduction
            if abilityData.isAOE and defensive.aoe_reduction then
                totalReduction = totalReduction + defensive.aoe_reduction
            elseif defensive.reduction then
                -- Apply regular reduction for non-AOE abilities or defensives without AOE-specific reduction
                totalReduction = totalReduction + defensive.reduction
            end
        end
    end

    -- Cap total reduction at 95% to prevent negative damage
    totalReduction = math.min(0.95, totalReduction)
    finalDamage = finalDamage * (1 - totalReduction)

    -- Apply avoidance stat for AOE abilities only
    if abilityData.isAOE and playerStats and playerStats.avoidance then
        local avoidanceReduction = playerStats.avoidance / 100 -- Convert percentage to decimal
        finalDamage = finalDamage * (1 - avoidanceReduction)
    end

    -- Apply versatility damage reduction
    local versatilityReduction = self:GetVersatilityDamageReduction()
    finalDamage = finalDamage * (1 - versatilityReduction)

    return math.max(0, finalDamage)
end

function MS:GetArmorReduction(playerStats)
    -- Use WoW's official armor effectiveness calculation
    local armor = (playerStats and playerStats.armor) or select(2, UnitArmor("player")) or 0
    local armorEffectiveness = C_PaperDollInfo.GetArmorEffectiveness(armor,
        GetMaxLevelForExpansionLevel(GetExpansionLevel())) or 0

    -- GetArmorEffectiveness returns a value between 0-1 (already a decimal)
    return armorEffectiveness
end

function MS:GetVersatilityDamageReduction()
    -- Get versatility damage reduction percentage (already calculated by WoW)
    local versatilityPercent = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_TAKEN) or 0

    -- Versatility damage reduction is half of the versatility percentage
    return versatilityPercent / 100 -- Convert to decimal percentage
end

function MS:GetPlayerDefensiveStats()
    -- Collect various defensive stats for display
    local stats = {}

    stats.health = UnitHealth("player")
    stats.maxHealth = UnitHealthMax("player")
    stats.absorb = UnitGetTotalAbsorbs("player") or 0
    stats.armor = select(2, UnitArmor("player")) or 0
    stats.versatility = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) or 0
    stats.avoidance = GetCombatRatingBonus(CR_AVOIDANCE) or 0

    -- Calculate effective health (use max health for survival calculations)
    -- This assumes the player will be at full health when the ability hits
    stats.effectiveHealth = stats.maxHealth + stats.absorb

    return stats
end

function MS:PredictDamageFromSpell(spellID, sourceLevel, difficulty)
    -- Predict damage for unknown spells based on spell school and level
    local abilityData = self:GetAbilityData(spellID)
    if abilityData then
        return abilityData.damage
    end

    -- Fallback estimation based on source level and difficulty
    sourceLevel = sourceLevel or 80
    difficulty = difficulty or 1          -- 1 = Normal, 2 = Heroic, 3 = Mythic

    local baseDamage = sourceLevel * 1000 -- Base estimation
    local difficultyMultiplier = 1 + (difficulty - 1) * 0.5

    return baseDamage * difficultyMultiplier
end

function MS:CalculateSingleAbilitySurvival(abilityData)
    -- Calculate survival for a single ability with keystone scaling and affixes
    local playerStats = self:GetPlayerDefensiveStats()
    local effectiveHealth = playerStats.effectiveHealth

    -- Apply keystone level and affix scaling to base damage first
    local scaledDamage = self:ApplyKeystoneScaling(abilityData.damage, abilityData)

    -- Then apply defensive mitigations to the scaled damage
    local finalDamage = self:CalculateMitigatedDamage(scaledDamage, abilityData, playerStats)

    -- Simple survival check
    local willSurvive = effectiveHealth > finalDamage
    local healthRemaining = effectiveHealth - finalDamage
    local overkillDamage = math.max(0, finalDamage - effectiveHealth)
    local survivalPercent = math.max(0, healthRemaining) / effectiveHealth * 100

    return willSurvive, survivalPercent, finalDamage, healthRemaining, overkillDamage
end

function MS:ApplyKeystoneScaling(baseDamage, abilityData)
    local scaledDamage = baseDamage
    local keystoneLevel = MS.keystoneLevel or 10

    -- Mythic+ keystone scaling percentages (official values)
    local keystoneScaling = {
        [2] = 0.00,
        [3] = 0.14,
        [4] = 0.23,
        [5] = 0.31,
        [6] = 0.40,
        [7] = 0.50,
        [8] = 0.61,
        [9] = 0.72,
        [10] = 0.84,
        [11] = 1.02,
        [12] = 1.22,
        [13] = 1.45,
        [14] = 1.69,
        [15] = 1.96,
        [16] = 2.26,
        [17] = 2.58,
        [18] = 2.94,
        [19] = 3.33,
        [20] = 3.77,
        [21] = 4.25,
        [22] = 4.77,
        [23] = 5.35,
        [24] = 5.98,
        [25] = 6.68,
        [26] = 7.45,
        [27] = 8.29,
        [28] = 9.22,
        [29] = 10.24,
        [30] = 11.37
    }

    -- Apply keystone scaling if level is in range
    local scalingMultiplier = keystoneScaling[keystoneLevel]
    if scalingMultiplier then
        scaledDamage = scaledDamage * (1 + scalingMultiplier)
    else
        -- For levels outside our table, use level 30 scaling
        if keystoneLevel > 30 then
            scaledDamage = scaledDamage * (1 + keystoneScaling[30])
        end
        -- Levels below 2 use no scaling (base damage)
    end

    -- Apply affix modifiers
    scaledDamage = self:ApplyAffixModifiers(scaledDamage, abilityData)

    return scaledDamage
end

function MS:ApplyAffixModifiers(damage, abilityData)
    local modifiedDamage = damage

    -- Check if Tyrannical is active and this is a boss ability
    if self:IsTyrannicalActive() and abilityData.source == "boss" then
        modifiedDamage = modifiedDamage * 1.15 -- +15% damage for boss abilities
    end

    -- Check if Fortified is active and this is a trash ability
    if self:IsFortifiedActive() and abilityData.source == "trash" then
        modifiedDamage = modifiedDamage * 1.20 -- +20% damage for trash abilities
    end

    return modifiedDamage
end

function MS:IsTyrannicalActive()
    -- Check if Tyrannical affix is active
    return MS.tyrannicalActive or false
end

function MS:IsFortifiedActive()
    -- Check if Fortified affix is active
    return MS.fortifiedActive or false
end
