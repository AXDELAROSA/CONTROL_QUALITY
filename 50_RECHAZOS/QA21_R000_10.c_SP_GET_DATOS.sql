-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[PPMS_PEARL]
-- // MODULO:			RECHAZOS
-- // OPERACION:		GET DATOS
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	30/NOVIEMBRE/2021
-- //////////////////////////////////////////////////////////////  

USE [PPMS_PEARL]
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
--	USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_TOTAL_MUESTRA_DEFECTO_X_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_TOTAL_MUESTRA_DEFECTO_X_ORDEN]
GO

/*
 EXEC	[dbo].[PG_GET_TOTAL_MUESTRA_DEFECTO_X_ORDEN] 0,0,  '45200'		
 EXEC	[dbo].[PG_GET_TOTAL_MUESTRA_DEFECTO_X_ORDEN] 0,0,  '48100'		
 EXEC	[dbo].[PG_GET_TOTAL_MUESTRA_DEFECTO_X_ORDEN] 0,0,  '48110'		
 EXEC	[dbo].[PG_GET_TOTAL_MUESTRA_DEFECTO_X_ORDEN] 0,0,  '43929'		
*/

CREATE PROCEDURE [dbo].[PG_GET_TOTAL_MUESTRA_DEFECTO_X_ORDEN]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_ORDEN							VARCHAR(50)
AS	
		
	-- SE OBTIENE DE LA ORDEN EL TOTAL DE MUESTRA QUE SE OBTIENE DE LA CANTIDAD DE KIT PROGRAMADO X NUMERO DE PATRONES
	DECLARE @VP_TOTAL_MUESTRA INT = 0
	SELECT	@VP_TOTAL_MUESTRA = SUM(CONVERT(INT, (OriginalQty * CUBE_QTY_PER)))
	FROM DATA_02.DBO.ccjoblin_sql  (NOLOCK)
	INNER JOIN DATA_02.DBO.imitmidx_sql (NOLOCK) ON ccjoblin_sql.item_no = imitmidx_sql.item_no
	WHERE	ccjoblin_sql.jobno = @PP_ORDEN

	IF @VP_TOTAL_MUESTRA IS NULL
		SET @VP_TOTAL_MUESTRA = 0

	-- SE OBTIENE EL TOTAL DE DEFECTOS DE LA ORDEN
	DECLARE @VP_TOTAL_DEFECTO INT = 0
	SELECT @VP_TOTAL_DEFECTO = COUNT(id)
	FROM [PPMS_PEARL].[dbo].[RECHAZOS] (NOLOCK)
	WHERE Orden = @PP_ORDEN

	IF @VP_TOTAL_DEFECTO IS NULL
		SET @VP_TOTAL_DEFECTO = 0

	-- SE OBTIENEN LOS PPMS DE LA ORDEN
	DECLARE @VP_PPMS_ORDEN INT = 0

	IF @VP_TOTAL_MUESTRA > 0
		SET @VP_PPMS_ORDEN = CONVERT(INT, (CONVERT(DECIMAL(13,2), @VP_TOTAL_DEFECTO) / CONVERT(DECIMAL(13,2), @VP_TOTAL_MUESTRA) * 1000000) )

	IF @VP_PPMS_ORDEN IS NULL
		SET @VP_PPMS_ORDEN = 0

	-- SE MUESTRA EL TOTAL DE MUESTRA, DEFECTOS Y PPM'S
	SELECT	@VP_TOTAL_MUESTRA	AS TOTAL_MUESTRA,
			@VP_TOTAL_DEFECTO	AS TOTAL_DEFECTO,
			@VP_PPMS_ORDEN		AS TOTAL_PPMS

	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / COMBO 
-- //////////////////////////////////////////////////////////////
--	USE [PPMS_PEARL]

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_CUS_PART_NO_X_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_CUS_PART_NO_X_ORDEN]
GO

/*
 EXEC	[dbo].[PG_CB_CUS_PART_NO_X_ORDEN] 0,0,  '48100'		
*/

CREATE PROCEDURE [dbo].[PG_CB_CUS_PART_NO_X_ORDEN]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_ORDEN							VARCHAR(50)
AS	
	
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50))

	INSERT INTO @VP_TA_CATALOGO
	SELECT	DISTINCT
			1, 
			LTRIM(RTRIM(cccusitm_sql.cus_item_no))	AS CUS_ITEM_NO			
	FROM DATA_02.DBO.ccjoblin_sql  (NOLOCK)
	-- ===========================
	INNER JOIN	DATA_02.DBO.cccusitm_sql (NOLOCK) ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
	AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
	AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
													FROM	DATA_02.DBO.cccusitm_sql (NOLOCK)
													WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
													AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)
	-- ===========================
	WHERE LTRIM(RTRIM(ccjoblin_sql.jobno)) = @PP_ORDEN

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
				TA_D_CATALOGO	AS D_COMBOBOX 
		FROM	@VP_TA_CATALOGO
		ORDER BY  TA_D_CATALOGO 
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
--	USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_LOTE_CORTADO_X_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_LOTE_CORTADO_X_ORDEN]
GO

/*
 EXEC	[dbo].[PG_GET_LOTE_CORTADO_X_ORDEN] 0,0,  '40580'		
 EXEC	[dbo].[PG_GET_LOTE_CORTADO_X_ORDEN] 0,0,  '48100'		
*/

CREATE PROCEDURE [dbo].[PG_GET_LOTE_CORTADO_X_ORDEN]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_ORDEN							VARCHAR(50)
AS	
		
	SELECT	LTRIM(RTRIM(LOTNO)) AS LOTE,
			COUNT(COLKEY) AS TOTAL_PIEL,
			CONVERT(DECIMAL(13,2), SUM(hidesqm)) AS TOTAL_SQF
	FROM DATA_02.DBO.cccuthst_sql (NOLOCK)
	-- ===========================
	WHERE LTRIM(RTRIM(jobno)) = @PP_ORDEN
	GROUP BY lotno
	ORDER BY SUM(hidesqm) DESC
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
--	USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_ORDEN_LIBERADA_X_CALIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_ORDEN_LIBERADA_X_CALIDAD]
GO

/*
 EXEC	[dbo].[PG_GET_ORDEN_LIBERADA_X_CALIDAD] 0,0,  '40580'			
 EXEC	[dbo].[PG_GET_ORDEN_LIBERADA_X_CALIDAD] 0,0,  '48100'			
*/

CREATE PROCEDURE [dbo].[PG_GET_ORDEN_LIBERADA_X_CALIDAD]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_ORDEN							VARCHAR(50)
AS	
	
	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	--///RN VALIDADES///////////////////
	IF @VP_MENSAJE=''
		EXECUTE [DATA_02].[dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_ORDEN,
																		@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
		
	IF @VP_MENSAJE=''
		EXECUTE [DATA_02].[dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_ESTATUS]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_ORDEN,
																		@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	--///SE VALIDA QUE LA ORDEN NO SE ENCUENTRE LIBERADA///////////////////
	IF @VP_MENSAJE=''
		BEGIN
			DECLARE @VP_N_ORDEN_LIBERADA INT = 0
			SELECT  @VP_N_ORDEN_LIBERADA = COUNT(ID) 
			FROM [PPMS_PEARL].[dbo].[QC] (NOLOCK)
			WHERE ORDER_NO = @PP_ORDEN
			
			IF @VP_N_ORDEN_LIBERADA IS NULL 
				SET @VP_N_ORDEN_LIBERADA = 0

			IF @VP_N_ORDEN_LIBERADA > 0
				SET @VP_MENSAJE = 'La orden ya fue liberada anteriormente.'
		END

	--///SE RETORNA UN MENSAJE SI ES VACIO LA ORDEN AUN NO HA SIDO LIBERADA O CERRADA///////////////////
	SELECT @VP_MENSAJE AS MENSAJE

	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
