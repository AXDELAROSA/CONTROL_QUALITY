-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[PPMS_PEARL]
-- // MODULO:			PPM & CERTIFICACION REPORT
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	22/SEP/2021
-- //////////////////////////////////////////////////////////////  

USE [PPMS_PEARL]
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_DEFECTO_CALIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_DEFECTO_CALIDAD]
GO

/*
 EXEC	[dbo].[PG_LI_DEFECTO_CALIDAD] 0,0,  '' 
*/

CREATE PROCEDURE [dbo].[PG_LI_DEFECTO_CALIDAD]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_BUSCAR							VARCHAR(150)
AS


	-- ////////////////////////////////////////////////
	SELECT	LTRIM(RTRIM(CLAVE)) AS CLAVE,
			LTRIM(RTRIM(DEFECTO)) AS DEFECTO,
			LTRIM(RTRIM(TIPODEF)) AS TIPO,
			LTRIM(RTRIM(ISNULL(DESCRIPCION, '( S/C )'))) AS DESCRIPCION,		
			LTRIM(RTRIM(ISNULL(TRADUCCION, ''))) AS TRADUCCION,		
			(CASE WHEN CRITICO = 1 THEN 'SI'
				ELSE 'NO' END ) AS CRITICO
	FROM  [PPMS_PEARL].[dbo].DEF (NOLOCK)
	ORDER BY CLAVE
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_DEFECTO_CALIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_DEFECTO_CALIDAD]
GO

/*
 EXEC	[dbo].[PG_SK_DEFECTO_CALIDAD] 0,0,  'BB' 
*/

CREATE PROCEDURE [dbo].[PG_SK_DEFECTO_CALIDAD]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_CLAVE							VARCHAR(150)
AS

	-- ////////////////////////////////////////////////
	SELECT	LTRIM(RTRIM(CLAVE)) AS CLAVE,
			LTRIM(RTRIM(DEFECTO)) AS DEFECTO,
			LTRIM(RTRIM(TIPODEF)) AS TIPO,
			LTRIM(RTRIM(ISNULL(DESCRIPCION, '( S/C )'))) AS DESCRIPCION,	
			LTRIM(RTRIM(ISNULL(TRADUCCION, ''))) AS TRADUCCION,		
			ISNULL(CRITICO, 0) AS CRITICO		
	FROM  [PPMS_PEARL].[dbo].DEF (NOLOCK)
	WHERE CLAVE = @PP_CLAVE
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / UPDATE
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_DEFECTO_CALIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_UP_DEFECTO_CALIDAD]
GO
/*
	EXEC  [dbo].[PG_IN_UP_DEFECTO_CALIDAD] 0, 144, 'TEST' , 'PRUEBA DE SISTEMA' , 'TEST SYSTEM' , 'LAMINADO' , 'NATURAL' , 1 , 'franciscoe' , 'IT-010' 
*/
CREATE PROCEDURE [dbo].[PG_IN_UP_DEFECTO_CALIDAD]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_CLAVE							VARCHAR(50),
	@PP_DEFECTO							VARCHAR(255),
	@PP_TRADUCCION						VARCHAR(255),
	@PP_TIPO							VARCHAR(100),
	--@PP_CLASIFICACION					VARCHAR(100),
	@PP_CRITICO							INT,
	-- ===========================
	@PP_USER							VARCHAR(50),
	@PP_COMPUTER_NAME					VARCHAR(255)					
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY	
				--IF @PP_CLASIFICACION = '( S/C )'
				--	SET @PP_CLASIFICACION = NULL
					
				DECLARE @VP_N_CLAVE INT = 0
				SELECT	@VP_N_CLAVE = COUNT(CLAVE)	
				FROM  [PPMS_PEARL].[dbo].DEF (NOLOCK)
				WHERE CLAVE = @PP_CLAVE
				
				IF @VP_N_CLAVE IS NULL
					SET @VP_N_CLAVE = 0

				IF @VP_N_CLAVE = 0
					BEGIN
						INSERT INTO	[DEF]	(	CLAVE, 
												DEFECTO,
												TIPODEF,
												descripcion,
												TRADUCCION,
												CRITICO				
											)
										VALUES	(	UPPER(@PP_CLAVE),		
													UPPER(@PP_DEFECTO),			
													UPPER(@PP_TIPO),
													NULL,	--UPPER(@PP_CLASIFICACION),
													UPPER(@PP_TRADUCCION),
													UPPER(@PP_CRITICO)
												)
						
						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible Asignar el Defecto en [DEF] ', 16, 1 ) --MENSAJE - Severity -State.

						-- ////////SE GUARDA EL LOG///////////////////////////////////////////////////////			
						EXECUTE DATA_02.[dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_USER, @PP_COMPUTER_NAME, 'Modificar defecto',
																	'', 'ADD', @PP_DEFECTO, @PP_CLAVE
					END
				ELSE
					BEGIN
						UPDATE [DEF]
							SET DEFECTO	= UPPER(@PP_DEFECTO),
								TIPODEF = UPPER(@PP_TIPO),
								--descripcion = UPPER(@PP_CLASIFICACION),
								TRADUCCION = UPPER(@PP_TRADUCCION),
								CRITICO	= UPPER(@PP_CRITICO)
						WHERE CLAVE = @PP_CLAVE

						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible Actualizar el Defecto en [DEF] ', 16, 1 ) --MENSAJE - Severity -State.

						-- ////////SE GUARDA EL LOG///////////////////////////////////////////////////////			
						EXECUTE DATA_02.[dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_USER, @PP_COMPUTER_NAME, 'Modificar defecto',
																	'', 'UP', @PP_DEFECTO, @PP_CLAVE
					END
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_UP_DEFECTO_CALIDAD // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [GUARDAR] el Defecto: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#Def.'+CONVERT(VARCHAR(10),@PP_CLAVE)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_CLAVE AS CLAVE

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / UPDATE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_DEFECTO_CALIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_DEFECTO_CALIDAD]
GO
/*
	EXEC  [dbo].[PG_DL_DEFECTO_CALIDAD] 0, 144, '060' 
*/
CREATE PROCEDURE [dbo].[PG_DL_DEFECTO_CALIDAD]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_CLAVE							VARCHAR(50),
	-- ===========================
	@PP_USER							VARCHAR(50),
	@PP_COMPUTER_NAME					VARCHAR(255)									
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY			
				-- ////////SE ACTUALIZA/GUARDA LA INFORMACION EN CERTIFICACION_RPT///////////////////////////////////////////////////////				
				DELETE [DEF]
				WHERE CLAVE = @PP_CLAVE

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible Eliminar el Defecto en [DEF] ', 16, 1 ) --MENSAJE - Severity -State.
				
				-- ////////SE GUARDA EL LOG///////////////////////////////////////////////////////			
				EXECUTE DATA_02.[dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_USER, @PP_COMPUTER_NAME, 'Modificar defecto',
															'', 'DL', '', @PP_CLAVE
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_DL_DEFECTO_CALIDAD // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [ELIMINAR] el Defecto: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#Def.'+CONVERT(VARCHAR(10),@PP_CLAVE)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_CLAVE AS CLAVE

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
