# _MidnightCompat

_MidnightCompat is a small World of Warcraft addon that restores selected legacy globals and API behavior for older addons broken by Retail 12.x changes.

## What it does

This addon provides compatibility shims for older addons that still expect removed or renamed Blizzard APIs and globals.

Current shims include:
- MainMenuBar compatibility
- GetMerchantItemInfo compatibility

## Goal

The goal is to avoid patching multiple third-party addons locally just to survive API drift in newer Retail clients.

## Scope

_MidnightCompat is intended for:
- missing Blizzard globals
- renamed Blizzard APIs
- simple compatibility aliases
- harmless placeholder objects or frames when needed

It is not intended to become a shadow fork of other addons or to replace real upstream fixes.

## Installation

Copy the `_MidnightCompat` folder into:

```text
World of Warcraft\_retail_\Interface\AddOns\
```

## Status

Active local compatibility project for Retail 12.x addon breakage.

## Author

Hentaya
