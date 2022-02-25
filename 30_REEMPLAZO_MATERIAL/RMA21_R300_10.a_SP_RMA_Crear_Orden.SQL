-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			RMA
-- // OPERATION:		TABLE
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210622
-- //////////////////////////////////////////////////////////////  

USE [DATA_02] 
--USE [DATA_02Pruebas] 
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
--			EXEC [dbo].[PG_PR_RMA_CREAR_ORDER] 0 ,139, 44
--			EXEC [dbo].[PG_PR_RMA_CREAR_ORDER] 0 ,139, 1183
CREATE PROCEDURE [dbo].[PG_PR_RMA_CREAR_ORDER]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_HEADER_RMA			INT
AS
	-- ///////////////////////////////////////////
	DECLARE  @VP_MENSAJE		NVARCHAR(MAX)	= ''
			,@VP_ORDEN			VARCHAR(10)		= ''
			,@VP_K_USER			INT
			,@VP_D_USER			VARCHAR(50)
			--,@VP_COMPUTER_NAME	VARCHAR(25)		= 'IT-002'
			,@VP_COMPUTER_NAME	VARCHAR(25)		= 'MATERIALES'
			,@VP_COMENTARIO		VARCHAR(250)	= ''--'Orden Generada automaticamente #RMA['+ CONVERT(VARCHAR(10),@PP_K_HEADER_RMA) +']'			
			,@VP_CLIENTE		VARCHAR(10)
			,@VP_NO_SECUENCIA	INT		= 0
			--=================================================================
			,@VP_K_ESTATUS_RMA	INT		= 0
			,@VP_JOB			NVARCHAR(MAX) = ''
			--=================================================================
			,@VP_MESA_CORTE		VARCHAR(250)	= ''
	-- //////////////////////////////////////////////////////////////
			--SET	@VP_CLIENTE	= ( 
			SELECT	@VP_CLIENTE			= CUS_NO,
					@VP_K_USER			= K_USUARIO_ALTA,
					@VP_K_ESTATUS_RMA	= K_STATUS_RMA 				
			FROM	HEADER_RMA			(NOLOCK) 
			WHERE	K_HEADER_RMA		= @PP_K_HEADER_RMA	
			--)
			--SET @VP_K_USER	= ( SELECT K_USUARIO_ALTA	FROM HEADER_RMA	(NOLOCK) WHERE	K_HEADER_RMA	= @PP_K_HEADER_RMA	)
--BEGIN TRANSACTION 
--BEGIN TRY
		---- ///////ACTUALIZAR EL ENCABEZADO DEL RMA //////////////////////////////////////////////
			--SELECT	@VP_K_ESTATUS_RMA	= K_STATUS_RMA 
			--FROM	HEADER_RMA		(NOLOCK)
			--WHERE	K_HEADER_RMA	= @PP_K_HEADER_RMA
			
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
		
		--------------------------------------------------------------------------------------------------------------
		----	CAMBIO AGREGADO SOLAMENTE PARA LA ETAPA DE PRUEBAS, PENDIENTE PONER EN PRODUCTIVO. AX: 20220111
		IF @VP_ORDEN = '999999'
			SET @VP_ORDEN = 0

		--SET @VP_ORDEN = @VP_ORDEN + 1
		---- =====================
		----// FEG: COMENTADO POR CAMBIO DE TAMAÑO DE LA ORDEN
		----SET @VP_ORDEN = RIGHT('00000' + @VP_ORDEN, 5)
		----// FEG: ADD POR CAMBIO DE TAMAÑO DE LA ORDEN
		----SET @VP_ORDEN = RIGHT('000000' + @VP_ORDEN, 6)		
		--------------------------------------------------------------------------------------------------------------
		--------------------------------------------------------------------------------------------------------------
		SET @VP_ORDEN = @VP_ORDEN + 1
		--SET @VP_ORDEN = RIGHT('00000' + @VP_ORDEN, 5)
		--SET @VP_ORDEN = RIGHT('000000' + @VP_ORDEN, 6)	--(1)	20220110: PARA DESCOMENTAR CUANDO ESTÉ LISTO EL CAMBIO, EXISTEN DOS LINEAS CON ESTE MISMO CODIGO
		--------------------------------------------------------------------------------------------------------------
	
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
				,TA_D_MODELO					VARCHAR(250)
				,TA_S_MODELO					VARCHAR(10)
				,TA_VERSIONNO					VARCHAR(10)
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
							,TA_GRUPO_ORDEN		
							,TA_D_MODELO		
							,TA_S_MODELO
							,TA_VERSIONNO	)
			SELECT	LEFT(ITEM_NO,8)
					,ITEM_NO
					,CANTIDAD_ORDENADA
					,RIGHT(S_COLOR_RMA,6)
					,(	SELECT	LTRIM(RTRIM(ITEM_DESC_1))
						FROM	IMITMIDX_SQL		(NOLOCK)
						WHERE	IMITMIDX_SQL.item_no	= S_COLOR_RMA		--CONCAT('F',RIGHT(DETAILS_RMA.ITEM_NO,6))					
					)
					,K_DETAILS_RMA
					,GRUPO_ORDEN
					,ARCUSFIL_PROGRAM_MODEL.D_ARCUSFIL_PROGRAM_MODEL
					,MODELNO
					,VERSIONNO
			FROM	DETAILS_RMA					(NOLOCK)
			INNER JOIN ARCUSFIL_PROGRAM_MODEL	(NOLOCK)	ON ARCUSFIL_PROGRAM_MODEL.S_ARCUSFIL_PROGRAM_MODEL	= DETAILS_RMA.MODELNO
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
	DECLARE  @VP_CU_PATTERN			VARCHAR(50)		= '',	@VP_CU_ITEM_NO		VARCHAR(100)	= '',	@VP_CU_CANTIDAD		INT = 0		,		
			 @VP_CU_S_COLOR_SINF	VARCHAR(10)		= '',	@VP_CU_D_COLOR		VARCHAR(10)		= '',	@VP_CU_K_DETAILS	INT			,
			 @VP_CU_MODELO			VARCHAR(250)		,	@VP_CU_S_MODELO		VARCHAR(10)			,	@VP_CU_VERSIONNO	VARCHAR(10) ,
			 @VP_GROSS				DECIMAL(16,4)	= 0 ,	@VP_NETO			DECIMAL(16,4)	= 0 ,	@VP_PATRON			INT = 0		,
			 @VP_TOTAL_GROSS		DECIMAL(16,4)	= 0 ,	@VP_TOTAL_NETO		DECIMAL(16,4)	= 0 ,	@VP_TOTAL_PATRON	INT = 0		,
			 @VP_CONSECUTIVO		INT				= 1 ,	@VP_NUMERO_RELOJ	INT				= 0 ,	
			 --=============================================================================================================================
			 @VP_CU_S_COLOR_SINF_anterior	VARCHAR(10)	= ''	,
			 @VP_CU_D_COLOR_anterior		VARCHAR(250)= ''	,
			 --=============================================================================================================================
			 @VP_EX_PATTERN			VARCHAR(50)		= '',	@VP_EX_ITEM_NO		VARCHAR(100)	= '',	@VP_EX_CANTIDAD		INT = 0,		
			 @VP_EX_S_COLOR_SINF	VARCHAR(10)		= '',	@VP_EX_D_COLOR		VARCHAR(10)		= '',
			 --=============================================================================================================================
			 @VP_DETAIL				VARCHAR(100) =	''
	
	-- //////SE OBTIENE EL NUMERO DE RELOJ DEL USUARIO PEARL/////////////////////////////////////
		SELECT	@VP_NUMERO_RELOJ		= K_EMPLEADO_PEARL,
				@VP_D_USER				= D_USUARIO_PEARL
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
					,TA_D_MODELO
					,TA_S_MODELO
					,TA_VERSIONNO
			FROM	@TBL_PATTERN_A_PROGRAMAR
			ORDER BY	TA_S_COLOR_SINF,	TA_GRUPO_ORDEN,		TA_ITEM_NO,		TA_CANTIDAD
	OPEN CU_PATTERN_A_PROGRAMAR
	FETCH NEXT FROM CU_PATTERN_A_PROGRAMAR INTO		@VP_CU_PATTERN,		@VP_CU_ITEM_NO,		@VP_CU_CANTIDAD,	@VP_CU_S_COLOR_SINF,		@VP_CU_D_COLOR,		@VP_CU_K_DETAILS, @VP_CU_MODELO,
													@VP_CU_S_MODELO,	@VP_CU_VERSIONNO
	WHILE @@FETCH_STATUS = 0
		BEGIN
			DECLARE  @VP_CUBE_LENGTH		DECIMAL(13,4) = 0	,@VP_CUBE_WIDTH			DECIMAL(13,4)	= 0		,@VP_CUBE_QTY_PER	DECIMAL(13,4) = 0
					,@VP_D_ITEM				VARCHAR(255)		,@VP_CHANGE_LEVEL		VARCHAR(100)			,@VP_MODELO			VARCHAR(50)
					,@VP_VERSION			VARCHAR(50)			,@VP_SERIAL				VARCHAR(50)		= ''	
					,@VP_D_ITEM_KIT			VARCHAR(255)		

			-- ////////SE OBTIENE EL GROSS, NETO Y PATRONES DEL KIT///////////////////////////////////
			SELECT TOP (1)
					 @VP_CUBE_LENGTH		= CUBE_LENGTH
					,@VP_CUBE_WIDTH			= CUBE_WIDTH
					,@VP_CUBE_QTY_PER		= CUBE_QTY_PER
					,@VP_D_ITEM				= LTRIM(RTRIM(item_desc_1))
					--,@VP_CHANGE_LEVEL		= LTRIM(RTRIM(Last_item_revision))
			FROM	IMITMIDX_SQL			(NOLOCK)
			WHERE	LTRIM(RTRIM(ITEM_NO))	= @VP_CU_ITEM_NO
	
			-- SE PIDIÓ AGREGAR LA DESCRIPCIÓN DEL KIT EN LUGAR DE LA DEL PATTERN PARA LAS ORDENES_RMA
			SELECT	@VP_D_ITEM_KIT			= LTRIM(RTRIM(item_desc_1))	--PJTSRB4NPJTX7  
			FROM	IMITMIDX_SQL			(NOLOCK)
			WHERE	LTRIM(RTRIM(ITEM_NO))	= (		SELECT LTRIM(RTRIM(ITEM_NO))
													FROM	DATA_02.DBO.CCPRDSTR_SQL	(NOLOCK)
													WHERE	COMP_ITEM_NO	= @VP_CU_ITEM_NO
													AND		VERSIONNO		= @VP_CU_VERSIONNO
													AND		MODELNO			= @VP_CU_S_MODELO		)

			IF @VP_D_ITEM_KIT = '' OR @VP_D_ITEM_KIT IS NULL
			BEGIN
				SET	@VP_D_ITEM_KIT	= @VP_D_ITEM
			END

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
			SET @VP_CHANGE_LEVEL = @VP_CU_S_MODELO	+	@VP_CU_VERSIONNO

			IF	LEN(@VP_CHANGE_LEVEL)	<	7 OR @VP_CHANGE_LEVEL IS NULL
			BEGIN
				RAISERROR ('No fue posible obtener el Change Level.', 16, 1 ) 
			END
			-- ///////////////////////////////////////////////////////////////////////////////////////
			INSERT INTO	[DATA_02].[dbo].ccjoblin_sql
			(		jobno,				kit,				kitdesc,		item_no, 
					PlannedQty,			OriginalQty,		CompletedQty, 
					netsqmper,			stdsqmper,			patternsper, 
					customer,			ChangeLevel,		Ser_no					)
			VALUES	
			(		@VP_ORDEN,			@VP_CU_PATTERN,		@VP_D_ITEM_KIT,		@VP_CU_ITEM_NO, 
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
				SET @VP_MENSAJE	= 'No fue posible actualizar el detalle ['+ CONVERT(VARCHAR(10),@VP_CU_K_DETAILS) +'] a la orden en [CCJOBLIN].'
				RAISERROR (@VP_MENSAJE, 16, 1 )
			END
			--========================================================================================================================================

			-- ///////SE AUMENTA EL CONSECUTIVO//////////////////////////////////////////////
			SET @VP_CONSECUTIVO = @VP_CONSECUTIVO + 1

				-- ///////////////////////////////////////////////////////////////////////////////////////	
				SET	@VP_CU_S_COLOR_SINF_anterior	= 	@VP_CU_S_COLOR_SINF				
				SET	@VP_CU_D_COLOR_anterior			=	@VP_CU_D_COLOR
									
			FETCH NEXT FROM CU_PATTERN_A_PROGRAMAR INTO		@VP_CU_PATTERN,		@VP_CU_ITEM_NO,		@VP_CU_CANTIDAD,	@VP_CU_S_COLOR_SINF,		@VP_CU_D_COLOR,		@VP_CU_K_DETAILS, @VP_CU_MODELO,
															@VP_CU_S_MODELO,	@VP_CU_VERSIONNO
				IF	@VP_CU_S_COLOR_SINF_anterior	<>	@VP_CU_S_COLOR_SINF
				BEGIN
					--	ASIGNAR EL COLOR VIEJO COMPARAR CONTRA EL NUEVO, SI SON DIFERENTE SE INSERTA LA ORDEN Y SE REINICIA EL CONSECUTIVO.	
					-- ///////SE INGRESA EL REGISTRO DE LA ORDEN EN CCJOBHDR_SQL//////////////////////////////////////////////					
					SET	@VP_NO_SECUENCIA	= @VP_NO_SECUENCIA + 1					
					SET	@VP_COMENTARIO		= 'Ord. Generada autom. #['+ CONVERT(VARCHAR(10),@PP_K_HEADER_RMA) +'] Sec'+CONVERT(VARCHAR(10),@VP_NO_SECUENCIA)+''
					
					--=========================================================
					--	VERIFICA EL TIPO DE ORDEN PARA INDICAR EN CUAL MESA SERÁ ASIGNADA
					IF (
							SELECT	K_TIPO_RMA
							FROM	HEADER_RMA								(NOLOCK)
							WHERE	HEADER_RMA.K_HEADER_RMA		= @PP_K_HEADER_RMA		) = 1

					BEGIN
						SET	@VP_MESA_CORTE	= 'Table 79'
					END
					ELSE
					BEGIN
						SET	@VP_MESA_CORTE	= 'Table 78'						
					END
					--=========================================================
					--	INSERTA EL REGISTRO DE LA ORDEN EN LA TABLA CORRESPONDIENTE
					INSERT INTO [DATA_02].[dbo].CCJOBHDR_SQL 
					(		jobno,					[status],			colour,				colourdesc, 
							machine,				datecreated,		dateplanned,		printedflag, 
							instruct1,				instruct2,			netsqm,				standardsqm, 
							targetutil,				customer,			patterns,	
							plannedshift,			plannedseq,			startedflag,		comments,	
							lotno,					[PROGRAM_MODEL_RMA]		 )
					VALUES 
					(		@VP_ORDEN,				'P',				@VP_CU_S_COLOR_SINF_anterior,	@VP_CU_D_COLOR_anterior, 
							@VP_MESA_CORTE,			@VP_FECHA,			@VP_FECHA,			'2', 
							@VP_COMENTARIO,			'',					@VP_TOTAL_NETO,		@VP_TOTAL_GROSS, 
							@VP_UTILIDAD_MINIMA,	@VP_CLIENTE,		@VP_TOTAL_PATRON,	
							@VP_TURNO,				'0',				'',					@VP_COMENTARIO, 
							'',						@VP_CU_MODELO			)					
					IF @@ROWCOUNT = 0
					BEGIN
						RAISERROR ('No fue posible agregar la orden en [CCJOBHDR]', 16, 1 ) 
					END
					
					-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////
					SET	@VP_DETAIL =	'Creacion de Orden: ' + @VP_ORDEN
					EXECUTE [DATA_02].[dbo].[PG_IN_PEARL_LOG]	@PP_K_SISTEMA_EXE, @VP_K_USER,--@PP_K_USUARIO_ACCION,
																@VP_D_USER,	@VP_COMPUTER_NAME,	'RMA',
																@VP_ORDEN,		'Crear orden',		@VP_DETAIL, 
																''
					
					-- /////////////////////////////////////////////////////// SE ACTUALIZA EL CAMPO DE JOBNOS EN EL ENCABEZADO DE LA RMA.
					SET @VP_JOB = ''

					SELECT	@VP_JOB		= JOBNO
					FROM	HEADER_RMA		(NOLOCK)
					WHERE	K_HEADER_RMA = @PP_K_HEADER_RMA

					IF @VP_JOB <> ''
					BEGIN
						SET @VP_JOB	= @VP_ORDEN + ' / ' + @VP_JOB
					END
					ELSE
					BEGIN
						SET	@VP_JOB	= @VP_ORDEN					
					END

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
						RAISERROR ('No fue posible obtener el numero de orden(2) en [CCJOBHDR]', 16, 1 ) 
					END
	
					--------------------------------------------------------------------------------------------------------------
					----	CAMBIO AGREGADO SOLAMENTE PARA LA ETAPA DE PRUEBAS, PENDIENTE PONER EN PRODUCTIVO. AX: 20220111
					IF @VP_ORDEN = '999999'
						SET @VP_ORDEN = 0
			
					--SET @VP_ORDEN = @VP_ORDEN + 1
					---- =====================
					----// FEG: COMENTADO POR CAMBIO DE TAMAÑO DE LA ORDEN
					----SET @VP_ORDEN = RIGHT('00000' + @VP_ORDEN, 5)
					----// FEG: ADD POR CAMBIO DE TAMAÑO DE LA ORDEN
					----SET @VP_ORDEN = RIGHT('000000' + @VP_ORDEN, 6)		
					--------------------------------------------------------------------------------------------------------------
					--------------------------------------------------------------------------------------------------------------
					SET @VP_ORDEN = @VP_ORDEN + 1
					--SET @VP_ORDEN = RIGHT('00000' + @VP_ORDEN, 5)
					----SET @VP_ORDEN = RIGHT('000000' + @VP_ORDEN, 6)	--(1)	20220110: PARA DESCOMENTAR CUANDO ESTÉ LISTO EL CAMBIO, EXISTEN DOS LINEAS CON ESTE MISMO CODIGO
					--------------------------------------------------------------------------------------------------------------
	
					-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					-- ///////SE ACTUALIZA LA LOCACION MFP CON LA ORDEN CREADA//////////////////////////////////////////////			
					UPDATE [DATA_02].[dbo].imlocfil_sql 
						SET user_def_fld_4 = @VP_ORDEN
					WHERE LOC = 'MFP'	
					IF @@ROWCOUNT = 0
					BEGIN
						RAISERROR ('No fue posible Actualizar la orden(2) en [IMLOCFIL]', 16, 1 ) 
					END
					-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
				END 
		END		--END CURSOR	
	CLOSE		CU_PATTERN_A_PROGRAMAR
	DEALLOCATE	CU_PATTERN_A_PROGRAMAR
	
				IF	(	SELECT		COUNT(JOBNO) 
						FROM		[DATA_02].[dbo].CCJOBHDR_SQL	(NOLOCK)
						WHERE		JOBNO			= @VP_ORDEN	) < 1
				BEGIN
					
					SET	@VP_NO_SECUENCIA	= @VP_NO_SECUENCIA + 1					
					SET	@VP_COMENTARIO		= 'Ord. Generada autom. #['+ CONVERT(VARCHAR(10),@PP_K_HEADER_RMA) +'] Sec'+CONVERT(VARCHAR(10),@VP_NO_SECUENCIA)+''

					--	ASIGNAR EL COLOR VIEJO COMPARAR CONTRA EL NUEVO, SI SON DIFERENTE SE INSERTA LA ORDEN Y SE REINICIA EL CONSECUTIVO.	
					-- ///////SE INGRESA EL REGISTRO DE LA ORDEN EN CCJOBHDR_SQL//////////////////////////////////////////////
					--=========================================================
					IF (
							SELECT	K_TIPO_RMA
							FROM	HEADER_RMA								(NOLOCK)
							WHERE	HEADER_RMA.K_HEADER_RMA		= @PP_K_HEADER_RMA		) = 1

					BEGIN
						SET	@VP_MESA_CORTE	= 'Table 79'
					END
					ELSE
					BEGIN
						SET	@VP_MESA_CORTE	= 'Table 78'						
					END
					--=========================================================

					INSERT INTO [DATA_02].[dbo].CCJOBHDR_SQL 
					(		jobno,					[status],			colour,				colourdesc, 
							machine,				datecreated,		dateplanned,		printedflag, 
							instruct1,				instruct2,			netsqm,				standardsqm, 
							targetutil,				customer,			patterns,	
							plannedshift,			plannedseq,			startedflag,		comments,	
							lotno		 ,			[PROGRAM_MODEL_RMA]	)
					VALUES 
					(		@VP_ORDEN,				'P',				@VP_CU_S_COLOR_SINF_anterior,	@VP_CU_D_COLOR_anterior,	--@VP_EX_S_COLOR_SINF,	@VP_EX_D_COLOR, 
							@VP_MESA_CORTE,			@VP_FECHA,			@VP_FECHA,			'2', 
							@VP_COMENTARIO,			'',		@VP_TOTAL_NETO,		@VP_TOTAL_GROSS, 
							@VP_UTILIDAD_MINIMA,	@VP_CLIENTE,		@VP_TOTAL_PATRON,	
							@VP_TURNO,				'0',				'',					@VP_COMENTARIO, 
							'',						@VP_CU_MODELO		)					
					IF @@ROWCOUNT = 0
					BEGIN
						RAISERROR ('No fue posible agregar la orden en [CCJOBHDR]', 16, 1 ) 
					END
				
					-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////
					SET		@VP_DETAIL =	'Creacion de Orden: ' + @VP_ORDEN

					EXECUTE [DATA_02].[dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @VP_K_USER,--@PP_K_USUARIO_ACCION,
													@VP_D_USER, @VP_COMPUTER_NAME, 'RMA',
													@VP_ORDEN, 'Crear orden',
													@VP_DETAIL, ''

					-- /////////////////////////////////////////////////////// SE ACTUALIZA EL CAMPO DE JOBNOS EN EL ENCABEZADO.					
					SET @VP_JOB = ''

					SELECT	@VP_JOB	= JOBNO
					FROM	HEADER_RMA		(NOLOCK)
					WHERE	K_HEADER_RMA = @PP_K_HEADER_RMA

					IF @VP_JOB <> ''
					BEGIN
						SET @VP_JOB	= @VP_ORDEN + ' / ' + @VP_JOB
					END
					ELSE
					BEGIN
						SET	@VP_JOB	= @VP_ORDEN
					END					

						UPDATE	HEADER_RMA
						SET		JOBNO			= @VP_JOB
						WHERE	K_HEADER_RMA	= @PP_K_HEADER_RMA
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
		RAISERROR ('No fue posible actualizar la orden.', 16, 1 ) 
	END
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> ENVIAR CORREO
-- //////////////////////////////////////////////////////////////	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_ENVIAR_CORREO_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_ENVIAR_CORREO_RMA]
GO
--		 EXECUTE [dbo].[PG_PR_ENVIAR_CORREO_RMA]	0,139,  7, 34659,1
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
	DECLARE  @VP_RECIPIENTS					NVARCHAR(MAX)	= ''
			,@VP_SUBJECT					NVARCHAR(MAX) 
			,@VP_BODY_HTML					NVARCHAR(MAX) 
			,@VP_ID_MAIL					INT
			,@VP_SENT_STATUS				VARCHAR(500)
			,@VP_K_TIPO_GRUPO_APROBADOR		VARCHAR(15)	=	0--9702
			,@PP_TIPO_ORDEN					VARCHAR(250)
			,@VP_K_USUARIO_DEPTO				INT
	----================================================================
	----================================================================
	SELECT	@PP_TIPO_ORDEN				= D_TIPO_RMA,
			@VP_K_USUARIO_DEPTO			= K_USUARIO_DEPARTAMENTO
	FROM	HEADER_RMA								(NOLOCK)
	INNER JOIN	TIPO_RMA							(NOLOCK) ON TIPO_RMA.K_TIPO_RMA	= HEADER_RMA.K_TIPO_RMA
	INNER JOIN	BD_GENERAL.DBO.USUARIO_PEARL		(NOLOCK) ON USUARIO_PEARL.K_USUARIO_PEARL	= HEADER_RMA.K_USUARIO_ALTA
	--AND			USUARIO_PEARL.K_USUARIO_DEPARTAMENTO	=	(	SELECT K_USUARIO_DEPARTAMENTO FROM BD_GENERAL.DBO.USUARIO_PEARL WHERE K_USUARIO_PEARL = @PP_K_USUARIO_ACCION  )
	AND		HEADER_RMA.K_HEADER_RMA		= @PP_K_HEADER_RMA


	IF @VP_K_USUARIO_DEPTO	IN ( 3 )		--	MATERIALES
	BEGIN
		SET	@VP_K_TIPO_GRUPO_APROBADOR	= 9704
	END
	ELSE IF @VP_K_USUARIO_DEPTO	IN ( 4 )	--	CALIDAD
	BEGIN
		SET	@VP_K_TIPO_GRUPO_APROBADOR	= 9702

	END

	----================================================================
	----================================================================
	SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
	FROM	BD_GENERAL.dbo.USUARIO_PEARL AS USERS  (NOLOCK) 
	INNER	JOIN	BD_GENERAL.dbo.GRUPO_APROBADOR (NOLOCK) ON GRUPO_APROBADOR.K_USUARIO=USERS.K_USUARIO_PEARL
	WHERE	GRUPO_APROBADOR.K_TIPO_GRUPO_APROBADOR = @VP_K_TIPO_GRUPO_APROBADOR
	AND		K_ESTATUS_GRUPO_APROBADOR = 1

	SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))
	----================================================================
		SET @VP_SUBJECT = '[RMA#' + CONVERT(VARCHAR(10),FORMAT(@PP_K_HEADER_RMA,'000000')) +'] APROBADA'
		
		SET @VP_BODY_HTML =
		N'<html>'+
		N'<head>'+		
		N'</head>'+
		N'<body>'+
		N'<span style="color:black; font-size:12pt">	Buen día:<br>' +
		N'La orden:  <b>[#' + CONVERT(VARCHAR(10),FORMAT(@PP_ORDEN,'00000')) +'] </b> // Secuencia ('+ CONVERT(VARCHAR(10),@PP_NO_SECUENCIA) +')'+
		N'<br><br> De tipo: <b>' + @PP_TIPO_ORDEN + '</b>,  ha sido aprobada por Gerencia de Planta.<br>'+
		
		N'Es necesario dar el seguimiento correspondiente. <br><br>'+
		
		--N'La orden indicada en el asunto del mensaje, ha sido aprobada por Gerencia de Planta.<br>'+
		--N'Puedes Verificar el estatus y el número de orden asignada en la pantalla donde generaste la Orden.</span><br><br>'+
		N'</body>'+
		N'</html>';

			EXEC msdb.dbo.sp_send_dbmail @recipients=@VP_RECIPIENTS,
			--@blind_copy_recipients='alejandrod@PEARLLEATHER.COM.MX',
			@subject = @VP_SUBJECT,
			@body = @VP_BODY_HTML,  
			@body_format = 'HTML';
			--@mailitem_id = @VP_ID_MAIL OUTPUT;

	-- ////////////////////////////////////////////////////////////////
	-- ///////////////////////////////////////////////////////////////
GO
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
