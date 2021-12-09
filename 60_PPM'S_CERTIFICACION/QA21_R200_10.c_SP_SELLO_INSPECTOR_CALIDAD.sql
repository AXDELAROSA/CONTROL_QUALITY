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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_SELLO_INSPECTOR_CALIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_SELLO_INSPECTOR_CALIDAD]
GO

/*
 EXEC	[dbo].[PG_LI_SELLO_INSPECTOR_CALIDAD] 0,0,  '' 
*/

CREATE PROCEDURE [dbo].[PG_LI_SELLO_INSPECTOR_CALIDAD]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_BUSCAR							VARCHAR(150)
AS

	-- ////////////////////////////////////////////////
	SELECT	SELLO, 
			NORELOJ AS N_RELOJ,
			inspector_cal AS INSPECTOR,
			TURNO			
	FROM  [PPMS_PEARL].[dbo].personal (NOLOCK)
	ORDER BY SELLO
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_SELLO_INSPECTOR_CALIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_SELLO_INSPECTOR_CALIDAD]
GO

/*
 EXEC	[dbo].[PG_SK_SELLO_INSPECTOR_CALIDAD] 0,0,  '011' 
*/

CREATE PROCEDURE [dbo].[PG_SK_SELLO_INSPECTOR_CALIDAD]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_SELLO							VARCHAR(150)
AS

	-- ////////////////////////////////////////////////
	SELECT	SELLO, 
			NORELOJ AS N_RELOJ,
			inspector_cal AS INSPECTOR,
			TURNO			
	FROM  [PPMS_PEARL].[dbo].personal (NOLOCK)
	WHERE SELLO = @PP_SELLO
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / UPDATE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_SELLO_INSPECTOR_CALIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_UP_SELLO_INSPECTOR_CALIDAD]
GO
/*
	EXEC  [dbo].[PG_IN_UP_SELLO_INSPECTOR_CALIDAD] 0, 0, 0 , '060' , '174034P' , 'WK JEEP GL DL' , '43789' , 'Table 16' , 1 , 30 , 'CA' , 1 , 'MCZ' , 1 , '( S/D )' , 0 , '2021/10/12' , 'JOVANNA DULCE DE LA LUZ BALCAZAR CRUZ' , '1' , '43789005' , '65426M1' , 'IT-010' 
*/
CREATE PROCEDURE [dbo].[PG_IN_UP_SELLO_INSPECTOR_CALIDAD]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_SELLO							VARCHAR(50),
	@PP_N_RELOJ							INT,
	@PP_NOMBRE							VARCHAR(255),
	@PP_TURNO							INT,			
	@PP_COMENTARIO						VARCHAR(25),
	-- ===========================
	@PP_USER							VARCHAR(50),
	@PP_COMPUTER_NAME					VARCHAR(255)					
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY			
				DECLARE @VP_N_SELLO INT = 0
				SELECT	@VP_N_SELLO = COUNT(SELLO)	
				FROM  [PPMS_PEARL].[dbo].[personal] (NOLOCK)
				WHERE SELLO = @PP_SELLO
				
				IF @VP_N_SELLO IS NULL
					SET @VP_N_SELLO = 0

				IF @VP_N_SELLO = 0
					BEGIN
						INSERT INTO	[personal]	(	SELLO, 
													NORELOJ,
													inspector_cal,
													TURNO
												)
										VALUES	(	@PP_SELLO,	
													@PP_N_RELOJ,	
													@PP_NOMBRE,	
													@PP_TURNO	
												)
						
						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible Asignar el sello en [personal] ', 16, 1 ) --MENSAJE - Severity -State.

						-- ////////SE GUARDA EL LOG///////////////////////////////////////////////////////			
						EXECUTE DATA_02.[dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_USER, @PP_COMPUTER_NAME, 'Modificar Sellos',
																	@PP_N_RELOJ, 'ADD', @PP_COMENTARIO, @PP_SELLO
					END
				ELSE
					BEGIN
						UPDATE [personal]
							SET NORELOJ			= @PP_N_RELOJ,
								inspector_cal	= @PP_NOMBRE,
								TURNO			= @PP_TURNO
						WHERE SELLO = @PP_SELLO

						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible Actualizar el sello en [personal] ', 16, 1 ) --MENSAJE - Severity -State.

						-- ////////SE GUARDA EL LOG///////////////////////////////////////////////////////			
						EXECUTE DATA_02.[dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_USER, @PP_COMPUTER_NAME, 'Modificar Sellos',
																	@PP_N_RELOJ, 'UP', @PP_COMENTARIO, @PP_SELLO
					END
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_UP_SELLO_INSPECTOR_CALIDAD // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [GUARDAR] el Sello: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#Sello.'+CONVERT(VARCHAR(10),@PP_SELLO)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_SELLO AS CLAVE

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / UPDATE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_SELLO_INSPECTOR_CALIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_SELLO_INSPECTOR_CALIDAD]
GO
/*
	EXEC  [dbo].[PG_DL_SELLO_INSPECTOR_CALIDAD] 0, 144, '060' 
*/
CREATE PROCEDURE [dbo].[PG_DL_SELLO_INSPECTOR_CALIDAD]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_SELLO							VARCHAR(50),
	-- ===========================
	@PP_USER							VARCHAR(50),
	@PP_COMPUTER_NAME					VARCHAR(255)									
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY			
				-- ////////SE ELIMINA EL SELLO DE [personal]///////////////////////////////////////////////////////				
				DELETE [personal]
				WHERE SELLO = @PP_SELLO

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible Eliminar el sello en [personal] ', 16, 1 ) --MENSAJE - Severity -State.
				
				-- ////////SE GUARDA EL LOG///////////////////////////////////////////////////////			
				EXECUTE DATA_02.[dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_USER, @PP_COMPUTER_NAME, 'Modificar Sellos',
															'', 'DL', '', @PP_SELLO
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_DL_SELLO_INSPECTOR_CALIDAD // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [ELIMINAR] el Sello: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#Sello.'+CONVERT(VARCHAR(10),@PP_SELLO)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_SELLO AS CLAVE

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
