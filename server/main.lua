local statusList, hereList = {}, {}

AddEventHandler('playerDropped', function(reason)
    local client = source
    if hereList[client] then
        hereList[client] = nil
        TriggerClientEvent("nl_chataddons:client:syncHere", -1, hereList)
    end

    if statusList[client] then
        statusList[client] = nil
        TriggerClientEvent("nl_chataddons:client:syncStatus", -1, statusList)
    end
end)

if Config.AvailableCommands.here.enabled then
    AddEventHandler('playerJoining', function()
        local client = source
        if not next(hereList) then return end
        TriggerClientEvent("nl_chataddons:client:syncHere", -1, hereList)
    end)
    
    RegisterCommand(Config.AvailableCommands.here.commandName, function (client, args)
        if hereList[client] then
            hereList[client] = nil
            TriggerClientEvent("nl_chataddons:client:syncHere", -1, hereList)
            return
        end

        if args and #args >= 1 then
            local msg = table.concat(args, ' ')
            hereList[client] = {
                message = msg,
                coords = GetEntityCoords(GetPlayerPed(client))
            }

            TriggerClientEvent("nl_chataddons:client:syncHere", -1, hereList)
        end
    end)
end

if Config.AvailableCommands.status.enabled then
    AddEventHandler('playerJoining', function()
        local client = source
        if not next(statusList) then return end
        TriggerClientEvent("nl_chataddons:client:syncStatus", -1, statusList)
    end)

    RegisterCommand(Config.AvailableCommands.status.commandName, function (client, args)
        if statusList[client] then
            statusList[client] = nil
            TriggerClientEvent("nl_chataddons:client:syncStatus", -1, statusList)
            return
        end

        if args and #args >= 1 then
            local msg = table.concat(args, ' ')
            statusList[client] = {
                message = msg,
                netId = NetworkGetNetworkIdFromEntity(GetPlayerPed(client))
            }

            TriggerClientEvent("nl_chataddons:client:syncStatus", -1, statusList)
        end
    end)
end

if Config.AvailableCommands.try.enabled then
    RegisterCommand(Config.AvailableCommands.try.commandName, function (client)
        local number = math.random(0,1)
        local message = Config.AvailableCommands.try.results[number]
        if not message then return end
        TriggerClientEvent("nl_chataddons:client:sendMessage", -1, {
            target = client,
            drawDistance = Config.AvailableCommands.try.drawDistance,
            message = message
        })
    end)
end