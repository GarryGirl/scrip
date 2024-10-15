
local QBCore = exports['qb-core']:GetCoreObject()


RegisterServerEvent('gpdesigns:removemoneycar')
AddEventHandler('gpdesigns:removemoneycar', function()
    local xPlayer = QBCore.Functions.GetPlayer(source)
    if xPlayer then
        local moneyRemove = Config.moneyRemovesac
        if xPlayer.Functions.RemoveMoney('bank', moneyRemove) then
            TriggerClientEvent('QBCore:Notify', source, 'Bạn đã bị trừ ' .. Config.moneyRemovesac .. ' tiền.', 'success')
        else
            TriggerClientEvent('QBCore:Notify', source, 'Bạn không đủ tiền nên đã bị âm.', 'error')
        end
    end
end)


RegisterServerEvent('consumables:server:usecoffee')
AddEventHandler('consumables:server:usecoffee', function()
    TriggerClientEvent('checkElectricCarAndDamage', -1) -- -1 để gửi cho tất cả client
end)