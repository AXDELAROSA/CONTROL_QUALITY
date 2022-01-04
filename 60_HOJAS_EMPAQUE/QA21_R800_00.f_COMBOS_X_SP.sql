-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			HOJA_EMPAQUE
-- // OPERATION:		CARGA COMBO
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20211130
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- ////////			CONTENIDO DEL SP
---------------------------------	SE MANEJAN CON SIGLAS CUSNO
--	[PG_CB_CUSNO_HOJA_EMPAQUE]
--	[PG_CB_PROGRAM_HOJA_EMPAQUE]
--	[PG_CB_MODELNO_HOJA_EMPAQUE]
--	[PG_CB_TIPO_PROCESO_SIMBOLO]
---------------------------------	COMENTADOS
--	[PG_CB_STATUS_HOJA_EMPAQUE]
--	[PG_CB_TIPO_HOJA_EMPAQUE]

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> CB / MUESTRA LOS CLIENTES CON VERSIONES ACTIVAS EN PEARL
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_CUSNO_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_CUSNO_HOJA_EMPAQUE]
GO
--		 EXECUTE [dbo].[PG_CB_CUSNO_HOJA_EMPAQUE] 0,0, 0
--		 EXECUTE [dbo].[PG_CB_CUSNO_HOJA_EMPAQUE] 0,0, 1
CREATE PROCEDURE [dbo].[PG_CB_CUSNO_HOJA_EMPAQUE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50),
					TA_O_CATALOGO		INT,
					TA_L_DELETED		INT,	
					TA_L_ACTIVO			INT			 )
	--IF @PP_L_CON_TODOS=0
	--BEGIN
		INSERT INTO @VP_TA_CATALOGO
		SELECT	DISTINCT
				0			,
				HOJA_EMPAQUE.CUS_NO		,
				0,	
				ARCUSFIL_SQL.L_BORRADO	,	--0,	
				ARCUSFIL_SQL.L_ARCUSFIL		--1
		--FROM	HEADER_HOJA_EMPAQUE	(NOLOCK)		
		FROM	HOJA_EMPAQUE	(NOLOCK)
		INNER JOIN	ARCUSFIL_SQL	(NOLOCK)	ON ARCUSFIL_SQL.CUS_NO	= HOJA_EMPAQUE.CUS_NO
	--END

	--IF @PP_L_CON_TODOS=1
	--BEGIN
	--	INSERT INTO @VP_TA_CATALOGO
	--	SELECT	DISTINCT
	--			ARCUSFIL_SQL.A4GLIdentity	,
	--			CCVERHDR_SQL.CUS_NO			,
	--			ARCUSFIL_SQL.O_ARCUSFIL		,
	--			ARCUSFIL_SQL.L_BORRADO		,
	--			ARCUSFIL_SQL.L_ARCUSFIL		
	--	FROM	CCVERHDR_SQL		(NOLOCK),
	--			ARCUSFIL_SQL		(NOLOCK)
	--	WHERE	CCVERHDR_SQL.STATUS			= 'L'
	--	AND		CCVERHDR_SQL.SPECSTATUS		= 'U'
	--	AND		ARCUSFIL_SQL.CUS_NO			= CCVERHDR_SQL.cus_no
	--	ORDER BY CCVERHDR_SQL.CUS_NO
	--END

	--IF @PP_L_CON_TODOS IN ( 0 )
	--	INSERT INTO @VP_TA_CATALOGO
	--			( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
	--		VALUES
	--			( -1,				'( SELECT )',	-999,		   0,			 1				)

	--IF @PP_L_CON_TODOS IN ( 1 )
	--	INSERT INTO @VP_TA_CATALOGO
	--			( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
	--		VALUES
	--			( -1,				'( TODOS )',	-999,		   0,			 1				)

	-- ==========================================		
	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			(
				(CASE 
					WHEN (TA_L_ACTIVO=1 AND TA_L_DELETED=0) THEN '' 
					ELSE '<X> ' 
					END 
				) +		TA_D_CATALOGO 
			) AS D_COMBOBOX
	FROM	@VP_TA_CATALOGO
	ORDER BY TA_D_CATALOGO ,	TA_O_CATALOGO
	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> CB	/	MUESTRA LOS PROGRAMAS DE ACUERDO AL CLIENTE POR SIGLAS DEL CLIENTE
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_PROGRAM_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_PROGRAM_HOJA_EMPAQUE]
GO
--		 EXECUTE [dbo].[PG_CB_PROGRAM_HOJA_EMPAQUE] 0,139,'MAGN03',0
--		 EXECUTE [dbo].[PG_CB_PROGRAM_HOJA_EMPAQUE] 0,139,'MAGN03',1
CREATE PROCEDURE [dbo].[PG_CB_PROGRAM_HOJA_EMPAQUE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_CUSNO					VARCHAR(6),
	@PP_L_CON_TODOS				INT
AS

	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50),
					TA_O_CATALOGO		INT,
					TA_L_DELETED		INT,	
					TA_L_ACTIVO			INT			 )

		INSERT INTO @VP_TA_CATALOGO
		SELECT	DISTINCT
				ARCUSFIL_PROGRAM.K_ARCUSFIL_PROGRAM		,
				ARCUSFIL_PROGRAM.S_ARCUSFIL_PROGRAM		,
				ARCUSFIL_PROGRAM.O_ARCUSFIL_PROGRAM		,
				ARCUSFIL_PROGRAM.L_BORRADO				,
				ARCUSFIL_PROGRAM.L_ARCUSFIL_PROGRAM		
		--===================================
		FROM	CCVERHDR_SQL		(NOLOCK)
		INNER JOIN ARCUSFIL_SQL		(NOLOCK) ON ARCUSFIL_SQL.CUS_NO			= CCVERHDR_SQL.cus_no
		INNER JOIN ARCUSFIL_PROGRAM	(NOLOCK) ON ARCUSFIL_PROGRAM.CUS_NO		= ARCUSFIL_SQL.CUS_NO
		--===================================
		WHERE	CCVERHDR_SQL.STATUS			= 'L'
		AND		CCVERHDR_SQL.SPECSTATUS		= 'U'
		AND		ARCUSFIL_SQL.CUS_NO			= @PP_CUSNO
		ORDER	BY	K_ARCUSFIL_PROGRAM		,S_ARCUSFIL_PROGRAM


	--IF @PP_L_CON_TODOS=0
	--	INSERT INTO @VP_TA_CATALOGO
	--			( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
	--		VALUES
	--			( -1,				'( SELECT )',	-999,		   0,			 1				)

	--IF @PP_L_CON_TODOS=1
	--	INSERT INTO @VP_TA_CATALOGO
	--			( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
	--		VALUES
	--			( -1,				'( TODOS )',	-999,		   0,			 1				)

	-- ==========================================		
	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			(
				(CASE 
					WHEN (TA_L_ACTIVO=1 AND TA_L_DELETED=0) THEN '' 
					ELSE '<X> ' 
					END 
				) +		TA_D_CATALOGO 
			) AS D_COMBOBOX
	FROM	@VP_TA_CATALOGO
	ORDER BY TA_D_CATALOGO ,	TA_O_CATALOGO
	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> CB / MUESTRA LOS MODELOS POR PROGRAMA ACTIVOS EN PEARL
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_MODELNO_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_MODELNO_HOJA_EMPAQUE]
GO
--		 EXECUTE [dbo].[PG_CB_MODELNO_HOJA_EMPAQUE] 1,139,'MAGN03','WK',0
--		 EXECUTE [dbo].[PG_CB_MODELNO_HOJA_EMPAQUE] 1,139,'MAGN02','WL',0
--		 EXECUTE [dbo].[PG_CB_MODELNO_HOJA_EMPAQUE] 1,139,'MAGN03','WK',1
--		 EXECUTE [dbo].[PG_CB_MODELNO_HOJA_EMPAQUE] 1,139,'MAGN03','WL',1
--		 EXECUTE [dbo].[PG_CB_MODELNO_HOJA_EMPAQUE] 1,139,'HOPE01','WD',0
--		 EXECUTE [dbo].[PG_CB_MODELNO_HOJA_EMPAQUE] 1,139,'IRVI02','JT',0
--		 EXECUTE [dbo].[PG_CB_MODELNO_HOJA_EMPAQUE] 1,139,'IRVI02','JT',1
CREATE PROCEDURE [dbo].[PG_CB_MODELNO_HOJA_EMPAQUE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_CUSNO					VARCHAR(6),
	@PP_S_PROGRAM				VARCHAR(50),
	@PP_L_CON_TODOS				INT
AS
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50),
					TA_O_CATALOGO		INT,
					TA_L_DELETED		INT,	
					TA_L_ACTIVO			INT			 )
	
	--IF @PP_L_CON_TODOS=0
	--BEGIN
		INSERT INTO @VP_TA_CATALOGO
		SELECT	DISTINCT
				ARCUSFIL_PROGRAM_MODEL.K_ARCUSFIL_PROGRAM_MODEL	,
				---CCVERHDR_SQL.CUS_NO					,
				CONCAT ( RTRIM(LTRIM(ARCUSFIL_PROGRAM_MODEL.S_ARCUSFIL_PROGRAM_MODEL)),' // ',RTRIM(LTRIM(ARCUSFIL_PROGRAM_MODEL.D_ARCUSFIL_PROGRAM_MODEL)))	,
				10		,
				ARCUSFIL_PROGRAM_MODEL.L_BORRADO					,
				1
		FROM	CCVERHDR_SQL				(NOLOCK)
		INNER JOIN ARCUSFIL_SQL				(NOLOCK) ON ARCUSFIL_SQL.CUS_NO								= CCVERHDR_SQL.cus_no
		INNER JOIN ARCUSFIL_PROGRAM			(NOLOCK) ON ARCUSFIL_PROGRAM.CUS_NO							= ARCUSFIL_SQL.CUS_NO
		INNER JOIN ARCUSFIL_PROGRAM_MODEL	(NOLOCK) ON ARCUSFIL_PROGRAM_MODEL.S_ARCUSFIL_PROGRAM		= ARCUSFIL_PROGRAM.S_ARCUSFIL_PROGRAM
		AND			ARCUSFIL_PROGRAM_MODEL.CUS_NO	= ARCUSFIL_SQL.CUS_NO
		WHERE	CCVERHDR_SQL.[STATUS]						= 'L'
		AND		CCVERHDR_SQL.SPECSTATUS						= 'U'
		--===================================
		AND		ARCUSFIL_PROGRAM_MODEL.CUS_NO				= @PP_CUSNO
		AND		ARCUSFIL_PROGRAM_MODEL.S_ARCUSFIL_PROGRAM	= @PP_S_PROGRAM
		AND		ARCUSFIL_PROGRAM_MODEL.L_BORRADO	= 0

	--END

	--IF @PP_L_CON_TODOS=1
	--BEGIN
	--	INSERT INTO @VP_TA_CATALOGO
	--	SELECT	DISTINCT
	--			0			,
	--			CUS_NO		,
	--			0,	0,	1
	--	FROM	HEADER_HOJA_EMPAQUE	(NOLOCK)		
	--END

	--IF @PP_L_CON_TODOS IN ( 0 )
	--	INSERT INTO @VP_TA_CATALOGO
	--			( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
	--		VALUES
	--			( -1,				'( SELECT )',	-999,		   0,			 1				)

	--IF @PP_L_CON_TODOS IN ( 1 )
	--	INSERT INTO @VP_TA_CATALOGO
	--			( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
	--		VALUES
	--			( -1,				'( TODOS )',	-999,		   0,			 1				)

	-- ==========================================		
	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			(
				(CASE 
					WHEN (TA_L_ACTIVO=1 AND TA_L_DELETED=0) THEN '' 
					ELSE '<X> ' 
					END 
				) +		TA_D_CATALOGO 
			) AS D_COMBOBOX
	FROM	@VP_TA_CATALOGO
	ORDER BY TA_D_CATALOGO ,	TA_O_CATALOGO
	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_TIPO_PROCESO_SIMBOLO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_TIPO_PROCESO_SIMBOLO]
GO
--		 EXECUTE [dbo].[PG_CB_TIPO_PROCESO_SIMBOLO] 0,139,0
--		 EXECUTE [dbo].[PG_CB_TIPO_PROCESO_SIMBOLO] 0,139,1
CREATE PROCEDURE [dbo].[PG_CB_TIPO_PROCESO_SIMBOLO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50),
					TA_O_CATALOGO		INT,
					TA_L_DELETED		INT,	
					TA_L_ACTIVO			INT			 )

	INSERT INTO @VP_TA_CATALOGO
	SELECT	K_TIPO_PROCESO_SIMBOLO		AS TA_K_CATALOGO,
			D_TIPO_PROCESO_SIMBOLO		AS TA_D_CATALOGO,
			O_TIPO_PROCESO_SIMBOLO		AS TA_O_CATALOGO,
			0							AS L_DELETED, 
			1							AS L_ACTIVO
	FROM	TIPO_PROCESO_SIMBOLO		(NOLOCK)
	--ORDER BY O_TIPO_PROCESO_SIMBOLO ASC , D_TIPO_PROCESO_SIMBOLO
	
	IF @PP_L_CON_TODOS=0
	INSERT INTO @VP_TA_CATALOGO
			( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
	VALUES
			( -1,				'( SELECCIONAR )',	-999,		   0,			 1				)

	IF @PP_L_CON_TODOS=1
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( TODOS )',	-999,		   0,			 1				)

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			(
				(CASE 
					WHEN (TA_L_ACTIVO=1 AND TA_L_DELETED=0) THEN '' 
					ELSE '<X> ' 
					END 
				) +		TA_D_CATALOGO 
			) AS D_COMBOBOX
	FROM	@VP_TA_CATALOGO
	ORDER BY TA_O_CATALOGO , TA_D_CATALOGO 
	-- ==========================================		
	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_STATUS_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_CB_STATUS_HOJA_EMPAQUE]
--GO
----		 EXECUTE [dbo].[PG_CB_STATUS_HOJA_EMPAQUE] 0,139,0
----		 EXECUTE [dbo].[PG_CB_STATUS_HOJA_EMPAQUE] 0,139,1
--CREATE PROCEDURE [dbo].[PG_CB_STATUS_HOJA_EMPAQUE]
--	@PP_K_SISTEMA_EXE			INT,
--	@PP_K_USUARIO				INT,
--	--============================
--	@PP_L_CON_TODOS				INT
--AS

--	DECLARE @VP_TA_CATALOGO	AS TABLE
--				(	TA_K_CATALOGO		INT,
--					TA_D_CATALOGO		VARCHAR(50),
--					TA_O_CATALOGO		INT,
--					TA_L_DELETED		INT,	
--					TA_L_ACTIVO			INT			 )

--	INSERT INTO @VP_TA_CATALOGO
--	SELECT	K_STATUS_HOJA_EMPAQUE				AS TA_K_CATALOGO,
--			D_STATUS_HOJA_EMPAQUE				AS TA_D_CATALOGO,
--			O_STATUS_HOJA_EMPAQUE				AS TA_O_CATALOGO,
--			0							AS L_DELETED, 
--			L_STATUS_HOJA_EMPAQUE				AS L_ACTIVO
--	FROM	STATUS_HOJA_EMPAQUE	(NOLOCK)
--	WHERE	K_STATUS_HOJA_EMPAQUE		<=	40
--	ORDER BY O_STATUS_HOJA_EMPAQUE
	
--	IF @PP_L_CON_TODOS=0
--		INSERT INTO @VP_TA_CATALOGO
--				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
--			VALUES
--				( -1,				'( SELECT )',	-999,		   0,			 1				)

--	IF @PP_L_CON_TODOS=1
--		INSERT INTO @VP_TA_CATALOGO
--				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
--			VALUES
--				( -1,				'( TODOS )',	-999,		   0,			 1				)

--	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
--			(
--				(CASE 
--					WHEN (TA_L_ACTIVO=1 AND TA_L_DELETED=0) THEN '' 
--					ELSE '<X> ' 
--					END 
--				) +		TA_D_CATALOGO 
--			) AS D_COMBOBOX
--	FROM	@VP_TA_CATALOGO
--	ORDER BY TA_O_CATALOGO, TA_D_CATALOGO 
--	-- ==========================================		
--	-- ////////////////////////////////////////////////////
--GO


---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> SELECT / LISTADO
---- //////////////////////////////////////////////////////////////
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_TIPO_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_CB_TIPO_HOJA_EMPAQUE]
--GO
----		 EXECUTE [dbo].[PG_CB_TIPO_HOJA_EMPAQUE] 0,139,0
----		 EXECUTE [dbo].[PG_CB_TIPO_HOJA_EMPAQUE] 0,139,1
--CREATE PROCEDURE [dbo].[PG_CB_TIPO_HOJA_EMPAQUE]
--	@PP_K_SISTEMA_EXE			INT,
--	@PP_K_USUARIO				INT,
--	--============================
--	@PP_L_CON_TODOS				INT
--AS

--	DECLARE @VP_TA_CATALOGO	AS TABLE
--				(	TA_K_CATALOGO		INT,
--					TA_D_CATALOGO		VARCHAR(50),
--					TA_O_CATALOGO		INT,
--					TA_L_DELETED		INT,	
--					TA_L_ACTIVO			INT			 )

--	INSERT INTO @VP_TA_CATALOGO
--	SELECT	K_TIPO_HOJA_EMPAQUE				AS TA_K_CATALOGO,
--			D_TIPO_HOJA_EMPAQUE				AS TA_D_CATALOGO,
--			O_TIPO_HOJA_EMPAQUE				AS TA_O_CATALOGO,
--			0							AS L_DELETED, 
--			L_TIPO_HOJA_EMPAQUE				AS L_ACTIVO
--	FROM	TIPO_HOJA_EMPAQUE	(NOLOCK)
--	ORDER BY O_TIPO_HOJA_EMPAQUE
	
--	IF @PP_L_CON_TODOS=0
--	INSERT INTO @VP_TA_CATALOGO
--			( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
--	VALUES
--			( -1,				'( TODOS )',	-999,		   0,			 1				)

--	--IF @PP_L_CON_TODOS=1
--	--	INSERT INTO @VP_TA_CATALOGO
--	--			( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
--	--		VALUES
--	--			( -1,				'( TODOS )',	-999,		   0,			 1				)

--	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
--			(
--				(CASE 
--					WHEN (TA_L_ACTIVO=1 AND TA_L_DELETED=0) THEN '' 
--					ELSE '<X> ' 
--					END 
--				) +		TA_D_CATALOGO 
--			) AS D_COMBOBOX
--	FROM	@VP_TA_CATALOGO
--	ORDER BY TA_O_CATALOGO, TA_D_CATALOGO 
--	-- ==========================================		
--	-- ////////////////////////////////////////////////////
--GO


-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////