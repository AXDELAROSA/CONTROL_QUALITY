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
--	[PG_LI_IMPRIMIR_HOJA_EMPAQUE_X_ORDEN]
--	[PG_LI_HOJA_EMPAQUE_COLORES]		--	FUE REEMPLAZADO POR EL QUE FUNCIONARÁ PARA LOS U NUMBERS
--	[PG_LI_HOJA_EMPAQUE_COLORES_U]		--	PARA REEMPLAZAR EL USADO ACTUALMENTE
--	[PG_LI_HOJA_EMPAQUE_PROCESO]
--	[PG_LI_HOJA_EMPAQUE_PROCESO_U]
--	[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE]
--	[PG_LI_HOJA_EMPAQUE_PROCESO_SIMBOLO]
--	[PG_LI_HOJA_EMPAQUE_CAPA]
--	[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE]
--	[PG_SK_HOJA_EMPAQUE]
--	[PG_SK_HOJA_EMPAQUE_REPORTE]
--	[PG_UP_HOJA_EMPAQUE]
--	[PG_INUP_HOJA_EMPAQUE_PROCESO]
-- //////////////////////////////////////////////////////////////
-- //////		SE MANDA LLAMAR DESDE EL SISTEMA DE COTIZACIONES
--	[PG_IN_HOJA_EMPAQUE_VERSION]
--	[PG_IN_HOJA_EMPAQUE_VERSION_PROCESO]
--	[PG_PR_COPIAR_IMAGEN_CAPA]
--	[PG_PR_LIMPIAR_RUTA_IMAGEN]
-- //////////////////////////////////////////////////////////////
--	[PG_INUP_HOJA_EMPAQUE]		-- REEMPLAZARÁ A [PG_UP_HOJA_EMPAQUE]
--	[PG_IN_HOJA_EMPAQUE_U]
--	[PG_UP_HOJA_EMPAQUE_U]
--	[PG_INUP_HOJA_EMPAQUE_PROCESO_U]
-- //////////////////////////////////////////////////////////////


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE] 0,139,'( TODOS )','( TODOS )'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE] 0,139,'FAUR01','FW2'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE] 0,139,'DAIM05','WDK'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE] 0,139,'MAGN02','WAL'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE] 0,139,'MAGN03','WD2'
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
			END)	AS L_LIVE
			,L_REVISION_ACTIVA
			,(	CASE	
					WHEN	L_CAPAS_COMPLETAS	= 0	THEN 'NO'
					WHEN	L_CAPAS_COMPLETAS	= 1	THEN 'SI'
			END) AS L_CAPAS_COMPLETAS
			,(	CASE
					WHEN	U_ITEM	<> ''	THEN	'SI'
					ELSE	'NO'
			END) AS L_U_ITEM
			,ISNULL(U_ITEM,'--------')	 AS U_ITEM
	FROM	[HOJA_EMPAQUE]		(NOLOCK)
	WHERE	( @PP_CUS_NO		= '( TODOS )'	OR	CUS_NO		= @PP_CUS_NO  )
	AND		( @PP_MODELNO		= '( T'			OR	MODELNO		= @PP_MODELNO )
	ORDER	BY CUS_NO	,MODELNO	,VERSIONNO DESC, U_ITEM DESC, ITEM_P, L_REVISION_ACTIVA DESC
--	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE_X_TEXTO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_X_TEXTO]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_X_TEXTO] 0,139, '',		'',				'FAUR01','FW2'						 ,1
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_X_TEXTO] 0,139, '',		'2775083X05WA6'	,'',''								 ,1
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_X_TEXTO] 0,139, '',		'PWSFCL2'		,'',''								 ,1
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_X_TEXTO] 0,139, '53037', ''				,'',''								 ,1
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_X_TEXTO] 0,139, '' , '' , 'DAIM05' , 'WDK // 2021 WK WD 2ND ROW ARMREST' , '0',0
CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_X_TEXTO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_ORDEN						VARCHAR(25),
	@PP_ITEM						VARCHAR(25),
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25),
	-- ===========================
	@PP_PERMISOS_APP				INT
AS

	DECLARE  @VP_HORA			INT			= FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
	DECLARE  @VP_TURNO			VARCHAR(5)	= '2'
	
	IF @VP_HORA > 2000 AND @VP_HORA < 60002
		SET @VP_TURNO = '3'
	ELSE IF @VP_HORA > 60001 AND @VP_HORA < 153001
		SET @VP_TURNO = '1'


IF @PP_PERMISOS_APP	= 0
BEGIN
	IF @PP_ORDEN	<> ''
	BEGIN
	EXECUTE	[dbo].[PG_LI_IMPRIMIR_HOJA_EMPAQUE_X_ORDEN]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
														-- ===========================
														@PP_ORDEN
	END
END
ELSE
BEGIN
	-- =========================================================================================================
	--	LA PRIORIDAD PARA BUSCAR ES POR ORDEN
	IF @PP_ORDEN	<> ''
	BEGIN
		EXECUTE	[dbo].[PG_LI_IMPRIMIR_HOJA_EMPAQUE_X_ORDEN]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
															-- ===========================
															@PP_ORDEN
	END
	ELSE
	-- =========================================================================================================
	--	LA SEGUNDA OPCIÓN ES BUSCAR POR "P"/"U" O POR NÚMERO DE PARTE DEL CLIENTE
	IF @PP_ITEM	<> ''
	BEGIN
		IF LEFT(@PP_ITEM ,1) = 'P'
		BEGIN
			SELECT	--DISTINCT (ITEM_P)
					 ITEM_NO
					,CUS_NO
					,MODELNO
					,VERSIONNO
					,LTRIM(RTRIM(D_ITEM_NO))	AS D_ITEM_NO
					,REVISION_HOJA_EMPAQUE
					,COLOR
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
					,(	CASE
							WHEN	U_ITEM	<> ''	THEN	'SI'
							ELSE	'NO'
					END) AS U_ITEM
			--	===========================================================================
					,0					AS SER_NO
					,'-'				AS MESA
					,@VP_TURNO			AS TURNO
					,0					AS IMPRIMIR
			FROM	HOJA_EMPAQUE		(NOLOCK)
			WHERE	ITEM_NO	LIKE ( '%' + @PP_ITEM + '%' )
			ORDER	BY CUS_NO	,MODELNO	,VERSIONNO DESC--, ITEM_P, L_REVISION_ACTIVA DESC
		END
		ELSE
		BEGIN
			SELECT	--DISTINCT (ITEM_P)
					 ITEM_NO
					,CUS_NO
					,MODELNO
					,VERSIONNO
					,LTRIM(RTRIM(D_ITEM_NO))	AS D_ITEM_NO
					,REVISION_HOJA_EMPAQUE
					,COLOR
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
					,(	CASE
							WHEN	U_ITEM	<> ''	THEN	'SI'
							ELSE	'NO'
					END) AS U_ITEM
			--	===========================================================================
					,0					AS SER_NO
					,'-'				AS MESA
					,@VP_TURNO			AS TURNO
					,0					AS IMPRIMIR
			FROM		HOJA_EMPAQUE	(NOLOCK)
			WHERE	CUSTOMER_ITEM_NO	LIKE ( '%' + @PP_ITEM + '%' )
			ORDER	BY CUS_NO	,MODELNO	,VERSIONNO DESC--, ITEM_P, L_REVISION_ACTIVA DESC
		END
	END
	ELSE
	-- =========================================================================================================
	--	LA OPCIÓN FINAL SERÁ BUSCAR TODOS LOS COMPONENTES QUE PERTENEZCAN AL CLIENTE, MODELO.
	BEGIN
		SET @PP_MODELNO = LTRIM(RTRIM(LEFT(@PP_MODELNO,3)))

		SELECT	--DISTINCT (ITEM_P)
				 ITEM_NO
				,CUS_NO
				,MODELNO
				,VERSIONNO
				,LTRIM(RTRIM(D_ITEM_NO))	AS D_ITEM_NO
				,REVISION_HOJA_EMPAQUE
				,COLOR
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
				,(	CASE
						WHEN	U_ITEM	<> ''	THEN	'SI'
						ELSE	'NO'
				END) AS U_ITEM
		--	===========================================================================
				,0					AS SER_NO
				,'-'				AS MESA
				,@VP_TURNO			AS TURNO
				,0					AS IMPRIMIR
		FROM	[HOJA_EMPAQUE]		(NOLOCK)
		WHERE	( @PP_CUS_NO		= '( TODOS )'	OR	CUS_NO		= @PP_CUS_NO  )
		AND		( @PP_MODELNO		= '( T'			OR	MODELNO		= @PP_MODELNO )
		ORDER	BY CUS_NO	,MODELNO	,VERSIONNO DESC, ITEM_P, L_REVISION_ACTIVA DESC
	END
END
 GO


 -- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_IMPRIMIR_HOJA_EMPAQUE_X_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_IMPRIMIR_HOJA_EMPAQUE_X_ORDEN]
GO
--		 EXECUTE [DBO].[PG_LI_IMPRIMIR_HOJA_EMPAQUE_X_ORDEN] 0 ,0,  '53036' -- MAGN02
--		 EXECUTE [DBO].[PG_LI_IMPRIMIR_HOJA_EMPAQUE_X_ORDEN] 0 ,0,  '53037' -- MAGN02
CREATE PROCEDURE [dbo].[PG_LI_IMPRIMIR_HOJA_EMPAQUE_X_ORDEN]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ORDEN					VARCHAR(50)	
AS
	DECLARE  @VP_HORA			INT			= FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
	DECLARE  @VP_TURNO			VARCHAR(5)	= '2'
	DECLARE  @VP_ORDEN_LIGADA	VARCHAR(50) = '' 

	-- ///////////////////////////////////////////
		DECLARE @TA_HOJA_EMPAQUE_X_ORDEN		AS TABLE	
		(	--TA_K_HOJA_EMPAQUE_CAPA				INT		NOT NULL,
			TA_IMPRIMIR							INT,
			TA_JOBNO							INT,
			TA_SER_NO							INT,
			-- ============================
			TA_CUS_NO							VARCHAR(20),
			TA_MODELNO							VARCHAR(25),
			TA_VERSIONNO						INT,
			TA_ITEM_NO							VARCHAR(25),
			-- ===========================
			--TA_COLOR_P							VARCHAR(25),
			-- ============================
			--TA_REVISION_HOJA_EMPAQUE			INT
			TA_MESA								VARCHAR(50),
			--TA_CAJA								VARCHAR(50),
			TA_TURNO							INT,
			TA_D_ITEM							VARCHAR(250)
		)
	-- /////SE OBTIENE EL TURNO EN QUE SE REALIZA LA IMPRESION//////////////////////////////////////
	
	IF @VP_HORA > 2000 AND @VP_HORA < 60002
		SET @VP_TURNO = '3'
	ELSE IF @VP_HORA > 60001 AND @VP_HORA < 153001
		SET @VP_TURNO = '1'

	-- /////SE VALIDA SI LA ORDEN VA LIGADA CON OTRA//////////////////////////////////////
	SELECT	@VP_ORDEN_LIGADA	= LTRIM(RTRIM(LOTNO))
	FROM	ccjobhdr_sql		(NOLOCK)
	WHERE	jobno				= @PP_ORDEN

	IF @VP_ORDEN_LIGADA IS NULL
		SET @VP_ORDEN_LIGADA = ''

	IF @VP_ORDEN_LIGADA <> ''
	BEGIN
		-- /////SE OBTIENE EL GROSS DE LAS DOS ORDENES//////////////////////////////////////
		DECLARE  @VP_GROSS_1				DECIMAL(13,4)	= 0
				,@VP_GROSS_2				DECIMAL(13,4)	= 0
				,@VP_ORDEN_PRINCIPAL		VARCHAR(50)		= @VP_ORDEN_LIGADA
				,@VP_ORDEN_COMPLEMENTO		VARCHAR(50)		= @PP_ORDEN

		SELECT	@VP_GROSS_1		= STANDARDSQM 
		FROM	ccjobhdr_sql	(NOLOCK)
		WHERE	jobno			= @PP_ORDEN

		SELECT	@VP_GROSS_2		= STANDARDSQM 
		FROM	ccjobhdr_sql	(NOLOCK)
		WHERE	jobno			= @VP_ORDEN_LIGADA

		-- /////SE VALIDA EL GROSS DE LAS DOS ORDENES PARA DEFINIR CUAL ES LA ORDEN PRINCIPAL Y LA SECUNDARIA//////////////////////////////////////
		IF @VP_GROSS_1 > @VP_GROSS_2
		BEGIN
			SET @VP_ORDEN_PRINCIPAL		= @PP_ORDEN
			SET @VP_ORDEN_COMPLEMENTO	= @VP_ORDEN_LIGADA
		END
				
		INSERT INTO	@TA_HOJA_EMPAQUE_X_ORDEN	(
			TA_IMPRIMIR		,
			TA_JOBNO		,
			TA_SER_NO		,
			-- ============================
			TA_CUS_NO		,
			TA_MODELNO		,
			TA_VERSIONNO	,
			TA_ITEM_NO		,
			-- ===========================
			--TA_COLOR_P		,
			-- ============================
			TA_MESA			,
			TA_TURNO		,
			TA_D_ITEM		)
		SELECT	
		-- ******************************************************************************************************************************
				1															AS IMPRIMIR,
				JOBNO														AS ORDEN_PRINCIPAL, 
				RIGHT('000' + CONVERT(VARCHAR(5), ccjoblin_sql.Ser_No), 3)	AS SER_NO,
				-- ===========================
				--( CASE 
				--	WHEN	imkitfil_sql.comp_item_no IS NULL	THEN ''
				--	ELSE	@VP_ORDEN_COMPLEMENTO 
				--END )														AS JOBNO_COMPLEMENTO,
				LTRIM(RTRIM(ccjoblin_sql.customer))							AS CUS_NO, 
				LEFT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),3)				AS MODELNO, 
				RIGHT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),4)				AS VERSIONNO, 
				-- ===========================
				( CASE 
					WHEN imkitfil_sql.comp_item_no IS NULL	THEN ccjoblin_sql.item_no	
					ELSE imkitfil_sql.item_no 
				END )														AS ITEM_NO,
				-- ===========================
				(	SELECT	LTRIM(RTRIM(MACHINE)) 
					FROM	ccjobhdr_sql	(NOLOCK)
					WHERE	JOBNO	= @VP_ORDEN_PRINCIPAL )					AS MESA,
				@VP_TURNO													AS TURNO,
				-------- ===========================
				------LTRIM(RTRIM(cccusitm_sql.cus_item_no))						AS CUS_ITEM_NO,
				------LTRIM(RTRIM(ccjoblin_sql.kit))								AS KIT, 
				-------- ===========================
				LTRIM(RTRIM(ccjoblin_sql.KitDesc))							AS KIT_DESC
				-------- ===========================
				------( CASE WHEN imkitfil_sql.comp_item_no IS NULL THEN (	SELECT LTRIM(RTRIM(ITEM_DESC_1)) 
				------														FROM IMITMIDX_SQL (NOLOCK)
				------														WHERE item_no = ccjoblin_sql.item_no )	
				------		ELSE (	SELECT LTRIM(RTRIM(ITEM_DESC_1)) 
				------				FROM IMITMIDX_SQL (NOLOCK)
				------				WHERE item_no = imkitfil_sql.item_no )	 
				------END )														AS KIT_DESC_1_IMPRIMIR,
				-------- ===========================
				------( CASE WHEN imkitfil_sql.comp_item_no IS NULL THEN (	SELECT LTRIM(RTRIM(ITEM_DESC_2))
				------														FROM IMITMIDX_SQL (NOLOCK)
				------														WHERE item_no = ccjoblin_sql.item_no )	
				------		ELSE (	SELECT	LTRIM(RTRIM(ITEM_DESC_2))
				------				FROM	IMITMIDX_SQL (NOLOCK)
				------				WHERE	item_no = imkitfil_sql.item_no )	 
				------END )														AS KIT_DESC_2_IMPRIMIR,
				-------- ===========================
				------ISNULL(ccjoblin_sql.user_def_fld1, 'N')						AS IMPRESA,
				-------- ===========================
				------LTRIM(RTRIM(ChangeLevel))									AS PROD_CAT,
				-------- ===========================
				------(	SELECT	COUNT(K_INVENTARIO_EMBARQUE) 
				------	FROM	INVENTARIO_EMBARQUE (NOLOCK)
				------	WHERE	(	SERIAL_1 = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) 
				------			OR	SERIAL_2 = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) )  
				------	AND		K_ESTATUS_INVENTARIO_EMBARQUE > 0)				AS ENVIADO
		-- ******************************************************************************************************************************
		FROM		ccjoblin_sql	(NOLOCK)
		LEFT JOIN	imkitfil_sql	(NOLOCK) ON		ccjoblin_sql.ITEM_NO = imkitfil_sql.comp_item_no
		AND		CONCAT('F', RIGHT(LTRIM(RTRIM(imkitfil_sql.item_no)),6)) <> 'FLCPTX7'
		INNER JOIN	cccusitm_sql	(NOLOCK) ON		ccjoblin_sql.Item_No = cccusitm_sql.item_no 
		AND		ccjoblin_sql.customer	= cccusitm_sql.cus_no
		AND		cccusitm_sql.versionno	= (	SELECT	MAX(CONVERT(INT, versionno)) 
											FROM	cccusitm_sql (NOLOCK)
											WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
											AND		cccusitm_sql.cus_no = ccjoblin_sql.customer		)
		WHERE	ccjoblin_sql.jobno		= @VP_ORDEN_PRINCIPAL 
		-- =================================================================
		UNION
		-- =================================================================
		SELECT	
		-- ******************************************************************************************************************************
				1															AS IMPRIMIR,
				LTRIM(RTRIM(JOBNO))											AS ORDEN_PRINCIPAL, 
				RIGHT('000' + CONVERT(VARCHAR(5), ccjoblin_sql.Ser_No), 3)	AS SER_NO,
				---- ===========================
				--''															AS JOBNO_COMPLEMENTO,
				LTRIM(RTRIM(ccjoblin_sql.customer))							AS CUS_NO, 
				LEFT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),3)				AS MODELNO,
				RIGHT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),4)				AS VERSIONNO,
				-- ===========================
				ccjoblin_sql.item_no										AS ITEM_NO,
				-- ===========================
				(	SELECT	LTRIM(RTRIM(MACHINE)) 
					FROM	ccjobhdr_sql (NOLOCK)
					WHERE	JOBNO	= @VP_ORDEN_COMPLEMENTO )				AS MESA,
				@VP_TURNO													AS TURNO,
				---------- ===========================
				--------LTRIM(RTRIM(cccusitm_sql.cus_item_no))						AS CUS_ITEM_NO,
				--------LTRIM(RTRIM(ccjoblin_sql.kit))								AS KIT, 
				---------- ===========================
				LTRIM(RTRIM(ccjoblin_sql.KitDesc))							AS KIT_DESC
				---------- ===========================
				--------(	SELECT	LTRIM(RTRIM(ITEM_DESC_1))
				--------	FROM	IMITMIDX_SQL (NOLOCK)
				--------	WHERE	item_no		= ccjoblin_sql.item_no )			AS KIT_DESC_1_IMPRIMIR,
				---------- ===========================
				--------(	SELECT  LTRIM(RTRIM(ITEM_DESC_2))
				--------	FROM	IMITMIDX_SQL (NOLOCK)
				--------	WHERE	item_no		= ccjoblin_sql.item_no )			AS KIT_DESC_2_IMPRIMIR,
				---------- ===========================
				--------ISNULL(ccjoblin_sql.user_def_fld1, 'N')						AS IMPRESA,
				---------- ===========================
				--------LTRIM(RTRIM(ChangeLevel))									AS PROD_CAT,
				---------- ===========================
				--------(	SELECT	COUNT(K_INVENTARIO_EMBARQUE) 
				--------	FROM	INVENTARIO_EMBARQUE (NOLOCK)
				--------	WHERE	(	SERIAL_1 = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) 
				--------			OR	SERIAL_2 = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) )  
				--------	AND K_ESTATUS_INVENTARIO_EMBARQUE > 0)					AS ENVIADO
		-- ******************************************************************************************************************************
		FROM	ccjoblin_sql		(NOLOCK)
		-- ===========================
		INNER JOIN	cccusitm_sql	(NOLOCK)	ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
		AND		ccjoblin_sql.customer		=	cccusitm_sql.cus_no
		AND		cccusitm_sql.versionno		=	(	SELECT	MAX(CONVERT(INT, versionno)) 
													FROM	cccusitm_sql			(NOLOCK)
													WHERE	cccusitm_sql.Item_No	= ccjoblin_sql.item_no  
													AND		cccusitm_sql.cus_no		= ccjoblin_sql.customer)
		-- ===========================
		WHERE	ccjoblin_sql.jobno			=	@VP_ORDEN_COMPLEMENTO 
		AND		ccjoblin_sql.ITEM_NO NOT IN (	SELECT comp_item_no 
												FROM imkitfil_sql		(NOLOCK)
												WHERE comp_item_no IN ( SELECT item_no 
																		FROM ccjoblin_sql	(NOLOCK)
																		WHERE JOBNO			=	@VP_ORDEN_COMPLEMENTO ) )
		ORDER	BY jobno, SER_NO
	-- =======================================================================================================================================
	END
	ELSE
	BEGIN
	-- =======================================================================================================================================
		INSERT INTO	@TA_HOJA_EMPAQUE_X_ORDEN	(
			TA_IMPRIMIR		,
			TA_JOBNO		,
			TA_SER_NO		,
			-- ============================
			TA_CUS_NO		,
			TA_MODELNO		,
			TA_VERSIONNO	,
			TA_ITEM_NO		,
			-- ===========================
			--TA_COLOR_P		,
			-- ============================
			TA_MESA			,
			TA_TURNO		,
			TA_D_ITEM		)
		SELECT	1															AS IMPRIMIR,
				LTRIM(RTRIM(JOBNO))											AS ORDEN_PRINCIPAL, 
				RIGHT('000' + CONVERT(VARCHAR(5), ccjoblin_sql.Ser_No), 3)	AS SER_NO,
				---- ===========================
				--''															AS JOBNO_COMPLEMENTO,
				LTRIM(RTRIM(ccjoblin_sql.customer))							AS CUS_NO, 
				LEFT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),3)				AS MODELNO,
				RIGHT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),4)				AS VERSIONNO,
				-- ===========================
				ccjoblin_sql.item_no										AS ITEM_NO,
				---------- ===========================
				(	SELECT	LTRIM(RTRIM(MACHINE)) 
					FROM	ccjobhdr_sql (NOLOCK)
					WHERE	JOBNO		= ccjoblin_sql.JOBNO )				AS MESA,
				@VP_TURNO													AS TURNO,
				-- ===========================
				--------LTRIM(RTRIM(cccusitm_sql.cus_item_no))						AS CUS_ITEM_NO,
				--------LTRIM(RTRIM(ccjoblin_sql.kit))								AS KIT, 
				LTRIM(RTRIM(ccjoblin_sql.KitDesc))							AS KIT_DESC
				---------- ===========================
				--------(	SELECT	LTRIM(RTRIM(ITEM_DESC_1))
				--------	FROM	IMITMIDX_SQL (NOLOCK)
				--------	WHERE	item_no		= ccjoblin_sql.item_no )			AS KIT_DESC_1_IMPRIMIR,
				---------- ===========================
				--------(	SELECT  LTRIM(RTRIM(ITEM_DESC_2))
				--------	FROM	IMITMIDX_SQL (NOLOCK)
				--------	WHERE	item_no		= ccjoblin_sql.item_no )			AS KIT_DESC_2_IMPRIMIR,
				---------- ===========================
				--------ISNULL(ccjoblin_sql.user_def_fld1, 'N')						AS IMPRESA,
				---------- ===========================
				---------- ===========================
				--------LTRIM(RTRIM(ChangeLevel))									AS PROD_CAT,
				---------- ===========================
				--------(	SELECT	COUNT(K_INVENTARIO_EMBARQUE) 
				--------	FROM	INVENTARIO_EMBARQUE (NOLOCK)
				--------	WHERE	(	SERIAL_1 = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) 
				--------			OR	SERIAL_2 = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) )  
				--------	AND K_ESTATUS_INVENTARIO_EMBARQUE > 0)					AS ENVIADO
		FROM	ccjoblin_sql		(NOLOCK)
		-- ===========================
		INNER JOIN	cccusitm_sql	(NOLOCK)	ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
		AND		ccjoblin_sql.customer	= cccusitm_sql.cus_no
		AND		cccusitm_sql.versionno	= (	SELECT	MAX(CONVERT(INT, versionno)) 
											FROM	cccusitm_sql (NOLOCK)
											WHERE	cccusitm_sql.Item_No	= ccjoblin_sql.item_no  
											AND		cccusitm_sql.cus_no		= ccjoblin_sql.customer)
		-- ===========================
		WHERE	ccjoblin_sql.jobno		= @PP_ORDEN 
		-- ===========================
		ORDER	BY ccjoblin_sql.Ser_No
	END

	SELECT	--* 
			--DISTINCT(CONCAT(TA_SER_NO,TA_ITEM_NO))			AS SER_NO		,
			TA_SER_NO							AS SER_NO		,
			TA_IMPRIMIR							AS IMPRIMIR		,
			TA_JOBNO							AS JOBNO		,
			-- ==============					AS -- ==============
			TA_CUS_NO							AS CUS_NO		,
			TA_MODELNO							AS MODELNO		,
			TA_VERSIONNO						AS VERSIONNO	,
			TA_ITEM_NO							AS ITEM_NO		,
			-- ==============					AS -- ==============
			--TA_COLOR_P						AS --TA_COLOR_P	
			-- ==============					AS -- ==============
			TA_MESA								AS MESA			,
			TA_TURNO							AS TURNO		,
			TA_D_ITEM							AS D_ITEM_NO	,
			--HOJA_EMPAQUE.REVISION_HOJA_EMPAQUE,
			--HOJA_EMPAQUE.D_ITEM_NO
			ISNULL(		(CASE
							WHEN	TMP.TA_ITEM_NO	LIKE 'U%'	THEN	(	SELECT	TOP (1)
																					REVISION_HOJA_EMPAQUE
																			FROM	HOJA_EMPAQUE	(NOLOCK)
																			WHERE	CUS_NO			= TMP.TA_CUS_NO			--	'MAGN03'	--	@PP_CUS_NO
																			AND		MODELNO			= TMP.TA_MODELNO		--	'WD2'		--	@PP_MODELNO
																			AND		VERSIONNO		= TMP.TA_VERSIONNO		--	'16'		--	@PP_VERSIONNO
																			AND		U_ITEM			= TMP.TA_ITEM_NO
																			AND		HOJA_EMPAQUE.L_REVISION_ACTIVA	= 1
																			AND		HOJA_EMPAQUE.L_CAPAS_COMPLETAS	= 1		)
							ELSE	(	SELECT	TOP (1)
												REVISION_HOJA_EMPAQUE
										FROM	HOJA_EMPAQUE	(NOLOCK)
										WHERE	CUS_NO			= TMP.TA_CUS_NO			--	'MAGN03'	--	@PP_CUS_NO
										AND		MODELNO			= TMP.TA_MODELNO		--	'WD2'		--	@PP_MODELNO
										AND		VERSIONNO		= TMP.TA_VERSIONNO		--	'16'		--	@PP_VERSIONNO
										AND		ITEM_NO			= TMP.TA_ITEM_NO
										AND		HOJA_EMPAQUE.L_REVISION_ACTIVA	= 1
										AND		HOJA_EMPAQUE.L_CAPAS_COMPLETAS	= 1		)
						END)	
				,	-1	)	AS	REVISION_HOJA_EMPAQUE
	FROM	@TA_HOJA_EMPAQUE_X_ORDEN	AS TMP
	--INNER JOIN	HOJA_EMPAQUE			(NOLOCK)	
	----ON		HOJA_EMPAQUE.CUS_NO		=	TMP.TA_CUS_NO		 
	----AND		HOJA_EMPAQUE.MODELNO	=	TMP.TA_MODELNO	
	----AND		HOJA_EMPAQUE.VERSIONNO	=	TMP.TA_VERSIONNO
	--ON		TMP.TA_ITEM_NO			=	
	----AND		HOJA_EMPAQUE.U_ITEM		=	
	--									(CASE
	--										WHEN	TMP.TA_ITEM_NO	LIKE 'U%'	THEN	HOJA_EMPAQUE.U_ITEM
	--										ELSE	HOJA_EMPAQUE.ITEM_NO
	--									END)
	--WHERE	HOJA_EMPAQUE.CUS_NO		=	TMP.TA_CUS_NO		 
	--AND		HOJA_EMPAQUE.MODELNO	=	TMP.TA_MODELNO	
	--AND		HOJA_EMPAQUE.VERSIONNO	=	TMP.TA_VERSIONNO
	--AND		TMP.TA_ITEM_NO			=	
	--AND			HOJA_EMPAQUE.U_ITEM		=	
	--									(CASE
	--										WHEN	TMP.TA_ITEM_NO	LIKE 'U%'	THEN	HOJA_EMPAQUE.U_ITEM
	--										ELSE	HOJA_EMPAQUE.ITEM_NO
	--									END)
	--AND		HOJA_EMPAQUE.L_REVISION_ACTIVA	= 1
	--AND		HOJA_EMPAQUE.L_CAPAS_COMPLETAS	= 1
	ORDER	BY SER_NO

	--////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA EL COLOR Y NÚMERO DE PARTE CLIENTE DEL P SELECCIONADO.
-- //////////////////////////////////////////////////////////////
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE_COLORES]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES]
--GO
----		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES] 0,139, 'DAIM05' , 'WDK' , '8' , 'PL2ARLH',	0
----		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSSC20',	0
----		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2',	0
--CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES]
--	@PP_K_SISTEMA_EXE				INT,
--	@PP_K_USUARIO_ACCION			INT,
--	-- ===========================
--	@PP_CUS_NO						VARCHAR(20),
--	@PP_MODELNO						VARCHAR(25),
--	@PP_VERSIONNO					INT,
--	@PP_ITEM_P						VARCHAR(25),
--	-- ===========================
--	@PP_REVISION_HOJA_EMPAQUE		INT
--AS
--	SELECT	COLOR, 
--			LTRIM(RTRIM(CUSTOMER_ITEM_NO))	AS CUSTOMER_ITEM_NO
--	FROM	[HOJA_EMPAQUE]						(NOLOCK)
--	WHERE	HOJA_EMPAQUE.ITEM_P					= @PP_ITEM_P
--	AND		HOJA_EMPAQUE.CUS_NO					= @PP_CUS_NO	
--	AND		HOJA_EMPAQUE.MODELNO				= @PP_MODELNO	
--	AND		HOJA_EMPAQUE.VERSIONNO				= @PP_VERSIONNO
--	AND		HOJA_EMPAQUE.REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
--	AND		HOJA_EMPAQUE.L_BORRADO	<> 1
--	ORDER	BY CUSTOMER_ITEM_NO		--,COLOR
--GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA EL COLOR Y NÚMERO DE PARTE CLIENTE DEL P SELECCIONADO.
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE_COLORES_U]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES_U]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES_U]	0,139, 'FAUR01'	, 'FW2'	, '0011',	'PWSFCL2',	0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES_U]	0,139, 'MAGN03'	, 'WD2'	, '0016',	'PW2RB60',	0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES_U]	0,139, 'MAGN02' , 'WAL' , '0014',	'PWALBRR',	0

--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE] 0,139, 'MAGN03' , 'WD2' , '0016' , 'PW2RB60', 0
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE] 0,139, 'MAGN02' , 'WAL' , '0014' , 'PWALBRR', 0
CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES_U]
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
	SELECT	--COLOR,
			ITEM_P AS COLOR,
			LTRIM(RTRIM(CUSTOMER_ITEM_NO))	AS CUSTOMER_ITEM_NO,
			ISNULL(U_ITEM,'----------')				AS U_ITEM,
			( SELECT LTRIM(RTRIM(search_desc))	FROM [DATA_02].[DBO].IMITMIDX_SQL	(NOLOCK) WHERE LTRIM(RTRIM(ITEM_NO)) = COLOR ) AS D_COLOR
	FROM	[HOJA_EMPAQUE]						(NOLOCK)
	--WHERE	HOJA_EMPAQUE.ITEM_P					= @PP_ITEM_P
	WHERE	HOJA_EMPAQUE.CUS_NO					= @PP_CUS_NO	
	AND		HOJA_EMPAQUE.MODELNO				= @PP_MODELNO	
	AND		HOJA_EMPAQUE.VERSIONNO				= @PP_VERSIONNO
	AND		HOJA_EMPAQUE.REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
	AND		HOJA_EMPAQUE.L_BORRADO	<> 1
	-- ========================================================================================================================
	AND		CUSTOMER_ITEM_NO					IN (	SELECT	LTRIM(RTRIM(CUSTOMER_ITEM_NO))	AS CUSTOMER_ITEM_NO
														FROM	[HOJA_EMPAQUE]						(NOLOCK)
														WHERE	HOJA_EMPAQUE.ITEM_P					= @PP_ITEM_P
														AND		HOJA_EMPAQUE.CUS_NO					= @PP_CUS_NO	
														AND		HOJA_EMPAQUE.MODELNO				= @PP_MODELNO	
														AND		HOJA_EMPAQUE.VERSIONNO				= @PP_VERSIONNO
														AND		HOJA_EMPAQUE.REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
														AND		HOJA_EMPAQUE.L_BORRADO	<> 1			)
	ORDER	BY CUSTOMER_ITEM_NO	--		COLOR
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
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_U]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_U]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_U] 0,139, 'DAIM05' , 'WDK' , '8' , 'PL2ARLH' ,0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_U] 0,139, 'FAUR01' , 'FW2' , '11', 'PWSFCL2' ,0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_U] 0,139, 'MAGN02' , 'WAL' , '14', 'PWALBRR' ,0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_U] 0,139, 'MAGN03' , 'WD2' , '16', 'PWD2TBL' ,0

--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE] 0,139, 'MAGN03' , 'WD2' , '0015' , 'PWD2TBL', 0
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE] 0,139, 'MAGN02' , 'WAL' , '0014' , 'PWALBRR', 0
CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_U]
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
	DECLARE	@VP_TA_ITEM_P		AS TABLE
	(	TA_ITEM_P				VARCHAR(50)		)


	INSERT INTO	@VP_TA_ITEM_P
	SELECT @PP_ITEM_P

	INSERT INTO	@VP_TA_ITEM_P
	SELECT	DISTINCT(ITEM_P)	--LTRIM(RTRIM(CUSTOMER_ITEM_NO))	AS CUSTOMER_ITEM_NO
	FROM	[HOJA_EMPAQUE]						(NOLOCK)
	WHERE	HOJA_EMPAQUE.ITEM_P					<> @PP_ITEM_P
	AND		HOJA_EMPAQUE.CUS_NO					= @PP_CUS_NO	
	AND		HOJA_EMPAQUE.MODELNO				= @PP_MODELNO	
	AND		HOJA_EMPAQUE.VERSIONNO				= @PP_VERSIONNO
	AND		HOJA_EMPAQUE.REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
	AND		HOJA_EMPAQUE.L_BORRADO	<> 1
	AND		U_ITEM								IN	(	SELECT	U_ITEM	--LTRIM(RTRIM(CUSTOMER_ITEM_NO))	AS CUSTOMER_ITEM_NO
														FROM	[HOJA_EMPAQUE]						(NOLOCK)
														WHERE	HOJA_EMPAQUE.ITEM_P					= @PP_ITEM_P
														AND		HOJA_EMPAQUE.CUS_NO					= @PP_CUS_NO	
														AND		HOJA_EMPAQUE.MODELNO				= @PP_MODELNO	
														AND		HOJA_EMPAQUE.VERSIONNO				= @PP_VERSIONNO
														AND		HOJA_EMPAQUE.REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
														AND		U_ITEM								<> ''
														AND		HOJA_EMPAQUE.L_BORRADO	<> 1		)

	SELECT	--	HOJA_EMPAQUE_PROCESO.*,
			K_HOJA_EMPAQUE_PROCESO
			,HOJA_EMPAQUE_PROCESO.K_PROCESO_SIMBOLO
			,L_HOJA_EMPAQUE_PROCESO
			,(CASE
				WHEN	K_PROCESO	< 50 	THEN	K_PROCESO
				ELSE	50
			END)	AS K_PROCESO
			,(CASE
				WHEN	D_HOJA_EMPAQUE_PROCESO <> ''	THEN	D_HOJA_EMPAQUE_PROCESO
				WHEN	D_HOJA_EMPAQUE_PROCESO =  ''	THEN	D_PROCESO_SIMBOLO
			END)										AS	D_HOJA_EMPAQUE_PROCESO
			,(	RUTA_SERVIDOR + RUTA_IMAGEN + RUTA_EXTENSION	)	AS	RUTA_AV_PROCESO_SIMBOLO
	FROM	[HOJA_EMPAQUE_PROCESO]			 (NOLOCK)
	LEFT JOIN	PROCESO_SIMBOLO (NOLOCK) ON PROCESO_SIMBOLO.K_PROCESO_SIMBOLO	= HOJA_EMPAQUE_PROCESO.K_PROCESO_SIMBOLO
	WHERE	CUS_NO					= @PP_CUS_NO
	AND		MODELNO					= @PP_MODELNO
	AND		VERSIONNO				= @PP_VERSIONNO
	AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
	-- ========================================================================================================================
	--AND		ITEM_P					= @PP_ITEM_P
	AND		ITEM_P					IN	(	SELECT TA_ITEM_P FROM @VP_TA_ITEM_P )
	ORDER	BY K_PROCESO
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA EL DETALLE DE LOS SPECIAL_PROCESS POR KIT
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2WSPAD4', 0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2WSPAX7', 0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE] 0,139, 'MAGN02'	, 'WAL'	, '14',	'UWALFBLWLCPT3', 0
CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25),
	@PP_VERSIONNO					INT,
	@PP_ITEM_NO						VARCHAR(25),
	-- ===========================
	@PP_REVISION_HOJA_EMPAQUE		INT
AS
	DECLARE	 @VP_CU_D_PROCESO		VARCHAR(500)
			,@VP_CU_R_PROCESO		NVARCHAR(MAX)
			,@VP_CONTA				INTEGER			= 0
			,@VP_STR_SQL			NVARCHAR(MAX)	= ''
	-- =================================================
			,@VP_U_ITEM				VARCHAR(50)		= ''
	-- =================================================
	DECLARE @TA_PROCESO		AS TABLE	
	(	TA_K_PROCESO		INT	IDENTITY(1,1),
		TA_D_PROCESO_1		VARCHAR(500),	TA_R_PROCESO_1		NVARCHAR(MAX), TA_D_PROCESO_2		VARCHAR(500),	TA_R_PROCESO_2		NVARCHAR(MAX),
		TA_D_PROCESO_3		VARCHAR(500),	TA_R_PROCESO_3		NVARCHAR(MAX), TA_D_PROCESO_4		VARCHAR(500),	TA_R_PROCESO_4		NVARCHAR(MAX),
		TA_D_PROCESO_5		VARCHAR(500),	TA_R_PROCESO_5		NVARCHAR(MAX), TA_D_PROCESO_6		VARCHAR(500),	TA_R_PROCESO_6		NVARCHAR(MAX),
		TA_D_PROCESO_7		VARCHAR(500),	TA_R_PROCESO_7		NVARCHAR(MAX), TA_D_PROCESO_8		VARCHAR(500),	TA_R_PROCESO_8		NVARCHAR(MAX),						
		TA_D_PROCESO_9		VARCHAR(500),	TA_R_PROCESO_9		NVARCHAR(MAX), TA_D_PROCESO_10		VARCHAR(500),	TA_R_PROCESO_10		NVARCHAR(MAX),
		TA_D_PROCESO_11		VARCHAR(500),	TA_R_PROCESO_11		NVARCHAR(MAX), TA_D_PROCESO_12		VARCHAR(500),	TA_R_PROCESO_12		NVARCHAR(MAX)	)

	DECLARE	@VP_TA_ITEM_P		AS TABLE
	(	TA_ITEM_P				VARCHAR(50)		)

	IF	@PP_ITEM_NO LIKE 'P%'
	BEGIN
		SELECT	@VP_U_ITEM		= ISNULL(ITEM_NO,'')
		FROM	IMKITFIL_SQL	(NOLOCK)
		WHERE	COMP_ITEM_NO						= @PP_ITEM_NO
		AND		LEFT(LTRIM(RTRIM(FILLER_0004)),3)	= @PP_MODELNO
		AND		RIGHT(LTRIM(RTRIM(FILLER_0004)),4)	= @PP_VERSIONNO
	END

	IF	@PP_ITEM_NO LIKE 'U%'	OR	@VP_U_ITEM <> ''
	BEGIN
		IF	@VP_U_ITEM = ''
		BEGIN
			SET	@VP_U_ITEM	= @PP_ITEM_NO
		END

		INSERT INTO	@VP_TA_ITEM_P
		SELECT	COMP_ITEM_NO
		FROM	IMKITFIL_SQL	(NOLOCK)
		WHERE	ITEM_NO								= @VP_U_ITEM	--@PP_ITEM_NO
		AND		LEFT(LTRIM(RTRIM(FILLER_0004)),3)	= @PP_MODELNO
		AND		RIGHT(LTRIM(RTRIM(FILLER_0004)),4)	= @PP_VERSIONNO
		ORDER	BY COMP_ITEM_NO	ASC
	END
	ELSE
	BEGIN
		INSERT INTO	@VP_TA_ITEM_P
		SELECT		@PP_ITEM_NO
	END		

	--INSERT INTO	@VP_TA_ITEM_P
	--SELECT	DISTINCT(ITEM_P)	--LTRIM(RTRIM(CUSTOMER_ITEM_NO))	AS CUSTOMER_ITEM_NO
	--FROM	[HOJA_EMPAQUE]						(NOLOCK)
	--WHERE	HOJA_EMPAQUE.ITEM_P					<> @PP_ITEM_P
	--AND		HOJA_EMPAQUE.CUS_NO					= @PP_CUS_NO	
	--AND		HOJA_EMPAQUE.MODELNO				= @PP_MODELNO	
	--AND		HOJA_EMPAQUE.VERSIONNO				= @PP_VERSIONNO
	--AND		HOJA_EMPAQUE.REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
	--AND		HOJA_EMPAQUE.L_BORRADO	<> 1
	--AND		U_ITEM								IN	(	SELECT	U_ITEM	--LTRIM(RTRIM(CUSTOMER_ITEM_NO))	AS CUSTOMER_ITEM_NO
	--													FROM	[HOJA_EMPAQUE]						(NOLOCK)
	--													WHERE	HOJA_EMPAQUE.ITEM_P					= @PP_ITEM_P
	--													AND		HOJA_EMPAQUE.CUS_NO					= @PP_CUS_NO	
	--													AND		HOJA_EMPAQUE.MODELNO				= @PP_MODELNO	
	--													AND		HOJA_EMPAQUE.VERSIONNO				= @PP_VERSIONNO
	--													AND		HOJA_EMPAQUE.REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
	--													AND		U_ITEM								<> ''
	--													AND		HOJA_EMPAQUE.L_BORRADO	<> 1		)

	DECLARE CU_CURSOR_PROCES	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR		
		SELECT	(CASE
					WHEN	D_HOJA_EMPAQUE_PROCESO <> ''	THEN	D_HOJA_EMPAQUE_PROCESO
					WHEN	D_HOJA_EMPAQUE_PROCESO =  ''	THEN	D_PROCESO_SIMBOLO
				END)										AS		D_HOJA_EMPAQUE_PROCESO
				,(	RUTA_SERVIDOR + RUTA_IMAGEN + RUTA_EXTENSION	)	AS	RUTA_AV_PROCESO_SIMBOLO
		FROM	[HOJA_EMPAQUE_PROCESO]			 (NOLOCK)
		LEFT JOIN	PROCESO_SIMBOLO (NOLOCK) ON PROCESO_SIMBOLO.K_PROCESO_SIMBOLO	= HOJA_EMPAQUE_PROCESO.K_PROCESO_SIMBOLO
		WHERE	CUS_NO					= @PP_CUS_NO
		AND		MODELNO					= @PP_MODELNO
		AND		VERSIONNO				= @PP_VERSIONNO
		AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
		AND		L_HOJA_EMPAQUE_PROCESO	= 1
		-- ========================================================================================================================
		--AND		ITEM_P					= @PP_ITEM_P
		AND		ITEM_P					IN	(	SELECT LEFT(TA_ITEM_P,7) FROM @VP_TA_ITEM_P )
	OPEN CU_CURSOR_PROCES
	FETCH NEXT FROM  CU_CURSOR_PROCES INTO   @VP_CU_D_PROCESO		,@VP_CU_R_PROCESO
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET	@VP_CONTA += 1

		IF @VP_CONTA	= 1
		BEGIN
			INSERT INTO	@TA_PROCESO
			VALUES	( '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''  )

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
		
		IF @VP_CONTA	= 7
		BEGIN
			UPDATE	@TA_PROCESO
			SET		TA_D_PROCESO_7	= @VP_CU_D_PROCESO,
					TA_R_PROCESO_7	= @VP_CU_R_PROCESO
		END

		IF @VP_CONTA	= 8
		BEGIN
			UPDATE	@TA_PROCESO
			SET		TA_D_PROCESO_8	= @VP_CU_D_PROCESO,
					TA_R_PROCESO_8	= @VP_CU_R_PROCESO
		END

		IF @VP_CONTA	= 9
		BEGIN
			UPDATE	@TA_PROCESO
			SET		TA_D_PROCESO_9	= @VP_CU_D_PROCESO,
					TA_R_PROCESO_9	= @VP_CU_R_PROCESO
		END

		IF @VP_CONTA	= 10
		BEGIN
			UPDATE	@TA_PROCESO
			SET		TA_D_PROCESO_10	= @VP_CU_D_PROCESO,
					TA_R_PROCESO_10	= @VP_CU_R_PROCESO
		END

		IF @VP_CONTA	= 11
		BEGIN
			UPDATE	@TA_PROCESO
			SET		TA_D_PROCESO_11	= @VP_CU_D_PROCESO,
					TA_R_PROCESO_11	= @VP_CU_R_PROCESO
		END

		IF @VP_CONTA	= 12
		BEGIN
			UPDATE	@TA_PROCESO
			SET		TA_D_PROCESO_12	= @VP_CU_D_PROCESO,
					TA_R_PROCESO_12	= @VP_CU_R_PROCESO
		END	

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
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_SIMBOLO] 0,139, 1
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
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA] 0,139, 'DAIM05'	, 'WDK' , '8' , 'PL2ARRH',0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA] 0,139, 'MAGN02'	, 'WAL' , '14', 'PWALBR2',0
--		 EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_CAPA] 0,139,	'MAGN03'	, 'WD2'	, '16',	'PWD2TFB',0
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
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2WSPAD4', 0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2WSPAX7', 0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE] 0,139, 'MAGN02'	, 'WAL'	, '14',	'UWALFBLWLCPT3', 0
CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25),
	@PP_VERSIONNO					INT,
	@PP_ITEM_NO						VARCHAR(25),
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

	DECLARE	@VP_TA_ITEM_P		AS TABLE
	(	TA_ITEM_P				VARCHAR(50)		)
	
	DECLARE	@VP_U_ITEM			VARCHAR	(50)	= ''

	IF	@PP_ITEM_NO LIKE 'P%'
	BEGIN
		SELECT	@VP_U_ITEM		= ISNULL(ITEM_NO,'')
		FROM	IMKITFIL_SQL	(NOLOCK)
		WHERE	COMP_ITEM_NO						= @PP_ITEM_NO
		AND		LEFT(LTRIM(RTRIM(FILLER_0004)),3)	= @PP_MODELNO
		AND		RIGHT(LTRIM(RTRIM(FILLER_0004)),4)	= @PP_VERSIONNO
	END

	IF	@PP_ITEM_NO LIKE 'U%'	OR	@VP_U_ITEM <> ''
	BEGIN
		IF	@VP_U_ITEM = ''
		BEGIN
			SET	@VP_U_ITEM	= @PP_ITEM_NO
		END

		INSERT INTO	@VP_TA_ITEM_P
		SELECT	TOP (1)
				COMP_ITEM_NO
		FROM	IMKITFIL_SQL	(NOLOCK)
		WHERE	ITEM_NO								= @VP_U_ITEM	--@PP_ITEM_NO
		AND		LEFT(LTRIM(RTRIM(FILLER_0004)),3)	= @PP_MODELNO
		AND		RIGHT(LTRIM(RTRIM(FILLER_0004)),4)	= @PP_VERSIONNO
		ORDER	BY COMP_ITEM_NO	ASC
	END
	ELSE
	BEGIN
		INSERT INTO	@VP_TA_ITEM_P
		SELECT		@PP_ITEM_NO
	END		


	DECLARE CU_CURSOR_PROCES	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
		SELECT		N_CAPA,
					N_PATRONES_CAPA,
					RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR + RUTA_HOJA_EMPAQUE_CAPA_MODELO + RUTA_HOJA_EMPAQUE_CAPA_IMAGEN + RUTA_HOJA_EMPAQUE_CAPA_EXTENSION
		FROM		HOJA_EMPAQUE_CAPA					(NOLOCK)
		WHERE		CUS_NO			= @PP_CUS_NO		
		AND			MODELNO			= @PP_MODELNO		
		AND			VERSIONNO		= @PP_VERSIONNO	
		AND			ITEM_P			IN	( SELECT LEFT(TA_ITEM_P, 7)FROM @VP_TA_ITEM_P)	--@PP_ITEM_P
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
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE] 0,139, 'MAGN03' , 'WD2' , '0016' , 'PW2RB60', 0
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE] 0,139, 'MAGN02' , 'WAL' , '0014' , 'PWALBRR', 0
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
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PLECFB2PABLUE', 0,''		
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2WSPAA6', 0,''		
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2WSPAD4', 0,''		
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2WSPAX7', 0,	'Table 36'
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'MAGN02'	, 'WAL'	, '14',	'UWALFBLWLCPT3', 0,	'Table 36'
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'MAGN02'	, 'WAL'	, '14',	'PWLAFCRWLCPX7', 0,	'Table 36'
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'MAGN02'	, 'WAL'	, '14',	'PWALBRRWLCPX7', 0,	'Table 36'
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'MAGN02'	, 'WAL'	, '14',	'PWALBRRWLCPT3', 0,	'Table 36'
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'MAGN03'	, 'WD2'	, '16',	'UW2SRB6CNPJRR', 0,	''
CREATE PROCEDURE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25),
	@PP_VERSIONNO					INT,
	@PP_ITEM_NO						VARCHAR(25),
	-- ===========================
	@PP_REVISION_HOJA_EMPAQUE		INT,
	-- ===========================
	@PP_MESA						VARCHAR(50)
AS
	-- ///////////////////////////////////////////			
	DECLARE  @K_ARCUSFIL			INT
			,@K_ARCUSFIL_PROGRAM	INT
			,@CB_ARCUSFIL_PROGRAM	VARCHAR(250)
			,@CB_PROGRAM			VARCHAR(250)
	--- ================================================
			,@VP_U_ITEM				VARCHAR(50)		= ''
			,@VP_U_PART				VARCHAR(50)		= ''
			,@VP_U_IT_1				VARCHAR(50)		= ''
			,@VP_U_IT_2				VARCHAR(50)		= ''
			,@VP_U_DT_1				VARCHAR(250)	= ''
			,@VP_U_DT_2				VARCHAR(250)  	= ''
	--- ================================================
	--DECLARE	@TA_ITEM_P				AS TABLE
	--	(	TA_ITEMP_P					VARCHAR(250)	)
	--- ================================================
	DECLARE  @VP_HORA			INT			= FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
	DECLARE  @VP_TURNO			VARCHAR(5)	= '2'
	
	IF @VP_HORA > 2000 AND @VP_HORA < 60002
		SET @VP_TURNO = '3'
	ELSE IF @VP_HORA > 60001 AND @VP_HORA < 153001
		SET @VP_TURNO = '1'
	--- ================================================	
	
	SELECT	@CB_ARCUSFIL_PROGRAM		= RTRIM(LTRIM(PROD_CAT_DESC)),
			@CB_PROGRAM					= RTRIM(LTRIM(S_ARCUSFIL_PROGRAM))
	FROM	ARCUSFIL_PROGRAM_MODEL		(NOLOCK)
	WHERE	S_ARCUSFIL_PROGRAM_MODEL	= @PP_MODELNO

	IF	@PP_ITEM_NO LIKE 'P%'
	BEGIN
		SELECT	@VP_U_ITEM		= ISNULL(ITEM_NO,'')
		FROM	IMKITFIL_SQL	(NOLOCK)
		WHERE	COMP_ITEM_NO						= @PP_ITEM_NO
		AND		LEFT(LTRIM(RTRIM(FILLER_0004)),3)	= @PP_MODELNO
		AND		RIGHT(LTRIM(RTRIM(FILLER_0004)),4)	= @PP_VERSIONNO
	END

	IF	@PP_ITEM_NO LIKE 'U%'	or	@VP_U_ITEM <> ''
	--IF	@VP_U_ITEM <> ''
	BEGIN
		IF	@VP_U_ITEM = ''
		BEGIN
			SET	@VP_U_ITEM	= @PP_ITEM_NO
		END

		SELECT	TOP(1)
				@VP_U_IT_1		= COMP_ITEM_NO
		FROM	IMKITFIL_SQL	(NOLOCK)
		WHERE	ITEM_NO								= @PP_ITEM_NO
		AND		LEFT(LTRIM(RTRIM(FILLER_0004)),3)	= @PP_MODELNO
		AND		RIGHT(LTRIM(RTRIM(FILLER_0004)),4)	= @PP_VERSIONNO
		ORDER	BY COMP_ITEM_NO	ASC

		SELECT	TOP(2)
				@VP_U_IT_2		= COMP_ITEM_NO
		FROM	IMKITFIL_SQL	(NOLOCK)
		WHERE	ITEM_NO								= @PP_ITEM_NO
		AND		LEFT(LTRIM(RTRIM(FILLER_0004)),3)	= @PP_MODELNO
		AND		RIGHT(LTRIM(RTRIM(FILLER_0004)),4)	= @PP_VERSIONNO
		ORDER	BY COMP_ITEM_NO	DESC

		SET	@VP_U_PART		=	(	SELECT LANDED_COST_CD FROM IMITMIDX_SQL	WHERE	ITEM_NO = @VP_U_ITEM )
		SET	@VP_U_DT_1		=	( SELECT LTRIM(RTRIM(search_desc))	FROM [DATA_02].[DBO].IMITMIDX_SQL	(NOLOCK) WHERE LTRIM(RTRIM(ITEM_NO)) = ('F' + RIGHT(LTRIM(RTRIM(@VP_U_IT_1)),6))	) --COLOR )
		SET	@VP_U_DT_2		=	( SELECT LTRIM(RTRIM(search_desc))	FROM [DATA_02].[DBO].IMITMIDX_SQL	(NOLOCK) WHERE LTRIM(RTRIM(ITEM_NO)) = ('F' + RIGHT(LTRIM(RTRIM(@VP_U_IT_2)),6))	) --COLOR )
	END
	
	SELECT		TOP (1)
				ISNULL(@VP_U_ITEM,'')				AS U_IT_M,	ISNULL(@VP_U_PART,'')				AS U_PART,
				ISNULL(@VP_U_IT_1,'')				AS U_IT_1,	ISNULL(@VP_U_IT_2,'')				AS U_IT_2,
				ISNULL(@VP_U_DT_1,'')				AS U_DT_1,	ISNULL(@VP_U_DT_2,'')				AS U_DT_2,
				-- =============================	
				(	SELECT	LTRIM(RTRIM(search_desc))	
					FROM	[DATA_02].[DBO].IMITMIDX_SQL	(NOLOCK) 
					WHERE	LTRIM(RTRIM(ITEM_NO)) = HOJA_EMPAQUE.COLOR 
				)	AS D_COLOR,
				-- =============================	
				UPPER(@PP_MESA)											AS MESA,
				@VP_TURNO												AS TURNO,
				FORMAT (getdate(), 'MMM dd yyyy')						AS FECHA,
				--convert(date,GETDATE()),
				-- =============================	
				'\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE'	--	MAGN03\RUE\28\
				+ '\'	+	CUS_NO		
				+ '\'	+	MODELNO		
				+ '\'	+	CONVERT(VARCHAR(10),VERSIONNO)	--+	'\'	+	ITEM_P		
				AS QR_CODE,
				-- =============================	 
				@CB_ARCUSFIL_PROGRAM	AS PROGRAMA		,
				@CB_PROGRAM				AS PROGRAMA_MODELO,
				-- =============================
				ISNULL(REVISION_HOJA_EMPAQUE,0) AS REVISION_HOJA_EMPAQUE,
				K_HOJA_EMPAQUE_CAPA_DIVISION	AS DIVISION_CAPAS,
				HOJA_EMPAQUE.*
				-- =============================	
	FROM		HOJA_EMPAQUE		(NOLOCK) 
	INNER JOIN 	HOJA_EMPAQUE_STATUS		(NOLOCK) ON HOJA_EMPAQUE_STATUS.K_HOJA_EMPAQUE_STATUS	= HOJA_EMPAQUE.K_HOJA_EMPAQUE_STATUS
				-- =============================
	WHERE		@PP_ITEM_NO							=	(	CASE
																WHEN	@PP_ITEM_NO LIKE 'U%' THEN HOJA_EMPAQUE.U_ITEM
																ELSE	HOJA_EMPAQUE.ITEM_NO
														END	)														
	AND			HOJA_EMPAQUE.CUS_NO					= @PP_CUS_NO	
	AND			HOJA_EMPAQUE.MODELNO				= @PP_MODELNO	
	AND			HOJA_EMPAQUE.VERSIONNO				= @PP_VERSIONNO
	AND			HOJA_EMPAQUE.REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
	AND			HOJA_EMPAQUE.L_BORRADO	<> 1
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> UPDATE / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_HOJA_EMPAQUE]
GO
--		EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE] 0,139, 'MAGN02' , 'WAL' , '0014' , 'PWALBRR', 0
-- EXECUTE [dbo].[PG_UP_HOJA_EMPAQUE]	0, 139,	'0' , 'DAIM05' , WDK , '8' , 'PL2ARRH' , 'P133124' , '' , '0' , 2 , '' , 1 ,				
--										'1' , '2' , '\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\DAIM05\WDK\8\PL2ARRH_000_1.PNG' , 
--										'\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\DAIM05\WDK\8\PL2ARRH_000_1.PNG' , 
--										'8' , '' , '' , '' , '' , ''
----	EXECUTE [dbo].[PG_UP_HOJA_EMPAQUE]	0, 139, '0' , 'MAGN02' , WAL , '14' , 'PWALBR2' , 'M02516-06' , '' , '0' , 3 , 'FALTA QUE SE REFLEN LOS PATRONES CON KUFNER TK1080' , 6 
----	, '1/2/3' , '1/1/1' , '\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\MAGN02\WAL\14\PWALBR2_000_1.PNG/\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\MAGN02\WAL\14\PWALBR2_000_2.PNG/\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\MAGN02\WAL\14\PWALBR2_000_3.PNG' 
----	, '\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\MAGN02\WAL\14\PWALBR2_000_1.PNG/\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\MAGN02\WAL\14\PWALBR2_000_2.PNG/\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\MAGN02\WAL\14\PWALBR2_000_3.PNG' 
----	, '60/61/62' , '449/446/447/448' , '2/3/7/8' , '1/2/0/1' , '1/1/0/1' , 'MULLER 6MM 6035/AXIS II/SHAVING/KUFNER TK 1080 BLACK' 
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
		,@VP_CANTIDAD_CAPAS				INT	= 0
		,@VP_L_CAPAS_COMPLETAS			INT	= 0
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

	SET	@VP_CANTIDAD_CAPAS	= (	CASE
										WHEN	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION	IN (1)			THEN	1
										WHEN	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION	IN (2,3)		THEN	2
										WHEN	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION	IN (4,5,6,7)	THEN	3
										WHEN	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION	IN (8)			THEN	4
										ELSE	0
								END )

	--SELECT	*--COUNT(K_HOJA_EMPAQUE)
	--FROM	HOJA_EMPAQUE					(NOLOCK)
	--WHERE	CUS_NO							= 'daim05'	--@PP_CUS_NO	
	--AND		MODELNO							= 'wdk'	--@PP_MODELNO
	--AND		VERSIONNO						= '0008'	--@PP_VERSIONNO
	---- ============================
	--AND		ITEM_P							= 'pl2arrh'	--@PP_ITEM_P
	--AND		REVISION_HOJA_EMPAQUE			= '0'		--@PP_REVISION_HOJA_EMPAQUE
	
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
	DECLARE	@VP_REVISION_NUEVA						AS INT				=	@PP_REVISION_HOJA_EMPAQUE + 1
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
					--[CUBE_WIDTH]					,	[CUBE_LENGTH]					,
					[AREA_NETA]						,	[AREA_GROSS]					,
					-- ============================
					[C_HOJA_EMPAQUE]				,	[L_REVISION_ACTIVA]				,
					-- ============================
					[K_HOJA_EMPAQUE_CAPA_DIVISION]	,
					[N_CAPAS]						,	--[L_CAPAS_COMPLETAS]				,
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
					--[CUBE_WIDTH]					,	[CUBE_LENGTH]					,
					[AREA_NETA]						,	[AREA_GROSS]					,
					-- ============================
					@PP_C_HOJA_EMPAQUE				,	1								,
					-- ============================
					@PP_K_HOJA_EMPAQUE_CAPA_DIVISION,	
					@VP_CANTIDAD_CAPAS				,	--@VP_L_CAPAS_COMPLETAS
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
					[N_CAPAS]						= @VP_CANTIDAD_CAPAS				,
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

		IF	@VP_CANTIDAD_CAPAS	= (	SELECT	COUNT(K_HOJA_EMPAQUE_CAPA)
									FROM	[HOJA_EMPAQUE_CAPA]
									WHERE	[CUS_NO]						= @PP_CUS_NO 
									AND		[MODELNO]						= @PP_MODELNO
									AND		[VERSIONNO]						= @PP_VERSIONNO
											-- ============================
									AND		[ITEM_P]						= @PP_ITEM_P
									AND		[REVISION_HOJA_EMPAQUE]			= @PP_REVISION_HOJA_EMPAQUE
									AND		[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]	<> ''	)
		BEGIN
			SET		@VP_L_CAPAS_COMPLETAS	= 1
		END

			UPDATE	[HOJA_EMPAQUE]
			SET		[L_CAPAS_COMPLETAS]		= @VP_L_CAPAS_COMPLETAS
					-- ============================
			WHERE	CUS_NO					= @PP_CUS_NO
			AND		MODELNO					= @PP_MODELNO
			AND		VERSIONNO				= @PP_VERSIONNO
			AND		ITEM_P					= @PP_ITEM_P
			AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='Registro no fue ingresado.(L_CAPAS)[HE#' + CONVERT(VARCHAR(10),@PP_ITEM_P ) + ']'
				RAISERROR (@VP_MENSAJE, 16, 1 ) 
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
		SET	@VP_MENSAJE = 'No es posible [Actualizar] la [Hoja de Empaque]: ' + @VP_MENSAJE
		--SET	@VP_MENSAJE +=	@PP_L_NUEVA_REVISIÓN					+ '*-*'
		--				-- ============================
		--SET	@VP_MENSAJE +=	@PP_CUS_NO								+ '*-*'
		--SET	@VP_MENSAJE +=	@PP_MODELNO								+ '*-*'
		--SET	@VP_MENSAJE +=	@PP_VERSIONNO							+ '*-*'
		--				-- ============================
		--SET	@VP_MENSAJE +=	@PP_ITEM_P								+ '*-*'
		--				-- ============================
		--SET	@VP_MENSAJE +=	@PP_CAJA_HOJA_EMPAQUE					+ '*-*'
		--SET	@VP_MENSAJE +=	@PP_DIBUJO_HOJA_EMPAQUE					+ '*-*'
		--SET	@VP_MENSAJE +=	@PP_REVISION_HOJA_EMPAQUE				+ '*-*'
		--				-- ============================
		--SET	@VP_MENSAJE +=	@PP_CANTIDAD_PATRONES					+ '*-*'
		--				-- ============================
		--SET	@VP_MENSAJE +=	@PP_C_HOJA_EMPAQUE						+ '*-*'
		--				-- ============================
		--SET	@VP_MENSAJE +=	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION		+ '*-*'
		--				-- ============================
		--SET	@VP_MENSAJE +=	@PP_ARRAY_N_CAPA						+ '*-*'
		--SET	@VP_MENSAJE +=	@PP_ARRAY_N_PATR						+ '*-*'
		--SET	@VP_MENSAJE +=	@PP_ARRAY_RUTA_C						+ '*-*'
		--SET	@VP_MENSAJE +=	@PP_ARRAY_RUTA_N						+ '*-*'
		--SET	@VP_MENSAJE +=	@PP_ARRAY_K_HOJA						+ '*-*'
		--				-- ============================
		--SET	@VP_MENSAJE +=	@PP_ARRAY_K_HE_PROC						+ '*-*'
		--SET	@VP_MENSAJE +=	@PP_ARRAY_K_PROCESO						+ '*-*'
		--SET	@VP_MENSAJE +=	@PP_ARRAY_K_P_SIMBO						+ '*-*'
		--SET	@VP_MENSAJE +=	@PP_ARRAY_L_PROCESO						+ '*-*'
		--SET	@VP_MENSAJE +=	@PP_ARRAY_D_PROCESO						+ '*-*'

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
			--	SE COLOCA ESTA PARTE DEL CÓDIGO POR PROBLEMAS PARA LA CONVERSIÓN DE LOS CHECK DE SELECCIÓN, NO AFECTA EL FUNCIONAMIENTO DEL SISTEMA, 
			--	AL CONTRARIO AYUDA A QUE NO MARQUE EL ERROR POR TIPO DE DATO ERRONEO.
			IF UPPER(@VP_VALOR_L_PROCESO)	= 'TRUE'
			BEGIN
				SET	@VP_VALOR_L_PROCESO	= 1
			END

			IF UPPER(@VP_VALOR_L_PROCESO)	= 'FALSE'
			BEGIN
				SET	@VP_VALOR_L_PROCESO	= 0
			END

			--	MOSTRAR EL NÚMERO P EN LA VISTA DEL LISTADO PARA JALAR EL DATO Y ACTULIZARLO DE LA MEJOR MANERA.
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


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INGRESA LA INFORMACIÓN DE LAS HOJAS DE EMPAQUE
-- // SISTEMA DE PRODUCTIVO							20220111
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_HOJA_EMPAQUE_VERSION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_HOJA_EMPAQUE_VERSION]
GO
--		EXECUTE  [dbo].[PG_IN_HOJA_EMPAQUE_VERSION] 	0,139,	'FAUR01','FW2','0011'
--		EXECUTE  [dbo].[PG_IN_HOJA_EMPAQUE_VERSION] 	0,139,	'IRVI02','JLI','0059'		--	PARA PRUEBAS DE ESTE SP
CREATE PROCEDURE [dbo].[PG_IN_HOJA_EMPAQUE_VERSION]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_S_CUSTOMER				VARCHAR(6),
	@PP_S_MODEL					VARCHAR(3),
	@PP_NO_VERSION				INT
AS
DECLARE @VP_MENSAJE NVARCHAR(MAX)
--BEGIN TRANSACTION 
--BEGIN TRY

	DECLARE	@VP_CU_ITEM_NO							VARCHAR(50),
			@VP_CU_K_HOJA_EMPAQUE_STATUS			INT,			
			-- ============================
			@VP_CU_CUS_NO							VARCHAR(6),
			@VP_CU_MODELNO							VARCHAR(3),
			@VP_CU_VERSIONNO						INT,
			-- ============================
			@VP_CU_COLOR							VARCHAR(50),
			@VP_CU_ITEM_P							VARCHAR(50),
			@VP_CU_CUSTOMER_ITEM_NO					VARCHAR(50),
			@VP_CU_D_ITEM_NO						VARCHAR(500),
			-- ============================
			@VP_CU_CAJA_HOJA_EMPAQUE				VARCHAR (150),
			@VP_CU_DIBUJO_HOJA_EMPAQUE				VARCHAR (150),
			@VP_CU_REVISION_HOJA_EMPAQUE			INT,
			-- ============================
			@VP_CU_STANDAR_PACK						INT,
			@VP_CU_CANTIDAD_PATRONES				INT,
			@VP_CU_AREA_NETA						DECIMAL(19,6),
			@VP_CU_AREA_GROSS						DECIMAL(19,6),
			-- ============================
			@VP_CU_C_HOJA_EMPAQUE					NVARCHAR(MAX),
			@VP_CU_L_REVISION_ACTIVA				INT,
			-- ============================
			@VP_CU_K_HOJA_EMPAQUE_CAPA_DIVISION		INT,
			-- ============================
			@VP_CU_K_TIPO_CAMBIO_KIT				INT,
			-- ============================
			@VP_CU_L_BORRADO						INT,
			-- ============================
			@VP_CU_N_CAPAS							INT

	
	DECLARE @PP_NO_VERSION_ANTERIOR					INT		=  @PP_NO_VERSION - 1
	DECLARE	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR		AS NVARCHAR(MAX)	=	'\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\'
															 
	DECLARE	@VP_TA_HOJA_NUEVA					AS TABLE
	(		TA_ITEM_NO							VARCHAR(50),
			TA_K_HOJA_EMPAQUE_STATUS			INT,			
			-- ============================
			TA_CUS_NO							VARCHAR(6),
			TA_MODELNO							VARCHAR(3),
			TA_VERSIONNO						VARCHAR(4),
			-- ============================
			TA_COLOR							VARCHAR(50),
			TA_ITEM_P							VARCHAR(50),
			TA_CUSTOMER_ITEM_NO					VARCHAR(50),
			TA_D_ITEM_NO						VARCHAR(500),
			-- ============================
			TA_CAJA_HOJA_EMPAQUE				VARCHAR (150),
			TA_DIBUJO_HOJA_EMPAQUE				VARCHAR (150),
			TA_REVISION_HOJA_EMPAQUE			INT,
			-- ============================
			TA_STANDAR_PACK						INT,
			TA_CANTIDAD_PATRONES				INT,
			TA_AREA_NETA						DECIMAL(19,6),
			TA_AREA_GROSS						DECIMAL(19,6),
			-- ============================
			TA_C_HOJA_EMPAQUE					NVARCHAR(MAX),
			TA_L_REVISION_ACTIVA				INT,
			-- ============================
			TA_K_HOJA_EMPAQUE_CAPA_DIVISION		INT,
			-- ============================
			TA_K_TIPO_CAMBIO_KIT				INT,
			-- ============================
			--TA_K_USUARIO_ALTA					INT,
			--TA_F_ALTA							DATETIME,
			--TA_K_USUARIO_CAMBIO					INT,
			--TA_F_CAMBIO							DATETIME,
			-- ============================
			TA_L_BORRADO						INT,
			TA_N_CAPAS							INT		)

	INSERT INTO @VP_TA_HOJA_NUEVA
	SELECT	DISTINCT
		(CCITMIDX_SQL.ITEM_NO) AS P,		--	ITEM_NO
		0,									--	STATUS
		-- ============================
		CCITMIDX_SQL.CUS_NO,
		CCITMIDX_SQL.MODELNO,
		CCITMIDX_SQL.VERSIONNO,
		-- ============================
		COLOUR,								--	COLOR
		LEFT(CCITMIDX_SQL.ITEM_NO,7),		--	ITEM_P SIN COLOR
		CUS_ITEM_NO,						--	CUSTOMER_ITEM
		ITEM_DESC_1,						--	D_ITEM_NO
		-- ============================
		'',									--	CAJA
		'',									--	DIBUJO
		0,									--	REVISIÓN
		-- ============================
		CCITMIDX_SQL.user_def_fld_5,		--	STANDAR_PACK
		CCITMIDX_SQL.CUBE_QTY_PER,			--	CANTIDAD_PATRONES
		CUBE_WIDTH,							--	AREA_NETA
		CUBE_LENGTH,						--	AREA_GROSS
		-- ============================
		'',									--	COMENTARIOS
		1,									--	L_REVISION_ACTIVA
		-- ============================
		1,									--	CAPA_DIVISION
		-- ============================
		0,									--	K_TIPO_CAMBIO
		-- ============================
		--139,	GETDATE(),	
		--139,	GETDATE(),	
		-- ============================
		0,
		1
		-- ============================
		--*
	--FROM	CCITMIDX_SQL		(NOLOCK)
	FROM	DATA_02.DBO.CCITMIDX_SQL		(NOLOCK)
	INNER JOIN	DATA_02.DBO.CCCUSITM_SQL	(NOLOCK) ON CCCUSITM_SQL.ITEM_NO	= CCITMIDX_SQL.ITEM_NO
	INNER JOIN	DATA_02.DBO.ccverhdr_sql	(NOLOCK) ON CONCAT(ccverhdr_sql.modelno, ccverhdr_sql.versionno ) = CONCAT(CCITMIDX_SQL.modelno, CCITMIDX_SQL.versionno )
	WHERE	CCITMIDX_SQL.ITEM_NO LIKE 'P%'
	AND		CCCUSITM_SQL.CUS_NO			= CCITMIDX_SQL.CUS_NO			
	AND		CCCUSITM_SQL.MODELNO		= CCITMIDX_SQL.MODELNO		
	AND		CCCUSITM_SQL.VERSIONNO		= CCITMIDX_SQL.VERSIONNO		
	--AND		ccverhdr_sql.status			= 'L' -- IN ('A', 'I', 'L' )--( @VP_ccverhdr_sql_status	 )		--= 'L' 
	--AND		ccverhdr_sql.specstatus		= 'U' -- IN ('A', 'C', 'U' )--( @VP_ccverhdr_sql_specstatus )	--= 'U' 
	AND		CCITMIDX_SQL.CUS_NO			= @PP_S_CUSTOMER
	AND		CCITMIDX_SQL.MODELNO		= @PP_S_MODEL		
	AND		CCITMIDX_SQL.VERSIONNO		= FORMAT(@PP_NO_VERSION,'0000')
	ORDER BY CCITMIDX_SQL.CUS_NO, CCITMIDX_SQL.MODELNO, CCITMIDX_SQL.VERSIONNO, P DESC
	IF @@ROWCOUNT = 0
	BEGIN
		SET @VP_MENSAJE = '[SELECT]: No se encontrarón registros para el modelo/versión. [HE]# '+ @PP_S_MODEL + '//' + FORMAT(@PP_NO_VERSION,'0000') +CHAR(13)+CHAR(10) +
											'Verifique....'
		RAISERROR (@VP_MENSAJE, 16, 1 ) 
	END

	--	SELECT * FROM @VP_TA_HOJA_NUEVA

	DECLARE	@VP_TA_HOJA_CAPA					AS TABLE
	(		TA_CUS_NO							VARCHAR(6),
			TA_MODELNO							VARCHAR(3),
			TA_VERSIONNO						VARCHAR(4),
			-- ============================
			TA_REVISION_HOJA_EMPAQUE			INT,
			TA_ITEM_P							VARCHAR(50),
			TA_TIPO_CAMBIO						INT
	)

	--IF @PP_NO_VERSION > 1
	--BEGIN
		DECLARE CU_CURSOR	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
			SELECT * FROM @VP_TA_HOJA_NUEVA
		OPEN CU_CURSOR
			FETCH NEXT FROM  CU_CURSOR INTO    @VP_CU_ITEM_NO				,@VP_CU_K_HOJA_EMPAQUE_STATUS			
											   -- ============================
											   ,@VP_CU_CUS_NO				,@VP_CU_MODELNO					,@VP_CU_VERSIONNO						
											   -- ============================
											   ,@VP_CU_COLOR				,@VP_CU_ITEM_P					,@VP_CU_CUSTOMER_ITEM_NO			,@VP_CU_D_ITEM_NO
											   -- ============================
											   ,@VP_CU_CAJA_HOJA_EMPAQUE	,@VP_CU_DIBUJO_HOJA_EMPAQUE		,@VP_CU_REVISION_HOJA_EMPAQUE			
											   -- ============================
											   ,@VP_CU_STANDAR_PACK			,@VP_CU_CANTIDAD_PATRONES		,@VP_CU_AREA_NETA					,@VP_CU_AREA_GROSS
											   -- ============================
											   ,@VP_CU_C_HOJA_EMPAQUE		,@VP_CU_L_REVISION_ACTIVA				
											   -- ============================
											   ,@VP_CU_K_HOJA_EMPAQUE_CAPA_DIVISION		
											   -- ============================
											   ,@VP_CU_K_TIPO_CAMBIO_KIT				
											   -- ============================
											   ,@VP_CU_L_BORRADO			,@VP_CU_N_CAPAS
			WHILE @@FETCH_STATUS=0
			BEGIN
				DECLARE	 @VP_CANTIDAD_PATRONES				INT
						,@VP_AREA_NETA						DECIMAL(19,6)
						,@VP_AREA_GROSS						DECIMAL(19,6)
						,@VP_CAJA_HOJA_EMPAQUE				VARCHAR(250)
						,@VP_K_HOJA_EMPAQUE_CAPA_DIVISION	INT
						,@VP_REVISION_HOJA_EMPAQUE			INT
						,@VP_N_CAPAS						INT	= 0


				SELECT	--@VP_ITEM_NO						=	[ITEM_NO]						,
						--@VP_K_HOJA_EMPAQUE_STATUS		=	[K_HOJA_EMPAQUE_STATUS]			,
						---- ============================-- ============================
						--@VP_CUS_NO						=	[CUS_NO]						,
						--@VP_MODELNO						=	[MODELNO]						,
						--@VP_VERSIONNO					=	[VERSIONNO]						,
						---- ============================-- ============================
						--@VP_COLOR						=	[COLOR]							,
						--@VP_ITEM_P						=	[ITEM_P]						,
						--@VP_CUSTOMER_ITEM_NO			=	[CUSTOMER_ITEM_NO]				,
						--@VP_D_ITEM_NO					=	[D_ITEM_NO]						,
						---- ============================-- ============================
						@VP_CAJA_HOJA_EMPAQUE			=	ISNULL([CAJA_HOJA_EMPAQUE]	,'')		,
						----[DIBUJO_HOJA_EMPAQUE]			--[DIBUJO_HOJA_EMPAQUE]			
						@VP_REVISION_HOJA_EMPAQUE		=	[REVISION_HOJA_EMPAQUE]			,
						---- ============================-- ============================
						--@VP_STANDAR_PACK				=	[STANDAR_PACK]					,
						@VP_CANTIDAD_PATRONES			=	ISNULL([CANTIDAD_PATRONES]	,0)		,
						@VP_AREA_NETA					=	ISNULL([AREA_NETA]			,0)		,
						@VP_AREA_GROSS					=	ISNULL([AREA_GROSS]			,0)		,
						----[RUTA_AYUDA_VISUAL_HEADER]	--[RUTA_AYUDA_VISUAL_HEADER]	
						---- ============================-- ============================
						--@VP_C_HOJA_EMPAQUE			=	[C_HOJA_EMPAQUE],
						--@VP_L_REVISION_ACTIVA			=	[L_REVISION_ACTIVA]				,
						---- ============================-- ============================
						@VP_K_HOJA_EMPAQUE_CAPA_DIVISION	= [K_HOJA_EMPAQUE_CAPA_DIVISION]	,
						---- ============================-- ============================
						--@VP_K_TIPO_CAMBIO_KIT			=	[K_TIPO_CAMBIO_KIT]				,
						--@VP_K_USUARIO_ALTA				=	[K_USUARIO_ALTA]				,
						--@VP_F_ALTA						=	[F_ALTA]						,
						--@VP_K_USUARIO_CAMBIO			=	[K_USUARIO_CAMBIO]				,
						--@VP_F_CAMBIO					=	[F_CAMBIO]						,
						--@VP_L_BORRADO					=	[L_BORRADO]						,
						@VP_N_CAPAS						=	[N_CAPAS]
				FROM	HOJA_EMPAQUE		(NOLOCK)
				WHERE	CUS_NO				= @PP_S_CUSTOMER
				AND		MODELNO				= @PP_S_MODEL		
				AND		VERSIONNO			= @PP_NO_VERSION_ANTERIOR
				AND		L_REVISION_ACTIVA	= 1
				AND		ITEM_NO				= @VP_CU_ITEM_NO
				IF @@ROWCOUNT	= 0
				BEGIN
						SET	@VP_CU_K_TIPO_CAMBIO_KIT	= 5
				END
				ELSE
				BEGIN				
					--	//	#0: SIN CAMBIOS,	#1: DIMENSIONES,	#2: PROCESOS_ESPECIALES,	#3: VARIOS_CAMBIOS, #4 REVISIÓN	,	#5 NUEVO KIT
					IF ( @VP_CANTIDAD_PATRONES <> @VP_CU_CANTIDAD_PATRONES ) OR ( @VP_AREA_NETA <> @VP_CU_AREA_NETA ) OR ( @VP_AREA_GROSS <> @VP_CU_AREA_GROSS )
					BEGIN
						SET	@VP_CU_K_TIPO_CAMBIO_KIT	= 1
					END

					SET	@VP_CU_K_HOJA_EMPAQUE_CAPA_DIVISION	= @VP_K_HOJA_EMPAQUE_CAPA_DIVISION
					SET	@VP_CU_CAJA_HOJA_EMPAQUE			= @VP_CAJA_HOJA_EMPAQUE
					SET	@VP_CU_N_CAPAS						= @VP_N_CAPAS
				
				END
				
				INSERT INTO [dbo].[HOJA_EMPAQUE]
				(	[K_HOJA_EMPAQUE_STATUS]			,
					-- ============================
					[CUS_NO]						,
					[MODELNO]						,
					[VERSIONNO]						,
					-- ============================
					[ITEM_NO]						,
					[COLOR]							,
					[ITEM_P]						,
					[CUSTOMER_ITEM_NO]				,
					[D_ITEM_NO]						,
					-- ============================
					[CAJA_HOJA_EMPAQUE]				,
					[DIBUJO_HOJA_EMPAQUE]			,
					[REVISION_HOJA_EMPAQUE]			,
					-- ============================
					[STANDAR_PACK]					,
					[CANTIDAD_PATRONES]				,
					[AREA_NETA]						,
					[AREA_GROSS]					,
					--[RUTA_AYUDA_VISUAL_HEADER]	
					-- ============================
					[C_HOJA_EMPAQUE],
					[L_REVISION_ACTIVA]				,
					-- ============================
					[K_HOJA_EMPAQUE_CAPA_DIVISION]	,
					-- ============================
					[K_TIPO_CAMBIO_KIT]				,
					-- ============================
					[K_USUARIO_ALTA]				,
					[F_ALTA]						,
					[K_USUARIO_CAMBIO]				,
					[F_CAMBIO]						,
					[L_BORRADO]						,
					[N_CAPAS]						)
				SELECT	 @VP_CU_K_HOJA_EMPAQUE_STATUS			
						-- ============================
						,@VP_CU_CUS_NO				,@VP_CU_MODELNO					,@VP_CU_VERSIONNO
						-- ============================
						,@VP_CU_ITEM_NO
						,@VP_CU_COLOR				,@VP_CU_ITEM_P					,@VP_CU_CUSTOMER_ITEM_NO		,@VP_CU_D_ITEM_NO
						-- ============================
						,@VP_CU_CAJA_HOJA_EMPAQUE	,@VP_CU_DIBUJO_HOJA_EMPAQUE		,@VP_CU_REVISION_HOJA_EMPAQUE			
						-- ============================
						,@VP_CU_STANDAR_PACK		,@VP_CU_CANTIDAD_PATRONES		,@VP_CU_AREA_NETA				,@VP_CU_AREA_GROSS
						-- ============================
						,@VP_CU_C_HOJA_EMPAQUE		,@VP_CU_L_REVISION_ACTIVA				
						-- ============================
						,@VP_CU_K_HOJA_EMPAQUE_CAPA_DIVISION
						-- ============================
						,@VP_CU_K_TIPO_CAMBIO_KIT				
						-- ============================
						,@PP_K_USUARIO_ACCION	,GETDATE()
						,@PP_K_USUARIO_ACCION	,GETDATE()
						-- ============================
						,@VP_CU_L_BORRADO
						,@VP_CU_N_CAPAS
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE = '[INSERT]: No se insertó el registro. [HE]# '+ @VP_CU_ITEM_NO + CHAR(13)+CHAR(10) +
														'Verifique....'
					RAISERROR (@VP_MENSAJE, 16, 1 ) 
				END

				INSERT INTO	@VP_TA_HOJA_CAPA
				(		TA_CUS_NO	,	TA_MODELNO	,	TA_VERSIONNO,	
						TA_REVISION_HOJA_EMPAQUE,
						TA_ITEM_P	,	TA_TIPO_CAMBIO	)
				SELECT	 @VP_CU_CUS_NO	,@VP_CU_MODELNO	,@VP_CU_VERSIONNO	--@PP_NO_VERSION_ANTERIOR
						,@VP_REVISION_HOJA_EMPAQUE
						,@VP_CU_ITEM_P	,@VP_CU_K_TIPO_CAMBIO_KIT
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE = '[INSERT]: No se insertó el registro. [HEC]# '+ @VP_CU_ITEM_NO + CHAR(13)+CHAR(10) +
														'Verifique....'
					RAISERROR (@VP_MENSAJE, 16, 1 ) 
				END						
				
			FETCH NEXT FROM  CU_CURSOR INTO    @VP_CU_ITEM_NO				,@VP_CU_K_HOJA_EMPAQUE_STATUS			
											   -- ============================
											   ,@VP_CU_CUS_NO				,@VP_CU_MODELNO					,@VP_CU_VERSIONNO						
											   -- ============================
											   ,@VP_CU_COLOR				,@VP_CU_ITEM_P					,@VP_CU_CUSTOMER_ITEM_NO			,@VP_CU_D_ITEM_NO						
											   -- ============================
											   ,@VP_CU_CAJA_HOJA_EMPAQUE	,@VP_CU_DIBUJO_HOJA_EMPAQUE		,@VP_CU_REVISION_HOJA_EMPAQUE			
											   -- ============================
											   ,@VP_CU_STANDAR_PACK			,@VP_CU_CANTIDAD_PATRONES		,@VP_CU_AREA_NETA					,@VP_CU_AREA_GROSS						
											   -- ============================
											   ,@VP_CU_C_HOJA_EMPAQUE		,@VP_CU_L_REVISION_ACTIVA				
											   -- ============================
											   ,@VP_CU_K_HOJA_EMPAQUE_CAPA_DIVISION		
											   -- ============================
											   ,@VP_CU_K_TIPO_CAMBIO_KIT				
											   -- ============================
											   ,@VP_CU_L_BORRADO			,@VP_CU_N_CAPAS
		END
		CLOSE		CU_CURSOR
		DEALLOCATE	CU_CURSOR	
--	END																   
	------------------------------------------------------------------------------
				UPDATE	HOJA_EMPAQUE
				SET		[L_REVISION_ACTIVA]	= 0
				WHERE	CUS_NO				= @PP_S_CUSTOMER
				AND		MODELNO				= @PP_S_MODEL		
				AND		VERSIONNO			= @PP_NO_VERSION_ANTERIOR			  
	------------------------------------------------------------------------------
		DECLARE	@VP_CU_2_ITEM_P						VARCHAR(50),
				@VP_CU_2_CUS_NO						VARCHAR(6),
				@VP_CU_2_MODELNO					VARCHAR(3),
				@VP_CU_2_VERSIONNO					INT,
				@VP_CU_2_REVISION_HOJA_EMPAQUE		INT,
				@VP_CU_2_K_TIPO_CAMBIO_KIT			INT
		--DECLARE @VP_TA_RUTAS_IMAGEN		AS TABLE
		--(	TA_RUTA_SERVR		NVARCHAR(MAX),
		--	TA_RUTA_LOCAL		NVARCHAR(MAX),
		--	TA_CREAR_CARP		NVARCHAR(MAX)	)
		DECLARE CU_CURSOR_CAPA	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
			SELECT	DISTINCT(TA_ITEM_P) ,
					TA_CUS_NO	,	TA_MODELNO	,	TA_VERSIONNO,	TA_REVISION_HOJA_EMPAQUE,	TA_TIPO_CAMBIO
			FROM	@VP_TA_HOJA_CAPA
		OPEN CU_CURSOR_CAPA
			FETCH NEXT FROM  CU_CURSOR_CAPA INTO    @VP_CU_2_ITEM_P	,@VP_CU_2_CUS_NO	,@VP_CU_2_MODELNO	,@VP_CU_2_VERSIONNO	,@VP_CU_2_REVISION_HOJA_EMPAQUE	,@VP_CU_2_K_TIPO_CAMBIO_KIT
			WHILE @@FETCH_STATUS=0
			BEGIN
			--	//	#0: SIN CAMBIOS,	#1: DIMENSIONES,	#2: PROCESOS_ESPECIALES,	#3: VARIOS_CAMBIOS, #4 REVISIÓN	,	#5 NUEVO KIT
				IF @VP_CU_K_TIPO_CAMBIO_KIT IN (0)
				BEGIN
					
					DECLARE	@VP_RUTA_CAPA_NUEVA	NVARCHAR(MAX)	= LTRIM(RTRIM(@VP_CU_2_CUS_NO)) +'\'+ LTRIM(RTRIM(@VP_CU_2_MODELNO)) +'\'+ LTRIM(RTRIM(@VP_CU_2_VERSIONNO)) + '\'
					DECLARE	@VP_RUTA_CAPA_ANTER	NVARCHAR(MAX)	= LTRIM(RTRIM(@VP_CU_2_CUS_NO)) +'\'+ LTRIM(RTRIM(@VP_CU_2_MODELNO)) +'\'+ LTRIM(RTRIM(@PP_NO_VERSION_ANTERIOR)) + '\'
					DECLARE @VP_REV	INT, @VP_CAPA INT

					SELECT	@VP_REV		= REVISION_HOJA_EMPAQUE,
							@VP_CAPA	= N_CAPA
							--[RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR]
							--[RUTA_HOJA_EMPAQUE_CAPA_MODELO]
							--[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]
							--[RUTA_HOJA_EMPAQUE_CAPA_EXTENSION]	
					FROM	[dbo].[HOJA_EMPAQUE_CAPA]	(NOLOCK)
					WHERE	CUS_NO					= @PP_S_CUSTOMER
					AND		MODELNO					= @PP_S_MODEL		
					AND		VERSIONNO				= @PP_NO_VERSION_ANTERIOR
					AND		REVISION_HOJA_EMPAQUE	= @VP_CU_2_REVISION_HOJA_EMPAQUE
					AND		ITEM_P					= @VP_CU_2_ITEM_P
					
					
					DECLARE	@VP_CAPA_IMAGEN		NVARCHAR(MAX)	= LTRIM(RTRIM(@VP_CU_2_ITEM_P)) +'_'+FORMAT(@VP_REV,'000') +'_'+ CONVERT(VARCHAR(10),@VP_CAPA)


					INSERT INTO [dbo].[HOJA_EMPAQUE_CAPA]
					(		 [CUS_NO]	,[MODELNO]	,[VERSIONNO]
							,[ITEM_P]	,[REVISION_HOJA_EMPAQUE]
							,[N_CAPA]	,[N_PATRONES_CAPA]
							--==================================
							,[RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR]
							,[RUTA_HOJA_EMPAQUE_CAPA_MODELO]
							,[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]
							,[RUTA_HOJA_EMPAQUE_CAPA_EXTENSION]
							--==================================
							,[K_USUARIO_ALTA]	,[F_ALTA]
							,[K_USUARIO_CAMBIO]	,[F_CAMBIO]		)
					SELECT	@VP_CU_2_CUS_NO,	@VP_CU_2_MODELNO,	@VP_CU_2_VERSIONNO,
							@VP_CU_2_ITEM_P,	0,
							[N_CAPA],		[N_PATRONES_CAPA],
							--1,			0,
							--==================================
							[RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR],
							--[RUTA_HOJA_EMPAQUE_CAPA_MODELO]	 ,
							--LTRIM(RTRIM(@VP_CU_2_CUS_NO)) +'\'+ LTRIM(RTRIM(@VP_CU_2_MODELNO)) +'\'+ LTRIM(RTRIM(@VP_CU_2_VERSIONNO)) + '\',
							@VP_RUTA_CAPA_NUEVA,
							@VP_CAPA_IMAGEN,	--[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]	 ,
							[RUTA_HOJA_EMPAQUE_CAPA_EXTENSION],
							--==================================
							@PP_K_USUARIO_ACCION,	GETDATE(),
							@PP_K_USUARIO_ACCION,	GETDATE()
					FROM	[dbo].[HOJA_EMPAQUE_CAPA]		(NOLOCK)
					WHERE	CUS_NO					= @PP_S_CUSTOMER
					AND		MODELNO					= @PP_S_MODEL		
					AND		VERSIONNO				= @PP_NO_VERSION_ANTERIOR
					AND		REVISION_HOJA_EMPAQUE	= @VP_CU_2_REVISION_HOJA_EMPAQUE
					AND		ITEM_P					= @VP_CU_2_ITEM_P
					--IF @@ROWCOUNT = 0
					--BEGIN
					--	SET @VP_MENSAJE = '[INSERT]: No se insertó el registro. [HECP]# '+ @VP_CU_2_ITEM_P + CHAR(13)+CHAR(10) + 'Verifique....'
					--	RAISERROR (@VP_MENSAJE, 16, 1 ) 
					--END
					--ELSE
					--BEGIN
						--	SÓLO CUANDO EL KIT NO SUFRE CAMBIOS SE REALIZA LA COPIA DE LA IMAGEN. EN CASO CONTRARIO SERÁ NECESARIO INGRESARLA DESDE EL FRONT.
						INSERT INTO HOJA_EMPAQUE_RUTAS_IMAGEN	--@VP_TA_RUTAS_IMAGEN
						(	[CUS_NO]		,
							[MODELNO]		,
							[VERSIONNO]		,
						-- ============================
							[RUTA_SERVR]	,	
							[RUTA_LOCAL]	,
							[CREAR_CARP]	)
						VALUES
						(	@PP_S_CUSTOMER	 ,
							@PP_S_MODEL		 ,
							@PP_NO_VERSION	 ,
						-- ============================							
							@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR + @VP_RUTA_CAPA_NUEVA + @VP_CAPA_IMAGEN + '.PNG'	,		--'',
							@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR + @VP_RUTA_CAPA_ANTER + @VP_CAPA_IMAGEN + '.PNG'	,		--'',
							@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	+ @VP_RUTA_CAPA_NUEVA	)									--'')
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El registro de la ruta no fue ingresado. [HECI# '+CONVERT(VARCHAR(10),@VP_CU_2_ITEM_P) + ']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END
					--END
				END
				ELSE IF @VP_CU_K_TIPO_CAMBIO_KIT IN (1)
				BEGIN
					INSERT INTO [dbo].[HOJA_EMPAQUE_CAPA]
					(		 [CUS_NO]	,[MODELNO]	,[VERSIONNO]
							,[ITEM_P]	,[REVISION_HOJA_EMPAQUE]
							,[N_CAPA]	,[N_PATRONES_CAPA]
							--==================================
							,[RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR]
							,[RUTA_HOJA_EMPAQUE_CAPA_MODELO]
							,[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]
							,[RUTA_HOJA_EMPAQUE_CAPA_EXTENSION]
							--==================================
							,[K_USUARIO_ALTA]	,[F_ALTA]
							,[K_USUARIO_CAMBIO]	,[F_CAMBIO]		)
					SELECT	@VP_CU_2_CUS_NO,	@VP_CU_2_MODELNO,	@VP_CU_2_VERSIONNO,
							@VP_CU_2_ITEM_P,	0,
							--[N_CAPA],		[N_PATRONES_CAPA],
							1,			0,
							--==================================
							'',	'',	'',	'',
							--==================================
							@PP_K_USUARIO_ACCION,	GETDATE(),
							@PP_K_USUARIO_ACCION,	GETDATE()
					IF @@ROWCOUNT = 0
					BEGIN
						SET @VP_MENSAJE = '[INSERT]: No se insertó el registro. [HECP]# '+ @VP_CU_2_ITEM_P + CHAR(13)+CHAR(10) + 'Verifique....'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END
				END
				ELSE IF @VP_CU_K_TIPO_CAMBIO_KIT IN (5)
				BEGIN
					INSERT INTO [dbo].[HOJA_EMPAQUE_CAPA]
					(		 [CUS_NO]	,[MODELNO]	,[VERSIONNO]
							,[ITEM_P]	,[REVISION_HOJA_EMPAQUE]
							,[N_CAPA]	,[N_PATRONES_CAPA]
							,[RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR]
							,[RUTA_HOJA_EMPAQUE_CAPA_MODELO]
							,[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]
							,[RUTA_HOJA_EMPAQUE_CAPA_EXTENSION]
							,[K_USUARIO_ALTA]	,[F_ALTA]
							,[K_USUARIO_CAMBIO]	,[F_CAMBIO]			)
					SELECT	@VP_CU_2_CUS_NO,	@VP_CU_2_MODELNO,	@VP_CU_2_VERSIONNO,
							@VP_CU_2_ITEM_P,	0,
							1,			0,
							'',	'',	'',	'',
							@PP_K_USUARIO_ACCION,	GETDATE(),
							@PP_K_USUARIO_ACCION,	GETDATE()
					IF @@ROWCOUNT = 0
					BEGIN
						SET @VP_MENSAJE = '[INSERT]: No se insertó el registro. [HECP]# '+ @VP_CU_2_ITEM_P + CHAR(13)+CHAR(10) + 'Verifique....'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END
				END
			FETCH NEXT FROM  CU_CURSOR_CAPA INTO    @VP_CU_2_ITEM_P	,@VP_CU_2_CUS_NO	,@VP_CU_2_MODELNO	,@VP_CU_2_VERSIONNO	,@VP_CU_2_REVISION_HOJA_EMPAQUE	,@VP_CU_2_K_TIPO_CAMBIO_KIT
		END
		CLOSE		CU_CURSOR_CAPA
		DEALLOCATE	CU_CURSOR_CAPA	
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	DECLARE	@VP_CU_X_ITEM_P						VARCHAR(50),
			@VP_CU_X_REVISION_HOJA_EMPAQUE		INT,
			@VP_CU_X_N_CAPA						INT

	DECLARE CU_CURSOR_CAPA_X	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
		SELECT	DISTINCT (ITEM_P),
				REVISION_HOJA_EMPAQUE,
				N_CAPAS
		FROM	[HOJA_EMPAQUE]		(NOLOCK)
		WHERE	CUS_NO				= @PP_S_CUSTOMER	--@PP_CUS_NO		--	'DAIM05'	--
		AND		MODELNO				= @PP_S_MODEL		--@PP_MODELNO		--	'WDK'		--
		AND		VERSIONNO			= @PP_NO_VERSION	--@PP_VERSIONNO		--	'9'			--
		--AND		ITEM_P					= 'PL3ARLH'				--@PP_ITEM_P
		--AND		REVISION_HOJA_EMPAQUE	= '0'				--@PP_REVISION_HOJA_EMPAQUE	
	OPEN CU_CURSOR_CAPA_X
		FETCH NEXT FROM  CU_CURSOR_CAPA_X INTO    @VP_CU_X_ITEM_P	,@VP_CU_X_REVISION_HOJA_EMPAQUE	,@VP_CU_X_N_CAPA
		WHILE @@FETCH_STATUS=0
		BEGIN	
		
			DECLARE	@VP_L_CAPAS_COMPLETAS	INT = 0

			IF	@VP_CU_X_N_CAPA > 0
			BEGIN
				IF	@VP_CU_X_N_CAPA	= (	SELECT	COUNT(K_HOJA_EMPAQUE_CAPA)
										FROM	[HOJA_EMPAQUE_CAPA]
										WHERE	[CUS_NO]						= @PP_S_CUSTOMER		--@PP_CUS_NO 
										AND		[MODELNO]						= @PP_S_MODEL				--@PP_MODELNO
										AND		[VERSIONNO]						= @PP_NO_VERSION		--@PP_VERSIONNO
												-- ============================
										AND		[ITEM_P]						= @VP_CU_X_ITEM_P
										AND		[REVISION_HOJA_EMPAQUE]			= @VP_CU_X_REVISION_HOJA_EMPAQUE
										AND		[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]	<> ''	)
				BEGIN
					SET		@VP_L_CAPAS_COMPLETAS	= 1
				END
			END

			UPDATE	[HOJA_EMPAQUE]
			SET		[L_CAPAS_COMPLETAS]		= @VP_L_CAPAS_COMPLETAS
					-- ============================
			WHERE	CUS_NO					= @PP_S_CUSTOMER
			AND		MODELNO					= @PP_S_MODEL	
			AND		VERSIONNO				= @PP_NO_VERSION
			AND		ITEM_P					= @VP_CU_X_ITEM_P
			AND		REVISION_HOJA_EMPAQUE	= @VP_CU_X_REVISION_HOJA_EMPAQUE
			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='Registro no fue ingresado.(L_CAPAS)[HE#' + CONVERT(VARCHAR(10),@VP_CU_X_ITEM_P ) + ']'
				RAISERROR (@VP_MENSAJE, 16, 1 ) 
			END
		FETCH NEXT FROM  CU_CURSOR_CAPA_X INTO    @VP_CU_X_ITEM_P	,@VP_CU_X_REVISION_HOJA_EMPAQUE	,@VP_CU_X_N_CAPA
	END
	CLOSE		CU_CURSOR_CAPA_X
	DEALLOCATE	CU_CURSOR_CAPA_X	

--COMMIT TRANSACTION 
--END TRY
--BEGIN CATCH
--	--	OCURRIÓ UN ERROR, DESHACEMOS LOS CAMBIOS
--	ROLLBACK TRANSACTION
--	DECLARE @ErrorMessage NVARCHAR(4000);
--	SET @ErrorMessage = ERROR_MESSAGE() 
--	SET @VP_MENSAJE = 'ERROR: // ' + @ErrorMessage
--END CATCH	

--SELECT	@VP_MENSAJE AS MENSAJE
-- //////////////////////////////////////////////////////////////
GO	


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INGRESA LA INFORMACIÓN DE LOS PROCESOS 
-- //						DE LAS HOJAS DE EMPAQUE.
-- // SISTEMA DE PRODUCTIVO							20220111
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_HOJA_EMPAQUE_VERSION_PROCESO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_HOJA_EMPAQUE_VERSION_PROCESO]
GO
--		EXECUTE  [dbo].[PG_IN_HOJA_EMPAQUE_VERSION_PROCESO] 	0,139,	'FAUR01','FW2','0011'
--		EXECUTE  [dbo].[PG_IN_HOJA_EMPAQUE_VERSION_PROCESO] 	0,139,	'IRVI02','JLI','0059'		--	PARA PRUEBAS DE ESTE SP
CREATE PROCEDURE [dbo].[PG_IN_HOJA_EMPAQUE_VERSION_PROCESO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_S_CUSTOMER				VARCHAR(6),
	@PP_S_MODEL					VARCHAR(3),
	@PP_NO_VERSION				INT
AS
DECLARE	 @VP_MENSAJE			NVARCHAR(MAX)
		,@VP_VERSION_ANTERIOR	INT
		
DECLARE	 @VP_CU_ITEM_NO							VARCHAR(50)
		--============================
		,@VP_CU_CUS_NO							VARCHAR(6)
		,@VP_CU_MODELNO							VARCHAR(3)
		,@VP_CU_VERSIONNO						VARCHAR(4)
		,@VP_CU_REVISION						VARCHAR(4)
		--============================
		,@VP_CU_K_PROCESO						INT
		,@VP_CU_K_PROCESO_SIMBOLO				INT
		--============================
		,@VP_CU_L_HOJA_EMPAQUE_PROCESO			INT
		--============================
		,@VP_CU_D_PROCESO						VARCHAR(250)

	SET	@VP_VERSION_ANTERIOR	= @PP_NO_VERSION  - 1

	DECLARE	@VP_TA_HOJA_PROCESO						AS TABLE
	(		TA_ITEM_NO							VARCHAR(50),	
			-- ============================
			TA_CUS_NO							VARCHAR(6),
			TA_MODELNO							VARCHAR(3),
			TA_VERSIONNO						VARCHAR(4),
			TA_REVISION							VARCHAR(4),
			-- ============================
			TA_K_PROCESO						INT,
			TA_K_PROCESO_SIMBOLO				INT,
			-- ============================
			TA_L_HOJA_EMPAQUE_PROCESO			INT,
			-- ============================
			TA_D_PROCESO						VARCHAR(250)	)

INSERT INTO @VP_TA_HOJA_PROCESO
SELECT	ITEM_P,	--	COUNT(K_HOJA_EMPAQUE_PROCESO)
		CUS_NO,
		MODELNO,
		VERSIONNO,
		REVISION_HOJA_EMPAQUE,
	-- ============================
		K_PROCESO,
		K_PROCESO_SIMBOLO,
		L_HOJA_EMPAQUE_PROCESO,
	-- ============================
		D_HOJA_EMPAQUE_PROCESO
FROM	HOJA_EMPAQUE_PROCESO	(NOLOCK)
WHERE	HOJA_EMPAQUE_PROCESO.CUS_NO		= @PP_S_CUSTOMER		--	
AND		HOJA_EMPAQUE_PROCESO.MODELNO	= @PP_S_MODEL			--	
AND		HOJA_EMPAQUE_PROCESO.VERSIONNO	= @VP_VERSION_ANTERIOR	--	
AND		HOJA_EMPAQUE_PROCESO.REVISION_HOJA_EMPAQUE	IN (	SELECT	REVISION_HOJA_EMPAQUE
															FROM	HOJA_EMPAQUE	
															WHERE	HOJA_EMPAQUE.CUS_NO				= @PP_S_CUSTOMER		--	
															AND		HOJA_EMPAQUE.MODELNO			= @PP_S_MODEL			--	
															AND		HOJA_EMPAQUE.VERSIONNO			= @VP_VERSION_ANTERIOR	--
															AND		HOJA_EMPAQUE.L_REVISION_ACTIVA	= 1		)

--SELECT	DISTINCT	(LEFT(HOJA_EMPAQUE.ITEM_NO,7)) AS IT,
--	-- ============================
--		SPITMIDX_SQL.CUS_NO,
--		SPITMIDX_SQL.MODELNO,
--		SPITMIDX_SQL.VERSIONNO,
--		0,
--	-- ============================
--		K_PROCESS,
--		(CASE
--			WHEN	K_PROCESS IN (2,8,9,11,12,13)	THEN	1
--			WHEN	K_PROCESS IN (3,10)				THEN	2
--			WHEN	K_PROCESS IN (5,14,15)			THEN	3
--			ELSE	0
--		END) AS K_PROCESO_SIMBOLO,		
--		(CASE
--			WHEN	K_PROCESS IN (1,4,6,7)			THEN	0
--			ELSE	1
--		END)	AS L_HOJA_EMPAQUE_PROCESO,
--	-- ============================
--		D_PROCESS
--FROM	SPITMIDX_SQL	(NOLOCK)
--INNER JOIN HOJA_EMPAQUE	(NOLOCK)	ON HOJA_EMPAQUE.CUS_NO	= SPITMIDX_SQL.CUS_NO
--AND		HOJA_EMPAQUE.MODELNO	= SPITMIDX_SQL.MODELNO
--AND		HOJA_EMPAQUE.VERSIONNO	= SPITMIDX_SQL.VERSIONNO
--AND		HOJA_EMPAQUE.ITEM_NO	= SPITMIDX_SQL.ITEM_NO_KIT
--WHERE	SPITMIDX_SQL.CUS_NO		= @PP_S_CUSTOMER		--	'MAGN03'
--AND		SPITMIDX_SQL.MODELNO	= @PP_S_MODEL			--	'WD2'
--AND		SPITMIDX_SQL.VERSIONNO	= @VP_VERSION_ANTERIOR	--	'0015'
--ORDER BY SPITMIDX_SQL.CUS_NO,
--		SPITMIDX_SQL.MODELNO,
--		SPITMIDX_SQL.VERSIONNO,
--		IT DESC


	DECLARE CU_CURSOR	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
		SELECT	DISTINCT	(LEFT(HOJA_EMPAQUE.ITEM_NO,7)) AS IT,
			-- ============================
				SPITMIDX_SQL.CUS_NO,
				SPITMIDX_SQL.MODELNO,
				SPITMIDX_SQL.VERSIONNO,
				0,
			-- ============================
				K_PROCESS,
				(CASE
					WHEN	K_PROCESS IN (2,8,9,11,12,13)	THEN	1
					WHEN	K_PROCESS IN (3,10)				THEN	2
					WHEN	K_PROCESS IN (5,14,15)			THEN	3
					ELSE	0
				END) AS K_PROCESO_SIMBOLO,
		
				(CASE
					WHEN	K_PROCESS IN (1,4,6,7)			THEN	0
					ELSE	1
				END)	AS L_HOJA_EMPAQUE_PROCESO,
			-- ============================
				D_PROCESS
		FROM	SPITMIDX_SQL	(NOLOCK)
		INNER JOIN HOJA_EMPAQUE	(NOLOCK)	ON HOJA_EMPAQUE.CUS_NO	= SPITMIDX_SQL.CUS_NO
		AND		HOJA_EMPAQUE.MODELNO	= SPITMIDX_SQL.MODELNO
		AND		HOJA_EMPAQUE.VERSIONNO	= SPITMIDX_SQL.VERSIONNO
		AND		HOJA_EMPAQUE.ITEM_NO	= SPITMIDX_SQL.ITEM_NO_KIT
		WHERE	SPITMIDX_SQL.CUS_NO		= @PP_S_CUSTOMER	--	'MAGN03'
		AND		SPITMIDX_SQL.MODELNO	= @PP_S_MODEL		--	'WD2'
		AND		SPITMIDX_SQL.VERSIONNO	= @PP_NO_VERSION	--	'0016'
		ORDER BY	SPITMIDX_SQL.CUS_NO,
					SPITMIDX_SQL.MODELNO,
					SPITMIDX_SQL.VERSIONNO,
					IT DESC
	OPEN CU_CURSOR
		FETCH NEXT FROM  CU_CURSOR INTO		@VP_CU_ITEM_NO,		@VP_CU_CUS_NO,	@VP_CU_MODELNO,
											@VP_CU_VERSIONNO,	@VP_CU_REVISION,
											--============================
											@VP_CU_K_PROCESO,	@VP_CU_K_PROCESO_SIMBOLO,
											--============================
											@VP_CU_L_HOJA_EMPAQUE_PROCESO,	
											--============================
											@VP_CU_D_PROCESO
		WHILE @@FETCH_STATUS=0
		BEGIN

			DECLARE	@VP_D_PROCESS	NVARCHAR(MAX)	= ''


			SET	@VP_D_PROCESS	= ISNULL(	(	SELECT	TA_D_PROCESO
												FROM	@VP_TA_HOJA_PROCESO
												WHERE	TA_CUS_NO		= @VP_CU_CUS_NO
												AND		TA_MODELNO		= @VP_CU_MODELNO
												--AND		TA_VERSIONNO	= @VP_CU_VERSIONNO
												AND		TA_ITEM_NO		= @VP_CU_ITEM_NO	
												AND		TA_K_PROCESO	= @VP_CU_K_PROCESO	)	,	'' )
			
			IF @VP_D_PROCESS <> ''
			BEGIN
				DECLARE	@VP_L_HOJA_EMPAQUE_PROCESO		INT	= 0
									
				IF (	SELECT	TA_D_PROCESO
						FROM	@VP_TA_HOJA_PROCESO
						WHERE	TA_CUS_NO		= @VP_CU_CUS_NO
						AND		TA_MODELNO		= @VP_CU_MODELNO
						--AND		TA_VERSIONNO	= @VP_CU_VERSIONNO
						AND		TA_ITEM_NO		= @VP_CU_ITEM_NO	
						AND		TA_K_PROCESO	= @VP_CU_K_PROCESO		)	<>	@VP_CU_D_PROCESO
				BEGIN
					
					SET	@VP_CU_D_PROCESO				= @VP_D_PROCESS
				END
				ELSE
				BEGIN
					SET	@VP_L_HOJA_EMPAQUE_PROCESO	= ISNULL(	(	SELECT	TA_L_HOJA_EMPAQUE_PROCESO
																	FROM	@VP_TA_HOJA_PROCESO
																	WHERE	TA_CUS_NO		= @VP_CU_CUS_NO
																	AND		TA_MODELNO		= @VP_CU_MODELNO
																	--AND		TA_VERSIONNO	= @VP_CU_VERSIONNO
																	AND		TA_ITEM_NO		= @VP_CU_ITEM_NO	
																	AND		TA_K_PROCESO	= @VP_CU_K_PROCESO	)	,	0 )
					
					SET	@VP_CU_L_HOJA_EMPAQUE_PROCESO	= @VP_L_HOJA_EMPAQUE_PROCESO
				
				END
			END


					INSERT INTO [HOJA_EMPAQUE_PROCESO] (
								--[K_HOJA_EMPAQUE]					,
								-- ============================
								[ITEM_P]							,
								-- ============================
								[CUS_NO]							,	
								[MODELNO]							,
								[VERSIONNO]							,
								[REVISION_HOJA_EMPAQUE]				,
								-- ============================
								[K_PROCESO]							,
								[K_PROCESO_SIMBOLO]					,
								[L_HOJA_EMPAQUE_PROCESO]			,
								-- ============================
								[D_HOJA_EMPAQUE_PROCESO]			)
					SELECT		@VP_CU_ITEM_NO						,
								-- ============================
								@VP_CU_CUS_NO						,
								@VP_CU_MODELNO						,
								@VP_CU_VERSIONNO					,
								0									,
								-- ============================
								@VP_CU_K_PROCESO					,
								@VP_CU_K_PROCESO_SIMBOLO			,
								@VP_CU_L_HOJA_EMPAQUE_PROCESO		,
								-- ============================
								@VP_CU_D_PROCESO
					IF @@ROWCOUNT = 0
					BEGIN
						SET @VP_MENSAJE = '[INSERT]: No se insertó el registro. [PROC]# '+ @VP_CU_ITEM_NO + ' // ' +  @VP_CU_D_PROCESO + CHAR(13)+CHAR(10) + 'Verifique....'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END

		FETCH NEXT FROM  CU_CURSOR INTO		@VP_CU_ITEM_NO,		@VP_CU_CUS_NO,	@VP_CU_MODELNO,
											@VP_CU_VERSIONNO,	@VP_CU_REVISION,
											--============================
											@VP_CU_K_PROCESO,	@VP_CU_K_PROCESO_SIMBOLO,
											--============================
											@VP_CU_L_HOJA_EMPAQUE_PROCESO,	
											--============================
											@VP_CU_D_PROCESO
		END
	CLOSE		CU_CURSOR
	DEALLOCATE	CU_CURSOR	
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> COPIA LAS IMAGENES DE UNA VERSIÓN A
-- //						OTRA.
-- // SISTEMA DE PRODUCTIVO							20220117
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_COPIAR_IMAGEN_CAPA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_COPIAR_IMAGEN_CAPA]
GO
--		EXECUTE  [dbo].[PG_PR_COPIAR_IMAGEN_CAPA] 	0,139,	'FAUR01','FW2','0011'
--		EXECUTE  [dbo].[PG_PR_COPIAR_IMAGEN_CAPA] 	0,139,	'IRVI02','JLI','0059'		--	PARA PRUEBAS DE ESTE SP
CREATE PROCEDURE [dbo].[PG_PR_COPIAR_IMAGEN_CAPA]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_S_CUSTOMER				VARCHAR(6),
	@PP_S_MODEL					VARCHAR(3),
	@PP_NO_VERSION				INT
AS
DECLARE	 @VP_MENSAJE			NVARCHAR(MAX)

	SELECT	*	
	FROM	HOJA_EMPAQUE_RUTAS_IMAGEN	(NOLOCK)
	WHERE	CUS_NO		= @PP_S_CUSTOMER	
	AND		MODELNO		= @PP_S_MODEL		
	AND		VERSIONNO	= @PP_NO_VERSION

GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> LIMPIA LA TABLA DE LOS REGISTRO RECIEN
-- //						COPIADOS A LA NUEVA VERSIÓN.
-- // SISTEMA DE PRODUCTIVO							20220117
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_LIMPIAR_RUTA_IMAGEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_LIMPIAR_RUTA_IMAGEN]
GO
--		EXECUTE  [dbo].[PG_PR_LIMPIAR_RUTA_IMAGEN] 	0,139,	'FAUR01','FW2','0011'
--		EXECUTE  [dbo].[PG_PR_LIMPIAR_RUTA_IMAGEN] 	0,139,	'IRVI02','JLI','0059'		--	PARA PRUEBAS DE ESTE SP
CREATE PROCEDURE [dbo].[PG_PR_LIMPIAR_RUTA_IMAGEN]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_S_CUSTOMER				VARCHAR(6),
	@PP_S_MODEL					VARCHAR(3),
	@PP_NO_VERSION				INT
AS
DECLARE	 @VP_MENSAJE			NVARCHAR(MAX)

	DELETE	HOJA_EMPAQUE_RUTAS_IMAGEN
	WHERE	CUS_NO		= @PP_S_CUSTOMER	
	AND		MODELNO		= @PP_S_MODEL		
	AND		VERSIONNO	= @PP_NO_VERSION

GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> UPDATE / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	--DROP PROCEDURE [dbo].[PG_INUP_HOJA_EMPAQUE]
	DROP PROCEDURE [dbo].[PG_UP_HOJA_EMPAQUE]
GO
---	PRUEBAS DE U´s
----	EXECUTE  [dbo].[PG_INUP_HOJA_EMPAQUE]	0, 139, '0' , 'MAGN02' , WAL , '14' , 'PWALBR2' , 'M02516-06' , '' , '0' , 3 , 'FALTA QUE SE REFLEN LOS PATRONES CON KUFNER TK1080' , 6 
----	, '1/2/3' , '1/1/1' , '\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\MAGN02\WAL\14\PWALBR2_000_1.PNG/\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\MAGN02\WAL\14\PWALBR2_000_2.PNG/\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\MAGN02\WAL\14\PWALBR2_000_3.PNG' 
----	, '\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\MAGN02\WAL\14\PWALBR2_000_1.PNG/\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\MAGN02\WAL\14\PWALBR2_000_2.PNG/\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\MAGN02\WAL\14\PWALBR2_000_3.PNG' 
----	, '60/61/62' , '449/446/447/448' , '2/3/7/8' , '1/2/0/1' , '1/1/0/1' , 'MULLER 6MM 6035/AXIS II/SHAVING/KUFNER TK 1080 BLACK' 

----	EXECUTE  [dbo].[PG_UP_HOJA_EMPAQUE]	0,139,'0' , 'MAGN03' , 'WD2' , '16' , 'PWDRC60' , 'M02522-05' , '' , '0' , 10 , '' , 3 ,																																		
----	'1/2' , '5/5' , ' / ' , 'P:\Quality\EXCEL AYUDAS VISUALES\IMAGENES\HOJAS DE EMPAQUE SIST\MAGNA\WD\ml\2t jrr - dx9\REAR CUSHION 60% 1.PNG/P:\Quality\EXCEL AYUDAS VISUALES\IMAGENES\HOJAS DE EMPAQUE SIST\MAGNA\WD\ml\2t jrr - dx9\REAR CUSHION 60% 2.PNG' , 
----	'-1/-1' , '1642/1643/-1' , '3/7/50' , '2/0/29' , '1/0/1' , 'AXIS II/SHAVING/COLOR DX9' 

----	EXECUTE  [dbo].[PG_UP_HOJA_EMPAQUE]	0,139,	'0' , 'MAGN02' , 'WAL' , '14' , 'PWALBR2' , 'M02516-06' , '' , '0' , 5 ,																																			
----	'CAMBIO DE INGENIERÍA 17-AGOSTO-2021 SE CORTAN CON ROMA LEATHER LOS INSERT UPPER Y BOLSTERS.' , 6 , '1/2/3' , '2/2/1' , 
----	'\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\MAGN02\WAL\14\PWALBR2_000_1.PNG/\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\MAGN02\WAL\14\PWALBR2_000_2.PNG/\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\MAGN02\WAL\14\PWALBR2_000_3.PNG' , 
----	'\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\MAGN02\WAL\14\PWALBR2_000_1.PNG/\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\MAGN02\WAL\14\PWALBR2_000_2.PNG/\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\MAGN02\WAL\14\PWALBR2_000_3.PNG' , 
----	'60/61/62' , '449/446/447/448' , '2/3/7/8' , '4/2/0/1' , '1/1/0/1' , 'MULLER 6MM 6035/AXIS II/SHAVING/KUFNER TK 1080 BLACK' 

--CREATE PROCEDURE [dbo].[PG_INUP_HOJA_EMPAQUE]
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
DECLARE  @VP_MENSAJE						NVARCHAR(MAX)
		,@VP_CANTIDAD_PATRONES				INT	= 0
		,@VP_CANTIDAD_CAPAS					INT	= 0
		,@VP_L_CAPAS_COMPLETAS				INT	= 0
		,@VP_REVISION_NUEVA_HOJA_EMPAQUE	INT	= @PP_REVISION_HOJA_EMPAQUE + 1 
-- /////////////////////////////////////////////////////////////////////
BEGIN TRANSACTION 
BEGIN TRY
	-- =======================================================================================================================
	--	VALIDACIÓN DE CANTIDAD DE PATRONES EN LA HOJA DE EMPAQUE VS CANTIDAD REGISTRADA EN SISTEMA.
	-- =======================================================================================================================
	--SELECT	TOP (1)
	--		@VP_CANTIDAD_PATRONES			= CANTIDAD_PATRONES
	--FROM	HOJA_EMPAQUE					(NOLOCK)
	--WHERE	CUS_NO							= @PP_CUS_NO	
	--AND		MODELNO							= @PP_MODELNO
	--AND		VERSIONNO						= @PP_VERSIONNO
	---- ============================
	--AND		ITEM_P							= @PP_ITEM_P
	--AND		REVISION_HOJA_EMPAQUE			= @PP_REVISION_HOJA_EMPAQUE

	--IF	(	@VP_CANTIDAD_PATRONES	) <>	@PP_CANTIDAD_PATRONES
	--BEGIN
	--	SET @VP_MENSAJE='La cantidad de patrones ingresada no coincide con la registrada en el sistema. [HE#'+CONVERT(VARCHAR(10),@PP_ITEM_P )+'] (' + CONVERT(VARCHAR(10),@VP_CANTIDAD_PATRONES) + ' // '+ CONVERT(VARCHAR(10),@PP_CANTIDAD_PATRONES) +')'
	--	RAISERROR (@VP_MENSAJE, 16, 1 ) 
	--END

	SET	@VP_CANTIDAD_CAPAS	= (	CASE
										WHEN	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION	IN (1)			THEN	1
										WHEN	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION	IN (2,3)		THEN	2
										WHEN	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION	IN (4,5,6,7)	THEN	3
										WHEN	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION	IN (8)			THEN	4
										ELSE	0
								END )

	
	-- =======================================================================================================================
	--	DECLARACIÓN DE VARIABLES DE USO GENERAL.
	-- =======================================================================================================================	
	DECLARE	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR		AS NVARCHAR(MAX)	=	'\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\'--	'\\10.1.1.5\documents\IT\001_DEVELOPER_FILES\APQP\AV_HE\'
	DECLARE @VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO		AS NVARCHAR(MAX)	=	LTRIM(RTRIM(@PP_CUS_NO)) +'\'+ LTRIM(RTRIM(@PP_MODELNO)) +'\'+ LTRIM(RTRIM(@PP_VERSIONNO)) + '\'
	DECLARE @VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN		AS NVARCHAR(MAX)	=	''
	DECLARE @VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION	AS NVARCHAR(MAX)	=	'.PNG'
	DECLARE	@VP_RUTA_IMAGEN							AS NVARCHAR(MAX)	=	''
	------------------------------------------------------------------------------
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
	-- =================================================			SE ACTUALIZA LA INFORMACIÓN					(INICIO)
	-- =================================================			DEL ENCABEZADO DE LA HOJA DE EMPAQUE.
	-- =======================================================================================================================
	--	SE VERIFICA SI SE CREARÁ UNA NUEVA REVISIÓN DE LA HOJA DE EMPAQUE.
	IF @PP_L_NUEVA_REVISIÓN	= 1
	BEGIN
		IF	(	SELECT	COUNT(K_HOJA_EMPAQUE)--,*	
				FROM	HOJA_EMPAQUE		(NOLOCK)
				WHERE	CUS_NO				=	@PP_CUS_NO		
				AND		MODELNO				=	@PP_MODELNO		
				AND		VERSIONNO			=	@PP_VERSIONNO	
				AND		[ITEM_P]			=	@PP_ITEM_P
				AND		U_ITEM				<> ''		) >= 1	-- ORDER BY VERSIONNO
		BEGIN
		-- =======================================================================================================================
		--	SI ES UN NÚMERO DE PARTE U, REALIZA LA INSERCIÓN ESPECIAL PARA CADA UNO DE LOS COMPONENTES INCLUIDOS.
		-- =======================================================================================================================
			EXECUTE	[dbo].[PG_IN_HOJA_EMPAQUE_U]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
													-- ===========================
													@PP_L_NUEVA_REVISIÓN				,
													-- ============================
													@PP_CUS_NO							,	@PP_MODELNO					,	
													@PP_VERSIONNO						,
													-- ============================
													@PP_ITEM_P							,-- ES EL P DEL ITEM_NO
													-- ============================
													@PP_CAJA_HOJA_EMPAQUE				,	@PP_DIBUJO_HOJA_EMPAQUE		,
													@PP_REVISION_HOJA_EMPAQUE			,
													-- ============================
													-- ============================
													@PP_C_HOJA_EMPAQUE			,
													-- ============================
													@PP_K_HOJA_EMPAQUE_CAPA_DIVISION	,	@VP_CANTIDAD_CAPAS			,
													@VP_REVISION_NUEVA_HOJA_EMPAQUE		
			
		END
		ELSE
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
			--	SE INGRESA LA INFORMACIÓN DE LA NUEVA REVISIÓN DE LA HOJA DE EMPAQUE.
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
					--[CUBE_WIDTH]					,	[CUBE_LENGTH]					,
					[AREA_NETA]						,	[AREA_GROSS]					,
					-- ============================
					[C_HOJA_EMPAQUE]				,	[L_REVISION_ACTIVA]				,
					-- ============================
					[K_HOJA_EMPAQUE_CAPA_DIVISION]	,
					[N_CAPAS]						,	--[L_CAPAS_COMPLETAS]				,
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
					@VP_REVISION_NUEVA_HOJA_EMPAQUE	,
					-- ============================
					[STANDAR_PACK]					,	[CANTIDAD_PATRONES]				,
					--[CUBE_WIDTH]					,	[CUBE_LENGTH]					,
					[AREA_NETA]						,	[AREA_GROSS]					,
					-- ============================
					@PP_C_HOJA_EMPAQUE				,	1								,
					-- ============================
					@PP_K_HOJA_EMPAQUE_CAPA_DIVISION,	
					@VP_CANTIDAD_CAPAS				,	--@VP_L_CAPAS_COMPLETAS
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
				SET @VP_MENSAJE='Registro no fue ingresado.(N)[HE#'+CONVERT(VARCHAR(10),@PP_ITEM_P )+ ' // ' +CONVERT(VARCHAR(10),@VP_REVISION_NUEVA_HOJA_EMPAQUE) + ']'
				RAISERROR (@VP_MENSAJE, 16, 1 ) 
			END
		END

	END
	ELSE
	BEGIN
	-- =======================================================================================================================
		IF	(	SELECT	COUNT(K_HOJA_EMPAQUE)--,*	
				FROM	HOJA_EMPAQUE		(NOLOCK)
				WHERE	CUS_NO				=	@PP_CUS_NO		
				AND		MODELNO				=	@PP_MODELNO		
				AND		VERSIONNO			=	@PP_VERSIONNO	
				AND		[ITEM_P]			=	@PP_ITEM_P
				AND		U_ITEM				<> ''		) >= 1	-- ORDER BY VERSIONNO
		BEGIN
		-- =======================================================================================================================
		--	SI ES UN NÚMERO DE PARTE U, REALIZA LA ACTUALIZACIÓN ESPECIAL PARA CADA UNO DE LOS COMPONENTES INCLUIDOS.
		-- =======================================================================================================================
			EXECUTE	[dbo].[PG_UP_HOJA_EMPAQUE_U]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
													-- ===========================
													@PP_L_NUEVA_REVISIÓN				,
													-- ============================
													@PP_CUS_NO							,	@PP_MODELNO					,	
													@PP_VERSIONNO						,
													-- ============================
													@PP_ITEM_P							,-- ES EL P DEL ITEM_NO
													-- ============================
													@PP_CAJA_HOJA_EMPAQUE				,	@PP_DIBUJO_HOJA_EMPAQUE		,
													@PP_REVISION_HOJA_EMPAQUE			,
													-- ============================
													@PP_CANTIDAD_PATRONES				,
													-- ============================
													@PP_C_HOJA_EMPAQUE					,
													-- ============================
													@PP_K_HOJA_EMPAQUE_CAPA_DIVISION	,	@VP_CANTIDAD_CAPAS			,
													@VP_REVISION_NUEVA_HOJA_EMPAQUE		
			
		END
		ELSE
		BEGIN
			-- =======================================================================================================================
			--	SE ACTUALIZA LA INFORMACIÓN DE LA HOJA DE EMPAQUE
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
					[N_CAPAS]						= @VP_CANTIDAD_CAPAS				,
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
	END

	-- =======================================================================================================================
	-- =================================================			SE ACTUALIZA LA INFORMACIÓN					(FIN)
	-- =================================================			DEL ENCABEZADO DE LA HOJA DE EMPAQUE.
	-- =======================================================================================================================

		
	-- =======================================================================================================================
	-- =================================================			ACTUALIZAR LA INFORMACIÓN CORRESPONDIENTE	(INICIO)
	-- =================================================			A LAS CAPAS DE LAS IMAGENES
	-- =======================================================================================================================
	DECLARE  @VP_CU_ITEM_P			VARCHAR(250)	= ''
			,@VP_CU_U_ITEM			VARCHAR(250)	= ''
			,@VP_L_CAMBIO			INTEGER			= 0
	
	
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
			--	SE VERIFICA SI SE DESEA CREAR UNA NUEVA VERSIÓN DE LA HOJA DE EMPAQUE.
			--========================================================================================================================================
			IF @PP_L_NUEVA_REVISIÓN	= 0
			BEGIN
			-- ===============================================================================================================================================
			-- ===============================================================================================================================================
			--	SI YA EXISTÍA LA CAPA REALIZA UNA ACTUALIZACIÓN CON LA INFORMACIÓN RECIBIDA.
			-- ===============================================================================================================================================
				IF	@VP_VALOR_K_HOJA	>  0
				--***********************************************************************************************
				BEGIN
					-- =======================================================================================================================
					--	VERIFICA SI PERTENECE A UN NÚMERO U PARA REALIZAR LA ACTUALIZACIÓN ESPECIAL.
					-- =======================================================================================================================
					IF	(	SELECT	COUNT(K_HOJA_EMPAQUE)--,*	
							FROM	HOJA_EMPAQUE		(NOLOCK)
							WHERE	CUS_NO				=	@PP_CUS_NO		
							AND		MODELNO				=	@PP_MODELNO		
							AND		VERSIONNO			=	@PP_VERSIONNO	
							AND		[ITEM_P]			=	@PP_ITEM_P
							AND		U_ITEM				<> ''		) >= 1	-- ORDER BY VERSIONNO
					BEGIN
						DECLARE CU_CURSOR_U_ITEM	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
								SELECT	DISTINCT(ITEM_P)	--	K_HOJA_EMPAQUE
										,U_ITEM
								FROM	HOJA_EMPAQUE		(NOLOCK)
								WHERE	CUS_NO				=	@PP_CUS_NO			--	'MAGN02'	--
								AND		MODELNO				=	@PP_MODELNO			--	'WAL'		--
								AND		VERSIONNO			=	@PP_VERSIONNO		--	 (0014)	--
								---AND		U_ITEM				<> ''
								AND		[U_ITEM]			IN (	SELECT	DISTINCT(U_ITEM) 
																	FROM	HOJA_EMPAQUE 
																	WHERE	CUS_NO				=  @PP_CUS_NO			--	'MAGN02'	--
																	AND		MODELNO				=  @PP_MODELNO			--	'WAL'		--
																	AND		VERSIONNO			=  @PP_VERSIONNO		--	 (0014)	--
																	AND		ITEM_P				=  @PP_ITEM_P			--	'PWALBRR' --
																)
						OPEN CU_CURSOR_U_ITEM
						FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_ITEM_P, @VP_CU_U_ITEM
						WHILE @@FETCH_STATUS=0
						BEGIN

							IF (	SELECT	COUNT(K_HOJA_EMPAQUE_CAPA)
									FROM	HOJA_EMPAQUE_CAPA
									WHERE	CUS_NO				=	@PP_CUS_NO			
									AND		MODELNO				=	@PP_MODELNO			
									AND		VERSIONNO			=	@PP_VERSIONNO		
									AND		ITEM_P				=	@VP_CU_ITEM_P			
									AND		N_CAPA				=	@VP_VALOR_N_CAPA	) >= 1
							BEGIN
								-- =======================================================================================================================
								--	ACTUALIZA LA INFORMACIÓN DE LAS CAPAS.
								-- =======================================================================================================================
								UPDATE	[HOJA_EMPAQUE_CAPA]
								SET		-- ========================== 
										--[N_CAPA]					= @VP_VALOR_N_CAPA,
										[N_PATRONES_CAPA]			= @VP_VALOR_N_PATR
										-- ========================== 
								--WHERE	K_HOJA_EMPAQUE_CAPA			= @VP_VALOR_K_HOJA
								WHERE	CUS_NO				=	@PP_CUS_NO			--	'MAGN02'	--
								AND		MODELNO				=	@PP_MODELNO			--	'WAL'		--
								AND		VERSIONNO			=	@PP_VERSIONNO		--	 (0014)	--
								AND		ITEM_P				=	@VP_CU_ITEM_P		--	'PWALBRR' --
								AND		N_CAPA				=	@VP_VALOR_N_CAPA

								IF @@ROWCOUNT = 0
								BEGIN
									SET @VP_MENSAJE='El registro no fue actualizado. [KHEU# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'//'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
									RAISERROR (@VP_MENSAJE, 16, 1 ) 
								END
							END
							ELSE
							BEGIN						
							------------------------------------------------------------------------------------------------------------------------------------------
								INSERT INTO [HOJA_EMPAQUE_CAPA]
									(	[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]	,
										-- ============================	
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
										[RUTA_HOJA_EMPAQUE_CAPA_EXTENSION]	,
										-- ============================	
										[K_USUARIO_ALTA]				,	[F_ALTA]			,
										[K_USUARIO_CAMBIO]				,	[F_CAMBIO]			)
								SELECT	@VP_CU_U_ITEM	+'_'+FORMAT(@PP_REVISION_HOJA_EMPAQUE,'000') +'_'+ CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA) ,
										--@VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	 ,
										-- ============================	
										@PP_CUS_NO						,	@PP_MODELNO			,	
										@PP_VERSIONNO					,
										-- ============================	
										@VP_CU_ITEM_P					,	@PP_REVISION_HOJA_EMPAQUE		,
										-- ============================	
										@VP_VALOR_N_CAPA				,	@VP_VALOR_N_PATR	,
										-- ============================	
										--@VP_RUTA_IMAGEN					,
										@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	 ,
										@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO	 ,
										@VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION ,
										-- ============================	
										@PP_K_USUARIO_ACCION			,	GETDATE()			,
										@PP_K_USUARIO_ACCION			,	GETDATE()
								IF @@ROWCOUNT = 0
								BEGIN
									SET @VP_MENSAJE='La información de la capa no fue ingresada. [CAPAU#'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
									RAISERROR (@VP_MENSAJE, 16, 1 )
								END
							END

						
							--	SI LA RUTA ORIGEN Y LA RUTA NUEVA SON IGUALES, ES POR QUE NO SUFRIÓ CAMBIOS EL REGISTRO EN LO QUE SE REFIERE A LA IMAGEN DE LA CAPA.
							IF @VP_VALOR_RUTA_C	<>	@VP_VALOR_RUTA_N
							BEGIN
								SET @VP_L_CAMBIO	= 1
							END

							INSERT INTO @VP_TA_RUTAS_IMAGEN
							(		 TA_RUTA_SERVR		,TA_RUTA_LOCAL		
									,TA_CREAR_CARP		,TA_L_CAMBIO	,MENSAJE	)
							SELECT	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR		+	
									@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO		+
									@VP_CU_U_ITEM	+ '_' + FORMAT(@PP_REVISION_HOJA_EMPAQUE,'000') + '_' + CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA) +										
									@VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION
									,@VP_VALOR_RUTA_N	,@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO
									,1					,''
							IF @@ROWCOUNT = 0
							BEGIN
								SET @VP_MENSAJE='El registro de la ruta no fue ingresado. [KHEU# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'-'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
								RAISERROR (@VP_MENSAJE, 16, 1 ) 
							END				  
							
						FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_ITEM_P, @VP_CU_U_ITEM
						END
						CLOSE		CU_CURSOR_U_ITEM
						DEALLOCATE	CU_CURSOR_U_ITEM
																		
					END
					ELSE
					-- =======================================================================================================================
					--	SI NO PERTENECE A UN NÚMERO U, ACTUALIZA SÓLO LOS KITS QUE LO COMPONEN.
					-- =======================================================================================================================
					BEGIN
						
						UPDATE	[HOJA_EMPAQUE_CAPA]
						SET		-- ========================== 
								--[N_CAPA]					= @VP_VALOR_N_CAPA,
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
				END
				--***********************************************************************************************
				ELSE
				-- ===============================================================================================================================================
			--	SI NO EXISTE LA CAPA REALIZA UNA ACTUALIZACIÓN CON LA INFORMACIÓN RECIBIDA.
			-- ===============================================================================================================================================
				--***********************************************************************************************
				BEGIN
					-- ==========================================================================================
					-- PARA LOS KITS QUE PERTENECEN A UN U
					-- ==========================================================================================
					IF	(	SELECT	COUNT(K_HOJA_EMPAQUE)--,*	
							FROM	HOJA_EMPAQUE		(NOLOCK)
							WHERE	CUS_NO				=	@PP_CUS_NO		
							AND		MODELNO				=	@PP_MODELNO		
							AND		VERSIONNO			=	@PP_VERSIONNO	
							AND		[ITEM_P]			=	@PP_ITEM_P
							AND		U_ITEM				<> ''		) >= 1	-- ORDER BY VERSIONNO
					BEGIN
						DECLARE CU_CURSOR_U_ITEM	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
							SELECT	DISTINCT(ITEM_P)	--	K_HOJA_EMPAQUE
							FROM	HOJA_EMPAQUE		(NOLOCK)
							WHERE	CUS_NO				=	@PP_CUS_NO			--	'MAGN02'	--
							AND		MODELNO				=	@PP_MODELNO			--	'WAL'		--
							AND		VERSIONNO			=	@PP_VERSIONNO		--	 (0014)	--
							---AND		U_ITEM				<> ''
							AND		[U_ITEM]			IN (	SELECT	DISTINCT(U_ITEM) 
																FROM	HOJA_EMPAQUE 
																WHERE	CUS_NO				=  @PP_CUS_NO			--	'MAGN02'	--
																AND		MODELNO				=  @PP_MODELNO			--	'WAL'		--
																AND		VERSIONNO			=  @PP_VERSIONNO		--	 (0014)	--
																AND		ITEM_P				=  @PP_ITEM_P			--	'PWALBRR' --
																)
						OPEN CU_CURSOR_U_ITEM
						FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_ITEM_P
						WHILE @@FETCH_STATUS=0
						BEGIN

						--SET @VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	=	LTRIM(RTRIM(@PP_ITEM_P)) +'_'+FORMAT(@PP_REVISION_HOJA_EMPAQUE,'000') +'_'+ CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)
									
						--SET	@VP_RUTA_IMAGEN	=	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO		+
						--						@VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION
						-----------------------------------------------------------------------------------------------------------------------------------------
						DECLARE @TA_U_ITEMS_X_P	AS TABLE (	TA_U_ITEM		NVARCHAR(MAX)	)

						INSERT INTO	@TA_U_ITEMS_X_P
						(	TA_U_ITEM	)
						SELECT DISTINCT(U_ITEM) 
						FROM	HOJA_EMPAQUE		(NOLOCK)
						WHERE	CUS_NO				=	@PP_CUS_NO	
						AND		MODELNO				=	@PP_MODELNO	
						AND		VERSIONNO			=	@PP_VERSIONNO
						AND		ITEM_P				IN	(	SELECT	DISTINCT(ITEM_P)	--	K_HOJA_EMPAQUE		
															FROM	HOJA_EMPAQUE		(NOLOCK)
															WHERE	CUS_NO				=	@PP_CUS_NO	
															AND		MODELNO				=	@PP_MODELNO	
															AND		VERSIONNO			=	@PP_VERSIONNO
															---AND		U_ITEM				<> ''
															AND		[U_ITEM]			IN (	SELECT	DISTINCT(U_ITEM) 
																								FROM	HOJA_EMPAQUE 
																								WHERE	CUS_NO				=  @PP_CUS_NO	
																								AND		MODELNO				=  @PP_MODELNO	
																								AND		VERSIONNO			=  @PP_VERSIONNO
																								AND		ITEM_P				=  @VP_CU_ITEM_P	)	)
						------------------------------------------------------------------------------------------------------------------------------------------
							INSERT INTO [HOJA_EMPAQUE_CAPA]
								(	[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]	,
									-- ============================	
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
									[RUTA_HOJA_EMPAQUE_CAPA_EXTENSION]	,
									-- ============================	
									[K_USUARIO_ALTA]				,	[F_ALTA]			,
									[K_USUARIO_CAMBIO]				,	[F_CAMBIO]			)
							SELECT	TA_U_ITEM	+'_'+FORMAT(@PP_REVISION_HOJA_EMPAQUE,'000') +'_'+ CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA) ,
								--@VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	 ,
								-- ============================	
								@PP_CUS_NO						,	@PP_MODELNO			,	
								@PP_VERSIONNO					,
								-- ============================	
								@VP_CU_ITEM_P					,	@PP_REVISION_HOJA_EMPAQUE		,
								-- ============================	
								@VP_VALOR_N_CAPA				,	@VP_VALOR_N_PATR	,
								-- ============================	
								--@VP_RUTA_IMAGEN					,
								@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	 ,
								@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO	 ,
								@VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION ,
								-- ============================	
								@PP_K_USUARIO_ACCION			,	GETDATE()			,
								@PP_K_USUARIO_ACCION			,	GETDATE()
							FROM	@TA_U_ITEMS_X_P
							IF @@ROWCOUNT = 0
							BEGIN
								SET @VP_MENSAJE='La información de la capa no fue ingresada. [CAPAU#'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
								RAISERROR (@VP_MENSAJE, 16, 1 )
							END

							INSERT INTO @VP_TA_RUTAS_IMAGEN
							(		 TA_RUTA_SERVR		,TA_RUTA_LOCAL		
									,TA_CREAR_CARP		,TA_L_CAMBIO	,MENSAJE	)
							SELECT	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR		+	
									@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO		+
									TA_U_ITEM	+ '_' + FORMAT(@PP_REVISION_HOJA_EMPAQUE,'000') + '_' + CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA) +										
									@VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION
									,@VP_VALOR_RUTA_N	,@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO
									,1					,''
							FROM	@TA_U_ITEMS_X_P
							IF @@ROWCOUNT = 0
							BEGIN
								SET @VP_MENSAJE='El registro de la ruta no fue ingresado. [KHEU# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'-'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
								RAISERROR (@VP_MENSAJE, 16, 1 ) 
							END

						FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_ITEM_P
						END
						CLOSE		CU_CURSOR_U_ITEM
						DEALLOCATE	CU_CURSOR_U_ITEM

					END
					--*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
					ELSE
					--*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
					-- PARA LOS KITS QUE NO SON Us
					-- ==========================================================================================
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
					--*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
				END
				--***********************************************************************************************						
				-- ===============================================================================================================================================
				-- ===============================================================================================================================================
				INSERT INTO @VP_TA_CAPAS_INCLUIDAS
				VALUES	( @VP_VALOR_N_CAPA )
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE='CAPA NO INSERTADA'
					RAISERROR (@VP_MENSAJE, 16, 1 ) 
				END	
				-- ===============================================================================================================================================
				-- ===============================================================================================================================================
				-- ===============================================================================================================================================
			END
			-- ===============================================================================================================================================
			-- ===============================================================================================================================================
			-- ===============================================================================================================================================
			ELSE	-- SI EL KIT SÓLO SE ACTUALIZA Y NO SE DESEA GENERAR UNA NUEVA REVISIÓN. IF @PP_L_NUEVA_REVISIÓN	= 1
			BEGIN
			--***********************************************************************************************
				--	PARA LOS KIT QUE PERTENECEN A UN NÚMERO U
				IF	(	SELECT	COUNT(K_HOJA_EMPAQUE)--,*	
						FROM	HOJA_EMPAQUE		(NOLOCK)
						WHERE	CUS_NO				=	@PP_CUS_NO		
						AND		MODELNO				=	@PP_MODELNO		
						AND		VERSIONNO			=	@PP_VERSIONNO	
						AND		[ITEM_P]			=	@PP_ITEM_P
						AND		U_ITEM				<> ''		) >= 1	-- ORDER BY VERSIONNO
				BEGIN
					DECLARE CU_CURSOR_U_ITEM	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
						SELECT	DISTINCT(ITEM_P)	--	K_HOJA_EMPAQUE
						FROM	HOJA_EMPAQUE		(NOLOCK)
						WHERE	CUS_NO				=	@PP_CUS_NO			--	'MAGN02'	--
						AND		MODELNO				=	@PP_MODELNO			--	'WAL'		--
						AND		VERSIONNO			=	@PP_VERSIONNO		--	 (0014)	--
						---AND		U_ITEM				<> ''
						AND		[U_ITEM]			IN (	SELECT	DISTINCT(U_ITEM) 
															FROM	HOJA_EMPAQUE 
															WHERE	CUS_NO				=  @PP_CUS_NO			--	'MAGN02'	--
															AND		MODELNO				=  @PP_MODELNO			--	'WAL'		--
															AND		VERSIONNO			=  @PP_VERSIONNO		--	 (0014)	--
															AND		ITEM_P				=  @PP_ITEM_P			--	'PWALBRR' --
															)
					OPEN CU_CURSOR_U_ITEM
					FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_ITEM_P
					WHILE @@FETCH_STATUS=0
					BEGIN

					--SET @VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	=	LTRIM(RTRIM(@PP_ITEM_P)) +'_'+FORMAT(@PP_REVISION_HOJA_EMPAQUE,'000') +'_'+ CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)
									
					--SET	@VP_RUTA_IMAGEN	=	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO		+
					--						@VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION
					-----------------------------------------------------------------------------------------------------------------------------------------
					DECLARE @TA_U_ITEMS		AS TABLE (	TA_U_ITEM		NVARCHAR(MAX)	)

					INSERT INTO	@TA_U_ITEMS
					(	TA_U_ITEM	)
					SELECT DISTINCT(U_ITEM) 
					FROM	HOJA_EMPAQUE		(NOLOCK)
					WHERE	CUS_NO				=	@PP_CUS_NO	
					AND		MODELNO				=	@PP_MODELNO	
					AND		VERSIONNO			=	@PP_VERSIONNO
					AND		ITEM_P				IN	(	SELECT	DISTINCT(ITEM_P)	--	K_HOJA_EMPAQUE		
														FROM	HOJA_EMPAQUE		(NOLOCK)
														WHERE	CUS_NO				=	@PP_CUS_NO	
														AND		MODELNO				=	@PP_MODELNO	
														AND		VERSIONNO			=	@PP_VERSIONNO
														---AND		U_ITEM				<> ''
														AND		[U_ITEM]			IN (	SELECT	DISTINCT(U_ITEM) 
																							FROM	HOJA_EMPAQUE 
																							WHERE	CUS_NO				=  @PP_CUS_NO	
																							AND		MODELNO				=  @PP_MODELNO	
																							AND		VERSIONNO			=  @PP_VERSIONNO
																							AND		ITEM_P				=  @VP_CU_ITEM_P	)	)
					------------------------------------------------------------------------------------------------------------------------------------------
						INSERT INTO [HOJA_EMPAQUE_CAPA]
							(	[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]	,
								-- ============================	
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
								[RUTA_HOJA_EMPAQUE_CAPA_EXTENSION]	,
								-- ============================	
								[K_USUARIO_ALTA]				,	[F_ALTA]			,
								[K_USUARIO_CAMBIO]				,	[F_CAMBIO]			)
						SELECT	TA_U_ITEM	+'_'+FORMAT(@PP_REVISION_HOJA_EMPAQUE,'000') +'_'+ CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA) ,
							--@VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	 ,
							-- ============================	
							@PP_CUS_NO						,	@PP_MODELNO			,	
							@PP_VERSIONNO					,
							-- ============================	
							@VP_CU_ITEM_P					,	@VP_REVISION_NUEVA_HOJA_EMPAQUE		,
							-- ============================	
							@VP_VALOR_N_CAPA				,	@VP_VALOR_N_PATR	,
							-- ============================	
							--@VP_RUTA_IMAGEN					,
							@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	 ,
							@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO	 ,
							@VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION ,
							-- ============================	
							@PP_K_USUARIO_ACCION			,	GETDATE()			,
							@PP_K_USUARIO_ACCION			,	GETDATE()
						FROM	@TA_U_ITEMS
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='La información de la capa no fue ingresada. [CAPAU#'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 )
						END

						INSERT INTO @VP_TA_RUTAS_IMAGEN
						(		 TA_RUTA_SERVR		,TA_RUTA_LOCAL		
								,TA_CREAR_CARP		,TA_L_CAMBIO	,MENSAJE	)
						SELECT	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR		+	
								@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO		+
								TA_U_ITEM	+ '_' + FORMAT(@PP_REVISION_HOJA_EMPAQUE,'000') + '_' + CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA) +										
								@VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION
								,@VP_VALOR_RUTA_N	,@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO
								,1					,''
						FROM	@TA_U_ITEMS
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El registro de la ruta no fue ingresado. [KHEU# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'-'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END

					FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_ITEM_P
					END
					CLOSE		CU_CURSOR_U_ITEM
					DEALLOCATE	CU_CURSOR_U_ITEM

				END
				ELSE
				BEGIN
					-- PARA LOS KITS QUE NO SON Us
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
							@PP_ITEM_P						,	@VP_REVISION_NUEVA_HOJA_EMPAQUE		,
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
			--***********************************************************************************************
			-- ===============================================================================================================================================
			-- ===============================================================================================================================================
			INSERT INTO @VP_TA_CAPAS_INCLUIDAS
			VALUES	( @VP_VALOR_N_CAPA )
			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='CAPA NO INSERTADA'
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
	--	AQUÍ SE ELIMINAN LOS REGISTROS DE LAS CAPAS QUE YA NO SE INCLUIRÁN EN LA HOJA DE EMPAQUE EN CASO DE QUE SE LE REDUZCA LA CANTIDAD DE LAS MISMAS.
	-- ========================================================================================================================================================================
	-- ========================================================================================================================================================================
	IF @PP_L_NUEVA_REVISIÓN	= 0
	BEGIN
		-- SE VERIFICA SI PERTENECE A UN NÚMERO U
		IF	(	SELECT	COUNT(K_HOJA_EMPAQUE)--,*	
							FROM	HOJA_EMPAQUE		(NOLOCK)
							WHERE	CUS_NO				=	@PP_CUS_NO		
							AND		MODELNO				=	@PP_MODELNO		
							AND		VERSIONNO			=	@PP_VERSIONNO	
							AND		[ITEM_P]			=	@PP_ITEM_P
							AND		U_ITEM				<> ''		) >= 1	-- ORDER BY VERSIONNO
		BEGIN

			DELETE	[HOJA_EMPAQUE_CAPA]
			WHERE	[CUS_NO]					= @PP_CUS_NO 
			AND		[MODELNO]					= @PP_MODELNO
			AND		[VERSIONNO]					= @PP_VERSIONNO
			-- ============================
			AND		[ITEM_P]					IN	(	SELECT	DISTINCT(ITEM_P)	--	K_HOJA_EMPAQUE		
														FROM	HOJA_EMPAQUE		(NOLOCK)
														WHERE	CUS_NO				=	@PP_CUS_NO	
														AND		MODELNO				=	@PP_MODELNO	
														AND		VERSIONNO			=	@PP_VERSIONNO
														AND		[U_ITEM]			IN (	SELECT	DISTINCT(U_ITEM) 
																							FROM	HOJA_EMPAQUE 
																							WHERE	CUS_NO				=  @PP_CUS_NO	
																							AND		MODELNO				=  @PP_MODELNO	
																							AND		VERSIONNO			=  @PP_VERSIONNO
																							AND		ITEM_P				=  @VP_CU_ITEM_P	)	)
					-- ============================
			AND		[REVISION_HOJA_EMPAQUE]			= @PP_REVISION_HOJA_EMPAQUE
			AND		[N_CAPA]						NOT IN (	SELECT	TA_N_CAPA 
															FROM	@VP_TA_CAPAS_INCLUIDAS	)
		END
		ELSE
		--	PARA LOS KIT QUE NO CORRESPONDEN A UN NÚMERO U
		BEGIN		
			--SELECT  FROM @VP_TA_CAPAS_INCLUIDAS
			DELETE	[HOJA_EMPAQUE_CAPA]
			WHERE	[CUS_NO]					= @PP_CUS_NO 
			AND		[MODELNO]					= @PP_MODELNO
			AND		[VERSIONNO]					= @PP_VERSIONNO
					-- ============================
			AND		[ITEM_P]					= @PP_ITEM_P
					-- ============================
			AND		[REVISION_HOJA_EMPAQUE]		= @PP_REVISION_HOJA_EMPAQUE
					-- ============================
			AND		[N_CAPA]			NOT IN (	SELECT	TA_N_CAPA 
													FROM	@VP_TA_CAPAS_INCLUIDAS	)
		END
	END
	-- ========================================================================================================================================================================
	-- ========================================================================================================================================================================
	--	PARA REALIZAR LA ACTUALIZACIÓN DE LOS PROCESOS DE LAS HOJAS DE EMPAQUE DE LOS KITS.
	EXECUTE [dbo].[PG_INUP_HOJA_EMPAQUE_PROCESO_U]	@PP_K_SISTEMA_EXE			,	@PP_K_USUARIO_ACCION	,
													@PP_L_NUEVA_REVISIÓN		,
													-- ============================
													@PP_CUS_NO					,	@PP_MODELNO				,
													@PP_VERSIONNO				,	@PP_ITEM_P				,
													@PP_REVISION_HOJA_EMPAQUE	,
													---- ===========================
													@PP_ARRAY_K_HE_PROC			,
													@PP_ARRAY_K_PROCESO			,	@PP_ARRAY_K_P_SIMBO		,
													@PP_ARRAY_L_PROCESO			,	@PP_ARRAY_D_PROCESO

	-- ========================================================================================================================================================================
	-- ========================================================================================================================================================================
	-- ========================================================================================================================================================================
				--	PARA LOS KIT QUE PERTENECEN A UN NÚMERO U
				IF	(	SELECT	COUNT(K_HOJA_EMPAQUE)--,*	
						FROM	HOJA_EMPAQUE		(NOLOCK)
						WHERE	CUS_NO				=	@PP_CUS_NO		
						AND		MODELNO				=	@PP_MODELNO		
						AND		VERSIONNO			=	@PP_VERSIONNO	
						AND		[ITEM_P]			=	@PP_ITEM_P
						AND		U_ITEM				<> ''		) >= 1	-- ORDER BY VERSIONNO
				BEGIN
					DECLARE CU_CURSOR_U_ITEM	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
						SELECT	DISTINCT(ITEM_P)	--	K_HOJA_EMPAQUE
						FROM	HOJA_EMPAQUE		(NOLOCK)
						WHERE	CUS_NO				=	@PP_CUS_NO			--	'MAGN02'	--
						AND		MODELNO				=	@PP_MODELNO			--	'WAL'		--
						AND		VERSIONNO			=	@PP_VERSIONNO		--	 (0014)	--
						---AND		U_ITEM				<> ''
						AND		[U_ITEM]			IN (	SELECT	DISTINCT(U_ITEM) 
															FROM	HOJA_EMPAQUE 
															WHERE	CUS_NO				=  @PP_CUS_NO			--	'MAGN02'	--
															AND		MODELNO				=  @PP_MODELNO			--	'WAL'		--
															AND		VERSIONNO			=  @PP_VERSIONNO		--	 (0014)	--
															AND		ITEM_P				=  @PP_ITEM_P			--	'PWALBRR' --
															)
					OPEN CU_CURSOR_U_ITEM
					FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_ITEM_P
					WHILE @@FETCH_STATUS=0
					BEGIN	

						--	PARA INDICAR QUE SE HAN CARGADO TODAS LAS IMAGENES DE CADA UNA DE LAS CAPAS, ESTE CAMPO LO USARÁ FEG EN SUS PANTALLAS.														
						IF	@VP_CANTIDAD_CAPAS	= (	SELECT	COUNT(K_HOJA_EMPAQUE_CAPA)
													FROM	[HOJA_EMPAQUE_CAPA]
													WHERE	[CUS_NO]						= @PP_CUS_NO 
													AND		[MODELNO]						= @PP_MODELNO
													AND		[VERSIONNO]						= @PP_VERSIONNO
															-- ============================
													AND		[ITEM_P]						= @VP_CU_ITEM_P	--@PP_ITEM_P
													AND		[REVISION_HOJA_EMPAQUE]			= @PP_REVISION_HOJA_EMPAQUE
													AND		[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]	<> ''	)
						BEGIN
							SET		@VP_L_CAPAS_COMPLETAS	= 1
						END

						UPDATE	[HOJA_EMPAQUE]
						SET		[L_CAPAS_COMPLETAS]		= @VP_L_CAPAS_COMPLETAS
								-- ============================
						WHERE	CUS_NO					= @PP_CUS_NO
						AND		MODELNO					= @PP_MODELNO
						AND		VERSIONNO				= @PP_VERSIONNO
						AND		ITEM_P					= @VP_CU_ITEM_P	--@PP_ITEM_P
						AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='Registro no fue ingresado.(L_CAPAS)[HE#' + CONVERT(VARCHAR(10),@PP_ITEM_P ) + ']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END

					FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_ITEM_P
					END
					CLOSE		CU_CURSOR_U_ITEM
					DEALLOCATE	CU_CURSOR_U_ITEM

				END
				ELSE
				BEGIN
					--	PARA INDICAR QUE SE HAN CARGADO TODAS LAS IMAGENES DE CADA UNA DE LAS CAPAS, ESTE CAMPO LO USARÁ FEG EN SUS PANTALLAS.														
					IF	@VP_CANTIDAD_CAPAS	= (	SELECT	COUNT(K_HOJA_EMPAQUE_CAPA)
												FROM	[HOJA_EMPAQUE_CAPA]
												WHERE	[CUS_NO]						= @PP_CUS_NO 
												AND		[MODELNO]						= @PP_MODELNO
												AND		[VERSIONNO]						= @PP_VERSIONNO
														-- ============================
												AND		[ITEM_P]						= @PP_ITEM_P
												AND		[REVISION_HOJA_EMPAQUE]			= @PP_REVISION_HOJA_EMPAQUE
												AND		[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]	<> ''	)
					BEGIN
						SET		@VP_L_CAPAS_COMPLETAS	= 1
					END

						UPDATE	[HOJA_EMPAQUE]
						SET		[L_CAPAS_COMPLETAS]		= @VP_L_CAPAS_COMPLETAS
								-- ============================
						WHERE	CUS_NO					= @PP_CUS_NO
						AND		MODELNO					= @PP_MODELNO
						AND		VERSIONNO				= @PP_VERSIONNO
						AND		ITEM_P					= @PP_ITEM_P
						AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='Registro no fue ingresado.(L_CAPAS)[HE#' + CONVERT(VARCHAR(10),@PP_ITEM_P ) + ']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END
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
		SET	@VP_MENSAJE = 'No es posible [Actualizar] la [Hoja de Empaque]: ' + @VP_MENSAJE
		SET	@VP_MENSAJE +=	@PP_L_NUEVA_REVISIÓN					+ '*-*'
						-- ============================
		SET	@VP_MENSAJE +=	@PP_CUS_NO								+ '*-*'
		SET	@VP_MENSAJE +=	@PP_MODELNO								+ '*-*'
		SET	@VP_MENSAJE +=	@PP_VERSIONNO							+ '*-*'
						-- ============================
		SET	@VP_MENSAJE +=	@PP_ITEM_P								+ '*-*'
						-- ============================
		SET	@VP_MENSAJE +=	@PP_CAJA_HOJA_EMPAQUE					+ '*-*'
		SET	@VP_MENSAJE +=	@PP_DIBUJO_HOJA_EMPAQUE					+ '*-*'
		SET	@VP_MENSAJE +=	@PP_REVISION_HOJA_EMPAQUE				+ '*-*'
						-- ============================
		SET	@VP_MENSAJE +=	@PP_CANTIDAD_PATRONES					+ '*-*'
						-- ============================
		SET	@VP_MENSAJE +=	@PP_C_HOJA_EMPAQUE						+ '*-*'
						-- ============================
		SET	@VP_MENSAJE +=	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION		+ '*-*'
						-- ============================
		SET	@VP_MENSAJE +=	@PP_ARRAY_N_CAPA						+ '*-*'
		SET	@VP_MENSAJE +=	@PP_ARRAY_N_PATR						+ '*-*'
		SET	@VP_MENSAJE +=	@PP_ARRAY_RUTA_C						+ '*-*'
		SET	@VP_MENSAJE +=	@PP_ARRAY_RUTA_N						+ '*-*'
		SET	@VP_MENSAJE +=	@PP_ARRAY_K_HOJA						+ '*-*'
						-- ============================
		SET	@VP_MENSAJE +=	@PP_ARRAY_K_HE_PROC						+ '*-*'
		SET	@VP_MENSAJE +=	@PP_ARRAY_K_PROCESO						+ '*-*'
		SET	@VP_MENSAJE +=	@PP_ARRAY_K_P_SIMBO						+ '*-*'
		SET	@VP_MENSAJE +=	@PP_ARRAY_L_PROCESO						+ '*-*'
		SET	@VP_MENSAJE +=	@PP_ARRAY_D_PROCESO						+ '*-*'

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
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_HOJA_EMPAQUE_U]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_HOJA_EMPAQUE_U]
GO
--		 EXECUTE [dbo].[PG_IN_HOJA_EMPAQUE_U]	0, 139,	'1' , 'MAGN02' , 'WAL' , '14' , 'PWALBRR' , 'P133124' , '' , '0' , '' , 3,2,0
--		 EXECUTE [dbo].[PG_IN_HOJA_EMPAQUE_U]	0, 139,	'1' , 'MAGN02' , 'WAL' , '14' , 'PWALBR2' , 'P133124' , '' , '0' , '' , 3,2,0
CREATE PROCEDURE [dbo].[PG_IN_HOJA_EMPAQUE_U]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
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
	-- ============================
	@PP_C_HOJA_EMPAQUE					NVARCHAR(MAX),
	-- ============================
	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION	INT,
	@PP_CANTIDAD_CAPAS					INT,
	@PP_REVISION_NUEVA_HOJA_EMPAQUE		INT
	---- ============================---- ============================
	---- ============================---- ============================
	---- ============================---- ============================
AS			
DECLARE  @VP_MENSAJE					NVARCHAR(MAX)
		,@VP_CU_K_HOJA_EMPAQUE			INT

DECLARE CU_CURSOR_U_ITEM	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR

		SELECT	K_HOJA_EMPAQUE
		FROM	HOJA_EMPAQUE		(NOLOCK)
		WHERE	CUS_NO				=	@PP_CUS_NO			--	'MAGN02'	--
		AND		MODELNO				=	@PP_MODELNO			--	'WAL'		--
		AND		VERSIONNO			=	@PP_VERSIONNO		--	 (0014)	--
		---AND		U_ITEM				<> ''
		AND		[U_ITEM]			IN (	SELECT	DISTINCT(U_ITEM) 
											FROM	HOJA_EMPAQUE 
											WHERE	CUS_NO				=  @PP_CUS_NO			--	'MAGN02'	--
											AND		MODELNO				=  @PP_MODELNO			--	'WAL'		--
											AND		VERSIONNO			=  @PP_VERSIONNO		--	 (0014)	--
											AND		ITEM_P				=  @PP_ITEM_P			--	'PWALBRR' --
											)
		-- ORDER BY VERSIONNO

OPEN CU_CURSOR_U_ITEM
	FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_K_HOJA_EMPAQUE
	WHILE @@FETCH_STATUS=0
	BEGIN	
	---- =======================================================================================================================
	---- 	SE COLOCA INACTIVA LA REVISIÓN ACTUAL, PARA DAR PASO A LA NUEVA REVISIÓN.
	---- =======================================================================================================================
	UPDATE	HOJA_EMPAQUE
	SET		[L_REVISION_ACTIVA]				= 0	,
			-- ============================	= -- ============================
			[F_BAJA]						= GETDATE(), 
			[K_USUARIO_BAJA]				= @PP_K_USUARIO_ACCION
	WHERE	[K_HOJA_EMPAQUE]				= @VP_CU_K_HOJA_EMPAQUE
	--WHERE	[CUS_NO]						= @PP_CUS_NO	
	--AND		[MODELNO]						= @PP_MODELNO	
	--AND		[VERSIONNO]						= @PP_VERSIONNO
	--AND		[ITEM_P]						= @PP_ITEM_P
	--AND		[REVISION_HOJA_EMPAQUE]			= @PP_REVISION_HOJA_EMPAQUE
	IF @@ROWCOUNT = 0
	BEGIN
		SET @VP_MENSAJE='Registro no fue modificado. (0)(N)[HEU#'+CONVERT(VARCHAR(10),@PP_ITEM_P )+']'
		RAISERROR (@VP_MENSAJE, 16, 1 ) 
	END

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
			--[CUBE_WIDTH]					,	[CUBE_LENGTH]					,
			[AREA_NETA]						,	[AREA_GROSS]					,
			-- ============================
			[C_HOJA_EMPAQUE]				,	[L_REVISION_ACTIVA]				,
			-- ============================
			[K_HOJA_EMPAQUE_CAPA_DIVISION]	,
			[N_CAPAS]						,	--[L_CAPAS_COMPLETAS]				,
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
			@PP_REVISION_NUEVA_HOJA_EMPAQUE	,	--@VP_REVISION_NUEVA				,
			-- ============================
			[STANDAR_PACK]					,	[CANTIDAD_PATRONES]				,
			--[CUBE_WIDTH]					,	[CUBE_LENGTH]					,
			[AREA_NETA]						,	[AREA_GROSS]					,
			-- ============================
			@PP_C_HOJA_EMPAQUE				,	1								,
			-- ============================
			@PP_K_HOJA_EMPAQUE_CAPA_DIVISION,	
			@PP_CANTIDAD_CAPAS				,	--@VP_L_CAPAS_COMPLETAS
			-- ============================
			4								,	--[K_TIPO_CAMBIO_KIT]	
			-- ============================
			@PP_K_USUARIO_ACCION			,	GETDATE()						,
			@PP_K_USUARIO_ACCION			,	GETDATE()						,
			0
	FROM	[HOJA_EMPAQUE]			(NOLOCK)
	WHERE	[K_HOJA_EMPAQUE]		= @VP_CU_K_HOJA_EMPAQUE
	--WHERE	CUS_NO					= @PP_CUS_NO
	--AND		MODELNO					= @PP_MODELNO
	--AND		VERSIONNO				= @PP_VERSIONNO
	--AND		ITEM_P					= @PP_ITEM_P
	--AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
	IF @@ROWCOUNT = 0
	BEGIN
		SET @VP_MENSAJE='Registro no fue ingresado.(N)[HEU#'+CONVERT(VARCHAR(10),@PP_ITEM_P )+ ' // ' +CONVERT(VARCHAR(10),@PP_REVISION_HOJA_EMPAQUE) + ']'
		RAISERROR (@VP_MENSAJE, 16, 1 ) 
	END

FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_K_HOJA_EMPAQUE
END
CLOSE		CU_CURSOR_U_ITEM
DEALLOCATE	CU_CURSOR_U_ITEM	

GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> UPDATE / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_HOJA_EMPAQUE_U]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_HOJA_EMPAQUE_U]
GO
--		 EXECUTE [dbo].[PG_UP_HOJA_EMPAQUE_U]	0, 139,	'1' , 'MAGN02' , 'WAL' , '14' , 'PWALBRR' , 'P133124' , '' , '0' , '' , 3,2,0
--		 EXECUTE [dbo].[PG_UP_HOJA_EMPAQUE_U]	0, 139,	'1' , 'MAGN02' , 'WAL' , '14' , 'PWALBR2' , 'P133124' , '' , '0' , '' , 3,2,0
CREATE PROCEDURE [dbo].[PG_UP_HOJA_EMPAQUE_U]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
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
	@PP_CANTIDAD_CAPAS					INT,
	@PP_REVISION_NUEVA_HOJA_EMPAQUE		INT
	---- ============================---- ============================
	---- ============================---- ============================
	---- ============================---- ============================
AS			
DECLARE  @VP_MENSAJE					NVARCHAR(MAX)
		,@VP_CU_K_HOJA_EMPAQUE			INT

DECLARE CU_CURSOR_U_ITEM	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR

		SELECT	K_HOJA_EMPAQUE
		FROM	HOJA_EMPAQUE		(NOLOCK)
		WHERE	CUS_NO				=	@PP_CUS_NO			--	'MAGN02'	--
		AND		MODELNO				=	@PP_MODELNO			--	'WAL'		--
		AND		VERSIONNO			=	@PP_VERSIONNO		--	 (0014)	--
		---AND		U_ITEM				<> ''
		AND		[U_ITEM]			IN (	SELECT	DISTINCT(U_ITEM) 
											FROM	HOJA_EMPAQUE 
											WHERE	CUS_NO				=  @PP_CUS_NO			--	'MAGN02'	--
											AND		MODELNO				=  @PP_MODELNO			--	'WAL'		--
											AND		VERSIONNO			=  @PP_VERSIONNO		--	 (0014)	--
											AND		ITEM_P				=  @PP_ITEM_P			--	'PWALBRR' --
											)
		-- ORDER BY VERSIONNO

OPEN CU_CURSOR_U_ITEM
	FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_K_HOJA_EMPAQUE
	WHILE @@FETCH_STATUS=0
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
					[N_CAPAS]						= @PP_CANTIDAD_CAPAS				,	--	@VP_CANTIDAD_CAPAS				,
					-- ============================	= -- ============================
					[F_CAMBIO]						= GETDATE(), 
					[K_USUARIO_CAMBIO]				= @PP_K_USUARIO_ACCION
			WHERE	[K_HOJA_EMPAQUE]				= @VP_CU_K_HOJA_EMPAQUE		   

			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='Registro no fue modificado. [HEU#'+CONVERT(VARCHAR(10),@PP_ITEM_P )+']'
				RAISERROR (@VP_MENSAJE, 16, 1 ) 
			END
			--WHERE	[CUS_NO]						= @PP_CUS_NO	
			--AND		[MODELNO]						= @PP_MODELNO	
			--AND		[VERSIONNO]						= @PP_VERSIONNO
			--AND		[ITEM_P]						= @PP_ITEM_P
			--AND		[REVISION_HOJA_EMPAQUE]			= @PP_REVISION_HOJA_EMPAQUE

FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_K_HOJA_EMPAQUE
END
CLOSE		CU_CURSOR_U_ITEM
DEALLOCATE	CU_CURSOR_U_ITEM	

GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> UPDATE / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_INUP_HOJA_EMPAQUE_PROCESO_U]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_INUP_HOJA_EMPAQUE_PROCESO_U]
GO
--		 EXECUTE [dbo].[PG_INUP_HOJA_EMPAQUE_PROCESO_U]	0, 139, '0' , 'FAUR01' , FW2 , '11' , 'PWSFCL2' , 0,
--														'39/40/41/42/43/44/-1' , '2/3/4/7/8/10/50' , '1/2/0/0/5/7/12' , '1/1/0/0/1/1/1',
--														'KUFNER R179G46/AXIS II/RECUT/SHAVING/KUFNER TX9080/REGISTERED/DIRECCION DE CORTE DE KUFNER'
CREATE PROCEDURE [dbo].[PG_INUP_HOJA_EMPAQUE_PROCESO_U]
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
			--	SE COLOCA ESTA PARTE DEL CÓDIGO POR PROBLEMAS PARA LA CONVERSIÓN DE LOS CHECK DE SELECCIÓN, NO AFECTA EL FUNCIONAMIENTO DEL SISTEMA, 
			--	AL CONTRARIO AYUDA A QUE NO MARQUE EL ERROR POR TIPO DE DATO ERRONEO.
			IF UPPER(@VP_VALOR_L_PROCESO)	= 'TRUE'
			BEGIN
				SET	@VP_VALOR_L_PROCESO	= 1
			END

			IF UPPER(@VP_VALOR_L_PROCESO)	= 'FALSE'
			BEGIN
				SET	@VP_VALOR_L_PROCESO	= 0
			END
			--	MOSTRAR EL NÚMERO P EN LA VISTA DEL LISTADO PARA JALAR EL DATO Y ACTULIZARLO DE LA MEJOR MANERA.
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
					--WHERE	[CUS_NO]					= @PP_CUS_NO 
					--AND		[MODELNO]					= @PP_MODELNO
					--AND		[VERSIONNO]					= @PP_VERSIONNO
					--		-- ============================
					--AND		[ITEM_P]					= @PP_ITEM_P
					--AND		[REVISION_HOJA_EMPAQUE]		= @PP_REVISION_HOJA_EMPAQUE
					WHERE		[K_HOJA_EMPAQUE_PROCESO]	= @VP_VALOR_K_HE_PROC
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


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////