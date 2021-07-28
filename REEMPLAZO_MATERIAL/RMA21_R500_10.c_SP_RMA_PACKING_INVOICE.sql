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
--	[PG_UP_INVENTARIO_EMBARQUE_PACKING_RMA]
--	[PG_LI_DETAILS_RMA_INVOICE]
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
		--SELECT  DISTINCT	DETAILS_RMA.JOBNO,
		--					D_TIPO_RMA,
		--					DETAILS_RMA.CUS_NO,
		--					0	AS [CHECK]
		--FROM	DETAILS_RMA		(NOLOCK)
		--INNER JOIN	HEADER_RMA	ON HEADER_RMA.K_HEADER_RMA	= DETAILS_RMA.K_HEADER_RMA
		--INNER JOIN	TIPO_RMA	ON HEADER_RMA.K_TIPO_RMA	= TIPO_RMA.K_TIPO_RMA
		--WHERE	DETAILS_RMA.K_STATUS_RMA	= @PP_K_STATUS_RMA	--13
		--AND		HEADER_RMA.K_TIPO_RMA		= @PP_K_TIPO_RMA

		
		SELECT  DISTINCT	LEFT(SERIAL_1,5)	AS JOBNO,
					--DETAILS_RMA.JOBNO,
					--D_TIPO_RMA,
					CUSTOMER					AS CUS_NO,
					--DETAILS_RMA.CUS_NO,
					0	AS [CHECK]
		FROM	INVENTARIO_EMBARQUE_RMA		(NOLOCK)
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
--		 EXECUTE [dbo].[PG_LI_DETAILS_RMA_PACKING] 0,139, '34659/35515'
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
				(	SELECT TOP (1) ITEM_NO 
					FROM	CCPRDSTR_SQL				(NOLOCK)
					WHERE	ccprdstr_sql.CUS_NO			= DETAILS_RMA.CUS_NO
					AND		ccprdstr_sql.MODELNO		= DETAILS_RMA.MODELNO
					AND		ccprdstr_sql.VERSIONNO		= DETAILS_RMA.VERSIONNO	
					AND		ccprdstr_sql.COMP_ITEM_NO	= DETAILS_RMA.ITEM_NO					
					) AS KIT,
				[DETAILS_RMA].* 
		FROM	[DETAILS_RMA]		(NOLOCK)
		INNER JOIN	IMITMIDX_SQL	(NOLOCK)	ON IMITMIDX_SQL.ITEM_NO		= DETAILS_RMA.ITEM_NO
		INNER JOIN	STATUS_RMA		(NOLOCK)	ON STATUS_RMA.K_STATUS_RMA	= DETAILS_RMA.K_STATUS_RMA	
		INNER JOIN	ARCUSFIL_PROGRAM_MODEL	(NOLOCK)	ON ARCUSFIL_PROGRAM_MODEL.S_ARCUSFIL_PROGRAM_MODEL	= DETAILS_RMA.MODELNO
		INNER JOIN	HEADER_RMA		(NOLOCK)	ON HEADER_RMA.K_HEADER_RMA	= DETAILS_RMA.K_HEADER_RMA
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
--		 EXECUTE [dbo].[PG_GET_DETALLE_PACKING_RMA] 0 ,0,  '101/102/103/104/105' , 'XXXXXXXXXX'
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
	
	IF @PP_PACKING_NO = 'XXXXXXXXXX'
	BEGIN
		DECLARE @VP_POSICION_K_DETAILS_RMA	INT
		DECLARE @VP_VALOR_K_DETAILS_RMA		VARCHAR(20)
						
		--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
		SET	@PP_ARRAY_K_DETAILS_RMA	= @PP_ARRAY_K_DETAILS_RMA		+ '/'		
		
		--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
		WHILE patindex('%/%' , @PP_ARRAY_K_DETAILS_RMA) <> 0
			BEGIN
				SELECT @VP_POSICION_K_DETAILS_RMA	=	patindex('%/%' , @PP_ARRAY_K_DETAILS_RMA)
				
				--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
				SELECT @VP_VALOR_K_DETAILS_RMA	= LEFT(@PP_ARRAY_K_DETAILS_RMA, @VP_POSICION_K_DETAILS_RMA - 1)

				-- /////////INSERTAMOS LA PIEL EN UNA TABLA TEMPORAL////////////////////////////////////////////////////////////
				INSERT	INTO	@TBL_MATERIAL_SELECCIONADO
				VALUES	( @VP_VALOR_K_DETAILS_RMA )

				--Reemplazamos lo procesado con nada con la funcion stuff
				SELECT @PP_ARRAY_K_DETAILS_RMA	= STUFF(@PP_ARRAY_K_DETAILS_RMA, 1, @VP_POSICION_K_DETAILS_RMA, '')

			END
	END
	ELSE
	BEGIN
		INSERT	INTO	@TBL_MATERIAL_SELECCIONADO
		SELECT	SERIAL_2 --K_INVENTARIO_EMBARQUE_RMA
		FROM	INVENTARIO_EMBARQUE_RMA		(NOLOCK)
		WHERE	PACKING_NO = @PP_PACKING_NO
		ORDER BY PROD_CAT
	END

	DECLARE @TBL_DETALLE_PACKING  TABLE (
			K_DETALLE_PACKING			INT IDENTITY(1,1),
			CUS_ITEM_NO					VARCHAR(100),
			D_ITEM_NO					VARCHAR(150),
			PROD_CAT					VARCHAR(100),
			QTY_SHIP					INT,
			BOX							INT,
			COST						DECIMAL(13,2),
			SQFT						DECIMAL(13,2)
		)
	SET NOCOUNT ON

	INSERT INTO @TBL_DETALLE_PACKING
	SELECT	CUS_ITEM_NO,	
			--(	SELECT TOP (1) LTRIM(RTRIM(ITEM_DESC_1))
			--	FROM IMITMIDX_SQL (NOLOCK)
			--	WHERE item_no	= DETAILS_RMA.ITEM_NO				),
			LTRIM(RTRIM(ITEM_DESC_1)),
			MODELNO,
			SUM(CANTIDAD_ENVIADA),
			COUNT(CUS_ITEM_NO),
			( SUM(PRECIO_UNITARIO)	* SUM(CANTIDAD_ENVIADA) ),
			( SUM(CANTIDAD_ENVIADA) * MAX(NET_AREA))
	FROM	DETAILS_RMA		(NOLOCK)
	INNER JOIN IMITMIDX_SQL	ON IMITMIDX_SQL.ITEM_NO	= DETAILS_RMA.ITEM_NO
	WHERE	K_DETAILS_RMA IN ( SELECT K_DETAILS_RMA FROM  @TBL_MATERIAL_SELECCIONADO	)
	GROUP BY	MODELNO, CUS_ITEM_NO, ITEM_DESC_1
	ORDER BY	MODELNO, CUS_ITEM_NO, ITEM_DESC_1

	INSERT INTO @TBL_DETALLE_PACKING
	SELECT	'  ', 'Totals:', '',
			SUM(QTY_SHIP) AS QTY_SHIP, 
			SUM(BOX) AS BOX, 
			SUM(COST) AS COST, 
			SUM(SQFT) AS SQFT 
	FROM	@TBL_DETALLE_PACKING

	SELECT	K_DETALLE_PACKING,	
			CUS_ITEM_NO,		
			D_ITEM_NO,
			CONVERT(VARCHAR(20), QTY_SHIP) AS QTY_SHIP,		
		    CONVERT(VARCHAR(20), BOX ) AS BOX,					
		    CONVERT(VARCHAR(20), COST ) AS COST,					
			CONVERT(VARCHAR(20), SQFT) AS SQFT,				
			CASE WHEN D_ITEM_NO = 'Totals:' THEN ' '
				ELSE CONVERT(VARCHAR(10),K_DETALLE_PACKING) END AS ID_DETALLE
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
	
	--IF @PP_PACKING_NO = 'XXXXXXXXXX'
	--BEGIN
		DECLARE @VP_POSICION_K_DETAILS_RMA	INT
		DECLARE @VP_VALOR_K_DETAILS_RMA		VARCHAR(20)
						
		--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
		SET	@PP_ARRAY_K_DETAILS_RMA	= @PP_ARRAY_K_DETAILS_RMA		+ '/'		
		
		--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
		WHILE patindex('%/%' , @PP_ARRAY_K_DETAILS_RMA) <> 0
			BEGIN
				SELECT @VP_POSICION_K_DETAILS_RMA	=	patindex('%/%' , @PP_ARRAY_K_DETAILS_RMA)
				
				--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
				SELECT @VP_VALOR_K_DETAILS_RMA	= LEFT(@PP_ARRAY_K_DETAILS_RMA, @VP_POSICION_K_DETAILS_RMA - 1)

				-- /////////INSERTAMOS LA PIEL EN UNA TABLA TEMPORAL////////////////////////////////////////////////////////////
				INSERT	INTO	@TBL_MATERIAL_SELECCIONADO
				SELECT	K_HEADER_RMA
				FROM	DETAILS_RMA		(NOLOCK)
				WHERE	K_DETAILS_RMA = @VP_VALOR_K_DETAILS_RMA

				--Reemplazamos lo procesado con nada con la funcion stuff
				SELECT @PP_ARRAY_K_DETAILS_RMA	= STUFF(@PP_ARRAY_K_DETAILS_RMA, 1, @VP_POSICION_K_DETAILS_RMA, '')

			END
	--END
	--ELSE
	--BEGIN
	--	INSERT	INTO	@TBL_MATERIAL_SELECCIONADO
	--	SELECT K_INVENTARIO_EMBARQUE
	--	FROM INVENTARIO_EMBARQUE
	--	WHERE PACKING_NO = @PP_PACKING_NO
	--	ORDER BY PROD_CAT
	--END

	DECLARE @TBL_DETALLE_PACKING  TABLE (
			K_DETALLE_PACKING			INT IDENTITY(1,1),
			TA_ATENCION_A				VARCHAR(150)
		)
	SET NOCOUNT ON

	INSERT INTO @TBL_DETALLE_PACKING
	SELECT	ATENCION_A
	FROM	HEADER_RMA	(NOLOCK)
	WHERE	K_HEADER_RMA	IN (
									SELECT DISTINCT TA_K_HEADER_RMA
									FROM	@TBL_MATERIAL_SELECCIONADO
								)

	DECLARE  @VP_RECIPIENTS					NVARCHAR(MAX)	= ''

	SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ', ' + TA_ATENCION_A
	FROM	@TBL_DETALLE_PACKING

	IF	LEFT(@VP_RECIPIENTS,1) =','
		SET @VP_RECIPIENTS	= STUFF(@VP_RECIPIENTS, 1, 2, '')

	SELECT  @VP_RECIPIENTS AS ATENCION_A
	--////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> ACTUALIZAR / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_INVENTARIO_EMBARQUE_PACKING_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_INVENTARIO_EMBARQUE_PACKING_RMA]
GO
--		 EXECUTE [dbo].[PG_UP_INVENTARIO_EMBARQUE_PACKING_RMA] 0,139,   'JEEP JT SUMMIT' , '199/109/108/116/115/117/114/113/112/110/111' , 1 
--		 EXECUTE [DBO].[PG_UP_INVENTARIO_EMBARQUE_PACKING_RMA] 1,139,  'JTS' , '18/19/20/151/152/153/154/155' , 1 , 2
--		 EXECUTE [DBO].[PG_UP_INVENTARIO_EMBARQUE_PACKING_RMA] 1,139,  'WTL' , '149/150/156' , 1 , 1
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
	SELECT	@VP_PROGRAMA = LTRIM(RTRIM(filler_0001)) 
	FROM	imcatfil_sql			(NOLOCK)
	WHERE	LTRIM(RTRIM(prod_cat)) = @PP_MODELNO

	IF @PP_TIPO_ORDEN	= 1
	BEGIN
		SET @VP_PROGRAMA	= 'REEM'
	END

	IF @VP_PROGRAMA IS NULL OR @VP_PROGRAMA = ''
		SET @VP_MENSAJE = 'No fue posible obtener el Product Category en [IMCATFIL].'
	-- =========================================

	IF @VP_MENSAJE = ''
		BEGIN
			DECLARE @VP_N_PACKING			INT = 0
			DECLARE @VP_PACKING_NO_ACTUAL	VARCHAR(50) = ''
			DECLARE @VP_DATE				DATE = GETDATE()

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
					DECLARE	@VP_N_PACKING_X_PROGRAMA INT = 0
					SELECT	@VP_N_PACKING_X_PROGRAMA = COUNT(PACKING_NO)
					FROM	INVENTARIO_EMBARQUE_LOG_RMA		(NOLOCK)
					WHERE	K_ESTATUS_INVENTARIO_EMBARQUE = 3 -- EMBARCADO
					AND		CONVERT(DATE, F_INVENTARIO_EMBARQUE_LOG_RMA) = @VP_DATE
					AND		LTRIM(RTRIM(PACKING_NO)) LIKE CONCAT(@VP_PROGRAMA, '%')

					IF @VP_N_PACKING_X_PROGRAMA IS NULL
						SET @VP_N_PACKING_X_PROGRAMA = 0

					IF @VP_N_PACKING_X_PROGRAMA > 0
						BEGIN
							-- /////////////SE OBTIENE EL ULTIMO EMBARQUE ENVIADO PARA EL PROGRAMA //////////////////////////////
							SELECT TOP 1 @VP_PACKING_NO_ACTUAL						= LTRIM(RTRIM(PACKING_NO))
							FROM	INVENTARIO_EMBARQUE_LOG_RMA		(NOLOCK)
							WHERE	K_ESTATUS_INVENTARIO_EMBARQUE					= 3 -- EMBARCADO
							AND		CONVERT(DATE, F_INVENTARIO_EMBARQUE_LOG_RMA)	= @VP_DATE
							AND		LTRIM(RTRIM(PACKING_NO)) LIKE CONCAT(@VP_PROGRAMA, '%')
							ORDER BY CONVERT(INT,SUBSTRING(PACKING_NO,CHARINDEX('-', PACKING_NO) + 1, 10)) DESC

							DECLARE @VP_DELIMITADOR VARCHAR(5) = '-'
							DECLARE @VP_CONSECUTIVO_ACTUAL VARCHAR(50) = ''
							DECLARE @VP_POSICION_GUION INT = 0
							DECLARE @VP_CONSECUTIVO_NUEVO INT = 0

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
				
				-- /////////SE OBTIENE DE LOS ARRAY EL LOTE Y PIEL INGRESADOS///////////////////////////////////////////////////////////	
				DECLARE @TBL_MATERIAL_SELECCIONADO  TABLE (
						TBL_K_MATERIAL_SELECCIONADO		INT IDENTITY(1,1),
						TBL_K_INVENTARIO_EMBARQUE		INT
					)
				SET NOCOUNT ON
				
				DECLARE @VP_POSICION_K_DETAILS_RMA	INT
				DECLARE @VP_VALOR_K_DETAILS_RMA		VARCHAR(20)
								
				--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
				SET	@PP_K_DETAILS_RMA_ARRAY	= @PP_K_DETAILS_RMA_ARRAY		+ '/'		
				
				--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
				WHILE patindex('%/%' , @PP_K_DETAILS_RMA_ARRAY) <> 0
					BEGIN
						SELECT @VP_POSICION_K_DETAILS_RMA	=	patindex('%/%' , @PP_K_DETAILS_RMA_ARRAY)
						
						--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
						SELECT @VP_VALOR_K_DETAILS_RMA	= LEFT(@PP_K_DETAILS_RMA_ARRAY, @VP_POSICION_K_DETAILS_RMA - 1)
						
						-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 
						--EXECUTE [dbo].[PG_RN_VALIDA_KIT_ASIGNAR_PACKING_RMA]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
						--														@VP_VALOR_K_DETAILS_RMA,
						--														@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
						DECLARE @VP_K_STATUS_RMA				INT		= 0
								,@VP_K_INVENTARIO_EMBARQUE_RMA	INT
						
						
						SELECT	@VP_K_STATUS_RMA				= K_ESTATUS_INVENTARIO_EMBARQUE_RMA,
								@VP_K_INVENTARIO_EMBARQUE_RMA	= K_INVENTARIO_EMBARQUE_RMA
						FROM	INVENTARIO_EMBARQUE_RMA		(NOLOCK)
						WHERE	SERIAL_2					= @VP_VALOR_K_DETAILS_RMA
						--SELECT	@VP_K_STATUS_RMA	= K_STATUS_RMA 
						--FROM	DETAILS_RMA			(NOLOCK)
						--WHERE	K_DETAILS_RMA		= @VP_VALOR_K_DETAILS_RMA
						
						IF ( @VP_K_STATUS_RMA	= 0 ) OR ( @VP_K_STATUS_RMA IS NULL )
						BEGIN
							SET	@VP_MENSAJE	= 'No fue posible obtener el estatus del registro... Verifique. [' + CONVERT(VARCHAR(50),@VP_VALOR_K_DETAILS_RMA) + ']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
						END
						ELSE IF ( @VP_K_STATUS_RMA	<> 5 )
						BEGIN
							SET	@VP_MENSAJE	= 'El estatus del registro, no permite realizar acción... Verifique. [' + CONVERT(VARCHAR(50),@VP_VALOR_K_DETAILS_RMA) + ']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
						END

						-- /////////INSERTAMOS LA PIEL EN UNA TABLA TEMPORAL////////////////////////////////////////////////////////////
						INSERT	INTO	@TBL_MATERIAL_SELECCIONADO
						VALUES	( @VP_K_INVENTARIO_EMBARQUE_RMA )--@VP_VALOR_K_DETAILS_RMA )

						--Reemplazamos lo procesado con nada con la funcion stuff
						SELECT @PP_K_DETAILS_RMA_ARRAY	= STUFF(@PP_K_DETAILS_RMA_ARRAY, 1, @VP_POSICION_K_DETAILS_RMA, '')
					END

				-- ///////SE VALIDA QUE EXISTA REGISTROS EN LA TABLA TEMPORAL///////////////////////////////////////////////////////
				DECLARE @VP_N_MATERIAL_SELECCIONADO INT = 0
				SELECT @VP_N_MATERIAL_SELECCIONADO = COUNT(TBL_K_MATERIAL_SELECCIONADO)
				FROM @TBL_MATERIAL_SELECCIONADO

				IF @VP_N_MATERIAL_SELECCIONADO IS NULL OR @VP_N_MATERIAL_SELECCIONADO = 0
					RAISERROR ('ERROR: No hay material seleccionado para asignar al Packing.', 16, 1 ) --MENSAJE - Severity -State.

				-- ///////SE ASIGNA EL PACKING AL MATERIAL SELECCIONADO///////////////////////////////////////////////////////		
				UPDATE	INVENTARIO_EMBARQUE_RMA
				SET		K_ESTATUS_INVENTARIO_EMBARQUE_RMA	= 3, -- EMBARCADO
						PACKING_NO							= @VP_PACKING_NUEVO,
						N_EMBARQUE							= @PP_NUMERO_EMBARQUE,
						TOTAL_CAJAS							= @PP_TOTAL_CAJAS,
						F_INVENTARIO_EMBARQUE_RMA			= GETDATE(),
						F_CAMBIO							= GETDATE()
				WHERE K_INVENTARIO_EMBARQUE_RMA IN (	SELECT	TBL_K_INVENTARIO_EMBARQUE
														FROM	@TBL_MATERIAL_SELECCIONADO	)

				IF @@ROWCOUNT = 0
					RAISERROR ('No fue posible asignar el Packing al material seleccionado en [INVENTARIO_EMBARQUE].', 16, 1 ) --MENSAJE - Severity -State.

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
					RAISERROR ('ERROR: No fue posible guardar el log del Packing en [INVENTARIO_EMBARQUE_LOG] ', 16, 1 ) --MENSAJE - Severity -State.

				-- //////SE OBTIENE EL NUMERO DE RELOJ DEL USUARIO PEARL/////////////////////////////////////
				--DECLARE @VP_NUMERO_RELOJ INT = 0;
				--SELECT	@VP_NUMERO_RELOJ = K_EMPLEADO_PEARL				
				--FROM	BD_GENERAL.DBO.USUARIO_PEARL			(NOLOCK)
				--WHERE	K_USUARIO_PEARL = @PP_K_USUARIO_ACCION

				---- ///////SE GUARDA EL LOG DEL MATERIAL EMBARCADO PARA EL RASTREO//////////////////////////////////////////////
				--EXECUTE [dbo].[PG_IN_EVENTO_EMBARCADO_FACTURADO_KIT_PROGRAMADO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
				--																430, @VP_PACKING_NUEVO, 'EMBARQUES', @VP_NUMERO_RELOJ, ''
				
				-- //////////////////////////////////////////////////////////////
				--INSERT INTO [MATERIAL_PROGRAMADO_LOG]	
				--	(	[K_TIPO_EVENTO_KIT], [SERIAL], [ITEM_NO], [USUARIO_EVENTO], [ESTACION], 
				--		[K_RESPONSABLE], [CODIGO_ETIQUETA], [F_LOG],			
				--		-- ===========================
				--		[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
				--		[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )	
				--SELECT	430, [SERIAL_1], [ITEM_NO], [PACKING_NO], 'EMBARQUES', 
				--		@VP_NUMERO_RELOJ, '', GETDATE(),
				--		-- ===========================
				--		@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
				--		0, 0, NULL 
				--FROM INVENTARIO_EMBARQUE
				--WHERE PACKING_NO = @VP_PACKING_NUEVO 

				--IF @@ROWCOUNT = 0
				--	RAISERROR ('ERROR: No fue posible guardar el log del Packing en [MATERIAL_PROGRAMADO_LOG]', 16, 1 ) --MENSAJE - Severity -State.
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


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HEADER_RMA_INVOICE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HEADER_RMA_INVOICE]
GO
--		 EXECUTE [DBO].[PG_LI_HEADER_DETAILS] 0,0, 'XXXXXXXX','JL1204-1', 'IRVI02'
CREATE PROCEDURE [dbo].[PG_LI_HEADER_RMA_INVOICE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_INVOICE_NO					VARCHAR(50),
	@PP_PACKING_NO					VARCHAR(50),
	@PP_CUSTOMER					VARCHAR(50)
AS
	-- =========================================		
	
	IF @PP_INVOICE_NO = 'XXXXXXXX'
		BEGIN
			DECLARE @VP_CUS_PART_NO	VARCHAR(100) = ''
			DECLARE @VP_ITEM_NO		VARCHAR(100) = ''
			DECLARE @VP_QTY_SHIP	INT = 0

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
						SUM(QTY) AS QTY_SHIP
				FROM	INVENTARIO_EMBARQUE_RMA
				WHERE	PACKING_NO	= @PP_PACKING_NO
				GROUP BY CUS_PART_NO, ITEM_NO
			
			OPEN CU_MATERIAL_A_FACTURAR
			FETCH NEXT FROM CU_MATERIAL_A_FACTURAR INTO @VP_CUS_PART_NO, @VP_ITEM_NO, @VP_QTY_SHIP
			
			WHILE @@FETCH_STATUS = 0
				BEGIN
					DECLARE @VP_ITEM_DESC_1 VARCHAR(150) = ''
					DECLARE @VP_BPO_NUMBER	VARCHAR(50) = ''

					SELECT @VP_ITEM_DESC_1 = LTRIM(RTRIM(ITEM_DESC_1)),
							@VP_BPO_NUMBER = LTRIM(RTRIM(ISNULL(filler_0003, '')))
					FROM IMITMIDX_SQL 
					WHERE LTRIM(RTRIM(item_no)) = @VP_ITEM_NO

					-- ///////////////////////////////////////////
					DECLARE @VP_PRECIO_UNITARIO DECIMAL(13,2) = 0 -- REVISAR CALCULOS PORQUE EL PRECIO ESTA A 6 DECIMALES
					SELECT TOP 1 @VP_PRECIO_UNITARIO = PRC_OR_DISC_1
					FROM	OEPRCFIL_SQL 
					WHERE	LTRIM(RTRIM(filler_0001)) LIKE '%' + @VP_ITEM_NO 
					AND		LTRIM(RTRIM(filler_0001)) LIKE @PP_CUSTOMER + '%'
					ORDER BY A4GLIdentity DESC

					-- ///////////////////////////////////////////
					DECLARE @VP_TOTAL_KIT DECIMAL(13,2) = 0
					SET @VP_TOTAL_KIT = @VP_QTY_SHIP * @VP_PRECIO_UNITARIO

					INSERT INTO @VP_TBL_DETALLE_INVOICE 
						SELECT	@VP_ITEM_NO AS Item_No,
								@VP_ITEM_DESC_1 AS Item_Desc_1,
								-- =========================================
								( CASE WHEN @PP_CUSTOMER = 'FAUR01' THEN
											CONCAT(@VP_CUS_PART_NO, ' (', @VP_BPO_NUMBER, ')') 
										ELSE @VP_CUS_PART_NO END ) AS Cus_Item_No,
								-- =========================================
								@VP_QTY_SHIP AS Qty_To_Ship,
								'EA' AS UOM_MANUAL,
								@VP_PRECIO_UNITARIO AS Unit_Price,
								@VP_TOTAL_KIT AS TOTAL_KIT

					FETCH NEXT FROM CU_MATERIAL_A_FACTURAR INTO @VP_CUS_PART_NO, @VP_ITEM_NO, @VP_QTY_SHIP
	
				END
				
				CLOSE CU_MATERIAL_A_FACTURAR
				DEALLOCATE CU_MATERIAL_A_FACTURAR

				-- ///////////////////////////////////////////
				SELECT *
				FROM @VP_TBL_DETALLE_INVOICE
		END
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


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_DETAILS_RMA_INVOICE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_DETAILS_RMA_INVOICE]
GO
--		 EXECUTE [DBO].[PG_LI_INVOICE_DETAILS] 0,0, 'XXXXXXXX','JL1204-1', 'IRVI02'
CREATE PROCEDURE [dbo].[PG_LI_DETAILS_RMA_INVOICE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_INVOICE_NO					VARCHAR(50),
	@PP_PACKING_NO					VARCHAR(50),
	@PP_CUSTOMER					VARCHAR(50)
AS
	-- =========================================		
	
	IF @PP_INVOICE_NO = 'XXXXXXXX'
		BEGIN
			DECLARE @VP_CUS_PART_NO	VARCHAR(100) = ''
			DECLARE @VP_ITEM_NO		VARCHAR(100) = ''
			DECLARE @VP_QTY_SHIP	INT = 0

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
						SUM(QTY) AS QTY_SHIP
				FROM	INVENTARIO_EMBARQUE_RMA
				WHERE	PACKING_NO	= @PP_PACKING_NO
				GROUP BY CUS_PART_NO, ITEM_NO
			
			OPEN CU_MATERIAL_A_FACTURAR
			FETCH NEXT FROM CU_MATERIAL_A_FACTURAR INTO @VP_CUS_PART_NO, @VP_ITEM_NO, @VP_QTY_SHIP
			
			WHILE @@FETCH_STATUS = 0
				BEGIN
					DECLARE @VP_ITEM_DESC_1 VARCHAR(150) = ''
					DECLARE @VP_BPO_NUMBER	VARCHAR(50) = ''

					SELECT @VP_ITEM_DESC_1 = LTRIM(RTRIM(ITEM_DESC_1)),
							@VP_BPO_NUMBER = LTRIM(RTRIM(ISNULL(filler_0003, '')))
					FROM IMITMIDX_SQL 
					WHERE LTRIM(RTRIM(item_no)) = @VP_ITEM_NO

					-- ///////////////////////////////////////////
					DECLARE @VP_PRECIO_UNITARIO DECIMAL(13,2) = 0 -- REVISAR CALCULOS PORQUE EL PRECIO ESTA A 6 DECIMALES
					SELECT TOP 1 @VP_PRECIO_UNITARIO = PRC_OR_DISC_1
					FROM	OEPRCFIL_SQL 
					WHERE	LTRIM(RTRIM(filler_0001)) LIKE '%' + @VP_ITEM_NO 
					AND		LTRIM(RTRIM(filler_0001)) LIKE @PP_CUSTOMER + '%'
					ORDER BY A4GLIdentity DESC

					-- ///////////////////////////////////////////
					DECLARE @VP_TOTAL_KIT DECIMAL(13,2) = 0
					SET @VP_TOTAL_KIT = @VP_QTY_SHIP * @VP_PRECIO_UNITARIO

					INSERT INTO @VP_TBL_DETALLE_INVOICE 
						SELECT	@VP_ITEM_NO AS Item_No,
								@VP_ITEM_DESC_1 AS Item_Desc_1,
								-- =========================================
								( CASE WHEN @PP_CUSTOMER = 'FAUR01' THEN
											CONCAT(@VP_CUS_PART_NO, ' (', @VP_BPO_NUMBER, ')') 
										ELSE @VP_CUS_PART_NO END ) AS Cus_Item_No,
								-- =========================================
								@VP_QTY_SHIP AS Qty_To_Ship,
								'EA' AS UOM_MANUAL,
								@VP_PRECIO_UNITARIO AS Unit_Price,
								@VP_TOTAL_KIT AS TOTAL_KIT

					FETCH NEXT FROM CU_MATERIAL_A_FACTURAR INTO @VP_CUS_PART_NO, @VP_ITEM_NO, @VP_QTY_SHIP
	
				END
				
				CLOSE CU_MATERIAL_A_FACTURAR
				DEALLOCATE CU_MATERIAL_A_FACTURAR

				-- ///////////////////////////////////////////
				SELECT *
				FROM @VP_TBL_DETALLE_INVOICE
		END
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

---- //////////////////////////////////////////////////////////////
---- //////////////////////////////////////////////////////////////
---- //////////////////////////////////////////////////////////////
