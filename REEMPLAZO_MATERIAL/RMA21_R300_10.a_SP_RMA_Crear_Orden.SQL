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

-- //////////////////////////////////////////////////////////////
--//////////	CONTENIDO DEL SP
--	[PG_PR_RMA_CREAR_ORDER]
--	[PG_PR_ENVIAR_CORREO_RMA]


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_RMA_CREAR_ORDER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_RMA_CREAR_ORDER]
GO
--			EXEC [dbo].[PG_PR_RMA_CREAR_ORDER] 0 ,139, 4
CREATE PROCEDURE [dbo].[PG_PR_RMA_CREAR_ORDER]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_HEADER_RMA			INT
AS
	-- ///////////////////////////////////////////
	DECLARE  @VP_MENSAJE		NVARCHAR(MAX)	= ''
			,@VP_ORDEN			VARCHAR(10)		= ''
			,@VP_K_USER			INT				= ( SELECT K_USUARIO_ALTA	FROM HEADER_RMA	WHERE	K_HEADER_RMA	= @PP_K_HEADER_RMA	)
			,@VP_COMPUTER_NAME	VARCHAR(25)		= 'IT-002'
			,@VP_COMENTARIO		VARCHAR(250)	= ''--'Orden Generada automaticamente #RMA['+ CONVERT(VARCHAR(10),@PP_K_HEADER_RMA) +']'			
			,@VP_CLIENTE		VARCHAR(10)		= ( SELECT CUS_NO	FROM HEADER_RMA	WHERE	K_HEADER_RMA	= @PP_K_HEADER_RMA	)
			,@VP_NO_SECUENCIA	INT		= 0
			--=================================================================
			,@VP_K_ESTATUS_RMA	INT		= 0
			,@VP_JOB			NVARCHAR(MAX) = ''
	-- //////////////////////////////////////////////////////////////
--BEGIN TRANSACTION 
--BEGIN TRY
		---- ///////ACTUALIZAR EL ENCABEZADO DEL RMA //////////////////////////////////////////////
			SELECT	@VP_K_ESTATUS_RMA	= K_STATUS_RMA 
			FROM	HEADER_RMA
			WHERE	K_HEADER_RMA	= @PP_K_HEADER_RMA
			
			IF ( @VP_K_ESTATUS_RMA <> 6 ) OR ( @VP_K_ESTATUS_RMA IS NULL )
			BEGIN
				RAISERROR ('La orden no ha sido aprobada.', 16, 1 ) 
			END

		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		-- ///////SE OBTIENE EL NUMERO DE LA ULTIMA ORDEN GENERADA//////////////////////////////////////////////
		SELECT	TOP 1 @VP_ORDEN = CONVERT(INT, LTRIM(RTRIM(user_def_fld_4)))
		FROM	[DATA_02].[dbo].imlocfil_sql	(NOLOCK)
		WHERE	LOC				= 'MFP'
	
		IF @VP_ORDEN IS NULL
		BEGIN
			RAISERROR ('No fue posible obtener el numero de orden en [CCJOBHDR]', 16, 1 ) 
		END
	
		SET @VP_ORDEN = @VP_ORDEN + 1
		SET @VP_ORDEN = RIGHT('00000' + @VP_ORDEN, 5)
	
		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		-- ///////SE ACTUALIZA LA LOCACION MFP CON LA ORDEN CREADA//////////////////////////////////////////////			
		UPDATE [DATA_02].[dbo].imlocfil_sql 
		SET		user_def_fld_4	= @VP_ORDEN
		WHERE	LOC				= 'MFP'	
		IF @@ROWCOUNT = 0
		BEGIN
			RAISERROR ('No fue posible Actualizar la orden en [IMLOCFIL]', 16, 1 ) 
		END

		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
		-- ///////SE OBTIENE LA FECHA EN FORMATO NUMERICO//////////////////////////////////////////////
		DECLARE @VP_FECHA	INT = DBO.CONVERT_DATE_TO_INT(GETDATE(), 'yyyyMMdd');
		DECLARE @VP_HORA	INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
		DECLARE @VP_TURNO	VARCHAR(5) = '2'
	
		IF @VP_HORA > 2000 AND @VP_HORA < 60002
		BEGIN
			SET @VP_TURNO = '3'
		END
		ELSE IF @VP_HORA > 60001 AND @VP_HORA < 153001
		BEGIN
			SET @VP_TURNO = '1'
		END

		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
		-- /////////SE OBTIENE LA UTILIDAD//////////////////////////////////
		DECLARE @VP_UTILIDAD_MINIMA DECIMAL(13,2) = 0
		SELECT	@VP_UTILIDAD_MINIMA = User_Def_Fld_2
		FROM	arcusfil_sql		(NOLOCK)
		WHERE	CUS_NO				= @VP_CLIENTE
	
		IF @VP_UTILIDAD_MINIMA IS NULL
		BEGIN
			SET @VP_UTILIDAD_MINIMA = 0
		END
	
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
				,TA_K_DETAILS					INT
				,TA_GRUPO_ORDEN					INT
		)
		--SET NOCOUNT ON
		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			INSERT	INTO	@TBL_PATTERN_A_PROGRAMAR
						(	 TA_S_PATTERN					
							,TA_ITEM_NO						
							,TA_CANTIDAD					
							,TA_S_COLOR_SINF			
							,TA_D_COLOR				
							,TA_K_DETAILS		
							,TA_GRUPO_ORDEN		)
			SELECT	 LEFT(ITEM_NO,8)
					,ITEM_NO
					,CANTIDAD_ORDENADA
					,RIGHT(ITEM_NO,6)
					,(	SELECT	LTRIM(RTRIM(ITEM_DESC_1))
						FROM	IMITMIDX_SQL		(NOLOCK)
						WHERE	IMITMIDX_SQL.item_no	= CONCAT('F',RIGHT(DETAILS_RMA.ITEM_NO,6))					
					)
					,K_DETAILS_RMA
					,GRUPO_ORDEN
			FROM	DETAILS_RMA
			WHERE	K_HEADER_RMA		= @PP_K_HEADER_RMA

		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		-- ///////SE VALIDA QUE EXISTA REGISTROS EN LA TABLA TEMPORAL///////////////////////////////////////////////////////
		IF	(	SELECT	COUNT(TA_K_PATTERN_A_PROGRAMAR)
				FROM	@TBL_PATTERN_A_PROGRAMAR		)	<= 0
		BEGIN
				RAISERROR ('No hay Patterns para programar.', 16, 1 ) 
		END

	-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	-- //////SE DECLARAN VARIABLES A USARSE/////////////////////////////////////
	DECLARE  @VP_CU_PATTERN			VARCHAR(50)		= '',	@VP_CU_ITEM_NO		VARCHAR(100)	= '',	@VP_CU_CANTIDAD		INT = 0,		
			 @VP_CU_S_COLOR_SINF	VARCHAR(10)		= '',	@VP_CU_D_COLOR		VARCHAR(10)		= '',	@VP_CU_K_DETAILS	INT, 
			 @VP_GROSS				DECIMAL(16,4)	= 0,	@VP_NETO			DECIMAL(16,4)	= 0,	@VP_PATRON			INT = 0,
			 @VP_TOTAL_GROSS		DECIMAL(16,4)	= 0,	@VP_TOTAL_NETO		DECIMAL(16,4)	= 0,	@VP_TOTAL_PATRON	INT = 0,
			 @VP_CONSECUTIVO		INT				= 1,	@VP_NUMERO_RELOJ	INT				= 0,	
			 --=============================================================================================================================
			 @VP_CU_S_COLOR_SINF_anterior	VARCHAR(10)	= '',
			 @VP_CU_D_COLOR_anterior		VARCHAR(10)	= '',
			 --=============================================================================================================================
			 @VP_EX_PATTERN			VARCHAR(50)		= '',	@VP_EX_ITEM_NO		VARCHAR(100)	= '',	@VP_EX_CANTIDAD		INT = 0,		
			 @VP_EX_S_COLOR_SINF	VARCHAR(10)		= '',	@VP_EX_D_COLOR		VARCHAR(10)		= '',
			 --=============================================================================================================================
			 @VP_DETAIL				VARCHAR(100) =	''
	
	-- //////SE OBTIENE EL NUMERO DE RELOJ DEL USUARIO PEARL/////////////////////////////////////
		SELECT	@VP_NUMERO_RELOJ		= K_EMPLEADO_PEARL
		FROM	BD_GENERAL.DBO.USUARIO_PEARL	(NOLOCK)
		WHERE	K_USUARIO_PEARL			= @VP_K_USER
	
	-- //////SE CREA CURSOR PARA DARLE FORMATO A LOS DATOS/////////////////////////////////////
	DECLARE CU_PATTERN_A_PROGRAMAR CURSOR FOR			
			SELECT	 TA_S_PATTERN
					,TA_ITEM_NO
					,TA_CANTIDAD
					,TA_S_COLOR_SINF
					,TA_D_COLOR
					,TA_K_DETAILS
			FROM	@TBL_PATTERN_A_PROGRAMAR
			ORDER BY	TA_S_COLOR_SINF,	TA_GRUPO_ORDEN,		TA_ITEM_NO,		TA_CANTIDAD
	OPEN CU_PATTERN_A_PROGRAMAR
	FETCH NEXT FROM CU_PATTERN_A_PROGRAMAR INTO		@VP_CU_PATTERN,		@VP_CU_ITEM_NO,		@VP_CU_CANTIDAD,	@VP_CU_S_COLOR_SINF,		@VP_CU_D_COLOR,		@VP_CU_K_DETAILS
	WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE  @VP_CUBE_LENGTH		DECIMAL(13,4) = 0	,@VP_CUBE_WIDTH			DECIMAL(13,4)	= 0		,@VP_CUBE_QTY_PER	DECIMAL(13,4) = 0
					,@VP_D_ITEM				VARCHAR(255)		,@VP_CHANGE_LEVEL		VARCHAR(100)			,@VP_MODELO			VARCHAR(50)
					,@VP_VERSION			VARCHAR(50)			,@VP_SERIAL				VARCHAR(50)		= ''	

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
			BEGIN
				SET @VP_CUBE_LENGTH = 0
			END
	
			IF @VP_CUBE_WIDTH IS NULL
			BEGIN
				SET @VP_CUBE_WIDTH = 0
			END
	
			IF @VP_CUBE_QTY_PER IS NULL
			BEGIN
				SET @VP_CUBE_QTY_PER = 0
			END
	
			SET @VP_GROSS	= @VP_CUBE_LENGTH	*	@VP_CU_CANTIDAD
			SET @VP_NETO	= @VP_CUBE_WIDTH	*	@VP_CU_CANTIDAD
			--SET @VP_PATRON	= @VP_CUBE_QTY_PER	*	@VP_CU_CANTIDAD
	
			SET @VP_TOTAL_GROSS		= @VP_TOTAL_GROSS	+	@VP_GROSS
			SET @VP_TOTAL_NETO		= @VP_TOTAL_NETO	+	@VP_NETO
			--SET @VP_TOTAL_PATRON	= @VP_TOTAL_PATRON	+	@VP_PATRON
			SET @VP_TOTAL_PATRON	= @VP_TOTAL_PATRON	+	@VP_CU_CANTIDAD
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
			--AND		RIGHT(LTRIM(RTRIM(cccusitm_sql.item_no)),6)		=	@VP_CU_S_COLOR_SINF
			AND		ccverhdr_sql.cus_no								=	@VP_CLIENTE
			AND		cccusitm_sql.item_no							=	@VP_CU_ITEM_NO
	
				SET @VP_CHANGE_LEVEL = @VP_MODELO + @VP_VERSION

			IF	LEN(@VP_CHANGE_LEVEL)	<	7
			BEGIN
				RAISERROR ('No fue posible obtener el Change Level.', 16, 1 ) 
			END
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
			BEGIN
				RAISERROR ('No fue posible obtener el Estandar Pack en [CCITMIDX]', 16, 1 ) 
			END
			-- ///////////////////////////////////////////////////////////////////////////////////////
			-- ///////////////////////////////////////////////////////////////////////////////////////
			-- ///////////////////////////////////////////////////////////////////////////////////////
			-- //////SE INGRESAN LOS KITS EN LA TABLA ccjoblin_sql/////////////////////////////////////
			IF @VP_CU_CANTIDAD < @VP_STD_PACK
			BEGIN
				INSERT INTO	[DATA_02].[dbo].ccjoblin_sql
				(		jobno,				kit,				kitdesc,		item_no, 
						PlannedQty,			OriginalQty,		CompletedQty, 
						netsqmper,			stdsqmper,			patternsper, 
						customer,			ChangeLevel,		Ser_no					)
				VALUES	
				(		@VP_ORDEN,			@VP_CU_PATTERN,		@VP_D_ITEM,		@VP_CU_ITEM_NO, 
						@VP_CU_CANTIDAD,	@VP_CU_CANTIDAD,	0,--0 ES VALOR POR DEFAULT
						@VP_CUBE_WIDTH,		@VP_CUBE_LENGTH,	1,--SE PONE 1, YA QUE LA RELACIÓN ES UN PATRON CONTIENE UN PATRON
						@VP_CLIENTE,		@VP_CHANGE_LEVEL,	@VP_CONSECUTIVO			)				
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE	= 'No fue posible agregar el pattern ['+ @VP_CU_ITEM_NO +'] a la orden en [CCJOBLIN].'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END
	
				-- ///////SE GUARDA EL REGISTRO DEL MATERIAL ESCANEADO//////////////////////////////////////////////
				SET @VP_SERIAL  = @VP_ORDEN + RIGHT('000'+ CONVERT(VARCHAR(10), @VP_CONSECUTIVO), 3) 
				
				EXECUTE [DATA_02].[dbo].[PG_IN_MATERIAL_PROGRAMADO_LOG]	@PP_K_SISTEMA_EXE,	@VP_K_USER,--@PP_K_USUARIO_ACCION,
																		10,				@VP_SERIAL,			@VP_CU_ITEM_NO,
																		'MATERIALES',	@VP_COMPUTER_NAME,	@VP_NUMERO_RELOJ, 
																		''				
				--========================================================================================================================================
				UPDATE	DETAILS_RMA
				SET		JOBNO			= 	@VP_ORDEN,
						SERIAL			=	@VP_SERIAL
				WHERE	K_DETAILS_RMA	=	@VP_CU_K_DETAILS
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE	= 'No fue posible actualizar el detalle RMA ['+ CONVERT(VARCHAR(10),@VP_CU_K_DETAILS) +'] a la orden en [CCJOBLIN].'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END
				--========================================================================================================================================

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
						INSERT INTO	[DATA_02].[dbo].ccjoblin_sql
						(		jobno,				kit,				kitdesc,		item_no, 
								PlannedQty,			OriginalQty,		CompletedQty, 
								netsqmper,			stdsqmper,			patternsper, 
								customer,			ChangeLevel,		Ser_no					)
						VALUES	
						(		@VP_ORDEN,			@VP_CU_PATTERN,		@VP_D_ITEM,		@VP_CU_ITEM_NO, 
								@VP_STD_PACK,		@VP_STD_PACK,		0,--0 ES VALOR POR DEFAULT
								@VP_CUBE_WIDTH,		@VP_CUBE_LENGTH,	1,--SE PONE 1, YA QUE LA RELACIÓN ES UN PATRON CONTIENE UN PATRON
								@VP_CLIENTE,		@VP_CHANGE_LEVEL,	@VP_CONSECUTIVO			)				
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE	= 'No fue posible agregar el pattern ['+ @VP_CU_ITEM_NO +'] a la orden en [CCJOBLIN].'
							RAISERROR (@VP_MENSAJE, 16, 1 )
						END
						--========================================================================================================================================
						UPDATE	DETAILS_RMA
						SET		JOBNO			= 	@VP_ORDEN,
								SERIAL			=	@VP_SERIAL
						WHERE	K_DETAILS_RMA	=	@VP_CU_K_DETAILS
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE	= 'No fue posible actualizar el detalle RMA ['+ CONVERT(VARCHAR(10),@VP_CU_K_DETAILS) +'] a la orden en [CCJOBLIN].'
							RAISERROR (@VP_MENSAJE, 16, 1 )
						END
						--========================================================================================================================================

					END
					ELSE
					BEGIN
						INSERT INTO	[DATA_02].[dbo].ccjoblin_sql
						(		jobno,				kit,				kitdesc,		item_no, 
								PlannedQty,			OriginalQty,		CompletedQty, 
								netsqmper,			stdsqmper,			patternsper, 
								customer,			ChangeLevel,		Ser_no					)
						VALUES	
						(		@VP_ORDEN,			@VP_CU_PATTERN,		@VP_D_ITEM,		@VP_CU_ITEM_NO, 
								@VP_CU_CANTIDAD,	@VP_CU_CANTIDAD,	0,--0 ES VALOR POR DEFAULT
								@VP_CUBE_WIDTH,		@VP_CUBE_LENGTH,	1,--SE PONE 1, YA QUE LA RELACIÓN ES UN PATRON CONTIENE UN PATRON
								@VP_CLIENTE,		@VP_CHANGE_LEVEL,	@VP_CONSECUTIVO			)				
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE	= 'No fue posible agregar el pattern ['+ @VP_CU_ITEM_NO +'] a la orden en [CCJOBLIN].'
							RAISERROR (@VP_MENSAJE, 16, 1 )
						END
						--========================================================================================================================================
						UPDATE	DETAILS_RMA
						SET		JOBNO			= 	@VP_ORDEN,
								SERIAL			=	@VP_SERIAL
						WHERE	K_DETAILS_RMA	=	@VP_CU_K_DETAILS
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE	= 'No fue posible actualizar el detalle RMA ['+ CONVERT(VARCHAR(10),@VP_CU_K_DETAILS) +'] a la orden en [CCJOBLIN].'
							RAISERROR (@VP_MENSAJE, 16, 1 )
						END
						--========================================================================================================================================
					END
	
					-- ///////SE GUARDA EL REGISTRO DEL MATERIAL ESCANEADO//////////////////////////////////////////////
					SET @VP_SERIAL  = @VP_ORDEN + RIGHT('000'+ CONVERT(VARCHAR(10), @VP_CONSECUTIVO), 3) 

					EXECUTE [DATA_02].[dbo].[PG_IN_MATERIAL_PROGRAMADO_LOG]	@PP_K_SISTEMA_EXE,	@VP_K_USER,--@PP_K_USUARIO_ACCION,
																			10,				@VP_SERIAL,			@VP_CU_ITEM_NO,
																			'MATERIALES',	@VP_COMPUTER_NAME,	@VP_NUMERO_RELOJ, 
																			''
					
					-- ///////SE RESTA DEL STADANDARD PACK LO INGRESADO Y SE AUMENTA EL CONSECUTIVO//////////////////////////////////////////////
					SET @VP_CU_CANTIDAD = @VP_CU_CANTIDAD - @VP_STD_PACK
					SET @VP_CONSECUTIVO = @VP_CONSECUTIVO + 1
				END	--END WHILE
			END

				-- ///////////////////////////////////////////////////////////////////////////////////////	
				SET	@VP_CU_S_COLOR_SINF_anterior	= 	@VP_CU_S_COLOR_SINF				
				SET	@VP_CU_D_COLOR_anterior			=	@VP_CU_D_COLOR
									
			FETCH NEXT FROM CU_PATTERN_A_PROGRAMAR INTO		@VP_CU_PATTERN,		@VP_CU_ITEM_NO,		@VP_CU_CANTIDAD,	@VP_CU_S_COLOR_SINF,		@VP_CU_D_COLOR,		@VP_CU_K_DETAILS

				IF	@VP_CU_S_COLOR_SINF_anterior	<>	@VP_CU_S_COLOR_SINF
				BEGIN
					--	ASIGNAR EL COLOR VIEJO COMPARAR CONTRA EL NUEVO, SI SON DIFERENTE SE INSERTA LA ORDEN Y SE REINICIA EL CONSECUTIVO.	
					-- ///////SE INGRESA EL REGISTRO DE LA ORDEN EN CCJOBHDR_SQL//////////////////////////////////////////////
					
					SET	@VP_NO_SECUENCIA	= @VP_NO_SECUENCIA + 1					
					SET	@VP_COMENTARIO		= 'Ord. Generada autom. #RMA['+ CONVERT(VARCHAR(10),@PP_K_HEADER_RMA) +'] Sec'+CONVERT(VARCHAR(10),@VP_NO_SECUENCIA)+''

					INSERT INTO [DATA_02].[dbo].CCJOBHDR_SQL 
					(		jobno,					[status],			colour,				colourdesc, 
							machine,				datecreated,		dateplanned,		printedflag, 
							instruct1,				instruct2,			netsqm,				standardsqm, 
							targetutil,				customer,			patterns,	
							plannedshift,			plannedseq,			startedflag,		comments,	
							lotno		 )
					VALUES 
					(		@VP_ORDEN,				'P',				@VP_CU_S_COLOR_SINF_anterior,	@VP_CU_D_COLOR_anterior, 
							'Table 79',				@VP_FECHA,			@VP_FECHA,			'2', 
							@VP_COMENTARIO,			'',					@VP_TOTAL_NETO,		@VP_TOTAL_GROSS, 
							@VP_UTILIDAD_MINIMA,	@VP_CLIENTE,		@VP_TOTAL_PATRON,	
							@VP_TURNO,				'0',				'',					@VP_COMENTARIO, 
							''			)					
					IF @@ROWCOUNT = 0
					BEGIN
						RAISERROR ('No fue posible agregar la orden en [CCJOBHDR]', 16, 1 ) 
					END
					
					-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////
					SET	@VP_DETAIL =	'Creacion de Orden: ' + @VP_ORDEN
					EXECUTE [DATA_02].[dbo].[PG_IN_PEARL_LOG]	@PP_K_SISTEMA_EXE, @VP_K_USER,--@PP_K_USUARIO_ACCION,
													@VP_K_USER,		@VP_COMPUTER_NAME,	'RMA',
													@VP_ORDEN,		'Crear orden',		@VP_DETAIL, 
													''
					
					-- /////////////////////////////////////////////////////// SE ACTUALIZA EL CAMPO DE JOBNOS EN EL ENCABEZADO.
					
					SET @VP_JOB = ''

					SELECT	@VP_JOB	= JOBNO
					FROM	HEADER_RMA		(NOLOCK)
					WHERE	K_HEADER_RMA = @PP_K_HEADER_RMA

					IF @VP_JOB <> ''
						SET @VP_JOB	= @VP_ORDEN + ' / ' + @VP_JOB
					ELSE
						SET	@VP_JOB	= @VP_ORDEN					

						UPDATE	HEADER_RMA
						SET		JOBNO	= @VP_JOB
						WHERE	K_HEADER_RMA = @PP_K_HEADER_RMA
						IF @@ROWCOUNT = 0
						BEGIN
							RAISERROR ('No fue posible agregar la orden en [HEADER_RMA]', 16, 1 ) 
						END				

					-- /////////////////////////ENVÍO DEL CORREO A USUARIO DE RMA////////////////////////////////////////////
					EXECUTE [PG_PR_ENVIAR_CORREO_RMA]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, @PP_K_HEADER_RMA, @VP_ORDEN,	@VP_NO_SECUENCIA

					
					-- /////////////////////////////////////////////	SE REINICIA CONTEO DE CONSECUTIVOS.
					SET	@VP_CONSECUTIVO		= 1
					SET	@VP_CU_S_COLOR_SINF_anterior	= ''
					SET	@VP_CU_D_COLOR_anterior			= '' 
					SET	@VP_GROSS			= 0	
					SET	@VP_NETO			= 0
					--SET	@VP_PATRON			INT = 0,
					SET	@VP_TOTAL_GROSS		= 0
					SET	@VP_TOTAL_NETO		= 0
					SET	@VP_TOTAL_PATRON	= 0

					-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					-- ///////SE OBTIENE EL NUMERO DE LA ULTIMA ORDEN GENERADA//////////////////////////////////////////////
					SELECT	TOP 1 @VP_ORDEN = CONVERT(INT, LTRIM(RTRIM(user_def_fld_4)))
					FROM	[DATA_02].[dbo].imlocfil_sql	(NOLOCK)
					WHERE	LOC				= 'MFP'
	
					IF @VP_ORDEN IS NULL
					BEGIN
						RAISERROR ('No fue posible obtener el numero de orden en [CCJOBHDR]', 16, 1 ) 
					END
	
					SET @VP_ORDEN = @VP_ORDEN + 1
					SET @VP_ORDEN = RIGHT('00000' + @VP_ORDEN, 5)
	
					-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					-- ///////SE ACTUALIZA LA LOCACION MFP CON LA ORDEN CREADA//////////////////////////////////////////////			
					UPDATE [DATA_02].[dbo].imlocfil_sql 
						SET user_def_fld_4 = @VP_ORDEN
					WHERE LOC = 'MFP'	
					IF @@ROWCOUNT = 0
					BEGIN
						RAISERROR ('No fue posible Actualizar la orden en [IMLOCFIL]', 16, 1 ) 
					END
					-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
				END --IF	@VP_COLOR_ANTERIOR	<>	@VP_CU_S_COLOR_SINF			
											
					--SET	@VP_EX_PATTERN			= @VP_CU_PATTERN		
					--SET	@VP_EX_ITEM_NO			= @VP_CU_ITEM_NO		
					--SET	@VP_EX_CANTIDAD			= @VP_CU_CANTIDAD
					--SET	@VP_EX_S_COLOR_SINF		= @VP_CU_S_COLOR_SINF
					--SET	@VP_EX_D_COLOR			= @VP_CU_D_COLOR
					--SET	@VP_DETAIL				= ''

		END		--END CURSOR	
	CLOSE		CU_PATTERN_A_PROGRAMAR
	DEALLOCATE	CU_PATTERN_A_PROGRAMAR
	
				IF	(	SELECT		COUNT(JOBNO) 
						FROM		[DATA_02].[dbo].CCJOBHDR_SQL	(NOLOCK)
						WHERE		JOBNO			= @VP_ORDEN	) < 1
				BEGIN
					
					SET	@VP_NO_SECUENCIA	= @VP_NO_SECUENCIA + 1					
					SET	@VP_COMENTARIO		= 'Ord. Generada autom. #RMA['+ CONVERT(VARCHAR(10),@PP_K_HEADER_RMA) +'] Sec'+CONVERT(VARCHAR(10),@VP_NO_SECUENCIA)+''

					--	ASIGNAR EL COLOR VIEJO COMPARAR CONTRA EL NUEVO, SI SON DIFERENTE SE INSERTA LA ORDEN Y SE REINICIA EL CONSECUTIVO.	
					-- ///////SE INGRESA EL REGISTRO DE LA ORDEN EN CCJOBHDR_SQL//////////////////////////////////////////////
					INSERT INTO [DATA_02].[dbo].CCJOBHDR_SQL 
					(		jobno,					[status],			colour,				colourdesc, 
							machine,				datecreated,		dateplanned,		printedflag, 
							instruct1,				instruct2,			netsqm,				standardsqm, 
							targetutil,				customer,			patterns,	
							plannedshift,			plannedseq,			startedflag,		comments,	
							lotno		 )
					VALUES 
					(		@VP_ORDEN,				'P',				@VP_CU_S_COLOR_SINF_anterior,	@VP_CU_D_COLOR_anterior,	--@VP_EX_S_COLOR_SINF,	@VP_EX_D_COLOR, 
							'Table 79',				@VP_FECHA,			@VP_FECHA,			'2', 
							@VP_COMENTARIO,			'',					@VP_TOTAL_NETO,		@VP_TOTAL_GROSS, 
							@VP_UTILIDAD_MINIMA,	@VP_CLIENTE,		@VP_TOTAL_PATRON,	
							@VP_TURNO,				'0',				'',					@VP_COMENTARIO, 
							''			)					
					IF @@ROWCOUNT = 0
					BEGIN
						RAISERROR ('No fue posible agregar la orden en [CCJOBHDR]', 16, 1 ) 
					END
				
					-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////
					SET		@VP_DETAIL =	'Creacion de Orden: ' + @VP_ORDEN

					EXECUTE [DATA_02].[dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @VP_K_USER,--@PP_K_USUARIO_ACCION,
													@VP_K_USER, @VP_COMPUTER_NAME, 'RMA',
													@VP_ORDEN, 'Crear orden',
													@VP_DETAIL, ''

					-- /////////////////////////////////////////////////////// SE ACTUALIZA EL CAMPO DE JOBNOS EN EL ENCABEZADO.					
					SET @VP_JOB = ''

					SELECT	@VP_JOB	= JOBNO
					FROM	HEADER_RMA		(NOLOCK)
					WHERE	K_HEADER_RMA = @PP_K_HEADER_RMA

					IF @VP_JOB <> ''
						SET @VP_JOB	= @VP_ORDEN + ' / ' + @VP_JOB
					ELSE
						SET	@VP_JOB	= @VP_ORDEN					

						UPDATE	HEADER_RMA
						SET		JOBNO	= @VP_JOB
						WHERE	K_HEADER_RMA = @PP_K_HEADER_RMA
						IF @@ROWCOUNT = 0
						BEGIN
							RAISERROR ('No fue posible agregar la orden en [HEADER_RMA]', 16, 1 ) 
						END				

					-- /////////////////////////ENVÍO DEL CORREO A USUARIO DE RMA////////////////////////////////////////////
					EXECUTE [PG_PR_ENVIAR_CORREO_RMA]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, @PP_K_HEADER_RMA, @VP_ORDEN,	@VP_NO_SECUENCIA
									
				END --IF	(	SELECT		COUNT(JOBNO) 

	---- ///////ACTUALIZAR EL ENCABEZADO DEL RMA //////////////////////////////////////////////
	UPDATE	HEADER_RMA
	SET		K_STATUS_RMA	= 7
	WHERE	K_HEADER_RMA	= @PP_K_HEADER_RMA
	IF @@ROWCOUNT = 0
	BEGIN
		RAISERROR ('No fue posible actualizar la orden (RMA).', 16, 1 ) 
	END

	--RAISERROR ('Fin del SP', 16, 1 )
-- ///////////////////////////////////////////
--COMMIT TRANSACTION 
--END TRY

--BEGIN CATCH
--	/* Ocurrió un error, deshacemos los cambios*/ 
--	ROLLBACK TRANSACTION
--	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
--	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
--	SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_PR_RMA_CREAR_ORDER] // ' + @VP_ERROR_TRANS
--END CATCH
--	-- /////////////////////////////////////////////////////////////////////
--	-- /////////////////////////////////////////////////////////////////////
--	IF @VP_MENSAJE<>''
--	BEGIN
		
--		SET		@VP_MENSAJE = 'No es posible Crear la Orden: ' + '[' + @VP_ORDEN +'] ' + @VP_MENSAJE 
		
--		--UPDATE HEADER_RMA
--		--SET		K_STATUS_RMA	= 0
--		--WHERE	K_HEADER_RMA	IN (SELECT TA_K_HEADER_RMA FROM @TBL_PATTERN_A_PROGRAMAR )

--	END
	
--	SELECT	@VP_MENSAJE AS MENSAJE, @VP_ORDEN AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	--EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--												-- ===========================================
	--												2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
	--												'PROCESO',
	--												'',
	--												-- ===========================================
	--												'[PR]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
	--												0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
	--												-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
	--												0, 0, @VP_ORDEN, @VP_COMENTARIO, 0.00, 0.00,
	--												-- === @PP_VALOR_1 al 6_DATO
	--												'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> ENVIAR CORREO
-- //////////////////////////////////////////////////////////////	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_ENVIAR_CORREO_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_ENVIAR_CORREO_RMA]
GO
--		 EXECUTE [dbo].[PG_PR_ENVIAR_CORREO_RMA]	0,139,  4, 39404,1
CREATE PROCEDURE [dbo].[PG_PR_ENVIAR_CORREO_RMA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_HEADER_RMA				INT,
	@PP_ORDEN						INT,
	@PP_NO_SECUENCIA				INT
AS
DECLARE @VP_MENSAJE			VARCHAR(500)=''
DECLARE @VP_ESTATUS_PO		INT
-- /////////////////////////////////////////////////////////////////////
	DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)	= '';

	DECLARE @VP_SUBJECT NVARCHAR(MAX) ;
	DECLARE @VP_BODY_HTML  NVARCHAR(MAX) ;
	DECLARE @VP_ID_MAIL INT;
	DECLARE @VP_SENT_STATUS VARCHAR(500);
	----================================================================
	----================================================================
	SELECT		@VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO.CORREO_USUARIO_PEARL	
	FROM		HEADER_RMA		(NOLOCK)
	LEFT JOIN	BD_GENERAL.DBO.USUARIO_PEARL	AS CORREO_USUARIO	ON	HEADER_RMA.K_USUARIO_ALTA	= CORREO_USUARIO.K_USUARIO_PEARL
	WHERE		K_HEADER_RMA	=	@PP_K_HEADER_RMA
	----================================================================
		SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))
		SET @VP_SUBJECT = '[RMA#' + CONVERT(VARCHAR(10),FORMAT(@PP_K_HEADER_RMA,'000000')) +'] APROBADA'
		
		SET @VP_BODY_HTML =
		N'<html>'+
		N'<head>'+		
		N'</head>'+
		N'<body>'+
		N'<span style="color:black; font-size:12pt">	Buen día:<br>' +
		N'La orden de compra indicada en el asunto del mensaje, ha sido aprobada por Gerencia de Planta.<br>'+
		N'Puedes Verificar el estatus del pedido en la pantalla donde generaste la Orden.<br><br>'+
		
		--N'La orden indicada en el asunto del mensaje, ha sido aprobada por Gerencia de Planta.<br>'+
		--N'Puedes Verificar el estatus y el número de orden asignada en la pantalla donde generaste la Orden.</span><br><br>'+
		N'[Orden#' + CONVERT(VARCHAR(10),FORMAT(@PP_ORDEN,'00000')) +'] // Secuencia ('+ CONVERT(VARCHAR(10),@PP_NO_SECUENCIA) +')'+
		N'</body>'+
		N'</html>';

			EXEC msdb.dbo.sp_send_dbmail @recipients=@VP_RECIPIENTS,
			--@blind_copy_recipients='rafaelf@PEARLLEATHER.COM.MX',
			@subject = @VP_SUBJECT,
			@body = @VP_BODY_HTML,  
			@body_format = 'HTML';
			--@mailitem_id = @VP_ID_MAIL OUTPUT;

	-- ////////////////////////////////////////////////////////////////
	-- ///////////////////////////////////////////////////////////////
GO

---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> ENVIAR CORREO
---- // PARA ENVIAR CORREO A LOS USUARIOS QUE GENERARON LA ORDEN DE COMPRA.
---- //////////////////////////////////////////////////////////////
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_ENVIAR_CORREO_RMA]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_PR_ENVIAR_CORREO_RMA]
--GO
----		 EXECUTE [dbo].[PG_PR_ENVIAR_CORREO_RMA]	0,139,  4, 39404,1
--CREATE PROCEDURE [dbo].[PG_PR_ENVIAR_CORREO_RMA]
--	@PP_K_SISTEMA_EXE				INT,
--	@PP_K_USUARIO_ACCION			INT,
--	-- ===========================
--	@PP_K_HEADER_RMA				INT,
--	@PP_ORDEN						INT,
--	@PP_NO_SECUENCIA				INT
--AS
--DECLARE @VP_MENSAJE			VARCHAR(500)=''
--DECLARE @VP_ESTATUS_RMA		INT
---- /////////////////////////////////////////////////////////////////////
--	DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)	= '';

--	DECLARE @VP_SUBJECT NVARCHAR(MAX) ;
--	DECLARE @VP_BODY_HTML  NVARCHAR(MAX) ;
--	DECLARE @VP_ID_MAIL INT;
--	DECLARE @VP_SENT_STATUS VARCHAR(500);
--	----================================================================
--	SELECT		@VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO.CORREO_USUARIO_PEARL	
--	FROM		HEADER_RMA
--	LEFT JOIN	BD_GENERAL.DBO.USUARIO_PEARL	AS CORREO_USUARIO	ON	HEADER_RMA.K_USUARIO_ALTA	= CORREO_USUARIO.K_USUARIO_PEARL
--	WHERE		K_HEADER_RMA	=	@PP_K_HEADER_RMA
			
--	----================================================================
--		IF LEN(@VP_RECIPIENTS)>5
--		BEGIN
--			SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))
--			SET @VP_SUBJECT = '[RMA#' + CONVERT(VARCHAR(10),FORMAT(@PP_K_HEADER_RMA,'000000')) +'] APROBADA'
		
--			SET @VP_BODY_HTML =
--			N'<html>'+
--			N'<head>'+		
--			N'</head>'+
--			N'<body>'+

--			N'<p style="color:black; font-size:14.0pt;font-family:"Calisto MT",serif">'+
--			N'Buen día:<br>' +

--			N'La orden indicada en el asunto del mensaje, ha sido aprobada por Gerencia de Planta.<br>'+
--			N'Puedes Verificar el estatus y el número de orden asignada en la pantalla donde generaste la Orden.</span><br><br>'+
--			N'[Orden#' + CONVERT(VARCHAR(10),FORMAT(@PP_ORDEN,'00000')) +'] // Secuencia ('+ CONVERT(VARCHAR(10),@PP_NO_SECUENCIA) +')'+
--			N'</body>'+
--			N'</html>';


--			EXEC msdb.dbo.sp_send_dbmail @recipients=@VP_RECIPIENTS,
--			--@copy_recipients='franciscoe@pearlleather.com.mx',
--			--@blind_copy_recipients='alejandrod@pearlleather.com.mx',
--			@subject = @VP_SUBJECT,
--			@body = @VP_BODY_HTML,  
--			@body_format = 'HTML'		
--		END
--	-- ////////////////////////////////////////////////////////////////
--	-- ///////////////////////////////////////////////////////////////
--GO
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
