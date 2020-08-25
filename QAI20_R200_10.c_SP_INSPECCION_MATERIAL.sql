-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			QA INSPECCION DE MATERIAL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	20/AGO/2020
-- //////////////////////////////////////////////////////////////  

USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_INSPECCION_MATERIAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_INSPECCION_MATERIAL]
GO

/*
 EXEC	[dbo].[PG_LI_INSPECCION_MATERIAL] 0,0, '', -1, -1, '2018-04-03'
*/

CREATE PROCEDURE [dbo].[PG_LI_INSPECCION_MATERIAL]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_BUSCAR							VARCHAR(200),
	-- ===========================
	@PP_K_ESTATUS_INSPECCION_MATERIAL	VARCHAR(100),
	@PP_K_TIPO_INSPECCION_MATERIAL		INT,
	@PP_NUMERO_PARTE					VARCHAR(100)
AS

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	
	-- ///////////////////////////////////////////

	SELECT	
			INSPECCION_MATERIAL.*,
			D_ESTATUS_INSPECCION_MATERIAL, S_ESTATUS_INSPECCION_MATERIAL, 
			D_TIPO_INSPECCION_MATERIAL, S_TIPO_INSPECCION_MATERIAL, 
			K_USUARIO_PEARL AS D_USUARIO_CAMBIO
			-- =============================	
	FROM	INSPECCION_MATERIAL, ESTATUS_INSPECCION_MATERIAL,
			TIPO_INSPECCION_MATERIAL,
			BD_GENERAL.dbo.USUARIO_PEARL
			-- =============================
	WHERE	INSPECCION_MATERIAL.K_ESTATUS_INSPECCION_MATERIAL = ESTATUS_INSPECCION_MATERIAL.K_ESTATUS_INSPECCION_MATERIAL
	AND		INSPECCION_MATERIAL.K_TIPO_INSPECCION_MATERIAL = TIPO_INSPECCION_MATERIAL.K_TIPO_INSPECCION_MATERIAL
	AND		INSPECCION_MATERIAL.K_USUARIO_CAMBIO = BD_GENERAL.dbo.USUARIO_PEARL.K_USUARIO_PEARL
			-- =============================
	AND		(	D_TIPO_INSPECCION_MATERIAL				LIKE '%'+@PP_BUSCAR+'%'
			OR	D_ESTATUS_INSPECCION_MATERIAL			LIKE '%'+@PP_BUSCAR+'%' 
			OR	[INSPECCION]							LIKE '%'+@PP_BUSCAR+'%' )
			-- =============================
	AND		( @PP_K_ESTATUS_INSPECCION_MATERIAL = -1	OR	INSPECCION_MATERIAL.K_ESTATUS_INSPECCION_MATERIAL = @PP_K_ESTATUS_INSPECCION_MATERIAL )
	AND		( @PP_K_TIPO_INSPECCION_MATERIAL = -1		OR	INSPECCION_MATERIAL.K_TIPO_INSPECCION_MATERIAL = @PP_K_TIPO_INSPECCION_MATERIAL )
	AND		( @PP_NUMERO_PARTE = '( TODOS )'			OR	INSPECCION_MATERIAL.NUMERO_PARTE = @PP_NUMERO_PARTE )
	
			-- =============================
	ORDER BY	F_INSPECCION_MATERIAL, NUMERO_PARTE DESC
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_INSPECCION_MATERIAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_INSPECCION_MATERIAL]
GO

/*
 EXEC	[dbo].[PG_SK_INSPECCION_MATERIAL] 0,144,1
*/

CREATE PROCEDURE [dbo].[PG_SK_INSPECCION_MATERIAL]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_INSPECCION_MATERIAL		INT
AS

	DECLARE @VP_MENSAJE						VARCHAR(300) = ''
	DECLARE @VP_K_TIPO_INSPECCION_MATERIAL	INT = 0
	-- ///////////////////////////////////////////

	SELECT	@VP_K_TIPO_INSPECCION_MATERIAL = K_TIPO_INSPECCION_MATERIAL
	FROM	INSPECCION_MATERIAL
	WHERE	K_INSPECCION_MATERIAL = @PP_K_INSPECCION_MATERIAL

	SELECT * FROM TIPO_INSPECCION_MATERIAL
	IF @VP_K_TIPO_INSPECCION_MATERIAL = 1
		BEGIN
			SELECT	
					INSPECCION_MATERIAL.*,
					D_ESTATUS_INSPECCION_MATERIAL, S_ESTATUS_INSPECCION_MATERIAL, 
					D_TIPO_INSPECCION_MATERIAL, S_TIPO_INSPECCION_MATERIAL, 
					K_USUARIO_PEARL AS D_USUARIO_CAMBIO
					-- =============================	
			FROM	INSPECCION_MATERIAL, ESTATUS_INSPECCION_MATERIAL,
					TIPO_INSPECCION_MATERIAL, INSPECCION_OPCION_MULTIPLE,
					BD_GENERAL.dbo.USUARIO_PEARL
					-- =============================
			WHERE	INSPECCION_MATERIAL.K_ESTATUS_INSPECCION_MATERIAL = ESTATUS_INSPECCION_MATERIAL.K_ESTATUS_INSPECCION_MATERIAL
			AND		INSPECCION_MATERIAL.K_TIPO_INSPECCION_MATERIAL = TIPO_INSPECCION_MATERIAL.K_TIPO_INSPECCION_MATERIAL
			AND		INSPECCION_MATERIAL.K_INSPECCION_MATERIAL = INSPECCION_OPCION_MULTIPLE.K_INSPECCION_MATERIAL
			AND		INSPECCION_MATERIAL.K_USUARIO_CAMBIO = BD_GENERAL.dbo.USUARIO_PEARL.K_USUARIO_PEARL
					-- =============================
			AND		INSPECCION_MATERIAL.K_INSPECCION_MATERIAL=@PP_K_INSPECCION_MATERIAL
		END

	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_INSPECCION_MATERIAL_X_NUMERO_PARTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_INSPECCION_MATERIAL_X_NUMERO_PARTE]
GO

/*
SELECT * FROM INSPECCION_MATERIAL
 EXEC	[dbo].[PG_SK_INSPECCION_MATERIAL_X_K_PUESTO_DESCRIPCION] 0,0, 1
*/

CREATE PROCEDURE [dbo].[PG_SK_INSPECCION_MATERIAL_X_NUMERO_PARTE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_NUMERO_PARTE				VARCHAR(100)
AS

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	
	-- ///////////////////////////////////////////

	SELECT	
			INSPECCION_MATERIAL.*,
			D_ESTATUS_INSPECCION_MATERIAL, S_ESTATUS_INSPECCION_MATERIAL, 
			D_TIPO_INSPECCION_MATERIAL, S_TIPO_INSPECCION_MATERIAL, 
			K_USUARIO_PEARL AS D_USUARIO_CAMBIO
			-- =============================	
	FROM	INSPECCION_MATERIAL, ESTATUS_INSPECCION_MATERIAL,
			TIPO_INSPECCION_MATERIAL,
			BD_GENERAL.dbo.USUARIO_PEARL
			-- =============================
	WHERE	INSPECCION_MATERIAL.K_ESTATUS_INSPECCION_MATERIAL = ESTATUS_INSPECCION_MATERIAL.K_ESTATUS_INSPECCION_MATERIAL
	AND		INSPECCION_MATERIAL.K_TIPO_INSPECCION_MATERIAL = TIPO_INSPECCION_MATERIAL.K_TIPO_INSPECCION_MATERIAL
	AND		INSPECCION_MATERIAL.K_USUARIO_CAMBIO = BD_GENERAL.dbo.USUARIO_PEARL.K_USUARIO_PEARL
			-- =============================
	AND		NUMERO_PARTE=@PP_NUMERO_PARTE
	AND		ESTATUS_INSPECCION_MATERIAL.K_ESTATUS_INSPECCION_MATERIAL = 1 -- ACTIVA
	ORDER BY TIPO_INSPECCION_MATERIAL.K_TIPO_INSPECCION_MATERIAL 

	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_INSPECCION_MATERIAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_INSPECCION_MATERIAL]
GO

-- EXECUTE [PG_IN_INSPECCION_MATERIAL] 0,0, 44 , 1 , 0 , 'DESARROLLAR LAS DIFERENTES SOLUCIONES QUE SE NECESITEN EN LA EMPRESA'
CREATE PROCEDURE [dbo].[PG_IN_INSPECCION_MATERIAL]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================	
	@PP_NUMERO_PARTE					VARCHAR(100),
	@PP_K_TIPO_INSPECCION_MATERIAL		INT,
	--@PP_K_ESTATUS_INSPECCION_MATERIAL	INT,
	-- ===========================	
	@PP_INSPECCION						VARCHAR(255),
	-- ============================		
	@PP_OPCION_1						VARCHAR(100),
	@PP_OPCION_2						VARCHAR(100),
	@PP_OPCION_3						VARCHAR(100),
	@PP_OPCION_4						VARCHAR(100),
	@PP_OPCION_5						VARCHAR(100)
AS			
	
	DECLARE @VP_MENSAJE		VARCHAR(300) = ''
	
	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	
	DECLARE @VP_K_INSPECCION_MATERIAL	INT = 0
	
	IF @VP_MENSAJE=''	
		--EXECUTE [dbo].[PG_RN_INSPECCION_MATERIAL_INSERT]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--														@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY

				EXECUTE BD_GENERAL.dbo.[PG_SK_CATALOGO_K_MAX_GET] @PP_K_SISTEMA_EXE,
																		'DATA_02Pruebas', 'INSPECCION_MATERIAL', 'K_INSPECCION_MATERIAL',
																		@OU_K_TABLA_DISPONIBLE = @VP_K_INSPECCION_MATERIAL	OUTPUT
				

				-- ///////SE INSERTA LA INSPECCION DEL MATERIAL///////////////////////////////////////////////////////
				INSERT INTO INSPECCION_MATERIAL
					(	[K_INSPECCION_MATERIAL],
						-- ===========================
						[K_TIPO_INSPECCION_MATERIAL],
						[K_ESTATUS_INSPECCION_MATERIAL],
						[NUMERO_PARTE],
						-- ===========================
						[INSPECCION],
						[F_INSPECCION_MATERIAL],
						-- ===========================
						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
				VALUES	
					(	@VP_K_INSPECCION_MATERIAL,
						-- ===========================	
						@PP_K_TIPO_INSPECCION_MATERIAL,
						--@PP_K_ESTATUS_INSPECCION_MATERIAL,
						1, -- ACTIVA
						@PP_NUMERO_PARTE,
						-- ===========================
						@PP_INSPECCION,
						GETDATE(),
						-- ===========================
						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
						0, NULL, NULL )

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No se ingreso la INSPECCION_MATERIAL ', 16, 1 ) --MENSAJE - Severity -State.
					--=====================================================

				-- /////////////SE INSERTAN LAS OPCIONES/PARAMETROS DEPENDIENDO DEL TIPO DE INSPECCION//////////////////////////////
				IF @PP_K_TIPO_INSPECCION_MATERIAL = 1
					BEGIN
						DECLARE @VP_K_INSPECCION_OPCION_MULTIPLE	INT = 0
						EXECUTE BD_GENERAL.dbo.[PG_SK_CATALOGO_K_MAX_GET] @PP_K_SISTEMA_EXE,
																		'DATA_02Pruebas', 'INSPECCION_OPCION_MULTIPLE', 'K_INSPECCION_OPCION_MULTIPLE',
																		@OU_K_TABLA_DISPONIBLE = @VP_K_INSPECCION_OPCION_MULTIPLE	OUTPUT
				

						-- ///////SE INSERTA LA INSPECCION DEL MATERIAL///////////////////////////////////////////////////////
						INSERT INTO [INSPECCION_OPCION_MULTIPLE]
							(	[K_INSPECCION_OPCION_MULTIPLE],
								[K_INSPECCION_MATERIAL],
								-- ===========================
								[OPCION_1],
								[OPCION_2],
								[OPCION_3],
								[OPCION_4],
								[OPCION_5]	)
								-- ===========================
						VALUES	
							(	@VP_K_INSPECCION_OPCION_MULTIPLE,
								@VP_K_INSPECCION_MATERIAL,
								-- ===========================	
								@PP_OPCION_1,
								@PP_OPCION_2,
								@PP_OPCION_3,
								@PP_OPCION_4,
								@PP_OPCION_5	)
					END
				-- //////////////////////////////////////////////////////////////

			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_INSPECCION_MATERIAL // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [Crear] la [INSPECCION_MATERIAL]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#INSP.'+CONVERT(VARCHAR(10),@VP_K_INSPECCION_MATERIAL)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_INSPECCION_MATERIAL AS CLAVE

	-- //////////////////////////////////////////////////////////////

GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> ACTUALIZAR / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_INSPECCION_MATERIAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_INSPECCION_MATERIAL]
GO

CREATE PROCEDURE [dbo].[PG_UP_INSPECCION_MATERIAL]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_INSPECCION_MATERIAL			INT,
	-- ===========================	
	@PP_NUMERO_PARTE					VARCHAR(100),
	@PP_K_TIPO_INSPECCION_MATERIAL		INT,
	--@PP_K_ESTATUS_INSPECCION_MATERIAL	INT,
	-- ===========================	
	@PP_INSPECCION						VARCHAR(255),
	-- ============================		
	@PP_OPCION_1						VARCHAR(100),
	@PP_OPCION_2						VARCHAR(100),
	@PP_OPCION_3						VARCHAR(100),
	@PP_OPCION_4						VARCHAR(100),
	@PP_OPCION_5						VARCHAR(100)
	-- ============================		
AS			

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	
	IF @VP_MENSAJE=''
		--EXECUTE [dbo].[PG_RN_INSPECCION_MATERIAL_UPDATE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--													@PP_K_INSPECCION_MATERIAL, @PP_NUMERO_PARTE,
		--													@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				-- ///////SE ACTUALIZA LA INSPECCION DEL MATERIAL///////////////////////////////////////////////////////
				UPDATE	INSPECCION_MATERIAL
					SET			
						--[K_TIPO_INSPECCION_MATERIAL]		= @PP_K_TIPO_INSPECCION_MATERIAL,
						--[K_ESTATUS_INSPECCION_MATERIAL]		= @PP_K_ESTATUS_INSPECCION_MATERIAL,
						[NUMERO_PARTE]						= @PP_NUMERO_PARTE,
						-- ===========================
						[INSPECCION]						= @PP_INSPECCION, 
						-- ===========================
					    [F_CAMBIO]							= GETDATE(), 
						[K_USUARIO_CAMBIO]					= @PP_K_USUARIO_ACCION
						-- ===========================
				WHERE	K_INSPECCION_MATERIAL = @PP_K_INSPECCION_MATERIAL

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No se Actualizo la INSPECCION_MATERIAL ', 16, 1 ) --MENSAJE - Severity -State.
				--=====================================================	

				-- /////////////SE ACTUALIZAN LAS OPCIONES/PARAMETROS DEPENDIENDO DEL TIPO DE INSPECCION//////////////////////////////
				-- SELECT * FROM [INSPECCION_OPCION_MULTIPLE]
				IF @PP_K_TIPO_INSPECCION_MATERIAL = 1
					UPDATE	[INSPECCION_OPCION_MULTIPLE]
						SET	
							-- ===========================
							[OPCION_1] = @PP_OPCION_1,
							[OPCION_2] = @PP_OPCION_2,
							[OPCION_3] = @PP_OPCION_3,
							[OPCION_4] = @PP_OPCION_4,
							[OPCION_5] = @PP_OPCION_5	
							-- ===========================
					WHERE	K_INSPECCION_MATERIAL=@PP_K_INSPECCION_MATERIAL

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No se Actualizo la INSPECCION_MATERIAL ', 16, 1 ) --MENSAJE - Severity -State.
				-- //////////////////////////////////////////////////////////////

			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_UP_INSPECCION_MATERIAL // ' + @VP_ERROR_TRANS
			END CATCH
	
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [Actualizar] la [INSPECCION_MATERIAL]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#INSP.'+CONVERT(VARCHAR(10),@PP_K_INSPECCION_MATERIAL)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'

		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_INSPECCION_MATERIAL AS CLAVE

	-- //////////////////////////////////////////////////////////////
	
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_INSPECCION_MATERIAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_INSPECCION_MATERIAL]
GO


CREATE PROCEDURE [dbo].[PG_DL_INSPECCION_MATERIAL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_INSPECCION_MATERIAL	INT,
	@PP_NUMERO_PARTE			VARCHAR(100)
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

				UPDATE INSPECCION_MATERIAL
					SET K_ESTATUS_INSPECCION_MATERIAL = 0
				WHERE	K_INSPECCION_MATERIAL = @PP_K_INSPECCION_MATERIAL
				AND		NUMERO_PARTE = @PP_NUMERO_PARTE

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No se Elimino el INSPECCION_MATERIAL ', 16, 1 ) --MENSAJE - Severity -State.
				-- //////////////////////////////////////////////////////////////

				--DELETE	INSPECCION_MATERIAL
				--WHERE	K_INSPECCION_MATERIAL = @PP_K_INSPECCION_MATERIAL
				--AND		NUMERO_PARTE = @PP_NUMERO_PARTE

				--IF @@ROWCOUNT = 0
				--	RAISERROR ('ERROR: No se Elimino el INSPECCION_MATERIAL ', 16, 1 ) --MENSAJE - Severity -State.
				-- //////////////////////////////////////////////////////////////

				--DECLARE @VP_N_OPCION_MULTILPE INT = 0
				--SELECT	@VP_N_OPCION_MULTILPE = [K_INSPECCION_OPCION_MULTIPLE]
				--FROM	[INSPECCION_OPCION_MULTIPLE]
				--WHERE	K_INSPECCION_MATERIAL = @PP_K_INSPECCION_MATERIAL

				--IF @VP_N_OPCION_MULTILPE IS NULL
				--	SET @VP_N_OPCION_MULTILPE = 0

				--IF @VP_N_OPCION_MULTILPE > 0
				--	BEGIN
				--		DELETE	[INSPECCION_OPCION_MULTIPLE]
				--		WHERE	K_INSPECCION_MATERIAL = @PP_K_INSPECCION_MATERIAL

				--		IF @@ROWCOUNT = 0
				--			RAISERROR ('ERROR: No se Elimino la INSPECCION_MATERIAL en [INSPECCION_OPCION_MULTIPLE]', 16, 1 ) --MENSAJE - Severity -State.
				--	END
				---- //////////////////////////////////////////////////////////////

				--DECLARE @VP_N_OPCION_CALCULO INT = 0
				--SELECT	@VP_N_OPCION_CALCULO = [K_INSPECCION_OPCION_CALCULO]
				--FROM	[INSPECCION_OPCION_CALCULO]
				--WHERE	K_INSPECCION_MATERIAL = @PP_K_INSPECCION_MATERIAL

				--IF @VP_N_OPCION_CALCULO IS NULL
				--	SET @VP_N_OPCION_CALCULO = 0

				--IF @VP_N_OPCION_CALCULO > 0
				--	BEGIN
				--		DELETE	[INSPECCION_OPCION_CALCULO]
				--		WHERE	K_INSPECCION_MATERIAL = @PP_K_INSPECCION_MATERIAL

				--		IF @@ROWCOUNT = 0
				--			RAISERROR ('ERROR: No se Elimino la INSPECCION_MATERIAL en [INSPECCION_OPCION_CALCULO]', 16, 1 ) --MENSAJE - Severity -State.
				--	END

			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_DL_INSPECCION_MATERIAL // ' + @VP_ERROR_TRANS
			END CATCH
		
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [Borrar] la [INSPECCION_MATERIAL]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#INSP.'+CONVERT(VARCHAR(10),@PP_K_INSPECCION_MATERIAL)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'

		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_INSPECCION_MATERIAL AS CLAVE

	-- //////////////////////////////////////////////////////////////
GO





---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> INSERT X DESCRIPCION DE PUESTO EXISTENTE PARA CLONAR UNA INSPECCION DE YA EXISTENTE
---- //////////////////////////////////////////////////////////////


--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_INSPECCION_MATERIAL_X_PUESTO_DESCRIPCION_EXISTENTE]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_IN_INSPECCION_MATERIAL_X_PUESTO_DESCRIPCION_EXISTENTE]
--GO

---- EXECUTE [PG_IN_INSPECCION_MATERIAL] 0,0, 44 , 1 , 0 , 'DESARROLLAR LAS DIFERENTES SOLUCIONES QUE SE NECESITEN EN LA EMPRESA'
--CREATE PROCEDURE [dbo].[PG_IN_INSPECCION_MATERIAL_X_PUESTO_DESCRIPCION_EXISTENTE]
--	@PP_K_SISTEMA_EXE				INT,
--	@PP_K_USUARIO_ACCION			INT,
--	-- ===========================	
--	@PP_K_PUESTO_DESCRIPCION		INT,
--	@PP_K_PUESTO_DESCRIPCION_CLONAR	INT
--	-- ============================		
--AS			
	
--	DECLARE @VP_MENSAJE		VARCHAR(300) = ''
	
--	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	
--	DECLARE @VP_K_INSPECCION_MATERIAL	INT = 0
	
--	IF @VP_MENSAJE=''
--		BEGIN
--			BEGIN TRANSACTION 
--			BEGIN TRY

--				DELETE INSPECCION_MATERIAL
--				WHERE K_PUESTO_DESCRIPCION = @PP_K_PUESTO_DESCRIPCION

--				DECLARE @VP_K_TIPO_INSPECCION_MATERIAL	INT
--				DECLARE @VP_REQUERIMIENTO	VARCHAR(MAX)

--				DECLARE CU_INSPECCION_MATERIAL_X_PUESTO_DESCRIPCION CURSOR 
--				FOR SELECT	K_TIPO_INSPECCION_MATERIAL, REQUERIMIENTO 
--					FROM	INSPECCION_MATERIAL
--					WHERE	K_PUESTO_DESCRIPCION = @PP_K_PUESTO_DESCRIPCION_CLONAR
				
--				OPEN CU_INSPECCION_MATERIAL_X_PUESTO_DESCRIPCION
--				FETCH NEXT FROM CU_INSPECCION_MATERIAL_X_PUESTO_DESCRIPCION INTO @VP_K_TIPO_INSPECCION_MATERIAL, @VP_REQUERIMIENTO
				
--				WHILE @@FETCH_STATUS = 0
--					BEGIN

--						EXECUTE BD_GENERAL.dbo.[PG_SK_CATALOGO_K_MAX_GET] @PP_K_SISTEMA_EXE,
--																				'RH', 'INSPECCION_MATERIAL', 'K_INSPECCION_MATERIAL',
--																				@OU_K_TABLA_DISPONIBLE = @VP_K_INSPECCION_MATERIAL	OUTPUT
--						-- ====================================
--						INSERT INTO INSPECCION_MATERIAL
--							(	[K_INSPECCION_MATERIAL],
--								-- ===========================
--								[K_PUESTO_DESCRIPCION], 
--								[K_TIPO_INSPECCION_MATERIAL],
--								[K_ESTATUS_INSPECCION_MATERIAL],
--								-- ===========================
--								[REQUERIMIENTO],
--								[F_ASIGNACION],
--								-- ===========================
--								[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
--								[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
--						VALUES	
--							(	@VP_K_INSPECCION_MATERIAL,
--							-- ===========================	
--								@PP_K_PUESTO_DESCRIPCION,	
--								@VP_K_TIPO_INSPECCION_MATERIAL,
--								0,
--								-- ===========================
--								@VP_REQUERIMIENTO,
--								GETDATE(),
--								-- ===========================
--								@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
--								0, NULL, NULL )

--						FETCH NEXT FROM CU_INSPECCION_MATERIAL_X_PUESTO_DESCRIPCION INTO @VP_K_TIPO_INSPECCION_MATERIAL, @VP_REQUERIMIENTO				
--					END
--				CLOSE CU_INSPECCION_MATERIAL_X_PUESTO_DESCRIPCION
--				DEALLOCATE CU_INSPECCION_MATERIAL_X_PUESTO_DESCRIPCION
--			COMMIT TRANSACTION 
--			END TRY
	
--			BEGIN CATCH
--				/* Ocurrió un error, deshacemos los cambios*/ 
--				ROLLBACK TRANSACTION
--				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
--				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
--				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_INSPECCION_MATERIAL_X_PUESTO_DESCRIPCION_EXISTENTE // ' + @VP_ERROR_TRANS
--			END CATCH
				
--		END

--	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
--	IF @VP_MENSAJE<>''
--		BEGIN
		
--		SET		@VP_MENSAJE = 'No es posible [Crear] el [INSPECCION_MATERIAL]: ' + @VP_MENSAJE 
--		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
--		SET		@VP_MENSAJE = @VP_MENSAJE + '[#DDP.'+CONVERT(VARCHAR(10),@PP_K_PUESTO_DESCRIPCION)+']'
--		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
--		END
	
--	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_PUESTO_DESCRIPCION AS CLAVE

--	-- //////////////////////////////////////////////////////////////

--GO




---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> DELETE / FICHA
---- //////////////////////////////////////////////////////////////

--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_INSPECCION_MATERIAL_K_ESTATUS]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_UP_INSPECCION_MATERIAL_K_ESTATUS]
--GO


--CREATE PROCEDURE [dbo].[PG_UP_INSPECCION_MATERIAL_K_ESTATUS]
--	@PP_K_SISTEMA_EXE			INT,
--	@PP_K_USUARIO_ACCION		INT,
--	-- ===========================
--	@PP_K_INSPECCION_MATERIAL					INT,
--	@PP_K_ESTATUS_INSPECCION_MATERIAL			INT
--AS

--	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

--	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 
	
--	IF @VP_MENSAJE=''
--		--EXECUTE [dbo].[PG_RN_INSPECCION_MATERIAL_UPDATE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
--		--									@PP_K_INSPECCION_MATERIAL,
--		--									@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

--	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR

--	IF @VP_MENSAJE=''
--		BEGIN
--			BEGIN TRANSACTION 
--			BEGIN TRY
		
--				UPDATE	INSPECCION_MATERIAL
--					SET K_ESTATUS_INSPECCION_MATERIAL = @PP_K_ESTATUS_INSPECCION_MATERIAL
--				WHERE	K_INSPECCION_MATERIAL=@PP_K_INSPECCION_MATERIAL

--				IF @@ROWCOUNT = 0
--				RAISERROR ('ERROR: No se Actualizo el Estatus del INSPECCION_MATERIAL ', 16, 1 ) --MENSAJE - Severity -State.
--				--=====================================================	

--			COMMIT TRANSACTION 
--			END TRY
	
--			BEGIN CATCH
--				/* Ocurrió un error, deshacemos los cambios*/ 
--				ROLLBACK TRANSACTION
--				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
--				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
--				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_DL_INSPECCION_MATERIAL // ' + @VP_ERROR_TRANS
--			END CATCH
				
--		END

--	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
--	IF @VP_MENSAJE<>''
--		BEGIN
		
--		SET		@VP_MENSAJE = 'No es posible enviar a Actualizar el [INSPECCION_MATERIAL]: ' + @VP_MENSAJE 
--		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
--		SET		@VP_MENSAJE = @VP_MENSAJE + '[#SKI.'+CONVERT(VARCHAR(10),@PP_K_INSPECCION_MATERIAL)+']'
--		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'

--		END
	
--	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_INSPECCION_MATERIAL AS CLAVE

--	-- //////////////////////////////////////////////////////////////
--GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
