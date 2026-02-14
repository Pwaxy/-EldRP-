local SelectedChar = {} -- src -> charId

local function nowUtc()
  return os.date("!%Y-%m-%d %H:%M:%S")
end

local function getAuth(src)
  return exports.eld_auth:GetPlayerAuth(src)
end

local function getCharSlots(playerId)
  local rows = exports.oxmysql:query_async("SELECT char_slots FROM players WHERE id=? LIMIT 1", { playerId })
  if rows and rows[1] and rows[1].char_slots then
    return tonumber(rows[1].char_slots) or 1
  end
  return 1
end

local function countChars(playerId)
  local rows = exports.oxmysql:query_async("SELECT COUNT(*) AS c FROM characters WHERE player_id=?", { playerId })
  if rows and rows[1] and rows[1].c then
    return tonumber(rows[1].c) or 0
  end
  return 0
end

local function listChars(playerId)
  return exports.oxmysql:query_async([[
    SELECT id, first_name, last_name, last_played
    FROM characters
    WHERE player_id=?
    ORDER BY id ASC
  ]], { playerId }) or {}
end

local function createChar(playerId, first, last)
  local spawn = { x = -368.0, y = 795.0, z = 116.0 } -- MVP spawn
  local now = nowUtc()

  exports.oxmysql:execute([[
    INSERT INTO characters (player_id, first_name, last_name, created_at, pos_x, pos_y, pos_z)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  ]], { playerId, first, last, now, spawn.x, spawn.y, spawn.z })

  local rows = exports.oxmysql:query_async("SELECT LAST_INSERT_ID() AS id", {})
  if rows and rows[1] and rows[1].id then
    return tonumber(rows[1].id)
  end
  return nil
end

local function getChar(charId)
  local rows = exports.oxmysql:query_async([[
    SELECT id, player_id, first_name, last_name, pos_x, pos_y, pos_z
    FROM characters
    WHERE id=?
    LIMIT 1
  ]], { charId })

  if rows and rows[1] then return rows[1] end
  return nil
end

local function setLastPlayed(charId)
  exports.oxmysql:execute("UPDATE characters SET last_played=? WHERE id=?", { nowUtc(), charId })
end

-- Auto-open UI after auth ready
AddEventHandler("eld:auth:ready", function(src, auth)
  TriggerClientEvent("eld:chars:open", src)
end)

-- NUI requests list
RegisterNetEvent("eld:chars:list")
AddEventHandler("eld:chars:list", function()
  local src = source
  local auth = getAuth(src)
  if not auth or not auth.playerId then return end

  local playerId = auth.playerId
  local slots = getCharSlots(playerId)
  local chars = listChars(playerId)

  TriggerClientEvent("eld:chars:listResult", src, {
    slots = slots,
    chars = chars
  })
end)

-- NUI create
RegisterNetEvent("eld:chars:create")
AddEventHandler("eld:chars:create", function(first, last)
  local src = source
  local auth = getAuth(src)
  if not auth or not auth.playerId then return end

  first = tostring(first or ""):gsub("[^%a%-'%s]", ""):sub(1, 32)
  last  = tostring(last or ""):gsub("[^%a%-'%s]", ""):sub(1, 32)

  if #first < 2 or #last < 2 then
    TriggerClientEvent("eld:chars:error", src, "Please enter a valid first and last name.")
    return
  end

  local playerId = auth.playerId
  local slots = getCharSlots(playerId)
  local cnt = countChars(playerId)

  if cnt >= slots then
    TriggerClientEvent("eld:chars:error", src, "No free character slots.")
    return
  end

  local charId = createChar(playerId, first, last)
  if not charId then
    TriggerClientEvent("eld:chars:error", src, "Failed to create character.")
    return
  end

  TriggerClientEvent("eld:chars:created", src, charId)
  TriggerClientEvent("eld:chars:list", src) -- refresh list (client will request)
end)

-- NUI select
RegisterNetEvent("eld:chars:select")
AddEventHandler("eld:chars:select", function(charId)
  local src = source
  local auth = getAuth(src)
  if not auth or not auth.playerId then return end

  charId = tonumber(charId)
  if not charId then return end

  local c = getChar(charId)
  if not c then
    TriggerClientEvent("eld:chars:error", src, "Character not found.")
    return
  end

  if tonumber(c.player_id) ~= tonumber(auth.playerId) then
    TriggerClientEvent("eld:chars:error", src, "Not your character.")
    return
  end

  SelectedChar[src] = charId
  setLastPlayed(charId)

  TriggerClientEvent("eld:chars:spawn", src, {
    charId = c.id,
    first = c.first_name,
    last = c.last_name,
    x = c.pos_x,
    y = c.pos_y,
    z = c.pos_z
  })
end)

AddEventHandler("playerDropped", function()
  SelectedChar[source] = nil
end)

exports("GetSelectedCharId", function(src)
  return SelectedChar[src]
end)