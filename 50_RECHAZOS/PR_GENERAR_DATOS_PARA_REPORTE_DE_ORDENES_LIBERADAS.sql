	
	USE [PPMS_PEARL]

	DECLARE @VP_ORDEN VARCHAR(50) = ''
	DECLARE CU_ORDEN_LIBERADA CURSOR 
	FOR SELECT DISTINCT Order_No
		FROM [PPMS_PEARL].[dbo].[QC] (NOLOCK)
		WHERE CONVERT(DATE, [DATE]) = '2022-01-31'
		--AND CONVERT(DATE, [DATE]) <= '2022-01-30'
	OPEN CU_ORDEN_LIBERADA

	FETCH NEXT FROM CU_ORDEN_LIBERADA INTO @VP_ORDEN
			
	-- ////////////////////SE RECORRE EL CURSOR//////////////////////////	
	WHILE @@FETCH_STATUS = 0
		BEGIN
			-- /////////SE OBTIENEN LOS NUMEROS DE PARTES CON TOTAL DE PATRONES PROGRAMADOS///////////////////////////////////////
				DECLARE @VP_MUESTRA INT = 0
				SELECT	@VP_MUESTRA = SUM(CONVERT(INT, (OriginalQty * imitmidx_sql.CUBE_QTY_PER)))
				FROM DATA_02.DBO.ccjoblin_sql  (NOLOCK)
				INNER JOIN DATA_02.dbo.imitmidx_sql (NOLOCK) ON ccjoblin_sql.item_no = imitmidx_sql.item_no
				WHERE LTRIM(RTRIM(ccjoblin_sql.jobno)) = @VP_ORDEN 
				
				-- ===========================
				IF @VP_MUESTRA IS NULL
					SET @VP_MUESTRA = 0

				-- /////////SE OBTIENEN LOS DEFECTOS DE LA ORDEN///////////////////////////////////////
				DECLARE @VP_CANTIDAD_DEFECTO INT = 0
				SELECT @VP_CANTIDAD_DEFECTO = COUNT(ID) 
				FROM [PPMS_PEARL].[dbo].Rechazos (NOLOCK) 
				WHERE ORDEN = @VP_ORDEN

				-- ===========================
				IF @VP_CANTIDAD_DEFECTO IS NULL
					SET @VP_CANTIDAD_DEFECTO = 0

				-- /////////SE OBTIENEN LOS DEFECTOS LA ORDEN POR TIPO DE DEFECTO///////////////////////////////////////
				DECLARE @VP_CANTIDAD_DEFECTO_LAMINADO INT = 0, @VP_CANTIDAD_DEFECTO_PERFORADO	INT = 0;
				DECLARE @VP_CANTIDAD_DEFECTO_QUILTY	INT = 0, @VP_CANTIDAD_DEFECTO_SKIVING	INT = 0;

				SELECT @VP_CANTIDAD_DEFECTO_LAMINADO = COUNT(ID)
				FROM [PPMS_PEARL].[dbo].Rechazos (NOLOCK) 
				INNER JOIN [PPMS_PEARL].[dbo].DEF (NOLOCK) ON Rechazos.defecto = clave
				WHERE ORDEN = @VP_ORDEN
				AND tipodef = 'LAMINADO'

				IF @VP_CANTIDAD_DEFECTO_LAMINADO IS NULL
					SET @VP_CANTIDAD_DEFECTO_LAMINADO = 0
				-- ===========================

				SELECT @VP_CANTIDAD_DEFECTO_PERFORADO = COUNT(ID)
				FROM [PPMS_PEARL].[dbo].Rechazos (NOLOCK) 
				INNER JOIN [PPMS_PEARL].[dbo].DEF (NOLOCK) ON Rechazos.defecto = clave
				WHERE ORDEN = @VP_ORDEN
				AND tipodef = 'PERFORADO'

				IF @VP_CANTIDAD_DEFECTO_PERFORADO IS NULL
					SET @VP_CANTIDAD_DEFECTO_PERFORADO = 0
				-- ===========================

				SELECT @VP_CANTIDAD_DEFECTO_QUILTY = COUNT(ID)
				FROM [PPMS_PEARL].[dbo].Rechazos (NOLOCK) 
				INNER JOIN [PPMS_PEARL].[dbo].DEF (NOLOCK) ON Rechazos.defecto = clave
				WHERE ORDEN = @VP_ORDEN
				AND tipodef = 'QUILTY'

				IF @VP_CANTIDAD_DEFECTO_QUILTY IS NULL
					SET @VP_CANTIDAD_DEFECTO_QUILTY = 0
				-- ===========================

				SELECT @VP_CANTIDAD_DEFECTO_SKIVING = COUNT(ID)
				FROM [PPMS_PEARL].[dbo].Rechazos (NOLOCK) 
				INNER JOIN [PPMS_PEARL].[dbo].DEF (NOLOCK) ON Rechazos.defecto = clave
				WHERE ORDEN = @VP_ORDEN
				AND tipodef = 'SKIVING'

				IF @VP_CANTIDAD_DEFECTO_SKIVING IS NULL
					SET @VP_CANTIDAD_DEFECTO_SKIVING = 0
				-- ===========================

				DECLARE @VP_CANTIDAD_DEFECTO_MESA INT = @VP_CANTIDAD_DEFECTO - (@VP_CANTIDAD_DEFECTO_LAMINADO + @VP_CANTIDAD_DEFECTO_PERFORADO + @VP_CANTIDAD_DEFECTO_QUILTY + @VP_CANTIDAD_DEFECTO_SKIVING)

				-- SELECT DISTINCT tipodef FROM [PPMS_PEARL].[dbo].DEF (NOLOCK)

				-- /////////SE CALCULAN LOS PPMS DE LA ORDEN///////////////////////////////////////
				DECLARE @VP_PPMS INT = 0
				IF @VP_MUESTRA > 0
					SET @VP_PPMS = CONVERT(INT, (CONVERT(DECIMAL(13,2), @VP_CANTIDAD_DEFECTO) / CONVERT(DECIMAL(13,2), @VP_MUESTRA) * 1000000) )

				-- /////////SE OBTIENE LA MESA DE LA ORDEN///////////////////////////////////////
				DECLARE @VP_MESA VARCHAR(50) = ''
				SELECT @VP_MESA = LTRIM(RTRIM(MACHINE)) 
				FROM DATA_02.DBO.ccjobhdr_sql (NOLOCK)
				WHERE JOBNO = @VP_ORDEN

				-- /////////SE CALCULAN LOS PPMS DE LA ORDEN///////////////////////////////////////
				DECLARE @VP_INSP_CALIDAD VARCHAR(150) = '', @VP_JEFE_GRUPO VARCHAR(150) = '', @VP_F_LIBERACION DATE;
				SELECT	@VP_INSP_CALIDAD = Inspector,
						@VP_JEFE_GRUPO = jefe_gpo,
						@VP_F_LIBERACION = CONVERT(DATE, [DATE])
				FROM [PPMS_PEARL].[dbo].[QC] (NOLOCK)
				WHERE Order_No = @VP_ORDEN

				-- /////////SE INGRESA EL REGISTRO DE LIBERACION DE LA ORDEN///////////////////////////////////////
				INSERT INTO [PPMS_PEARL].[dbo].[ORDEN_LIBERADA] (	
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
												1,
												@VP_ORDEN,
												@VP_MESA,
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
												@VP_INSP_CALIDAD,
												@VP_JEFE_GRUPO,
												-- ===========================
												@VP_F_LIBERACION,
												-- ===========================
												144, GETDATE(), 144, GETDATE(),
												0, NULL, NULL 
											)
			FETCH NEXT FROM CU_ORDEN_LIBERADA INTO @VP_ORDEN
		END
			
	-- ////////////////////SE CIERRA EL CURSOR//////////////////////////
	CLOSE CU_ORDEN_LIBERADA
	DEALLOCATE CU_ORDEN_LIBERADA