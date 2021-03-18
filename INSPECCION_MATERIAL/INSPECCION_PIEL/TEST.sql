
USE DATA_02Pruebas

SELECT TOP 100	* FROM	IncInsp_sql ORDER BY Date DESC
WHERE 	LTRIM(RTRIM(Lot)) = '034451' 

SELECT DISTINCT [STATUS] FROM	IncInsp_sql 

select * from PPMS_PEARL.DBO.def where descripcion='NATURAL'


SELECT TOP 10 * FROM Perforacion WHERE NOSERIE = '25984005'


SELECT TOP 100 * FROM cccuthst_sql WHERE --machine = 'Table 37' AND cdate = 20210316 AND 
jobno = '26220 '


--UPDATE cccuthst_sql 
--SET cshift = 0
--WHERE jobno = '26220'








