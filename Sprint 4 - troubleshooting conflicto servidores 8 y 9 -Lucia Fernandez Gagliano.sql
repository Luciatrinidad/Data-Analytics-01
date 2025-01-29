----------------------------------------------------------------------------------------------
-- > POR PROBLEMAS DE CONFIGURACIÓN DE MYSQL WORKBENCH INICIAMOS EL SIGUIENTE TROUBLESHOOTING:
----------------------------------------------------------------------------------------------
# ERROR 1290 
# Error Code: 2068. LOAD DATA LOCAL INFILE file request rejected due to restrictions on access.
# Doble servidor, 8.0 y 9.0 que podrían generar conflicto
----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
-- 1 > buscamos dónde se alojan los archivos para cargarlos desde el servidor:
----------------------------------------------------------------------------------------------
#SHOW VARIABLES LIKE 'secure_file_priv'; -- > para ver dónde se alojan el
# C:\ProgramData\MySQL\MySQL Server 9.0\Uploads\

----------------------------------------------------------------------------------------------
-- 2 > abrimos el archivo de configuración
----------------------------------------------------------------------------------------------
# borro la condición de Secure File en el archivo 'my' de C:\ProgramData\MySQL\MySQL Server 9.0
# copio el archivo en la carpeta Uploads
# borro esto 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads'
# borro esto 'C:/ProgramData/MySQL/MySQL Server 9.0/Uploads'
# sigue dándome el mismo error

# tutoriales:
-- LOAD DATA
-- https://dev.mysql.com/doc/refman/8.4/en/load-data.html

-- PRIVILEDGES PROVIDED BY MYSQL
-- https://dev.mysql.com/doc/refman/8.4/en/privileges-provided.html

-- ERROR 1290 
-- https://www.youtube.com/watch?v=INtejSjK5w0
-- https://www.youtube.com/shorts/n4xjOUnfOMY
-- https://www.youtube.com/watch?v=-FAUojWZ0-k
-- https://fullstacklog.com/importar-fichero-csv-en-mysql-mariadb-via-command-line/

----------------------------------------------------------------------------------------------
-- 3 > configuramos para que nos permita cargar archivos desde servidor
----------------------------------------------------------------------------------------------
#SET GLOBAL local_infile=on;
#SHOW GLOBAL VARIABLES LIKE 'local_infile'; #ON

----------------------------------------------------------------------------------------------
-- 4 > INTEGRO LA SIGUIENTE ORDEN EN EL Manage Conections - Advanced . Test Conection:
----------------------------------------------------------------------------------------------
# OPT_LOCAL_INFILE=1

----------------------------------------------------------------------------------------------
-- 5 > EL PROBLEMA PERSISTE...
----------------------------------------------------------------------------------------------
-- las soluciones que funcionan en la versión 8.4 no me funcionan en mi versión 9.0 posiblemente por un conflicto entre los dos servidores 
-- que se encuentran en simultáneo... 

-- tampoco me deja exportar las bases de datos por este problema que la dirección que tiene para alojar los datos estába en el server 8.4 que 
-- ya no se encuentra 

-- mi ordenador tampoco encuentra la direccion donde dice alojar las exportaciones
-- C:\Users\lulaz\Documents\dumps

--  ni encuentro la capeta donde hace el dumping del servidor 9.0

----------------------------------------------------------------------------------------------
# ME DISPONGO A PREPARAR LA DESINSTALACIÓN Y RE-INSTALACIÓN DE MySQL. EL CONFLICTO ENTRE LOS SERVIDORES PARECE IRREVERSIBLE...
----------------------------------------------------------------------------------------------
# Pruebo borrando dos bases de datos de Especialización y volviéndolas a cargar. Me exporta y guarda las tablas, así que:
# 1ero -> hay que crear las Database
# 2do -> hay que ir cargando tabla por tabla
# 3ro -> probando con la tabla 'transactions' veo que carga bien las tablas
# 4to -> las 'views' que se alojan en el archivo 'transactions_routines' no se cargan bien, por lo que habrá que volver a ejecutarlas desde el Sprint 3
# Ahora sí, me voy despidiendo de mis dos versioner chafadas MySql -> hasta la vista baby!

----------------------------------------------------------------------------------------------
# VUELVO A INSTALAR MYSQL, server 8.0
----------------------------------------------------------------------------------------------
# me aseguro que transactions funciona bien y puedo ejecutar correctamente el Sprint 2 igual que antes de desinstalar

# VUELVO A CREAR LAS DOS BASES DE DATOS QUE TENÍA, 'transactions' y 'transtrans'.
# REALIZO LAS MODIFICACIONES SUGERIDAS EN EL ARCHIVO 'my' DE CONFIGURACIÓN PARA PODER CARGAR LOS ARCHIVOS CSV
