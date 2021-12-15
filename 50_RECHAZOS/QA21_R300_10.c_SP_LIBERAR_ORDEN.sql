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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_LIBERAR_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_LIBERAR_ORDEN]
GO

/*
 EXEC	[dbo].[PG_SK_LIBERAR_ORDEN] 0,144,  '48100'
 EXEC	[dbo].[PG_SK_LIBERAR_ORDEN] 0,144,  '43929'
 EXEC	[dbo].[PG_SK_LIBERAR_ORDEN] 0,144,  '45200'
*/

CREATE PROCEDURE [dbo].[PG_SK_LIBERAR_ORDEN]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_ORDEN						VARCHAR(50)
AS

	-- ////////SE OBTIENE EL NUMERO DE LA MESA///////////////////////////////////
	DECLARE @VP_MESA INT = 0, @VP_MESA_DESC VARCHAR(50) = '';
	SELECT	@VP_MESA = SUBSTRING(LTRIM(RTRIM(LOC)), 2,5),
			@VP_MESA_DESC = LTRIM(RTRIM(MACHINE)) 
	FROM  [DATA_02].dbo.imlocfil_sql (NOLOCK) 
	INNER JOIN  [DATA_02].dbo.ccjobhdr_sql (NOLOCK) ON  [DATA_02].dbo.imlocfil_sql.loc_desc = machine
	WHERE jobno = @PP_ORDEN

	IF @VP_MESA IS NULL
		SET @VP_MESA = 0

	-- ////////SE CREA TABLA TEMPORAL OBTENER LA MUESTRA POR PROCESO Y TURNO///////////////////////////////////
	DECLARE @TBL_MUESTRA_X_PROCESO_TURNO TABLE(
		ID_PROCESO	INT,
		PROCESO		VARCHAR(100),
		TURNO		INT,
		MUESTRA		INT,
		DEFECTO		INT
	)

	INSERT INTO @TBL_MUESTRA_X_PROCESO_TURNO 
	SELECT @VP_MESA, 'SIN ASIGNAR', 0, ISNULL((SUM(CONVERT(INT, (OriginalQty * CUBE_QTY_PER)))), 0), 0
		FROM	DATA_02.dbo.ccjoblin_sql (NOLOCK)
		-- ===========================
		INNER JOIN DATA_02.DBO.imitmidx_sql (NOLOCK) ON ccjoblin_sql.item_no = imitmidx_sql.item_no
		-- ===========================
			INNER JOIN	DATA_02.DBO.cccusitm_sql (NOLOCK) ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
			AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
			AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
															FROM	DATA_02.DBO.cccusitm_sql (NOLOCK)
															WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
															AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)
			-- ===========================
		WHERE	jobno = @PP_ORDEN -- '48100'
		AND CUS_ITEM_NO NOT IN (	SELECT noparte		
									FROM [PPMS_PEARL].[dbo].[RECHAZOS] (NOLOCK) 
									WHERE Orden = @PP_ORDEN ) --'48100' )

	-- ////////SE AGREGAN LOS 3 TURNOS EN 0///////////////////////////////////
	INSERT INTO @TBL_MUESTRA_X_PROCESO_TURNO 
	SELECT @VP_MESA, @VP_MESA_DESC, 1, 0, 0

	INSERT INTO @TBL_MUESTRA_X_PROCESO_TURNO 
	SELECT @VP_MESA, @VP_MESA_DESC, 2, 0, 0

	INSERT INTO @TBL_MUESTRA_X_PROCESO_TURNO 
	SELECT @VP_MESA, @VP_MESA_DESC, 3, 0, 0

	-- ////////SE DECLARAN VARIABLES A USAR DENTRO DEL CURSOR///////////////////////////////////
	DECLARE @VP_ITEM_NO VARCHAR(100) = '', @VP_CUS_ITEM_NO VARCHAR(100) = 0, @VP_QTY_PROGRAMADO INT = 0;

	-- //////SE CREA CURSOR PARA RECORRER LOS DIFERENTES KITS PROGRAMADOS EN LA ORDEN/////////////////////////////////////
	DECLARE CU_KIT_PROGRAMADO_A_LIBERAR CURSOR 
	FOR SELECT	ccjoblin_sql.Item_No, 
				CUS_ITEM_NO,
				(SUM(CONVERT(INT, (OriginalQty * CUBE_QTY_PER))))
		FROM	DATA_02.dbo.ccjoblin_sql (NOLOCK)
		-- ===========================
		INNER JOIN DATA_02.DBO.imitmidx_sql (NOLOCK) ON ccjoblin_sql.item_no = imitmidx_sql.item_no
		-- ===========================
		INNER JOIN	DATA_02.DBO.cccusitm_sql (NOLOCK) ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
		AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
		AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
														FROM	DATA_02.DBO.cccusitm_sql (NOLOCK)
														WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
														AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)
			-- ===========================
		WHERE	jobno = @PP_ORDEN --'48100' -- '43929'
		AND CUS_ITEM_NO IN (	SELECT noparte		
									FROM [PPMS_PEARL].[dbo].[RECHAZOS] (NOLOCK) 
									WHERE Orden = @PP_ORDEN ) --'48100' )
		GROUP BY jobno, ccjoblin_sql.Item_No, CUS_ITEM_NO
		ORDER BY ccjoblin_sql.Item_No

	OPEN CU_KIT_PROGRAMADO_A_LIBERAR
	FETCH NEXT FROM CU_KIT_PROGRAMADO_A_LIBERAR INTO @VP_ITEM_NO, @VP_CUS_ITEM_NO, @VP_QTY_PROGRAMADO

	WHILE @@FETCH_STATUS = 0
		BEGIN			
			DECLARE @VP_N_TURNO INT = 0
			SELECT 	@VP_N_TURNO = COUNT(DISTINCT(TURNO))		
			FROM [PPMS_PEARL].[dbo].[RECHAZOS] (NOLOCK) 
			WHERE Orden = @PP_ORDEN 
			AND NOPARTE = @VP_CUS_ITEM_NO

			DECLARE @VP_MUESTRA_PROPORCION INT = @VP_QTY_PROGRAMADO / @VP_N_TURNO

			DECLARE @VP_DEFECTO INT = 0
			SELECT	@VP_DEFECTO = COUNT(ID)			
			FROM [PPMS_PEARL].[dbo].[RECHAZOS] 
			WHERE Orden = @PP_ORDEN 
			AND NOPARTE = @VP_CUS_ITEM_NO
			AND turno = 1 
			--AND DEFECTO IN (	SELECT CLAVE 
			--						FROM [PPMS_PEARL].[dbo].DEF 
			--						WHERE TIPODEF NOT IN ('QUILTY', 'PERFORADO') 
			--					)

			IF @VP_DEFECTO IS NULL
				SET @VP_DEFECTO = 0
			
			IF @VP_DEFECTO > 0
				UPDATE @TBL_MUESTRA_X_PROCESO_TURNO
					SET MUESTRA = MUESTRA + @VP_MUESTRA_PROPORCION,
						DEFECTO = DEFECTO + @VP_DEFECTO
				WHERE TURNO = 1

			SET @VP_DEFECTO = 0
			SELECT	@VP_DEFECTO = COUNT(ID)			
			FROM [PPMS_PEARL].[dbo].[RECHAZOS] 
			WHERE Orden = @PP_ORDEN 
			AND NOPARTE = @VP_CUS_ITEM_NO
			AND turno = 2 
			--AND DEFECTO IN (	SELECT CLAVE 
			--						FROM [PPMS_PEARL].[dbo].DEF 
			--						WHERE TIPODEF NOT IN ('QUILTY', 'PERFORADO') 
			--					)

			IF @VP_DEFECTO IS NULL
				SET @VP_DEFECTO = 0

			IF @VP_DEFECTO > 0
				UPDATE @TBL_MUESTRA_X_PROCESO_TURNO
					SET MUESTRA = MUESTRA + @VP_MUESTRA_PROPORCION,
						DEFECTO = DEFECTO + @VP_DEFECTO
				WHERE TURNO = 2

			SET @VP_DEFECTO = 0
			SELECT	@VP_DEFECTO = COUNT(ID)			
			FROM [PPMS_PEARL].[dbo].[RECHAZOS] 
			WHERE Orden = @PP_ORDEN 
			AND NOPARTE = @VP_CUS_ITEM_NO 
			AND turno = 3 
			--AND DEFECTO IN (	SELECT CLAVE 
			--						FROM [PPMS_PEARL].[dbo].DEF 
			--						WHERE TIPODEF NOT IN ('QUILTY', 'PERFORADO') 
			--					)

			IF @VP_DEFECTO IS NULL
				SET @VP_DEFECTO = 0
			
			IF @VP_DEFECTO > 0
				UPDATE @TBL_MUESTRA_X_PROCESO_TURNO
					SET MUESTRA = MUESTRA + @VP_MUESTRA_PROPORCION,
						DEFECTO = DEFECTO + @VP_DEFECTO
				WHERE TURNO = 3		

			FETCH NEXT FROM CU_KIT_PROGRAMADO_A_LIBERAR INTO @VP_ITEM_NO, @VP_CUS_ITEM_NO, @VP_QTY_PROGRAMADO
		END
				
	CLOSE CU_KIT_PROGRAMADO_A_LIBERAR
	DEALLOCATE CU_KIT_PROGRAMADO_A_LIBERAR

	DECLARE @VP_MUESTRA_SIN_APLICAR INT = 0

	SELECT @VP_MUESTRA_SIN_APLICAR = MUESTRA
	FROM @TBL_MUESTRA_X_PROCESO_TURNO
	WHERE TURNO = 0

	IF @VP_MUESTRA_SIN_APLICAR = 0
		DELETE @TBL_MUESTRA_X_PROCESO_TURNO WHERE MUESTRA = 0

	SELECT	ID_PROCESO,	
			PROCESO,		
			TURNO,		
			MUESTRA,		
			DEFECTO,
			(	CASE WHEN MUESTRA > 0 THEN CONVERT(INT, (CONVERT(DECIMAL(13,2), DEFECTO) / CONVERT(DECIMAL(13,2), MUESTRA) * 1000000) )
				ELSE 0 END ) AS PPMS
	FROM @TBL_MUESTRA_X_PROCESO_TURNO

	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> SELECT / LISTADO
---- //////////////////////////////////////////////////////////////

--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_LIBERAR_ORDEN]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_SK_LIBERAR_ORDEN]
--GO

--/*
-- EXEC	[dbo].[PG_SK_LIBERAR_ORDEN] 0,144,  '48100'
--*/

--CREATE PROCEDURE [dbo].[PG_SK_LIBERAR_ORDEN]
--	@PP_K_SISTEMA_EXE					INT,
--	@PP_K_USUARIO_ACCION				INT,
--	-- ===========================
--	@PP_ORDEN						VARCHAR(50)
--AS

--	-- ////////SE OBTIENE EL NUMERO DE LA MESA///////////////////////////////////
--	DECLARE @VP_MESA INT = 0
--	SELECT @VP_MESA = SUBSTRING(LTRIM(RTRIM(LOC)), 2,5) 
--	FROM  [DATA_02].dbo.imlocfil_sql (NOLOCK) 
--	INNER JOIN  [DATA_02].dbo.ccjobhdr_sql (NOLOCK) ON  [DATA_02].dbo.imlocfil_sql.loc_desc = machine
--	WHERE jobno = @PP_ORDEN

--	IF @VP_MESA IS NULL
--		SET @VP_MESA = 0

--	-- ////////SE CREA TABLA TEMPORAL OBTENER LA MUESTRA POR PROCESO Y TURNO///////////////////////////////////
--	DECLARE @VP_MUESTRA_X_PROCESO_TURNO TABLE(
--		ID_PROCESO	INT,
--		PROCESO		VARCHAR(100),
--		TURNO		INT,
--		MUESTRA		INT,
--		DEFECTO		INT,
--		PPMS		INT
--	)

--	-- ////////SE DECLARAN VARIABLES A USAR DENTRO DEL CURSOR///////////////////////////////////
--	DECLARE @VP_ITEM_NO VARCHAR(100) = '', @VP_CUS_ITEM_NO VARCHAR(100) = 0, @VP_QTY_PROGRAMADO INT = 0;

--	-- //////SE CREA CURSOR PARA RECORRER LOS DIFERENTES KITS PROGRAMADOS EN LA ORDEN/////////////////////////////////////
--	DECLARE CU_KIT_PROGRAMADO_A_LIBERAR CURSOR 
--	FOR SELECT	ccjoblin_sql.Item_No, 
--				CUS_ITEM_NO,
--				(SUM(CONVERT(INT, (OriginalQty * CUBE_QTY_PER))))
--		FROM	DATA_02.dbo.ccjoblin_sql (NOLOCK)
--		-- ===========================
--		INNER JOIN DATA_02.DBO.imitmidx_sql (NOLOCK) ON ccjoblin_sql.item_no = imitmidx_sql.item_no
--		-- ===========================
--			INNER JOIN	DATA_02.DBO.cccusitm_sql (NOLOCK) ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
--			AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
--			AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
--															FROM	DATA_02.DBO.cccusitm_sql (NOLOCK)
--															WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
--															AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)
--			-- ===========================
--		WHERE	jobno = @PP_ORDEN -- '43929'
--		GROUP BY jobno, ccjoblin_sql.Item_No, CUS_ITEM_NO
--		ORDER BY ccjoblin_sql.Item_No

--	OPEN CU_KIT_PROGRAMADO_A_LIBERAR
--	FETCH NEXT FROM CU_KIT_PROGRAMADO_A_LIBERAR INTO @VP_ITEM_NO, @VP_CUS_ITEM_NO, @VP_QTY_PROGRAMADO

--	WHILE @@FETCH_STATUS = 0
--		BEGIN
--			-- //////SE VALIDA SI EL KIT TIENE DEFECTOS///////////////////////////////////// 
--			DECLARE @VP_N_DEFECTO_X_KIT INT = 0
--			SELECT @VP_N_DEFECTO_X_KIT = COUNT(ID)			
--			FROM [PPMS_PEARL].[dbo].[RECHAZOS] (NOLOCK) 
--			WHERE Orden = @PP_ORDEN --'43929' 
--			AND NOPARTE = @VP_CUS_ITEM_NO --'203091ATX7'

--			-- //////SI EL KIT NO TIENE DEFECTO SE AGREGA AL TURNO CERO///////////////////////////////////// 
--			IF @VP_N_DEFECTO_X_KIT IS NULL OR @VP_N_DEFECTO_X_KIT = 0
--				BEGIN
--					DECLARE @VP_N_TURNO_0 INT = 0

--					SELECT @VP_N_TURNO_0 = COUNT(ID_PROCESO) 
--					FROM @VP_MUESTRA_X_PROCESO_TURNO
--					WHERE TURNO = 0

--					IF @VP_N_DEFECTO_X_KIT IS NULL OR @VP_N_DEFECTO_X_KIT = 0
--						BEGIN
--							INSERT INTO @VP_MUESTRA_X_PROCESO_TURNO 
--							SELECT @VP_MESA, 'CORTE', 0, @VP_QTY_PROGRAMADO, 0, 0
--						END
--					ELSE
--						BEGIN
--							DECLARE @VP_MUESTRA INT = 0
--							SELECT @VP_MUESTRA = MUESTRA 
--							FROM @VP_MUESTRA_X_PROCESO_TURNO
--							WHERE TURNO = 0

--							SET @VP_MUESTRA = @VP_MUESTRA + @VP_QTY_PROGRAMADO

--							UPDATE @VP_MUESTRA_X_PROCESO_TURNO
--								SET MUESTRA = @VP_MUESTRA
--							WHERE TURNO = 0
--						END
--				END
--			ELSE
--				BEGIN
--					DECLARE @VP_N_TURNO INT = 0
--					SELECT 	@VP_N_TURNO = COUNT(DISTINCT(TURNO))		
--					FROM [PPMS_PEARL].[dbo].[RECHAZOS] (NOLOCK) 
--					WHERE Orden = '43929' AND NOPARTE = '203091ATX7'

--					DECLARE @VP_MUESTRA_PROPORCION INT = @VP_QTY_PROGRAMADO / @VP_N_TURNO

--					SELECT	@VP_MESA, 
--							TURNO, 			
--					FROM [PPMS_PEARL].[dbo].[RECHAZOS] 
--					WHERE Orden = '43929' AND NOPARTE = '203091ATX7' 

--				END
			 
--			SELECT *			
--			FROM [PPMS_PEARL].[dbo].[RECHAZOS] (NOLOCK) 
--			WHERE Orden = '43929' AND NOPARTE = '203091ATX7'

--			FETCH NEXT FROM CU_KIT_PROGRAMADO_A_LIBERAR INTO @VP_ITEM_NO, @VP_CUS_ITEM_NO, @VP_QTY_PROGRAMADO
--		END
				
--	CLOSE CU_KIT_A_PROGRAMAR
--	DEALLOCATE CU_KIT_A_PROGRAMAR
--	-- ////////////////////////////////////////////////
--	-- ////////////////////////////////////////////////
--GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / UPDATE
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_RECHAZOS]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_IN_UP_RECHAZOS]
--GO
--/*
--	EXEC  [dbo].[PG_IN_UP_RECHAZOS] 0, 0 ,  0 , '43929' , 'Table 01' , '203091ATX7' , '000' , 'S' , 'TEST SISTEMAS' , 'BB' , 2 , 2 , 'M' , 'IT-010'  
--*/
--CREATE PROCEDURE [dbo].[PG_IN_UP_RECHAZOS]
--	@PP_K_SISTEMA_EXE					INT,
--	@PP_K_USUARIO_ACCION				INT,
--	-- ===========================
--	@PP_ID								INT,
--	@PP_ORDEN							VARCHAR(50),
--	@PP_MESA							VARCHAR(100),
--	@PP_CUS_PART_NO						VARCHAR(100),
--	@PP_SELLO_INSP						VARCHAR(20),
--	@PP_INICIAL_OPE						VARCHAR(50),
--	@PP_JEFE_GRUPO						VARCHAR(100),
--	@PP_DEFECTO							VARCHAR(20),
--	@PP_CANTIDAD						INT,
--	@PP_TURNO							INT,
--	@PP_ESTATUS							VARCHAR(20),	
--	@PP_ESTACION						VARCHAR(100),
--	@PP_USER							VARCHAR(100)
--AS

--	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

--	-- ////////RN VALIDACIONES///////////////////////////////////////////////////////
--	IF @PP_ID > 0
--		BEGIN
--			DECLARE @VP_LIBERADO INT = 0
--			SELECT @VP_LIBERADO = COUNT(ID)
--			FROM [PPMS_PEARL].[dbo].rechazos 
--			WHERE id = @PP_ID
--			AND [Status] = 'L'

--			IF @VP_LIBERADO IS NULL
--				SET @VP_LIBERADO = 0

--			IF @VP_LIBERADO > 0
--				SET @VP_MENSAJE = 'El rechazo que intenta modificar ya esta liberado.'
--		END

--	IF @VP_MENSAJE=''
--		EXECUTE [DATA_02].[dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
--																		@PP_ORDEN,
--																		@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
		
--	IF @VP_MENSAJE=''
--		EXECUTE [DATA_02].[dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_ESTATUS]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
--																		@PP_ORDEN,
--																		@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

--	-- ////////SI PASA LAS VALIDACIONES SE ABRE LA TRANSACCION///////////////////////////////////////////////////////
--	IF @VP_MENSAJE=''
--		BEGIN
--			BEGIN TRANSACTION 
--			BEGIN TRY
--				-- ////////SE DECLARAN VARIABLES A USARSE///////////////////////////////////////////////////////				
--				DECLARE @VP_FECHA DATE = GETDATE()
--				DECLARE @VP_HORA INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
--				DECLARE @VP_MOVIMIENTO VARCHAR(10) = 'ADD', @VP_CANT VARCHAR(10) = CONVERT(VARCHAR(10), @PP_CANTIDAD);

--				-- ////////SE OBTINE EL TURNO EN BASE A LA HORA DEL GUARDADO DE LA INFORMACION///////////////////////////////////////////////////////
--				IF @VP_HORA > 000000 AND @VP_HORA < 60001
--					SET @VP_FECHA =  DATEADD(DAY, -1, @VP_FECHA)

--					DECLARE @VP_FECHA_INT INT = DATA_02.[dbo].[CONVERT_DATE_TO_INT](@VP_FECHA, 'yyyyMMdd');

--				-- ////////SE ACTUALIZA/GUARDA LA INFORMACION EN Rechazos///////////////////////////////////////////////////////
--				IF @PP_ID = 0
--					BEGIN
--						WHILE  @PP_CANTIDAD > 0
--							BEGIN
--								SET @PP_CANTIDAD = @PP_CANTIDAD - 1
--								INSERT INTO Rechazos(	orden, mesa, turno, defecto, inspprod, inspqc, fecha, 
--														[status], hora, jefe_grupo, fisica, noparte, perfora,quilty, estacion, aceptado_por
--													) 
--												VALUES(	@PP_ORDEN, @PP_MESA, @PP_TURNO, @PP_DEFECTO, UPPER(@PP_INICIAL_OPE), @PP_SELLO_INSP, @VP_FECHA_INT,
--														@PP_ESTATUS, @VP_HORA, @PP_JEFE_GRUPO, 'SI', @PP_CUS_PART_NO, 'NO', 'NO', @PP_ESTACION, @PP_K_USUARIO_ACCION )
								
--								IF @@ROWCOUNT = 0
--									RAISERROR ('ERROR: No fue posible Guardar los datos en [Rechazos] ', 16, 1 ) --MENSAJE - Severity -State.
--							END
--					END

--					-- ////////SE GUARDA EL LOG///////////////////////////////////////////////////////		
--				DECLARE @VP_DETALLE VARCHAR(255) = '# PARTE: '	+ @PP_CUS_PART_NO + ' DEFECTO: ' + @PP_DEFECTO + ' Cant: ' + @VP_CANT + ' INICIAL OPE: ' + @PP_INICIAL_OPE

--				IF @VP_MOVIMIENTO = 'UP'
--					SET @VP_DETALLE = '# PARTE: '	+ @PP_CUS_PART_NO + ' DEFECTO: ' + @PP_DEFECTO + ' INICIAL OPE: ' + @PP_INICIAL_OPE

--				EXECUTE DATA_02.[dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
--															@PP_USER, @PP_ESTACION, 'RECHAZOS',
--															@PP_ORDEN, @VP_MOVIMIENTO, @VP_DETALLE, @PP_SELLO_INSP

--			COMMIT TRANSACTION 
--			END TRY
	
--			BEGIN CATCH
--				/* Ocurrió un error, deshacemos los cambios*/ 
--				ROLLBACK TRANSACTION
--				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
--				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
--				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_UP_RECHAZOS // ' + @VP_ERROR_TRANS
--			END CATCH
				
--		END

--	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
--	IF @VP_MENSAJE<>''
--		BEGIN
		
--		SET		@VP_MENSAJE = 'No es posible [GUARDAR] el rechazo: ' + @VP_MENSAJE 
--		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
--		SET		@VP_MENSAJE = @VP_MENSAJE + '[#Rec.'+CONVERT(VARCHAR(10),@PP_ID)+']'
--		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
--		END
	
--	SELECT	@VP_MENSAJE AS MENSAJE, @PP_ID AS CLAVE

--	-- ///////////////////////////////////////////////////////////////
--	-- //////////////////////////////////////////////////////////////

--GO





-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
