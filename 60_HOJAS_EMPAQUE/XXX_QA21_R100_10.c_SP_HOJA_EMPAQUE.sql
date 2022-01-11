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
--	[PG_LI_HEADER_HOJA_EMPAQUE]
--	[PG_LI_DETAILS_HOJA_EMPAQUE]
--	[PG_SK_HEADER_HOJA_EMPAQUE]
--	[PG_SK_DETAILS_HOJA_EMPAQUE]
--	[PG_IN_HEADER_HOJA_EMPAQUE]
--	[PG_IN_DETAILS_HOJA_EMPAQUE]
--	[PG_UP_HEADER_HOJA_EMPAQUE]
--	[PG_DL_HEADER_HOJA_EMPAQUE]
-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HEADER_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HEADER_HOJA_EMPAQUE]
GO
--		 EXECUTE [dbo].[PG_LI_HEADER_HOJA_EMPAQUE] 0,139,'( TODOS )','( TODOS )'
--		 EXECUTE [dbo].[PG_LI_HEADER_HOJA_EMPAQUE] 0,139,'IRVI02','JTM'
CREATE PROCEDURE [dbo].[PG_LI_HEADER_HOJA_EMPAQUE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	--@PP_BUSCAR						VARCHAR(25),
	--@PP_K_STATUS_HOJA_EMPAQUE				INT,
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25)
	--@PP_F_INIT						DATE,
	--@PP_F_FINISH					DATE
AS
	SET @PP_MODELNO = LTRIM(RTRIM(LEFT(@PP_MODELNO,3)))

	SELECT	*
	FROM	HEADER_HOJA_EMPAQUE	(NOLOCK)
	WHERE	( @PP_CUS_NO		= '( TODOS )'	OR	CUS_NO		= @PP_CUS_NO  )
	AND		( @PP_MODELNO		= '( T'	OR	MODELNO		= @PP_MODELNO )
	ORDER	BY	CUS_NO, MODELNO, VERSIONNO, ITEM_NO, CUSTOMER_ITEM_NO, COLOR
	--WHERE	CUS_NO		= @PP_CUS_NO
	--AND		MODELNO		= @PP_MODELNO
--	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA EL DETALLE DE LOS SPECIAL_PROCESS POR KIT
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_DETAILS_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_DETAILS_HOJA_EMPAQUE]
GO
--		 EXECUTE [dbo].[PG_LI_DETAILS_HOJA_EMPAQUE] 0,139, 1042
--		 EXECUTE [dbo].[PG_LI_DETAILS_HOJA_EMPAQUE] 0,139, 2483
CREATE PROCEDURE [dbo].[PG_LI_DETAILS_HOJA_EMPAQUE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_HEADER_HOJA_EMPAQUE				INT
AS
	SELECT	'C:\Users\alejandrod\Desktop\1.JPEG' AS RUTA_AV_HOJA_EMPAQUE,
			[DETAILS_HOJA_EMPAQUE].* 
	FROM	[DETAILS_HOJA_EMPAQUE]		(NOLOCK)
	WHERE	K_HEADER_HOJA_EMPAQUE	=	@PP_K_HEADER_HOJA_EMPAQUE

GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_HEADER_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_HEADER_HOJA_EMPAQUE]
GO
--		 EXECUTE [dbo].[PG_SK_HEADER_HOJA_EMPAQUE] 0,139,1
CREATE PROCEDURE [dbo].[PG_SK_HEADER_HOJA_EMPAQUE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_HEADER_HOJA_EMPAQUE		INT
AS
	-- ///////////////////////////////////////////			
	DECLARE @K_ARCUSFIL				INT
			,@K_ARCUSFIL_PROGRAM	INT
			,@CB_ARCUSFIL_PROGRAM	VARCHAR(250)

	----SELECT	@K_ARCUSFIL	= K_ARCUSFIL
	----FROM	ARCUSFIL_SQL
	----WHERE	ARCUSFIL_SQL.CUS_NO	= HEADER_HOJA_EMPAQUE.CUS_NO

	----SELECT	@K_ARCUSFIL_PROGRAM	= K_ARCUSFIL_PROGRAM 
	----FROM	ARCUSFIL_PROGRAM		(NOLOCK)
	----INNER JOIN	HEADER_HOJA_EMPAQUE			(NOLOCK) ON HEADER_HOJA_EMPAQUE.PROGRAM	= S_ARCUSFIL_PROGRAM 
	----AND		HEADER_HOJA_EMPAQUE.K_HEADER_HOJA_EMPAQUE			= @PP_K_HEADER_HOJA_EMPAQUE

	----SELECT	@CB_ARCUSFIL_PROGRAM		= RTRIM(LTRIM(S_ARCUSFIL_PROGRAM_MODEL)) + ' // ' + RTRIM(LTRIM(D_ARCUSFIL_PROGRAM_MODEL))
	----FROM	ARCUSFIL_PROGRAM_MODEL		(NOLOCK)
	----INNER JOIN	HEADER_HOJA_EMPAQUE				(NOLOCK) ON HEADER_HOJA_EMPAQUE.MODELNO	= S_ARCUSFIL_PROGRAM_MODEL
	----AND		HEADER_HOJA_EMPAQUE.K_HEADER_HOJA_EMPAQUE		= @PP_K_HEADER_HOJA_EMPAQUE

	--SELECT	@CB_ARCUSFIL_PROGRAM		= RTRIM(LTRIM(S_ARCUSFIL_PROGRAM_MODEL)) + ' // ' + RTRIM(LTRIM(D_ARCUSFIL_PROGRAM_MODEL))
	--SELECT	@CB_ARCUSFIL_PROGRAM		= RTRIM(LTRIM(S_ARCUSFIL_PROGRAM)) + ' // ' + RTRIM(LTRIM(D_ARCUSFIL_PROGRAM_MODEL))
	SELECT	@CB_ARCUSFIL_PROGRAM		= RTRIM(LTRIM(PROD_CAT_DESC))
	FROM	ARCUSFIL_PROGRAM_MODEL		(NOLOCK)	
	INNER JOIN	HEADER_HOJA_EMPAQUE		(NOLOCK) ON HEADER_HOJA_EMPAQUE.MODELNO	= S_ARCUSFIL_PROGRAM_MODEL
	AND		HEADER_HOJA_EMPAQUE.K_HEADER_HOJA_EMPAQUE		= @PP_K_HEADER_HOJA_EMPAQUE

	SELECT		TOP (1)
				-- =============================	 
				S_STATUS_HOJA_EMPAQUE	, D_STATUS_HOJA_EMPAQUE	,
				--S_TIPO_HOJA_EMPAQUE		, D_TIPO_HOJA_EMPAQUE	,
				@CB_ARCUSFIL_PROGRAM	AS PROGRAMA,
				--CUS_NO			, PROGRAMA		,
				--MODELNO,
				--VERSIONNO,
				-- =============================
				--ISNULL(REVISION_HOJA_EMPAQUE,'') AS CAJA_HOJA_EMPAQUE,
				ISNULL(REVISION_HOJA_EMPAQUE,0) AS REVISION_HOJA_EMPAQUE,
				HEADER_HOJA_EMPAQUE.*
				-- =============================	
	FROM		HEADER_HOJA_EMPAQUE		(NOLOCK) 
	INNER JOIN 	STATUS_HOJA_EMPAQUE		(NOLOCK) ON STATUS_HOJA_EMPAQUE.K_STATUS_HOJA_EMPAQUE	= HEADER_HOJA_EMPAQUE.K_STATUS_HOJA_EMPAQUE
	--INNER JOIN 	TIPO_HOJA_EMPAQUE		(NOLOCK) ON TIPO_HOJA_EMPAQUE.K_TIPO_HOJA_EMPAQUE		= HEADER_HOJA_EMPAQUE.K_TIPO_HOJA_EMPAQUE
				-- =============================
	WHERE		HEADER_HOJA_EMPAQUE.K_HEADER_HOJA_EMPAQUE	= @PP_K_HEADER_HOJA_EMPAQUE
	AND			HEADER_HOJA_EMPAQUE.L_BORRADO	<> 1
	-- ////////////////////////////////////////////////////////////////////
GO


---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> SELECT / FICHA
---- //////////////////////////////////////////////////////////////
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_DETAILS_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_SK_DETAILS_HOJA_EMPAQUE]
--GO
----		 EXECUTE [dbo].[PG_SK_DETAILS_HOJA_EMPAQUE] 0,139,7
--CREATE PROCEDURE [dbo].[PG_SK_DETAILS_HOJA_EMPAQUE]
--	@PP_K_SISTEMA_EXE				INT,
--	@PP_K_USUARIO_ACCION			INT,
--	-- ===========================
--	@PP_K_HEADER_HOJA_EMPAQUE				INT
--AS
--	-- ///////////////////////////////////////////

--		SELECT		TOP (100)
--					DETAILS_HOJA_EMPAQUE.*
--		FROM		DETAILS_HOJA_EMPAQUE					(NOLOCK)
--		WHERE		DETAILS_HOJA_EMPAQUE.K_HEADER_HOJA_EMPAQUE	= @PP_K_HEADER_HOJA_EMPAQUE
--		ORDER BY	K_DETAILS_HOJA_EMPAQUE

--	-- ////////////////////////////////////////////////////////////////////
--GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_HEADER_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_HEADER_HOJA_EMPAQUE]
GO
--		 EXECUTE [dbo].[PG_IN_HEADER_HOJA_EMPAQUE] 1,139,  '19' , '' , '' , 'WKL' , '0009' , 'IWKL0042CPRDX9' , '65327M11' , '0.6400' , '8' , '-1'
CREATE PROCEDURE [dbo].[PG_IN_HEADER_HOJA_EMPAQUE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	--@PP_K_STATUS_HOJA_EMPAQUE		INT,
	-- ============================
	----@PP_K_QUOTE_TRIM_COLOR				INT,
	----@PP_K_QUOTE_KIT						INT,
	-- ============================
	@PP_CUS_NO							VARCHAR(6),
	----@PP_PROGRAM							VARCHAR(50),
	@PP_MODELNO							VARCHAR(3),
	@PP_VERSIONNO						VARCHAR(5),
	-- ============================
	@PP_ITEM_NO							VARCHAR(50),
	@PP_CUSTOMER_ITEM_NO				VARCHAR(50),
	@PP_D_ITEM_NO						VARCHAR(500),
	-- ============================
	--@PP_CAJA_HOJA_EMPAQUE				VARCHAR(150),
	--@PP_DIBUJO_HOJA_EMPAQUE			VARCHAR(150),
	--@PP_REVISION_HOJA_EMPAQUE			INT,
	-- ============================
	--@PP_RUTA_AYUDA_VISUAL_HEADER		VARCHAR(500),
	@PP_K_TIPO_CAMBIO_KIT				INT,
	@PP_K_QUOTE_TRIM_COLOR				INT,
	@PP_K_QUOTE_KIT						INT
	-- ============================
	--@PP_ARRAY_O_DETAILS_HOJA_EMPAQUE	NVARCHAR(MAX),
	--@PP_ARRAY_D_DETAILS_HOJA_EMPAQUE	NVARCHAR(MAX),
	--@PP_ARRAY_L_AYUDA_VISUAL			NVARCHAR(MAX),
	--@PP_ARRAY_K_AV_HOJA_EMPAQUE		NVARCHAR(MAX)
	-- ============================
AS			
DECLARE  @VP_MENSAJE						NVARCHAR(MAX)
		,@VP_K_HEADER_HOJA_EMPAQUE			INT = 0
		,@VP_K_HEADER_HOJA_EMPAQUE_PREV		INT	= 0
		,@VP_VERSIONNO_PREV					INT	= 0
		--============================================
		----,@VP_EXISTE						INT
		,@VP_CAJA_HOJA_EMPAQUE			VARCHAR(150)
		,@VP_DIBUJO_HOJA_EMPAQUE		VARCHAR(150)
		,@VP_REVISION_HOJA_EMPAQUE		INT
		,@VP_RUTA_AYUDA_VISUAL_HEADER	VARCHAR(500)
		--============================================
	--SET @PP_MODELNO = LTRIM(RTRIM(LEFT(@PP_MODELNO,3)))
--BEGIN TRANSACTION 
--BEGIN TRY
	IF @PP_K_TIPO_CAMBIO_KIT	= 0		--AX:20210920	//	#0: SIN CAMBIOS,	#1: LONGITUD,	#2: AGREGADO/ELIMINADO PROCESOS ESPECIALES,	#3: CAMBIO PROCESOS ESPECIALES
	BEGIN
		--============================================
		--	SE VERIFICA SI EXISTE INFORMACIÓN DEL MODELO EN UNA VERSIÓN PREVIA.
		SELECT	TOP (1)
				----@VP_EXISTE					= COUNT(K_HEADER_HOJA_EMPAQUE)
				@VP_K_HEADER_HOJA_EMPAQUE_PREV	= K_HEADER_HOJA_EMPAQUE		,
				@VP_VERSIONNO_PREV				= VERSIONNO					,
				--============================================================
				@VP_CAJA_HOJA_EMPAQUE			= CAJA_HOJA_EMPAQUE			,
				@VP_DIBUJO_HOJA_EMPAQUE			= DIBUJO_HOJA_EMPAQUE		,
				@VP_REVISION_HOJA_EMPAQUE		= REVISION_HOJA_EMPAQUE		,
				@VP_RUTA_AYUDA_VISUAL_HEADER	= RUTA_AYUDA_VISUAL_HEADER	
				--* 
		FROM	[HEADER_HOJA_EMPAQUE]		(NOLOCK)
		WHERE	CUS_NO				= @PP_CUS_NO
		AND		MODELNO				= @PP_MODELNO
		AND		ITEM_NO				= @PP_ITEM_NO			
		AND		CUSTOMER_ITEM_NO	= @PP_CUSTOMER_ITEM_NO
		ORDER	BY VERSIONNO
	END
	ELSE
	BEGIN
		SET @VP_K_HEADER_HOJA_EMPAQUE_PREV	= 0
		SET @VP_VERSIONNO_PREV				= 0
		SET	@VP_CAJA_HOJA_EMPAQUE			= ''
		SET	@VP_DIBUJO_HOJA_EMPAQUE			= ''
		SET	@VP_REVISION_HOJA_EMPAQUE		= ''
		SET	@VP_RUTA_AYUDA_VISUAL_HEADER	= ''
	END
	
	----IF	@VP_EXISTE	> 0
	----BEGIN
	----	SET	@PP_CAJA_HOJA_EMPAQUE			= @VP_CAJA_HOJA_EMPAQUE
	----	SET	@PP_DIBUJO_HOJA_EMPAQUE			= @VP_DIBUJO_HOJA_EMPAQUE
	----	SET	@PP_REVISION_HOJA_EMPAQUE		= @VP_REVISION_HOJA_EMPAQUE
	----	SET	@PP_RUTA_AYUDA_VISUAL_HEADER	= @VP_RUTA_AYUDA_VISUAL_HEADER
	----END
	--============================================================================
	--======================================INSERTAR EL HEADER_HOJA_EMPAQUE
	--============================================================================
		INSERT INTO HEADER_HOJA_EMPAQUE
			(	-- ============================
				[K_STATUS_HOJA_EMPAQUE]		,
				-- ============================
				[CUS_NO]					,	----[PROGRAM]				,
				[MODELNO]					,	[VERSIONNO]				,
				-- ============================
				[ITEM_NO]					,	[CUSTOMER_ITEM_NO]		,
				[D_ITEM_NO]					,
				-- ============================
				[CAJA_HOJA_EMPAQUE]			,	
				[DIBUJO_HOJA_EMPAQUE]		,
				[REVISION_HOJA_EMPAQUE]		,
				-- ============================
				[RUTA_AYUDA_VISUAL_HEADER]	,
				[K_TIPO_CAMBIO_KIT]			,
				-- ============================
				[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
		VALUES	
			(	1,	-- @PP_K_STATUS_HOJA_EMPAQUE			,
				-- ============================				
				@PP_CUS_NO					,	----@PP_PROGRAM					,
				@PP_MODELNO					,	@PP_VERSIONNO				,
				-- ============================
				@PP_ITEM_NO					,	@PP_CUSTOMER_ITEM_NO		,
				@PP_D_ITEM_NO				,
				-- ============================
				@VP_CAJA_HOJA_EMPAQUE		,--@PP_CAJA_HOJA_EMPAQUE		,	
				@VP_DIBUJO_HOJA_EMPAQUE		,--@PP_DIBUJO_HOJA_EMPAQUE		,
				@VP_REVISION_HOJA_EMPAQUE	,--@PP_REVISION_HOJA_EMPAQUE	,
				-- ============================
				@VP_RUTA_AYUDA_VISUAL_HEADER,--@PP_RUTA_AYUDA_VISUAL_HEADER,
				@PP_K_TIPO_CAMBIO_KIT,	--AX:20210920	//	#0: SIN CAMBIOS,	#1: LONGITUD,	#2: AGREGADO/ELIMINADO PROCESOS ESPECIALES,	#3: CAMBIO PROCESOS ESPECIALES
				-- ============================
				@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
				0, NULL, NULL  )

		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='No se generó. [HDR#'+CONVERT(VARCHAR(10),@VP_K_HEADER_HOJA_EMPAQUE)+']'
			RAISERROR (@VP_MENSAJE, 16, 1 ) 
		END
		ELSE
		BEGIN
			SELECT @VP_K_HEADER_HOJA_EMPAQUE	= SCOPE_IDENTITY()

			IF	( @VP_K_HEADER_HOJA_EMPAQUE	= 0 OR @VP_K_HEADER_HOJA_EMPAQUE IS NULL )
			BEGIN
				RAISERROR ('Error en la asignación de identidad.[HDR]', 16, 1 ) 
			END
		END

		EXECUTE [PG_IN_DETAILS_HOJA_EMPAQUE]	@PP_K_SISTEMA_EXE	,	@PP_K_USUARIO_ACCION,
												-- ============================
												@PP_CUS_NO						,	@PP_MODELNO					,
												@PP_VERSIONNO					,	
												-- ============================
												@PP_ITEM_NO						,	@PP_CUSTOMER_ITEM_NO		,
												-- ============================
												@PP_K_TIPO_CAMBIO_KIT			,	@VP_K_HEADER_HOJA_EMPAQUE	,
												@VP_K_HEADER_HOJA_EMPAQUE_PREV	,	@VP_VERSIONNO_PREV			,
												-- ============================
												@PP_K_QUOTE_TRIM_COLOR			,	@PP_K_QUOTE_KIT
-- /////////////////////////////////////////////////////////////////////
--COMMIT TRANSACTION 
--END TRY

--BEGIN CATCH
--	/* Ocurrió un error, deshacemos los cambios*/ 
--	ROLLBACK TRANSACTION
--	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
--	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
--	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
--END CATCH	
--	-- /////////////////////////////////////////////////////////////////////	
--	IF @VP_MENSAJE<>''
--	BEGIN
--		SET		@VP_MENSAJE = 'No es posible [Insertar] la [Orden]: ' + @VP_MENSAJE 
--	END
--	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_HEADER_HOJA_EMPAQUE AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // PARA INSERTAR LOS DETALLES DE LA ORDEN
-- // STORED PROCEDURE ---> INSERT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_DETAILS_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_DETAILS_HOJA_EMPAQUE]
GO
CREATE PROCEDURE [dbo].[PG_IN_DETAILS_HOJA_EMPAQUE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ============================
	@PP_CUS_NO						VARCHAR(6),
	@PP_MODELNO						VARCHAR(3),
	@PP_VERSIONNO					VARCHAR(5),
	-- ============================
	@PP_ITEM_NO						VARCHAR(50),
	@PP_CUSTOMER_ITEM_NO			VARCHAR(50),
	-- ============================
	@PP_K_TIPO_CAMBIO_KIT			INT,
	-- ============================
	@PP_K_HEADER_HOJA_EMPAQUE		INT,
	@PP_K_HEADER_HOJA_EMPAQUE_PREV	INT,
	@PP_VERSIONNO_PREV				INT,
	@PP_K_QUOTE_TRIM_COLOR			INT,
	@PP_K_QUOTE_KIT					INT
AS
	DECLARE  @VP_MENSAJE					NVARCHAR(MAX) = ''
			-- =====================
			,@VP_CU_O_DETAILS_HOJA_EMPAQUE		INT	= 0
			-- =====================
			,@VP_CU_D_DETAILS_HOJA_EMPAQUE		VARCHAR(500)
			,@VP_CU_L_AYUDA_VISUAL				VARCHAR(500)
			,@VP_CU_K_AV_HOJA_EMPAQUE			INT	= 1
			-- =====================
			,@VP_CU_D_PROCESS					VARCHAR(500)
			-- =====================
			,@VP_O_REGISTROS					INT	= 0

	IF @PP_K_HEADER_HOJA_EMPAQUE_PREV = 0
	BEGIN

		DECLARE CU_CURSOR		CURSOR LOCAL FOR
			SELECT	--*
					DISTINCT QUOTE_PROCESS_SPECIAL_COST_CHECKS.K_PROCESS,
					D_QUOTE_PROCESS_SPECIAL_COST,
					1,
					1,
					D_PROCESS
			FROM	COT19_Cotizaciones_V9999_R0.dbo.QUOTE_PROCESS_SPECIAL_COST_CHECKS
			INNER JOIN	COT19_Cotizaciones_V9999_R0.dbo.QUOTE_PROCESS_SPECIAL_COST	ON QUOTE_PROCESS_SPECIAL_COST.K_QUOTE_TRIM_LEVEL	= QUOTE_PROCESS_SPECIAL_COST_CHECKS.K_QUOTE_TRIM_LEVEL
			INNER JOIN	COT19_Cotizaciones_V9999_R0.dbo.PROCESS						ON PROCESS.K_PROCESS								= QUOTE_PROCESS_SPECIAL_COST_CHECKS.K_PROCESS
			AND			QUOTE_PROCESS_SPECIAL_COST.K_PROCESS		= QUOTE_PROCESS_SPECIAL_COST_CHECKS.K_PROCESS
			WHERE	QUOTE_PROCESS_SPECIAL_COST_CHECKS.K_QUOTE_TRIM_COLOR		= @PP_K_QUOTE_TRIM_COLOR
			AND		QUOTE_PROCESS_SPECIAL_COST_CHECKS.K_QUOTE_KIT				= @PP_K_QUOTE_KIT
			ORDER	BY D_PROCESS
		OPEN CU_CURSOR
		FETCH NEXT FROM CU_CURSOR INTO	@VP_CU_O_DETAILS_HOJA_EMPAQUE	,@VP_CU_D_DETAILS_HOJA_EMPAQUE	,@VP_CU_L_AYUDA_VISUAL	,@VP_CU_K_AV_HOJA_EMPAQUE	,@VP_CU_D_PROCESS
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET	@VP_O_REGISTROS += 1
				-----	====================================================================================================================
				-----	/////////					SE INSERTALA INFORMACIÓN DE AQUELLOS KIT QUE NO CONTIENEN HOJA DE EMPAQUE.		20210915
				INSERT INTO	[dbo].[DETAILS_HOJA_EMPAQUE] 
				(		[K_HEADER_HOJA_EMPAQUE]			,
						-- ============================
						[O_DETAILS_HOJA_EMPAQUE]		,
						-- ============================
						[D_DETAILS_HOJA_EMPAQUE]		,
						[L_AYUDA_VISUAL]				,
						[K_AV_HOJA_EMPAQUE]				,
						-- ============================
						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
				VALUES	
					(	@PP_K_HEADER_HOJA_EMPAQUE		,
						-- ============================
						@VP_O_REGISTROS	,
						-- ============================
						@VP_CU_D_DETAILS_HOJA_EMPAQUE	,	
						@VP_CU_L_AYUDA_VISUAL			,
						@VP_CU_K_AV_HOJA_EMPAQUE		,
						-- ============================
						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
						0, NULL, NULL  )
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE = '[HOJAS_EMPAQUE] No fue posible insertar el registro en la tabla: ' + LTRIM(RTRIM(@PP_CUSTOMER_ITEM_NO)) + ' // '+ CONVERT(VARCHAR(50),@PP_K_HEADER_HOJA_EMPAQUE) +'... Informe a SISTEMAS.'
					RAISERROR (@VP_MENSAJE, 16, 1 ) 				
				END
				--END
			-----	====================================================================================================================
				FETCH NEXT FROM CU_CURSOR INTO	@VP_CU_O_DETAILS_HOJA_EMPAQUE	,@VP_CU_D_DETAILS_HOJA_EMPAQUE	,@VP_CU_L_AYUDA_VISUAL	,@VP_CU_K_AV_HOJA_EMPAQUE	,@VP_CU_D_PROCESS
			END
		CLOSE		CU_CURSOR
		DEALLOCATE	CU_CURSOR
	-- ////////////////////////////////////////////////////////////////
	END
	ELSE
	BEGIN
		DECLARE CU_CURSOR		CURSOR LOCAL FOR
			SELECT	--*
					[O_DETAILS_HOJA_EMPAQUE],
					-- =====================
					[D_DETAILS_HOJA_EMPAQUE],
					[L_AYUDA_VISUAL]		,
					[K_AV_HOJA_EMPAQUE]		
			FROM	[DETAILS_HOJA_EMPAQUE]		(NOLOCK)
			WHERE	K_HEADER_HOJA_EMPAQUE		= @PP_K_HEADER_HOJA_EMPAQUE_PREV
			ORDER	BY O_DETAILS_HOJA_EMPAQUE	ASC
		OPEN CU_CURSOR
		FETCH NEXT FROM CU_CURSOR INTO	@VP_CU_O_DETAILS_HOJA_EMPAQUE	,@VP_CU_D_DETAILS_HOJA_EMPAQUE	,@VP_CU_L_AYUDA_VISUAL	,@VP_CU_K_AV_HOJA_EMPAQUE
			WHILE @@FETCH_STATUS = 0
			BEGIN
			-----	====================================================================================================================
			-----	/////////					SE INSERTALA INFORMACIÓN DE AQUELLOS KIT QUE NO CONTIENEN HOJA DE EMPAQUE.		20210915

				INSERT INTO	[dbo].[DETAILS_HOJA_EMPAQUE] 
				(		[K_HEADER_HOJA_EMPAQUE]			,
						-- ============================
						[O_DETAILS_HOJA_EMPAQUE]		,
						-- ============================
						[D_DETAILS_HOJA_EMPAQUE]		,
						[L_AYUDA_VISUAL]				,
						[K_AV_HOJA_EMPAQUE]				,
						-- ============================
						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
				VALUES	
					(	@PP_K_HEADER_HOJA_EMPAQUE		,
						-- ============================
						@VP_CU_O_DETAILS_HOJA_EMPAQUE	,
						-- ============================
						@VP_CU_D_DETAILS_HOJA_EMPAQUE	,	
						@VP_CU_L_AYUDA_VISUAL			,
						@VP_CU_K_AV_HOJA_EMPAQUE		,
						-- ============================
						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
						0, NULL, NULL  )
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE = '[HOJAS_EMPAQUE] No fue posible insertar el registro en la tabla: ' + LTRIM(RTRIM(@PP_CUSTOMER_ITEM_NO)) + ' // '+ CONVERT(VARCHAR(50),@PP_K_HEADER_HOJA_EMPAQUE) +'... Informe a SISTEMAS.'
					RAISERROR (@VP_MENSAJE, 16, 1 ) 				
				END
				--END
			-----	====================================================================================================================
				FETCH NEXT FROM CU_CURSOR INTO	@VP_CU_O_DETAILS_HOJA_EMPAQUE	,@VP_CU_D_DETAILS_HOJA_EMPAQUE	,@VP_CU_L_AYUDA_VISUAL	,@VP_CU_K_AV_HOJA_EMPAQUE			
			END
		CLOSE		CU_CURSOR
		DEALLOCATE	CU_CURSOR
	END
	-- ////////////////////////////////////////////////////////////////
	-- ///////////////////////////////////////////////////////////////
GO


---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> UPDATE / FICHA
---- //////////////////////////////////////////////////////////////
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_HEADER_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_UP_HEADER_HOJA_EMPAQUE]
--GO
----       EXECUTE [dbo].[PG_UP_HEADER_HOJA_EMPAQUE] 0, 139,												
----		 1 , 'MAGN03' , 'WK' , 'WBL' , 'IVAN DECENA' , '' , 'WBL/WBL/WBL' , '0012/0012/0012' , 'IWBL0002CNPDX9/IWBL0003CNPDX9/IWBL0004CNPDX9' , '55467M1/55468M2/55473M1' , '0.5202/0.8219/0.2766' , 'CLL/CO/ET' , 'CALLO/CORTADA/ESTRIAS' , '5/3/2' , '1/2/3' 
--CREATE PROCEDURE [dbo].[PG_UP_HEADER_HOJA_EMPAQUE]
--	@PP_K_SISTEMA_EXE				INT,
--	@PP_K_USUARIO_ACCION			INT,
--	-- ===========================
--	@PP_K_HEADER_HOJA_EMPAQUE				INT,
--	-- ===========================
--	--@PP_K_STATUS_HOJA_EMPAQUE				INT,
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

--	DECLARE  @VP_STATUS_HOJA_EMPAQUE		INT
--			-- ,@VP_FECHA			DATE
	
--	SET @PP_MODELNO = LTRIM(RTRIM(LEFT(@PP_MODELNO,3)))

--	SELECT	@VP_STATUS_HOJA_EMPAQUE	= K_STATUS_HOJA_EMPAQUE	
--			--,@VP_FECHA		= F_CREACION_HOJA_EMPAQUE
--	FROM	HEADER_HOJA_EMPAQUE		(NOLOCK)
--	WHERE	K_HEADER_HOJA_EMPAQUE	= @PP_K_HEADER_HOJA_EMPAQUE
	
--	IF @VP_STATUS_HOJA_EMPAQUE IN ( 1 )
--	BEGIN
--		SET @VP_STATUS_HOJA_EMPAQUE = 1	-- SE LE ASIGNA EL ESTATUS INICIAL.	
--	END
--	ELSE IF @VP_STATUS_HOJA_EMPAQUE IN (0, 3, 5 )
--	BEGIN
--		SET @VP_STATUS_HOJA_EMPAQUE = 1		-- SE LE ASIGNA EL ESTATUS INICIAL.
--		--SET @VP_FECHA	= GETDATE()	-- SE REASIGNA
--	END
--	ELSE
--	BEGIN
--		SET @VP_MENSAJE =  'El estatus no lo permite.[HDR] Verifique...' 
--		RAISERROR (@VP_MENSAJE, 16, 1 ) 
--	END

--	-- /////////////////////////////////////////////////////////////////////	

--	UPDATE	HEADER_HOJA_EMPAQUE
--	SET		
--			[K_STATUS_HOJA_EMPAQUE]					= @VP_STATUS_HOJA_EMPAQUE			,
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
--	WHERE	[K_HEADER_HOJA_EMPAQUE]					= @PP_K_HEADER_HOJA_EMPAQUE
--	IF @@ROWCOUNT = 0
--	BEGIN
--		SET @VP_MENSAJE='Registro no fue modificado. [HDR#'+CONVERT(VARCHAR(10),@PP_K_HEADER_HOJA_EMPAQUE)+']'
--		RAISERROR (@VP_MENSAJE, 16, 1 ) 
--	END		

--	EXECUTE [PG_INUP_DETAILS_HOJA_EMPAQUE]	@PP_K_SISTEMA_EXE	,	@PP_K_USUARIO_ACCION,
--									-- ============================
--									@PP_K_HEADER_HOJA_EMPAQUE	,	@PP_CUS_NO			,
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

--	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_HEADER_HOJA_EMPAQUE AS CLAVE
--	-- //////////////////////////////////////////////////////////////	
--GO


---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> DELETE / FICHA
---- //////////////////////////////////////////////////////////////
----	EXECUTE [dbo].[PG_DL_HEADER_HOJA_EMPAQUE] 0,139,380,2,2
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_HEADER_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_DL_HEADER_HOJA_EMPAQUE]
--GO
--CREATE PROCEDURE [dbo].[PG_DL_HEADER_HOJA_EMPAQUE]
--	@PP_K_SISTEMA_EXE				INT,
--	@PP_K_USUARIO_ACCION			INT,
--	-- ===========================
--	@PP_K_HEADER_HOJA_EMPAQUE				INT
--AS
--DECLARE @VP_MENSAJE				NVARCHAR(MAX) = ''
--BEGIN TRANSACTION 
--BEGIN TRY
--	--/////////////////////////////////////////////////////////////
--		DECLARE @VP_STATUS_K_HEADER		INT
		
--		SELECT	@VP_STATUS_K_HEADER		= K_STATUS_HOJA_EMPAQUE
--		FROM	HEADER_HOJA_EMPAQUE				(NOLOCK)
--		WHERE	K_HEADER_HOJA_EMPAQUE			= @PP_K_HEADER_HOJA_EMPAQUE
--		AND		L_BORRADO				<> 1
--		IF @@ROWCOUNT = 0
--		BEGIN
--			SET @VP_MENSAJE='No se obtuvo el estatus de la [Orden#'+CONVERT(VARCHAR(10),@PP_K_HEADER_HOJA_EMPAQUE)+'], verifique...'
--			RAISERROR (@VP_MENSAJE, 16, 1 ) 
--		END			

--		IF @VP_STATUS_K_HEADER NOT IN ( 0, 1, 3, 5)
--		BEGIN
--			SET @VP_MENSAJE='La [Orden#'+CONVERT(VARCHAR(10),@PP_K_HEADER_HOJA_EMPAQUE)+'] no puede ser eliminada, verifique...'
--			RAISERROR (@VP_MENSAJE, 16, 1 ) 
--		END
--	--////////////////////////////////////////////////////////////

--		UPDATE	HEADER_HOJA_EMPAQUE
--		SET		
--				[L_BORRADO]				= 1			,
--				-- ====================
--				[F_BAJA]				= GETDATE()	,
--				[K_USUARIO_BAJA]		= @PP_K_USUARIO_ACCION
--		WHERE	K_HEADER_HOJA_EMPAQUE			= @PP_K_HEADER_HOJA_EMPAQUE
--		IF @@ROWCOUNT = 0
--		BEGIN
--			SET @VP_MENSAJE='la orden no puede ser borrada. [HDR#'+CONVERT(VARCHAR(10),@PP_K_HEADER_HOJA_EMPAQUE)+']'
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

--	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_HEADER_HOJA_EMPAQUE AS CLAVE
--	-- /////////////////////////////////////////////////////////////////////	
--GO
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////