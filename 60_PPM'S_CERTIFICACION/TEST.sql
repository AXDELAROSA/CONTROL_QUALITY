

USE PPMS_PEARL
	SELECT * FROM numpart WHERE noparte = '200766DTX7'

	SELECT * FROM [PPMS_PEARL].[dbo].personal (NOLOCK) WHERE INSPECTOR_CAL = 'GLADYS DEL CARMEN MARTINEZ PATRACA'
	SELECT * FROM [PPMS_PEARL].[dbo].personal (NOLOCK) WHERE SELLO = '000'
	SELECT * FROM [PPMS_PEARL].[dbo].personal (NOLOCK) WHERE NORELOJ =14869

	--OBTENER TOTAL EN DINERO DE LOS DEFECTOS DE CDERTIFICACION DEL DIA
	SELECT	* FROM [PPMS_PEARL].[dbo].certificacion_rpt (NOLOCK) WHERE CONVERT(DATE,FECHA) = '2021-12-09' and cant1 > 0 AND PATRON <> '' AND PATRON = '11075877' ORDER BY noserie_caja, PATRON 
	
	SELECT	* FROM [PPMS_PEARL].[dbo ].certificacion_rpt (NOLOCK) WHERE COSTO > 0 --AND CONVERT(DATE,FECHA) = '2021-12-14'
	ORDER BY ID DESC
	
	SELECT	TOP 2000 * FROM [PPMS_PEARL].[dbo].certificacion_rpt WHERE noserie_caja = '58171010' 
	ORDER BY ID DESC
	

	SELECT	TIPODEF,
			(SUM(cant1)+ SUM(cant2)+ SUM(cant3)) AS TOTAL_DEFECTOS,
			SUM(ISNULL(COSTO, 0)) AS TOTAL_COSTO
	FROM [PPMS_PEARL].[dbo].certificacion_rpt (NOLOCK) 
	INNER JOIN [PPMS_PEARL].[dbo].DEF (NOLOCK)  ON certificacion_rpt.defecto1 = DEF.clave
	WHERE CONVERT(DATE,FECHA) >= '2021-12-01'  AND CONVERT(DATE,FECHA) <= '2021-12-14'
	GROUP BY  TIPODEF
	ORDER BY  TIPODEF

	SELECT	* FROM [PPMS_PEARL].[dbo].certificacion_rpt (NOLOCK) 
	INNER JOIN [PPMS_PEARL].[dbo].DEF (NOLOCK)  ON certificacion_rpt.defecto1 = DEF.clave
	WHERE TIPODEF = 'PERFORADO'
	AND CONVERT(DATE,FECHA) >= '2021-12-01'  AND CONVERT(DATE,FECHA) <= '2021-12-13'

	SELECT DISTINCT TIPODEF FROM [PPMS_PEARL].[dbo].DEF 

	 SELECT  * FROM	DATA_02.DBO.IMITMIDX_SQL WHERE LTRIM(RTRIM(LANDED_COST_CD)) = '2532968'

	SELECT * --LTRIM(RTRIM(CUS.CUS_ITEM_NO)) 
	FROM DATA_02.DBO.cccusitm_sql (NOLOCK)  
	WHERE ITEM_NO = 'PWSBRB6VCCAD4' 
	--AND CUS.CUS_NO = cccusitm_sql.CUS_NO  
	--AND CUS.MODELNO = cccusitm_sql.MODELNO AND CUS.VERSIONNO = cccusitm_sql.VERSIONNO
	ORDER BY versionno DESC

	SELECT * FROM	DATA_02.DBO.ccprdstr_sql (NOLOCK) WHERE ITEM_NO IN ( 'PWSBRB6VCCAD4') ORDER BY versionno DESC
	
	SELECT	* FROM [PPMS_PEARL].[dbo].certificacion_rpt (NOLOCK) WHERE ORDEN = '43929' order by noserie_caja

	SELECT * --TOP 1 PRC_OR_DISC_1
	FROM	DATA_02.DBO.OEPRCFIL_SQL 
	WHERE	LTRIM(RTRIM(filler_0001)) LIKE '%' + 'IC3A0008VCCAD4' 
	AND LTRIM(RTRIM(filler_0001)) LIKE 'FAUR01' + '%'
	ORDER BY A4GLIdentity DESC
	
	SELECT 1.5523 * 2

	--OBTENER TOTAL EN DINERO DE LOS DEFECTOS DE CDERTIFICACION DEL DIA
	SELECT	* FROM [PPMS_PEARL].[dbo].certificacion_rpt (NOLOCK) WHERE CONVERT(DATE,FECHA) >= '2021-11-01' AND CONVERT(DATE,FECHA) <= '2021-11-30' and cant1 > 0 AND PATRON <> '' ORDER BY noserie_caja, PATRON 



	SELECT * FROM HOWE.DBO.VISTA_GAFETES (NOLOCK) WHERE  EN_NUM_EMP = 13367

	--	DEFECTO CRITICO: ( 'EE', 'ES', 'FL', 'LE', 'LM', 'MI', 'PF', 'PFL', 'PM', 'PSP', 'PS', 'PE', 'PSL', 'SB' )
	SELECT * FROM DEF WHERE CRITICO = 1

	SELECT * FROM [PPMS_PEARL].[dbo].DEF WHERE clave IN ('AC', 'AR' )

	-- //////////PPMS DE PRD////////////////////////////////////////////////////
	SELECT * 
	FROM [PPMS_PEARL].[dbo].[QC] 
	WHERE  CONVERT(DATE, [Date]) = '2021-12-08' 
	AND [Shift] = 1

	 SELECT DEFECTO, SUM(Cant) AS TOTAL
	 FROM [PPMS_PEARL].[dbo].[DEFECTOS] 
	 WHERE ID IN (SELECT ID  FROM [PPMS_PEARL].[dbo].[QC] WHERE CONVERT(DATE, [Date]) = '2021-12-08' AND [Shift] = 1)
	 GROUP BY Defecto 
	 ORDER BY Defecto
	 	 
	select * from [PPMS_PEARL].[dbo].rechazos where ORDEN = 48690
	
select * from [PPMS_PEARL].[dbo].numpart 
WHERE nopartepearl IN ( SELECT item_no 
						FROM	DATA_02.dbo.ccjoblin_sql (NOLOCK)
						WHERE	jobno in ('48665')
						)

	SELECT * FROM [PPMS_PEARL].[dbo].[QC] WHERE  ORDER_NO = '10935'--CONVERT(DATE, Date) = '2021-12-08' AND MACHINE = 41 --AND [SHIFT] = 1

	SELECT *   FROM [PPMS_PEARL].[dbo].[DEFECTOS] WHERE  ORDEN = '32736' --ID IN (316165, 316075) ORDER BY ID
	
	SELECT Machine,
			ISNULL((SELECT SUM([DEFECTOS].Cant)  FROM [PPMS_PEARL].[dbo].[DEFECTOS] (NOLOCK) WHERE [DEFECTOS].ID = [QC].ID), 0)	 
	FROM 
	[PPMS_PEARL].[dbo].[QC] 
	WHERE CONVERT(DATE, Date) = '2021-11-15' 
	GROUP BY Machine
	ORDER BY Machine	

	SELECT * FROM  [DATA_02].dbo.imlocfil_sql where loc = 'mfp'

	-- ORDEN CON KIT U 48125
	SELECT * FROM [DATA_02].dbo.jobs_piso WHERE  jobno = '48125'
		
	SELECT * FROM [MATERIAL_PROGRAMADO_LOG] (NOLOCK) WHERE SERIAL LIKE '46500%' ORDER BY SERIAL, K_MATERIAL_PROGRAMADO_LOG

	SELECT * FROM [DATA_02].dbo.ccjoblin_sql WHERE JOBNO = '43929'

	SELECT * FROM [DATA_02].dbo.ccjobhdr_sql WHERE jobno = '43929'

	SELECT * --SUM(OriginalQty * patternsper)
	FROM [DATA_02].dbo.ccjoblin_sql WHERE  jobno = '47978'

	SELECT * FROM [DATA_02].dbo.cccuthst_sql WHERE  jobno = '45250' ORDER BY LOTNO
	
	select * from [PPMS_PEARL].[dbo].rechazos WHERE mesa = 'TABLE 54' AND fecha = '20220118'
	
	
select * from [PPMS_PEARL].[dbo].numpart WHERE nopartepearl in ( SELECT item_no FROM	DATA_02.dbo.ccjoblin_sql (NOLOCK)
WHERE	jobno in ('47978'))

	--DELETE [PPMS_PEARL].[dbo].[QC] WHERE Machine = '54' AND CONVERT(DATE, [DATE]) = '2022-01-18'

--ID		Date					Order_No	Shift	Machine	Inspector			Sample_size	Accepted	Rejected	Defect_No	Defect_type	inspector_prod	jefe_gpo	Lot_no	Set_No
--323344	2022-01-18 00:00:00.000	47978		1		54		ALEXIS DIAZ REYES	22			0			1	NULL	NULL	EDGAR ALBERTO HERNANDEZ HERNANDEZ	LUIS CERVANTES	403441	NULL
--323345	2022-01-18 00:00:00.000	47978		2		54		ALEXIS DIAZ REYES	6			0			1	NULL	NULL	EDGAR ALBERTO HERNANDEZ HERNANDEZ	LUIS CERVANTES	403441	NULL
--323408	2022-01-18 00:00:00.000	49297		1		54		ALEXIS DIAZ REYES	0			0			1	NULL	NULL	EMMA JADZIRY CARRILLO INIESTRA	OMAR	403271	NULL
--323409	2022-01-18 00:00:00.000	49297		2		54		ALEXIS DIAZ REYES	11			0			1	NULL	NULL	EMMA JADZIRY CARRILLO INIESTRA	OMAR	403271	NULL

	SELECT * FROM [PPMS_PEARL].[dbo].[DEFECTOS] WHERE ID IN (323344, 323345)

	SELECT * FROM [BD_GENERAL].[dbo].USUARIO_PEARL 

	SELECT * FROM DATA_02.dbo.pearl_log WHERE  screen_opt = 'Modificar defecto' and movement = 'dl'

	SELECT * FROM DATA_02.dbo.pearl_log WHERE jobno = '48336'


	-- logica para liberar orden

SELECT		ccjoblin_sql.item_no, SUM(CONVERT(int,(OriginalQty * CUBE_QTY_PER))) as muestra,
(select top 1 cus_item_no from DATA_02.dbo.cccusitm_sql where cccusitm_sql.item_no = ccjoblin_sql.Item_No
			order by versionno desc) AS noparte
FROM DATA_02.dbo.ccjoblin_sql  (NOLOCK)
inner join DATA_02.dbo.imitmidx_sql on ccjoblin_sql.item_no = imitmidx_sql.item_no
WHERE	ccjoblin_sql.jobno = '48665'  
group by ccjoblin_sql.item_no order by item_no

--SELECT  jobno,  sum (muestra * originalqty/30) as muestrat, sum (perforado* originalqty/30) as perft, sum (quilty* originalqty/30) as quiltyt  
--FROM DATA_02.dbo.ccjoblin_sql, PPMS_PEARL.dbo.numpart 
--WHERE item_no = nopartepearl AND jobno ='48665'
--group by jobno

--SELECT	jobno, ccjoblin_sql.Item_No, 
--		count(col_key) AS KIT_PROGRAMADO, 
--		sum(OriginalQty)as originalqty, --KitDesc, --, cus_item_no
--		(select top 1 cus_item_no from DATA_02.dbo.cccusitm_sql where cccusitm_sql.item_no = ccjoblin_sql.Item_No
--			order by versionno desc) AS noparte
--from	DATA_02.dbo.ccjoblin_sql 
----inner join DATA_02.dbo.cccusitm_sql on cccusitm_sql.item_no	= ccjoblin_sql.Item_No
--WHERE	jobno in ('48100')--,'48100')--'" & Val(txtorden.Text).ToString.PadLeft(5, "0") & "' 
----and item_no = 'PJL2RB6MCKTX7'
--group	by jobno, ccjoblin_sql.Item_No--, KitDesc
--order by ccjoblin_sql.Item_No

select * from [PPMS_PEARL].[dbo].numpart WHERE nopartepearl in ( SELECT item_no FROM	DATA_02.dbo.ccjoblin_sql (NOLOCK)
WHERE	jobno in ('48665'))
             
SELECT * FROM [PPMS_PEARL].[dbo].[RECHAZOS] WHERE Orden IN (45200)

SELECT * FROM [PPMS_PEARL].[dbo].DEF WHERE clave IN (
	SELECT DISTINCT DEFECTO FROM [PPMS_PEARL].[dbo].[RECHAZOS] WHERE Orden IN (48336)
)

SELECT COUNT(id) AS TOTAL_DEFECTO FROM [PPMS_PEARL].[dbo].[RECHAZOS] WHERE Orden IN (45200)

SELECT * FROM [PPMS_PEARL].[dbo].[QC] WHERE ORDER_NO = '46981' -- ID IN (303022)

SELECT * FROM [PPMS_PEARL].[dbo].[DEFECTOS] WHERE Orden IN (45200)
SELECT SUM(Cant) AS TOTAL_DEFECTO FROM [PPMS_PEARL].[dbo].[DEFECTOS] WHERE Orden IN (45200)

SELECT * FROM	DATA_02.dbo.ccjoblin_sql (NOLOCK) WHERE	jobno in ('43929')

SELECT		ccjoblin_sql.item_no, SUM(CONVERT(int,(OriginalQty * CUBE_QTY_PER))) as muestra
FROM DATA_02.dbo.ccjoblin_sql  (NOLOCK)
inner join DATA_02.dbo.imitmidx_sql on ccjoblin_sql.item_no = imitmidx_sql.item_no
WHERE	ccjoblin_sql.jobno = '48100'  
group by ccjoblin_sql.item_no order by item_no


SELECT * FROM	DATA_02.dbo.ccjobhdr_sql (NOLOCK)
WHERE	jobno in ('48100')

SELECT * FROM	DATA_02.dbo.ccjoblin_sql WHERE	jobno in ('48100') ORDER BY item_no

SELECT item_no, CUBE_QTY_PER FROM DATA_02.dbo.imitmidx_sql (NOLOCK) 
WHERE item_no IN ( SELECT DISTINCT item_no 
					FROM DATA_02.dbo.ccjoblin_sql (NOLOCK) 
					WHERE	ccjoblin_sql.jobno = '48100') ORDER BY item_no



