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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_CERTIFICACION_REPORT_X_FECHA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_CERTIFICACION_REPORT_X_FECHA]
GO

/*
 EXEC	[dbo].[PG_LI_CERTIFICACION_REPORT_X_FECHA] 0,0, '2021-09-01', '2021-09-22'
*/

CREATE PROCEDURE [dbo].[PG_LI_CERTIFICACION_REPORT_X_FECHA]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_F_INICIAL						DATE,
	@PP_F_FIN							DATE
AS

	-- ///////////////////////////////////////////	
	DECLARE @VP_F_INICIAL_INT INT = DATA_02.[dbo].[CONVERT_DATE_TO_INT](@PP_F_INICIAL, 'yyyyMMdd')
	DECLARE @VP_F_FIN_INT INT = DATA_02.[dbo].[CONVERT_DATE_TO_INT](@PP_F_FIN, 'yyyyMMdd')

	-- ///////////////////////////////////////////
	SELECT	[sello_paq], [no_parte], [programa], [orden], [mesa], [paquetes], [piezas_set], 
			[defecto1], [cant1], [defecto2], [cant2], [defecto3], [cant3], [fecha], [turno], 
			[insp_certi], [mezclada], [extra], [total], [id],[noserie_caja], [patron], [estacion], [hora]
	FROM certificacion_rpt (NOLOCK)
	WHERE fecha >= @VP_F_INICIAL_INT
	AND fecha <= @VP_F_FIN_INT
	ORDER BY FECHA DESC
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> DELETE / FICHA
---- //////////////////////////////////////////////////////////////

--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_8D_TEAM_RECONOCIMIENTO]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_UP_8D_TEAM_RECONOCIMIENTO]
--GO

--/*
--	EXEC	[dbo].[PG_UP_8D_TEAM_RECONOCIMIENTO] 0, 144, 1
--*/

--CREATE PROCEDURE [dbo].[PG_UP_8D_TEAM_RECONOCIMIENTO]
--	@PP_K_SISTEMA_EXE			INT,
--	@PP_K_USUARIO_ACCION		INT,
--	-- ===========================
--	@PP_K_8D					INT,
--	@PP_F_CLOSED				DATE,
--	@PP_COMMENT					VARCHAR(MAX)
--AS

--	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

--	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 
--	EXECUTE [dbo].PG_RN_8D_VALIDAR_FECHA_CLOSED		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
--													@PP_K_8D, @PP_F_CLOSED,
--													@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

--	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
--	IF @VP_MENSAJE=''
--		BEGIN
--			BEGIN TRANSACTION 
--			BEGIN TRY
				
--				UPDATE [8D]	
--					SET [DATE_CLOSED] = @PP_F_CLOSED,
--						COMMENT = @PP_COMMENT,
--						-- ===========================
--						[K_USUARIO_CAMBIO]	= @PP_K_USUARIO_ACCION, 
--						[F_CAMBIO]			=  GETDATE()
--				WHERE	K_8D = @PP_K_8D

--				IF @@ROWCOUNT = 0
--					RAISERROR ('ERROR: No fue posible Agregar el reconocimiento.', 16, 1 ) --MENSAJE - Severity -State.
			
--			-- //////////////////////////////////////////////////////////////
--			COMMIT TRANSACTION 
--			END TRY
	
--			BEGIN CATCH
--				/* Ocurrió un error, deshacemos los cambios*/ 
--				ROLLBACK TRANSACTION
--				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
--				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
--				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_UP_8D_TEAM_RECONOCIMIENTO // ' + @VP_ERROR_TRANS
--			END CATCH
		
--		END

--	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
--	IF @VP_MENSAJE<>''
--		BEGIN
--			SET		@VP_MENSAJE = 'No es posible [Agregar] el reconocimiento al equipo de la [8D]: ' + @VP_MENSAJE 
--			SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
--			SET		@VP_MENSAJE = @VP_MENSAJE + '[#8D.'+CONVERT(VARCHAR(10),@PP_K_8D)+']'
--			SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
--		END
	
--	-- //////////////////////////////////////////////////////////////
--	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_8D AS CLAVE

--	-- //////////////////////////////////////////////////////////////
--GO




---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> INSERT
---- //////////////////////////////////////////////////////////////

---- USE DATA_02
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_8D_TEAM]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_IN_8D_TEAM]
--GO
--/*
-- EXECUTE [PG_IN_8D_TEAM] 0,144, 0 , '' , 0 , 1 , '' , '' , '2019/10/01' , '2019/10/01' , '2019/10/01' , '2019/10/01' , 'C:\Users\Francisco Esteban\Desktop\SERIAL REPETIDO.xlsx' , 'SERIAL REPETIDO.xlsx' 

--*/
--CREATE PROCEDURE [dbo].[PG_IN_8D_TEAM]
--	@PP_K_SISTEMA_EXE					INT,
--	@PP_K_USUARIO_ACCION				INT,
--	-- ===========================	
--	@PP_K_8D							INT,
--	@PP_EMPLEADO						VARCHAR(255),
--	-- ============================		
--	@PP_ROL								VARCHAR(150)	
--	--- =================
--AS			
	
--	DECLARE @VP_MENSAJE		VARCHAR(255) = ''

--	-- ////////SE OBTIENE EL NUMERO DE RELOJ DE LA PERSONA SELECCIONADA/////////////////////////////////////////////////////
--	/*
--	12210	JOSE ABRHAM REZA     (SISTEMAS)     [12210]
--	13164	ALEJANDRO DE LA ROSA     (SISTEMAS)     [13164]
--	13367	FRANCISCO ESTEBAN     (SISTEMAS)     [13367] 
--	*/

--	--DECLARE @PP_PERSONA_SELECIONADA VARCHAR(MAX) = 'FRANCISCO ESTEBAN     (SISTEMAS)     [13367]'
--	DECLARE @VP_POSICION_CORCHETE_ABRIR INT = CHARINDEX('[', @PP_EMPLEADO)
--	DECLARE @VP_POSICION_CORCHETE_CERRAR INT = CHARINDEX(']', @PP_EMPLEADO)		
	
--	DECLARE @PP_NUMERO_RELOJ VARCHAR(10) =  SUBSTRING(@PP_EMPLEADO, (@VP_POSICION_CORCHETE_ABRIR + 1), (@VP_POSICION_CORCHETE_CERRAR - (@VP_POSICION_CORCHETE_ABRIR + 1)))
--	--SELECT @PP_NUMERO_RELOJ
--	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
--	DECLARE @VP_N_RELOJ INT  = 0

--	SELECT @VP_N_RELOJ = COUNT([K_8D_TEAM])
--	FROM [8D_TEAM]
--	WHERE [K_8D] = @PP_K_8D
--	AND NUMERO_RELOJ = @PP_NUMERO_RELOJ

--	IF @VP_N_RELOJ IS NULL
--		SET @VP_N_RELOJ = 0

--	IF @VP_N_RELOJ > 0
--		SET @VP_MENSAJE = 'La persona que intenta Agregar ya esta dentro del equipo.'


--	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
--	IF @VP_MENSAJE=''
--		BEGIN
--			BEGIN TRANSACTION 
--			BEGIN TRY
--				-- ///////SE INSERTA EL PARTICIPANTE A LA 8D///////////////////////////////////////////////////////
--				INSERT INTO [8D_TEAM]
--					(	[K_8D],			
--						-- =================
--						[NUMERO_RELOJ],
--						[ROL],
--						-- ===========================
--						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
--						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
--				VALUES	
--					(	@PP_K_8D,	
--						-- =================
--						@PP_NUMERO_RELOJ,	
--						@PP_ROL,							
--						-- ===========================
--						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
--						0, NULL, NULL )

--				IF @@ROWCOUNT = 0
--					RAISERROR ('ERROR: No fue posible Agregar a la persona al equipo para la [8D].', 16, 1 ) --MENSAJE - Severity -State.
								
--			-- //////////////////////////////////////////////////////////////
--			COMMIT TRANSACTION 
--			END TRY
	
--			BEGIN CATCH
--				/* Ocurrió un error, deshacemos los cambios*/ 
--				ROLLBACK TRANSACTION
--				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
--				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
--				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_8D_TEAM // ' + @VP_ERROR_TRANS
--			END CATCH
				
--		END

--	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
--	IF @VP_MENSAJE<>''
--		BEGIN
--			SET		@VP_MENSAJE = 'No es posible [AGREGAR] a la Persona al equipo para la [8D]: ' + @VP_MENSAJE 
--			SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
--			SET		@VP_MENSAJE = @VP_MENSAJE + '[#8D.'+CONVERT(VARCHAR(10),@PP_K_8D)+']'
--			SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
--		END
	
--	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_8D AS CLAVE

--	-- //////////////////////////////////////////////////////////////
--GO




---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> DELETE / FICHA
---- //////////////////////////////////////////////////////////////

--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_8D_TEAM]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_DL_8D_TEAM]
--GO


--CREATE PROCEDURE [dbo].[PG_DL_8D_TEAM]
--	@PP_K_SISTEMA_EXE			INT,
--	@PP_K_USUARIO_ACCION		INT,
--	-- ===========================
--	@PP_K_8D					INT,
--	@PP_K_8D_TEAM				INT
--AS

--	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

--	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 

--	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
--	IF @VP_MENSAJE=''
--		BEGIN
--			BEGIN TRANSACTION 
--			BEGIN TRY

--				DELETE [8D_TEAM]		
--				WHERE	K_8D = @PP_K_8D
--				AND	K_8D_TEAM = @PP_K_8D_TEAM

--				IF @@ROWCOUNT = 0
--					RAISERROR ('ERROR: No fue posible Eliminar a la persona del equipo de la [8D].', 16, 1 ) --MENSAJE - Severity -State.
			
--			-- //////////////////////////////////////////////////////////////
--			COMMIT TRANSACTION 
--			END TRY
	
--			BEGIN CATCH
--				/* Ocurrió un error, deshacemos los cambios*/ 
--				ROLLBACK TRANSACTION
--				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
--				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
--				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_DL_8D_TEAM // ' + @VP_ERROR_TRANS
--			END CATCH
		
--		END

--	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
--	IF @VP_MENSAJE<>''
--		BEGIN
--			SET		@VP_MENSAJE = 'No es posible [Eliminar] a la persona del equipo de la [8D]: ' + @VP_MENSAJE 
--			SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
--			SET		@VP_MENSAJE = @VP_MENSAJE + '[#8D.'+CONVERT(VARCHAR(10),@PP_K_8D)+']'
--			SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
--		END
	
--	-- //////////////////////////////////////////////////////////////
--	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_8D AS CLAVE

--	-- //////////////////////////////////////////////////////////////
--GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
