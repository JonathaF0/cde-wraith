--[[
    CDE Wraith ARS 2X Integration - Server
    Handles Wraith events and queries the CDECAD plate reader API
]]

-- Cache for recent lookups to avoid spamming the API
local plateCache = {}

-- Debug print helper
local function DebugPrint(...)
    if Config.Debug then
        print('[CDE-Wraith]', ...)
    end
end

-- =============================================================================
-- API REQUEST
-- =============================================================================

local function LookupPlate(plate, source, cam)
    -- Clean the plate (Wraith pads plates with spaces to 8 chars)
    local cleanPlate = plate:gsub('%s', '')

    if cleanPlate == '' then return end

    -- Check cooldown cache
    local cacheKey = cleanPlate:upper()
    local now = os.time()

    if plateCache[cacheKey] and (now - plateCache[cacheKey].time) < Config.PlateReader.LookupCooldown then
        DebugPrint('Cache hit for plate:', cleanPlate)
        -- Send cached result to client
        TriggerClientEvent('cde-wraith:plateResult', source, plateCache[cacheKey].data, cam)
        return
    end

    local url = Config.API_URL .. '/civilian/fivem-plate-lookup/' .. cleanPlate .. '?communityId=' .. Config.COMMUNITY_ID

    DebugPrint('Looking up plate:', cleanPlate, 'URL:', url)

    PerformHttpRequest(url, function(statusCode, responseText, responseHeaders)
        DebugPrint('Response:', statusCode, responseText)

        if statusCode ~= 200 or not responseText or responseText == '' then
            DebugPrint('Lookup failed - status:', statusCode)
            TriggerClientEvent('cde-wraith:plateResult', source, {
                success = true,
                found = false,
                plate = cleanPlate,
            }, cam)
            return
        end

        local ok, data = pcall(json.decode, responseText)
        if not ok or not data then
            DebugPrint('Failed to decode response')
            return
        end

        -- Cache the result
        plateCache[cacheKey] = {
            time = now,
            data = data,
        }

        -- Send result to the client
        TriggerClientEvent('cde-wraith:plateResult', source, data, cam)

        -- Log the lookup
        local playerName = GetPlayerName(source) or 'Unknown'
        if data.found then
            print(('[CDE-Wraith] %s looked up plate %s via %s reader - Alert: %s'):format(
                playerName, cleanPlate, cam, data.alertLevel or 'none'
            ))
        end

    end, 'GET', '', {
        ['Content-Type'] = 'application/json',
        ['x-api-key'] = Config.API_KEY,
    })
end

-- =============================================================================
-- WRAITH ARS 2X EVENT HANDLERS
-- =============================================================================

-- NOTE: wk:onPlateScanned is intentionally NOT hooked.
-- Scanning fires constantly (30+ plates/min per player) and would overwhelm the API.
-- Only locked plates trigger a CAD lookup.

RegisterNetEvent('wk:onPlateLocked')
AddEventHandler('wk:onPlateLocked', function(cam, plate, index)
    if not Config.PlateReader.LookupOnLock then return end

    local src = source
    DebugPrint(GetPlayerName(src) .. ' locked plate ' .. plate .. ' on ' .. cam .. ' reader')

    -- Check permissions
    if Config.Permissions.RestrictToJobs then
        TriggerEvent('cde-wraith:checkPermission', src, function(allowed)
            if allowed then
                LookupPlate(plate, src, cam)
            end
        end)
    else
        LookupPlate(plate, src, cam)
    end
end)

-- =============================================================================
-- PERMISSION CHECK
-- =============================================================================

RegisterNetEvent('cde-wraith:checkPermission')
AddEventHandler('cde-wraith:checkPermission', function(src, callback)
    -- If no framework restriction, allow everyone
    if not Config.Permissions.RestrictToJobs then
        callback(true)
        return
    end

    if Config.Permissions.UseQBCore then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local job = Player.PlayerData.job.name
            for _, allowedJob in ipairs(Config.Permissions.AllowedJobs) do
                if job == allowedJob then
                    callback(true)
                    return
                end
            end
        end
        callback(false)

    elseif Config.Permissions.UseESX then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            local job = xPlayer.getJob().name
            for _, allowedJob in ipairs(Config.Permissions.AllowedJobs) do
                if job == allowedJob then
                    callback(true)
                    return
                end
            end
        end
        callback(false)

    else
        -- No framework - allow all
        callback(true)
    end
end)

-- =============================================================================
-- MANUAL LOOKUP COMMAND (for testing)
-- =============================================================================

RegisterCommand('platelookup', function(source, args)
    if source == 0 then
        print('[CDE-Wraith] This command can only be used in-game')
        return
    end

    local plate = table.concat(args, ' ')
    if plate == '' then
        TriggerClientEvent('chat:addMessage', source, {
            args = { '^1[CDE-Wraith]', 'Usage: /platelookup [plate number]' }
        })
        return
    end

    LookupPlate(plate, source, 'manual')
end, false)

-- =============================================================================
-- CACHE CLEANUP
-- =============================================================================

-- Clear stale cache entries every 5 minutes
CreateThread(function()
    while true do
        Wait(300000) -- 5 minutes
        local now = os.time()
        local cleared = 0
        for k, v in pairs(plateCache) do
            if (now - v.time) > Config.PlateReader.LookupCooldown * 2 then
                plateCache[k] = nil
                cleared = cleared + 1
            end
        end
        if cleared > 0 then
            DebugPrint('Cleared', cleared, 'stale cache entries')
        end
    end
end)

print('[CDE-Wraith] Wraith ARS 2X <> CDECAD integration loaded')
