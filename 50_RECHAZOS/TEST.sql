

USE PPMS_PEARL
	SELECT * FROM numpart WHERE noparte = '200766DTX7'
	SELECT * FROM certificacion_rpt WHERE orden = 50011 order by id

	SELECT * FROM [PPMS_PEARL].[dbo].personal (NOLOCK) WHERE SELLO = '100'
	SELECT * FROM [PPMS_PEARL].[dbo].personal (NOLOCK) WHERE NORELOJ =14869

	 SELECT  * FROM	DATA_02.DBO.IMITMIDX_SQL WHERE LTRIM(RTRIM(LANDED_COST_CD)) = '2532968'

	SELECT * --LTRIM(RTRIM(CUS.CUS_ITEM_NO)) 
	FROM DATA_02.DBO.cccusitm_sql (NOLOCK)  
	WHERE ITEM_NO = 'PWSBRB6VCCAD4' 
	--AND CUS.CUS_NO = cccusitm_sql.CUS_NO  
	--AND CUS.MODELNO = cccusitm_sql.MODELNO AND CUS.VERSIONNO = cccusitm_sql.VERSIONNO
	ORDER BY versionno DESC

	SELECT * FROM	DATA_02.DBO.ccprdstr_sql (NOLOCK) WHERE ITEM_NO IN ( 'PWSBRB6VCCAD4') ORDER BY versionno DESC
	
	SELECT * --TOP 1 PRC_OR_DISC_1
	FROM	DATA_02.DBO.OEPRCFIL_SQL 
	WHERE	LTRIM(RTRIM(filler_0001)) LIKE '%' + 'IC3A0008VCCAD4' 
	AND LTRIM(RTRIM(filler_0001)) LIKE 'FAUR01' + '%'
	ORDER BY A4GLIdentity DESC

	SELECT * FROM HOWE.DBO.VISTA_GAFETES (NOLOCK) WHERE  EN_NUM_EMP = 13367

	--	DEFECTO CRITICO: ( 'EE', 'ES', 'FL', 'LE', 'LM', 'MI', 'PF', 'PFL', 'PM', 'PSP', 'PS', 'PE', 'PSL', 'SB' )
	SELECT * FROM DEF WHERE CRITICO = 1

	SELECT * FROM [PPMS_PEARL].[dbo].DEF WHERE clave IN ('AC', 'AR' )

	-- //////////PPMS DE PRD////////////////////////////////////////////////////
	SELECT * FROM [DATA_02].dbo.ccjoblin_sql WHERE JOBNO = '51169'

	SELECT * FROM [DATA_02].dbo.pearl_log WHERE JOBNO = '51823'

	SELECT * FROM [DATA_02].dbo.ccjobhdr_sql WHERE jobno = '51823'

	SELECT SUM(OriginalQty * patternsper)
	FROM [DATA_02].dbo.ccjoblin_sql WHERE  jobno = '45250'
		
	SELECT	tipodef	AS TIPO_DEFECTO, 
			CLAVE	AS CLAVE_DEFECTO,  
			COUNT(ID) AS TOTAL_DEFECTO
	FROM [PPMS_PEARL].[dbo].Rechazos (NOLOCK)
	INNER JOIN [PPMS_PEARL].[dbo].DEF (NOLOCK) ON clave = Rechazos.defecto
	WHERE ORDEN = 48100
	AND noparte = '201025A' --'201024A'
	GROUP BY tipodef, CLAVE
	ORDER BY tipodef, CLAVE

	SELECT DISTINCT tipodef FROM [PPMS_PEARL].[dbo].DEF (NOLOCK) WHERE tipodef = 'NORMAL'

	SELECT * FROM [PPMS_PEARL].[dbo].personal (NOLOCK) WHERE SELLO = '100'

	SELECT * FROM [DATA_02].dbo.cccuthst_sql WHERE  jobno = '51169' ORDER BY LOTNO

	SELECT * FROM [PPMS_PEARL].[dbo].rechazos WHERE orden = 51169

	-- 339 + 1814 = 2,153
	SELECT * --SUM(DEFECTOS) DEFECTO, SUM(MUESTRA) MUESTRA 
	FROM [PPMS_PEARL].DBO.[ORDEN_LIBERADA] -- WHERE  ORDEN = 48100  AND F_LIBERACION = '2022-01-24' 
	ORDER BY F_LIBERACION DESC 

	SELECT * FROM [PPMS_PEARL].[dbo].[QC] WHERE Order_No = '48100' -- ID IN (303022)

	SELECT * FROM [PPMS_PEARL].[dbo].[DEFECTOS] WHERE Orden = 50011 -- ID IN (303022)
	
	SELECT * FROM [BD_GENERAL].[dbo].USUARIO_PEARL 

	SELECT * FROM [PPMS_PEARL].[dbo].[QC] WHERE Order_No = '50011' -- ID IN (303022)

	SELECT * --COUNT(ID) AS DEFECTOS
	FROM [PPMS_PEARL].[dbo].rechazos 
	WHERE orden IN (	SELECT ORDEN
						FROM [PPMS_PEARL].DBO.[ORDEN_LIBERADA]  
						WHERE K_TIPO_ORDEN_LIBERADA = 1 --ORDEN = 50011
						AND MESA = 'Table 79'
						--AND F_LIBERACION = '2022-01-24'
					)

	SELECT * 
	FROM [PPMS_PEARL].DBO.[ORDEN_LIBERADA]  
	WHERE  K_TIPO_ORDEN_LIBERADA = 1 --#1 NORMAL #2 FICTICIA --oRDEN = 39330 
	--AND F_LIBERACION >= '2022-01-01'
	--AND F_LIBERACION <= '2022-01-25'
	--AND MESA = 'Table 28'
	ORDER BY F_LIBERACION DESC

	SELECT	MESA, 
			SUM(MUESTRA), 
			SUM(DEFECTOS),
			( CASE WHEN SUM(MUESTRA) > 0 THEN CONVERT(INT, (CONVERT(DECIMAL(13,2), SUM(DEFECTOS)) / CONVERT(DECIMAL(13,2), SUM(MUESTRA)) * 1000000) )
				ELSE 0 END ) AS 'TOTAL_PPMS'
	FROM [PPMS_PEARL].[dbo].[ORDEN_LIBERADA] (NOLOCK)
	WHERE F_LIBERACION >= @PP_F_INICIAL
	AND F_LIBERACION <= @PP_F_FIN
	--AND DEFECTOS > 0
	AND MESA = 'Table 28'

	SELECT * FROM DATA_02.dbo.pearl_log WHERE jobno = '48100' -- screen_opt = 'RECHAZOS'

	-- logica para liberar orden

SELECT		ccjoblin_sql.item_no, SUM(CONVERT(int,(OriginalQty * CUBE_QTY_PER))) as muestra,
(select top 1 cus_item_no from DATA_02.dbo.cccusitm_sql where cccusitm_sql.item_no = ccjoblin_sql.Item_No
			order by versionno desc) AS noparte
FROM DATA_02.dbo.ccjoblin_sql  (NOLOCK)
inner join DATA_02.dbo.imitmidx_sql on ccjoblin_sql.item_no = imitmidx_sql.item_no
WHERE	ccjoblin_sql.jobno = '48665'  
group by ccjoblin_sql.item_no order by item_no

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

SELECT * FROM	DATA_02.dbo.ccjoblin_sql WHERE	jobno in ('48100') --ORDER BY item_no

SELECT item_no, CUBE_QTY_PER FROM DATA_02.dbo.imitmidx_sql (NOLOCK) 
WHERE item_no IN ( SELECT DISTINCT item_no 
					FROM DATA_02.dbo.ccjoblin_sql (NOLOCK) 
					WHERE	ccjoblin_sql.jobno = '48100') ORDER BY item_no



