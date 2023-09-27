-- Determine the framework in use (ESX or QBCore)
if FrameworkUse == "ESX" then 

    -- Check the ESX Version and initialize the framework
    if versionESX == "older" then 
        ESX = nil
        CreateThread(function()
            -- Wait for ESX to be initialized
            while ESX == nil do
                TriggerEvent(getSharedObjectEvent, function(obj) ESX = obj end)
                Wait(0)
            end
        end)
    elseif versionESX == "newer" then 
        FrameworkExport()  -- Export new ESX functionalities
    end

    -- Register an event when the player is loaded
    RegisterNetEvent(playerLoadedEvent)
    AddEventHandler(playerLoadedEvent, function(xPlayer)
        ESX.PlayerData = xPlayer  -- Store player data locally
        PlayerLoaded = true

        WashingBlips()
        WashingNpcs()
    end)

    AddEventHandler("onResourceStart", function(resource)
        if resource == GetCurrentResourceName() then
            WashingBlips()
            WashingNpcs()
        end
    end)

    function WashingBlips()
        for _, wash in pairs(WashingZones) do
            local blipConfig = wash["Blip"]
            local blip = AddBlipForCoord(blipConfig["Coords"])
            SetBlipSprite(blip, blipConfig["Sprite"])
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, blipConfig["Scale"])
            SetBlipColour(blip, blipConfig["Color"])
            SetBlipAlpha(blip, blipConfig["Opacity"])
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(blipConfig["Name"])
            EndTextCommandSetBlipName(blip)
        end

        if DebugMode then
            print("Blips created")
        end

    end


    function WashingNpcs()
        for _, wash in pairs(WashingZones) do
            local npcConfig = wash["NPC"]
            lib.requestModel(npcConfig["Model"])
            local ped = CreatePed(4, npcConfig["Model"], npcConfig["Coords"].x, npcConfig["Coords"].y, npcConfig["Coords"].z, npcConfig["Coords"].w, true, true)
            SetEntityAsMissionEntity(ped, true, true)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            lib.requestAnimDict(npcConfig["AnimDictionnary"])
            TaskPlayAnim(ped, npcConfig["AnimDictionnary"], npcConfig["AnimName"], 8.0, 8.0, -1, 1, 0, false, false, false)
            SetModelAsNoLongerNeeded(npcConfig["Model"])
        end

        if DebugMode then
            print("NPCs created")
        end

    end


    CreateThread(function()
        exports.ox_target:addBoxZone({
            coords = vec3(171.2850, -1722.8196, 29.4),
            size = vec3(1, 1, 1),
            rotation = 49,
            debug = true,
            options = {
                {
                    label = "Accéder au menu",
                    name = "target_wash_access",
                    icon = "fa-solid fa-circle",
                    iconColor = "#0EFF00",
                    onSelect = function()

                        if DebugMode then
                            print("Menu access success")
                        end

                        WashingMenu()
                    end
                }
            }
        })

        if DebugMode then
            print("Target created")
        end

    end)

    function WashingMenu()
        lib.registerContext({
            id = "wash_menu_main",
            title = "Lavage de véhicule",
            icon = "fa-solid fa-car",
            options = {
                {
                    title = "Lavage Manuelle",
                    description = "Lavage manuelle de votre véhicule",
                    icon = "fa-solid fa-car",
                    onSelect = function()

                        if DebugMode then
                            print("Wash menu success - Manual Wash")
                        end

                        ESX.TriggerServerCallback("ww-carWash:Server:CheckMoney", function(success)
                            print("Is player has enough money : ", success)
                            if success then
                               TriggerServerEvent("ww-carWash:Server:GiveItemManualWash")
                            end
                        end, "Manual")
                    end
                },
                {
                    title = "Lavage Standard",
                    description = "Lavage standard de votre véhicule",
                    icon = "fa-solid fa-car",
                    onSelect = function()

                        if DebugMode then
                            print("Wash menu success - Standard Wash")
                        end

                        ESX.TriggerServerCallback("ww-carWash:Server:CheckMoney", function(success)
                            if success then
                                StandardWash()
                            end
                        end, "Standard")
                    end
                },
                {
                    title = "Lavage Premium",
                    description = "Lavage premium de votre véhicule",
                    icon = "fa-solid fa-car",
                    onSelect = function()

                        if DebugMode then
                            print("Wash menu success - Premium Wash")
                        end

                        ESX.TriggerServerCallback("ww-carWash:Server:CheckMoney", function(success)
                            if success then
                                PremiumWash()
                            end
                        end, "Premium")
                    end
                },
            }
        })

        if DebugMode then
            print("Context created")
        end

        lib.showContext("wash_menu_main")

        if DebugMode then
            print("Context showed")
        end

    end

    RegisterNetEvent("ww-carWash:Client:ManualWash")
    AddEventHandler("ww-carWash:Client:ManualWash", function()
        ManualWash()
    end)
    function ManualWash()
        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player)
        local vehicle = GetVehiclePedIsIn(player, true)
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(playerCoords - vehicleCoords)

        if DebugMode then
            print("Distance : ", distance)
        end

        if distance <= 3.0 then
            TaskTurnPedToFaceEntity(player, vehicle, 2000)
            Wait(2000)
            UseParticleFxAssetNextCall("core")
            local particle = StartParticleFxLoopedOnPedBone("ent_amb_waterfall_splash_p", player, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 57005, 0.05, false, false, false)
            lib.progressCircle({
                duration = 10000,
                label = "Lavage en cours...",
                position = 'bottom',
                useWhileDead = false,
                anim = {
                    scenario = "WORLD_HUMAN_MAID_CLEAN"
                },
                disable = {
                    move = true,
                    car = true,
                    combat = true,
                    mouse = true
                }


            })
            StopParticleFxLooped(particle, 0)
            local vehicleDirt = GetVehicleDirtLevel(vehicle)
            SetVehicleDirtLevel(vehicle, vehicleDirt * 0.5)
            TriggerServerEvent("ww-carWash:Server:RemoveItemManualWash")
        else
            lib.notify({
                title = "Car Wash",
                description = "Vous devez être proche de votre véhicule pour le laver",
                type = "error",
                position = "top",
                duration = 3500,
            })
            return
        end
    end

    function StandardWash()
        local player = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(player, true)
        for _, wash in pairs(WashingZones) do
            SetEntityCoords(vehicle, wash["WashingPlaceForVehicle"].x, wash["WashingPlaceForVehicle"].y, wash["WashingPlaceForVehicle"].z, false, false, false, true)
            SetEntityHeading(vehicle, wash["WashingPlaceForVehicle"].w)
            SetEntityInvincible(vehicle, true)
            FreezeEntityPosition(vehicle, true)
            SetVehicleOnGroundProperly(vehicle)

            if DebugMode then
                print("Vehicle ready to be washed")
            end

            local standard = wash["StandardWash"]
            lib.requestModel(standard["ModelNpc1"])
            lib.requestModel(standard["ModelNpc2"])
            local npc1 = CreatePed(4, standard["ModelNpc1"], standard["SpawnNpc1"].x, standard["SpawnNpc1"].y, standard["SpawnNpc1"].z, standard["SpawnNpc1"].w, true, true)
            local npc2 = CreatePed(4, standard["ModelNpc2"], standard["SpawnNpc2"].x, standard["SpawnNpc2"].y, standard["SpawnNpc2"].z, standard["SpawnNpc2"].w, true, true)
            SetModelAsNoLongerNeeded(standard["ModelNpc1"])
            SetModelAsNoLongerNeeded(standard["ModelNpc2"])

            if DebugMode then
                print("NPCs ready to come")
            end

            TaskGoToCoordAnyMeans(npc1, standard["PlaceNpc1Wash"].x, standard["PlaceNpc1Wash"].y, standard["PlaceNpc1Wash"].z, 2.0)
            TaskGoToCoordAnyMeans(npc2, standard["PlaceNpc2Wash"].x, standard["PlaceNpc2Wash"].y, standard["PlaceNpc2Wash"].z, 2.0)
            lib.progressCircle({
                duration = 9500,
                label = "Workers in coming ...",
                position = 'bottom',
                useWhileDead = false
            })
            TaskTurnPedToFaceEntity(npc1, vehicle, 1500)
            TaskTurnPedToFaceEntity(npc2, vehicle, 1500)
            
            if DebugMode then
                print("NPCs ready to wash the vehicle")
            end

            Wait(1500)
            TaskStartScenarioInPlace(npc1, "WORLD_HUMAN_MAID_CLEAN", -1, true)
            TaskStartScenarioInPlace(npc2, "WORLD_HUMAN_MAID_CLEAN", -1, true)
            UseParticleFxAssetNextCall("core")
            local particle = StartParticleFxLoopedOnPedBone("ent_amb_waterfall_splash_p", npc1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 57005, 0.08, false, false, false)
            local particle2 = StartParticleFxLoopedOnPedBone("ent_amb_waterfall_splash_p", npc2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 57005, 0.08, false, false, false)

            if DebugMode then
                print("NPCs working ...")
            end

            lib.progressCircle({
                duration = 15000,
                label = "Car Washing en cours ...",
                position = 'bottom',
                useWhileDead = false
            })
            ClearPedTasksImmediately(npc1)
            ClearPedTasksImmediately(npc2)
            StopParticleFxLooped(particle, 0)
            StopParticleFxLooped(particle2, 0)
            SetPedAsNoLongerNeeded(npc)
			SetPedAsNoLongerNeeded(npc2)
            TaskGoToCoordAnyMeans(npc1, standard["SpawnNpc1"].x, standard["SpawnNpc1"].y, standard["SpawnNpc1"].z, 2.0)
            TaskGoToCoordAnyMeans(npc2, standard["SpawnNpc2"].x, standard["SpawnNpc2"].y, standard["SpawnNpc2"].z, 2.0)

            if DebugMode then
                print("NPCs finished to wash the vehicle")
            end

            local dirt = GetVehicleDirtLevel(vehicle)
            SetVehicleDirtLevel(vehicle, dirt * 0.75)
            FreezeEntityPosition(vehicle, false)
            SetEntityInvincible(vehicle, false)

            if DebugMode then
                print("Vehicle ready to leave")
                print("Standard Wash success")
            end

        end
    end

    function PremiumWash()
        local player = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(player, true)
        local playerCoords = GetEntityCoords(player)
        for _, wash in pairs(WashingZones) do
            SetEntityCoords(vehicle, wash["WashingPlaceForVehicle"].x, wash["WashingPlaceForVehicle"].y, wash["WashingPlaceForVehicle"].z, false, false, false, true)
            SetEntityHeading(vehicle, wash["WashingPlaceForVehicle"].w)
            SetEntityInvincible(vehicle, true)
            FreezeEntityPosition(vehicle, true)
            SetVehicleOnGroundProperly(vehicle)

            if DebugMode then
                print("Vehicle ready to be washed")
            end

            local premium = wash["PremiumWash"]
            lib.requestModel(premium["ModelNpc1"])
            lib.requestModel(premium["ModelNpc2"])
            lib.requestModel(premium["ModelNpc3"])
            local npc1 = CreatePed(4, premium["ModelNpc1"], premium["SpawnNpc1"].x, premium["SpawnNpc1"].y, premium["SpawnNpc1"].z, premium["SpawnNpc1"].w, true, true)
            local npc2 = CreatePed(4, premium["ModelNpc2"], premium["SpawnNpc2"].x, premium["SpawnNpc2"].y, premium["SpawnNpc2"].z, premium["SpawnNpc2"].w, true, true)
            local npc3 = CreatePed(4, premium["ModelNpc3"], premium["SpawnNpc3"].x, premium["SpawnNpc3"].y, premium["SpawnNpc3"].z, premium["SpawnNpc3"].w, true, true)
            SetModelAsNoLongerNeeded(premium["ModelNpc1"])
            SetModelAsNoLongerNeeded(premium["ModelNpc2"])
            SetModelAsNoLongerNeeded(premium["ModelNpc3"])

            if DebugMode then
                print("NPCs ready to come")
            end

            TaskGoToCoordAnyMeans(npc1, premium["PlaceNpc1Wash"].x, premium["PlaceNpc1Wash"].y, premium["PlaceNpc1Wash"].z, 2.0)
            TaskGoToCoordAnyMeans(npc2, premium["PlaceNpc2Wash"].x, premium["PlaceNpc2Wash"].y, premium["PlaceNpc2Wash"].z, 2.0)
            TaskGoToCoordAnyMeans(npc3, playerCoords.x, playerCoords.y, playerCoords.z, 2.0)
            lib.progressCircle({
                duration = 9500,
                label = "Workers in coming ...",
                position = 'bottom',
                useWhileDead = false
            })
            TaskTurnPedToFaceEntity(npc1, vehicle, 1500)
            TaskTurnPedToFaceEntity(npc2, vehicle, 1500)
            TaskTurnPedToFaceEntity(npc3, player, 1500)
            
            if DebugMode then
                print("NPCs ready to wash the vehicle")
            end

            Wait(1500)
            TaskStartScenarioInPlace(npc1, "WORLD_HUMAN_MAID_CLEAN", -1, true)
            TaskStartScenarioInPlace(npc2, "WORLD_HUMAN_MAID_CLEAN", -1, true)
            lib.requestAnimDict("mini@strip_club@idles@stripper")
            TaskPlayAnim(npc3, "mini@strip_club@idles@stripper", "stripper_idle_06", 8.0, 8.0, -1, 1, 0, false, false, false)
            UseParticleFxAssetNextCall("core")
            local particle = StartParticleFxLoopedOnPedBone("ent_amb_waterfall_splash_p", npc1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 57005, 0.08, false, false, false)
            local particle2 = StartParticleFxLoopedOnPedBone("ent_amb_waterfall_splash_p", npc2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 57005, 0.08, false, false, false)

            if DebugMode then
                print("NPCs working ...")
            end

            lib.progressCircle({
                duration = 15000,
                label = "Car Washing en cours ...",
                position = 'bottom',
                useWhileDead = false
            })
            ClearPedTasksImmediately(npc1)
            ClearPedTasksImmediately(npc2)
            ClearPedTasksImmediately(npc3)
            StopParticleFxLooped(particle, 0)
            StopParticleFxLooped(particle2, 0)
            SetPedAsNoLongerNeeded(npc)
			SetPedAsNoLongerNeeded(npc2)
            SetPedAsNoLongerNeeded(npc3)
            TaskGoToCoordAnyMeans(npc1, premium["SpawnNpc1"].x, premium["SpawnNpc1"].y, premium["SpawnNpc1"].z, 2.0)
            TaskGoToCoordAnyMeans(npc2, premium["SpawnNpc2"].x, premium["SpawnNpc2"].y, premium["SpawnNpc2"].z, 2.0)
            TaskGoToCoordAnyMeans(npc3, premium["SpawnNpc3"].x, premium["SpawnNpc3"].y, premium["SpawnNpc3"].z, 2.0)

            if DebugMode then
                print("NPCs finished to wash the vehicle")
            end

            SetVehicleDirtLevel(vehicle, 0.0)
            FreezeEntityPosition(vehicle, false)
            SetEntityInvincible(vehicle, false)

            if DebugMode then
                print("Vehicle ready to leave")
                print("Premium Wash success")
            end

        end
    end



    if DebugMode then
        RegisterCommand("Sale", function(source, args, rawCommand)
            local player = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(player, false)
            SetVehicleDirtLevel(vehicle, 15.0)
        end)

        RegisterCommand("Propre", function(source, args, rawCommand)
            local player = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(player, false)
            SetVehicleDirtLevel(vehicle, 0.0)
        end)
    end










-- If using QBCore, this script is currently not supported
elseif FrameworkUse == "QBCore" then
    return nil
end