local addonName, MS = ...

local MainFrame = nil
local AbilityList = {}

function MS:InitializeGUI()
    self:CreateMainFrame()
end

function MS:CreateMainFrame()
    if MainFrame then return end

    -- Main container frame
    MainFrame = CreateFrame("Frame", "MythicSurvivor", UIParent, "BackdropTemplate")
    MainFrame:SetSize(550, 600) -- Increased size for better content visibility
    MainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

    -- Modern backdrop with transparency
    MainFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })

    -- Dark transparent background (Details/ElvUI style)
    MainFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
    MainFrame:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
    MainFrame:SetAlpha(0.9)

    -- Make it always movable (but not resizable)
    MainFrame:SetMovable(true)
    MainFrame:EnableMouse(true)
    MainFrame:RegisterForDrag("LeftButton")
    MainFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    MainFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        -- Position is not saved (no database)
    end)

    -- Title bar
    local titleBar = CreateFrame("Frame", nil, MainFrame, "BackdropTemplate")
    titleBar:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 1, -1)
    titleBar:SetPoint("TOPRIGHT", MainFrame, "TOPRIGHT", -1, -1)
    titleBar:SetHeight(25)
    titleBar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = nil,
        tile = false,
        tileSize = 0,
        edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    titleBar:SetBackdropColor(0.1, 0.1, 0.1, 0.8)

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("CENTER", titleBar, "TOP", 0, -12)
    title:SetText("Mythic Survivor")
    title:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
    title:SetTextColor(0.8, 0.8, 0.6, 1)

    -- Logo overlay frame (separate frame for better layering control)
    local logoFrame = CreateFrame("Frame", nil, MainFrame)
    logoFrame:SetSize(250, 250)
    logoFrame:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", -90, 110)
    logoFrame:SetFrameStrata("HIGH")

    local logoIcon = logoFrame:CreateTexture(nil, "OVERLAY")
    logoIcon:SetAllPoints(logoFrame)
    logoIcon:SetTexture("Interface\\AddOns\\MythicSurvivor\\Logo.png")

    -- Close button
    local closeButton = CreateFrame("Button", nil, titleBar, "UIPanelCloseButtonNoScripts")
    closeButton:SetSize(20, 20)
    closeButton:SetPoint("RIGHT", titleBar, "RIGHT", -3, 0)
    closeButton:SetScript("OnClick", function()
        MS:HideMainFrame()
    end)

    -- Content area
    local contentFrame = CreateFrame("Frame", nil, MainFrame)
    contentFrame:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 4, -4)
    contentFrame:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", -4, 35) -- Make room for bottom bar

    -- Dungeon status display
    local headerFrame = CreateFrame("Frame", nil, contentFrame, "BackdropTemplate")
    headerFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, 0)
    headerFrame:SetPoint("TOPRIGHT", contentFrame, "TOPRIGHT", 0, 0)
    headerFrame:SetHeight(50)
    headerFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    headerFrame:SetBackdropColor(0.02, 0.02, 0.02, 0.7)
    headerFrame:SetBackdropBorderColor(0.15, 0.15, 0.15, 0.8)

    -- Main display text (dungeon name or "Select a Dungeon")
    local dungeonText = headerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dungeonText:SetPoint("CENTER", headerFrame, "CENTER", 0, 0)
    dungeonText:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    dungeonText:SetText("Select a Dungeon")
    dungeonText:SetTextColor(0.8, 0.8, 0.6, 1)

    -- Dungeon selection area
    local dungeonFrame = CreateFrame("Frame", nil, contentFrame, "BackdropTemplate")
    dungeonFrame:SetPoint("TOPLEFT", headerFrame, "BOTTOMLEFT", 0, -8)
    dungeonFrame:SetPoint("TOPRIGHT", headerFrame, "TOPRIGHT", 0, -8)
    dungeonFrame:SetHeight(75)
    dungeonFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    dungeonFrame:SetBackdropColor(0.02, 0.02, 0.02, 0.7)
    dungeonFrame:SetBackdropBorderColor(0.15, 0.15, 0.15, 0.8)

    -- Dungeon label (centered)
    local dungeonLabel = dungeonFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dungeonLabel:SetPoint("TOP", dungeonFrame, "TOP", 0, -4)
    dungeonLabel:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    dungeonLabel:SetText("Dungeons")
    dungeonLabel:SetTextColor(0.8, 0.8, 0.8, 1)

    -- Create dungeon icons
    local dungeonIcons = {}
    local dungeonData = {
        { name = "Tazavesh: Streets of Wonder", id = 4062727, icon = 4062727 }, -- Official Tazavesh icon
        { name = "Tazavesh: So'leah's Gambit",  id = 4062728, icon = 4062727 }, -- Official Tazavesh icon (same for both wings)
        { name = "Eco-Dome Al'dani",            id = 6921877, icon = 6921877 }, -- Official Eco-Dome icon
        { name = "Halls of Atonement",          id = 3601526, icon = 3601526 }, -- Official Halls of Atonement icon
        { name = "Ara-Kara, City of Echoes",    id = 5899326, icon = 5899326 }, -- Official Ara-Kara icon
        { name = "The Dawnbreaker",             id = 5899330, icon = 5899330 }, -- Official Dawnbreaker icon
        { name = "Operation: Floodgate",        id = 6392629, icon = 6392629 }, -- Official Floodgate icon
        { name = "Priory Sacred Flame",         id = 5899331, icon = 5899331 }  -- Official Priory icon
    }

    local iconSize = 32
    local spacing = 38
    local startY = -6
    -- Calculate total width and center the icons
    local totalIcons = #dungeonData
    local totalWidth = (totalIcons - 1) * spacing + iconSize
    local startOffsetFromCenter = -(totalWidth / 2) + (iconSize / 2)

    for i, dungeon in ipairs(dungeonData) do
        local iconButton = CreateFrame("Button", nil, dungeonFrame)
        iconButton:SetSize(iconSize, iconSize)
        iconButton:SetPoint("CENTER", dungeonFrame, "CENTER", startOffsetFromCenter + (i - 1) * spacing, startY)

        -- Icon texture
        local iconTexture = iconButton:CreateTexture(nil, "ARTWORK")
        iconTexture:SetAllPoints(iconButton)
        iconTexture:SetTexture(dungeon.icon)
        iconTexture:SetTexCoord(0.07, 0.93, 0.07, 0.93) -- Standard icon cropping

        -- Underline for selected state
        local underline = iconButton:CreateTexture(nil, "OVERLAY")
        underline:SetTexture("Interface\\Buttons\\WHITE8x8")
        underline:SetPoint("BOTTOMLEFT", iconButton, "BOTTOMLEFT", 0, -3)
        underline:SetPoint("BOTTOMRIGHT", iconButton, "BOTTOMRIGHT", 0, -3)
        underline:SetHeight(2)
        underline:SetVertexColor(0.2, 0.8, 1, 1) -- Blue underline
        underline:Hide()
        local border = underline                 -- Hover highlight
        local highlight = iconButton:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints(iconButton)
        highlight:SetTexture("Interface\\Buttons\\WHITE8x8")
        highlight:SetVertexColor(1, 1, 1, 0.3)

        -- Store references
        iconButton.border = border
        iconButton.dungeonName = dungeon.name
        iconButton.dungeonID = dungeon.id
        iconButton.selected = false

        -- Click handler
        iconButton:SetScript("OnClick", function(self)
            -- Clear other selections
            for _, btn in pairs(dungeonIcons) do
                btn.selected = false
                btn.border:Hide()
            end

            -- Select this dungeon
            self.selected = true
            self.border:Show()

            -- Update selected dungeon
            MS.selectedDungeon = dungeon.id
            MS.selectedDungeonName = dungeon.name

            -- Update abilities list
            MS:UpdateAbilitiesList()
            MS:UpdateMainFrame()
        end)

        -- Tooltip
        iconButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(dungeon.name, 1, 1, 1, true)
            GameTooltip:AddLine("Click to select this dungeon", 0.6, 0.8, 1)
            GameTooltip:Show()
        end)

        iconButton:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        dungeonIcons[i] = iconButton
    end

    -- Mythic+ Configuration section (Keystone level and Affixes)
    local mythicConfigFrame = CreateFrame("Frame", nil, contentFrame, "BackdropTemplate")
    mythicConfigFrame:SetPoint("TOPLEFT", dungeonFrame, "BOTTOMLEFT", 0, -8)
    mythicConfigFrame:SetPoint("TOPRIGHT", dungeonFrame, "TOPRIGHT", 0, -8)
    mythicConfigFrame:SetHeight(40)
    mythicConfigFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    mythicConfigFrame:SetBackdropColor(0.02, 0.02, 0.02, 0.7)
    mythicConfigFrame:SetBackdropBorderColor(0.15, 0.15, 0.15, 0.8)

    -- Keystone Level Slider
    local keystoneLevelText = mythicConfigFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    keystoneLevelText:SetPoint("LEFT", mythicConfigFrame, "LEFT", 80, 0)
    keystoneLevelText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    keystoneLevelText:SetText("Keystone Level: 10")
    keystoneLevelText:SetTextColor(0.9, 0.9, 0.9, 1)

    local keystoneSlider = CreateFrame("Slider", nil, mythicConfigFrame, "MinimalSliderTemplate")
    keystoneSlider:SetPoint("LEFT", mythicConfigFrame, "LEFT", 190, 0)
    keystoneSlider:SetSize(80, 10)
    keystoneSlider:SetMinMaxValues(2, 30)
    keystoneSlider:SetValue(10)
    keystoneSlider:SetValueStep(1)
    keystoneSlider:SetObeyStepOnDrag(true)

    -- Affix Icons
    local affixLabel = mythicConfigFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    affixLabel:SetPoint("RIGHT", mythicConfigFrame, "RIGHT", -150, 0)
    affixLabel:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    affixLabel:SetText("Affixes:")
    affixLabel:SetTextColor(0.8, 0.8, 0.8, 1)

    -- Fortified Icon (Trash affix)
    local fortifiedIcon = CreateFrame("Button", nil, mythicConfigFrame)
    fortifiedIcon:SetSize(28, 28)
    fortifiedIcon:SetPoint("LEFT", affixLabel, "RIGHT", 5, 0)

    local fortifiedTexture = fortifiedIcon:CreateTexture(nil, "ARTWORK")
    fortifiedTexture:SetAllPoints(fortifiedIcon)
    fortifiedTexture:SetTexture(463829) -- Fortified affix icon
    fortifiedTexture:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    -- Fortified underline
    local fortifiedUnderline = fortifiedIcon:CreateTexture(nil, "OVERLAY")
    fortifiedUnderline:SetTexture("Interface\\Buttons\\WHITE8x8")
    fortifiedUnderline:SetPoint("BOTTOMLEFT", fortifiedIcon, "BOTTOMLEFT", 0, -3)
    fortifiedUnderline:SetPoint("BOTTOMRIGHT", fortifiedIcon, "BOTTOMRIGHT", 0, -3)
    fortifiedUnderline:SetHeight(2)
    fortifiedUnderline:SetVertexColor(0.2, 0.8, 1, 1)

    -- Fortified hover and click
    local fortifiedHighlight = fortifiedIcon:CreateTexture(nil, "HIGHLIGHT")
    fortifiedHighlight:SetAllPoints(fortifiedIcon)
    fortifiedHighlight:SetTexture("Interface\\Buttons\\WHITE8x8")
    fortifiedHighlight:SetVertexColor(1, 1, 1, 0.3)
    fortifiedIcon.selected = true

    -- Tyrannical Icon (Boss affix)
    local tyrannicalIcon = CreateFrame("Button", nil, mythicConfigFrame)
    tyrannicalIcon:SetSize(28, 28)
    tyrannicalIcon:SetPoint("LEFT", fortifiedIcon, "RIGHT", 5, 0)

    local tyrannicalTexture = tyrannicalIcon:CreateTexture(nil, "ARTWORK")
    tyrannicalTexture:SetAllPoints(tyrannicalIcon)
    tyrannicalTexture:SetTexture(236401) -- Tyrannical affix icon
    tyrannicalTexture:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    -- Tyrannical underline
    local tyrannicalUnderline = tyrannicalIcon:CreateTexture(nil, "OVERLAY")
    tyrannicalUnderline:SetTexture("Interface\\Buttons\\WHITE8x8")
    tyrannicalUnderline:SetPoint("BOTTOMLEFT", tyrannicalIcon, "BOTTOMLEFT", 0, -3)
    tyrannicalUnderline:SetPoint("BOTTOMRIGHT", tyrannicalIcon, "BOTTOMRIGHT", 0, -3)
    tyrannicalUnderline:SetHeight(2)
    tyrannicalUnderline:SetVertexColor(0.2, 0.8, 1, 1)

    -- Tyrannical hover and click
    local tyrannicalHighlight = tyrannicalIcon:CreateTexture(nil, "HIGHLIGHT")
    tyrannicalHighlight:SetAllPoints(tyrannicalIcon)
    tyrannicalHighlight:SetTexture("Interface\\Buttons\\WHITE8x8")
    tyrannicalHighlight:SetVertexColor(1, 1, 1, 0.3)
    tyrannicalIcon.selected = true

    tyrannicalIcon:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Tyrannical", 1, 1, 1, true)
        GameTooltip:AddLine("Boss abilities deal 15% more damage", 0.8, 0.2, 0.2)
        GameTooltip:AddLine("Click to toggle", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)

    tyrannicalIcon:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    tyrannicalIcon.underline = tyrannicalUnderline

    fortifiedIcon:SetScript("OnClick", function(self)
        self.selected = not self.selected
        if self.selected then
            self.underline:Show()
        else
            self.underline:Hide()
        end
        MS.fortifiedActive = self.selected
        MS:UpdateMainFrame()
    end)

    tyrannicalIcon:SetScript("OnClick", function(self)
        self.selected = not self.selected
        if self.selected then
            self.underline:Show()
        else
            self.underline:Hide()
        end
        MS.tyrannicalActive = self.selected
        MS:UpdateMainFrame()
    end)

    fortifiedIcon:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Fortified", 1, 1, 1, true)
        GameTooltip:AddLine("Non-boss enemies deal 20% more damage", 0.8, 0.2, 0.2)
        GameTooltip:AddLine("Click to toggle", 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)

    fortifiedIcon:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    fortifiedIcon.underline = fortifiedUnderline

    -- Slider Script
    keystoneSlider:SetScript("OnValueChanged", function(self, value)
        MS.keystoneLevel = math.floor(value)
        keystoneLevelText:SetText("Keystone Level: " .. MS.keystoneLevel)

        -- Auto-activate both affixes at keystone level 10+
        if MS.keystoneLevel >= 10 then
            tyrannicalIcon.selected = true
            tyrannicalIcon.underline:Show()
            fortifiedIcon.selected = true
            fortifiedIcon.underline:Show()
            MS.tyrannicalActive = true
            MS.fortifiedActive = true
        else
            -- Below level 10, maintain current manual selections
            MS.tyrannicalActive = tyrannicalIcon.selected
            MS.fortifiedActive = fortifiedIcon.selected
        end

        -- Only update survival calculations, don't recreate the ability list
        MS:UpdateSurvivalChances()
    end)

    -- Character Stats section
    local statsFrame = CreateFrame("Frame", nil, contentFrame, "BackdropTemplate")
    statsFrame:SetPoint("TOPLEFT", mythicConfigFrame, "BOTTOMLEFT", 0, -8)
    statsFrame:SetPoint("TOPRIGHT", dungeonFrame, "TOPRIGHT", 0, -8)
    statsFrame:SetHeight(60)
    statsFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    statsFrame:SetBackdropColor(0.02, 0.02, 0.02, 0.7)
    statsFrame:SetBackdropBorderColor(0.15, 0.15, 0.15, 0.8)

    -- Stats label
    local statsLabel = statsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statsLabel:SetPoint("TOP", statsFrame, "TOP", 0, -4)
    statsLabel:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    statsLabel:SetText("Character Stats")
    statsLabel:SetTextColor(0.8, 0.8, 0.8, 1)

    -- Create stats display (2x2 grid)
    local statTexts = {}
    local statPositions = {
        { name = "Stamina",     x = -100, y = 2.5 },
        { name = "Armor",       x = 100,  y = 2.5 },
        { name = "Versatility", x = -100, y = -7.5 },
        { name = "Avoidance",   x = 100,  y = -7.5 }
    }

    for i, stat in ipairs(statPositions) do
        local statText = statsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        statText:SetPoint("CENTER", statsFrame, "CENTER", stat.x, stat.y)
        statText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        statText:SetText(stat.name .. ": 0")
        statText:SetTextColor(0.9, 0.9, 0.9, 1)
        statTexts[stat.name] = statText
    end

    -- Defensives section
    local defensivesFrame = CreateFrame("Frame", nil, contentFrame, "BackdropTemplate")
    defensivesFrame:SetPoint("TOPLEFT", statsFrame, "BOTTOMLEFT", 0, -8)
    defensivesFrame:SetPoint("TOPRIGHT", statsFrame, "TOPRIGHT", 0, -8)
    defensivesFrame:SetHeight(110)
    defensivesFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    defensivesFrame:SetBackdropColor(0.02, 0.02, 0.02, 0.7)
    defensivesFrame:SetBackdropBorderColor(0.15, 0.15, 0.15, 0.8)

    -- Defensives label
    local defensivesLabel = defensivesFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    defensivesLabel:SetPoint("TOP", defensivesFrame, "TOP", 0, -4)
    defensivesLabel:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    defensivesLabel:SetText("Defensives")
    defensivesLabel:SetTextColor(0.8, 0.8, 0.8, 1)

    -- External Defensives section
    local externalLabel = defensivesFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    externalLabel:SetPoint("TOPLEFT", defensivesFrame, "TOPLEFT", 8, -26)
    externalLabel:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    externalLabel:SetText("Externals")
    externalLabel:SetTextColor(0.6, 0.8, 1, 1) -- Light blue

    -- Personal Defensives section
    local personalLabel = defensivesFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    personalLabel:SetPoint("TOPLEFT", defensivesFrame, "TOPLEFT", 8, -56)
    personalLabel:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    personalLabel:SetText("Personals")
    personalLabel:SetTextColor(0.6, 1, 0.6, 1) -- Light green

    -- Group Buffs section
    local groupLabel = defensivesFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    groupLabel:SetPoint("TOPLEFT", defensivesFrame, "TOPLEFT", 8, -86)
    groupLabel:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    groupLabel:SetText("Group Buffs")
    groupLabel:SetTextColor(1, 0.8, 0.4, 1) -- Orange/yellow

    -- Create defensive buttons/checkboxes
    local defensiveButtons = {}

    -- Create external defensive icon buttons
    for i, defensive in ipairs(MS.externalsDB) do
        local iconButton = CreateFrame("Button", nil, defensivesFrame)
        iconButton:SetSize(24, 24)
        iconButton:SetPoint("TOPLEFT", defensivesFrame, "TOPLEFT", 80 + (i - 1) * 30, -20)

        -- Icon texture
        local iconTexture = iconButton:CreateTexture(nil, "ARTWORK")
        iconTexture:SetAllPoints(iconButton)
        iconTexture:SetTexture(C_Spell.GetSpellTexture(defensive.spellID))
        iconTexture:SetTexCoord(0.07, 0.93, 0.07, 0.93) -- Standard icon cropping

        -- Underline for selected state
        local underline = iconButton:CreateTexture(nil, "OVERLAY")
        underline:SetTexture("Interface\\Buttons\\WHITE8x8")
        underline:SetPoint("BOTTOMLEFT", iconButton, "BOTTOMLEFT", 0, -3)
        underline:SetPoint("BOTTOMRIGHT", iconButton, "BOTTOMRIGHT", 0, -3)
        underline:SetHeight(2)
        underline:SetVertexColor(0.6, 0.8, 1, 1) -- Light blue underline for externals
        underline:Hide()

        -- Hover highlight
        local highlight = iconButton:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints(iconButton)
        highlight:SetTexture("Interface\\Buttons\\WHITE8x8")
        highlight:SetVertexColor(1, 1, 1, 0.3)

        -- Store references
        iconButton.underline = underline
        iconButton.defensive = defensive
        iconButton.selected = false

        -- Click handler
        iconButton:SetScript("OnClick", function(self)
            self.selected = not self.selected
            if self.selected then
                self.underline:Show()
            else
                self.underline:Hide()
            end
            MS:UpdateSurvivalChances()
        end)

        -- Tooltip
        iconButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(defensive.name, 1, 1, 1, true)
            GameTooltip:AddLine((defensive.reduction * 100) .. "% " .. defensive.tooltip, 0.6, 1, 0.6)
            GameTooltip:AddLine("Click to toggle", 0.8, 0.8, 0.8)
            GameTooltip:Show()
        end)

        iconButton:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        defensiveButtons["external_" .. i] = iconButton
    end

    -- Create personal defensive icon buttons - filter by player class
    local playerClass = select(2, UnitClass("player"))
    local classPersonals = {}
    for _, defensive in ipairs(MS.personalsDB) do
        if defensive.class == playerClass then
            table.insert(classPersonals, defensive)
        end
    end

    for i, defensive in ipairs(classPersonals) do
        local iconButton = CreateFrame("Button", nil, defensivesFrame)
        iconButton:SetSize(24, 24)
        iconButton:SetPoint("TOPLEFT", defensivesFrame, "TOPLEFT", 80 + (i - 1) * 30, -50)

        -- Icon texture
        local iconTexture = iconButton:CreateTexture(nil, "ARTWORK")
        iconTexture:SetAllPoints(iconButton)
        iconTexture:SetTexture(C_Spell.GetSpellTexture(defensive.spellID))
        iconTexture:SetTexCoord(0.07, 0.93, 0.07, 0.93) -- Standard icon cropping

        -- Underline for selected state
        local underline = iconButton:CreateTexture(nil, "OVERLAY")
        underline:SetTexture("Interface\\Buttons\\WHITE8x8")
        underline:SetPoint("BOTTOMLEFT", iconButton, "BOTTOMLEFT", 0, -3)
        underline:SetPoint("BOTTOMRIGHT", iconButton, "BOTTOMRIGHT", 0, -3)
        underline:SetHeight(2)
        underline:SetVertexColor(0.6, 1, 0.6, 1) -- Light green underline for personals
        underline:Hide()

        -- Hover highlight
        local highlight = iconButton:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints(iconButton)
        highlight:SetTexture("Interface\\Buttons\\WHITE8x8")
        highlight:SetVertexColor(1, 1, 1, 0.3)

        -- Store references
        iconButton.underline = underline
        iconButton.defensive = defensive
        iconButton.selected = false

        -- Click handler
        iconButton:SetScript("OnClick", function(self)
            self.selected = not self.selected
            if self.selected then
                self.underline:Show()
            else
                self.underline:Hide()
            end
            MS:UpdateSurvivalChances()
        end)

        -- Tooltip
        iconButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(defensive.name, 1, 1, 1, true)
            if defensive.aoe_reduction and defensive.reduction == 0 then
                GameTooltip:AddLine((defensive.aoe_reduction * 100) .. "% " .. defensive.tooltip .. " (AOE only)", 0.6, 1,
                    0.6)
            elseif not defensive.aoe_reduction then
                GameTooltip:AddLine((defensive.reduction * 100) .. "% " .. defensive.tooltip, 0.6, 1, 0.6)
            else
                GameTooltip:AddLine(
                    (defensive.reduction * 100) ..
                    "% " .. defensive.tooltip .. " / " .. (defensive.aoe_reduction * 100) .. "% (AOE)", 0.6, 1, 0.6)
            end
            GameTooltip:AddLine("Click to toggle", 0.8, 0.8, 0.8)
            GameTooltip:Show()
        end)

        iconButton:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        defensiveButtons["personal_" .. i] = iconButton
    end

    -- Create group buff icon buttons
    for i, defensive in ipairs(MS.groupbuffsDB) do
        local iconButton = CreateFrame("Button", nil, defensivesFrame)
        iconButton:SetSize(24, 24)
        iconButton:SetPoint("TOPLEFT", defensivesFrame, "TOPLEFT", 80 + (i - 1) * 30, -80)

        -- Icon texture
        local iconTexture = iconButton:CreateTexture(nil, "ARTWORK")
        iconTexture:SetAllPoints(iconButton)
        iconTexture:SetTexture(C_Spell.GetSpellTexture(defensive.spellID))
        iconTexture:SetTexCoord(0.07, 0.93, 0.07, 0.93) -- Standard icon cropping

        -- Underline for selected state
        local underline = iconButton:CreateTexture(nil, "OVERLAY")
        underline:SetTexture("Interface\\Buttons\\WHITE8x8")
        underline:SetPoint("BOTTOMLEFT", iconButton, "BOTTOMLEFT", 0, -3)
        underline:SetPoint("BOTTOMRIGHT", iconButton, "BOTTOMRIGHT", 0, -3)
        underline:SetHeight(2)
        underline:SetVertexColor(1, 0.8, 0.4, 1) -- Orange/yellow underline for group buffs
        underline:Hide()

        -- Hover highlight
        local highlight = iconButton:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints(iconButton)
        highlight:SetTexture("Interface\\Buttons\\WHITE8x8")
        highlight:SetVertexColor(1, 1, 1, 0.3)

        -- Store references
        iconButton.underline = underline
        iconButton.defensive = defensive
        iconButton.selected = false

        -- Click handler
        iconButton:SetScript("OnClick", function(self)
            self.selected = not self.selected
            if self.selected then
                self.underline:Show()
            else
                self.underline:Hide()
            end
            MS:UpdateSurvivalChances()
        end)

        -- Tooltip
        iconButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(defensive.name, 1, 1, 1, true)
            if defensive.aoe_reduction then
                GameTooltip:AddLine((defensive.aoe_reduction * 100) .. "% " .. defensive.tooltip .. " (AOE only)", 0.6, 1,
                    0.6)
            elseif not defensive.aoe_reduction then
                GameTooltip:AddLine((defensive.reduction * 100) .. "% " .. defensive.tooltip, 0.6, 1, 0.6)
            else
                GameTooltip:AddLine(
                    (defensive.reduction * 100) ..
                    "% " .. defensive.tooltip .. " / " .. (defensive.aoe_reduction * 100) .. "% (AOE)", 0.6, 1, 0.6)
            end
            GameTooltip:AddLine("Click to toggle", 0.8, 0.8, 0.8)
            GameTooltip:Show()
        end)

        iconButton:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        defensiveButtons["group_" .. i] = iconButton
    end

    -- Incoming abilities list (moved down to make room for defensives) - Modern scrollbar
    local abilitiesFrame = CreateFrame("ScrollFrame", nil, contentFrame, "ScrollFrameTemplate")
    abilitiesFrame:SetPoint("TOPLEFT", defensivesFrame, "BOTTOMLEFT", 0, -8)
    abilitiesFrame:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", -16, 0)

    local abilitiesContent = CreateFrame("Frame", nil, abilitiesFrame)
    abilitiesContent:SetSize(500, 60) -- Set explicit size - width and height
    abilitiesFrame:SetScrollChild(abilitiesContent)

    -- Bottom bar (similar to title bar design)
    local bottomBar = CreateFrame("Frame", nil, MainFrame, "BackdropTemplate")
    bottomBar:SetPoint("BOTTOMLEFT", MainFrame, "BOTTOMLEFT", 1, 1)
    bottomBar:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", -1, 1)
    bottomBar:SetHeight(30)
    bottomBar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    bottomBar:SetBackdropColor(0.02, 0.02, 0.02, 0.7)
    bottomBar:SetBackdropBorderColor(0.15, 0.15, 0.15, 0.8)

    -- Support me button (matching the addon's button style)
    local supportButton = CreateFrame("Button", nil, bottomBar, "BackdropTemplate")
    supportButton:SetSize(90, 22)
    supportButton:SetPoint("LEFT", bottomBar, "LEFT", 8, 0)
    supportButton:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    supportButton:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    supportButton:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    local supportText = supportButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    supportText:SetPoint("CENTER", supportButton, "CENTER", 0, 0)
    supportText:SetText("Support me")
    supportText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    supportText:SetTextColor(0.8, 0.8, 0.6, 1)

    -- Support button hover and click
    local supportHighlight = supportButton:CreateTexture(nil, "HIGHLIGHT")
    supportHighlight:SetAllPoints(supportButton)
    supportHighlight:SetTexture("Interface\\Buttons\\WHITE8x8")
    supportHighlight:SetVertexColor(1, 1, 1, 0.2)

    supportButton:SetScript("OnClick", function()
        MS:Link("https://streamelements.com/muleyo/tip")
    end)

    -- Twitch button (matching the addon's button style)
    local twitchButton = CreateFrame("Button", nil, bottomBar, "BackdropTemplate")
    twitchButton:SetSize(70, 22)
    twitchButton:SetPoint("RIGHT", bottomBar, "RIGHT", -8, 0)
    twitchButton:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    twitchButton:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    twitchButton:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    local twitchText = twitchButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    twitchText:SetPoint("CENTER", twitchButton, "CENTER", 0, 0)
    twitchText:SetText("Twitch")
    twitchText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    twitchText:SetTextColor(0.8, 0.8, 0.6, 1)

    -- Twitch button hover and click
    local twitchHighlight = twitchButton:CreateTexture(nil, "HIGHLIGHT")
    twitchHighlight:SetAllPoints(twitchButton)
    twitchHighlight:SetTexture("Interface\\Buttons\\WHITE8x8")
    twitchHighlight:SetVertexColor(1, 1, 1, 0.2)

    twitchButton:SetScript("OnClick", function()
        MS:Link("https://twitch.tv/muleyo")
    end)

    local creatorText = bottomBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    creatorText:SetPoint("CENTER", bottomBar, "CENTER", 0, 0)
    creatorText:SetText("Created by muleyo")
    creatorText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    creatorText:SetTextColor(0.6, 0.6, 0.6, 1)

    -- Store references
    MainFrame.titleBar = titleBar
    MainFrame.logoIcon = logoIcon
    MainFrame.titleText = titleText
    MainFrame.contentFrame = contentFrame
    MainFrame.headerFrame = headerFrame
    MainFrame.dungeonText = dungeonText
    MainFrame.dungeonFrame = dungeonFrame
    MainFrame.dungeonIcons = dungeonIcons
    MainFrame.mythicConfigFrame = mythicConfigFrame
    MainFrame.keystoneSlider = keystoneSlider
    MainFrame.keystoneLevelText = keystoneLevelText
    MainFrame.tyrannicalIcon = tyrannicalIcon
    MainFrame.fortifiedIcon = fortifiedIcon
    MainFrame.statsFrame = statsFrame
    MainFrame.statTexts = statTexts
    MainFrame.defensivesFrame = defensivesFrame
    MainFrame.defensiveButtons = defensiveButtons
    MainFrame.abilitiesFrame = abilitiesFrame
    MainFrame.abilitiesContent = abilitiesContent
    MainFrame.logoFrame = logoFrame
    MainFrame.logoIcon = logoIcon
    MainFrame.bottomBar = bottomBar
    MainFrame.supportButton = supportButton
    MainFrame.twitchButton = twitchButton

    -- Initialize affix status variables
    MS.tyrannicalActive = false
    MS.fortifiedActive = false

    -- Initially hidden
    MainFrame:Hide()
end

function MS:ShowMainFrame()
    if not MainFrame then
        self:CreateMainFrame()
    end

    if MainFrame then
        -- Cancel any existing fade out animation
        if MainFrame.fadeOutAnimGroup then
            MainFrame.fadeOutAnimGroup:Stop()
        end

        -- Start from 0 alpha and show the frame
        MainFrame:SetAlpha(0)
        MainFrame:Show()

        -- Create fade in animation if it doesn't exist
        if not MainFrame.fadeInAnimGroup then
            MainFrame.fadeInAnimGroup = MainFrame:CreateAnimationGroup()
            MainFrame.fadeInAnim = MainFrame.fadeInAnimGroup:CreateAnimation("Alpha")
            MainFrame.fadeInAnim:SetFromAlpha(0)
            MainFrame.fadeInAnim:SetToAlpha(1)
            MainFrame.fadeInAnim:SetDuration(0.15)

            -- Ensure frame stays visible and at full alpha after fade in
            MainFrame.fadeInAnimGroup:SetScript("OnFinished", function()
                MainFrame:SetAlpha(1)
            end)
        end

        -- Start fade in animation
        MainFrame.fadeInAnimGroup:Play()
        self:UpdateMainFrame()
    end
end

function MS:HideMainFrame()
    if MainFrame then
        -- Cancel any existing fade in animation
        if MainFrame.fadeInAnimGroup then
            MainFrame.fadeInAnimGroup:Stop()
        end

        -- Create fade out animation if it doesn't exist
        if not MainFrame.fadeOutAnimGroup then
            MainFrame.fadeOutAnimGroup = MainFrame:CreateAnimationGroup()
            MainFrame.fadeOutAnim = MainFrame.fadeOutAnimGroup:CreateAnimation("Alpha")
            MainFrame.fadeOutAnim:SetFromAlpha(1)
            MainFrame.fadeOutAnim:SetToAlpha(0)
            MainFrame.fadeOutAnim:SetDuration(0.15)

            -- Hide the frame when animation completes
            MainFrame.fadeOutAnimGroup:SetScript("OnFinished", function()
                MainFrame:Hide()
            end)
        end

        -- Start fade out animation
        MainFrame.fadeOutAnimGroup:Play()
    end
end

function MS:ToggleMainFrame()
    if not MainFrame then
        self:ShowMainFrame()
        return
    end

    if MainFrame:IsShown() then
        self:HideMainFrame()
    else
        self:ShowMainFrame()
    end
end

function MS:UpdateMainFrame()
    if not MainFrame or not MainFrame:IsShown() then return end

    -- Update main display text
    if MS.selectedDungeonName then
        -- Show selected dungeon name
        MainFrame.dungeonText:SetText(MS.selectedDungeonName)
    else
        -- Show "Select a Dungeon" message
        MainFrame.dungeonText:SetText("Select a Dungeon")
    end

    -- Update character stats
    self:UpdateCharacterStats()

    -- Update abilities list (this will show instruction text if no dungeon is selected)
    self:UpdateAbilitiesList()

    -- Update survival chances
    self:UpdateSurvivalChances()
end

function MS:UpdateCharacterStats()
    if not MainFrame or not MainFrame.statTexts then return end

    -- Get current character stats
    local stamina = UnitStat("player", 3)
    local _, effectiveArmor = UnitArmor("player")
    local versatility = string.format("%.2f", (GetCombatRatingBonus(31) or 0)) .. "%"
    local avoidance = string.format("%.2f", (GetCombatRatingBonus(21) or 0)) .. "%"

    -- Update stat displays
    MainFrame.statTexts["Stamina"]:SetText("Stamina: " .. (stamina or 0))
    MainFrame.statTexts["Armor"]:SetText("Armor: " .. (effectiveArmor or 0))
    MainFrame.statTexts["Versatility"]:SetText("Versatility: " .. versatility)
    MainFrame.statTexts["Avoidance"]:SetText("Avoidance: " .. avoidance)
end

function MS:GetActiveDefensives()
    if not MainFrame or not MainFrame.defensiveButtons then return {} end

    local activeDefensives = {}
    for key, button in pairs(MainFrame.defensiveButtons) do
        if button.selected then
            table.insert(activeDefensives, button.defensive)
        end
    end

    return activeDefensives
end

function MS:UpdateAbilitiesList()
    if not MainFrame or not MainFrame.abilitiesContent then return end

    -- Clear existing ability frames and instruction text
    for _, frame in pairs(AbilityList) do
        if frame then
            frame:Hide()
            frame:ClearAllPoints()
            frame:SetParent(UIParent)
            frame:SetParent(nil)
        end
    end
    wipe(AbilityList)

    -- Force clear the scroll content completely
    if MainFrame.abilitiesContent then
        -- Hide the content temporarily
        MainFrame.abilitiesContent:Hide()

        -- Clear all children
        for i = 1, MainFrame.abilitiesContent:GetNumChildren() do
            local child = select(i, MainFrame.abilitiesContent:GetChildren())
            if child and child ~= MainFrame.instructionText then
                child:Hide()
                child:ClearAllPoints()
                child:SetParent(nil)
            end
        end

        -- Show the content again
        MainFrame.abilitiesContent:Show()
    end

    -- Clear any existing instruction text
    if MainFrame.instructionText then
        MainFrame.instructionText:Hide()
        MainFrame.instructionText:SetParent(nil)
        MainFrame.instructionText = nil
    end

    -- Show available abilities for selected dungeon (if any)
    if MS.selectedDungeon then
        local dungeonAbilities = MS:GetDungeonAbilities(MS.selectedDungeon)
        if dungeonAbilities then
            local yOffset = -5
            local abilityIndex = 1

            -- Separate abilities by source
            local bossAbilities = {}
            local trashAbilities = {}

            for spellID, abilityData in pairs(dungeonAbilities) do
                if abilityData.source == "boss" then
                    table.insert(bossAbilities, { spellID = spellID, data = abilityData })
                else
                    table.insert(trashAbilities, { spellID = spellID, data = abilityData })
                end
            end

            -- Create Boss Abilities section
            if #bossAbilities > 0 then
                local bossHeaderFrame = self:CreateCategoryHeader("Boss Abilities", abilityIndex)
                if bossHeaderFrame then
                    bossHeaderFrame:SetPoint("TOPLEFT", MainFrame.abilitiesContent, "TOPLEFT", 0, yOffset)
                    bossHeaderFrame:SetPoint("TOPRIGHT", MainFrame.abilitiesContent, "TOPRIGHT", 0, yOffset)
                    AbilityList[abilityIndex] = bossHeaderFrame
                    yOffset = yOffset - 25
                    abilityIndex = abilityIndex + 1
                end

                for _, ability in ipairs(bossAbilities) do
                    local abilityFrame = self:CreateAbilitySelectionFrame(ability.spellID, ability.data, abilityIndex)
                    if abilityFrame and MainFrame.abilitiesContent then
                        abilityFrame:SetPoint("TOPLEFT", MainFrame.abilitiesContent, "TOPLEFT", 0, yOffset)
                        abilityFrame:SetPoint("TOPRIGHT", MainFrame.abilitiesContent, "TOPRIGHT", 0, yOffset)

                        AbilityList[abilityIndex] = abilityFrame
                        yOffset = yOffset - 32 -- Increased spacing for full-width abilities
                        abilityIndex = abilityIndex + 1
                    end
                end

                yOffset = yOffset - 5 -- Extra spacing between categories
            end

            -- Create Trash Abilities section
            if #trashAbilities > 0 then
                local trashHeaderFrame = self:CreateCategoryHeader("Trash Abilities", abilityIndex)
                if trashHeaderFrame then
                    trashHeaderFrame:SetPoint("TOPLEFT", MainFrame.abilitiesContent, "TOPLEFT", 0, yOffset)
                    trashHeaderFrame:SetPoint("TOPRIGHT", MainFrame.abilitiesContent, "TOPRIGHT", 0, yOffset)
                    AbilityList[abilityIndex] = trashHeaderFrame
                    yOffset = yOffset - 25
                    abilityIndex = abilityIndex + 1
                end

                for _, ability in ipairs(trashAbilities) do
                    local abilityFrame = self:CreateAbilitySelectionFrame(ability.spellID, ability.data, abilityIndex)
                    if abilityFrame and MainFrame.abilitiesContent then
                        abilityFrame:SetPoint("TOPLEFT", MainFrame.abilitiesContent, "TOPLEFT", 0, yOffset)
                        abilityFrame:SetPoint("TOPRIGHT", MainFrame.abilitiesContent, "TOPRIGHT", 0, yOffset)

                        AbilityList[abilityIndex] = abilityFrame
                        yOffset = yOffset - 32
                        abilityIndex = abilityIndex + 1
                    end
                end
            end

            -- Update scroll child height with proper spacing
            MainFrame.abilitiesContent:SetSize(500, math.max(150, math.abs(yOffset) + 30))

            -- Force refresh the scroll frame
            MainFrame.abilitiesFrame:UpdateScrollChildRect()
            MainFrame.abilitiesContent:Show()
            MainFrame.abilitiesFrame:Show()
            -- Force complete UI refresh
            MainFrame.abilitiesContent:SetAlpha(0)
            C_Timer.After(0.01, function()
                if MainFrame.abilitiesContent then
                    MainFrame.abilitiesContent:SetAlpha(1)
                end
            end)
        else
            MainFrame.abilitiesContent:SetSize(500, 150)
            MainFrame.abilitiesFrame:UpdateScrollChildRect()
            MainFrame.abilitiesContent:Show()
        end
    else
        -- No dungeon selected - show instruction text
        local instructionText = MainFrame.abilitiesContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        instructionText:SetPoint("CENTER", MainFrame.abilitiesContent, "CENTER", 0, 0)
        instructionText:SetText("Select a dungeon above to see abilities")
        instructionText:SetTextColor(0.6, 0.6, 0.6, 1)
        instructionText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

        -- Set proper size and update scroll frame
        MainFrame.abilitiesContent:SetSize(500, 150)
        MainFrame.abilitiesFrame:UpdateScrollChildRect()
        MainFrame.abilitiesContent:Show()
        MainFrame.abilitiesFrame:Show()

        -- Store reference for cleanup
        MainFrame.instructionText = instructionText
    end
end

function MS:CreateAbilitySelectionFrame(spellID, abilityData, index)
    if not MainFrame or not MainFrame.abilitiesContent then return end

    local frame = CreateFrame("Button", nil, MainFrame.abilitiesContent, "BackdropTemplate")
    frame:SetHeight(28)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false,
        tileSize = 0,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    frame:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
    frame:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

    -- Ability icon
    local icon = frame:CreateTexture(nil, "ARTWORK")
    icon:SetSize(24, 24)
    icon:SetPoint("LEFT", frame, "LEFT", 6, 0)
    local spellTexture = C_Spell.GetSpellTexture(spellID)
    if spellTexture then
        icon:SetTexture(spellTexture)
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    else
        -- Fallback icon if spell texture not found
        icon:SetTexture("Interface\\Icons\\Spell_Shadow_ShadowBolt")
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end

    -- Ability name
    local nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameText:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    nameText:SetText(abilityData.name)
    nameText:SetTextColor(1, 1, 1, 1)
    nameText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")

    -- Calculate survival status and remaining health
    local willSurvive, survivalPercent, finalDamage, healthRemaining, overkillDamage = MS:CalculateSingleAbilitySurvival(
        abilityData)

    -- Also get the pre-mitigation scaled damage for comparison
    local scaledDamage = MS:ApplyKeystoneScaling(abilityData.damage, abilityData)

    -- Survival status text (right side)
    local survivalText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    survivalText:SetPoint("RIGHT", frame, "RIGHT", -8, 3)

    if willSurvive then
        survivalText:SetText("SURVIVE")
        survivalText:SetTextColor(0.2, 0.8, 0.2, 1) -- Green
    else
        survivalText:SetText("DEATH")
        survivalText:SetTextColor(0.8, 0.2, 0.2, 1) -- Red
    end
    survivalText:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")

    -- Health remaining text (right side, below survival)
    local healthText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    healthText:SetPoint("RIGHT", frame, "RIGHT", -8, -8)

    -- Show remaining health after ability hits or overkill damage
    if willSurvive then
        healthText:SetText(string.format("%.0fk HP left", healthRemaining / 1000))
        healthText:SetTextColor(0.2, 0.8, 0.2, 1) -- Green for survival
    else
        healthText:SetText(string.format("%.0fk overkill", overkillDamage / 1000))
        healthText:SetTextColor(0.8, 0.2, 0.2, 1) -- Red for death
    end
    healthText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")

    -- Selection underline (similar to defensive system)
    local underline = frame:CreateTexture(nil, "OVERLAY")
    underline:SetTexture("Interface\\Buttons\\WHITE8x8")
    underline:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 2, 1)
    underline:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 1)
    underline:SetHeight(2)
    underline:SetVertexColor(0.3, 0.8, 1, 1) -- Blue underline for abilities
    underline:Hide()

    -- Hover highlight
    local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints(frame)
    highlight:SetTexture("Interface\\Buttons\\WHITE8x8")
    highlight:SetVertexColor(1, 1, 1, 0.1)

    -- Store references
    frame.spellID = spellID
    frame.abilityData = abilityData
    frame.underline = underline
    frame.selected = false
    frame.survivalText = survivalText
    frame.healthText = healthText

    -- Tooltip
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetSpellByID(spellID)
        GameTooltip:AddLine(" ") -- Empty line
        GameTooltip:AddLine("Damage: " .. abilityData.damage, 1, 1, 1)
        GameTooltip:AddLine("Type: " .. abilityData.type, 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)

    frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    -- Click handler for selection
    frame:SetScript("OnClick", function(self)
        self.selected = not self.selected
        if self.selected then
            self.underline:Show()
            self:SetBackdropColor(0.1, 0.2, 0.4, 0.9)
        else
            self.underline:Hide()
            self:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
        end

        -- Trigger survival calculation update
        MS:UpdateSurvivalChances()
    end)

    frame:Show()
    return frame
end

function MS:CreateCategoryHeader(categoryName, index)
    if not MainFrame or not MainFrame.abilitiesContent then return end

    local frame = CreateFrame("Frame", nil, MainFrame.abilitiesContent)
    frame:SetHeight(20)

    -- Header text
    local headerText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    headerText:SetPoint("LEFT", frame, "LEFT", 5, 0)
    headerText:SetText(categoryName)
    headerText:SetTextColor(0.9, 0.8, 0.2, 1) -- Golden color for headers
    headerText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")

    -- Underline
    local underline = frame:CreateTexture(nil, "OVERLAY")
    underline:SetTexture("Interface\\Buttons\\WHITE8x8")
    underline:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 5, 2)
    underline:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 2)
    underline:SetHeight(1)
    underline:SetVertexColor(0.9, 0.8, 0.2, 0.8)

    frame:Show()
    return frame
end

function MS:UpdateSurvivalChances()
    -- Update existing ability frames instead of recreating them
    for _, frame in pairs(AbilityList) do
        if frame and frame.abilityData and frame.survivalText and frame.healthText then
            -- Recalculate survival for this ability
            local willSurvive, survivalPercent, finalDamage, healthRemaining, overkillDamage = self
                :CalculateSingleAbilitySurvival(frame
                    .abilityData)

            -- Update survival text
            if willSurvive then
                frame.survivalText:SetText("SURVIVE")
                frame.survivalText:SetTextColor(0.2, 0.8, 0.2, 1) -- Green
            else
                frame.survivalText:SetText("DEATH")
                frame.survivalText:SetTextColor(0.8, 0.2, 0.2, 1) -- Red
            end

            -- Update health remaining text
            if willSurvive then
                frame.healthText:SetText(string.format("%.0fk HP left", healthRemaining / 1000))
                frame.healthText:SetTextColor(0.2, 0.8, 0.2, 1) -- Green for survival
            else
                frame.healthText:SetText(string.format("%.0fk overkill", overkillDamage / 1000))
                frame.healthText:SetTextColor(0.8, 0.2, 0.2, 1) -- Red for death
            end
        end
    end
end
