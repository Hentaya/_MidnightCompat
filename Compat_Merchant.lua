-- _MidnightCompat - Merchant API shims
-- Author: Hentaya

local Compat = _G.MidnightCompat

-- Polyfill legacy GetMerchantItemInfo for addons that still expect
-- the old global on 12.0+ clients.
--
-- Legacy signature:
-- name, texture, price, quantity, numAvailable, isPurchasable, isUsable, extendedCost

if not _G.GetMerchantItemInfo and C_MerchantFrame and C_MerchantFrame.GetItemInfo then
    function _G.GetMerchantItemInfo(index)
        local info = C_MerchantFrame.GetItemInfo(index)
        if not info then
            return nil
        end

        return info.name
            , info.texture
            , info.price
            , info.quantity
            , info.numAvailable
            , info.isPurchasable
            , info.isUsable
            , info.hasExtendedCost
    end

    if Compat then
        Compat.MarkShimApplied("GetMerchantItemInfo")
    end
end