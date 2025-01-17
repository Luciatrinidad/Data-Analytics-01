-- SPRINT 2 - Lucía Fernández Gagliano

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- NIVELL 1
---------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------
-- EXERCICI  1 
----------------------------------------
-- La Base de Datos 'Transactions' cuenta con dos tablas: Transaction y Company. 
-- Por estar en SQL se trata de una tabla relacional, pero si estuviéramos en Power BI podría funcionar como una base de datos Dimensional.

-- En la Tabla Transaction -que podría funcionar como una 'tabla de hechos'- tenemos los datos de cada transacción con su ID como Primary Key. 
-- Las variables que se computan son el ID de la tarjeta de crédito, el ID de la empresa, el ID del usuario, la latitud y la longitud -como locación-, 
-- el momento de la transación (timestamp), y el monto de la misma. 

-- En la Tabla Company -que podría funcionar como Tabla de Dimensiones- tenemos el ID de la empresa como Primary Key junto a otras variables de la empresa: 
-- El nombre, el teléfono, email, país y la website de la empresa.

-- La relación de ambas tablas es de 1 a N entre la ID de la tabla ‘Company’ y la variable Company_ID de la tabla ‘ Transaction’.


----------------------------------------
-- EXERCICI 2 (JOINS)
----------------------------------------
-----------------------------------------------------------------------------------------------
-- A > Llistat dels països que estan fent compres.
-----------------------------------------------------------------------------------------------

SELECT distinct country 
FROM company JOIN transaction 
	ON company.id=transaction.company_id
	WHERE declined = 0;

-----------------------------------------------------------------------------------------------
-- B > Des de quants països es realitzen les compres.
-----------------------------------------------------------------------------------------------

SELECT count(distinct country) 
FROM company 
JOIN transaction
	ON company.id=transaction.company_id
    WHERE declined = 0;

-----------------------------------------------------------------------------------------------
-- C > Identifica la companyia amb la mitjana més gran de vendes.
-----------------------------------------------------------------------------------------------

SELECT company_name, ROUND(avg(amount), 2) media_ventas 
FROM company JOIN transaction 
	ON company.id=transaction.company_id
	WHERE declined = 0
GROUP BY company_name
ORDER BY media_ventas DESC
LIMIT 1;


----------------------------------------
-- EXERCICI 3 (SUBCONSULTES)
----------------------------------------
-----------------------------------------------------------------------------------------------
-- A > Mostra totes les transaccions realitzades per empreses d'Alemanya.
-----------------------------------------------------------------------------------------------
-- RESPUESTA SUBCONSULTA
SELECT transaction.id as transacciones_alemanas 
FROM transaction 
	WHERE company_id in ( 
		SELECT id 
        FROM company 
        WHERE country = 'Germany');

-- > DOBLE-CHECK (con JOIN para corroborar)-> hay 118 transacciones con empresas de Alemania
SELECT transaction.id, company.country 
FROM transaction JOIN company 
	ON company.id=transaction.company_id
	WHERE country = 'Germany';

-----------------------------------------------------------------------------------------------
-- B > Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
-----------------------------------------------------------------------------------------------
-- (sin tener en cuenta si las transacciones han sido declinadas o no)

SELECT company_name 
FROM company
WHERE company.id IN (
	SELECT company_id 
    FROM transaction 
    WHERE amount > (
		SELECT  ROUND(avg(amount), 2) 
        FROM transaction));

-- (la Subconsulta)
SELECT ROUND(avg(amount), 2) from transaction;

-- CORROBORACIÓN
select distinct company_id from transaction
where amount > '256.74'
;
-----------------------------------------------------------------------------------------------
-- C > Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
-----------------------------------------------------------------------------------------------

SELECT distinct id from company; -- HAY 100 EMPRESAS EN TOTAL
SELECT distinct company_id from transaction; -- HAY 100 EMPRESAS EN TOTAL QUE HAN REALIZADO TRANSACCIONES REGISTRADAS

-- (ya sospechamos que no hay ninguna empresa en la tabla company que no haya realizado transacciones, pero seguimos probando) --

-- tiramos un Left Join desde la tabla 'company' para ver si encontramos algún NULL pero no aparecere ninguno...
SELECT * from company LEFT JOIN transaction on transaction.company_id=company.id;

-- tiro el código con SUNCONSULTA que me podría devolver las empresas que no tuvieran su transacción

SELECT company_name from company
where company.id NOT IN (SELECT company_id from transaction);

SELECT company_name from company
where id IN (SELECT company_id from transaction);

-- ahora sí, tenemos súper corroborado que no existe ninguna 'company' que no haya realizado ninguna transacción ;)



---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- NIVELL 2
---------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------
-- Exercici 1
----------------------------------------
-- > Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
-- > Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT date(timestamp) Dia, sum(amount) Amount_by_Day 
FROM transaction
	WHERE declined = 0
GROUP BY Dia
ORDER BY amount_by_day desc
LIMIT 5;


----------------------------------------
-- Exercici 2
----------------------------------------
-- >Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.

SELECT ROUND(AVG(amount), 2) media_ventas_pais, country 
FROM transaction JOIN company 
	ON transaction.company_id=company.id
WHERE declined = 0
GROUP BY country
ORDER BY media_ventas_pais desc;

----------------------------------------
-- Exercici 3
----------------------------------------
-- > En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". 
-- > Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.

-- Primero buscamos el país de la empresa 'Non Institute' y corroboramos que es de United Kingdom
Select country from company
where company_name = 'Non Institute';

-----------------------------------------------------------------------------------------------
-- A> Mostra el llistat aplicant JOIN i subconsultes.
-----------------------------------------------------------------------------------------------
-- Utilizando el JOIN me permite visualizar los datos de ambas tablas y ver los datos de las empresas que realizan cada transacción

SELECT * 
FROM transaction JOIN company 
	ON transaction.company_id=company.id
	WHERE country in (
		SELECT country 
        FROM company
		WHERE company_name = 'Non Institute')
	AND company_name not like 'Non Institute';

-- Ahora bien, si quisiera sólamente visualizar los datos de la tabla de transacciones pero solo tomando id y nombre de la
-- tabla 'company', el código sería el siguiente:

SELECT * 
FROM transaction join (
	SELECT id, company_name 
    FROM company
	WHERE company_name not like 'Non Institute' 
    AND country in (
		SELECT country from company
		WHERE company_name = 'Non Institute')) empresas_UK
		ON transaction.company_id=empresas_UK.id;


-----------------------------------------------------------------------------------------------
-- B> Mostra el llistat aplicant solament subconsultes.
-----------------------------------------------------------------------------------------------
-- En esta logro el resultado correcto utilizando puras subconsultas, pero sin utilizar los JOINS no se pueden ver los datos de la tabla 'company', sino
-- solo los datos de las transacciones

SELECT * 
FROM transaction
WHERE company_id in 
	(SELECT id 
    FROM company 
    WHERE company_name not like 'Non Institute' 
    AND country in(
		SELECT country 
        FROM company 
        WHERE company_name = 'Non Institute'));

-- SUBCONSULTA QUE ME DA LA ID DE LAS EMPRESAS DEL MISMO PAÍS QUE Non Institute como para poder filtrarlo luego

Select id, company_name from company
where country in ( Select country from company
where company_name = 'Non Institute');

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- NIVELL 3
---------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------
-- Exercici 1
----------------------------------------
-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 100 i 200 euros 
-- i en alguna d'aquestes dates: 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. Ordena els resultats de major a menor quantitat.

SELECT company_name, phone, country, amount, date(timestamp) 
FROM transaction JOIN company 
	ON company.id=transaction.company_id
	WHERE amount > 100 
    AND amount < 200
	AND (date(timestamp) = '2021-04-29' or date(timestamp) = '2021-07-20' or date(timestamp) = '2022-03-13')
ORDER BY amount desc;

-- (otra forma de gestionar el date)
SELECT company_name, phone, country, date(timestamp) as data, amount
FROM company JOIN transaction 
	ON transaction.company_id=company.id
	WHERE amount between 100 and 200 AND date(timestamp) in ('2021-04-29', "2021-07-20", "2022-03-13")
ORDER BY amount desc;

----------------------------------------
-- Exercici 2
----------------------------------------
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la informació 
-- sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat de les empreses on 
-- especifiquis si tenen més de 4 transaccions o menys.

SELECT company.company_name EMPRESAS, count(transaction.id) as 'transacciones totales', 
IF(count(transaction.id) >4, 'mas de 4', '4 o menos') as 'Más o menos de 4'
FROM company JOIN transaction 
	ON company.id=transaction.company_id
GROUP BY company_name
ORDER BY 2 desc;



  
