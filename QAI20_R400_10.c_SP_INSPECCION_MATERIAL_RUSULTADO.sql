-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			QA INSPECCION DE MATERIAL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	04/SEP/2020
-- //////////////////////////////////////////////////////////////  

USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_INSPECCION_MATERIAL_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_INSPECCION_MATERIAL_ORDEN]
GO
/*
 EXECUTE [PG_IN_INSPECCION_MATERIAL_ORDEN] 0,0,  'FDNPDX9' , 1 , 'El numero de parte corresponde al de la factura?' , 
											0.00 , 'Si' , 20.00 , 'No' , 0.00 , '' , 0.00 , '' , 0.00 , '' , 0.00 
*/
CREATE PROCEDURE [dbo].[PG_IN_INSPECCION_MATERIAL_ORDEN]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================	
	@PP_K_ORDEN_COMPRA					INT,
	@PP_NUMERO_PARTE					VARCHAR(100),
	@PP_K_INSPECCION_MATERIAL			INT,
	-- ===========================	
	@PP_OPCION_SELECCIONADA				VARCHAR(255),
	@PP_OPCION_PORCENTAJE				DECIMAL(13,2),
	@PP_COMENTARIO						VARCHAR(255),
	-- ============================		
	@PP_PORCENTAJE_APROBATORIO			DECIMAL(13,2),
	@PP_PORCENTAJE_ACUMULADO			DECIMAL(13,2),
	@PP_APROBACION_MANUAL				INT			
AS			
	
	DECLARE @VP_MENSAJE		VARCHAR(300) = ''
	
	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	
	DECLARE @VP_K_INSPECCION_MATERIAL_ORDEN	INT = 0
	
	--IF @VP_MENSAJE=''	
		--EXECUTE [dbo].[PG_RN_INSPECCION_MATERIAL_ORDEN_INSERT]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--													@PP_INSPECCION_PORCENTAJE, @PP_OPCION_1_PORCENTAJE,
		--													@PP_OPCION_2_PORCENTAJE, @PP_OPCION_3_PORCENTAJE,
		--													@PP_OPCION_4_PORCENTAJE, @PP_OPCION_5_PORCENTAJE,
		--													@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
					--  SELECT * FROM [INSPECCION_MATERIAL_ORDEN_RESULTADO]	
					--	SELECT * FROM [INSPECCION_MATERIAL_ORDEN]
				DECLARE @VP_N_INSPECCION_MATERIAL_ORDEN INT = 0

				SELECT	@VP_N_INSPECCION_MATERIAL_ORDEN = COUNT([K_INSPECCION_MATERIAL_ORDEN])
				FROM	INSPECCION_MATERIAL_ORDEN
				WHERE	K_ORDEN_COMPRA = @PP_K_ORDEN_COMPRA
				AND		NUMERO_PARTE = @PP_NUMERO_PARTE
				AND		K_INSPECCION_MATERIAL = @PP_K_INSPECCION_MATERIAL
				
				IF 	@VP_N_INSPECCION_MATERIAL_ORDEN IS NULL
					SET @VP_N_INSPECCION_MATERIAL_ORDEN = 0

				IF @VP_N_INSPECCION_MATERIAL_ORDEN = 0
					BEGIN
						EXECUTE BD_GENERAL.dbo.[PG_SK_CATALOGO_K_MAX_GET] @PP_K_SISTEMA_EXE,
																				'DATA_02Pruebas', 'INSPECCION_MATERIAL_ORDEN', 'K_INSPECCION_MATERIAL_ORDEN',
																				@OU_K_TABLA_DISPONIBLE = @VP_K_INSPECCION_MATERIAL_ORDEN	OUTPUT

						-- ///////SE INSERTA LA INSPECCION DEL MATERIAL///////////////////////////////////////////////////////
						INSERT INTO [INSPECCION_MATERIAL_ORDEN]
							(	[K_INSPECCION_MATERIAL_ORDEN],
								-- ===========================
								[K_ORDEN_COMPRA],
								[NUMERO_PARTE],
								[K_INSPECCION_MATERIAL],
								-- ===========================
								[OPCION_SELECCIONADA],
								[OPCION_PORCENTAJE],
								[COMENTARIO],
								[F_INSPECCION_MATERIAL_ORDEN],
								-- ===========================
								[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
								[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
						VALUES	
							(	@VP_K_INSPECCION_MATERIAL_ORDEN,
								-- ===========================	
								@PP_K_ORDEN_COMPRA,
								@PP_NUMERO_PARTE,
								@PP_K_INSPECCION_MATERIAL,
								-- ===========================
								@PP_OPCION_SELECCIONADA,
								@PP_OPCION_PORCENTAJE,
								@PP_COMENTARIO,
								GETDATE(),
								-- ===========================
								@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
								0, NULL, NULL )

						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible ingresar el registro en [INSPECCION_MATERIAL_ORDEN] ', 16, 1 ) --MENSAJE - Severity -State.
							--=====================================================
					END
				ELSE
					BEGIN
						UPDATE [INSPECCION_MATERIAL_ORDEN]
							SET	[OPCION_SELECCIONADA]			= @PP_OPCION_SELECCIONADA,
								[OPCION_PORCENTAJE]				= @PP_OPCION_PORCENTAJE,
								[COMENTARIO]					= @PP_COMENTARIO,
								[F_INSPECCION_MATERIAL_ORDEN]	= GETDATE()
						WHERE	K_ORDEN_COMPRA = @PP_K_ORDEN_COMPRA
						AND		NUMERO_PARTE = @PP_NUMERO_PARTE
						AND		K_INSPECCION_MATERIAL = @PP_K_INSPECCION_MATERIAL
						
						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible actualizar el registro en [INSPECCION_MATERIAL_ORDEN] ', 16, 1 ) --MENSAJE - Severity -State.

					END

				-- /////////////SE VERIFICA SI LA ORDEN Y EL NUMERO DE PARTE EXISTEN EN INSPECCION_MATERIAL_ORDEN_RESULTADO//////////////////////////////
				DECLARE @VP_APROBACION_SISTEMA INT = 0

				IF @PP_PORCENTAJE_ACUMULADO >= @PP_PORCENTAJE_APROBATORIO
					SET @VP_APROBACION_SISTEMA = 1
				
				--=====================================================
				DECLARE @VP_N_INSPECCION_MATERIAL_ORDEN_RESULTADO INT = 0

				SELECT	@VP_N_INSPECCION_MATERIAL_ORDEN_RESULTADO = COUNT(K_INSPECCION_MATERIAL_ORDEN_RESULTADO)
				FROM	INSPECCION_MATERIAL_ORDEN_RESULTADO
				WHERE	K_ORDEN_COMPRA = @PP_K_ORDEN_COMPRA
				AND		NUMERO_PARTE = @PP_NUMERO_PARTE

				IF @VP_N_INSPECCION_MATERIAL_ORDEN_RESULTADO IS NULL
					SET @VP_N_INSPECCION_MATERIAL_ORDEN_RESULTADO = 0

				--=====================================================
				IF @VP_N_INSPECCION_MATERIAL_ORDEN_RESULTADO = 0
					BEGIN
						DECLARE @VP_K_INSPECCION_MATERIAL_ORDEN_RESULTADO	INT = 0
						EXECUTE BD_GENERAL.dbo.[PG_SK_CATALOGO_K_MAX_GET] @PP_K_SISTEMA_EXE,
																		'DATA_02Pruebas', 'INSPECCION_MATERIAL_ORDEN_RESULTADO', 'K_INSPECCION_MATERIAL_ORDEN_RESULTADO',
																		@OU_K_TABLA_DISPONIBLE = @VP_K_INSPECCION_MATERIAL_ORDEN_RESULTADO	OUTPUT

						-- ///////SE INSERTA LA INSPECCION DEL MATERIAL///////////////////////////////////////////////////////
						INSERT INTO [INSPECCION_MATERIAL_ORDEN_RESULTADO]
							(	[K_INSPECCION_MATERIAL_ORDEN_RESULTADO],
								[K_ORDEN_COMPRA],
								-- ===========================
								[NUMERO_PARTE],
								[PORCENTAJE_APROBATORIO],
								[TOTAL_PORCENTAJE_ACUMULADO],
								[APROBACION_SISTEMA],
								[APROBACION_MANUAL],
								[COMENTARIO],
								[F_INSPECCION_MATERIAL_ORDEN_RESULTADO]	)
								-- ===========================
						VALUES	
							(	@VP_K_INSPECCION_MATERIAL_ORDEN_RESULTADO,
								-- ===========================	
								@PP_K_ORDEN_COMPRA,
								@PP_NUMERO_PARTE,
								-- ===========================	
								@PP_PORCENTAJE_APROBATORIO,
								@PP_PORCENTAJE_ACUMULADO,
								@VP_APROBACION_SISTEMA,
								@PP_APROBACION_MANUAL,
								@PP_COMENTARIO,
								GETDATE()	)

						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible ingresar el registro en [INSPECCION_MATERIAL_ORDEN_RESULTADO] ', 16, 1 ) --MENSAJE - Severity -State.
							--=====================================================
					END
				ELSE
					BEGIN
						UPDATE	[INSPECCION_MATERIAL_ORDEN_RESULTADO]
							SET	[PORCENTAJE_APROBATORIO]					= @PP_PORCENTAJE_APROBATORIO,
								[TOTAL_PORCENTAJE_ACUMULADO]				= @PP_PORCENTAJE_ACUMULADO,
								[APROBACION_SISTEMA]						= @VP_APROBACION_SISTEMA,
								[APROBACION_MANUAL]							= @PP_APROBACION_MANUAL,
								[COMENTARIO]								= @PP_COMENTARIO,
								[F_INSPECCION_MATERIAL_ORDEN_RESULTADO]		= GETDATE()	
						WHERE K_ORDEN_COMPRA = @PP_K_ORDEN_COMPRA
						AND	  NUMERO_PARTE = @PP_NUMERO_PARTE

						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible actualizar el registro en [INSPECCION_MATERIAL_ORDEN_RESULTADO] ', 16, 1 ) --MENSAJE - Severity -State.
					END

				-- //////////////////////////////////////////////////////////////

			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_INSPECCION_MATERIAL_ORDEN // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [Crear] la [INSPECCION_MATERIAL_ORDEN]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#INSP.'+CONVERT(VARCHAR(10),@VP_K_INSPECCION_MATERIAL_ORDEN)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_INSPECCION_MATERIAL_ORDEN AS CLAVE

	-- //////////////////////////////////////////////////////////////

GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
