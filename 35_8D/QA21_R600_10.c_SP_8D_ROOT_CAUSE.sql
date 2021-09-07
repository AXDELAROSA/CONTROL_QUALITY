-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			QC 8D
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	24/AGO/2021
-- //////////////////////////////////////////////////////////////  

USE [DATA_02]
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_8D_ROOT_CAUSE_RPT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_8D_ROOT_CAUSE_RPT]
GO

/*
 EXEC	[PG_SK_8D_ROOT_CAUSE_RPT] 0,144,2
*/
			
CREATE PROCEDURE [dbo].[PG_SK_8D_ROOT_CAUSE_RPT]
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT,
	-- ===========================
	@PP_K_8D				INT
AS

	-- ///////////////////////////////////////////
	--SELECT	[K_8D_ROOT_CAUSE],	
	--		-- =================
	--		[K_8D],	
	--		[8D_ROOT_CAUSE].[K_CLASIFICACION_ROOT_CAUSE_8D],
	--		[D_CLASIFICACION_ROOT_CAUSE_8D],
	--		[8D_ROOT_CAUSE].[K_TIPO_ROOT_CAUSE_8D],		
	--		[D_TIPO_ROOT_CAUSE_8D],		
	--		-- =================							
	--		[VALOR],					
	--		D_USUARIO_PEARL,
	--		CONVERT(DATE, [8D_ROOT_CAUSE].[F_CAMBIO]) AS [DATE]
	--		-- =================
	--FROM	[8D_ROOT_CAUSE] (NOLOCK)
	--INNER JOIN CLASIFICACION_ROOT_CAUSE_8D (NOLOCK) ON [8D_ROOT_CAUSE].[K_CLASIFICACION_ROOT_CAUSE_8D] = CLASIFICACION_ROOT_CAUSE_8D.[K_CLASIFICACION_ROOT_CAUSE_8D]
	--INNER JOIN [TIPO_ROOT_CAUSE_8D] (NOLOCK) ON [8D_ROOT_CAUSE].[K_TIPO_ROOT_CAUSE_8D] = [TIPO_ROOT_CAUSE_8D].[K_TIPO_ROOT_CAUSE_8D]
	--INNER JOIN  BD_GENERAL.DBO.USUARIO_PEARL (NOLOCK) ON USUARIO_PEARL.K_USUARIO_PEARL = [8D_ROOT_CAUSE].[K_USUARIO_CAMBIO]
	---- =============================
	--WHERE 	[K_8D] = @PP_K_8D
	--AND [8D_ROOT_CAUSE].[K_CLASIFICACION_ROOT_CAUSE_8D] IN (1, 2, 3)
	--AND [8D_ROOT_CAUSE].[K_TIPO_ROOT_CAUSE_8D] IN (6, 7)
	--ORDER BY [K_CLASIFICACION_ROOT_CAUSE_8D], [K_TIPO_ROOT_CAUSE_8D]

	DECLARE @TBL_ROOT_CAUSE TABLE(
		ID INT IDENTITY(1,1),
		CLASIFICACION	VARCHAR(50),
		CAUSA			VARCHAR(MAX),
		CONTRIBUCION	VARCHAR(10)
	)

	-- /////////VALOES PARA ROOT CAUSE OCURRENCE///////////////////////////////////////
	DECLARE @VP_CUASE_VALOR VARCHAR(255) = ''
	SELECT	@VP_CUASE_VALOR = VALOR
	FROM	[8D_ROOT_CAUSE] (NOLOCK)
	WHERE	K_8D = @PP_K_8D
	AND [8D_ROOT_CAUSE].[K_CLASIFICACION_ROOT_CAUSE_8D] = 1 -- OCURRENCE
	AND	[K_TIPO_ROOT_CAUSE_8D] = 6 --CAUSE

	IF @VP_CUASE_VALOR IS NULL
		SET @VP_CUASE_VALOR = ''

	DECLARE @VP_CONTRIBUTION_VALOR VARCHAR(255) = ''
	SELECT	@VP_CONTRIBUTION_VALOR = VALOR
	FROM	[8D_ROOT_CAUSE] (NOLOCK)
	WHERE	K_8D = @PP_K_8D
	AND [8D_ROOT_CAUSE].[K_CLASIFICACION_ROOT_CAUSE_8D] = 1 -- OCURRENCE
	AND	[K_TIPO_ROOT_CAUSE_8D] = 7 --CONTRIBUTION

	IF @VP_CONTRIBUTION_VALOR IS NULL
		SET @VP_CONTRIBUTION_VALOR = ''

	IF @VP_CUASE_VALOR <> ''
		INSERT INTO @TBL_ROOT_CAUSE
			SELECT 'Ocurrence', @VP_CUASE_VALOR, @VP_CONTRIBUTION_VALOR

	-- /////////VALOES PARA ROOT CAUSE DETECTION///////////////////////////////////////
	SET @VP_CUASE_VALOR = ''
	SELECT	@VP_CUASE_VALOR = VALOR
	FROM	[8D_ROOT_CAUSE] (NOLOCK)
	WHERE	K_8D = @PP_K_8D
	AND [8D_ROOT_CAUSE].[K_CLASIFICACION_ROOT_CAUSE_8D] = 2 -- DETECTION
	AND	[K_TIPO_ROOT_CAUSE_8D] = 6 --CAUSE

	IF @VP_CUASE_VALOR IS NULL
		SET @VP_CUASE_VALOR = ''

	SET @VP_CONTRIBUTION_VALOR = ''
	SELECT	@VP_CONTRIBUTION_VALOR = VALOR
	FROM	[8D_ROOT_CAUSE] (NOLOCK)
	WHERE	K_8D = @PP_K_8D
	AND [8D_ROOT_CAUSE].[K_CLASIFICACION_ROOT_CAUSE_8D] = 2 -- DETECTION
	AND	[K_TIPO_ROOT_CAUSE_8D] = 7 --CONTRIBUTION

	IF @VP_CONTRIBUTION_VALOR IS NULL
		SET @VP_CONTRIBUTION_VALOR = ''

	IF @VP_CUASE_VALOR <> ''
		INSERT INTO @TBL_ROOT_CAUSE
			SELECT 'Detection', @VP_CUASE_VALOR, @VP_CONTRIBUTION_VALOR

	-- /////////VALOES PARA ROOT CAUSE SYSTEMATIC///////////////////////////////////////
	SET @VP_CUASE_VALOR = ''
	SELECT	@VP_CUASE_VALOR = VALOR
	FROM	[8D_ROOT_CAUSE] (NOLOCK)
	WHERE	K_8D = @PP_K_8D
	AND [8D_ROOT_CAUSE].[K_CLASIFICACION_ROOT_CAUSE_8D] = 3 -- SYSTEMATIC
	AND	[K_TIPO_ROOT_CAUSE_8D] = 6 --CAUSE

	IF @VP_CUASE_VALOR IS NULL
		SET @VP_CUASE_VALOR = ''

	SET @VP_CONTRIBUTION_VALOR = ''
	SELECT	@VP_CONTRIBUTION_VALOR = VALOR
	FROM	[8D_ROOT_CAUSE] (NOLOCK)
	WHERE	K_8D = @PP_K_8D
	AND [8D_ROOT_CAUSE].[K_CLASIFICACION_ROOT_CAUSE_8D] = 3 -- SYSTEMATIC
	AND	[K_TIPO_ROOT_CAUSE_8D] = 7 --CONTRIBUTION

	IF @VP_CONTRIBUTION_VALOR IS NULL
		SET @VP_CONTRIBUTION_VALOR = ''

	IF @VP_CUASE_VALOR <> ''
		INSERT INTO @TBL_ROOT_CAUSE
			SELECT 'Systematic', @VP_CUASE_VALOR, @VP_CONTRIBUTION_VALOR

	-- ////////////////////////////////////////////////
	SELECT CLASIFICACION,	 
		   CAUSA,			
		   CONTRIBUCION	
	FROM @TBL_ROOT_CAUSE

	-- ////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_8D_ROOT_CAUSE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_8D_ROOT_CAUSE]
GO

/*
 EXEC	[PG_SK_8D_ROOT_CAUSE] 0,144,1
*/
			
CREATE PROCEDURE [dbo].[PG_SK_8D_ROOT_CAUSE]
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT,
	-- ===========================
	@PP_K_8D				INT
AS

	-- ///////////////////////////////////////////
	SELECT	[K_8D_ROOT_CAUSE],	
			-- =================
			[K_8D],	
			[K_CLASIFICACION_ROOT_CAUSE_8D],
			[K_TIPO_ROOT_CAUSE_8D],		
			-- =================							
			[VALOR],					
			D_USUARIO_PEARL,
			CONVERT(DATE, [8D_ROOT_CAUSE].[F_CAMBIO]) AS [DATE]
			-- =================
	FROM	[8D_ROOT_CAUSE] (NOLOCK)
	INNER JOIN  BD_GENERAL.DBO.USUARIO_PEARL (NOLOCK) ON USUARIO_PEARL.K_USUARIO_PEARL = [8D_ROOT_CAUSE].[K_USUARIO_CAMBIO]
	-- =============================
	WHERE 	[K_8D] = @PP_K_8D
	ORDER BY [K_CLASIFICACION_ROOT_CAUSE_8D], [K_TIPO_ROOT_CAUSE_8D]
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE]
GO

/*
 EXEC	[PG_SK_8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE] 0,144,2
*/
			
CREATE PROCEDURE [dbo].[PG_SK_8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE]
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT,
	-- ===========================
	@PP_K_8D				INT
AS

	-- ///////////////////////////////////////////
	SELECT	[K_8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE],	
			-- =================================
			[K_8D],								
			-- =================================
			[RUTA],								
			[NOMBRE_ARCHIVO],					
			[TIPO_ARCHIVO]	
			-- =================
	FROM	[8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE] (NOLOCK)
	-- =============================
	WHERE 	[K_8D] = @PP_K_8D
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_8D_ROOT_CAUSE_X_TIPO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_8D_ROOT_CAUSE_X_TIPO]
GO

/*
 EXEC	[PG_SK_8D_ROOT_CAUSE_X_TIPO] 0,144,2, 4
*/
			
CREATE PROCEDURE [dbo].[PG_SK_8D_ROOT_CAUSE_X_TIPO]
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT,
	-- ===========================
	@PP_K_8D					INT,
	@PP_K_TIPO_ROOT_CAUSE_8D	INT
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_N_ROOT_CAUSE_ISHIKAWA INT = 0

	SELECT	@VP_N_ROOT_CAUSE_ISHIKAWA = COUNT([K_8D_ROOT_CAUSE])
	FROM	[8D_ROOT_CAUSE] (NOLOCK)
	-- =============================
	WHERE 	[K_8D] = @PP_K_8D
	AND [K_CLASIFICACION_ROOT_CAUSE_8D] = @PP_K_TIPO_ROOT_CAUSE_8D
	AND LTRIM(RTRIM(VALOR)) <> ''
	
	IF @VP_N_ROOT_CAUSE_ISHIKAWA IS NULL
		SET @VP_N_ROOT_CAUSE_ISHIKAWA = 0

	SELECT @VP_N_ROOT_CAUSE_ISHIKAWA AS N_ROOT_CAUSE_ISHIKAWA

	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT
-- //////////////////////////////////////////////////////////////

-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE]
GO
/*
 EXECUTE [PG_IN_8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE] 0,144, 3 , 2 , 'CAMBIO # PARTE.xlsx' , '.xlsx' 
*/
CREATE PROCEDURE [dbo].[PG_IN_8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================	
	@PP_K_8D							INT,
	-- =================							
	@PP_NOMBRE_ARCHIVO					VARCHAR(255),	
	@PP_TIPO_ARCHIVO					VARCHAR(50)	
	--- =================
AS			
	
	DECLARE @VP_MENSAJE		VARCHAR(255) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	--	EXECUTE [dbo].[PG_RN_INSPECCION_MATERIAL_INSERT]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--														@PP_K_ITEM, @PP_K_TIPO_INSPECCION_MATERIAL,
	--														@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				-- ///////SE CREA LA SUBCARPETA CONTAINMENT DE LA 8D///////////////////////////////////////////////////////
				DECLARE @CREAR_CARPETA NVARCHAR(255) = N'\\10.1.1.5\documents\Quality\8D POR SISTEMA\' + CONVERT(VARCHAR(25), @PP_K_8D)+ '\ROOT_CAUSE'
				SET NOCOUNT ON
				EXECUTE master.dbo.xp_create_subdir  @CREAR_CARPETA
				SET NOCOUNT OFF

				INSERT INTO [8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE]
					(	[K_8D],				
						-- =================		
						[RUTA],				
						[NOMBRE_ARCHIVO],
						[TIPO_ARCHIVO],
						-- ===========================
						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
				VALUES	
					(	@PP_K_8D,
						--- =================
						CONCAT(@CREAR_CARPETA, '\'),
						@PP_NOMBRE_ARCHIVO,	
						@PP_TIPO_ARCHIVO,								
						-- ===========================
						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
						0, NULL, NULL )
				
				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible agregar la evidencia.', 16, 1 ) --MENSAJE - Severity -State.

			-- //////////////////////////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	IF @VP_MENSAJE<>''
		BEGIN
			SET		@VP_MENSAJE = 'No es posible [Agregar] la Evidencia para la [8D]: ' + @VP_MENSAJE 
			SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
			SET		@VP_MENSAJE = @VP_MENSAJE + '[#8D.'+CONVERT(VARCHAR(10),@PP_K_8D)+']'
			SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_8D AS CLAVE

	-- //////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT
-- //////////////////////////////////////////////////////////////

-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_8D_ROOT_CAUSE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_UP_8D_ROOT_CAUSE]
GO
/*
 EXECUTE [PG_IN_UP_8D_ROOT_CAUSE] 0,144, 0 , '' , 0 , 1 , '' , '' , '2019/10/01' , '2019/10/01' , '2019/10/01' , '2019/10/01' , 'C:\Users\Francisco Esteban\Desktop\SERIAL REPETIDO.xlsx' , 'SERIAL REPETIDO.xlsx' 

*/
CREATE PROCEDURE [dbo].[PG_IN_UP_8D_ROOT_CAUSE]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================	
	@PP_K_8D							INT,
	@PP_K_CLASIFICACION_ROOT_CAUSE_8D	INT,
	@PP_K_TIPO_ROOT_CAUSE_8D			INT,
	-- ============================		
	@PP_VALOR							VARCHAR(MAX)
	--- =================
AS			
	
	DECLARE @VP_MENSAJE		VARCHAR(255) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	--IF @PP_K_TIPO_INSPECCION_MATERIAL IN (4, 5, 6, 7, 8)	-- ESTE TIPO DE INSPECCION SOLO SE PUEDEN AGREGAR UNA VEZ AL # PARTE
	--	EXECUTE [dbo].[PG_RN_INSPECCION_MATERIAL_INSERT]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--														@PP_K_ITEM, @PP_K_TIPO_INSPECCION_MATERIAL,
	--														@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				DECLARE @VP_N_ROOT_CAUSE INT = 0

				SELECT @VP_N_ROOT_CAUSE = COUNT([K_8D_ROOT_CAUSE])
				FROM [8D_ROOT_CAUSE]
				WHERE K_8D = @PP_K_8D
				AND [K_CLASIFICACION_ROOT_CAUSE_8D]	= @PP_K_CLASIFICACION_ROOT_CAUSE_8D	
				AND [K_TIPO_ROOT_CAUSE_8D] = @PP_K_TIPO_ROOT_CAUSE_8D			
				
				IF ( @VP_N_ROOT_CAUSE IS NULL OR @VP_N_ROOT_CAUSE = 0 )
					BEGIN
						-- ///////SE INSERTA EL VALOR PARA CADA UNO DE LOS DATOS REQUERIDOS EN EL 5 WHY'S///////////////////////////////////////////////////////
						INSERT INTO [8D_ROOT_CAUSE]
							(	[K_8D],
								[K_CLASIFICACION_ROOT_CAUSE_8D],
								[K_TIPO_ROOT_CAUSE_8D],
								-- =================================
								[VALOR],
								-- ===========================
								[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
								[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
						VALUES	
							(	@PP_K_8D,
								@PP_K_CLASIFICACION_ROOT_CAUSE_8D,
								@PP_K_TIPO_ROOT_CAUSE_8D,
								--- =================
								@PP_VALOR,
								-- ===========================
								@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
								0, NULL, NULL )
						
						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible Agregar el valor.', 16, 1 ) --MENSAJE - Severity -State.
					END
				ELSE
					BEGIN
						UPDATE [8D_ROOT_CAUSE]
							SET [VALOR] = @PP_VALOR,
								[K_USUARIO_CAMBIO] = @PP_K_USUARIO_ACCION,
								[F_CAMBIO] = GETDATE()
						WHERE K_8D = @PP_K_8D
						AND [K_CLASIFICACION_ROOT_CAUSE_8D]	= @PP_K_CLASIFICACION_ROOT_CAUSE_8D	
						AND [K_TIPO_ROOT_CAUSE_8D] = @PP_K_TIPO_ROOT_CAUSE_8D	

						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible Actualizar la valor.', 16, 1 ) --MENSAJE - Severity -State.
					END

			-- //////////////////////////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_UP_8D_ROOT_CAUSE // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	IF @VP_MENSAJE<>''
		BEGIN
			SET		@VP_MENSAJE = 'No es posible [AGREGAR] el valor para la [8D]: ' + @VP_MENSAJE 
			SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
			SET		@VP_MENSAJE = @VP_MENSAJE + '[#8D.'+CONVERT(VARCHAR(10),@PP_K_8D)+']'
			SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_8D AS CLAVE

	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
