CREATE DATABASE logistics CHARACTER SET utf8mb4;
USE logistics;

CREATE TABLE orderlist (
Order_ID INT NOT NULL PRIMARY KEY,
Order_Date VARCHAR(7),
Orig_Port VARCHAR(6),
Carrier VARCHAR(20),
TPT_Day_Count INT,
Service_Level VARCHAR(3),
Ship_Ahead_Day_Count INT,
Ship_Late_Day_Count INT,
Customer VARCHAR(22),
Product_ID INT,
Plant_Code VARCHAR(7),
Dest_Port VARCHAR(7),
Unit_Quant INT,
Weight FLOAT);

CREATE TABLE FreightRates (
Carrier	 VARCHAR(20),
Orig_Port VARCHAR(6),
Dest_Port VARCHAR(7),	
Min_Weight_Quant FLOAT,
Max_Weight_Quant FLOAT,
Service_Level VARCHAR(3),
Min_Cost FLOAT,
Rate FLOAT,
Mode_DSC VARCHAR(6),
TPT_Day_Count INT,
Carrier_Type VARCHAR(12));

CREATE TABLE PlantPorts(
Plant_Code VARCHAR (7) NOT NULL,
Ports VARCHAR(6) NOT NULL,
PRIMARY KEY(Plant_Code, Ports));

CREATE TABLE ProductsPerPlant(
Plant_Code VARCHAR (7) NOT NULL,
Product_ID INT NOT NULL,
 PRIMARY KEY(Plant_Code, Product_ID));

CREATE TABLE WhCapacities(
Plant_Code VARCHAR (7) NOT NULL PRIMARY KEY,
Daily_Capacity INT NOT NULL);

CREATE TABLE WhCosts(
Plant_Code VARCHAR (7) NOT NULL PRIMARY KEY,
Cost_Per_Unit FLOAT NOT NULL);

CREATE TABLE VmiCustomers(
Plant_Code VARCHAR (7),
Customer VARCHAR(23),
PRIMARY KEY(Plant_Code,Customer));

SET GLOBAL local_infile = 1;

TRUNCATE TABLE orderlist;

LOAD DATA LOCAL INFILE 'C:/Users/rusla/OneDrive/Escritorio/Coursera. analisis de datos/PRACTICA/Nueva carpeta/OrderList.csv'
INTO TABLE orderlist 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(Order_ID, Order_Date, Orig_Port, Carrier, TPT_Day_Count, Service_Level, Ship_Ahead_Day_Count, Ship_Late_Day_Count, Customer, Product_ID, Plant_Code, Dest_Port, Unit_Quant, Weight);

TRUNCATE TABLE FreightRates;
LOAD DATA LOCAL INFILE 'C:/Users/rusla/OneDrive/Escritorio/Coursera. analisis de datos/PRACTICA/Nueva carpeta/FreightRates.csv'
INTO TABLE FreightRates 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(Carrier, Orig_Port, Dest_Port,	Min_Weight_Quant, Max_Weight_Quant, Service_Level, Min_Cost, Rate, Mode_DSC, TPT_Day_Count, Carrier_Type);

TRUNCATE TABLE PlantPorts;

LOAD DATA LOCAL INFILE 'C:/Users/rusla/OneDrive/Escritorio/Coursera. analisis de datos/PRACTICA/Nueva carpeta/PlantPorts.csv'
INTO TABLE PlantPorts
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(Plant_Code, Ports);

LOAD DATA LOCAL INFILE 'C:/Users/rusla/OneDrive/Escritorio/Coursera. analisis de datos/PRACTICA/Nueva carpeta/ProductsPerPlant.csv'
INTO TABLE ProductsPerPlant
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS 
(Plant_Code, Product_ID);


LOAD DATA LOCAL INFILE 'C:/Users/rusla/OneDrive/Escritorio/Coursera. analisis de datos/PRACTICA/Nueva carpeta/WhCapacities.csv'
INTO TABLE WhCapacities
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS 
(Plant_Code, Daily_Capacity);

LOAD DATA LOCAL INFILE 'C:/Users/rusla/OneDrive/Escritorio/Coursera. analisis de datos/PRACTICA/Nueva carpeta/WhCosts.csv'
INTO TABLE WhCosts
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS 
(Plant_Code, Cost_Per_Unit);

LOAD DATA LOCAL INFILE 'C:/Users/rusla/OneDrive/Escritorio/Coursera. analisis de datos/PRACTICA/Nueva carpeta/VmiCustomers.csv'
INTO TABLE VmiCustomers
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS 
(Plant_Code,Customer);


SELECT COUNT(*) FROM orderlist;
SELECT COUNT(*) AS total, COUNT(DISTINCT Order_ID) AS unique_ids FROM orderlist;


SELECT COUNT(*) FROM freightrates;
SELECT COUNT(*) AS total, COUNT(DISTINCT Carrier) AS unique_ids FROM freightrates;

SELECT * FROM freightrates WHERE Rate IS NULL OR Min_Weight_Quant IS NULL;

SELECT COUNT(*) FROM plantports;
SELECT COUNT(*) AS total, COUNT(DISTINCT plant_code) AS unique_ids FROM plantports;

SELECT COUNT(*) FROM ProductsPerPlant;
SELECT COUNT(*) AS total, COUNT(DISTINCT plant_code) AS unique_ids FROM ProductsPerPlant;

SELECT COUNT(*) FROM vmicustomers;
SELECT COUNT(*) AS total, COUNT(DISTINCT plant_code) AS unique_ids FROM vmicustomers;

SELECT COUNT(*) FROM whcapacities;
SELECT COUNT(*) AS total, COUNT(DISTINCT plant_code) AS unique_ids FROM whcapacities;

SELECT COUNT(*) FROM whcosts;
SELECT COUNT(*) AS total, COUNT(DISTINCT plant_code) AS unique_ids FROM whcosts;

# encontrar precio de entrega

SELECT 
o.order_id, o.carrier, o.orig_port, o.dest_port, o.Service_Level, o.weight, f.tpt_day_count, f.rate FROM  orderlist AS o
LEFT JOIN freightrates AS f 
ON  o.Carrier   = f.Carrier
	AND o.Orig_Port = f.Orig_Port
    AND o.Dest_Port = f.Dest_Port
    AND o.Service_Level = f.Service_Level
    AND o.tpt_day_count = f.tpt_day_count
    AND o.Weight BETWEEN f.Min_Weight_quant AND f.Max_Weight_quant;
    
    
SELECT o.Order_ID, o.Weight, f.Min_Weight_Quant, f.Max_Weight_Quant, f.Rate
FROM orderlist o
JOIN freightrates f
  ON o.Carrier = f.Carrier
  AND o.Orig_Port = f.Orig_Port
  AND o.Dest_Port = f.Dest_Port
  AND o.Service_Level = f.Service_Level
  AND o.Weight BETWEEN f.Min_Weight_Quant AND f.Max_Weight_Quant
WHERE o.Order_ID = 1447133214;
    
SELECT * FROM freightrates 
WHERE Carrier='V444_0' AND Orig_Port='PORT03' AND Dest_Port='PORT09' 
AND Min_Weight_Quant=0 AND Max_Weight_Quant=5000 AND Service_Level='DTD';

DROP TABLE ordenes_flete_resumen;

CREATE TABLE ordenes_flete_resumen AS 
SELECT o.order_id, 
o.carrier, 
o.orig_port,
 o.dest_port,
 o.Service_Level,
 o.weight, 
 f.tpt_day_count,
 f.min_cost,
 f.rate
 FROM  orderlist AS o
LEFT JOIN freightrates AS f 
ON  o.Carrier   = f.Carrier
	AND o.Orig_Port = f.Orig_Port
    AND o.Dest_Port = f.Dest_Port
    AND o.Service_Level = f.Service_Level
    AND o.tpt_day_count = f.tpt_day_count
    AND o.Weight BETWEEN f.Min_Weight_quant AND f.Max_Weight_quant;
    
SELECT COUNT(*) AS total_orders,
       SUM(CASE WHEN Rate IS NULL THEN 1 ELSE 0 END) AS orders_without_rate,
       SUM(CASE WHEN Rate IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100 AS pct_without_rate
FROM ordenes_flete_resumen;

SELECT order_id, COUNT(*) 
FROM ordenes_flete_resumen 
GROUP BY order_id 
HAVING COUNT(*) > 1
LIMIT 10;

SELECT * FROM ordenes_flete_resumen;

SELECT order_id, COUNT(*) FROM ordenes_flete_resumen
GROUP BY order_id;

SELECT order_id, COUNT(rate) AS num_rate FROM ordenes_flete_resumen
GROUP BY order_id 
ORDER BY num_rate;

SELECT order_id,
 COUNT(rate) AS num_rate, 
 CASE
	WHEN COUNT(rate) = 0 THEN 'no rate'
    WHEN COUNT(rate) = 1 THEN 'ok'
	ELSE 'ambiguous'
END AS rate_status
FROM ordenes_flete_resumen
GROUP BY order_id
ORDER BY rate_status;

SELECT rate_status, COUNT(*) AS orders_count
FROM (
  SELECT order_id, 
    CASE 
        WHEN COUNT(rate) = 0 THEN 'no rate'
        WHEN COUNT(rate) = 1 THEN 'ok'
        ELSE 'ambiguous'
    END AS rate_status
  FROM ordenes_flete_resumen
  GROUP BY order_id
) sub
GROUP BY rate_status;


SELECT r.carrier, COUNT(*) 
FROM ordenes_flete_resumen r
JOIN (
  SELECT order_id, COUNT(rate) AS num_rate
  FROM ordenes_flete_resumen
  GROUP BY order_id
  HAVING COUNT(rate) = 0
) no_rate ON r.order_id = no_rate.order_id
GROUP BY r.carrier;


SELECT * FROM ordenes_flete_resumen 
WHERE carrier = 'V444_1' AND rate IS NULL 
LIMIT 5;

SELECT * FROM ordenes_flete_resumen
WHERE Order_ID = 1447133215;

SELECT order_id, MAX(weight) AS max_weight FROM ordenes_flete_resumen
GROUP BY order_id
ORDER BY max_weight DESC
LIMIT 1;

SELECT * FROM ordenes_flete_resumen WHERE order_id = 1447281733;

ALTER TABLE ordenes_flete_resumen 
DROP COLUMN shipping_cost;

ALTER TABLE ordenes_flete_resumen 
ADD COLUMN shipping_cost FLOAT GENERATED ALWAYS AS (GREATEST(weight * rate, min_cost)) STORED;


SELECT * FROM ordenes_flete_resumen WHERE order_id = 1447281733;

SELECT order_id, rate, min_cost, shipping_cost 
FROM ordenes_flete_resumen 
WHERE rate IS NULL 
LIMIT 3;

SELECT MIN(shipping_cost), MAX(shipping_cost), AVG(shipping_cost), COUNT(*) 
FROM ordenes_flete_resumen 
WHERE shipping_cost IS NOT NULL;

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE ordenes_flete_resumen ADD COLUMN rate_status VARCHAR(15);
UPDATE ordenes_flete_resumen 
JOIN (
	SELECT order_id,
		CASE
			WHEN COUNT(rate) = 0 THEN 'no rate'
			WHEN COUNT(rate) = 1 THEN 'ok'
			ELSE 'ambiguous'
		END AS rate_status
	FROM ordenes_flete_resumen
	GROUP BY order_id
	) AS sub ON ordenes_flete_resumen.order_id = sub.order_id
SET ordenes_flete_resumen.rate_status = sub.rate_status;




CREATE TABLE orders_flete_complet AS 
SELECT o.order_id, 
       o.carrier, 
       o.orig_port,
       o.dest_port,
       o.Service_Level,
       o.weight,
       o.plant_code,
       o.product_id,
       o.order_date,
       f.tpt_day_count,
       f.min_cost,
       f.rate
FROM orderlist AS o
LEFT JOIN freightrates AS f 
    ON o.Carrier = f.Carrier
    AND o.Orig_Port = f.Orig_Port
    AND o.Dest_Port = f.Dest_Port
    AND o.Service_Level = f.Service_Level
    AND o.tpt_day_count = f.tpt_day_count
    AND o.Weight BETWEEN f.Min_Weight_quant AND f.Max_Weight_quant
WHERE o.order_id IN (
    SELECT order_id
    FROM (
        SELECT order_id,
               CASE 
                   WHEN COUNT(rate) = 0 THEN 'no rate'
                   WHEN COUNT(rate) = 1 THEN 'ok'
                   ELSE 'ambiguous'
               END AS rate_status
        FROM ordenes_flete_resumen
        GROUP BY order_id
    ) AS sub
    WHERE rate_status = 'ok'
);

SELECT COUNT(*) FROM orders_flete_complet;

SELECT MAX(weight*rate) AS max_cal, MAX(min_cost) AS max_min_cost
FROM orders_flete_complet;

ALTER TABLE orders_flete_complet
ADD COLUMN shipping_cost DECIMAL(10,2) GENERATED ALWAYS AS (GREATEST(weight * rate, min_cost)) STORED;

SELECT MIN(shipping_cost), MAX(shipping_cost), AVG(shipping_cost), COUNT(*) FROM  orders_flete_complet;

SELECT
	carrier,
    COUNT(*) AS cantidad_orders, 
	SUM(shipping_cost) AS suma_orders,
	AVG(shipping_cost) AS avg_orders
FROM orders_flete_complet
GROUP BY carrier
ORDER BY cantidad_orders;

SELECT rate_status, carrier, COUNT(*)
FROM (
    SELECT order_id, carrier,
           CASE 
               WHEN COUNT(rate) = 0 THEN 'no rate'
               WHEN COUNT(rate) = 1 THEN 'ok'
               ELSE 'ambiguous'
           END AS rate_status
    FROM ordenes_flete_resumen
    GROUP BY order_id, carrier
) sub
GROUP BY rate_status, carrier
ORDER BY carrier, rate_status;

SELECT
	orig_port, dest_port,
    COUNT(*) AS cantidad_orders, 
	SUM(shipping_cost) AS suma_orders,
	AVG(shipping_cost) AS avg_orders
FROM orders_flete_complet
GROUP BY orig_port, dest_port
ORDER BY cantidad_orders;

SELECT MIN(shipping_cost), MAX(shipping_cost),AVG(shipping_cost), COUNT(*)
FROM orders_flete_complet
WHERE orig_port = 'PORT09' AND dest_port = 'PORT09';

SELECT shipping_cost 
FROM orders_flete_complet
WHERE orig_port='PORT09' AND dest_port='PORT09'
ORDER BY shipping_cost DESC
LIMIT 34;

SELECT order_id, order_date, plant_code, product_id, weight, min_cost, shipping_cost
FROM orders_flete_complet
WHERE orig_port='PORT09' AND dest_port='PORT09'
ORDER BY shipping_cost DESC
LIMIT 4;

SELECT product_id, COUNT(*), MIN(weight), MAX(weight), AVG(weight)
FROM orders_flete_complet
WHERE product_id IN (1686435, 1696533) AND orig_port='PORT09' AND dest_port='PORT09'
GROUP BY product_id;

SELECT MIN(shipping_cost), MAX(shipping_cost),AVG(shipping_cost), COUNT(*)
FROM orders_flete_complet
WHERE orig_port = 'PORT04' AND dest_port = 'PORT09';

SELECT shipping_cost
FROM orders_flete_complet
WHERE orig_port='PORT04' AND dest_port='PORT09'
ORDER BY shipping_cost
LIMIT 1 OFFSET 3114;

SELECT shipping_cost, COUNT(*) 
FROM orders_flete_complet
WHERE orig_port='PORT04' AND dest_port='PORT09'
GROUP BY shipping_cost
ORDER BY COUNT(*) DESC
LIMIT 10;

SELECT order_id, order_date, plant_code, product_id, weight, min_cost, shipping_cost
FROM orders_flete_complet
WHERE orig_port='PORT04' AND dest_port='PORT09'
ORDER BY shipping_cost DESC
LIMIT 10;

SELECT product_id, plant_code, COUNT(*)
FROM orders_flete_complet
WHERE orig_port='PORT04' AND dest_port='PORT09' AND plant_code = 'PLANT03' AND shipping_cost = 1.50
GROUP BY product_id, plant_code
ORDER BY COUNT(*) DESC;

SELECT  plant_code, COUNT(*)
FROM orders_flete_complet
WHERE orig_port='PORT04' AND dest_port='PORT09' 
GROUP BY  plant_code
ORDER BY COUNT(*) DESC;


SELECT o.plant_code, SUM(o.unit_quant) AS sum_unit, w.Daily_Capacity 
FROM orderlist AS o
LEFT JOIN whcapacities AS w
ON o.plant_code = w.plant_code
GROUP BY o.plant_code
ORDER BY sum_unit;

SELECT * FROM whcapacities ORDER BY Daily_Capacity;

SELECT MIN(Unit_Quant), MAX(Unit_Quant), AVG(Unit_Quant) FROM orderlist;