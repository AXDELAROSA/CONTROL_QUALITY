-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			QA INSPECCION DE MATERIAL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	09/SEP/2020
-- //////////////////////////////////////////////////////////////  

USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT
-- //////////////////////////////////////////////////////////////

--PG_IN_UP_INSPECCION_MATERIAL_ORDEN
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_INVENTARIO_MATERIAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_INVENTARIO_MATERIAL]
GO
/*
 EXECUTE [PG_IN_UP_INSPECCION_MATERIAL_ORDEN] 0,0,    78 , '200435AWT3' , 1 , 2 , '1.1' , '' 
*/
CREATE PROCEDURE [dbo].[PG_IN_INVENTARIO_MATERIAL]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================	
	@PP_K_ITEM							INT,
	@PP_K_INSPECCION_MATERIAL			INT,
	@PP_TIPO_INSPECCION_MATERIAL		INT,
	-- ===========================	
	@PP_RESULTADO_INSPECCION			VARCHAR(255),
	@PP_COMENTARIO						VARCHAR(255)
	-- ============================			
AS			
	
	DECLARE @VP_MENSAJE		VARCHAR(300) = ''
	
	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	
	DECLARE @VP_K_INVENTARIO_MATERIAL	INT = 0
	
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
				-- ///////SE OBTIENE EL ID A INGRESAR///////////////////////////////////////////////////////
				EXECUTE BD_GENERAL.dbo.[PG_SK_CATALOGO_K_MAX_GET] @PP_K_SISTEMA_EXE,
																		'DATA_02Pruebas', 'INVENTARIO_MATERIAL', 'K_INVENTARIO_MATERIAL',
																		@OU_K_TABLA_DISPONIBLE = @VP_K_INSPECCION_MATERIAL_ORDEN	OUTPUT
				-- SELECT * FROM [INVENTARIO_MATERIAL]
				-- ///////SE INSERTA LA INSPECCION DEL MATERIAL///////////////////////////////////////////////////////
				INSERT INTO [INVENTARIO_MATERIAL]
					(	[K_INVENTARIO_MATERIAL],
						-- ===========================
						[K_ORDEN_COMPRA],
						[NUMERO_PARTE],
						[K_INSPECCION_MATERIAL],
						-- ===========================
						[OPCION_SELECCIONADA],
						[COMENTARIO],
						[F_INSPECCION_MATERIAL_ORDEN],
						-- ===========================
						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
				VALUES	
					(	@VP_K_INVENTARIO_MATERIAL,
						-- ===========================	
						@PP_K_ORDEN_COMPRA,
						@PP_NUMERO_PARTE,
						@PP_K_INSPECCION_MATERIAL,
						-- ===========================
						@PP_RESULTADO_INSPECCION,

						@PP_COMENTARIO,
						GETDATE(),
						-- ===========================
						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
						0, NULL, NULL )

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible ingresar el registro en [INVENTARIO_MATERIAL] ', 16, 1 ) --MENSAJE - Severity -State.
					--=====================================================
					
				-- //////////////////////////////////////////////////////////////

			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_INVENTARIO_MATERIAL // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [Crear] el [INVENTARIO_MATERIAL]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#INV.'+CONVERT(VARCHAR(10),@VP_K_INVENTARIO_MATERIAL)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_INSPECCION_MATERIAL_ORDEN AS CLAVE

	-- //////////////////////////////////////////////////////////////

GO

