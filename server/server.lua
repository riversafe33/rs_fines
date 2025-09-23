local VORPcore = exports.vorp_core:GetCore()
local VorpInv = exports.vorp_inventory:vorp_inventoryApi()
local ultimoSheriff = nil

Citizen.CreateThread(function()
    Wait(200)
    VorpInv.RegisterUsableItem(Config.ItemName, function(data)
        local _source = data.source
        local Character = VORPcore.getUser(_source).getUsedCharacter
        if not Character then return end

        local job = Character.job
        local grade = Character.jobGrade
        VorpInv.CloseInv(_source)

        if canUseItem(job, grade) then
            TriggerClientEvent("rs_fines:abrirFormulario", _source)
        else
            VORPcore.NotifyLeft(_source, Config.Textos.Notify.collect, Config.Textos.Notify.notpermisitem,"toasts_mp_generic", "toast_mp_customer_service", 4000, "COLOR_RED" )
        end
    end)
end)

function canUseItem(job, grade)
    if not Config.jobRequiredItem then
        return true
    end

    local jobConfig = Config.allowedJobsItem[job]
    if jobConfig then
        if jobConfig.minGrade == false or grade >= jobConfig.minGrade then
            return true
        end
    end
    return false
end

RegisterServerEvent("rs_fines:guardarMulta")
AddEventHandler("rs_fines:guardarMulta", function(data)
    local src = source
    local autorChar = VORPcore.getUser(src).getUsedCharacter
    local autor = autorChar.firstname .. " " .. autorChar.lastname

    local targetUser = VORPcore.getUser(tonumber(data.id))
    if not targetUser then
        VORPcore.NotifyLeft(src, Config.Textos.Notify.collect, Config.Textos.Notify.notid, "toasts_mp_generic", "toast_mp_customer_service", 4000, "COLOR_RED")
        return
    end

    local targetChar = targetUser.getUsedCharacter
    local idMultado = targetChar.charIdentifier
    local targetSrc = targetUser.source

    MySQL.insert('INSERT INTO multas (nombre, apellido, id_multado, motivo, autor, monto, pagada) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        data.nombre, data.apellido, idMultado, data.motivo, autor, data.monto, 0
    })

    VORPcore.NotifyLeft(src, Config.Textos.Notify.collect, Config.Textos.Notify.correctfine, "toasts_mp_generic", "toast_mp_customer_service", 5000, "COLOR_GREEN")

    VORPcore.NotifyLeft(targetSrc, Config.Textos.Notify.collect, Config.Textos.Notify.recivefine .. " " .. data.monto .. "$ " , "toasts_mp_generic", "toast_mp_customer_service", 6000, "COLOR_BLUE")
end)

RegisterServerEvent("rs_fines:abrirMenuPago")
AddEventHandler("rs_fines:abrirMenuPago", function()
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter
    local id = Character.charIdentifier

    MySQL.query('SELECT * FROM multas WHERE id_multado = ? AND pagada = 0', { id }, function(result)
        if #result > 0 then
            local elementos = {}
            for _, multa in ipairs(result) do
                table.insert(elementos, {
                    label = multa.monto .. "$",
                    value = multa.id,
                    desc = multa.motivo,
                })
            end
            TriggerClientEvent("rs_fines:mostrarMenuPago", src, elementos)
        else
            VORPcore.NotifyLeft(src, Config.Textos.Notify.collect, Config.Textos.Notify.notfine, "toasts_mp_generic", "toast_mp_customer_service", 5000, "COLOR_BLUE")
        end
    end)
end)

RegisterServerEvent("rs_fines:pagarMulta")
AddEventHandler("rs_fines:pagarMulta", function(multaId)
    local src = source
    local Character = VORPcore.getUser(src).getUsedCharacter

    MySQL.query('SELECT * FROM multas WHERE id = ?', { multaId }, function(result)
        if #result > 0 then
            local multa = result[1]
            if Character.money >= multa.monto then
                Character.removeCurrency(0, multa.monto)
                MySQL.update('UPDATE multas SET pagada = 1 WHERE id = ?', { multaId })
                VORPcore.NotifyLeft(src, Config.Textos.Notify.collect, Config.Textos.Notify.corectpay, "toasts_mp_generic", "toast_mp_customer_service", 5000, "COLOR_GREEN")
            else
                VORPcore.NotifyLeft(src, Config.Textos.Notify.collect, Config.Textos.Notify.notmoney, "toasts_mp_generic", "toast_mp_customer_service", 4000, "COLOR_RED")
            end
        end
    end)
end)

local onlyOwn = Config.onlyOwn

function canCollectMoney(job, grade)
    if not Config.jobRequiredCollect then return true end
    local jobConfig = Config.allowedJobsCollect[job]
    if jobConfig then
        if jobConfig.minGrade == false or grade >= jobConfig.minGrade then
            return true
        end
    end
    return false
end

RegisterCommand(Config.Command, function(source)
    local Character = VORPcore.getUser(source).getUsedCharacter
    local job = Character.job
    local grade = Character.jobGrade

    if canCollectMoney(job, grade) then
        ultimoSheriff = source
        MySQL.query('SELECT * FROM multas', {}, function(result)
            for _, multa in ipairs(result) do
                multa.pagada = tonumber(multa.pagada)
            end
            TriggerClientEvent("rs_fines:abrirPanelSheriff", source, result)
        end)
    else
        VORPcore.NotifyLeft(source, Config.Textos.Notify.collect, Config.Textos.Notify.notpermiscommad, "toasts_mp_generic", "toast_mp_customer_service", 4000, "COLOR_RED")
    end
end)

RegisterServerEvent("rs_fines:solicitarMultas")
AddEventHandler("rs_fines:solicitarMultas", function()
    local src = source
    local User = VORPcore.getUser(src)
    local Character = User.getUsedCharacter
    local autorCompleto = Character.firstname .. " " .. Character.lastname

    local query = [[
        SELECT 
            id, nombre, apellido, id_multado, motivo, monto, autor, 
            CAST(pagada AS UNSIGNED) AS pagada,
            CAST(recolectada AS UNSIGNED) AS recolectada
        FROM multas
    ]]
    local params = {}

    if onlyOwn then
        query = query .. " WHERE autor = ?"
        params = { autorCompleto }
    end

    MySQL.query(query, params, function(result)
        TriggerClientEvent("rs_fines:recibirMultas", src, result)
    end)
end)

RegisterServerEvent("rs_fines:recolectarMultas")
AddEventHandler("rs_fines:recolectarMultas", function()
    local src = source
    local User = VORPcore.getUser(src)
    if not User then return end
    local Character = User.getUsedCharacter
    if not Character then return end
    local job = Character.job
    local grade = Character.jobGrade
    local autorCompleto = Character.firstname .. " " .. Character.lastname

    if not canCollectMoney(job, grade) then
        VORPcore.NotifyLeft(src, Config.Textos.Notify.collect, Config.Textos.Notify.notpermistocollect, "toasts_mp_generic", "toast_mp_customer_service", 4000, "COLOR_RED")
        return
    end

    local query = 'SELECT * FROM multas WHERE pagada = 1 AND recolectada = 0'
    local params = {}

    if onlyOwn then
        query = query .. ' AND autor = ?'
        params = { autorCompleto }
    end

    MySQL.query(query, params, function(result)
        if not result or #result == 0 then
            VORPcore.NotifyLeft(src, Config.Textos.Notify.collect, Config.Textos.Notify.notfinetocollect, "toasts_mp_generic", "toast_mp_customer_service", 5000, "COLOR_BLUE")
            return
        end

        local total = 0
        local idsToUpdate = {}

        for _, multa in ipairs(result) do
            if not onlyOwn or multa.autor == autorCompleto then
                total = total + multa.monto
                table.insert(idsToUpdate, multa.id)
            end
        end

        if total > 0 then
            Character.addCurrency(0, total)

            for _, id in ipairs(idsToUpdate) do
                MySQL.update('UPDATE multas SET recolectada = 1 WHERE id = ?', {id})
            end

            VORPcore.NotifyLeft(src, Config.Textos.Notify.collect, Config.Textos.Notify.received .. total .. "$ " .. Config.Textos.Notify.amount, "toasts_mp_generic", "toast_mp_customer_service", 5000, "COLOR_GREEN")
        end
    end)
end)

RegisterServerEvent("rs_fines:eliminarMulta")
AddEventHandler("rs_fines:eliminarMulta", function(id)
    local src = source
    MySQL.execute('DELETE FROM multas WHERE id = ?', { id })
    TriggerClientEvent("rs_fines:multaEliminada", src)
end)
