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

	--SELECT * FROM TIPO_INSPECCION_MATERIAL
	IF @VP_K_TIPO_INSPECCION_MATERIAL = 1
		BEGIN
			SELECT	
					INSPECCION_MATERIAL.*,
					INSPECCION_OPCION_MULTIPLE.*,
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
 EXEC	[dbo].[PG_SK_INSPECCION_MATERIAL_X_NUMERO_PARTE] 0,0, 1
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
/*
 EXECUTE [PG_IN_INSPECCION_MATERIAL] 0,0,  'FDNPDX9' , 1 , 'El numero de parte corresponde al de la factura?' , 
											0.00 , 'Si' , 20.00 , 'No' , 0.00 , '' , 0.00 , '' , 0.00 , '' , 0.00 
*/
CREATE PROCEDURE [dbo].[PG_IN_INSPECCION_MATERIAL]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================	
	@PP_NUMERO_PARTE					VARCHAR(100),
	@PP_K_TIPO_INSPECCION_MATERIAL		INT,
	-- ===========================	
	@PP_INSPECCION						VARCHAR(255),
	@PP_INSPECCION_PORCENTAJE			DECIMAL(13,2),
	-- ============================		
	@PP_OPCION_1						VARCHAR(100),
	@PP_OPCION_1_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_2						VARCHAR(100),
	@PP_OPCION_2_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_3						VARCHAR(100),
	@PP_OPCION_3_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_4						VARCHAR(100),
	@PP_OPCION_4_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_5						VARCHAR(100),
	@PP_OPCION_5_PORCENTAJE				DECIMAL(13,2)
AS			
	
	DECLARE @VP_MENSAJE		VARCHAR(300) = ''
	
		-- SELECT * FROM [INSPECCION_OPCION_MULTIPLE]
			-- SELECT * FROM [INSPECCION_MATERIAL]
	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	
	DECLARE @VP_K_INSPECCION_MATERIAL	INT = 0
	
	IF @VP_MENSAJE=''	
		EXECUTE [dbo].[PG_RN_INSPECCION_MATERIAL_INSERT]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_INSPECCION_PORCENTAJE, @PP_OPCION_1_PORCENTAJE,
															@PP_OPCION_2_PORCENTAJE, @PP_OPCION_3_PORCENTAJE,
															@PP_OPCION_4_PORCENTAJE, @PP_OPCION_5_PORCENTAJE,
															@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

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
						[INSPECCION_PORCENTAJE],
						[F_INSPECCION_MATERIAL],
						-- ===========================
						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
				VALUES	
					(	@VP_K_INSPECCION_MATERIAL,
						-- ===========================	
						@PP_K_TIPO_INSPECCION_MATERIAL,
						1, -- ACTIVA
						@PP_NUMERO_PARTE,
						-- ===========================
						@PP_INSPECCION,
						@PP_INSPECCION_PORCENTAJE,
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
								[OPCION_1_PORCENTAJE],
								[OPCION_2],
								[OPCION_2_PORCENTAJE],
								[OPCION_3],
								[OPCION_3_PORCENTAJE],
								[OPCION_4],
								[OPCION_4_PORCENTAJE],
								[OPCION_5],	
								[OPCION_5_PORCENTAJE]	)
								-- ===========================
						VALUES	
							(	@VP_K_INSPECCION_OPCION_MULTIPLE,
								@VP_K_INSPECCION_MATERIAL,
								-- ===========================	
								@PP_OPCION_1,
								@PP_OPCION_1_PORCENTAJE,
								@PP_OPCION_2,
								@PP_OPCION_2_PORCENTAJE,
								@PP_OPCION_3,
								@PP_OPCION_3_PORCENTAJE,
								@PP_OPCION_4,
								@PP_OPCION_4_PORCENTAJE,
								@PP_OPCION_5,
								@PP_OPCION_5_PORCENTAJE	)
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
	-- ===========================	
	@PP_INSPECCION						VARCHAR(255),
	@PP_INSPECCION_PORCENTAJE			DECIMAL(13,2),
	-- ============================		
	@PP_OPCION_1						VARCHAR(100),
	@PP_OPCION_1_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_2						VARCHAR(100),
	@PP_OPCION_2_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_3						VARCHAR(100),
	@PP_OPCION_3_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_4						VARCHAR(100),
	@PP_OPCION_4_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_5						VARCHAR(100),
	@PP_OPCION_5_PORCENTAJE				DECIMAL(13,2)
	-- ============================		
AS			

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	
	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_INSPECCION_MATERIAL_UPDATE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_INSPECCION_PORCENTAJE, @PP_OPCION_1_PORCENTAJE,
															@PP_OPCION_2_PORCENTAJE, @PP_OPCION_3_PORCENTAJE,
															@PP_OPCION_4_PORCENTAJE, @PP_OPCION_5_PORCENTAJE,
															@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				-- ///////SE ACTUALIZA LA INSPECCION DEL MATERIAL///////////////////////////////////////////////////////
				UPDATE	INSPECCION_MATERIAL
					SET			
						[NUMERO_PARTE]						= @PP_NUMERO_PARTE,
						-- ===========================
						[INSPECCION]						= @PP_INSPECCION, 
						[INSPECCION_PORCENTAJE]			= @PP_INSPECCION_PORCENTAJE, 
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
							[OPCION_1]				= @PP_OPCION_1,
							[OPCION_1_PORCENTAJE]	= @PP_OPCION_1_PORCENTAJE,
							[OPCION_2]				= @PP_OPCION_2,
							[OPCION_2_PORCENTAJE]	= @PP_OPCION_2_PORCENTAJE,
							[OPCION_3]				= @PP_OPCION_3,
							[OPCION_3_PORCENTAJE]	= @PP_OPCION_3_PORCENTAJE,
							[OPCION_4]				= @PP_OPCION_4,
							[OPCION_4_PORCENTAJE]	= @PP_OPCION_4_PORCENTAJE,
							[OPCION_5]				= @PP_OPCION_5,
							[OPCION_5_PORCENTAJE]	= @PP_OPCION_5_PORCENTAJE	
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



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
