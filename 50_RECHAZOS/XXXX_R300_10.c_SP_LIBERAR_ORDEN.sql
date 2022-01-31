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

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
