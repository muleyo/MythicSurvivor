local addonName, MS = ...

function MS:Link(url)
    if not url then return end
    StaticPopupDialogs["MSPopup"] = nil
    StaticPopupDialogs["MSPopup"] = {
        text = "|cffcccc99Mythic Survivor|r\n\n|cffffcc00Copy the link below ( CTRL + C )|r",
        button1 = CLOSE,
        whileDead = true,
        hideOnEscape = true,
        hasEditBox = true,
        editBoxWidth = 200,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide()
        end,
        OnShow = function(self, data)
            self.EditBox:SetText(data.url)
            self.EditBox:HighlightText()
            self.EditBox:SetScript("OnKeyDown", function(_, key)
                if key == "C" and IsControlKeyDown() then
                    C_Timer.After(0.3, function()
                        self.EditBox:GetParent():Hide()
                        UIErrorsFrame:AddMessage("Link copied to clipboard")
                    end)
                end
            end)
        end,
    }
    StaticPopup_Show("MSPopup", "", "", { url = url })
end
