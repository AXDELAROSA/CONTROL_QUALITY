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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_8D_TEAM_DISPONIBLE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_8D_TEAM_DISPONIBLE]
GO

/*
 EXEC	[dbo].[PG_GET_8D_TEAM_DISPONIBLE] 0,0,  4
*/

CREATE PROCEDURE [dbo].[PG_GET_8D_TEAM_DISPONIBLE]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_CLASE_EMPLEADO					INT
AS
	
	-- ///////////////////////////////////////////
	SELECT	CONCAT(LTRIM(RTRIM(EP_NOMBRE)), ' ', LTRIM(RTRIM(EP_APELLIDO_PATERNO)), '     ', LTRIM(RTRIM(DP_DESC_DEPTO)),'     [', EN_NUM_EMP, ']') AS EMPLEADO
	FROM HOWE.dbo.VISTA_GAFETES (NOLOCK)
	WHERE EN_CLASE_EMP < 4
	ORDER BY DP_DEPTO
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_8D_TEAM]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_8D_TEAM]
GO

/*
 EXEC	[dbo].[PG_SK_8D_TEAM] 0,0,  1
*/

CREATE PROCEDURE [dbo].[PG_SK_8D_TEAM]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_8D							INT
AS
	
	-- ///////////////////////////////////////////
	SELECT	[K_8D_TEAM],	
			-- =================
			[K_8D],
			-- =================	
			[NUMERO_RELOJ],
			[ROL],			
			EP_NOMBRE				AS NOMBRE,
			EP_APELLIDO_PATERNO		AS AP_PATERNO,
			CORREO_USUARIO_PEARL	AS CORREO,
			DP_DESC_DEPTO			AS DEPARTAMENTO,			
			--D_USUARIO_PEARL,
			( SELECT	D_USUARIO_PEARL 
				FROM BD_GENERAL.dbo.USUARIO_PEARL (NOLOCK)
				WHERE K_USUARIO_PEARL = [8D_TEAM].K_USUARIO_CAMBIO ) AS D_USUARIO_PEARL,
			CONVERT(DATE, [8D_TEAM].[F_CAMBIO])	AS DATE	
			-- =================
	FROM	[8D_TEAM] (NOLOCK)
	INNER JOIN	HOWE.dbo.VISTA_GAFETES (NOLOCK) ON VISTA_GAFETES.EN_NUM_EMP = [NUMERO_RELOJ]
	INNER JOIN  BD_GENERAL.DBO.USUARIO_PEARL (NOLOCK) ON USUARIO_PEARL.K_EMPLEADO_PEARL = [NUMERO_RELOJ]
	-- =============================
	WHERE 	[K_8D] = @PP_K_8D
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_8D_TEAM_RECONOCIMIENTO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_8D_TEAM_RECONOCIMIENTO]
GO

/*
 EXEC	[dbo].[PG_SK_8D_TEAM_RECONOCIMIENTO] 0, 144, 1
*/

CREATE PROCEDURE [dbo].[PG_SK_8D_TEAM_RECONOCIMIENTO]
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT,
	-- ===========================
	@PP_K_8D				INT
AS

	-- ///////////////////////////////////////////
	SELECT	[K_8D],				
			-- =================
			( CASE WHEN [DATE_CLOSED] IS NULL THEN NULL --CONVERT(DATE, GETDATE()) 
					ELSE [DATE_CLOSED] END ) AS DATE_CLOSED,
			COMMENT
			-- =============================
	FROM	[8D] (NOLOCK)
	-- =============================
	WHERE 	[8D].K_8D = @PP_K_8D
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_8D_TEAM_RECONOCIMIENTO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_8D_TEAM_RECONOCIMIENTO]
GO

/*
	EXEC	[dbo].[PG_UP_8D_TEAM_RECONOCIMIENTO] 0, 144, 1
*/

CREATE PROCEDURE [dbo].[PG_UP_8D_TEAM_RECONOCIMIENTO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_8D					INT,
	@PP_F_CLOSED				DATE,
	@PP_COMMENT					VARCHAR(MAX)
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 
	EXECUTE [dbo].PG_RN_8D_VALIDAR_FECHA_CLOSED		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													@PP_K_8D, @PP_F_CLOSED,
													@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				
				UPDATE [8D]	
					SET [DATE_CLOSED] = @PP_F_CLOSED,
						COMMENT = @PP_COMMENT,
						-- ===========================
						[K_USUARIO_CAMBIO]	= @PP_K_USUARIO_ACCION, 
						[F_CAMBIO]			=  GETDATE()
				WHERE	K_8D = @PP_K_8D

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible Agregar el reconocimiento.', 16, 1 ) --MENSAJE - Severity -State.
			
			-- //////////////////////////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_UP_8D_TEAM_RECONOCIMIENTO // ' + @VP_ERROR_TRANS
			END CATCH
		
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	IF @VP_MENSAJE<>''
		BEGIN
			SET		@VP_MENSAJE = 'No es posible [Agregar] el reconocimiento al equipo de la [8D]: ' + @VP_MENSAJE 
			SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
			SET		@VP_MENSAJE = @VP_MENSAJE + '[#8D.'+CONVERT(VARCHAR(10),@PP_K_8D)+']'
			SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		END
	
	-- //////////////////////////////////////////////////////////////
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_8D AS CLAVE

	-- //////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT
-- //////////////////////////////////////////////////////////////

-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_8D_TEAM]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_8D_TEAM]
GO
/*
 EXECUTE [PG_IN_8D_TEAM] 0,144, 0 , '' , 0 , 1 , '' , '' , '2019/10/01' , '2019/10/01' , '2019/10/01' , '2019/10/01' , 'C:\Users\Francisco Esteban\Desktop\SERIAL REPETIDO.xlsx' , 'SERIAL REPETIDO.xlsx' 

*/
CREATE PROCEDURE [dbo].[PG_IN_8D_TEAM]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================	
	@PP_K_8D							INT,
	@PP_EMPLEADO						VARCHAR(255),
	-- ============================		
	@PP_ROL								VARCHAR(150)	
	--- =================
AS			
	
	DECLARE @VP_MENSAJE		VARCHAR(255) = ''

	-- ////////SE OBTIENE EL NUMERO DE RELOJ DE LA PERSONA SELECCIONADA/////////////////////////////////////////////////////
	/*
	12210	JOSE ABRHAM REZA     (SISTEMAS)     [12210]
	13164	ALEJANDRO DE LA ROSA     (SISTEMAS)     [13164]
	13367	FRANCISCO ESTEBAN     (SISTEMAS)     [13367] 
	*/

	--DECLARE @PP_PERSONA_SELECIONADA VARCHAR(MAX) = 'FRANCISCO ESTEBAN     (SISTEMAS)     [13367]'
	DECLARE @VP_POSICION_CORCHETE_ABRIR INT = CHARINDEX('[', @PP_EMPLEADO)
	DECLARE @VP_POSICION_CORCHETE_CERRAR INT = CHARINDEX(']', @PP_EMPLEADO)		
	
	DECLARE @PP_NUMERO_RELOJ VARCHAR(10) =  SUBSTRING(@PP_EMPLEADO, (@VP_POSICION_CORCHETE_ABRIR + 1), (@VP_POSICION_CORCHETE_CERRAR - (@VP_POSICION_CORCHETE_ABRIR + 1)))
	--SELECT @PP_NUMERO_RELOJ
	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	DECLARE @VP_N_RELOJ INT  = 0

	SELECT @VP_N_RELOJ = COUNT([K_8D_TEAM])
	FROM [8D_TEAM]
	WHERE [K_8D] = @PP_K_8D
	AND NUMERO_RELOJ = @PP_NUMERO_RELOJ

	IF @VP_N_RELOJ IS NULL
		SET @VP_N_RELOJ = 0

	IF @VP_N_RELOJ > 0
		SET @VP_MENSAJE = 'La persona que intenta Agregar ya esta dentro del equipo.'


	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				-- ///////SE INSERTA EL PARTICIPANTE A LA 8D///////////////////////////////////////////////////////
				INSERT INTO [8D_TEAM]
					(	[K_8D],			
						-- =================
						[NUMERO_RELOJ],
						[ROL],
						-- ===========================
						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
				VALUES	
					(	@PP_K_8D,	
						-- =================
						@PP_NUMERO_RELOJ,	
						@PP_ROL,							
						-- ===========================
						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
						0, NULL, NULL )

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible Agregar a la persona al equipo para la [8D].', 16, 1 ) --MENSAJE - Severity -State.
								
			-- //////////////////////////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_8D_TEAM // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	IF @VP_MENSAJE<>''
		BEGIN
			SET		@VP_MENSAJE = 'No es posible [AGREGAR] a la Persona al equipo para la [8D]: ' + @VP_MENSAJE 
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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_8D_TEAM]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_8D_TEAM]
GO


CREATE PROCEDURE [dbo].[PG_DL_8D_TEAM]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_8D					INT,
	@PP_K_8D_TEAM				INT
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY

				DELETE [8D_TEAM]		
				WHERE	K_8D = @PP_K_8D
				AND	K_8D_TEAM = @PP_K_8D_TEAM

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible Eliminar a la persona del equipo de la [8D].', 16, 1 ) --MENSAJE - Severity -State.
			
			-- //////////////////////////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_DL_8D_TEAM // ' + @VP_ERROR_TRANS
			END CATCH
		
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	IF @VP_MENSAJE<>''
		BEGIN
			SET		@VP_MENSAJE = 'No es posible [Eliminar] a la persona del equipo de la [8D]: ' + @VP_MENSAJE 
			SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
			SET		@VP_MENSAJE = @VP_MENSAJE + '[#8D.'+CONVERT(VARCHAR(10),@PP_K_8D)+']'
			SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		END
	
	-- //////////////////////////////////////////////////////////////
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_8D AS CLAVE

	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
