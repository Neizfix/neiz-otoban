local QBCore = exports['qb-core']:GetCoreObject()

local otobanlar = {
    {
        aktif = false,
        markerPos = vector3(1475.56, 781.84, 77.19),
        teleportPos = vector3(1480.0, 780.0, 77.19), 
        heading = 180.0,
        teleportState = false,
        orijinalPos = nil
    },
    {
        aktif = false,
        markerPos = vector3(2819.17, 3430.59, 55.61),
        teleportPos = vector3(2825.0, 3430.0, 55.61), 
        heading = 90.0,
        teleportState = false,
        orijinalPos = nil
    }
}

RegisterNetEvent("neiz-otoban:toggleOtoban")
AddEventHandler("neiz-otoban:toggleOtoban", function(state)
    for i=1, #otobanlar do
        otobanlar[i].aktif = state
        if not state then
            otobanlar[i].teleportState = false
            otobanlar[i].orijinalPos = nil
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerData = QBCore.Functions.GetPlayerData()
        local isDead = false
        if playerData and playerData.metadata then
            isDead = playerData.metadata["isdead"] or false
        end

        if isDead then
            DisableControlAction(0, 38, true)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for i, otoban in ipairs(otobanlar) do
            if otoban.aktif then
                local distance = #(coords - otoban.markerPos)

                if distance < 50.0 then
                    DrawMarker(28, otoban.markerPos.x, otoban.markerPos.y, otoban.markerPos.z - 0.9, 0, 0, 0, 0, 0, 0, 5.0, 5.0, 5.0, 255, 0, 0, 100, false, false, 2, false, nil, nil, false)
                end

                if distance < 5.0 then
                    if not otoban.teleportState then
                        DrawText3D(otoban.markerPos.x, otoban.markerPos.y, otoban.markerPos.z + 1.0, "[E] Otoban Giriş")
                    else
                        DrawText3D(otoban.markerPos.x, otoban.markerPos.y, otoban.markerPos.z + 1.0, "[E] Ana Dünya")
                    end

                    if IsControlJustPressed(0, 38) then 
                        local inVehicle = IsPedInAnyVehicle(ped, false)
                        if not otoban.teleportState then
                            otoban.orijinalPos = coords
                            otoban.teleportState = true
                            QBCore.Functions.Notify("Otoban giriş yapıldı.", "success")
                            TriggerEvent("otoban:teleportClient", otoban.teleportPos, otoban.heading, inVehicle)
                        else
                            if otoban.orijinalPos then
                                TriggerEvent("otoban:teleportClient", otoban.orijinalPos, 0.0, inVehicle)
                                otoban.teleportState = false
                                QBCore.Functions.Notify("Ana dünyaya döndünüz.", "error")
                            else
                                QBCore.Functions.Notify("Orijinal pozisyon bulunamadı.", "error")
                            end
                        end
                    end
                end
            end
        end
    end
end)

RegisterNetEvent("otoban:teleportClient", function(pos, heading, inVehicle)
    local ped = PlayerPedId()
    if inVehicle then
        local veh = GetVehiclePedIsIn(ped, false)
        SetEntityCoords(veh, pos.x, pos.y, pos.z, false, false, false, true)
        SetEntityHeading(veh, heading)
    else
        SetEntityCoords(ped, pos.x, pos.y, pos.z, false, false, false, true)
        SetEntityHeading(ped, heading)
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end
