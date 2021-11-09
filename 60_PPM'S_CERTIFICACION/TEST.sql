

USE PPMS_PEARL
SELECT TOP 1 * FROM rechazos WHERE ORDEN = '43103'

-- 100051983-001  44801               
--UPDATE rechazos 
--SET ORDEN = '44801',
--	noparte  = '100051983-001'
--WHERE ORDEN = '43103' AND ID = 2092213

SELECT TOP 1 * FROM DEF

	SELECT DISTINCT ITEM_NO FROM DATA_02.dbo.ccjoblin_sql WHERE JOBNO = '43103'
	
	SELECT * FROM numpart 
	WHERE noparte = '200766DTX7'

	SELECT * FROM numpart 
	WHERE nopartepearl IN (SELECT ITEM_NO FROM DATA_02.dbo.ccjoblin_sql WHERE JOBNO IN ('44801', '43103') )

-- ////////////////CERTIFICACION//////////////////////////////////////////////
	select distinct cus_item_no, imitmidx_sql.item_no, imitmidx_sql.prod_cat, imcatfil_sql.prod_cat_desc 
	from DATA_02.DBO.part_no_view, DATA_02.DBO.imitmidx_sql, DATA_02.DBO.imcatfil_sql  
	where imitmidx_sql.item_no= part_no_view.item_no and imitmidx_sql.prod_cat= imcatfil_sql.prod_cat AND imcatfil_sql.L_BORRADO<>1 and cus_item_no= '2532934C4X-AD'

	select distinct cus_part_no, imitmidx_sql.item_no, imitmidx_sql.prod_cat, imcatfil_sql.prod_cat_desc 
	from DATA_02.DBO.u_PART_no, DATA_02.DBO.imitmidx_sql, DATA_02.DBO.imcatfil_sql  
	where imitmidx_sql.item_no= u_PART_no.u_PART_no and imitmidx_sql.prod_cat= imcatfil_sql.prod_cat and cus_PART_no= '2532934C4X-AD'

	SELECT * FROM DATA_02.DBO.ccjobhdr_sql WHERE jobno = '43380'
	SELECT * FROM DATA_02.DBO.CCJOBLIN_SQL WHERE jobno = '43380'
	AND MODELNO = 'RUA' 
	AND VERSIONNO = '0036'

	SELECT * FROM DATA_02.DBO.PEARL_LOG WHERE SCREEN_OPT = 'Modificar SELLOS' ORDER BY CKEY DESC

	FR 01-SEP-2021 A 08-11-201

	SELECT *
	FROM certificacion_rpt (NOLOCK)
	WHERE  NO_PARTE = '200489BTX7'

	SELECT *
	FROM certificacion_rpt (NOLOCK)
	WHERE  id IN ( '4106698', '4107119') 
	AND FECHA = '20211012'

	SELECT *
	FROM  [PPMS_PEARL].[dbo].personal 
	WHERE NORELOJ IN (15438, 15498, 15996) order by inspector_cal

	SELECT inspector_cal, noreloj, COUNT(sello) AS N_SELLO 
	FROM  [PPMS_PEARL].[dbo].personal 
	GROUP BY inspector_cal, noreloj
	HAVING COUNT(sello) > 1

	SELECT	CONVERT(DATE, fecha) AS 'FECHA', 
			SUM(TOTAL) AS 'TOTAL_MUESTRA', 
			(SUM(cant1)+ SUM(cant2)+ SUM(cant3)) AS 'TOTAL_DEFECTOS'
	FROM certificacion_rpt (NOLOCK)
	INNER JOIN personal (NOLOCK) ON sello = sello_paq
	WHERE CONVERT(DATE, fecha) = '2021-10-01'
	AND personal.turno = 1
	GROUP BY CONVERT(DATE, fecha)
	order by fecha
	
	SELECT sum(total)
	FROM certificacion_rpt (NOLOCK)
	INNER JOIN personal (NOLOCK) ON sello = sello_paq
	WHERE CONVERT(DATE, fecha) = '2021-10-01'
	AND personal.turno = 1

	SELECT * FROM personal (NOLOCK)
	SELECT * FROM DEF (NOLOCK) ORDER BY clave
	-- //////////PPMS////////////////////////////////////////////////////
	SELECT * FROM [PPMS_PEARL].[dbo].[QC] WHERE CONVERT(DATE, Date) = '2021-09-13' ORDER BY INSPECTOR
	SELECT * FROM [PPMS_PEARL].[dbo].[QC] WHERE ID = 303022 -- CONVERT(DATE, Date) = '2021-09-01'
	SELECT *   FROM [PPMS_PEARL].[dbo].[DEFECTOS] WHERE ID IN (303022) ORDER BY ID
	