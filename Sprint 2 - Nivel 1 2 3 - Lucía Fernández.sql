-- SPRINT 2 - Lucía Fernández Gagliano

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- NIVELL 1
---------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------
-- EXERCICI  1 
----------------------------------------
--       La Base de Datos 'Transactions' cuenta con dos tablas: Transaction y Company. Por estar en SQL se trata de una tabla relacional.

--       En la Tabla Transaction -que podría funcionar como una 'tabla de hechos'- tenemos los datos de cada transacción con su ID como Primary Key. 
--       Las variables que se computan son el ID de la tarjeta de crédito, el ID de la empresa, el ID del usuario, la latitud y la longitud -como locación-,
--       el momento de la transación (timestamp), y el monto de la misma. 

--       En la Tabla Company -que podría funcionar como Tabla de Dimensiones- tenemos el ID de la empresa como Primary Key junto a otras variables de la empresa:
--       El nombre, el teléfono, email, país y la website de la empresa.



----------------------------------------
-- EXERCICI 2 (JOINS)
----------------------------------------
-----------------------------------------------------------------------------------------------
-- A > Llistat dels països que estan fent compres.
-----------------------------------------------------------------------------------------------

SELECT distinct country from company join transaction on company.id=transaction.company_id;





-----------------------------------------------------------------------------------------------
-- B > Des de quants països es realitzen les compres.
-----------------------------------------------------------------------------------------------

SELECT count(distinct country) from company join transaction on company.id=transaction.company_id;

-----------------------------------------------------------------------------------------------
-- C > Identifica la companyia amb la mitjana més gran de vendes.
-----------------------------------------------------------------------------------------------

SELECT company_name, avg(amount) media_ventas from company join transaction on company.id=transaction.company_id
where declined = 0
group by company_name
order by media_ventas desc
LIMIT 1;


----------------------------------------
-- EXERCICI 3 (SUBCONSULTES)
----------------------------------------
-----------------------------------------------------------------------------------------------
-- A > Mostra totes les transaccions realitzades per empreses d'Alemanya.
-----------------------------------------------------------------------------------------------

-- con SUBCONSULTA
SELECT transaction.id as transacciones_alemanas from transaction 
where company_id in(SELECT id from company where country = 'Germany');

-- (la Subconsulta):
SELECT id from company where country = 'Germany';

-- (con JOIN para corroborar)-> hay 118 transacciones con empresas de Alemania
SELECT transaction.id, company.country from transaction join company on company.id=transaction.company_id
where country = 'Germany';
-----------------------------------------------------------------------------------------------
-- B > Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
-----------------------------------------------------------------------------------------------
-- (sin tener en cuenta si las transacciones han sido declinadas o no)

SELECT company_name from company
where company.id IN (SELECT company_id from transaction where amount > (SELECT  avg(amount) from transaction));

-- (la Subconsulta)
SELECT  avg(amount) from transaction;

-- CORROBORACIÓN
select distinct company_id from transaction
where amount > '256.735520'
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


-- sin fecha convertida
SELECT timestamp, sum(amount) amount_by_day from transaction
where declined = 0
group by timestamp
order by amount_by_day desc
limit 5;

-- PARA PASAR SOLO A FECHA SIN HORA Y PODER AGRUPAR POR DÍA 
select date(timestamp) from transaction;

-- CON FECHA CONVERTIDA
SELECT date(timestamp) fecha, sum(amount) amount_by_day from transaction
where declined = 0
group by fecha
order by amount_by_day desc
limit 5;

----------------------------------------
-- Exercici 2
----------------------------------------
-- >Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.

SELECT AVG(amount) media_ventas_pais, country from transaction join company on transaction.company_id=company.id
where declined = 0
group by country
order by media_ventas_pais desc;

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

SELECT * from transaction join company on transaction.company_id=company.id
where country in (Select country from company
where company_name = 'Non Institute')
and company_name not like 'Non Institute';

-- Ahora bien, si quisiera sólamente visualizar los datos de la tabla de transacciones pero solo tomando id y nombre de la
-- tabla 'company', el código sería el siguiente:

Select * from transaction join 
	(Select id, company_name from company
	where company_name not like 'Non Institute' and country in ( Select country from company
	where company_name = 'Non Institute')) empresas_UK
    on transaction.company_id=empresas_UK.id;


-----------------------------------------------------------------------------------------------
-- B> Mostra el llistat aplicant solament subconsultes.
-----------------------------------------------------------------------------------------------
-- En esta logro el resultado correcto utilizando puras subconsultas, pero sin utilizar los JOINS no se pueden ver los datos de la tabla 'company', sino
-- solo los datos de las transacciones

Select * from transaction
where company_id in 
	(Select id from company where company_name not like 'Non Institute' and country in 
		( Select country from company where company_name = 'Non Institute'));

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

SELECT company_name, phone, country, amount, date(timestamp) from transaction join company on company.id=transaction.company_id
where amount > 100 and amount < 200
and (date(timestamp) = '2021-04-29' or date(timestamp) = '2021-07-20' or date(timestamp) = '2022-03-13')
order by amount desc;

-- (otra forma de gestionar el date)
select company_name, phone, country, date(timestamp) as data, amount
from company
join transaction on transaction.company_id=company.id
where amount between 100 and 200 and date(timestamp) in ('2021-04-29', "2021-07-20", "2022-03-13")
order by amount desc;

----------------------------------------
-- Exercici 2
----------------------------------------
-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la informació 
-- sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat de les empreses on 
-- especifiquis si tenen més de 4 transaccions o menys.

SELECT company.company_name EMPRESASMENOS, count(transaction.id) as 'transacciones totales', 
IF(count(transaction.id) >4, 'mas de 4', '4 o menos') as 'Más o menos de 4'
from company join transaction on company.id=transaction.company_id
group by company_name
order by 2 desc;



  
