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

RegisterNetEvent("eld:chars:open")
AddEventHandler("eld:chars:open", function()
  setUi(true)
  -- ask server for list
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
  SetEntityCoords(ped, c.x + 0.0, c.y + 0.0, c.z + 0.0, false, false, false, true)
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

-- Character create

RegisterNetEvent("eld:creator:open")
AddEventHandler("eld:creator:open", function(info)
  -- UI öffnen + freeze wie chars ui
  SetNuiFocus(true, true)
  local ped = PlayerPedId()
  FreezeEntityPosition(ped, true)
  SetEntityVisible(ped, true, false) -- sichtbar im creator
  SetPlayerControl(PlayerId(), false, 0)

  SendNUIMessage({ action = "creator_open", data = info })
end)
