local uiOpen = false

local function setUi(open)
  uiOpen = open
  SetNuiFocus(open, open)

  local ped = PlayerPedId()
  FreezeEntityPosition(ped, open)
  SetEntityVisible(ped, not open, false)
  SetPlayerControl(PlayerId(), not open, 0)

  SendNUIMessage({ action = open and "open" or "close" })
end

local function setCreatorUi(open, info)
  SetNuiFocus(open, open)

  local ped = PlayerPedId()
  FreezeEntityPosition(ped, open)
  SetEntityVisible(ped, true, false) -- im Creator sichtbar lassen
  SetPlayerControl(PlayerId(), not open, 0)

  if open then
    SendNUIMessage({ action = "creator_open", data = info })
  else
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
  setUi(false)

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
