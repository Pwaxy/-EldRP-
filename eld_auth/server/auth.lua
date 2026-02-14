local Players = {} -- src -> { playerId, license, steam, discord }

local function getIdentifiers(src)
  local ids = {
    license = nil,
    steam = nil,
    discord = nil,
  }

  for i = 0, GetNumPlayerIdentifiers(src) - 1 do
    local id = GetPlayerIdentifier(src, i)
    if id then
      if id:sub(1, 8) == "license:" then ids.license = id
      elseif id:sub(1, 6) == "steam:" then ids.steam = id
      elseif id:sub(1, 8) == "discord:" then ids.discord = id
      end
    end
  end

  return ids
end

local function nowUtcSql()
  -- MariaDB/MySQL DATETIME, UTC
  return os.date("!%Y-%m-%d %H:%M:%S")
end

local function upsertPlayer(ids)
  local now = os.date("!%Y-%m-%d %H:%M:%S")

  -- MariaDB: RETURNING liefert auch bei Duplicate Key die id zurück
  local rows = exports.oxmysql:query_async([[
    INSERT INTO players (license, steam, discord, first_seen, last_seen)
    VALUES (?, ?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE
      steam = VALUES(steam),
      discord = VALUES(discord),
      last_seen = VALUES(last_seen)
    RETURNING id
  ]], { ids.license, ids.steam, ids.discord, now, now })

  if rows and rows[1] and rows[1].id then
    return tonumber(rows[1].id)
  end

  return nil
end


AddEventHandler("playerJoining", function()
  local src = source
  local ids = getIdentifiers(src)

  if not ids.license then
    print(("[eld_auth] src=%d missing license, cannot track player"):format(src))
    return
  end

  -- upsert + cache
  local playerId = upsertPlayer(ids)

  if not playerId then
  print(("[eld_auth] src=%d ERROR: playerId is nil (DB query failed)"):format(src))
  return
end

  Players[src] = {
    playerId = playerId,
    license = ids.license,
    steam = ids.steam,
    discord = ids.discord
  }

  print(("[eld_auth] src=%d playerId=%s license=%s"):format(src, tostring(playerId), ids.license))

  -- broadcast for other resources
  TriggerEvent("eld:auth:ready", src, Players[src])
end)

AddEventHandler("playerDropped", function()
  Players[source] = nil
end)

-- optional export: other resources can grab it anytime
exports("GetPlayerAuth", function(src)
  return Players[src]
end)