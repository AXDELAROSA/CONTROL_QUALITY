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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_8D]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_8D]
GO

/*
 EXEC	[dbo].[PG_LI_8D] 0,0,  '' , ''
*/

CREATE PROCEDURE [dbo].[PG_LI_8D]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_BUSCAR							VARCHAR(200),
	-- ===========================
	@PP_DATE							DATE
AS
	
	-- ///////////////////////////////////////////
	SELECT	[K_8D],				
			-- =================
			[K_8D_CUSTOMER],		
			[K_RMA],				
			[K_ESTATUS_8D],		
			-- =================
			CASE WHEN [EXTERNAL_FORMAT] = 0 THEN 'NO' ELSE 'SI' END AS FORMAT_EXTERNAL,	
			-- =================
			[TITLE],				
			[PRODUCT_PROCESS],		
			[DATE_OPENED],		
			[LAST_UPDATE],		
			[DUE_DATE],			
			[DATE_CLOSED],
			D_USUARIO_PEARL
			-- =============================
	FROM	[8D] (NOLOCK)
	INNER JOIN  BD_GENERAL.DBO.USUARIO_PEARL (NOLOCK) ON USUARIO_PEARL.K_USUARIO_PEARL = [8D].[K_USUARIO_ALTA]
	-- =============================
	WHERE 	( [K_8D_CUSTOMER]				LIKE '%'+@PP_BUSCAR+'%'
				OR	[TITLE]					LIKE '%'+@PP_BUSCAR+'%'
				OR	[PRODUCT_PROCESS]		LIKE '%'+@PP_BUSCAR+'%' )
	-- =============================
	AND		( [DATE_OPENED] = CASE WHEN @PP_DATE = '' THEN [DATE_OPENED]		ELSE	 @PP_DATE END
				OR	[LAST_UPDATE] = CASE WHEN @PP_DATE = '' THEN [LAST_UPDATE]	ELSE	 @PP_DATE END
				OR	[DATE_CLOSED] = CASE WHEN @PP_DATE = '' THEN [DATE_CLOSED]	ELSE	 @PP_DATE END )
	-- =============================
	AND K_ESTATUS_8D = 1 -- ACTIVA	
	-- =============================	
	ORDER BY [DATE_OPENED] DESC
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_8D]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_8D]
GO

/*
 EXEC	[dbo].[PG_SK_8D] 0,144,1
*/

CREATE PROCEDURE [dbo].[PG_SK_8D]
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT,
	-- ===========================
	@PP_K_8D				INT
AS

	-- ///////////////////////////////////////////
	SELECT	[K_8D],				
			-- =================
			[K_8D_CUSTOMER],		
			[K_RMA],				
			[K_ESTATUS_8D],		
			-- =================
			[EXTERNAL_FORMAT],	
			-- =================
			[TITLE],				
			[PRODUCT_PROCESS],		
			[DATE_OPENED],		
			[LAST_UPDATE],		
			[DUE_DATE],			
			[DATE_CLOSED],
			D_USUARIO_PEARL
			-- =============================
	FROM	[8D] (NOLOCK)
	INNER JOIN  BD_GENERAL.DBO.USUARIO_PEARL (NOLOCK) ON USUARIO_PEARL.K_USUARIO_PEARL = [8D].[K_USUARIO_ALTA]
	-- =============================
	WHERE 	[8D].K_8D = @PP_K_8D
	AND K_ESTATUS_8D = 1 -- ACTIVA
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_8D_EXTERNAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_8D_EXTERNAL]
GO

/*
 EXEC	[dbo].[PG_SK_8D_EXTERNAL] 0,144,2
*/

CREATE PROCEDURE [dbo].[PG_SK_8D_EXTERNAL]
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT,
	-- ===========================
	@PP_K_8D				INT
AS

	-- ///////////////////////////////////////////
	SELECT	[K_EXTERNAL_8D],
			-- ==============
			[K_8D],				
			-- =============	
			[RUTA],			
			[NOMBRE_ARCHIVO]		
			-- ==============
	FROM	[EXTERNAL_8D] (NOLOCK)
	WHERE 	[EXTERNAL_8D].K_8D = @PP_K_8D
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT
-- //////////////////////////////////////////////////////////////

-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_8D]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_UP_8D]
GO
/*
 EXECUTE [PG_IN_UP_8D] 0,144, 0 , '' , 0 , 1 , '' , '' , '2019/10/01' , '2019/10/01' , '2019/10/01' , '2019/10/01' , 'C:\Users\Francisco Esteban\Desktop\SERIAL REPETIDO.xlsx' , 'SERIAL REPETIDO.xlsx' 
 EXECUTE [PG_IN_UP_8D] 0,144, 0 , '' , 0 , 1 , '' , '' , '2019/10/01' , '2019/10/01' , '2019/10/01' , '2019/10/01' , '\\10.1.1.5\documents\Quality\8D POR SISTEMA\TEST.txt' , 'TEST.txt' 
  EXECUTE [PG_IN_UP_8D] 0,144, 0 , '' , 0 , 1 , '' , '' , '' , '' , '' , '' , 'INSPECCION_PIEL_450321.pdf' 
*/
CREATE PROCEDURE [dbo].[PG_IN_UP_8D]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================	
	@PP_K_8D							INT,
	@PP_K_8D_CUSTOMER					VARCHAR(150),
	@PP_K_RMA							INT,
	-- ===========================	
	@PP_EXTERNAL_FORMAT					INT,
	-- ============================		
	@PP_TITLE							VARCHAR(MAX),
	@PP_PRODUCT_PROCESS					VARCHAR(MAX),
	@PP_DATE_OPENED						DATE,
	@PP_LAST_UPDATE						DATE,
	@PP_DUE_DATE						DATE,
	@PP_DATE_CLOSED						DATE,
	-- =================							
	@PP_NOMBRE_ARCHIVO					VARCHAR(255)	
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
				IF @PP_K_8D = 0
					BEGIN
						EXECUTE BD_GENERAL.dbo.[PG_SK_CATALOGO_K_MAX_GET]	@PP_K_SISTEMA_EXE,
																			--'DATA_02PRUEBAS', 
																			'DATA_02', 
																			'[8D]', '[K_8D]',
																			@OU_K_TABLA_DISPONIBLE = @PP_K_8D	OUTPUT
						IF @PP_EXTERNAL_FORMAT = 1 
							BEGIN
								SET @PP_DATE_OPENED	= GETDATE()
								SET @PP_LAST_UPDATE	= GETDATE()
							END

						-- ///////SE INSERTA EL ENCABEZADO DEL 8D///////////////////////////////////////////////////////
						INSERT INTO [8D]
							(	[K_8D],			
								-- =================
								[K_8D_CUSTOMER],		
								[K_RMA],			
								-- =================
								[EXTERNAL_FORMAT],	
								-- =================
								[TITLE],				
								[PRODUCT_PROCESS],
								[DATE_OPENED],		
								[LAST_UPDATE],		
								[DUE_DATE],		
								[DATE_CLOSED],
								-- ===========================
								[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
								[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
						VALUES	
							(	@PP_K_8D,			
								@PP_K_8D_CUSTOMER,
								@PP_K_RMA,
								-- =================
								@PP_EXTERNAL_FORMAT,
								-- =================
								@PP_TITLE,
								@PP_PRODUCT_PROCESS,
								@PP_DATE_OPENED,
								@PP_LAST_UPDATE,	
								@PP_DUE_DATE,	
								@PP_DATE_CLOSED,
								-- ===========================
								@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
								0, NULL, NULL )

						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible Crear la [8D].', 16, 1 ) --MENSAJE - Severity -State.
						
						-- ///////SE CREA LA CARPETA PRINCIPAL DE LA 8D///////////////////////////////////////////////////////
						DECLARE @CREAR_CARPETA NVARCHAR(255)= N'\\10.1.1.5\documents\Quality\8D POR SISTEMA\' + CONVERT(VARCHAR(25), @PP_K_8D)
						--DECLARE @CREAR_CARPETA NVARCHAR(MAX) =  @VP_RUTA_DEFAULT + CONVERT(VARCHAR(25), @PP_K_8D)
						SET NOCOUNT ON
						EXECUTE master.dbo.xp_create_subdir  @CREAR_CARPETA
						SET NOCOUNT OFF

						-- ///////SI SE USA EL FORMATO DEL CLIENTE, SE SUBE EL  ARCHIVO DEL CLIENTE 8D EXTERNA///////////////////////////////////////////////////////
						IF @PP_EXTERNAL_FORMAT = 1
							BEGIN
								-- ///////SE CREA LA SUBCARPETA HEADER DE LA 8D///////////////////////////////////////////////////////
								SET @CREAR_CARPETA = N'\\10.1.1.5\documents\Quality\8D POR SISTEMA\' + CONVERT(VARCHAR(25), @PP_K_8D)+ '\HEADER'
								--SET @CREAR_CARPETA = @VP_RUTA_DEFAULT + CONVERT(VARCHAR(25), @PP_K_8D) + '\HEADER'
								SET NOCOUNT ON
								EXECUTE master.dbo.xp_create_subdir  @CREAR_CARPETA
								SET NOCOUNT OFF

								INSERT INTO [EXTERNAL_8D]
									(	[K_8D],				
										-- =================		
										[RUTA],				
										[NOMBRE_ARCHIVO],
										-- ===========================
										[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
										[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
								VALUES	
									(	@PP_K_8D,
										--- =================
										CONCAT(@CREAR_CARPETA, '\'),
										@PP_NOMBRE_ARCHIVO,									
										-- ===========================
										@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
										0, NULL, NULL )
								
								IF @@ROWCOUNT = 0
									RAISERROR ('ERROR: No fue posible subir el archivo del formato [8D] Externo.', 16, 1 ) --MENSAJE - Severity -State.
							END
					END
				ELSE
					BEGIN
						IF @PP_EXTERNAL_FORMAT = 1 
							SET @PP_LAST_UPDATE	= GETDATE()

						-- ///////SE ACTUALIZA EL ENCABEZADO DEL 8D///////////////////////////////////////////////////////
						UPDATE [8D]
							SET [K_8D_CUSTOMER]	= @PP_K_8D_CUSTOMER,		
								[K_RMA]				= @PP_K_RMA,
								-- =================
								[EXTERNAL_FORMAT]	= @PP_EXTERNAL_FORMAT,	
								-- =================
								[TITLE]				= @PP_TITLE,				
								[PRODUCT_PROCESS]	= @PP_PRODUCT_PROCESS,
								[DATE_OPENED]		= @PP_DATE_OPENED,		
								[LAST_UPDATE]		= @PP_LAST_UPDATE,		
								[DUE_DATE]			= @PP_DUE_DATE,		
								[DATE_CLOSED]		= @PP_DATE_CLOSED,
								-- ===========================
								[K_USUARIO_CAMBIO]	= @PP_K_USUARIO_ACCION, 
								[F_CAMBIO]			=  GETDATE()							
						WHERE	K_8D = @PP_K_8D

						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible Actualizar la [8D].', 16, 1 ) --MENSAJE - Severity -State.
							
						-- ///////SE CREA LA CARPETA PRINCIPAL DE LA 8D///////////////////////////////////////////////////////
						SET @CREAR_CARPETA = N'\\10.1.1.5\documents\Quality\8D POR SISTEMA\' + CONVERT(VARCHAR(25), @PP_K_8D)
						--SET @CREAR_CARPETA = @VP_RUTA_DEFAULT + CONVERT(VARCHAR(25), @PP_K_8D)
						SET NOCOUNT ON
						EXECUTE master.dbo.xp_create_subdir  @CREAR_CARPETA
						SET NOCOUNT OFF

						-- ///////SI SE USA EL FORMATO DEL CLIENTE, SE SUBE EL  ARCHIVO DEL CLIENTE 8D EXTERNA///////////////////////////////////////////////////////
						IF @PP_EXTERNAL_FORMAT = 1
							BEGIN	
								-- ///////SE CREA LA SUBCARPETA HEADER DE LA 8D///////////////////////////////////////////////////////
								SET @CREAR_CARPETA = N'\\10.1.1.5\documents\Quality\8D POR SISTEMA\' + CONVERT(VARCHAR(25), @PP_K_8D)+ '\HEADER'
								--SET @CREAR_CARPETA = @VP_RUTA_DEFAULT + CONVERT(VARCHAR(25), @PP_K_8D)+ '\HEADER'
								SET NOCOUNT ON
								EXECUTE master.dbo.xp_create_subdir  @CREAR_CARPETA
								SET NOCOUNT OFF
							
								INSERT INTO [EXTERNAL_8D]
									(	[K_8D],				
										-- =================		
										[RUTA],				
										[NOMBRE_ARCHIVO],
										-- ===========================
										[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
										[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
								VALUES	
									(	@PP_K_8D,
										-- =================
										CONCAT(@CREAR_CARPETA, '\'),
										@PP_NOMBRE_ARCHIVO,									
										-- ===========================
										@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
										0, NULL, NULL )
								
								IF @@ROWCOUNT = 0
									RAISERROR ('ERROR: No fue posible subir el archivo del formato [8D] Externo.', 16, 1 ) --MENSAJE - Severity -State.
							END
					END

			-- //////////////////////////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_8D // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	IF @VP_MENSAJE<>''
		BEGIN
			SET		@VP_MENSAJE = 'No es posible [Crear] la [8D]: ' + @VP_MENSAJE 
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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_8D]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_8D]
GO


CREATE PROCEDURE [dbo].[PG_DL_8D]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_8D					INT
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
				UPDATE [8D]
					SET K_ESTATUS_8D = 0,
						[K_USUARIO_CAMBIO]	= @PP_K_USUARIO_ACCION, 
						[F_CAMBIO]			=  GETDATE()
				WHERE	K_8D = @PP_K_8D

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible Eliminar la [8D] ', 16, 1 ) --MENSAJE - Severity -State.
			
			-- //////////////////////////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_DL_8D // ' + @VP_ERROR_TRANS
			END CATCH
		
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [Eliminar] la [8D]: ' + @VP_MENSAJE 
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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_8D_EXTERNAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_8D_EXTERNAL]
GO


CREATE PROCEDURE [dbo].[PG_DL_8D_EXTERNAL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_8D					INT,
	@PP_K_EXTERNAL_8D			INT
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

				DELETE [EXTERNAL_8D]
				WHERE	K_8D = @PP_K_8D
				AND K_EXTERNAL_8D = @PP_K_EXTERNAL_8D

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible Eliminar el formnato [8D] Externo.', 16, 1 ) --MENSAJE - Severity -State.
			
			-- //////////////////////////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_DL_8D // ' + @VP_ERROR_TRANS
			END CATCH
		
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	IF @VP_MENSAJE<>''
		BEGIN
			SET		@VP_MENSAJE = 'No es posible [Eliminar] el formato [8D] Externo: ' + @VP_MENSAJE 
			SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
			SET		@VP_MENSAJE = @VP_MENSAJE + '[#8D Ext.'+CONVERT(VARCHAR(10),@PP_K_EXTERNAL_8D)+']'
			SET		@VP_MENSAJE = @VP_MENSAJE + ' )'

		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_EXTERNAL_8D AS CLAVE

	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
