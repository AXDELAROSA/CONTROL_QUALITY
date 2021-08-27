-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			RMA
-- // OPERATION:		CARGA COMBO
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210610
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- ////////			CONTENIDO DEL SP
--	[PG_CB_STATUS_RMA]
--	[PG_CB_STATUS_RMA_PACKING]
--	[PG_CB_TIPO_RMA]
--	[PG_CB_CUSNO_RMA]
---------------------------------	SE MANEJAN CON SIGLAS CUSNO
--	[PG_CB_S_CUSNO_PROGRAM_RMA]
--	[PG_CB_S_CUSNO_MODELNO_RMA]
---------------------------------	SE MANEJAN CON K CUSNO
--	[PG_CB_CUSNO_PROGRAM_RMA]
--	[PG_CB_CUSNO_MODELNO_RMA]

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_STATUS_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_STATUS_RMA]
GO
--		 EXECUTE [dbo].[PG_CB_STATUS_RMA] 0,139,0
--		 EXECUTE [dbo].[PG_CB_STATUS_RMA] 0,139,1
CREATE PROCEDURE [dbo].[PG_CB_STATUS_RMA]
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
	SELECT	K_STATUS_RMA				AS TA_K_CATALOGO,
			D_STATUS_RMA				AS TA_D_CATALOGO,
			O_STATUS_RMA				AS TA_O_CATALOGO,
			0							AS L_DELETED, 
			L_STATUS_RMA				AS L_ACTIVO
	FROM	STATUS_RMA	(NOLOCK)
	ORDER BY O_STATUS_RMA
	
	IF @PP_L_CON_TODOS=0
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( SELECT )',	-999,		   0,			 1				)

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
	ORDER BY TA_O_CATALOGO, TA_D_CATALOGO 
	-- ==========================================		
	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_STATUS_RMA_PACKING]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_STATUS_RMA_PACKING]
GO
--		 EXECUTE [dbo].[PG_CB_STATUS_RMA_PACKING] 0,139,0
--		 EXECUTE [dbo].[PG_CB_STATUS_RMA_PACKING] 0,139,1
CREATE PROCEDURE [dbo].[PG_CB_STATUS_RMA_PACKING]
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
	SELECT	K_STATUS_RMA				AS TA_K_CATALOGO,
			D_STATUS_RMA				AS TA_D_CATALOGO,
			O_STATUS_RMA				AS TA_O_CATALOGO,
			0							AS L_DELETED, 
			L_STATUS_RMA				AS L_ACTIVO
	FROM	STATUS_RMA	(NOLOCK)
	--WHERE	K_STATUS_RMA	IN (13)
	WHERE	K_STATUS_RMA	IN (30)
	ORDER BY O_STATUS_RMA
	
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

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			(
				(CASE 
					WHEN (TA_L_ACTIVO=1 AND TA_L_DELETED=0) THEN '' 
					ELSE '<X> ' 
					END 
				) +		TA_D_CATALOGO 
			) AS D_COMBOBOX
	FROM	@VP_TA_CATALOGO
	ORDER BY TA_O_CATALOGO, TA_D_CATALOGO 
	-- ==========================================		
	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_TIPO_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_TIPO_RMA]
GO
--		 EXECUTE [dbo].[PG_CB_TIPO_RMA] 0,139,0
--		 EXECUTE [dbo].[PG_CB_TIPO_RMA] 0,139,1
CREATE PROCEDURE [dbo].[PG_CB_TIPO_RMA]
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
	SELECT	K_TIPO_RMA				AS TA_K_CATALOGO,
			D_TIPO_RMA				AS TA_D_CATALOGO,
			O_TIPO_RMA				AS TA_O_CATALOGO,
			0							AS L_DELETED, 
			L_TIPO_RMA				AS L_ACTIVO
	FROM	TIPO_RMA	(NOLOCK)
	ORDER BY O_TIPO_RMA
	
	IF @PP_L_CON_TODOS=0
	INSERT INTO @VP_TA_CATALOGO
			( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
	VALUES
			( -1,				'( TODOS )',	-999,		   0,			 1				)

	--IF @PP_L_CON_TODOS=1
	--	INSERT INTO @VP_TA_CATALOGO
	--			( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
	--		VALUES
	--			( -1,				'( TODOS )',	-999,		   0,			 1				)

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			(
				(CASE 
					WHEN (TA_L_ACTIVO=1 AND TA_L_DELETED=0) THEN '' 
					ELSE '<X> ' 
					END 
				) +		TA_D_CATALOGO 
			) AS D_COMBOBOX
	FROM	@VP_TA_CATALOGO
	ORDER BY TA_O_CATALOGO, TA_D_CATALOGO 
	-- ==========================================		
	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> CB / MUESTRA LOS CLIENTES CON VERSIONES ACTIVAS EN PEARL
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_CUSNO_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_CUSNO_RMA]
GO
--		 EXECUTE [dbo].[PG_CB_CUSNO_RMA] 0,0, 0
--		 EXECUTE [dbo].[PG_CB_CUSNO_RMA] 0,0, 1
CREATE PROCEDURE [dbo].[PG_CB_CUSNO_RMA]
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
	IF @PP_L_CON_TODOS=0
	BEGIN
		INSERT INTO @VP_TA_CATALOGO
		SELECT	DISTINCT
				0			,
				CUS_NO		,
				0,	0,	1
		FROM	HEADER_RMA	(NOLOCK)		
	END

	IF @PP_L_CON_TODOS=1
	BEGIN
		INSERT INTO @VP_TA_CATALOGO
		SELECT	DISTINCT
				ARCUSFIL_SQL.A4GLIdentity	,
				CCVERHDR_SQL.CUS_NO			,
				ARCUSFIL_SQL.O_ARCUSFIL		,
				ARCUSFIL_SQL.L_BORRADO		,
				ARCUSFIL_SQL.L_ARCUSFIL		
		FROM	CCVERHDR_SQL		(NOLOCK),
				ARCUSFIL_SQL		(NOLOCK)
		WHERE	CCVERHDR_SQL.STATUS			= 'L'
		AND		CCVERHDR_SQL.SPECSTATUS		= 'U'
		AND		ARCUSFIL_SQL.CUS_NO			= CCVERHDR_SQL.cus_no
		ORDER BY CCVERHDR_SQL.CUS_NO
	END

	IF @PP_L_CON_TODOS IN ( 0 )
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( SELECT )',	-999,		   0,			 1				)

	IF @PP_L_CON_TODOS IN ( 1 )
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( TODOS )',	-999,		   0,			 1				)

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
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_S_CUSNO_PROGRAM_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_S_CUSNO_PROGRAM_RMA]
GO
--		 EXECUTE [dbo].[PG_CB_S_CUSNO_PROGRAM_RMA] 0,139,'MAGN03',0
--		 EXECUTE [dbo].[PG_CB_S_CUSNO_PROGRAM_RMA] 0,139,'MAGN03',1
CREATE PROCEDURE [dbo].[PG_CB_S_CUSNO_PROGRAM_RMA]
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


	IF @PP_L_CON_TODOS=0
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( SELECT )',	-999,		   0,			 1				)

	IF @PP_L_CON_TODOS=1
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( TODOS )',	-999,		   0,			 1				)

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
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_S_CUSNO_MODELNO_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_S_CUSNO_MODELNO_RMA]
GO
--		 EXECUTE [dbo].[PG_CB_S_CUSNO_MODELNO_RMA] 1,139,'MAGN03','WK',0
--		 EXECUTE [dbo].[PG_CB_S_CUSNO_MODELNO_RMA] 1,139,'MAGN02','WL',0
--		 EXECUTE [dbo].[PG_CB_S_CUSNO_MODELNO_RMA] 1,139,'MAGN03','WK',1
--		 EXECUTE [dbo].[PG_CB_S_CUSNO_MODELNO_RMA] 1,139,'MAGN03','WL',1
--		 EXECUTE [dbo].[PG_CB_S_CUSNO_MODELNO_RMA] 1,139,'HOPE01','WD',0
CREATE PROCEDURE [dbo].[PG_CB_S_CUSNO_MODELNO_RMA]
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
	
	IF @PP_L_CON_TODOS=0
	BEGIN
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

	END

	--IF @PP_L_CON_TODOS=1
	--BEGIN
	--	INSERT INTO @VP_TA_CATALOGO
	--	SELECT	DISTINCT
	--			0			,
	--			CUS_NO		,
	--			0,	0,	1
	--	FROM	HEADER_RMA	(NOLOCK)		
	--END

	IF @PP_L_CON_TODOS IN ( 0 )
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( SELECT )',	-999,		   0,			 1				)

	IF @PP_L_CON_TODOS IN ( 1 )
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( TODOS )',	-999,		   0,			 1				)

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


---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> CB / MUESTRA LOS COLORES ACTIVOS POR MODELO
----						 		DE LA VERSIÓN QUE ESTÁ LIVE.
---- //////////////////////////////////////////////////////////////
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_CUSNO_MODELNO_COLOR_RMA]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_CB_CUSNO_MODELNO_COLOR_RMA]
--GO
----		 EXECUTE [dbo].[PG_CB_CUSNO_MODELNO_COLOR_RMA] 0,0, 0
----		 EXECUTE [dbo].[PG_CB_CUSNO_MODELNO_COLOR_RMA] 0,0, 'MAGN03','WKZ',0
--CREATE PROCEDURE [dbo].[PG_CB_CUSNO_MODELNO_COLOR_RMA]
--	@PP_K_SISTEMA_EXE			INT,
--	@PP_K_USUARIO				INT,
--	--============================
--	@PP_CUS_NO					VARCHAR(10),
--	@PP_MODELNO					VARCHAR(10),
--	@PP_L_CON_TODOS				INT
--AS
--	DECLARE @VP_TA_CATALOGO	AS TABLE
--				(	TA_K_CATALOGO		INT,
--					TA_D_CATALOGO		VARCHAR(50),
--					TA_O_CATALOGO		INT,
--					TA_L_DELETED		INT,	
--					TA_L_ACTIVO			INT			 )

--		INSERT INTO @VP_TA_CATALOGO
--		select	--CCVERPRC_SQL.* ,
--				IMITMIDX_SQL.A4GLIDENTITY,
--				colour,
--				0,0,1
--		from	ccverhdr_sql		(NOLOCK),
--				CCVERPRC_SQL		(NOLOCK),
--				imitmidx_sql		(NOLOCK)
--		where	ccverhdr_sql.status			= 'L' -- IN ('A', 'I', 'L' )--( @VP_ccverhdr_sql_status	 )		--= 'L' 
--		AND		ccverhdr_sql.specstatus		= 'U' -- IN ('A', 'C', 'U' )--( @VP_ccverhdr_sql_specstatus )	--= 'U' 
--		AND		CONCAT(ccverhdr_sql.modelno, ccverhdr_sql.versionno ) = CONCAT(CCVERPRC_SQL.modelno, CCVERPRC_SQL.versionno )
--		and		CCVERPRC_SQL.cus_no			=	@PP_CUS_NO	--'magn03'	-- 
--		and		CCVERPRC_SQL.modelno		=	@PP_MODELNO	--'wkz'		-- 
--		and		imitmidx_sql.item_no		=	CCVERPRC_SQL.colour
--		order by ccverhdr_sql.cus_no


--	IF @PP_L_CON_TODOS IN ( 0 )
--		INSERT INTO @VP_TA_CATALOGO
--				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
--			VALUES
--				( -1,				'( SELECT )',	-999,		   0,			 1				)

--	IF @PP_L_CON_TODOS IN ( 1 )
--		INSERT INTO @VP_TA_CATALOGO
--				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
--			VALUES
--				( -1,				'( TODOS )',	-999,		   0,			 1				)

--	-- ==========================================		
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
--	-- ////////////////////////////////////////////////////
--GO

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> CB	/	MUESTRA LOS PROGRAMAS DE ACUERDO AL CLIENTE
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_CUSNO_PROGRAM_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_CUSNO_PROGRAM_RMA]
GO
--		 EXECUTE [dbo].[PG_CB_CUSNO_PROGRAM_RMA] 0,139,'',0
--		 EXECUTE [dbo].[PG_CB_CUSNO_PROGRAM_RMA] 0,139,'',1
--		 EXECUTE [dbo].[PG_CB_CUSNO_PROGRAM_RMA] 0,139,'MAGN03',0
--		 EXECUTE [dbo].[PG_CB_CUSNO_PROGRAM_RMA] 0,139,'MAGN03',1
--		 EXECUTE [dbo].[PG_CB_CUSNO_PROGRAM_RMA] 0,139,19,0
--		 EXECUTE [dbo].[PG_CB_CUSNO_PROGRAM_RMA] 0,139,19,1
CREATE PROCEDURE [dbo].[PG_CB_CUSNO_PROGRAM_RMA]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	--@PP_CUSNO					VARCHAR(6),
	@PP_CUSNO					INT,
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
				--CCVERHDR_SQL.CUS_NO					,
				ARCUSFIL_PROGRAM.S_ARCUSFIL_PROGRAM		,
				ARCUSFIL_PROGRAM.O_ARCUSFIL_PROGRAM		,
				ARCUSFIL_PROGRAM.L_BORRADO				,
				ARCUSFIL_PROGRAM.L_ARCUSFIL_PROGRAM		
		FROM	CCVERHDR_SQL		(NOLOCK),
				ARCUSFIL_SQL		(NOLOCK),
				ARCUSFIL_PROGRAM	(NOLOCK)
		WHERE	CCVERHDR_SQL.STATUS			= 'L'
		AND		CCVERHDR_SQL.SPECSTATUS		= 'U'
		AND		ARCUSFIL_SQL.CUS_NO			= CCVERHDR_SQL.cus_no
		--===================================
		AND		ARCUSFIL_PROGRAM.K_ARCUSFIL	= ARCUSFIL_SQL.A4GLIDENTITY
		AND		ARCUSFIL_SQL.A4GLIdentity	= @PP_CUSNO
		ORDER BY	K_ARCUSFIL_PROGRAM		,S_ARCUSFIL_PROGRAM


	IF @PP_L_CON_TODOS=0
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( SELECT )',	-999,		   0,			 1				)

	IF @PP_L_CON_TODOS=1
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( TODOS )',	-999,		   0,			 1				)

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
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_CUSNO_MODELNO_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_CUSNO_MODELNO_RMA]
GO
--		 EXECUTE [dbo].[PG_CB_CUSNO_MODELNO_RMA] 1,139,43,0
--		 EXECUTE [dbo].[PG_CB_CUSNO_MODELNO_RMA] 1,139,43,1
CREATE PROCEDURE [dbo].[PG_CB_CUSNO_MODELNO_RMA]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_K_PROGRAM				INT,
	@PP_L_CON_TODOS				INT
AS
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50),
					TA_O_CATALOGO		INT,
					TA_L_DELETED		INT,	
					TA_L_ACTIVO			INT			 )
	
	IF @PP_L_CON_TODOS=0
	BEGIN
		INSERT INTO @VP_TA_CATALOGO

		SELECT	DISTINCT
				ARCUSFIL_PROGRAM_MODEL.K_ARCUSFIL_PROGRAM_MODEL		,
				--CCVERHDR_SQL.CUS_NO					,
				CONCAT ( RTRIM(LTRIM(ARCUSFIL_PROGRAM_MODEL.S_ARCUSFIL_PROGRAM_MODEL)),' // ',RTRIM(LTRIM(ARCUSFIL_PROGRAM_MODEL.D_ARCUSFIL_PROGRAM_MODEL)))	,
				10		,
				ARCUSFIL_PROGRAM_MODEL.L_BORRADO					,
				1
		FROM	CCVERHDR_SQL			(NOLOCK),
				ARCUSFIL_SQL			(NOLOCK),
				ARCUSFIL_PROGRAM		(NOLOCK),
				ARCUSFIL_PROGRAM_MODEL	(NOLOCK)
		WHERE	CCVERHDR_SQL.[STATUS]						= 'L'
		AND		CCVERHDR_SQL.SPECSTATUS						= 'U'
		AND		ARCUSFIL_SQL.CUS_NO							= CCVERHDR_SQL.cus_no
		--===================================
		AND		ARCUSFIL_PROGRAM.K_ARCUSFIL					= ARCUSFIL_SQL.A4GLIDENTITY
		AND		ARCUSFIL_PROGRAM_MODEL.K_ARCUSFIL_PROGRAM	= ARCUSFIL_PROGRAM.K_ARCUSFIL_PROGRAM
		AND		ARCUSFIL_PROGRAM_MODEL.K_ARCUSFIL_PROGRAM	= @PP_K_PROGRAM
		---																	-- OBSOLETOS AGREGADOS
		--AND		ARCUSFIL_PROGRAM_MODEL.K_ARCUSFIL_PROGRAM_MODEL	NOT IN (144,145)
		AND		ARCUSFIL_PROGRAM_MODEL.L_BORRADO	= 0
		--ORDER BY	K_ARCUSFIL_PROGRAM_MODEL		,S_ARCUSFIL_PROGRAM_MODEL

	END

	IF @PP_L_CON_TODOS=1
	BEGIN
		INSERT INTO @VP_TA_CATALOGO
		SELECT	DISTINCT
				0			,
				CUS_NO		,
				0,	0,	1
		FROM	HEADER_RMA	(NOLOCK)		
	END

	IF @PP_L_CON_TODOS IN ( 0 )
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( SELECT )',	-999,		   0,			 1				)

	IF @PP_L_CON_TODOS IN ( 1 )
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( TODOS )',	-999,		   0,			 1				)

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