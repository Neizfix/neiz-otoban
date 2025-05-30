local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Commands.Add("otobanaç", "Otobanları açar", {}, false, function(source, args)
    TriggerClientEvent("neiz-otoban:toggleOtoban", -1, true)
    TriggerClientEvent('QBCore:Notify', source, "Otobanlar aktif edildi.", "success")
end, "god")

QBCore.Commands.Add("otobankapat", "Otobanları kapatır", {}, false, function(source, args)
    TriggerClientEvent("neiz-otoban:toggleOtoban", -1, false) 
    TriggerClientEvent('QBCore:Notify', source, "Tüm otobanlar kapatıldı.", "error")
end, "god")


local otobanlar = {
    [1] = {
        otobanPos = vector3(2000.0, 3000.0, 50.0),
        heading = 180.0
    },
    [2] = {
        otobanPos = vector3(2100.0, 3100.0, 50.0),
        heading = 90.0
    }
}

local oyuncuOrijinalPozisyon = {}

RegisterServerEvent("otoban:teleport")
AddEventHandler("otoban:teleport", function(otobanIndex, inVehicle, orijinalPos)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local otoban = otobanlar[otobanIndex]
    if not otoban then return end

    oyuncuOrijinalPozisyon[src] = orijinalPos
    SetPlayerRoutingBucket(src, 551)

    TriggerClientEvent("otoban:teleportClient", src, otoban.otobanPos, otoban.heading, inVehicle)
end)

RegisterServerEvent("otoban:teleportAnaDunya")
AddEventHandler("otoban:teleportAnaDunya", function(inVehicle)
    local src = source
    local orijinal = oyuncuOrijinalPozisyon[src]
    if not orijinal then return end

    SetPlayerRoutingBucket(src, 0)
    TriggerClientEvent("otoban:teleportClient", src, orijinal, 0.0, inVehicle)
    oyuncuOrijinalPozisyon[src] = nil
end)

RegisterServerEvent("otoban:kapat")
AddEventHandler("otoban:kapat", function()
    local players = GetPlayers()
    for _, playerId in pairs(players) do
        local bucket = GetPlayerRoutingBucket(playerId)
        if bucket == 551 then
            local pos = oyuncuOrijinalPozisyon[playerId] or vector3(0, 0, 0)
            SetPlayerRoutingBucket(playerId, 0)
            TriggerClientEvent("otoban:teleportClient", playerId, pos, 0.0, false)
            oyuncuOrijinalPozisyon[playerId] = nil
        end
    end
end)
