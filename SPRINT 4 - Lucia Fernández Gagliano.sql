-----------------------------------------------------------------------------------------
# SPRINT 4
-- Lucía Fernández Gagliano
-----------------------------------------------------------------------------------------
# NIVELL 1
-----------------------------------------------------------------------------------------
# PARA PODER REALIZAR LOS EJERCICIOS DEL NIVEL 1:
-- > PRIMERO CREAMOS LA BASE  DE DATOS, LAS TABLAS DE 'DIMENSIONES' Y CARGAMOS SUS DATOS
-- > RECIÉN AHÍ ES CONVENIENTE CREAR LA TABLA DE HECHOS TRANSACCIONS Y CARGARLE SUS DATOS
-----------------------------------------------------------------------------------------

------------------------------
-- CREAMOS BASE DE DATOS
------------------------------
CREATE database transtrans;
USE transtrans;

---------------------------------------
-- CREAMOS LAS TABLAS DE 'DIMENSIONES'
---------------------------------------
DROP TABLE IF exists users;
CREATE TABLE IF NOT EXISTS users (
id	INT NOT NULL PRIMARY KEY,
name VARCHAR (50),
surname	VARCHAR (100),
phone VARCHAR (50), 
email VARCHAR (100),	
birth_date	VARCHAR (30),
country	VARCHAR (100),
city VARCHAR (100),	
postal_code	VARCHAR (20),
address VARCHAR (100)
);


DROP TABLE IF exists companies;
CREATE TABLE IF NOT EXISTS companies (
company_id	VARCHAR(10) PRIMARY KEY,
company_name VARCHAR (100),
phone VARCHAR (30),
email VARCHAR (100),
country	VARCHAR (100),
website VARCHAR (100)
);

DROP TABLE IF exists credit_cards;
CREATE TABLE IF NOT EXISTS credit_cards (
id	VARCHAR (10) PRIMARY KEY,
user_id	VARCHAR (10),
iban VARCHAR (50),
pan	VARCHAR (50),
pin	VARCHAR(4),
cvv	VARCHAR(3),
track1 VARCHAR (100),
track2	VARCHAR (100),
expiring_date VARCHAR (20)
);

-------------------------------------------------------------------------
-- > DESPUÉS INTENTAMOS CARGAR LA DATA DESDE LOS ARCHIVOS CSV, PERO... hay que modificar la configuración...
-------------------------------------------------------------------------

SHOW VARIABLES LIKE 'secure_file_priv'; -- > para ver dónde se alojan los archivos que se cargan
-- > 'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\'
-- > subo las tablas de datos a utilizar a la carpeta Uploads

#EJECUTO:
SET GLOBAL local_infile=on;
SHOW GLOBAL VARIABLES LIKE 'local_infile'; #ON

# INTEGRO LA SIGUIENTE ORDEN EN EL Manage Conections - Advanced . Test Conection:
# OPT_LOCAL_INFILE=1

# ME SIGUE DANDO ERROR
# Error Code: 2068. LOAD DATA LOCAL INFILE file request rejected due to restrictions on access.
--------------------------------------------------------------- 
### ¡¡¡ PRUEBO QUITANDO EL 'LOCAL' Y AHORA SÍ ME CARGA LOS DATOS !!! (emoción)
---------------------------------------------------------------
-- > CARGAMOS DATOS DE LA TABLA USERS

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'  # agregamos \r porque birthday tiene una coma que divide la celda
IGNORE 1 ROWS;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'  # agregamos \r porque birthday tiene una coma que divide la celda
IGNORE 1 ROWS;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv"
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' # agregamos \r porque birthday tiene una coma que divide la celda
IGNORE 1 ROWS;

-- > CARGAMOS DATOS DE LA TABLA COMPANY

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv"
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

-- > CARGAMOS DATOS DE LA TABLA credit_cards

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv"
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- > AHORA SÍ CREAMOS LA TABLA DE HECHOS 'transactions'

DROP TABLE IF exists transactions;
CREATE TABLE IF NOT EXISTS transactions (
        id VARCHAR(255) PRIMARY KEY,
        card_id VARCHAR(15), #es varchar(10)
        business_id VARCHAR(10), # ok
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined boolean,
        product_ids varchar (200),
		user_id INT, #ok
        lat FLOAT,
        longitude FLOAT,
FOREIGN KEY (card_id) REFERENCES credit_cards(id),
FOREIGN KEY (business_id) REFERENCES companies(company_id),
FOREIGN KEY (user_id) REFERENCES users(id)
);
    
-- > CARGAMOS DATOS DE LA TABLA transactions

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ';' # esta tabla está separada por ;
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-----------------------------------------------------------------------------------------
-- > AHORA SÍ, CON LOS DATOS CARGADOS, PASAMOS A LOS EJERCICIOS
-----------------------------------------------------------------------------------------
# NIVELL 1 - EXERCICI 1
-----------------------------------------------------------------------------------------
-- > Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.
-----------------------------------------------------------------------------------------
SELECT id 
FROM users
WHERE id IN (
			SELECT user_id
            FROM (
					SELECT user_id, COUNT(id) cantidad_transacciones_por_usuarios
					FROM transactions
					GROUP BY user_id) trans_por_usuarios
			WHERE cantidad_transacciones_por_usuarios > 30);
            
-----------------------------------------------------------------------------------------
# NIVELL 1 - EXERCICI 2
-----------------------------------------------------------------------------------------
-- > Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.			
-----------------------------------------------------------------------------------------
SELECT companies.company_name NOM_EMPRESA, credit_cards.iban, ROUND(AVG(transactions.amount),2)
FROM companies
JOIN transactions
	ON companies.company_id=transactions.business_id
JOIN credit_cards
	ON credit_cards.id=transactions.card_id
WHERE company_name = 'Donec Ltd'
GROUP BY 2,1
;

-----------------------------------------------------------------------------------------
# NIVELL 2 - EXERCICI 1
-----------------------------------------------------------------------------------------
-- > Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades 
--   i genera la següent consulta:
-- > Quantes targetes estan actives?
-----------------------------------------------------------------------------------------

-- > Primero buscamos el modo de seleccionar las última tres transcacciones por usuario de acuerdo al timestamp

SELECT id, card_id, timestamp, declined
FROM (
    SELECT id, card_id, timestamp, declined,
        ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS ultimas3
    FROM transactions
) AS ultimas_3
WHERE ultimas3 <= 3
ORDER BY card_id
# and declined = '1'
;

-- > Aquí podemos generar una columna mediante el IF que me distinga a cada tarjeta como Activa o No Activa si las últimas 3 transacciones fueron declinadas

SELECT card_id Card_id, 
IF(sum(declined) >=3, 'Not Active', 'Active') as 'Estado_Tarjeta',
sum(declined) Recent_declines
FROM (
    SELECT id, card_id, timestamp, declined,
        ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS ultimas3
    FROM transactions
) AS ultimas_3
WHERE ultimas3 <= 3
GROUP BY card_id
ORDER BY Estado_Tarjeta DESC
;

-- > Aquí le quito la suma de declinaciones para dejar solamente el estado de la tarjeta

SELECT card_id Card_id,
IF(sum(declined) >=1, 'Not Active', 'Active') as 'Status'
FROM (
    SELECT id, card_id, timestamp, declined,
        ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS ultimas3
    FROM transactions
) AS ultimas_3
WHERE ultimas3 <= 3
GROUP BY card_id
ORDER BY card_id DESC
;
--------------------------------------------------------------------------
-- > CREAMOS LA TABLA card_status
--------------------------------------------------------------------------
DROP TABLE IF EXISTS card_status;

CREATE TABLE card_status
SELECT card_id Card_id, 
IF(sum(declined) >=3, 'Not Active', 'Active') as 'Estado_Tarjeta',
sum(declined) Recent_declines
FROM (
    SELECT id, card_id, timestamp, declined,
        ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS ultimas3
    FROM transactions
) AS ultimas_3
WHERE ultimas3 <= 3
GROUP BY card_id
ORDER BY Estado_Tarjeta DESC
;

SELECT * from card_status;

-- > AGREGAMOS LA PRIMERY KEY A LA NUEVA TABLA Y LA FK QUE LA CONECTE A LA TABLA credit_cards

ALTER TABLE card_status ADD PRIMARY KEY(card_id);

ALTER TABLE credit_cards
ADD FOREIGN KEY (id) REFERENCES card_status(card_id);

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- > A PARTIR DE AHORA, NUESTRO MODELO SE CONVIERTE EN UN MODELO 'COPO DE NIEVE' < --
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- > VEMOS CUÁNTAS DE LAS TARJETAS ESTÁN ACTIVAS 
---------------------------------------------------------------------------------------
SELECT count(card_id) Total_active_cards
FROM card_status
where Estado_Tarjeta ='Active'
GROUP BY Estado_Tarjeta
; 
#275 Total_active_cards, es decir no hay ninguna de las tarjetas que haya sido declinada 3 veces en las últimas 3 transacciones

-- > esta Opción me permitiría ver las tarjetas que tuvieron al menos un decline en las últimas 3 transacciones
--  y ver cuántas veces fueron declinadas
SELECT * from card_status
where Recent_declines >= 1;

-- > CORROBORACIONES

#es correcta la relación entre la tabla credit_cards y card_status
select credit_cards.id, card_status.Card_id
from credit_cards left join card_status
on credit_cards.id=card_status.Card_id; # resultado 275 rows, correcto

-- > PRUEBO UN JOIN CON LA TABLA TRANSACCIONES (armo búsqueda para que me muestra si hubiera alguna 'Not Active'
select transactions.declined, transactions.card_id transcard, card_status.Estado_Tarjeta, timestamp
from transactions join credit_cards
on transactions.card_id=credit_cards.id
join card_status
on credit_cards.id=card_status.Card_id
where Estado_Tarjeta = 'Not Active'
order by transcard, timestamp desc; 




-----------------------------------------------------------------------------------------
# NIVELL 3 - EXERCICI 1
-----------------------------------------------------------------------------------------
-- > Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que 
--   des de transaction tens product_ids. Genera la següent consulta:
-- > Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

-- CREAMOS LA TABLA products
DROP TABLE IF EXISTS products;
CREATE TABLE IF NOT EXISTS products (
id INT PRIMARY KEY NOT NULL,
product_name VARCHAR(200),
price VARCHAR (200),
colour VARCHAR(20),
weight DECIMAL (10,2),
warehouse_id VARCHAR(100)
);

-- CARGAMOS DATOS 
# Me genera conflicto con el símbolo $ en la columna Price
-- > borro el signo $ de la columna price en el .csv para poder cargarlos 
-- > (mmm, dudo si es lo correcto! porque después si siguen cargando productos con el mismo símbolo no me cargará los datos cuando se actualicen las tablas)

#LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv"
#INTO TABLE products
#FIELDS TERMINATED BY ','
#ENCLOSED BY '"'
#LINES TERMINATED BY '\n' 
#IGNORE 1 ROWS; 

-- CON REEMPLAZO DEL $ EN PRICE
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv"
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS
(id, product_name, @price_raw, colour, weight,	warehouse_id)
SET price = REPLACE(@price_raw, '$', ''); #QUITAMOS EL $ DE PRICE


-- CAMBIAMOS EL CAMPO 'PRICE' DE VARCHAR A DECIMAL 
ALTER TABLE products MODIFY price DECIMAL (10,2);

-- CORROBORAMOS LA CARGA DE DATOS, OK ;)
SELECT * from products;

------------------------------
-- PROBLEMA
-- la columna 'produc_ids' de la tabla transactions, al tener varios product ids en cada registro no me matchea con los id de la tabla products
------------------------------

SELECT transactions.id, transactions.card_id, transactions.product_ids, products.id 
FROM  transactions left join products
on transactions.product_ids=products.id
;

# acá me selecciona solo los que reconoce de una cifra

SELECT transactions.id, transactions.card_id, transactions.product_ids, products.id
FROM  transactions left join products
on transactions.product_ids=products.id
where transactions.card_id ='CcU-2945' OR transactions.card_id ='CcU-2938'
AND transactions.product_ids IN (select id from products);
;

-- CREAMOS UNA TABLA INTERMEDIA PARA EVITAR LA RELACIÓN MUCHOS A MUCHOS ENTRE LA TABLA PRODUCTS Y LA TABLA TRANSACTIONS
# aquí logro que me distinga cada product id 

DROP TABLE IF EXISTS products_transactions;
CREATE TABLE IF NOT EXISTS products_transactions
SELECT DISTINCT
    transactions.id AS transaction_id,
    product_id
FROM 
    transactions
JOIN 
    JSON_TABLE(
        CONCAT('["', REPLACE(transactions.product_ids, ',', '","'), '"]'),
        '$[*]' COLUMNS (product_id INT PATH '$')
    ) jt
    ON jt.product_id = product_id
LEFT JOIN 
    products 
    ON jt.product_id = product_id
ORDER BY 
    transactions.id;

SELECT * FROM products_transactions;

-------------------------------------------------------------------
-- > GENERAMOS LA PRIMARY KEY COMPUESTA DE NUESTRA TABLA INTERMEDIA products_transactions
-------------------------------------------------------------------
ALTER TABLE products_transactions
ADD PRIMARY KEY (transaction_id, product_id)
;
-------------------------------------------------------------------
-- > GENERAMOS LAS FOREING KEYS EN LAS TABLA products_transactions CON LAS TABLAS transactions y products

# LA FK CON transactions ME FUNCIONA 
ALTER TABLE products_transactions
ADD CONSTRAINT fk_transactions_id
FOREIGN KEY (transaction_id)
REFERENCES transactions(id)
;
ALTER TABLE products_transactions
ADD CONSTRAINT fk_product_id
FOREIGN KEY (product_id)
REFERENCES products(id)
;


------------------------------------------------------------------------
-- > Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
------------------------------------------------------------------------
SELECT product_id, COUNT(transaction_id)cantidad_vendida
FROM products_transactions
GROUP BY product_id
ORDER BY product_id;

-- > EXTRA: así podemos corroborar la cantidad de ventas de todos los productos presentes en la tabla 'products'
--   viendo también cuál no ha tenido ninguna venta hasta ahora

SELECT products.id, cantidad_vendida from products
left join (
		SELECT product_id, COUNT(transaction_id)cantidad_vendida
		FROM products_transactions
		GROUP BY product_id
		ORDER BY product_id) cantidades
	ON products.id=cantidades.product_id;




