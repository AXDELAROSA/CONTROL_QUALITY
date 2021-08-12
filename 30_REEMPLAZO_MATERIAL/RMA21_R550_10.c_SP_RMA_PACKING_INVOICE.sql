-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			RMA
-- // OPERATION:		SP'S
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210720
-- ////////////////////////////////////////////////////////////// 

USE	[DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- //////		CONTENIDO DEL SP
--	[PG_LI_HEADER_RMA_PACKING]
--	[PG_LI_DETAILS_RMA_PACKING]
--	[PG_GET_DETALLE_PACKING_RMA]
--	[PG_GET_DETALLE_PACKING_RMA_INFO]
--	[PG_LI_HEADER_RMA_INVOICE]
--	[PG_LI_DETAILS_RMA_INVOICE]
--***************************************************	
--ESTOS SP SIRVEN PARA GENERAR EL ARCHIVO PDF DE LA FACTURA
--		[PG_LI_INVOICE_HEADER_RMA]
--		[PG_LI_INVOICE_HEADER_YANFENG_RMA]
--		[PG_LI_INVOICE_FOOTER_RMA]
--		[PG_SK_DETAILS_RMA_INVOICE]
--***************************************************	
--	CON ESTOS SE INSERTAN LOS REGISTROS EN LAS TABLAS Y SE ACTUALIZAN LOS ESTATUS CORRESPONDIENTES.
--		[PG_UP_INVENTARIO_EMBARQUE_PACKING_RMA]
--		[PG_UP_INVENTARIO_EMBARQUE_INVOICE_RMA]
-- //////////////////////////////////////////////////////////////

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HEADER_RMA_PACKING]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HEADER_RMA_PACKING]
GO
--		 EXECUTE [dbo].[PG_LI_HEADER_RMA_PACKING] 0,139,-1
--		 EXECUTE [dbo].[PG_LI_HEADER_RMA_PACKING] 0,139,13, 1
CREATE PROCEDURE [dbo].[PG_LI_HEADER_RMA_PACKING]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	--@PP_BUSCAR						VARCHAR(25),
	@PP_K_STATUS_RMA				INT,
	@PP_K_TIPO_RMA					INT
	--@PP_CUS_NO						VARCHAR(20)
	--@PP_F_INIT						DATE,
	--@PP_F_FINISH					DATE
AS
	-- /////////////////////////////////////////////////////////////////////
		SELECT  DISTINCT	
					LEFT(LTRIM(RTRIM(SERIAL_1)),5)	AS JOBNO,
					CUSTOMER						AS CUS_NO,
					0								AS [CHECK]
		FROM	INVENTARIO_EMBARQUE_RMA				(NOLOCK)
		WHERE	SERIAL_1 IN (
								SELECT	SERIAL
								FROM	DETAILS_RMA		(NOLOCK)
								INNER JOIN	HEADER_RMA	ON HEADER_RMA.K_HEADER_RMA	= DETAILS_RMA.K_HEADER_RMA
								INNER JOIN	TIPO_RMA	ON HEADER_RMA.K_TIPO_RMA	= TIPO_RMA.K_TIPO_RMA
								WHERE	DETAILS_RMA.K_STATUS_RMA	= @PP_K_STATUS_RMA
								AND		HEADER_RMA.K_TIPO_RMA		= @PP_K_TIPO_RMA
							)
		AND	K_ESTATUS_INVENTARIO_EMBARQUE_RMA	= 5
-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA LOS PATTERN DE LOS KIT DE LOS COLORES ACTIVOS POR MODELO.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_DETAILS_RMA_PACKING]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_DETAILS_RMA_PACKING]
GO
--		 EXECUTE [dbo].[PG_LI_DETAILS_RMA_PACKING] 0,139, '36191/36192'
--		 EXECUTE [dbo].[PG_LI_DETAILS_RMA_PACKING] 0,139, '35522/35523'
CREATE PROCEDURE [dbo].[PG_LI_DETAILS_RMA_PACKING]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_ARRAY_JOBNO					NVARCHAR(MAX)	--INT
AS
			DECLARE @TBL_DETALLE_JOBNO  TABLE (
			K_REGISTRO					INT IDENTITY(1,1),
			JOBNO						INT
			--COLOR						VARCHAR(50)
			)
			SET NOCOUNT ON

			DECLARE @VP_POSICION_JOBNO			INT
			DECLARE @VP_VALOR_JOBNO				VARCHAR(100)
							
			--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
			SET	@PP_ARRAY_JOBNO	= @PP_ARRAY_JOBNO	+	'/'
			--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
			WHILE patindex('%/%' , @PP_ARRAY_JOBNO) <> 0
			BEGIN	-- BEGIN WHILE
				SELECT @VP_POSICION_JOBNO	=	patindex('%/%' , @PP_ARRAY_JOBNO)
				
				--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
				SELECT @VP_VALOR_JOBNO	= LEFT(@PP_ARRAY_JOBNO, @VP_POSICION_JOBNO - 1)

				-- /////////INSERTAMOS LA PIEL EN UNA TABLA TEMPORAL////////////////////////////////////////////////////////////
				IF @VP_VALOR_JOBNO <> ''
				BEGIN
					INSERT	INTO	@TBL_DETALLE_JOBNO
					VALUES			(	@VP_VALOR_JOBNO	)
					SET NOCOUNT ON
				END

				--Reemplazamos lo procesado con nada con la funcion stuff
				SELECT @PP_ARRAY_JOBNO	= STUFF(@PP_ARRAY_JOBNO, 1, @VP_POSICION_JOBNO, '')
			END		-- END WHILE
				
	IF ( SELECT COUNT(K_REGISTRO) FROM @TBL_DETALLE_JOBNO )	> 0
	BEGIN
		SELECT	K_TIPO_RMA,
				D_STATUS_RMA,
				--(SELECT TOP (1) D_ARCUSFIL_PROGRAM_MODEL	FROM ARCUSFIL_PROGRAM_MODEL (NOLOCK) WHERE S_ARCUSFIL_PROGRAM_MODEL	= DETAILS_RMA.MODELNO)							AS D_MODELNO,
				D_ARCUSFIL_PROGRAM_MODEL		AS D_MODELNO,
				DETAILS_RMA.ITEM_NO				AS S_PATTERN,
				LTRIM(RTRIM(SEARCH_DESC))		AS D_PATTERN,
				S_KIT	AS KIT,
				--(	SELECT TOP (1) ITEM_NO 
				--	FROM	CCPRDSTR_SQL				(NOLOCK)
				--	WHERE	ccprdstr_sql.CUS_NO			= DETAILS_RMA.CUS_NO
				--	AND		ccprdstr_sql.MODELNO		= DETAILS_RMA.MODELNO
				--	AND		ccprdstr_sql.VERSIONNO		= DETAILS_RMA.VERSIONNO	
				--	AND		ccprdstr_sql.COMP_ITEM_NO	= DETAILS_RMA.ITEM_NO					
				--	) AS KIT,
				DETAILS_RMA.CANTIDAD_ORDENADA			AS CANTIDAD_ENVIADA,
				ISNULL(PACKING_NO,'-')					AS PACKING_NO,
				ISNULL(INVOICE_NO,'-')					AS INVOICE_NO,
				--(	CASE
				--		WHEN	PO_NUMBER	= '' THEN	'-'
				--		ELSE	PO_NUMBER
				--		END
				--)	AS PO_NUMBER,
				[DETAILS_RMA].* 
		FROM	[DETAILS_RMA]				(NOLOCK)
		INNER JOIN	IMITMIDX_SQL			(NOLOCK)	ON IMITMIDX_SQL.ITEM_NO		= DETAILS_RMA.ITEM_NO
		INNER JOIN	STATUS_RMA				(NOLOCK)	ON STATUS_RMA.K_STATUS_RMA	= DETAILS_RMA.K_STATUS_RMA	
		INNER JOIN	ARCUSFIL_PROGRAM_MODEL	(NOLOCK)	ON ARCUSFIL_PROGRAM_MODEL.S_ARCUSFIL_PROGRAM_MODEL	= DETAILS_RMA.MODELNO
		INNER JOIN	HEADER_RMA				(NOLOCK)	ON HEADER_RMA.K_HEADER_RMA	= DETAILS_RMA.K_HEADER_RMA
		INNER JOIN	INVENTARIO_EMBARQUE_RMA	(NOLOCK)	ON INVENTARIO_EMBARQUE_RMA.SERIAL_2	= DETAILS_RMA.K_DETAILS_RMA
		WHERE	DETAILS_RMA.JOBNO			IN	(SELECT JOBNO FROM @TBL_DETALLE_JOBNO)
		ORDER BY MODELNO ASC, SERIAL ASC
	END
GO


---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> SELECT / SE USA EN EL REPORTE RPT_PACKING_RMA
---- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_DETALLE_PACKING_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_DETALLE_PACKING_RMA]
GO
--		 EXECUTE [dbo].[PG_GET_DETALLE_PACKING_RMA] 0 ,0,  '18/19/20/151/152/153/154/155' , 'JL0723-1'
--		 EXECUTE [dbo].[PG_GET_DETALLE_PACKING_RMA] 0 ,0,  '18/19/20/151/152/153/154/155' , 'XXXXXXXXXX'
--		 EXECUTE [dbo].[PG_GET_DETALLE_PACKING_RMA] 0 ,0,  '101/102/103/104/105' , 'XXXXXXXXXX'
--		 EXECUTE [dbo].[PG_GET_DETALLE_PACKING_RMA] 0 ,0,  '126/127' , 'XXXXXXXXXX'
--		 EXECUTE [dbo].[PG_GET_DETALLE_PACKING_RMA] 0 ,0,  '1402/1403' , 'XXXXXXXXXX'
CREATE PROCEDURE [dbo].[PG_GET_DETALLE_PACKING_RMA]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ARRAY_K_DETAILS_RMA		NVARCHAR(MAX),
	@PP_PACKING_NO				VARCHAR(50)
AS
	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE VARCHAR(255) = ''
	-- /////////SE OBTIENE DE LOS ARRAY EL LOTE Y PIEL INGRESADOS///////////////////////////////////////////////////////////	
	DECLARE @TBL_MATERIAL_SELECCIONADO  TABLE (
			K_MATERIAL_SELECCIONADO		INT IDENTITY(1,1),
			K_DETAILS_RMA				INT
		)
	SET NOCOUNT ON

	DECLARE @TBL_ENCABEZADOS	TABLE 
	(		TA_K_HEADER_RMA		INT		)
	SET NOCOUNT ON
	
	IF @PP_PACKING_NO = 'XXXXXXXXXX'
	BEGIN
		DECLARE @VP_POSICION_K_DETAILS_RMA	INT
		DECLARE @VP_VALOR_K_DETAILS_RMA		VARCHAR(20)
						
		--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
		SET	@PP_ARRAY_K_DETAILS_RMA	= @PP_ARRAY_K_DETAILS_RMA		+ '/'		
		
		--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
		WHILE patindex('%/%' , @PP_ARRAY_K_DETAILS_RMA) <> 0
		BEGIN	-- WHILE
			SELECT @VP_POSICION_K_DETAILS_RMA	=	patindex('%/%' , @PP_ARRAY_K_DETAILS_RMA)
			
			--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
			SELECT @VP_VALOR_K_DETAILS_RMA	= LEFT(@PP_ARRAY_K_DETAILS_RMA, @VP_POSICION_K_DETAILS_RMA - 1)

			-- /////////INSERTAMOS EL DETALLE POR DETALLE EN UNA TABLA TEMPORAL////////////////////////////////////////////////////////////
			INSERT	INTO	@TBL_MATERIAL_SELECCIONADO
			VALUES	( @VP_VALOR_K_DETAILS_RMA )
			SET NOCOUNT ON

			-- /////////INSERTAMOS LOS ENCABEZADOS DE LOS DETALLES EN UNA TABLA TEMPORAL////////////////////////////////////////////////////////////
			INSERT	INTO	@TBL_ENCABEZADOS
			SELECT	K_HEADER_RMA
			FROM	DETAILS_RMA		(NOLOCK)
			WHERE	K_DETAILS_RMA	= @VP_VALOR_K_DETAILS_RMA
			SET NOCOUNT ON

			--Reemplazamos lo procesado con nada con la funcion stuff
			SELECT @PP_ARRAY_K_DETAILS_RMA	= STUFF(@PP_ARRAY_K_DETAILS_RMA, 1, @VP_POSICION_K_DETAILS_RMA, '')
		END		-- WHILE
	END
	ELSE
	BEGIN
		INSERT	INTO	@TBL_MATERIAL_SELECCIONADO
		SELECT	SERIAL_2 --K_INVENTARIO_EMBARQUE_RMA
		FROM	INVENTARIO_EMBARQUE_RMA		(NOLOCK)
		WHERE	PACKING_NO					= @PP_PACKING_NO
		ORDER	BY PROD_CAT
		SET NOCOUNT ON
	END
	--===============================================================================================================================================================
	--===============================================================================================================================================================
	--===============================================================================================================================================================
	DECLARE @TBL_ATENCION			TABLE (
			--K_DETALLE_PACKING		INT IDENTITY(1,1),
			TA_ATENCION_A			VARCHAR(150)		)

	INSERT	INTO @TBL_ATENCION
	SELECT	TOP	 (1)	
			ATENCION_A
	FROM	HEADER_RMA	(NOLOCK)
	WHERE	K_HEADER_RMA	IN (	SELECT DISTINCT TA_K_HEADER_RMA
									FROM	@TBL_ENCABEZADOS		)

	DECLARE  @VP_RECIPIENTS			NVARCHAR(MAX)	= ''

	SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ', ' + TA_ATENCION_A
	FROM	@TBL_ATENCION

	IF	LEFT(@VP_RECIPIENTS,1) =','
		SET @VP_RECIPIENTS	= STUFF(@VP_RECIPIENTS, 1, 2, '')

	--SELECT  @VP_RECIPIENTS AS ATENCION_A

	--===============================================================================================================================================================
	--===============================================================================================================================================================
	--===============================================================================================================================================================
	DECLARE @TBL_DETALLE_PACKING  TABLE (
			K_DETALLE_PACKING			INT IDENTITY(1,1),
			ITEM_NO						VARCHAR(100),
			CUS_ITEM_NO					VARCHAR(100),
			S_CUS_ITEM_NO				VARCHAR(100),
			D_ITEM_NO					VARCHAR(150),
			PROD_CAT					VARCHAR(100),
			QTY_SHIP					INT,
			BOX							INT,
			COST						DECIMAL(13,2),
			--COST_MANUAL					DECIMAL(13,2),
			SQFT						DECIMAL(13,2)		)
	SET NOCOUNT ON

	INSERT INTO @TBL_DETALLE_PACKING
	SELECT	DETAILS_RMA.ITEM_NO				AS ITEM_NO,
			CUS_ITEM_NO						AS CUS_ITEM_NO,
			(	CASE
					WHEN	CUS_NO	= 'IRVI02'	THEN	(	SELECT  TOP (1)
																	LTRIM(RTRIM(CUS_ITEM_NO))
															FROM	CCCUSITM_SQL	(NOLOCK)
															WHERE	LTRIM(RTRIM(ITEM_NO))	= DETAILS_RMA.S_KIT
															AND		CUS_NO					= DETAILS_RMA.CUS_NO
															AND		MODELNO					= DETAILS_RMA.MODELNO
															--AND		VERSIONNO				= DETAILS_RMA.VERSIONNO
															ORDER BY 	VERSIONNO	DESC
														)
					ELSE	''
				END
			)								AS	S_CUS_ITEM_NO,
			LTRIM(RTRIM(ITEM_DESC_1))		AS D_ITEM_NO,
			MODELNO							AS PROD_CAT,
			SUM(CANTIDAD_ENVIADA)			AS QTY_SHIP,
			COUNT(CUS_ITEM_NO)				AS BOX,
			(	CASE
					WHEN	PRECIO_MANUAL		<> 0 THEN	( SUM(PRECIO_MANUAL)	* SUM(CANTIDAD_ENVIADA) )
					WHEN	PRECIO_UNITARIO		<> 0 THEN	( SUM(PRECIO_UNITARIO)	* SUM(CANTIDAD_ENVIADA) )
				END		)					AS COST,
			--PRECIO_UNITARIO,
			--PRECIO_MANUAL,
			( SUM(CANTIDAD_ENVIADA) * MAX(NET_AREA)	)
	FROM	DETAILS_RMA		(NOLOCK)
	INNER JOIN	IMITMIDX_SQL	(NOLOCK) ON IMITMIDX_SQL.ITEM_NO	= DETAILS_RMA.ITEM_NO
	--INNER JOIN	HEADER_RMA		(NOLOCK) ON HEADER_RMA.K_HEADER_RMA	= DETAILS_RMA.K_HEADER_RMA
	WHERE	K_DETAILS_RMA IN ( SELECT K_DETAILS_RMA FROM  @TBL_MATERIAL_SELECCIONADO	)
	GROUP BY	CUS_NO, MODELNO, CUS_ITEM_NO, DETAILS_RMA.ITEM_NO,ITEM_DESC_1,	PRECIO_UNITARIO, PRECIO_MANUAL,DETAILS_RMA.S_KIT
	ORDER BY	CUS_NO, MODELNO, CUS_ITEM_NO, ITEM_DESC_1
	SET NOCOUNT ON

	--===============================================================================================================================================================
	--===============================================================================================================================================================
	--===============================================================================================================================================================

	INSERT INTO @TBL_DETALLE_PACKING
	SELECT	' ','  ','', 'Totals:', '',
			SUM(QTY_SHIP) AS QTY_SHIP, 
			SUM(BOX) AS BOX, 
			SUM(COST) AS COST,
			SUM(SQFT) AS SQFT 
	FROM	@TBL_DETALLE_PACKING
	SET NOCOUNT ON

	SELECT	K_DETALLE_PACKING,	
		CONCAT(
				CUS_ITEM_NO,
				(	CASE
						WHEN	S_CUS_ITEM_NO	LIKE '%BQW%'	THEN	RIGHT(S_CUS_ITEM_NO,6)
						WHEN	S_CUS_ITEM_NO	LIKE '%BQX%'	THEN	RIGHT(S_CUS_ITEM_NO,6)
						WHEN	S_CUS_ITEM_NO	LIKE '%C4X%'	THEN	RIGHT(S_CUS_ITEM_NO,6)
						WHEN	S_CUS_ITEM_NO	LIKE '%C6S%'	THEN	RIGHT(S_CUS_ITEM_NO,6)
						ELSE	''
					END
				)			)				AS CUS_ITEM_NO,
			''								AS S_CUS_ITEM_NO,
			D_ITEM_NO,
			CONVERT(VARCHAR(20), QTY_SHIP)	AS QTY_SHIP,		
		    CONVERT(VARCHAR(20), BOX )		AS BOX,					
		    CONVERT(VARCHAR(20), COST )		AS COST,					
			CONVERT(VARCHAR(20), SQFT)		AS SQFT,				
			(	CASE 
					WHEN D_ITEM_NO = 'Totals:' THEN ' '
					ELSE CONVERT(VARCHAR(10),K_DETALLE_PACKING) 
				END		)	AS ID_DETALLE,
			@VP_RECIPIENTS	as ATENCION_A
	FROM		@TBL_DETALLE_PACKING AS DETALLE_PACKING
	ORDER BY	K_DETALLE_PACKING
	--////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO


---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> SELECT / SE USA EN EL REPORTE RPT_PACKING_RMA
---- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_DETALLE_PACKING_RMA_INFO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_DETALLE_PACKING_RMA_INFO]
GO
--		 EXECUTE [dbo].[PG_GET_DETALLE_PACKING_RMA_INFO] 0 ,0,  '18/19/20/151/152/153/154/155' , 'XXXXXXXXXX'
--		 EXECUTE [dbo].[PG_GET_DETALLE_PACKING_RMA_INFO] 0 ,0,  '101/102/103/104/105' , 'XXXXXXXXXX'
--		 EXECUTE [dbo].[PG_GET_DETALLE_PACKING_RMA_INFO] 0 ,0,  '1402/1403' , 'XXXXXXXXXX'
CREATE PROCEDURE [dbo].[PG_GET_DETALLE_PACKING_RMA_INFO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ARRAY_K_DETAILS_RMA		NVARCHAR(MAX),
	@PP_PACKING_NO				VARCHAR(50)
AS
	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE VARCHAR(255) = ''
	-- /////////SE OBTIENE DE LOS ARRAY EL LOTE Y PIEL INGRESADOS///////////////////////////////////////////////////////////	
	DECLARE @TBL_MATERIAL_SELECCIONADO  TABLE 
	(		TA_K_HEADER_RMA				INT		)
	SET NOCOUNT ON
	
	IF @PP_PACKING_NO = 'XXXXXXXXXX'
	BEGIN
		DECLARE @VP_POSICION_K_DETAILS_RMA	INT
		DECLARE @VP_VALOR_K_DETAILS_RMA		VARCHAR(20)
						
		--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
		SET	@PP_ARRAY_K_DETAILS_RMA	= @PP_ARRAY_K_DETAILS_RMA		+ '/'		
		
		--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
		WHILE patindex('%/%' , @PP_ARRAY_K_DETAILS_RMA) <> 0
		BEGIN		-- WHILE
			SELECT @VP_POSICION_K_DETAILS_RMA	=	patindex('%/%' , @PP_ARRAY_K_DETAILS_RMA)
			
			--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
			SELECT @VP_VALOR_K_DETAILS_RMA	= LEFT(@PP_ARRAY_K_DETAILS_RMA, @VP_POSICION_K_DETAILS_RMA - 1)

			-- /////////INSERTAMOS LA PIEL EN UNA TABLA TEMPORAL////////////////////////////////////////////////////////////
			INSERT	INTO	@TBL_MATERIAL_SELECCIONADO
			SELECT	K_HEADER_RMA
			FROM	DETAILS_RMA		(NOLOCK)
			WHERE	K_DETAILS_RMA	= @VP_VALOR_K_DETAILS_RMA
			SET NOCOUNT ON
			--Reemplazamos lo procesado con nada con la funcion stuff
			SELECT @PP_ARRAY_K_DETAILS_RMA	= STUFF(@PP_ARRAY_K_DETAILS_RMA, 1, @VP_POSICION_K_DETAILS_RMA, '')

		END		-- WHILE
	END
	ELSE
	BEGIN
		INSERT	INTO	@TBL_MATERIAL_SELECCIONADO
		SELECT	K_INVENTARIO_EMBARQUE_RMA
		FROM	INVENTARIO_EMBARQUE_RMA			(NOLOCK)
		WHERE	PACKING_NO						= @PP_PACKING_NO
		ORDER	BY PROD_CAT
	END

	DECLARE @TBL_DETALLE_PACKING  TABLE (
			K_DETALLE_PACKING			INT IDENTITY(1,1),
			TA_ATENCION_A				VARCHAR(150)		)

	SET NOCOUNT ON
	INSERT INTO @TBL_DETALLE_PACKING
	SELECT	TOP (1)	
			ATENCION_A
	FROM	HEADER_RMA	(NOLOCK)
	WHERE	K_HEADER_RMA	IN (	SELECT DISTINCT TA_K_HEADER_RMA
									FROM	@TBL_MATERIAL_SELECCIONADO		)

	DECLARE  @VP_RECIPIENTS			NVARCHAR(MAX)	= ''

	SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ', ' + TA_ATENCION_A
	FROM	@TBL_DETALLE_PACKING

	IF	LEFT(@VP_RECIPIENTS,1) =','
		SET @VP_RECIPIENTS	= STUFF(@VP_RECIPIENTS, 1, 2, '')

	SELECT  @VP_RECIPIENTS AS ATENCION_A
	--////////////////////////////////////////////////////////////////
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HEADER_RMA_INVOICE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HEADER_RMA_INVOICE]
GO
--		 EXECUTE [DBO].[PG_LI_HEADER_RMA_INVOICE] 0,0, 'IRVI02',2
CREATE PROCEDURE [dbo].[PG_LI_HEADER_RMA_INVOICE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUSTOMER					VARCHAR(50),
	@PP_K_TIPO_RMA					INT
AS
	-- =========================================	
	SELECT	DISTINCT	
			PACKING_NO,
			CUSTOMER
	FROM	INVENTARIO_EMBARQUE_RMA				(NOLOCK)
	WHERE	K_ESTATUS_INVENTARIO_EMBARQUE_RMA	IN ( 3,4 )
	AND		( CUSTOMER	= @PP_CUSTOMER	OR	@PP_CUSTOMER = '( TODOS )' )
	AND		SERIAL_2	IN  (
								SELECT	K_DETAILS_RMA 
								FROM	DETAILS_RMA		(NOLOCK)
								INNER JOIN HEADER_RMA	(NOLOCK)	ON HEADER_RMA.K_HEADER_RMA	= DETAILS_RMA.K_HEADER_RMA
								WHERE	K_TIPO_RMA	= @PP_K_TIPO_RMA
							)

	-- /////////////////////////////////////////////////////////////////////
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_DETAILS_RMA_INVOICE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_DETAILS_RMA_INVOICE]
GO
--		 EXECUTE [DBO].[PG_LI_DETAILS_RMA_INVOICE] 0,0, 'JL0728-1', 'IRVI02'
CREATE PROCEDURE [dbo].[PG_LI_DETAILS_RMA_INVOICE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	--@PP_INVOICE_NO					VARCHAR(50),
	@PP_PACKING_NO					VARCHAR(50),
	@PP_CUSTOMER					VARCHAR(50)
AS
	-- =========================================	
	--IF @PP_INVOICE_NO = 'XXXXXXXX'
	--BEGIN
		SELECT	K_TIPO_RMA,
				D_STATUS_RMA,
				--(SELECT TOP (1) D_ARCUSFIL_PROGRAM_MODEL	FROM ARCUSFIL_PROGRAM_MODEL (NOLOCK) WHERE S_ARCUSFIL_PROGRAM_MODEL	= DETAILS_RMA.MODELNO)							AS D_MODELNO,
				--D_ARCUSFIL_PROGRAM_MODEL		AS D_MODELNO,
				LTRIM(RTRIM(prod_cat_desc))		AS D_MODELNO,
				DETAILS_RMA.ITEM_NO				AS S_PATTERN,
				LTRIM(RTRIM(SEARCH_DESC))		AS D_PATTERN,
				S_KIT							AS KIT,
				--(	SELECT TOP (1) ITEM_NO 
				--	FROM	CCPRDSTR_SQL				(NOLOCK)
				--	WHERE	ccprdstr_sql.CUS_NO			= DETAILS_RMA.CUS_NO
				--	AND		ccprdstr_sql.MODELNO		= DETAILS_RMA.MODELNO
				--	AND		ccprdstr_sql.VERSIONNO		= DETAILS_RMA.VERSIONNO	
				--	AND		ccprdstr_sql.COMP_ITEM_NO	= DETAILS_RMA.ITEM_NO					
				--	) AS KIT,
				DETAILS_RMA.CANTIDAD_ORDENADA AS CANTIDAD_ENVIADA,
				ISNULL(PACKING_NO,'-')					AS PACKING_NO,
				ISNULL(INVOICE_NO,'-')					AS INVOICE_NO,
				--(	CASE
				--		WHEN	PO_NUMBER	= '' THEN	'-'
				--		ELSE	PO_NUMBER
				--		END
				--)	AS PO_NUMBER,
				[DETAILS_RMA].*
		FROM	[DETAILS_RMA]				(NOLOCK)
		INNER JOIN	IMITMIDX_SQL			(NOLOCK)	ON IMITMIDX_SQL.ITEM_NO		= DETAILS_RMA.ITEM_NO
		INNER JOIN	STATUS_RMA				(NOLOCK)	ON STATUS_RMA.K_STATUS_RMA	= DETAILS_RMA.K_STATUS_RMA	
		--INNER JOIN	ARCUSFIL_PROGRAM_MODEL	(NOLOCK)	ON ARCUSFIL_PROGRAM_MODEL.S_ARCUSFIL_PROGRAM_MODEL	= DETAILS_RMA.MODELNO
		INNER JOIN	IMCATFIL_SQL			(NOLOCK)	ON IMCATFIL_SQL.PROD_CAT	= DETAILS_RMA.MODELNO
		INNER JOIN	HEADER_RMA				(NOLOCK)	ON HEADER_RMA.K_HEADER_RMA	= DETAILS_RMA.K_HEADER_RMA
		INNER JOIN	INVENTARIO_EMBARQUE_RMA	(NOLOCK)	ON INVENTARIO_EMBARQUE_RMA.SERIAL_2	= DETAILS_RMA.K_DETAILS_RMA
		WHERE	DETAILS_RMA.K_DETAILS_RMA	IN	(	SELECT	SERIAL_2
													FROM	INVENTARIO_EMBARQUE_RMA	(NOLOCK)
													WHERE	PACKING_NO				= @PP_PACKING_NO	)
		ORDER BY MODELNO ASC, SERIAL ASC
	--END
	--ELSE
	--	BEGIN
	--		SELECT	
	--				OELINHST_SQL.Item_No,
	--				OELINHST_SQL.Item_Desc_1,
	--				-- =========================================
	--				( CASE WHEN @PP_CUSTOMER = 'FAUR01' THEN
	--							CONCAT(LTRIM(RTRIM(OELINHST_SQL.Cus_Item_No)), ' (', LTRIM(RTRIM(ISNULL(filler_0003, ''))) , ')') 
	--					ELSE LTRIM(RTRIM(OELINHST_SQL.Cus_Item_No)) END ) AS Cus_Item_No,
	--				-- =========================================
	--				OELINHST_SQL.Qty_To_Ship,
	--				'EA'	AS UOM_MANUAL,
	--				OELINHST_SQL.Unit_Price,
	--				SLS_AMT	AS	TOTAL_KIT
	--		-- =========================================-- =========================================
	--		FROM	OELINHST_SQL
	--		LEFT JOIN IMITMIDX_SQL ON LTRIM(RTRIM(IMITMIDX_SQL.item_no)) = LTRIM(RTRIM(OELINHST_SQL.item_no))
	--		WHERE	OELINHST_SQL.Inv_No	= @PP_INVOICE_NO
	--		AND		LTRIM(RTRIM(CUS_NO)) = @PP_CUSTOMER
	--		ORDER BY OELINHST_SQL.Line_Seq_No
	--	END	
	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_INVOICE_HEADER_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_INVOICE_HEADER_RMA]
GO
--		 EXECUTE [DBO].[PG_LI_INVOICE_HEADER_RMA] 0,0, 'XXXXXXXX',	'JL0728-1', 'IRVI02','999999'
--		 EXECUTE [DBO].[PG_LI_INVOICE_HEADER_RMA] 0,0, '558571',	'JL0728-1', 'IRVI02','999999'
CREATE PROCEDURE [dbo].[PG_LI_INVOICE_HEADER_RMA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_INVOICE_NO					VARCHAR(50),
	@PP_PACKING_NO					VARCHAR(50),
	@PP_CUSTOMER					VARCHAR(50),
	@PP_PO_NUMBER					VARCHAR(50)
AS
	-- =========================================
	DECLARE  @VP_F_INVOICE_NO			VARCHAR(10) = ''
			,@VP_F_PACKING_NO			VARCHAR(10) = ''

	SELECT TOP (1) 
			@VP_F_PACKING_NO							= CONVERT(VARCHAR(10),F_INVENTARIO_EMBARQUE_LOG_RMA, 101) 
	FROM	DATA_02.DBO.INVENTARIO_EMBARQUE_LOG_RMA		(NOLOCK)
	WHERE	PACKING_NO									= @PP_PACKING_NO

	-- ///////////////////////////////////////////
	IF @PP_INVOICE_NO = 'XXXXXXXX'
	BEGIN			
			SET @VP_F_INVOICE_NO = CONVERT(VARCHAR(10),GETDATE(), 6)
			
			SELECT  @VP_F_INVOICE_NO						AS F_INVOICE,
					@PP_INVOICE_NO							AS inv_no,
					@PP_PACKING_NO							AS USER_DEF_FLD_5,
					@VP_F_PACKING_NO						AS F_PACKING,
					'O'										AS ORD_TYPE,
					ARCUSFIL_SQL.A4GLIDENTITY				AS ORD_NO,
					@PP_PO_NUMBER							AS oe_po_no, 
					ADRESS_BILL.D_ARCUSFIL_ADDRESS_NAME		AS BILL_TO_NAME,
					ADRESS_BILL.D_ARCUSFIL_ADDRESS_01		AS BILL_TO_ADDR_1,
					ADRESS_BILL.D_ARCUSFIL_ADDRESS_02		AS BILL_TO_ADDR_2,
					ADRESS_BILL.D_ARCUSFIL_ADDRESS_03		AS BILL_TO_ADDR_3,
					ADRESS_BILL.D_ARCUSFIL_ADDRESS_04		AS BILL_TO_COUNTRY,
					ADRESS_SHIP.D_ARCUSFIL_ADDRESS_NAME		AS SHIP_TO_NAME,
					ADRESS_SHIP.D_ARCUSFIL_ADDRESS_01		AS SHIP_TO_ADDR_1,
					ADRESS_SHIP.D_ARCUSFIL_ADDRESS_02		AS SHIP_TO_ADDR_2,
					ADRESS_SHIP.D_ARCUSFIL_ADDRESS_03		AS SHIP_TO_ADDR_3,
					ADRESS_SHIP.D_ARCUSFIL_ADDRESS_04		AS SHIP_TO_ADDR_4,
					S_ARCUSFIL_TERMS_PERIOD					AS AR_TERMS_CD,
					SLSPSN_NO,
					0										AS	TAX_CD,
					'MFP'									AS	LOC,
					(SELECT LOC_DESC FROM IMLOCFIL_SQL (NOLOCK)	WHERE	LOC= 'MFP')	AS	LOC_DESC
					--ARCUSFIL_SQL.*
			FROM	ARCUSFIL_SQL
			INNER JOIN ARCUSFIL_ADDRESS AS ADRESS_BILL	(NOLOCK) ON ARCUSFIL_SQL.A4GLIdentity	= ADRESS_BILL.A4GLIdentity
			AND			ADRESS_BILL.K_ADDRESS_TYPE	= 1		-- BILL_TO			
			INNER JOIN ARCUSFIL_ADDRESS AS ADRESS_SHIP	(NOLOCK) ON ARCUSFIL_SQL.A4GLIdentity	= ADRESS_SHIP.A4GLIdentity
			AND			ADRESS_SHIP.K_ADDRESS_TYPE	= 2		-- SHIP_TO
			INNER JOIN	ARCUSFIL_TERMS_PERIOD			(NOLOCK) ON ARCUSFIL_SQL.K_ARCUSFIL_TERMS_PERIOD	= ARCUSFIL_TERMS_PERIOD.K_ARCUSFIL_TERMS_PERIOD
			WHERE		ARCUSFIL_SQL.CUS_NO		= @PP_CUSTOMER
	END
	ELSE
	BEGIN
	--		--20210803
			--SET @VP_F_INVOICE_NO = CONVERT(VARCHAR(10),GETDATE(), 6)
			SELECT	TOP (1)
					CONVERT(VARCHAR(10),dbo.CONVERT_INT_TO_DATE(billed_dt), 6)  AS F_INVOICE ,
					inv_no,
					USER_DEF_FLD_5,
					@VP_F_PACKING_NO		AS F_PACKING,
					ord_type, 
					ord_no, 
					oe_po_no, 
					bill_to_name,
					bill_to_addr_1,
					bill_to_addr_2,
					bill_to_addr_3,
					bill_to_country,
					ship_to_name,
					ship_to_addr_1,
					ship_to_addr_2,
					ship_to_addr_3,
					ship_to_country			AS ship_to_addr_4,
					ar_terms_cd,
					slspsn_no,
					tax_cd,
					mfg_loc					AS LOC,
					curr_cd,
					ship_via_cd,
					cus_no,
					'MFP'					AS	LOC_DESC
			FROM	OEHDRHST_SQL			(NOLOCK)
			WHERE	Inv_No					= @PP_INVOICE_NO
			AND		LTRIM(RTRIM(CUS_NO))	= @PP_CUSTOMER
			AND		LTRIM(RTRIM(oe_po_no))	= @PP_PO_NUMBER
	END
	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_INVOICE_HEADER_YANFENG_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_INVOICE_HEADER_YANFENG_RMA]
GO
CREATE PROCEDURE [dbo].[PG_LI_INVOICE_HEADER_YANFENG_RMA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_INVOICE_NO					VARCHAR(50),
	@PP_PACKING_NO					VARCHAR(50),
	@PP_CUSTOMER					VARCHAR(50),
	@PP_PO_NUMBER					VARCHAR(50)
AS
	-- =========================================	
	DECLARE	 @VP_F_INVOICE_NO		VARCHAR(10) = ''
			,@VP_F_PACKING_NO		VARCHAR(10) = ''
			
	SELECT TOP (1) 
			@VP_F_PACKING_NO							= CONVERT(VARCHAR(10),F_INVENTARIO_EMBARQUE_LOG_RMA, 101) 
	FROM	DATA_02.DBO.INVENTARIO_EMBARQUE_LOG_RMA		(NOLOCK)
	WHERE	PACKING_NO									= @PP_PACKING_NO
	-- ///////////////////////////////////////////
	IF @PP_INVOICE_NO = 'XXXXXXXX'
	BEGIN			
			SET @VP_F_INVOICE_NO = CONVERT(VARCHAR(10),GETDATE(), 6)
			
			SELECT  @VP_F_INVOICE_NO						AS F_INVOICE,
					@PP_INVOICE_NO							AS inv_no,
					@PP_PACKING_NO							AS USER_DEF_FLD_5,
					@VP_F_PACKING_NO						AS F_PACKING,
					'O'										AS ORD_TYPE,
					ARCUSFIL_SQL.A4GLIDENTITY				AS ORD_NO,
					@PP_PO_NUMBER							AS oe_po_no, 
					ADRESS_BILL.D_ARCUSFIL_ADDRESS_NAME		AS BILL_TO_NAME,
					ADRESS_BILL.D_ARCUSFIL_ADDRESS_01		AS BILL_TO_ADDR_1,
					ADRESS_BILL.D_ARCUSFIL_ADDRESS_02		AS BILL_TO_ADDR_2,
					ADRESS_BILL.D_ARCUSFIL_ADDRESS_03		AS BILL_TO_ADDR_3,
					ADRESS_BILL.D_ARCUSFIL_ADDRESS_04		AS BILL_TO_COUNTRY,
					ADRESS_SHIP.D_ARCUSFIL_ADDRESS_NAME		AS SHIP_TO_NAME,
					ADRESS_SHIP.D_ARCUSFIL_ADDRESS_01		AS SHIP_TO_ADDR_1,
					ADRESS_SHIP.D_ARCUSFIL_ADDRESS_02		AS SHIP_TO_ADDR_2,
					ADRESS_SHIP.D_ARCUSFIL_ADDRESS_03		AS SHIP_TO_ADDR_3,
					ADRESS_SHIP.D_ARCUSFIL_ADDRESS_04		AS SHIP_TO_COUNTRY,
					S_ARCUSFIL_TERMS_PERIOD					AS AR_TERMS_CD,
					SLSPSN_NO,
					0										AS	TAX_CD,
					'MFP'									AS	LOC,
					(SELECT LOC_DESC FROM IMLOCFIL_SQL (NOLOCK)	WHERE	LOC= 'MFP')	AS	LOC_DESC,
					'N/A'									AS TRACKING_NUMBER,
					'N/A'									AS LC_NUMBER
					--ship_via_cd,
					--ARCUSFIL_SQL.*
			FROM	ARCUSFIL_SQL
			INNER JOIN ARCUSFIL_ADDRESS AS ADRESS_BILL	(NOLOCK) ON ARCUSFIL_SQL.A4GLIdentity	= ADRESS_BILL.A4GLIdentity
			AND			ADRESS_BILL.K_ADDRESS_TYPE	= 1		-- BILL_TO			
			INNER JOIN ARCUSFIL_ADDRESS AS ADRESS_SHIP	(NOLOCK) ON ARCUSFIL_SQL.A4GLIdentity	= ADRESS_SHIP.A4GLIdentity
			AND			ADRESS_SHIP.K_ADDRESS_TYPE	= 2		-- SHIP_TO
			INNER JOIN	ARCUSFIL_TERMS_PERIOD			(NOLOCK) ON ARCUSFIL_SQL.K_ARCUSFIL_TERMS_PERIOD	= ARCUSFIL_TERMS_PERIOD.K_ARCUSFIL_TERMS_PERIOD
			WHERE		ARCUSFIL_SQL.CUS_NO		= @PP_CUSTOMER
	END
	ELSE
	BEGIN
			SELECT	TOP (1)
					CONVERT(VARCHAR(10),dbo.CONVERT_INT_TO_DATE(billed_dt), 6)  AS F_INVOICE ,
					inv_no,
					ord_type, 
					ord_no, 
					oe_po_no, 
					cus_no,
					bill_to_name,
					bill_to_addr_1,
					bill_to_addr_2,
					bill_to_addr_3,
					bill_to_country,
					ship_to_name,
					ship_to_addr_1,
					ship_to_addr_2,
					ship_to_addr_3,
					ship_to_country,
					ship_via_cd,
					ar_terms_cd,
					slspsn_no,
					tax_cd,
					mfg_loc				AS LOC,
					curr_cd,
					user_def_fld_5,
					@VP_F_PACKING_NO	AS F_PACKING,
					'N/A'				AS TRACKING_NUMBER,
					'N/A'				AS LC_NUMBER
			FROM	OEHDRHST_SQL
			WHERE	Inv_No					= @PP_INVOICE_NO
			AND		LTRIM(RTRIM(CUS_NO))	= @PP_CUSTOMER
			AND		LTRIM(RTRIM(oe_po_no))	= @PP_PO_NUMBER
	END
	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO INFORMACIÓN PARA
-- //						EL PIEDE PAGINA DE LA FACTURA.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_INVOICE_FOOTER_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_INVOICE_FOOTER_RMA]
GO												--		553085', 'A-47635', 'WK1208-1', 'MAGN03'
--		 EXECUTE [DBO].[PG_LI_INVOICE_FOOTER_RMA] 0,0,  'XXXXXXXX',	'JL0728-1', 'IRVI02',1
--		 EXECUTE [DBO].[PG_LI_INVOICE_FOOTER_RMA] 0,0,  '558594',	'R-JL0803-1', 'IRVI02',1
CREATE PROCEDURE [dbo].[PG_LI_INVOICE_FOOTER_RMA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_INVOICE_NO					VARCHAR(50),
	@PP_PACKING_NO					VARCHAR(50),
	@PP_CUSTOMER					VARCHAR(50),
	@PP_TIPO_ORDEN					VARCHAR(10)
AS
	-- =========================================
	DECLARE @VP_TOTAL_INVOICE					AS DECIMAL(13,2) = 0
			,@VP_N_BOX							INT = 0
			,@VP_DESCUENTO_LEYENDA				VARCHAR(150) = ''
			,@VP_DESCUENTO_PORCENTAJE			DECIMAL(13,2) = 0
			,@VP_DESCUENTO_TOTAL				DECIMAL(13,2) = 0
			,@VP_DESCUENTO_TOTAL_TEXTO			VARCHAR(20) = ''
			,@VP_SUBTOTAL_INVOICE				DECIMAL(13,2) = 0

	-- /////////////////////////////////////////////////////////////////////
	SELECT	TOP (1)
			@VP_N_BOX					= TOTAL_CAJAS
	FROM	INVENTARIO_EMBARQUE_RMA		(NOLOCK)
	WHERE	PACKING_NO					= @PP_PACKING_NO

	IF @PP_INVOICE_NO = 'XXXXXXXX'
	BEGIN
			DECLARE	 @VP_CU_CUS_PART_NO			VARCHAR(100) = ''
					,@VP_CU_ITEM_NO				VARCHAR(100) = ''
					,@VP_CU_QTY_SHIP			INT = 0
					,@VP_CU_SERIAL_2			INT	= 0

			DECLARE @VP_TBL_DETALLE_INVOICE TABLE(	TOTAL_KIT		VARCHAR(50)	 )			
			-- /////////////////////////////////////////////////////////////////////
			DECLARE	CU_MATERIAL_A_FACTURAR	CURSOR FOR 
				SELECT	CUS_PART_NO, 
						ITEM_NO,
						SUM(QTY) AS QTY_SHIP,
						SERIAL_2
				FROM	INVENTARIO_EMBARQUE_RMA		(NOLOCK)
				WHERE	PACKING_NO					= @PP_PACKING_NO
				GROUP	BY CUS_PART_NO,	 ITEM_NO,	SERIAL_2			
			OPEN CU_MATERIAL_A_FACTURAR
			FETCH NEXT FROM CU_MATERIAL_A_FACTURAR INTO @VP_CU_CUS_PART_NO, @VP_CU_ITEM_NO, @VP_CU_QTY_SHIP,	@VP_CU_SERIAL_2			
			WHILE	@@FETCH_STATUS = 0
			BEGIN
					-- ///////////////////////////////////////////
					DECLARE  @VP_PRECIO_UNITARIO			DECIMAL(13,2) = 0				-- REVISAR CALCULOS PORQUE EL PRECIO ESTA A 6 DECIMALES
							,@VP_PRECIO_MANUAL				DECIMAL(13,2) = 0				-- REVISAR CALCULOS PORQUE EL PRECIO ESTA A 6 DECIMALES

					SELECT TOP (1) 
							@VP_PRECIO_UNITARIO			= PRC_OR_DISC_1
					FROM	OEPRCFIL_SQL				(NOLOCK)
					WHERE	LTRIM(RTRIM(filler_0001))	LIKE '%' + @VP_CU_ITEM_NO 
					AND		LTRIM(RTRIM(filler_0001))	LIKE @PP_CUSTOMER + '%'
					ORDER	BY A4GLIdentity				DESC

					--	VERIFICAMOS SI EL PATTERN CONTIENE PRECIO MANUAL.
					SELECT	@VP_PRECIO_MANUAL	= PRECIO_MANUAL
					FROM	[DETAILS_RMA]		(NOLOCK)
					WHERE	K_DETAILS_RMA		= @VP_CU_SERIAL_2
					
					IF	( @VP_PRECIO_MANUAL IS NULL )
					BEGIN
						SET	@VP_PRECIO_MANUAL	= 0
					END

					IF	@VP_PRECIO_MANUAL	>	0
					BEGIN
						SET	@VP_PRECIO_UNITARIO = @VP_PRECIO_MANUAL
					END

					-- ///////////////////////////////////////////
					DECLARE @VP_TOTAL_KIT DECIMAL(13,2) = 0

					SET		@VP_TOTAL_KIT = @VP_CU_QTY_SHIP * @VP_PRECIO_UNITARIO
					
					IF @PP_TIPO_ORDEN	= 1
					BEGIN
						SET		@VP_TOTAL_KIT = 0
					END

					INSERT INTO @VP_TBL_DETALLE_INVOICE 
					SELECT	@VP_TOTAL_KIT		AS TOTAL_KIT

					FETCH NEXT FROM CU_MATERIAL_A_FACTURAR INTO @VP_CU_CUS_PART_NO, @VP_CU_ITEM_NO, @VP_CU_QTY_SHIP,	@VP_CU_SERIAL_2
				END				
				CLOSE CU_MATERIAL_A_FACTURAR
				DEALLOCATE CU_MATERIAL_A_FACTURAR
			-- /////////////////////////////////////////////////////////////////////
			SELECT	@VP_TOTAL_INVOICE	=	SUM(CONVERT(DECIMAL(13,2),TOTAL_KIT))
			FROM	@VP_TBL_DETALLE_INVOICE				

			SET @VP_SUBTOTAL_INVOICE	= @VP_TOTAL_INVOICE
			SET @VP_DESCUENTO_TOTAL		= 0	--( @VP_DESCUENTO_PORCENTAJE * @VP_SUBTOTAL_INVOICE ) / 100
			SET @VP_TOTAL_INVOICE		= @VP_SUBTOTAL_INVOICE - @VP_DESCUENTO_TOTAL
	END
	ELSE
	BEGIN		
			DECLARE @VP_TOTAL_DETALLE DECIMAL(13,2) = 0
			SELECT @VP_TOTAL_DETALLE = SUM(SLS_AMT)
			FROM OELINHST_SQL			(NOLOCK)
			WHERE inv_no = @PP_INVOICE_NO
			AND item_desc_2 <> 'COMPLEMENTO'

			IF @VP_TOTAL_DETALLE IS NULL
				SET @VP_TOTAL_DETALLE = 0

			DECLARE @VP_TOTAL_DETALLE_COMPLEMENTO DECIMAL(13,2) = 0
			SELECT	@VP_TOTAL_DETALLE_COMPLEMENTO = SUM(SLS_AMT)
			FROM	OELINHST_SQL		(NOLOCK)
			WHERE	inv_no		= @PP_INVOICE_NO
			AND		item_desc_2 = 'COMPLEMENTO'

			IF @VP_TOTAL_DETALLE_COMPLEMENTO IS NULL
				SET @VP_TOTAL_DETALLE_COMPLEMENTO = 0
		
			SET @VP_SUBTOTAL_INVOICE	= @VP_TOTAL_DETALLE
			SET @VP_DESCUENTO_TOTAL		= ( @VP_DESCUENTO_PORCENTAJE * (@VP_SUBTOTAL_INVOICE) ) / 100
			SET @VP_TOTAL_INVOICE		= @VP_SUBTOTAL_INVOICE - @VP_DESCUENTO_TOTAL

			UPDATE OEHDRHST_SQL
				SET discount_pct = @VP_DESCUENTO_PORCENTAJE,
					tot_sls_disc = @VP_DESCUENTO_TOTAL,
					tot_sls_amt = ( @VP_TOTAL_INVOICE + @VP_TOTAL_DETALLE_COMPLEMENTO )
			WHERE  inv_no = @PP_INVOICE_NO 

			SET	@VP_TOTAL_INVOICE	= ( @VP_TOTAL_INVOICE + @VP_TOTAL_DETALLE_COMPLEMENTO )
	END

	SET @VP_DESCUENTO_LEYENDA		= '-'	--'Financing ' + CONVERT(VARCHAR(10), @VP_DESCUENTO_PORCENTAJE) + '%:'
	SET @VP_DESCUENTO_TOTAL_TEXTO	= '0'	-- + CONVERT(VARCHAR(10), @VP_DESCUENTO_TOTAL)

	-- /////////////////////////////////////////////////////////////////////
	SELECT	@VP_DESCUENTO_LEYENDA									AS LEYENDA_DESCUENTO, 
			@VP_SUBTOTAL_INVOICE									AS SUBTOTAL,
			@VP_DESCUENTO_TOTAL_TEXTO								AS DESCUENTO,
			@VP_TOTAL_INVOICE										AS TOTAL_INVOICE, 
			@VP_N_BOX												AS BOX
	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> PARA OBTENER LA INFORMACIÓN DEL DETALLE 
-- //						DE LA FACTURA.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_DETAILS_RMA_INVOICE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_DETAILS_RMA_INVOICE]
GO
--		 EXECUTE [DBO].[PG_SK_DETAILS_RMA_INVOICE] 0,0, 'XXXXXXXX',	'JL0728-1', 'IRVI02',1
--		 EXECUTE [DBO].[PG_SK_DETAILS_RMA_INVOICE] 0,0, '558571',	'JL0728-1', 'IRVI02',1
CREATE PROCEDURE [dbo].[PG_SK_DETAILS_RMA_INVOICE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_INVOICE_NO					VARCHAR(50),
	@PP_PACKING_NO					VARCHAR(50),
	@PP_CUSTOMER					VARCHAR(50),
	@PP_TIPO_ORDEN					VARCHAR(10)
AS
	-- =========================================			
	IF @PP_INVOICE_NO = 'XXXXXXXX'
		BEGIN
			DECLARE  @VP_CU_CUS_PART_NO			VARCHAR(100)	= ''
					,@VP_CU_ITEM_NO				VARCHAR(100)	= ''
					,@VP_CU_QTY_SHIP			INT				= 0
					,@VP_CU_SERIAL_2			INT				= 0

			DECLARE @VP_TBL_DETALLE_INVOICE TABLE(
				Item_No			VARCHAR(100),
				Item_Desc_1		VARCHAR(100),
				Cus_Item_No		VARCHAR(100),
				Qty_To_Ship		VARCHAR(20),
				UOM_MANUAL		VARCHAR(10),
				Unit_Price		VARCHAR(10),
				TOTAL_KIT		DECIMAL(13,2)
			)

			-- ///////////////////////////////////////////
			DECLARE	CU_MATERIAL_A_FACTURAR 
			CURSOR FOR 
				SELECT	CUS_PART_NO, 
						ITEM_NO,
						SUM(QTY)				AS QTY_SHIP,
						SERIAL_2
				FROM	INVENTARIO_EMBARQUE_RMA	(NOLOCK)
				WHERE	PACKING_NO				= @PP_PACKING_NO
				GROUP	BY CUS_PART_NO, ITEM_NO, SERIAL_2
				ORDER	BY SERIAL_2
			OPEN CU_MATERIAL_A_FACTURAR
			FETCH NEXT FROM CU_MATERIAL_A_FACTURAR INTO @VP_CU_CUS_PART_NO, @VP_CU_ITEM_NO, @VP_CU_QTY_SHIP, @VP_CU_SERIAL_2			
			WHILE @@FETCH_STATUS = 0
				BEGIN
					DECLARE  @VP_ITEM_DESC_1	VARCHAR(150)	= ''
							,@VP_BPO_NUMBER		VARCHAR(50)		= ''

					SELECT	@VP_ITEM_DESC_1		= LTRIM(RTRIM(ITEM_DESC_1)),
							@VP_BPO_NUMBER		= LTRIM(RTRIM(ISNULL(filler_0003, '')))
					FROM	IMITMIDX_SQL		(NOLOCK)
					WHERE LTRIM(RTRIM(item_no)) = @VP_CU_ITEM_NO

					-- ///////////////////////////////////////////
					DECLARE  @VP_PRECIO_UNITARIO			DECIMAL(13,2) = 0				-- REVISAR CALCULOS PORQUE EL PRECIO ESTA A 6 DECIMALES
							,@VP_PRECIO_MANUAL				DECIMAL(13,2) = 0				-- REVISAR CALCULOS PORQUE EL PRECIO ESTA A 6 DECIMALES

					SELECT TOP 1 @VP_PRECIO_UNITARIO	= PRC_OR_DISC_1
					FROM	OEPRCFIL_SQL				(NOLOCK)
					WHERE	LTRIM(RTRIM(filler_0001))	LIKE '%' + @VP_CU_ITEM_NO 
					AND		LTRIM(RTRIM(filler_0001))	LIKE @PP_CUSTOMER + '%'
					ORDER	BY A4GLIdentity				DESC

					IF (	SELECT	PRECIO_UNITARIO
							FROM	DETAILS_RMA		(NOLOCK)
							WHERE	SERIAL			= @VP_CU_SERIAL_2	) <> @VP_PRECIO_UNITARIO
					BEGIN
						UPDATE	DETAILS_RMA
						SET		PRECIO_UNITARIO		=	@VP_PRECIO_UNITARIO
						WHERE	K_DETAILS_RMA		=	@VP_CU_SERIAL_2
						--IF @@ROWCOUNT = 0
						--BEGIN
						--	SET	@VP_MENSAJE	= 'No fue posible actualizar el [PRECIO UNITARIO] en [DETAILS_RMA].	SERIE#' + @VP_CU_SERIAL_2
						--	RAISERROR (@VP_MENSAJE, 16, 1 ) 
						--END
					END

					--	VERIFICAMOS SI EL PATTERN CONTIENE PRECIO MANUAL.
					SELECT	@VP_PRECIO_MANUAL	 = PRECIO_MANUAL
					FROM	[DETAILS_RMA]		(NOLOCK)
					WHERE	K_DETAILS_RMA		=	@VP_CU_SERIAL_2

					IF	( @VP_PRECIO_MANUAL IS NULL )
					BEGIN
						SET	@VP_PRECIO_MANUAL	= 0
					END

					IF	@VP_PRECIO_MANUAL	>	0
					BEGIN
						SET	@VP_PRECIO_UNITARIO = @VP_PRECIO_MANUAL
					END						
					-- ///////////////////////////////////////////
					DECLARE @VP_TOTAL_KIT DECIMAL(13,2) = 0

					SET	@VP_TOTAL_KIT = @VP_CU_QTY_SHIP * @VP_PRECIO_UNITARIO

					IF @PP_TIPO_ORDEN	= 1
					BEGIN
						SET	@VP_PRECIO_UNITARIO		= 0
						SET	@VP_TOTAL_KIT			= 0
					END

					INSERT INTO @VP_TBL_DETALLE_INVOICE 
					SELECT	@VP_CU_ITEM_NO AS Item_No,
							@VP_ITEM_DESC_1 AS Item_Desc_1,
							-- =========================================
							( CASE WHEN @PP_CUSTOMER = 'FAUR01' THEN
										CONCAT(@VP_CU_CUS_PART_NO, ' (', @VP_BPO_NUMBER, ')') 
									ELSE @VP_CU_CUS_PART_NO END ) AS Cus_Item_No,
							-- =========================================
							@VP_CU_QTY_SHIP AS Qty_To_Ship,
							'EA' AS UOM_MANUAL,
							@VP_PRECIO_UNITARIO AS Unit_Price,
							@VP_TOTAL_KIT		AS TOTAL_KIT

					FETCH NEXT FROM CU_MATERIAL_A_FACTURAR INTO @VP_CU_CUS_PART_NO, @VP_CU_ITEM_NO, @VP_CU_QTY_SHIP, @VP_CU_SERIAL_2
				END
				
				CLOSE CU_MATERIAL_A_FACTURAR
				DEALLOCATE CU_MATERIAL_A_FACTURAR

				-- ///////////////////////////////////////////
				SELECT	*
				FROM	@VP_TBL_DETALLE_INVOICE
				ORDER BY Cus_Item_No DESC
		END
	ELSE
	BEGIN
		SELECT	
				OELINHST_SQL.Item_No,
				OELINHST_SQL.Item_Desc_1,
				-- =========================================
				( CASE WHEN @PP_CUSTOMER = 'FAUR01' THEN
							CONCAT(LTRIM(RTRIM(OELINHST_SQL.Cus_Item_No)), ' (', LTRIM(RTRIM(ISNULL(filler_0003, ''))) , ')') 
					ELSE LTRIM(RTRIM(OELINHST_SQL.Cus_Item_No)) END ) AS Cus_Item_No,
				-- =========================================
				OELINHST_SQL.Qty_To_Ship,
				'EA'	AS UOM_MANUAL,
				OELINHST_SQL.Unit_Price,
				SLS_AMT	AS	TOTAL_KIT
		-- =========================================-- =========================================
		FROM	OELINHST_SQL
		LEFT JOIN IMITMIDX_SQL ON LTRIM(RTRIM(IMITMIDX_SQL.item_no)) = LTRIM(RTRIM(OELINHST_SQL.item_no))
		WHERE	OELINHST_SQL.Inv_No		= @PP_INVOICE_NO
		AND		LTRIM(RTRIM(CUS_NO))	= @PP_CUSTOMER
		ORDER BY OELINHST_SQL.Line_Seq_No
	END	
	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> ACTUALIZAR / INFORMACIÓN PARA PACKING.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_INVENTARIO_EMBARQUE_PACKING_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_INVENTARIO_EMBARQUE_PACKING_RMA]
GO
--		 EXECUTE [dbo].[PG_UP_INVENTARIO_EMBARQUE_PACKING_RMA] 0,139,   'JEEP JT SUMMIT' , '199/109/108/116/115/117/114/113/112/110/111' , 1 
--		 EXECUTE [DBO].[PG_UP_INVENTARIO_EMBARQUE_PACKING_RMA] 1,139,  'JTS' , '18/19/20/151/152/153/154/155' , 1 , 2
--		 EXECUTE [DBO].[PG_UP_INVENTARIO_EMBARQUE_PACKING_RMA] 1,139,  'WTL' , '149/150/156' , 1 , 1
--		 EXECUTE [DBO].[PG_UP_INVENTARIO_EMBARQUE_PACKING_RMA] 1,139,  'JSU' , '1300/1301' , 2 , 2 , 1 
CREATE PROCEDURE [dbo].[PG_UP_INVENTARIO_EMBARQUE_PACKING_RMA]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_MODELNO							VARCHAR(150),
	@PP_K_DETAILS_RMA_ARRAY				NVARCHAR(MAX),
	@PP_TIPO_ORDEN						INT,
	@PP_NUMERO_EMBARQUE					INT,
	@PP_TOTAL_CAJAS						INT
	-- ============================		
AS
	DECLARE  @VP_MENSAJE			VARCHAR(300)	= ''
			,@VP_PACKING_NUEVO		VARCHAR(50)		= ''
			,@VP_PROGRAMA			VARCHAR(150)	= ''

	-- /////////////SE OBTIENE EL PRODUCT CATEGORY //////////////////////////////
	SELECT	@VP_PROGRAMA			= LTRIM(RTRIM(filler_0001)) 
	FROM	imcatfil_sql			(NOLOCK)
	WHERE	LTRIM(RTRIM(prod_cat))	= @PP_MODELNO

	--SELECT	@VP_PROGRAMA = LTRIM(RTRIM(filler_0001)) 
	--FROM	ARCUSFIL_PROGRAM_MODEL		(NOLOCK)
	--WHERE	S_ARCUSFIL_PROGRAM_MODEL	= @PP_MODELNO

	IF @PP_TIPO_ORDEN	= 1
	BEGIN
		SET @VP_PROGRAMA	= 'R-'
	END
	ELSE IF @PP_TIPO_ORDEN	= 2
	BEGIN
		SET @VP_PROGRAMA	= 'S-' + @VP_PROGRAMA
	END

	IF @VP_PROGRAMA IS NULL OR @VP_PROGRAMA = ''
		SET @VP_MENSAJE = 'No fue posible obtener el Product Category en [IMCATFIL].'
	-- =========================================
	IF @VP_MENSAJE = ''
		BEGIN
			DECLARE  @VP_N_PACKING				INT			= 0
					,@VP_PACKING_NO_ACTUAL		VARCHAR(50) = ''
					,@VP_DATE					DATE		= GETDATE()

			-- /////////////SE VALIDA SI YA SE HA REALIZADO ALGUN EMBARQUE EN EL DIA //////////////////////////////
			SELECT	@VP_N_PACKING					= COUNT(K_INVENTARIO_EMBARQUE_LOG_RMA)
			FROM	INVENTARIO_EMBARQUE_LOG_RMA		(NOLOCK)
			WHERE	K_ESTATUS_INVENTARIO_EMBARQUE	= 3 -- EMBARCADO
			AND		CONVERT(DATE, F_INVENTARIO_EMBARQUE_LOG_RMA) = @VP_DATE

			IF @VP_N_PACKING IS NULL
				SET @VP_N_PACKING = 0

			IF @VP_N_PACKING > 0
				BEGIN
					-- /////////////SE VALIDA SI YA SE HA REALIZADO ALGUN EMBARQUE PARA EL PROGRAMA //////////////////////////////
					DECLARE	@VP_N_PACKING_X_PROGRAMA		INT = 0
					
					SELECT	@VP_N_PACKING_X_PROGRAMA						= COUNT(PACKING_NO)
					FROM	INVENTARIO_EMBARQUE_LOG_RMA						(NOLOCK)
					WHERE	K_ESTATUS_INVENTARIO_EMBARQUE					= 3 -- EMBARCADO
					AND		CONVERT(DATE, F_INVENTARIO_EMBARQUE_LOG_RMA)	= @VP_DATE
					AND		LTRIM(RTRIM(PACKING_NO))						LIKE CONCAT(@VP_PROGRAMA, '%')

					IF @VP_N_PACKING_X_PROGRAMA IS NULL
						SET @VP_N_PACKING_X_PROGRAMA = 0

					IF @VP_N_PACKING_X_PROGRAMA > 0
						BEGIN
							-- /////////////SE OBTIENE EL ULTIMO EMBARQUE ENVIADO PARA EL PROGRAMA //////////////////////////////
							SELECT TOP 1 @VP_PACKING_NO_ACTUAL						= LTRIM(RTRIM(PACKING_NO))
							FROM	INVENTARIO_EMBARQUE_LOG_RMA						(NOLOCK)
							WHERE	K_ESTATUS_INVENTARIO_EMBARQUE					= 3 -- EMBARCADO
							AND		CONVERT(DATE, F_INVENTARIO_EMBARQUE_LOG_RMA)	= @VP_DATE
							AND		LTRIM(RTRIM(PACKING_NO))						LIKE CONCAT(@VP_PROGRAMA, '%')
							ORDER	BY	CONVERT(INT,SUBSTRING(PACKING_NO,CHARINDEX('-', PACKING_NO) + 1, 10))	DESC

							DECLARE  @VP_DELIMITADOR			VARCHAR(5)	= '-'
									,@VP_CONSECUTIVO_ACTUAL		VARCHAR(50) = ''
									,@VP_POSICION_GUION			INT			= 0
									,@VP_CONSECUTIVO_NUEVO		INT			= 0

							SET @VP_POSICION_GUION = CHARINDEX(@VP_DELIMITADOR, @VP_PACKING_NO_ACTUAL)
	
							SET @VP_CONSECUTIVO_ACTUAL = SUBSTRING(@VP_PACKING_NO_ACTUAL, @VP_POSICION_GUION + 1, 5)

							SET @VP_CONSECUTIVO_NUEVO = CONVERT(INT, @VP_CONSECUTIVO_ACTUAL) + 1
							
							SET @VP_PACKING_NUEVO = CONCAT(@VP_PROGRAMA, FORMAT(GETDATE(),'MMdd'), '-', @VP_CONSECUTIVO_NUEVO )

						END
					ELSE
						BEGIN
							SET @VP_PACKING_NUEVO = CONCAT(@VP_PROGRAMA, FORMAT(GETDATE(),'MMdd'), '-', '1' )
						END
				END
			ELSE
				BEGIN
					SET @VP_PACKING_NUEVO = CONCAT(@VP_PROGRAMA, FORMAT(GETDATE(),'MMdd'), '-', '1' )
				END
		END

		IF @VP_PACKING_NUEVO IS NULL OR @VP_PACKING_NUEVO = ''
			SET @VP_MENSAJE = 'No fue posible obtener el Numero del Packing.'

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				IF @PP_K_USUARIO_ACCION NOT IN (139,87)
				BEGIN
					RAISERROR ('Usuario no válido para realizar la acción.', 16, 1 )
				END
				---==================================================================================================================================================================
				---==================================================================================================================================================================
				---==================================================================================================================================================================
				---==================================================================================================================================================================				
				-- /////////SE OBTIENE DE LOS ARRAY EL LOTE Y PIEL INGRESADOS///////////////////////////////////////////////////////////	
				DECLARE @TBL_MATERIAL_SELECCIONADO  TABLE (
						TBL_K_MATERIAL_SELECCIONADO		INT IDENTITY(1,1),
						TBL_K_INVENTARIO_EMBARQUE		INT
					)
				SET NOCOUNT ON

				DECLARE @TBL_MATERIAL_SELECCIONADO_HEADER_RMA  TABLE (
						TBL_K_MATERIAL_SELECCIONADO_RMA		INT IDENTITY(1,1),
						TBL_K_HEADER_RMA					INT
					)
				SET NOCOUNT ON
				
				DECLARE  @VP_POSICION_K_DETAILS_RMA		INT
						,@VP_VALOR_K_DETAILS_RMA		VARCHAR(20)
						,@VP_VALIDA_CLIENTE				VARCHAR(50)	= ''
						,@VP_VALIDA_TIPO				INT
						,@VP_CONTA						INT			= 0
								
				--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
				SET	@PP_K_DETAILS_RMA_ARRAY	= @PP_K_DETAILS_RMA_ARRAY		+ '/'		
				
				--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
				WHILE patindex('%/%' , @PP_K_DETAILS_RMA_ARRAY) <> 0
				BEGIN		-- WHILE
						SELECT @VP_POSICION_K_DETAILS_RMA	=	patindex('%/%' , @PP_K_DETAILS_RMA_ARRAY)
						
						--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
						SELECT @VP_VALOR_K_DETAILS_RMA	= LEFT(@PP_K_DETAILS_RMA_ARRAY, @VP_POSICION_K_DETAILS_RMA - 1)
						
						DECLARE  @VP_K_STATUS_RMA				INT		= 0
								,@VP_K_INVENTARIO_EMBARQUE_RMA	INT		
								,@VP_K_HEADER_RMA				INT
								,@VP_WH_CLIENTE					VARCHAR(50)	= ''
								,@VP_WH_TIPO					INT
						
						SELECT	@VP_K_STATUS_RMA				= K_ESTATUS_INVENTARIO_EMBARQUE_RMA,
								@VP_K_INVENTARIO_EMBARQUE_RMA	= K_INVENTARIO_EMBARQUE_RMA
						FROM	INVENTARIO_EMBARQUE_RMA			(NOLOCK)
						WHERE	SERIAL_2						= @VP_VALOR_K_DETAILS_RMA
						
						SELECT	@VP_K_HEADER_RMA	= DETAILS_RMA.K_HEADER_RMA,
								@VP_WH_CLIENTE		= DETAILS_RMA.CUS_NO,
								@VP_WH_TIPO			= K_TIPO_RMA
						FROM	DETAILS_RMA			(NOLOCK)
						INNER JOIN HEADER_RMA		(NOLOCK) ON HEADER_RMA.K_HEADER_RMA	= DETAILS_RMA.K_HEADER_RMA
						WHERE	K_DETAILS_RMA		= @VP_VALOR_K_DETAILS_RMA
						
						-- /////////VALIDACIÓN QUE SEAN DEL MISMO TIPO Y CLIENTE TODOS LOS REGISTROS.////////////////////////////////////////////////////////////
						IF @VP_CONTA	= 0
						BEGIN
							SET	@VP_CONTA				= @VP_CONTA + 1
							SET	@VP_VALIDA_CLIENTE		= @VP_WH_CLIENTE
							SET	@VP_VALIDA_TIPO			= @VP_WH_TIPO		
						END
						ELSE
						BEGIN
							IF @VP_VALIDA_CLIENTE		<> @VP_WH_CLIENTE
								RAISERROR ('Las ordenes deben pertencer al mismo Cliente', 16, 1 ) 
						
							IF @VP_VALIDA_TIPO			<> @VP_WH_TIPO		
								RAISERROR ('Las órdenes deben pertencer al mismo Tipo (Reemplazo ó Pedido especial)', 16, 1 ) 
						END

						-- /////////VALIDACIÓN DEL ESTATUS DEL REGISTRO.////////////////////////////////////////////////////////////
						IF ( @VP_K_STATUS_RMA	= 0 ) OR ( @VP_K_STATUS_RMA IS NULL )
						BEGIN
							SET	@VP_MENSAJE	= 'No fue posible obtener el estatus del registro... Verifique. [' + CONVERT(VARCHAR(50),@VP_VALOR_K_DETAILS_RMA) + ']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END
						ELSE IF ( @VP_K_STATUS_RMA	<> 5 )
						BEGIN
							SET	@VP_MENSAJE	= 'El estatus del registro, no permite realizar acción... Verifique. [' + CONVERT(VARCHAR(50),@VP_VALOR_K_DETAILS_RMA) + ']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END

						-- /////////INSERTAMOS LA PIEL EN UNA TABLA TEMPORAL////////////////////////////////////////////////////////////
						INSERT	INTO	@TBL_MATERIAL_SELECCIONADO
						VALUES	( @VP_K_INVENTARIO_EMBARQUE_RMA )--@VP_VALOR_K_DETAILS_RMA )
						IF @@ROWCOUNT = 0
							RAISERROR ('No fue posible encontrar el pattern a embarcar [INVENTARIO_EMBARQUE].', 16, 1 ) 

						-- /////////ACTUALIZAMOS EL ESTATUS DE LA TABLA DETAILS_RMA////////////////////////////////////////////////////////////
						UPDATE	DETAILS_RMA
						SET		K_STATUS_RMA	= 35
						WHERE	K_DETAILS_RMA		= @VP_VALOR_K_DETAILS_RMA
						IF @@ROWCOUNT = 0
							RAISERROR ('No fue posible actualizar el estatus del detalle, verifique...', 16, 1 )

						-- /////////PARA INSERTAR LOS ENCABEZADOS DE LOS DETALLES QUE HAN SIDO EMBARCADOS////////////////////////////////////////////////////////////
						IF (SELECT COUNT(K_DETAILS_RMA) FROM DETAILS_RMA	WHERE K_HEADER_RMA	= @VP_K_HEADER_RMA)	= 
							(SELECT COUNT(K_DETAILS_RMA) FROM DETAILS_RMA	WHERE K_HEADER_RMA	= @VP_K_HEADER_RMA AND	K_STATUS_RMA = 35 )
						BEGIN
							INSERT	INTO	@TBL_MATERIAL_SELECCIONADO_HEADER_RMA
							VALUES	(	@VP_K_HEADER_RMA	)
							IF @@ROWCOUNT = 0
								RAISERROR ('No fue posible encontrar el encabezado del pattern a embarcar [INVENTARIO_EMBARQUE].', 16, 1 ) 
						END

						--Reemplazamos lo procesado con nada con la funcion stuff
						SELECT @PP_K_DETAILS_RMA_ARRAY	= STUFF(@PP_K_DETAILS_RMA_ARRAY, 1, @VP_POSICION_K_DETAILS_RMA, '')
				END		-- WHILE
				---==================================================================================================================================================================
				---==================================================================================================================================================================
				---==================================================================================================================================================================
				---==================================================================================================================================================================
				-- ///////SE VALIDA QUE EXISTA REGISTROS EN LA TABLA TEMPORAL///////////////////////////////////////////////////////
				DECLARE @VP_N_MATERIAL_SELECCIONADO INT = 0
				SELECT @VP_N_MATERIAL_SELECCIONADO = COUNT(TBL_K_MATERIAL_SELECCIONADO)
				FROM @TBL_MATERIAL_SELECCIONADO

				IF @VP_N_MATERIAL_SELECCIONADO IS NULL OR @VP_N_MATERIAL_SELECCIONADO = 0
					RAISERROR ('ERROR: No hay material seleccionado para asignar al Packing.', 16, 1 ) 

				-- ///////SE ASIGNA EL PACKING AL MATERIAL SELECCIONADO///////////////////////////////////////////////////////		
				UPDATE	INVENTARIO_EMBARQUE_RMA
				SET		K_ESTATUS_INVENTARIO_EMBARQUE_RMA	= 3, -- EMBARCADO
						PACKING_NO							= @VP_PACKING_NUEVO,
						N_EMBARQUE							= @PP_NUMERO_EMBARQUE,
						TOTAL_CAJAS							= @PP_TOTAL_CAJAS,
						F_INVENTARIO_EMBARQUE_RMA			= GETDATE(),
						F_CAMBIO							= GETDATE()
				WHERE	K_INVENTARIO_EMBARQUE_RMA IN (	SELECT	TBL_K_INVENTARIO_EMBARQUE
														FROM	@TBL_MATERIAL_SELECCIONADO	)
				IF @@ROWCOUNT = 0
					RAISERROR ('No fue posible asignar el Packing al material seleccionado en [INVENTARIO_EMBARQUE].', 16, 1 ) 

				IF (SELECT COUNT(TBL_K_HEADER_RMA) FROM @TBL_MATERIAL_SELECCIONADO_HEADER_RMA) > 0
				BEGIN
					UPDATE	HEADER_RMA
					SET		K_STATUS_RMA		= 35
					WHERE	K_HEADER_RMA		IN	( SELECT TBL_K_HEADER_RMA	FROM	@TBL_MATERIAL_SELECCIONADO_HEADER_RMA	)
					AND		K_STATUS_RMA		<= 30
					IF @@ROWCOUNT = 0
						RAISERROR ('No fue posible asignar el Estatus al material seleccionado en [INVENTARIO_EMBARQUE].', 16, 1 ) 
				END

				-- /////////////SE INGRESA EL LOG EN INVENTARIO_EMBARQUE_LOG_RMA//////////////////////////////
				INSERT INTO INVENTARIO_EMBARQUE_LOG_RMA	(	[K_ESTATUS_INVENTARIO_EMBARQUE], [ITEM_NO], [QTY], [CUBE_WIDTH], [SERIAL_1],		
														[SERIAL_2],	[COLOR], [CUSTOMER], [CUS_PART_NO],	[PROD_CAT],
														[D_PROD_CAT], [N_EMBARQUE], [PACKING_NO], [INVOICE_NO], [F_INVENTARIO_EMBARQUE_LOG_RMA],	
														-- ===========================
														[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
														[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )	
												SELECT	[K_ESTATUS_INVENTARIO_EMBARQUE_RMA], [ITEM_NO], [QTY], [CUBE_WIDTH], [SERIAL_1],		
														[SERIAL_2],	[COLOR], [CUSTOMER], [CUS_PART_NO],	[PROD_CAT],
														[D_PROD_CAT], N_EMBARQUE, [PACKING_NO], [INVOICE_NO], [F_INVENTARIO_EMBARQUE_RMA],
														-- ===========================
														@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
														0, 0, NULL 
												FROM	INVENTARIO_EMBARQUE_RMA				(NOLOCK)
												WHERE	PACKING_NO = @VP_PACKING_NUEVO

				IF @@ROWCOUNT = 0
				BEGIN
					RAISERROR ('ERROR: No fue posible guardar el log del Packing en [INVENTARIO_EMBARQUE_LOG] ', 16, 1 ) 
				END

				-- //////SE OBTIENE EL NUMERO DE RELOJ DEL USUARIO PEARL/////////////////////////////////////
				DECLARE @VP_NUMERO_RELOJ		INT		= 0;
				SELECT	@VP_NUMERO_RELOJ				= K_EMPLEADO_PEARL				
				FROM	BD_GENERAL.DBO.USUARIO_PEARL	(NOLOCK)
				WHERE	K_USUARIO_PEARL					= @PP_K_USUARIO_ACCION

				-- ///////SE GUARDA EL LOG DEL MATERIAL EMBARCADO PARA EL RASTREO//////////////////////////////////////////////
				EXECUTE [dbo].[PG_IN_EVENTO_EMBARCADO_FACTURADO_KIT_PROGRAMADO_RMA]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																				430, @VP_PACKING_NUEVO, 'EMBARQUES RMA', @VP_NUMERO_RELOJ, ''
				
				-- //////////////////////////////////////////////////////////////
				INSERT INTO [MATERIAL_PROGRAMADO_LOG]	
					(	[K_TIPO_EVENTO_KIT], [SERIAL], [ITEM_NO], [USUARIO_EVENTO], [ESTACION], 
						[K_RESPONSABLE], [CODIGO_ETIQUETA], [F_LOG],			
						-- ===========================
						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )	
				SELECT	430, [SERIAL_1], [ITEM_NO], [PACKING_NO], 'EMBARQUES RMA', 
						@VP_NUMERO_RELOJ, '', GETDATE(),
						-- ===========================
						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
						0, 0, NULL 
				FROM	INVENTARIO_EMBARQUE_RMA		(NOLOCK)
				WHERE	PACKING_NO					= @VP_PACKING_NUEVO 

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible guardar el log del Packing en [MATERIAL_PROGRAMADO_LOG]', 16, 1 ) 
				-- //////////////////////////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_UP_INVENTARIO_EMBARQUE_PACKING // ' + @VP_ERROR_TRANS
			END CATCH
	
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN		
		--SET		@VP_MENSAJE = 'No es posible [Asignar] el Packing al material en [INVENTARIO_EMBARQUE]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#PACKING.'+ @VP_PACKING_NUEVO + ']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_PACKING_NUEVO AS CLAVE
	-- //////////////////////////////////////////////////////////////	
GO
------ //////////////////////////////////////////////////////////////
------ //////////////////////////////////////////////////////////////
------ //////////////////////////////////////////////////////////////

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> ACTUALIZAR / INFORMACIÓN PARA FACTURA.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_INVENTARIO_EMBARQUE_INVOICE_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_INVENTARIO_EMBARQUE_INVOICE_RMA]
GO
--			EXEC [dbo].[PG_UP_INVENTARIO_EMBARQUE_INVOICE_RMA] 0,139, '99999' , 'R-JL0803-1', 'IRVI02', 'alejandrod'
CREATE PROCEDURE [dbo].[PG_UP_INVENTARIO_EMBARQUE_INVOICE_RMA]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_PO_NUMBER				VARCHAR(50),
	@PP_PACKING_NO				VARCHAR(50),
	@PP_CUSTOMER				VARCHAR(50),
	@PP_D_USUARIO				VARCHAR(50)
	-- ============================		
AS			
	DECLARE  @VP_MENSAJE					VARCHAR(300)	= ''
			,@VP_INVOICE					VARCHAR(50)		= ''
			,@VP_JNL_CD						VARCHAR(50)		= ''
	-- // SECCION#1 ////////////////////////////////////////////////////////// VALIDACIONES
			,@VP_N_MATERIAL_PACKING			INT = 0
	SELECT	@VP_N_MATERIAL_PACKING			= COUNT(K_INVENTARIO_EMBARQUE_RMA)
	FROM	INVENTARIO_EMBARQUE_RMA			(NOLOCK)
	WHERE	PACKING_NO						= @PP_PACKING_NO
	
	IF @VP_N_MATERIAL_PACKING IS NULL OR @VP_N_MATERIAL_PACKING = 0
		SET @VP_MENSAJE = 'No fue posible obtener el material asignado al Packing.'

	IF @VP_MENSAJE = ''
	BEGIN
		DECLARE @VP_N_MATERIAL_X_FACTURAR			INT = 0
		SELECT	@VP_N_MATERIAL_X_FACTURAR			= COUNT(K_INVENTARIO_EMBARQUE_RMA)
		FROM	INVENTARIO_EMBARQUE_RMA				(NOLOCK)
		WHERE	PACKING_NO							= @PP_PACKING_NO
		AND		K_ESTATUS_INVENTARIO_EMBARQUE_RMA	= 3 -- EMBARCADO

		IF @VP_N_MATERIAL_X_FACTURAR IS NULL OR @VP_N_MATERIAL_X_FACTURAR = 0
			SET @VP_MENSAJE = 'No fue posible obtener el material asignado al Packing.'

		IF @VP_MENSAJE = ''
			IF @VP_N_MATERIAL_PACKING <> @VP_N_MATERIAL_X_FACTURAR
				SET @VP_MENSAJE = 'EL Packing ya fue facturado.' 
	END

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	IF @VP_MENSAJE=''		-- IF SECCION#2
	BEGIN
		BEGIN TRANSACTION 
		BEGIN TRY
			-- ///////SE OBTIENE EL CONSECUTIVO DE LA FACTURA///////////////////////////////////////////////////////
			SELECT	TOP (1)
					@VP_INVOICE		= str_inv_no
			FROM	ARCTLFIL_SQL	(NOLOCK)

			IF @VP_INVOICE IS NULL OR @VP_INVOICE = '0'
				RAISERROR ('ERROR: No fue posible obtener el numero de Factura en [ARCTLFIL_SQL] ', 16, 1 ) 

			-- ///////SE ACTUALIZA EL CONSECUTIVO DE LA FACTURA///////////////////////////////////////////////////////
			UPDATE	ARCTLFIL_SQL
			SET		ARCTLFIL_SQL.str_inv_no = ARCTLFIL_SQL.str_inv_no + 1
			IF @@ROWCOUNT = 0
			BEGIN
				RAISERROR ('ERROR: No fue posible actualizar el numero de Factura en [ARCTLFIL_SQL] ', 16, 1 ) 
			END

			-- ///////SE OBTIENE EL jnl_cd DE LA OELINHST_SQL///////////////////////////////////////////////////////
			SELECT	TOP (1)
					@VP_JNL_CD		= LTRIM(RTRIM(JNL_CD))
			FROM	OELINHST_SQL	(NOLOCK)
			ORDER	BY A4GLIdentity	DESC
			
			IF ( @VP_JNL_CD IS NULL ) OR	( @VP_JNL_CD = '' )
				RAISERROR ('ERROR: No fue posible obtener jnl_cd en [OELINHST_SQL] ', 16, 1 ) 

			DECLARE	@VP_JNL_CONSECUTIVO INT = SUBSTRING(@VP_JNL_CD, 3, 10)

			SET @VP_JNL_CONSECUTIVO = @VP_JNL_CONSECUTIVO + 1
			SET @VP_JNL_CD			= 'IP' + CONVERT(VARCHAR(10), @VP_JNL_CONSECUTIVO)

			-- ///////SE CREA CURSOR CON MATERIAL DEL PACKING///////////////////////////////////////////////////////
			DECLARE		 @VP_CU_CUS_PART_NO			VARCHAR(100)	= ''
						,@VP_CU_ITEM_NO				VARCHAR(100)	= ''
						,@VP_CU_QTY_SHIP			INT				= 0
						,@VP_CU_QTY_BOX				INT				= 0
						,@VP_CU_SERIAL_2			INT				= 0
						,@VP_TOTAL_INVOICE			DECIMAL(13,2)	= 0
						,@VP_LINE_NO				INT				= 0
						,@VP_VALIDA_CLIENTE			VARCHAR(50)	= ''
						,@VP_VALIDA_TIPO			INT
						,@VP_CONTA					INT			= 0
			
			DECLARE @TBL_MATERIAL_SELECCIONADO_HEADER_RMA  TABLE (
						TBL_K_MATERIAL_SELECCIONADO_RMA		INT IDENTITY(1,1),
						TBL_K_HEADER_RMA					INT
					)
			SET NOCOUNT ON

			DECLARE CU_PACKING_A_FACTURAR CURSOR FOR 
				SELECT	CUS_PART_NO,
						ITEM_NO,
						SUM(QTY) AS QTY_SHIP,
						TOTAL_CAJAS,
						SERIAL_2
				FROM	INVENTARIO_EMBARQUE_RMA				(NOLOCK)
				WHERE	PACKING_NO							= @PP_PACKING_NO
				AND		K_ESTATUS_INVENTARIO_EMBARQUE_RMA	= 3 -- EMBARCADO
				GROUP	BY CUS_PART_NO, ITEM_NO, SERIAL_2, TOTAL_CAJAS
				ORDER	BY ITEM_NO, SERIAL_2
			OPEN CU_PACKING_A_FACTURAR
			FETCH NEXT FROM CU_PACKING_A_FACTURAR INTO	@VP_CU_CUS_PART_NO,	@VP_CU_ITEM_NO,	@VP_CU_QTY_SHIP, @VP_CU_QTY_BOX,	@VP_CU_SERIAL_2
			WHILE @@FETCH_STATUS = 0
			BEGIN
					DECLARE  
							@VP_UNIT_PRICE			DECIMAL(13,2)	= 0
							,@VP_TOTAL_QTY_ORDERED	DECIMAL(13,6)	= 0
							,@VP_TOTAL_QTY_SHIPPED	DECIMAL(13,6)	= 0
							,@VP_FECHA				INT				= FORMAT(CAST(GETDATE() AS DATE), N'yyyyMMdd')
							,@VP_HORA				INT				= FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss')
							,@VP_TOTAL_KIT			DECIMAL(13,2)	= 0
							,@VP_FECHA_REQUEST_DATE DATE			= DATEADD(WK, DATEDIFF(WK, 0, GETDATE()), 0) 
							,@VP_K_HEADER_RMA		INT				= 0
					DECLARE	 @VP_FECHA_REQUEST_INT	INT				= FORMAT(@VP_FECHA_REQUEST_DATE, N'yyyyMMdd')
					---====================================================================================
					DECLARE	 @VP_PRICE_ACTUAL		DECIMAL(13,2)	= 0
							,@VP_PRECIO_MANUAL		DECIMAL(13,2)	= 0
					---====================================================================================
							,@VP_TIPO_ORDEN			INT		= 1
							,@VP_WH_CLIENTE			VARCHAR(50)	= ''
							,@VP_WH_TIPO			INT

				SET	@VP_LINE_NO	+= 1
				
				-- ///////SE OBTIENE EL PRECIO ACTUAL PARA EL ITEM NO/////////////////////////////////////////////////////// 
				SELECT	TOP (1)
						@VP_PRICE_ACTUAL				= PRC_OR_DISC_1 
				FROM	OEPRCFIL_SQL					(NOLOCK)
				WHERE	LTRIM(RTRIM(filler_0001))		LIKE '%' + @VP_CU_ITEM_NO
				AND		LTRIM(RTRIM(filler_0001))		LIKE @PP_CUSTOMER + '%'
				ORDER	BY A4GLIdentity					DESC

				IF @VP_PRICE_ACTUAL IS NULL OR @VP_PRICE_ACTUAL = 0
				BEGIN
					RAISERROR ('ERROR: No fue posible obtener precio del Item No en [OEPRCFIL_SQL] ', 16, 1 ) 
				END			
				-- ///////SE OBTIENEN LOS DATOS DEL ITEM REQUERIDO EN LA ORDEN DE FACTURACION///////////////////////////////////////////////////////
				-- **************************************************************************************************************************************
				--	VERIFICAMOS SI EL PATTERN CONTIENE PRECIO MANUAL.
				SELECT	--@VP_LINE_NO				= RIGHT(LTRIM(RTRIM(SERIAL)),3),
						@VP_K_HEADER_RMA		= DETAILS_RMA.K_HEADER_RMA,
						@VP_PRECIO_MANUAL		= PRECIO_MANUAL,
						@VP_TIPO_ORDEN			= K_TIPO_RMA,
						@VP_WH_CLIENTE			= DETAILS_RMA.CUS_NO,
						@VP_WH_TIPO				= K_TIPO_RMA
				FROM	[DETAILS_RMA]			(NOLOCK)
				INNER JOIN HEADER_RMA			(NOLOCK) ON HEADER_RMA.K_HEADER_RMA	= [DETAILS_RMA].K_HEADER_RMA
				WHERE	K_DETAILS_RMA			=	@VP_CU_SERIAL_2

				IF	( @VP_PRECIO_MANUAL IS NULL )
				BEGIN
					SET	@VP_PRECIO_MANUAL	= 0
				END

				IF	@VP_PRECIO_MANUAL	>	0
				BEGIN
					SET	@VP_PRICE_ACTUAL = @VP_PRECIO_MANUAL
				END						

				SET @VP_TOTAL_KIT			= @VP_CU_QTY_SHIP		*	@VP_PRICE_ACTUAL
				SET @VP_TOTAL_INVOICE		= @VP_TOTAL_INVOICE		+	@VP_TOTAL_KIT
				
				IF @VP_TIPO_ORDEN	= 1
				BEGIN
					SET @VP_TOTAL_KIT			= 0
					SET @VP_TOTAL_INVOICE		= 0
				END
                
				-- /////////VALIDACIÓN QUE SEAN DEL MISMO TIPO Y CLIENTE TODOS LOS REGISTROS.////////////////////////////////////////////////////////////
				IF @VP_CONTA	= 0
				BEGIN
					SET	@VP_CONTA				= @VP_CONTA + 1
					SET	@VP_VALIDA_CLIENTE		= @VP_WH_CLIENTE
					SET	@VP_VALIDA_TIPO			= @VP_WH_TIPO		
				END
				ELSE
				BEGIN
					IF @VP_VALIDA_CLIENTE		<> @VP_WH_CLIENTE
						RAISERROR ('Las ordenes deben pertencer al mismo Cliente', 16, 1 ) 
				
					IF @VP_VALIDA_TIPO			<> @VP_WH_TIPO		
						RAISERROR ('Las órdenes deben pertencer al mismo Tipo (Reemplazo ó Pedido especial)', 16, 1 ) 
				END

				-- /////////CREAR DATOS PARA EL DETALLE DE LA FACTURA////////////////////////////////////////////////////////////
				DECLARE @VP_ORDEN	VARCHAR(15)	= CONVERT(VARCHAR(15),@VP_K_HEADER_RMA)

				DECLARE  @VP_ID_NO			VARCHAR(150) = 'O' + RIGHT('000000' + @VP_ORDEN, 6) + RIGHT(  '00000000' + @VP_INVOICE , 8)  + RIGHT(  '0000' + @VP_LINE_NO , 4) + '0000000'
						,@VP_ITEM_DESC_1	VARCHAR(40)
						,@VP_ITEM_DESC_2	VARCHAR(40)

				SELECT	@VP_ITEM_DESC_1	= LTRIM(RTRIM(ITEM_DESC_1)),
						@VP_ITEM_DESC_2	= LTRIM(RTRIM(ITEM_DESC_2))
				FROM	IMITMIDX_SQL		(NOLOCK)
				WHERE	LTRIM(RTRIM(item_no)) = @VP_CU_ITEM_NO 

				-- ///////SE INGRESAN LOS DETALLES DE LA FACTURA EN oelinhst_sql///////////////////////////////////////////////////////		
				INSERT INTO oelinhst_sql
						( ord_type,	ord_no, line_seq_no, item_no, item_filler, loc, pick_seq, cus_item_no, item_desc_1, item_desc_2, qty_ordered, qty_to_ship, unit_price,
						discount_pct,request_dt,qty_bkord,qty_return_to_stk,bkord_fg,uom,uom_ratio,unit_cost,unit_weight,comm_calc_type,comm_pct_or_amt,promise_dt,tax_fg,stocked_fg,controlled_fg,select_cd,tot_qty_ordered,
						tot_qty_shipped,tax_fg_1,tax_fg_2,tax_fg_3,orig_price,copy_to_bm_fg,explode_kit,mfg_ord_no,allocate_dt,last_post_dt,post_to_inv_qty,posted_to_inv,tot_qty_posted,qty_allocated,components_alloc,bin_fg,
						cost_meth,ser_lot_cd,mult_ftr_fg,line_type,prod_cat,pur_or_mfg,reason_cd,feature_return,rec_inspection,ship_from_stk,mult_release,req_ship_dt,qty_from_stk,user_def_fld_1,user_def_fld_2,user_def_fld_3,
						user_def_fld_4,user_def_fld_5,picked_dt,shipped_dt,billed_dt,update_fg,prc_cd_orig_price,tax_sched,cus_no,tax_amt,qty_bkord_fg,line_no,mfg_method,forced_demand,conf_pick_dt,item_release_no,bin_ser_lot_comp,
						offset_used_fg,ecs_space,sfc_order_status,total_cost,po_ord_no,rma_line_seq_no,vend_no,hst_dt,hst_tm,id_no,inv_no,filler_0001,user_name,jnl_cd,sls_amt,cost_amt	)
				SELECT	TOP (1)
				--								RIGHT(LTRIM(RTRIM(SERIAL)),3)
				--		ord_type,	ord_no,		line_seq_no,	item_no, item_filler, loc,	pick_seq,	cus_item_no, item_desc_1,		item_desc_2,		qty_ordered,		qty_to_ship,
						'I',		'00000000',	@VP_LINE_NO,	ITEM_NO, '',			'MFP',	NULL,		CUS_ITEM_NO, @VP_ITEM_DESC_1,	@VP_ITEM_DESC_2,	CANTIDAD_ORDENADA,	CANTIDAD_ENVIADA, 
				--		unit_price,			discount_pct,	request_dt,				qty_bkord,	qty_return_to_stk,	bkord_fg,	uom,	uom_ratio,	unit_cost,	unit_weight,
						@VP_PRICE_ACTUAL,	0,				@VP_FECHA_REQUEST_INT,	0,			0,					NULL,		'EA',	'1.0000',	0,			0,	
				--		comm_calc_type,	comm_pct_or_amt,	promise_dt,				tax_fg,	stocked_fg,	controlled_fg,	select_cd,	tot_qty_ordered,
						NULL,			0,					@VP_FECHA,				NULL,	NULL,		NULL,			'S',		CANTIDAD_ORDENADA,
				--		tot_qty_shipped,	tax_fg_1,	tax_fg_2,	tax_fg_3,	orig_price,	copy_to_bm_fg,	explode_kit,	mfg_ord_no,	allocate_dt,	last_post_dt,			post_to_inv_qty,	
						CANTIDAD_ENVIADA,	NULL,		NULL,		NULL,		0,			NULL,			NULL,			0,			0,				@VP_FECHA,				0,					
				--		posted_to_inv,	tot_qty_posted,	qty_allocated,	components_alloc,	bin_fg,
						0,				0,				0,				0,					NULL,
				--		cost_meth,	ser_lot_cd,	mult_ftr_fg,	line_type,	prod_cat,	pur_or_mfg,	reason_cd,	feature_return,	rec_inspection,	ship_from_stk,	mult_release,	req_ship_dt,
						NULL,		NULL,		NULL,			'I',		MODELNO,	NULL,		NULL,		NULL,			NULL,			NULL,			NULL,			@VP_FECHA,	
				--		qty_from_stk,	user_def_fld_1(@VP_STANDARD_PACK),		user_def_fld_2,	user_def_fld_3,	user_def_fld_4,		user_def_fld_5,		picked_dt,	shipped_dt,	billed_dt,	update_fg,	prc_cd_orig_price,
						0,				CANTIDAD_ORDENADA,						NULL,			NULL,			@PP_PO_NUMBER,		CANTIDAD_ENVIADA,	0,			0,			@VP_FECHA,	NULL,		@VP_PRICE_ACTUAL,
				--		tax_sched,	cus_no,	tax_amt,	qty_bkord_fg,	line_no(@VP_LINE_NO),	mfg_method,	forced_demand,	conf_pick_dt,	item_release_no,	bin_ser_lot_comp,
						NULL,		CUS_NO,	0,			'',				@VP_LINE_NO,'SF',	NULL,			0,				1,					'',
				--		offset_used_fg,	ecs_space,	sfc_order_status,	total_cost,	po_ord_no,	rma_line_seq_no,	vend_no,	hst_dt,		hst_tm,	
						NULL,			NULL,		NULL,				0,			'',			0,					NULL,		@VP_FECHA,	@VP_HORA,
				--		id_no,		inv_no,			filler_0001,	user_name,		jnl_cd,						sls_amt,		cost_amt
						@VP_ID_NO,	@VP_INVOICE,	'Y00',			@PP_D_USUARIO,	LTRIM(RTRIM(@VP_JNL_CD)),	@VP_TOTAL_KIT,	'0.00' 
				FROM	DETAILS_RMA		(NOLOCK)
				WHERE	K_DETAILS_RMA			= @VP_CU_SERIAL_2
				AND		K_STATUS_RMA			= 35
				IF @@ROWCOUNT = 0
				BEGIN
					RAISERROR ('ERROR: No fue posible agregar el dato del Item No. Facturado en [oelinhst_sql]-RMA', 16, 1 )
				END

				-- /////////ACTUALIZAMOS EL ESTATUS DE LA TABLA DETAILS_RMA////////////////////////////////////////////////////////////
				UPDATE	DETAILS_RMA
				SET		K_STATUS_RMA	= 40,
						PO_NUMBER		= @PP_PO_NUMBER
				WHERE	K_DETAILS_RMA	= @VP_CU_SERIAL_2
				AND		K_STATUS_RMA	= 35
				IF @@ROWCOUNT = 0
					RAISERROR ('No fue posible actualizar el estatus del detalle, verifique...', 16, 1 ) 

				-- /////////PARA INSERTAR LOS ENCABEZADOS DE LOS DETALLES QUE HAN SIDO EMBARCADOS////////////////////////////////////////////////////////////
				IF	(SELECT COUNT(K_DETAILS_RMA) FROM DETAILS_RMA	(NOLOCK)	WHERE K_HEADER_RMA	= @VP_K_HEADER_RMA)	= 
					(SELECT COUNT(K_DETAILS_RMA) FROM DETAILS_RMA	(NOLOCK)	WHERE K_HEADER_RMA	= @VP_K_HEADER_RMA AND	K_STATUS_RMA = 40 )
				BEGIN
					INSERT	INTO	@TBL_MATERIAL_SELECCIONADO_HEADER_RMA
					VALUES	(	@VP_K_HEADER_RMA	)
					IF @@ROWCOUNT = 0
						RAISERROR ('No fue posible encontrar el encabezado del pattern a embarcar [INVENTARIO_EMBARQUE].', 16, 1 ) 
				END

				FETCH NEXT FROM CU_PACKING_A_FACTURAR INTO	@VP_CU_CUS_PART_NO,	@VP_CU_ITEM_NO,	@VP_CU_QTY_SHIP, @VP_CU_QTY_BOX,	@VP_CU_SERIAL_2
			END			
			CLOSE CU_PACKING_A_FACTURAR
			DEALLOCATE CU_PACKING_A_FACTURAR

		-- ///////SE ASIGNA LA FACTURA AL PACKING///////////////////////////////////////////////////////
		UPDATE	INVENTARIO_EMBARQUE_RMA
		SET		K_ESTATUS_INVENTARIO_EMBARQUE_RMA	= 4, -- FACTURADO
				INVOICE_NO							= @VP_INVOICE,
				F_CAMBIO							= GETDATE()
		WHERE	PACKING_NO							= @PP_PACKING_NO
		AND		K_ESTATUS_INVENTARIO_EMBARQUE_RMA	= 3 --EMBARCADO
		IF @@ROWCOUNT = 0
			RAISERROR ('No fue posible asignar la Factura al Packing en [INVENTARIO_EMBARQUE].', 16, 1 )

		-- ///////SE INGRESA EL EMCABEZADO DE LA FACTURA EN OEHDRHST_SQL///////////////////////////////////////////////////////		
		DECLARE  @VP_ID_NO_HDR			VARCHAR(150)
		--SET @VP_ID_NO_HDR = '' --'" & Trim(txtCustomer.Text) & "      " & DateYMD(Date.Today) & Format(TimeOfDay, "HHmmss") & inv.ToString.PadLeft(8, "0") & "I" & inv.ToString.PadLeft(8, "0") & "'
		SET @VP_ID_NO_HDR = @PP_CUSTOMER + '      ' + CONVERT(VARCHAR(10), @VP_FECHA) + CONVERT(VARCHAR(10), @VP_HORA) + RIGHT(  '00000000' + @VP_INVOICE , 8) + 'I' + RIGHT(  '00000000' + @VP_INVOICE , 8)
						
		INSERT INTO OEHDRHST_SQL(	
		ord_type,ord_no,status,entered_dt,ord_dt,apply_to_no,oe_po_no,cus_no,bal_meth,bill_to_name,bill_to_addr_1,bill_to_addr_2,bill_to_addr_3,		--13
                          
		bill_to_country,cus_alt_adr_cd,ship_to_name,ship_to_addr_1,ship_to_addr_2,ship_to_addr_3,ship_to_country,shipping_dt,ship_via_cd,ar_terms_cd,	--10
		
		frt_pay_cd,ship_instruction_1,ship_instruction_2,slspsn_no,slspsn_pct_comm,	slspsn_comm_amt,slspsn_no_2,slspsn_pct_comm_2,slspsn_comm_amt_2,slspsn_no_3,	--10
		slspsn_pct_comm_3,slspsn_comm_amt_3,tax_cd,tax_pct,tax_cd_2,tax_pct_2,tax_cd_3,tax_pct_3,discount_pct,job_no,mfg_loc,profit_center,				--12
							-- AQUÍ VA EL TOTAL DE LA FACTURA
		dept,ar_reference,	tot_sls_amt,	--	3
		tot_sls_disc,tot_tax_amt,tot_cost,tot_weight,misc_amt,misc_mn_no,misc_sb_no,misc_dp_no,frt_amt,frt_mn_no,frt_sb_no,frt_dp_no,sls_tax_amt_1,sls_tax_amt_2,sls_tax_amt_3,		--15
		comm_pct,comm_amt,cmt_1,cmt_2,cmt_3,payment_amt,payment_disc_amt,chk_no,chk_dt,cash_mn_no,cash_sb_no,cash_dp_no,picked_dt,billed_dt,inv_no,inv_dt,selection_cd,posted_dt,	--18
		part_posted_fg,ship_to_freefrm_fg,bill_to_freefrm_fg,copy_to_bm_fg,edi_fg,closed_fg,accum_misc_amt,accum_frt_amt,accum_tot_tax_amt,accum_sls_tax_amt,accum_tot_sls_amt,		--11
		hold_fg,prepayment_fg,lost_sale_cd,orig_ord_type,orig_ord_dt,orig_ord_no,award_probability,oe_cash_no,exch_rt_fg,curr_cd,	--10
              
		orig_trx_rt,curr_trx_rt,tax_sched,user_def_fld_1,user_def_fld_2,user_def_fld_3,user_def_fld_4,user_def_fld_5,deter_rate_by,form_no,tax_fg,sls_mn_no,sls_sb_no,sls_dp_no,shipped_dt,	--15
		-- AQUÍ VA EL TOTAL DE LA FACTURA
		tot_dollars,mult_loc_fg,tot_tax_cost,hist_load_record,	--4
              
		pre_select_status,packing_no,deliv_ar_terms_cd,inv_batch_id,user_name,jnl_src,rma_no,filler_0001,hist_dt,hist_tm,id_no,trx_posted_fg	)	--12
        SELECT TOP (1)
	--	ord_type,	ord_no,		status,	entered_dt,	ord_dt,		apply_to_no,	@PP_PO_NUMBER,	cus_no,			bal_meth,
		'O',		'00000000',	1,		@VP_FECHA,	@VP_FECHA,	0,				@PP_PO_NUMBER,	@PP_CUSTOMER,	'O',
	--	bill_to_name,	bill_to_addr_1,	bill_to_addr_2,	bill_to_addr_3,	bill_to_country,
		ADRESS_BILL.D_ARCUSFIL_ADDRESS_NAME		,--	BILL_TO_NAME,
		ADRESS_BILL.D_ARCUSFIL_ADDRESS_01		,--	BILL_TO_ADDR_1,
		ADRESS_BILL.D_ARCUSFIL_ADDRESS_02		,--	BILL_TO_ADDR_2,
		ADRESS_BILL.D_ARCUSFIL_ADDRESS_03		,--	BILL_TO_ADDR_3,
		ADRESS_BILL.D_ARCUSFIL_ADDRESS_04		,--	BILL_TO_COUNTRY,
	--	cus_alt_adr_cd,
		'',
	--	ship_to_name,	ship_to_addr_1,	ship_to_addr_2,	ship_to_addr_3,	ship_to_country,
		ADRESS_SHIP.D_ARCUSFIL_ADDRESS_NAME		,-- SHIP_TO_NAME,
		ADRESS_SHIP.D_ARCUSFIL_ADDRESS_01		,-- SHIP_TO_ADDR_1,
		ADRESS_SHIP.D_ARCUSFIL_ADDRESS_02		,-- SHIP_TO_ADDR_2,
		ADRESS_SHIP.D_ARCUSFIL_ADDRESS_03		,-- SHIP_TO_ADDR_3,
		ADRESS_SHIP.D_ARCUSFIL_ADDRESS_04		,-- SHIP_TO_ADDR_4,
	--	shipping_dt,	ship_via_cd,	ar_terms_cd,				frt_pay_cd,	ship_instruction_1,	ship_instruction_2,
		@VP_FECHA,		'LOC',			S_ARCUSFIL_TERMS_PERIOD,	NULL,		NULL,				NULL,
	--	slspsn_no,	slspsn_pct_comm,	slspsn_comm_amt,	slspsn_no_2,	slspsn_pct_comm_2,	slspsn_comm_amt_2,	slspsn_no_3,	slspsn_pct_comm_3,	slspsn_comm_amt_3,
		SLSPSN_NO,	100,				0,					NULL,			0,					0.00,				NULL,			0.00,				0.00,
	--	tax_cd,	tax_pct,	tax_cd_2,	tax_pct_2,	tax_cd_3,	tax_pct_3,	discount_pct,	job_no,	mfg_loc,	profit_center,
		'0%',	0.0000,		NULL,		0.0000,		NULL,		0.0000,		0.00,			NULL,	'MFP',		NULL,
	--	dept,	ar_reference,		tot_sls_amt,
		NULL,	NULL,				@VP_TOTAL_INVOICE,
	--	tot_sls_disc,	tot_tax_amt,	tot_cost,	tot_weight,	misc_amt,	misc_mn_no,	misc_sb_no,	misc_dp_no,	frt_amt,	frt_mn_no,	frt_sb_no,	frt_dp_no,
		0,				0,				0,			0,			0,			NULL,		NULL,		NULL,		0,			NULL,		NULL,		NULL,
	--	sls_tax_amt_1,	sls_tax_amt_2,	sls_tax_amt_3,	comm_pct,	comm_amt,
		0,				0,				0,				0,			0,
	--	cmt_1,	cmt_2,	cmt_3,	payment_amt,	payment_disc_amt,	chk_no,	chk_dt,	cash_mn_no,	cash_sb_no,	cash_dp_no,	picked_dt,	billed_dt,	inv_no,			inv_dt,
		NULL,	NULL,	NULL,	'0.00',			'0.00',				0,		0,		NULL,		NULL,		NULL,		0,			@VP_FECHA,	@VP_INVOICE,	@VP_FECHA,
	--	selection_cd,	posted_dt,	part_posted_fg,	ship_to_freefrm_fg,	bill_to_freefrm_fg,	copy_to_bm_fg,	edi_fg,	closed_fg,
		'Z',			@VP_FECHA,	NULL,			NULL,				NULL,				NULL,			NULL,	NULL,
	--	accum_misc_amt,	accum_frt_amt,	accum_tot_tax_amt,	accum_sls_tax_amt,	accum_tot_sls_amt,	hold_fg,	prepayment_fg,	lost_sale_cd,	orig_ord_type,
		0,				0,				0,					0,					@VP_TOTAL_INVOICE,	NULL,		'N',			NULL,			'O',
	--	orig_ord_dt,	orig_ord_no,	award_probability,	oe_cash_no,	exch_rt_fg,	curr_cd,			
		0,				'00000000',		0,					0,			NULL,		'USD',
	--	orig_trx_rt,	curr_trx_rt,	tax_sched,	user_def_fld_1,	user_def_fld_2,	user_def_fld_3,	user_def_fld_4,	user_def_fld_5,	deter_rate_by,
		1.0000,		1.0000,		NULL,		NULL,			NULL,			NULL,			NULL,			@PP_PACKING_NO,	'I',
	--	form_no,	tax_fg,	sls_mn_no,	sls_sb_no,	sls_dp_no,	shipped_dt,		tot_dollars,
		26,			'N',	NULL,		NULL,		NULL,		0,				@VP_TOTAL_INVOICE,
	--	mult_loc_fg,	tot_tax_cost,	hist_load_record,	pre_select_status,	packing_no,	deliv_ar_terms_cd,	inv_batch_id,			user_name,
		NULL,			0,				NULL,				1,					0,			NULL,				LEFT(@PP_D_USUARIO,8),	@PP_D_USUARIO,
	--	jnl_src,		rma_no,	filler_0001,	hist_dt,	hist_tm,	id_no,		trx_posted_fg	)
		@VP_JNL_CD,		0,		NULL,			@VP_FECHA,	@VP_HORA,	@VP_ID_NO,	''
		FROM	INVENTARIO_EMBARQUE_RMA				(NOLOCK)
		INNER JOIN	ARCUSFIL_SQL					(NOLOCK) ON ARCUSFIL_SQL.CUS_NO	= INVENTARIO_EMBARQUE_RMA.CUSTOMER
		INNER JOIN ARCUSFIL_ADDRESS AS ADRESS_BILL	(NOLOCK) ON ARCUSFIL_SQL.A4GLIdentity	= ADRESS_BILL.A4GLIdentity
		AND			ADRESS_BILL.K_ADDRESS_TYPE	= 1		-- BILL_TO			
		INNER JOIN ARCUSFIL_ADDRESS AS ADRESS_SHIP	(NOLOCK) ON ARCUSFIL_SQL.A4GLIdentity	= ADRESS_SHIP.A4GLIdentity
		AND			ADRESS_SHIP.K_ADDRESS_TYPE	= 2		-- SHIP_TO
		INNER JOIN	ARCUSFIL_TERMS_PERIOD			(NOLOCK) ON ARCUSFIL_SQL.K_ARCUSFIL_TERMS_PERIOD	= ARCUSFIL_TERMS_PERIOD.K_ARCUSFIL_TERMS_PERIOD
		WHERE	INVENTARIO_EMBARQUE_RMA.INVOICE_NO		= @VP_INVOICE
		--WHERE	INVENTARIO_EMBARQUE_RMA.packing_NO		= 'R-JL0803-1'
		IF @@ROWCOUNT = 0
			RAISERROR ('ERROR: No fue posible agregar la Factura en [OEHDRHST_SQL] ', 16, 1 ) 
			
		--///////////////// PARA ACTUALIZAR EL HEADER DE LA ORDEN ///////////////////////////////////////////////////////////////////
		IF (SELECT COUNT(TBL_K_HEADER_RMA) FROM @TBL_MATERIAL_SELECCIONADO_HEADER_RMA) > 0
			BEGIN
				UPDATE	HEADER_RMA
				SET		K_STATUS_RMA		= 40
				WHERE	K_HEADER_RMA		IN	( SELECT TBL_K_HEADER_RMA	FROM	@TBL_MATERIAL_SELECCIONADO_HEADER_RMA	)
				AND		K_STATUS_RMA		<= 35
				IF @@ROWCOUNT = 0
					RAISERROR ('No fue posible asignar el Estatus al material seleccionado en [INVENTARIO_EMBARQUE].', 16, 1 ) 
			END
		-- /////////////SE INGRESA EL LOG EN INVENTARIO_EMBARQUE_LOG_RMA//////////////////////////////
		INSERT INTO INVENTARIO_EMBARQUE_LOG_RMA	(	[K_ESTATUS_INVENTARIO_EMBARQUE], [ITEM_NO], [QTY], [CUBE_WIDTH], [SERIAL_1],		
												[SERIAL_2],	[COLOR], [CUSTOMER], [CUS_PART_NO],	[PROD_CAT],
												[D_PROD_CAT], [N_EMBARQUE], [PACKING_NO], [INVOICE_NO], [F_INVENTARIO_EMBARQUE_LOG_RMA],	
												-- ===========================
												[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
												[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )	
										SELECT	[K_ESTATUS_INVENTARIO_EMBARQUE_RMA], [ITEM_NO], [QTY], [CUBE_WIDTH], [SERIAL_1],		
												[SERIAL_2],	[COLOR], [CUSTOMER], [CUS_PART_NO],	[PROD_CAT],
												[D_PROD_CAT], N_EMBARQUE, [PACKING_NO], [INVOICE_NO], [F_INVENTARIO_EMBARQUE_RMA],
												-- ===========================
												@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
												0, 0, NULL 
										FROM	INVENTARIO_EMBARQUE_RMA		(NOLOCK)
										WHERE	INVOICE_NO					= @VP_INVOICE
										AND		PACKING_NO					= @PP_PACKING_NO
		IF @@ROWCOUNT = 0
			RAISERROR ('ERROR: No fue posible guardar el Log del Material Facturado en [INVENTARIO_EMBARQUE_LOG_RMA] ', 16, 1 ) 
		
		-- //////SE OBTIENE EL NUMERO DE RELOJ DEL USUARIO PEARL/////////////////////////////////////
		DECLARE @VP_NUMERO_RELOJ INT = 0;
		SELECT @VP_NUMERO_RELOJ = K_EMPLEADO_PEARL				
		FROM BD_GENERAL.DBO.USUARIO_PEARL 
		WHERE K_USUARIO_PEARL = @PP_K_USUARIO_ACCION

		-- ///////SE GUARDA EL LOG DEL MATERIAL EMBARCADO PARA EL RASTREO//////////////////////////////////////////////
		EXECUTE [dbo].[PG_IN_EVENTO_EMBARCADO_FACTURADO_KIT_PROGRAMADO_RMA]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		440,	-- TIPO DE EVENTO
																		@VP_INVOICE, 'FACTURACION RMA', @VP_NUMERO_RELOJ, ''
		
		INSERT INTO [MATERIAL_PROGRAMADO_LOG]	
			(	[K_TIPO_EVENTO_KIT], [SERIAL], [ITEM_NO], [USUARIO_EVENTO], [ESTACION], 
				[K_RESPONSABLE], [CODIGO_ETIQUETA], [F_LOG],			
				-- ===========================
				[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )	
		SELECT	440, [SERIAL_1], [ITEM_NO], INVOICE_NO, 'FACTURACION RMA', 
				@VP_NUMERO_RELOJ, '', GETDATE(),
				-- ===========================
				@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
				0, 0, NULL 
		FROM	INVENTARIO_EMBARQUE_RMA			(NOLOCK)
		WHERE	INVOICE_NO						= @VP_INVOICE
		AND		PACKING_NO						= @PP_PACKING_NO

		IF @@ROWCOUNT = 0
			RAISERROR ('ERROR: No fue posible guardar el log de la Factura en [MATERIAL_PROGRAMADO_LOG]', 16, 1 ) 
		-- //////////////////////////////////////////////////////////////
		-- //////////////////////////////////////////////////////////////

		COMMIT TRANSACTION 
		END TRY
	
		BEGIN CATCH
			/* Ocurrió un error, deshacemos los cambios*/ 
			ROLLBACK TRANSACTION
			DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
			SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
			SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_UP_INVENTARIO_EMBARQUE_INVOICE // ' + @VP_ERROR_TRANS
		END CATCH	
	END				-- IF SECCION#2
	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN		
		--SET		@VP_MENSAJE = 'No es posible [Asignar] el Packing al material en [INVENTARIO_EMBARQUE]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#INVOICE.'+ @VP_INVOICE + ']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_INVOICE AS CLAVE
	-- //////////////////////////////////////////////////////////////	
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_EVENTO_EMBARCADO_FACTURADO_KIT_PROGRAMADO_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_EVENTO_EMBARCADO_FACTURADO_KIT_PROGRAMADO_RMA]
GO
CREATE PROCEDURE [dbo].[PG_IN_EVENTO_EMBARCADO_FACTURADO_KIT_PROGRAMADO_RMA]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TIPO_EVENTO_KIT			INT,
	@PP_USUARIO_EVENTO			VARCHAR(100),
	@PP_ESTACION				VARCHAR(100),
	@PP_K_RESPONSABLE			INT,
	@PP_CODIGO_ETIQUETA			VARCHAR(255)
AS
	-- ///////////////////////////////////////////
	DECLARE @VP_ITEM_NO VARCHAR(50) = ''
	DECLARE @VP_SERIAL VARCHAR(50) = ''
	
	IF @PP_TIPO_EVENTO_KIT = 430 
		BEGIN
			DECLARE CU_EVENTO_EMB_FACT CURSOR FOR 
				SELECT  ITEM_NO, SERIAL_1
				FROM	INVENTARIO_EMBARQUE_RMA		(NOLOCK) 
				WHERE	PACKING_NO = @PP_USUARIO_EVENTO
		END
	ELSE
		BEGIN
			DECLARE CU_EVENTO_EMB_FACT CURSOR FOR 
				SELECT  ITEM_NO, SERIAL_1
				FROM	INVENTARIO_EMBARQUE_RMA			(NOLOCK)
				WHERE	INVOICE_NO = @PP_USUARIO_EVENTO
		END

	OPEN CU_EVENTO_EMB_FACT
	FETCH NEXT FROM CU_EVENTO_EMB_FACT INTO  @VP_ITEM_NO, @VP_SERIAL
	
	WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE @VP_N_SERIAL_EXISTE INT = 0

			SELECT  @VP_N_SERIAL_EXISTE = COUNT([K_MATERIAL_PROGRAMADO]) 
			FROM [MATERIAL_PROGRAMADO] 
			WHERE SERIAL = @VP_SERIAL

			IF ( @VP_N_SERIAL_EXISTE IS NULL OR @VP_N_SERIAL_EXISTE = 0 )
				BEGIN
					INSERT INTO [MATERIAL_PROGRAMADO]	
							(					
								[K_TIPO_EVENTO_KIT],			
								-- =====================				
								[SERIAL],					
								[ITEM_NO],				
								[USUARIO_EVENTO],			
								[ESTACION],				
								[K_RESPONSABLE],			
								[CODIGO_ETIQUETA],		
								[F_EVENTO],			
								-- ===========================
								[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
								[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )	
						VALUES	
							(	@PP_TIPO_EVENTO_KIT,				
								@VP_SERIAL,				
								@VP_ITEM_NO,				
								@PP_USUARIO_EVENTO,			
								@PP_ESTACION,						
								@PP_K_RESPONSABLE,		
								@PP_CODIGO_ETIQUETA,								
								GETDATE(),
								-- ===========================				
								@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
								0, NULL, NULL )	
				
					IF @@ROWCOUNT = 0
						RAISERROR ('ERROR SP: PG_IN_EVENTO_EMBARCADO_FACTURADO_KIT_PROGRAMADO_LOG_RMA', 16, 1 ) --MENSAJE - Severity -State.
				END
			ELSE
				BEGIN
					UPDATE [MATERIAL_PROGRAMADO]	
						SET [K_TIPO_EVENTO_KIT]	= @PP_TIPO_EVENTO_KIT,			
							-- =====================			
							[ITEM_NO]			= @VP_ITEM_NO,				
							[USUARIO_EVENTO]	= @PP_USUARIO_EVENTO,			
							[ESTACION]			= @PP_ESTACION,				
							[K_RESPONSABLE]		= @PP_K_RESPONSABLE,			
							[CODIGO_ETIQUETA]	= @PP_CODIGO_ETIQUETA,		
							[F_EVENTO]			= GETDATE(),			
							-- ===========================
							[K_USUARIO_CAMBIO]	= @PP_K_USUARIO_ACCION, 
							[F_CAMBIO]			= GETDATE()
					WHERE SERIAL = @VP_SERIAL

					IF @@ROWCOUNT = 0
						RAISERROR ('ERROR SP: PG_IN_EVENTO_EMBARCADO_FACTURADO_KIT_PROGRAMADO_LOG_RMA', 16, 1 ) --MENSAJE - Severity -State.
				END

			FETCH NEXT FROM CU_EVENTO_EMB_FACT INTO  @VP_ITEM_NO, @VP_SERIAL
		END
	CLOSE CU_EVENTO_EMB_FACT
	DEALLOCATE CU_EVENTO_EMB_FACT

	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO


---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> ACTUALIZAR / INFORMACIÓN PARA FACTURA.
---- //////////////////////////////////////////////////////////////
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_INVOICE_DETAILS_RMA]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_LI_INVOICE_DETAILS_RMA]
--GO												-- '00318798','553085', 'A-47635', 'WK1208-1', 'MAGN03'
----		 EXECUTE [DBO].[PG_LI_INVOICE_DETAILS_RMA] 0,0, '00318769','XXXXXXXX','JL1204-1', 'IRVI02'
--CREATE PROCEDURE [dbo].[PG_LI_INVOICE_DETAILS_RMA]
--	@PP_K_SISTEMA_EXE				INT,
--	@PP_K_USUARIO_ACCION			INT,
--	-- ===========================
--	--@PP_ORDEN_FACTURACION			VARCHAR(50),
--	@PP_INVOICE_NO					VARCHAR(50),
--	@PP_PACKING_NO					VARCHAR(50),
--	@PP_CUSTOMER					VARCHAR(50)
--AS
--	-- =========================================		
	
--	IF @PP_INVOICE_NO = 'XXXXXXXX'
--		BEGIN
--			DECLARE @VP_CUS_PART_NO	VARCHAR(100) = ''
--			DECLARE @VP_ITEM_NO		VARCHAR(100) = ''
--			DECLARE @VP_QTY_SHIP	INT = 0

--			DECLARE @VP_TBL_DETALLE_INVOICE TABLE(
--				Item_No			VARCHAR(100),
--				Item_Desc_1		VARCHAR(100),
--				Cus_Item_No		VARCHAR(100),
--				Qty_To_Ship		VARCHAR(20),
--				UOM_MANUAL		VARCHAR(10),
--				Unit_Price		VARCHAR(10),
--				TOTAL_KIT		DECIMAL(13,2)
--			)

--			-- ///////////////////////////////////////////
--			DECLARE CU_MATERIAL_A_FACTURAR CURSOR 
--			FOR SELECT	CUS_PART_NO, 
--						ITEM_NO,
--						SUM(QTY) AS QTY_SHIP
--				FROM	INVENTARIO_EMBARQUE
--				WHERE	PACKING_NO = @PP_PACKING_NO
--				GROUP BY CUS_PART_NO, ITEM_NO
			
--			OPEN CU_MATERIAL_A_FACTURAR
--			FETCH NEXT FROM CU_MATERIAL_A_FACTURAR INTO @VP_CUS_PART_NO, @VP_ITEM_NO, @VP_QTY_SHIP
			
--			WHILE @@FETCH_STATUS = 0
--				BEGIN
--					DECLARE @VP_ITEM_DESC_1 VARCHAR(150) = ''
--					DECLARE @VP_BPO_NUMBER	VARCHAR(50) = ''

--					SELECT @VP_ITEM_DESC_1 = LTRIM(RTRIM(ITEM_DESC_1)),
--							@VP_BPO_NUMBER = LTRIM(RTRIM(ISNULL(filler_0003, '')))
--					FROM IMITMIDX_SQL 
--					WHERE LTRIM(RTRIM(item_no)) = @VP_ITEM_NO

--					-- ///////////////////////////////////////////
--					DECLARE @VP_PRECIO_UNITARIO DECIMAL(13,2) = 0 -- REVISAR CALCULOS PORQUE EL PRECIO ESTA A 6 DECIMALES
--					SELECT TOP 1 @VP_PRECIO_UNITARIO = PRC_OR_DISC_1
--					FROM	OEPRCFIL_SQL 
--					WHERE	LTRIM(RTRIM(filler_0001)) LIKE '%' + @VP_ITEM_NO 
--					AND		LTRIM(RTRIM(filler_0001)) LIKE @PP_CUSTOMER + '%'
--					ORDER BY A4GLIdentity DESC

--					-- ///////////////////////////////////////////
--					DECLARE @VP_TOTAL_KIT DECIMAL(13,2) = 0
--					SET @VP_TOTAL_KIT = @VP_QTY_SHIP * @VP_PRECIO_UNITARIO

--					INSERT INTO @VP_TBL_DETALLE_INVOICE 
--						SELECT	@VP_ITEM_NO AS Item_No,
--								@VP_ITEM_DESC_1 AS Item_Desc_1,
--								-- =========================================
--								( CASE WHEN @PP_CUSTOMER = 'FAUR01' THEN
--											CONCAT(@VP_CUS_PART_NO, ' (', @VP_BPO_NUMBER, ')') 
--										ELSE @VP_CUS_PART_NO END ) AS Cus_Item_No,
--								-- =========================================
--								@VP_QTY_SHIP AS Qty_To_Ship,
--								'EA' AS UOM_MANUAL,
--								@VP_PRECIO_UNITARIO AS Unit_Price,
--								@VP_TOTAL_KIT AS TOTAL_KIT

--					FETCH NEXT FROM CU_MATERIAL_A_FACTURAR INTO @VP_CUS_PART_NO, @VP_ITEM_NO, @VP_QTY_SHIP
	
--				END
				
--				CLOSE CU_MATERIAL_A_FACTURAR
--				DEALLOCATE CU_MATERIAL_A_FACTURAR

--				-- ///////////////////////////////////////////
--				SELECT *
--				FROM @VP_TBL_DETALLE_INVOICE
--		END
--	ELSE
--		BEGIN
--			SELECT	
--					OELINHST_SQL.Item_No,
--					OELINHST_SQL.Item_Desc_1,
--					-- =========================================
--					( CASE WHEN @PP_CUSTOMER = 'FAUR01' THEN
--								CONCAT(LTRIM(RTRIM(OELINHST_SQL.Cus_Item_No)), ' (', LTRIM(RTRIM(ISNULL(filler_0003, ''))) , ')') 
--						ELSE LTRIM(RTRIM(OELINHST_SQL.Cus_Item_No)) END ) AS Cus_Item_No,
--					-- =========================================
--					OELINHST_SQL.Qty_To_Ship,
--					'EA'	AS UOM_MANUAL,
--					OELINHST_SQL.Unit_Price,
--					SLS_AMT	AS	TOTAL_KIT
--			-- =========================================-- =========================================
--			FROM	OELINHST_SQL
--			LEFT JOIN IMITMIDX_SQL ON LTRIM(RTRIM(IMITMIDX_SQL.item_no)) = LTRIM(RTRIM(OELINHST_SQL.item_no))
--			WHERE	OELINHST_SQL.Inv_No	= @PP_INVOICE_NO
--			AND		LTRIM(RTRIM(CUS_NO)) = @PP_CUSTOMER
--			ORDER BY OELINHST_SQL.Line_Seq_No
--		END

	
--	-- /////////////////////////////////////////////////////////////////////
--GO

