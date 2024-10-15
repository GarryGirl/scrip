local QBCore = exports['qb-core']:GetCoreObject()
local charging = false
local charging2 = false
local chargingVehicle = nil
local chargingVehicle2 = nil
local chargeDuration = 15 
local chargeDuration2 = 30
local vehiclesBeingCharged = {} 
local isInRestrictedZone = false
local fuelLevels = {}
local chargeStartTime = 0
local chargeStartTime2 = 0

------------------------------------------  NẠP VÍP--------------------------------------

function DrawRestrictedZonez1()
    for _, zone in pairs(Config.ChargingZones) do
        local coords = vector3(zone.x, zone.y, zone.z)
        local width = zone.width or 1.0  
        local length = zone.length or 1.0  
        local height = zone.height or 1.0 
        local color = {0, 255, 0, 150} 

        DrawMarker(23, coords.x, coords.y, coords.z - 0.9, 0, 0, 0, 0, 0, 0, length, width, height, color[1], color[2], color[3], color[4], false, false, 2, false, nil, nil, false)
    end
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        DrawRestrictedZonez1()

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _, zone in ipairs(Config.ChargingZones) do
            local distance = #(playerCoords - vector3(zone.x, zone.y, zone.z))
            if distance < zone.radius then
                DrawText3Ds(zone.x, zone.y, zone.z + 1.0, "<FONT FACE='arial font'>[E] Sạc điện xe[mất phí]")

                if IsControlJustReleased(0, 38) then 
                    local vehicle = GetVehiclePedIsIn(playerPed, false)
                    if vehicle ~= 0 then
                        local vehicleModel = GetEntityModel(vehicle)
                        local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)

                        if IsElectricCar(vehicleName) then
                            SendNUIMessage({
                                type = 'playSound'
                            })

                            TriggerServerEvent('gpdesigns:removemoneycar')
                            local ped = PlayerPedId()
                            local vehicle = GetVehiclePedIsIn(ped, false)
                            
                            if vehicle ~= 0 then
                                SetVehicleFuelLevel(vehicle, 100.0) 
                            end
                            Citizen.Wait(1100)
                            StartOut(vehicle)
                            StartCharging(vehicle)

                            Citizen.CreateThread(function()
                                while true do
                                    Citizen.Wait(0)
                                      DrawRestrictedZonez1()
                                end
                            end)

                        else
                            QBCore.Functions.Notify('Xe của bạn không phải là xe điện', 'error')
                        end
                    else
                        QBCore.Functions.Notify('Bạn cần ngồi trong xe để sạc điện', 'error')
                    end
                end
            end
        end
    end
end)




function StartCharging(vehicle)
    local vehicleModel = GetEntityModel(vehicle)
    local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)
    local vehiclePlate = GetVehicleNumberPlateText(vehicle)

    charging = true
    chargingVehicle = vehicle
    chargeStartTime = GetGameTimer()

    FreezeEntityPosition(vehicle, true)
    vehiclesBeingCharged[vehiclePlate] = {
        model = vehicleName,
        plate = vehiclePlate
    }

    Citizen.CreateThread(function()
        while charging do
            Citizen.Wait(0)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(playerCoords - vehicleCoords)
            if distance <= 10.0 then
                local currentTime = GetGameTimer()
                local remainingTime = chargeDuration - ((currentTime - chargeStartTime) / 1000)

                if remainingTime <= 0 then
                    charging = false
                    local info = vehiclesBeingCharged[vehiclePlate]
                    if info then
                        SetVehicleFuelLevel(vehicle, 100.0)
                        local message = "Xe " .. info.model .. " (" .. info.plate .. ") đã kết thúc thời gian sạc [ĐÃ ĐẦY ĐIỆN]"
                        QBCore.Functions.Notify(message, 'success')
                    end

                    FreezeEntityPosition(vehicle, false)
                    vehiclesBeingCharged[vehiclePlate] = nil 
                else
                    DrawText3Ds(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.0, "<FONT FACE='arial font'>Auto sạc điện còn... " .. math.ceil(remainingTime) .. " giây")
                end
            end
        end
    end)
end

-----------------------------------------------------------------------NẠP THƯỜNG-----------------------------------------------


function DrawRestrictedZonez2()
    for _, zone in pairs(Config.ChargingZones2) do
        local coords = vector3(zone.x, zone.y, zone.z)
        local width = zone.width or 1.0  
        local length = zone.length or 1.0  
        local height = zone.height or 1.0  
        local color = {0, 150, 255, 150}  

        DrawMarker(23, coords.x, coords.y, coords.z - 0.9, 0, 0, 0, 0, 0, 0, length, width, height, color[1], color[2], color[3], color[4], false, false, 2, false, nil, nil, false)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        DrawRestrictedZonez2()
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        for _, zone in ipairs(Config.ChargingZones2) do
            local distance = #(playerCoords - vector3(zone.x, zone.y, zone.z))
            if distance < zone.radius then
                DrawText3Ds(zone.x, zone.y, zone.z + 1.0, "<FONT FACE='arial font'>[E] Sạc điện xe [Thường]")
                if IsControlJustReleased(0, 38) then 
                    local vehicle = GetVehiclePedIsIn(playerPed, false)
                    if vehicle ~= 0 then
                        local vehicleModel = GetEntityModel(vehicle)
                        local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)
                        if IsElectricCar(vehicleName) then
                            SendNUIMessage({
                                type = 'playSound'
                            })
                            QBCore.Functions.Notify('Hãy quay lại xe trước khi sạc xong', 'success')
                            StartOut(vehicle)
                            Citizen.Wait(1200)
                            StartCharging2(vehicle)
                            Citizen.CreateThread(function()
                                while true do
                                    Citizen.Wait(0)
                                    DrawRestrictedZonez2()
                                end
                            end)
                            ThongBaoTruockhixong(vehicle)
                        else
                            QBCore.Functions.Notify('Xe của bạn không phải là xe điện', 'error')
                        end
                    else
                        QBCore.Functions.Notify('Bạn cần ngồi trong xe để sạc điện', 'error')
                    end
                end
            end
        end
    end
end)



function ThongBaoTruockhixong(vehicle)
    Citizen.Wait(10000)
    QBCore.Functions.Notify('LƯU Ý : Sạc gần xong hãy quay lại và ngồi lên xe ', 'error')
 end





 function StartCharging2(vehicle)
    local vehicleModel = GetEntityModel(vehicle)
    local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)
    local vehiclePlate = GetVehicleNumberPlateText(vehicle)
    charging2 = true
    chargingVehicle2 = vehicle
    chargeStartTime2 = GetGameTimer()
    FreezeEntityPosition(vehicle, true)
    vehiclesBeingCharged[vehiclePlate] = {
        model = vehicleName,
        plate = vehiclePlate
    }
    Citizen.CreateThread(function()
        while charging2 do
            Citizen.Wait(0)
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(playerCoords - vehicleCoords)
            local visibleDistance = 10.0  

            if distance <= visibleDistance then
                local currentTime = GetGameTimer()
                local remainingTime = chargeDuration2 - ((currentTime - chargeStartTime2) / 1000)

                if remainingTime <= 0 then
                    charging2 = false
                    local info = vehiclesBeingCharged[vehiclePlate]
                    if info then
                        SetVehicleFuelLevel(vehicle, 100.0)
                        local message = "Xe " .. info.model .. " (" .. info.plate .. ") đã kết thúc thời gian sạc"
                        QBCore.Functions.Notify(message, 'success')
                    end
                    FreezeEntityPosition(vehicle, false)
                    vehiclesBeingCharged[vehiclePlate] = nil 
                else
                    DrawText3Ds(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 1.0, "<FONT FACE='arial font'>Sạc điện phải ngồi trên xe còn... " .. math.ceil(remainingTime) .. " giây")
                end
            end
        end
    end)
end




function StartOut(vehicle)
     if IsPedInAnyVehicle(PlayerPedId(), false) then
         TaskLeaveVehicle(PlayerPedId(), vehicle, 0)
         Citizen.Wait(1000)
     end
 end




function IsElectricCar(vehicleName)
    for _, car in ipairs(Config.ElectricCars) do
        if string.lower(car) == string.lower(vehicleName) then
            return true
        end
    end
    return false
end


function DrawText3Ds(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end



function DrawRestrictedZones()
    for _, zone in pairs(Config.RestrictedZoneCoords) do
        local coords = vector3(zone.x, zone.y, zone.z)
        local radius = zone.radius
        local color = {255, 0, 0, 150} 

 --  DrawMarker(1, coords.x, coords.y, coords.z - 1.0, 0, 0, 0, 0, 0, 0, radius * 2.0, radius * 2.0, 1.0, color[1], color[2], color[3], color[4], false, false, 2, false, nil, nil, false)
    end
end

function IsPlayerInElectricCar()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    
    if vehicle ~= 0 then
        local vehicleModel = GetEntityModel(vehicle)
        local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)
        
        
        for _, model in pairs(Config.ElectricCars) do
            if vehicleName == model then
                return true
            end
        end
    end
    
    return false
end

function CheckRestrictedZones()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local inRestrictedZone = false
    
    for _, zone in pairs(Config.RestrictedZoneCoords) do
        local distance = GetDistanceBetweenCoords(coords, zone.x, zone.y, zone.z, true)
        
        if distance <= zone.radius then
            inRestrictedZone = true
            if IsPlayerInElectricCar() then
                if not isInRestrictedZone then
                    isInRestrictedZone = true
                    QBCore.Functions.Notify('xe bạn đang chạy là xe điện CẤM ĐỔ XĂNG', 'error')
                end
                if IsControlJustPressed(0, 38) then
                    local ped = PlayerPedId()
                    local vehicle = GetVehiclePedIsIn(ped, false)
                
                    if vehicle ~= 0 then
                        SetVehicleEngineHealth(vehicle, -100.0)
                        SetVehicleBodyHealth(vehicle, 0.0)
                        SetVehicleFuelLevel(vehicle, 1.0)
                        
                    end
                    
                    QBCore.Functions.Notify('thôi xong rồi..!', 'error')
                end

                break
            end
        end
    end

    if not inRestrictedZone then
        isInRestrictedZone = false 
    end
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)  
        CheckRestrictedZones()
        DrawRestrictedZones()
    end
end)

RegisterNetEvent('gpvehiclenat:startEvent')
AddEventHandler('gpvehiclenat:startEvent', function()

    QBCore.Functions.Notify('Nát rồi ..còn bấm cái gì nữa..!', 'error')
end)

RegisterNetEvent('checkElectricCarAndDamage')
AddEventHandler('checkElectricCarAndDamage', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle ~= 0 then 
        local vehicleModel = GetEntityModel(vehicle)
        local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)
        for _, modelName in ipairs(Config.ElectricCars) do
            if vehicleName == modelName then
                SetVehicleEngineHealth(vehicle, -1000)
                SetVehiclePetrolTankHealth(vehicle, -1000)
                SetVehicleFuelLevel(vehicle, 10.0)
                TriggerEvent('QBCore:Notify', 'Xe điện của bạn đã bị hư !', 'error')
                return
            end
        end
    end
end)





