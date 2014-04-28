DROP DATABASE IF EXISTS ATN_db;
CREATE DATABASE ATN_db;

USE ATN_db;

SET GLOBAL log_bin_trust_function_creators = 1;

DROP TABLE IF EXISTS user;
CREATE TABLE user
(
	u_id INT auto_increment,
	uname VARCHAR(50),
	pass VARCHAR(100),
	PRIMARY KEY(u_id)
);

DROP TABLE IF EXISTS site;
CREATE TABLE site
(
	u_id INT,
	url VARCHAR(100),
	FOREIGN KEY (u_id) references user(u_id)
);

DROP TABLE IF EXISTS s_keys;
CREATE TABLE s_key
(
	u_id INT,
	s_key VARCHAR(100),
	FOREIGN KEY (u_id) references user(u_id)
);

DROP TABLE IF EXISTS stories;
CREATE TABLE stories
(
	u_id INT,
	s_num INT auto_increment,
	title TEXT,
	des TEXT,
	link TEXT,
	s_date DATETIME,
	rank INT,
	PRIMARY KEY (s_num),
	FOREIGN KEY (u_id) references user(u_id)	
);

DROP TRIGGER IF EXISTS repeatTrig;
DELIMITER //
CREATE TRIGGER repeatTrig
BEFORE INSERT ON stories
FOR EACH ROW
BEGIN
	SET NEW.rank=(dateRank(NEW.s_date, NEW.rank));

	IF (SELECT  COUNT(*) FROM stories WHERE title=NEW.title GROUP BY title) > 0 THEN
		DELETE FROM stories WHERE s_num=NEW.s_num;
		/*SIGNAL SQLSTATE '45000'
						SET MESSAGE_TEXT = "Repeat Stopping";*/
	END IF;
END;
//
DELIMITER ;

DROP FUNCTION IF EXISTS dateRank;
DELIMITER //
CREATE FUNCTION dateRank
(
	pubDate DATETIME,
	rank INT
)
RETURNS INT
BEGIN
	SET rank = rank + ((TIMESTAMPDIFF(hour, NOW(), pubDate)/3));
	RETURN rank;
END;
//
DELIMITER ;

