Config = {}

Config.Prompt = 0x760A9C6F -- G

Config.Align = "top-right"  -- Align Menu Fines Pay Station

Config.ItemName = "fine_book" 
-- Item used to open the menu for creating invoices.
-- Config.jobRequiredItem = true → only players with the required job and grade can use it to create invoices.
-- If Config.jobRequiredItem = false → any player can use the item to create invoices, regardless of job,
-- as long as Config.onlyOwn = true.

Config.jobRequiredItem = true 
Config.allowedJobsItem = {
    police = {minGrade = 3}, -- If minGrade is 3, only players with the police job grade 3 or higher can use the item.
    marshal = {minGrade = 2}, -- Only marshals grade 2 or higher can use it.
    lawmen = {minGrade = false} -- If minGrade is false and Config.jobRequiredItem = true, any player with the lawmen job can create fines/invoices.
} -- You can remove or add as many as you want

Config.onlyOwn = true 
-- If true → only the person who created the fine/invoice can see it and collect it using the /collectfines command.
-- Useful if you want to use the system for invoices: only the person who issued the invoice can collect the money.
-- If false → anyone who uses the command can collect all paid fines/invoices.
-- This is useful if you have a higher job in Config.allowedJobsCollect that is meant to review and collect all paid fines.

Config.Command = "collectfines" 
Config.jobRequiredCollect = true 
-- If Config.jobRequiredCollect = false and Config.onlyOwn = true → only the player who used the item and created the invoice can collect the money.
-- If Config.jobRequiredCollect = true → you need to associate the job with Config.jobRequiredItem = true so that the player can create invoices
-- and then collect the money when the recipient pays it.
-- If false → no job or grade is required to collect invoices if Config.onlyOwn = true.
-- If Config.onlyOwn = false → any player can collect the money. Be careful with this setting!

Config.allowedJobsCollect = {
    police = {minGrade = 3}, -- If Config.onlyOwn = true and Config.jobRequiredCollect = true, only police grade 3+ can open the panel and collect fines.
    marshal = {minGrade = 2}, -- Only marshals grade 2+ can open the panel and collect fines.
    lawmen = {minGrade = false} -- If minGrade is false, anyone with that job can open the menu and collect.
}  -- You can remove or add as many as you want

-- Payment locations on the map where invoices/fines can be paid.
-- You can add as many as you want.
Config.puntosPago = {
    vector3(-810.59, -1277.49, 43.64), -- Blackwater Bank
    vector3(-305.08, 775.3, 118.7),    -- Valentine Bank
    vector3(2648.49, -1294.21, 52.25), -- Sain Denist Bank
    vector3(1292.35, -1301.57, 77.04), -- Rhodes Bank
    vector3(2939.54, 1288.55, 44.65),  -- Annesburg Train Station
}

-- Toggle whether blips should be created on the map
Config.EnableBlips = true -- true = blips will be created / false = no blips

-- List of blips to display on the map if EnableBlips is true
Config.BlipsFines = {
    -- Each entry represents a fines station with its position, name, and blip sprite
    { pos = vector3(-810.59, -1277.49, 43.64), name = "Blackwater Fines Pay Station", sprite = 587827268 },
    { pos = vector3(-305.08, 775.3, 118.7), name = "Valentine Fines Pay Station", sprite = 587827268 },
    { pos = vector3(2648.49, -1294.21, 52.25), name = "Saint Denis Fines Pay Station", sprite = 587827268 },
    { pos = vector3(1292.35, -1301.57, 77.04), name = "Rhodes Fines Pay Station", sprite = 587827268 },
    { pos = vector3(2939.54, 1288.55, 44.65), name = "Annesburg Fines Pay Station", sprite = 587827268 },
}

-- Toggle whether NPCs should be spawned at the stations
Config.EnableNPCs = true -- true = NPCs will be spawned / false = no NPCs

-- NPC configuration
Config.NPC = {
  model = "A_M_M_RHDOBESEMEN_01", -- Model name of the NPC to be used

  -- List of coordinates where NPCs will be placed if EnableNPCs is true
  -- Each entry is a vector4 with position (x, y, z) and heading (w)
  coords = {
    vector4(-810.51, -1275.36, 43.64, 193.4),
    vector4(-306.18, 773.53, 118.7, 327.32),
    vector4(2646.99, -1294.75, 52.25, 310.81),
    vector4(1291.23, -1303.29, 77.04, 325.85),
    vector4(2939.02, 1286.95, 44.65, 350.03),
  }
}

Config.Textos = {
    tituloPagina = "Fine System",
    formularioTitulo = "Fine Book",
    panelTitulo = "Sheriff Panel",
    labelNombre = "First Name:",
    labelApellido = "Last Name:",
    labelPanelID = "Offender ID:",
    labelPanelMotivo = "Reason for Fine:",
    labelPanelMonto = "Fine Amount $:",
    botonRegistrar = "Register Fine",
    buscadorPlaceholder = "Search by first or last name...",
    botonRecolectar = "Collect Paid Fines",
    estadoPagada = "Paid",
    estadoPendiente = "Unpaid",
    promptTitulo = "Ticket System",
    press = "Press [G] to pay your fines",
    labelID = "ID:",
    labelMotivo = "Reason:",
    labelMonto = "Amount:",
    autorLabel = "Author:",
    estadoLabel = "Status:",
    menuamount = "Fine in the amount of ",
    menureason = "Reason : ",
    botonEliminar = "Delete",
    estadoRecolectada = "Collected",
    Notify = {
        collect = "Fine System",
        notpermisitem = "You don't have permission to use this item.",
        notid = "No player found with that ID.",
        correctfine = "Fine successfully registered.",
        notfine = "You have no pending fines.",
        corectpay = "Fine successfully paid.",
        notmoney = "You don't have enough money.",
        notpermiscommad = "You don't have permission to use this command.",
        received = "You have collected ",
        amount = " in paid fines.",
        notfinetocollect = "There are no paid fines to collect.",
        notpermistocollect = "You don't have permission to collect fines.",
        multaEliminada = "Fine successfully removed",
        -- new notification
        recivefine =  "You have received a fine of",
    }
}
