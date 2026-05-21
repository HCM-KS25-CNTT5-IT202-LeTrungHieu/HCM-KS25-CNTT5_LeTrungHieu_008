create database if not exists football_db;
use football_db;
# phần 1
CREATE TABLE IF NOT EXISTS teams (
    team_id INT PRIMARY KEY AUTO_INCREMENT,
    team_name VARCHAR(100) NOT NULL,
    founded_year YEAR NOT NULL,
    stadium VARCHAR(100) NOT NULL,
    ranking_position INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS coaches (
    coach_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    nationality VARCHAR(50) NOT NULL,
    experience_years INT DEFAULT 0,
    team_id INT,
    CONSTRAINT fk_coaches_team FOREIGN KEY (team_id)
        REFERENCES teams (team_id)
);

CREATE TABLE IF NOT EXISTS players (
    player_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    jersey_number INT NOT NULL,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(12 , 2 ) NOT NULL,
    team_id INT,
    CONSTRAINT fk_players_team FOREIGN KEY (team_id)
        REFERENCES teams (team_id)
);

CREATE TABLE IF NOT EXISTS matches (
    match_id INT PRIMARY KEY AUTO_INCREMENT,
    home_team_id INT,
    away_team_id INT,
    win_team_id INT,
    match_date DATETIME NOT NULL,
    stadium VARCHAR(100) NOT NULL,
    match_status VARCHAR(30) DEFAULT 'Scheduled',
    CONSTRAINT fk_matches_home_team FOREIGN KEY (home_team_id)
        REFERENCES teams (team_id),
    CONSTRAINT fk_matches_away_team FOREIGN KEY (away_team_id)
        REFERENCES teams (team_id),
    CONSTRAINT chk_win_team_id CHECK (win_team_id IN (home_team_id , away_team_id, -1)) -- -1 là Hòa
);

CREATE TABLE IF NOT EXISTS player_statistics (
    stat_id INT PRIMARY KEY AUTO_INCREMENT,
    player_id INT,
    match_id INT,
    goals INT DEFAULT 0,
    assists INT DEFAULT 0,
    yellow_cards INT DEFAULT 0,
    rating_score DECIMAL(3 , 1 ) DEFAULT 0,
    CONSTRAINT fk_pStatistics_player FOREIGN KEY (player_id)
        REFERENCES players (player_id),
    CONSTRAINT fk_pStatistics_match FOREIGN KEY (match_id)
        REFERENCES matches (match_id)
);

# Bảng lịch sử chuyển nhượng
CREATE TABLE IF NOT EXISTS transfer_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    player_id INT,
    old_team_id INT,
    new_team_id INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_histories_player FOREIGN KEY (player_id)
        REFERENCES players (player_id),
    CONSTRAINT chk_same_oldnew_team_id CHECK (old_team_id <> new_team_id)
);

CREATE TRIGGER ten_trg
AFTER/BEFORE UPDATE on ten_bang
FOR EACH ROW
BEGIN
END //

# Phần 2
# Câu 1
INSERT INTO teams (team_name, founded_year, stadium, ranking_position)
VALUES 
	('Manchester City', '1901', 'Etihad Stadium', 1),
  ('Real Marid', '1902', 'Santiago Bernabeu', 2),
  ('Hanoi FC', '2006', 'Hang Day Stadium', 3),
  ('Saigon United', '2015', 'Thong Nhat Stadium', 5),
  ('Thép xanh Nam Định', '1979', 'Thiên Trường Stadium', 10);
  
INSERT INTO coaches (full_name, nationality, experience_years, team_id )
VALUES
	('Pep Guardiola', 'Spanish', 15, 1),
  ('Carlo Ancelotti', 'Italian', 25, 2),
  ('Chu Đình Nghiêm', 'Vietnamese', 12, 3),
  ('Alexandre Polking', 'German-Brazilian', 10, 4),
  ('Park Hang-seo', 'Korean', 30, 5);
  
INSERT INTO players (full_name, jersey_number, position, salary, team_id)
VALUES
	('Erling Haaland', 9, 'Forward', 450000000, 1),
  ('Kevin De Bruyne', 17, 'Midfielder', 400000000, 1),
  ('Nguyễn Quang Hải', 19, 'Midfielder', 60000000, 3),
  ('Kylian Mbappe', 7, 'Forward', 500000000, 2),
  ('Nguyễn Văn Quyết', 10, 'Forward', 55000000, 3);
  
  
INSERT INTO matches(home_team_id, away_team_id, win_team_id, match_date, stadium, match_status)
VALUES
	(1, 2, 2, '2026-05-10 19:00', 'Etihad Stadium', 'Finished'),
  (3, 4, 3, '2026-05-12 18:30', 'Hang Day Stadium', 'Finished'),
  (5, 1, NULL, '2026-05-15 20:00', 'Thien Truong Stadium', 'Scheduled'),
  (2, 3, NULL, '2026-05-20 21:00', 'Santiago Bernabeu', 'Scheduled'),
  (4, 5, NULL, '2026-05-25 17:00', 'Thong Nhat Stadium', 'Scheduled');
  
INSERT INTO player_statistics (player_id, match_id, goals, assists, yellow_cards, rating_score)
VALUES 
	(1, 1, 2, 1, 0, 9.5),
	(4, 1, 1, 0, 1, 8.2),
  (3, 2, 0, 2, 0, 8.5),
  (5, 2, 3, 0, 0, 9.0),
  (1, 4, 0, 0, 3, 5.0);

SET SQL_SAFE_UPDATES = 0;
# Câu 2
# Tăng 15% lương cho các cầu thủ
UPDATE players p
        JOIN
    player_statistics ps ON p.player_id = ps.player_id 
SET 
    salary = salary * 1.15
WHERE
    p.position = 'Forward'
        AND ps.rating_score > 8.0;
  
# Xóa các bản ghi trong player_statistics
DELETE FROM player_statistics 
WHERE
    yellow_cards > 2;
    
# phần 3
# Câu 1
SELECT 
    full_name, jersey_number, position
FROM
    players
WHERE
    salary > 50000000
        OR position = 'Midfielder';
        
# Câu 2
SELECT 
    team_name, stadium
FROM
    teams
WHERE
    (ranking_position BETWEEN 1 AND 5)
        AND stadium LIKE 'S%';
        
# Câu 3
SELECT 
    match_id, stadium, match_date
FROM
    matches
ORDER BY match_date DESC
LIMIT 3 OFFSET 3;

# Phần 4
# Câu 1
SELECT 
    p.full_name,
    IFNULL(t.team_name, 'Chưa có đội bóng') AS team_name,
    IFNULL(ps.goals, 0) AS goals,
    IFNULL(ps.assists, 0) AS assists
FROM
    players p
        LEFT JOIN
    teams t ON t.team_id = p.team_id
        LEFT JOIN
    player_statistics ps ON ps.player_id = p.player_id;

# Câu 2
SELECT 
    t.team_name, IFNULL(SUM(ps.goals), 0) AS total_goals
FROM
    teams t
        LEFT JOIN
    players p ON t.team_id = p.team_id
        LEFT JOIN
    player_statistics ps ON p.player_id = ps.player_id
GROUP BY t.team_name
HAVING total_goals > 10;

# Câu 3
SELECT 
    player_id, full_name, salary
FROM
    players
ORDER BY salary DESC
LIMIT 1;

# Phần 5
# Câu 1
CREATE INDEX idx_position_salary ON players(position, salary);

# Câu 2
CREATE OR REPLACE VIEW vw_team_statistics AS
    SELECT 
        t.team_name,
        COUNT(DISTINCT p.player_id) AS total_players,
        IFNULL(SUM(p.salary), 0) AS total_salary
    FROM
        teams t
            LEFT JOIN
        players p ON t.team_id = p.team_id
    GROUP BY t.team_name;

# SELECT 
#     *
# FROM
#     vw_team_statistics;

# Phần 6
# Câu 1
DELIMITER //
CREATE TRIGGER tg_update_salary_on_statistics
BEFORE INSERT ON player_statistics
FOR EACH ROW
BEGIN
	IF NEW.goals > 10 THEN
		UPDATE players 
    SET salary = salary * 1.05
    WHERE player_id = NEW.player_id;
  END IF;
END //

# Test câu 1
# INSERT INTO player_statistics (player_id, match_id, goals)
# VALUES
# 	(2, 1, 11);

# Câu 2
DELIMITER //
CREATE TRIGGER trg_add_rk_pos_after_match_finished
AFTER UPDATE ON matches
FOR EACH ROW
BEGIN
	IF NEW.match_status = 'Finished' THEN
		UPDATE teams SET ranking_position = ranking_position + 1
    WHERE team_id = NEW.win_team_id;
  END IF ;
END //

DELIMITER ;

# Phần 7
# Câu 1
DELIMITER //
CREATE PROCEDURE sp_rating_player(IN p_player_id INT, OUT p_message VARCHAR(15))
BEGIN
	DECLARE v_goals INT DEFAULT 0;
  
	IF NOT EXISTS (
		SELECT 1 FROM players WHERE player_id = p_player_id
  ) THEN
		SIGNAL SQLSTATE '45000'
    SET message_text = 'Lỗi: Cầu thủ không có trong hệ thống';
  END IF;
  
  SELECT ps.goals INTO v_goals
  FROM players p
  JOIN player_statistics ps
  ON p.player_id = ps.player_id
  WHERE p.player_id = p_player_id;
  
  IF v_goals > 10 THEN
		SET p_message = 'Excellent';
  ELSEIF v_goals BETWEEN 10 AND 20 THEN
		SET p_message = 'Good';
	ELSEIF v_goals < 10 THEN
		SET p_message = 'Good';
	END IF;
END //
DELIMITER ;

CALL sp_rating_player(1, @message);
SELECT @message;

DELIMITER //
CREATE PROCEDURE transfer_player(IN p_player_id INT, IN p_old_team_id INT, IN p_new_team_id INT)
BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
		ROLLBACK;
    RESIGNAL;
  END;
	START TRANSACTION;
		IF NOT EXISTS (SELECT 1 FROM players WHERE player_id = p_player_id) THEN
			ROLLBACK;
			SIGNAL SQLSTATE '45000'
      SET message_text = 'Lỗi: Cầu thủ không tồn tại';
    END IF ;
    
    IF NOT EXISTS (SELECT 1 FROM teams WHERE team_id = p_old_team_id) THEN
			ROLLBACK;
      SIGNAL SQLSTATE '45000'
      SET message_text = 'Lỗi: Đội bóng cũ không tồn tại';
    END IF ;
    
    IF NOT EXISTS (SELECT 1 FROM teams WHERE team_id = p_new_team_id) THEN
			ROLLBACK;
      SIGNAL SQLSTATE '45000'
      SET message_text = 'Lỗi: Đội bóng mới không tồn tại';
    END IF ;
    
		UPDATE players SET team_id = p_team_id WHERE player_id = p_player_id;
    
    INSERT INTO transfer_history (player_id, old_team_id, new_team_id)
    VALUES
			(p_player_id, p_old_team_id, p_new_team_id);
  COMMIT;
END //
DELIMITER ;

# Lỗi không tồn tại player
CALL transfer_player(100, 1, 2);

# Lỗi không tồn tại team cũ
CALL transfer_player(1, 100, 2);

# Lỗi không tồn tại team mới
CALL transfer_player(1, 1, 100);

# Chuyển nhượng thành công
CALL transfer_player(1, 1, 2);