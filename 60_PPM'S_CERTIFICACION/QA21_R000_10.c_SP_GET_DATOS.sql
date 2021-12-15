-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[PPMS_PEARL]
-- // MODULO:			PPM & CERTIFICACION REPORT
-- // OPERACION:		GET DATOS
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	10/OCTUBRE/2021
-- //////////////////////////////////////////////////////////////  

USE [PPMS_PEARL]
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_DATOS_PERSONAL_X_SELLO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_DATOS_PERSONAL_X_SELLO]
GO

/*
 EXEC	[dbo].[PG_GET_DATOS_PERSONAL_X_SELLO] 0,0,  '011'
*/

CREATE PROCEDURE [dbo].[PG_GET_DATOS_PERSONAL_X_SELLO]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_SELLO							VARCHAR(10)
AS

	-- ////////////////////////////////////////////////
	SELECT	LTRIM(RTRIM(inspector_cal)) AS INSPECTOR,
			LTRIM(RTRIM(sello)) AS SELLO,
			turno AS TURNO,
			noreloj AS N_RELOJ
	FROM [PPMS_PEARL].[dbo].[personal] (NOLOCK)
	WHERE sello = @PP_SELLO 
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_DATOS_PERSONAL_X_N_RELOJ]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_DATOS_PERSONAL_X_N_RELOJ]
GO

/*
 EXEC	[dbo].[PG_GET_DATOS_PERSONAL_X_N_RELOJ] 0,0,  '13367'
*/

CREATE PROCEDURE [dbo].[PG_GET_DATOS_PERSONAL_X_N_RELOJ]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_N_RELOJ							INT
AS

	-- ////////////////////////////////////////////////
	SELECT	CONCAT(EP_NOMBRE, ' ' + EP_APELLIDO_PATERNO + ' ' + EP_APELLIDO_MATERNO) AS NOMBRE,
			EN_TURNO AS TURNO
	FROM [HOWE].[dbo].[VISTA_GAFETES] (NOLOCK)
	WHERE EN_NUM_EMP = @PP_N_RELOJ 
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_DATOS_ORDEN_KIT_X_SERIAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_DATOS_ORDEN_KIT_X_SERIAL]
GO

/*
 EXEC	[dbo].[PG_GET_DATOS_ORDEN_KIT_X_SERIAL] 0,0,  '49582003'	
 EXEC	[dbo].[PG_GET_DATOS_ORDEN_KIT_X_SERIAL] 0,0,  '43929001'	
*/

CREATE PROCEDURE [dbo].[PG_GET_DATOS_ORDEN_KIT_X_SERIAL]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_SERIAL							VARCHAR(50)
AS
	-- /////SE VALIDA SI LA ORDEN VA LIGADA CON OTRA//////////////////////////////////////
	DECLARE @VP_ORDEN_LIGADA VARCHAR(50) = '' 
	SELECT TOP 1 @VP_ORDEN_LIGADA = LTRIM(RTRIM(LOTNO))
	FROM DATA_02.DBO.ccjoblin_sql  (NOLOCK)
	INNER JOIN DATA_02.DBO.ccjobhdr_sql (NOLOCK) ON ccjoblin_sql.jobno = ccjobhdr_sql.jobno 
	--AND ccjobhdr_sql.JOBNO < 50000
	WHERE LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ CONVERT(VARCHAR(10),ser_no), 3) = @PP_SERIAL 

	IF @VP_ORDEN_LIGADA IS NULL
		SET @VP_ORDEN_LIGADA = ''

	IF @VP_ORDEN_LIGADA <> ''
		BEGIN
			-- ////////////////////////////////////////////////
			SELECT	LTRIM(RTRIM(ccjoblin_sql.jobno))		AS ORDEN, 
					Ser_No,
					-- ===========================
					LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ CONVERT(VARCHAR(10),ser_no), 3) AS SERIAL,
					-- ===========================
					LTRIM(RTRIM(ccjoblin_sql.kitdesc))		AS KIT_DESC, 
					CONVERT(INT,ccjoblin_sql.originalqty)	AS ORIGINAL_QTY, 
					LTRIM(RTRIM(ccjoblin_sql.customer))		AS CUSTOMER, 
					-- ===========================
					--LTRIM(RTRIM(ccjoblin_sql.item_no))		AS ITEM_NO,
					( CASE WHEN imkitfil_sql.comp_item_no IS NULL THEN ccjoblin_sql.item_no	
									ELSE imkitfil_sql.item_no END ) AS ITEM_NO,
					-- ===========================
					LTRIM(RTRIM(cccusitm_sql.cus_item_no))	AS CUS_ITEM_NO,
					LTRIM(RTRIM(cccusitm_sql.modelno))		AS MODEL_NO,
					-- ===========================
					(SELECT TOP 1 LTRIM(RTRIM(PROD_CAT_DESC)) FROM DATA_02.DBO.IMCATFIL_SQL (NOLOCK) WHERE  prod_cat = modelno ) AS PROD_CAT_DESC,
					-- ===========================
					LTRIM(RTRIM(cccusitm_sql.versionno))	AS VERSION_NO,
					LTRIM(RTRIM(MACHINE))					AS MESA,
					CONCAT('F', LTRIM(RTRIM(colour)))					AS COLOR
					-- ===========================
			FROM DATA_02.DBO.ccjoblin_sql  (NOLOCK)
			INNER JOIN DATA_02.DBO.ccjobhdr_sql (NOLOCK) ON ccjoblin_sql.jobno = ccjobhdr_sql.jobno 
				--AND ccjobhdr_sql.JOBNO < 50000
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
			WHERE LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ CONVERT(VARCHAR(10),ser_no), 3) = @PP_SERIAL --'42282009'
		END
	ELSE
		BEGIN
			SELECT	LTRIM(RTRIM(ccjoblin_sql.jobno))		AS ORDEN, 
					Ser_No,
					-- ===========================
					LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ CONVERT(VARCHAR(10),ser_no), 3) AS SERIAL,
					-- ===========================
					LTRIM(RTRIM(ccjoblin_sql.kitdesc))		AS KIT_DESC, 
					CONVERT(INT,ccjoblin_sql.originalqty)	AS ORIGINAL_QTY, 
					LTRIM(RTRIM(ccjoblin_sql.customer))		AS CUSTOMER, 
					-- ===========================
					LTRIM(RTRIM(ccjoblin_sql.item_no))		AS ITEM_NO,
					-- ===========================
					LTRIM(RTRIM(cccusitm_sql.cus_item_no))	AS CUS_ITEM_NO,
					LTRIM(RTRIM(cccusitm_sql.modelno))		AS MODEL_NO,
					-- ===========================
					(SELECT TOP 1 LTRIM(RTRIM(PROD_CAT_DESC)) FROM DATA_02.DBO.IMCATFIL_SQL (NOLOCK) WHERE  prod_cat = modelno ) AS PROD_CAT_DESC,
					-- ===========================
					LTRIM(RTRIM(cccusitm_sql.versionno))	AS VERSION_NO,
					LTRIM(RTRIM(MACHINE))					AS MESA,
					CONCAT('F', LTRIM(RTRIM(colour)))					AS COLOR
					-- ===========================
			FROM DATA_02.DBO.ccjoblin_sql  (NOLOCK)
			INNER JOIN DATA_02.DBO.ccjobhdr_sql (NOLOCK) ON ccjoblin_sql.jobno = ccjobhdr_sql.jobno 
				--AND ccjobhdr_sql.JOBNO < 50000
			-- ===========================
			INNER JOIN	DATA_02.DBO.cccusitm_sql (NOLOCK) ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
			AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
			AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
															FROM	DATA_02.DBO.cccusitm_sql (NOLOCK)
															WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
															AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)
			-- ===========================
			WHERE LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ CONVERT(VARCHAR(10),ser_no), 3) = @PP_SERIAL --'42282009'
		END
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_PATRON_X_KIT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_PATRON_X_KIT]
GO
/*
 EXECUTE [PG_CB_PATRON_X_KIT] 001,144, 0, 'PWSBRB6VCCAD4', 'FAUR01', 'C3A', '0007'
 EXECUTE [PG_CB_PATRON_X_KIT] 001,144, 0, 'PWLKL2FWLROX7', 'MAGN02', 'WLK', '0012'
*/
CREATE PROCEDURE [dbo].[PG_CB_PATRON_X_KIT]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT,
	@PP_KIT						VARCHAR(50),
	@PP_CLIENTE					VARCHAR(50),
	@PP_MODELO					VARCHAR(50),
	@PP_VERSION					VARCHAR(10)
AS
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50))

	IF SUBSTRING(@PP_KIT, 1, 1) = 'P'
		BEGIN
			INSERT INTO @VP_TA_CATALOGO 
			SELECT	1, (	SELECT TOP 1 LTRIM(RTRIM(CUS.CUS_ITEM_NO)) 
						FROM DATA_02.DBO.cccusitm_sql (NOLOCK) AS CUS 
						WHERE CUS.ITEM_NO = COMP_ITEM_NO 
						AND CUS.CUS_NO = cccusitm_sql.CUS_NO  
						AND CUS.MODELNO = cccusitm_sql.MODELNO AND CUS.VERSIONNO = cccusitm_sql.VERSIONNO) AS CUS_PART_NO
			FROM	DATA_02.DBO.ccprdstr_sql (NOLOCK)
			INNER JOIN DATA_02.DBO.cccusitm_sql (NOLOCK) ON  ccprdstr_sql.CUS_NO = cccusitm_sql.CUS_NO 
				AND ccprdstr_sql.MODELNO = cccusitm_sql.MODELNO
				AND ccprdstr_sql.VERSIONNO = cccusitm_sql.VERSIONNO
				AND ccprdstr_sql.item_no = cccusitm_sql.item_no
			WHERE LTRIM(RTRIM(ccprdstr_sql.item_no))= @PP_KIT
			AND ccprdstr_sql.CUS_NO = @PP_CLIENTE
			AND ccprdstr_sql.MODELNO = @PP_MODELO 
			AND ccprdstr_sql.VERSIONNO = @PP_VERSION
		END
	
	IF ( SUBSTRING(@PP_KIT, 1, 1) = 'U' )  
		BEGIN
			INSERT INTO @VP_TA_CATALOGO 
			SELECT	1, (	SELECT TOP 1 LTRIM(RTRIM(CUS.CUS_ITEM_NO)) 
						FROM DATA_02.DBO.cccusitm_sql (NOLOCK) AS CUS 
						WHERE CUS.ITEM_NO = COMP_ITEM_NO 
						AND CUS.CUS_NO = cccusitm_sql.CUS_NO  
						AND CUS.MODELNO = cccusitm_sql.MODELNO AND CUS.VERSIONNO = cccusitm_sql.VERSIONNO) AS CUS_PART_NO
			FROM	DATA_02.DBO.ccprdstr_sql (NOLOCK)
			INNER JOIN DATA_02.DBO.cccusitm_sql (NOLOCK) ON  ccprdstr_sql.CUS_NO = cccusitm_sql.CUS_NO 
				AND ccprdstr_sql.MODELNO = cccusitm_sql.MODELNO
				AND ccprdstr_sql.VERSIONNO = cccusitm_sql.VERSIONNO
				AND ccprdstr_sql.item_no = cccusitm_sql.item_no
			WHERE LTRIM(RTRIM(ccprdstr_sql.item_no)) IN (  SELECT LTRIM(RTRIM(comp_item_no)) FROM DATA_02.DBO.imkitfil_sql (NOLOCK) WHERE item_no = @PP_KIT )
			AND ccprdstr_sql.CUS_NO = @PP_CLIENTE
			AND ccprdstr_sql.MODELNO = @PP_MODELO 
			AND ccprdstr_sql.VERSIONNO = @PP_VERSION
		END 

	IF @PP_L_CON_TODOS=1
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO	)
			VALUES
				( -1,				'( TODOS )'	)

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
				TA_D_CATALOGO	AS D_COMBOBOX 
		FROM	@VP_TA_CATALOGO
		ORDER BY  TA_D_CATALOGO 

	-- ==========================================
		
	-- ////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_PATRON_X_KIT_V2]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_PATRON_X_KIT_V2]
GO
/*
 EXECUTE [PG_CB_PATRON_X_KIT_V2] 001,144, 0, 'PWSBRB6VCCAD4', 'FAUR01', 'C3A', '0007'
 EXECUTE [PG_CB_PATRON_X_KIT_V2] 001,144, 0, 'PWLKL2FWLROX7', 'MAGN02', 'WLK', '0012'
*/
CREATE PROCEDURE [dbo].[PG_CB_PATRON_X_KIT_V2]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT,
	@PP_KIT						VARCHAR(50),
	@PP_CLIENTE					VARCHAR(50),
	@PP_MODELO					VARCHAR(50),
	@PP_VERSION					VARCHAR(10)
AS
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		VARCHAR(50),
					TA_D_CATALOGO		VARCHAR(50)
				)

	IF SUBSTRING(@PP_KIT, 1, 1) = 'P'
		BEGIN
			INSERT INTO @VP_TA_CATALOGO 
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
						AND CUS.MODELNO = cccusitm_sql.MODELNO AND CUS.VERSIONNO = cccusitm_sql.VERSIONNO) AS CUS_PART_NO
			FROM	DATA_02.DBO.ccprdstr_sql (NOLOCK)
			INNER JOIN DATA_02.DBO.cccusitm_sql (NOLOCK) ON  ccprdstr_sql.CUS_NO = cccusitm_sql.CUS_NO 
				AND ccprdstr_sql.MODELNO = cccusitm_sql.MODELNO
				AND ccprdstr_sql.VERSIONNO = cccusitm_sql.VERSIONNO
				AND ccprdstr_sql.item_no = cccusitm_sql.item_no
			WHERE LTRIM(RTRIM(ccprdstr_sql.item_no))= @PP_KIT
			AND ccprdstr_sql.CUS_NO = @PP_CLIENTE
			AND ccprdstr_sql.MODELNO = @PP_MODELO 
			AND ccprdstr_sql.VERSIONNO = @PP_VERSION
		END
	
	IF ( SUBSTRING(@PP_KIT, 1, 1) = 'U' )  
		BEGIN
			INSERT INTO @VP_TA_CATALOGO 
			SELECT	(	SELECT TOP 1 LTRIM(RTRIM(CUS.ITEM_NO)) 
								FROM DATA_02.DBO.cccusitm_sql (NOLOCK) AS CUS 
								WHERE CUS.ITEM_NO = COMP_ITEM_NO 
								AND CUS.CUS_NO = cccusitm_sql.CUS_NO  
								AND CUS.MODELNO = cccusitm_sql.MODELNO AND CUS.VERSIONNO = cccusitm_sql.VERSIONNO),
					(	SELECT TOP 1 LTRIM(RTRIM(CUS.CUS_ITEM_NO)) 
						FROM DATA_02.DBO.cccusitm_sql (NOLOCK) AS CUS 
						WHERE CUS.ITEM_NO = COMP_ITEM_NO 
						AND CUS.CUS_NO = cccusitm_sql.CUS_NO  
						AND CUS.MODELNO = cccusitm_sql.MODELNO AND CUS.VERSIONNO = cccusitm_sql.VERSIONNO) AS CUS_PART_NO
			FROM	DATA_02.DBO.ccprdstr_sql (NOLOCK)
			INNER JOIN DATA_02.DBO.cccusitm_sql (NOLOCK) ON  ccprdstr_sql.CUS_NO = cccusitm_sql.CUS_NO 
				AND ccprdstr_sql.MODELNO = cccusitm_sql.MODELNO
				AND ccprdstr_sql.VERSIONNO = cccusitm_sql.VERSIONNO
				AND ccprdstr_sql.item_no = cccusitm_sql.item_no
			WHERE LTRIM(RTRIM(ccprdstr_sql.item_no)) IN (  SELECT LTRIM(RTRIM(comp_item_no)) FROM DATA_02.DBO.imkitfil_sql (NOLOCK) WHERE item_no = @PP_KIT )
			AND ccprdstr_sql.CUS_NO = @PP_CLIENTE
			AND ccprdstr_sql.MODELNO = @PP_MODELO 
			AND ccprdstr_sql.VERSIONNO = @PP_VERSION
		END 

	IF @PP_L_CON_TODOS=1
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO	)
			VALUES
				( -1,				'( TODOS )'	)

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
				TA_D_CATALOGO	AS D_COMBOBOX 
		FROM	@VP_TA_CATALOGO
		ORDER BY  TA_D_CATALOGO 

	-- ==========================================
		
	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_DEFECTO_CERTIFICACION_REPORT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_DEFECTO_CERTIFICACION_REPORT]
GO
/*
 EXECUTE [PG_CB_DEFECTO_CERTIFICACION_REPORT] 001,144, 0
*/
CREATE PROCEDURE [dbo].[PG_CB_DEFECTO_CERTIFICACION_REPORT]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50))
	
	INSERT INTO @VP_TA_CATALOGO 
	SELECT 1,
			LTRIM(RTRIM(clave)) 
	FROM PPMS_PEARL.DBO.def (NOLOCK)
	
	IF @PP_L_CON_TODOS=1
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO	)
			VALUES
				( -1,				'( TODOS )'	)

	IF @PP_L_CON_TODOS=0
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO	)
			VALUES
				( -1,				'( S/D )'	)
		

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
				TA_D_CATALOGO	AS D_COMBOBOX 
		FROM	@VP_TA_CATALOGO
		ORDER BY  TA_D_CATALOGO 

	-- ==========================================
		
	-- ////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_TIPO_DEFECTO_CALIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_TIPO_DEFECTO_CALIDAD]
GO
-- EXECUTE [PG_CB_TIPO_DEFECTO_CALIDAD] 001,144, 0

CREATE PROCEDURE [dbo].[PG_CB_TIPO_DEFECTO_CALIDAD]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50))
	
	INSERT INTO @VP_TA_CATALOGO 
	SELECT DISTINCT 1,
			 LTRIM(RTRIM(TIPODEF)) 
	FROM PPMS_PEARL.DBO.def (NOLOCK)
	
	IF @PP_L_CON_TODOS=1
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO	)
			VALUES
				( -1,				'( TODOS )'	)

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
				TA_D_CATALOGO	AS D_COMBOBOX 
		FROM	@VP_TA_CATALOGO
		ORDER BY  TA_D_CATALOGO 

	-- ==========================================
		
	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_CLASIFICACION_DEFECTO_CALIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_CLASIFICACION_DEFECTO_CALIDAD]
GO
-- EXECUTE [PG_CB_CLASIFICACION_DEFECTO_CALIDAD] 001,144, 0

CREATE PROCEDURE [dbo].[PG_CB_CLASIFICACION_DEFECTO_CALIDAD]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50))
	
	INSERT INTO @VP_TA_CATALOGO 
	SELECT DISTINCT 1,
			LTRIM(RTRIM(ISNULL(DESCRIPCION, '( S/C )')))
	FROM PPMS_PEARL.DBO.def (NOLOCK)
	
	--IF @PP_L_CON_TODOS=1
		--INSERT INTO @VP_TA_CATALOGO
		--		( TA_K_CATALOGO,	TA_D_CATALOGO	)
		--	VALUES
		--		( -1,				'(S/C)'	)

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
				TA_D_CATALOGO	AS D_COMBOBOX 
		FROM	@VP_TA_CATALOGO
		ORDER BY  TA_D_CATALOGO 

	-- ==========================================
		
	-- ////////////////////////////////////////////////////
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
