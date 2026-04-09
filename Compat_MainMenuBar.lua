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

-- Legacy MainMenuBarArtFrame shim for older addons.
if not _G.MainMenuBarArtFrame and _G.MainMenuBar then
	_G.MainMenuBarArtFrame = _G.MainMenuBar
end

-- Some older code expects a PageNumber field on MainMenuBarArtFrame.
do
	local pageText =
		_G.MainMenuBarPageNumber
		or (_G.MainMenuBar and _G.MainMenuBar.ActionBarPageNumber and _G.MainMenuBar.ActionBarPageNumber.Text)

	if _G.MainMenuBarArtFrame and pageText and not _G.MainMenuBarArtFrame.PageNumber then
		_G.MainMenuBarArtFrame.PageNumber = pageText
	end
end