# CDE Wraith - CDECAD x Wraith ARS 2X Integration

Connects **Wraith ARS 2X** (police radar & plate reader) to your **CDECAD** system. When plates are scanned or locked by the plate reader, this script queries your CAD for vehicle and owner information and displays the results in-game.

## Features

- **Automatic plate lookups** on plate scan or lock via Wraith ARS 2X events
- **Vehicle info** - make, model, color, year, registration & insurance status
- **Owner info** - name, DOB, license status, warrants, dangerous flags
- **BOLO matching** - checks both vehicle plate BOLOs and owner BOLOs
- **Flag detection** - stolen vehicles, expired registration, no insurance, impounded, etc.
- **Auto-lock on flagged plates** - automatically locks the plate reader when a flagged plate is scanned
- **NUI popup** - sleek, non-intrusive on-screen display with alert levels
- **Chat messages** - color-coded chat notifications for quick reference
- **Cooldown caching** - prevents API spam for the same plate
- **Framework support** - works standalone, with QBCore, or ESX for job permission checks
- **Manual lookup** - `/platelookup [plate]` command for manual queries

## Requirements

- [Wraith ARS 2X](https://github.com/WolfKnight98/wk_wars2x) v1.3.1+
- A CDECAD instance with a valid FiveM API key
- FiveM server (cerulean+)

## Installation

1. Download and place `cde-wraith` in your server's `resources` folder
2. Add `ensure cde-wraith` to your `server.cfg` (after `ensure wk_wars2x`)
3. Edit `shared/config.lua`:
   - Set `Config.API_URL` to your CDECAD API URL (e.g. `https://cad.yourserver.com/api`)
   - Set `Config.API_KEY` to your community's FiveM API key
   - Set `Config.COMMUNITY_ID` to your Discord guild ID or CDECAD community ID
4. Configure permissions if you want to restrict usage to specific jobs
5. Restart your server

## Configuration

### Plate Reader Behavior

| Setting | Default | Description |
|---------|---------|-------------|
| `LookupOnScan` | `false` | Look up every plate that passes the reader |
| `LookupOnLock` | `true` | Look up plates when manually locked |
| `AutoLockFlagged` | `true` | Auto-lock the reader when a flagged plate is scanned |
| `LookupCooldown` | `30` | Seconds between lookups for the same plate |

### Alert Levels

- **CLEAN** (green) - No flags, vehicle and owner are clear
- **CAUTION** (yellow) - Minor flags (expired registration, no insurance, etc.)
- **HIGH ALERT** (red, pulsing) - Stolen, BOLO, warrants, or dangerous person

### Flags Detected

| Flag | Trigger |
|------|---------|
| STOLEN | Vehicle marked as stolen in CAD |
| BOLO ALERT | Active BOLO matching this plate |
| OWNER BOLO | Active BOLO matching the vehicle owner |
| ACTIVE WARRANTS | Owner has outstanding warrants |
| DANGEROUS PERSON | Owner flagged as dangerous |
| MISSING PERSON | Owner flagged as missing |
| IMPOUNDED | Vehicle is impounded |
| REG EXPIRED/SUSPENDED/REVOKED | Registration issues |
| NO INSURANCE | No valid insurance |

## API Endpoint

This script uses the `/api/civilian/fivem-plate-lookup/:plate` endpoint on your CDECAD backend. This endpoint returns combined vehicle, owner, BOLO, and flag data in a single request.

## Commands

| Command | Description |
|---------|-------------|
| `/platelookup [plate]` | Manually look up a plate number |

## Controls

- **Backspace** - Dismiss the plate reader popup
