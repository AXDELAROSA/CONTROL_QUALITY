-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[PPMS_PEARL]
-- // MODULO:			QC RECHAZOS
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	01/DIC/2021
-- //////////////////////////////////////////////////////////////  

USE [PPMS_PEARL]
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_RECHAZO_X_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_RECHAZO_X_ORDEN]
GO

/*
 EXEC	[dbo].[PG_LI_RECHAZO_X_ORDEN] 0,144,  '40572'
*/

CREATE PROCEDURE [dbo].[PG_LI_RECHAZO_X_ORDEN]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_ORDEN						VARCHAR(50)
AS

	-- ///////////////////////////////////////////
	SELECT	ID,
			LTRIM(RTRIM(ORDEN)) AS ORDEN,
			LTRIM(RTRIM([STATUS])) AS ESTATUS,
			LTRIM(RTRIM(MESA)) AS MESA,
			ISNULL(noserie, 0) AS SERIAL,
			LTRIM(RTRIM(noparte)) AS CUS_PART_NO,
			ISNULL(PATRON, '') AS PATRON,
			LTRIM(RTRIM(Rechazos.DEFECTO)) AS DEFECTO,
			ISNULL(LTRIM(RTRIM(TIPODEF)), 'N/E') AS TIPO_DEFECTO,
			( CASE WHEN	Rechazos.TURNO = 1 THEN 'Turno 1'
					WHEN	Rechazos.TURNO = 2 THEN 'Turno 2'
					ELSE	'Turno 3' END ) AS TURNO,
			ISNULL(ESTACION, '') AS ESTACION,
			LTRIM(RTRIM(inspprod)) AS S_INSP_PROD,
			LTRIM(RTRIM(INSPQC)) AS SELLO_INSP_CAL,
			ISNULL(LTRIM(RTRIM(INSPECTOR_CAL)), 'N/A') AS INSP_CALIDAD,
			LTRIM(RTRIM(JEFE_GRUPO)) AS JEFE_GRUPO,
			LTRIM(RTRIM(FISICA)) AS FISICA,
			LTRIM(RTRIM(perfora)) AS PERFORACION,
			LTRIM(RTRIM(QUILTY)) AS QUILTY,
			ISNULL(D_USUARIO_PEARL, '') AS D_USUARIO,
			[DATA_02].[dbo].[CONVERT_INT_TO_DATE](fecha)	AS FECHA,
			CONVERT(VARCHAR(8),[DATA_02].[dbo].[CONVERT_INT_TO_TIME](hora))		AS HORA
	FROM [PPMS_PEARL].[dbo].Rechazos  (NOLOCK)
	LEFT JOIN [PPMS_PEARL].[dbo].personal (NOLOCK) ON SELLO = INSPQC
	LEFT JOIN [BD_GENERAL].[dbo].USUARIO_PEARL (NOLOCK) ON K_USUARIO_PEARL = aceptado_por
	LEFT JOIN [PPMS_PEARL].[dbo].DEF ON Rechazos.DEFECTO = clave
	WHERE ORDEN = @PP_ORDEN
	ORDER BY noparte, DEFECTO
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / UPDATE
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_RECHAZOS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_UP_RECHAZOS]
GO
/*
	EXEC  [dbo].[PG_IN_UP_RECHAZOS] 0, 0 ,  0 , '43929' , 'Table 01' , '203091ATX7' , '000' , 'S' , 'TEST SISTEMAS' , 'BB' , 2 , 2 , 'M' , 'IT-010'  
*/
CREATE PROCEDURE [dbo].[PG_IN_UP_RECHAZOS]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_ID								INT,
	@PP_ORDEN							VARCHAR(50),
	@PP_MESA							VARCHAR(100),
	@PP_CUS_PART_NO						VARCHAR(100),
	@PP_SELLO_INSP						VARCHAR(20),
	@PP_INICIAL_OPE						VARCHAR(50),
	@PP_JEFE_GRUPO						VARCHAR(100),
	@PP_DEFECTO							VARCHAR(20),
	@PP_CANTIDAD						INT,
	@PP_TURNO							INT,
	@PP_ESTATUS							VARCHAR(20),	
	@PP_ESTACION						VARCHAR(100),
	@PP_USER							VARCHAR(100)
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

	-- ////////RN VALIDACIONES///////////////////////////////////////////////////////
	IF @PP_ID > 0
		BEGIN
			DECLARE @VP_LIBERADO INT = 0
			SELECT @VP_LIBERADO = COUNT(ID)
			FROM [PPMS_PEARL].[dbo].rechazos (NOLOCK)
			WHERE id = @PP_ID
			AND [Status] = 'L'

			IF @VP_LIBERADO IS NULL
				SET @VP_LIBERADO = 0

			IF @VP_LIBERADO > 0
				SET @VP_MENSAJE = 'El rechazo que intenta modificar ya esta liberado.'
		END
	ELSE
		BEGIN
			IF @PP_CANTIDAD = 0
				SET @VP_MENSAJE = 'La cantidad de rechazos no puede ser 0!' 

			IF @VP_MENSAJE = ''
				IF @PP_CANTIDAD > 4
					SET @VP_MENSAJE = 'La cantidad de rechazos no puede ser mayor a 4!' 
		END
	
	IF	@VP_MENSAJE=''
		BEGIN
			DECLARE @VP_N_SELLO INT = 0
			SELECT	@VP_N_SELLO = COUNT(noreloj)
			FROM [PPMS_PEARL].[dbo].[personal] (NOLOCK)
			WHERE sello = @PP_SELLO_INSP
			
			IF @VP_N_SELLO IS NULL OR @VP_N_SELLO = 0
				 SET @VP_MENSAJE = 'El sello no existe!' 
		END

	IF @VP_MENSAJE=''
		EXECUTE [DATA_02].[dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_ORDEN,
																		@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
		
	IF @VP_MENSAJE=''
		EXECUTE [DATA_02].[dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_ESTATUS]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_ORDEN,
																		@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- ////////SI PASA LAS VALIDACIONES SE ABRE LA TRANSACCION///////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				-- ////////SE DECLARAN VARIABLES A USARSE///////////////////////////////////////////////////////				
				DECLARE @VP_FECHA DATE = GETDATE()
				DECLARE @VP_HORA INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
				DECLARE @VP_MOVIMIENTO VARCHAR(10) = 'ADD', @VP_CANT VARCHAR(10) = CONVERT(VARCHAR(10), @PP_CANTIDAD);

				-- ////////SE OBTINE EL TURNO EN BASE A LA HORA DEL GUARDADO DE LA INFORMACION///////////////////////////////////////////////////////
				IF @VP_HORA > 000000 AND @VP_HORA < 60001
					SET @VP_FECHA =  DATEADD(DAY, -1, @VP_FECHA)

					DECLARE @VP_FECHA_INT INT = DATA_02.[dbo].[CONVERT_DATE_TO_INT](@VP_FECHA, 'yyyyMMdd');

				-- ////////SE ACTUALIZA/GUARDA LA INFORMACION EN Rechazos///////////////////////////////////////////////////////
				IF @PP_ID = 0
					BEGIN
						WHILE  @PP_CANTIDAD > 0
							BEGIN
								SET @PP_CANTIDAD = @PP_CANTIDAD - 1
								INSERT INTO Rechazos(	orden, mesa, turno, defecto, inspprod, inspqc, fecha, 
														[status], hora, jefe_grupo, fisica, noparte, perfora,quilty, estacion, aceptado_por
													) 
												VALUES(	@PP_ORDEN, @PP_MESA, @PP_TURNO, @PP_DEFECTO, UPPER(@PP_INICIAL_OPE), @PP_SELLO_INSP, @VP_FECHA_INT,
														@PP_ESTATUS, @VP_HORA, @PP_JEFE_GRUPO, 'SI', @PP_CUS_PART_NO, 'NO', 'NO', @PP_ESTACION, @PP_K_USUARIO_ACCION )
								
								IF @@ROWCOUNT = 0
									RAISERROR ('ERROR: No fue posible Guardar los datos en [Rechazos] ', 16, 1 ) --MENSAJE - Severity -State.
							END
					END
				ELSE
					BEGIN
						UPDATE Rechazos 
							SET turno= @PP_TURNO, 
								defecto = @PP_DEFECTO, 
								inspprod =	UPPER(@PP_INICIAL_OPE), 
								fecha=	@VP_FECHA_INT, 
								hora = @VP_HORA, 
								jefe_grupo = UPPER(@PP_JEFE_GRUPO), 
								noparte = @PP_CUS_PART_NO,
								estacion = @PP_ESTACION,
								aceptado_por = @PP_K_USUARIO_ACCION
						WHERE id = @PP_ID

						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible Actualizar los datos en [Rechazos] ', 16, 1 ) --MENSAJE - Severity -State.

						SET @VP_MOVIMIENTO = 'UP'
					END

					-- ////////SE GUARDA EL LOG///////////////////////////////////////////////////////		
				DECLARE @VP_DETALLE VARCHAR(255) = '# PARTE: '	+ @PP_CUS_PART_NO + ' DEFECTO: ' + @PP_DEFECTO + ' Cant: ' + @VP_CANT + ' INICIAL OPE: ' + @PP_INICIAL_OPE

				IF @VP_MOVIMIENTO = 'UP'
					SET @VP_DETALLE = '# PARTE: '	+ @PP_CUS_PART_NO + ' DEFECTO: ' + @PP_DEFECTO + ' INICIAL OPE: ' + @PP_INICIAL_OPE

				EXECUTE DATA_02.[dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_USER, @PP_ESTACION, 'RECHAZOS',
															@PP_ORDEN, @VP_MOVIMIENTO, @VP_DETALLE, @PP_SELLO_INSP

			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_UP_RECHAZOS // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [GUARDAR] el rechazo: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#Rec.'+CONVERT(VARCHAR(10),@PP_ID)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_ID AS CLAVE

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / UPDATE
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_RECHAZOS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_RECHAZOS]
GO
/*
	EXEC  [dbo].[PG_DL_RECHAZOS] 0, 0 ,  2107500 , '43929' , '203091ATX7' , '048' , 'S' , 'BB' , 1 , 'IT-010' , 'franciscoe' 
*/
CREATE PROCEDURE [dbo].[PG_DL_RECHAZOS]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_ID								INT,
	@PP_ORDEN							VARCHAR(50),
	@PP_CUS_PART_NO						VARCHAR(100),
	@PP_SELLO_INSP						VARCHAR(20),
	@PP_INICIAL_OPE						VARCHAR(50),
	@PP_DEFECTO							VARCHAR(20),
	@PP_CANTIDAD						INT,
	@PP_ESTACION						VARCHAR(100),
	@PP_USER							VARCHAR(100)
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

	-- ////////RN VALIDACIONES///////////////////////////////////////////////////////
	DECLARE @VP_LIBERADO INT = 0
	SELECT @VP_LIBERADO = COUNT(ID)
	FROM [PPMS_PEARL].[dbo].rechazos (NOLOCK)
	WHERE id = @PP_ID
	AND [Status] = 'L'

	IF @VP_LIBERADO IS NULL
		SET @VP_LIBERADO = 0

	IF @VP_LIBERADO > 0
		SET @VP_MENSAJE = 'El rechazo que intenta Eliminar ya esta liberado.'
	
	IF @VP_MENSAJE=''
		EXECUTE [DATA_02].[dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_ORDEN,
																		@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
		
	IF @VP_MENSAJE=''
		EXECUTE [DATA_02].[dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_ESTATUS]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_ORDEN,
																		@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- ////////SI PASA LAS VALIDACIONES SE ABRE LA TRANSACCION///////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				-- ////////SE ELIMINA EL RECHAZO DE [RECHAZOS]///////////////////////////////////////////////////////				
				DELETE RECHAZOS 
				WHERE ID = @PP_ID

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible Eliminar el rechazo en [RECHAZOS] ', 16, 1 ) --MENSAJE - Severity -State.

				-- ////////SE GUARDA EL LOG///////////////////////////////////////////////////////		
				DECLARE @VP_DETALLE VARCHAR(255) = '# PARTE: '	+ @PP_CUS_PART_NO + ' DEFECTO: ' + @PP_DEFECTO + ' INICIAL OPE: ' + @PP_INICIAL_OPE
				EXECUTE DATA_02.[dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_USER, @PP_ESTACION, 'RECHAZOS',
															@PP_ORDEN, 'DL', @VP_DETALLE, @PP_SELLO_INSP

			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_DL_RECHAZOS // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [ELIMINAR] el rechazo: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#Rec.'+CONVERT(VARCHAR(10),@PP_ID)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_ID AS CLAVE

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / UPDATE
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LIBERAR_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LIBERAR_ORDEN]
GO
/*
	EXEC  [dbo].[PG_LIBERAR_ORDEN] 0, 144 ,  '43909' , 'Table 78' , 1 , 'LAURA LOPEZ LOPEZ' , 'JORGE CESAR BARRIOS SALAS' , 'franciscoe' , 'IT-010' 
*/
CREATE PROCEDURE [dbo].[PG_LIBERAR_ORDEN]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_ORDEN							VARCHAR(50),
	@PP_MESA							VARCHAR(100),
	@PP_TIPO_ORDEN						INT,
	@PP_INSP_CALIDAD					VARCHAR(255),
	@PP_JEFE_GRUPO						VARCHAR(255),
	@PP_USER							VARCHAR(100),
	@PP_ESTACION						VARCHAR(100)
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

	-- ////////RN VALIDACIONES///////////////////////////////////////////////////////
	DECLARE @VP_N_ORDEN_LIBERADA INT = 0
	SELECT @VP_N_ORDEN_LIBERADA = COUNT([K_ORDEN_LIBERADA])
	FROM [PPMS_PEARL].DBO.[ORDEN_LIBERADA] (NOLOCK)
	WHERE ORDEN = @PP_ORDEN

	IF @VP_N_ORDEN_LIBERADA IS NULL
		SET @VP_N_ORDEN_LIBERADA = 0

	IF @VP_N_ORDEN_LIBERADA > 0
		SET @VP_MENSAJE = 'La orden que intenta liberar ya fue liberada anteriormente.'
	
	-- ///////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		EXECUTE [DATA_02].[dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_ORDEN,
																		@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
		
	IF @VP_MENSAJE=''
		EXECUTE [DATA_02].[dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_ESTATUS]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_ORDEN,
																		@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
	
	-- ////////SI LA ORDEN ES RMA NO VALIDA LOS EVENTOS///////////////////////////////////////////////////////
	DECLARE @VP_N_ORDEN_RMA INT = 0
	SELECT	@VP_N_ORDEN_RMA = COUNT(K_DETAILS_RMA)
	FROM	[DATA_02].[dbo].DETAILS_RMA (NOLOCK)
	WHERE	JOBNO	= @PP_ORDEN
	
	IF @VP_N_ORDEN_RMA IS NULL
		SET @VP_N_ORDEN_RMA = 0

	IF ( @VP_MENSAJE = '' AND @VP_N_ORDEN_RMA = 0)
		EXECUTE [PPMS_PEARL].[dbo].[PG_RN_VALIDA_KIT_LIBERADO_X_ORDEN]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_ORDEN,
																		@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- ////////SI PASA LAS VALIDACIONES SE ABRE LA TRANSACCION///////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY				
				-- /////////SE OBTIENEN LOS NUMEROS DE PARTES CON TOTAL DE PATRONES PROGRAMADOS///////////////////////////////////////
				DECLARE @VP_MUESTRA INT = 0
				SELECT	@VP_MUESTRA = SUM(CONVERT(INT, (OriginalQty * imitmidx_sql.CUBE_QTY_PER)))
				FROM DATA_02.DBO.ccjoblin_sql  (NOLOCK)
				INNER JOIN DATA_02.dbo.imitmidx_sql (NOLOCK) ON ccjoblin_sql.item_no = imitmidx_sql.item_no
				WHERE LTRIM(RTRIM(ccjoblin_sql.jobno)) = @PP_ORDEN 
				
				-- ===========================
				IF @VP_MUESTRA IS NULL
					SET @VP_MUESTRA = 0

				-- /////////SE OBTIENEN LOS DEFECTOS DE LA ORDEN///////////////////////////////////////
				DECLARE @VP_CANTIDAD_DEFECTO INT = 0
				SELECT @VP_CANTIDAD_DEFECTO = COUNT(ID) 
				FROM [PPMS_PEARL].[dbo].Rechazos (NOLOCK) 
				WHERE ORDEN = @PP_ORDEN

				-- ===========================
				IF @VP_CANTIDAD_DEFECTO IS NULL
					SET @VP_CANTIDAD_DEFECTO = 0

				-- /////////SE CALCULAN LOS PPMS DE LA ORDEN///////////////////////////////////////
				DECLARE @VP_PPMS INT = 0
				IF @VP_MUESTRA > 0
					SET @VP_PPMS = CONVERT(INT, (CONVERT(DECIMAL(13,2), @VP_CANTIDAD_DEFECTO) / CONVERT(DECIMAL(13,2), @VP_MUESTRA) * 1000000) )
				
				-- /////////SE OBTIENEN LOS DEFECTOS LA ORDEN POR TIPO DE DEFECTO///////////////////////////////////////
				DECLARE @VP_CANTIDAD_DEFECTO_LAMINADO INT = 0, @VP_CANTIDAD_DEFECTO_PERFORADO	INT = 0;
				DECLARE @VP_CANTIDAD_DEFECTO_QUILTY	INT = 0, @VP_CANTIDAD_DEFECTO_SKIVING	INT = 0;

				SELECT @VP_CANTIDAD_DEFECTO_LAMINADO = COUNT(ID)
				FROM [PPMS_PEARL].[dbo].Rechazos (NOLOCK) 
				INNER JOIN [PPMS_PEARL].[dbo].DEF (NOLOCK) ON Rechazos.defecto = clave
				WHERE ORDEN = @PP_ORDEN
				AND tipodef = 'LAMINADO'

				IF @VP_CANTIDAD_DEFECTO_LAMINADO IS NULL
					SET @VP_CANTIDAD_DEFECTO_LAMINADO = 0
				-- ===========================

				SELECT @VP_CANTIDAD_DEFECTO_PERFORADO = COUNT(ID)
				FROM [PPMS_PEARL].[dbo].Rechazos (NOLOCK) 
				INNER JOIN [PPMS_PEARL].[dbo].DEF (NOLOCK) ON Rechazos.defecto = clave
				WHERE ORDEN = @PP_ORDEN
				AND tipodef = 'PERFORADO'

				IF @VP_CANTIDAD_DEFECTO_PERFORADO IS NULL
					SET @VP_CANTIDAD_DEFECTO_PERFORADO = 0
				-- ===========================

				SELECT @VP_CANTIDAD_DEFECTO_QUILTY = COUNT(ID)
				FROM [PPMS_PEARL].[dbo].Rechazos (NOLOCK) 
				INNER JOIN [PPMS_PEARL].[dbo].DEF (NOLOCK) ON Rechazos.defecto = clave
				WHERE ORDEN = @PP_ORDEN
				AND tipodef = 'QUILTY'

				IF @VP_CANTIDAD_DEFECTO_QUILTY IS NULL
					SET @VP_CANTIDAD_DEFECTO_QUILTY = 0
				-- ===========================

				SELECT @VP_CANTIDAD_DEFECTO_SKIVING = COUNT(ID)
				FROM [PPMS_PEARL].[dbo].Rechazos (NOLOCK) 
				INNER JOIN [PPMS_PEARL].[dbo].DEF (NOLOCK) ON Rechazos.defecto = clave
				WHERE ORDEN = @PP_ORDEN
				AND tipodef = 'SKIVING'

				IF @VP_CANTIDAD_DEFECTO_SKIVING IS NULL
					SET @VP_CANTIDAD_DEFECTO_SKIVING = 0
				-- ===========================

				DECLARE @VP_CANTIDAD_DEFECTO_MESA INT = @VP_CANTIDAD_DEFECTO - (@VP_CANTIDAD_DEFECTO_LAMINADO + @VP_CANTIDAD_DEFECTO_PERFORADO + @VP_CANTIDAD_DEFECTO_QUILTY + @VP_CANTIDAD_DEFECTO_SKIVING)

				-- /////////SE INGRESA EL REGISTRO DE LIBERACION DE LA ORDEN///////////////////////////////////////
				INSERT INTO [ORDEN_LIBERADA] (	
												[K_TIPO_ORDEN_LIBERADA],
												-- ====================
												[ORDEN],					
												[MESA],					
												[MUESTRA],				
												[DEFECTOS],				
												[PPMS],	
												-- =========================
												[DEFECTOS_LAMINADO],	
												[DEFECTOS_PERFORADO],		
												[DEFECTOS_QUILTY],			
												[DEFECTOS_SKIVING],			
												[DEFECTOS_MESA],				
												-- =========================																
												[INSPECTOR_CALIDAD],		
												[JEFE_GRUPO],			
												-- ====================
												[F_LIBERACION],			
												-- =============================
												[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
												[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  
											)
									VALUES(	
												@PP_TIPO_ORDEN,
												@PP_ORDEN,
												@PP_MESA,
												@VP_MUESTRA,
												@VP_CANTIDAD_DEFECTO,
												@VP_PPMS,
												-- ===========================
												@VP_CANTIDAD_DEFECTO_LAMINADO, 
												@VP_CANTIDAD_DEFECTO_PERFORADO,
												@VP_CANTIDAD_DEFECTO_QUILTY,
												@VP_CANTIDAD_DEFECTO_SKIVING,
												@VP_CANTIDAD_DEFECTO_MESA,
												-- ===========================
												@PP_INSP_CALIDAD,
												@PP_JEFE_GRUPO,
												-- ===========================
												GETDATE(),
												-- ===========================
												@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
												0, NULL, NULL 
											)
				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible guardar el registro de la orden en [ORDEN_LIBERADA] ', 16, 1 ) --MENSAJE - Severity -State.

				-- /////////SE ACTUALIZAN LOS RECHAZOS DE LA ORDEN A L QUE SIGNIFICA QUE LA ORDEN SE LIBERO///////////////////////////////////////
				UPDATE Rechazos  
					SET [status] = 'L' 
				WHERE Orden = @PP_ORDEN

				-- ////////SE GUARDA EL LOG///////////////////////////////////////////////////////		
				DECLARE @VP_DETALLE VARCHAR(255) = '# INSPECTOR: '	+ @PP_INSP_CALIDAD + ' JEFE DE GRUPO: ' + @PP_JEFE_GRUPO
				EXECUTE DATA_02.[dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_USER, @PP_ESTACION, 'RECHAZOS',
															@PP_ORDEN, 'LIBERAR_ORDEN', @VP_DETALLE, ''

			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_LIBERAR_ORDEN // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [LIBERAR] la orden: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#Ord.'+CONVERT(VARCHAR(10),@PP_ORDEN)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_ORDEN AS CLAVE

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
