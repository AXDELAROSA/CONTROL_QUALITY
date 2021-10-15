

USE PPMS_PEARL
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


	SELECT *
	FROM certificacion_rpt (NOLOCK)
	WHERE  FECHA = '20211012'

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

	
	-- //////////PPMS////////////////////////////////////////////////////
	SELECT * FROM [PPMS_PEARL].[dbo].[QC] WHERE CONVERT(DATE, Date) = '2021-09-13' ORDER BY INSPECTOR
	SELECT * FROM [PPMS_PEARL].[dbo].[QC] WHERE ID = 303022 -- CONVERT(DATE, Date) = '2021-09-01'
	SELECT *   FROM [PPMS_PEARL].[dbo].[DEFECTOS] WHERE ID IN (303022) ORDER BY ID
	