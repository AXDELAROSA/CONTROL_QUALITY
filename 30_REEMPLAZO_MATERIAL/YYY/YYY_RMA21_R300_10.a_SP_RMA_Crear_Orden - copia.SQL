-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			RMA
-- // OPERATION:		TABLE
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210622
-- //////////////////////////////////////////////////////////////  

USE [DATA_02] 
GO

select * from header_rma
select * from details_rma
-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_RMA_CREAR_ORDER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_RMA_CREAR_ORDER]
GO
/*
	 EXEC [PG_PR_RMA_CREAR_ORDER] 0 ,144, 'MAGN03' , 'FCNPJRR' , 'Table 38' , 
								'PLMWARM/PWD2TFB/PWD2TBL/PWD2TCR/PWD2TCL/PW2RB40/PW2RB60/PW2RC40/PWDRC60' , 
								'30/30/30/30/30/30/30/30/30' , '' , 'ORDEN GENERADA POR SISTEMAS PARA PRUEBAS' , 'franciscoe' , 'IT-010'  
*/
CREATE PROCEDURE [dbo].[PG_PR_RMA_CREAR_ORDER]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_CLIENTE					VARCHAR(50)		,
	--@PP_MESA					VARCHAR(50)		,
	@PP_K_HEADER_RMA			INT
	--@PP_ARRAY_PATTERN			NVARCHAR(MAX)	,
	--@PP_ARRAY_CANTIDA			NVARCHAR(MAX)	,
	--@PP_COMENTARIO				VARCHAR(255)	,
	--@PP_USER					VARCHAR(25)		,
	--@PP_COMPUTER_NAME			VARCHAR(25)
AS
	-- ///////////////////////////////////////////
	DECLARE  @VP_MENSAJE		NVARCHAR(MAX)	= ''
			,@VP_ORDEN			VARCHAR(10)		= ''
			,@VP_K_USER			INT		= ( SELECT K_USUARIO_ALTA	FROM HEADER_RMA	WHERE	K_HEADER_RMA	= @PP_K_HEADER_RMA	)
			,@VP_COMPUTER_NAME	VARCHAR(25)		= 'RMA_AUTOMATICA'
	-- //////////////////////////////////////////////////////////////
BEGIN TRANSACTION 
BEGIN TRY
		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		-- ///////SE OBTIENE EL NUMERO DE LA ULTIMA ORDEN GENERADA//////////////////////////////////////////////
		SELECT	TOP 1 @VP_ORDEN = CONVERT(INT, LTRIM(RTRIM(user_def_fld_4)))
		FROM	imlocfil_sql	(NOLOCK)
		WHERE	LOC				= 'MFP'
	
		IF @VP_ORDEN IS NULL
			RAISERROR ('ERROR: No fue posible obtener el numero de orden en [CCJOBHDR_SQL]', 16, 1 ) 
	
		SET @VP_ORDEN = @VP_ORDEN + 1
		SET @VP_ORDEN = RIGHT('00000' + @VP_ORDEN, 5)
	
		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		-- ///////SE ACTUALIZA LA LOCACION MFP CON LA ORDEN CREADA//////////////////////////////////////////////			
		UPDATE imlocfil_sql 
			SET user_def_fld_4 = @VP_ORDEN
		WHERE LOC = 'MFP'	
		IF @@ROWCOUNT = 0
			RAISERROR ('ERROR: No fue posible Actualizar la orden en [imlocfil_sql]', 16, 1 ) 

		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
		-- ///////SE OBTIENE LA FECHA EN FORMATO NUMERICO//////////////////////////////////////////////
		DECLARE @VP_FECHA	INT = DBO.CONVERT_DATE_TO_INT(GETDATE(), 'yyyyMMdd');
		DECLARE @VP_HORA	INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
		DECLARE @VP_TURNO	VARCHAR(5) = '2'
	
		IF @VP_HORA > 2000 AND @VP_HORA < 60002
			SET @VP_TURNO = '3'
		ELSE IF @VP_HORA > 60001 AND @VP_HORA < 153001
			SET @VP_TURNO = '1'

		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
		-- /////////SE OBTIENE LA UTILIDAD//////////////////////////////////
		DECLARE @VP_UTILIDAD_MINIMA DECIMAL(13,2) = 0
		SELECT @VP_UTILIDAD_MINIMA = User_Def_Fld_2
		FROM arcusfil_sql			(NOLOCK)
		WHERE CUS_NO				= @PP_CLIENTE
	
		IF @VP_UTILIDAD_MINIMA IS NULL
			SET @VP_UTILIDAD_MINIMA = 0
	
		SET @VP_UTILIDAD_MINIMA = @VP_UTILIDAD_MINIMA / 1000000						

		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////						
		-- ///////SE CREA TABLA TEMPORAL /////////////////////////////////////////////	
		DECLARE @TBL_PATTERN_A_PROGRAMAR		TABLE 
		(		 TA_K_PATTERN_A_PROGRAMAR		INT IDENTITY(1,1)
				,TA_S_PATTERN					VARCHAR(50)
				,TA_ITEM_NO						VARCHAR(100)
				,TA_CANTIDAD					INT			
				,TA_S_COLOR_SINF				VARCHAR(10)
				,TA_D_COLOR						VARCHAR(250)
		)
		SET NOCOUNT ON
		---- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		---- ///////SE INSERTAN LOS REGISTROS EN LA TABLA TEMPORAL /////////////////////////////////////////////	
		--DECLARE  @VP_POSICION_PATTERN	INT
		--		,@VP_POSICION_CANTIDA	INT
		--		,@VP_VALOR_PATTERN		VARCHAR(50)
		--		,@VP_VALOR_CANTIDA		VARCHAR(50)
						
		----Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
		--SET	@PP_ARRAY_PATTERN		= @PP_ARRAY_PATTERN		+ '/'		
		--SET	@PP_ARRAY_CANTIDA		= @PP_ARRAY_CANTIDA		+ '/'		
		
		----Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
		--WHILE patindex('%/%' , @PP_ARRAY_PATTERN) <> 0
		--	BEGIN
		--		SELECT @VP_POSICION_PATTERN	=	patindex('%/%' , @PP_ARRAY_PATTERN)
		--		SELECT @VP_POSICION_CANTIDA	=	patindex('%/%' , @PP_ARRAY_CANTIDA)
				
		--		--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
		--		SELECT @VP_VALOR_PATTERN		= LEFT(@PP_ARRAY_PATTERN, @VP_POSICION_PATTERN - 1)
		--		SELECT @VP_VALOR_CANTIDA		= LEFT(@PP_ARRAY_CANTIDA, @VP_POSICION_CANTIDA - 1)
				
		--		-- /////////////////////////////////////////////////////////////////////
		--		---	VALIDAR EL TAMAÑO DEL PATTERN, DE LAS SIGLAS DEL PATTERN Y EL COLOR
		--			DECLARE		 @VP_WH_S_PATTERN		AS VARCHAR(10)	= LEFT(@VP_VALOR_PATTERN,8)
		--						,@VP_WH_S_COLOR_SINF	AS VARCHAR(10)	= RIGHT(@VP_VALOR_PATTERN,6)
		--						,@VP_WH_D_COLOR			AS VARCHAR(250)
		--						,@VP_WH_K_COLOR			AS INT	= 0

		--			IF LEN(@VP_VALOR_PATTERN)	<> 14
		--				RAISERROR ('ERROR: Longitud del Pattern incorrecta [ITEM_NO]', 16, 1 )
				
		--			IF LEN(@VP_WH_S_PATTERN)	<> 8
		--				RAISERROR ('ERROR: Longitud del Pattern incorrecta [S_PATTERN]', 16, 1 )

		--			IF LEN(@VP_WH_S_COLOR_SINF)	<> 6
		--			BEGIN
		--				RAISERROR ('ERROR: Longitud del Color incorrecta [S_COLOR]', 16, 1 )
		--			END
						
		--			SELECT	@VP_WH_K_COLOR		= A4GLIDENTITY
		--			FROM	IMITMIDX_SQL		(NOLOCK)
		--			WHERE	ITEM_NO				= CONCAT('F',@VP_WH_S_COLOR_SINF)

		--			IF (@VP_WH_K_COLOR	IS NULL) OR	( @VP_WH_K_COLOR = 0 )
		--			BEGIN
		--				SET @VP_MENSAJE = 'ERROR: El color ['+ CONCAT('F',@VP_WH_S_COLOR_SINF) +'] no existe en la Base de datos.'
		--				RAISERROR (@VP_MENSAJE, 16, 1 ) 
		--			END

		--			SELECT	@VP_WH_D_COLOR		= LTRIM(RTRIM(ITEM_DESC_1))
		--			FROM	IMITMIDX_SQL		(NOLOCK)
		--			WHERE	A4GLIDENTITY		= @VP_WH_K_COLOR

		--			IF	LTRIM(RTRIM(@VP_WH_D_COLOR))	= ''
		--			BEGIN
		--				SET @VP_MENSAJE = 'ERROR: La descripción del color ['+ CONCAT('F',@VP_WH_S_COLOR_SINF) +'] no existe en la Base de datos.'
		--				RAISERROR (@VP_MENSAJE, 16, 1 ) 
		--			END

		--		-- /////////////////////////////////////////////////////////////////////
		--			INSERT	INTO	@TBL_PATTERN_A_PROGRAMAR
		--				(	 TA_S_PATTERN					
		--					,TA_ITEM_NO						
		--					,TA_CANTIDAD					
		--					,TA_S_COLOR_SINF			
		--					,TA_D_COLOR		)
		--			VALUES	
		--				(	 @VP_WH_S_PATTERN	
		--					,@VP_VALOR_PATTERN	
		--					,@VP_VALOR_CANTIDA	
		--					,@VP_WH_S_COLOR_SINF		
		--					,@VP_WH_D_COLOR		)
		--			IF @@ROWCOUNT = 0
		--				SET @VP_MENSAJE = 'ERROR: No se insertó el registro (PATTERN_A_PROGRAMAR): [' + @VP_VALOR_PATTERN + '].'
		--				RAISERROR (@VP_MENSAJE, 16, 1 ) 

		--		--Reemplazamos lo procesado con nada con la funcion stuff
		--		SELECT @PP_ARRAY_PATTERN	= STUFF(@PP_ARRAY_PATTERN, 1, @VP_POSICION_PATTERN, '')
		--		SELECT @PP_ARRAY_CANTIDA	= STUFF(@PP_ARRAY_CANTIDA, 1, @VP_POSICION_CANTIDA, '')
		--	END
	
		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			INSERT	INTO	@TBL_PATTERN_A_PROGRAMAR
						(	 TA_S_PATTERN					
							,TA_ITEM_NO						
							,TA_CANTIDAD					
							,TA_S_COLOR_SINF			
							,TA_D_COLOR				)
			SELECT	 LEFT(ITEM_NO,8)
					,ITEM_NO
					,CANTIDAD_ORDENADA
					,RIGHT(ITEM_NO,6)
					,(	SELECT	LTRIM(RTRIM(ITEM_DESC_1))
						FROM	IMITMIDX_SQL		(NOLOCK)
						WHERE	ITEM_NO		= CONCAT('F',RIGHT(ITEM_NO,6))					
					)
			FROM	DETAILS_RMA
			WHERE	K_HEADER_RMA		= @PP_HEADER_RMA

		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		-- ///////SE VALIDA QUE EXISTA REGISTROS EN LA TABLA TEMPORAL///////////////////////////////////////////////////////
		IF	(	SELECT	COUNT(TA_K_PATTERN_A_PROGRAMAR)
				FROM	@TBL_PATTERN_A_PROGRAMAR		)	<= 0
			
				RAISERROR ('ERROR: No hay Patterns para programar.', 16, 1 ) 

	-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	-- //////SE DECLARAN VARIABLES A USARSE/////////////////////////////////////
	DECLARE  @VP_CU_PATTERN			VARCHAR(50)		= '',	@VP_CU_ITEM_NO		VARCHAR(100)	= '',	@VP_CU_CANTIDAD		INT = 0,		
			 @VP_CU_S_COLOR_SINF	VARCHAR(10)		= '',	@VP_CU_D_COLOR		VARCHAR(10)		= '',
			 @VP_GROSS				DECIMAL(16,4)	= 0,	@VP_NETO			DECIMAL(16,4)	= 0,	@VP_PATRON			INT = 0,
			 @VP_TOTAL_GROSS		DECIMAL(16,4)	= 0,	@VP_TOTAL_NETO		DECIMAL(16,4)	= 0,	@VP_TOTAL_PATRON	INT = 0,
			 @VP_CONSECUTIVO		INT				= 1,	@VP_NUMERO_RELOJ	INT				= 0,	@VP_COLOR_ANTERIOR	VARCHAR(10)	= '',
			 --=============================================================================================================================
			 @VP_EX_PATTERN			VARCHAR(50)		= '',	@VP_EX_ITEM_NO		VARCHAR(100)	= '',	@VP_EX_CANTIDAD		INT = 0,		
			 @VP_EX_S_COLOR_SINF	VARCHAR(10)		= '',	@VP_EX_D_COLOR		VARCHAR(10)		= '',
			 --=============================================================================================================================
			 @VP_DETAIL				VARCHAR(100) =	''
	
	-- //////SE OBTIENE EL NUMERO DE RELOJ DEL USUARIO PEARL/////////////////////////////////////
		SELECT	@VP_NUMERO_RELOJ		= K_EMPLEADO_PEARL
		FROM	BD_GENERAL.DBO.USUARIO_PEARL	(NOLOCK)
		WHERE	K_USUARIO_PEARL			= @PP_K_USUARIO_ACCION
	
	-- //////SE CREA CURSOR PARA DARLE FORMATO A LOS DATOS/////////////////////////////////////
	DECLARE CU_PATTERN_A_PROGRAMAR CURSOR FOR			
			SELECT	 --K_PATTERN_A_PROGRAMAR
					 TA_S_PATTERN
					,TA_ITEM_NO
					,TA_CANTIDAD
					,TA_S_COLOR_SINF
					,TA_D_COLOR
			FROM	@TBL_PATTERN_A_PROGRAMAR
			ORDER BY	TA_S_COLOR_SINF,	TA_ITEM_NO,		TA_CANTIDAD
	OPEN CU_PATTERN_A_PROGRAMAR
	FETCH NEXT FROM CU_PATTERN_A_PROGRAMAR INTO		@VP_CU_PATTERN,		@VP_CU_ITEM_NO,		@VP_CU_CANTIDAD,	@VP_CU_S_COLOR_SINF,		@VP_CU_D_COLOR
	WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE  @VP_CUBE_LENGTH		DECIMAL(13,4) = 0	,@VP_CUBE_WIDTH			DECIMAL(13,4)	= 0		,@VP_CUBE_QTY_PER	DECIMAL(13,4) = 0
					,@VP_D_ITEM				VARCHAR(255)		,@VP_CHANGE_LEVEL		VARCHAR(100)			,@VP_MODELO			VARCHAR(50)
					,@VP_VERSION			VARCHAR(50)			,@VP_SERIAL				VARCHAR(50)		= ''	

			-- ///////////////////////////////////////////////////////////////////////////////////////
			IF @VP_COLOR_ANTERIOR	= ''
			BEGIN
				SET	@VP_COLOR_ANTERIOR	= @VP_CU_S_COLOR_SINF
			END
			-- ////////SE OBTIENE EL GROSS, NETO Y PATRONES DEL KIT///////////////////////////////////
			SELECT TOP (1)
					 @VP_CUBE_LENGTH		= CUBE_LENGTH
					,@VP_CUBE_WIDTH			= CUBE_WIDTH
					,@VP_CUBE_QTY_PER		= CUBE_QTY_PER
					,@VP_D_ITEM				= LTRIM(RTRIM(item_desc_1))
					--,@VP_CHANGE_LEVEL		= LTRIM(RTRIM(Last_item_revision))
			FROM	IMITMIDX_SQL			(NOLOCK)
			WHERE	LTRIM(RTRIM(ITEM_NO))	= @VP_CU_ITEM_NO
	
			IF @VP_CUBE_LENGTH IS NULL
				SET @VP_CUBE_LENGTH = 0
	
			IF @VP_CUBE_WIDTH IS NULL
				SET @VP_CUBE_WIDTH = 0
	
			IF @VP_CUBE_QTY_PER IS NULL
				SET @VP_CUBE_QTY_PER = 0						 
	
			SET @VP_GROSS	= @VP_CUBE_LENGTH	*	@VP_CU_CANTIDAD
			SET @VP_NETO	= @VP_CUBE_WIDTH	*	@VP_CU_CANTIDAD
			--SET @VP_PATRON	= @VP_CUBE_QTY_PER	*	@VP_CU_CANTIDAD
	
			SET @VP_TOTAL_GROSS		= @VP_TOTAL_GROSS	+	@VP_GROSS
			SET @VP_TOTAL_NETO		= @VP_TOTAL_NETO	+	@VP_NETO
			--SET @VP_TOTAL_PATRON	= @VP_TOTAL_PATRON	+	@VP_PATRON
			-- ///////////////////////////////////////////////////////////////////////////////////////
			-- ////////SE OBTIENE EL MODELO Y ULTIMA VERSION DEL KIT//////////////////////////////////				
			SELECT	DISTINCT TOP (1) PERCENT 
					 @VP_MODELO		= ccverhdr_sql.modelno
					,@VP_VERSION		= ccverhdr_sql.versionno
			FROM	dbo.ccverhdr_sql		(NOLOCK)
			INNER JOIN	cccusitm_sql		(NOLOCK)	ON CONCAT(ccverhdr_sql.modelno, ccverhdr_sql.versionno ) = CONCAT(cccusitm_sql.modelno, cccusitm_sql.versionno ) 
				AND		SUBSTRING(LTRIM(RTRIM(cccusitm_sql.item_no)) ,1 ,1)		=	'I' 
				--AND												cus_item_no		<>	''
			INNER JOIN	IMITMIDX_SQL		(NOLOCK)	ON IMITMIDX_SQL.item_no			= cccusitm_sql.item_no
			INNER JOIN  IMCATFIL_SQL		(NOLOCK)	ON dbo.IMITMIDX_SQL.prod_cat	= IMCATFIL_SQL.prod_cat 
				AND		IMCATFIL_SQL.L_BORRADO						=	0
			WHERE	ccverhdr_sql.specstatus							=	'U'
			AND		ccverhdr_sql.status								=	'L'
			AND		RIGHT(LTRIM(RTRIM(cccusitm_sql.item_no)),6)		=	@VP_CU_S_COLOR_SINF
			AND		ccverhdr_sql.cus_no								=	@PP_CLIENTE
			AND		cccusitm_sql.item_no							=	@VP_CU_ITEM_NO
	
			SET @VP_CHANGE_LEVEL = @VP_MODELO + @VP_VERSION

			IF	LEN(@VP_CHANGE_LEVEL)	<	7
				RAISERROR ('ERROR: No fue posible obtener el Change Level.', 16, 1 ) 
			-- ///////////////////////////////////////////////////////////////////////////////////////
			-- ////////SE OBTIENE EL STANDARD PACK DEL KIT///////////////////////////////////
			DECLARE @VP_STD_PACK INT = 0

				SELECT	TOP(1) 
						@VP_STD_PACK			= user_def_fld_5 
				FROM	ccitmidx_sql			(NOLOCK)
				WHERE	LTRIM(RTRIM(item_no))	= @VP_CU_ITEM_NO
				AND		modelno					= @VP_MODELO		
				AND		versionno				= @VP_VERSION		
				ORDER BY versionno DESC
			
			IF @VP_STD_PACK IS NULL
				RAISERROR ('ERROR: No fue posible obtener el Estandar Pack en [ccitmidx_sql]', 16, 1 ) 
	
			-- ///////////////////////////////////////////////////////////////////////////////////////
			-- ///////////////////////////////////////////////////////////////////////////////////////
			-- ///////////////////////////////////////////////////////////////////////////////////////
			-- //////SE INGRESAN LOS KITS EN LA TABLA ccjoblin_sql/////////////////////////////////////
			IF @VP_CU_CANTIDAD < @VP_STD_PACK
			BEGIN
				INSERT INTO	ccjoblin_sql
				(		jobno,				kit,				kitdesc,		item_no, 
						PlannedQty,			OriginalQty,		CompletedQty, 
						netsqmper,			stdsqmper,			patternsper, 
						customer,			ChangeLevel,		Ser_no					)
				VALUES	
				(		@VP_ORDEN,			@VP_CU_PATTERN,		@VP_D_ITEM,		@VP_CU_ITEM_NO, 
						@VP_CU_CANTIDAD,	@VP_CU_CANTIDAD,	0,--0 ES VALOR POR DEFAULT
						@VP_CUBE_WIDTH,		@VP_CUBE_LENGTH,	1,--SE PONE 1, YA QUE LA RELACIÓN ES UN PATRON CONTIENE UN PATRON
						@PP_CLIENTE,		@VP_CHANGE_LEVEL,	@VP_CONSECUTIVO			)				
				IF @@ROWCOUNT = 0
					SET @VP_MENSAJE	= 'ERROR: No fue posible agregar el pattern ['+ @VP_CU_ITEM_NO +'] a la orden en [ccjoblin_sql].'
					RAISERROR (@VP_MENSAJE, 16, 1 )
	
				-- ///////SE GUARDA EL REGISTRO DEL MATERIAL ESCANEADO//////////////////////////////////////////////
				SET @VP_SERIAL  = @VP_ORDEN + RIGHT('000'+ CONVERT(VARCHAR(10), @VP_CONSECUTIVO), 3) 
				
				EXECUTE [dbo].[PG_IN_MATERIAL_PROGRAMADO_LOG]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																10, @VP_SERIAL, @VP_CU_ITEM_NO,
																'MATERIALES', @PP_COMPUTER_NAME, @VP_NUMERO_RELOJ, ''
						
				-- ///////SE AUMENTA EL CONSECUTIVO//////////////////////////////////////////////
				SET @VP_CONSECUTIVO = @VP_CONSECUTIVO + 1
			END
			---------------------------------------------------------------------------------------------------------------------
			ELSE
			---------------------------------------------------------------------------------------------------------------------
			BEGIN
				WHILE  @VP_CU_CANTIDAD > 0
				BEGIN	--BEGIN WHILE
					IF @VP_CU_CANTIDAD > @VP_STD_PACK
					BEGIN
						INSERT INTO	ccjoblin_sql
						(		jobno,				kit,				kitdesc,		item_no, 
								PlannedQty,			OriginalQty,		CompletedQty, 
								netsqmper,			stdsqmper,			patternsper, 
								customer,			ChangeLevel,		Ser_no					)
						VALUES	
						(		@VP_ORDEN,			@VP_CU_PATTERN,		@VP_D_ITEM,		@VP_CU_ITEM_NO, 
								@VP_STD_PACK,		@VP_STD_PACK,		0,--0 ES VALOR POR DEFAULT
								@VP_CUBE_WIDTH,		@VP_CUBE_LENGTH,	1,--SE PONE 1, YA QUE LA RELACIÓN ES UN PATRON CONTIENE UN PATRON
								@PP_CLIENTE,		@VP_CHANGE_LEVEL,	@VP_CONSECUTIVO			)				
						IF @@ROWCOUNT = 0
							SET @VP_MENSAJE	= 'ERROR: No fue posible agregar el pattern ['+ @VP_CU_ITEM_NO +'] a la orden en [ccjoblin_sql].'
							RAISERROR (@VP_MENSAJE, 16, 1 )
					END
					ELSE
					BEGIN
						INSERT INTO	ccjoblin_sql
						(		jobno,				kit,				kitdesc,		item_no, 
								PlannedQty,			OriginalQty,		CompletedQty, 
								netsqmper,			stdsqmper,			patternsper, 
								customer,			ChangeLevel,		Ser_no					)
						VALUES	
						(		@VP_ORDEN,			@VP_CU_PATTERN,		@VP_D_ITEM,		@VP_CU_ITEM_NO, 
								@VP_CU_CANTIDAD,	@VP_CU_CANTIDAD,	0,--0 ES VALOR POR DEFAULT
								@VP_CUBE_WIDTH,		@VP_CUBE_LENGTH,	1,--SE PONE 1, YA QUE LA RELACIÓN ES UN PATRON CONTIENE UN PATRON
								@PP_CLIENTE,		@VP_CHANGE_LEVEL,	@VP_CONSECUTIVO			)				
						IF @@ROWCOUNT = 0
							SET @VP_MENSAJE	= 'ERROR: No fue posible agregar el pattern ['+ @VP_CU_ITEM_NO +'] a la orden en [ccjoblin_sql].'
							RAISERROR (@VP_MENSAJE, 16, 1 )
					END
	
					-- ///////SE GUARDA EL REGISTRO DEL MATERIAL ESCANEADO//////////////////////////////////////////////
					SET @VP_SERIAL  = @VP_ORDEN + RIGHT('000'+ CONVERT(VARCHAR(10), @VP_CONSECUTIVO), 3) 
					
					EXECUTE [dbo].[PG_IN_MATERIAL_PROGRAMADO_LOG]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	10, @VP_SERIAL, @VP_CU_ITEM_NO,
																	'MATERIALES', @PP_COMPUTER_NAME, @VP_NUMERO_RELOJ, ''
					
					-- ///////SE RESTA DEL STADANDARD PACK LO INGRESADO Y SE AUMENTA EL CONSECUTIVO//////////////////////////////////////////////
					SET @VP_CU_CANTIDAD = @VP_CU_CANTIDAD - @VP_STD_PACK
					SET @VP_CONSECUTIVO = @VP_CONSECUTIVO + 1
				END	--END WHILE
			END
									
			FETCH NEXT FROM CU_PATTERN_A_PROGRAMAR INTO		@VP_CU_PATTERN,		@VP_CU_ITEM_NO,		@VP_CU_CANTIDAD,	@VP_CU_S_COLOR_SINF,		@VP_CU_D_COLOR

				IF	@VP_COLOR_ANTERIOR	<>	@VP_CU_S_COLOR_SINF
				BEGIN
					--	ASIGNAR EL COLOR VIEJO COMPARAR CONTRA EL NUEVO, SI SON DIFERENTE SE INSERTA LA ORDEN Y SE REINICIA EL CONSECUTIVO.	
					-- ///////SE INGRESA EL REGISTRO DE LA ORDEN EN CCJOBHDR_SQL//////////////////////////////////////////////
					INSERT INTO CCJOBHDR_SQL 
					(		jobno,					[status],			colour,				colourdesc, 
							machine,				datecreated,		dateplanned,		printedflag, 
							instruct1,				instruct2,			netsqm,				standardsqm, 
							targetutil,				customer,			patterns,	
							plannedshift,			plannedseq,			startedflag,		comments,	
							lotno		 )
					VALUES 
					(		@VP_ORDEN,				'P',				@VP_CU_S_COLOR_SINF,	@VP_CU_D_COLOR, 
							'Table 00',				@VP_FECHA,			@VP_FECHA,			'2', 
							@PP_COMENTARIO,			'',					@VP_TOTAL_NETO,		@VP_TOTAL_GROSS, 
							@VP_UTILIDAD_MINIMA,	@PP_CLIENTE,		@VP_TOTAL_PATRON,	
							@VP_TURNO,				'0',				'',					@PP_HEADER_RMA_COMMENTS, 
							''			)					
					IF @@ROWCOUNT = 0
						RAISERROR ('ERROR: No fue posible agregar la orden en [CCJOBHDR_SQL]', 16, 1 ) 
				
					-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////
					SET	@VP_DETAIL =	'Creacion de Orden: ' + @VP_ORDEN
					EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													@PP_USER, @PP_COMPUTER_NAME, 'RMA',
													@VP_ORDEN, 'Crear orden',
													@VP_DETAIL, ''
				
					SET	@VP_CONSECUTIVO		= 1		--- SE REINICIA CONTEO DE CONSECUTIVOS.
					SET	@VP_COLOR_ANTERIOR	= ''
					SET	@VP_GROSS			= 0	
					SET	@VP_NETO			= 0
					--SET	@VP_PATRON			INT = 0,
					SET	@VP_TOTAL_GROSS		= 0
					SET	@VP_TOTAL_NETO		= 0
					SET	@VP_TOTAL_PATRON	= 0

					-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					-- ///////SE OBTIENE EL NUMERO DE LA ULTIMA ORDEN GENERADA//////////////////////////////////////////////
					SELECT	TOP 1 @VP_ORDEN = CONVERT(INT, LTRIM(RTRIM(user_def_fld_4)))
					FROM	imlocfil_sql	(NOLOCK)
					WHERE	LOC				= 'MFP'
	
					IF @VP_ORDEN IS NULL
						RAISERROR ('ERROR: No fue posible obtener el numero de orden en [CCJOBHDR_SQL]', 16, 1 ) 
	
					SET @VP_ORDEN = @VP_ORDEN + 1
					SET @VP_ORDEN = RIGHT('00000' + @VP_ORDEN, 5)
	
					-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					-- ///////SE ACTUALIZA LA LOCACION MFP CON LA ORDEN CREADA//////////////////////////////////////////////			
					UPDATE imlocfil_sql 
						SET user_def_fld_4 = @VP_ORDEN
					WHERE LOC = 'MFP'	
					IF @@ROWCOUNT = 0
						RAISERROR ('ERROR: No fue posible Actualizar la orden en [imlocfil_sql]', 16, 1 ) 

					-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	


				END --IF	@VP_COLOR_ANTERIOR	<>	@VP_CU_S_COLOR_SINF			
											
					SET	@VP_EX_PATTERN			= @VP_CU_PATTERN		
					SET	@VP_EX_ITEM_NO			= @VP_CU_ITEM_NO		
					SET	@VP_EX_CANTIDAD			= @VP_CU_CANTIDAD
					SET	@VP_EX_S_COLOR_SINF		= @VP_CU_S_COLOR_SINF
					SET	@VP_EX_D_COLOR			= @VP_CU_D_COLOR
					SET	@VP_DETAIL				= ''

		END		--END CURSOR	
	CLOSE		CU_PATTERN_A_PROGRAMAR
	DEALLOCATE	CU_PATTERN_A_PROGRAMAR
	
				IF	(	SELECT		COUNT(JOBNO) 
						FROM		CCJOBHDR_SQL	(NOLOCK)
						WHERE		JOBNO			= @VP_ORDEN	) < 1
				BEGIN
					--	ASIGNAR EL COLOR VIEJO COMPARAR CONTRA EL NUEVO, SI SON DIFERENTE SE INSERTA LA ORDEN Y SE REINICIA EL CONSECUTIVO.	
					-- ///////SE INGRESA EL REGISTRO DE LA ORDEN EN CCJOBHDR_SQL//////////////////////////////////////////////
					INSERT INTO CCJOBHDR_SQL 
					(		jobno,					[status],			colour,				colourdesc, 
							machine,				datecreated,		dateplanned,		printedflag, 
							instruct1,				instruct2,			netsqm,				standardsqm, 
							targetutil,				customer,			patterns,	
							plannedshift,			plannedseq,			startedflag,		comments,	
							lotno		 )
					VALUES 
					(		@VP_ORDEN,				'P',				@VP_EX_S_COLOR_SINF,	@VP_EX_D_COLOR, 
							'Table 00',				@VP_FECHA,			@VP_FECHA,			'2', 
							@PP_COMENTARIO,			'',					@VP_TOTAL_NETO,		@VP_TOTAL_GROSS, 
							@VP_UTILIDAD_MINIMA,	@PP_CLIENTE,		@VP_TOTAL_PATRON,	
							@VP_TURNO,				'0',				'',					@PP_HEADER_RMA_COMMENTS, 
							''			)					
					IF @@ROWCOUNT = 0
						RAISERROR ('ERROR: No fue posible agregar la orden en [CCJOBHDR_SQL]', 16, 1 ) 
				
					-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////
					SET		@VP_DETAIL =	'Creacion de Orden: ' + @VP_ORDEN

					EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													@PP_USER, @PP_COMPUTER_NAME, 'RMA',
													@VP_ORDEN, 'Crear orden',
													@VP_DETAIL, ''
				
				END --IF	(	SELECT		COUNT(JOBNO) 



	---- ///////SE VERIFICA SI LA ORDEN CREADA TIENE KITS (U) DOS TODOS//////////////////////////////////////////////
	--DECLARE @VP_N_KITS_U INT = 0
	--SELECT @VP_N_KITS_U = COUNT(A4GLIdentity) 
	--FROM imkitfil_sql 
	--WHERE comp_item_no IN ( SELECT item_no 
	--						FROM ccjoblin_sql 
	--						WHERE JOBNO = @VP_ORDEN )
	
	--IF @VP_N_KITS_U IS NULL
	--	SET @VP_N_KITS_U = 0
	
	---- ///////SE SI EXISTEN KITS (U) DOS TONOS SE GENERA LA ORDEN COMPLEMENTO//////////////////////////////////////////////
	--IF @VP_N_KITS_U > 0
	--	EXECUTE [dbo].[PG_PR_PLANNING_CREAR_ORDER_2_TONO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--														@VP_ORDEN, @PP_CLIENTE, @PP_MESA, 
	--														@PP_COMENTARIO, @PP_USER, @PP_COMPUTER_NAME

		RAISERROR ('Fin del SP', 16, 1 ) 	
-- ///////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	/* Ocurrió un error, deshacemos los cambios*/ 
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_PR_PLANNING_CREAR_ORDER] // ' + @VP_ERROR_TRANS
END CATCH
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
	BEGIN
		
		SET		@VP_MENSAJE = 'No es posible Crear la Orden: ' + '[' + @VP_ORDEN +'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
	END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_ORDEN AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'PROCESO',
													'',
													-- ===========================================
													'[PR]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @VP_ORDEN, @PP_HEADER_RMA_COMMENTS , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
