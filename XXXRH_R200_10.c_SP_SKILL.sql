-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	RH
-- // MODULO:			SKILL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	10/FEB/2020
-- //////////////////////////////////////////////////////////////  

USE [RH]
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_SKILL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_SKILL]
GO
/*
 EXEC	[dbo].[PG_LI_SKILL] 0,0, '', -1, -1, '2018-04-03'
*/

CREATE PROCEDURE [dbo].[PG_LI_SKILL]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_BUSCAR						VARCHAR(200),
	-- ===========================
	@PP_K_PUESTO_DESCRIPCION		INT,
	@PP_K_ESTATUS_SKILL				INT,
	@PP_K_TIPO_SKILL				INT
AS

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	
	-- ///////////////////////////////////////////

	SELECT	TOP (5000)
			SKILL.*,
			D_PUESTO_DESCRIPCION, S_PUESTO_DESCRIPCION, 
			D_ESTATUS_SKILL, S_ESTATUS_SKILL, 
			D_TIPO_SKILL, S_TIPO_SKILL, 
			K_USUARIO_PEARL AS D_USUARIO_CAMBIO
			-- =============================	
	FROM	SKILL, PUESTO_DESCRIPCION, ESTATUS_SKILL,
			TIPO_SKILL,
			BD_GENERAL.dbo.USUARIO_PEARL
			-- =============================
	WHERE	SKILL.K_ESTATUS_SKILL=ESTATUS_SKILL.K_ESTATUS_SKILL
	AND		SKILL.K_PUESTO_DESCRIPCION=PUESTO_DESCRIPCION.K_PUESTO_DESCRIPCION
	AND		SKILL.K_TIPO_SKILL=TIPO_SKILL.K_TIPO_SKILL
	AND		SKILL.K_USUARIO_CAMBIO=BD_GENERAL.dbo.USUARIO_PEARL.K_USUARIO_PEARL
			-- =============================
	AND		(	D_PUESTO_DESCRIPCION		LIKE '%'+@PP_BUSCAR+'%'
			OR	D_TIPO_SKILL				LIKE '%'+@PP_BUSCAR+'%'
			OR	D_ESTATUS_SKILL				LIKE '%'+@PP_BUSCAR+'%' 
			OR	REQUERIMIENTO				LIKE '%'+@PP_BUSCAR+'%' )
			-- =============================
	AND		( @PP_K_PUESTO_DESCRIPCION=-1	OR	SKILL.K_PUESTO_DESCRIPCION=@PP_K_PUESTO_DESCRIPCION )
	AND		( @PP_K_ESTATUS_SKILL=-1		OR	SKILL.K_ESTATUS_SKILL=@PP_K_ESTATUS_SKILL )
	AND		( @PP_K_TIPO_SKILL=-1			OR	SKILL.K_TIPO_SKILL=@PP_K_TIPO_SKILL )
			-- =============================
	ORDER BY	K_TIPO_SKILL
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_SKILL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_SKILL]
GO

/*
 EXEC	[dbo].[PG_SK_SKILL] 0,2003,100, 2
*/

CREATE PROCEDURE [dbo].[PG_SK_SKILL]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_SKILL					INT
AS

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	
	-- ///////////////////////////////////////////

	SELECT	TOP (5000)
			SKILL.*,
			D_PUESTO_DESCRIPCION, S_PUESTO_DESCRIPCION, 
			D_ESTATUS_SKILL, S_ESTATUS_SKILL, 
			D_TIPO_SKILL, S_TIPO_SKILL, 
			K_USUARIO_PEARL AS D_USUARIO_CAMBIO
			-- =============================	
	FROM	SKILL, PUESTO_DESCRIPCION, ESTATUS_SKILL,
			TIPO_SKILL,
			BD_GENERAL.dbo.USUARIO_PEARL
			-- =============================
	WHERE	SKILL.K_ESTATUS_SKILL=ESTATUS_SKILL.K_ESTATUS_SKILL
	AND		SKILL.K_PUESTO_DESCRIPCION=PUESTO_DESCRIPCION.K_PUESTO_DESCRIPCION
	AND		SKILL.K_TIPO_SKILL=TIPO_SKILL.K_TIPO_SKILL
	AND		SKILL.K_USUARIO_CAMBIO=BD_GENERAL.dbo.USUARIO_PEARL.K_USUARIO_PEARL
			-- =============================
	AND		K_SKILL=@PP_K_SKILL

	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_SKILL_X_K_PUESTO_DESCRIPCION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_SKILL_X_K_PUESTO_DESCRIPCION]
GO

/*
SELECT * FROM SKILL
 EXEC	[dbo].[PG_SK_SKILL_X_K_PUESTO_DESCRIPCION] 0,0, 1
*/

CREATE PROCEDURE [dbo].[PG_SK_SKILL_X_K_PUESTO_DESCRIPCION]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_PUESTO_DESCRIPCION					INT
AS

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	
	-- ///////////////////////////////////////////

	SELECT	TOP (5000)
			SKILL.*,
			D_PUESTO_DESCRIPCION, S_PUESTO_DESCRIPCION, 
			D_ESTATUS_SKILL, S_ESTATUS_SKILL, 
			-- =============================	
			( CASE	WHEN SKILL.K_ESTATUS_SKILL = 0 THEN 0
					ELSE 1 END )	AS AUTORIZADO,
			-- =============================	
			D_TIPO_SKILL, S_TIPO_SKILL, 
			K_USUARIO_PEARL AS D_USUARIO_CAMBIO
			-- =============================	
	FROM	SKILL, PUESTO_DESCRIPCION, ESTATUS_SKILL,
			TIPO_SKILL,
			BD_GENERAL.dbo.USUARIO_PEARL
			-- =============================
	WHERE	SKILL.K_ESTATUS_SKILL=ESTATUS_SKILL.K_ESTATUS_SKILL
	AND		SKILL.K_PUESTO_DESCRIPCION=PUESTO_DESCRIPCION.K_PUESTO_DESCRIPCION
	AND		SKILL.K_TIPO_SKILL=TIPO_SKILL.K_TIPO_SKILL
	AND		SKILL.K_USUARIO_CAMBIO=BD_GENERAL.dbo.USUARIO_PEARL.K_USUARIO_PEARL
			-- =============================
	AND		SKILL.K_PUESTO_DESCRIPCION=@PP_K_PUESTO_DESCRIPCION
	ORDER BY TIPO_SKILL.K_TIPO_SKILL 

	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_SKILL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_SKILL]
GO

-- EXECUTE [PG_IN_SKILL] 0,0, 44 , 1 , 0 , 'DESARROLLAR LAS DIFERENTES SOLUCIONES QUE SE NECESITEN EN LA EMPRESA'
CREATE PROCEDURE [dbo].[PG_IN_SKILL]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================	
	@PP_K_PUESTO_DESCRIPCION					INT,
	@PP_K_TIPO_SKILL				INT,
	@PP_K_ESTATUS_SKILL				INT,
	-- ===========================	
	@PP_REQUERIMIENTO				VARCHAR(255)
	-- ============================		
AS			
	
	DECLARE @VP_MENSAJE		VARCHAR(300) = ''
	
	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	
	DECLARE @VP_K_SKILL	INT = 0
	
	IF @VP_MENSAJE=''	
		--EXECUTE [dbo].[PG_RN_SKILL_INSERT]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--										@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY

				EXECUTE BD_GENERAL.dbo.[PG_SK_CATALOGO_K_MAX_GET] @PP_K_SISTEMA_EXE,
																		'RH', 'SKILL', 'K_SKILL',
																		@OU_K_TABLA_DISPONIBLE = @VP_K_SKILL	OUTPUT
				
				-- ====================================
				INSERT INTO SKILL
					(	[K_SKILL],
						-- ===========================
						[K_PUESTO_DESCRIPCION], 
						[K_TIPO_SKILL],
						[K_ESTATUS_SKILL],
						-- ===========================
						[REQUERIMIENTO],
						[F_ASIGNACION],
						-- ===========================
						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
				VALUES	
					(	@VP_K_SKILL,
					-- ===========================	
						@PP_K_PUESTO_DESCRIPCION,	
						@PP_K_TIPO_SKILL,
						@PP_K_ESTATUS_SKILL,
						-- ===========================
						@PP_REQUERIMIENTO,
						GETDATE(),
						-- ===========================
						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
						0, NULL, NULL )

			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_SKILL // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [Crear] el [SKILL]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#SKI.'+CONVERT(VARCHAR(10),@VP_K_SKILL)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_SKILL AS CLAVE

	-- //////////////////////////////////////////////////////////////

GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT X DESCRIPCION DE PUESTO EXISTENTE
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_SKILL_X_PUESTO_DESCRIPCION_EXISTENTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_SKILL_X_PUESTO_DESCRIPCION_EXISTENTE]
GO

-- EXECUTE [PG_IN_SKILL] 0,0, 44 , 1 , 0 , 'DESARROLLAR LAS DIFERENTES SOLUCIONES QUE SE NECESITEN EN LA EMPRESA'
CREATE PROCEDURE [dbo].[PG_IN_SKILL_X_PUESTO_DESCRIPCION_EXISTENTE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================	
	@PP_K_PUESTO_DESCRIPCION		INT,
	@PP_K_PUESTO_DESCRIPCION_CLONAR	INT
	-- ============================		
AS			
	
	DECLARE @VP_MENSAJE		VARCHAR(300) = ''
	
	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	
	DECLARE @VP_K_SKILL	INT = 0
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY

				DELETE SKILL
				WHERE K_PUESTO_DESCRIPCION = @PP_K_PUESTO_DESCRIPCION

				DECLARE @VP_K_TIPO_SKILL	INT
				DECLARE @VP_REQUERIMIENTO	VARCHAR(MAX)

				DECLARE CU_SKILL_X_PUESTO_DESCRIPCION CURSOR 
				FOR SELECT	K_TIPO_SKILL, REQUERIMIENTO 
					FROM	SKILL
					WHERE	K_PUESTO_DESCRIPCION = @PP_K_PUESTO_DESCRIPCION_CLONAR
				
				OPEN CU_SKILL_X_PUESTO_DESCRIPCION
				FETCH NEXT FROM CU_SKILL_X_PUESTO_DESCRIPCION INTO @VP_K_TIPO_SKILL, @VP_REQUERIMIENTO
				
				WHILE @@FETCH_STATUS = 0
					BEGIN

						EXECUTE BD_GENERAL.dbo.[PG_SK_CATALOGO_K_MAX_GET] @PP_K_SISTEMA_EXE,
																				'RH', 'SKILL', 'K_SKILL',
																				@OU_K_TABLA_DISPONIBLE = @VP_K_SKILL	OUTPUT
						-- ====================================
						INSERT INTO SKILL
							(	[K_SKILL],
								-- ===========================
								[K_PUESTO_DESCRIPCION], 
								[K_TIPO_SKILL],
								[K_ESTATUS_SKILL],
								-- ===========================
								[REQUERIMIENTO],
								[F_ASIGNACION],
								-- ===========================
								[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
								[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
						VALUES	
							(	@VP_K_SKILL,
							-- ===========================	
								@PP_K_PUESTO_DESCRIPCION,	
								@VP_K_TIPO_SKILL,
								0,
								-- ===========================
								@VP_REQUERIMIENTO,
								GETDATE(),
								-- ===========================
								@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
								0, NULL, NULL )

						FETCH NEXT FROM CU_SKILL_X_PUESTO_DESCRIPCION INTO @VP_K_TIPO_SKILL, @VP_REQUERIMIENTO				
					END
				CLOSE CU_SKILL_X_PUESTO_DESCRIPCION
				DEALLOCATE CU_SKILL_X_PUESTO_DESCRIPCION
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_SKILL_X_PUESTO_DESCRIPCION_EXISTENTE // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [Crear] el [SKILL]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#DDP.'+CONVERT(VARCHAR(10),@PP_K_PUESTO_DESCRIPCION)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_PUESTO_DESCRIPCION AS CLAVE

	-- //////////////////////////////////////////////////////////////

GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> ACTUALIZAR / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_SKILL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_SKILL]
GO

CREATE PROCEDURE [dbo].[PG_UP_SKILL]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_SKILL						INT,
	-- ============================	
	@PP_K_PUESTO_DESCRIPCION					INT,
	@PP_K_TIPO_SKILL				INT,
	@PP_K_ESTATUS_SKILL				INT,
	-- ===========================	
	@PP_REQUERIMIENTO				VARCHAR(255)
	-- ============================		
AS			

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	
	IF @VP_MENSAJE=''
		--EXECUTE [dbo].[PG_RN_SKILL_UPDATE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--									@PP_K_SKILL,
		--									@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
		
				UPDATE	SKILL
				SET			
						[K_SKILL]				= @PP_K_SKILL,
						-- ===========================
						[K_PUESTO_DESCRIPCION]				= @PP_K_PUESTO_DESCRIPCION,
						[K_TIPO_SKILL]			= @PP_K_TIPO_SKILL,
						[K_ESTATUS_SKILL]		= @PP_K_ESTATUS_SKILL,
						-- ===========================
						[REQUERIMIENTO]			= @PP_REQUERIMIENTO, 
						-- ===========================
					    [F_CAMBIO]						= GETDATE(), 
						[K_USUARIO_CAMBIO]				= @PP_K_USUARIO_ACCION
				WHERE	K_SKILL=@PP_K_SKILL

				IF @@ROWCOUNT = 0
				RAISERROR ('ERROR: No se Actualizo el Skill ', 16, 1 ) --MENSAJE - Severity -State.
				--=====================================================	

			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_UP_SKILL // ' + @VP_ERROR_TRANS
			END CATCH
	
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [Actualizar] el [SKILL]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#SKI.'+CONVERT(VARCHAR(10),@PP_K_SKILL)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'

		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_SKILL AS CLAVE

	-- //////////////////////////////////////////////////////////////
	
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_SKILL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_SKILL]
GO


CREATE PROCEDURE [dbo].[PG_DL_SKILL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_SKILL				INT
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 
	
	IF @VP_MENSAJE=''
		--EXECUTE [dbo].[PG_RN_SKILL_DELETE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--									@PP_K_SKILL, 
		--									@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR

	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY

				DELETE	SKILL
				WHERE	K_SKILL = @PP_K_SKILL

				IF @@ROWCOUNT = 0
				RAISERROR ('ERROR: No se Elimino el Skill ', 16, 1 ) --MENSAJE - Severity -State.
				--=====================================================	

			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_DL_SKILL // ' + @VP_ERROR_TRANS
			END CATCH
		
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [Borrar] el [SKILL]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#SKI.'+CONVERT(VARCHAR(10),@PP_K_SKILL)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'

		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_SKILL AS CLAVE

	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_SKILL_K_ESTATUS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_SKILL_K_ESTATUS]
GO


CREATE PROCEDURE [dbo].[PG_UP_SKILL_K_ESTATUS]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_SKILL					INT,
	@PP_K_ESTATUS_SKILL			INT
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 
	
	IF @VP_MENSAJE=''
		--EXECUTE [dbo].[PG_RN_SKILL_UPDATE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--									@PP_K_SKILL,
		--									@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR

	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
		
				UPDATE	SKILL
					SET K_ESTATUS_SKILL = @PP_K_ESTATUS_SKILL
				WHERE	K_SKILL=@PP_K_SKILL

				IF @@ROWCOUNT = 0
				RAISERROR ('ERROR: No se Actualizo el Estatus del Skill ', 16, 1 ) --MENSAJE - Severity -State.
				--=====================================================	

			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_DL_SKILL // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible enviar a Actualizar el [SKILL]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#SKI.'+CONVERT(VARCHAR(10),@PP_K_SKILL)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'

		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_SKILL AS CLAVE

	-- //////////////////////////////////////////////////////////////
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
