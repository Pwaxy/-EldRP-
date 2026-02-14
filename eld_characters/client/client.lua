local uiOpen = false
local creatorOpen = false

local function lockPlayer(lock, visibleInCreator)
  local ped = PlayerPedId()

  FreezeEntityPosition(ped, lock)
  SetEntityInvincible(ped, lock)

  -- In selection unsichtbar, im Creator sichtbar
  if visibleInCreator then
    SetEntityVisible(ped, true, false)
  else
    SetEntityVisible(ped, not lock, false)
  end

  SetPlayerControl(PlayerId(), not lock, 0)
end

-- Hard block controls while UI/Creator open (fixes camera turning)
Citizen.CreateThread(function()
  while true do
    if uiOpen or creatorOpen then
      DisableAllControlActions(0)
      DisableAllControlActions(1)
      DisableAllControlActions(2)
      Wait(0)
    else
      Wait(250)
    end
  end
end)

local function moveToStaging()
  local ped = PlayerPedId()
  -- unter die map, damit nix “gespawnt” sichtbar ist
  SetEntityCoords(ped, 0.0, 0.0, -200.0, false, false, false, true)
end

local function setUi(open)
  uiOpen = open
  creatorOpen = false

  if open then
    DoScreenFadeOut(200)
    while not IsScreenFadedOut() do Wait(0) end

    moveToStaging()
    lockPlayer(true, false)

    SetNuiFocus(true, true)
    if SetNuiFocusKeepInput then
      SetNuiFocusKeepInput(false)
    end
    SetCursorLocation(0.5, 0.5)
    SendNUIMessage({ action = "open" })

    DoScreenFadeIn(200)
  else
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
  end
end

local function setCreatorUi(open, info)
  creatorOpen = open
  uiOpen = not open and uiOpen or uiOpen -- uiOpen bleibt true “im Hintergrund”

  if open then
    -- Im Creator: sichtbar, aber weiterhin Controls gesperrt + Maus aktiv
    lockPlayer(true, true)

    SetNuiFocus(true, true)
    SetCursorLocation(0.5, 0.5)
    SendNUIMessage({ action = "creator_open", data = info })
  else
    creatorOpen = false
    -- zurück zur selection UI
    lockPlayer(true, false)
    SetNuiFocus(true, true)
    SetCursorLocation(0.5, 0.5)
    SendNUIMessage({ action = "open" })
  end
end

local function setPlayerModel(modelName)
  if not modelName or modelName == "" then return end
  local model = GetHashKey(modelName)

  RequestModel(model)
  while not HasModelLoaded(model) do Wait(0) end

  SetPlayerModel(PlayerId(), model, false)
  SetModelAsNoLongerNeeded(model)
end

local function applyAppearance(appearanceJson)
  if not appearanceJson or appearanceJson == "" then return end
  if not json or not json.decode then return end

  local ok, data = pcall(function() return json.decode(appearanceJson) end)
  if not ok or not data then return end

  if data.model then
    setPlayerModel(data.model)
  end
end

RegisterNetEvent("eld:chars:open")
AddEventHandler("eld:chars:open", function()
  setUi(true)
  TriggerServerEvent("eld:chars:list")
end)

RegisterNetEvent("eld:chars:listResult")
AddEventHandler("eld:chars:listResult", function(payload)
  SendNUIMessage({ action = "list", data = payload })
end)

RegisterNetEvent("eld:chars:error")
AddEventHandler("eld:chars:error", function(msg)
  SendNUIMessage({ action = "error", message = msg })
end)

RegisterNetEvent("eld:chars:created")
AddEventHandler("eld:chars:created", function(charId)
  SendNUIMessage({ action = "created", charId = charId })
  TriggerServerEvent("eld:chars:list")
end)

RegisterNetEvent("eld:chars:spawn")
AddEventHandler("eld:chars:spawn", function(c)
  -- UI komplett schließen
  uiOpen = false
  creatorOpen = false

  SetNuiFocus(false, false)
  SendNUIMessage({ action = "close" })

  -- Spieler wieder freigeben
  lockPlayer(false, false)

  local ped = PlayerPedId()
  SetEntityCoords(ped, (c.x or 0) + 0.0, (c.y or 0) + 0.0, (c.z or 0) + 0.0, false, false, false, true)

  if c.appearance then
    applyAppearance(c.appearance)
  end
end)

-- NUI callbacks
RegisterNUICallback("select", function(data, cb)
  TriggerServerEvent("eld:chars:select", data.charId)
  cb({ ok = true })
end)

RegisterNUICallback("create", function(data, cb)
  TriggerServerEvent("eld:chars:create", data.first, data.last)
  cb({ ok = true })
end)

RegisterNUICallback("close", function(_, cb)
  -- Ich empfehle: nicht komplett schließen, solange kein Char selected ist.
  -- Aber wenn du es erlauben willst, bleibt staging/lock aktiv.
  setUi(false)
  cb({ ok = true })
end)

-- Creator open from server
RegisterNetEvent("eld:creator:open")
AddEventHandler("eld:creator:open", function(info)
  setCreatorUi(true, info)
end)

-- Creator finish from UI
RegisterNUICallback("creatorFinish", function(data, cb)
  TriggerServerEvent("eld:creator:finish", data.charId, data.appearance)
  cb({ ok = true })
end)
