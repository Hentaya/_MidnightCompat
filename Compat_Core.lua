-- _MidnightCompat - Core
-- Author: Hentaya

local AddonName = ...
local Compat = _G.MidnightCompat or {}

Compat.AddonName = AddonName
Compat.Version = "1.1"
Compat.AppliedShims = Compat.AppliedShims or {}

function Compat.MarkShimApplied(shimName)
    Compat.AppliedShims[shimName] = true
end

_G.MidnightCompat = Compat