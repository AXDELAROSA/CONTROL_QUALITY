
	DECLARE @VP_ORDEN VARCHAR(100) = '', @VP_SERIAL VARCHAR(100) = '', @VP_PATRON VARCHAR(100) = 0, @VP_CANTIDAD INT = 0, @VP_TOTAL_COSTO DECIMAL(13,2) = 0;
	
	DECLARE CU_COSTO_MATERIAL_RECHAZADO CURSOR 
	FOR SELECT --TOP 1 
				ORDEN,
				LTRIM(RTRIM(noserie_caja)), 
				LTRIM(RTRIM(patron)),
				(SUM(cant1) + SUM(cant2) + SUM(cant3))
		FROM [PPMS_PEARL].[dbo].certificacion_rpt (NOLOCK) 
		WHERE CONVERT(DATE, FECHA) >= '2021-12-01' 
		AND CONVERT(DATE, FECHA) <= '2021-12-10' 
		AND cant1 > 0  
		AND PATRON <> '' 
		--AND noserie_caja = '48703015'
		GROUP BY orden, noserie_caja, PATRON

	OPEN CU_COSTO_MATERIAL_RECHAZADO
	FETCH NEXT FROM CU_COSTO_MATERIAL_RECHAZADO INTO @VP_ORDEN, @VP_SERIAL, @VP_PATRON, @VP_CANTIDAD

	WHILE @@FETCH_STATUS = 0
		BEGIN		
			-- /////SE VALIDA SI LA ORDEN VA LIGADA CON OTRA//////////////////////////////////////
			DECLARE @VP_ORDEN_LIGADA VARCHAR(50) = '' 
			SELECT TOP 1 @VP_ORDEN_LIGADA = LTRIM(RTRIM(LOTNO))
			FROM DATA_02.DBO.ccjobhdr_sql  (NOLOCK)
			WHERE ccjobhdr_sql.jobno = @VP_ORDEN

			IF @VP_ORDEN_LIGADA IS NULL
				SET @VP_ORDEN_LIGADA = ''

			IF @VP_ORDEN_LIGADA <> ''
				BEGIN
					-- ////////////////////////////////////////////////
					DECLARE @VP_CLIENTE VARCHAR(50) = '', @VP_ITEM_NO VARCHAR(100) = '', @VP_MODELO VARCHAR(10) = '', @VP_VERSION VARCHAR(10) = '';
					SELECT	
							@VP_CLIENTE = LTRIM(RTRIM(ccjoblin_sql.customer)), 
							-- ===========================
							@VP_ITEM_NO = ( CASE WHEN imkitfil_sql.comp_item_no IS NULL THEN ccjoblin_sql.item_no	
											ELSE imkitfil_sql.item_no END ),
							-- ===========================
							@VP_MODELO = LTRIM(RTRIM(cccusitm_sql.modelno)),
							-- ===========================
							@VP_VERSION = LTRIM(RTRIM(cccusitm_sql.versionno))
							-- ===========================
					FROM DATA_02.DBO.ccjoblin_sql  (NOLOCK)
					-- ===========================
					LEFT JOIN DATA_02.DBO.imkitfil_sql (NOLOCK) ON ccjoblin_sql.ITEM_NO = imkitfil_sql.comp_item_no
					-- ===========================
					INNER JOIN	DATA_02.DBO.cccusitm_sql (NOLOCK) ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
					AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
					AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
																	FROM	DATA_02.DBO.cccusitm_sql (NOLOCK)
																	WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
																	AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)
					-- ===========================
					WHERE LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ CONVERT(VARCHAR(10),ser_no), 3) = @VP_SERIAL --'42282009'
				END
			ELSE
				BEGIN
					SELECT	
							@VP_CLIENTE = LTRIM(RTRIM(ccjoblin_sql.customer)), 
							-- ===========================
							@VP_ITEM_NO = LTRIM(RTRIM(ccjoblin_sql.item_no)),
							-- ===========================
							@VP_MODELO = LTRIM(RTRIM(cccusitm_sql.modelno)),
							-- ===========================
							@VP_VERSION = LTRIM(RTRIM(cccusitm_sql.versionno))
							-- ===========================
					FROM DATA_02.DBO.ccjoblin_sql  (NOLOCK)
					-- ===========================
					INNER JOIN	DATA_02.DBO.cccusitm_sql (NOLOCK) ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
					AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
					AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
																	FROM	DATA_02.DBO.cccusitm_sql (NOLOCK)
																	WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
																	AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)
					-- ===========================
					WHERE LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ CONVERT(VARCHAR(10),ser_no), 3) = @VP_SERIAL --'42282009'
				END

			DECLARE @VP_TA_PATRON_X_KIT	AS TABLE
				(	ITEM_NO_PATRON			VARCHAR(100),
					CUS_PART_NO_PATRON		VARCHAR(100))

			IF SUBSTRING(@VP_ITEM_NO, 1, 1) = 'P'
				BEGIN
					INSERT INTO @VP_TA_PATRON_X_KIT
					SELECT	
							(	SELECT TOP 1 LTRIM(RTRIM(CUS.ITEM_NO)) 
								FROM DATA_02.DBO.cccusitm_sql (NOLOCK) AS CUS 
								WHERE CUS.ITEM_NO = COMP_ITEM_NO 
								AND CUS.CUS_NO = cccusitm_sql.CUS_NO  
								AND CUS.MODELNO = cccusitm_sql.MODELNO AND CUS.VERSIONNO = cccusitm_sql.VERSIONNO),
							(	SELECT TOP 1 LTRIM(RTRIM(CUS.CUS_ITEM_NO)) 
								FROM DATA_02.DBO.cccusitm_sql (NOLOCK) AS CUS 
								WHERE CUS.ITEM_NO = COMP_ITEM_NO 
								AND CUS.CUS_NO = cccusitm_sql.CUS_NO  
								AND CUS.MODELNO = cccusitm_sql.MODELNO AND CUS.VERSIONNO = cccusitm_sql.VERSIONNO)
					FROM	DATA_02.DBO.ccprdstr_sql (NOLOCK)
					INNER JOIN DATA_02.DBO.cccusitm_sql (NOLOCK) ON  ccprdstr_sql.CUS_NO = cccusitm_sql.CUS_NO 
						AND ccprdstr_sql.MODELNO = cccusitm_sql.MODELNO
						AND ccprdstr_sql.VERSIONNO = cccusitm_sql.VERSIONNO
						AND ccprdstr_sql.item_no = cccusitm_sql.item_no
					WHERE ccprdstr_sql.item_no = @VP_ITEM_NO
					AND ccprdstr_sql.CUS_NO = @VP_CLIENTE
					AND ccprdstr_sql.MODELNO = @VP_MODELO 
					AND ccprdstr_sql.VERSIONNO = @VP_VERSION
				END
			ELSE
				BEGIN
					INSERT INTO @VP_TA_PATRON_X_KIT
					SELECT	
							(	SELECT TOP 1 LTRIM(RTRIM(CUS.ITEM_NO)) 
								FROM DATA_02.DBO.cccusitm_sql (NOLOCK) AS CUS 
								WHERE CUS.ITEM_NO = COMP_ITEM_NO 
								AND CUS.CUS_NO = cccusitm_sql.CUS_NO  
								AND CUS.MODELNO = cccusitm_sql.MODELNO AND CUS.VERSIONNO = cccusitm_sql.VERSIONNO),
							(	SELECT TOP 1 LTRIM(RTRIM(CUS.CUS_ITEM_NO)) 
								FROM DATA_02.DBO.cccusitm_sql (NOLOCK) AS CUS 
								WHERE CUS.ITEM_NO = COMP_ITEM_NO 
								AND CUS.CUS_NO = cccusitm_sql.CUS_NO  
								AND CUS.MODELNO = cccusitm_sql.MODELNO AND CUS.VERSIONNO = cccusitm_sql.VERSIONNO)
					FROM	DATA_02.DBO.ccprdstr_sql (NOLOCK)
					INNER JOIN DATA_02.DBO.cccusitm_sql (NOLOCK) ON  ccprdstr_sql.CUS_NO = cccusitm_sql.CUS_NO 
						AND ccprdstr_sql.MODELNO = cccusitm_sql.MODELNO
						AND ccprdstr_sql.VERSIONNO = cccusitm_sql.VERSIONNO
						AND ccprdstr_sql.item_no = cccusitm_sql.item_no
					WHERE ccprdstr_sql.item_no IN (  SELECT LTRIM(RTRIM(comp_item_no)) FROM DATA_02.DBO.imkitfil_sql (NOLOCK) WHERE item_no = @VP_ITEM_NO )
					AND ccprdstr_sql.CUS_NO = @VP_CLIENTE
					AND ccprdstr_sql.MODELNO = @VP_MODELO 
					AND ccprdstr_sql.VERSIONNO = @VP_VERSION
				END

				DECLARE @VP_ITEM_NO_PATRON VARCHAR(100) = ''
				SELECT @VP_ITEM_NO_PATRON = ITEM_NO_PATRON			
				FROM @VP_TA_PATRON_X_KIT
				WHERE CUS_PART_NO_PATRON = @VP_PATRON
			
				DECLARE @VP_PRECIO_PATRON DECIMAL(13,4) = 0
				SELECT TOP 1 @VP_PRECIO_PATRON = PRC_OR_DISC_1
				FROM	DATA_02.DBO.OEPRCFIL_SQL (NOLOCK)
				WHERE	LTRIM(RTRIM(filler_0001)) LIKE '%' + @VP_ITEM_NO_PATRON
				AND LTRIM(RTRIM(filler_0001)) LIKE @VP_CLIENTE + '%'
				ORDER BY A4GLIdentity DESC

				IF @VP_PRECIO_PATRON IS NULL 
					SET @VP_PRECIO_PATRON = 0

				DECLARE @VP_TOTAL_PRECIO_PATRON DECIMAL(13,4) = @VP_PRECIO_PATRON * @VP_CANTIDAD
				--SELECT	
				--	@VP_SERIAL AS SERIAL,
				--	@VP_CLIENTE AS CLIENTE, 
				--	@VP_ITEM_NO	AS KIT, 
				--	@VP_MODELO	AS MODELO, 
				--	@VP_VERSION AS VERSION,
				--	@VP_PATRON	AS CUS_PATRON,
				--	@VP_ITEM_NO_PATRON AS PATRON,
				--	@VP_PRECIO_PATRON AS PRECIO_PATRON,
				--	@VP_CANTIDAD AS CANTIDAD,
				--	@VP_TOTAL_PRECIO_PATRON as TOTAL_COSTO_ATRON

				SET @VP_TOTAL_COSTO = @VP_TOTAL_COSTO + @VP_TOTAL_PRECIO_PATRON

			FETCH NEXT FROM CU_COSTO_MATERIAL_RECHAZADO INTO @VP_ORDEN, @VP_SERIAL, @VP_PATRON, @VP_CANTIDAD
		END

	CLOSE CU_COSTO_MATERIAL_RECHAZADO
	DEALLOCATE CU_COSTO_MATERIAL_RECHAZADO


	SELECT	@VP_TOTAL_COSTO AS TOTAL_COSTO
