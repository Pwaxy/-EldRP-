CreateThread(function()
  -- players
  DB.execute([[
    CREATE TABLE IF NOT EXISTS players (
      id INT NOT NULL AUTO_INCREMENT,
      license VARCHAR(64) NOT NULL,
      steam VARCHAR(64) NULL,
      discord VARCHAR(64) NULL,
      first_seen DATETIME NOT NULL,
      last_seen DATETIME NOT NULL,
      PRIMARY KEY (id),
      UNIQUE KEY uq_players_license (license)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]])

  -- characters
  DB.execute([[
    CREATE TABLE IF NOT EXISTS characters (
      id INT NOT NULL AUTO_INCREMENT,
      player_id INT NOT NULL,
      first_name VARCHAR(32) NOT NULL,
      last_name VARCHAR(32) NOT NULL,
      created_at DATETIME NOT NULL,
      last_played DATETIME NULL,
      pos_x DOUBLE NOT NULL DEFAULT 0,
      pos_y DOUBLE NOT NULL DEFAULT 0,
      pos_z DOUBLE NOT NULL DEFAULT 0,
      PRIMARY KEY (id),
      KEY idx_char_player (player_id),
      CONSTRAINT fk_char_player FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
  ]])

  DB.execute([[
  CREATE TABLE IF NOT EXISTS characters (
    id INT NOT NULL AUTO_INCREMENT,
    player_id INT NOT NULL,
    first_name VARCHAR(32) NOT NULL,
    last_name VARCHAR(32) NOT NULL,
    created_at DATETIME NOT NULL,
    last_played DATETIME NULL,
    pos_x DOUBLE NOT NULL DEFAULT 0,
    pos_y DOUBLE NOT NULL DEFAULT 0,
    pos_z DOUBLE NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    KEY idx_char_player (player_id),
    CONSTRAINT fk_char_player FOREIGN KEY (player_id) REFERENCES players(id) ON DELETE CASCADE
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
]])

  print("[eld_db] schema ensured ✅")
end)