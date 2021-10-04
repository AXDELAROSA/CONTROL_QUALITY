

USE PPMS_PEARL
-- ////////////////CERTIFICACION//////////////////////////////////////////////
	SELECT *
	FROM certificacion_rpt (NOLOCK)
	WHERE --CONVERT(DATE, fecha) = '2021-09-13'
	 YEAR(CONVERT(DATE, fecha)) = 2021
	AND MONTH(CONVERT(DATE, fecha)) = 9
	AND insp_certi LIKE '%NANCY%'

	SELECT inspector_cal,COUNT(sello)  FROM  [PPMS_PEARL].[dbo].personal 
	GROUP BY  inspector_cal
	HAVING COUNT(sello) > 1

	SELECT * FROM  [PPMS_PEARL].[dbo].personal WHERE inspector_cal = 'ADONIRAM BALCAZAR VIDANA'
	SELECT * FROM  [PPMS_PEARL].[dbo].personal WHERE inspector_cal = 'ALMA LIDIA ESPINO RODRIGUEZ'
	SELECT * FROM  [PPMS_PEARL].[dbo].personal WHERE inspector_cal = 'ARY LAZARO LOPEZ'
	SELECT * FROM  [PPMS_PEARL].[dbo].personal WHERE inspector_cal = 'NANCY JAZMIN SILVA GARCIA'
	SELECT * FROM  [PPMS_PEARL].[dbo].personal WHERE inspector_cal = 'ROBERTO CARLOS MARTINEZ GONZALEZ'


	SELECT * FROM  [PPMS_PEARL].[dbo].def

	-- //////////PPMS////////////////////////////////////////////////////
	SELECT * FROM [PPMS_PEARL].[dbo].[QC] WHERE CONVERT(DATE, Date) = '2021-09-01' ORDER BY INSPECTOR
	SELECT * FROM [PPMS_PEARL].[dbo].[QC] WHERE ID = 301019 -- CONVERT(DATE, Date) = '2021-09-01'
	SELECT *   FROM [PPMS_PEARL].[dbo].[DEFECTOS] WHERE ID IN (301019) ORDER BY ID
	