local QBCore = exports['qb-core']:GetCoreObject()
local noteActive = false
local PlayerProps = {}

local function SharedRequestAnimDict(animDict, cb)
	if not HasAnimDictLoaded(animDict) then
		RequestAnimDict(animDict)

		while not HasAnimDictLoaded(animDict) do
			Citizen.Wait(1)
		end
	end
	if cb ~= nil then
		cb()
	end
end

local function AnimationActions(type)
    if type == "start" then
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        if DoesEntityExist(ped) and not IsEntityDead(ped) then 
            local x,y,z = table.unpack(pedCoords)
            local one = CreateObject(GetHashKey('prop_notepad_01'), x, y, z+0.2,  true,  true, true)
            PlayerProps[#PlayerProps+1] = one
            local two = CreateObject(GetHashKey('prop_pencil_01'), x, y, z+0.2,  true,  true, true)
            PlayerProps[#PlayerProps+1] = two
            AttachEntityToEntity(one, ped, GetPedBoneIndex(ped, 18905), 0.1, 0.02, 0.05, 10.0, 0.0, 0.0, true, true, false, true, 1, true)
            AttachEntityToEntity(two, ped, GetPedBoneIndex(ped, 58866), 0.12, 0.0, 0.001, -150.0, 0.0, 0.0, true, true, false, true, 1, true)
            SharedRequestAnimDict("missheistdockssetup1clipboard@base", function()
                TaskPlayAnim(ped, "missheistdockssetup1clipboard@base", "base", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )  
            end)
        end
    elseif type == "end" then
        for k,v in pairs(PlayerProps) do
            DeleteEntity(v)
        end
        Wait(100)
        PlayerProps = {}
        ClearPedTasks(PlayerPedId())
    end
end

local function fullclose()
    if noteActive then 
        SetNuiFocus(false, false)
        noteActive = false 
        AnimationActions("end")
        SendNUIMessage({
            action = "close"
        })
    end
end

RegisterNetEvent("wert-notes:client:use-item", function()
    if not noteActive then
        noteActive = true
        AnimationActions("start")
        TriggerEvent("wert-notes:client:open-menu")
    end
end)


RegisterNetEvent("wert-notes:client:open-menu", function()
    local Menu = {
        {
            header = "Notebook",
            icon = "fa-solid fa-clipboard",
            isMenuHeader = true
        }
    }
    Menu[#Menu+1] = {
        header = "My notes",
        txt = "Look my notes",
        icon = "fa-solid fa-square-caret-right",
        params = {
            event = "wert-notes:client:select-action",
            args = {
                action = "mynotes"
            }
        }
    }
    Menu[#Menu+1] = {
        header = "Create new note",
        txt = "Open a white paper",
        icon = "fa-solid fa-square-caret-right",
        params = {
            event = "wert-notes:client:select-action",
            args = {
                action = "newnote"
            }
        }
    }
    Menu[#Menu+1] = {
        header = "Close",
        txt = "",
        icon = "fa-solid fa-circle-xmark",
        params = {
            event = "qb-menu:client:closeMenu"
        }
    }
    exports['qb-menu']:openMenu(Menu)
end)

RegisterNetEvent("wert-notes:client:select-action", function(data)
    local type = data.action
    if type == "newnote" then
        SendNUIMessage({
            action = "open"
        })
        SetNuiFocus(true, true)
    elseif type == "mynotes" then
        QBCore.Functions.TriggerCallback('wert-notes:get-my-notes', function(result)
            if result then
                local Menu = {
                    {
                        header = "Saved notes",
                        icon = "fa-solid fa-clipboard",
                        isMenuHeader = true
                    }
                }
                for k,v in pairs(result) do
                    local test = v.text
                    if string.len(v.text) > 10 then
                        test = string.sub(v.text, 1, 10) .. "..."
                    end
                    Menu[#Menu+1] = {
                        header = test,
                        txt = "#".. k .. " Numbered note",
                        icon = "fa-solid fa-square-caret-right",
                        params = {
                            event = "wert-notes:client:opensavednot",
                            args = {
                                text = v.text,
                                id = v.id
                            }
                        }
                    }
                end
                Menu[#Menu+1] = {
                    header = "Close",
                    txt = "",
                    icon = "fa-solid fa-circle-xmark",
                    params = {
                        event = "qb-menu:client:closeMenu"
                    }
                }
                exports['qb-menu']:openMenu(Menu)
            else
                fullclose()
                QBCore.Functions.Notify('You dont have any saved note!', 'error')
            end
        end)
    end
end)

RegisterNetEvent("wert-notes:client:opensavednot", function(data)
    if data.text and data.id then
        SendNUIMessage({
            action = "load",
            id = data.id,
            text = data.text
        })
        SetNuiFocus(true, true)
    end
end)

RegisterNetEvent("qb-menu:client:closeMenu", function() if noteActive then noteActive = false AnimationActions("end") end end)
RegisterNetEvent("wert-notes:client:qb-menu-close", function() if noteActive then noteActive = false AnimationActions("end") end end)

--Callbacks
RegisterNUICallback("close", function()
    if noteActive then 
        SetNuiFocus(false, false)
        noteActive = false 
        AnimationActions("end") 
    end
end)

RegisterNUICallback("new-note", function(data)
    if data.text then
        fullclose()
        TriggerServerEvent("wert-notes:server:new-note", tostring(data.text))
    end
end)

RegisterNUICallback("save-note", function(data)
    if data.id and data.text then
        fullclose()
        TriggerServerEvent("wert-notes:server:save-note", tonumber(data.id), tostring(data.text))
    end
end)

RegisterNUICallback("delete-note", function(data)
    if data.id then
        fullclose()
        TriggerServerEvent("wert-notes:server:delete-note", tonumber(data.id))
    end
end)

RegisterNUICallback("share-note", function(data)
    if data.id then
        fullclose()
        local player, distance = QBCore.Functions.GetClosestPlayer()
        if player ~= -1 and distance < 3.0 then
            local playerId = GetPlayerServerId(player)
            TriggerServerEvent("wert-notes:server:share-note", tonumber(data.id), tostring(data.text), playerId)
        else
            QBCore.Functions.Notify("No player by closest", "error")
        end
    end
end)

RegisterNUICallback("notify", function(data)
    QBCore.Functions.Notify(data.notif, "error")
end)
