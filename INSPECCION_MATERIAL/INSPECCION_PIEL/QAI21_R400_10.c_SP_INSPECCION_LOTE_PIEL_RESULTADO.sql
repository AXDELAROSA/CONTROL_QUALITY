-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			QA INSPECCION DE MATERIAL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	04/SEP/2020
-- //////////////////////////////////////////////////////////////  

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / UPDATE
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_INSPECCION_LOTE_PIEL_MARCA_NATURAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_INSPECCION_LOTE_PIEL_MARCA_NATURAL]
GO

/*
 EXEC  [PG_IN_INSPECCION_LOTE_PIEL_MARCA_NATURAL] 0,144, 5635 , 1191 , 107791 , 200 , 33 , 'CORTADA' , 10.20 
*/

CREATE PROCEDURE [dbo].[PG_IN_INSPECCION_LOTE_PIEL_MARCA_NATURAL]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_LOTE_IMPORTACION				INT,
	@PP_K_ITEM							INT,
	@PP_LOTE							INT,
	@PP_PIEL							INT,
	@PP_K_INSPECCION_MATERIAL			INT,
	@PP_DEFECTO							VARCHAR(255),
	@PP_AREA_PORCENTAJE					DECIMAL(13,2)
AS
	
	DECLARE @VP_MENSAJE	VARCHAR(300) = ''

	BEGIN TRANSACTION 
		BEGIN TRY			
			-- /////// INGRESAN LOS VALORES DE LOS DEFECTOS POR PIEL //////////////////
			INSERT INTO [INSPECCION_LOTE_PIEL_MARCA_NATURAL]	(	[K_IMPORTACION_LOTE_PIEL],		
																	[K_ITEM],						
																	[LOTE],						
																	[PIEL],	
																	[K_INSPECCION_MATERIAL],						
																	[DEFECTO],	
																	[AREA_PORCENTAJE]
																)
														VALUES	(	@PP_K_LOTE_IMPORTACION,
																	@PP_K_ITEM,			
																	@PP_LOTE,
																	@PP_PIEL,
																	@PP_K_INSPECCION_MATERIAL,
																	@PP_DEFECTO,
																	@PP_AREA_PORCENTAJE
																)
			
			IF @@ROWCOUNT = 0
				RAISERROR ('ERROR: No fue posible ingresar el registro en [INSPECCION_LOTE_PIEL_MARCA_NATURAL] ', 16, 1 ) --MENSAJE - Severity -State.

			-- ////SE OBTIENE LA CANTIDAD DE PIELES A INSPECCIONAR POR LOTE//////////////////////////////////////////////
			DECLARE @VP_N_PIEL_A_INSPECCIONAR	INT = 0
			SELECT	@VP_N_PIEL_A_INSPECCIONAR = Sample_size 
			FROM	IncInsp_sql (NOLOCK)
			WHERE	ID = @PP_K_LOTE_IMPORTACION

			IF @VP_N_PIEL_A_INSPECCIONAR IS NULL
				SET @VP_N_PIEL_A_INSPECCIONAR = 0
			
			-- ////SE OBTIENE LA CANTIDAD DE PIELES A INSPECCIONADAS POR LOTE//////////////////////////////////////////////
			DECLARE @VP_N_PIEL_INSPECCIONADA INT = 0
			SELECT	@VP_N_PIEL_INSPECCIONADA = COUNT(DISTINCT PIEL)		
			-- =============================	
			FROM	[INSPECCION_LOTE_PIEL_MARCA_NATURAL] (NOLOCK)
			-- =============================
			WHERE	[K_IMPORTACION_LOTE_PIEL] = @PP_K_LOTE_IMPORTACION
			AND		K_ITEM = @PP_K_ITEM
			AND		LOTE = @PP_LOTE
			AND		[K_INSPECCION_MATERIAL] = @PP_K_INSPECCION_MATERIAL

			IF @VP_N_PIEL_INSPECCIONADA IS NULL
				SET @VP_N_PIEL_INSPECCIONADA = 0

			-- ////SI LA CANTIDAD DE PIELES INSPECCIONADAS ES MAYOR A LA QUE SE REQUIERE INSPECIONAR MUESTRA UN ERROR//////////////////////////////////////////////
			IF @VP_N_PIEL_INSPECCIONADA > @VP_N_PIEL_A_INSPECCIONAR
			RAISERROR ('ERROR: ya se han inspeccionado las pieles requeridas.', 16, 1 ) --MENSAJE - Severity -State.

		COMMIT TRANSACTION 
	END TRY
	
	BEGIN CATCH
		/* Ocurrió un error, deshacemos los cambios*/ 
		ROLLBACK TRANSACTION
		DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
		SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
		SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_INSPECCION_LOTE_PIEL_MARCA_NATURAL // ' + @VP_ERROR_TRANS
	END CATCH
				

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [Guardar] la inspección de Marcas Naturales: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#INSP.'+CONVERT(VARCHAR(10),@PP_K_INSPECCION_MATERIAL)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_INSPECCION_MATERIAL AS CLAVE

	-- //////////////////////////////////////////////////////////////
	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_INSPECCION_LOTE_PIEL_MARCA_NATURAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_INSPECCION_LOTE_PIEL_MARCA_NATURAL]
GO


CREATE PROCEDURE [dbo].[PG_DL_INSPECCION_LOTE_PIEL_MARCA_NATURAL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_INSPECCION_LOTE_PIEL_MARCA_NATURAL	INT
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

				DELETE [INSPECCION_LOTE_PIEL_MARCA_NATURAL]
				WHERE	K_INSPECCION_LOTE_PIEL_MARCA_NATURAL = @PP_K_INSPECCION_LOTE_PIEL_MARCA_NATURAL

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible borrar el registro en [INSPECCION_LOTE_PIEL_MARCA_NATURAL] ', 16, 1 ) --MENSAJE - Severity -State.
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
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#INSP.'+CONVERT(VARCHAR(10),@PP_K_INSPECCION_LOTE_PIEL_MARCA_NATURAL)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'

		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_INSPECCION_LOTE_PIEL_MARCA_NATURAL AS CLAVE

	-- //////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / UPDATE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_UP_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]
GO


CREATE PROCEDURE [dbo].[PG_IN_UP_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_LOTE_IMPORTACION				INT,
	@PP_K_ITEM							INT,
	@PP_LOTE							INT,
	@PP_POSICION_PIEL					INT,
	@PP_PIEL							INT,
	@PP_K_INSPECCION_MATERIAL			INT,
	@PP_PIEL_ZONA						VARCHAR(10),
	@PP_PIEL_DATO_ZONA					DECIMAL(13,2) -- SE OCUPA PARA GROS Y SUAVIDAD
AS

	DECLARE @VP_N_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD INT = 0

	SELECT @VP_N_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD = COUNT([K_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]) 
	FROM [INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]
	WHERE [K_IMPORTACION_LOTE_PIEL] = @PP_K_LOTE_IMPORTACION
	AND K_ITEM = @PP_K_ITEM
	AND LOTE = @PP_LOTE
	AND PIEL = @PP_PIEL
	AND K_INSPECCION_MATERIAL = @PP_K_INSPECCION_MATERIAL
	AND	ZONA = @PP_PIEL_ZONA

	IF @VP_N_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD IS NULL OR @VP_N_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD = 0
		BEGIN
			INSERT INTO [INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]	(	[K_IMPORTACION_LOTE_PIEL],		
																	[K_ITEM],						
																	[LOTE],	
																	[POSICION_PIEL],					
																	[PIEL],							
																	[K_INSPECCION_MATERIAL],			
																	[ZONA],							
																	[VALOR]	
																)
														VALUES	(	@PP_K_LOTE_IMPORTACION,
																	@PP_K_ITEM,			
																	@PP_LOTE,
																	@PP_POSICION_PIEL,
																	@PP_PIEL,
																	@PP_K_INSPECCION_MATERIAL,
																	@PP_PIEL_ZONA,
																	@PP_PIEL_DATO_ZONA
																)
			
			IF @@ROWCOUNT = 0
				RAISERROR ('ERROR: No fue posible ingresar el registro en [INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD] ', 16, 1 ) --MENSAJE - Severity -State.
		END
	ELSE
		BEGIN
			UPDATE [INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]
				SET [VALOR] = @PP_PIEL_DATO_ZONA
			WHERE [K_IMPORTACION_LOTE_PIEL] = @PP_K_LOTE_IMPORTACION
			AND K_ITEM = @PP_K_ITEM
			AND LOTE = @PP_LOTE
			AND PIEL = @PP_PIEL
			AND K_INSPECCION_MATERIAL = @PP_K_INSPECCION_MATERIAL
			AND	ZONA = @PP_PIEL_ZONA 

			IF @@ROWCOUNT = 0
				RAISERROR ('ERROR: No fue posible actualizar la inspección en [INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD] ', 16, 1 ) --MENSAJE - Severity -State.
		END

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / UPDATE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GUARDAR_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GUARDAR_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]
GO
/*
 EXEC  [PG_GUARDAR_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD] 0,144, 5635 , 1191 , 107791 , 20 , 29 , 1.3 , 1.1 , 1.0 , 1.2 , 1.1 , 1.3 , 1.1 , 1.0 
*/

CREATE PROCEDURE [dbo].[PG_GUARDAR_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_LOTE_IMPORTACION				INT,
	@PP_K_ITEM							INT,
	@PP_LOTE							INT,
	@PP_POSICION_PIEL					INT,
	@PP_PIEL							INT,
	@PP_K_INSPECCION_MATERIAL			INT,
	@PP_PIEL_DATO_ZONA_A				DECIMAL(13,2), -- SE OCUPA PARA GROS Y SUAVIDAD
	@PP_PIEL_DATO_ZONA_B				DECIMAL(13,2), -- SE OCUPA PARA GROS Y SUAVIDAD
	@PP_PIEL_DATO_ZONA_C				DECIMAL(13,2), -- SE OCUPA PARA GROS Y SUAVIDAD
	@PP_PIEL_DATO_ZONA_D				DECIMAL(13,2), -- SE OCUPA PARA GROS Y SUAVIDAD
	@PP_PIEL_DATO_ZONA_E				DECIMAL(13,2), -- SE OCUPA PARA GROS Y SUAVIDAD
	@PP_PIEL_DATO_ZONA_F				DECIMAL(13,2), -- SE OCUPA PARA GROS Y SUAVIDAD
	@PP_PIEL_DATO_ZONA_G				DECIMAL(13,2), -- SE OCUPA PARA GROS Y SUAVIDAD
	@PP_PIEL_DATO_ZONA_H				DECIMAL(13,2) -- SE OCUPA PARA GROS Y SUAVIDAD
AS
	
	DECLARE @VP_MENSAJE	VARCHAR(300) = ''
	DECLARE @VP_VALOR_REPETIDO DECIMAL(13,2) = 0
	DECLARE @VP_N_VALOR_REPETIDO INT = 0

	BEGIN TRANSACTION 
		BEGIN TRY			
			-- ///////INGRESAN LOS VALORES DEL GORSS - SUAVIDAD PARA CADA UNA DE LAS ZONAS POR PIEL //////////////////
			EXECUTE [PG_IN_UP_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_K_LOTE_IMPORTACION, @PP_K_ITEM, @PP_LOTE, @PP_POSICION_PIEL,
																	@PP_PIEL, @PP_K_INSPECCION_MATERIAL, 'A', @PP_PIEL_DATO_ZONA_A

			EXECUTE [PG_IN_UP_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_K_LOTE_IMPORTACION, @PP_K_ITEM, @PP_LOTE, @PP_POSICION_PIEL,
																	@PP_PIEL, @PP_K_INSPECCION_MATERIAL, 'B', @PP_PIEL_DATO_ZONA_B

			EXECUTE [PG_IN_UP_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_K_LOTE_IMPORTACION, @PP_K_ITEM, @PP_LOTE, @PP_POSICION_PIEL,
																	@PP_PIEL, @PP_K_INSPECCION_MATERIAL, 'C', @PP_PIEL_DATO_ZONA_C

			EXECUTE [PG_IN_UP_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_K_LOTE_IMPORTACION, @PP_K_ITEM, @PP_LOTE, @PP_POSICION_PIEL,
																	@PP_PIEL, @PP_K_INSPECCION_MATERIAL, 'D', @PP_PIEL_DATO_ZONA_D

			EXECUTE [PG_IN_UP_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_K_LOTE_IMPORTACION, @PP_K_ITEM, @PP_LOTE, @PP_POSICION_PIEL,
																	@PP_PIEL, @PP_K_INSPECCION_MATERIAL, 'E', @PP_PIEL_DATO_ZONA_E

			EXECUTE [PG_IN_UP_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_K_LOTE_IMPORTACION, @PP_K_ITEM, @PP_LOTE, @PP_POSICION_PIEL,
																	@PP_PIEL, @PP_K_INSPECCION_MATERIAL, 'F', @PP_PIEL_DATO_ZONA_F

			EXECUTE [PG_IN_UP_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_K_LOTE_IMPORTACION, @PP_K_ITEM, @PP_LOTE, @PP_POSICION_PIEL,
																	@PP_PIEL, @PP_K_INSPECCION_MATERIAL, 'G', @PP_PIEL_DATO_ZONA_G

			EXECUTE [PG_IN_UP_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_K_LOTE_IMPORTACION, @PP_K_ITEM, @PP_LOTE, @PP_POSICION_PIEL,
																	@PP_PIEL, @PP_K_INSPECCION_MATERIAL, 'H', @PP_PIEL_DATO_ZONA_H

			-- ///////OBTIENE EL VALOR DEL GORSS - SUAVIDAD QUE MAS SE REPITE//////////////////
			SELECT TOP 1 @VP_VALOR_REPETIDO = [VALOR], 
					@VP_N_VALOR_REPETIDO = COUNT(*) 
			FROM INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD 
			WHERE [K_IMPORTACION_LOTE_PIEL] = @PP_K_LOTE_IMPORTACION
			AND K_ITEM = @PP_K_ITEM
			AND LOTE = @PP_LOTE
			AND K_INSPECCION_MATERIAL = @PP_K_INSPECCION_MATERIAL			
			GROUP BY [VALOR]
			ORDER BY COUNT(*) DESC

		COMMIT TRANSACTION 
	END TRY
	
	BEGIN CATCH
		/* Ocurrió un error, deshacemos los cambios*/ 
		ROLLBACK TRANSACTION
		DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
		SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
		SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_GUARDAR_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD // ' + @VP_ERROR_TRANS
	END CATCH
				

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [Guardar] la inspección: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#INSP.'+CONVERT(VARCHAR(10),@PP_K_INSPECCION_MATERIAL)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_VALOR_REPETIDO AS CLAVE

	-- //////////////////////////////////////////////////////////////
	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / UPDATE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_INSPECCION_LOTE_PIEL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_UP_INSPECCION_LOTE_PIEL]
GO


CREATE PROCEDURE [dbo].[PG_IN_UP_INSPECCION_LOTE_PIEL]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_LOTE_IMPORTACION				INT,
	@PP_K_ITEM							INT,
	@PP_LOTE							INT,
	@PP_K_INSPECCION_MATERIAL			INT,
	@PP_RESULTADO_INSPECCION			VARCHAR(255),
	@PP_ACEPTADO						INT,
	@PP_COMENTARIO						VARCHAR(255)
AS

	-- ///////SE VERIFICA SI LA INSPECCION YA FUE REALIZADA//////////////////
	DECLARE @VP_N_INSPECCION_LOTE_PIEL  INT = 0

	SELECT @VP_N_INSPECCION_LOTE_PIEL = COUNT([K_INSPECCION_LOTE_PIEL]) 
	FROM [INSPECCION_LOTE_PIEL]
	WHERE [K_IMPORTACION_LOTE_PIEL] = @PP_K_LOTE_IMPORTACION
	AND K_ITEM = @PP_K_ITEM
	AND LOTE = @PP_LOTE
	AND K_INSPECCION_MATERIAL = @PP_K_INSPECCION_MATERIAL	

	IF @VP_N_INSPECCION_LOTE_PIEL IS NULL OR @VP_N_INSPECCION_LOTE_PIEL = 0
		BEGIN
			-- ///////SE INSERTA LA INSPECCION DEL MATERIAL///////////////////////////////////////////////////////
			INSERT INTO [INSPECCION_LOTE_PIEL]
				(	[K_IMPORTACION_LOTE_PIEL],			
					[K_ITEM],							
					[LOTE],										
					[K_INSPECCION_MATERIAL],				
					[OPCION_SELECCIONADA],				
					[ACEPTADO],							
					-- =================================
					[COMENTARIO],						
					[F_INSPECCION],
					-- ===========================
					[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
					[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
			VALUES	
				(	@PP_K_LOTE_IMPORTACION,
					@PP_K_ITEM,			
					@PP_LOTE,
					@PP_K_INSPECCION_MATERIAL,
					-- ===========================	
					@PP_RESULTADO_INSPECCION,		
					@PP_ACEPTADO,		
					@PP_COMENTARIO,			
					GETDATE(),
					-- ===========================
					@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
					0, NULL, NULL )

			IF @@ROWCOUNT = 0
				RAISERROR ('ERROR: No fue posible ingresar el registro en [INSPECCION_LOTE_PIEL] ', 16, 1 ) --MENSAJE - Severity -State.
		END
	ELSE
		BEGIN
			-- ///////SI ACTUALIZA LA INSPECCION CON ESA INSPECCION EN [INSPECCION_LOTE_PIEL]//////////////////
			UPDATE [INSPECCION_LOTE_PIEL]
				SET	[OPCION_SELECCIONADA]					= @PP_RESULTADO_INSPECCION,
					[COMENTARIO]							= @PP_COMENTARIO,
					[ACEPTADO]								= @PP_ACEPTADO,
					[F_INSPECCION]							= GETDATE(),
					F_CAMBIO								= GETDATE(),
					K_USUARIO_CAMBIO						= @PP_K_USUARIO_ACCION
			WHERE [K_IMPORTACION_LOTE_PIEL] = @PP_K_LOTE_IMPORTACION
			AND K_ITEM = @PP_K_ITEM
			AND LOTE = @PP_LOTE
			AND K_INSPECCION_MATERIAL = @PP_K_INSPECCION_MATERIAL	
			
			IF @@ROWCOUNT = 0
				RAISERROR ('ERROR: No fue posible actualizar la inspección en [INSPECCION_LOTE_PIEL] ', 16, 1 ) --MENSAJE - Severity -State.
		END

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / UPDATE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_INSPECCION_LOTE_PIEL_RESULTADO_LOG]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_INSPECCION_LOTE_PIEL_RESULTADO_LOG]
GO


CREATE PROCEDURE [dbo].[PG_IN_INSPECCION_LOTE_PIEL_RESULTADO_LOG]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@VP_TIPO_INSPECCION_MATERIAL_LOG	INT,
	@PP_K_LOTE_IMPORTACION				INT,
	@PP_K_ITEM							INT,
	@PP_LOTE							INT,
	@PP_K_INSPECCION_MATERIAL			INT,
	@@PP_VALOR_ANTERIOR					VARCHAR(150),
	@PP_VALOR_NUEVO						VARCHAR(150),
	-- ===========================
	@PP_K_USUARIO_AUTORIZACION			INT,
	@PP_COMENTARIO						VARCHAR(255)
AS

	INSERT INTO [INSPECCION_LOTE_PIEL_RESULTADO_LOG]
		(	[K_ESTATUS_INSPECCION_LOTE_PIEL],
			[K_IMPORTACION_LOTE_PIEL],						
			[K_ITEM],												
			[LOTE],											
			[K_INSPECCION_MATERIAL],				
			-- =================================			
			[VALOR_ANTERIOR],								
			[VALOR_NUEVO],									
			-- =================================
			[K_USUARIO_AUTORIZACION],						
			[COMENTARIO],					
			-- ===========================
			[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
			[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
	VALUES	
		(	@VP_TIPO_INSPECCION_MATERIAL_LOG,
			@PP_K_LOTE_IMPORTACION,
			@PP_K_ITEM,			
			@PP_LOTE,
			@PP_K_INSPECCION_MATERIAL,
			-- ===========================	
			@@PP_VALOR_ANTERIOR,		
			@PP_VALOR_NUEVO,		
			-- ===========================	
			@PP_K_USUARIO_AUTORIZACION,
			@PP_COMENTARIO,	
			-- ===========================
			@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
			0, NULL, NULL )

	IF @@ROWCOUNT = 0
		RAISERROR ('ERROR: No fue posible ingresar el registro en [INSPECCION_LOTE_PIEL_RESULTADO_LOG] ', 16, 1 ) --MENSAJE - Severity -State.

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GUARDAR_INSPECCION_LOTE_PIEL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GUARDAR_INSPECCION_LOTE_PIEL]
GO
/*
 EXECUTE [PG_GUARDAR_INSPECCION_LOTE_PIEL] 0,144,  5635 , 1191 , 107791 , 28 , 'Si' , 1 , 'Pruebas para inspeccion de piel' , 4 
*/
CREATE PROCEDURE [dbo].[PG_GUARDAR_INSPECCION_LOTE_PIEL]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================	
	@PP_K_LOTE_IMPORTACION				INT,
	@PP_K_ITEM							INT,
	@PP_LOTE							INT,
	@PP_K_INSPECCION_MATERIAL			INT,
	-- ============================	
	@PP_RESULTADO_INSPECCION			VARCHAR(255),
	@PP_ACEPTADO						INT,
	@PP_COMENTARIO						VARCHAR(255),
	-- ============================	
	@PP_N_INSPECCION_CONFIGURADA		INT
AS			
	
	DECLARE @VP_MENSAJE					VARCHAR(300) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY							
				-- ///////SI OBTIENE EL TIPO DE INSPECCION//////////////////
				DECLARE @VP_K_TIPO_INSPECCION	INT = 0
				
				SELECT	@VP_K_TIPO_INSPECCION = K_TIPO_INSPECCION_MATERIAL 
				FROM	INSPECCION_MATERIAL
				WHERE	K_INSPECCION_MATERIAL = @PP_K_INSPECCION_MATERIAL

				IF @VP_K_TIPO_INSPECCION IS NULL OR @VP_K_TIPO_INSPECCION = 0
					RAISERROR ('ERROR: No fue posible obtener el tipo de la inspección en [INSPECCION_MATERIAL] ', 16, 1 ) --MENSAJE - Severity -State.

				IF @VP_K_TIPO_INSPECCION = 2 --EVALUACION
					BEGIN
						DECLARE @VALOR_MINIMO DECIMAL(13,2) = 0
						DECLARE @VALOR_MAXIMO DECIMAL(13,2) = 0

						SELECT  @VALOR_MINIMO = CONVERT(DECIMAL(13,2),ISNULL(OPCION_1, 0)),
								@VALOR_MAXIMO = CONVERT(DECIMAL(13,2),ISNULL(OPCION_2, 0))
						FROM INSPECCION_OPCION
						WHERE [K_INSPECCION_MATERIAL] = @PP_K_INSPECCION_MATERIAL


						DECLARE @VP_VALOR_INSPECCION_DECIMAL DECIMAL(13,2) = CONVERT(DECIMAL(13,2), @PP_RESULTADO_INSPECCION)

						IF ( @VP_VALOR_INSPECCION_DECIMAL < @VALOR_MINIMO OR @VP_VALOR_INSPECCION_DECIMAL > @VALOR_MAXIMO )
							SET @PP_ACEPTADO = 0
					END	
					
				IF @VP_K_TIPO_INSPECCION = 7 --MARCAS NATURALES
					BEGIN
						-- ///////OBTIENE EL VALOR DEL DEFECTO QUE MAS SE REPITE//////////////////
						DECLARE @VP_VALOR_REPETIDO VARCHAR(255) = ''
						DECLARE @VP_N_VALOR_REPETIDO INT = 0

						SELECT TOP 1 @VP_VALOR_REPETIDO = DEFECTO, 
								@VP_N_VALOR_REPETIDO = COUNT(*) 
						FROM [INSPECCION_LOTE_PIEL_MARCA_NATURAL] 
						WHERE [K_IMPORTACION_LOTE_PIEL] = @PP_K_LOTE_IMPORTACION
						AND K_ITEM = @PP_K_ITEM
						AND LOTE = @PP_LOTE
						AND K_INSPECCION_MATERIAL = @PP_K_INSPECCION_MATERIAL	
						AND DEFECTO <> '( SIN DEFECTO )'		
						GROUP BY DEFECTO
						ORDER BY COUNT(*) DESC

						SET @PP_RESULTADO_INSPECCION = @VP_VALOR_REPETIDO
					END				

				IF @VP_K_TIPO_INSPECCION IN (5, 6) -- #5 GROSS/THICKNESS #6 SUAVIDAD
					BEGIN
						DECLARE @VP_CANTIDAD_MUESTRA INT = 0

						SELECT @VP_CANTIDAD_MUESTRA = sample_size 
						FROM	IncInsp_sql
						WHERE ID = @PP_K_LOTE_IMPORTACION
						AND LTRIM(RTRIM(LOT)) = @PP_LOTE

						IF @VP_CANTIDAD_MUESTRA IS NULL OR @VP_CANTIDAD_MUESTRA = 0
							RAISERROR ('ERROR: No fue posible obtener la cantidad de muestra en [IncInsp_sql] ', 16, 1 ) --MENSAJE - Severity -State.

						DECLARE @VP_N_PIEL_INSPECCIONADA INT = 0
						SELECT	@VP_N_PIEL_INSPECCIONADA = COUNT(DISTINCT(PIEL)) 
						FROM	INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD
						WHERE [K_IMPORTACION_LOTE_PIEL]	= @PP_K_LOTE_IMPORTACION
						AND [K_ITEM] = @PP_K_ITEM						
						AND	[LOTE] = @PP_LOTE							
						AND	[K_INSPECCION_MATERIAL] = @PP_K_INSPECCION_MATERIAL

						IF @VP_N_PIEL_INSPECCIONADA IS NULL
							SET @VP_N_PIEL_INSPECCIONADA = 0

						IF @VP_CANTIDAD_MUESTRA = @VP_N_PIEL_INSPECCIONADA
							BEGIN
								IF @PP_COMENTARIO = ''
									RAISERROR ('ERROR: Debe de Capturar el comentario. ', 16, 1 ) --MENSAJE - Severity -State.

								-- ///////INGRESAN LOS VALORES DE LA INSPECCION //////////////////
								EXECUTE [PG_IN_UP_INSPECCION_LOTE_PIEL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_K_LOTE_IMPORTACION, @PP_K_ITEM, @PP_LOTE,
																			@PP_K_INSPECCION_MATERIAL, @PP_RESULTADO_INSPECCION, 
																			@PP_ACEPTADO, @PP_COMENTARIO
							END
					END
				ELSE
					BEGIN
						-- ///////INGRESAN LOS VALORES DE LA INSPECCION //////////////////
						EXECUTE [PG_IN_UP_INSPECCION_LOTE_PIEL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_K_LOTE_IMPORTACION, @PP_K_ITEM, @PP_LOTE,
																	@PP_K_INSPECCION_MATERIAL, @PP_RESULTADO_INSPECCION, 
																	@PP_ACEPTADO, @PP_COMENTARIO
					END		

				-- ///////SE OBTIENE EL NUMERO DE INSPECCIONES REALIZADAS//////////////////
				DECLARE	@VP_N_INSPECCION_REALIZADA		INT = 0
				SELECT	@VP_N_INSPECCION_REALIZADA = COUNT([K_INSPECCION_LOTE_PIEL])
				FROM	[INSPECCION_LOTE_PIEL]
				WHERE	[K_IMPORTACION_LOTE_PIEL] = @PP_K_LOTE_IMPORTACION
				AND	K_ITEM = @PP_K_ITEM
				AND	LOTE = @PP_LOTE

				IF @VP_N_INSPECCION_REALIZADA IS NULL
					SET @VP_N_INSPECCION_REALIZADA = 0

				-- /////// SI EL NUMERO DE INSPECCIONES CONFIGURADAS SON IGUALES A LAS REALIZADAS SE CIERRA LA INSPECCION DEL MATERIAL//////////////////
				IF @PP_N_INSPECCION_CONFIGURADA = @VP_N_INSPECCION_REALIZADA
					BEGIN
						-- ///////SE OBTIENE EL NUMERO DE INSPECCIONES REALIZADAS//////////////////
						DECLARE	@VP_N_INSPECCION_TERMINADA		INT = 0
						SELECT	@VP_N_INSPECCION_TERMINADA = COUNT([K_INSPECCION_LOTE_PIEL_RESULTADO])
						FROM	[INSPECCION_LOTE_PIEL_RESULTADO]
						WHERE	[K_IMPORTACION_LOTE_PIEL] = @PP_K_LOTE_IMPORTACION
						AND	K_ITEM = @PP_K_ITEM
						AND	LOTE = @PP_LOTE

						IF @VP_N_INSPECCION_TERMINADA IS NULL OR @VP_N_INSPECCION_TERMINADA = 0
							BEGIN
								-- ///////SE INSERTA LA INSPECCION DEL MATERIAL POR DEFAULT SE ACEPTA///////////////////////////////////////////////////////
								INSERT INTO [INSPECCION_LOTE_PIEL_RESULTADO]
									(	[K_IMPORTACION_LOTE_PIEL],			
										[K_ITEM],							
										[LOTE],									
										[K_ESTATUS_INSPECCION_LOTE_PIEL],							
										-- =================================
										[K_USUARIO_ALTA],					
										[F_INSPECCION_LOTE_PIEL_RESULTADO]	
										)
										-- ===========================
								VALUES	
									(	@PP_K_LOTE_IMPORTACION,				
										@PP_K_ITEM,						
										@PP_LOTE,
										2, --@VP_RESULTADO_FINAL,	--#2 EN ESPERA DE SER AUTORIZADO																																			
										@PP_K_USUARIO_ACCION,
										GETDATE()	
									)

								IF @@ROWCOUNT = 0
									RAISERROR ('ERROR: No fue posible ingresar la inspección en [INSPECCION_LOTE_PIEL_RESULTADO] ', 16, 1 ) --MENSAJE - Severity -State.
									--=====================================================

								-- ///////////////////INGRESO EL LOG DEL RESULTADO DE LA INSPECCION DEL MATERIAL #1 INSPECCIONADO//////////////
								EXECUTE [dbo].[PG_IN_INSPECCION_LOTE_PIEL_RESULTADO_LOG]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																							1, @PP_K_LOTE_IMPORTACION, 
																							@PP_K_ITEM, @PP_LOTE, 0, '', '', @PP_K_USUARIO_ACCION, @PP_COMENTARIO
														
								-- //////////////////////SE NOTIFICA A LOS RESPONSABLES DE ATORIZAR LA INSPECCION DE LOTE MQU///////////////////////
								DECLARE @VP_COLOR VARCHAR(50) = ''
								DECLARE @VP_CANTIDAD_PIEL INT = 0

								SELECT	@VP_COLOR = LTRIM(RTRIM([DESCRIPTION])),
										@VP_CANTIDAD_PIEL = Lot_size
								FROM	IncInsp_sql
								WHERE ID = @PP_K_LOTE_IMPORTACION
								AND LTRIM(RTRIM(LOT)) = @PP_LOTE

								IF @VP_COLOR IS NULL 
									RAISERROR ('ERROR: No fue posible obtener el color de [IncInsp_sql] ', 16, 1 ) --MENSAJE - Severity -State.

								EXECUTE [dbo].[PG_CONFIGURAR_CORREO_LOTE_INSPECCIONADO_REVISION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																									@PP_K_LOTE_IMPORTACION, @PP_LOTE, @VP_COLOR, @VP_CANTIDAD_PIEL
							END
						ELSE
							BEGIN
								UPDATE [INSPECCION_LOTE_PIEL_RESULTADO]
									SET [K_USUARIO_ALTA] = @PP_K_USUARIO_ACCION,					
										[F_INSPECCION_LOTE_PIEL_RESULTADO]	= GETDATE()
								WHERE	[K_IMPORTACION_LOTE_PIEL] = @PP_K_LOTE_IMPORTACION
								AND	K_ITEM = @PP_K_ITEM
								AND	LOTE = @PP_LOTE

								IF @@ROWCOUNT = 0
									RAISERROR ('ERROR: No fue posible Actualizar la inspección en [INSPECCION_LOTE_PIEL_RESULTADO] ', 16, 1 ) --MENSAJE - Severity -State.

								-- ///////////////////INGRESO EL LOG DEL RESULTADO DE LA INSPECCION DEL MATERIAL #5 MODIFICACION INSPECCION MANUAL//////////////
								EXECUTE [dbo].[PG_IN_INSPECCION_LOTE_PIEL_RESULTADO_LOG]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																							5, @PP_K_LOTE_IMPORTACION, 
																							@PP_K_ITEM, @PP_LOTE, @PP_K_INSPECCION_MATERIAL, '', '', @PP_K_USUARIO_ACCION, @PP_COMENTARIO
	
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
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_GUARDAR_INSPECCION_LOTE_PIEL // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [Guardar] la inspección: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#INSP.'+CONVERT(VARCHAR(10),@PP_K_INSPECCION_MATERIAL)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_INSPECCION_MATERIAL AS CLAVE

	-- //////////////////////////////////////////////////////////////

GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_AUTORIZAR_INSPECCION_LOTE_PIEL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_AUTORIZAR_INSPECCION_LOTE_PIEL]
GO
/*
 EXECUTE [PG_AUTORIZAR_INSPECCION_LOTE_PIEL] 0,144,  5635 , 1191 , 107791 , 28 , 'Si' , 1 , 'Pruebas para inspeccion de piel' , 4 
*/
CREATE PROCEDURE [dbo].[PG_AUTORIZAR_INSPECCION_LOTE_PIEL]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================	
	@PP_K_LOTE_IMPORTACION				INT,
	@PP_K_ITEM							INT,
	@PP_LOTE							INT,
	@PP_K_ESTATUS_INSPECCION			INT,
	@PP_COMENTARIO						VARCHAR(255)
	-- ============================	
AS			
	
	DECLARE @VP_MENSAJE					VARCHAR(300) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	DECLARE @VP_N_INSPECCION_ESTATUS INT = 0
	SELECT @VP_N_INSPECCION_ESTATUS = COUNT(K_INSPECCION_LOTE_PIEL_RESULTADO) FROM [INSPECCION_LOTE_PIEL_RESULTADO]
	WHERE [K_IMPORTACION_LOTE_PIEL] = @PP_K_LOTE_IMPORTACION
	AND	[K_ITEM] = @PP_K_ITEM
	AND [LOTE] = @PP_LOTE
	AND K_ESTATUS_INSPECCION_LOTE_PIEL = @PP_K_ESTATUS_INSPECCION

	IF @VP_N_INSPECCION_ESTATUS IS NULL 
		SET @VP_N_INSPECCION_ESTATUS = 0

	IF @VP_N_INSPECCION_ESTATUS > 0
		SET @VP_MENSAJE = 'La Inspeccion ya esta en el estatus seleccionado.'
	
	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY		
				-- ///////SE INSERTA LA INSPECCION DEL MATERIAL POR DEFAULT SE ACEPTA///////////////////////////////////////////////////////
				UPDATE [INSPECCION_LOTE_PIEL_RESULTADO]
						SET [K_ESTATUS_INSPECCION_LOTE_PIEL] = @PP_K_ESTATUS_INSPECCION
				WHERE [K_IMPORTACION_LOTE_PIEL] = @PP_K_LOTE_IMPORTACION
				AND	[K_ITEM] = @PP_K_ITEM
				AND [LOTE] = @PP_LOTE

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible Actualizar la inspección en [INSPECCION_LOTE_PIEL_RESULTADO] ', 16, 1 ) --MENSAJE - Severity -State.
					--=====================================================
 						 
				EXECUTE [dbo].[PG_IN_INSPECCION_LOTE_PIEL_RESULTADO_LOG]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_K_ESTATUS_INSPECCION, @PP_K_LOTE_IMPORTACION, 
																			@PP_K_ITEM, @PP_LOTE, 0, '', '', @PP_K_USUARIO_ACCION, @PP_COMENTARIO
										
				-- ///////SE ACTUALIZA EL REGISTRO DE LA INSPECCION EN IncInsp_sql///////////////////////////////////////////////////////
				DECLARE @VP_ESTATUS VARCHAR(5) = 'C'
				DECLARE @VP_ACCEPTED VARCHAR(5) = 'S'

				IF @PP_K_ESTATUS_INSPECCION = 4 -- RECHAZADO
					BEGIN
						SET @VP_ESTATUS = 'P'
						SET @VP_ACCEPTED = '-'
					END

				-- /////////SE OBTIENE EL VALOR DEL TICKNESS QUE MAS SE REPITIO EN LA INSPECCION/////////////////////////////////////////////////////
				DECLARE @VP_THICKNESS VARCHAR(10) = ''
				SELECT TOP 1	
						@VP_THICKNESS = OPCION_SELECCIONADA
				FROM	INSPECCION_LOTE_PIEL
				INNER JOIN	INSPECCION_MATERIAL ON INSPECCION_LOTE_PIEL.K_INSPECCION_MATERIAL = INSPECCION_MATERIAL.K_INSPECCION_MATERIAL
				WHERE	K_TIPO_INSPECCION_MATERIAL = 5 --GROSS/THICKNESS
				AND	K_ESTATUS_INSPECCION_MATERIAL = 1 -- ACTIVA
				AND [K_IMPORTACION_LOTE_PIEL] = @PP_K_LOTE_IMPORTACION
				AND	INSPECCION_LOTE_PIEL.[K_ITEM] = @PP_K_ITEM
				AND [LOTE] = @PP_LOTE

				-- /////////SE OBTIENE EL VALOR DEL DEFECTO QUE MAS SE REPITIO EN LA INSPECCION/////////////////////////////////////////////////////
				DECLARE @VP_DEFECTO VARCHAR(255) = ''
				SELECT TOP 1	
						@VP_DEFECTO = OPCION_SELECCIONADA
				FROM	INSPECCION_LOTE_PIEL
				INNER JOIN	INSPECCION_MATERIAL ON INSPECCION_LOTE_PIEL.K_INSPECCION_MATERIAL = INSPECCION_MATERIAL.K_INSPECCION_MATERIAL
				WHERE	K_TIPO_INSPECCION_MATERIAL = 7 --MARCAS NATURALES
				AND	K_ESTATUS_INSPECCION_MATERIAL = 1 -- ACTIVA
				AND [K_IMPORTACION_LOTE_PIEL] = @PP_K_LOTE_IMPORTACION
				AND	INSPECCION_LOTE_PIEL.[K_ITEM] = @PP_K_ITEM
				AND [LOTE] = @PP_LOTE

				UPDATE IncInsp_sql
					SET STATUS = @VP_ESTATUS,
						ACCEPTED = @VP_ACCEPTED,
						Thickness = @VP_THICKNESS,
						Defecto = @VP_DEFECTO
				WHERE ID = @PP_K_LOTE_IMPORTACION

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible Actualizar la inspección en [IncInsp_sql] ', 16, 1 ) --MENSAJE - Severity -State.

				-- //////////////////////////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_AUTORIZAR_INSPECCION_LOTE_PIEL // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [Actualizar] la inspección: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#INSP.'+CONVERT(VARCHAR(10),@PP_K_LOTE_IMPORTACION)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_LOTE_IMPORTACION AS CLAVE

	-- //////////////////////////////////////////////////////////////

GO



-- //////////////////////////////////////////////////////////////	
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
