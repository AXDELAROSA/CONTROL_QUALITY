-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			ORDEN_PATRON
-- // OPERATION:		SP'S
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210804
-- ////////////////////////////////////////////////////////////// 

USE	[DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- //////		CONTENIDO DEL SP
--	[PG_LI_COLOR_ORDEN_PATRON]
--	[PG_LI_COLOR_KIT_ORDEN_PATRON]
--	[PG_LI_COLOR_KIT_PATTERN_ORDEN_PATRON]
--	[PG_INUP_ORDEN_PATRON]
--	[PG_SK_NOTIFICACION_ORDEN_PATRON]		--	EN ESPERA DE USO
-- //////////////////////////////////////////////////////////////


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA LOS COLORES ACTIVOS POR MODELO
--						 	DE LA VERSIÓN QUE ESTÁ LIVE.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_COLOR_ORDEN_PATRON]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_COLOR_ORDEN_PATRON]
GO
--		 EXECUTE [dbo].[PG_LI_COLOR_ORDEN_PATRON] 0,139,'IRVI02','JLI'
CREATE PROCEDURE [dbo].[PG_LI_COLOR_ORDEN_PATRON]
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
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_COLOR_KIT_ORDEN_PATRON]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_COLOR_KIT_ORDEN_PATRON]
GO
--		 EXECUTE [dbo].[PG_LI_COLOR_KIT_ORDEN_PATRON] 0,139,'MAGN03','WKZ','0018', 'FCNPDX9'
--		 EXECUTE [dbo].[PG_LI_COLOR_KIT_ORDEN_PATRON] 0,139,'MAGN03','WKL','0009', 'FCPRDX9'
CREATE PROCEDURE [dbo].[PG_LI_COLOR_KIT_ORDEN_PATRON]
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
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_COLOR_KIT_PATTERN_ORDEN_PATRON]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_COLOR_KIT_PATTERN_ORDEN_PATRON]
GO
--		 EXECUTE [dbo].[PG_LI_COLOR_KIT_PATTERN_ORDEN_PATRON] 0,139,'MAGN03','WKZ','0021', 'PMDZFCLCNPDX9','173612R'
--		 EXECUTE [dbo].[PG_LI_COLOR_KIT_PATTERN_ORDEN_PATRON] 0,139,'MAGN03','WKL','0011', 'PMWKLK6CPRDX9','174372A'
--		 EXECUTE [dbo].[PG_LI_COLOR_KIT_PATTERN_ORDEN_PATRON] 0,139,'GRAM04','GR2','0001', 'PGMRFARWSPAA6','1467036'
CREATE PROCEDURE [dbo].[PG_LI_COLOR_KIT_PATTERN_ORDEN_PATRON]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUS_NO					VARCHAR(15),
	@PP_MODELNO					VARCHAR(15),
	@PP_VERSIONNO				VARCHAR(6),
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
			----==============================================================================
					--,reference_1							AS ORDEN_PATRON
					,(
						SELECT	LTRIM(RTRIM(reference_1))
						FROM	[DATA_02].[DBO].ccprdstr_sql	(NOLOCK)
						where	item_no				=	@PP_S_KIT
						AND		CUS_NO				=	@PP_CUS_NO			--	'MAGN03'	--
						AND		MODELNO				=	@PP_MODELNO			--	'WKZ'		--
						AND		VERSIONNO			=	@PP_VERSIONNO		--	'0018'		--
						AND		COMP_ITEM_NO		=	LTRIM(RTRIM(CCCUSITM_SQL.ITEM_NO))
					)										AS ORDEN_PATRON
					,(
						SELECT	LTRIM(RTRIM(reference_1))
						FROM	[DATA_02].[DBO].ccprdstr_sql	(NOLOCK)
						where	item_no				=	@PP_S_KIT
						AND		CUS_NO				=	@PP_CUS_NO			--	'MAGN03'	--
						AND		MODELNO				=	@PP_MODELNO			--	'WKZ'		--
						AND		VERSIONNO			=	@PP_VERSIONNO		--	'0018'		--
						AND		COMP_ITEM_NO		=	LTRIM(RTRIM(CCCUSITM_SQL.ITEM_NO))
					)										AS ORDEN_PATRON_ORIGEN
			----==============================================================================
			FROM	 CCCUSITM_SQL				(NOLOCK)
					,IMITMIDX_SQL				(NOLOCK)
					--,ccprdstr_sql				(NOLOCK)
			WHERE	IMITMIDX_SQL.item_no		=	CCCUSITM_SQL.ITEM_NO
			----==============================================================================
			AND		CCCUSITM_SQL.CUS_NO			=	@PP_CUS_NO			--	'MAGN03'	--
			AND		CCCUSITM_SQL.MODELNO		=	@PP_MODELNO			--	'WKZ'		--
			AND		CCCUSITM_SQL.VERSIONNO		=	@PP_VERSIONNO		--	'0018'		--
			AND		LTRIM(RTRIM(CCCUSITM_SQL.ITEM_NO))	IN	(
															SELECT	COMP_ITEM_NO
															FROM	[DATA_02].[DBO].ccprdstr_sql	(NOLOCK)
															where	item_no				=	@PP_S_KIT
															AND		CUS_NO				=	@PP_CUS_NO			--	'MAGN03'	--
															AND		MODELNO				=	@PP_MODELNO			--	'WKZ'		--
															AND		VERSIONNO			=	@PP_VERSIONNO		--	'0018'		--
															)		
			----==============================================================================
	END
	ELSE
	BEGIN
		SELECT 'Se ha publicado una nueva versión del [MODELO] seleccionado, cierre y vuelva a abrir la ficha para actualizar.' AS MENSAJE
	END
GO


-- //////////////////////////////////////////////////////////////
-- // PARA INSERTAR LOS DETALLES DE LA ORDEN
-- // STORED PROCEDURE ---> INSERT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_INUP_ORDEN_PATRON]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_INUP_ORDEN_PATRON]
GO
CREATE PROCEDURE [dbo].[PG_INUP_ORDEN_PATRON]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ============================
	@PP_CUS_NO					VARCHAR(6),
	-- ============================
	@PP_MODELNO					NVARCHAR(MAX),
	@PP_VERSION					NVARCHAR(MAX),
	-- ============================
	@PP_KIT_ITM					NVARCHAR(MAX),
	@PP_PATTERN					NVARCHAR(MAX),
	@PP_CUSITEM					NVARCHAR(MAX),
	-- ============================
	@PP_ORDEN_P					NVARCHAR(MAX)
AS
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
BEGIN TRANSACTION 
BEGIN TRY
	--/////////////////////////////////////////////////////////////	
	DECLARE		@VP_VERSIONNO_BD	AS VARCHAR(6)

		SELECT	DISTINCT
				@VP_VERSIONNO_BD			= CCVERHDR_SQL.VERSIONNO
		FROM	CCVERHDR_SQL				(NOLOCK)
		WHERE	CCVERHDR_SQL.STATUS			= 'L' -- IN ('A', 'I', 'L' )--( @VP_CCVERHDR_SQL_STATUS	 )		--= 'L' 
		AND		CCVERHDR_SQL.SPECSTATUS		= 'U' -- IN ('A', 'C', 'U' )--( @VP_CCVERHDR_SQL_SPECSTATUS )	--= 'U' 
		AND		CCVERHDR_SQL.CUS_NO			=	@PP_CUS_NO	--	'MAGN03'	-- 
		AND		CCVERHDR_SQL.MODELNO		=	@PP_MODELNO	--	'WKZ'		-- 

	-- ///////////////////////////////////////////
	IF @VP_VERSIONNO_BD	= @PP_VERSION
	BEGIN
		IF @PP_ORDEN_P =''
			SET @PP_ORDEN_P	= '0'
			
		UPDATE	CCPRDSTR_SQL
		SET		[REFERENCE_1]			= @PP_ORDEN_P
		WHERE	cus_no					= @PP_CUS_NO
		AND		modelno					= @PP_MODELNO
		AND		versionno				= @PP_VERSION
		AND		item_no					= @PP_KIT_ITM
		AND		comp_item_no			= @PP_PATTERN		
		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='El registro no fue modificado, verifique. [ITEM# '+ @PP_PATTERN +']'
			RAISERROR (@VP_MENSAJE, 16, 1 ) 
		END	
	END
	ELSE
	BEGIN
		RAISERROR ('Se ha publicado una nueva versión del [MODELO] seleccionado, vuelva a elegir el modelo para refrescar los listados.', 16, 1 )
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
		SET		@VP_MENSAJE = 'No es posible [ACTUALIZAR]: ' + @VP_MENSAJE 
	END

	SELECT	@VP_MENSAJE AS MENSAJE, @PP_PATTERN AS CLAVE
	-- /////////////////////////////////////////////////////////////////////
GO


---- //////////////////////////////////////////////////////////////
---- //	STORED PROCEDURE --->	PARA MOSTRAR ALERTAS 
---- //							DE PATRONES PENDIENTES DE DEFINIR UN ORDEN.
---- //////////////////////////////////////////////////////////////
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_NOTIFICACION_ORDEN_PATRON]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_SK_NOTIFICACION_ORDEN_PATRON]
--GO
----		 EXECUTE [dbo].[PG_SK_NOTIFICACION_ORDEN_PATRON] 0,47,9703
----		 EXECUTE [dbo].[PG_SK_NOTIFICACION_ORDEN_PATRON] 0,43,9703
----		 EXECUTE [dbo].[PG_SK_NOTIFICACION_ORDEN_PATRON] 0,139,9703
--CREATE PROCEDURE [dbo].[PG_SK_NOTIFICACION_ORDEN_PATRON]
--	@PP_K_SISTEMA_EXE				INT,
--	@PP_K_USUARIO_ACCION			INT,
--	-- ===========================
--	@PP_K_GRUPO_APROBADOR			INT
--AS
--	DECLARE  @VP_MENSAJE			NVARCHAR(MAX)	= ''
--			,@VP_EXISTE				INT				= 0
--			,@VP_PENDIENTES			INT				= 0
--	-- ///////////////////////////////////////////
	
--	SELECT		@VP_EXISTE					= COUNT(K_USUARIO)
--				-- =============================	
--	FROM		BD_GENERAL.DBO.GRUPO_APROBADOR		(NOLOCK)
--				-- =============================
--	WHERE		K_USUARIO					= @PP_K_USUARIO_ACCION
--	AND			K_TIPO_GRUPO_APROBADOR		= @PP_K_GRUPO_APROBADOR
--	AND			K_ESTATUS_GRUPO_APROBADOR	= 1

--	IF @VP_EXISTE>0
--	BEGIN
--		IF	(		@PP_K_USUARIO_ACCION IN ( 47 )					---MIGUELC
--				OR	@PP_K_USUARIO_ACCION IN ( 56 )		)			---MANUELG
--		BEGIN

--			SELECT	@VP_PENDIENTES		= COUNT(K_HEADER_RMA)
--			FROM	HEADER_RMA			(NOLOCK)
--			WHERE	K_STATUS_RMA		=	2
--			AND		L_BORRADO			=	0

--		END
--		ELSE IF @PP_K_USUARIO_ACCION IN ( 43 )			---JORGEH
--		BEGIN
			
--			SELECT	@VP_PENDIENTES		= COUNT(K_HEADER_RMA)
--			FROM	HEADER_RMA			(NOLOCK)
--			WHERE	K_STATUS_RMA		=	4
--			AND		L_BORRADO			=	0
--			--AND		K_HEADER_RMA		
--			--NOT IN (	'1137',	'1138',	'1139',	'1140',	'1141',	'1142',	'1143',	
--			--		'1144',	'1145',	'1146',	'1147',	'1148',	'1149')

--		END
--		--ELSE IF @PP_K_USUARIO_ACCION IN ( 139 )			---AX
--		--BEGIN
			
--		--	SELECT	@VP_PENDIENTES		= COUNT(K_HEADER_RMA)
--		--	FROM	HEADER_RMA			(NOLOCK)
--		--	WHERE	K_STATUS_RMA		IN	(2)
--		--	AND		L_BORRADO			=	0

--		--	IF @VP_PENDIENTES > 0
--		--	BEGIN
--		--		SET @VP_MENSAJE	= 'DPTO // '
--		--	END
--		--	ELSE IF @VP_PENDIENTES = 0
--		--	BEGIN
--		--		SELECT	@VP_PENDIENTES		= COUNT(K_HEADER_RMA)
--		--		FROM	HEADER_RMA			(NOLOCK)
--		--		WHERE	K_STATUS_RMA		IN	(4)
--		--		AND		L_BORRADO			=	0

--		--		IF @VP_PENDIENTES > 0
--		--		BEGIN
--		--			SET @VP_MENSAJE	= 'MNGR // '
--		--		END
--		--	END
--		--END
	
--		IF @VP_PENDIENTES>0
--		BEGIN
--			SET @VP_MENSAJE = @VP_MENSAJE + 'Existen [Órdenes de Reemplazo] por autorizar. Da click aquí par ingresar a la pantalla.'
--		END

--	END

--	SELECT  @VP_MENSAJE AS MENSAJE, 'RMA' AS TITULO_UDA
--	-- ////////////////////////////////////////////////////////////////////
--GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////