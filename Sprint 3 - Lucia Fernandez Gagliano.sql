-- SPRINT 3 LUCÍA FERNÁNDEZ GAGLIANO

----------------------------------------------------------------------------------------------------
-- NIVELL 1 - EXERCICI 1
----------------------------------------------------------------------------------------------------
-- > Dissenyar i crear una taula anomenada "credit_card 
-- > La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació  
--   adequada amb les altres dues taules ("transaction" i "company"). 
-- > Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit".
-- > Recorda mostrar el diagrama i realitzar una breu descripció d'aquest.
----------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS credit_card;

CREATE TABLE IF NOT EXISTS credit_card (
id VARCHAR(15), 
iban VARCHAR (40) NOT NULL, 
pan varchar (60) NOT NULL, 
pin INT NOT NULL, 
cvv INT NOT NULL, 
expiring_date VARCHAR (8),
PRIMARY KEY (id)
);

-- > se cargan los datos de credit_card 
-- > corroboramos:
SELECT * FROM credit_card;

-- > se establece la Foreing Key para relacionar la tabla credit_card con la tabla transaction

ALTER TABLE transaction
ADD CONSTRAINT fk_credit_card_id
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id);

----------------------------------------------------------------------------------------------------
-- NIVELL 1 - Exercici 2
----------------------------------------------------------------------------------------------------
-- > El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938. 
--   La informació que ha de mostrar-se per a aquest registre és: R323456312213576817699999. Recorda mostrar que el canvi es va realitzar.
----------------------------------------------------------------------------------------------------

UPDATE credit_card
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938';

SELECT id, iban 
FROM credit_card
WHERE id = 'CcU-2938'; #corroboración OK
----------------------------------------------------------------------------------------------------
-- NIVELL 1 - Exercici 3
----------------------------------------------------------------------------------------------------
-- > En la taula "transaction" ingressa un nou usuari amb la següent informació:
# Id	108B1D1D-5B23-A76C-55EF-C568E49A99DD
# credit_card_id	CcU-9999
# company_id	b-9999
# user_id	9999
# lat	829.999
# longitude	-117.999
# amount	111.11
# declined	0
----------------------------------------------------------------------------------------------------

-- Para poder Cargar los nuevos datos en la tabla transaction, primero debemos cargar los datos en las otra tablas de 'dimensiones'

-- > CREAMOS UNA CREDIT CARD ID= 'CcU-9999'
INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date) 
VALUES ('CcU-9999', 'TR301950312213576817638699', '5424465566813699', '3999', '999', '10-30-25');

-- > CREAMOS UNA COMPANY 'b-9999':
INSERT INTO company (id, company_name, phone, email, country, website) 
VALUES ('b-9999', 'wili wili', '06 85 56 99 99', 'wiliwili@yahoo.net', 'Germany', 'https://wilis.com/site');

-- > AHORA SÍ CARGAMOS LOS DATOS CORRECTAMENTE:
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined) 
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', '111.11', '0');

SELECT * FROM transaction
WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';


----------------------------------------------------------
-- NIVELL 1 - Exercici 4
----------------------------------------------------------------------------------------------------
-- > Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_*card. Recorda mostrar el canvi realitzat.
----------------------------------------------------------------------------------------------------

ALTER TABLE credit_card DROP COLUMN pan;


----------------------------------------------------------------------------------------------------
-- NIVELL 2 - EXERCICI 1
----------------------------------------------------------------------------------------------------
-- > Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.
----------------------------------------------------------------------------------------------------

DELETE FROM transaction 
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

----------------------------------------------------------------------------------------------------
-- NIVELL 2 -  EXERCICI 2
----------------------------------------------------------------------------------------------------
-- > La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
-- S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. 
-- Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: 
-- Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. 
-- Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.
----------------------------------------------------------------------------------------------------

CREATE VIEW VistaMarketing AS
SELECT company.company_name EMPRESA, company.phone TEL, company.country PAIS, Round(AVG(transaction.amount), 2) MEDIA_DE_VENTAS
FROM company JOIN transaction
	ON company.id=transaction.company_id
    WHERE declined= 0
GROUP BY EMPRESA, TEL, PAIS
ORDER BY MEDIA_DE_VENTAS DESC;

SELECT * from vistamarketing;

----------------------------------------------------------------------------------------------------
-- EXERCICI 3
----------------------------------------------------------------------------------------------------
-- Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"

SELECT * from VistaMarketing
where PAIS = 'Germany';



----------------------------------------------------------------------------------------------------
-- NIVELL 3 - EXERCICI 1
----------------------------------------------------------------------------------------------------
-- La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar modificacions en la base de dades, 
-- però no recorda com les va realitzar. 
-- Et demana que l'ajudis a deixar els comandos executats per a obtenir el següent diagrama:
----------------------------------------------------------------------------------------------------

-- 1) PRIMERO DEBEMOS CARGAR LA BASE DE DATOS User

-- > se ejecuta el archivo de estructura de datos User, y corre el código que establece el índice pero no la creación de la tabla

CREATE INDEX idx_user_id ON transaction(user_id); # OK

-- > Error Code: 6125. Failed to add the foreign key constraint. Missing unique key for constraint 'user_ibfk_1' in the referenced table 'transaction'

-- > quitamos el establecimiento de la Foreing Key en esta instancia para poder generar la tabla y luego establecer la FK desde ALTER TABLE transaction.

CREATE TABLE IF NOT EXISTS user (
        id INT PRIMARY KEY,
        name VARCHAR(100),
        surname VARCHAR(100),
        phone VARCHAR(150),
        email VARCHAR(150),
        birth_date VARCHAR(100),
        country VARCHAR(150),
        city VARCHAR(150),
        postal_code VARCHAR(100),
        address VARCHAR(255)          
    ); # borré la FK y REFERENCE a la tabla Transaction pero está todo friamente calculado ;)

# OK carga la estructura de la tabla al quitar la referencia de la Foreing Key

-- >  CARGAMOS LOS DATOS DE LA TABLA USER -> OK, SIN PROBLEMAS

-- > Ahora sí, volvemos a intentar establecer la Foreing Key para conectar la tabla User a la tabla Transaction

# ALTER TABLE transaction
# ADD CONSTRAINT fk_user_id
# FOREIGN KEY (user_id)
# REFERENCES user(id); 

# PERO NO CORRE :(
# Error Code: 1452. Cannot add or update a child row: a foreign key constraint fails (`transactions`.`#sql-1804_2c`, CONSTRAINT `fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`))

-- > Buscamos las posibles diferencias entre las tablas con un LEFT JOIN

SELECT transaction.user_id, user.id
FROM transaction LEFT JOIN user
ON transaction.user_id=user.id;

-- > encontramos que hay un user_id '9999' que antes habíamos creado que no está en la tabla Transaction, así que pasamos a añadirlo en la tabla User
--   para despejar el error de la FK

INSERT INTO user (id, name, surname, phone, email, birth_date, country, city, postal_code, address) 
VALUES ("9999", "wili", "Wilis", "1-282-581-0551", "wiliwili@protonmail.edu", "Nov 17, 1985", "United States", "Lowell", "73544", "348-7818 Sagittis St.");

-- > ahora sí podemos generar la Foreing Key ;)

ALTER TABLE transaction
ADD CONSTRAINT fk_user_id
FOREIGN KEY (user_id)
REFERENCES user(id); 



-- 2) FINALMENTE PASAMOS A MIRAR EL DIAGRAMA QUE NOS DEJÓ EL COMPAÑERO

-- A. La tabla user debe pasar a llamarse 'data_user'. 

RENAME TABLE user TO data_user;

-- B. En la tabla Credit_Card hay que añadir una columna 'fecha_actual' en formato DATE

ALTER TABLE credit_card
ADD Fecha_Actual DATE;

-- C. En la tabla Company hay que borrar la columna 'email'

ALTER TABLE company
DROP column email;

----------------------------------------------------------------------------------------------------
-- NIVELL 3 - EXERCICI 2
----------------------------------------------------------------------------------------------------
-- L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:

# ID de la transacció
# Nom de l'usuari/ària
# Cognom de l'usuari/ària
# IBAN de la targeta de crèdit usada.
# Nom de la companyia de la transacció realitzada.

-- > Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari.
-- > Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction.
----------------------------------------------------------------------------------------------------

CREATE VIEW InformeTecnico AS
SELECT transaction.id ID_transaccion, data_user.name Nombre, data_user.surname Apellido, credit_card.iban IBAN, company.company_name EMPRESA
FROM transaction 
JOIN data_user
	ON transaction.user_id=data_user.id
JOIN credit_card
	ON transaction.credit_card_id=credit_card.id
JOIN company
	ON transaction.company_id=company.id
ORDER BY ID_transaccion desc;

-- > Vista creada:
SELECT * FROM InformeTecnico;
