--[[
    CDE Wraith ARS 2X Integration - Client
    Handles displaying plate reader results to the player
]]

local isDisplaying = false
local hideTimer = nil

-- =============================================================================
-- RECEIVE PLATE RESULTS FROM SERVER
-- =============================================================================

RegisterNetEvent('cde-wraith:plateResult')
AddEventHandler('cde-wraith:plateResult', function(data, cam)
    if not data then return end

    -- Show chat message
    if Config.Display.ShowChat then
        ShowChatResult(data, cam)
    end

    -- Show NUI popup
    if Config.Display.ShowPopup and data.found then
        ShowNUIResult(data, cam)
    end

    -- Show ox_lib notification
    if Config.Notifications.UseOxLib then
        ShowOxLibNotification(data, cam)
    end
end)

-- =============================================================================
-- CHAT DISPLAY
-- =============================================================================

function ShowChatResult(data, cam)
    local plate = data.plate or 'UNKNOWN'
    local camLabel = cam:upper()

    if not data.found then
        TriggerEvent('chat:addMessage', {
            args = { string.format(Config.Display.ChatNotFoundFormat, plate) }
        })
        return
    end

    local veh = data.vehicle or {}
    local owner = data.owner or {}
    local ownerName = owner.name or 'Unknown'
    local vehDesc = string.format('%s %s %s', veh.color or '', veh.year or '', veh.model or '')

    if data.alertLevel == 'none' then
        TriggerEvent('chat:addMessage', {
            args = { string.format(Config.Display.ChatCleanFormat,
                plate, veh.color or '', veh.year or '', veh.model or '', ownerName
            ) }
        })
    else
        local flagStr = table.concat(data.flags or {}, ', ')
        TriggerEvent('chat:addMessage', {
            args = { string.format(Config.Display.ChatFlagFormat,
                plate, veh.color or '', veh.year or '', veh.model or '', ownerName, flagStr
            ) }
        })
    end
end

-- =============================================================================
-- NUI DISPLAY
-- =============================================================================

function ShowNUIResult(data, cam)
    isDisplaying = true

    SendNUIMessage({
        action = 'showPlateResult',
        data = data,
        cam = cam,
    })

    SetNuiFocus(false, false) -- Don't steal mouse focus

    -- Auto-hide after duration
    if Config.Display.DisplayDuration > 0 then
        -- Cancel any existing hide timer
        if hideTimer then
            hideTimer = nil
        end

        local thisTimer = GetGameTimer()
        hideTimer = thisTimer

        SetTimeout(Config.Display.DisplayDuration * 1000, function()
            if hideTimer == thisTimer then
                HideNUIResult()
            end
        end)
    end
end

function HideNUIResult()
    isDisplaying = false
    hideTimer = nil

    SendNUIMessage({
        action = 'hidePlateResult',
    })
end

-- =============================================================================
-- OX_LIB NOTIFICATIONS
-- =============================================================================

function ShowOxLibNotification(data, cam)
    local plate = data.plate or 'UNKNOWN'

    if not data.found then
        lib.notify({
            title = 'Plate Reader',
            description = plate .. ' - Not in system',
            type = 'warning',
            position = Config.Notifications.Position,
            duration = Config.Notifications.Duration,
        })
        return
    end

    local veh = data.vehicle or {}
    local owner = data.owner or {}

    -- Determine notification type based on alert level
    local notifType = 'success'
    if data.alertLevel == 'caution' then
        notifType = 'warning'
    elseif data.alertLevel == 'alert' then
        notifType = 'error'
    end

    -- Build description
    local desc = ''
    if Config.Notifications.Detailed then
        desc = string.format('%s %s %s %s', veh.color or '', veh.year or '', veh.make or '', veh.model or '')
        desc = desc .. '\nOwner: ' .. (owner.name or 'Unknown')
        if owner.licenseStatus then
            desc = desc .. '\nLicense: ' .. owner.licenseStatus
        end
        if data.flags and #data.flags > 0 then
            desc = desc .. '\nFlags: ' .. table.concat(data.flags, ', ')
        end
        if data.bolo then
            desc = desc .. '\nBOLO: ' .. (data.bolo.reason or 'Active')
        end
    else
        if data.alertLevel == 'none' then
            desc = (owner.name or 'Unknown') .. ' - Clean'
        else
            desc = (owner.name or 'Unknown') .. ' - ' .. table.concat(data.flags or {}, ', ')
        end
    end

    lib.notify({
        title = 'Plate: ' .. plate,
        description = desc,
        type = notifType,
        position = Config.Notifications.Position,
        duration = Config.Notifications.Duration,
    })
end

-- =============================================================================
-- NUI CALLBACKS
-- =============================================================================

RegisterNUICallback('closePlateResult', function(data, cb)
    HideNUIResult()
    cb('ok')
end)

-- =============================================================================
-- KEY BINDING TO DISMISS
-- =============================================================================

-- Press Backspace to dismiss the plate result popup
CreateThread(function()
    while true do
        Wait(0)
        if isDisplaying then
            if IsControlJustReleased(0, 177) then -- Backspace
                HideNUIResult()
            end
        else
            Wait(500) -- Reduce CPU usage when not displaying
        end
    end
end)
