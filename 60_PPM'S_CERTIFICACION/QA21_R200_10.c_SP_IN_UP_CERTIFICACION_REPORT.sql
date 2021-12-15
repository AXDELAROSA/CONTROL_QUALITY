-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[PPMS_PEARL]
-- // MODULO:			PPM & CERTIFICACION REPORT
-- // OPERACION:		GUARDAR INFORMACION
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	11/OCTUBRE/2021
-- //////////////////////////////////////////////////////////////  

USE [PPMS_PEARL]
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_CERTIFICACION_REPORT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_CERTIFICACION_REPORT]
GO

/*
 EXEC	[dbo].[PG_LI_CERTIFICACION_REPORT] 0,0,  '2021/10/12' 
*/

CREATE PROCEDURE [dbo].[PG_LI_CERTIFICACION_REPORT]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_FECHA							DATE
AS

	-- ////////////////////////////////////////////////
	SELECT [sello_paq] AS SELLO_INSP_MESA
		   ,LTRIM(RTRIM(INSP_MESA.INSPECTOR_CAL)) AS NOMBRE_INSP_MESA
		   ,INSP_MESA.TURNO AS TURNO_INSP_MESA
	      ,LTRIM(RTRIM([no_parte])) AS no_parte
	      ,LTRIM(RTRIM([programa])) AS programa
	      ,LTRIM(RTRIM([orden])) AS ORDEN
	      ,LTRIM(RTRIM([mesa])) AS MESA
	      ,[paquetes]
	      ,[piezas_set]
	      ,LTRIM(RTRIM([defecto1])) AS defecto1
	      ,[cant1]
	      ,LTRIM(RTRIM([defecto2])) AS defecto2
	      ,[cant2]
	      ,LTRIM(RTRIM([defecto3])) AS defecto3
	      ,[cant3]
	      ,CONVERT(DATE, [fecha]) AS FECHA
		  ,INSP_CERTI.SELLO AS SELLO_INSP_CERTI
	      ,LTRIM(RTRIM([insp_certi])) AS NOMBRE_INSP_CERTI
	      ,[certificacion_rpt].[turno] AS TURNO_INSP_CERTI
	      ,[mezclada]
	      ,[extra]
	      ,[total]
	      ,[id]
	      ,LTRIM(RTRIM([noserie_caja])) AS SERIAL
	       ,LTRIM(RTRIM([patron])) AS patron
	      ,[estacion]
	      ,[hora]
	  FROM [PPMS_PEARL].[dbo].[certificacion_rpt]
	  INNER JOIN [PPMS_PEARL].[dbo].personal AS INSP_MESA (NOLOCK) ON INSP_MESA.sello = [sello_paq]
	  INNER JOIN [PPMS_PEARL].[dbo].personal AS INSP_CERTI (NOLOCK) ON INSP_CERTI.INSPECTOR_CAL = insp_certi
	  WHERE CONVERT(DATE, fecha) = @PP_FECHA
	  ORDER BY ID DESC 
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / UPDATE
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_CERTIFICACION_REPORT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_UP_CERTIFICACION_REPORT]
GO
/*
	EXEC  [dbo].[PG_IN_UP_CERTIFICACION_REPORT] 0, 0, 0 , '060' , '174034P' , 'WK JEEP GL DL' , '43789' , 'Table 16' , 1 , 30 , 'CA' , 1 , 'MCZ' , 1 , '( S/D )' , 0 , '2021/10/12' , 'JOVANNA DULCE DE LA LUZ BALCAZAR CRUZ' , '1' , '43789005' , '65426M1' , 'IT-010' 
*/
CREATE PROCEDURE [dbo].[PG_IN_UP_CERTIFICACION_REPORT]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_ID								INT,
	@PP_SELLO_INSP_MESA					VARCHAR(20),
	@PP_CUS_PART_NO						VARCHAR(50),
	@PP_PROGRAMA						VARCHAR(255),
	@PP_ORDEN							VARCHAR(20),
	@PP_MESA							VARCHAR(50),
	@PP_N_PAQUETE						INT,
	@PP_N_PIEZA							INT,
	@PP_DEFECTO_1						VARCHAR(20),
	@PP_CANTIDAD_1						INT,
	@PP_DEFECTO_2						VARCHAR(20),
	@PP_CANTIDAD_2						INT,
	@PP_DEFECTO_3						VARCHAR(20),
	@PP_CANTIDAD_3						INT,
	@PP_FECHA							DATE,
	@PP_NOMBRE_INSP_CERTI				VARCHAR(255),
	@PP_TURNO_INSP_CERTI				INT,
	@PP_SERIAL							VARCHAR(50),
	@PP_PATRON							VARCHAR(50),
	@PP_ESTACION						VARCHAR(50)	
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

	-- ////////RN VALIDACIONES///////////////////////////////////////////////////////
	DECLARE @VP_N_SELLO INT = 0
	SELECT	@VP_N_SELLO = COUNT(noreloj)
	FROM [PPMS_PEARL].[dbo].[personal] (NOLOCK)
	WHERE sello = @PP_SELLO_INSP_MESA
			
	IF @VP_N_SELLO IS NULL OR @VP_N_SELLO = 0
		 SET @VP_MENSAJE = 'El sello del inspector de mesa no existe' 

	IF  @VP_MENSAJE=''
		BEGIN
			SET @VP_N_SELLO = 0
			SELECT	@VP_N_SELLO = COUNT(noreloj)
			FROM [PPMS_PEARL].[dbo].[personal] (NOLOCK)
			WHERE INSPECTOR_CAL = @PP_NOMBRE_INSP_CERTI

			IF @VP_N_SELLO IS NULL OR @VP_N_SELLO = 0
				SET @VP_MENSAJE = 'El Inspector de certificación no tiene sello asignado'
		END	
		
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				IF @PP_DEFECTO_1 = '( S/D )'
					SET @PP_DEFECTO_1 = ''

				IF @PP_DEFECTO_2 = '( S/D )'
					SET @PP_DEFECTO_2 = ''

				IF @PP_DEFECTO_3 = '( S/D )'
					SET @PP_DEFECTO_3 = ''

				-- ////////SE DECLARAN VARIABLES A USARSE///////////////////////////////////////////////////////
				DECLARE @VP_EXTRA INT = 0, @VP_VALIDAR_TURNO INT = 2;
				DECLARE @VP_TOTAL INT = (@PP_N_PAQUETE * @PP_N_PIEZA);
				DECLARE @VP_FECHA_INT INT = DATA_02.[dbo].[CONVERT_DATE_TO_INT](@PP_FECHA, 'yyyyMMdd');
				DECLARE @VP_HORA_VAR VARCHAR(20) = CONVERT(VARCHAR,GETDATE(),24);
				DECLARE @VP_HORA INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
				
				-- ////////SE OBTINE EL TURNO EN BASE A LA HORA DEL GUARDADO DE LA INFORMACION///////////////////////////////////////////////////////
				IF @VP_HORA > 2000 AND @VP_HORA < 60002
					SET @VP_VALIDAR_TURNO = 3
				ELSE IF @VP_HORA > 60001 AND @VP_HORA < 153001
					SET @VP_VALIDAR_TURNO = 1

				-- ////////SE VALIDA SI EL TURNO DEL OPERAR ES IGUAL AL TURNO EN BASE ALA HORA DEL GUARDADO DE LA INFORMACION///////////////////////////////////////////////////////
				IF @PP_TURNO_INSP_CERTI <> @VP_VALIDAR_TURNO
					SET @VP_EXTRA = 1

				-- ////////SE ACTUALIZA/GUARDA LA INFORMACION EN CERTIFICACION_RPT///////////////////////////////////////////////////////
				IF @PP_ID = 0
					BEGIN
						INSERT INTO [certificacion_rpt]	(	[sello_paq], [no_parte], [programa], [orden], [mesa], [paquetes], [piezas_set], 
															[defecto1], [cant1], [defecto2], [cant2], [defecto3], [cant3], [fecha], [turno],
															[insp_certi], [mezclada], [extra], [total], [noserie_caja], [patron], [estacion], [hora]
														)
												VALUES	(	@PP_SELLO_INSP_MESA, @PP_CUS_PART_NO, @PP_PROGRAMA, @PP_ORDEN, @PP_MESA, @PP_N_PAQUETE, @PP_N_PIEZA,
															@PP_DEFECTO_1, @PP_CANTIDAD_1, @PP_DEFECTO_2, @PP_CANTIDAD_2, @PP_DEFECTO_3, @PP_CANTIDAD_3, @VP_FECHA_INT,	@PP_TURNO_INSP_CERTI,
															@PP_NOMBRE_INSP_CERTI, 	0, 	@VP_EXTRA, @VP_TOTAL, @PP_SERIAL, @PP_PATRON, @PP_ESTACION, @VP_HORA_VAR		
														)
						
						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible Guardar los datos en [certificacion_rpt] ', 16, 1 ) --MENSAJE - Severity -State.
					END
				ELSE
					BEGIN
						UPDATE [certificacion_rpt]
							SET [sello_paq]	= @PP_SELLO_INSP_MESA, 
								[no_parte]	= @PP_CUS_PART_NO,
								[programa]	= @PP_PROGRAMA,
								[orden]		= @PP_ORDEN,
								[mesa]		= @PP_MESA,
								[paquetes]	= @PP_N_PAQUETE,
								[piezas_set] = @PP_N_PIEZA,
								[defecto1]	= @PP_DEFECTO_1,
								[cant1]		= @PP_CANTIDAD_1,
								[defecto2]	= @PP_DEFECTO_2,
								[cant2]		= @PP_CANTIDAD_2,
								[defecto3]	= @PP_DEFECTO_3,
								[cant3]		= @PP_CANTIDAD_3,
								[fecha]		= @VP_FECHA_INT,
								[turno]		= @PP_TURNO_INSP_CERTI,
								[insp_certi] = @PP_NOMBRE_INSP_CERTI, 
								[extra]		= @VP_EXTRA,
								[total]		= @VP_TOTAL,
								[noserie_caja] = @PP_SERIAL,
								[patron]	= @PP_PATRON,
								[estacion]	= @PP_ESTACION,
								[hora]		= @VP_HORA_VAR
						WHERE ID = @PP_ID

						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible Actualizar los datos en [certificacion_rpt] ', 16, 1 ) --MENSAJE - Severity -State.
					END
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_UP_CERTIFICACION_REPORT // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [GUARDAR] el registro de Certificación: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#Cert.'+CONVERT(VARCHAR(10),@PP_ID)+']'
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
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_CERTIFICACION_REPORT_V2]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_UP_CERTIFICACION_REPORT_V2]
GO
/*
	EXEC  [dbo].[PG_IN_UP_CERTIFICACION_REPORT_V2] 0, 0,  0 , '048' , 'MAGN02' , '200487CTX7' , 'PWLKL2FWLROX7' , '2021 WL KL E6' , '43929' , 'Table 01' , 1 , 30 , 
										'AC' , 1 , 'AR' , 1 , 'AC' , 1 , '2021/12/13' , 'NAYELI HERNANDEZ HERNANDEZ' , '1' , '43929001' , '11063960' , '1' , 'IT-010' 
*/
CREATE PROCEDURE [dbo].[PG_IN_UP_CERTIFICACION_REPORT_V2]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_ID								INT,
	@PP_SELLO_INSP_MESA					VARCHAR(20),
	@PP_CLIENTE							VARCHAR(50),
	@PP_MODELO							VARCHAR(50),
	@PP_VERSION							VARCHAR(50),
	@PP_COLOR							VARCHAR(50),
	@PP_CUS_PART_NO						VARCHAR(50),
	@PP_ITEM_NO							VARCHAR(50),
	@PP_PROGRAMA						VARCHAR(255),
	@PP_ORDEN							VARCHAR(20),
	@PP_MESA							VARCHAR(50),
	@PP_N_PAQUETE						INT,
	@PP_N_PIEZA							INT,
	@PP_DEFECTO_1						VARCHAR(20),
	@PP_CANTIDAD_1						INT,
	@PP_DEFECTO_2						VARCHAR(20),
	@PP_CANTIDAD_2						INT,
	@PP_DEFECTO_3						VARCHAR(20),
	@PP_CANTIDAD_3						INT,
	@PP_FECHA							DATE,
	@PP_NOMBRE_INSP_CERTI				VARCHAR(255),
	@PP_TURNO_INSP_CERTI				INT,
	@PP_SERIAL							VARCHAR(50),
	@PP_PATRON							VARCHAR(50),
	@PP_ITEM_NO_PATRON					VARCHAR(50),
	@PP_ESTACION						VARCHAR(50)	
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

	-- ////////RN VALIDACIONES///////////////////////////////////////////////////////
	DECLARE @VP_N_SELLO INT = 0
	SELECT	@VP_N_SELLO = COUNT(noreloj)
	FROM [PPMS_PEARL].[dbo].[personal] (NOLOCK)
	WHERE sello = @PP_SELLO_INSP_MESA
			
	IF @VP_N_SELLO IS NULL OR @VP_N_SELLO = 0
		 SET @VP_MENSAJE = 'El sello del inspector de mesa no existe' 

	IF  @VP_MENSAJE=''
		BEGIN
			SET @VP_N_SELLO = 0
			SELECT	@VP_N_SELLO = COUNT(noreloj)
			FROM [PPMS_PEARL].[dbo].[personal] (NOLOCK)
			WHERE INSPECTOR_CAL = @PP_NOMBRE_INSP_CERTI

			IF @VP_N_SELLO IS NULL OR @VP_N_SELLO = 0
				SET @VP_MENSAJE = 'El Inspector de certificación no tiene sello asignado'
		END	
		
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				IF @PP_DEFECTO_1 = '( S/D )'
					SET @PP_DEFECTO_1 = ''

				IF @PP_DEFECTO_2 = '( S/D )'
					SET @PP_DEFECTO_2 = ''

				IF @PP_DEFECTO_3 = '( S/D )'
					SET @PP_DEFECTO_3 = ''

				-- ////////SE DECLARAN VARIABLES A USARSE///////////////////////////////////////////////////////
				DECLARE @VP_EXTRA INT = 0, @VP_VALIDAR_TURNO INT = 2;
				DECLARE @VP_TOTAL INT = (@PP_N_PAQUETE * @PP_N_PIEZA);
				DECLARE @VP_TOTAL_DEFECTO INT = @PP_CANTIDAD_1 + @PP_CANTIDAD_2 + @PP_CANTIDAD_3;
				DECLARE @VP_FECHA_INT INT = DATA_02.[dbo].[CONVERT_DATE_TO_INT](@PP_FECHA, 'yyyyMMdd');
				DECLARE @VP_HORA_VAR VARCHAR(20) = CONVERT(VARCHAR,GETDATE(),24);
				DECLARE @VP_HORA INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
				
				-- ////////SE OBTINE EL PRECIO DEL PATRON ///////////////////////////////////////////////////////
				DECLARE @VP_PRECIO_PATRON DECIMAL(13,4) = 0
				SELECT TOP 1 @VP_PRECIO_PATRON = PRC_OR_DISC_1
				FROM	DATA_02.DBO.OEPRCFIL_SQL (NOLOCK)
				WHERE	LTRIM(RTRIM(filler_0001)) LIKE '%' + @PP_ITEM_NO_PATRON 
				AND LTRIM(RTRIM(filler_0001)) LIKE @PP_CLIENTE + '%'
				ORDER BY A4GLIdentity DESC

				IF @VP_PRECIO_PATRON IS NULL
					SET @VP_PRECIO_PATRON = 0

				-- ////////SE CALCULA EL COSTO DE PRODUCCION DE LOS PATRONES CON DEFECTOS ///////////////////////////////////////////////////////
				DECLARE @VP_COSTO_PRODUCCION DECIMAL(13,4) = @VP_PRECIO_PATRON * @VP_TOTAL_DEFECTO

				-- ////////SE OBTINE EL TURNO EN BASE A LA HORA DEL GUARDADO DE LA INFORMACION///////////////////////////////////////////////////////
				IF @VP_HORA > 2000 AND @VP_HORA < 60002
					SET @VP_VALIDAR_TURNO = 3
				ELSE IF @VP_HORA > 60001 AND @VP_HORA < 153001
					SET @VP_VALIDAR_TURNO = 1

				-- ////////SE VALIDA SI EL TURNO DEL OPERAR ES IGUAL AL TURNO EN BASE ALA HORA DEL GUARDADO DE LA INFORMACION///////////////////////////////////////////////////////
				IF @PP_TURNO_INSP_CERTI <> @VP_VALIDAR_TURNO
					SET @VP_EXTRA = 1

				-- ////////SE ACTUALIZA/GUARDA LA INFORMACION EN CERTIFICACION_RPT///////////////////////////////////////////////////////
				IF @PP_ID = 0
					BEGIN
						INSERT INTO [certificacion_rpt]	(	[sello_paq], [no_parte], [programa], [orden], [mesa], [paquetes], [piezas_set], 
															[defecto1], [cant1], [defecto2], [cant2], [defecto3], [cant3], [fecha], [turno],
															[insp_certi], [mezclada], [extra], [total], [noserie_caja], [patron], [estacion], 
															[hora], ITEM_NO, ITEM_NO_PATRON, PRECIO_PATRON, COSTO, 
															CLIENTE, MODELO, [VERSION], COLOR
														)
												VALUES	(	@PP_SELLO_INSP_MESA, @PP_CUS_PART_NO, @PP_PROGRAMA, @PP_ORDEN, @PP_MESA, @PP_N_PAQUETE, @PP_N_PIEZA,
															@PP_DEFECTO_1, @PP_CANTIDAD_1, @PP_DEFECTO_2, @PP_CANTIDAD_2, @PP_DEFECTO_3, @PP_CANTIDAD_3, @VP_FECHA_INT,	@PP_TURNO_INSP_CERTI,
															@PP_NOMBRE_INSP_CERTI, 0, @VP_EXTRA, @VP_TOTAL, @PP_SERIAL, @PP_PATRON, @PP_ESTACION, 
															@VP_HORA_VAR, @PP_ITEM_NO, @PP_ITEM_NO_PATRON, @VP_PRECIO_PATRON, @VP_COSTO_PRODUCCION,
															@PP_CLIENTE, @PP_MODELO, @PP_VERSION, @PP_COLOR
														)
						
						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible Guardar los datos en [certificacion_rpt] ', 16, 1 ) --MENSAJE - Severity -State.
					END
				ELSE
					BEGIN
						UPDATE [certificacion_rpt]
							SET [sello_paq]	= @PP_SELLO_INSP_MESA, 
								[no_parte]	= @PP_CUS_PART_NO,
								[programa]	= @PP_PROGRAMA,
								[orden]		= @PP_ORDEN,
								[mesa]		= @PP_MESA,
								[paquetes]	= @PP_N_PAQUETE,
								[piezas_set] = @PP_N_PIEZA,
								[defecto1]	= @PP_DEFECTO_1,
								[cant1]		= @PP_CANTIDAD_1,
								[defecto2]	= @PP_DEFECTO_2,
								[cant2]		= @PP_CANTIDAD_2,
								[defecto3]	= @PP_DEFECTO_3,
								[cant3]		= @PP_CANTIDAD_3,
								[fecha]		= @VP_FECHA_INT,
								[turno]		= @PP_TURNO_INSP_CERTI,
								[insp_certi] = @PP_NOMBRE_INSP_CERTI, 
								[extra]		= @VP_EXTRA,
								[total]		= @VP_TOTAL,
								[noserie_caja] = @PP_SERIAL,
								[patron]	= @PP_PATRON,
								[estacion]	= @PP_ESTACION,
								[hora]		= @VP_HORA_VAR,
								ITEM_NO		= @PP_ITEM_NO, 
								ITEM_NO_PATRON = @PP_ITEM_NO_PATRON, 
								PRECIO_PATRON = @VP_PRECIO_PATRON, 
								COSTO	= @VP_COSTO_PRODUCCION,
								CLIENTE = @PP_CLIENTE, 
								MODELO = @PP_MODELO, 
								[VERSION] = @PP_VERSION, 
								COLOR = @PP_COLOR
						WHERE ID = @PP_ID

						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible Actualizar los datos en [certificacion_rpt] ', 16, 1 ) --MENSAJE - Severity -State.
					END
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_UP_CERTIFICACION_REPORT // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [GUARDAR] el registro de Certificación: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#Cert.'+CONVERT(VARCHAR(10),@PP_ID)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_ID AS CLAVE

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
