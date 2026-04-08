-- _MidnightCompat - MainMenuBar shim
-- Author: Hentaya

local Compat = _G.MidnightCompat

-- Create a simple stand-in MainMenuBar frame for legacy addons.
-- We do this at LOAD time, not on events, so anything that runs later
-- always sees a non-nil global.

if not _G.MainMenuBar then
    local bar = CreateFrame("Frame", "MainMenuBar", UIParent)
    bar:SetSize(512, 128)
    bar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)

    _G.MainMenuBar = bar

    if Compat then
        Compat.MarkShimApplied("MainMenuBar")
    end
end