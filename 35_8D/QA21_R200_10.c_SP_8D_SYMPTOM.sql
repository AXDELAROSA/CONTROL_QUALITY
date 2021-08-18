-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			QC 8D
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	16/AGO/2021
-- //////////////////////////////////////////////////////////////  

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_8D_SYMPTOM]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_8D_SYMPTOM]
GO

/*
 EXEC	[dbo].[PG_SK_8D_SYMPTOM] 0,0,  1
*/

CREATE PROCEDURE [dbo].[PG_SK_8D_SYMPTOM]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_8D							INT
AS
	
	-- ///////////////////////////////////////////
	SELECT	[K_8D_SYMPTOM]		
			-- =================
			[K_8D],
			-- =================				
			[SYMPTOM],			
			D_USUARIO_PEARL,
			[8D_SYMPTOM].[F_CAMBIO]			
			-- =================
	FROM	[8D_SYMPTOM] (NOLOCK)
	INNER JOIN  BD_GENERAL.DBO.USUARIO_PEARL (NOLOCK) ON USUARIO_PEARL.K_USUARIO_PEARL = [8D_SYMPTOM].[K_USUARIO_CAMBIO]
	-- =============================
	WHERE 	[K_8D] = @PP_K_8D
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_8D_SYMPTOM_ACTION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_8D_SYMPTOM_ACTION]
GO

/*
 EXEC	[dbo].[PG_SK_8D_SYMPTOM_ACTION] 0,144,1
*/

CREATE PROCEDURE [dbo].[PG_SK_8D_SYMPTOM_ACTION]
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT,
	-- ===========================
	@PP_K_8D				INT
AS

	-- ///////////////////////////////////////////
	-- ///////////////////////////////////////////
	SELECT	[K_8D_SYMPTOM_ACTION]		
			-- =================
			[K_8D],				
			-- =================								
			[ACCION],			
			[PORCENTAJE],			
			D_USUARIO_PEARL,
			[8D_SYMPTOM_ACTION].[F_CAMBIO]			
			-- =================
	FROM	[8D_SYMPTOM_ACTION] (NOLOCK)
	INNER JOIN  BD_GENERAL.DBO.USUARIO_PEARL (NOLOCK) ON USUARIO_PEARL.K_USUARIO_PEARL = [8D_SYMPTOM_ACTION].[K_USUARIO_CAMBIO]
	-- =============================
	WHERE 	[K_8D] = @PP_K_8D
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_8D_SYMPTOM_EVIDENCE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_8D_SYMPTOM_EVIDENCE]
GO

/*
 EXEC	[dbo].[PG_SK_8D_SYMPTOM_EVIDENCE] 0,144,1
*/

CREATE PROCEDURE [dbo].[PG_SK_8D_SYMPTOM_EVIDENCE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_8D_SYMPTOM_ACTION		INT
AS

	-- ///////////////////////////////////////////
	-- ///////////////////////////////////////////
	SELECT	[K_8D_SYMPTOM_EVIDENCE],
			-- =================					
			[K_8D_SYMPTOM_ACTION],	
			-- =================							
			[RUTA],			
			[NOMBRE_ARCHIVO],
			[TIPO_ARCHIVO],		
			-- =================					
			D_USUARIO_PEARL,
			[8D_SYMPTOM_EVIDENCE].[F_CAMBIO]			
			-- =================
	FROM	[8D_SYMPTOM_EVIDENCE] (NOLOCK)
	INNER JOIN  BD_GENERAL.DBO.USUARIO_PEARL (NOLOCK) ON USUARIO_PEARL.K_USUARIO_PEARL = [8D_SYMPTOM_EVIDENCE].[K_USUARIO_CAMBIO]
	-- =============================
	WHERE 	[K_8D_SYMPTOM_ACTION] = @PP_K_8D_SYMPTOM_ACTION
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT
-- //////////////////////////////////////////////////////////////

-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_8D_SYMPTOM_ACTION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_UP_8D_SYMPTOM_ACTION]
GO
/*
 EXECUTE [PG_IN_UP_8D_SYMPTOM_ACTION] 0,144, 0 , '' , 0 , 1 , '' , '' , '2019/10/01' , '2019/10/01' , '2019/10/01' , '2019/10/01' , 'C:\Users\Francisco Esteban\Desktop\SERIAL REPETIDO.xlsx' , 'SERIAL REPETIDO.xlsx' 

*/
CREATE PROCEDURE [dbo].[PG_IN_UP_8D_SYMPTOM_ACTION]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================	
	@PP_K_8D							INT,
	-- ============================		
	@PP_SYMPTOM							VARCHAR(MAX),
	-- ============================		
	@PP_ACCION							VARCHAR(MAX),	
	@PP_PORCENTAJE						INT	
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
				DECLARE @VP_N_8_SYMPTOM INT = 0 

				SELECT @VP_N_8_SYMPTOM = COUNT([K_8D_SYMPTOM])
				FROM [8D_SYMPTOM]
				WHERE K_8D = @PP_K_8D

				IF @VP_N_8_SYMPTOM IS NULL
					SET @VP_N_8_SYMPTOM = 0

				IF @VP_N_8_SYMPTOM = 0
					BEGIN
						-- ///////SE INSERTA O ACTUALIZA EL SINTOMA DE LA 8D///////////////////////////////////////////////////////
						INSERT INTO [8D_SYMPTOM]
							(	[K_8D],			
								-- =================
								[SYMPTOM],
								-- ===========================
								[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
								[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
						VALUES	
							(	@PP_K_8D,	
								-- =================
								@PP_SYMPTOM,								
								-- ===========================
								@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
								0, NULL, NULL )

						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible Agregar el sintoma a la [8D].', 16, 1 ) --MENSAJE - Severity -State.
					END
				ELSE
					BEGIN
						UPDATE [8D_SYMPTOM]
							SET [SYMPTOM] = @PP_SYMPTOM,
								[K_USUARIO_CAMBIO] = @PP_K_USUARIO_ACCION,
								[F_CAMBIO] = GETDATE()
						WHERE [K_8D] = @PP_K_8D

						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible Actualizar el sintoma a la [8D].', 16, 1 ) --MENSAJE - Severity -State.
					END					

				-- ///////SE INSERTA LA ACCION PARA SINTOMA DE LA 8D///////////////////////////////////////////////////////
				INSERT INTO [8D_SYMPTOM_ACTION]
					(	[K_8D],				
						-- =================		
						[ACCION],
						[PORCENTAJE],
						-- ===========================
						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
				VALUES	
					(	@PP_K_8D,
						--- =================
						@PP_ACCION,		
						@PP_PORCENTAJE,						
						-- ===========================
						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
						0, NULL, NULL )
				
				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible Agregar la acción del sintoma para la [8D].', 16, 1 ) --MENSAJE - Severity -State.
						

			-- //////////////////////////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_UP_8D_SYMPTOM_ACTION // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	IF @VP_MENSAJE<>''
		BEGIN
			SET		@VP_MENSAJE = 'No es posible [AGREGAR] la acción del sintoma para la [8D]: ' + @VP_MENSAJE 
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
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_SYMPTOM_EVIDENCE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_SYMPTOM_EVIDENCE]
GO
/*
 EXECUTE [PG_IN_UP_8D] 0,144, 0 , '' , 0 , 1 , '' , '' , '2019/10/01' , '2019/10/01' , '2019/10/01' , '2019/10/01' , 'C:\Users\Francisco Esteban\Desktop\SERIAL REPETIDO.xlsx' , 'SERIAL REPETIDO.xlsx' 

*/
CREATE PROCEDURE [dbo].[PG_IN_SYMPTOM_EVIDENCE]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================	
	@PP_K_8D							INT,
	@PP_K_8D_SYMPTOM_ACTION				INT,
	-- =================							
	@PP_NOMBRE_ARCHIVO					VARCHAR(255),	
	@PP_TIPO_ARCHIVO					VARCHAR(50)	
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
				DECLARE @VP_RUTA_DEFAULT VARCHAR(MAX) = ''	
				SELECT @VP_RUTA_DEFAULT = CONCAT(SERVIDOR, RUTA)
				FROM BD_GENERAL.DBO.RUTA_ARCHIVO
				WHERE D_RUTA_ARCHIVO = 'RUTA_8D_POR_SISTEMA'
				
				IF ( @VP_RUTA_DEFAULT IS NULL OR @VP_RUTA_DEFAULT = '' )
					RAISERROR ('ERROR: No fue posible obtener la ruta default para la 8D.', 16, 1 ) --MENSAJE - Severity -State.

				-- ///////SE CREA LA SUBCARPETA SYMPTOM DE LA 8D///////////////////////////////////////////////////////
				--DECLARE @CREAR_CARPETA NVARCHAR(MAX) = N'\\10.1.1.5\documents\Quality\8D POR SISTEMA\' + CONVERT(VARCHAR(25), @PP_K_8D)+ '\SYMPTOM'
				DECLARE @CREAR_CARPETA NVARCHAR(MAX) = @VP_RUTA_DEFAULT + CONVERT(VARCHAR(25), @PP_K_8D)+ '\SYMPTOM'
				SET NOCOUNT ON
				EXECUTE master.dbo.xp_create_subdir  @CREAR_CARPETA
				SET NOCOUNT OFF

				INSERT INTO [8D_SYMPTOM_EVIDENCE]
					(	[K_8D_SYMPTOM_ACTION],				
						-- =================		
						[RUTA],				
						[NOMBRE_ARCHIVO],
						[TIPO_ARCHIVO],
						-- ===========================
						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
				VALUES	
					(	@PP_K_8D_SYMPTOM_ACTION,
						--- =================
						CONCAT(@CREAR_CARPETA, '\'),
						@PP_NOMBRE_ARCHIVO,	
						@PP_TIPO_ARCHIVO,								
						-- ===========================
						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
						0, NULL, NULL )
				
				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible subir el archivo para la [8D].', 16, 1 ) --MENSAJE - Severity -State.

			-- //////////////////////////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_SYMPTOM_EVIDENCE // ' + @VP_ERROR_TRANS
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
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_8D_SYMPTOM_ACTION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_8D_SYMPTOM_ACTION]
GO


CREATE PROCEDURE [dbo].[PG_DL_8D_SYMPTOM_ACTION]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_8D					INT,
	@PP_K_8D_SYMPTOM_ACTION		INT
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 
	IF @VP_MENSAJE=''
		BEGIN
			-- //////SE VERIFICA QUE LA ACCION NO TENGA EVIDENCIAS ASIGNADAS////////////////////////////////
			DECLARE @VP_N_EVIDENCE INT = 0
			SELECT @VP_N_EVIDENCE =  COUNT([K_8D_SYMPTOM_EVIDENCE])
			FROM [8D_SYMPTOM_EVIDENCE]
			WHERE K_8D_SYMPTOM_EVIDENCE = @PP_K_8D_SYMPTOM_ACTION

			IF @VP_N_EVIDENCE IS NULL
				SET @VP_N_EVIDENCE = 0

			IF @VP_N_EVIDENCE > 0
				SET @VP_MENSAJE = 'Contiene evidencias asignadas.'
		END

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY

				DELETE [8D_SYMPTOM_ACTION]		
				WHERE	K_8D = @PP_K_8D
				AND	K_8D_SYMPTOM_ACTION = @PP_K_8D_SYMPTOM_ACTION

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible Eliminar la Acción de la [8D].', 16, 1 ) --MENSAJE - Severity -State.
			
			-- //////////////////////////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_DL_8D_SYMPTOM_ACTION // ' + @VP_ERROR_TRANS
			END CATCH
		
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	IF @VP_MENSAJE<>''
		BEGIN
			SET		@VP_MENSAJE = 'No es posible [Eliminar] la Acción para la [8D]: ' + @VP_MENSAJE 
			SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
			SET		@VP_MENSAJE = @VP_MENSAJE + '[#8D.'+CONVERT(VARCHAR(10),@PP_K_8D)+']'
			SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		END
	
	-- //////////////////////////////////////////////////////////////
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_8D AS CLAVE

	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_8D_SYMPTOM_EVIDENCE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_8D_SYMPTOM_EVIDENCE]
GO


CREATE PROCEDURE [dbo].[PG_DL_8D_SYMPTOM_EVIDENCE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_8D_SYMPTOM_ACTION		INT,
	@PP_K_8D_SYMPTOM_EVIDENCE	INT
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 
	IF @VP_MENSAJE=''
		--EXECUTE [dbo].[PG_RN_INSPECCION_MATERIAL_DELETE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--									@PP_K_INSPECCION_MATERIAL, 
		--									@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY

				DELETE [8D_SYMPTOM_EVIDENCE]
				WHERE	K_8D_SYMPTOM_ACTION = @PP_K_8D_SYMPTOM_ACTION
				AND	K_8D_SYMPTOM_EVIDENCE = @PP_K_8D_SYMPTOM_EVIDENCE

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible Eliminar la evidencia para la [8D].', 16, 1 ) --MENSAJE - Severity -State.
			
			-- //////////////////////////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_DL_8D_SYMPTOM_EVIDENCE // ' + @VP_ERROR_TRANS
			END CATCH
		
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	IF @VP_MENSAJE<>''
		BEGIN
			SET		@VP_MENSAJE = 'No es posible [Eliminar] la evidencia para la [8D]: ' + @VP_MENSAJE 
			SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
			SET		@VP_MENSAJE = @VP_MENSAJE + '[#8D Ext.'+CONVERT(VARCHAR(10),@PP_K_8D_SYMPTOM_EVIDENCE)+']'
			SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		END
	
	-- //////////////////////////////////////////////////////////////
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_8D_SYMPTOM_EVIDENCE AS CLAVE

	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
