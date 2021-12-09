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
			LTRIM(RTRIM(DEFECTO)) AS DEFECTO,
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
			FROM [PPMS_PEARL].[dbo].rechazos 
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
	FROM [PPMS_PEARL].[dbo].rechazos 
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
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
