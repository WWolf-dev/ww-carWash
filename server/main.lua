if FrameworkUse == "ESX" then
    if versionESX == "older" then
        ESX = nil
        TriggerEvent(getSharedObjectEvent, function(obj) ESX = obj end)
    elseif versionESX == "newer" then
        FrameworkExport()
    end

    ESX.RegisterServerCallback("ww-carWash:Server:CheckMoney", function(source, cb, washType)
        local xPlayer = ESX.GetPlayerFromId(source)
        local washPrice = Prices[washType] or 0

        if washPrice == 0 then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'LAVAGE',
                description = "Type de lavage invalide !",
                type = 'error',
                duration = 3500,
            })
            cb(false)
            return
        end

        if DebugMode then
            print("Type : ", washType, " ", "Price : ", washPrice)
        end

        local xMoney = xPlayer.getMoney()

        if DebugMode then
            print("Money : ", xMoney)
        end

        if xMoney >= washPrice then
            xPlayer.removeMoney(washPrice)
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'LAVAGE',
                description = "Vous avez payé " .. washPrice .. " $ pour votre lavage",
                type = 'success',
                duration = 3500,
            })
            cb(true)
        else
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'LAVAGE',
                description = "Vous n'avez pas assez d'argent sur vous pour payer un lavage",
                type = 'error',
                duration = 3500,
            })
            cb(false)
        end
    end)


    RegisterServerEvent("ww-carWash:Server:GiveItemManualWash")
    AddEventHandler("ww-carWash:Server:GiveItemManualWash", function()
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.addInventoryItem(ManualWash.ItemUseToWash, ManualWash.NumberGivenToPlayer)

        if DebugMode then
            print("Item : ", ManualWash.ItemUseToWash, " ", "Number Given : ", ManualWash.NumberGivenToPlayer)
        end

    end)

    RegisterServerEvent("ww-carWash:Server:RemoveItemManualWash")
    AddEventHandler("ww-carWash:Server:RemoveItemManualWash", function()
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.removeInventoryItem(ManualWash.ItemUseToWash, 1)

        if DebugMode then
            print("Item : ", ManualWash.ItemUseToWash, " ", "Number Removed : ", 1)
        end

    end)

    ESX.RegisterUsableItem(ManualWash.ItemUseToWash, function(source)
        TriggerClientEvent("ww-carWash:Client:ManualWash", source)
    end)

    -- Soon QBCore support
elseif FrameworkUse == "QBCore" then
    return nil
end
