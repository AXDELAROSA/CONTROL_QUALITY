
USE DATA_02Pruebas

SELECT TOP 100	* FROM	IncInsp_sql ORDER BY Date DESC
WHERE 	LTRIM(RTRIM(Lot)) = '034451' 

SELECT DISTINCT [STATUS] FROM	IncInsp_sql 

select * from PPMS_PEARL.DBO.def where descripcion='NATURAL'









