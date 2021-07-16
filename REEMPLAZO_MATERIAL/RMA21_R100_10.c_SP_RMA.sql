-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			RMA
-- // OPERATION:		SP'S
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210609
-- ////////////////////////////////////////////////////////////// 

USE	[DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- //////		CONTENIDO DEL SP
--	[PG_LI_HEADER_RMA]
--	[PG_LI_DETAILS_RMA]
--	[PG_LI_COLOR_RMA]
--	[PG_LI_COLOR_KIT_RMA]
--	[PG_LI_COLOR_KIT_PATTERN_RMA]
--	[PG_LI_DEFECTO_RMA]
--	[PG_SK_HEADER_RMA]
--	[PG_SK_DETAILS_RMA]
--	[PG_SK_DEFECTO_RMA]
--	[PG_SK_NOTIFICACION_RMA]
--	[PG_IN_HEADER_RMA]
--	[PG_UP_HEADER_RMA]
--	[PG_INUP_DETAILS_RMA]
--	[PG_UP_ESTATUS_RMA]
--	[PG_DL_HEADER_RMA]
--	[PG_ERROR_GENERAR_ORDEN_RMA]
-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HEADER_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HEADER_RMA]
GO
--		 EXECUTE [dbo].[PG_LI_HEADER_RMA] 0,47,'',-1,'( TODOS )',null,null
--		 EXECUTE [dbo].[PG_LI_HEADER_RMA] 0,43,'',-1,'( TODOS )',null,null
--		 EXECUTE [dbo].[PG_LI_HEADER_RMA] 0,56,'',-1,'( TODOS )',null,null
--		 EXECUTE [dbo].[PG_LI_HEADER_RMA] 0,139,'',-1,'( TODOS )',null,null
CREATE PROCEDURE [dbo].[PG_LI_HEADER_RMA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_BUSCAR						VARCHAR(25),
	@PP_K_STATUS_RMA				INT,
	@PP_CUS_NO						VARCHAR(20),
	--@PP_MODELNO						VARCHAR(25),
	@PP_F_INIT						DATE,
	@PP_F_FINISH					DATE
AS

		-----	47: MIGUELC		//	43: JORGEH		//	139:ALEJANDROD
		--IF @PP_K_USUARIO_ACCION IN ( 139 )
		--	SET	@PP_K_STATUS_RMA	= @PP_K_STATUS_RMA
		--ELSE IF @PP_K_USUARIO_ACCION IN ( 47 )
		--	SET	@PP_K_STATUS_RMA	= 2
		--ELSE IF @PP_K_USUARIO_ACCION IN ( 43 ) 
		--	SET	@PP_K_STATUS_RMA	= 4

	-- /////////////////////////////////////////////////////////////////////
	IF @PP_K_USUARIO_ACCION	= 43 OR @PP_K_USUARIO_ACCION	= 139
	BEGIN
		SELECT		TOP (1000)
					-- =============================	 
					--F_CREACION_RMA,	--F_ENTREGA_RMA,	--MODELNO,	--VERSIONNO,
					-- =============================
					(SELECT COUNT(K_DETAILS_RMA) FROM DETAILS_RMA (NOLOCK) WHERE	DETAILS_RMA.K_HEADER_RMA	= HEADER_RMA.K_HEADER_RMA) AS PATTERNS,
					(SELECT SUM(CANTIDAD_ORDENADA) FROM DETAILS_RMA (NOLOCK) WHERE	DETAILS_RMA.K_HEADER_RMA	= HEADER_RMA.K_HEADER_RMA) AS CANTIDAD,
					HEADER_RMA.JOBNO	AS JOBNOS_ARRAY,
					( CASE
						WHEN	L_APLICA_COBRO = 1 THEN 'SÍ'
						ELSE	'NO'
					END	)	AS APLICA_COBRO,
					-- =============================
					S_STATUS_RMA	, D_STATUS_RMA,
					S_TIPO_RMA		, D_TIPO_RMA,
					HEADER_RMA.CUS_NO,
					-- =============================
					HEADER_RMA.*
					-- =============================	
		FROM		HEADER_RMA		(NOLOCK) 
		INNER JOIN 	STATUS_RMA		(NOLOCK) ON STATUS_RMA.K_STATUS_RMA		= HEADER_RMA.K_STATUS_RMA
		INNER JOIN 	TIPO_RMA		(NOLOCK) ON TIPO_RMA.K_TIPO_RMA			= HEADER_RMA.K_TIPO_RMA
		INNER JOIN	BD_GENERAL.DBO.USUARIO_PEARL		(NOLOCK) ON USUARIO_PEARL.K_USUARIO_PEARL	= HEADER_RMA.K_USUARIO_ALTA
					-- =============================
		WHERE		(	HEADER_RMA.K_HEADER_RMA				= @PP_BUSCAR
					OR	C_RMA								LIKE '%'+@PP_BUSCAR+'%'	)
					-- =============================
		AND			( @PP_F_INIT IS NULL		OR	@PP_F_INIT<=F_CREACION_RMA)
		AND			( @PP_F_FINISH IS NULL		OR	@PP_F_FINISH>=F_CREACION_RMA)
					-- =============================
		--	AND			( HEADER_RMA.K_STATUS_RMA IN (4,5,6,7,8,9,11) )
		AND			( @PP_CUS_NO		= '( TODOS )'		OR	HEADER_RMA.CUS_NO		= @PP_CUS_NO )
		AND			( @PP_K_STATUS_RMA	= -1				OR	HEADER_RMA.K_STATUS_RMA	= @PP_K_STATUS_RMA )
		--AND			( @PP_MODELNO	= '( TODOS )'		OR	HEADER_RMA.MODELNO	= @PP_MODELNO )
		--AND			USUARIO_PEARL.K_USUARIO_DEPARTAMENTO	=	(	SELECT K_USUARIO_DEPARTAMENTO FROM BD_GENERAL.DBO.USUARIO_PEARL WHERE K_USUARIO_PEARL = @PP_K_USUARIO_ACCION  )
					-- =============================
		AND			HEADER_RMA.L_BORRADO	<> 1
		ORDER BY	K_STATUS_RMA	DESC,	F_CREACION_RMA	DESC
	END
	ELSE
	BEGIN
		SELECT		TOP (1000)
					-- =============================	 
					--F_CREACION_RMA,	--F_ENTREGA_RMA,	--MODELNO,	--VERSIONNO,
					-- =============================
					(SELECT COUNT(K_DETAILS_RMA) FROM DETAILS_RMA (NOLOCK) WHERE	DETAILS_RMA.K_HEADER_RMA	= HEADER_RMA.K_HEADER_RMA) AS PATTERNS,
					(SELECT SUM(CANTIDAD_ORDENADA) FROM DETAILS_RMA (NOLOCK) WHERE	DETAILS_RMA.K_HEADER_RMA	= HEADER_RMA.K_HEADER_RMA) AS CANTIDAD,
					HEADER_RMA.JOBNO	AS JOBNOS_ARRAY,
					( CASE
						WHEN	L_APLICA_COBRO = 1 THEN 'SÍ'
						ELSE	'NO'
					END	)	AS APLICA_COBRO,
					-- =============================
					S_STATUS_RMA	, D_STATUS_RMA,
					S_TIPO_RMA		, D_TIPO_RMA,
					HEADER_RMA.CUS_NO,
					-- =============================
					HEADER_RMA.*
					-- =============================	
		FROM		HEADER_RMA		(NOLOCK) 
		INNER JOIN 	STATUS_RMA		(NOLOCK) ON STATUS_RMA.K_STATUS_RMA		= HEADER_RMA.K_STATUS_RMA
		INNER JOIN 	TIPO_RMA		(NOLOCK) ON TIPO_RMA.K_TIPO_RMA			= HEADER_RMA.K_TIPO_RMA
		INNER JOIN	BD_GENERAL.DBO.USUARIO_PEARL		(NOLOCK) ON USUARIO_PEARL.K_USUARIO_PEARL	= HEADER_RMA.K_USUARIO_ALTA
					-- =============================
		WHERE		(	HEADER_RMA.K_HEADER_RMA				= @PP_BUSCAR
					OR	C_RMA								LIKE '%'+@PP_BUSCAR+'%'	)
					-- =============================
		AND			( @PP_F_INIT IS NULL		OR	@PP_F_INIT<=F_CREACION_RMA)
		AND			( @PP_F_FINISH IS NULL		OR	@PP_F_FINISH>=F_CREACION_RMA)
					-- =============================
		--	AND			( HEADER_RMA.K_STATUS_RMA IN (4,5,6,7,8,9,11) )
		AND			( @PP_CUS_NO		= '( TODOS )'		OR	HEADER_RMA.CUS_NO		= @PP_CUS_NO )
		AND			( @PP_K_STATUS_RMA	= -1				OR	HEADER_RMA.K_STATUS_RMA	= @PP_K_STATUS_RMA )
		--AND			( @PP_MODELNO	= '( TODOS )'		OR	HEADER_RMA.MODELNO	= @PP_MODELNO )
		AND			USUARIO_PEARL.K_USUARIO_DEPARTAMENTO	=	(	SELECT K_USUARIO_DEPARTAMENTO FROM BD_GENERAL.DBO.USUARIO_PEARL WHERE K_USUARIO_PEARL = @PP_K_USUARIO_ACCION  )
					-- =============================
		AND			HEADER_RMA.L_BORRADO	<> 1
		ORDER BY	K_STATUS_RMA	DESC,	F_CREACION_RMA	DESC
	END
	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA LOS PATTERN DE LOS KIT DE LOS COLORES ACTIVOS POR MODELO.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_DETAILS_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_DETAILS_RMA]
GO
--		 EXECUTE [dbo].[PG_LI_DETAILS_RMA] 0,139, 17
CREATE PROCEDURE [dbo].[PG_LI_DETAILS_RMA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_HEADER_RMA				INT
AS

	SELECT	DETAILS_RMA.ITEM_NO				AS S_PATTERN,
			LTRIM(RTRIM(SEARCH_DESC))		AS D_PATTERN,
			(	SELECT TOP (1) ITEM_NO 
				FROM	CCPRDSTR_SQL
				WHERE	ccprdstr_sql.CUS_NO	= DETAILS_RMA.CUS_NO
				AND		ccprdstr_sql.MODELNO	= DETAILS_RMA.MODELNO
				AND		ccprdstr_sql.VERSIONNO	= DETAILS_RMA.VERSIONNO	
				AND		ccprdstr_sql.COMP_ITEM_NO	= DETAILS_RMA.ITEM_NO					
				) AS KIT,
			[DETAILS_RMA].* 
	FROM	[DETAILS_RMA]		(NOLOCK)
	INNER JOIN	IMITMIDX_SQL	(NOLOCK)	ON IMITMIDX_SQL.ITEM_NO	= DETAILS_RMA.ITEM_NO
	WHERE	DETAILS_RMA.K_HEADER_RMA	=	@PP_K_HEADER_RMA

GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA LOS COLORES ACTIVOS POR MODELO
--						 	DE LA VERSIÓN QUE ESTÁ LIVE.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_COLOR_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_COLOR_RMA]
GO
--		 EXECUTE [dbo].[PG_LI_COLOR_RMA] 0,139,'IRVI02','JLI'
CREATE PROCEDURE [dbo].[PG_LI_COLOR_RMA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUS_NO					VARCHAR(10),
	@PP_MODELNO					VARCHAR(10)
AS

	SET @PP_MODELNO = LTRIM(RTRIM(LEFT(@PP_MODELNO,3)))
	-- ///////////////////////////////////////////
		SELECT	IMITMIDX_SQL.A4GLIDENTITY				AS K_COLOR,
				LTRIM(RTRIM(IMITMIDX_SQL.ITEM_DESC_1))	AS D_COLOR,
				LTRIM(RTRIM(colour))					AS S_COLOR,
				@PP_CUS_NO								AS CUS_NO,
				@PP_MODELNO								AS MODELNO,
				LTRIM(RTRIM(ccverhdr_sql.versionno))	AS VERSIONNO
		FROM	ccverhdr_sql		(NOLOCK),
				CCVERPRC_SQL		(NOLOCK),
				imitmidx_sql		(NOLOCK)
		WHERE	ccverhdr_sql.status			= 'L' -- IN ('A', 'I', 'L' )--( @VP_ccverhdr_sql_status	 )		--= 'L' 
		AND		ccverhdr_sql.specstatus		= 'U' -- IN ('A', 'C', 'U' )--( @VP_ccverhdr_sql_specstatus )	--= 'U' 
		AND		CONCAT(ccverhdr_sql.modelno, ccverhdr_sql.versionno ) = CONCAT(CCVERPRC_SQL.modelno, CCVERPRC_SQL.versionno )
		AND		CCVERPRC_SQL.cus_no			=	@PP_CUS_NO	--'magn03'	-- 
		AND		CCVERPRC_SQL.modelno		=	@PP_MODELNO	--'wkz'		-- 
		AND		imitmidx_sql.item_no		=	CCVERPRC_SQL.colour
		ORDER BY ccverhdr_sql.cus_no
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA LOS KIT DE LOS COLORES ACTIVOS POR MODELO.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_COLOR_KIT_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_COLOR_KIT_RMA]
GO
--		 EXECUTE [dbo].[PG_LI_COLOR_KIT_RMA] 0,139,'MAGN03','WKZ','0018', 'FCNPDX9'
--		 EXECUTE [dbo].[PG_LI_COLOR_KIT_RMA] 0,139,'MAGN03','WKL','0009', 'FCPRDX9'
CREATE PROCEDURE [dbo].[PG_LI_COLOR_KIT_RMA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUS_NO					VARCHAR(15),
	@PP_MODELNO					VARCHAR(15),
	@PP_VERSIONNO				VARCHAR(6),
	@PP_S_COLOR					VARCHAR(15)
AS
	DECLARE		@VP_VERSIONNO_BD	AS VARCHAR(6)

		SELECT	DISTINCT
				@VP_VERSIONNO_BD			= CCVERHDR_SQL.VERSIONNO
		FROM	CCVERHDR_SQL		(NOLOCK)
		WHERE	CCVERHDR_SQL.STATUS			= 'L' -- IN ('A', 'I', 'L' )--( @VP_CCVERHDR_SQL_STATUS	 )		--= 'L' 
		AND		CCVERHDR_SQL.SPECSTATUS		= 'U' -- IN ('A', 'C', 'U' )--( @VP_CCVERHDR_SQL_SPECSTATUS )	--= 'U' 
		AND		CCVERHDR_SQL.CUS_NO			=	@PP_CUS_NO	--	'MAGN03'	-- 
		AND		CCVERHDR_SQL.MODELNO		=	@PP_MODELNO	--	'WKZ'		-- 

	-- ///////////////////////////////////////////
	IF @VP_VERSIONNO_BD	= @PP_VERSIONNO
	BEGIN
		SELECT	 LTRIM(RTRIM(CCCUSITM_SQL.ITEM_NO))		AS S_KIT
				,LTRIM(RTRIM(CUS_ITEM_NO))				AS CUS_ITEM_NO
				,LTRIM(RTRIM(ITEM_DESC_1))				AS D_KIT
				,@PP_CUS_NO				AS CUS_NO
				,@PP_MODELNO			AS MODELNO
				,@PP_VERSIONNO			AS VERSIONNO
				,''						AS MENSAJE
		FROM	CCCUSITM_SQL			(NOLOCK)
				,IMITMIDX_SQL			(NOLOCK)
		WHERE	IMITMIDX_SQL.item_no		= CCCUSITM_SQL.ITEM_NO
		AND		CUS_NO						=	@PP_CUS_NO			--	'MAGN03'	--
		AND		MODELNO						=	@PP_MODELNO			--	'WKZ'		--
		AND		VERSIONNO					=	@PP_VERSIONNO		--	'0018'		--
		AND		CCCUSITM_SQL.ITEM_NO		LIKE 'P%' + RIGHT(LTRIM(RTRIM(@PP_S_COLOR)),6)
	END
	ELSE
	BEGIN
		SELECT 'Registro no encontrado, versión del [KIT]. VerBD[' + @VP_VERSIONNO_BD + ']  //   VerSIS[' + @PP_VERSIONNO + '], verifique...'	AS MENSAJE
	END

GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA LOS PATTERN DE LOS KIT DE LOS COLORES ACTIVOS POR MODELO.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_COLOR_KIT_PATTERN_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_COLOR_KIT_PATTERN_RMA]
GO
--		 EXECUTE [dbo].[PG_LI_COLOR_KIT_PATTERN_RMA] 0,139,'MAGN03','WKZ','0018', 'PMDZFCLCNPDX9','173612R'
--		 EXECUTE [dbo].[PG_LI_COLOR_KIT_PATTERN_RMA] 0,139,'MAGN03','WKL','0009', 'PMWKLK6CPRDX9','174372A'
CREATE PROCEDURE [dbo].[PG_LI_COLOR_KIT_PATTERN_RMA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUS_NO					VARCHAR(15),
	@PP_MODELNO					VARCHAR(15),
	@PP_VERSIONNO				VARCHAR(6),
	--@PP_S_COLOR					VARCHAR(15),
	@PP_S_KIT					VARCHAR(15),
	@PP_CUS_ITEM_NO				VARCHAR(25)
AS
	DECLARE		@VP_VERSIONNO_BD	AS VARCHAR(6)

		SELECT	DISTINCT
				@VP_VERSIONNO_BD			= CCVERHDR_SQL.VERSIONNO
		FROM	CCVERHDR_SQL		(NOLOCK)
		WHERE	CCVERHDR_SQL.STATUS			= 'L' -- IN ('A', 'I', 'L' )--( @VP_CCVERHDR_SQL_STATUS	 )		--= 'L' 
		AND		CCVERHDR_SQL.SPECSTATUS		= 'U' -- IN ('A', 'C', 'U' )--( @VP_CCVERHDR_SQL_SPECSTATUS )	--= 'U' 
		AND		CCVERHDR_SQL.CUS_NO			=	@PP_CUS_NO	--	'MAGN03'	-- 
		AND		CCVERHDR_SQL.MODELNO		=	@PP_MODELNO	--	'WKZ'		-- 

	-- ///////////////////////////////////////////
	IF @VP_VERSIONNO_BD	= @PP_VERSIONNO
	BEGIN
		
		IF	(	SELECT	COUNT(ITEM_NO)
				FROM	CCCUSITM_SQL	(NOLOCK)
				WHERE	LTRIM(RTRIM(CCCUSITM_SQL.CUS_ITEM_NO))	= @PP_CUS_ITEM_NO	)	< 1
		BEGIN
			SELECT 'El Customer Part Number [BD], no coincide con el mostrado en SISTEMA, verifique...' AS MENSAJE
		END

			SELECT	 LTRIM(RTRIM(CCCUSITM_SQL.ITEM_NO))		AS S_PATTERN
					,LTRIM(RTRIM(CUS_ITEM_NO))				AS CUS_ITEM_NO
					,LTRIM(RTRIM(ITEM_DESC_1))				AS D_PATTERN
					,@PP_CUS_NO								AS CUS_NO
					,@PP_MODELNO							AS MODELNO
					,@PP_VERSIONNO							AS VERSIONNO
					,''										AS MENSAJE
					,cube_width								AS NET_AREA
					,cube_length							AS GROSS_AREA
			FROM	CCCUSITM_SQL				(NOLOCK)
					,IMITMIDX_SQL				(NOLOCK)
			WHERE	IMITMIDX_SQL.item_no		= CCCUSITM_SQL.ITEM_NO
			AND		CUS_NO						=	@PP_CUS_NO			--	'MAGN03'	--
			AND		MODELNO						=	@PP_MODELNO			--	'WKZ'		--
			AND		VERSIONNO					=	@PP_VERSIONNO		--	'0018'		--
			AND		LTRIM(RTRIM(CCCUSITM_SQL.ITEM_NO))	IN	(
															SELECT	COMP_ITEM_NO
															FROM	[DATA_02].[DBO].ccprdstr_sql	(NOLOCK)
															where	item_no				= @PP_S_KIT
															AND		CUS_NO				=	@PP_CUS_NO			--	'MAGN03'	--
															AND		MODELNO				=	@PP_MODELNO			--	'WKZ'		--
															AND		VERSIONNO			=	@PP_VERSIONNO		--	'0018'		--
															)		
	END
	ELSE
	BEGIN
		SELECT 'Se ha publicado una nueva versión del [MODELO] seleccionado, cierre y vuelva a abrir la ficha para actualizar.' AS MENSAJE
	END
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_DEFECTO_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_DEFECTO_RMA]
GO
--		 EXECUTE [dbo].[PG_LI_DEFECTO_RMA] 0,139,0
--		 EXECUTE [dbo].[PG_LI_DEFECTO_RMA] 0,139,1
CREATE PROCEDURE [dbo].[PG_LI_DEFECTO_RMA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_TODOS						INT
AS

	-- ///////////////////////////////////////////
	SELECT	RTRIM(LTRIM(DEFECTO))			AS D_DEFECTO_RMA,
			RTRIM(LTRIM(CLAVE))				AS CLAVE_DEFECTO_RMA,
			RTRIM(LTRIM(TIPODEF))			AS TIPO_DEFECTO_RMA,
			RTRIM(LTRIM(DESCRIPCION))		AS ORIGEN_DEFECTO_RMA
	FROM	PPMS_PEARL.DBO.DEF	(NOLOCK)

	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_HEADER_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_HEADER_RMA]
GO
--		 EXECUTE [dbo].[PG_SK_HEADER_RMA] 0,139,7
CREATE PROCEDURE [dbo].[PG_SK_HEADER_RMA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_HEADER_RMA				INT
AS
	-- ///////////////////////////////////////////			
	DECLARE @K_ARCUSFIL				INT
			,@K_ARCUSFIL_PROGRAM	INT
			,@CB_ARCUSFIL_PROGRAM	VARCHAR(250)

	--SELECT	@K_ARCUSFIL	= K_ARCUSFIL
	--FROM	ARCUSFIL_SQL
	--WHERE	ARCUSFIL_SQL.CUS_NO	= HEADER_RMA.CUS_NO

	--SELECT	@K_ARCUSFIL_PROGRAM	= K_ARCUSFIL_PROGRAM 
	--FROM	ARCUSFIL_PROGRAM		(NOLOCK)
	--INNER JOIN	HEADER_RMA			(NOLOCK) ON HEADER_RMA.PROGRAM	= S_ARCUSFIL_PROGRAM 
	--AND		HEADER_RMA.K_HEADER_RMA			= @PP_K_HEADER_RMA

	SELECT	@CB_ARCUSFIL_PROGRAM = RTRIM(LTRIM(S_ARCUSFIL_PROGRAM_MODEL)) + ' // ' + RTRIM(LTRIM(D_ARCUSFIL_PROGRAM_MODEL))
	FROM	ARCUSFIL_PROGRAM_MODEL		(NOLOCK)
	INNER JOIN	HEADER_RMA				(NOLOCK) ON HEADER_RMA.MODELNO	= S_ARCUSFIL_PROGRAM_MODEL
	AND		HEADER_RMA.K_HEADER_RMA			= @PP_K_HEADER_RMA

	SELECT		TOP (1)
				-- =============================	 
				S_STATUS_RMA	, D_STATUS_RMA	,
				S_TIPO_RMA		, D_TIPO_RMA	,
				@CB_ARCUSFIL_PROGRAM	AS MODELNO_CB,
				--CUS_NO			, PROGRAMA		,
				--MODELNO,
				--VERSIONNO,
				-- =============================
				HEADER_RMA.*
				-- =============================	
	FROM		HEADER_RMA		(NOLOCK) 
	INNER JOIN 	STATUS_RMA		(NOLOCK) ON STATUS_RMA.K_STATUS_RMA	= HEADER_RMA.K_STATUS_RMA
	INNER JOIN 	TIPO_RMA		(NOLOCK) ON TIPO_RMA.K_TIPO_RMA		= HEADER_RMA.K_TIPO_RMA
				-- =============================
	WHERE		HEADER_RMA.K_HEADER_RMA	= @PP_K_HEADER_RMA
	AND			HEADER_RMA.L_BORRADO	<> 1
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_DETAILS_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_DETAILS_RMA]
GO
--		 EXECUTE [dbo].[PG_SK_DETAILS_RMA] 0,139,7
CREATE PROCEDURE [dbo].[PG_SK_DETAILS_RMA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_HEADER_RMA				INT
AS
	-- ///////////////////////////////////////////

		SELECT		TOP (100)
					DETAILS_RMA.*
		FROM		DETAILS_RMA
		WHERE		DETAILS_RMA.K_HEADER_RMA	= @PP_K_HEADER_RMA
		ORDER BY	K_DETAILS_RMA

	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_DEFECTO_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_DEFECTO_RMA]
GO
--		 EXECUTE [dbo].[PG_SK_DEFECTO_RMA] 0,139, 'AC'
--		 EXECUTE [dbo].[PG_SK_DEFECTO_RMA] 0,139, 'AW'
CREATE PROCEDURE [dbo].[PG_SK_DEFECTO_RMA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CLAVE						VARCHAR(3)
AS
	-- ///////////////////////////////////////////
	DECLARE	 @VP_DEFECTO				VARCHAR(250)
			,@VP_DEFECTO_ERROR			VARCHAR(250)

	SELECT	@VP_DEFECTO			= RTRIM(LTRIM(DEFECTO))
			--AS D_CLAVE_DEFECTO_RMA
			--RTRIM(LTRIM(CLAVE))				AS CLAVE_DEFECTO_RMA,
			--RTRIM(LTRIM(TIPODEF))			AS TIPO_DEFECTO_RMA,
			--RTRIM(LTRIM(DESCRIPCION))		AS ORIGEN_DEFECTO_RMA
	FROM	PPMS_PEARL.DBO.DEF	(NOLOCK)
	WHERE	CLAVE			= @PP_CLAVE	

	IF 	( @VP_DEFECTO = '' ) OR (@VP_DEFECTO IS NULL)
	BEGIN
		SET @VP_DEFECTO	= ''
		SET @VP_DEFECTO_ERROR	= 'Clave [ ' + UPPER(@PP_CLAVE) + ' ] no encontrada'
	END
	ELSE
	BEGIN
		SET @VP_DEFECTO_ERROR	= ''
	END

	SELECT @VP_DEFECTO	AS DEFECTO , @VP_DEFECTO_ERROR AS DEFECTO_ERROR
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- //	STORED PROCEDURE ---> PARA MOSTRAR ALERTAS 
-- //	DE ORDENES PENDIENTES.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_NOTIFICACION_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_NOTIFICACION_RMA]
GO
--		 EXECUTE [dbo].[PG_SK_NOTIFICACION_RMA] 0,47,9703
--		 EXECUTE [dbo].[PG_SK_NOTIFICACION_RMA] 0,43,9703
--		 EXECUTE [dbo].[PG_SK_NOTIFICACION_RMA] 0,139,9703
CREATE PROCEDURE [dbo].[PG_SK_NOTIFICACION_RMA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_GRUPO_APROBADOR			INT
AS
	DECLARE  @VP_MENSAJE			NVARCHAR(MAX)	= ''
			,@VP_EXISTE				INT				= 0
			,@VP_PENDIENTES			INT				= 0
	-- ///////////////////////////////////////////
	
	SELECT		@VP_EXISTE					= COUNT(K_USUARIO)
				-- =============================	
	FROM		BD_GENERAL.DBO.GRUPO_APROBADOR		(NOLOCK)
				-- =============================
	WHERE		K_USUARIO					= @PP_K_USUARIO_ACCION
	AND			K_TIPO_GRUPO_APROBADOR		= @PP_K_GRUPO_APROBADOR
	AND			K_ESTATUS_GRUPO_APROBADOR	= 1

	IF @VP_EXISTE>0
	BEGIN
		IF	(		@PP_K_USUARIO_ACCION IN ( 47 )					---MIGUELC
				OR	@PP_K_USUARIO_ACCION IN ( 56 )		)			---MANUELG
		BEGIN

			SELECT	@VP_PENDIENTES		= COUNT(K_HEADER_RMA)
			FROM	HEADER_RMA
			WHERE	K_STATUS_RMA		=	2
			AND		L_BORRADO			=	0

		END
		ELSE IF @PP_K_USUARIO_ACCION IN ( 43 )			---JORGEH
		BEGIN
			
			SELECT	@VP_PENDIENTES		= COUNT(K_HEADER_RMA)
			FROM	HEADER_RMA
			WHERE	K_STATUS_RMA		=	4
			AND		L_BORRADO			=	0

		END
		ELSE IF @PP_K_USUARIO_ACCION IN ( 139 )			---AX
		BEGIN
			
			SELECT	@VP_PENDIENTES		= COUNT(K_HEADER_RMA)
			FROM	HEADER_RMA
			WHERE	K_STATUS_RMA		IN	(2)
			AND		L_BORRADO			=	0

			IF @VP_PENDIENTES > 0
			BEGIN
				SET @VP_MENSAJE	= 'DPTO // '
			END
			ELSE IF @VP_PENDIENTES = 0
			BEGIN
				SELECT	@VP_PENDIENTES		= COUNT(K_HEADER_RMA)
				FROM	HEADER_RMA
				WHERE	K_STATUS_RMA		IN	(4)
				AND		L_BORRADO			=	0

				IF @VP_PENDIENTES > 0
				BEGIN
					SET @VP_MENSAJE	= 'MNGR // '
				END
			END

		END
	
		IF @VP_PENDIENTES>0
		BEGIN
			SET @VP_MENSAJE = @VP_MENSAJE + 'Existen [ORDENES RMA] por autorizar. Da click aquí par ingresar a la pantalla.'
		END

	END

	SELECT  @VP_MENSAJE AS MENSAJE, 'RMA' AS TITULO_UDA
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_HEADER_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_HEADER_RMA]
GO
--		 EXECUTE [dbo].[PG_IN_HEADER_RMA] 1,139,  '19' , '' , '' , 'WKL' , '0009' , 'IWKL0042CPRDX9' , '65327M11' , '0.6400' , '8' , '-1'

--		 EXECUTE [dbo].[PG_IN_HEADER_RMA] 1,139, 'MAGN03' , 'WK' , 'WBL' , 'IVAN DECENA' , '' , 'WBL/WBL/WBL' , '0012/0012/0012' , 'IWBL0003CNPDX9/IWBL0002CNPDX9/IWBL0001CNPDX9' , '55468M2/55467M1/55466M2' , '0.8219/0.5202/0.9284' , 'CALLO/COSTURA MAL ALINEADA/CON SELLO' , '8/4/2' , '-1/-1/-1'  
CREATE PROCEDURE [dbo].[PG_IN_HEADER_RMA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	--@PP_K_STATUS_RMA				INT,
	-- ============================
	@PP_CUS_NO						VARCHAR(6),
	@PP_PROGRAM						VARCHAR(50),
	@PP_MODELNO						VARCHAR(3),
	--@PP_VERSIONNO					VARCHAR(5),
	-- ============================
	--@PP_F_CREACION_RMA				DATE,
	-- ============================
	@PP_SOLICITADA_POR_RMA			VARCHAR (250),
	-- ============================
	@PP_C_RMA						VARCHAR(255),
	@PP_K_TIPO_RMA					INT,
	@PP_L_APLICA_COBRO				INT,
	-- ============================
	@PP_ARRAY_MODELNO				NVARCHAR(MAX),
	@PP_ARRAY_VERSION				NVARCHAR(MAX),
	-- ============================
	@PP_ARRAY_ITEM_NO				NVARCHAR(MAX),
	@PP_ARRAY_CUSITEM				NVARCHAR(MAX),
	@PP_ARRAY_NETAREA				NVARCHAR(MAX),
	-- ============================
	@PP_ARRAY_CLAVE_D				NVARCHAR(MAX),
	@PP_ARRAY_DEFECTO				NVARCHAR(MAX),
	-- ============================
	@PP_ARRAY_QTY_ORD				NVARCHAR(MAX),
	@PP_ARRAY_K_DETAI				NVARCHAR(MAX),
	-- ============================
	@PP_ARRAY_GRUPO_O				NVARCHAR(MAX),
	@PP_ARRAY_PRECIOM				NVARCHAR(MAX),
	@PP_ATENCION_A					VARCHAR (250)	= ''
AS			
DECLARE  @VP_MENSAJE				NVARCHAR(MAX)
		,@VP_K_HEADER_RMA			INT = 0
		,@VP_D_USUARIO				VARCHAR(250)
		,@VP_S_USUARIO				VARCHAR(50)

	SET @PP_MODELNO = LTRIM(RTRIM(LEFT(@PP_MODELNO,3)))

	SELECT	@VP_D_USUARIO		= NOMBRE + ' ' + APELLIDO_PATERNO,
			@VP_S_USUARIO		= D_USUARIO_PEARL
	FROM	BD_GENERAL.dbo.USUARIO_PEARL	(NOLOCK)
	WHERE	K_USUARIO_PEARL		= @PP_K_USUARIO_ACCION

	IF @VP_D_USUARIO	= ''
		SET	@VP_D_USUARIO	= @VP_S_USUARIO

BEGIN TRANSACTION 
BEGIN TRY
	--============================================================================
	--======================================INSERTAR EL HEADER_RMA
	--============================================================================
		INSERT INTO HEADER_RMA
			(	[K_STATUS_RMA]					,	
				[K_TIPO_RMA]					,
				-- ============================	
				[CUS_NO]						,	[PROGRAM]						,
				[MODELNO]						,
				--[VERSIONNO]						,	
				-- ============================	
				[F_CREACION_RMA]				,--	[F_ENTREGA_RMA]					,
				-- ============================	
				[CREADA_POR_RMA]				,	[SOLICITADA_POR_RMA]			,
				[ATENCION_A]					,
				-- ============================	
				[C_RMA]							,	[L_APLICA_COBRO]				,
				-- ============================
				[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
		VALUES	
			(	1,	-- @PP_K_STATUS_RMA			,
				@PP_K_TIPO_RMA					,
				-- ============================	
				@PP_CUS_NO						,	@PP_PROGRAM						,
				@PP_MODELNO						,
				--@PP_VERSIONNO					,
				-- ============================	
				GETDATE(),	-- @PP_F_CREACION_RMA,
				-- ============================	
				@VP_D_USUARIO					,	@PP_SOLICITADA_POR_RMA			,
				@PP_ATENCION_A					,
				-- ============================	
				@PP_C_RMA						,	@PP_L_APLICA_COBRO				,
				-- ============================
				@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
				0, NULL, NULL  )

			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='La orden no se generó. [HDR#'+CONVERT(VARCHAR(10),@VP_K_HEADER_RMA)+']'
				RAISERROR (@VP_MENSAJE, 16, 1 ) 
			END
			ELSE
			BEGIN
				SELECT @VP_K_HEADER_RMA	= SCOPE_IDENTITY()

				IF	( @VP_K_HEADER_RMA	= 0 OR @VP_K_HEADER_RMA IS NULL )
				BEGIN
					RAISERROR ('Error en la asignación de identidad.[HDR]', 16, 1 ) 
				END
			END

		EXECUTE [PG_INUP_DETAILS_RMA]	@PP_K_SISTEMA_EXE	,	@PP_K_USUARIO_ACCION,
										-- ============================
										@VP_K_HEADER_RMA	,	@PP_CUS_NO			,
										-- ============================
										@PP_ARRAY_MODELNO	,	@PP_ARRAY_VERSION	,
										-- ============================
										@PP_ARRAY_ITEM_NO	,	@PP_ARRAY_CUSITEM	,
										@PP_ARRAY_NETAREA	,	
										-- ============================
										@PP_ARRAY_CLAVE_D	,	@PP_ARRAY_DEFECTO	,
										-- ============================
										@PP_ARRAY_QTY_ORD	,	@PP_ARRAY_K_DETAI	,
										@PP_K_TIPO_RMA		,	@PP_ARRAY_GRUPO_O	,
										@PP_ARRAY_PRECIOM

-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	/* Ocurrió un error, deshacemos los cambios*/ 
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH	
	-- /////////////////////////////////////////////////////////////////////	
	IF @VP_MENSAJE<>''
	BEGIN
		SET		@VP_MENSAJE = 'No es posible [Insertar] la [RMA]: ' + @VP_MENSAJE 
	END
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_HEADER_RMA AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> UPDATE / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_HEADER_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_HEADER_RMA]
GO
--       EXECUTE [dbo].[PG_UP_HEADER_RMA] 0, 139,												
--		 1 , 'MAGN03' , 'WK' , 'WBL' , 'IVAN DECENA' , '' , 'WBL/WBL/WBL' , '0012/0012/0012' , 'IWBL0002CNPDX9/IWBL0003CNPDX9/IWBL0004CNPDX9' , '55467M1/55468M2/55473M1' , '0.5202/0.8219/0.2766' , 'CLL/CO/ET' , 'CALLO/CORTADA/ESTRIAS' , '5/3/2' , '1/2/3' 
CREATE PROCEDURE [dbo].[PG_UP_HEADER_RMA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_HEADER_RMA				INT,
	-- ===========================
	--@PP_K_STATUS_RMA				INT,
	-- ============================
	@PP_CUS_NO						VARCHAR(6),
	@PP_PROGRAM						VARCHAR(50),
	@PP_MODELNO						VARCHAR(3),
	--@PP_VERSIONNO					VARCHAR(5),
	-- ============================
	--@PP_F_CREACION_RMA				DATE,
	-- ============================
	@PP_SOLICITADA_POR_RMA			VARCHAR (250),
	-- ============================
	@PP_C_RMA						VARCHAR(255),
	@PP_K_TIPO_RMA					INT,
	@PP_L_APLICA_COBRO				INT,
	-- ============================
	@PP_ARRAY_MODELNO				NVARCHAR(MAX),
	@PP_ARRAY_VERSION				NVARCHAR(MAX),
	-- ============================
	@PP_ARRAY_ITEM_NO				NVARCHAR(MAX),
	@PP_ARRAY_CUSITEM				NVARCHAR(MAX),
	@PP_ARRAY_NETAREA				NVARCHAR(MAX),
	-- ============================
	@PP_ARRAY_CLAVE_D				NVARCHAR(MAX),
	@PP_ARRAY_DEFECTO				NVARCHAR(MAX),
	-- ============================
	@PP_ARRAY_QTY_ORD				NVARCHAR(MAX),
	@PP_ARRAY_K_DETAI				NVARCHAR(MAX),
	-- ============================
	@PP_ARRAY_GRUPO_O				NVARCHAR(MAX),
	@PP_ARRAY_PRECIOM				NVARCHAR(MAX),
	@PP_ATENCION_A					VARCHAR (250)	= ''
AS			
DECLARE @VP_MENSAJE				NVARCHAR(MAX)
-- /////////////////////////////////////////////////////////////////////
BEGIN TRANSACTION 
BEGIN TRY

	DECLARE  @VP_STATUS_RMA		INT
			-- ,@VP_FECHA			DATE
	
	SET @PP_MODELNO = LTRIM(RTRIM(LEFT(@PP_MODELNO,3)))

	SELECT	@VP_STATUS_RMA	= K_STATUS_RMA	
			--,@VP_FECHA		= F_CREACION_RMA
	FROM	HEADER_RMA		(NOLOCK)
	WHERE	K_HEADER_RMA	= @PP_K_HEADER_RMA
	
	IF @VP_STATUS_RMA IN ( 1 )
	BEGIN
		SET @VP_STATUS_RMA = 1	-- SE LE ASIGNA EL ESTATUS INICIAL.	
	END
	ELSE IF @VP_STATUS_RMA IN (0, 3, 5 )
	BEGIN
		SET @VP_STATUS_RMA = 1		-- SE LE ASIGNA EL ESTATUS INICIAL.
		--SET @VP_FECHA	= GETDATE()	-- SE REASIGNA
	END
	ELSE
	BEGIN
		SET @VP_MENSAJE =  'No es posible modificar la orden, el estatus no lo permite.[HDR] Verifique...' 
		RAISERROR (@VP_MENSAJE, 16, 1 ) 
	END

	-- /////////////////////////////////////////////////////////////////////	

	UPDATE	HEADER_RMA
	SET		
			[K_STATUS_RMA]					= @VP_STATUS_RMA			,
			[K_TIPO_RMA]					= @PP_K_TIPO_RMA			,
			-- ============================	= -- ============================			
			--[CUS_NO]						= @PP_CUS_NO				,					
			--[MODELNO]						= @PP_MODELNO				,					
			--[VERSIONNO]						= @PP_VERSIONNO				,				
			-- ============================	= -- ============================			
			--[F_CREACION_RMA]				= @VP_FECHA					,
			-- ============================	= -- ============================			
			[SOLICITADA_POR_RMA]			= @PP_SOLICITADA_POR_RMA	,
			[ATENCION_A]					= @PP_ATENCION_A			,
			-- ============================	= -- ============================
			[C_RMA]							= @PP_C_RMA					,
			[L_APLICA_COBRO]				= @PP_L_APLICA_COBRO		,
			-- ============================	= -- ============================
			[F_CAMBIO]						= GETDATE(), 
			[K_USUARIO_CAMBIO]				= @PP_K_USUARIO_ACCION
	WHERE	[K_HEADER_RMA]					= @PP_K_HEADER_RMA
	IF @@ROWCOUNT = 0
	BEGIN
		SET @VP_MENSAJE='La orden no fue actualizada. [HDR#'+CONVERT(VARCHAR(10),@PP_K_HEADER_RMA)+']'
		RAISERROR (@VP_MENSAJE, 16, 1 ) 
	END		

	EXECUTE [PG_INUP_DETAILS_RMA]	@PP_K_SISTEMA_EXE	,	@PP_K_USUARIO_ACCION,
									-- ============================
									@PP_K_HEADER_RMA	,	@PP_CUS_NO			,
									-- ============================
									@PP_ARRAY_MODELNO	,	@PP_ARRAY_VERSION	,
									-- ============================
									@PP_ARRAY_ITEM_NO	,	@PP_ARRAY_CUSITEM	,
									@PP_ARRAY_NETAREA	,	
									-- ============================
									@PP_ARRAY_CLAVE_D	,	@PP_ARRAY_DEFECTO	,
									-- ============================
									@PP_ARRAY_QTY_ORD	,	@PP_ARRAY_K_DETAI	,
									@PP_K_TIPO_RMA		,	@PP_ARRAY_GRUPO_O	,
									@PP_ARRAY_PRECIOM

-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH	
	-- /////////////////////////////////////////////////////////////////////	
	IF @VP_MENSAJE<>''
	BEGIN
		SET		@VP_MENSAJE = 'No es posible [Actualizar] la [RMA]: ' + @VP_MENSAJE 
	END

	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_HEADER_RMA AS CLAVE
	-- //////////////////////////////////////////////////////////////	
GO


-- //////////////////////////////////////////////////////////////
-- // PARA INSERTAR LOS DETALLES DE LA ORDEN
-- // STORED PROCEDURE ---> INSERT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_INUP_DETAILS_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_INUP_DETAILS_RMA]
GO
CREATE PROCEDURE [dbo].[PG_INUP_DETAILS_RMA]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ============================
	@PP_K_HEADER_RMA			INT,
	@PP_CUS_NO					VARCHAR(6),
	-- ============================
	@PP_ARRAY_MODELNO			NVARCHAR(MAX),
	@PP_ARRAY_VERSION			NVARCHAR(MAX),
	-- ============================
	@PP_ARRAY_ITEM_NO			NVARCHAR(MAX),
	@PP_ARRAY_CUSITEM			NVARCHAR(MAX),
	@PP_ARRAY_NETAREA			NVARCHAR(MAX),
	-- ============================
	@PP_ARRAY_CLAVE_D			NVARCHAR(MAX),
	@PP_ARRAY_DEFECTO			NVARCHAR(MAX),
	-- ============================
	@PP_ARRAY_QTY_ORD			NVARCHAR(MAX),
	@PP_ARRAY_K_DETAI			NVARCHAR(MAX),
	@PP_K_TIPO_RMA				INT,
	-- ============================
	@PP_ARRAY_GRUPO_O			NVARCHAR(MAX),
	@PP_ARRAY_PRECIOM			NVARCHAR(MAX)
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
		-- ============================
			,@VP_K_DETAIL_PO	INT = 1
		-- ============================	
			,@VP_POSICION_MODELNO	INT
			,@VP_POSICION_VERSION	INT
		--------------------------------
			,@VP_POSICION_ITEM_NO	INT
			,@VP_POSICION_CUSITEM	INT
			,@VP_POSICION_NETAREA	INT
		--------------------------------
			,@VP_POSICION_CLAVE_D	INT
			,@VP_POSICION_DEFECTO	INT
		--------------------------------
			,@VP_POSICION_QTY_ORD	INT
			,@VP_POSICION_K_DETAI	INT	
			,@VP_POSICION_GRUPO_O	INT	

			,@VP_POSICION_PRECIOM	INT	
		-- ============================	
			,@VP_VALOR_MODELNO		VARCHAR(500)
			,@VP_VALOR_VERSION		VARCHAR(500)			
		--------------------------------
			,@VP_VALOR_ITEM_NO		VARCHAR(500)
			,@VP_VALOR_CUSITEM		VARCHAR(500)
			,@VP_VALOR_NETAREA		VARCHAR(500)
		--------------------------------
			,@VP_VALOR_CLAVE_D		VARCHAR(500)
			,@VP_VALOR_DEFECTO		VARCHAR(500)
		--------------------------------
			,@VP_VALOR_QTY_ORD		VARCHAR(500)
			,@VP_VALOR_K_DETAI		VARCHAR(500)
			,@VP_VALOR_GRUPO_O		VARCHAR(500)

			,@VP_VALOR_PRECIOM		VARCHAR(500)

	
	DECLARE @VP_TA_DETAILS			AS TABLE
			(	TA_K_DETAILS		INT		)

	--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
	SET	@PP_ARRAY_MODELNO		= @PP_ARRAY_MODELNO	+ '/'
	SET	@PP_ARRAY_VERSION		= @PP_ARRAY_VERSION	+ '/'	
	----------------------------------------------------------------
	SET	@PP_ARRAY_ITEM_NO		= @PP_ARRAY_ITEM_NO	+ '/'	
	SET	@PP_ARRAY_CUSITEM		= @PP_ARRAY_CUSITEM	+ '/'
	SET	@PP_ARRAY_NETAREA		= @PP_ARRAY_NETAREA	+ '/'
	----------------------------------------------------------------
	SET	@PP_ARRAY_CLAVE_D		= @PP_ARRAY_CLAVE_D	+ '/'
	SET	@PP_ARRAY_DEFECTO		= @PP_ARRAY_DEFECTO	+ '/'
	----------------------------------------------------------------
	SET	@PP_ARRAY_QTY_ORD		= @PP_ARRAY_QTY_ORD	+ '/'
	SET	@PP_ARRAY_K_DETAI		= @PP_ARRAY_K_DETAI	+ '/'
	SET	@PP_ARRAY_GRUPO_O		= @PP_ARRAY_GRUPO_O	+ '/'

	SET	@PP_ARRAY_PRECIOM		= @PP_ARRAY_PRECIOM	+ '/'
	
	--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
	WHILE patindex('%/%' , @PP_ARRAY_ITEM_NO) <> 0
		BEGIN
			SELECT @VP_POSICION_MODELNO	=	patindex('%/%' , @PP_ARRAY_MODELNO		)
			SELECT @VP_POSICION_VERSION	=	patindex('%/%' , @PP_ARRAY_VERSION		)			
			------------------------------------------------------------------------------------------------
			SELECT @VP_POSICION_ITEM_NO	=	patindex('%/%' , @PP_ARRAY_ITEM_NO		)			
			SELECT @VP_POSICION_CUSITEM	=	patindex('%/%' , @PP_ARRAY_CUSITEM		)
			SELECT @VP_POSICION_NETAREA	=	patindex('%/%' , @PP_ARRAY_NETAREA		)
			------------------------------------------------------------------------------------------------			
			SELECT @VP_POSICION_CLAVE_D	=	patindex('%/%' , @PP_ARRAY_CLAVE_D		)
			SELECT @VP_POSICION_DEFECTO	=	patindex('%/%' , @PP_ARRAY_DEFECTO		)
			------------------------------------------------------------------------------------------------
			SELECT @VP_POSICION_QTY_ORD	=	patindex('%/%' , @PP_ARRAY_QTY_ORD		)
			SELECT @VP_POSICION_K_DETAI	=	patindex('%/%' , @PP_ARRAY_K_DETAI		)
			SELECT @VP_POSICION_GRUPO_O	=	patindex('%/%' , @PP_ARRAY_GRUPO_O		)

			SELECT @VP_POSICION_PRECIOM	=	patindex('%/%' , @PP_ARRAY_PRECIOM		)

			--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
			SELECT @VP_VALOR_MODELNO	= LEFT(@PP_ARRAY_MODELNO	, @VP_POSICION_MODELNO	- 1)
			SELECT @VP_VALOR_VERSION	= LEFT(@PP_ARRAY_VERSION	, @VP_POSICION_VERSION	- 1)			
			------------------------------------------------------------------------------------------------
			SELECT @VP_VALOR_ITEM_NO	= LEFT(@PP_ARRAY_ITEM_NO	, @VP_POSICION_ITEM_NO	- 1)			
			SELECT @VP_VALOR_CUSITEM	= LEFT(@PP_ARRAY_CUSITEM	, @VP_POSICION_CUSITEM	- 1)
			SELECT @VP_VALOR_NETAREA	= LEFT(@PP_ARRAY_NETAREA	, @VP_POSICION_NETAREA	- 1)
			------------------------------------------------------------------------------------------------
			SELECT @VP_VALOR_CLAVE_D	= LEFT(@PP_ARRAY_CLAVE_D	, @VP_POSICION_CLAVE_D	- 1)
			SELECT @VP_VALOR_DEFECTO	= LEFT(@PP_ARRAY_DEFECTO	, @VP_POSICION_DEFECTO	- 1)
			------------------------------------------------------------------------------------------------
			SELECT @VP_VALOR_QTY_ORD	= LEFT(@PP_ARRAY_QTY_ORD	, @VP_POSICION_QTY_ORD	- 1)
			SELECT @VP_VALOR_K_DETAI	= LEFT(@PP_ARRAY_K_DETAI	, @VP_POSICION_K_DETAI	- 1)
			SELECT @VP_VALOR_GRUPO_O	= LEFT(@PP_ARRAY_GRUPO_O	, @VP_POSICION_GRUPO_O	- 1)

			SELECT @VP_VALOR_PRECIOM	= LEFT(@PP_ARRAY_PRECIOM	, @VP_POSICION_PRECIOM	- 1)
				
				--========================================================================================================================================
				--========================================================================================================================================
				-- SACAR CANTIDAD DE REGISTROS POR COLOR/GRUPO DE DETAILS_RMA
				DECLARE	@VP_CANTIDAD_REGISTROS_X_GPO	AS INT
				SELECT  @VP_CANTIDAD_REGISTROS_X_GPO	= COUNT(GRUPO_ORDEN)
				FROM	DETAILS_RMA		(NOLOCK)
				WHERE	K_HEADER_RMA	= @PP_K_HEADER_RMA
				AND		CONCAT('F',LTRIM(RTRIM(RIGHT(item_no,6)))) = CONCAT('F',LTRIM(RTRIM(RIGHT(@VP_VALOR_ITEM_NO,6))))			--@VP_VALOR_ITEM_NO
				AND		GRUPO_ORDEN	= @VP_VALOR_GRUPO_O
				--GROUP BY  LOT, HIDE
				--HAVING COUNT(*)>4
				--ORDER BY LOT, HIDE

				IF @VP_CANTIDAD_REGISTROS_X_GPO > 12
				BEGIN
					SET @VP_MENSAJE='Únicamente se puede indicar 12 Patrones por grupo. Verifique...'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END
				--========================================================================================================================================
				--========================================================================================================================================

				DECLARE	@VP_PRECIO_PATTERN	DECIMAL(19,4)
				SELECT	@VP_PRECIO_PATTERN	= ISNULL( costleather , 0 )
				FROM	[DATA_02].[DBO].ccprcovr_sql	(NOLOCK)
				WHERE	CUS_NO					= @PP_CUS_NO	
				AND		MODELNO					= @VP_VALOR_MODELNO
				AND		VERSIONNO				= @VP_VALOR_VERSION
				AND		LTRIM(RTRIM(ITEMNO))	= @VP_VALOR_ITEM_NO

					IF @PP_K_TIPO_RMA	IN	(2)
					BEGIN
						SET	@VP_VALOR_CLAVE_D	= 'XSR'
						SET	@VP_VALOR_DEFECTO	= 'ORDEN DE SERVICIO'
					END
					ELSE
					BEGIN	
						SET	@VP_VALOR_PRECIOM	= 0

						IF	@VP_VALOR_CLAVE_D	= 'XSR' OR	@VP_VALOR_DEFECTO	= 'ORDEN DE SERVICIO'
						BEGIN
							SET @VP_MENSAJE='Se debe indicar un defecto para todos los Pattern agregados a la orden. [DET#'+CONVERT(VARCHAR(10),@VP_VALOR_ITEM_NO)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END
					END

								
				IF	@VP_VALOR_K_DETAI	>  0
				BEGIN
					UPDATE	DETAILS_RMA
					SET		[CANTIDAD_ORDENADA]		= @VP_VALOR_QTY_ORD		,
							[CLAVE_DEFECTO_RMA]		= @VP_VALOR_CLAVE_D		,
							[D_DEFECTO_RMA]			= @VP_VALOR_DEFECTO		,
							[PRECIO_UNITARIO]		= @VP_PRECIO_PATTERN	,
							[GRUPO_ORDEN]			= @VP_VALOR_GRUPO_O		,
							[PRECIO_MANUAL]			= @VP_VALOR_PRECIOM
					WHERE	K_DETAILS_RMA			= @VP_VALOR_K_DETAI

					IF @@ROWCOUNT = 0
					BEGIN
						SET @VP_MENSAJE='El detalle de la Orden no fue actualizado. [DET#'+CONVERT(VARCHAR(10),@VP_VALOR_ITEM_NO)+']'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END	

				END
				ELSE
				BEGIN
					INSERT INTO DETAILS_RMA
						(
							[K_HEADER_RMA]				,
							-- =========================
							[CUS_NO]					,	[MODELNO]					,
							[VERSIONNO]					,
							-- =========================
							[ITEM_NO]					,	[CUS_ITEM_NO]				,
							[NET_AREA]					,	
							-- =========================
							[CLAVE_DEFECTO_RMA]			,	[D_DEFECTO_RMA]				,
							-- =========================
							[CANTIDAD_ORDENADA]			,	[PRECIO_UNITARIO]			,
							-- =========================
							[CANTIDAD_ENVIADA]			,	[GRUPO_ORDEN]				,
							[PRECIO_MANUAL]
						)
					VALUES
						(	
							@PP_K_HEADER_RMA			,
							-- =========================
							@PP_CUS_NO					,	@VP_VALOR_MODELNO			,
							@VP_VALOR_VERSION			,
							-- =========================
							@VP_VALOR_ITEM_NO			,	@VP_VALOR_CUSITEM			,
							@VP_VALOR_NETAREA			,	
							-- ============================
							@VP_VALOR_CLAVE_D			,	@VP_VALOR_DEFECTO			,
							-- ============================
							@VP_VALOR_QTY_ORD			,	@VP_PRECIO_PATTERN			,
							-- =========================
							0							,	@VP_VALOR_GRUPO_O			,
							@VP_VALOR_PRECIOM
						)																															
					IF @@ROWCOUNT = 0
					BEGIN
						SET @VP_MENSAJE='El detalle de la Orden no fue ingresado. [DET#'+CONVERT(VARCHAR(10),@VP_VALOR_ITEM_NO)+']'
						RAISERROR (@VP_MENSAJE, 16, 1 )
					END
					ELSE
					BEGIN
						SELECT @VP_VALOR_K_DETAI	= SCOPE_IDENTITY()

						IF ( @VP_VALOR_K_DETAI	= NULL ) or ( @VP_VALOR_K_DETAI < 0 )
						BEGIN
							SET @VP_MENSAJE='Error en la asignación de IDENTIDAD.'
							RAISERROR (@VP_MENSAJE, 16, 1 )
						END
					END
				END
				
				INSERT INTO @VP_TA_DETAILS
				VALUES	( @VP_VALOR_K_DETAI )

			--Reemplazamos lo procesado con nada con la funcion stuff
			SELECT @PP_ARRAY_MODELNO	= STUFF(@PP_ARRAY_MODELNO	, 1, @VP_POSICION_MODELNO , '')
			SELECT @PP_ARRAY_VERSION	= STUFF(@PP_ARRAY_VERSION	, 1, @VP_POSICION_VERSION , '')		
			------------------------------------------------------------------------------------------------				
			SELECT @PP_ARRAY_ITEM_NO	= STUFF(@PP_ARRAY_ITEM_NO	, 1, @VP_POSICION_ITEM_NO , '')			
			SELECT @PP_ARRAY_CUSITEM	= STUFF(@PP_ARRAY_CUSITEM	, 1, @VP_POSICION_CUSITEM , '')
			SELECT @PP_ARRAY_NETAREA	= STUFF(@PP_ARRAY_NETAREA	, 1, @VP_POSICION_NETAREA , '')
			------------------------------------------------------------------------------------------------				
			SELECT @PP_ARRAY_CLAVE_D	= STUFF(@PP_ARRAY_CLAVE_D	, 1, @VP_POSICION_CLAVE_D , '')
			SELECT @PP_ARRAY_DEFECTO	= STUFF(@PP_ARRAY_DEFECTO	, 1, @VP_POSICION_DEFECTO , '')
			------------------------------------------------------------------------------------------------				
			SELECT @PP_ARRAY_QTY_ORD	= STUFF(@PP_ARRAY_QTY_ORD	, 1, @VP_POSICION_QTY_ORD , '')
			SELECT @PP_ARRAY_K_DETAI	= STUFF(@PP_ARRAY_K_DETAI	, 1, @VP_POSICION_K_DETAI , '')
			SELECT @PP_ARRAY_GRUPO_O	= STUFF(@PP_ARRAY_GRUPO_O	, 1, @VP_POSICION_GRUPO_O , '')

			SELECT @PP_ARRAY_PRECIOM	= STUFF(@PP_ARRAY_PRECIOM	, 1, @VP_POSICION_PRECIOM , '')
		END

		DELETE	FROM DETAILS_RMA
		WHERE	K_HEADER_RMA	= @PP_K_HEADER_RMA
		AND		K_DETAILS_RMA NOT IN ( SELECT TA_K_DETAILS FROM @VP_TA_DETAILS )
	-- ////////////////////////////////////////////////////////////////
	-- ///////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> UPDATE / RMA
-- // PARA ACTUALIZAR EL ESTATUS DE LA RMA POR PARTE DE GERENCIA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_ESTATUS_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_ESTATUS_RMA]
GO
--		 EXECUTE [dbo].[PG_UP_ESTATUS_RMA]	0,47,   1,2
--		 EXECUTE [dbo].[PG_UP_ESTATUS_RMA]	0,148,  1,2

-- PRUEBAS RMA
--		 EXECUTE [dbo].[PG_UP_ESTATUS_RMA]	0,139,  1,1				---REGISTRAR
--		 EXECUTE [dbo].[PG_UP_ESTATUS_RMA]	0,139,  1,2				---APROB. DEPTO
--		 EXECUTE [dbo].[PG_UP_ESTATUS_RMA]	0,139,  4,2				---APROB. GENRL

--		 EXECUTE [dbo].[PG_UP_ESTATUS_RMA]	0,139,  1,3				---RECHAZAR
--		 EXECUTE [dbo].[PG_UP_ESTATUS_RMA]	0,139,  1,4				---CANCELAR

CREATE PROCEDURE [dbo].[PG_UP_ESTATUS_RMA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_ARRAY_K_HEADER				NVARCHAR(MAX),
	@PP_L_ACCION_REALIZAR			INT		-- 1 ENVIAR		//	2 APROBAR	//	3 RECHAZAR	//	4 CANCELAR
AS
DECLARE  @VP_MENSAJE				NVARCHAR(MAX)=''
		-- ===========================
		,@VP_POSICION_K_HEADER		INT
		,@VP_VALOR_K_HEADER			INT
		--,@VP_POSICION_K_STATUS		INT
		--,@VP_VALOR_K_STATUS			INT
		-- ===========================		
		,@VP_STATUS_K_HEADER		INT
		,@VP_D_STATUS_K_HEADER		VARCHAR(150)
		,@VP_ESTATUS_SIGUIENTE		INT

-- /////////////////////////////////////////////////////////////////////
BEGIN TRANSACTION 
BEGIN TRY
		-----	47: MIGUELC		//	43: JORGEH		//	56: MANUELG			//	139:ALEJANDROD
		IF @PP_K_USUARIO_ACCION IN ( 139 )
		BEGIN
			SET @VP_MENSAJE	= ''
		END
		ELSE IF @PP_K_USUARIO_ACCION IN ( 47, 43, 56 ) AND @PP_L_ACCION_REALIZAR NOT IN ( 2, 3)
		BEGIN
			SET @VP_MENSAJE='Acción no permitida para este usuario, verifique...'
			RAISERROR (@VP_MENSAJE, 16, 1 ) 
		END
		ELSE IF @PP_K_USUARIO_ACCION NOT IN ( 47, 43, 56 ) AND @PP_L_ACCION_REALIZAR NOT IN ( 1, 4)
		BEGIN
			SET @VP_MENSAJE='Acción no permitida para este usuario, verifique...'
			RAISERROR (@VP_MENSAJE, 16, 1 ) 
		END

		--IF @PP_L_ACCION_REALIZAR = 1 AND @PP_K_USUARIO_ACCION IN ( 47, 43, 56 )
		--BEGIN
		--	SET @PP_L_ACCION_REALIZAR = 2
		--END
	-- /////////////////////////////////////////////////////////////////////
	--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
	SET	@PP_ARRAY_K_HEADER		= @PP_ARRAY_K_HEADER		+ '/'

	--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
	WHILE patindex('%/%' , @PP_ARRAY_K_HEADER) <> 0
		BEGIN
			SELECT @VP_POSICION_K_HEADER	=	patindex('%/%' , @PP_ARRAY_K_HEADER		)

			--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
			SELECT @VP_VALOR_K_HEADER		= LEFT(@PP_ARRAY_K_HEADER		, @VP_POSICION_K_HEADER		- 1)
			
			-- PRIMERO SE VERIFICA QUE LA ORDEN SE ENCUENTRE ACTIVA.
			SELECT	@VP_STATUS_K_HEADER		= HEADER_RMA.K_STATUS_RMA
					,@VP_D_STATUS_K_HEADER	= D_STATUS_RMA
			FROM	HEADER_RMA				(NOLOCK)
					,STATUS_RMA				(NOLOCK)
			WHERE	K_HEADER_RMA				= @VP_VALOR_K_HEADER
			AND		STATUS_RMA.K_STATUS_RMA		= HEADER_RMA.K_STATUS_RMA
			AND		L_BORRADO				<> 1
			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='No se encontró el estatus de la [RMA#'+CONVERT(VARCHAR(10),@VP_VALOR_K_HEADER)+']...'
				RAISERROR (@VP_MENSAJE, 16, 1 ) 
			END			

			-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				IF	@PP_L_ACCION_REALIZAR	= 1		-- ENVIAR
				BEGIN 					
					IF ( @VP_STATUS_K_HEADER NOT IN (0,1,3,5))		-- DEBE TENER UN ESTATUS VÁLIDO. DE ACUERDO A LA ACCIÓN A REALIZAR.
					BEGIN
						SET @VP_MENSAJE='El estatus ( '+ @VP_D_STATUS_K_HEADER +' ) de la [RMA#'+CONVERT(VARCHAR(10),@VP_VALOR_K_HEADER)+'] no es válido para realizar la acción...'
						RAISERROR (@VP_MENSAJE, 16, 1 )
					END
				
						UPDATE	HEADER_RMA
						SET		K_STATUS_RMA	= 2
								,F_CAMBIO		= GETDATE()
						WHERE	K_HEADER_RMA	= @VP_VALOR_K_HEADER
						AND		L_BORRADO		<> 1
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='La [RMA#'+CONVERT(VARCHAR(10),@VP_VALOR_K_HEADER)+'] no fue encontrada...'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END			
				END
			-- /////////////////////////////////////////////////////////////////////
				IF	@PP_L_ACCION_REALIZAR	= 2		--APROBAR
				BEGIN 

					--IF @VP_STATUS_K_HEADER NOT IN (2, 4)			-- DEBE TENER UN ESTATUS VÁLIDO. DE ACUERDO A LA ACCIÓN A REALIZAR.
					--BEGIN
					--	SET @VP_MENSAJE='El estatus ( '+ @VP_D_STATUS_K_HEADER +' ) de la [RMA#'+CONVERT(VARCHAR(10),@VP_VALOR_K_HEADER)+'] no es válido para realizar la acción...'
					--	RAISERROR (@VP_MENSAJE, 16, 1 )
					--END
						SET @VP_ESTATUS_SIGUIENTE	= 0

						IF @PP_K_USUARIO_ACCION IN (47) AND @VP_STATUS_K_HEADER IN (2)				-- MIGUELC
						BEGIN
							SET @VP_ESTATUS_SIGUIENTE	= 4
						END
						
						IF @PP_K_USUARIO_ACCION IN (43, 56)  AND @VP_STATUS_K_HEADER IN (4)				-- JORGEH
						BEGIN
							SET @VP_ESTATUS_SIGUIENTE	= 6
						END

						
						IF @PP_K_USUARIO_ACCION IN (139) AND @VP_STATUS_K_HEADER IN (2,4)			-- ALEJANDROD
						BEGIN
							IF @VP_STATUS_K_HEADER IN (2)
							BEGIN
								SET @VP_ESTATUS_SIGUIENTE	= 4
							END
							ELSE
							BEGIN
								SET @VP_ESTATUS_SIGUIENTE	= 6
							END
						END		

						IF	@VP_ESTATUS_SIGUIENTE = 0
						BEGIN
							SET @VP_MENSAJE='El estatus ( '+ @VP_D_STATUS_K_HEADER +' ) de la [RMA#'+CONVERT(VARCHAR(10),@VP_VALOR_K_HEADER)+'] no es válido para realizar la acción...'
							RAISERROR (@VP_MENSAJE, 16, 1 )
						END
															
							UPDATE	HEADER_RMA
							SET		 K_STATUS_RMA	= @VP_ESTATUS_SIGUIENTE
									,F_CAMBIO		= GETDATE()
							WHERE	K_HEADER_RMA	= @VP_VALOR_K_HEADER
							AND		L_BORRADO		<> 1
							IF @@ROWCOUNT = 0
							BEGIN
								SET @VP_MENSAJE='La [RMA#'+CONVERT(VARCHAR(10),@VP_VALOR_K_HEADER)+'] no fue actualizada...'
								RAISERROR (@VP_MENSAJE, 16, 1 ) 
							END

						IF	@VP_ESTATUS_SIGUIENTE	= 6
						BEGIN
							-- CREAR LA ORDEN.
							EXECUTE [PG_PR_RMA_CREAR_ORDER]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, @VP_VALOR_K_HEADER							
						END
				END
			-- /////////////////////////////////////////////////////////////////////
				IF	@PP_L_ACCION_REALIZAR	= 3		-- RECHAZAR
				BEGIN
					IF @VP_STATUS_K_HEADER IN ( 3, 5)
					BEGIN
						SET @VP_MENSAJE='La orden ya se encuentra rechazada...'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END
					ELSE IF @VP_STATUS_K_HEADER >= 6	-- YA NO SE PUEDE CANCELAR, YA ESTA SIENDO PROCESADA.
					BEGIN
						SET @VP_MENSAJE='La orden no se puede rechazar, ya se encuentra en proceso, verifique...'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END
					
						UPDATE	HEADER_RMA
						SET
								-- ============================	= -- ============================
								[K_STATUS_RMA]					= @VP_STATUS_K_HEADER + 1,		--SET @VP_ESTATUS_SIGUIENTE =	@VP_STATUS_K_HEADER + 1
								-- ============================	= -- ============================
								[F_CAMBIO]						= GETDATE(), 
								[K_USUARIO_CAMBIO]				= @PP_K_USUARIO_ACCION
						WHERE	[K_HEADER_RMA]					= @VP_VALOR_K_HEADER
						AND		[K_STATUS_RMA]					IN	( 2, 4) 
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El estatus no fue cambiado. [HDR#'+CONVERT(VARCHAR(10),@VP_VALOR_K_HEADER)+']...'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END
				END
			-- /////////////////////////////////////////////////////////////////////
				IF	@PP_L_ACCION_REALIZAR	= 4		-- CANCELAR
				BEGIN
					IF @VP_STATUS_K_HEADER = 0	
					BEGIN
						SET @VP_MENSAJE='La orden ya se encuentra cancelada...'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END
					ELSE IF @VP_STATUS_K_HEADER >= 6	-- YA NO SE PUEDE CANCELAR, YA ESTA SIENDO PROCESADA.
					BEGIN
						SET @VP_MENSAJE='La orden no se puede cancelar, ya se encuentra en proceso, verifique...'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END

						UPDATE	HEADER_RMA
						SET		
								-- ============================	= -- ============================
								[K_STATUS_RMA]					= 0	,
								-- ============================	= -- ============================
								[F_CAMBIO]						= GETDATE(), 
								[K_USUARIO_CAMBIO]				= @PP_K_USUARIO_ACCION
						WHERE	[K_HEADER_RMA]					= @VP_VALOR_K_HEADER
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El estatus no fue cambiado. [HDR#'+CONVERT(VARCHAR(10),@VP_VALOR_K_HEADER)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END

				END
			-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

			--Reemplazamos lo procesado con nada con la funcion stuff
			SELECT @PP_ARRAY_K_HEADER		= STUFF(@PP_ARRAY_K_HEADER		, 1, @VP_POSICION_K_HEADER , '')
		END
	-- ////////////////////////////////////////////////////////////////
	-- ///////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	/* Ocurrió un error, deshacemos los cambios*/ 
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH
-- /////////////////////////////////////////////////////////////////////	
	IF @VP_MENSAJE<>''
	BEGIN
		SET		@VP_MENSAJE = 'No es posible [ACTUALIZAR]: ' + @VP_MENSAJE 

		-- PARA ENVIAR EL CORREO EN CASO DE ERRORES.
		--EXECUTE	[PG_ERROR_GENERAR_ORDEN_RMA]	0,		@PP_ARRAY_K_HEADER,		@VP_MENSAJE
	END
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_L_ACCION_REALIZAR AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////
--	EXECUTE [dbo].[PG_DL_HEADER_RMA] 0,139,380,2,2
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_HEADER_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_HEADER_RMA]
GO
CREATE PROCEDURE [dbo].[PG_DL_HEADER_RMA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_HEADER_RMA				INT
AS
DECLARE @VP_MENSAJE				NVARCHAR(MAX) = ''
BEGIN TRANSACTION 
BEGIN TRY
	--/////////////////////////////////////////////////////////////
		DECLARE @VP_STATUS_K_HEADER		INT
		
		SELECT	@VP_STATUS_K_HEADER		= K_STATUS_RMA
		FROM	HEADER_RMA				(NOLOCK)
		WHERE	K_HEADER_RMA			= @PP_K_HEADER_RMA
		AND		L_BORRADO				<> 1
		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='No se obtuvo el estatus de la [RMA#'+CONVERT(VARCHAR(10),@PP_K_HEADER_RMA)+'], verifique...'
			RAISERROR (@VP_MENSAJE, 16, 1 ) 
		END			

		IF @VP_STATUS_K_HEADER NOT IN ( 0, 1, 3, 5)
		BEGIN
			SET @VP_MENSAJE='La [RMA#'+CONVERT(VARCHAR(10),@PP_K_HEADER_RMA)+'] no puede ser eliminada, verifique...'
			RAISERROR (@VP_MENSAJE, 16, 1 ) 
		END
	--////////////////////////////////////////////////////////////

		UPDATE	HEADER_RMA
		SET		
				[L_BORRADO]				= 1			,
				-- ====================
				[F_BAJA]				= GETDATE()	,
				[K_USUARIO_BAJA]		= @PP_K_USUARIO_ACCION
		WHERE	K_HEADER_RMA			= @PP_K_HEADER_RMA
		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='La orden no puede ser eliminada. [RMA#'+CONVERT(VARCHAR(10),@PP_K_HEADER_RMA)+']'
		END

-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH	

	-- /////////////////////////////////////////////////////////////////////	
	IF @VP_MENSAJE<>''
	BEGIN
		SET		@VP_MENSAJE = 'No es posible [ELIMINAR] la orden: ' + @VP_MENSAJE 
	END

	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_HEADER_RMA AS CLAVE
	-- /////////////////////////////////////////////////////////////////////	
GO
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // PARA ENVIAR NOTIFICACIÓN DE STOCK MINIMO.
-- //////////////////////////////////////////////////////////////
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_ERROR_GENERAR_ORDEN_RMA]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_ERROR_GENERAR_ORDEN_RMA]
--GO
----		 EXECUTE [dbo].[PG_ERROR_GENERAR_ORDEN_RMA]	1,139, 1,1,3500,70
--CREATE PROCEDURE [dbo].[PG_ERROR_GENERAR_ORDEN_RMA]
--	@PP_K_SISTEMA_EXE			INT,
--	-----=====================================================
--	@PP_ARRAY_K_HEADER			NVARCHAR(MAX),
--	@PP_MENSAJE_ERRROR			NVARCHAR(MAX)
--AS	
--	-- ////////////////////////////////////////////////////////////////
--	DECLARE	 @VP_SUBJECT				VARCHAR(255)	= ''
--			,@VP_RECIPIENTS				NVARCHAR(MAX)	= ''
--			,@VP_BODY_HTML				NVARCHAR(MAX)	= ''
			
--		--SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
--		--FROM	BD_GENERAL.dbo.USUARIO_PEARL			(NOLOCK)	AS USERS
--		--INNER	JOIN	BD_GENERAL.dbo.GRUPO_APROBADOR	(NOLOCK)	ON GRUPO_APROBADOR.K_USUARIO=USERS.K_USUARIO_PEARL
--		--WHERE	GRUPO_APROBADOR.K_TIPO_GRUPO_APROBADOR = @PP_K_TIPO_GRUPO_APROBADOR
--		--AND		K_ESTATUS_GRUPO_APROBADOR = 1

--		--SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))

--		--SET @VP_SUBJECT	=	'['	+	CONVERT(VARCHAR(50),FORMAT(@PP_K_ORDEN_COMPRA_PEDIDO,'00000')) +']  ['	+	CONVERT(VARCHAR(50),@PP_NO_ENTREGA) + '] Material recibido con excedente.'
--		SET @VP_SUBJECT	=	'[0]' + ' RMA ERROR DE ORDEN.'
		
--		SET @VP_BODY_HTML = 
--			N'<html>'+
--			N'<head>'+		
--			N'<style>'+
--			N'table	{border: solid 1px;border-collapse:collapse; width: 50%; cellspacing="1"}'+
--			N'th	{border: solid 1px;padding: 3px;text-align: "center";background:"#ADD8E6"; color:"#000000"}'+
--			N'td	{border: solid 1px;padding: 3px;text-align: "center";background:"#48D1CC"; color:"#000000"}'+
--			N'</style>'+
					
--			N'</head>'+
--			N'<body>'+

--			N'<p style="color:black; font-size:14.0pt;font-family:"Calisto MT",serif">'+
			
--			N'Error al generar la orden: <br><br>'+
--			N'<br><br><br>'+
--			N' '+ @PP_ARRAY_K_HEADER +
--			N'<br><br><br>'+
--			N' '+ @PP_MENSAJE_ERRROR +
--				--N'<table>' +
--				--	N'<thead>' + 
--				--	  N'<tr>' + 
--				--	    N'<th colspan="4">Tendencia de uso de material:</th>' + 
--				--	  N'</tr>' + 
--				--	  N'<tr>' +
--				--		N'	<th width: 25%>   Cantidad Stock.									</th>	
--				--			<th width: 25%>   Cantidad utilizada<br> los últimos 30 días.		</th>
--				--			<th width: 25%>   Cantidad aproximada <br>de uso diario.			</th>
--				--			<th width: 25%>   Unidad <br> de Medida.							</th>' + 
--				--	  N'</tr>' + 
--				--	N'</thead>' + 
--				--	N'<tbody>' + 
--				--		N'<tr>'+
--				--		N'	<td>'+ CONVERT(VARCHAR(50),@PP_QTY_STOCK_PRODUCCION)		+ '</td>	
--				--			<td>'+ CONVERT(VARCHAR(50),@PP_QTY_CONSUMIDA_MES)			+ '</td>
--				--			<td>'+ CONVERT(VARCHAR(50),@PP_QTY_USO_DIARIA)				+ '</td>
--				--			<td>'+ 'Rollos'												+ '</td>' +
--				--	N'</tbody>' + 
--				--N'</table>'+
--				N'<br>'+
--				--N'<b>NOTA:</b>A falta de una cantidad mínima base establecida, se considera la tendencia de uso de los ultimos 30 dias. <br><br>'+
--			N'</body>'+
--			N'</html>';


				
--	EXEC msdb.dbo.sp_send_dbmail @recipients=@VP_RECIPIENTS,
--	--@blind_copy_recipients='ALEJANDROD@PEARLLEATHER.COM.MX',
--	@subject = @VP_SUBJECT,
--	@body = @VP_BODY_HTML,  
--	@body_format = 'HTML'		
--	-- ///////////////////////////////////////////////////////////////
--GO