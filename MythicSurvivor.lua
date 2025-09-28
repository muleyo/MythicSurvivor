-- MythicSurvivor Main Entry Point
-- Handles initialization and cleanup

local addonName, MS = ...

-- Initialize variables (pre-combat planning focus)
MS.currentDungeon = nil
MS.selectedAbility = nil
MS.playerClass = nil
MS.playerSpec = nil
MS.playerLevel = nil

-- Version info
MS.VERSION = "1.0.0"
MS.BUILD_DATE = "2025-09-25"

-- Debug flag
MS.DEBUG = false

function MS:Print(msg)
    if msg then
        print("|cffffff00MythicSurvivor:|r " .. msg)
    end
end

function MS:Debug(msg)
    if self.DEBUG and msg then
        print("|cff808080[DEBUG]|r " .. msg)
    end
end

-- Test function to add fake threats for GUI testing
function MS:AddTestThreat()
    if not self.AbilityDB then return end

    -- Add a test threat
    local testSpellID = 320170 -- Necrotic Bolt
    local testThreat = {
        spellID = testSpellID,
        sourceGUID = "test-guid-123",
        castTime = 3.0,
        eta = GetTime() + 3.0,
        data = self.AbilityDB[testSpellID] or {
            name = "Test Ability",
            damage = 50000,
            type = "magic",
            school = "shadow",
            canDodge = false,
            canParry = false,
            canBlock = false
        }
    }

    table.insert(self.incomingAbilities, testThreat)
    self:UpdateMainFrame()

    self:Print("Added test threat for GUI testing")
end

function MS:ClearThreats()
    self.incomingAbilities = {}
    self:UpdateMainFrame()
    self:Print("Cleared all threats")
end

-- Single slash command to open GUI
SLASH_MYTHICSURVIVOR1 = "/ms"
SlashCmdList["MYTHICSURVIVOR"] = function(msg)
    MS:ShowMainFrame()
end

function MS:ShowStatus()
    self:Print("Status Report:")
    print(string.format("  Version: %s", self.VERSION))
    print(string.format("  Current Dungeon: %s", self.currentDungeon or "None selected"))
    print(string.format("  Selected Ability: %s", self.selectedAbility or "None selected"))
    print(string.format("  Player Class: %s", self.playerClass or "Unknown"))

    if MainFrame then
        local width, height = MainFrame:GetSize()
        print(string.format("  GUI Visible: %s", MainFrame:IsShown() and "Yes" or "No"))
        print(string.format("  GUI Size: %.0fx%.0f", width, height))
        print("  |cffcccccc(Pre-combat planning tool - no real-time tracking)|r")
    end
end

-- Register for addon loading
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Initialize the addon (no combat events needed)
        MS:InitializeDatabase()
        MS:InitializeGUI()

        print("|cffffff00MythicSurvivor|r: Addon loaded. Type |cff00ff00/ms|r to open.")
        MS:Debug("Addon loaded successfully")
    end
end)
