-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[PPMS_PEARL]
-- // MODULO:			QC RECHAZOS
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	01/DIC/2021
-- //////////////////////////////////////////////////////////////  

USE [PPMS_PEARL]
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
--	USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_ENCABEZADO_LIBERAR_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_ENCABEZADO_LIBERAR_ORDEN]
GO

/*
 EXEC	[dbo].[PG_ENCABEZADO_LIBERAR_ORDEN] 0,0,  '52429', ''		
 EXEC	[dbo].[PG_ENCABEZADO_LIBERAR_ORDEN] 0,0,  '47834'		
 EXEC	[dbo].[PG_ENCABEZADO_LIBERAR_ORDEN] 0,0,  '48110', 'TEST SISTEMAS'	
 EXEC	[dbo].[PG_ENCABEZADO_LIBERAR_ORDEN] 0,0,  '50011', ''	
*/

CREATE PROCEDURE [dbo].[PG_ENCABEZADO_LIBERAR_ORDEN]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_ORDEN							VARCHAR(50),
	@PP_INSPECTOR_CALIDAD				VARCHAR(255)

AS	
	
	-- /////////SE OBTIENE LA INFORMACION DE LA ORDEN///////////////////////////////////////
	SELECT	 [jobno]
			-- ===========================
			,( CASE WHEN [status] = 'C' THEN 'Cerrada'
					ELSE 'Abierta' END) AS [status]
			-- ===========================
			,CONCAT('F', [colour])	AS [colour]
			,[colourdesc]
			,[machine]
			,[datecreated]
			,[dateplanned]
			,[datecompleted]
			,[printedflag]
			,[instruct1]
			,[instruct2]
			,[netsqm]
			,[standardsqm]
			,[actualsqm]
			,[targetutil]
			,[customer]
			,[patterns]
			,[plannedshift]
			,[plannedseq]
			,[startedflag]
			,[comments]
			,[lotno]
			,[folio]
			,[PROGRAM_MODEL_RMA]
			-- ===========================
			,(CASE WHEN F_LIBERACION IS NULL THEN CONVERT(VARCHAR, GETDATE() ,120) --CONVERT(DATE, GETDATE())
					ELSE CONVERT(VARCHAR, F_ALTA ,120) END ) AS F_LIBERACION
			-- ===========================
			,(CASE WHEN JEFE_GRUPO IS NULL THEN ''
					ELSE JEFE_GRUPO END ) AS JEFE_GRUPO
			-- ===========================
			,(CASE WHEN INSPECTOR_CALIDAD IS NULL THEN @PP_INSPECTOR_CALIDAD
					ELSE INSPECTOR_CALIDAD END ) AS INSPECTOR_CALIDAD
			-- ===========================
  FROM	[DATA_02].[dbo].[ccjobhdr_sql] (NOLOCK)
  LEFT JOIN [PPMS_PEARL].DBO.[ORDEN_LIBERADA] (NOLOCK) ON [jobno] = ORDEN
  WHERE	[jobno] = @PP_ORDEN

	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
--	USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DETALLE_LIBERAR_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DETALLE_LIBERAR_ORDEN]
GO

/*
 EXEC	[dbo].[PG_ENCABEZADO_LIBERAR_ORDEN] 0,0,  '45200'	
 EXEC	[dbo].[PG_DETALLE_LIBERAR_ORDEN] 0,0,  '45200'		
 EXEC	[dbo].[PG_DETALLE_LIBERAR_ORDEN] 0,0,  '48100'		
 EXEC	[dbo].[PG_DETALLE_LIBERAR_ORDEN] 0,0,  '48110'		
 EXEC	[dbo].[PG_DETALLE_LIBERAR_ORDEN] 0,0,  '43929'		
*/

CREATE PROCEDURE [dbo].[PG_DETALLE_LIBERAR_ORDEN]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_ORDEN							VARCHAR(50)
AS	
	
	-- /////////SE OBTIENEN LOS NUMEROS DE PARTES CON TOTAL DE PATRONES PROGRAMADOS///////////////////////////////////////
	SELECT	LTRIM(RTRIM(ccjoblin_sql.item_no))				AS	ITEM_NO, 
			LTRIM(RTRIM(cccusitm_sql.cus_item_no))			AS	CUS_ITEM_NO,
			SUM(CONVERT(INT, (OriginalQty * imitmidx_sql.CUBE_QTY_PER)))	AS	MUESTRA,
			(	SELECT COUNT(ID) 
				FROM [PPMS_PEARL].[dbo].Rechazos (NOLOCK) 
				WHERE ORDEN = @PP_ORDEN
				AND noparte = LTRIM(RTRIM(cccusitm_sql.cus_item_no)))	AS DEFECTO
	FROM DATA_02.DBO.ccjoblin_sql  (NOLOCK)
	-- ===========================
	INNER JOIN DATA_02.dbo.imitmidx_sql (NOLOCK) ON ccjoblin_sql.item_no = imitmidx_sql.item_no
	INNER JOIN	DATA_02.DBO.cccusitm_sql (NOLOCK) ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
	AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
	AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
													FROM	DATA_02.DBO.cccusitm_sql (NOLOCK)
													WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
													AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)
	-- ===========================
	WHERE LTRIM(RTRIM(ccjoblin_sql.jobno)) = @PP_ORDEN
	-- ===========================
	GROUP BY LTRIM(RTRIM(ccjoblin_sql.item_no)), LTRIM(RTRIM(cccusitm_sql.cus_item_no))
	ORDER BY CUS_ITEM_NO
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
--	USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DETALLE_DEFECTO_LIBERAR_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DETALLE_DEFECTO_LIBERAR_ORDEN]
GO

/*	
 EXEC	[dbo].[PG_DETALLE_DEFECTO_LIBERAR_ORDEN] 0,0,  '48100', '201025A' 
 EXEC	[dbo].[PG_DETALLE_DEFECTO_LIBERAR_ORDEN] 0,0,  '48100', '201024A'
*/

CREATE PROCEDURE [dbo].[PG_DETALLE_DEFECTO_LIBERAR_ORDEN]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_ORDEN							VARCHAR(50),
	@PP_NO_PARTE_CLIENTE				VARCHAR(50)
AS	
	
	-- /////////SE OBTIENEN LOS DEFECTOS POR NUMERO DE PARTE EN LA ORDEN///////////////////////////////////////
	SELECT	tipodef		AS TIPO_DEFECTO, 
			CLAVE		AS CLAVE_DEFECTO,  
			inspprod	AS INICIAL_PRD,  
			COUNT(ID) AS TOTAL_DEFECTO
	FROM [PPMS_PEARL].[dbo].Rechazos (NOLOCK)
	INNER JOIN [PPMS_PEARL].[dbo].DEF (NOLOCK) ON clave = Rechazos.defecto
	WHERE ORDEN = @PP_ORDEN
	AND noparte = @PP_NO_PARTE_CLIENTE
	GROUP BY tipodef, CLAVE, inspprod
	ORDER BY tipodef, CLAVE
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
