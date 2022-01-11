-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			HOJA_EMPAQUE
-- // OPERATION:		SP'S
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210916
-- ////////////////////////////////////////////////////////////// 

USE	[DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- //////		CONTENIDO DEL SP
--	[PG_LI_HOJA_EMPAQUE]
--	[PG_LI_HOJA_EMPAQUE_X_TEXTO]
--	[PG_LI_HOJA_EMPAQUE_COLORES]
--	[PG_LI_HOJA_EMPAQUE_PROCESO]
--	[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE]
--	[PG_LI_HOJA_EMPAQUE_PROCESO_SIMBOLO]
--	[PG_LI_HOJA_EMPAQUE_CAPA]
--	[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE]
--	[PG_SK_HOJA_EMPAQUE]
--	[PG_SK_HOJA_EMPAQUE_REPORTE]
--	[PG_UP_HOJA_EMPAQUE]
--	[PG_DL_HOJA_EMPAQUE]
-- //////////////////////////////////////////////////////////////
--	[PG_IN_HOJA_EMPAQUE]
--	[PG_IN_HOJA_EMPAQUE_PROCESO]
-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE] 0,139,'( TODOS )','( TODOS )'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE] 0,139,'FAUR01','FW2'
CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	--@PP_BUSCAR						VARCHAR(25),
	--@PP_K_HOJA_EMPAQUE_STATUS				INT,
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25)
	--@PP_F_INIT						DATE,
	--@PP_F_FINISH					DATE
AS
	SET @PP_MODELNO = LTRIM(RTRIM(LEFT(@PP_MODELNO,3)))

	SELECT	DISTINCT (ITEM_P)
			,CUS_NO
			,MODELNO
			,VERSIONNO
			,LTRIM(RTRIM(D_ITEM_NO))	AS D_ITEM_NO
			,REVISION_HOJA_EMPAQUE
			,CAJA_HOJA_EMPAQUE
			,C_HOJA_EMPAQUE
			,(CASE
					WHEN	HOJA_EMPAQUE.VERSIONNO	= ISNULL(	(	SELECT	DISTINCT
																			CCVERHDR_SQL.VERSIONNO
																	FROM	CCVERHDR_SQL		(NOLOCK)
																	WHERE	CCVERHDR_SQL.STATUS			= 'L'
																	AND		CCVERHDR_SQL.SPECSTATUS		= 'U'
																	AND		CCVERHDR_SQL.CUS_NO			=	[HOJA_EMPAQUE].CUS_NO
																	AND		CCVERHDR_SQL.MODELNO		=	[HOJA_EMPAQUE].MODELNO
																	--ORDER	BY CUS_NO	,MODELNO	,VERSIONNO	
																	),0)	THEN 1
					ELSE	0
			END)	AS L_LIVE,
			L_REVISION_ACTIVA
	FROM	[HOJA_EMPAQUE]
	WHERE	( @PP_CUS_NO		= '( TODOS )'	OR	CUS_NO		= @PP_CUS_NO  )
	AND		( @PP_MODELNO		= '( T'			OR	MODELNO		= @PP_MODELNO )
	ORDER	BY CUS_NO	,MODELNO	,VERSIONNO DESC, ITEM_P, L_REVISION_ACTIVA DESC
--	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE_X_TEXTO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_X_TEXTO]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_X_TEXTO] 0,139,'',				'FAUR01','FW2'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_X_TEXTO] 0,139,'2775083X05WA6'	,'',''
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_X_TEXTO] 0,139,'PWSFCL2'			,'',''
CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_X_TEXTO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_BUSCAR						VARCHAR(25),
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25)
AS
	IF @PP_BUSCAR	= ''
	BEGIN
		SET @PP_MODELNO = LTRIM(RTRIM(LEFT(@PP_MODELNO,3)))

		SELECT	DISTINCT (ITEM_P)
				,CUS_NO
				,MODELNO
				,VERSIONNO
				,LTRIM(RTRIM(D_ITEM_NO))	AS D_ITEM_NO
				,REVISION_HOJA_EMPAQUE
				,CAJA_HOJA_EMPAQUE
				,C_HOJA_EMPAQUE
				,(CASE
						WHEN	HOJA_EMPAQUE.VERSIONNO	= ISNULL(	(	SELECT	DISTINCT
																				CCVERHDR_SQL.VERSIONNO
																		FROM	CCVERHDR_SQL		(NOLOCK)
																		WHERE	CCVERHDR_SQL.STATUS			= 'L'
																		AND		CCVERHDR_SQL.SPECSTATUS		= 'U'
																		AND		CCVERHDR_SQL.CUS_NO			=	[HOJA_EMPAQUE].CUS_NO
																		AND		CCVERHDR_SQL.MODELNO		=	[HOJA_EMPAQUE].MODELNO
																		--ORDER	BY CUS_NO	,MODELNO	,VERSIONNO	
																		),0)	THEN 1
						ELSE	0
				END)	AS L_LIVE,
				L_REVISION_ACTIVA
		FROM	[HOJA_EMPAQUE]
		WHERE	( @PP_CUS_NO		= '( TODOS )'	OR	CUS_NO		= @PP_CUS_NO  )
		AND		( @PP_MODELNO		= '( T'			OR	MODELNO		= @PP_MODELNO )
		ORDER	BY CUS_NO	,MODELNO	,VERSIONNO DESC, ITEM_P, L_REVISION_ACTIVA DESC
	END
	ELSE
	IF LEFT(@PP_BUSCAR ,1) = 'P'
	BEGIN
		SELECT	DISTINCT (ITEM_P)
				,CUS_NO
				,MODELNO
				,VERSIONNO
				,LTRIM(RTRIM(D_ITEM_NO))	AS D_ITEM_NO
				,REVISION_HOJA_EMPAQUE
				,CAJA_HOJA_EMPAQUE
				,C_HOJA_EMPAQUE
				,(CASE
						WHEN	HOJA_EMPAQUE.VERSIONNO	= ISNULL(	(	SELECT	DISTINCT
																				CCVERHDR_SQL.VERSIONNO
																		FROM	CCVERHDR_SQL		(NOLOCK)
																		WHERE	CCVERHDR_SQL.STATUS			= 'L'
																		AND		CCVERHDR_SQL.SPECSTATUS		= 'U'
																		AND		CCVERHDR_SQL.CUS_NO			=	[HOJA_EMPAQUE].CUS_NO
																		AND		CCVERHDR_SQL.MODELNO		=	[HOJA_EMPAQUE].MODELNO
																		--ORDER	BY CUS_NO	,MODELNO	,VERSIONNO	
																		),0)	THEN 1
						ELSE	0
				END)	AS L_LIVE,
				L_REVISION_ACTIVA
		FROM	HOJA_EMPAQUE
		WHERE	ITEM_NO	LIKE ( '%' + @PP_BUSCAR + '%' )
		ORDER	BY CUS_NO	,MODELNO	,VERSIONNO DESC--, ITEM_P, L_REVISION_ACTIVA DESC
	END
	ELSE
	BEGIN
		SELECT	DISTINCT (ITEM_P)
				,CUS_NO
				,MODELNO
				,VERSIONNO
				,LTRIM(RTRIM(D_ITEM_NO))	AS D_ITEM_NO
				,REVISION_HOJA_EMPAQUE
				,CAJA_HOJA_EMPAQUE
				,C_HOJA_EMPAQUE
				,(CASE
						WHEN	HOJA_EMPAQUE.VERSIONNO	= ISNULL(	(	SELECT	DISTINCT
																				CCVERHDR_SQL.VERSIONNO
																		FROM	CCVERHDR_SQL		(NOLOCK)
																		WHERE	CCVERHDR_SQL.STATUS			= 'L'
																		AND		CCVERHDR_SQL.SPECSTATUS		= 'U'
																		AND		CCVERHDR_SQL.CUS_NO			=	[HOJA_EMPAQUE].CUS_NO
																		AND		CCVERHDR_SQL.MODELNO		=	[HOJA_EMPAQUE].MODELNO
																		--ORDER	BY CUS_NO	,MODELNO	,VERSIONNO	
																		),0)	THEN 1
						ELSE	0
				END)	AS L_LIVE,
				L_REVISION_ACTIVA
		FROM		HOJA_EMPAQUE
		WHERE	CUSTOMER_ITEM_NO	LIKE ( '%' + @PP_BUSCAR + '%' )
		ORDER	BY CUS_NO	,MODELNO	,VERSIONNO DESC--, ITEM_P, L_REVISION_ACTIVA DESC
	END
 GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA EL COLOR Y NÚMERO DE PARTE CLIENTE DEL P SELECCIONADO.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE_COLORES]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES] 0,139, 'DAIM05' , 'WDK' , '8' , 'PL2ARLH',	0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSSC20',	0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2',	0
CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25),
	@PP_VERSIONNO					INT,
	@PP_ITEM_P						VARCHAR(25),
	-- ===========================
	@PP_REVISION_HOJA_EMPAQUE		INT
AS
	SELECT	COLOR, 
			LTRIM(RTRIM(CUSTOMER_ITEM_NO))	AS CUSTOMER_ITEM_NO
	FROM	[HOJA_EMPAQUE]
	WHERE	HOJA_EMPAQUE.ITEM_P					= @PP_ITEM_P
	AND		HOJA_EMPAQUE.CUS_NO					= @PP_CUS_NO	
	AND		HOJA_EMPAQUE.MODELNO				= @PP_MODELNO	
	AND		HOJA_EMPAQUE.VERSIONNO				= @PP_VERSIONNO
	AND		HOJA_EMPAQUE.REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
	AND		HOJA_EMPAQUE.L_BORRADO	<> 1
	ORDER	BY COLOR
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA EL DETALLE DE LOS SPECIAL_PROCESS POR KIT
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE_PROCESO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO] 0,139, 'DAIM05' , 'WDK' , '8' , 'PL2ARLH' ,0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSSC20' ,0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2' ,0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2' ,1
CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25),
	@PP_VERSIONNO					INT,
	@PP_ITEM_P						VARCHAR(25),
	-- ===========================
	@PP_REVISION_HOJA_EMPAQUE		INT
AS

	SELECT	--	HOJA_EMPAQUE_PROCESO.*,
			K_HOJA_EMPAQUE_PROCESO,
			HOJA_EMPAQUE_PROCESO.K_PROCESO_SIMBOLO,
			L_HOJA_EMPAQUE_PROCESO,
			--(CASE
			--	WHEN	K_PROCESO	IN (1)				THEN	1
			--	WHEN	K_PROCESO	IN (2,8,9,11,12,13)	THEN	2
			--	WHEN	K_PROCESO	IN (3,10)			THEN	3
			--	WHEN	K_PROCESO	IN (4)				THEN	4
			--	WHEN	K_PROCESO	IN (5,14,15)		THEN	5
			--	WHEN	K_PROCESO	IN (6)				THEN	6
			--	WHEN	K_PROCESO	IN (7)				THEN	7
			--	ELSE	50
			--END)	AS K_PROCESO,
			(CASE
				WHEN	K_PROCESO	< 50 	THEN	K_PROCESO
				ELSE	50
			END)	AS K_PROCESO,
			(CASE
				WHEN	D_HOJA_EMPAQUE_PROCESO <> ''	THEN	D_HOJA_EMPAQUE_PROCESO
				WHEN	D_HOJA_EMPAQUE_PROCESO =  ''	THEN	D_PROCESO_SIMBOLO
			END)										AS	D_HOJA_EMPAQUE_PROCESO,
			(	RUTA_SERVIDOR + RUTA_IMAGEN + RUTA_EXTENSION	)	AS	RUTA_AV_PROCESO_SIMBOLO
			--RUTA_AV_PROCESO_SIMBOLO						AS RUTA_AV_PROCESO_SIMBOLO
	FROM	[HOJA_EMPAQUE_PROCESO]			 (NOLOCK)
	LEFT JOIN	PROCESO_SIMBOLO (NOLOCK) ON PROCESO_SIMBOLO.K_PROCESO_SIMBOLO	= HOJA_EMPAQUE_PROCESO.K_PROCESO_SIMBOLO
	WHERE	CUS_NO					= @PP_CUS_NO
	AND		MODELNO					= @PP_MODELNO
	AND		VERSIONNO				= @PP_VERSIONNO
	AND		ITEM_P					= @PP_ITEM_P
	AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
	ORDER	BY K_PROCESO
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA EL DETALLE DE LOS SPECIAL_PROCESS POR KIT
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2' ,0	--	'FWSPAA6'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2' ,1	--	'FWSPAA6'
CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25),
	@PP_VERSIONNO					INT,
	@PP_ITEM_P						VARCHAR(25),
	-- ===========================
	@PP_REVISION_HOJA_EMPAQUE		INT
AS						   
	DECLARE	 @VP_CU_D_PROCESO		VARCHAR(500)
			,@VP_CU_R_PROCESO		NVARCHAR(MAX)
			,@VP_CONTA				INTEGER			= 0
			,@VP_STR_SQL			NVARCHAR(MAX)	= ''

	DECLARE @TA_PROCESO		AS TABLE	
	(	TA_K_PROCESO		INT	IDENTITY(1,1),
		TA_D_PROCESO_1		VARCHAR(500),
		TA_R_PROCESO_1		NVARCHAR(MAX),
		TA_D_PROCESO_2		VARCHAR(500),
		TA_R_PROCESO_2		NVARCHAR(MAX),
		TA_D_PROCESO_3		VARCHAR(500),
		TA_R_PROCESO_3		NVARCHAR(MAX),
		TA_D_PROCESO_4		VARCHAR(500),
		TA_R_PROCESO_4		NVARCHAR(MAX),
		TA_D_PROCESO_5		VARCHAR(500),
		TA_R_PROCESO_5		NVARCHAR(MAX),
		TA_D_PROCESO_6		VARCHAR(500),
		TA_R_PROCESO_6		NVARCHAR(MAX)	)

	--	INSERT INTO	@TA_PROCESO
	--	VALUES	( '', '', '', '', '', '', '', '', '', '', '', '' )

	DECLARE CU_CURSOR_PROCES	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR		
		SELECT	(CASE
					WHEN	D_HOJA_EMPAQUE_PROCESO <> ''	THEN	D_HOJA_EMPAQUE_PROCESO
					WHEN	D_HOJA_EMPAQUE_PROCESO =  ''	THEN	D_PROCESO_SIMBOLO
				END)										AS	D_HOJA_EMPAQUE_PROCESO,
				(	RUTA_SERVIDOR + RUTA_IMAGEN + RUTA_EXTENSION	)	AS	RUTA_AV_PROCESO_SIMBOLO
		FROM	[HOJA_EMPAQUE_PROCESO]			 (NOLOCK)
		LEFT JOIN	PROCESO_SIMBOLO (NOLOCK) ON PROCESO_SIMBOLO.K_PROCESO_SIMBOLO	= HOJA_EMPAQUE_PROCESO.K_PROCESO_SIMBOLO
		WHERE	CUS_NO					= @PP_CUS_NO
		AND		MODELNO					= @PP_MODELNO
		AND		VERSIONNO				= @PP_VERSIONNO
		AND		ITEM_P					= @PP_ITEM_P
		AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
		AND		L_HOJA_EMPAQUE_PROCESO	= 1
		ORDER	BY K_PROCESO
	OPEN CU_CURSOR_PROCES
	FETCH NEXT FROM  CU_CURSOR_PROCES INTO   @VP_CU_D_PROCESO		,@VP_CU_R_PROCESO
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET	@VP_CONTA += 1

		IF @VP_CONTA	= 1
		BEGIN
			INSERT INTO	@TA_PROCESO
			VALUES	( '', '', '', '', '', '', '', '', '', '', '', '' )

			UPDATE	@TA_PROCESO
			SET		TA_D_PROCESO_1	= @VP_CU_D_PROCESO,
					TA_R_PROCESO_1	= @VP_CU_R_PROCESO
		END
		IF @VP_CONTA	= 2
		BEGIN
			UPDATE	@TA_PROCESO
			SET		TA_D_PROCESO_2	= @VP_CU_D_PROCESO,
					TA_R_PROCESO_2	= @VP_CU_R_PROCESO
		END
		IF @VP_CONTA	= 3
		BEGIN
			UPDATE	@TA_PROCESO
			SET		TA_D_PROCESO_3	= @VP_CU_D_PROCESO,
					TA_R_PROCESO_3	= @VP_CU_R_PROCESO
		END
		IF @VP_CONTA	= 4
		BEGIN
			UPDATE	@TA_PROCESO
			SET		TA_D_PROCESO_4	= @VP_CU_D_PROCESO,
					TA_R_PROCESO_4	= @VP_CU_R_PROCESO
		END
		IF @VP_CONTA	= 5
		BEGIN
			UPDATE	@TA_PROCESO
			SET		TA_D_PROCESO_5	= @VP_CU_D_PROCESO,
					TA_R_PROCESO_5	= @VP_CU_R_PROCESO
		END
		IF @VP_CONTA	= 6
		BEGIN
			UPDATE	@TA_PROCESO
			SET		TA_D_PROCESO_6	= @VP_CU_D_PROCESO,
					TA_R_PROCESO_6	= @VP_CU_R_PROCESO
		END

		--SET @VP_STR_SQL = 'UPDATE @TA_PROCESO '	
		--				-- =============================	
		--				+ 'SET   TA_D_PROCESO_' + CONVERT(VARCHAR(2),@VP_CONTA)	+ ' = ' + '''' +	@VP_CU_D_PROCESO
		--				+ '		,TA_R_PROCESO_' + CONVERT(VARCHAR(2),@VP_CONTA)	+ ' = ' + '''' +	@VP_CU_R_PROCESO
		--				+ ' WHERE TA_K_PROCESO = 1'
		--				 -- =============================
		--EXECUTE sp_executesql @VP_STR_SQL
		

	FETCH NEXT FROM  CU_CURSOR_PROCES INTO   @VP_CU_D_PROCESO		,@VP_CU_R_PROCESO
	END
	CLOSE	   CU_CURSOR_PROCES
	DEALLOCATE CU_CURSOR_PROCES								  

	SELECT * FROM @TA_PROCESO	
GO
	

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA EL DETALLE DE LOS SPECIAL_PROCESS POR KIT
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_SIMBOLO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_SIMBOLO]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_SIMBOLO] 0,139, 2
CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_SIMBOLO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_TIPO_PROCESO_SIMBOLO		INT
AS
	SELECT	[PROCESO_SIMBOLO].*,
			(	RUTA_SERVIDOR + RUTA_IMAGEN + RUTA_EXTENSION	)	AS	RUTA_AV_PROCESO_SIMBOLO,
			(CASE
				WHEN	D_PROCESO_SIMBOLO = '' THEN D_TIPO_PROCESO_SIMBOLO
				ELSE	D_PROCESO_SIMBOLO
			END) AS D_TIPO_PROCESO_SIMBOLO
	FROM	[PROCESO_SIMBOLO]			(NOLOCK)
	INNER JOIN	TIPO_PROCESO_SIMBOLO	(NOLOCK)	ON TIPO_PROCESO_SIMBOLO.K_TIPO_PROCESO_SIMBOLO	= PROCESO_SIMBOLO.K_TIPO_PROCESO_SIMBOLO
	--WHERE	K_TIPO_PROCESO_SIMBOLO		= @PP_K_TIPO_PROCESO_SIMBOLO
	ORDER	BY K_PROCESO_SIMBOLO
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE_CAPA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA] 0,139,	'FAUR01'	, 'FW2'	, '11',	'PWSSC20',0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA] 0,139,	'FAUR01'	, 'FW2'	, '11',	'PWSFCL2',0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA] 0,139,	'FAUR01'	, 'FW2'	, '11',	'PWSFCL2',1
CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25),
	@PP_VERSIONNO					INT,
	@PP_ITEM_P						VARCHAR(25),
	-- ===========================
	@PP_REVISION_HOJA_EMPAQUE		INT
AS
	-- ///////////////////////////////////////////
		DECLARE @TA_HOJA_EMPAQUE_CAPA	AS TABLE	
		(	TA_K_HOJA_EMPAQUE_CAPA				INT		NOT NULL,
			-- ============================
			TA_CUS_NO							VARCHAR(6),
			TA_MODELNO							VARCHAR(3),
			TA_VERSIONNO						VARCHAR(4),
			TA_ITEM_NO_P						VARCHAR(15),
			-- ============================
			TA_N_CAPA							INT,
			TA_N_PATRONES_CAPA					INT,
			-- ============================
			TA_RUTA_AV_HOJA_EMPAQUE_CAPA		NVARCHAR(MAX),
			TA_RUTA_AV_HOJA_EMPAQUE_CAPA_NUEVA	NVARCHAR(MAX)
		)

		INSERT INTO @TA_HOJA_EMPAQUE_CAPA
		SELECT		K_HOJA_EMPAQUE_CAPA,
					CUS_NO,
					MODELNO,
					VERSIONNO,
					ITEM_P,
					N_CAPA,
					N_PATRONES_CAPA,
					--RUTA_AV_HOJA_EMPAQUE_CAPA,
					--RUTA_AV_HOJA_EMPAQUE_CAPA			--	''
					RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR + RUTA_HOJA_EMPAQUE_CAPA_MODELO + RUTA_HOJA_EMPAQUE_CAPA_IMAGEN + RUTA_HOJA_EMPAQUE_CAPA_EXTENSION,
					RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR + RUTA_HOJA_EMPAQUE_CAPA_MODELO + RUTA_HOJA_EMPAQUE_CAPA_IMAGEN + RUTA_HOJA_EMPAQUE_CAPA_EXTENSION				
					
		FROM		HOJA_EMPAQUE_CAPA					(NOLOCK)
		WHERE		CUS_NO			= @PP_CUS_NO		
		AND			MODELNO			= @PP_MODELNO		
		AND			VERSIONNO		= @PP_VERSIONNO	
		AND			ITEM_P			= @PP_ITEM_P
		AND			REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
		ORDER	BY	N_CAPA ASC
		

		WHILE	(	SELECT		COUNT(TA_K_HOJA_EMPAQUE_CAPA)
					FROM		@TA_HOJA_EMPAQUE_CAPA	) < 4
		BEGIN
			INSERT INTO @TA_HOJA_EMPAQUE_CAPA
			VALUES	(	-1					,
						@PP_CUS_NO			,
						@PP_MODELNO			,
						@PP_VERSIONNO		,
						@PP_ITEM_P			,
						(	
							SELECT		COUNT(TA_K_HOJA_EMPAQUE_CAPA)
							FROM		@TA_HOJA_EMPAQUE_CAPA	
						)	+ 1				,	--N_CAPA				,
						0					,	--N_PATRONES_CAPA		, 
						''					,	--RUTA_AV_HOJA_EMPAQUE_CAPA
						''
					)
		END

	SELECT	TA_K_HOJA_EMPAQUE_CAPA				AS	K_HOJA_EMPAQUE_CAPA				,
			-- ============================		-- ============================
			TA_CUS_NO							AS	CUS_NO							,
			TA_MODELNO							AS	MODELNO							,
			TA_VERSIONNO						AS	VERSIONNO						,
			TA_ITEM_NO_P						AS	ITEM_NO_P						,
			-- ============================		-- ============================
			TA_N_CAPA							AS	N_CAPA							,
			TA_N_PATRONES_CAPA					AS	N_PATRONES_CAPA					,
			-- ============================		-- ============================
			TA_RUTA_AV_HOJA_EMPAQUE_CAPA		AS	RUTA_AV_HOJA_EMPAQUE_CAPA		,
			TA_RUTA_AV_HOJA_EMPAQUE_CAPA_NUEVA	AS	RUTA_AV_HOJA_EMPAQUE_CAPA_ORIGEN_NUEVA	
	FROM	@TA_HOJA_EMPAQUE_CAPA
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE] 0,139,	'FAUR01'	, 'FW2'	, '11',	'PWSSC20',0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE] 0,139,	'FAUR01'	, 'FW2'	, '11',	'PWSFCL2',0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE] 0,139,	'FAUR01'	, 'FW2'	, '11',	'PWSFCL2',1
CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25),
	@PP_VERSIONNO					INT,
	@PP_ITEM_P						VARCHAR(25),
	-- ===========================
	@PP_REVISION_HOJA_EMPAQUE		INT
AS
	-- ///////////////////////////////////////////
	DECLARE	 @VP_CU_N_CAPA			INT
			,@VP_CU_N_PATRONES		INT
			,@VP_CU_R_AV_CAPA		NVARCHAR(MAX)
			,@VP_CONTA				INTEGER			= 0

	DECLARE @TA_CAPA		AS TABLE	
	(	TA_K_CAPA_HOJA		INT	IDENTITY(1,1),
		TA_N_CAPA_1			INT,
		TA_N_PATRONES_1		INT,
		TA_R_AV_CAPA_1		NVARCHAR(MAX),
		TA_N_CAPA_2			INT,
		TA_N_PATRONES_2		INT,
		TA_R_AV_CAPA_2		NVARCHAR(MAX),
		TA_N_CAPA_3			INT,
		TA_N_PATRONES_3		INT,
		TA_R_AV_CAPA_3		NVARCHAR(MAX),
		TA_N_CAPA_4			INT,
		TA_N_PATRONES_4		INT,
		TA_R_AV_CAPA_4		NVARCHAR(MAX)	)

	DECLARE CU_CURSOR_PROCES	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
		SELECT		N_CAPA,
					N_PATRONES_CAPA,
					RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR + RUTA_HOJA_EMPAQUE_CAPA_MODELO + RUTA_HOJA_EMPAQUE_CAPA_IMAGEN + RUTA_HOJA_EMPAQUE_CAPA_EXTENSION
		FROM		HOJA_EMPAQUE_CAPA					(NOLOCK)
		WHERE		CUS_NO			= @PP_CUS_NO		
		AND			MODELNO			= @PP_MODELNO		
		AND			VERSIONNO		= @PP_VERSIONNO	
		AND			ITEM_P			= @PP_ITEM_P
		AND			REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
		ORDER	BY	N_CAPA ASC
	OPEN CU_CURSOR_PROCES
		FETCH NEXT FROM  CU_CURSOR_PROCES INTO   @VP_CU_N_CAPA		,@VP_CU_N_PATRONES	,@VP_CU_R_AV_CAPA
		WHILE @@FETCH_STATUS=0
		BEGIN
			SET	@VP_CONTA += 1

			IF @VP_CONTA	= 1
			BEGIN
				INSERT INTO	@TA_CAPA
				VALUES	( '1', '0', '', '2', '0', '', '3', '0', '', '4', '0', '' )

				UPDATE	@TA_CAPA
				SET		--TA_N_CAPA_1			= @VP_CU_N_CAPA		,
						TA_N_PATRONES_1		= @VP_CU_N_PATRONES	,
						TA_R_AV_CAPA_1		= @VP_CU_R_AV_CAPA	
			END
			IF @VP_CONTA	= 2
			BEGIN
				UPDATE	@TA_CAPA
				SET		--TA_N_CAPA_2			= @VP_CU_N_CAPA		,
						TA_N_PATRONES_2		= @VP_CU_N_PATRONES	,
						TA_R_AV_CAPA_2		= @VP_CU_R_AV_CAPA	
			END
			IF @VP_CONTA	= 3
			BEGIN
				UPDATE	@TA_CAPA
				SET		--TA_N_CAPA_3			= @VP_CU_N_CAPA		,
						TA_N_PATRONES_3		= @VP_CU_N_PATRONES	,
						TA_R_AV_CAPA_3		= @VP_CU_R_AV_CAPA	
			END
			IF @VP_CONTA	= 4
			BEGIN
				UPDATE	@TA_CAPA
				SET		--TA_N_CAPA_4			= @VP_CU_N_CAPA		,
						TA_N_PATRONES_4		= @VP_CU_N_PATRONES	,
						TA_R_AV_CAPA_4		= @VP_CU_R_AV_CAPA	
			END

		FETCH NEXT FROM  CU_CURSOR_PROCES INTO   @VP_CU_N_CAPA		,@VP_CU_N_PATRONES	,@VP_CU_R_AV_CAPA	
		END
		CLOSE	   CU_CURSOR_PROCES
		DEALLOCATE CU_CURSOR_PROCES								  

		SELECT * FROM @TA_CAPA
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_HOJA_EMPAQUE]
GO
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE] 0,139, 'DAIM05' , 'WDK' , '8' , 'PL2ARLH', 0
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSSC20', 0
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2', 0
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2', 1
CREATE PROCEDURE [dbo].[PG_SK_HOJA_EMPAQUE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25),
	@PP_VERSIONNO					INT,
	@PP_ITEM_P						VARCHAR(25),
	-- ===========================
	@PP_REVISION_HOJA_EMPAQUE		INT
AS
	-- ///////////////////////////////////////////			
	DECLARE  @K_ARCUSFIL			INT
			,@K_ARCUSFIL_PROGRAM	INT
			,@CB_ARCUSFIL_PROGRAM	VARCHAR(250)

	SELECT	@CB_ARCUSFIL_PROGRAM	= RTRIM(LTRIM(PROD_CAT_DESC))
	FROM	ARCUSFIL_PROGRAM_MODEL	(NOLOCK)
	WHERE	S_ARCUSFIL_PROGRAM_MODEL	= @PP_MODELNO

	SELECT		TOP (1)
				-- =============================	 
				--S_HOJA_EMPAQUE_STATUS	, D_HOJA_EMPAQUE_STATUS	,
				------------S_TIPO_HOJA_EMPAQUE		, D_TIPO_HOJA_EMPAQUE	,
				@CB_ARCUSFIL_PROGRAM	AS PROGRAMA		,
				--CUS_NO			, --PROGRAMA		,
				--MODELNO,
				--VERSIONNO,
				-- =============================
				--ISNULL(REVISION_HOJA_EMPAQUE,'') AS CAJA_HOJA_EMPAQUE,
				ISNULL(REVISION_HOJA_EMPAQUE,0) AS REVISION_HOJA_EMPAQUE,
				K_HOJA_EMPAQUE_CAPA_DIVISION	AS DIVISION_CAPAS,
				HOJA_EMPAQUE.*
				-- =============================	
	FROM		HOJA_EMPAQUE		(NOLOCK) 
	INNER JOIN 	HOJA_EMPAQUE_STATUS		(NOLOCK) ON HOJA_EMPAQUE_STATUS.K_HOJA_EMPAQUE_STATUS	= HOJA_EMPAQUE.K_HOJA_EMPAQUE_STATUS
				-- =============================
	WHERE		HOJA_EMPAQUE.ITEM_P			= @PP_ITEM_P
	AND			HOJA_EMPAQUE.CUS_NO			= @PP_CUS_NO	
	AND			HOJA_EMPAQUE.MODELNO		= @PP_MODELNO	
	AND			HOJA_EMPAQUE.VERSIONNO		= @PP_VERSIONNO
	AND			REVISION_HOJA_EMPAQUE		= @PP_REVISION_HOJA_EMPAQUE
	AND			HOJA_EMPAQUE.L_BORRADO	<> 1
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_HOJA_EMPAQUE_REPORTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE]
GO
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'DAIM05' , 'WDK' , '8' , 'PL2ARLH', 0
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSSC20', 0
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2', 0
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2', 'FWSPAA6',1
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2', 'FWSPAD4',1
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2', 'FWSPAX7',1
CREATE PROCEDURE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25),
	@PP_VERSIONNO					INT,
	@PP_ITEM_P						VARCHAR(25),
	@PP_COLOR_P						VARCHAR(25),
	-- ===========================
	@PP_REVISION_HOJA_EMPAQUE		INT
AS
	-- ///////////////////////////////////////////			
	DECLARE  @K_ARCUSFIL			INT
			,@K_ARCUSFIL_PROGRAM	INT
			,@CB_ARCUSFIL_PROGRAM	VARCHAR(250)
			,@CB_PROGRAM			VARCHAR(250)

	SELECT	@CB_ARCUSFIL_PROGRAM		= RTRIM(LTRIM(PROD_CAT_DESC)),
			@CB_PROGRAM					= RTRIM(LTRIM(S_ARCUSFIL_PROGRAM))
	FROM	ARCUSFIL_PROGRAM_MODEL		(NOLOCK)
	WHERE	S_ARCUSFIL_PROGRAM_MODEL	= @PP_MODELNO

	SELECT		TOP (1)
				-- =============================	 
				--S_HOJA_EMPAQUE_STATUS	, D_HOJA_EMPAQUE_STATUS	,
				------------S_TIPO_HOJA_EMPAQUE		, D_TIPO_HOJA_EMPAQUE	,
				@CB_ARCUSFIL_PROGRAM	AS PROGRAMA		,
				@CB_PROGRAM				AS PROGRAMA_MODELO,
				--CUS_NO			, --PROGRAMA		,
				--MODELNO,
				--VERSIONNO,
				-- =============================
				--ISNULL(REVISION_HOJA_EMPAQUE,'') AS CAJA_HOJA_EMPAQUE,
				ISNULL(REVISION_HOJA_EMPAQUE,0) AS REVISION_HOJA_EMPAQUE,
				K_HOJA_EMPAQUE_CAPA_DIVISION	AS DIVISION_CAPAS,
				HOJA_EMPAQUE.*
				-- =============================	
	FROM		HOJA_EMPAQUE		(NOLOCK) 
	INNER JOIN 	HOJA_EMPAQUE_STATUS		(NOLOCK) ON HOJA_EMPAQUE_STATUS.K_HOJA_EMPAQUE_STATUS	= HOJA_EMPAQUE.K_HOJA_EMPAQUE_STATUS
				-- =============================
	WHERE		HOJA_EMPAQUE.ITEM_P					= @PP_ITEM_P
	AND			HOJA_EMPAQUE.CUS_NO					= @PP_CUS_NO	
	AND			HOJA_EMPAQUE.MODELNO				= @PP_MODELNO	
	AND			HOJA_EMPAQUE.VERSIONNO				= @PP_VERSIONNO
	AND			HOJA_EMPAQUE.REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
	AND			( @PP_COLOR_P = ''	OR HOJA_EMPAQUE.COLOR	= @PP_COLOR_P )
	AND			HOJA_EMPAQUE.L_BORRADO	<> 1
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> UPDATE / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_HOJA_EMPAQUE]
GO
-- EXECUTE [dbo].[PG_UP_HOJA_EMPAQUE] 0, 139,	'0' , 'FAUR01' , FW2 , '11' , 'PWSFCL2' , '' , '' , '0' , 8 , '' , 3 , 
--												'1/2' , '5/3' , ' / ' , 
--												'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesEmpaque\2775084X05WA6-capa1.PNG/\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesEmpaque\2775084X05WA6-capa2.PNG' , 
--												'-1/-1' , 
--												'39/40/41/42/43/44/-1' , '2/3/4/7/8/10/50' , '1/2/0/0/5/7/12' , '1/1/0/0/1/1/1',
--												'KUFNER R179G46/AXIS II/RECUT/SHAVING/KUFNER TX9080/REGISTERED/DIRECCION DE CORTE DE KUFNER'														
CREATE PROCEDURE [dbo].[PG_UP_HOJA_EMPAQUE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	--@PP_K_HOJA_EMPAQUE				INT,
	-- ===========================
	@PP_L_NUEVA_REVISIÓN				INT,
	-- ============================
	@PP_CUS_NO							VARCHAR(6),
	@PP_MODELNO							VARCHAR(3),
	@PP_VERSIONNO						VARCHAR(5),
	-- ============================
	@PP_ITEM_P							VARCHAR(50),	-- ES EL P DEL ITEM_NO
	-- ============================
	@PP_CAJA_HOJA_EMPAQUE				VARCHAR (150),
	@PP_DIBUJO_HOJA_EMPAQUE				VARCHAR (150),
	@PP_REVISION_HOJA_EMPAQUE			INT,			
	-- ============================
	@PP_CANTIDAD_PATRONES				INT,
	-- ============================
	@PP_C_HOJA_EMPAQUE					NVARCHAR(MAX),
	-- ============================
	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION	INT,
	---- ============================---- ============================
	@PP_ARRAY_N_CAPA					NVARCHAR(MAX),
	@PP_ARRAY_N_PATR					NVARCHAR(MAX),
	@PP_ARRAY_RUTA_C					NVARCHAR(MAX),
	@PP_ARRAY_RUTA_N					NVARCHAR(MAX),
	@PP_ARRAY_K_HOJA					NVARCHAR(MAX),
	---- ============================---- ============================
	@PP_ARRAY_K_HE_PROC					NVARCHAR(MAX),
	@PP_ARRAY_K_PROCESO					NVARCHAR(MAX),
	@PP_ARRAY_K_P_SIMBO					NVARCHAR(MAX),
	@PP_ARRAY_L_PROCESO					NVARCHAR(MAX),
	@PP_ARRAY_D_PROCESO					NVARCHAR(MAX)
	---- ============================---- ============================
AS			
DECLARE  @VP_MENSAJE					NVARCHAR(MAX)
		,@VP_CANTIDAD_PATRONES			INT	= 0
-- /////////////////////////////////////////////////////////////////////
BEGIN TRANSACTION 
BEGIN TRY
	-- =======================================================================================================================
	--	VALIDACIÓN DE CANTIDAD DE PATRONES EN LA HOJA DE EMPAQUE VS CANTIDAD REGISTRADA EN SISTEMA.
	-- =======================================================================================================================
	SELECT	TOP (1)
			@VP_CANTIDAD_PATRONES			= CANTIDAD_PATRONES
	FROM	HOJA_EMPAQUE					(NOLOCK)
	WHERE	CUS_NO							= @PP_CUS_NO	
	AND		MODELNO							= @PP_MODELNO
	AND		VERSIONNO						= @PP_VERSIONNO
	-- ============================
	AND		ITEM_P							= @PP_ITEM_P
	AND		REVISION_HOJA_EMPAQUE			= @PP_REVISION_HOJA_EMPAQUE
	
	IF	(	@VP_CANTIDAD_PATRONES	) <>	@PP_CANTIDAD_PATRONES
	BEGIN
		SET @VP_MENSAJE='La cantidad de patrones ingresada no coincide con la registrada en el sistema. [HE#'+CONVERT(VARCHAR(10),@PP_ITEM_P )+'] (' + CONVERT(VARCHAR(10),@VP_CANTIDAD_PATRONES) + ' // '+ CONVERT(VARCHAR(10),@PP_CANTIDAD_PATRONES) +')'
		RAISERROR (@VP_MENSAJE, 16, 1 ) 
	END
	-- =======================================================================================================================
	--	DECLARACIÓN DE VARIABLES DE USO GENERAL.
	-- =======================================================================================================================	
	DECLARE	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR		AS NVARCHAR(MAX)	=	'\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\'--	'\\10.1.1.5\documents\IT\001_DEVELOPER_FILES\APQP\AV_HE\'
	DECLARE @VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO		AS NVARCHAR(MAX)	=	LTRIM(RTRIM(@PP_CUS_NO)) +'\'+ LTRIM(RTRIM(@PP_MODELNO)) +'\'+ LTRIM(RTRIM(@PP_VERSIONNO)) + '\'
	DECLARE @VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN		AS NVARCHAR(MAX)	=	''
	DECLARE @VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION	AS NVARCHAR(MAX)	=	'.PNG'
	DECLARE	@VP_RUTA_IMAGEN							AS NVARCHAR(MAX)	=	''
	------------------------------------------------------------------------------
	DECLARE	@VP_REVISION_NUEVA	INT	= @PP_REVISION_HOJA_EMPAQUE + 1
	------------------------------------------------------------------------------
	DECLARE @VP_TA_RUTAS_IMAGEN		AS TABLE
		(	TA_RUTA_SERVR		NVARCHAR(MAX),
			TA_RUTA_LOCAL		NVARCHAR(MAX),
			TA_CREAR_CARP		NVARCHAR(MAX),
			TA_L_CAMBIO			INT,
			MENSAJE				VARCHAR(50) DEFAULT ''	)
	------------------------------------------------------------------------------		
	DECLARE @VP_TA_CAPAS_INCLUIDAS	AS TABLE
		(	TA_K_IDENTITY		INT IDENTITY (1,1),
			TA_N_CAPA			INT	)
	------------------------------------------------------------------------------
	DECLARE	 @VP_POSICION_N_CAPA	INT
			,@VP_POSICION_N_PATR	INT
			,@VP_POSICION_RUTA_C	INT
			,@VP_POSICION_RUTA_N	INT
			,@VP_POSICION_K_HOJA	INT
		-- ============================	
			,@VP_VALOR_N_CAPA		NVARCHAR(MAX)
			,@VP_VALOR_N_PATR		NVARCHAR(MAX)
			,@VP_VALOR_RUTA_C		NVARCHAR(MAX)
			,@VP_VALOR_RUTA_N		NVARCHAR(MAX)
			,@VP_VALOR_K_HOJA		NVARCHAR(MAX)
				
	-- =======================================================================================================================
	-- =======================================================================================================================
	IF @PP_L_NUEVA_REVISIÓN	= 1
	BEGIN
			-- =======================================================================================================================
			--	SE COLOCA INACTIVA LA REVISIÓN ACTUAL, PARA DAR PASO A LA NUEVA REVISIÓN.
			-- =======================================================================================================================
			UPDATE	HOJA_EMPAQUE
			SET		[L_REVISION_ACTIVA]				= 0	,
					-- ============================	= -- ============================
					[F_BAJA]						= GETDATE(), 
					[K_USUARIO_BAJA]				= @PP_K_USUARIO_ACCION
			WHERE	[CUS_NO]						= @PP_CUS_NO	
			AND		[MODELNO]						= @PP_MODELNO	
			AND		[VERSIONNO]						= @PP_VERSIONNO
			AND		[ITEM_P]						= @PP_ITEM_P
			AND		[REVISION_HOJA_EMPAQUE]			= @PP_REVISION_HOJA_EMPAQUE
			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='Registro no fue modificado. (0)(N)[HE#'+CONVERT(VARCHAR(10),@PP_ITEM_P )+']'
				RAISERROR (@VP_MENSAJE, 16, 1 ) 
			END
			-- =======================================================================================================================
			--	SE INGRESA LA INFORMACIÓN DEL NUEVA REVISIÓN DE LA HOJA DE EMPAQUE.
			-- =======================================================================================================================
			INSERT INTO [dbo].[HOJA_EMPAQUE] (
					[K_HOJA_EMPAQUE_STATUS]			,
					-- ============================
					[CUS_NO]						,	[MODELNO]						,
					[VERSIONNO]						,
					-- ============================
					[ITEM_NO]						,	[COLOR]							,	
					[ITEM_P]						,	[CUSTOMER_ITEM_NO]				,	
					[D_ITEM_NO]						,
					-- ============================
					[CAJA_HOJA_EMPAQUE]				,	[DIBUJO_HOJA_EMPAQUE]			,
					[REVISION_HOJA_EMPAQUE]			,
					-- ============================
					[STANDAR_PACK]					,	[CANTIDAD_PATRONES]				,
					-- ============================
					[C_HOJA_EMPAQUE]				,	[L_REVISION_ACTIVA]				,
					-- ============================
					[K_HOJA_EMPAQUE_CAPA_DIVISION]	,
					-- ============================
					[K_TIPO_CAMBIO_KIT]				,		--AX:20211203	//	#0: SIN CAMBIOS,	#1: LONGITUD,	#2: AGREGADO/ELIMINADO PROCESOS ESPECIALES,	#3: CAMBIO PROCESOS ESPECIALES, #4 REVISIÓN
					-- ============================
					[K_USUARIO_ALTA]				,	[F_ALTA]						,
					[K_USUARIO_CAMBIO]				,	[F_CAMBIO]						,
					[L_BORRADO]						)				
			--------------------------------------------
			SELECT	[K_HOJA_EMPAQUE_STATUS]			,
					-- ============================
					[CUS_NO]						,	[MODELNO]						,
					[VERSIONNO]						,
					-- ============================
					[ITEM_NO]						,	[COLOR]							,
					[ITEM_P]						,	[CUSTOMER_ITEM_NO]				,
					[D_ITEM_NO]						,
					-- ============================
					@PP_CAJA_HOJA_EMPAQUE			,	[DIBUJO_HOJA_EMPAQUE]			,
					@VP_REVISION_NUEVA				,
					-- ============================
					[STANDAR_PACK]					,	[CANTIDAD_PATRONES]				,
					-- ============================
					@PP_C_HOJA_EMPAQUE				,	1								,
					-- ============================
					@PP_K_HOJA_EMPAQUE_CAPA_DIVISION,	
					-- ============================
					4								,	--[K_TIPO_CAMBIO_KIT]	
					-- ============================
					@PP_K_USUARIO_ACCION			,	GETDATE()						,
					@PP_K_USUARIO_ACCION			,	GETDATE()						,
					0
			FROM	[HOJA_EMPAQUE]			(NOLOCK)
			WHERE	CUS_NO					= @PP_CUS_NO
			AND		MODELNO					= @PP_MODELNO
			AND		VERSIONNO				= @PP_VERSIONNO
			AND		ITEM_P					= @PP_ITEM_P
			AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='Registro no fue ingresado.(N)[HE#'+CONVERT(VARCHAR(10),@PP_ITEM_P )+ ' // ' +CONVERT(VARCHAR(10),@VP_REVISION_NUEVA) + ']'
				RAISERROR (@VP_MENSAJE, 16, 1 ) 
			END
	END
	ELSE
	BEGIN
			-- =======================================================================================================================
			--	ACTUALIZA LA INFORMACIÓN DEL ENCABEZADO DE LA HOJA DE EMPAQUE
			-- =======================================================================================================================
			UPDATE	HOJA_EMPAQUE
			SET		[CAJA_HOJA_EMPAQUE]				= @PP_CAJA_HOJA_EMPAQUE				,
					[DIBUJO_HOJA_EMPAQUE]			= @PP_DIBUJO_HOJA_EMPAQUE			,	
					[REVISION_HOJA_EMPAQUE]			= @PP_REVISION_HOJA_EMPAQUE			,
					-- ============================ -- ============================
					[CANTIDAD_PATRONES]				= @PP_CANTIDAD_PATRONES				,
					-- ============================ -- ============================
					[C_HOJA_EMPAQUE]				= @PP_C_HOJA_EMPAQUE				,
					-- ============================ -- ============================
					[K_HOJA_EMPAQUE_CAPA_DIVISION]	= @PP_K_HOJA_EMPAQUE_CAPA_DIVISION	,
					-- ============================	= -- ============================
					[F_CAMBIO]						= GETDATE(), 
					[K_USUARIO_CAMBIO]				= @PP_K_USUARIO_ACCION
			WHERE	[CUS_NO]						= @PP_CUS_NO	
			AND		[MODELNO]						= @PP_MODELNO	
			AND		[VERSIONNO]						= @PP_VERSIONNO
			AND		[ITEM_P]						= @PP_ITEM_P
			AND		[REVISION_HOJA_EMPAQUE]			= @PP_REVISION_HOJA_EMPAQUE
			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='Registro no fue modificado. [HE#'+CONVERT(VARCHAR(10),@PP_ITEM_P )+']'
				RAISERROR (@VP_MENSAJE, 16, 1 ) 
			END
	END

	-- ========================================================================================================================================================================
	-- ========================================================================================================================================================================
	-- ========================================================================================================================================================================
	-- ========================================================================================================================================================================
	--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
	SET	@PP_ARRAY_N_CAPA		= @PP_ARRAY_N_CAPA	+ '/'
	SET	@PP_ARRAY_N_PATR		= @PP_ARRAY_N_PATR	+ '/'
	SET	@PP_ARRAY_RUTA_C		= @PP_ARRAY_RUTA_C	+ '/'
	SET	@PP_ARRAY_RUTA_N		= @PP_ARRAY_RUTA_N	+ '/'
	SET	@PP_ARRAY_K_HOJA		= @PP_ARRAY_K_HOJA	+ '/'	
	--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
	WHILE patindex('%/%' , @PP_ARRAY_N_CAPA) <> 0
	BEGIN
		SELECT @VP_POSICION_N_CAPA	=	patindex(	'%/%' , @PP_ARRAY_N_CAPA	)
		SELECT @VP_POSICION_N_PATR	=	patindex(	'%/%' , @PP_ARRAY_N_PATR	)
		SELECT @VP_POSICION_RUTA_C	=	patindex(	'%/%' , @PP_ARRAY_RUTA_C	)
		SELECT @VP_POSICION_RUTA_N	=	patindex(	'%/%' , @PP_ARRAY_RUTA_N	)
		SELECT @VP_POSICION_K_HOJA	=	patindex(	'%/%' , @PP_ARRAY_K_HOJA	)

		--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
		SELECT @VP_VALOR_N_CAPA	= LEFT(	@PP_ARRAY_N_CAPA	, @VP_POSICION_N_CAPA	- 1	)
		SELECT @VP_VALOR_N_PATR	= LEFT(	@PP_ARRAY_N_PATR	, @VP_POSICION_N_PATR	- 1	)
		SELECT @VP_VALOR_RUTA_C	= LEFT(	@PP_ARRAY_RUTA_C	, @VP_POSICION_RUTA_C	- 1	)
		SELECT @VP_VALOR_RUTA_N	= LEFT(	@PP_ARRAY_RUTA_N	, @VP_POSICION_RUTA_N	- 1	)
		SELECT @VP_VALOR_K_HOJA	= LEFT(	@PP_ARRAY_K_HOJA	, @VP_POSICION_K_HOJA	- 1	)
			--========================================================================================================================================
			--	SE VALIDA SI ES UNA ACTUALIZACIÓN DE VALORES EN LA CAPA DE LA HOJA DE EMPAQUE. EL VALOR DE LA RUTA NO PUEDE VENIR VACÍO, 
			--	ESTO SUCEDE CUANDO SE ELIMINA LA IMAGEN DE LA CAPA, SE COLOCA COMO VACÍO, PERO EL USUARIO DEBE AGREGAR UNA NUEVA ANTES DE GUARDAR EL REGISTRO.
			--========================================================================================================================================
			IF	@VP_VALOR_RUTA_N	= ''
			BEGIN
				SET @VP_MENSAJE='Es necesario indicar una imagen para todas las capas activas de la Hoja de Empaque. [Capa# '+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
				RAISERROR (@VP_MENSAJE, 16, 1 ) 
			END						
			--========================================================================================================================================
			--========================================================================================================================================
			IF @PP_L_NUEVA_REVISIÓN	= 0
			BEGIN
					-- ===============================================================================================================================================
					-- ===============================================================================================================================================
					-- ===============================================================================================================================================
					IF	@VP_VALOR_K_HOJA	>  0
					BEGIN
						DECLARE	@VP_L_CAMBIO AS INTEGER	= 0

						UPDATE	[HOJA_EMPAQUE_CAPA]
						SET		-- ========================== 
								[N_CAPA]					= @VP_VALOR_N_CAPA,
								[N_PATRONES_CAPA]			= @VP_VALOR_N_PATR
								-- ========================== 
						WHERE	K_HOJA_EMPAQUE_CAPA			= @VP_VALOR_K_HOJA

						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El registro no fue actualizado. [KHE# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END	

						--	SI LA RUTA ORIGEN Y LA RUTA NUEVA SON IGUALES, ES POR QUE NO SUFRIÓ CAMBIOS EL REGISTRO EN LO QUE SE REFIERE A LA IMAGEN DE LA CAPA.
						IF @VP_VALOR_RUTA_C	<>	@VP_VALOR_RUTA_N
						BEGIN
							SET @VP_L_CAMBIO	= 1
						END
						
						INSERT INTO @VP_TA_RUTAS_IMAGEN
						(	 TA_RUTA_SERVR		,TA_RUTA_LOCAL	
							,TA_CREAR_CARP
							,TA_L_CAMBIO
							,MENSAJE	)
						VALUES
						(	 @VP_VALOR_RUTA_C	,@VP_VALOR_RUTA_N
							,@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO
							,@VP_L_CAMBIO
							,''			)
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El registro de la ruta no fue ingresado. [KHE# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'-'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END	

					END
					ELSE
					BEGIN
						SET @VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	=	LTRIM(RTRIM(@PP_ITEM_P)) +'_'+FORMAT(@PP_REVISION_HOJA_EMPAQUE,'000') +'_'+ CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)
										
						SET	@VP_RUTA_IMAGEN	=	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO		+
												@VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION

						INSERT INTO [HOJA_EMPAQUE_CAPA]
							(
								[CUS_NO]						,	[MODELNO]			,
								[VERSIONNO]						,
								-- ============================	
								[ITEM_P]						,	[REVISION_HOJA_EMPAQUE]			,
								-- ============================	
								[N_CAPA]						,	[N_PATRONES_CAPA]	,
								-- ============================	
								--[RUTA_AV_HOJA_EMPAQUE_CAPA]		,
								[RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR]	,
								[RUTA_HOJA_EMPAQUE_CAPA_MODELO]		,
								[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]		,
								[RUTA_HOJA_EMPAQUE_CAPA_EXTENSION]	,
								-- ============================	
								[K_USUARIO_ALTA]				,	[F_ALTA]			,
								[K_USUARIO_CAMBIO]				,	[F_CAMBIO]			
							)
						VALUES
							(	
								@PP_CUS_NO						,	@PP_MODELNO			,	
								@PP_VERSIONNO					,
								-- ============================	
								@PP_ITEM_P						,	@PP_REVISION_HOJA_EMPAQUE		,
								-- ============================	
								@VP_VALOR_N_CAPA				,	@VP_VALOR_N_PATR	,
								-- ============================	
								--@VP_RUTA_IMAGEN					,
								@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	 ,
								@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO	 ,
								@VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	 ,
								@VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION ,
								-- ============================	
								@PP_K_USUARIO_ACCION			,	GETDATE()			,
								@PP_K_USUARIO_ACCION			,	GETDATE()
							)																															
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='La información de la capa no fue ingresada. [CAPA#'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 )
						END

						INSERT INTO @VP_TA_RUTAS_IMAGEN
						(	 TA_RUTA_SERVR		,TA_RUTA_LOCAL		
							,TA_CREAR_CARP
							,TA_L_CAMBIO
							,MENSAJE	)
						VALUES
						(	@VP_RUTA_IMAGEN		,	@VP_VALOR_RUTA_N
							,@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO
							,1
							,''			)
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El registro de la ruta no fue ingresado. [KHE# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'-'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END	

					END
						
					-- ===============================================================================================================================================
					-- ===============================================================================================================================================
					INSERT INTO @VP_TA_CAPAS_INCLUIDAS
					VALUES	( @VP_VALOR_N_CAPA )
					IF @@ROWCOUNT = 0
					BEGIN
						SET @VP_MENSAJE='ERRO'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END	
					-- ===============================================================================================================================================
					-- ===============================================================================================================================================
					-- ===============================================================================================================================================
			END
			ELSE
			BEGIN
				------------------------------------------------------------------------------------------------------------------------------------------
				--	RUTA GENERICA PARA GUARDAR LAS IMAGENES.
				SET @VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	 =	LTRIM(RTRIM(@PP_ITEM_P)) +'_'+FORMAT(@VP_REVISION_NUEVA,'000') +'_'+ CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)
				------------------------------------------------------------------------------------------------------------------------------------------
				SET	@VP_RUTA_IMAGEN	=	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION

				INSERT INTO [HOJA_EMPAQUE_CAPA]
					(
						[CUS_NO]						,	[MODELNO]			,
						[VERSIONNO]						,
						-- ============================	
						[ITEM_P]						,	[REVISION_HOJA_EMPAQUE]			,
						-- ============================	
						[N_CAPA]						,	[N_PATRONES_CAPA]	,
						-- ============================	
						--[RUTA_AV_HOJA_EMPAQUE_CAPA]		,
						[RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR]	,
						[RUTA_HOJA_EMPAQUE_CAPA_MODELO]		,
						[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]		,
						[RUTA_HOJA_EMPAQUE_CAPA_EXTENSION]	,
						-- ============================	
						[K_USUARIO_ALTA]				,	[F_ALTA]			,
						[K_USUARIO_CAMBIO]				,	[F_CAMBIO]			
					)
				VALUES
					(	
						@PP_CUS_NO						,	@PP_MODELNO			,	
						@PP_VERSIONNO					,
						-- ============================	
						@PP_ITEM_P						,	@VP_REVISION_NUEVA	,
						-- ============================	
						@VP_VALOR_N_CAPA				,	@VP_VALOR_N_PATR	,
						-- ============================	
						--@VP_RUTA_IMAGEN					,
						@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	 ,
						@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO	 ,
						@VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	 ,
						@VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION ,
						-- ============================	
						@PP_K_USUARIO_ACCION			,	GETDATE()			,
						@PP_K_USUARIO_ACCION			,	GETDATE()
					)																															
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE='La información de la capa no fue ingresada.(N)[CAPA#'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END

				INSERT INTO @VP_TA_RUTAS_IMAGEN
				(	 TA_RUTA_SERVR		,TA_RUTA_LOCAL		
					,TA_CREAR_CARP
					,TA_L_CAMBIO
					,MENSAJE	)
				VALUES
				(	@VP_RUTA_IMAGEN		,	@VP_VALOR_RUTA_N
					,@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO
					,1
					,''			)
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE='El registro de la ruta no fue ingresado.(N)[KHE# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'-'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
					RAISERROR (@VP_MENSAJE, 16, 1 ) 
				END	
			END
			--========================================================================================================================================
			--========================================================================================================================================
		--Reemplazamos lo procesado con nada con la funcion stuff
		SELECT @PP_ARRAY_N_CAPA	= STUFF(@PP_ARRAY_N_CAPA	, 1, @VP_POSICION_N_CAPA , '')
		SELECT @PP_ARRAY_N_PATR	= STUFF(@PP_ARRAY_N_PATR	, 1, @VP_POSICION_N_PATR , '')			
		SELECT @PP_ARRAY_RUTA_C	= STUFF(@PP_ARRAY_RUTA_C	, 1, @VP_POSICION_RUTA_C , '')
		SELECT @PP_ARRAY_RUTA_N	= STUFF(@PP_ARRAY_RUTA_N	, 1, @VP_POSICION_RUTA_N , '')
		SELECT @PP_ARRAY_K_HOJA	= STUFF(@PP_ARRAY_K_HOJA	, 1, @VP_POSICION_K_HOJA , '')
	END
	-- ========================================================================================================================================================================
	-- ========================================================================================================================================================================
	-- ========================================================================================================================================================================
	-- ========================================================================================================================================================================
	IF @PP_L_NUEVA_REVISIÓN	= 0
	BEGIN
		--SELECT  FROM @VP_TA_CAPAS_INCLUIDAS
		DELETE	[HOJA_EMPAQUE_CAPA]
		WHERE	[CUS_NO]					= @PP_CUS_NO 
		AND		[MODELNO]					= @PP_MODELNO
		AND		[VERSIONNO]					= @PP_VERSIONNO
				-- ============================
		AND		[ITEM_P]					= @PP_ITEM_P
		AND		[REVISION_HOJA_EMPAQUE]		= @PP_REVISION_HOJA_EMPAQUE
				-- ============================
		AND		[N_CAPA]			NOT IN (	SELECT	TA_N_CAPA 
												FROM	@VP_TA_CAPAS_INCLUIDAS	)
	END

	EXECUTE [dbo].[PG_INUP_HOJA_EMPAQUE_PROCESO]	@PP_K_SISTEMA_EXE			,	@PP_K_USUARIO_ACCION	,
													@PP_L_NUEVA_REVISIÓN		,
													-- ============================
													@PP_CUS_NO					,	@PP_MODELNO				,
													@PP_VERSIONNO				,	@PP_ITEM_P				,
													@PP_REVISION_HOJA_EMPAQUE	,
													---- ===========================
													@PP_ARRAY_K_HE_PROC			,
													@PP_ARRAY_K_PROCESO			,	@PP_ARRAY_K_P_SIMBO		,
													@PP_ARRAY_L_PROCESO			,	@PP_ARRAY_D_PROCESO
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
		SET		@VP_MENSAJE = 'No es posible [Actualizar] la [Hoja de Empaque]: ' + @VP_MENSAJE 
		SELECT	@VP_MENSAJE AS MENSAJE, @PP_ITEM_P AS CLAVE	--CONCAT(	@PP_CUS_NO,	@PP_MODELNO	,@PP_VERSIONNO )	AS CLAVE		
	END
	ELSE
	BEGIN
		SELECT * FROM	@VP_TA_RUTAS_IMAGEN
	END
	-- //////////////////////////////////////////////////////////////	
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> UPDATE / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_INUP_HOJA_EMPAQUE_PROCESO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_INUP_HOJA_EMPAQUE_PROCESO]
GO
--		 EXECUTE [dbo].[PG_INUP_HOJA_EMPAQUE_PROCESO]	0, 139, '0' , 'FAUR01' , FW2 , '11' , 'PWSFCL2' , 0,
--														'39/40/41/42/43/44/-1' , '2/3/4/7/8/10/50' , '1/2/0/0/5/7/12' , '1/1/0/0/1/1/1',
--														'KUFNER R179G46/AXIS II/RECUT/SHAVING/KUFNER TX9080/REGISTERED/DIRECCION DE CORTE DE KUFNER'
CREATE PROCEDURE [dbo].[PG_INUP_HOJA_EMPAQUE_PROCESO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_L_NUEVA_REVISIÓN				INT,
	-- ============================
	@PP_CUS_NO							VARCHAR(6),
	@PP_MODELNO							VARCHAR(3),
	@PP_VERSIONNO						VARCHAR(5),
	-- ============================
	@PP_ITEM_P							VARCHAR(50),
	@PP_REVISION_HOJA_EMPAQUE			INT,
	---- ============================---- ============================
	@PP_ARRAY_K_HE_PROC					NVARCHAR(MAX),
	@PP_ARRAY_K_PROCESO					NVARCHAR(MAX),
	@PP_ARRAY_K_P_SIMBO					NVARCHAR(MAX),
	@PP_ARRAY_L_PROCESO					NVARCHAR(MAX),
	@PP_ARRAY_D_PROCESO					NVARCHAR(MAX)
	---- ============================---- ============================
AS			
	DECLARE  @VP_MENSAJE				NVARCHAR(MAX)
			,@VP_POSICION_K_HE_PROC		INT
			,@VP_POSICION_K_PROCESO		INT
			,@VP_POSICION_K_P_SIMBO		INT
			,@VP_POSICION_L_PROCESO		INT
			,@VP_POSICION_D_PROCESO		INT
		-- ============================	
			,@VP_VALOR_K_HE_PROC		NVARCHAR(MAX)
			,@VP_VALOR_K_PROCESO		NVARCHAR(MAX)
			,@VP_VALOR_K_P_SIMBO		NVARCHAR(MAX)
			,@VP_VALOR_L_PROCESO		NVARCHAR(MAX)
			,@VP_VALOR_D_PROCESO		NVARCHAR(MAX)
	-- ========================================================================================================================================================================
	-- ========================================================================================================================================================================
	-- ========================================================================================================================================================================
	-- ========================================================================================================================================================================
	-- ================================================
	-- ================================================
	--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
	SET	@PP_ARRAY_K_HE_PROC		= @PP_ARRAY_K_HE_PROC	+ '/'	
	SET	@PP_ARRAY_K_PROCESO		= @PP_ARRAY_K_PROCESO	+ '/'
	SET	@PP_ARRAY_K_P_SIMBO		= @PP_ARRAY_K_P_SIMBO	+ '/'
	SET	@PP_ARRAY_L_PROCESO		= @PP_ARRAY_L_PROCESO	+ '/'
	SET	@PP_ARRAY_D_PROCESO		= @PP_ARRAY_D_PROCESO	+ '/'	
	--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
	WHILE patindex('%/%' , @PP_ARRAY_K_PROCESO) <> 0
		BEGIN
			SELECT @VP_POSICION_K_HE_PROC	=	patindex('%/%' , @PP_ARRAY_K_HE_PROC		)			
			SELECT @VP_POSICION_K_PROCESO	=	patindex('%/%' , @PP_ARRAY_K_PROCESO		)
			SELECT @VP_POSICION_K_P_SIMBO	=	patindex('%/%' , @PP_ARRAY_K_P_SIMBO		)
			SELECT @VP_POSICION_L_PROCESO	=	patindex('%/%' , @PP_ARRAY_L_PROCESO		)
			SELECT @VP_POSICION_D_PROCESO	=	patindex('%/%' , @PP_ARRAY_D_PROCESO		)
			--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
			SELECT @VP_VALOR_K_HE_PROC	= LEFT(@PP_ARRAY_K_HE_PROC	, @VP_POSICION_K_HE_PROC	- 1)			
			SELECT @VP_VALOR_K_PROCESO	= LEFT(@PP_ARRAY_K_PROCESO	, @VP_POSICION_K_PROCESO	- 1)
			SELECT @VP_VALOR_K_P_SIMBO	= LEFT(@PP_ARRAY_K_P_SIMBO	, @VP_POSICION_K_P_SIMBO	- 1)
			SELECT @VP_VALOR_L_PROCESO	= LEFT(@PP_ARRAY_L_PROCESO	, @VP_POSICION_L_PROCESO	- 1)
			SELECT @VP_VALOR_D_PROCESO	= LEFT(@PP_ARRAY_D_PROCESO	, @VP_POSICION_D_PROCESO	- 1)
				--========================================================================================================================================
				--SE IDENTIFICA SI ES NUEVA REVISIÓN.
				--========================================================================================================================================															
			IF @PP_L_NUEVA_REVISIÓN	= 1
			BEGIN
					INSERT INTO [HOJA_EMPAQUE_PROCESO]
						(	[CUS_NO]					,	[MODELNO]				,
							[VERSIONNO]					,
							-- ============================
							[ITEM_P]					,	[REVISION_HOJA_EMPAQUE]	,
							-- ============================
							[K_PROCESO]					,	[K_PROCESO_SIMBOLO]		,
							[L_HOJA_EMPAQUE_PROCESO]	,
							-- ============================	
							[D_HOJA_EMPAQUE_PROCESO]	)
					VALUES
						(	@PP_CUS_NO						,	@PP_MODELNO			,	
							@PP_VERSIONNO					,
							-- ============================	
							@PP_ITEM_P						,	@PP_REVISION_HOJA_EMPAQUE + 1	,
							-- ============================	
							@VP_VALOR_K_PROCESO				,	@VP_VALOR_K_P_SIMBO				,
							@VP_VALOR_L_PROCESO				,
							-- ============================	
							@VP_VALOR_D_PROCESO				)																															
					IF @@ROWCOUNT = 0
					BEGIN
						SET @VP_MENSAJE='La información de la característica no fue ingresada.(P)[PROC#'+CONVERT(VARCHAR(10),@VP_VALOR_K_PROCESO)+']'
						RAISERROR (@VP_MENSAJE, 16, 1 )
					END
			END
			ELSE
			BEGIN			
				------------------------------------------------------------------------------------------------------------------------------------------
				------------------------------------------------------------------------------------------------------------------------------------------
				IF @VP_VALOR_K_P_SIMBO	= 0	AND	@VP_VALOR_K_PROCESO >= 50		-- SE ELIMINA EL REGISTRO DEL K_PROCESO 
				BEGIN
					DELETE FROM [HOJA_EMPAQUE_PROCESO]
					WHERE	[CUS_NO]					= @PP_CUS_NO 
					AND		[MODELNO]					= @PP_MODELNO
					AND		[VERSIONNO]					= @PP_VERSIONNO
							-- ============================
					AND		[ITEM_P]					= @PP_ITEM_P
					AND		[REVISION_HOJA_EMPAQUE]		= @PP_REVISION_HOJA_EMPAQUE
					AND		[K_HOJA_EMPAQUE_PROCESO]	= @VP_VALOR_K_HE_PROC
					IF @@ROWCOUNT = 0
					BEGIN
						SET @VP_MENSAJE='La información de la característica no fue ELIMINADA.(P)[PROC#'+CONVERT(VARCHAR(10),@VP_VALOR_K_HE_PROC)+CONVERT(VARCHAR(10),@VP_VALOR_K_PROCESO)+']'
						RAISERROR (@VP_MENSAJE, 16, 1 )
					END
				END
				ELSE
				BEGIN
					------------------------------------------------------------------------------------------------------------------------------------------
					IF	@VP_VALOR_K_HE_PROC	<= -1
					BEGIN

							INSERT INTO [HOJA_EMPAQUE_PROCESO]
								(	[CUS_NO]					,	[MODELNO]				,
									[VERSIONNO]					,
									-- ============================
									[ITEM_P]					,	[REVISION_HOJA_EMPAQUE]	,
									-- ============================
									[K_PROCESO]					,	[K_PROCESO_SIMBOLO]		,
									[L_HOJA_EMPAQUE_PROCESO]	,
									-- ============================	
									[D_HOJA_EMPAQUE_PROCESO]	)
							VALUES
								(	@PP_CUS_NO						,	@PP_MODELNO			,	
									@PP_VERSIONNO					,
									-- ============================	
									@PP_ITEM_P						,	@PP_REVISION_HOJA_EMPAQUE		,
									-- ============================	
									@VP_VALOR_K_PROCESO				,	@VP_VALOR_K_P_SIMBO				,
									@VP_VALOR_L_PROCESO				,
									-- ============================	
									@VP_VALOR_D_PROCESO				)																															
							IF @@ROWCOUNT = 0
							BEGIN
								SET @VP_MENSAJE='La información de la característica no fue ingresada.(P)[PROC#'+CONVERT(VARCHAR(10),@VP_VALOR_K_PROCESO)+']'
								RAISERROR (@VP_MENSAJE, 16, 1 )
							END

					END
					ELSE IF @VP_VALOR_K_HE_PROC	> 0
					BEGIN
							UPDATE	[HOJA_EMPAQUE_PROCESO]
							SET		[K_PROCESO]					= @VP_VALOR_K_PROCESO,
									[K_PROCESO_SIMBOLO]			= @VP_VALOR_K_P_SIMBO,
									[L_HOJA_EMPAQUE_PROCESO]	= @VP_VALOR_L_PROCESO,
									[D_HOJA_EMPAQUE_PROCESO]	= @VP_VALOR_D_PROCESO
							WHERE	[K_HOJA_EMPAQUE_PROCESO]	= @VP_VALOR_K_HE_PROC
							IF @@ROWCOUNT = 0
							BEGIN
								SET @VP_MENSAJE='La información de la característica no fue ELIMINADA.(P)[PROC#'+CONVERT(VARCHAR(10),@VP_VALOR_K_HE_PROC)+']'
								RAISERROR (@VP_MENSAJE, 16, 1 )
							END
					END
					------------------------------------------------------------------------------------------------------------------------------------------
				END
				------------------------------------------------------------------------------------------------------------------------------------------
				------------------------------------------------------------------------------------------------------------------------------------------
			END
			--Reemplazamos lo procesado con nada con la funcion stuff
			SELECT @PP_ARRAY_K_HE_PROC	= STUFF(@PP_ARRAY_K_HE_PROC	, 1, @VP_POSICION_K_HE_PROC , '')			
			SELECT @PP_ARRAY_K_PROCESO	= STUFF(@PP_ARRAY_K_PROCESO	, 1, @VP_POSICION_K_PROCESO , '')
			SELECT @PP_ARRAY_K_P_SIMBO	= STUFF(@PP_ARRAY_K_P_SIMBO	, 1, @VP_POSICION_K_P_SIMBO , '')			
			SELECT @PP_ARRAY_L_PROCESO	= STUFF(@PP_ARRAY_L_PROCESO	, 1, @VP_POSICION_L_PROCESO , '')
			SELECT @PP_ARRAY_D_PROCESO	= STUFF(@PP_ARRAY_D_PROCESO	, 1, @VP_POSICION_D_PROCESO , '')
		END
	-- ========================================================================================================================================================================
	-- ========================================================================================================================================================================
	-- ========================================================================================================================================================================
	-- ========================================================================================================================================================================
-- /////////////////////////////////////////////////////////////////////
GO


---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> DELETE / FICHA
---- //////////////////////////////////////////////////////////////
----	EXECUTE [dbo].[PG_DL_HOJA_EMPAQUE] 0,139,380,2,2
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_DL_HOJA_EMPAQUE]
--GO
--CREATE PROCEDURE [dbo].[PG_DL_HOJA_EMPAQUE]
--	@PP_K_SISTEMA_EXE				INT,
--	@PP_K_USUARIO_ACCION			INT,
--	-- ===========================
--	@PP_K_HOJA_EMPAQUE				INT
--AS
--DECLARE @VP_MENSAJE				NVARCHAR(MAX) = ''
--BEGIN TRANSACTION 
--BEGIN TRY
--	--/////////////////////////////////////////////////////////////
--		DECLARE @VP_STATUS_K_HEADER		INT
		
--		SELECT	@VP_STATUS_K_HEADER		= K_HOJA_EMPAQUE_STATUS
--		FROM	HOJA_EMPAQUE				(NOLOCK)
--		WHERE	K_HOJA_EMPAQUE			= @PP_K_HOJA_EMPAQUE
--		AND		L_BORRADO				<> 1
--		IF @@ROWCOUNT = 0
--		BEGIN
--			SET @VP_MENSAJE='No se obtuvo el estatus de la [Orden#'+CONVERT(VARCHAR(10),@PP_K_HOJA_EMPAQUE)+'], verifique...'
--			RAISERROR (@VP_MENSAJE, 16, 1 ) 
--		END			

--		IF @VP_STATUS_K_HEADER NOT IN ( 0, 1, 3, 5)
--		BEGIN
--			SET @VP_MENSAJE='La [Orden#'+CONVERT(VARCHAR(10),@PP_K_HOJA_EMPAQUE)+'] no puede ser eliminada, verifique...'
--			RAISERROR (@VP_MENSAJE, 16, 1 ) 
--		END
--	--////////////////////////////////////////////////////////////

--		UPDATE	HOJA_EMPAQUE
--		SET		
--				[L_BORRADO]				= 1			,
--				-- ====================
--				[F_BAJA]				= GETDATE()	,
--				[K_USUARIO_BAJA]		= @PP_K_USUARIO_ACCION
--		WHERE	K_HOJA_EMPAQUE			= @PP_K_HOJA_EMPAQUE
--		IF @@ROWCOUNT = 0
--		BEGIN
--			SET @VP_MENSAJE='la orden no puede ser borrada. [HDR#'+CONVERT(VARCHAR(10),@PP_K_HOJA_EMPAQUE)+']'
--		END

---- /////////////////////////////////////////////////////////////////////
--COMMIT TRANSACTION 
--END TRY

--BEGIN CATCH
--	ROLLBACK TRANSACTION
--	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
--	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
--	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
--END CATCH	

--	-- /////////////////////////////////////////////////////////////////////	
--	IF @VP_MENSAJE<>''
--	BEGIN
--		SET		@VP_MENSAJE = 'No es posible [ELIMINAR]: ' + @VP_MENSAJE 
--	END

--	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_HOJA_EMPAQUE AS CLAVE
--	-- /////////////////////////////////////////////////////////////////////	
--GO
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////


---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> INSERT / FICHA
---- //////////////////////////////////////////////////////////////
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_IN_HOJA_EMPAQUE]
--GO
----		 EXECUTE [dbo].[PG_IN_HOJA_EMPAQUE] 1,139,  '19' , '' , '' , 'WKL' , '0009' , 'IWKL0042CPRDX9' , '65327M11' , '0.6400' , '8' , '-1'
--CREATE PROCEDURE [dbo].[PG_IN_HOJA_EMPAQUE]
--	@PP_K_SISTEMA_EXE				INT,
--	@PP_K_USUARIO_ACCION			INT,
--	-- ===========================
--	--@PP_K_HOJA_EMPAQUE_STATUS		INT,
--	-- ============================
--	----@PP_K_QUOTE_TRIM_COLOR				INT,
--	----@PP_K_QUOTE_KIT						INT,
--	-- ============================
--	@PP_CUS_NO							VARCHAR(6),
--	----@PP_PROGRAM							VARCHAR(50),
--	@PP_MODELNO							VARCHAR(3),
--	@PP_VERSIONNO						VARCHAR(5),
--	-- ============================
--	@PP_ITEM_NO							VARCHAR(50),
--	@PP_CUSTOMER_ITEM_NO				VARCHAR(50),
--	@PP_D_ITEM_NO						VARCHAR(500),
--	-- ============================
--	--@PP_CAJA_HOJA_EMPAQUE				VARCHAR(150),
--	--@PP_DIBUJO_HOJA_EMPAQUE			VARCHAR(150),
--	--@PP_REVISION_HOJA_EMPAQUE			INT,
--	-- ============================
--	--@PP_RUTA_AYUDA_VISUAL_HEADER		VARCHAR(500),
--	@PP_K_TIPO_CAMBIO_KIT				INT,
--	@PP_K_QUOTE_TRIM_COLOR				INT,
--	@PP_K_QUOTE_KIT						INT
--	-- ============================
--	--@PP_ARRAY_O_HOJA_EMPAQUE_PROCESO	NVARCHAR(MAX),
--	--@PP_ARRAY_D_HOJA_EMPAQUE_PROCESO	NVARCHAR(MAX),
--	--@PP_ARRAY_L_AYUDA_VISUAL			NVARCHAR(MAX),
--	--@PP_ARRAY_K_AV_HOJA_EMPAQUE		NVARCHAR(MAX)
--	-- ============================
--AS			
--DECLARE  @VP_MENSAJE						NVARCHAR(MAX)
--		,@VP_K_HOJA_EMPAQUE			INT = 0
--		,@VP_K_HOJA_EMPAQUE_PREV		INT	= 0
--		,@VP_VERSIONNO_PREV					INT	= 0
--		--============================================
--		----,@VP_EXISTE						INT
--		,@VP_CAJA_HOJA_EMPAQUE			VARCHAR(150)
--		,@VP_DIBUJO_HOJA_EMPAQUE		VARCHAR(150)
--		,@VP_REVISION_HOJA_EMPAQUE		INT
--		,@VP_RUTA_AYUDA_VISUAL_HEADER	VARCHAR(500)
--		--============================================
--	--SET @PP_MODELNO = LTRIM(RTRIM(LEFT(@PP_MODELNO,3)))
----BEGIN TRANSACTION 
----BEGIN TRY
--	IF @PP_K_TIPO_CAMBIO_KIT	= 0		--AX:20210920	//	#0: SIN CAMBIOS,	#1: LONGITUD,	#2: AGREGADO/ELIMINADO PROCESOS ESPECIALES,	#3: CAMBIO PROCESOS ESPECIALES
--	BEGIN
--		--============================================
--		--	SE VERIFICA SI EXISTE INFORMACIÓN DEL MODELO EN UNA VERSIÓN PREVIA.
--		SELECT	TOP (1)
--				----@VP_EXISTE					= COUNT(K_HOJA_EMPAQUE)
--				@VP_K_HOJA_EMPAQUE_PREV	= K_HOJA_EMPAQUE		,
--				@VP_VERSIONNO_PREV				= VERSIONNO					,
--				--============================================================
--				@VP_CAJA_HOJA_EMPAQUE			= CAJA_HOJA_EMPAQUE			,
--				@VP_DIBUJO_HOJA_EMPAQUE			= DIBUJO_HOJA_EMPAQUE		,
--				@VP_REVISION_HOJA_EMPAQUE		= REVISION_HOJA_EMPAQUE		,
--				@VP_RUTA_AYUDA_VISUAL_HEADER	= RUTA_AYUDA_VISUAL_HEADER	
--				--* 
--		FROM	[HOJA_EMPAQUE]		(NOLOCK)
--		WHERE	CUS_NO				= @PP_CUS_NO
--		AND		MODELNO				= @PP_MODELNO
--		AND		ITEM_NO				= @PP_ITEM_NO			
--		AND		CUSTOMER_ITEM_NO	= @PP_CUSTOMER_ITEM_NO
--		ORDER	BY VERSIONNO
--	END
--	ELSE
--	BEGIN
--		SET @VP_K_HOJA_EMPAQUE_PREV	= 0
--		SET @VP_VERSIONNO_PREV				= 0
--		SET	@VP_CAJA_HOJA_EMPAQUE			= ''
--		SET	@VP_DIBUJO_HOJA_EMPAQUE			= ''
--		SET	@VP_REVISION_HOJA_EMPAQUE		= ''
--		SET	@VP_RUTA_AYUDA_VISUAL_HEADER	= ''
--	END
	
--	----IF	@VP_EXISTE	> 0
--	----BEGIN
--	----	SET	@PP_CAJA_HOJA_EMPAQUE			= @VP_CAJA_HOJA_EMPAQUE
--	----	SET	@PP_DIBUJO_HOJA_EMPAQUE			= @VP_DIBUJO_HOJA_EMPAQUE
--	----	SET	@PP_REVISION_HOJA_EMPAQUE		= @VP_REVISION_HOJA_EMPAQUE
--	----	SET	@PP_RUTA_AYUDA_VISUAL_HEADER	= @VP_RUTA_AYUDA_VISUAL_HEADER
--	----END
--	--============================================================================
--	--======================================INSERTAR EL HOJA_EMPAQUE
--	--============================================================================
--		INSERT INTO HOJA_EMPAQUE
--			(	-- ============================
--				[K_HOJA_EMPAQUE_STATUS]		,
--				-- ============================
--				[CUS_NO]					,	----[PROGRAM]				,
--				[MODELNO]					,	[VERSIONNO]				,
--				-- ============================
--				[ITEM_NO]					,	[CUSTOMER_ITEM_NO]		,
--				[D_ITEM_NO]					,
--				-- ============================
--				[CAJA_HOJA_EMPAQUE]			,	
--				[DIBUJO_HOJA_EMPAQUE]		,
--				[REVISION_HOJA_EMPAQUE]		,
--				-- ============================
--				[RUTA_AYUDA_VISUAL_HEADER]	,
--				[K_TIPO_CAMBIO_KIT]			,
--				-- ============================
--				[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
--				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
--		VALUES	
--			(	1,	-- @PP_K_HOJA_EMPAQUE_STATUS			,
--				-- ============================				
--				@PP_CUS_NO					,	----@PP_PROGRAM					,
--				@PP_MODELNO					,	@PP_VERSIONNO				,
--				-- ============================
--				@PP_ITEM_NO					,	@PP_CUSTOMER_ITEM_NO		,
--				@PP_D_ITEM_NO				,
--				-- ============================
--				@VP_CAJA_HOJA_EMPAQUE		,--@PP_CAJA_HOJA_EMPAQUE		,	
--				@VP_DIBUJO_HOJA_EMPAQUE		,--@PP_DIBUJO_HOJA_EMPAQUE		,
--				@VP_REVISION_HOJA_EMPAQUE	,--@PP_REVISION_HOJA_EMPAQUE	,
--				-- ============================
--				@VP_RUTA_AYUDA_VISUAL_HEADER,--@PP_RUTA_AYUDA_VISUAL_HEADER,
--				@PP_K_TIPO_CAMBIO_KIT,	--AX:20210920	//	#0: SIN CAMBIOS,	#1: LONGITUD,	#2: AGREGADO/ELIMINADO PROCESOS ESPECIALES,	#3: CAMBIO PROCESOS ESPECIALES
--				-- ============================
--				@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
--				0, NULL, NULL  )

--		IF @@ROWCOUNT = 0
--		BEGIN
--			SET @VP_MENSAJE='No se generó. [HDR#'+CONVERT(VARCHAR(10),@VP_K_HOJA_EMPAQUE)+']'
--			RAISERROR (@VP_MENSAJE, 16, 1 ) 
--		END
--		ELSE
--		BEGIN
--			SELECT @VP_K_HOJA_EMPAQUE	= SCOPE_IDENTITY()

--			IF	( @VP_K_HOJA_EMPAQUE	= 0 OR @VP_K_HOJA_EMPAQUE IS NULL )
--			BEGIN
--				RAISERROR ('Error en la asignación de identidad.[HDR]', 16, 1 ) 
--			END
--		END

--		EXECUTE [PG_IN_HOJA_EMPAQUE_PROCESO]	@PP_K_SISTEMA_EXE	,	@PP_K_USUARIO_ACCION,
--												-- ============================
--												@PP_CUS_NO						,	@PP_MODELNO					,
--												@PP_VERSIONNO					,	
--												-- ============================
--												@PP_ITEM_NO						,	@PP_CUSTOMER_ITEM_NO		,
--												-- ============================
--												@PP_K_TIPO_CAMBIO_KIT			,	@VP_K_HOJA_EMPAQUE	,
--												@VP_K_HOJA_EMPAQUE_PREV	,	@VP_VERSIONNO_PREV			,
--												-- ============================
--												@PP_K_QUOTE_TRIM_COLOR			,	@PP_K_QUOTE_KIT
---- /////////////////////////////////////////////////////////////////////
----COMMIT TRANSACTION 
----END TRY

----BEGIN CATCH
----	/* Ocurrió un error, deshacemos los cambios*/ 
----	ROLLBACK TRANSACTION
----	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
----	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
----	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
----END CATCH	
----	-- /////////////////////////////////////////////////////////////////////	
----	IF @VP_MENSAJE<>''
----	BEGIN
----		SET		@VP_MENSAJE = 'No es posible [Insertar] la [Orden]: ' + @VP_MENSAJE 
----	END
----	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_HOJA_EMPAQUE AS CLAVE
--	-- //////////////////////////////////////////////////////////////
--GO

---- //////////////////////////////////////////////////////////////
---- // PARA INSERTAR LOS DETALLES DE LA ORDEN
---- // STORED PROCEDURE ---> INSERT / FICHA
---- //////////////////////////////////////////////////////////////
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_HOJA_EMPAQUE_PROCESO]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_IN_HOJA_EMPAQUE_PROCESO]
--GO
--CREATE PROCEDURE [dbo].[PG_IN_HOJA_EMPAQUE_PROCESO]
--	@PP_K_SISTEMA_EXE			INT,
--	@PP_K_USUARIO_ACCION		INT,
--	-- ============================
--	@PP_CUS_NO						VARCHAR(6),
--	@PP_MODELNO						VARCHAR(3),
--	@PP_VERSIONNO					VARCHAR(5),
--	-- ============================
--	@PP_ITEM_NO						VARCHAR(50),
--	@PP_CUSTOMER_ITEM_NO			VARCHAR(50),
--	-- ============================
--	@PP_K_TIPO_CAMBIO_KIT			INT,
--	-- ============================
--	@PP_K_HOJA_EMPAQUE		INT,
--	@PP_K_HOJA_EMPAQUE_PREV	INT,
--	@PP_VERSIONNO_PREV				INT,
--	@PP_K_QUOTE_TRIM_COLOR			INT,
--	@PP_K_QUOTE_KIT					INT
--AS
--	DECLARE  @VP_MENSAJE					NVARCHAR(MAX) = ''
--			-- =====================
--			,@VP_CU_O_HOJA_EMPAQUE_PROCESO		INT	= 0
--			-- =====================
--			,@VP_CU_D_HOJA_EMPAQUE_PROCESO		VARCHAR(500)
--			,@VP_CU_L_AYUDA_VISUAL				VARCHAR(500)
--			,@VP_CU_K_AV_HOJA_EMPAQUE			INT	= 1
--			-- =====================
--			,@VP_CU_D_PROCESS					VARCHAR(500)
--			-- =====================
--			,@VP_O_REGISTROS					INT	= 0

--	IF @PP_K_HOJA_EMPAQUE_PREV = 0
--	BEGIN

--		DECLARE CU_CURSOR		CURSOR LOCAL FOR
--			SELECT	--*
--					DISTINCT QUOTE_PROCESS_SPECIAL_COST_CHECKS.K_PROCESS,
--					D_QUOTE_PROCESS_SPECIAL_COST,
--					1,
--					1,
--					D_PROCESS
--			FROM	COT19_Cotizaciones_V9999_R0.dbo.QUOTE_PROCESS_SPECIAL_COST_CHECKS
--			INNER JOIN	COT19_Cotizaciones_V9999_R0.dbo.QUOTE_PROCESS_SPECIAL_COST	ON QUOTE_PROCESS_SPECIAL_COST.K_QUOTE_TRIM_LEVEL	= QUOTE_PROCESS_SPECIAL_COST_CHECKS.K_QUOTE_TRIM_LEVEL
--			INNER JOIN	COT19_Cotizaciones_V9999_R0.dbo.PROCESS						ON PROCESS.K_PROCESS								= QUOTE_PROCESS_SPECIAL_COST_CHECKS.K_PROCESS
--			AND			QUOTE_PROCESS_SPECIAL_COST.K_PROCESS		= QUOTE_PROCESS_SPECIAL_COST_CHECKS.K_PROCESS
--			WHERE	QUOTE_PROCESS_SPECIAL_COST_CHECKS.K_QUOTE_TRIM_COLOR		= @PP_K_QUOTE_TRIM_COLOR
--			AND		QUOTE_PROCESS_SPECIAL_COST_CHECKS.K_QUOTE_KIT				= @PP_K_QUOTE_KIT
--			ORDER	BY D_PROCESS
--		OPEN CU_CURSOR
--		FETCH NEXT FROM CU_CURSOR INTO	@VP_CU_O_HOJA_EMPAQUE_PROCESO	,@VP_CU_D_HOJA_EMPAQUE_PROCESO	,@VP_CU_L_AYUDA_VISUAL	,@VP_CU_K_AV_HOJA_EMPAQUE	,@VP_CU_D_PROCESS
--			WHILE @@FETCH_STATUS = 0
--			BEGIN
--				SET	@VP_O_REGISTROS += 1
--				-----	====================================================================================================================
--				-----	/////////					SE INSERTALA INFORMACIÓN DE AQUELLOS KIT QUE NO CONTIENEN HOJA DE EMPAQUE.		20210915
--				INSERT INTO	[dbo].[HOJA_EMPAQUE_PROCESO] 
--				(		[K_HOJA_EMPAQUE]			,
--						-- ============================
--						[O_HOJA_EMPAQUE_PROCESO]		,
--						-- ============================
--						[D_HOJA_EMPAQUE_PROCESO]		,
--						[L_AYUDA_VISUAL]				,
--						[K_AV_HOJA_EMPAQUE]				,
--						-- ============================
--						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
--						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
--				VALUES	
--					(	@PP_K_HOJA_EMPAQUE		,
--						-- ============================
--						@VP_O_REGISTROS	,
--						-- ============================
--						@VP_CU_D_HOJA_EMPAQUE_PROCESO	,	
--						@VP_CU_L_AYUDA_VISUAL			,
--						@VP_CU_K_AV_HOJA_EMPAQUE		,
--						-- ============================
--						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
--						0, NULL, NULL  )
--				IF @@ROWCOUNT = 0
--				BEGIN
--					SET @VP_MENSAJE = '[HOJAS_EMPAQUE] No fue posible insertar el registro en la tabla: ' + LTRIM(RTRIM(@PP_CUSTOMER_ITEM_NO)) + ' // '+ CONVERT(VARCHAR(50),@PP_K_HOJA_EMPAQUE) +'... Informe a SISTEMAS.'
--					RAISERROR (@VP_MENSAJE, 16, 1 ) 				
--				END
--				--END
--			-----	====================================================================================================================
--				FETCH NEXT FROM CU_CURSOR INTO	@VP_CU_O_HOJA_EMPAQUE_PROCESO	,@VP_CU_D_HOJA_EMPAQUE_PROCESO	,@VP_CU_L_AYUDA_VISUAL	,@VP_CU_K_AV_HOJA_EMPAQUE	,@VP_CU_D_PROCESS
--			END
--		CLOSE		CU_CURSOR
--		DEALLOCATE	CU_CURSOR
--	-- ////////////////////////////////////////////////////////////////
--	END
--	ELSE
--	BEGIN
--		DECLARE CU_CURSOR		CURSOR LOCAL FOR
--			SELECT	--*
--					[O_HOJA_EMPAQUE_PROCESO],
--					-- =====================
--					[D_HOJA_EMPAQUE_PROCESO],
--					[L_AYUDA_VISUAL]		,
--					[K_AV_HOJA_EMPAQUE]		
--			FROM	[HOJA_EMPAQUE_PROCESO]		(NOLOCK)
--			WHERE	K_HOJA_EMPAQUE		= @PP_K_HOJA_EMPAQUE_PREV
--			ORDER	BY O_HOJA_EMPAQUE_PROCESO	ASC
--		OPEN CU_CURSOR
--		FETCH NEXT FROM CU_CURSOR INTO	@VP_CU_O_HOJA_EMPAQUE_PROCESO	,@VP_CU_D_HOJA_EMPAQUE_PROCESO	,@VP_CU_L_AYUDA_VISUAL	,@VP_CU_K_AV_HOJA_EMPAQUE
--			WHILE @@FETCH_STATUS = 0
--			BEGIN
--			-----	====================================================================================================================
--			-----	/////////					SE INSERTALA INFORMACIÓN DE AQUELLOS KIT QUE NO CONTIENEN HOJA DE EMPAQUE.		20210915

--				INSERT INTO	[dbo].[HOJA_EMPAQUE_PROCESO] 
--				(		[K_HOJA_EMPAQUE]			,
--						-- ============================
--						[O_HOJA_EMPAQUE_PROCESO]		,
--						-- ============================
--						[D_HOJA_EMPAQUE_PROCESO]		,
--						[L_AYUDA_VISUAL]				,
--						[K_AV_HOJA_EMPAQUE]				,
--						-- ============================
--						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
--						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
--				VALUES	
--					(	@PP_K_HOJA_EMPAQUE		,
--						-- ============================
--						@VP_CU_O_HOJA_EMPAQUE_PROCESO	,
--						-- ============================
--						@VP_CU_D_HOJA_EMPAQUE_PROCESO	,	
--						@VP_CU_L_AYUDA_VISUAL			,
--						@VP_CU_K_AV_HOJA_EMPAQUE		,
--						-- ============================
--						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
--						0, NULL, NULL  )
--				IF @@ROWCOUNT = 0
--				BEGIN
--					SET @VP_MENSAJE = '[HOJAS_EMPAQUE] No fue posible insertar el registro en la tabla: ' + LTRIM(RTRIM(@PP_CUSTOMER_ITEM_NO)) + ' // '+ CONVERT(VARCHAR(50),@PP_K_HOJA_EMPAQUE) +'... Informe a SISTEMAS.'
--					RAISERROR (@VP_MENSAJE, 16, 1 ) 				
--				END
--				--END
--			-----	====================================================================================================================
--				FETCH NEXT FROM CU_CURSOR INTO	@VP_CU_O_HOJA_EMPAQUE_PROCESO	,@VP_CU_D_HOJA_EMPAQUE_PROCESO	,@VP_CU_L_AYUDA_VISUAL	,@VP_CU_K_AV_HOJA_EMPAQUE			
--			END
--		CLOSE		CU_CURSOR
--		DEALLOCATE	CU_CURSOR
--	END
--	-- ////////////////////////////////////////////////////////////////
--	-- ///////////////////////////////////////////////////////////////
--GO
