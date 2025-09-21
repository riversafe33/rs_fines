local Menu = exports.vorp_menu:GetMenuData()
local VORPcore = exports.vorp_core:GetCore()
local Blips = {}
local NPCs = {}

RegisterNetEvent("rs_fines:abrirFormulario")
AddEventHandler("rs_fines:abrirFormulario", function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "abrirFormulario",
        textos = Config.Textos
    })
end)

RegisterNUICallback("registrarMulta", function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent("rs_fines:guardarMulta", data)
    cb({})
end)

RegisterNUICallback("cerrarFormulario", function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNetEvent("rs_fines:abrirPanelSheriff")
AddEventHandler("rs_fines:abrirPanelSheriff", function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "abrirPanelSheriff",
        textos = Config.Textos
    })
    TriggerServerEvent("rs_fines:solicitarMultas")
end)

RegisterNetEvent("rs_fines:recibirMultas")
AddEventHandler("rs_fines:recibirMultas", function(multas)
    SendNUIMessage({
        action = "actualizarMultas",
        multas = multas,
        textos = Config.Textos
    })
end)

RegisterNUICallback("cerrarSheriff", function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback("recolectarMultas", function(_, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent("rs_fines:recolectarMultas")
    cb({})
end)

RegisterNUICallback("eliminarMulta", function(data, cb)
    TriggerServerEvent("rs_fines:eliminarMulta", data.id)
    cb({})
end)

RegisterNetEvent("rs_fines:multaEliminada")
AddEventHandler("rs_fines:multaEliminada", function()
    VORPcore.NotifyLeft( Config.Textos.Notify.collect, Config.Textos.Notify.multaEliminada, "toasts_mp_generic", "toast_mp_customer_service", 4000, "COLOR_GREEN" )
end)

RegisterNetEvent("rs_fines:mostrarMenuPago")
AddEventHandler("rs_fines:mostrarMenuPago", function(multas)
    local menuElements = {}

    for _, multa in ipairs(multas) do
        table.insert(menuElements, {
            label = Config.Textos.menuamount .. multa.label,
            value = multa.value,
            desc = Config.Textos.menureason .. multa.desc,
        })
    end

    Menu.Open("default", GetCurrentResourceName(), "menuPagoMultas", {
        title = "Pending Fines",
        align = Config.Align,
        elements = menuElements
    }, function(data, menu)
        TriggerServerEvent("rs_fines:pagarMulta", data.current.value)
        Menu.CloseAll()
    end, function(data, menu)
        Menu.CloseAll()
    end)
end)


RegisterNetEvent("rs_fines:mostrarMenuPago")
AddEventHandler("rs_fines:mostrarMenuPago", function(multas)
    local menuElements = {}

    for _, multa in ipairs(multas) do
        table.insert(menuElements, {
            label = Config.Textos.menuamount .. multa.label,
            value = multa.value,
            desc = Config.Textos.menureason .. multa.desc,
        })
    end

    Menu.Open("default", GetCurrentResourceName(), "menuPagoMultas", {
        title = "Pending Fines",
        align = Config.Align,
        elements = menuElements
    }, function(data, menu)
        TriggerServerEvent("rs_fines:pagarMulta", data.current.value)
        Menu.CloseAll()
    end, function(data, menu)
        Menu.CloseAll()
    end)
end)

Citizen.CreateThread(function()
    local mostrandoPago = false

    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local cercaPago = false

        for _, punto in ipairs(Config.puntosPago) do
            if #(playerCoords - punto) < 1.5 then
                cercaPago = true

                if not mostrandoPago then
                    SendNUIMessage({
                        type = "showprompt",
                        text = Config.Textos.press
                    })
                    mostrandoPago = true
                end

                if IsControlJustReleased(0, Config.Prompt) then
                    TriggerServerEvent("rs_fines:abrirMenuPago")
                end
                break
            end
        end

        if not cercaPago and mostrandoPago then
            SendNUIMessage({ type = "hideprompt" })
            mostrandoPago = false
        end

        Citizen.Wait(cercaPago and 0 or 500)
    end
end)

Citizen.CreateThread(function()
    if not Config.EnableBlips then return end

    for _, location in pairs(Config.BlipsFines) do
        local blip = N_0x554d9d53f696d002(1664425300, location.pos.x, location.pos.y, location.pos.z)
        SetBlipSprite(blip, location.sprite, 1)
        SetBlipScale(blip, 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, location.name)
        table.insert(Blips, blip)
    end
end)

Citizen.CreateThread(function()
    if not Config.EnableNPCs then return end

    for _, coords in pairs(Config.NPC.coords) do
        TriggerEvent("rs_fines:CreateNPC", coords)
    end
end)

RegisterNetEvent("rs_fines:CreateNPC")
AddEventHandler("rs_fines:CreateNPC", function(zone)
    if not zone then return end

    local model = GetHashKey(Config.NPC.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(500) end

    local npc = CreatePed(model, zone.x, zone.y, zone.z - 1, zone.w, false, true)
    Citizen.InvokeNative(0x283978A15512B2FE , npc, true)
    SetEntityNoCollisionEntity(PlayerPedId(), npc, false)
    SetEntityCanBeDamaged(npc, false)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetModelAsNoLongerNeeded(model)

    table.insert(NPCs, npc)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    for _, blip in pairs(Blips) do
        RemoveBlip(blip)
    end

    for _, npc in pairs(NPCs) do
        if DoesEntityExist(npc) then
            DeleteEntity(npc)
        end
    end
end)
