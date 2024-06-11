CREATE DATABASE CFGGaming;

USE CFGGaming;

CREATE TABLE Publisher
(Publisher_ID varchar(20) PRIMARY KEY,
Publisher_name varchar(255));

INSERT INTO Publisher
VALUES
('PU1', 'Rockstar Games'),
('PU2', 'Ubisoft'),
('PU3', 'Activision'),
('PU4', 'Take-two interactive'),
('PU5', 'EA'),
('PU6', 'Developer Digital'),
('PU7', 'Nintendo'),
('PU8', 'Xbox Game Studio'),
('PU9', 'Telltale Games'),
('PU10', '2K'),
('PU11', 'Paradox'),
('PU12', 'CAPCOM');

CREATE TABLE Genre
(Genre_ID Varchar(20) PRIMARY KEY,
Genre_name varchar (50));

INSERT INTO genre
VALUES
('GE1', 'Horror'),
('GE2', 'Simulation'),
('GE3', 'Survival'),
('GE4', 'RPG'),
('GE5', 'Action'),
('GE6', 'Sports'),
('GE7', 'Platform'),
('GE8', 'Puzzle'),
('GE9', 'FPS');

CREATE TABLE Region
(Region_ID varchar(20) PRIMARY KEY,
Region_name varchar(50));

CREATE TABLE Category
(Category_ID varchar(20) PRIMARY KEY,
Category_name varchar(50));

CREATE TABLE Platform
(Platform_ID varchar(20) PRIMARY KEY,
Platform_name varchar(50));

SET SQL_SAFE_UPDATES = 0;

SET FOREIGN_KEY_CHECKS=0;

SET GLOBAL event_scheduler = ON;


-- import games table data - change price to 'double'
ALTER TABLE game
CHANGE Game_ID Game_ID Varchar(20);

ALTER TABLE game
CHANGE Publisher_ID Publisher_ID Varchar(20);

ALTER TABLE game
CHANGE Genre_ID Genre_ID Varchar(20);

alter table game
change price price decimal(4,2);

ALTER TABLE Game
ADD primary key (Game_ID);

ALTER TABLE Game
ADD CONSTRAINT FOREIGN KEY (Genre_ID) REFERENCES Genre(Genre_ID),
ADD CONSTRAINT FOREIGN KEY (Publisher_ID) REFERENCES Publisher(Publisher_ID);

-- import Sales table data
ALTER TABLE sales
CHANGE transaction_ID transaction_ID Varchar(20),
CHANGE Game_ID Game_ID Varchar(20),
CHANGE Category_ID Category_ID Varchar(20),
CHANGE Platform_ID Platform_ID Varchar(20),
CHANGE region_sold region_sold Varchar(20);

ALTER TABLE sales
ADD PRIMARY KEY (Transaction_ID);

ALTER TABLE Sales 
ADD CONSTRAINT FOREIGN KEY (Game_ID) REFERENCES game(Game_ID),
ADD CONSTRAINT FOREIGN KEY (Category_ID) REFERENCES Category(Category_ID),
ADD CONSTRAINT FOREIGN KEY (Platform_ID) REFERENCES Platform(Platform_ID),
ADD CONSTRAINT FOREIGN KEY (region_sold) REFERENCES Region(region_ID);

-- import ratings table data
ALTER TABLE ratings
CHANGE rating_score rating_score decimal(4,2);

Alter table ratings
Change rating_ID rating_ID varchar(20);

Alter table ratings
Change Game_ID Game_ID varchar(20);

ALTER TABLE ratings
ADD PRIMARY KEY (Rating_ID);

ALTER TABLE ratings
ADD CONSTRAINT FOREIGN KEY (Game_ID) REFERENCES game(Game_ID);

-- insert data into last 3 tables
INSERT INTO region
VALUES
('RE1', 'South America'),
('RE2', 'Asia'),
('RE3', 'North America'),
('RE4', 'Australia'),
('RE5', 'Europe');

INSERT INTO Category
VALUES
('TY1', 'Digital'),
('TY2', 'Physical');

INSERT INTO Platform
VALUES
('PL1', 'Xbox one X'),
('PL2', 'Xbox Series S'),
('PL3', 'PS4'),
('PL4', 'PS5'),
('PL5', 'PC'),
('PL6', 'Nintendo'),
('PL7', 'Xbox 360'),
('PL8', 'PS3');

select * from game;

-- add avg rating for each game to game table from ratings table FINAL EXAMPLE
UPDATE game g
SET overall_rating = (select avg(rating_score)
                   FROM ratings r
                   WHERE r.game_id = g.game_id);

delete from game
where Overall_rating > 1;

-- Avg rating test 
SELECT * FROM game;

-- Alter the overall_rating data type
ALTER TABLE game
CHANGE Overall_rating Overall_rating decimal(4,2);

-- Avg rating test
SELECT * FROM game;

-- Trigger FINAL EXAMPLE
Select * from game;

DELIMITER //
CREATE TRIGGER Update_ratings
AFTER INSERT ON ratings
FOR EACH ROW
UPDATE game g
SET overall_rating = (select avg(rating_score) FROM ratings r
WHERE r.game_id = g.game_ID)
WHERE game_ID = NEW.game_ID;

-- Trigger test
INSERT INTO ratings
VALUES
('RA79', 'GA9', 5);

-- SS Stored Function  - shows us which genres are most expensive, mid range and most affordable FINAL EXAMPLE
DELIMITER //
CREATE FUNCTION Affordability( price INT )
returns varchar(20)
DETERMINISTIC
BEGIN
    DECLARE Affordability varchar(20);
    
	IF price > 50 then
   	 set Affordability = 'Most Expensive';       	 
    elseif ( price >= 40 and price <=50) then
   	 set Affordability = 'Mid Range Price';
    elseif price < 40 then
   	 set Affordability = 'Most affordable';
    END IF;
    return (Affordability);
END//
DELIMITER ;

-- Function Test
Select Game_name, genre_ID, Affordability(PRICE)
from game
order by Affordability(Price);

-- most sales by region
SELECT s.region_sold, COUNT(s.transaction_ID) as Noofsales, r.region_name
from sales s
left join region r
on r.region_ID = s.region_sold
group by region_sold
order by Noofsales DESC;

-- HC Join most sales of each region and game FINAL EXAMPLE
SELECT g1.game_name, s1.region_sold, COUNT(s1.transaction_ID) as Noofsales
FROM game as g1
LEFT JOIN sales as s1
ON g1.game_ID = s1.game_ID
group by g1.game_name, s1.region_sold
order by Noofsales DESC;

-- most sales by highest selling region FINAL EXAMPLE
SELECT g1.*, s1.*, g.*, p.*
FROM game as g1
LEFT JOIN sales as s1
ON g1.game_ID = s1.game_ID
LEFT JOIN genre g
ON g.genre_ID = g1.Genre_ID
LEFT JOIN Platform p
ON p.platform_ID = s1.platform_ID
WHERE s1.region_sold = 'RE5' -- change the Region_ID as needed
ORDER BY Game_name;

-- Join Shows us every rating ID and the game details together
select * from game as g
left join ratings as r
on g.Game_ID = r.Game_ID;

-- DF subquery Select sales by genre and their region
SELECT Game_ID AS Game, Region_sold AS Region_sold
FROM sales WHERE game_ID IN
(SELECT game_ID FROM game
WHERE genre_ID IN (SELECT genre_ID FROM genre WHERE Genre_name = 'Horror')) -- change based on genre query
order by region_sold;

-- DF2 subquery Select sales by genre and their region
SELECT Game_ID AS Game, Region_sold AS Region_sold
FROM sales WHERE game_ID IN
(SELECT game_ID FROM game
WHERE genre_ID IN (SELECT genre_ID FROM genre WHERE Genre_name = 'Horror')) -- change based on genre query
order by region_sold;

SELECT Game_ID AS GameID, Region_sold AS Region_sold
FROM sales  WHERE game_ID IN
(SELECT game_ID FROM game
WHERE genre_ID IN (SELECT genre_ID FROM genre WHERE Genre_name = 'Horror')) -- change based on genre query
order by region_sold;


-- subquery Most sales by game FINAL EXAMPLE
select count(transaction_ID) AS total_sales, s.game_ID
from sales as s where game_ID in 
(select g.game_ID from game as g where s.game_ID = g.Game_ID)
group by game_ID
order by count(transaction_ID) DESC;

-- subquery Most sales by game with game name
Select count(transaction_ID) AS total_sales, s.game_id, tab.game_name
FROM SALES as s
inner join
(select g.game_ID, g.game_name
from game as g) as tab
on s.game_id = tab.game_id
group by TAB.game_ID, tab.game_name
order by count(transaction_ID) DESC;

-- join most sales by game with game name
select count(transaction_ID) AS total_sales, g.game_ID, g.Game_name
from sales as s
inner join
game as g
where s.game_id = g.game_ID
group by g.game_id, g.game_name
order by count(transaction_ID) DESC;

-- See gross sales by game FINAL EXAMPLE
select g.game_ID, g.game_name, round(count(s.game_id) * g.price) as total_sales, overall_rating, ge.genre_name
from sales s
left join game g
on s.game_id = g.game_id 
left join genre ge
on ge.genre_id = g.genre_id
group by g.game_ID, g.game_name, g.price, overall_rating, genre_name
order by overall_rating DESC;

-- Group by and Having - most sales by game **
select s.game_ID, count(s.transaction_ID) as total
from sales as s
group by s.game_ID
having count(s.transaction_ID); -- change to greater than a certain amount so it only shows high sales instead of all

-- SS Group by and Having - counting number of games sold in each region. 
SELECT s.Region_sold, COUNT(s.Game_ID) AS total
FROM Sales AS s
GROUP BY s.Region_sold
HAVING COUNT(s.Game_ID) > 1;

-- Group by and Having FINAL EXAMPLE
SELECT s.Region_sold, count(g.genre_id) AS Genre, ge.genre_name
FROM Sales AS s
left join game g
on s.game_ID = g.game_id
left join genre ge
on g.genre_ID = ge.genre_ID
GROUP BY s.Region_sold, genre_name
HAVING Genre > 3
order by region_sold;

Select count(s.transaction_id) AS NoSold, game_name, price, Overall_rating 
from game g
left join sales s
on g.game_id = s.game_id
group by game_name, price, overall_rating
order by overall_rating DESC;

-- HC Stored Procedure
SELECT * FROM sales;

DELIMITER //
CREATE PROCEDURE NewTransaction (IN Transaction_ID VARCHAR(20), IN Game_ID VARCHAR(20), Category_ID VARCHAR(20), Platform_ID VARCHAR(20), Region_sold VARCHAR(20))
BEGIN
INSERT INTO sales(Transaction_ID, Game_ID, Category_ID, Platform_ID, Region_sold)
VALUES (Transaction_ID, Game_ID, Category_ID, Platform_ID, Region_sold);
END //
DELIMITER ;

-- calling the stored procedure to add a new transaction
CALL NewTransaction ('TR111', 'GA1', 'TY1', 'PL7', 'RE5');

-- Procedure test
SELECT * FROM sales;


-- DF Event FINAL EXAMPLE
SET GLOBAL event_scheduler = ON;
USE cfggaming;
CREATE TABLE monitoring_events
(ID INT AUTO_INCREMENT, Game_ID varchar(20), Game_name varchar(50), Price decimal(4,2),
Last_Update TIMESTAMP,
PRIMARY KEY (ID));

DELIMITER //
CREATE EVENT check_update
ON SCHEDULE EVERY 5 second
STARTS NOW()
DO BEGIN
INSERT INTO monitoring_events(Game_ID, Game_name, Price, Last_Update)
        SELECT Game_ID, Game_name, Price, CURRENT_TIMESTAMP from game;
END//
DELIMITER ;

-- Event check
select * from monitoring_events;

-- Event end
SET GLOBAL event_scheduler = OFF;

-- View FINAL EXAMPLE
CREATE OR REPLACE VIEW Final_game AS
SELECT g.overall_rating, s.transaction_ID, g.game_name, p.platform_name, r.region_name
FROM sales s
INNER JOIN game g ON g.game_ID = s.game_ID
INNER JOIN platform p ON p.platform_ID = s.platform_ID
INNER JOIN region r ON r.region_ID = s.Region_sold
ORDER BY g.overall_rating DESC;

SELECT * FROM final_game;

Select overall_rating, game_name, region_name
from final_game
Where game_name LIKE 'R%';

Select overall_rating, game_name, region_name
from final_game
Where overall_rating > 3 ;

Select * from sales;
select * from game;
Select * from ratings;
