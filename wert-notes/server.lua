local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('wert-notes:get-my-notes', function(source, cb)
    local ply = QBCore.Functions.GetPlayer(source)
    if ply then
        local result = MySQL.query.await('SELECT * FROM notepad WHERE citizenid = ?', {ply.PlayerData.citizenid})
        if result and result[1] then
            cb(result)
        else
            cb(nil)
        end
    else
        cb(nil)
    end
end)

RegisterNetEvent("wert-notes:server:new-note", function(text)
    local src = source
    local ply = QBCore.Functions.GetPlayer(source)
    if ply and text then
        MySQL.Async.fetchAll("INSERT INTO notepad SET citizenid = @citizenid, text = @text", {
            ["@citizenid"] = ply.PlayerData.citizenid,
            ["@text"] = text,
        })
    end
end)

RegisterNetEvent("wert-notes:server:save-note", function(id, text)
    local src = source
    local ply = QBCore.Functions.GetPlayer(source)
    if ply and id and text then
        TriggerClientEvent("QBCore:Notify", src, "Note updated!", "success")
        MySQL.Async.execute('UPDATE notepad SET text = ? WHERE id = ?', {text, id})
    end
end)

RegisterNetEvent("wert-notes:server:delete-note", function(id)
    local src = source
    if id then
        TriggerClientEvent("QBCore:Notify", src, "Note deleted!", "error")
        MySQL.Async.execute('DELETE FROM notepad WHERE id = @id', {['@id'] = id})
    end
end)

RegisterNetEvent("wert-notes:server:share-note", function(id, text, playerId)
    local src = source
    local ply = QBCore.Functions.GetPlayer(src)
    local trgt = QBCore.Functions.GetPlayer(playerId)
    if ply and trgt and id and text then
        MySQL.Async.fetchAll("INSERT INTO notepad SET citizenid = @citizenid, text = @text", {
            ["@citizenid"] = trgt.PlayerData.citizenid,
            ["@text"] = text,
        })
        TriggerClientEvent("QBCore:Notify", ply.PlayerData.source, " You gave your #" .. id .. " numbered note to the nearby player!", "success")
        TriggerClientEvent("QBCore:Notify", trgt.PlayerData.source, "You got a note!", "success")
    end
end)

QBCore.Functions.CreateUseableItem("stickynote", function(source, item)
    local src = source
    TriggerClientEvent("wert-notes:client:use-item", src)
end)