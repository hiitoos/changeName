local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Commands.Add('changename', 'Cambiar nombre y apellido de un jugador', {{name='id', help='ID del jugador'}, {name='nombre', help='Nuevo nombre'}, {name='apellido', help='Nuevo apellido'}}, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    --if Player and QBCore.Functions.HasPermission(Player.PlayerData.source, 'admin') then
        local targetId = tonumber(args[1])
        local newName = args[2]
        local newLastname = args[3]

        if targetId and newName and newLastname then
            local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
            if TargetPlayer then
                MySQL.Async.fetchScalar('SELECT charinfo FROM players WHERE citizenid = ?', {TargetPlayer.PlayerData.citizenid}, function(charinfoJson)
                    local charinfo = json.decode(charinfoJson)
                    print (charinfo)
                    -- {"account":"US05QBCore4060119088","firstname":"Daniel","phone":"7546737921","nationality":"España","backstory":"placeholder backstory","lastname":"Gomez","birthdate":"02/11/2000","gender":0}
                    local nationality = charinfo.nationality or 'Spanish'
                    local birthdate = charinfo.birthdate or '24/06/1990'
                    local account = charinfo.account
                    local phone = charinfo.phone
                    local backstory = charinfo.backstory
                    local gender = charinfo.gender
                    local csn = citizenid

                    MySQL.Async.execute('UPDATE players SET charinfo = JSON_SET(charinfo, "$.firstname", ?, "$.lastname", ?) WHERE citizenid = ?', {newName, newLastname, TargetPlayer.PlayerData.citizenid}, function(rowsChanged)
                        if rowsChanged > 0 then
                            TargetPlayer.Functions.SetPlayerData('charinfo', { firstname = newName, lastname = newLastname, nationality = nationality, birthdate = birthdate })
                            --TriggerClientEvent('QBCore:Notify', src, 'Nombre cambiado con éxito', 'success')
                            TriggerClientEvent('QBCore:Notify', targetId, 'Tu nombre ha sido cambiado a ' .. newName .. ' ' .. newLastname, 'success')

                            -- Añadir el ítem "id_card" al jugador con metadatos adicionales
                            TargetPlayer.Functions.RemoveItem('driver_license', 1)
                            TargetPlayer.Functions.RemoveItem('id_card', 1)

                            TargetPlayer.Functions.AddItem('id_card', 1, nil, { citizenid= csn, account = account, phone = phone, backstory = backstory, gender = gender, firstname = newName, lastname = newLastname, nationality = nationality, birthdate = birthdate })
                            TargetPlayer.Functions.AddItem('driver_license', 1, nil, { gender = gender, firstname = newName, lastname = newLastname, birthdate = birthdate })
                            TriggerClientEvent('inventory:client:ItemBox', targetId, QBCore.Shared.Items['id_card'], 'add')
                            TriggerClientEvent('inventory:client:ItemBox', targetId, QBCore.Shared.Items['driver_license'], 'add')
                        else
                            TriggerClientEvent('QBCore:Notify', src, 'Error al cambiar el nombre', 'error')
                        end
                    end)
                end)
            else
                TriggerClientEvent('QBCore:Notify', src, 'Jugador no encontrado', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'Parámetros inválidos', 'error')
        end
    --else
    --    TriggerClientEvent('QBCore:Notify', src, 'No tienes permisos para usar este comando', 'error')
    --end
end, 'admin') -- Solo los jugadores con el grupo 'admin' pueden usar este comando
