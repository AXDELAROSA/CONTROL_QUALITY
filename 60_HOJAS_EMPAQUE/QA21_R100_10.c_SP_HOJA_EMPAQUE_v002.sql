-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			HOJA_EMPAQUE
-- // OPERATION:		SP'S
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210916
-- ////////////////////////////////////////////////////////////// 

USE	[DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- //////		CONTENIDO DEL SP
--	[PG_LI_HOJA_EMPAQUE]
--	[PG_LI_HOJA_EMPAQUE_PROCESO]
--	[PG_SK_HOJA_EMPAQUE]
--	[PG_SK_HOJA_EMPAQUE_PROCESO]
--	[PG_IN_HOJA_EMPAQUE]
--	[PG_IN_HOJA_EMPAQUE_PROCESO]
--	[PG_UP_HOJA_EMPAQUE]
--	[PG_DL_HOJA_EMPAQUE]
-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE] 0,139,'( TODOS )','( TODOS )'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE] 0,139,'IRVI02','JTM'
CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	--@PP_BUSCAR						VARCHAR(25),
	--@PP_K_HOJA_EMPAQUE_STATUS				INT,
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25)
	--@PP_F_INIT						DATE,
	--@PP_F_FINISH					DATE
AS
	SET @PP_MODELNO = LTRIM(RTRIM(LEFT(@PP_MODELNO,3)))

	SELECT	DISTINCT (ITEM_P)
			,CUS_NO
			,MODELNO
			,VERSIONNO
			,LTRIM(RTRIM(D_ITEM_NO))	AS D_ITEM_NO
			,REVISION_HOJA_EMPAQUE
			,CAJA_HOJA_EMPAQUE
			,(CASE
					WHEN	HOJA_EMPAQUE.VERSIONNO	= ISNULL(	(	SELECT	DISTINCT
																			CCVERHDR_SQL.VERSIONNO
																	FROM	CCVERHDR_SQL		(NOLOCK)
																	WHERE	CCVERHDR_SQL.STATUS			= 'L'
																	AND		CCVERHDR_SQL.SPECSTATUS		= 'U'
																	AND		CCVERHDR_SQL.CUS_NO			=	[HOJA_EMPAQUE].CUS_NO
																	AND		CCVERHDR_SQL.MODELNO		=	[HOJA_EMPAQUE].MODELNO
																	--ORDER	BY CUS_NO	,MODELNO	,VERSIONNO	
																	),0)	THEN 1
					ELSE	0
			END)	AS L_LIVE
	FROM	[HOJA_EMPAQUE]
	WHERE	( @PP_CUS_NO		= '( TODOS )'	OR	CUS_NO		= @PP_CUS_NO  )
	AND		( @PP_MODELNO		= '( T'			OR	MODELNO		= @PP_MODELNO )
	ORDER	BY CUS_NO	,MODELNO	,VERSIONNO DESC
--	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA EL COLOR Y NÚMERO DE PARTE CLIENTE DEL P SELECCIONADO.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE_COLORES]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES] 0,139, 'DAIM05' , 'WDK' , '8' , 'PL2ARLH'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSSC20'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2'
CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25),
	@PP_VERSIONNO					INT,
	@PP_ITEM_P						VARCHAR(25)
AS
	SELECT	COLOR, 
			LTRIM(RTRIM(CUSTOMER_ITEM_NO))	AS CUSTOMER_ITEM_NO
	FROM	[HOJA_EMPAQUE]
	WHERE	HOJA_EMPAQUE.ITEM_P			= @PP_ITEM_P
	AND		HOJA_EMPAQUE.CUS_NO			= @PP_CUS_NO	
	AND		HOJA_EMPAQUE.MODELNO		= @PP_MODELNO	
	AND		HOJA_EMPAQUE.VERSIONNO		= @PP_VERSIONNO
	AND		HOJA_EMPAQUE.L_BORRADO	<> 1
	ORDER	BY COLOR
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA EL DETALLE DE LOS SPECIAL_PROCESS POR KIT
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE_PROCESO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO] 0,139, 'DAIM05' , 'WDK' , '8' , 'PL2ARLH'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSSC20'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2'
CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25),
	@PP_VERSIONNO					INT,
	@PP_ITEM_P						VARCHAR(25)
AS
	--SELECT	'C:\Users\alejandrod\Desktop\1.JPEG' AS RUTA_AV_HOJA_EMPAQUE,
	--		[HOJA_EMPAQUE_PROCESO].* 
	--FROM	[HOJA_EMPAQUE_PROCESO]		(NOLOCK)
	--WHERE	K_HOJA_EMPAQUE	=	@PP_K_HOJA_EMPAQUE

	SELECT	HOJA_EMPAQUE_PROCESO.*,
			(CASE
				WHEN	D_HOJA_EMPAQUE_PROCESO <> ''	THEN	D_HOJA_EMPAQUE_PROCESO
				WHEN	D_HOJA_EMPAQUE_PROCESO =  ''	THEN	D_HOJA_EMPAQUE_PROCESO_SIMBOLO
			END)										AS	D_HOJA_EMPAQUE_PROCESO,
			RUTA_HOJA_EMPAQUE_PROCESO_SIMBOLO			AS RUTA_AV_HOJA_EMPAQUE
	FROM	[HOJA_EMPAQUE_PROCESO]			 (NOLOCK)
	LEFT JOIN	HOJA_EMPAQUE_PROCESO_SIMBOLO (NOLOCK) ON HOJA_EMPAQUE_PROCESO_SIMBOLO.K_HOJA_EMPAQUE_PROCESO_SIMBOLO	= HOJA_EMPAQUE_PROCESO.K_HOJA_EMPAQUE_PROCESO_SIMBOLO
	WHERE	CUS_NO		= @PP_CUS_NO
	AND		MODELNO		= @PP_MODELNO		
	AND		VERSIONNO	= @PP_VERSIONNO	
	AND		ITEM_P		= @PP_ITEM_P
	ORDER	BY K_PROCESO
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_HOJA_EMPAQUE]
GO
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE] 0,139, 'DAIM05' , 'WDK' , '8' , 'PL2ARLH'
CREATE PROCEDURE [dbo].[PG_SK_HOJA_EMPAQUE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25),
	@PP_VERSIONNO					INT,
	@PP_ITEM_P						VARCHAR(25)
AS
	-- ///////////////////////////////////////////			
	DECLARE  @K_ARCUSFIL			INT
			,@K_ARCUSFIL_PROGRAM	INT
			,@CB_ARCUSFIL_PROGRAM	VARCHAR(250)

	SELECT	@CB_ARCUSFIL_PROGRAM	= RTRIM(LTRIM(PROD_CAT_DESC))
	FROM	ARCUSFIL_PROGRAM_MODEL	(NOLOCK)
	WHERE	S_ARCUSFIL_PROGRAM_MODEL	= @PP_MODELNO

	SELECT		TOP (1)
				-- =============================	 
				S_HOJA_EMPAQUE_STATUS	, D_HOJA_EMPAQUE_STATUS	,
				----S_TIPO_HOJA_EMPAQUE		, D_TIPO_HOJA_EMPAQUE	,
				@CB_ARCUSFIL_PROGRAM	AS PROGRAMA,
				CUS_NO			, --PROGRAMA		,
				MODELNO,
				VERSIONNO,
				-- =============================
				--ISNULL(REVISION_HOJA_EMPAQUE,'') AS CAJA_HOJA_EMPAQUE,
				ISNULL(REVISION_HOJA_EMPAQUE,0) AS REVISION_HOJA_EMPAQUE,
				K_HOJA_EMPAQUE_CAPA_DIVISION	AS DIVISION_CAPAS,
				HOJA_EMPAQUE.*
				-- =============================	
	FROM		HOJA_EMPAQUE		(NOLOCK) 
	INNER JOIN 	HOJA_EMPAQUE_STATUS		(NOLOCK) ON HOJA_EMPAQUE_STATUS.K_HOJA_EMPAQUE_STATUS	= HOJA_EMPAQUE.K_HOJA_EMPAQUE_STATUS
				-- =============================
	WHERE		HOJA_EMPAQUE.ITEM_P			= @PP_ITEM_P
	AND			HOJA_EMPAQUE.CUS_NO			= @PP_CUS_NO	
	AND			HOJA_EMPAQUE.MODELNO		= @PP_MODELNO	
	AND			HOJA_EMPAQUE.VERSIONNO		= @PP_VERSIONNO
	AND			HOJA_EMPAQUE.L_BORRADO	<> 1
	-- ////////////////////////////////////////////////////////////////////
GO


------ //////////////////////////////////////////////////////////////
------ // STORED PROCEDURE ---> SELECT / FICHA
------ //////////////////////////////////////////////////////////////
----IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_HOJA_EMPAQUE_PROCESO]') AND type in (N'P', N'PC'))
----	DROP PROCEDURE [dbo].[PG_SK_HOJA_EMPAQUE_PROCESO]
----GO
------		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_PROCESO] 0,139,7
----CREATE PROCEDURE [dbo].[PG_SK_HOJA_EMPAQUE_PROCESO]
----	@PP_K_SISTEMA_EXE				INT,
----	@PP_K_USUARIO_ACCION			INT,
----	-- ===========================
----	@PP_K_HOJA_EMPAQUE				INT
----AS
----	-- ///////////////////////////////////////////

----		SELECT		TOP (100)
----					HOJA_EMPAQUE_PROCESO.*
----		FROM		HOJA_EMPAQUE_PROCESO					(NOLOCK)
----		WHERE		HOJA_EMPAQUE_PROCESO.K_HOJA_EMPAQUE	= @PP_K_HOJA_EMPAQUE
----		ORDER BY	K_HOJA_EMPAQUE_PROCESO

----	-- ////////////////////////////////////////////////////////////////////
----GO


---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> INSERT / FICHA
---- //////////////////////////////////////////////////////////////
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_IN_HOJA_EMPAQUE]
--GO
----		 EXECUTE [dbo].[PG_IN_HOJA_EMPAQUE] 1,139,  '19' , '' , '' , 'WKL' , '0009' , 'IWKL0042CPRDX9' , '65327M11' , '0.6400' , '8' , '-1'
--CREATE PROCEDURE [dbo].[PG_IN_HOJA_EMPAQUE]
--	@PP_K_SISTEMA_EXE				INT,
--	@PP_K_USUARIO_ACCION			INT,
--	-- ===========================
--	--@PP_K_HOJA_EMPAQUE_STATUS		INT,
--	-- ============================
--	----@PP_K_QUOTE_TRIM_COLOR				INT,
--	----@PP_K_QUOTE_KIT						INT,
--	-- ============================
--	@PP_CUS_NO							VARCHAR(6),
--	----@PP_PROGRAM							VARCHAR(50),
--	@PP_MODELNO							VARCHAR(3),
--	@PP_VERSIONNO						VARCHAR(5),
--	-- ============================
--	@PP_ITEM_NO							VARCHAR(50),
--	@PP_CUSTOMER_ITEM_NO				VARCHAR(50),
--	@PP_D_ITEM_NO						VARCHAR(500),
--	-- ============================
--	--@PP_CAJA_HOJA_EMPAQUE				VARCHAR(150),
--	--@PP_DIBUJO_HOJA_EMPAQUE			VARCHAR(150),
--	--@PP_REVISION_HOJA_EMPAQUE			INT,
--	-- ============================
--	--@PP_RUTA_AYUDA_VISUAL_HEADER		VARCHAR(500),
--	@PP_K_TIPO_CAMBIO_KIT				INT,
--	@PP_K_QUOTE_TRIM_COLOR				INT,
--	@PP_K_QUOTE_KIT						INT
--	-- ============================
--	--@PP_ARRAY_O_HOJA_EMPAQUE_PROCESO	NVARCHAR(MAX),
--	--@PP_ARRAY_D_HOJA_EMPAQUE_PROCESO	NVARCHAR(MAX),
--	--@PP_ARRAY_L_AYUDA_VISUAL			NVARCHAR(MAX),
--	--@PP_ARRAY_K_AV_HOJA_EMPAQUE		NVARCHAR(MAX)
--	-- ============================
--AS			
--DECLARE  @VP_MENSAJE						NVARCHAR(MAX)
--		,@VP_K_HOJA_EMPAQUE			INT = 0
--		,@VP_K_HOJA_EMPAQUE_PREV		INT	= 0
--		,@VP_VERSIONNO_PREV					INT	= 0
--		--============================================
--		----,@VP_EXISTE						INT
--		,@VP_CAJA_HOJA_EMPAQUE			VARCHAR(150)
--		,@VP_DIBUJO_HOJA_EMPAQUE		VARCHAR(150)
--		,@VP_REVISION_HOJA_EMPAQUE		INT
--		,@VP_RUTA_AYUDA_VISUAL_HEADER	VARCHAR(500)
--		--============================================
--	--SET @PP_MODELNO = LTRIM(RTRIM(LEFT(@PP_MODELNO,3)))
----BEGIN TRANSACTION 
----BEGIN TRY
--	IF @PP_K_TIPO_CAMBIO_KIT	= 0		--AX:20210920	//	#0: SIN CAMBIOS,	#1: LONGITUD,	#2: AGREGADO/ELIMINADO PROCESOS ESPECIALES,	#3: CAMBIO PROCESOS ESPECIALES
--	BEGIN
--		--============================================
--		--	SE VERIFICA SI EXISTE INFORMACIÓN DEL MODELO EN UNA VERSIÓN PREVIA.
--		SELECT	TOP (1)
--				----@VP_EXISTE					= COUNT(K_HOJA_EMPAQUE)
--				@VP_K_HOJA_EMPAQUE_PREV	= K_HOJA_EMPAQUE		,
--				@VP_VERSIONNO_PREV				= VERSIONNO					,
--				--============================================================
--				@VP_CAJA_HOJA_EMPAQUE			= CAJA_HOJA_EMPAQUE			,
--				@VP_DIBUJO_HOJA_EMPAQUE			= DIBUJO_HOJA_EMPAQUE		,
--				@VP_REVISION_HOJA_EMPAQUE		= REVISION_HOJA_EMPAQUE		,
--				@VP_RUTA_AYUDA_VISUAL_HEADER	= RUTA_AYUDA_VISUAL_HEADER	
--				--* 
--		FROM	[HOJA_EMPAQUE]		(NOLOCK)
--		WHERE	CUS_NO				= @PP_CUS_NO
--		AND		MODELNO				= @PP_MODELNO
--		AND		ITEM_NO				= @PP_ITEM_NO			
--		AND		CUSTOMER_ITEM_NO	= @PP_CUSTOMER_ITEM_NO
--		ORDER	BY VERSIONNO
--	END
--	ELSE
--	BEGIN
--		SET @VP_K_HOJA_EMPAQUE_PREV	= 0
--		SET @VP_VERSIONNO_PREV				= 0
--		SET	@VP_CAJA_HOJA_EMPAQUE			= ''
--		SET	@VP_DIBUJO_HOJA_EMPAQUE			= ''
--		SET	@VP_REVISION_HOJA_EMPAQUE		= ''
--		SET	@VP_RUTA_AYUDA_VISUAL_HEADER	= ''
--	END
	
--	----IF	@VP_EXISTE	> 0
--	----BEGIN
--	----	SET	@PP_CAJA_HOJA_EMPAQUE			= @VP_CAJA_HOJA_EMPAQUE
--	----	SET	@PP_DIBUJO_HOJA_EMPAQUE			= @VP_DIBUJO_HOJA_EMPAQUE
--	----	SET	@PP_REVISION_HOJA_EMPAQUE		= @VP_REVISION_HOJA_EMPAQUE
--	----	SET	@PP_RUTA_AYUDA_VISUAL_HEADER	= @VP_RUTA_AYUDA_VISUAL_HEADER
--	----END
--	--============================================================================
--	--======================================INSERTAR EL HOJA_EMPAQUE
--	--============================================================================
--		INSERT INTO HOJA_EMPAQUE
--			(	-- ============================
--				[K_HOJA_EMPAQUE_STATUS]		,
--				-- ============================
--				[CUS_NO]					,	----[PROGRAM]				,
--				[MODELNO]					,	[VERSIONNO]				,
--				-- ============================
--				[ITEM_NO]					,	[CUSTOMER_ITEM_NO]		,
--				[D_ITEM_NO]					,
--				-- ============================
--				[CAJA_HOJA_EMPAQUE]			,	
--				[DIBUJO_HOJA_EMPAQUE]		,
--				[REVISION_HOJA_EMPAQUE]		,
--				-- ============================
--				[RUTA_AYUDA_VISUAL_HEADER]	,
--				[K_TIPO_CAMBIO_KIT]			,
--				-- ============================
--				[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
--				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
--		VALUES	
--			(	1,	-- @PP_K_HOJA_EMPAQUE_STATUS			,
--				-- ============================				
--				@PP_CUS_NO					,	----@PP_PROGRAM					,
--				@PP_MODELNO					,	@PP_VERSIONNO				,
--				-- ============================
--				@PP_ITEM_NO					,	@PP_CUSTOMER_ITEM_NO		,
--				@PP_D_ITEM_NO				,
--				-- ============================
--				@VP_CAJA_HOJA_EMPAQUE		,--@PP_CAJA_HOJA_EMPAQUE		,	
--				@VP_DIBUJO_HOJA_EMPAQUE		,--@PP_DIBUJO_HOJA_EMPAQUE		,
--				@VP_REVISION_HOJA_EMPAQUE	,--@PP_REVISION_HOJA_EMPAQUE	,
--				-- ============================
--				@VP_RUTA_AYUDA_VISUAL_HEADER,--@PP_RUTA_AYUDA_VISUAL_HEADER,
--				@PP_K_TIPO_CAMBIO_KIT,	--AX:20210920	//	#0: SIN CAMBIOS,	#1: LONGITUD,	#2: AGREGADO/ELIMINADO PROCESOS ESPECIALES,	#3: CAMBIO PROCESOS ESPECIALES
--				-- ============================
--				@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
--				0, NULL, NULL  )

--		IF @@ROWCOUNT = 0
--		BEGIN
--			SET @VP_MENSAJE='No se generó. [HDR#'+CONVERT(VARCHAR(10),@VP_K_HOJA_EMPAQUE)+']'
--			RAISERROR (@VP_MENSAJE, 16, 1 ) 
--		END
--		ELSE
--		BEGIN
--			SELECT @VP_K_HOJA_EMPAQUE	= SCOPE_IDENTITY()

--			IF	( @VP_K_HOJA_EMPAQUE	= 0 OR @VP_K_HOJA_EMPAQUE IS NULL )
--			BEGIN
--				RAISERROR ('Error en la asignación de identidad.[HDR]', 16, 1 ) 
--			END
--		END

--		EXECUTE [PG_IN_HOJA_EMPAQUE_PROCESO]	@PP_K_SISTEMA_EXE	,	@PP_K_USUARIO_ACCION,
--												-- ============================
--												@PP_CUS_NO						,	@PP_MODELNO					,
--												@PP_VERSIONNO					,	
--												-- ============================
--												@PP_ITEM_NO						,	@PP_CUSTOMER_ITEM_NO		,
--												-- ============================
--												@PP_K_TIPO_CAMBIO_KIT			,	@VP_K_HOJA_EMPAQUE	,
--												@VP_K_HOJA_EMPAQUE_PREV	,	@VP_VERSIONNO_PREV			,
--												-- ============================
--												@PP_K_QUOTE_TRIM_COLOR			,	@PP_K_QUOTE_KIT
---- /////////////////////////////////////////////////////////////////////
----COMMIT TRANSACTION 
----END TRY

----BEGIN CATCH
----	/* Ocurrió un error, deshacemos los cambios*/ 
----	ROLLBACK TRANSACTION
----	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
----	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
----	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
----END CATCH	
----	-- /////////////////////////////////////////////////////////////////////	
----	IF @VP_MENSAJE<>''
----	BEGIN
----		SET		@VP_MENSAJE = 'No es posible [Insertar] la [Orden]: ' + @VP_MENSAJE 
----	END
----	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_HOJA_EMPAQUE AS CLAVE
--	-- //////////////////////////////////////////////////////////////
--GO


---- //////////////////////////////////////////////////////////////
---- // PARA INSERTAR LOS DETALLES DE LA ORDEN
---- // STORED PROCEDURE ---> INSERT / FICHA
---- //////////////////////////////////////////////////////////////
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_HOJA_EMPAQUE_PROCESO]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_IN_HOJA_EMPAQUE_PROCESO]
--GO
--CREATE PROCEDURE [dbo].[PG_IN_HOJA_EMPAQUE_PROCESO]
--	@PP_K_SISTEMA_EXE			INT,
--	@PP_K_USUARIO_ACCION		INT,
--	-- ============================
--	@PP_CUS_NO						VARCHAR(6),
--	@PP_MODELNO						VARCHAR(3),
--	@PP_VERSIONNO					VARCHAR(5),
--	-- ============================
--	@PP_ITEM_NO						VARCHAR(50),
--	@PP_CUSTOMER_ITEM_NO			VARCHAR(50),
--	-- ============================
--	@PP_K_TIPO_CAMBIO_KIT			INT,
--	-- ============================
--	@PP_K_HOJA_EMPAQUE		INT,
--	@PP_K_HOJA_EMPAQUE_PREV	INT,
--	@PP_VERSIONNO_PREV				INT,
--	@PP_K_QUOTE_TRIM_COLOR			INT,
--	@PP_K_QUOTE_KIT					INT
--AS
--	DECLARE  @VP_MENSAJE					NVARCHAR(MAX) = ''
--			-- =====================
--			,@VP_CU_O_HOJA_EMPAQUE_PROCESO		INT	= 0
--			-- =====================
--			,@VP_CU_D_HOJA_EMPAQUE_PROCESO		VARCHAR(500)
--			,@VP_CU_L_AYUDA_VISUAL				VARCHAR(500)
--			,@VP_CU_K_AV_HOJA_EMPAQUE			INT	= 1
--			-- =====================
--			,@VP_CU_D_PROCESS					VARCHAR(500)
--			-- =====================
--			,@VP_O_REGISTROS					INT	= 0

--	IF @PP_K_HOJA_EMPAQUE_PREV = 0
--	BEGIN

--		DECLARE CU_CURSOR		CURSOR LOCAL FOR
--			SELECT	--*
--					DISTINCT QUOTE_PROCESS_SPECIAL_COST_CHECKS.K_PROCESS,
--					D_QUOTE_PROCESS_SPECIAL_COST,
--					1,
--					1,
--					D_PROCESS
--			FROM	COT19_Cotizaciones_V9999_R0.dbo.QUOTE_PROCESS_SPECIAL_COST_CHECKS
--			INNER JOIN	COT19_Cotizaciones_V9999_R0.dbo.QUOTE_PROCESS_SPECIAL_COST	ON QUOTE_PROCESS_SPECIAL_COST.K_QUOTE_TRIM_LEVEL	= QUOTE_PROCESS_SPECIAL_COST_CHECKS.K_QUOTE_TRIM_LEVEL
--			INNER JOIN	COT19_Cotizaciones_V9999_R0.dbo.PROCESS						ON PROCESS.K_PROCESS								= QUOTE_PROCESS_SPECIAL_COST_CHECKS.K_PROCESS
--			AND			QUOTE_PROCESS_SPECIAL_COST.K_PROCESS		= QUOTE_PROCESS_SPECIAL_COST_CHECKS.K_PROCESS
--			WHERE	QUOTE_PROCESS_SPECIAL_COST_CHECKS.K_QUOTE_TRIM_COLOR		= @PP_K_QUOTE_TRIM_COLOR
--			AND		QUOTE_PROCESS_SPECIAL_COST_CHECKS.K_QUOTE_KIT				= @PP_K_QUOTE_KIT
--			ORDER	BY D_PROCESS
--		OPEN CU_CURSOR
--		FETCH NEXT FROM CU_CURSOR INTO	@VP_CU_O_HOJA_EMPAQUE_PROCESO	,@VP_CU_D_HOJA_EMPAQUE_PROCESO	,@VP_CU_L_AYUDA_VISUAL	,@VP_CU_K_AV_HOJA_EMPAQUE	,@VP_CU_D_PROCESS
--			WHILE @@FETCH_STATUS = 0
--			BEGIN
--				SET	@VP_O_REGISTROS += 1
--				-----	====================================================================================================================
--				-----	/////////					SE INSERTALA INFORMACIÓN DE AQUELLOS KIT QUE NO CONTIENEN HOJA DE EMPAQUE.		20210915
--				INSERT INTO	[dbo].[HOJA_EMPAQUE_PROCESO] 
--				(		[K_HOJA_EMPAQUE]			,
--						-- ============================
--						[O_HOJA_EMPAQUE_PROCESO]		,
--						-- ============================
--						[D_HOJA_EMPAQUE_PROCESO]		,
--						[L_AYUDA_VISUAL]				,
--						[K_AV_HOJA_EMPAQUE]				,
--						-- ============================
--						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
--						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
--				VALUES	
--					(	@PP_K_HOJA_EMPAQUE		,
--						-- ============================
--						@VP_O_REGISTROS	,
--						-- ============================
--						@VP_CU_D_HOJA_EMPAQUE_PROCESO	,	
--						@VP_CU_L_AYUDA_VISUAL			,
--						@VP_CU_K_AV_HOJA_EMPAQUE		,
--						-- ============================
--						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
--						0, NULL, NULL  )
--				IF @@ROWCOUNT = 0
--				BEGIN
--					SET @VP_MENSAJE = '[HOJAS_EMPAQUE] No fue posible insertar el registro en la tabla: ' + LTRIM(RTRIM(@PP_CUSTOMER_ITEM_NO)) + ' // '+ CONVERT(VARCHAR(50),@PP_K_HOJA_EMPAQUE) +'... Informe a SISTEMAS.'
--					RAISERROR (@VP_MENSAJE, 16, 1 ) 				
--				END
--				--END
--			-----	====================================================================================================================
--				FETCH NEXT FROM CU_CURSOR INTO	@VP_CU_O_HOJA_EMPAQUE_PROCESO	,@VP_CU_D_HOJA_EMPAQUE_PROCESO	,@VP_CU_L_AYUDA_VISUAL	,@VP_CU_K_AV_HOJA_EMPAQUE	,@VP_CU_D_PROCESS
--			END
--		CLOSE		CU_CURSOR
--		DEALLOCATE	CU_CURSOR
--	-- ////////////////////////////////////////////////////////////////
--	END
--	ELSE
--	BEGIN
--		DECLARE CU_CURSOR		CURSOR LOCAL FOR
--			SELECT	--*
--					[O_HOJA_EMPAQUE_PROCESO],
--					-- =====================
--					[D_HOJA_EMPAQUE_PROCESO],
--					[L_AYUDA_VISUAL]		,
--					[K_AV_HOJA_EMPAQUE]		
--			FROM	[HOJA_EMPAQUE_PROCESO]		(NOLOCK)
--			WHERE	K_HOJA_EMPAQUE		= @PP_K_HOJA_EMPAQUE_PREV
--			ORDER	BY O_HOJA_EMPAQUE_PROCESO	ASC
--		OPEN CU_CURSOR
--		FETCH NEXT FROM CU_CURSOR INTO	@VP_CU_O_HOJA_EMPAQUE_PROCESO	,@VP_CU_D_HOJA_EMPAQUE_PROCESO	,@VP_CU_L_AYUDA_VISUAL	,@VP_CU_K_AV_HOJA_EMPAQUE
--			WHILE @@FETCH_STATUS = 0
--			BEGIN
--			-----	====================================================================================================================
--			-----	/////////					SE INSERTALA INFORMACIÓN DE AQUELLOS KIT QUE NO CONTIENEN HOJA DE EMPAQUE.		20210915

--				INSERT INTO	[dbo].[HOJA_EMPAQUE_PROCESO] 
--				(		[K_HOJA_EMPAQUE]			,
--						-- ============================
--						[O_HOJA_EMPAQUE_PROCESO]		,
--						-- ============================
--						[D_HOJA_EMPAQUE_PROCESO]		,
--						[L_AYUDA_VISUAL]				,
--						[K_AV_HOJA_EMPAQUE]				,
--						-- ============================
--						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
--						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
--				VALUES	
--					(	@PP_K_HOJA_EMPAQUE		,
--						-- ============================
--						@VP_CU_O_HOJA_EMPAQUE_PROCESO	,
--						-- ============================
--						@VP_CU_D_HOJA_EMPAQUE_PROCESO	,	
--						@VP_CU_L_AYUDA_VISUAL			,
--						@VP_CU_K_AV_HOJA_EMPAQUE		,
--						-- ============================
--						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
--						0, NULL, NULL  )
--				IF @@ROWCOUNT = 0
--				BEGIN
--					SET @VP_MENSAJE = '[HOJAS_EMPAQUE] No fue posible insertar el registro en la tabla: ' + LTRIM(RTRIM(@PP_CUSTOMER_ITEM_NO)) + ' // '+ CONVERT(VARCHAR(50),@PP_K_HOJA_EMPAQUE) +'... Informe a SISTEMAS.'
--					RAISERROR (@VP_MENSAJE, 16, 1 ) 				
--				END
--				--END
--			-----	====================================================================================================================
--				FETCH NEXT FROM CU_CURSOR INTO	@VP_CU_O_HOJA_EMPAQUE_PROCESO	,@VP_CU_D_HOJA_EMPAQUE_PROCESO	,@VP_CU_L_AYUDA_VISUAL	,@VP_CU_K_AV_HOJA_EMPAQUE			
--			END
--		CLOSE		CU_CURSOR
--		DEALLOCATE	CU_CURSOR
--	END
--	-- ////////////////////////////////////////////////////////////////
--	-- ///////////////////////////////////////////////////////////////
--GO


---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> UPDATE / FICHA
---- //////////////////////////////////////////////////////////////
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_UP_HOJA_EMPAQUE]
--GO
----       EXECUTE [dbo].[PG_UP_HOJA_EMPAQUE] 0, 139,												
----		 1 , 'MAGN03' , 'WK' , 'WBL' , 'IVAN DECENA' , '' , 'WBL/WBL/WBL' , '0012/0012/0012' , 'IWBL0002CNPDX9/IWBL0003CNPDX9/IWBL0004CNPDX9' , '55467M1/55468M2/55473M1' , '0.5202/0.8219/0.2766' , 'CLL/CO/ET' , 'CALLO/CORTADA/ESTRIAS' , '5/3/2' , '1/2/3' 
--CREATE PROCEDURE [dbo].[PG_UP_HOJA_EMPAQUE]
--	@PP_K_SISTEMA_EXE				INT,
--	@PP_K_USUARIO_ACCION			INT,
--	-- ===========================
--	@PP_K_HOJA_EMPAQUE				INT,
--	-- ===========================
--	--@PP_K_HOJA_EMPAQUE_STATUS				INT,
--	-- ============================
--	@PP_CUS_NO						VARCHAR(6),
--	@PP_PROGRAM						VARCHAR(50),
--	@PP_MODELNO						VARCHAR(3),
--	--@PP_VERSIONNO					VARCHAR(5),
--	-- ============================
--	--@PP_F_CREACION_HOJA_EMPAQUE				DATE,
--	-- ============================
--	@PP_SOLICITADA_POR_HOJA_EMPAQUE			VARCHAR (250),
--	-- ============================
--	@PP_C_HOJA_EMPAQUE						VARCHAR(255),
--	@PP_K_TIPO_HOJA_EMPAQUE					INT,
--	@PP_L_APLICA_COBRO				INT,
--	-- ============================
--	@PP_ARRAY_MODELNO				NVARCHAR(MAX),
--	@PP_ARRAY_VERSION				NVARCHAR(MAX),
--	-- ============================
--	@PP_ARRAY_ITEM_NO				NVARCHAR(MAX),
--	@PP_ARRAY_CUSITEM				NVARCHAR(MAX),
--	@PP_ARRAY_NETAREA				NVARCHAR(MAX),
--	-- ============================
--	@PP_ARRAY_CLAVE_D				NVARCHAR(MAX),
--	@PP_ARRAY_DEFECTO				NVARCHAR(MAX),
--	-- ============================
--	@PP_ARRAY_QTY_ORD				NVARCHAR(MAX),
--	@PP_ARRAY_K_DETAI				NVARCHAR(MAX),
--	-- ============================
--	@PP_ARRAY_GRUPO_O				NVARCHAR(MAX),
--	@PP_ARRAY_PRECIOM				NVARCHAR(MAX),
--	@PP_ATENCION_A					VARCHAR (250)	= ''
--AS			
--DECLARE @VP_MENSAJE				NVARCHAR(MAX)
---- /////////////////////////////////////////////////////////////////////
--BEGIN TRANSACTION 
--BEGIN TRY

--	DECLARE  @VP_HOJA_EMPAQUE_STATUS		INT
--			-- ,@VP_FECHA			DATE
	
--	SET @PP_MODELNO = LTRIM(RTRIM(LEFT(@PP_MODELNO,3)))

--	SELECT	@VP_HOJA_EMPAQUE_STATUS	= K_HOJA_EMPAQUE_STATUS	
--			--,@VP_FECHA		= F_CREACION_HOJA_EMPAQUE
--	FROM	HOJA_EMPAQUE		(NOLOCK)
--	WHERE	K_HOJA_EMPAQUE	= @PP_K_HOJA_EMPAQUE
	
--	IF @VP_HOJA_EMPAQUE_STATUS IN ( 1 )
--	BEGIN
--		SET @VP_HOJA_EMPAQUE_STATUS = 1	-- SE LE ASIGNA EL ESTATUS INICIAL.	
--	END
--	ELSE IF @VP_HOJA_EMPAQUE_STATUS IN (0, 3, 5 )
--	BEGIN
--		SET @VP_HOJA_EMPAQUE_STATUS = 1		-- SE LE ASIGNA EL ESTATUS INICIAL.
--		--SET @VP_FECHA	= GETDATE()	-- SE REASIGNA
--	END
--	ELSE
--	BEGIN
--		SET @VP_MENSAJE =  'El estatus no lo permite.[HDR] Verifique...' 
--		RAISERROR (@VP_MENSAJE, 16, 1 ) 
--	END

--	-- /////////////////////////////////////////////////////////////////////	

--	UPDATE	HOJA_EMPAQUE
--	SET		
--			[K_HOJA_EMPAQUE_STATUS]					= @VP_HOJA_EMPAQUE_STATUS			,
--			[K_TIPO_HOJA_EMPAQUE]					= @PP_K_TIPO_HOJA_EMPAQUE			,
--			-- ============================	= -- ============================			
--			--[CUS_NO]						= @PP_CUS_NO				,					
--			--[MODELNO]						= @PP_MODELNO				,					
--			--[VERSIONNO]						= @PP_VERSIONNO				,				
--			-- ============================	= -- ============================			
--			--[F_CREACION_HOJA_EMPAQUE]				= @VP_FECHA					,
--			-- ============================	= -- ============================			
--			[SOLICITADA_POR_HOJA_EMPAQUE]			= @PP_SOLICITADA_POR_HOJA_EMPAQUE	,
--			[ATENCION_A]					= @PP_ATENCION_A			,
--			-- ============================	= -- ============================
--			[C_HOJA_EMPAQUE]							= @PP_C_HOJA_EMPAQUE					,
--			[L_APLICA_COBRO]				= @PP_L_APLICA_COBRO		,
--			-- ============================	= -- ============================
--			[F_CAMBIO]						= GETDATE(), 
--			[K_USUARIO_CAMBIO]				= @PP_K_USUARIO_ACCION
--	WHERE	[K_HOJA_EMPAQUE]					= @PP_K_HOJA_EMPAQUE
--	IF @@ROWCOUNT = 0
--	BEGIN
--		SET @VP_MENSAJE='Registro no fue modificado. [HDR#'+CONVERT(VARCHAR(10),@PP_K_HOJA_EMPAQUE)+']'
--		RAISERROR (@VP_MENSAJE, 16, 1 ) 
--	END		

--	EXECUTE [PG_INUP_HOJA_EMPAQUE_PROCESO]	@PP_K_SISTEMA_EXE	,	@PP_K_USUARIO_ACCION,
--									-- ============================
--									@PP_K_HOJA_EMPAQUE	,	@PP_CUS_NO			,
--									-- ============================
--									@PP_ARRAY_MODELNO	,	@PP_ARRAY_VERSION	,
--									-- ============================
--									@PP_ARRAY_ITEM_NO	,	@PP_ARRAY_CUSITEM	,
--									@PP_ARRAY_NETAREA	,	
--									-- ============================
--									@PP_ARRAY_CLAVE_D	,	@PP_ARRAY_DEFECTO	,
--									-- ============================
--									@PP_ARRAY_QTY_ORD	,	@PP_ARRAY_K_DETAI	,
--									@PP_K_TIPO_HOJA_EMPAQUE		,	@PP_ARRAY_GRUPO_O	,
--									@PP_ARRAY_PRECIOM

---- /////////////////////////////////////////////////////////////////////
--COMMIT TRANSACTION 
--END TRY

--BEGIN CATCH
--	ROLLBACK TRANSACTION
--	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
--	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
--	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
--END CATCH	
--	-- /////////////////////////////////////////////////////////////////////	
--	IF @VP_MENSAJE<>''
--	BEGIN
--		SET		@VP_MENSAJE = 'No es posible [Actualizar] la [Orden]: ' + @VP_MENSAJE 
--	END

--	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_HOJA_EMPAQUE AS CLAVE
--	-- //////////////////////////////////////////////////////////////	
--GO


---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> DELETE / FICHA
---- //////////////////////////////////////////////////////////////
----	EXECUTE [dbo].[PG_DL_HOJA_EMPAQUE] 0,139,380,2,2
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_DL_HOJA_EMPAQUE]
--GO
--CREATE PROCEDURE [dbo].[PG_DL_HOJA_EMPAQUE]
--	@PP_K_SISTEMA_EXE				INT,
--	@PP_K_USUARIO_ACCION			INT,
--	-- ===========================
--	@PP_K_HOJA_EMPAQUE				INT
--AS
--DECLARE @VP_MENSAJE				NVARCHAR(MAX) = ''
--BEGIN TRANSACTION 
--BEGIN TRY
--	--/////////////////////////////////////////////////////////////
--		DECLARE @VP_STATUS_K_HEADER		INT
		
--		SELECT	@VP_STATUS_K_HEADER		= K_HOJA_EMPAQUE_STATUS
--		FROM	HOJA_EMPAQUE				(NOLOCK)
--		WHERE	K_HOJA_EMPAQUE			= @PP_K_HOJA_EMPAQUE
--		AND		L_BORRADO				<> 1
--		IF @@ROWCOUNT = 0
--		BEGIN
--			SET @VP_MENSAJE='No se obtuvo el estatus de la [Orden#'+CONVERT(VARCHAR(10),@PP_K_HOJA_EMPAQUE)+'], verifique...'
--			RAISERROR (@VP_MENSAJE, 16, 1 ) 
--		END			

--		IF @VP_STATUS_K_HEADER NOT IN ( 0, 1, 3, 5)
--		BEGIN
--			SET @VP_MENSAJE='La [Orden#'+CONVERT(VARCHAR(10),@PP_K_HOJA_EMPAQUE)+'] no puede ser eliminada, verifique...'
--			RAISERROR (@VP_MENSAJE, 16, 1 ) 
--		END
--	--////////////////////////////////////////////////////////////

--		UPDATE	HOJA_EMPAQUE
--		SET		
--				[L_BORRADO]				= 1			,
--				-- ====================
--				[F_BAJA]				= GETDATE()	,
--				[K_USUARIO_BAJA]		= @PP_K_USUARIO_ACCION
--		WHERE	K_HOJA_EMPAQUE			= @PP_K_HOJA_EMPAQUE
--		IF @@ROWCOUNT = 0
--		BEGIN
--			SET @VP_MENSAJE='la orden no puede ser borrada. [HDR#'+CONVERT(VARCHAR(10),@PP_K_HOJA_EMPAQUE)+']'
--		END

---- /////////////////////////////////////////////////////////////////////
--COMMIT TRANSACTION 
--END TRY

--BEGIN CATCH
--	ROLLBACK TRANSACTION
--	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
--	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
--	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
--END CATCH	

--	-- /////////////////////////////////////////////////////////////////////	
--	IF @VP_MENSAJE<>''
--	BEGIN
--		SET		@VP_MENSAJE = 'No es posible [ELIMINAR]: ' + @VP_MENSAJE 
--	END

--	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_HOJA_EMPAQUE AS CLAVE
--	-- /////////////////////////////////////////////////////////////////////	
--GO
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////