local function DrawText3D(text, coords, offset, scale, font, r, g, b, a)
    r = r or 255
    g = g or 255
    b = b or 255
    a = a or 255
    scale = scale or 0.4
    font = font or 4
    offset = offset or 0.5

    local onScreen, _, _ = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not onScreen then return end
    SetTextFont(font)
    EndTextCommandDisplayText(0.0, 0.0)
    SetDrawOrigin(coords.x, coords.y, coords.z + offset, 0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 150)
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

RegisterNetEvent("nl_chataddons:client:sendMessage", function (data)
    local target = GetPlayerFromServerId(data.target)
	if target == -1 then return end
    local targetPed = GetPlayerPed(target)
    if not DoesEntityExist(targetPed) then return end
    local targetCoords = GetEntityCoords(targetPed)
    local playerCoords = GetEntityCoords(PlayerPedId())

    if #(targetCoords - playerCoords) <= data.drawDistance then
        CreateThread(function ()
            local displaying = true

            SetTimeout(5000, function()
                if displaying then
                    displaying = false
                end
            end)

            while displaying do
                Wait(0)
                targetCoords = GetEntityCoords(targetPed)
                DrawText3D(data.message, targetCoords)
            end
        end)
    end
end)

if not Config.AvailableCommands.here.enabled and not Config.AvailableCommands.status.enabled then
    return
end

local statusList, hereList, drawingMsg = {}, {}, {}
local loopIsRunning

RegisterNetEvent("nl_chataddons:client:syncHere", function (sync)
    hereList = sync
end)

RegisterNetEvent("nl_chataddons:client:syncStatus", function (sync)
    statusList = sync
end)

local function toggleTextLoop(data)
    if loopIsRunning then return end
    loopIsRunning = true

    CreateThread(function (threadId)
        while loopIsRunning do
            Wait(0)
            for i, data in pairs(drawingMsg) do
                if data.coords then
                    DrawText3D(data.message, data.coords)
                elseif data.entity then
                    local targetCoords = GetEntityCoords(data.entity)
                    DrawText3D(data.message, targetCoords)
                end
            end
        end
    end)
end

CreateThread(function ()
    while true do
        Wait(1500)

        local temporaryList = {}
        local shouldEnable = false
        local playerCoords = GetEntityCoords(PlayerPedId())
        if Config.AvailableCommands.here.enabled then
            for client, data in pairs(hereList) do
                if #(playerCoords - data.coords.xyz) <= Config.AvailableCommands.here.drawDistance then
                    temporaryList[#temporaryList+1] = {
                        coords = data.coords,
                        message = data.message
                    }
                end
            end
        end

        if Config.AvailableCommands.status.enabled then
            for client, data in pairs(statusList) do
                if NetworkDoesEntityExistWithNetworkId(data.netId) then
                    local entity = NetworkGetEntityFromNetworkId(data.netId)
                    local targetCoords = GetEntityCoords(entity)

                    if #(playerCoords - targetCoords) <= Config.AvailableCommands.status.drawDistance then
                        temporaryList[#temporaryList+1] = {
                            entity = entity,
                            message = data.message
                        }
                    end
                end
            end
        end

        drawingMsg = temporaryList
        if not next(temporaryList) then
            loopIsRunning = false
        else
            toggleTextLoop()
        end
    end
end)