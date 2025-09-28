-- MythicSurvivor: Widget Utilities
-- Helper functions for GUI components

local addonName, MS = ...

-- Color utilities
MS.Colors = {
    GREEN = { r = 0, g = 1, b = 0 },
    YELLOW = { r = 1, g = 1, b = 0 },
    ORANGE = { r = 1, g = 0.5, b = 0 },
    RED = { r = 1, g = 0, b = 0 },
    WHITE = { r = 1, g = 1, b = 1 },
    GRAY = { r = 0.5, g = 0.5, b = 0.5 }
}

function MS:GetThreatColor(survivalChance)
    if survivalChance >= 0.8 then
        return self.Colors.GREEN
    elseif survivalChance >= 0.5 then
        return self.Colors.YELLOW
    elseif survivalChance >= 0.2 then
        return self.Colors.ORANGE
    else
        return self.Colors.RED
    end
end

function MS:FormatTime(seconds)
    if seconds <= 0 then
        return "|cffff0000NOW!|r"
    elseif seconds < 60 then
        return string.format("|cffffff00%.1fs|r", seconds)
    else
        local minutes = math.floor(seconds / 60)
        local remainingSeconds = seconds % 60
        return string.format("|cffffff00%dm %.0fs|r", minutes, remainingSeconds)
    end
end

function MS:FormatDamage(damage)
    if damage >= 1000000 then
        return string.format("%.1fM", damage / 1000000)
    elseif damage >= 1000 then
        return string.format("%.0fK", damage / 1000)
    else
        return tostring(damage)
    end
end

-- Animation helpers
function MS:FadeIn(frame, duration)
    if not frame then return end

    duration = duration or 0.3
    local fadeIn = frame:CreateAnimationGroup()
    local alpha = fadeIn:CreateAnimation("Alpha")
    alpha:SetFromAlpha(0)
    alpha:SetToAlpha(1)
    alpha:SetDuration(duration)
    fadeIn:Play()
end

function MS:FadeOut(frame, duration, hideOnComplete)
    if not frame then return end

    duration = duration or 0.3
    local fadeOut = frame:CreateAnimationGroup()
    local alpha = fadeOut:CreateAnimation("Alpha")
    alpha:SetFromAlpha(1)
    alpha:SetToAlpha(0)
    alpha:SetDuration(duration)

    if hideOnComplete then
        fadeOut:SetScript("OnFinished", function()
            frame:Hide()
        end)
    end

    fadeOut:Play()
end

-- Tooltip helpers
function MS:ShowAbilityTooltip(frame, abilityData, anchor)
    if not abilityData then return end

    GameTooltip:SetOwner(frame, anchor or "ANCHOR_RIGHT")
    GameTooltip:SetText(abilityData.name, 1, 1, 1, true)

    -- Add damage info
    if abilityData.damage then
        GameTooltip:AddLine(string.format("Damage: %s", self:FormatDamage(abilityData.damage)), 1, 0.8, 0.2)
    end

    -- Add mitigation info
    local mitigationText = {}
    if abilityData.canDodge then table.insert(mitigationText, "Dodge") end
    if abilityData.canParry then table.insert(mitigationText, "Parry") end
    if abilityData.canBlock then table.insert(mitigationText, "Block") end

    if #mitigationText > 0 then
        GameTooltip:AddLine("Can be: " .. table.concat(mitigationText, ", "), 0.6, 1, 0.6)
    else
        GameTooltip:AddLine("Cannot be avoided", 1, 0.6, 0.6)
    end

    GameTooltip:Show()
end

function MS:HideTooltip()
    GameTooltip:Hide()
end
