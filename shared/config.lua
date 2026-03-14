--[[
    CDE Wraith ARS 2X Integration - Configuration
    Connects Wraith ARS 2X plate reader to your CDECAD system
]]

Config = {}

-- =============================================================================
-- API CONFIGURATION
-- =============================================================================

-- Your CDECAD API URL (no trailing slash)
Config.API_URL = 'https://your-cdecad-instance.com/api'

-- Your CDECAD API Key (get this from your CDECAD admin panel > FiveM Settings)
Config.API_KEY = 'your-api-key-here'

-- Your Community ID (Discord Guild ID or CDECAD community Mongo ID)
Config.COMMUNITY_ID = '1234567890123456789'

-- =============================================================================
-- PLATE READER SETTINGS
-- =============================================================================

Config.PlateReader = {
    -- Look up plates when they are locked by the officer
    -- This is the only trigger - scans are NOT queried to avoid API overload
    -- (30 scans/min × 40 players × 40 communities = 48k req/min)
    LookupOnLock = true,

    -- Cooldown between lookups for the same plate (seconds)
    -- Prevents duplicate queries if an officer locks the same plate quickly
    LookupCooldown = 10,
}

-- =============================================================================
-- DISPLAY SETTINGS
-- =============================================================================

Config.Display = {
    -- How long to show the plate results popup (seconds)
    -- Set to 0 for manual dismiss only
    DisplayDuration = 15,

    -- Show the NUI popup with detailed results
    ShowPopup = true,

    -- Also show a chat message with results
    ShowChat = true,

    -- Chat message format for clean plates
    ChatCleanFormat = '~g~[PLATE READER]~w~ %s | %s %s %s | Owner: %s | ~g~CLEAN',

    -- Chat message format for flagged plates
    ChatFlagFormat = '~r~[PLATE READER]~w~ %s | %s %s %s | Owner: %s | ~r~FLAGS: %s',

    -- Chat message for plates not found in CAD
    ChatNotFoundFormat = '~y~[PLATE READER]~w~ %s | ~y~NOT IN SYSTEM',
}

-- =============================================================================
-- PERMISSIONS
-- =============================================================================

Config.Permissions = {
    -- Restrict plate reader lookups to specific jobs
    -- Set to false to allow all players (anyone with Wraith access)
    RestrictToJobs = true,

    -- Jobs that can use the plate reader integration
    -- Only applies if RestrictToJobs = true
    AllowedJobs = {
        'police',
        'sheriff',
        'statepolice',
        'trooper',
        'highway',
        'ranger',
        'marshal',
    },

    -- Use QBCore job system for permission checks
    UseQBCore = false,

    -- Use ESX job system for permission checks
    UseESX = false,

    -- If both UseQBCore and UseESX are false, all players are allowed
    -- (useful for standalone servers)
}

-- =============================================================================
-- NOTIFICATIONS (ox_lib)
-- =============================================================================

Config.Notifications = {
    -- Use ox_lib notifications instead of (or in addition to) the NUI popup
    UseOxLib = false,

    -- Notification position (ox_lib positions)
    Position = 'top-right',

    -- Notification duration (ms)
    Duration = 8000,

    -- Show detailed ox_lib notification (multi-line with vehicle + owner info)
    Detailed = true,
}

-- =============================================================================
-- DEBUG
-- =============================================================================

Config.Debug = false
