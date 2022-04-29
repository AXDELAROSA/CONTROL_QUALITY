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
--	[PG_LI_HOJA_EMPAQUE]							-- x P, xI, xYANG
--	[PG_LI_HOJA_EMPAQUE_X_TEXTO]					-- x P, xI, xYANG, xOrden
--	[PG_LI_IMPRIMIR_HOJA_EMPAQUE_X_ORDEN]
--	[PG_LI_HOJA_EMPAQUE_COLORES_U]					-- x P, xI, xYANG	--	PARA REEMPLAZAR EL USADO ACTUALMENTE	(NUEVO)	--	[PG_LI_HOJA_EMPAQUE_COLORES]		--	FUE REEMPLAZADO POR EL QUE FUNCIONARÁ PARA LOS U NUMBERS			(VIEJO)
--	[PG_LI_HOJA_EMPAQUE_PROCESO_U]					-- x P, xI, xYANG
--	[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE]
--	[PG_LI_HOJA_EMPAQUE_PROCESO_SIMBOLO]
--	[PG_LI_HOJA_EMPAQUE_CAPA]
--	[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE]
--	[PG_LI_HOJA_EMPAQUE_MODELO_MASTER]
--	[PG_SK_HOJA_EMPAQUE]
--	[PG_SK_HOJA_EMPAQUE_REPORTE]
--	[PG_SK_HOJA_EMPAQUE_COMPLETA]		--	PARA SABER SI SE PREVISUALIZA LA HOJA EN LA PANTALLA DE IMPRESIÓN.
--	[PG_UP_HOJA_EMPAQUE]
--	[PG_INUP_HOJA_EMPAQUE_PROCESO]
-- //////////////////////////////////////////////////////////////
-- //////		SE MANDA LLAMAR DESDE EL SISTEMA DE COTIZACIONES
--	[PG_IN_HOJA_EMPAQUE_VERSION]
--	[PG_IN_HOJA_EMPAQUE_VERSION_PROCESO]
--	[PG_PR_COPIAR_IMAGEN_CAPA]
--	[PG_PR_LIMPIAR_RUTA_IMAGEN]
-- //////////////////////////////////////////////////////////////
----------	[PG_INUP_HOJA_EMPAQUE]		-- REEMPLAZARÁ A [PG_UP_HOJA_EMPAQUE]
--	[PG_IN_HOJA_EMPAQUE_U]
--	[PG_UP_HOJA_EMPAQUE_U]
--	[PG_INUP_HOJA_EMPAQUE_PROCESO_U]
-- //////////////////////////////////////////////////////////////
--	[PG_NOTIFICAR_HOJA_EMPAQUE]


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
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE] 0,139,'253293','MAGN03','WD2'		
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE] 0,139,'PJLFCRL','MAGN03','WD2'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE] 0,139,'','IRVI02','JLI'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE] 0,139,'','MAGN03','WD2'
CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	--@PP_BUSCAR						VARCHAR(25),
	--@PP_K_HOJA_EMPAQUE_STATUS				INT,
	@PP_ITEM						VARCHAR(25),
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25)
	--@PP_F_INIT						DATE,
	--@PP_F_FINISH					DATE
AS
	DECLARE  @VP_HORA			INT			= FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
	DECLARE  @VP_TURNO			VARCHAR(5)	= '2'
	
	IF @VP_HORA > 2000 AND @VP_HORA < 60002
		SET @VP_TURNO = '3'
	ELSE IF @VP_HORA > 60001 AND @VP_HORA < 153001
		SET @VP_TURNO = '1'	
	-- =========================================================================================================
	--	LA PRIMER OPCIÓN ES BUSCAR POR "P"/"U" O POR NÚMERO DE PARTE DEL CLIENTE.
	IF @PP_ITEM	<> ''
	BEGIN
		IF LEFT(@PP_ITEM ,1) = 'P'
		BEGIN
			SELECT	--DISTINCT (ITEM_P)
					 ITEM_NO					AS ITEM_P
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
			--	===========================================================================
					,(	CASE	
							WHEN	L_CAPAS_COMPLETAS	= 0	THEN 'NO'
							WHEN	L_CAPAS_COMPLETAS	= 1	THEN 'SI'
					END) AS L_CAPAS_COMPLETAS
					,STANDAR_PACK
			FROM	HOJA_EMPAQUE		(NOLOCK)
			WHERE	ITEM_NO	LIKE ( '%' + @PP_ITEM + '%' )
			ORDER	BY CUS_NO	,MODELNO	,VERSIONNO DESC--, ITEM_P, L_REVISION_ACTIVA DESC
		END
		ELSE
		BEGIN
			SELECT	--DISTINCT (ITEM_P)
					 ITEM_NO					AS ITEM_P
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
			--	===========================================================================
					,(	CASE	
							WHEN	L_CAPAS_COMPLETAS	= 0	THEN 'NO'
							WHEN	L_CAPAS_COMPLETAS	= 1	THEN 'SI'
					END) AS L_CAPAS_COMPLETAS
					,STANDAR_PACK
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

		IF @PP_CUS_NO	IN ('YANG02')	AND @PP_MODELNO	= 'WL5'
		BEGIN			
			SELECT	 ITEM_NO					AS ITEM_P
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
					,STANDAR_PACK
			FROM	[HOJA_EMPAQUE]		(NOLOCK)
			WHERE	( @PP_CUS_NO		= '( TODOS )'	OR	CUS_NO		= @PP_CUS_NO  )
			AND		( @PP_MODELNO		= '( T'			OR	MODELNO		= @PP_MODELNO )
			ORDER	BY CUS_NO	,MODELNO	,VERSIONNO DESC, U_ITEM DESC, ITEM_P, L_REVISION_ACTIVA DESC
		END
		ELSE
		BEGIN
			SELECT	ITEM_NO			AS ITEM_P--DISTINCT (ITEM_P)
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
					,STANDAR_PACK
			FROM	[HOJA_EMPAQUE]		(NOLOCK)
			WHERE	( @PP_CUS_NO		= '( TODOS )'	OR	CUS_NO		= @PP_CUS_NO  )
			AND		( @PP_MODELNO		= '( T'			OR	MODELNO		= @PP_MODELNO )
			ORDER	BY CUS_NO	,MODELNO	,VERSIONNO DESC, U_ITEM DESC, ITEM_P, L_REVISION_ACTIVA DESC
		END
	END
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
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_X_TEXTO] 0,139, '54730', ''				,'',''								 ,1
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
			--	===========================================================================
					,(	CASE	
							WHEN	L_CAPAS_COMPLETAS	= 0	THEN 'NO'
							WHEN	L_CAPAS_COMPLETAS	= 1	THEN 'SI'
					END) AS L_CAPAS_COMPLETAS
					,STANDAR_PACK
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
			--	===========================================================================
					,(	CASE	
							WHEN	L_CAPAS_COMPLETAS	= 0	THEN 'NO'
							WHEN	L_CAPAS_COMPLETAS	= 1	THEN 'SI'
					END) AS L_CAPAS_COMPLETAS
					,STANDAR_PACK
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
		--	===========================================================================
					,(	CASE	
							WHEN	L_CAPAS_COMPLETAS	= 0	THEN 'NO'
							WHEN	L_CAPAS_COMPLETAS	= 1	THEN 'SI'
					END) AS L_CAPAS_COMPLETAS
					,STANDAR_PACK
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
--		 EXECUTE [DBO].[PG_LI_IMPRIMIR_HOJA_EMPAQUE_X_ORDEN] 0 ,0,  '53986'
--		 EXECUTE [DBO].[PG_LI_IMPRIMIR_HOJA_EMPAQUE_X_ORDEN] 0 ,0,  '55086'	-- RMA
--		 EXECUTE [DBO].[PG_LI_IMPRIMIR_HOJA_EMPAQUE_X_ORDEN] 0 ,0,  '52967'	--	U
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
			TA_D_ITEM							VARCHAR(250),
			TA_L_CAPAS_COMPLETAS				VARCHAR(50),
			TA_STANDAR_PACK						INT
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
			TA_D_ITEM		,
			TA_L_CAPAS_COMPLETAS	,
			TA_STANDAR_PACK			)
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
				LTRIM(RTRIM(ccjoblin_sql.KitDesc))							AS KIT_DESC,
				-------- ===========================
				--(	CASE	
				--			WHEN	(	SELECT	TOP(1)
				--								L_CAPAS_COMPLETAS
				--						FROM	HOJA_EMPAQUE	(NOLOCK)
				--						WHERE	CUS_NO		=	LTRIM(RTRIM(ccjoblin_sql.customer))				
				--						AND		MODELNO		=	LEFT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),3)	
				--						AND		VERSIONNO	=	RIGHT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),4)	
				--						AND		( CASE
				--									WHEN	(LTRIM(RTRIM(ccjoblin_sql.item_no))) LIKE 'U%' THEN	U_ITEM
				--									ELSE	ITEM_NO
				--								END)		=	LTRIM(RTRIM(ccjoblin_sql.item_no))
				--						)	= 1	THEN 'SI'
				--			ELSE	'NO'
				--END) AS L_CAPAS_COMPLETAS
				(	CASE	
							WHEN	(	SELECT	TOP(1)
												L_CAPAS_COMPLETAS
										FROM	HOJA_EMPAQUE	(NOLOCK)
										WHERE	CUS_NO		=	LTRIM(RTRIM(ccjoblin_sql.customer))				
										AND		MODELNO		=	LEFT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),3)	
										AND		VERSIONNO	=	RIGHT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),4)	
										AND		ITEM_NO		= (	CASE
																	WHEN	LTRIM(RTRIM(ccjoblin_sql.item_no)) LIKE 'I%' THEN	(	SELECT	TOP(1)
																																			ITEM_NO 
																																	FROM	ccprdstr_sql (NOLOCK)
																																	WHERE	comp_item_no	=	LTRIM(RTRIM(ccjoblin_sql.item_no))
																																	AND		jobno			= 	@PP_ORDEN )
																	ELSE	LTRIM(RTRIM(ccjoblin_sql.item_no))	
																END	)
										)	= 1	THEN 'SI'
							ELSE	'NO'
				END) AS L_CAPAS_COMPLETAS
				-------- ===========================
				,ISNULL(	(	SELECT	TOP(1)
									STANDAR_PACK
							FROM	HOJA_EMPAQUE	(NOLOCK)
							WHERE	CUS_NO		=	LTRIM(RTRIM(ccjoblin_sql.customer))				
							AND		MODELNO		=	LEFT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),3)	
							AND		VERSIONNO	=	RIGHT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),4)	
							AND		( CASE
										WHEN	(LTRIM(RTRIM(ccjoblin_sql.item_no))) LIKE 'U%' THEN	U_ITEM
										ELSE	ITEM_NO
									END)		=	LTRIM(RTRIM(ccjoblin_sql.item_no))
							), 0)		AS STANDAR_PACK
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
				LTRIM(RTRIM(ccjoblin_sql.KitDesc))							AS KIT_DESC,
				---------- ===========================
				--(	CASE	
				--			WHEN	(	SELECT	TOP(1)
				--								L_CAPAS_COMPLETAS
				--						FROM	HOJA_EMPAQUE	(NOLOCK)
				--						WHERE	CUS_NO		=	LTRIM(RTRIM(ccjoblin_sql.customer))				
				--						AND		MODELNO		=	LEFT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),3)	
				--						AND		VERSIONNO	=	RIGHT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),4)	
				--						AND		ITEM_NO		=	LTRIM(RTRIM(ccjoblin_sql.item_no))			)	= 1	THEN 'SI'
				--			ELSE	'NO'
				--END) AS L_CAPAS_COMPLETAS
			(	CASE	
							WHEN	(	SELECT	TOP(1)
												L_CAPAS_COMPLETAS
										FROM	HOJA_EMPAQUE	(NOLOCK)
										WHERE	CUS_NO		=	LTRIM(RTRIM(ccjoblin_sql.customer))				
										AND		MODELNO		=	LEFT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),3)	
										AND		VERSIONNO	=	RIGHT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),4)	
										AND		ITEM_NO		= (	CASE
																	WHEN	LTRIM(RTRIM(ccjoblin_sql.item_no)) LIKE 'I%' THEN	(	SELECT	TOP(1)
																																			ITEM_NO 
																																	FROM	ccprdstr_sql (NOLOCK)
																																	WHERE	comp_item_no	=	LTRIM(RTRIM(ccjoblin_sql.item_no))
																																	AND		jobno			= 	@PP_ORDEN )
																	ELSE	LTRIM(RTRIM(ccjoblin_sql.item_no))	
																END	)
										)	= 1	THEN 'SI'
							ELSE	'NO'
				END) AS L_CAPAS_COMPLETAS
				-------- ===========================
				,ISNULL(	(	SELECT	TOP(1)
									STANDAR_PACK
							FROM	HOJA_EMPAQUE	(NOLOCK)
							WHERE	CUS_NO		=	LTRIM(RTRIM(ccjoblin_sql.customer))				
							AND		MODELNO		=	LEFT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),3)	
							AND		VERSIONNO	=	RIGHT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),4)	
							AND		( CASE
										WHEN	(LTRIM(RTRIM(ccjoblin_sql.item_no))) LIKE 'U%' THEN	U_ITEM
										ELSE	ITEM_NO
									END)		=	LTRIM(RTRIM(ccjoblin_sql.item_no))
							), 0)		AS STANDAR_PACK
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
			TA_D_ITEM		,
			TA_L_CAPAS_COMPLETAS	,
			TA_STANDAR_PACK			)
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
				LTRIM(RTRIM(ccjoblin_sql.KitDesc))							AS KIT_DESC,
				---------- ===========================
				(	CASE	
							WHEN	(	SELECT	TOP(1)
												L_CAPAS_COMPLETAS
										FROM	HOJA_EMPAQUE	(NOLOCK)
										WHERE	CUS_NO		=	LTRIM(RTRIM(ccjoblin_sql.customer))				
										AND		MODELNO		=	LEFT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),3)	
										AND		VERSIONNO	=	RIGHT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),4)	
										AND		ITEM_NO		= (	CASE
																	WHEN	LTRIM(RTRIM(ccjoblin_sql.item_no)) LIKE 'I%' THEN	(	SELECT	TOP(1)
																																			ITEM_NO 
																																	FROM	ccprdstr_sql (NOLOCK)
																																	WHERE	comp_item_no	=	LTRIM(RTRIM(ccjoblin_sql.item_no))
																																	AND		jobno			= 	@PP_ORDEN )
																	ELSE	LTRIM(RTRIM(ccjoblin_sql.item_no))	
																END	)
										)	= 1	THEN 'SI'
							ELSE	'NO'
				END) AS L_CAPAS_COMPLETAS
				-------- ===========================
				,ISNULL(	(	SELECT	TOP(1)
									STANDAR_PACK
							FROM	HOJA_EMPAQUE	(NOLOCK)
							WHERE	CUS_NO		=	LTRIM(RTRIM(ccjoblin_sql.customer))				
							AND		MODELNO		=	LEFT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),3)	
							AND		VERSIONNO	=	RIGHT(LTRIM(RTRIM(ccjoblin_sql.ChangeLevel)),4)	
							AND		( CASE
										WHEN	(LTRIM(RTRIM(ccjoblin_sql.item_no))) LIKE 'U%' THEN	U_ITEM
										ELSE	ITEM_NO
									END)		=	LTRIM(RTRIM(ccjoblin_sql.item_no))
							), 0)		AS STANDAR_PACK
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
		AND		cccusitm_sql.versionno	=(	SELECT	MAX(CONVERT(INT, versionno)) 
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
																			--AND		HOJA_EMPAQUE.L_REVISION_ACTIVA	= 1
																			--AND		HOJA_EMPAQUE.L_CAPAS_COMPLETAS	= 1		
																			)
							ELSE	(	SELECT	TOP (1)
												REVISION_HOJA_EMPAQUE
										FROM	HOJA_EMPAQUE	(NOLOCK)
										WHERE	CUS_NO			= TMP.TA_CUS_NO			--	'MAGN03'	--	@PP_CUS_NO
										AND		MODELNO			= TMP.TA_MODELNO		--	'WD2'		--	@PP_MODELNO
										AND		VERSIONNO		= TMP.TA_VERSIONNO		--	'16'		--	@PP_VERSIONNO
										AND		ITEM_NO			= TMP.TA_ITEM_NO
										--AND		HOJA_EMPAQUE.L_REVISION_ACTIVA	= 1
										--AND		HOJA_EMPAQUE.L_CAPAS_COMPLETAS	= 1		
										)
						END)	
				,	-1	)	AS	REVISION_HOJA_EMPAQUE
				,TA_L_CAPAS_COMPLETAS			AS	L_CAPAS_COMPLETAS
				,TA_STANDAR_PACK				AS	STANDAR_PACK
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
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE_COLORES_U]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES_U]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES_U] 0,139, 'YANG02' , 'WL5' , '0004' ,'PYFRBOLYPAWT5' ,'0'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES_U] 0,139, 'YANG02' , 'WL5' , '0004' ,'PYFRBOLYPATX7' ,'0'
--		 EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_COLORES_U] 0,139, 'MAGN02' , 'WAL' , '0014' ,'PWALBR2WLROX7' ,'0'
--		 EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_COLORES_U] 0,139, 'MAGN03'	, 'WD2'	, '16',	'PWD2TFBCNPWA3'	,'0'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES_U] 0,139, 'MAGN02' , 'WAL' , '0014' ,'UWALFBLWLCPT3', '0'	
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES_U] 0,139, 'MAGN03' , 'WD2' , '0016' , 'PWD2TBLCNPWA3' , '0'  
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_COLORES_U] 0,139, 'MAGN03' , 'WD2' , '0016' , 'PWD2TBLCNPLV5' , '0'  
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
	DECLARE	@VP_U_ITEM			VARCHAR	(50)	= ''

	IF	@PP_ITEM_P LIKE 'P%'
	BEGIN
		SELECT	@VP_U_ITEM		= ISNULL(ITEM_NO,'')
		FROM	IMKITFIL_SQL	(NOLOCK)
		WHERE	COMP_ITEM_NO						= @PP_ITEM_P
		AND		LEFT(LTRIM(RTRIM(FILLER_0004)),3)	= @PP_MODELNO
		AND		RIGHT(LTRIM(RTRIM(FILLER_0004)),4)	= FORMAT(@PP_VERSIONNO,'0000')
	END

	IF	@PP_ITEM_P LIKE 'U%'	--OR	@VP_U_ITEM <> ''
	BEGIN
			SET	@VP_U_ITEM	= @PP_ITEM_P
	END

	SELECT	--COLOR,
			ITEM_P AS COLOR,
			ITEM_NO,
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
	--AND		CUSTOMER_ITEM_NO					IN (	--SELECT	LTRIM(RTRIM(CUSTOMER_ITEM_NO))		AS CUSTOMER_ITEM_NO
	AND		ITEM_NO								IN (	SELECT	ITEM_NO
														FROM	[HOJA_EMPAQUE]						(NOLOCK)
														--WHERE	HOJA_EMPAQUE.ITEM_NO				= @PP_ITEM_P
														-- =============================================================================
														WHERE	( CASE
																	WHEN	@VP_U_ITEM <> ''	THEN	HOJA_EMPAQUE.U_ITEM
																	ELSE	HOJA_EMPAQUE.ITEM_NO
																END)		=	(	CASE
																						WHEN	@VP_U_ITEM <> ''	THEN	@VP_U_ITEM
																						ELSE	@PP_ITEM_P 
																				END	)
														-- =============================================================================
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
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_U]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_U]
GO
-- ===================================================================================================
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_U] 0,139, 'IRVI02' , 'JLI' , '59' , 'PJLFCRLMCKTX7' , 0		
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_U] 0,139, 'MAGN03' , 'WD2' , '16'   , 'PWD2TCLCNPDX9' ,'0'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_U] 0,139, 'YANG02' , 'WL5' , '0004' , 'PYFRBOLYPAWT5' ,'0' 
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_U] 0,139, 'YANG02' , 'WL5' , '0004' , 'PYFRBOLYPATX7' ,'0' 
--		 EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_PROCESO_U] 0,139, 'MAGN02' , 'WAL' , '0014' , 'PWALBR2WLROX7' ,'0'
--		 EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_PROCESO_U] 0,139, 'MAGN02' , 'WAL' , '0014' , 'PWALBRRWLCPT3' ,'0'
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
	DECLARE	@VP_TA_ITEM_U		AS TABLE
	(	
		TA_U_K_HOJA_EMPAQUE_PROCESO			INTEGER,
		TA_U_K_PROCESO_SIMBOLO				INTEGER,
		TA_U_L_HOJA_EMPAQUE_PROCESO			INTEGER,
		TA_U_K_PROCESO						INTEGER,
		TA_U_D_HOJA_EMPAQUE_PROCESO			NVARCHAR(MAX),
		TA_U_RUTA_AV_PROCESO_SIMBOLO		NVARCHAR(MAX)
	)
	
	DECLARE	@VP_TA_ITEM_P		AS TABLE
	(	TA_ITEM_P				VARCHAR(50)		)

	INSERT INTO	@VP_TA_ITEM_P
	SELECT @PP_ITEM_P

	INSERT INTO	@VP_TA_ITEM_P
	SELECT	ITEM_NO
	FROM	[HOJA_EMPAQUE]						(NOLOCK)
	WHERE	HOJA_EMPAQUE.ITEM_NO				<> @PP_ITEM_P
	AND		HOJA_EMPAQUE.CUS_NO					= @PP_CUS_NO	
	AND		HOJA_EMPAQUE.MODELNO				= @PP_MODELNO	
	AND		HOJA_EMPAQUE.VERSIONNO				= @PP_VERSIONNO
	AND		HOJA_EMPAQUE.REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
	AND		HOJA_EMPAQUE.L_BORRADO	<> 1
	AND		U_ITEM								IN	(	SELECT	U_ITEM	--LTRIM(RTRIM(CUSTOMER_ITEM_NO))	AS CUSTOMER_ITEM_NO
														FROM	[HOJA_EMPAQUE]						(NOLOCK)
														WHERE	HOJA_EMPAQUE.ITEM_NO				= @PP_ITEM_P
														AND		HOJA_EMPAQUE.CUS_NO					= @PP_CUS_NO	
														AND		HOJA_EMPAQUE.MODELNO				= @PP_MODELNO	
														AND		HOJA_EMPAQUE.VERSIONNO				= @PP_VERSIONNO
														AND		HOJA_EMPAQUE.REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
														AND		U_ITEM								<> ''
														AND		HOJA_EMPAQUE.L_BORRADO	<> 1		)
	
	DECLARE	@VP_CU_K_PROCESO					INTEGER,
			@VP_CU_K_HOJA_EMPAQUE_PROCESO		INTEGER,
			@VP_CU_K_PROCESO_SIMBOLO			INTEGER,
			@VP_CU_L_HOJA_EMPAQUE_PROCESO		INTEGER,
			@VP_CU_D_HOJA_EMPAQUE_PROCESO		NVARCHAR(MAX),
			@VP_CU_RUTA_AV_PROCESO_SIMBOLO		NVARCHAR(MAX)

	DECLARE CU_CURSOR_PROCES	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR		
		SELECT	----DISTINCT(HOJA_EMPAQUE_PROCESO_RESPALDO.D_HOJA_EMPAQUE_PROCESO),	--	HOJA_EMPAQUE_PROCESO.*,
				 K_HOJA_EMPAQUE_PROCESO
				,HE.K_PROCESO_SIMBOLO
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
		FROM	[HOJA_EMPAQUE_PROCESO]	AS HE			 (NOLOCK)
		LEFT JOIN	PROCESO_SIMBOLO (NOLOCK) ON PROCESO_SIMBOLO.K_PROCESO_SIMBOLO	= HE.K_PROCESO_SIMBOLO
		WHERE	CUS_NO					= @PP_CUS_NO
		AND		MODELNO					= @PP_MODELNO
		AND		VERSIONNO				= @PP_VERSIONNO
		AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
		-- ========================================================================================================================
		--AND		ITEM_P					= @PP_ITEM_P
		AND		ITEM_NO					IN	(	SELECT TA_ITEM_P FROM @VP_TA_ITEM_P )
		ORDER	BY K_HOJA_EMPAQUE_PROCESO, HE.D_HOJA_EMPAQUE_PROCESO, K_PROCESO
	OPEN CU_CURSOR_PROCES
	FETCH NEXT FROM  CU_CURSOR_PROCES INTO    @VP_CU_K_HOJA_EMPAQUE_PROCESO		,@VP_CU_K_PROCESO_SIMBOLO			
											 ,@VP_CU_L_HOJA_EMPAQUE_PROCESO		,@VP_CU_K_PROCESO
											 ,@VP_CU_D_HOJA_EMPAQUE_PROCESO		,@VP_CU_RUTA_AV_PROCESO_SIMBOLO		
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @VP_CU_K_PROCESO <> 50
		BEGIN
			IF ( SELECT COUNT(TA_U_K_HOJA_EMPAQUE_PROCESO) FROM @VP_TA_ITEM_U WHERE TA_U_K_PROCESO = @VP_CU_K_PROCESO	) <= 0
			BEGIN
				INSERT INTO @VP_TA_ITEM_U
				(	 TA_U_K_HOJA_EMPAQUE_PROCESO		,TA_U_K_PROCESO_SIMBOLO
					,TA_U_L_HOJA_EMPAQUE_PROCESO		,TA_U_K_PROCESO				
					,TA_U_D_HOJA_EMPAQUE_PROCESO		,TA_U_RUTA_AV_PROCESO_SIMBOLO
				)	VALUES	(
					 @VP_CU_K_HOJA_EMPAQUE_PROCESO		,@VP_CU_K_PROCESO_SIMBOLO
					,@VP_CU_L_HOJA_EMPAQUE_PROCESO		,@VP_CU_K_PROCESO
					,@VP_CU_D_HOJA_EMPAQUE_PROCESO		,@VP_CU_RUTA_AV_PROCESO_SIMBOLO
				)
			END
		END
		ELSE
		BEGIN
				INSERT INTO @VP_TA_ITEM_U
				(	 TA_U_K_HOJA_EMPAQUE_PROCESO		,TA_U_K_PROCESO_SIMBOLO
					,TA_U_L_HOJA_EMPAQUE_PROCESO		,TA_U_K_PROCESO				
					,TA_U_D_HOJA_EMPAQUE_PROCESO		,TA_U_RUTA_AV_PROCESO_SIMBOLO
				)	VALUES	(
					 @VP_CU_K_HOJA_EMPAQUE_PROCESO		,@VP_CU_K_PROCESO_SIMBOLO
					,@VP_CU_L_HOJA_EMPAQUE_PROCESO		,@VP_CU_K_PROCESO
					,@VP_CU_D_HOJA_EMPAQUE_PROCESO		,@VP_CU_RUTA_AV_PROCESO_SIMBOLO
				)
		END	
	FETCH NEXT FROM  CU_CURSOR_PROCES INTO    @VP_CU_K_HOJA_EMPAQUE_PROCESO		,@VP_CU_K_PROCESO_SIMBOLO			
											 ,@VP_CU_L_HOJA_EMPAQUE_PROCESO		,@VP_CU_K_PROCESO
											 ,@VP_CU_D_HOJA_EMPAQUE_PROCESO		,@VP_CU_RUTA_AV_PROCESO_SIMBOLO		
	END
	CLOSE	   CU_CURSOR_PROCES
	DEALLOCATE CU_CURSOR_PROCES	

	SELECT	
			TA_U_K_HOJA_EMPAQUE_PROCESO		AS K_HOJA_EMPAQUE_PROCESO	,	
			TA_U_K_PROCESO_SIMBOLO			AS K_PROCESO_SIMBOLO		,	
			TA_U_L_HOJA_EMPAQUE_PROCESO		AS L_HOJA_EMPAQUE_PROCESO	,	
			TA_U_D_HOJA_EMPAQUE_PROCESO		AS D_HOJA_EMPAQUE_PROCESO	,	
			TA_U_K_PROCESO					AS K_PROCESO				,	
			--(CASE
			--	WHEN	TA_U_K_PROCESO	< 50 	THEN	TA_U_K_PROCESO
			--	ELSE	50
			--END)	AS K_PROCESO,			
			TA_U_RUTA_AV_PROCESO_SIMBOLO	AS RUTA_AV_PROCESO_SIMBOLO
	FROM	@VP_TA_ITEM_U
	ORDER	BY D_HOJA_EMPAQUE_PROCESO, K_PROCESO
	
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> MUESTRA EL DETALLE DE LOS SPECIAL_PROCESS POR KIT
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2WSPAD4', 0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE] 0,139, 'FAUR01'	, 'FW2'	, '11',	'PWSFCL2WSPAX7', 0
--	==============================================================================================================
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE] 0,139, 'MAGN03'	, 'WD2'	, '16',	'UWD2FCLCNPJRR', 0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE] 0,139, 'IRVI02' , 'JLI' , '0059' , 'PJLFCRLMCKTX7' , 0		
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE] 0,139, 'MAGN03' , 'WD2' , '0016' , 'PWD2TFBCNPWA3' ,'0'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE] 0,139, 'YANG02' , 'WL5' , '0004' , 'PYFRBOLYPAWT5' ,'0' 
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE] 0,139, 'YANG02' , 'WL5' , '0004' , 'PYFRBOLYPATX7' ,'0' 
--		 EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE] 0,139, 'MAGN02' , 'WAL' , '0014' , 'PWALBR2WLROX7' ,'0'
--		 EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE] 0,139, 'MAGN02'	, 'WTL'	, '16',	'PWLFB2RWLNPX7', 0
--		 EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_PROCESO_REPORTE] 0,139, 'MAGN02'	, 'WTL'	, '16',	'IWTL0085WLNPX7', 0
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

	DECLARE  @VP_ITEM_NO_DE_RMA			VARCHAR(50)	= ''
			,@VP_REVISION_NO_DE_RMA		INT			= -1
	
	IF @PP_ITEM_NO LIKE 'I%'
	BEGIN	
		SET	@VP_ITEM_NO_DE_RMA		= 	ISNULL(	(	SELECT	TOP(1)	RTRIM(LTRIM(ITEM_NO))
												FROM	CCPRDSTR_SQL (NOLOCK)
												WHERE	CUS_NO			= @PP_CUS_NO		
												AND		MODELNO			= @PP_MODELNO		
												AND		VERSIONNO		= @PP_VERSIONNO	
												AND		COMP_ITEM_NO	= @PP_ITEM_NO	),'')
		IF @VP_ITEM_NO_DE_RMA	<>''
		BEGIN
			SELECT	@VP_REVISION_NO_DE_RMA	= ISNULL(REVISION_HOJA_EMPAQUE,-1)
			FROM	HOJA_EMPAQUE
			WHERE	CUS_NO			= @PP_CUS_NO		
			AND		MODELNO			= @PP_MODELNO		
			AND		VERSIONNO		= @PP_VERSIONNO	
			AND		ITEM_NO			= @VP_ITEM_NO_DE_RMA	
			ORDER BY REVISION_HOJA_EMPAQUE	DESC
		END
	END

	IF	@VP_ITEM_NO_DE_RMA <> ''
	BEGIN
		SET	@PP_ITEM_NO					=	@VP_ITEM_NO_DE_RMA
		SET	@PP_REVISION_HOJA_EMPAQUE	=	@VP_REVISION_NO_DE_RMA
	END

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
		--AND		ITEM_P					IN	(	SELECT LEFT(TA_ITEM_P,7) FROM @VP_TA_ITEM_P )
		AND		ITEM_NO					IN	(	SELECT TA_ITEM_P FROM @VP_TA_ITEM_P )
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
-- ===================================================================================================
--		 EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_CAPA] 0,139,	'YANG02'	, 'WL5'	, '4',	'PYFRBOLYPAWT5',0
--		 EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_CAPA] 0,139,	'YANG02'	, 'WL5'	, '4',	'PYFRBOLYPATX7',0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA] 1,139, 'MAGN03'	, 'WD2'	, '16',	'UWD2TFBCNPWA3',0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA] 1,139, 'MAGN03'	, 'WD2'	, '16',	'PWD2TFBCNPWA3',0
--		 EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_CAPA] 0,139, 'MAGN02' , 'WAL' , '0014' , 'PWALBR2WLROX7',0
--		 EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_CAPA] 0,139, 'MAGN03' , 'WD2' , '0016' , 'PWD2TBLCNPWA3' , '0'  
--		 EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_CAPA] 0,139, 'MAGN03' , 'WD2' , '0016' , 'PWD2TBLCNPLV5' , '0'  
-- ===================================================================================================
--		EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_CAPA]  0,139, 'IRVI02' , 'JSU' , '0015' , 'PMJSFSCNPJSA5' , '0'  
--		EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_CAPA]  0,139, 'MAGN02' , 'WAL' , '15' , 'PWALBR2WLROX7  ' , '0'  
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

	DECLARE	@VP_TA_ITEM_P		AS TABLE
	(	TA_ITEM_P				VARCHAR(50)		)
	
	DECLARE	@VP_U_ITEM			VARCHAR	(50)	= ''

	IF	@PP_ITEM_P LIKE 'P%'
	BEGIN
		SELECT	@VP_U_ITEM		= ISNULL(ITEM_NO,'')
		FROM	IMKITFIL_SQL	(NOLOCK)
		WHERE	COMP_ITEM_NO						= @PP_ITEM_P
		AND		LEFT(LTRIM(RTRIM(FILLER_0004)),3)	= @PP_MODELNO
		AND		RIGHT(LTRIM(RTRIM(FILLER_0004)),4)	= FORMAT(@PP_VERSIONNO,'0000')
	END

	IF	@PP_ITEM_P LIKE 'U%'	--OR	@VP_U_ITEM <> ''
	BEGIN
			SET	@VP_U_ITEM	= @PP_ITEM_P
	END
-- ///////////////////////////////////////////

		INSERT INTO @TA_HOJA_EMPAQUE_CAPA
		SELECT		K_HOJA_EMPAQUE_CAPA,
					CUS_NO,
					MODELNO,
					VERSIONNO,
					(	CASE
							WHEN	U_ITEM	<> '' THEN	U_ITEM
							ELSE	ITEM_NO
					END	)	AS ITEM_NO	,
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
		AND			REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
		AND			(	CASE
							WHEN	@VP_U_ITEM<>'' THEN	U_ITEM
							ELSE	ITEM_NO
					END)		= (	CASE
										WHEN	@VP_U_ITEM<>'' THEN	@VP_U_ITEM
										ELSE	@PP_ITEM_P
									END)		
		--AND			ITEM_P			= @PP_ITEM_P
		ORDER	BY	N_CAPA ASC		
--END

		WHILE	(	SELECT		COUNT(TA_K_HOJA_EMPAQUE_CAPA)
					FROM		@TA_HOJA_EMPAQUE_CAPA	) < 4
		BEGIN
			INSERT INTO @TA_HOJA_EMPAQUE_CAPA
			VALUES	(	-1					,
						@PP_CUS_NO			,
						@PP_MODELNO			,
						@PP_VERSIONNO		,
						(	CASE
								WHEN	@VP_U_ITEM	<> '' THEN	@VP_U_ITEM
								ELSE	@PP_ITEM_P			
						END),
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
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE] 1,139, 'MAGN03'	, 'WD2'	, '16',	'PWD2TFBCNPWA3', 0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE] 1,139, 'MAGN03'	, 'WD2'	, '16',	'UWD2TFBCNPWA3', 0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE] 0,139, 'MAGN02'	, 'WAL'	, '14',	'UWALFBLWLCPT3', 0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE] 1,139, 'MAGN03'	, 'WAL'	, '14',	'PWALBR2WLROX7', 0
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE] 0,139, 'MAGN02'	, 'WDL'	, '19',	'UWLDFBRWLCPX7', 0
-- ==================================================================================================================
--		 EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE] 0,139,	'YANG02'	, 'WL5'	, '4',	'PYFRBOLYPAWT5',0
--		 EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE] 0,139,	'YANG02'	, 'WL5'	, '4',	'PYFRBOLYPATX7',0
--		 EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE] 0,139,	'WOOD01'	, 'RUP'	, '8',	'PRUPIL1NRULK5',0
--		 EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE] 0,139,	'WOOD01'	, 'RUP'	, '9',	'PRUPIL1NRULK5',0
--		 EXECUTE [DBO].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE] 0,139, 'MAGN02'	, 'WTL'	, '16',	'IWTL0085WLNPX7', 0
-- ==================================================================================================================
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_CAPA_REPORTE] 0,139, 'MAGN03'	, 'WD2'	, '16',	'UWD2FCLCNPJRR', 0
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

	DECLARE  @VP_ITEM_NO_DE_RMA			VARCHAR(50)	= ''
			,@VP_REVISION_NO_DE_RMA		INT			= -1
	
	IF @PP_ITEM_NO LIKE 'I%'
	BEGIN	
		SET	@VP_ITEM_NO_DE_RMA		= 	ISNULL(	(	SELECT	TOP(1)	RTRIM(LTRIM(ITEM_NO))
													FROM	CCPRDSTR_SQL (NOLOCK)
													WHERE	CUS_NO			= @PP_CUS_NO		
													AND		MODELNO			= @PP_MODELNO		
													AND		VERSIONNO		= @PP_VERSIONNO	
													AND		COMP_ITEM_NO	= @PP_ITEM_NO	),'')
		IF @VP_ITEM_NO_DE_RMA	<>''
		BEGIN
			SELECT	@VP_REVISION_NO_DE_RMA	= ISNULL(REVISION_HOJA_EMPAQUE,-1)
			FROM	HOJA_EMPAQUE
			WHERE	CUS_NO			= @PP_CUS_NO		
			AND		MODELNO			= @PP_MODELNO		
			AND		VERSIONNO		= @PP_VERSIONNO	
			AND		ITEM_NO			= @VP_ITEM_NO_DE_RMA	
			ORDER BY REVISION_HOJA_EMPAQUE	DESC
		END
	END

	IF	@VP_ITEM_NO_DE_RMA <> ''
	BEGIN
		SET	@PP_ITEM_NO					=	@VP_ITEM_NO_DE_RMA
		SET	@PP_REVISION_HOJA_EMPAQUE	=	@VP_REVISION_NO_DE_RMA
	END

	IF	@PP_ITEM_NO LIKE 'P%'
	BEGIN
		SELECT	@VP_U_ITEM		= ISNULL(ITEM_NO,'')
		FROM	IMKITFIL_SQL	(NOLOCK)
		WHERE	COMP_ITEM_NO						= @PP_ITEM_NO
		AND		LEFT(LTRIM(RTRIM(FILLER_0004)),3)	= @PP_MODELNO
		AND		RIGHT(LTRIM(RTRIM(FILLER_0004)),4)	= FORMAT(@PP_VERSIONNO,'0000')
	END

	IF	@PP_ITEM_NO LIKE 'U%'	--OR	@VP_U_ITEM <> ''
	BEGIN
		--IF	@VP_U_ITEM = ''
		--BEGIN
			SET	@VP_U_ITEM	= @PP_ITEM_NO
	END

	IF @VP_U_ITEM=''
	BEGIN
		INSERT INTO	@VP_TA_ITEM_P
		SELECT		@PP_ITEM_NO
	END	
		
		DECLARE	@VP_TABLE_U	AS TABLE
		(	N_CAPA				NVARCHAR(MAX),
			N_PATRONES_CAPA		NVARCHAR(MAX),
			RUTA_SERVIDOR		NVARCHAR(MAX)
		)

		IF @VP_U_ITEM<>''
		BEGIN
			INSERT INTO @VP_TABLE_U
			SELECT		N_CAPA,
						N_PATRONES_CAPA,
						LTRIM(RTRIM(RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR))	+
						'REPORTES\'	+ 
						LTRIM(RTRIM(RUTA_HOJA_EMPAQUE_CAPA_MODELO))		+ 
						LTRIM(RTRIM(RUTA_HOJA_EMPAQUE_CAPA_IMAGEN))		+ 
						LTRIM(RTRIM(RUTA_HOJA_EMPAQUE_CAPA_EXTENSION))
			FROM		HOJA_EMPAQUE_CAPA					(NOLOCK)
			WHERE		CUS_NO			= @PP_CUS_NO		
			AND			MODELNO			= @PP_MODELNO		
			AND			VERSIONNO		= @PP_VERSIONNO	
			AND			U_ITEM			=	@VP_U_ITEM			
			AND			REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
			ORDER	BY	N_CAPA ASC			

			--SELECT * FROM @VP_TABLE_U
		END
		ELSE
		BEGIN
			INSERT INTO @VP_TABLE_U
			SELECT		N_CAPA,
						N_PATRONES_CAPA,
						LTRIM(RTRIM(RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR))	+
						'REPORTES\'	+ 
						LTRIM(RTRIM(RUTA_HOJA_EMPAQUE_CAPA_MODELO))		+ 
						LTRIM(RTRIM(RUTA_HOJA_EMPAQUE_CAPA_IMAGEN))		+ 
						LTRIM(RTRIM(RUTA_HOJA_EMPAQUE_CAPA_EXTENSION))
			FROM		HOJA_EMPAQUE_CAPA					(NOLOCK)
			WHERE		CUS_NO			= @PP_CUS_NO		
			AND			MODELNO			= @PP_MODELNO		
			AND			VERSIONNO		= @PP_VERSIONNO	
			--AND			ITEM_P			IN	(	SELECT LEFT(TA_ITEM_P, 7)FROM @VP_TA_ITEM_P	)
			AND			ITEM_NO			IN	(	SELECT TA_ITEM_P	FROM	@VP_TA_ITEM_P	)
			AND			REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
			ORDER	BY	N_CAPA ASC
		END
	DECLARE CU_CURSOR_PROCES	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
		SELECT	* 
		FROM	@VP_TABLE_U
	OPEN CU_CURSOR_PROCES
		FETCH NEXT FROM  CU_CURSOR_PROCES INTO   @VP_CU_N_CAPA		,@VP_CU_N_PATRONES	,@VP_CU_R_AV_CAPA
		WHILE @@FETCH_STATUS=0
		BEGIN
			--SELECT  @VP_CU_N_CAPA		,@VP_CU_N_PATRONES	,@VP_CU_R_AV_CAPA
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
			IF @VP_CONTA	= 2		--AND	@VP_CU_N_CAPA	= 2
			BEGIN
				UPDATE	@TA_CAPA
				SET		--TA_N_CAPA_2			= @VP_CU_N_CAPA		,
						TA_N_PATRONES_2		= @VP_CU_N_PATRONES	,
						TA_R_AV_CAPA_2		= @VP_CU_R_AV_CAPA	
			END
			IF @VP_CONTA	= 3	--AND	@VP_CU_N_CAPA	= 3
			BEGIN
				UPDATE	@TA_CAPA
				SET		--TA_N_CAPA_3			= @VP_CU_N_CAPA		,
						TA_N_PATRONES_3		= @VP_CU_N_PATRONES	,
						TA_R_AV_CAPA_3		= @VP_CU_R_AV_CAPA	
			END
			IF @VP_CONTA	= 4	--AND	@VP_CU_N_CAPA	= 4
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
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_HOJA_EMPAQUE_MODELO_MASTER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_MODELO_MASTER]
GO
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_MODELO_MASTER] 0,139,'FAUR01','FW2'
--		 EXECUTE [dbo].[PG_LI_HOJA_EMPAQUE_MODELO_MASTER] 0,139,'DAIM05','WDK'
CREATE PROCEDURE [dbo].[PG_LI_HOJA_EMPAQUE_MODELO_MASTER]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_CUS_NO						VARCHAR(20),
	@PP_MODELNO						VARCHAR(25)
AS
	SELECT	 CUS_NO
			,MODELNO
			,VERSIONNO
			,ITEM_NO						AS ITEM_P
			,LTRIM(RTRIM(D_ITEM_NO))		AS D_ITEM_NO
			,REVISION_HOJA_EMPAQUE
			,CAJA_HOJA_EMPAQUE
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
			END)							AS L_LIVE
			,L_REVISION_ACTIVA
			,(	CASE	
					WHEN	L_CAPAS_COMPLETAS	= 0	THEN 'NO'
					WHEN	L_CAPAS_COMPLETAS	= 1	THEN 'SI'
			END)							AS L_CAPAS_COMPLETAS
			,(	CASE
					WHEN	U_ITEM	<> ''	THEN	'SI'
					ELSE	'NO'
			END)							AS L_U_ITEM
			,ISNULL(U_ITEM,'--------')		AS U_ITEM
			,STANDAR_PACK
			,C_HOJA_EMPAQUE
	FROM	[HOJA_EMPAQUE]		(NOLOCK)
	WHERE	( CUS_NO		= @PP_CUS_NO  )
	AND		( MODELNO		= @PP_MODELNO )
	ORDER	BY CUS_NO	,MODELNO	,VERSIONNO DESC, U_ITEM DESC, ITEM_P, L_REVISION_ACTIVA DESC
--	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_HOJA_EMPAQUE]
GO
 --		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE] 0,139, 'IRVI02' , 'JLI' , '0059' , 'PJLFBR2MCKTX7' , '0' 
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE] 0,139, 'YANG02' , 'WL5' , '0004' , 'PYFRBOLYPAWT5' , '0' 
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE] 0,139, 'YANG02' , 'WL5' , '0004' , 'PYFRBOLYPATX7' , '0' 
--		 EXECUTE [DBO].[PG_SK_HOJA_EMPAQUE] 0,139, 'MAGN02' , 'WAL' , '0014' , 'PWALBR2WLROX7' , '0'
-- ===================================================================================================
--		 EXECUTE [DBO].[PG_SK_HOJA_EMPAQUE] 0,139, 'IRVI02' , 'JSU' , '0015' , 'PMJSFSCNPJSA5' , '0'
--		 EXECUTE [DBO].[PG_SK_HOJA_EMPAQUE] 0,139, 'MAGN02' , 'WAL' , '15' , 'PWALBR2WLROX7  ' , '0'   
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

	SELECT	@CB_ARCUSFIL_PROGRAM		= RTRIM(LTRIM(PROD_CAT_DESC))
	FROM	ARCUSFIL_PROGRAM_MODEL		(NOLOCK)
	WHERE	S_ARCUSFIL_PROGRAM_MODEL	= @PP_MODELNO

	SELECT		TOP (1)
				ITEM_NO					AS ITEM_NO_P,
				--(	CASE
				--		WHEN	MODELNO	= 'WL5'	THEN	ITEM_NO
				--		ELSE	ITEM_P
				--END)					AS ITEM_NO_P,
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
	WHERE		HOJA_EMPAQUE.ITEM_NO		= @PP_ITEM_P
	--WHERE		@PP_ITEM_P	=	(	CASE
	--									WHEN	MODELNO	= 'WL5'	THEN	HOJA_EMPAQUE.ITEM_NO
	--									ELSE	HOJA_EMPAQUE.ITEM_P
	--							END)
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
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'MAGN02'	, 'WAL'	, '14',	'PWALBR2WLROT3', 0,	'Table 36'
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'MAGN02'	, 'WAL'	, '14',	'PWLAFCRWLCPX7', 0,	'Table 36'
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'MAGN02'	, 'WAL'	, '14',	'PWALBRRWLCPT3', 0,	'Table 36'
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'MAGN03'	, 'WD2'	, '16',	'UW2SRB6CNPJRR', 0,	''
---	============================================================================================================================================================
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'MAGN02'	, 'W7E'	, '10',	'PLEB60HWLPAX7', 0,	'TABLE 59', 53986
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'MAGN02'	, 'WTL'	, '16',	'IWTL0085WLNPX7', 0,'TABLE 78', 54730
---	============================================================================================================================================================
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'FAUR01'	, 'C3B'	, '8',	'PWSARB6VCCPD4', 0,'', 0
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'FAUR01'	, 'C3A'	, '8',	'PWSBRB6VCCax7', 0,'Table 80', 54088
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_REPORTE] 0,139, 'FAUR01'	, 'C3B'	, '8',	'PWSBRB6VCCax7', 0,'Table 80', 54088
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
	@PP_MESA						VARCHAR(50),
	@PP_ORDEN						VARCHAR(50)	= ''
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


	DECLARE  @VP_ITEM_NO_DE_RMA			VARCHAR(50)	= ''
			,@VP_REVISION_NO_DE_RMA		INT			= -1
	
	IF @PP_ITEM_NO LIKE 'I%'
	BEGIN	
		SET	@VP_ITEM_NO_DE_RMA		= 	ISNULL(	(	SELECT	TOP(1)	RTRIM(LTRIM(ITEM_NO))
												FROM	CCPRDSTR_SQL (NOLOCK)
												WHERE	CUS_NO			= @PP_CUS_NO		
												AND		MODELNO			= @PP_MODELNO		
												AND		VERSIONNO		= @PP_VERSIONNO	
												AND		COMP_ITEM_NO	= @PP_ITEM_NO	),'')
		IF @VP_ITEM_NO_DE_RMA	<>''
		BEGIN
			SELECT	@VP_REVISION_NO_DE_RMA	= ISNULL(REVISION_HOJA_EMPAQUE,-1)
			FROM	HOJA_EMPAQUE
			WHERE	CUS_NO			= @PP_CUS_NO		
			AND		MODELNO			= @PP_MODELNO		
			AND		VERSIONNO		= @PP_VERSIONNO	
			AND		ITEM_NO			= @VP_ITEM_NO_DE_RMA	
			ORDER BY REVISION_HOJA_EMPAQUE	DESC
		END
	END

	IF	@VP_ITEM_NO_DE_RMA <> ''
	BEGIN
		SET	@PP_ITEM_NO					=	@VP_ITEM_NO_DE_RMA
		SET	@PP_REVISION_HOJA_EMPAQUE	=	@VP_REVISION_NO_DE_RMA
	END

	IF	@PP_ITEM_NO LIKE 'P%'
	BEGIN
		SELECT	@VP_U_ITEM		= ISNULL(LTRIM(RTRIM(ITEM_NO)),'')
		FROM	IMKITFIL_SQL	(NOLOCK)
		WHERE	LTRIM(RTRIM(COMP_ITEM_NO))			= @PP_ITEM_NO
		AND		LEFT(LTRIM(RTRIM(FILLER_0004)),3)	= @PP_MODELNO
		AND		RIGHT(LTRIM(RTRIM(FILLER_0004)),4)	= FORMAT(@PP_VERSIONNO,'0000')
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
		WHERE	LTRIM(RTRIM(ITEM_NO))				= @VP_U_ITEM
		AND		LEFT(LTRIM(RTRIM(FILLER_0004)),3)	= @PP_MODELNO
		AND		RIGHT(LTRIM(RTRIM(FILLER_0004)),4)	= FORMAT(@PP_VERSIONNO,'0000')
		ORDER	BY COMP_ITEM_NO	ASC

		SELECT	TOP(1)
				@VP_U_IT_2		= COMP_ITEM_NO
		FROM	IMKITFIL_SQL	(NOLOCK)
		WHERE	LTRIM(RTRIM(ITEM_NO))				= @VP_U_ITEM
		AND		LEFT(LTRIM(RTRIM(FILLER_0004)),3)	= @PP_MODELNO
		AND		RIGHT(LTRIM(RTRIM(FILLER_0004)),4)	= FORMAT(@PP_VERSIONNO,'0000')
		ORDER	BY COMP_ITEM_NO	DESC

		SET	@VP_U_PART		=	( SELECT LTRIM(RTRIM(LANDED_COST_CD))	FROM IMITMIDX_SQL (NOLOCK) WHERE ITEM_NO = @VP_U_ITEM )
		SET	@VP_U_DT_1		=	( SELECT LTRIM(RTRIM(search_desc))		FROM IMITMIDX_SQL (NOLOCK) WHERE LTRIM(RTRIM(ITEM_NO)) = ('F' + RIGHT(LTRIM(RTRIM(@VP_U_IT_1)),6))	) --COLOR )
		SET	@VP_U_DT_2		=	( SELECT LTRIM(RTRIM(search_desc))		FROM IMITMIDX_SQL (NOLOCK) WHERE LTRIM(RTRIM(ITEM_NO)) = ('F' + RIGHT(LTRIM(RTRIM(@VP_U_IT_2)),6))	) --COLOR )
	END

	DECLARE	@VP_RMA		VARCHAR(50) = ''
	IF	@PP_ORDEN	<> '' OR @PP_ORDEN > 0
	BEGIN
		IF (	SELECT	COUNT(K_HEADER_RMA)
				FROM	HEADER_RMA	(NOLOCK)
				WHERE	JOBNO	LIKE	'%' + @PP_ORDEN + '%'	) > 0
		BEGIN
			SET	@VP_RMA	= 'R'
		END
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
				@PP_ORDEN												AS ORDEN,
				@VP_RMA													AS RMA,
				@PP_K_USUARIO_ACCION									AS K_USUARIO,
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
	FROM		HOJA_EMPAQUE			(NOLOCK) 
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
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_HOJA_EMPAQUE_COMPLETA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_HOJA_EMPAQUE_COMPLETA]
GO
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_COMPLETA] 0,139, 'MAGN03' , 'WD2' , '0016' , 'PW2RB60', 0
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_COMPLETA] 0,139, 'MAGN02' , 'WAL' , '0014' , 'UWALFBRWLCPX7', 0		
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_COMPLETA] 0,139, 'MAGN02' , 'WTL' , '0016' , 'IWTL0085WLNPX7',0
--		 EXECUTE [dbo].[PG_SK_HOJA_EMPAQUE_COMPLETA] 0,139, 'MAGN02' , 'WTL' , '0016' , 'PWLFB2RWLNPX7', 0
CREATE PROCEDURE [dbo].[PG_SK_HOJA_EMPAQUE_COMPLETA]
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
	--DECLARE  @K_ARCUSFIL			INT
	--		,@K_ARCUSFIL_PROGRAM	INT
	--		,@CB_ARCUSFIL_PROGRAM	VARCHAR(250)

	--SELECT	@CB_ARCUSFIL_PROGRAM		= RTRIM(LTRIM(PROD_CAT_DESC))
	--FROM	ARCUSFIL_PROGRAM_MODEL		(NOLOCK)
	--WHERE	S_ARCUSFIL_PROGRAM_MODEL	= @PP_MODELNO
	DECLARE  @VP_ITEM_NO_DE_RMA			VARCHAR(50)	= ''
			,@VP_REVISION_NO_DE_RMA		INT			= -1
	
	IF @PP_ITEM_NO LIKE 'I%'
	BEGIN	
		SET	@VP_ITEM_NO_DE_RMA		= 	ISNULL(	(	SELECT	TOP(1)	RTRIM(LTRIM(ITEM_NO))
												FROM	CCPRDSTR_SQL (NOLOCK)
												WHERE	CUS_NO			= @PP_CUS_NO		
												AND		MODELNO			= @PP_MODELNO		
												AND		VERSIONNO		= @PP_VERSIONNO	
												AND		COMP_ITEM_NO	= @PP_ITEM_NO	),'')
		IF @VP_ITEM_NO_DE_RMA	<>''
		BEGIN
			SELECT	@VP_REVISION_NO_DE_RMA	= ISNULL(REVISION_HOJA_EMPAQUE,-1)
			FROM	HOJA_EMPAQUE
			WHERE	CUS_NO			= @PP_CUS_NO		
			AND		MODELNO			= @PP_MODELNO		
			AND		VERSIONNO		= @PP_VERSIONNO	
			AND		ITEM_NO			= @VP_ITEM_NO_DE_RMA	
			ORDER BY REVISION_HOJA_EMPAQUE	DESC
			--SET	@VP_REVISION_NO_DE_RMA	= 	ISNULL(	(	SELECT	REVISION_HOJA_EMPAQUE
			--											FROM	HOJA_EMPAQUE
			--											WHERE	CUS_NO			= @PP_CUS_NO		
			--											AND		MODELNO			= @PP_MODELNO		
			--											AND		VERSIONNO		= @PP_VERSIONNO	
			--											AND		ITEM_NO			= @VP_ITEM_NO_DE_RMA	
			--											ORDER BY REVISION_HOJA_EMPAQUE	DESC),-1)
		END
	END

	SELECT		TOP (1)
				'COMPLETA'				AS MENSAJE	--L_CAPAS_COMPLETAS
				-- =============================	
	FROM		HOJA_EMPAQUE			(NOLOCK) 
	INNER JOIN 	HOJA_EMPAQUE_STATUS		(NOLOCK) ON HOJA_EMPAQUE_STATUS.K_HOJA_EMPAQUE_STATUS	= HOJA_EMPAQUE.K_HOJA_EMPAQUE_STATUS
				-- =============================
	WHERE		(	CASE	
						WHEN	@PP_ITEM_NO LIKE 'I%'	THEN	@VP_ITEM_NO_DE_RMA
						ELSE	@PP_ITEM_NO
				END	)						=	(	CASE
														WHEN	@PP_ITEM_NO LIKE 'U%'	THEN	HOJA_EMPAQUE.U_ITEM
														ELSE	HOJA_EMPAQUE.ITEM_NO
												END	)	
	AND			HOJA_EMPAQUE.CUS_NO			= @PP_CUS_NO	
	AND			HOJA_EMPAQUE.MODELNO		= @PP_MODELNO	
	AND			HOJA_EMPAQUE.VERSIONNO		= @PP_VERSIONNO
	AND			REVISION_HOJA_EMPAQUE		=	(	CASE
														WHEN	@PP_ITEM_NO LIKE 'I%'	THEN	@VP_REVISION_NO_DE_RMA
														ELSE	@PP_REVISION_HOJA_EMPAQUE
												END	)
	AND			L_CAPAS_COMPLETAS			= 1
	AND			HOJA_EMPAQUE.L_BORRADO		<> 1
	-- ////////////////////////////////////////////////////////////////////
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
							[ITEM_NO]					,	[REVISION_HOJA_EMPAQUE]	,
							[ITEM_P]					,
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
							LEFT(@PP_ITEM_P,7)				,
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
					AND		[ITEM_NO]					= @PP_ITEM_P
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
									[ITEM_NO]					,	[REVISION_HOJA_EMPAQUE]	,
									[ITEM_P]					,
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
									LEFT(@PP_ITEM_P,7)				,
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
	DECLARE	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR				AS NVARCHAR(MAX)	=	'\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\'
	DECLARE	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR_REPORTE		AS NVARCHAR(MAX)	=	'\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\REPORTES\'

															 
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
			TA_TIPO_CAMBIO						INT,
			TA_ITEM_U							VARCHAR(50),
			TA_ITEM_NO							VARCHAR(50)		)
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
						,@VP_U_ITEM							VARCHAR(50)


				SELECT	---- ============================-- ============================
						@VP_CAJA_HOJA_EMPAQUE			=	ISNULL([CAJA_HOJA_EMPAQUE]	,'')	,
						@VP_REVISION_HOJA_EMPAQUE		=	ISNULL([REVISION_HOJA_EMPAQUE]	, 0),
						---- ============================-- ============================
						@VP_CANTIDAD_PATRONES			=	ISNULL([CANTIDAD_PATRONES]	,0)		,
						@VP_AREA_NETA					=	ISNULL([AREA_NETA]			,0)		,
						@VP_AREA_GROSS					=	ISNULL([AREA_GROSS]			,0)		,
						---- ============================-- ============================
						@VP_K_HOJA_EMPAQUE_CAPA_DIVISION	= [K_HOJA_EMPAQUE_CAPA_DIVISION]	,
						---- ============================-- ============================
						@VP_U_ITEM						=	ISNULL([U_ITEM]				,'')	,
						---- ============================-- ============================
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


				IF	(	@VP_U_ITEM	<> '' )	-- OR  ( NOT (@VP_U_ITEM IS NULL) )
				BEGIN
					DECLARE	@VP_K_QUOTE_TRIM_LEVEL		INT
					SELECT	@VP_K_QUOTE_TRIM_LEVEL	= K_QUOTE_TRIM_LEVEL
					FROM	COT19_Cotizaciones_V9999_R0.DBO.QUOTE_TRIM_LEVEL	(NOLOCK)
					WHERE	S_QUOTE_TRIM_LEVEL		= @PP_S_MODEL
					AND		VERSION_NO				= @PP_NO_VERSION	--@PP_NO_VERSION_ANTERIOR
					
					IF (	SELECT	COUNT(K_QUOTE_KIT_U)
							FROM	COT19_Cotizaciones_V9999_R0.DBO.QUOTE_KIT_U
							WHERE	K_QUOTE_TRIM_LEVEL		= @VP_K_QUOTE_TRIM_LEVEL
							AND		U_ITEM					= @VP_U_ITEM	) <= 0
					BEGIN
						SET @VP_MENSAJE = '[U_NUMBER]: Eliminado para el modelo/versión. [HE-UN]# ' + @VP_U_ITEM + ' // ' + @PP_S_MODEL + '//' + FORMAT(@PP_NO_VERSION,'0000') +CHAR(13)+CHAR(10) +
											'Informe a Sistemas....'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END
				END
				ELSE
				BEGIN
					SET	@VP_U_ITEM	= ''
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
					[U_ITEM]						,
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
						,@VP_CU_C_HOJA_EMPAQUE		,@VP_CU_L_REVISION_ACTIVA	--SIEMPRE VA EN 1, PORQUE ES LA REVISIÓN QUE SE ESTÁ ACTIVANDO.
						-- ============================
						,@VP_CU_K_HOJA_EMPAQUE_CAPA_DIVISION
						-- ============================
						,@VP_CU_K_TIPO_CAMBIO_KIT		
						-- ============================
						,@VP_U_ITEM
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
						TA_ITEM_P	,	TA_TIPO_CAMBIO	,	
						TA_ITEM_U	,	TA_ITEM_NO	)
				SELECT	 @VP_CU_CUS_NO	,@VP_CU_MODELNO	,@VP_CU_VERSIONNO	--@PP_NO_VERSION_ANTERIOR
						,@VP_REVISION_HOJA_EMPAQUE
						,@VP_CU_ITEM_P	,@VP_CU_K_TIPO_CAMBIO_KIT
						,@VP_U_ITEM		,@VP_CU_ITEM_NO
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE = '[INSERT]: No se insertó el registro. [HEC]# '+ @VP_CU_ITEM_NO + CHAR(13)+CHAR(10) +
														'Verifique....'
					RAISERROR (@VP_MENSAJE, 16, 1 ) 
				END						
	
				INSERT INTO HOJA_EMPAQUE_REGISTRO_CORREO
				(	[CUS_NO]	,	[MODELNO]			,
					[VERSIONNO]	,
					-- ============================
					[ITEM_NO]	,	[CUSTOMER_ITEM_NO]	,
					[D_ITEM_NO]	,	[U_ITEM]			,
					[D_TIPO_CAMBIO_KIT]		,
					[K_TIPO_MOVIMIENTO]		)
				SELECT
					@VP_CU_CUS_NO		,	@VP_CU_MODELNO			,	
					@VP_CU_VERSIONNO	,
					-- ============================
					@VP_CU_ITEM_NO		,	@VP_CU_CUSTOMER_ITEM_NO	,
					@VP_CU_D_ITEM_NO	,	@VP_U_ITEM				,
					--	//	#0: SIN CAMBIOS,	#1: DIMENSIONES,	#2: PROCESOS_ESPECIALES,	#3: VARIOS_CAMBIOS, #4 REVISIÓN	,	#5 NUEVO KIT
					-- ================================================================================================================
					(	CASE	
							WHEN	@VP_CU_K_TIPO_CAMBIO_KIT	= 0	THEN	'SIN CAMBIOS'
							WHEN	@VP_CU_K_TIPO_CAMBIO_KIT	= 1	THEN	'CAMBIOS EN #PATRONES / ÁREA(NET-GROSS)'
							WHEN	@VP_CU_K_TIPO_CAMBIO_KIT	= 5	THEN	'KIT NUEVO'
					END		),
					-- ================================================================================================================
					1	--	K_TIPO_MOVIMIENTO: #1 KIT	// #2 PROCESOS_ESPECIALES	// #3 TOTAL_PROCESOS_ESPECIALES
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE = '[INSERT]: No se insertó el registro. [HERC]# '+ @VP_CU_ITEM_NO + CHAR(13)+CHAR(10) +
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
				@VP_CU_2_K_TIPO_CAMBIO_KIT			INT,
				@VP_CU_2_ITEM_U						VARCHAR(50),
				@VP_CU_2_ITEM_NO					VARCHAR(50)
		
		--DECLARE @VP_TA_RUTAS_IMAGEN		AS TABLE
		--(	TA_RUTA_SERVR		NVARCHAR(MAX),
		--	TA_RUTA_LOCAL		NVARCHAR(MAX),
		--	TA_CREAR_CARP		NVARCHAR(MAX)	)
		DECLARE CU_CURSOR_CAPA	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
			SELECT	--DISTINCT(TA_ITEM_P) ,
					TA_ITEM_P	,
					TA_CUS_NO	,	TA_MODELNO	,	TA_VERSIONNO,	TA_REVISION_HOJA_EMPAQUE,	TA_TIPO_CAMBIO,	TA_ITEM_U,	TA_ITEM_NO
			FROM	@VP_TA_HOJA_CAPA
		OPEN CU_CURSOR_CAPA
			FETCH NEXT FROM  CU_CURSOR_CAPA INTO     @VP_CU_2_ITEM_P	,@VP_CU_2_CUS_NO	,@VP_CU_2_MODELNO	,@VP_CU_2_VERSIONNO	
													,@VP_CU_2_REVISION_HOJA_EMPAQUE	,@VP_CU_2_K_TIPO_CAMBIO_KIT,	@VP_CU_2_ITEM_U,	@VP_CU_2_ITEM_NO
			WHILE @@FETCH_STATUS=0
			BEGIN
			--	//	#0: SIN CAMBIOS,	#1: DIMENSIONES,	#2: PROCESOS_ESPECIALES,	#3: VARIOS_CAMBIOS, #4 REVISIÓN	,	#5 NUEVO KIT
				IF @VP_CU_2_K_TIPO_CAMBIO_KIT IN (0)
				BEGIN
					
					DECLARE	@VP_RUTA_CAPA_NUEVA	NVARCHAR(MAX)	= LTRIM(RTRIM(@VP_CU_2_CUS_NO)) +'\'+ LTRIM(RTRIM(@VP_CU_2_MODELNO)) +'\'+ LTRIM(RTRIM(@VP_CU_2_VERSIONNO)) + '\'
					DECLARE	@VP_RUTA_CAPA_ANTER	NVARCHAR(MAX)	= LTRIM(RTRIM(@VP_CU_2_CUS_NO)) +'\'+ LTRIM(RTRIM(@VP_CU_2_MODELNO)) +'\'+ LTRIM(RTRIM(@PP_NO_VERSION_ANTERIOR)) + '\'

					INSERT INTO [dbo].[HOJA_EMPAQUE_CAPA]
					(		 [CUS_NO]	,[MODELNO]	,[VERSIONNO]
							,[ITEM_P]	,[REVISION_HOJA_EMPAQUE]
							,[ITEM_NO]	,[U_ITEM]
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
							@VP_CU_2_ITEM_NO,	@VP_CU_2_ITEM_U,
							[N_CAPA],		[N_PATRONES_CAPA],
							--1,			0,
							--==================================
							[RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR],
							--[RUTA_HOJA_EMPAQUE_CAPA_MODELO]	 ,
							--LTRIM(RTRIM(@VP_CU_2_CUS_NO)) +'\'+ LTRIM(RTRIM(@VP_CU_2_MODELNO)) +'\'+ LTRIM(RTRIM(@VP_CU_2_VERSIONNO)) + '\',
							@VP_RUTA_CAPA_NUEVA,
							--==================================
							( CASE	
								WHEN	@VP_CU_2_MODELNO	= 'WL5'		THEN	LTRIM(RTRIM(@VP_CU_2_ITEM_NO)) +'_'+FORMAT(0,'000') +'_'+ CONVERT(VARCHAR(10),HOJA_EMPAQUE_CAPA.N_CAPA)
								WHEN	U_ITEM	<> ''					THEN	LTRIM(RTRIM(@VP_CU_2_ITEM_U)) +'_'+FORMAT(0,'000') +'_'+ CONVERT(VARCHAR(10),HOJA_EMPAQUE_CAPA.N_CAPA)
								ELSE	LTRIM(RTRIM(@VP_CU_2_ITEM_P)) +'_'+FORMAT(0,'000') +'_'+ CONVERT(VARCHAR(10),HOJA_EMPAQUE_CAPA.N_CAPA)
							END),
							--	@VP_CAPA_IMAGEN,	--[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]	 ,
							--==================================
							[RUTA_HOJA_EMPAQUE_CAPA_EXTENSION],
							--==================================
							@PP_K_USUARIO_ACCION,	GETDATE(),
							@PP_K_USUARIO_ACCION,	GETDATE()
					FROM	[dbo].[HOJA_EMPAQUE_CAPA]		(NOLOCK)
					WHERE	CUS_NO					= @PP_S_CUSTOMER
					AND		MODELNO					= @PP_S_MODEL		
					AND		VERSIONNO				= @PP_NO_VERSION_ANTERIOR
					AND		REVISION_HOJA_EMPAQUE	= @VP_CU_2_REVISION_HOJA_EMPAQUE
					--AND		ITEM_P					= @VP_CU_2_ITEM_P
					AND		ITEM_NO					= @VP_CU_2_ITEM_NO
					IF @@ROWCOUNT = 0
					BEGIN
						--SET @VP_MENSAJE = '[INSERT]: No se insertó el registro. (3)[HECP]# '+ @VP_CU_2_ITEM_NO + CHAR(13)+CHAR(10) + 'Verifique....'
						--RAISERROR (@VP_MENSAJE, 16, 1 ) 
						DECLARE @VP_TOLIVA VARCHAR(150)	= ''
					END
					ELSE
					BEGIN
						--	PARA EL REGISTRO NORMAL.
						--	SÓLO CUANDO EL KIT NO SUFRE CAMBIOS SE REALIZA LA COPIA DE LA IMAGEN. EN CASO CONTRARIO SERÁ NECESARIO INGRESARLA DESDE EL FRONT.
						INSERT INTO HOJA_EMPAQUE_RUTAS_IMAGEN	--@VP_TA_RUTAS_IMAGEN
						(	[CUS_NO]		,
							[MODELNO]		,
							[VERSIONNO]		,
						-- ============================
							[RUTA_SERVR]	,	
							[RUTA_LOCAL]	,
							[CREAR_CARP]	)
						SELECT	@VP_CU_2_CUS_NO,	
								@VP_CU_2_MODELNO,	
								@VP_CU_2_VERSIONNO,
						-- ========================================================================================================================================================================
						[RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR] + @VP_RUTA_CAPA_NUEVA + 
						( CASE	
							WHEN	@VP_CU_2_MODELNO	= 'WL5'		THEN	LTRIM(RTRIM(@VP_CU_2_ITEM_NO)) +'_'+FORMAT(0,'000') +'_'+ CONVERT(VARCHAR(10),HOJA_EMPAQUE_CAPA.N_CAPA)
							WHEN	U_ITEM	<> ''					THEN	LTRIM(RTRIM(@VP_CU_2_ITEM_U)) +'_'+FORMAT(0,'000') +'_'+ CONVERT(VARCHAR(10),HOJA_EMPAQUE_CAPA.N_CAPA)
							ELSE	LTRIM(RTRIM(@VP_CU_2_ITEM_P)) +'_'+FORMAT(0,'000') +'_'+ CONVERT(VARCHAR(10),HOJA_EMPAQUE_CAPA.N_CAPA)
						END)	+	'.PNG',
						-- ========================================================================================================================================================================
						[RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR] + @VP_RUTA_CAPA_ANTER +
						( CASE	
							WHEN	@VP_CU_2_MODELNO	= 'WL5'		THEN	LTRIM(RTRIM(@VP_CU_2_ITEM_NO)) +'_'+FORMAT(	ISNULL((	SELECT	TOP (1)	
																																			REVISION_HOJA_EMPAQUE
																																	FROM	[dbo].[HOJA_EMPAQUE_CAPA]
																																	WHERE	CUS_NO					= @PP_S_CUSTOMER
																																	AND		MODELNO					= @PP_S_MODEL		
																																	AND		VERSIONNO				= @PP_NO_VERSION_ANTERIOR
																																	AND		REVISION_HOJA_EMPAQUE	= @VP_CU_2_REVISION_HOJA_EMPAQUE
																																	--AND		ITEM_P					= @VP_CU_2_ITEM_P
																																	AND		ITEM_NO					= @VP_CU_2_ITEM_NO 
																																	ORDER BY  REVISION_HOJA_EMPAQUE DESC ),0)									
																			,'000') +'_'+ CONVERT(VARCHAR(10),HOJA_EMPAQUE_CAPA.N_CAPA)
							WHEN	U_ITEM	<> ''					THEN	LTRIM(RTRIM(@VP_CU_2_ITEM_U)) +'_'+FORMAT(	ISNULL((	SELECT	TOP (1)	
																																			REVISION_HOJA_EMPAQUE
																																	FROM	[dbo].[HOJA_EMPAQUE_CAPA]
																																	WHERE	CUS_NO					= @PP_S_CUSTOMER
																																	AND		MODELNO					= @PP_S_MODEL		
																																	AND		VERSIONNO				= @PP_NO_VERSION_ANTERIOR
																																	AND		REVISION_HOJA_EMPAQUE	= @VP_CU_2_REVISION_HOJA_EMPAQUE
																																	--AND		ITEM_P					= @VP_CU_2_ITEM_P
																																	ORDER BY  REVISION_HOJA_EMPAQUE DESC ),0)									
																			,'000') +'_'+ CONVERT(VARCHAR(10),HOJA_EMPAQUE_CAPA.N_CAPA)									
							ELSE	LTRIM(RTRIM(@VP_CU_2_ITEM_P)) +'_'+FORMAT(	ISNULL((	SELECT	TOP (1)	
																									REVISION_HOJA_EMPAQUE
																							FROM	[dbo].[HOJA_EMPAQUE_CAPA]
																							WHERE	CUS_NO					= @PP_S_CUSTOMER
																							AND		MODELNO					= @PP_S_MODEL		
																							AND		VERSIONNO				= @PP_NO_VERSION_ANTERIOR
																							AND		REVISION_HOJA_EMPAQUE	= @VP_CU_2_REVISION_HOJA_EMPAQUE
																							--AND		ITEM_P					= @VP_CU_2_ITEM_P
																							ORDER BY  REVISION_HOJA_EMPAQUE DESC ),0)
																			,'000') +'_'+ CONVERT(VARCHAR(10),HOJA_EMPAQUE_CAPA.N_CAPA)
							END)	+	'.PNG',
							@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	+ @VP_RUTA_CAPA_NUEVA
						FROM	[dbo].[HOJA_EMPAQUE_CAPA]		(NOLOCK)
						WHERE	CUS_NO					= @PP_S_CUSTOMER
						AND		MODELNO					= @PP_S_MODEL		
						AND		VERSIONNO				= @VP_CU_2_VERSIONNO
						AND		REVISION_HOJA_EMPAQUE	= @VP_CU_2_REVISION_HOJA_EMPAQUE	--0
						--AND		ITEM_P					= @VP_CU_2_ITEM_P
						AND		ITEM_NO					= @VP_CU_2_ITEM_NO						
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El registro de la ruta no fue ingresado. [HECI# '+CONVERT(VARCHAR(10),@VP_CU_2_ITEM_P) + ']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END
						--	PARA LOS REPORTES DE IMPRESIÓN.
						--	SÓLO CUANDO EL KIT NO SUFRE CAMBIOS SE REALIZA LA COPIA DE LA IMAGEN. EN CASO CONTRARIO SERÁ NECESARIO INGRESARLA DESDE EL FRONT.
						INSERT INTO HOJA_EMPAQUE_RUTAS_IMAGEN	--@VP_TA_RUTAS_IMAGEN
						(	[CUS_NO]		,
							[MODELNO]		,
							[VERSIONNO]		,
						-- ============================
							[RUTA_SERVR]	,	
							[RUTA_LOCAL]	,
							[CREAR_CARP]	)
						SELECT	@VP_CU_2_CUS_NO,	
								@VP_CU_2_MODELNO,	
								@VP_CU_2_VERSIONNO,
						-- ========================================================================================================================================================================
						@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR_REPORTE + @VP_RUTA_CAPA_NUEVA + 
						( CASE	
							WHEN	@VP_CU_2_MODELNO	= 'WL5'		THEN	LTRIM(RTRIM(@VP_CU_2_ITEM_NO)) +'_'+FORMAT(0,'000') +'_'+ CONVERT(VARCHAR(10),HOJA_EMPAQUE_CAPA.N_CAPA)
							WHEN	U_ITEM	<> ''					THEN	LTRIM(RTRIM(@VP_CU_2_ITEM_U)) +'_'+FORMAT(0,'000') +'_'+ CONVERT(VARCHAR(10),HOJA_EMPAQUE_CAPA.N_CAPA)
							ELSE	LTRIM(RTRIM(@VP_CU_2_ITEM_P)) +'_'+FORMAT(0,'000') +'_'+ CONVERT(VARCHAR(10),HOJA_EMPAQUE_CAPA.N_CAPA)
						END)	+	'.PNG',
						-- ========================================================================================================================================================================
						@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR_REPORTE + @VP_RUTA_CAPA_ANTER +
						( CASE	
							WHEN	@VP_CU_2_MODELNO	= 'WL5'		THEN	LTRIM(RTRIM(@VP_CU_2_ITEM_NO)) +'_'+FORMAT(	ISNULL((	SELECT	TOP (1)	REVISION_HOJA_EMPAQUE
																																	FROM	[dbo].[HOJA_EMPAQUE_CAPA]
																																	WHERE	CUS_NO					= @PP_S_CUSTOMER
																																	AND		MODELNO					= @PP_S_MODEL		
																																	AND		VERSIONNO				= @PP_NO_VERSION_ANTERIOR
																																	AND		REVISION_HOJA_EMPAQUE	= @VP_CU_2_REVISION_HOJA_EMPAQUE
																																	--AND		ITEM_P					= @VP_CU_2_ITEM_P
																																	AND		ITEM_NO					= @VP_CU_2_ITEM_NO 
																																	ORDER BY  REVISION_HOJA_EMPAQUE DESC ),0)									
																			,'000') +'_'+ CONVERT(VARCHAR(10),HOJA_EMPAQUE_CAPA.N_CAPA)
							WHEN	U_ITEM	<> ''					THEN	LTRIM(RTRIM(@VP_CU_2_ITEM_U)) +'_'+FORMAT(	ISNULL((	SELECT	TOP (1)	REVISION_HOJA_EMPAQUE
																																	FROM	[dbo].[HOJA_EMPAQUE_CAPA]
																																	WHERE	CUS_NO					= @PP_S_CUSTOMER
																																	AND		MODELNO					= @PP_S_MODEL		
																																	AND		VERSIONNO				= @PP_NO_VERSION_ANTERIOR
																																	AND		REVISION_HOJA_EMPAQUE	= @VP_CU_2_REVISION_HOJA_EMPAQUE
																																	--AND		ITEM_P					= @VP_CU_2_ITEM_P
																																	ORDER BY  REVISION_HOJA_EMPAQUE DESC ),0)									
																			,'000') +'_'+ CONVERT(VARCHAR(10),HOJA_EMPAQUE_CAPA.N_CAPA)									
							ELSE	LTRIM(RTRIM(@VP_CU_2_ITEM_P)) +'_'+FORMAT(	ISNULL((	SELECT	TOP (1)	REVISION_HOJA_EMPAQUE
																							FROM	[dbo].[HOJA_EMPAQUE_CAPA]
																							WHERE	CUS_NO					= @PP_S_CUSTOMER
																							AND		MODELNO					= @PP_S_MODEL		
																							AND		VERSIONNO				= @PP_NO_VERSION_ANTERIOR
																							AND		REVISION_HOJA_EMPAQUE	= @VP_CU_2_REVISION_HOJA_EMPAQUE
																							--AND		ITEM_P					= @VP_CU_2_ITEM_P
																							ORDER BY  REVISION_HOJA_EMPAQUE DESC ),0)
																			,'000') +'_'+ CONVERT(VARCHAR(10),HOJA_EMPAQUE_CAPA.N_CAPA)
							END)	+	'.PNG',
							@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR_REPORTE	+ @VP_RUTA_CAPA_NUEVA
						FROM	[dbo].[HOJA_EMPAQUE_CAPA]		(NOLOCK)
						WHERE	CUS_NO					= @PP_S_CUSTOMER
						AND		MODELNO					= @PP_S_MODEL		
						AND		VERSIONNO				= @VP_CU_2_VERSIONNO
						AND		REVISION_HOJA_EMPAQUE	= @VP_CU_2_REVISION_HOJA_EMPAQUE	--0
						--AND		ITEM_P					= @VP_CU_2_ITEM_P
						AND		ITEM_NO					= @VP_CU_2_ITEM_NO	
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El registro de la ruta no fue ingresado. [HECI# '+CONVERT(VARCHAR(10),@VP_CU_2_ITEM_P) + ']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END

					END
					
				END
				ELSE IF @VP_CU_2_K_TIPO_CAMBIO_KIT IN (1)
				BEGIN
					INSERT INTO [dbo].[HOJA_EMPAQUE_CAPA]
					(		 [CUS_NO]	,[MODELNO]	,[VERSIONNO]
							,[ITEM_P]	,[REVISION_HOJA_EMPAQUE]
							,[N_CAPA]	,[N_PATRONES_CAPA]
							,[ITEM_NO]	,[U_ITEM]
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
							@VP_CU_2_ITEM_NO,	@VP_CU_2_ITEM_U,
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
				ELSE IF @VP_CU_2_K_TIPO_CAMBIO_KIT IN (5)
				BEGIN
					INSERT INTO [dbo].[HOJA_EMPAQUE_CAPA]
					(		 [CUS_NO]	,[MODELNO]	,[VERSIONNO]
							,[ITEM_P]	,[REVISION_HOJA_EMPAQUE]
							,[ITEM_NO]	,[U_ITEM]
							,[N_CAPA]	,[N_PATRONES_CAPA]
							,[RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR]
							,[RUTA_HOJA_EMPAQUE_CAPA_MODELO]
							,[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]
							,[RUTA_HOJA_EMPAQUE_CAPA_EXTENSION]
							,[K_USUARIO_ALTA]	,[F_ALTA]
							,[K_USUARIO_CAMBIO]	,[F_CAMBIO]			)
					SELECT	@VP_CU_2_CUS_NO,	@VP_CU_2_MODELNO,	@VP_CU_2_VERSIONNO,
							@VP_CU_2_ITEM_P,	0,
							@VP_CU_2_ITEM_NO,	@VP_CU_2_ITEM_U,
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
			FETCH NEXT FROM  CU_CURSOR_CAPA INTO     @VP_CU_2_ITEM_P	,@VP_CU_2_CUS_NO	,@VP_CU_2_MODELNO	,@VP_CU_2_VERSIONNO	
													,@VP_CU_2_REVISION_HOJA_EMPAQUE	,@VP_CU_2_K_TIPO_CAMBIO_KIT,	@VP_CU_2_ITEM_U,	@VP_CU_2_ITEM_NO
		END
		CLOSE		CU_CURSOR_CAPA
		DEALLOCATE	CU_CURSOR_CAPA	
	------------------------------------------------------------------------------
	------------------------------------------------------------------------------
	DECLARE	@VP_CU_X_ITEM_P						VARCHAR(50),
			@VP_CU_X_REVISION_HOJA_EMPAQUE		INT,
			@VP_CU_X_N_CAPA						INT

	DECLARE CU_CURSOR_CAPA_X	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
		--SELECT	DISTINCT (ITEM_P),
		SELECT	ITEM_NO,
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
										--AND		[ITEM_P]						= @VP_CU_X_ITEM_P
										AND		[ITEM_NO]						= @VP_CU_X_ITEM_P
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
			AND		ITEM_NO					= @VP_CU_X_ITEM_P
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
--		EXECUTE  [dbo].[PG_IN_HOJA_EMPAQUE_VERSION_PROCESO] 	0,139,	'FAUR01','FWS','0008'		--	PARA PRUEBAS DE ESTE SP
CREATE PROCEDURE [dbo].[PG_IN_HOJA_EMPAQUE_VERSION_PROCESO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_S_CUSTOMER				VARCHAR(6),
	@PP_S_MODEL					VARCHAR(3),
	@PP_NO_VERSION				INT
AS
DECLARE	 @VP_MENSAJE						NVARCHAR(MAX)
		,@VP_VERSION_ANTERIOR				INT
		,@VP_EXISTE_INFORMACION_PREVIA		INT	= 0
		
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

	DECLARE	@VP_TA_HOJA_PROCESO					AS TABLE
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
--SELECT	ITEM_P,	--	COUNT(K_HOJA_EMPAQUE_PROCESO)
SELECT	ITEM_NO,	--	COUNT(K_HOJA_EMPAQUE_PROCESO)
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
AND		HOJA_EMPAQUE_PROCESO.REVISION_HOJA_EMPAQUE	IN (	SELECT	TOP(1)
																	REVISION_HOJA_EMPAQUE
															FROM	HOJA_EMPAQUE	
															WHERE	HOJA_EMPAQUE.CUS_NO				= @PP_S_CUSTOMER		--	
															AND		HOJA_EMPAQUE.MODELNO			= @PP_S_MODEL			--	
															AND		HOJA_EMPAQUE.VERSIONNO			= @VP_VERSION_ANTERIOR	--
															--AND		HOJA_EMPAQUE.L_REVISION_ACTIVA	= 1		)
															ORDER BY REVISION_HOJA_EMPAQUE	DESC				)
AND		K_PROCESO						<> 50
ORDER	BY ITEM_NO	ASC, K_PROCESO	ASC

-- ==============================================================================================================

	SET	@VP_EXISTE_INFORMACION_PREVIA	= ( SELECT COUNT(TA_ITEM_NO) FROM  @VP_TA_HOJA_PROCESO )

-- ==============================================================================================================
	DECLARE CU_CURSOR	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
		--SELECT	DISTINCT	(LEFT(HOJA_EMPAQUE.ITEM_NO,7)) AS IT,
		SELECT	DISTINCT(HOJA_EMPAQUE.ITEM_NO) AS IT,
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
		AND		HOJA_EMPAQUE.MODELNO		= SPITMIDX_SQL.MODELNO
		AND		HOJA_EMPAQUE.VERSIONNO		= SPITMIDX_SQL.VERSIONNO
		AND		HOJA_EMPAQUE.ITEM_NO		= SPITMIDX_SQL.ITEM_NO_KIT
		WHERE	SPITMIDX_SQL.CUS_NO			= @PP_S_CUSTOMER	--	'MAGN03'
		AND		SPITMIDX_SQL.MODELNO		= @PP_S_MODEL		--	'WD2'
		AND		SPITMIDX_SQL.VERSIONNO		= FORMAT(@PP_NO_VERSION,'0000')	--	'0016'
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

		IF @VP_EXISTE_INFORMACION_PREVIA	> 0
		BEGIN
			SET	@VP_D_PROCESS	= ISNULL(	(	SELECT	TA_D_PROCESO
												FROM	@VP_TA_HOJA_PROCESO
												--WHERE	TA_CUS_NO		= @VP_CU_CUS_NO
												--AND		TA_MODELNO		= @VP_CU_MODELNO
												----AND		TA_VERSIONNO	= @VP_CU_VERSIONNO
												WHERE		TA_ITEM_NO		= @VP_CU_ITEM_NO
												AND			TA_K_PROCESO	= @VP_CU_K_PROCESO	)	,	'' )

			IF	@VP_D_PROCESS	<> @VP_CU_D_PROCESO
			BEGIN					
				INSERT INTO HOJA_EMPAQUE_REGISTRO_CORREO
				(	[CUS_NO]	,	[MODELNO]			,
					[VERSIONNO]	,
					-- ============================
					[ITEM_NO]	,	[CUSTOMER_ITEM_NO]	,
					[D_ITEM_NO]	,	[U_ITEM]			,
					[D_TIPO_CAMBIO_KIT]		,
					[K_TIPO_MOVIMIENTO]		)
				SELECT
					@VP_CU_CUS_NO		,	@VP_CU_MODELNO	,	
					@VP_CU_VERSIONNO	,
					-- ============================
					@VP_CU_ITEM_NO		,	''				,	-- @VP_CU_CUSTOMER_ITEM_NO	,
					@VP_D_PROCESS		,	@VP_CU_D_PROCESO,	-- @VP_CU_D_ITEM_NO	,	@VP_U_ITEM				,
					-- ================================================================================================================
					'CAMBIO DE NOMBRE EN PROCESO ESPECIAL'	,
					-- ================================================================================================================
					2	--	K_TIPO_MOVIMIENTO: #1 KIT	// #2 PROCESOS_ESPECIALES	// #3 TOTAL_PROCESOS_ESPECIALES
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE = '[INSERT]: No se insertó el registro. [HEpr]# '+ @VP_CU_ITEM_NO + CHAR(13)+CHAR(10) +	'Verifique....'
					RAISERROR (@VP_MENSAJE, 16, 1 ) 
				END
				
				SET	@VP_CU_D_PROCESO				= @VP_D_PROCESS
			END
			ELSE
			BEGIN
				INSERT INTO HOJA_EMPAQUE_REGISTRO_CORREO
				(	[CUS_NO]	,	[MODELNO]			,
					[VERSIONNO]	,
					-- ============================
					[ITEM_NO]	,	[CUSTOMER_ITEM_NO]	,
					[D_ITEM_NO]	,	[U_ITEM]			,
					[D_TIPO_CAMBIO_KIT]		,
					[K_TIPO_MOVIMIENTO]		)
				SELECT
					@VP_CU_CUS_NO		,	@VP_CU_MODELNO	,	
					@VP_CU_VERSIONNO	,
					-- ============================
					@VP_CU_ITEM_NO		,	''				,	-- @VP_CU_CUSTOMER_ITEM_NO	,
					@VP_CU_D_PROCESO	,	''				,	-- @VP_CU_D_ITEM_NO	,	@VP_U_ITEM				,
					-- ================================================================================================================
					( CASE
						WHEN	@VP_D_PROCESS = '' THEN	'NUEVO PROCESO ESPECIAL'	
						ELSE	'SIN CAMBIOS'
					END ),
					-- ================================================================================================================
					2	--	K_TIPO_MOVIMIENTO: #1 KIT	// #2 PROCESOS_ESPECIALES	// #3 TOTAL_PROCESOS_ESPECIALES
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE = '[INSERT]: No se insertó el registro. [HEpr]# '+ @VP_CU_ITEM_NO + CHAR(13)+CHAR(10) +	'Verifique....'
					RAISERROR (@VP_MENSAJE, 16, 1 ) 
				END									   
			END
		END
		ELSE
		BEGIN
				INSERT INTO HOJA_EMPAQUE_REGISTRO_CORREO
				(	[CUS_NO]	,	[MODELNO]			,
					[VERSIONNO]	,
					-- ============================
					[ITEM_NO]	,	[CUSTOMER_ITEM_NO]	,
					[D_ITEM_NO]	,	[U_ITEM]			,
					[D_TIPO_CAMBIO_KIT]		,
					[K_TIPO_MOVIMIENTO]		)
				SELECT
					@VP_CU_CUS_NO		,	@VP_CU_MODELNO	,	
					@VP_CU_VERSIONNO	,
					-- ============================
					@VP_CU_ITEM_NO		,	''				,	-- @VP_CU_CUSTOMER_ITEM_NO	,
					@VP_CU_D_PROCESO	,	''				,	-- @VP_CU_D_ITEM_NO	,	@VP_U_ITEM				,
					-- ================================================================================================================
					'NUEVO PROCESO ESPECIAL'	,
					-- ================================================================================================================
					2	--	K_TIPO_MOVIMIENTO: #1 KIT	// #2 PROCESOS_ESPECIALES	// #3 TOTAL_PROCESOS_ESPECIALES
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE = '[INSERT]: No se insertó el registro. [HEpr2]# '+ @VP_CU_ITEM_NO + CHAR(13)+CHAR(10) +	'Verifique....'
					RAISERROR (@VP_MENSAJE, 16, 1 ) 
				END
		END
		-- ================================================================================================================
		-- ================================================================================================================
		-- ================================================================================================================
			--SET	@VP_L_HOJA_EMPAQUE_PROCESO	= ISNULL(	(	SELECT	TA_L_HOJA_EMPAQUE_PROCESO
			--												FROM	@VP_TA_HOJA_PROCESO
			--												--FROM	@VP_TA_HOJA_PROCESO_ANTERIOR
			--												--WHERE	TA_CUS_NO		= @VP_CU_CUS_NO
			--												--AND		TA_MODELNO		= @VP_CU_MODELNO
			--												--AND		TA_VERSIONNO	= @VP_CU_VERSIONNO
			--												WHERE	TA_ITEM_NO		= @VP_CU_ITEM_NO	
			--												AND		TA_K_PROCESO	= @VP_CU_K_PROCESO	)	,	0 )

			DECLARE	 @VL_L_HOJA_EMPAQUE_PROCESO		INT	= -1
					,@VL_K_PROCESO_SIMBOLO			INT = -1

			
			SET		@VL_L_HOJA_EMPAQUE_PROCESO	= ISNULL((	SELECT	TA_L_HOJA_EMPAQUE_PROCESO
															FROM	@VP_TA_HOJA_PROCESO
															WHERE	TA_ITEM_NO		= @VP_CU_ITEM_NO	
															AND		TA_K_PROCESO	= @VP_CU_K_PROCESO),-1)

			SET		@VL_K_PROCESO_SIMBOLO		= ISNULL((	SELECT	TA_K_PROCESO_SIMBOLO
															FROM	@VP_TA_HOJA_PROCESO
															WHERE	TA_ITEM_NO		= @VP_CU_ITEM_NO	
															AND		TA_K_PROCESO	= @VP_CU_K_PROCESO),-1)
					
			IF	@VL_L_HOJA_EMPAQUE_PROCESO	> 0
			BEGIN
				SET	@VP_CU_L_HOJA_EMPAQUE_PROCESO	= @VL_L_HOJA_EMPAQUE_PROCESO
			END

			IF	@VL_K_PROCESO_SIMBOLO	> 0
			BEGIN
				SET	@VP_CU_K_PROCESO_SIMBOLO	= @VL_K_PROCESO_SIMBOLO
			END

				INSERT INTO [HOJA_EMPAQUE_PROCESO] (
							--[K_HOJA_EMPAQUE]					,
							-- ============================
							[ITEM_NO]							,
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
							(LEFT(@VP_CU_ITEM_NO,7))			,
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
	-- ================================================================================================================
	-- ================================================================================================================
	-- ================================================================================================================
	--	SE INSERTAN LOS PROCESOS PERSONALIZADOS DEL MODELO ANTERIOR
	IF @VP_EXISTE_INFORMACION_PREVIA	> 0
	BEGIN
		INSERT INTO [HOJA_EMPAQUE_PROCESO] (
			-- ============================
			[ITEM_NO]							,
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
			SELECT	ITEM_NO,		--	COUNT(K_HOJA_EMPAQUE_PROCESO)
					LEFT(ITEM_NO,7),
				-- ============================
					CUS_NO,
					MODELNO,
					@PP_NO_VERSION,					--	VERSIONNO,
					0,								--	REVISION_HOJA_EMPAQUE,
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
			AND		HOJA_EMPAQUE_PROCESO.REVISION_HOJA_EMPAQUE	IN (	SELECT	TOP(1)
																				REVISION_HOJA_EMPAQUE
																		FROM	HOJA_EMPAQUE	
																		WHERE	HOJA_EMPAQUE.CUS_NO				= @PP_S_CUSTOMER		--	
																		AND		HOJA_EMPAQUE.MODELNO			= @PP_S_MODEL			--	
																		AND		HOJA_EMPAQUE.VERSIONNO			= @VP_VERSION_ANTERIOR	--
																		--AND		HOJA_EMPAQUE.L_REVISION_ACTIVA	= 1		)
																		ORDER BY REVISION_HOJA_EMPAQUE	DESC				)
			AND		K_PROCESO						= 50
			ORDER	BY ITEM_NO	ASC, K_PROCESO	ASC
		--SELECT	
		--	TA_ITEM_NO							,
		--	LEFT(TA_ITEM_NO,7)					,
		--	-- ============================
		--	TA_CUS_NO							,
		--	TA_MODELNO							,
		--	TA_VERSIONNO						,
		--	TA_REVISION							,
		--	-- ============================
		--	TA_K_PROCESO						,
		--	TA_K_PROCESO_SIMBOLO				,
		--	-- ============================
		--	TA_L_HOJA_EMPAQUE_PROCESO			,
		--	-- ============================
		--	TA_D_PROCESO								
		--FROM	@VP_TA_HOJA_PROCESO
		--WHERE	TA_K_PROCESO	>= 50
	END
	-- ================================================================================================================
	-- ================================================================================================================
	-- ================================================================================================================
	DECLARE @VP_LEYENDA_INSERTA AS VARCHAR(500)	= ''

	IF (ISNULL(	(	SELECT	COUNT(K_HOJA_EMPAQUE_PROCESO)
					FROM	HOJA_EMPAQUE_PROCESO	(NOLOCK)
					WHERE	HOJA_EMPAQUE_PROCESO.CUS_NO		= @PP_S_CUSTOMER		--	
					AND		HOJA_EMPAQUE_PROCESO.MODELNO	= @PP_S_MODEL			--	
					AND		HOJA_EMPAQUE_PROCESO.VERSIONNO	= @VP_VERSION_ANTERIOR	--	
					AND		HOJA_EMPAQUE_PROCESO.REVISION_HOJA_EMPAQUE	IN (	SELECT	TOP(1)
																						REVISION_HOJA_EMPAQUE
																				FROM	HOJA_EMPAQUE	
																				WHERE	HOJA_EMPAQUE.CUS_NO				= @PP_S_CUSTOMER		--	
																				AND		HOJA_EMPAQUE.MODELNO			= @PP_S_MODEL			--	
																				AND		HOJA_EMPAQUE.VERSIONNO			= @VP_VERSION_ANTERIOR	--
																				--AND		HOJA_EMPAQUE.L_REVISION_ACTIVA	= 1	))	,0)	)	<>
																				ORDER BY REVISION_HOJA_EMPAQUE	DESC	))	,0)	)	
	<>	--SON DIFERENTES, ES PORQUE EXISTEN CAMBIOS.
	(ISNULL( (		SELECT	COUNT(K_HOJA_EMPAQUE_PROCESO)
					FROM	HOJA_EMPAQUE_PROCESO	(NOLOCK)
					WHERE	HOJA_EMPAQUE_PROCESO.CUS_NO		= @PP_S_CUSTOMER		--	
					AND		HOJA_EMPAQUE_PROCESO.MODELNO	= @PP_S_MODEL			--	
					AND		HOJA_EMPAQUE_PROCESO.VERSIONNO	= @PP_NO_VERSION	--	
					AND		HOJA_EMPAQUE_PROCESO.REVISION_HOJA_EMPAQUE	IN (	SELECT	TOP(1)
																						REVISION_HOJA_EMPAQUE
																				FROM	HOJA_EMPAQUE	
																				WHERE	HOJA_EMPAQUE.CUS_NO				= @PP_S_CUSTOMER		--	
																				AND		HOJA_EMPAQUE.MODELNO			= @PP_S_MODEL			--	
																				AND		HOJA_EMPAQUE.VERSIONNO			= @PP_NO_VERSION))	,0)	)
																				--AND		HOJA_EMPAQUE.L_REVISION_ACTIVA	= 1	))	,0)	)
	BEGIN		
		SET	@VP_LEYENDA_INSERTA	= 	'EL MODELO NO SUFRIÓ CAMBIOS EN LA CANTIDAD DE PROCESOS ESPECIALES'
	END
	ELSE
	BEGIN
		SET	@VP_LEYENDA_INSERTA	= 	'SIN CAMBIOS EN CANTIDAD DE PROCESOS ESPECIALES'
	END

		INSERT INTO HOJA_EMPAQUE_REGISTRO_CORREO
		(	[CUS_NO]	,	[MODELNO]			,
			[VERSIONNO]	,
			-- ============================
			[ITEM_NO]	,	[CUSTOMER_ITEM_NO]	,
			[D_ITEM_NO]	,	[U_ITEM]			,
			[D_TIPO_CAMBIO_KIT]		,
			[K_TIPO_MOVIMIENTO]		)
		SELECT
			@PP_S_CUSTOMER		,	@PP_S_MODEL		,
			@PP_NO_VERSION		,
			-- ============================
			''					,	''				,	-- @VP_CU_CUSTOMER_ITEM_NO	,
			''					,	''				,	-- @VP_CU_D_ITEM_NO	,	@VP_U_ITEM				,
			-- ================================================================================================================
			@VP_LEYENDA_INSERTA	,
			-- ================================================================================================================
			3	--	K_TIPO_MOVIMIENTO: #1 KIT	// #2 PROCESOS_ESPECIALES	// #3 TOTAL_PROCESOS_ESPECIALES
		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE = '[INSERT]: No se insertó el registro. [HEpr]# '+ @VP_CU_ITEM_NO + CHAR(13)+CHAR(10) +	'Verifique....'
			RAISERROR (@VP_MENSAJE, 16, 1 ) 
		END	
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
-- // SISTEMA DE PRODUCTIVO			20220117
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

	--DELETE	HOJA_EMPAQUE_RUTAS_IMAGEN
	--WHERE	CUS_NO		= @PP_S_CUSTOMER	
	--AND		MODELNO		= @PP_S_MODEL		
	--AND		VERSIONNO	= @PP_NO_VERSION
			
	--DELETE	
	--FROM	DATA_02.DBO.HOJA_EMPAQUE_REGISTRO_CORREO
	--WHERE	CUS_NO				= @PP_S_CUSTOMER
	--AND		MODELNO				= @PP_S_MODEL		
	--AND		VERSIONNO			= @PP_NO_VERSION
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> UPDATE / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_HOJA_EMPAQUE]
GO
---	PRUEBAS DE U´s
----	EXECUTE  [dbo].[PG_UP_HOJA_EMPAQUE]	0,139,'0' , 'MAGN03' , 'WD2' , '16' , 'PWDRC60' , 'M02522-05' , '' , '0' , 10 , '' , 3 ,																																		
----	'1/2' , '5/5' , ' / ' , 'P:\Quality\EXCEL AYUDAS VISUALES\IMAGENES\HOJAS DE EMPAQUE SIST\MAGNA\WD\ml\2t jrr - dx9\REAR CUSHION 60% 1.PNG/P:\Quality\EXCEL AYUDAS VISUALES\IMAGENES\HOJAS DE EMPAQUE SIST\MAGNA\WD\ml\2t jrr - dx9\REAR CUSHION 60% 2.PNG' , 
----	'-1/-1' , '1642/1643/-1' , '3/7/50' , '2/0/29' , '1/0/1' , 'AXIS II/SHAVING/COLOR DX9' 

----	EXECUTE  [dbo].[PG_UP_HOJA_EMPAQUE]	0,139,	
----	'0' , 'YANG02' , 'WL5' , '4' , 'PYFRBOLYPAWT5' , 'M04316-08' , '' , '0' , 6 , '' , 3 , '1/2' , '3/3' , '\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\YANG02\WL5\4\PYFRBOLYPAWT5_000_1.PNG/\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\YANG02\WL5\4\PYFRBOLYPAWT5_000_2.PNG' , '\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\YANG02\WL5\4\PYFRBOLYPAWT5_000_1.PNG/\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\YANG02\WL5\4\PYFRBOLYPAWT5_000_2.PNG' , '1090/1091' , '2242/2243/2244/2245' , '1/2/4/50' , '0/1/0/48' , '1/0/0/1' , 'SKIVING 1.0 ± 0.1 MM/FOAM 3.1 MM/RECUT/PAQUETES DE 20 PIEZAS' 

----	EXECUTE  [dbo].[PG_UP_HOJA_EMPAQUE]	0,139,	
----	'0' , 'MAGN03' , 'WDM' , '20' , 'PWD2RC6CNPDX9' , '' , '' , '0' , 10 , '' , 2 , '1/2' , '5/5' , ' / ' , ' / ' , '-1/-1' , '5244/5247' , '3/7' , '2/0' , '1/0' , 'AXIS II/SHAVING' 

 ----	EXECUTE  [dbo].[PG_UP_HOJA_EMPAQUE]	0,139,'0' , 'MAGN03' , 'WD2' , '16' , 'PWD2TCLCNPJRR' , '' , '' , '0' , 7 , '' , 2 , 
 ----	'1/2' , '4/3' , ' / ' , 'C:\Users\ALEJANDROD\Desktop\U1_2T.png/C:\Users\ALEJANDROD\Desktop\U2_2T.png' , 
 ----	'-1/-1' , '5675/5676/6205' , '3/7/2' , '2/0/1' , '1/0/1' , 'AXIS II/SHAVING/TK1080' 

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
	@PP_ITEM_NO							VARCHAR(50),	-- ES EL P DEL ITEM_NO
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
		,@VP_ITEM_P							VARCHAR(50)
-- /////////////////////////////////////////////////////////////////////
BEGIN TRANSACTION 
BEGIN TRY

	SET		@VP_ITEM_P			= LEFT(LTRIM(RTRIM(@PP_ITEM_NO)),7)
	SET		@VP_CANTIDAD_CAPAS	= (	CASE
										WHEN	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION	IN (1)			THEN	1
										WHEN	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION	IN (2,3)		THEN	2
										WHEN	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION	IN (4,5,6,7)	THEN	3
										WHEN	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION	IN (8)			THEN	4
										ELSE	0
									END )	
	-- =======================================================================================================================
	--	DECLARACIÓN DE VARIABLES DE USO GENERAL.
	-- =======================================================================================================================	
	DECLARE	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR				AS NVARCHAR(MAX)	=	'\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\'
	DECLARE	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR_REPORTE		AS NVARCHAR(MAX)	=	'\\10.1.1.5\documents\Common\APQP\AV_CUSTOMER\AV_HE\REPORTES\'
	DECLARE @VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO				AS NVARCHAR(MAX)	=	LTRIM(RTRIM(@PP_CUS_NO)) +'\'+ LTRIM(RTRIM(@PP_MODELNO)) +'\'+ LTRIM(RTRIM(@PP_VERSIONNO)) + '\'
	DECLARE @VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN				AS NVARCHAR(MAX)	=	''
	DECLARE @VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION			AS NVARCHAR(MAX)	=	'.PNG'
	DECLARE	@VP_RUTA_IMAGEN									AS NVARCHAR(MAX)	=	''
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
			--	SET @VP_MENSAJE='Función no habilitada informar a SISTEMAS. (Revisión)(N)[HE#'+CONVERT(VARCHAR(10),@PP_ITEM_NO )+']'
			--	RAISERROR (@VP_MENSAJE, 16, 1 ) 
		IF	(	SELECT	COUNT(K_HOJA_EMPAQUE)--,*	
				FROM	HOJA_EMPAQUE		(NOLOCK)
				WHERE	CUS_NO				=	@PP_CUS_NO		
				AND		MODELNO				=	@PP_MODELNO		
				AND		VERSIONNO			=	@PP_VERSIONNO	
				AND		[ITEM_NO]			=	@PP_ITEM_NO
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
													@PP_ITEM_NO							,-- ES EL P DEL ITEM_NO
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
			AND		(	CASE	
										WHEN	@PP_MODELNO	= 'WL5'	THEN	[ITEM_NO]
										ELSE	[ITEM_P]
					END	)							=	(	CASE	
																WHEN	@PP_MODELNO	= 'WL5'	THEN	@PP_ITEM_NO
																ELSE	@VP_ITEM_P
														END	)
			--AND		[ITEM_P]						= @PP_ITEM_P			
			AND		[REVISION_HOJA_EMPAQUE]			= @PP_REVISION_HOJA_EMPAQUE
			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='Registro no fue modificado. (0)(N)[HE#'+CONVERT(VARCHAR(10),@PP_ITEM_NO )+']'
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
					[U_ITEM]						,
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
					U_ITEM							,
					-- ============================
					@PP_K_USUARIO_ACCION			,	GETDATE()						,
					@PP_K_USUARIO_ACCION			,	GETDATE()						,
					0
			FROM	[HOJA_EMPAQUE]			(NOLOCK)
			WHERE	CUS_NO					= @PP_CUS_NO
			AND		MODELNO					= @PP_MODELNO
			AND		VERSIONNO				= @PP_VERSIONNO
			AND		(	CASE
							WHEN	MODELNO	= 'WL5'	THEN	@PP_ITEM_NO
							ELSE	@VP_ITEM_P	
					END	)							=	(	CASE
																	WHEN	MODELNO	= 'WL5'	THEN	HOJA_EMPAQUE.ITEM_NO
																	ELSE	HOJA_EMPAQUE.ITEM_P
														END	)
			--AND		ITEM_P					= @PP_ITEM_P
			AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='Registro no fue ingresado.(N)[HE#'+CONVERT(VARCHAR(10),@PP_ITEM_NO )+ ' // ' +CONVERT(VARCHAR(10),@VP_REVISION_NUEVA_HOJA_EMPAQUE) + ']'
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
				AND		ITEM_NO				=	@PP_ITEM_NO
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
													@PP_ITEM_NO							,-- ES EL P DEL ITEM_NO
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
			AND		(	CASE
							WHEN	MODELNO	= 'WL5'	THEN	@PP_ITEM_NO
							ELSE	@VP_ITEM_P	
					END	)							=	(	CASE
																	WHEN	MODELNO	= 'WL5'	THEN	HOJA_EMPAQUE.ITEM_NO
																	ELSE	HOJA_EMPAQUE.ITEM_P
														END	)
			--AND		[ITEM_P]						= @PP_ITEM_P
			AND		[REVISION_HOJA_EMPAQUE]			= @PP_REVISION_HOJA_EMPAQUE
			IF @@ROWCOUNT = 0
			BEGIN
				SET @VP_MENSAJE='Registro no fue modificado. [HE#'+CONVERT(VARCHAR(10),@PP_ITEM_NO )+']'
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
			,@VP_CU_ITEM_NO			VARCHAR(250)	= ''
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
				SET @VP_MENSAJE='Es necesario indicar una imagen para todas las capas activas de la Hoja de Empaque.(C)[Capa# '+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
				RAISERROR (@VP_MENSAJE, 16, 1 ) 
			END						
			--========================================================================================================================================
			IF @PP_L_NUEVA_REVISIÓN	= 0		-- SI EL KIT SÓLO SE ACTUALIZA Y NO SE DESEA GENERAR UNA NUEVA REVISIÓN.
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
							AND		[ITEM_NO]			=	@PP_ITEM_NO
							AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
							AND		U_ITEM				<> ''		) >= 1	-- ORDER BY VERSIONNO
					BEGIN
						DECLARE CU_CURSOR_U_ITEM	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
								SELECT	DISTINCT(ITEM_P)	--	K_HOJA_EMPAQUE
										,ITEM_NO
										,U_ITEM
								FROM	HOJA_EMPAQUE		(NOLOCK)
								WHERE	CUS_NO				=	@PP_CUS_NO			--	'MAGN02'	--
								AND		MODELNO				=	@PP_MODELNO			--	'WAL'		--
								AND		VERSIONNO			=	@PP_VERSIONNO		--	 (0014)	--
								AND		REVISION_HOJA_EMPAQUE		= @PP_REVISION_HOJA_EMPAQUE
								---AND		U_ITEM				<> ''
								AND		[U_ITEM]			IN (	SELECT	DISTINCT(U_ITEM) 
																	FROM	HOJA_EMPAQUE 
																	WHERE	CUS_NO				=  @PP_CUS_NO			--	'MAGN02'	--
																	AND		MODELNO				=  @PP_MODELNO			--	'WAL'		--
																	AND		VERSIONNO			=  @PP_VERSIONNO		--	 (0014)	--
																	AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
																	AND		ITEM_NO				=  @PP_ITEM_NO			--	'PWALBRR' --
																	--AND		ITEM_P				=  @VP_ITEM_P			--	'PWALBRR' --
																)
						OPEN CU_CURSOR_U_ITEM
						FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_ITEM_P, @VP_CU_ITEM_NO, @VP_CU_U_ITEM
						WHILE @@FETCH_STATUS=0
						BEGIN

							IF (	SELECT	COUNT(K_HOJA_EMPAQUE_CAPA)
									FROM	HOJA_EMPAQUE_CAPA
									WHERE	CUS_NO					=	@PP_CUS_NO			
									AND		MODELNO					=	@PP_MODELNO			
									AND		VERSIONNO				=	@PP_VERSIONNO		
									AND		ITEM_NO					=	@VP_CU_ITEM_NO
									AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE			
									AND		N_CAPA					=	@VP_VALOR_N_CAPA	) >= 1
							BEGIN
								-- =======================================================================================================================
								--	ACTUALIZA LA INFORMACIÓN DE LAS CAPAS.
								-- =======================================================================================================================
								UPDATE	[HOJA_EMPAQUE_CAPA]
								SET		-- ========================== 
										--[N_CAPA]					= @VP_VALOR_N_CAPA,
										[N_PATRONES_CAPA]					= @VP_VALOR_N_PATR,
										[RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR]	= @VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	,
										[RUTA_HOJA_EMPAQUE_CAPA_MODELO]		= @VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO		,
										[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]		= @VP_CU_U_ITEM	+'_'+FORMAT(@PP_REVISION_HOJA_EMPAQUE,'000') +'_'+ CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA) ,
										[RUTA_HOJA_EMPAQUE_CAPA_EXTENSION]	= @VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION	
										-- ========================== 
								--WHERE	K_HOJA_EMPAQUE_CAPA			= @VP_VALOR_K_HOJA
								WHERE	CUS_NO				=	@PP_CUS_NO			--	'MAGN02'	--
								AND		MODELNO				=	@PP_MODELNO			--	'WAL'		--
								AND		VERSIONNO			=	@PP_VERSIONNO		--	 (0014)	--
								AND		ITEM_NO				=	@VP_CU_ITEM_NO		--	'PWALBRR' --
								AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
								AND		N_CAPA				=	@VP_VALOR_N_CAPA
								IF @@ROWCOUNT = 0
								BEGIN
									SET @VP_MENSAJE='El registro no fue actualizado.(UP) [KHEU# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+' // '+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
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
										[ITEM_P]						,	[REVISION_HOJA_EMPAQUE]	,
										[ITEM_NO]						,	[U_ITEM]				,
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
										@VP_CU_ITEM_NO					,	@VP_CU_U_ITEM		,
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
									SET @VP_MENSAJE='La información de la capa no fue ingresada.(CC) [CAPAU#'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
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
								SET @VP_MENSAJE='El registro de la ruta no fue ingresado.(SRV) [KHEU# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'-'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
								RAISERROR (@VP_MENSAJE, 16, 1 ) 
							END
														
							INSERT INTO @VP_TA_RUTAS_IMAGEN
							(		 TA_RUTA_SERVR		,TA_RUTA_LOCAL		
									,TA_CREAR_CARP		,TA_L_CAMBIO	,MENSAJE	)
							SELECT	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR_REPORTE		+	
									@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO		+
									@VP_CU_U_ITEM	+ '_' + FORMAT(@PP_REVISION_HOJA_EMPAQUE,'000') + '_' + CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA) +										
									@VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION
									,@VP_VALOR_RUTA_N	,@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR_REPORTE	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO
									,1					,''
							IF @@ROWCOUNT = 0
							BEGIN
								SET @VP_MENSAJE='El registro de la ruta no fue ingresado.(REP) [KHEU# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'-'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
								RAISERROR (@VP_MENSAJE, 16, 1 ) 
							END

						FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_ITEM_P, @VP_CU_ITEM_NO, @VP_CU_U_ITEM
						END
						CLOSE		CU_CURSOR_U_ITEM
						DEALLOCATE	CU_CURSOR_U_ITEM
																		
					END
					ELSE
					-- =======================================================================================================================
					--	SI NO PERTENECE A UN NÚMERO U, ACTUALIZA SÓLO LOS KITS QUE LO COMPONEN.
					-- =======================================================================================================================
					BEGIN
						SET @VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	=	LTRIM(RTRIM(@VP_ITEM_P)) +'_'+FORMAT(@PP_REVISION_HOJA_EMPAQUE,'000') +'_'+ CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)
									
						--SET	@VP_RUTA_IMAGEN	=	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO		+
						--						@VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION

						UPDATE	[HOJA_EMPAQUE_CAPA]
						SET		-- ========================== 
								--[N_CAPA]							= @VP_VALOR_N_CAPA,
								[N_PATRONES_CAPA]					= @VP_VALOR_N_PATR,
								[RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR]	= @VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	,
								[RUTA_HOJA_EMPAQUE_CAPA_MODELO]		= @VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO		,
								[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]		= @VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN		,
								[RUTA_HOJA_EMPAQUE_CAPA_EXTENSION]	= @VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION	
								-- ========================== 
						--WHERE	K_HOJA_EMPAQUE_CAPA			= @VP_VALOR_K_HOJA
						WHERE	CUS_NO				=	@PP_CUS_NO			--	'MAGN02'	--
						AND		MODELNO				=	@PP_MODELNO			--	'WAL'		--
						AND		VERSIONNO			=	@PP_VERSIONNO		--	 (0014)	--
						AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
						AND		N_CAPA				=	@VP_VALOR_N_CAPA
						AND		(	CASE	
										WHEN	@PP_MODELNO	= 'WL5'	THEN	[ITEM_NO]
										ELSE	[ITEM_P]
								END	)						=	(	CASE	
																		WHEN	@PP_MODELNO	= 'WL5'	THEN	@PP_ITEM_NO
																		ELSE	@VP_ITEM_P
																END	)
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El registro no fue actualizado.(CC2) [KHE# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+']'
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
							SET @VP_MENSAJE='El registro de la ruta no fue ingresado.(SRV2) [KHE# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'-'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END	
						
						INSERT INTO @VP_TA_RUTAS_IMAGEN
						(	 TA_RUTA_SERVR		,TA_RUTA_LOCAL	
							,TA_CREAR_CARP
							,TA_L_CAMBIO
							,MENSAJE	)
						VALUES
						(	 @VP_VALOR_RUTA_C	,@VP_VALOR_RUTA_N
							,@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR_REPORTE	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO
							,@VP_L_CAMBIO
							,''			)
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El registro de la ruta no fue ingresado.(REP2) [KHE# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'-'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END	
					END
				END
				--***********************************************************************************************
				ELSE
				-- ===============================================================================================================================================
			--	SI NO EXISTE LA CAPA REALIZA UNA INSERCIÓN CON LA INFORMACIÓN RECIBIDA.
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
							AND		[ITEM_NO]			=	@PP_ITEM_NO
							AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
							AND		U_ITEM				<> ''		) >= 1	-- ORDER BY VERSIONNO
					BEGIN
						DECLARE CU_CURSOR_U_ITEM	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
							SELECT	DISTINCT(ITEM_P),	--	K_HOJA_EMPAQUE
									ITEM_NO,
									U_ITEM
							FROM	HOJA_EMPAQUE		(NOLOCK)
							WHERE	CUS_NO				=	@PP_CUS_NO			--	'MAGN02'	--
							AND		MODELNO				=	@PP_MODELNO			--	'WAL'		--
							AND		VERSIONNO			=	@PP_VERSIONNO		--	 (0014)	--
							AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
							---AND		U_ITEM				<> ''
							AND		[U_ITEM]			IN (	SELECT	DISTINCT(U_ITEM) 
																FROM	HOJA_EMPAQUE 
																WHERE	CUS_NO				=  @PP_CUS_NO			--	'MAGN02'	--
																AND		MODELNO				=  @PP_MODELNO			--	'WAL'		--
																AND		VERSIONNO			=  @PP_VERSIONNO		--	 (0014)	--
																AND		ITEM_NO				=  @PP_ITEM_NO			--	'PWALBRR' --
																AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
																)
						OPEN CU_CURSOR_U_ITEM
						FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_ITEM_P, @VP_CU_ITEM_NO, @VP_CU_U_ITEM
						WHILE @@FETCH_STATUS=0
						BEGIN
						--------------------------------------------------------------------------------------------------------------------------------------------
							INSERT INTO [HOJA_EMPAQUE_CAPA]
								(	[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]	,
									-- ============================	
									[CUS_NO]						,	[MODELNO]			,
									[VERSIONNO]						,
									-- ============================	
									[ITEM_P]						,	[REVISION_HOJA_EMPAQUE]			,
									[ITEM_NO]						,	[U_ITEM]			,
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
								@VP_CU_ITEM_NO					,	@VP_CU_U_ITEM		,
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
							--	FROM	@TA_U_ITEMS_X_P
							IF @@ROWCOUNT = 0
							BEGIN
								SET @VP_MENSAJE='La información de la capa no fue ingresada.(CC3) [CAPAU#'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
								RAISERROR (@VP_MENSAJE, 16, 1 )
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
							--FROM	@TA_U_ITEMS_X_P
							IF @@ROWCOUNT = 0
							BEGIN
								SET @VP_MENSAJE='El registro de la ruta no fue ingresado.(SRV3) [KHEU# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'-'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
								RAISERROR (@VP_MENSAJE, 16, 1 ) 
							END
							
							INSERT INTO @VP_TA_RUTAS_IMAGEN
							(		 TA_RUTA_SERVR		,TA_RUTA_LOCAL		
									,TA_CREAR_CARP		,TA_L_CAMBIO	,MENSAJE	)
							SELECT	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR_REPORTE		+	
									@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO		+
									@VP_CU_U_ITEM	+ '_' + FORMAT(@PP_REVISION_HOJA_EMPAQUE,'000') + '_' + CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA) +										
									@VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION
									,@VP_VALOR_RUTA_N	,@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR_REPORTE	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO
									,1					,''
							--FROM	@TA_U_ITEMS_X_P
							IF @@ROWCOUNT = 0
							BEGIN
								SET @VP_MENSAJE='El registro de la ruta no fue ingresado.(REP3) [KHEU# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'-'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
								RAISERROR (@VP_MENSAJE, 16, 1 ) 
							END

						FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_ITEM_P, @VP_CU_ITEM_NO, @VP_CU_U_ITEM
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
						SET @VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	=	LTRIM(RTRIM(@VP_ITEM_P)) +'_'+FORMAT(@PP_REVISION_HOJA_EMPAQUE,'000') +'_'+ CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)
									
						SET	@VP_RUTA_IMAGEN	=	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO		+
												@VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION

						INSERT INTO [HOJA_EMPAQUE_CAPA]
							(
								[CUS_NO]						,	[MODELNO]			,
								[VERSIONNO]						,
								-- ============================	
								[ITEM_P]						,	[REVISION_HOJA_EMPAQUE]			,
								[ITEM_NO]						,
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
								@VP_ITEM_P						,	@PP_REVISION_HOJA_EMPAQUE		,
								@PP_ITEM_NO						,
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
							SET @VP_MENSAJE='La información de la capa no fue ingresada.(CC4) [CAPA#'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
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
							SET @VP_MENSAJE='El registro de la ruta no fue ingresado.(SRV4) [KHE# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'-'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END	
						
						INSERT INTO @VP_TA_RUTAS_IMAGEN
						(	 TA_RUTA_SERVR		,TA_RUTA_LOCAL		
							,TA_CREAR_CARP
							,TA_L_CAMBIO
							,MENSAJE	)
						VALUES
						(	@VP_RUTA_IMAGEN		,	@VP_VALOR_RUTA_N
							,@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR_REPORTE	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO
							,1
							,''			)
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El registro de la ruta no fue ingresado.(REP4) [KHE# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'-'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
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
			ELSE	--	IF @PP_L_NUEVA_REVISIÓN	= 1		--	SE VERIFICA SI SE DESEA CREAR UNA NUEVA VERSIÓN DE LA HOJA DE EMPAQUE.
			BEGIN
			--***********************************************************************************************
				--	PARA LOS KIT QUE PERTENECEN A UN NÚMERO U
				IF	(	SELECT	COUNT(K_HOJA_EMPAQUE)--,*	
						FROM	HOJA_EMPAQUE		(NOLOCK)
						WHERE	CUS_NO				=	@PP_CUS_NO		
						AND		MODELNO				=	@PP_MODELNO		
						AND		VERSIONNO			=	@PP_VERSIONNO
						AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
						AND		[ITEM_NO]			=	@PP_ITEM_NO
						AND		U_ITEM				<> ''		) >= 1	-- ORDER BY VERSIONNO
				BEGIN
					DECLARE CU_CURSOR_U_ITEM	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
						SELECT	DISTINCT(ITEM_P)	--	K_HOJA_EMPAQUE
										,ITEM_NO
										,U_ITEM
						FROM	HOJA_EMPAQUE		(NOLOCK)
						WHERE	CUS_NO				=	@PP_CUS_NO			--	'MAGN02'	--
						AND		MODELNO				=	@PP_MODELNO			--	'WAL'		--
						AND		VERSIONNO			=	@PP_VERSIONNO		--	 (0014)	--
						AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
						---AND		U_ITEM				<> ''
						AND		[U_ITEM]			IN (	SELECT	DISTINCT(U_ITEM) 
															FROM	HOJA_EMPAQUE 
															WHERE	CUS_NO				=  @PP_CUS_NO			--	'MAGN02'	--
															AND		MODELNO				=  @PP_MODELNO			--	'WAL'		--
															AND		VERSIONNO			=  @PP_VERSIONNO		--	 (0014)	--
															AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
															AND		ITEM_NO				=  @PP_ITEM_NO			--	'PWALBRR' --
															)
					OPEN CU_CURSOR_U_ITEM
					FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_ITEM_P, @VP_CU_ITEM_NO, @VP_CU_U_ITEM
					WHILE @@FETCH_STATUS=0
					BEGIN
					------------------------------------------------------------------------------------------------------------------------------------------
						INSERT INTO [HOJA_EMPAQUE_CAPA]
							(	[RUTA_HOJA_EMPAQUE_CAPA_IMAGEN]	,
								-- ============================	
								[CUS_NO]						,	[MODELNO]			,
								[VERSIONNO]						,
								-- ============================	
								[ITEM_P]						,	[REVISION_HOJA_EMPAQUE]			,
								[ITEM_NO]						,	[U_ITEM]			,
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
							@VP_CU_ITEM_P					,	@VP_REVISION_NUEVA_HOJA_EMPAQUE		,
							@VP_CU_ITEM_NO					,	@VP_CU_U_ITEM		,
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
						--FROM	@TA_U_ITEMS
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='La información de la capa no fue ingresada.(CC5) [CAPAU#'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 )
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
						--FROM	@TA_U_ITEMS
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El registro de la ruta no fue ingresado.(SRV5) [KHEU# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'-'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END
						
						INSERT INTO @VP_TA_RUTAS_IMAGEN
						(		 TA_RUTA_SERVR		,TA_RUTA_LOCAL		
								,TA_CREAR_CARP		,TA_L_CAMBIO	,MENSAJE	)
						SELECT	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR_REPORTE		+	
								@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO		+
								@VP_CU_U_ITEM	+ '_' + FORMAT(@PP_REVISION_HOJA_EMPAQUE,'000') + '_' + CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA) +										
								@VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION
								,@VP_VALOR_RUTA_N	,@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR_REPORTE	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO
								,1					,''
						--FROM	@TA_U_ITEMS
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El registro de la ruta no fue ingresado.(REP5) [KHEU# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'-'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END
					FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_ITEM_P, @VP_CU_ITEM_NO, @VP_CU_U_ITEM
					END
					CLOSE		CU_CURSOR_U_ITEM
					DEALLOCATE	CU_CURSOR_U_ITEM

				END
				ELSE
				BEGIN
					-- PARA LOS KITS QUE NO SON Us
					SET @VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	=	LTRIM(RTRIM(@VP_ITEM_P)) +'_'+FORMAT(@PP_REVISION_HOJA_EMPAQUE,'000') +'_'+ CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)
									
					SET	@VP_RUTA_IMAGEN	=	@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO		+
											@VP_RUTA_HOJA_EMPAQUE_CAPA_IMAGEN	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_EXTENSION

					INSERT INTO [HOJA_EMPAQUE_CAPA]
						(
							[CUS_NO]						,	[MODELNO]			,
							[VERSIONNO]						,
							-- ============================	
							[ITEM_P]						,	[REVISION_HOJA_EMPAQUE],
							[ITEM_NO]						,
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
							@VP_ITEM_P						,	@VP_REVISION_NUEVA_HOJA_EMPAQUE	,
							@PP_ITEM_NO						,
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
						SET @VP_MENSAJE='La información de la capa no fue ingresada.(CC6) [CAPA#'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
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
						SET @VP_MENSAJE='El registro de la ruta no fue ingresado.(SRV6) [KHE# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'-'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
						RAISERROR (@VP_MENSAJE, 16, 1 ) 
					END	
					
					INSERT INTO @VP_TA_RUTAS_IMAGEN
					(	 TA_RUTA_SERVR		,TA_RUTA_LOCAL		
						,TA_CREAR_CARP
						,TA_L_CAMBIO
						,MENSAJE	)
					VALUES
					(	@VP_RUTA_IMAGEN		,	@VP_VALOR_RUTA_N
						,@VP_RUTA_HOJA_EMPAQUE_CAPA_SERVIDOR_REPORTE	+	@VP_RUTA_HOJA_EMPAQUE_CAPA_MODELO
						,1
						,''			)
					IF @@ROWCOUNT = 0
					BEGIN
						SET @VP_MENSAJE='El registro de la ruta no fue ingresado.(REP6) [KHE# '+CONVERT(VARCHAR(10),@VP_VALOR_K_HOJA)+'-'+CONVERT(VARCHAR(10),@VP_VALOR_N_CAPA)+']'
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
							AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
							AND		[ITEM_NO]			=	@PP_ITEM_NO
							AND		U_ITEM				<> ''		) >= 1	-- ORDER BY VERSIONNO
		BEGIN

			DELETE	[HOJA_EMPAQUE_CAPA]
			WHERE	[CUS_NO]					= @PP_CUS_NO 
			AND		[MODELNO]					= @PP_MODELNO
			AND		[VERSIONNO]					= @PP_VERSIONNO
			AND		[REVISION_HOJA_EMPAQUE]			= @PP_REVISION_HOJA_EMPAQUE
			-- ============================
			AND		[ITEM_NO]					IN	(	SELECT	DISTINCT(ITEM_NO)	--	K_HOJA_EMPAQUE		
														FROM	HOJA_EMPAQUE		(NOLOCK)
														WHERE	CUS_NO				=	@PP_CUS_NO	
														AND		MODELNO				=	@PP_MODELNO	
														AND		VERSIONNO			=	@PP_VERSIONNO
														AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
														AND		[U_ITEM]			IN (	SELECT	DISTINCT(U_ITEM) 
																							FROM	HOJA_EMPAQUE 
																							WHERE	CUS_NO				=  @PP_CUS_NO	
																							AND		MODELNO				=  @PP_MODELNO	
																							AND		VERSIONNO			=  @PP_VERSIONNO
																							AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
																							AND		ITEM_NO				=  @VP_CU_ITEM_NO	)	)
					-- ============================
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
			AND		[REVISION_HOJA_EMPAQUE]		= @PP_REVISION_HOJA_EMPAQUE
					-- ============================
			AND		(	CASE	
							WHEN	@PP_MODELNO	= 'WL5'	THEN	[ITEM_NO]
							ELSE	[ITEM_P]
					END	)						=	(	CASE	
															WHEN	@PP_MODELNO	= 'WL5'	THEN	@PP_ITEM_NO
															ELSE	@VP_ITEM_P
													END	)									
			--AND		[ITEM_P]					= @PP_ITEM_P
					-- ============================
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
													@PP_VERSIONNO				,	@PP_ITEM_NO				,
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
						AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
						AND		[ITEM_NO]			=	@PP_ITEM_NO
						AND		U_ITEM				<> ''		) >= 1	-- ORDER BY VERSIONNO
				BEGIN
					DECLARE CU_CURSOR_U_ITEM	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
						SELECT	DISTINCT(ITEM_P)	--	K_HOJA_EMPAQUE
								,ITEM_NO
						FROM	HOJA_EMPAQUE		(NOLOCK)
						WHERE	CUS_NO				=	@PP_CUS_NO			--	'MAGN02'	--
						AND		MODELNO				=	@PP_MODELNO			--	'WAL'		--
						AND		VERSIONNO			=	@PP_VERSIONNO		--	 (0014)	--
						AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
						---AND		U_ITEM				<> ''
						AND		[U_ITEM]			IN (	SELECT	DISTINCT(U_ITEM) 
															FROM	HOJA_EMPAQUE 
															WHERE	CUS_NO				=  @PP_CUS_NO			--	'MAGN02'	--
															AND		MODELNO				=  @PP_MODELNO			--	'WAL'		--
															AND		VERSIONNO			=  @PP_VERSIONNO		--	 (0014)	--
															AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
															AND		ITEM_NO				=  @PP_ITEM_NO			--	'PWALBRR' --
															)
					OPEN CU_CURSOR_U_ITEM
					FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_ITEM_P, @VP_CU_ITEM_NO
					WHILE @@FETCH_STATUS=0
					BEGIN	
						--	PARA INDICAR QUE SE HAN CARGADO TODAS LAS IMAGENES DE CADA UNA DE LAS CAPAS, ESTE CAMPO LO USARÁ FEG EN SUS PANTALLAS.														
						IF	@VP_CANTIDAD_CAPAS	= (	SELECT	COUNT(K_HOJA_EMPAQUE_CAPA)
													FROM	[HOJA_EMPAQUE_CAPA]
													WHERE	[CUS_NO]						= @PP_CUS_NO 
													AND		[MODELNO]						= @PP_MODELNO
													AND		[VERSIONNO]						= @PP_VERSIONNO
													AND		[REVISION_HOJA_EMPAQUE]			= @PP_REVISION_HOJA_EMPAQUE
															-- ============================
													--AND		[ITEM_P]						= @VP_CU_ITEM_P	--@PP_ITEM_P
													AND		[ITEM_NO]						= @VP_CU_ITEM_NO
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
						--AND		ITEM_P					= @VP_CU_ITEM_P	--@PP_ITEM_P
						AND		ITEM_NO					= @VP_CU_ITEM_NO
						AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='Registro no fue ingresado.(1)(L_CAPAS)[HE#' + CONVERT(VARCHAR(10),@PP_ITEM_NO ) + ']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END

					FETCH NEXT FROM  CU_CURSOR_U_ITEM INTO  @VP_CU_ITEM_P, @VP_CU_ITEM_NO
					END
					CLOSE		CU_CURSOR_U_ITEM
					DEALLOCATE	CU_CURSOR_U_ITEM

				END
				ELSE
				BEGIN
					DECLARE CU_CURSOR_ITEM_P	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
						SELECT	DISTINCT(ITEM_P)	--	K_HOJA_EMPAQUE
								,ITEM_NO
						FROM	HOJA_EMPAQUE		(NOLOCK)
						WHERE	CUS_NO				=	@PP_CUS_NO			--	'MAGN02'	--
						AND		MODELNO				=	@PP_MODELNO			--	'WAL'		--
						AND		VERSIONNO			=	@PP_VERSIONNO		--	 (0014)	--
						AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
						AND		(	CASE	
										WHEN	@PP_MODELNO	= 'WL5'	THEN	[ITEM_NO]
										ELSE	[ITEM_P]
								END	)						=	(	CASE	
																		WHEN	@PP_MODELNO	= 'WL5'	THEN	@PP_ITEM_NO
																		ELSE	@VP_ITEM_P
																END	)
					OPEN CU_CURSOR_ITEM_P
					FETCH NEXT FROM  CU_CURSOR_ITEM_P INTO  @VP_CU_ITEM_P, @VP_CU_ITEM_NO
					WHILE @@FETCH_STATUS=0
					BEGIN	
						--	PARA INDICAR QUE SE HAN CARGADO TODAS LAS IMAGENES DE CADA UNA DE LAS CAPAS, ESTE CAMPO LO USARÁ FEG EN SUS PANTALLAS.														
						IF	@VP_CANTIDAD_CAPAS	= (	SELECT	COUNT(K_HOJA_EMPAQUE_CAPA)
													FROM	[HOJA_EMPAQUE_CAPA]
													WHERE	[CUS_NO]						= @PP_CUS_NO 
													AND		[MODELNO]						= @PP_MODELNO
													AND		[VERSIONNO]						= @PP_VERSIONNO
													AND		[REVISION_HOJA_EMPAQUE]			= @PP_REVISION_HOJA_EMPAQUE
															-- ============================
													AND		[ITEM_NO]						= @VP_CU_ITEM_NO
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
						AND		ITEM_NO					= @VP_CU_ITEM_NO
						AND		REVISION_HOJA_EMPAQUE	= @PP_REVISION_HOJA_EMPAQUE
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='Registro no fue ingresado.(2)(L_CAPAS)[HE#' + CONVERT(VARCHAR(10),@PP_ITEM_NO ) + ']'
							RAISERROR (@VP_MENSAJE, 16, 1 ) 
						END

					FETCH NEXT FROM  CU_CURSOR_ITEM_P INTO  @VP_CU_ITEM_P, @VP_CU_ITEM_NO
					END
					CLOSE		CU_CURSOR_ITEM_P
					DEALLOCATE	CU_CURSOR_ITEM_P
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
		SET	@VP_MENSAJE = 'No es posible [Actualizar] la [Hoja de Empaque]: '			+ @VP_MENSAJE
		SET	@VP_MENSAJE +=	CONVERT(VARCHAR(50),@PP_L_NUEVA_REVISIÓN)					+ '*-*'	+ CHAR(13) + CHAR(10)
						-- ============================											+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	@PP_CUS_NO													+ '*-*'	+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	@PP_MODELNO													+ '*-*'	+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	CONVERT(VARCHAR(50),@PP_VERSIONNO)							+ '*-*'	+ CHAR(13) + CHAR(10)
						-- ============================											+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	@PP_ITEM_NO													+ '*-*'	+ CHAR(13) + CHAR(10)
						-- ============================											+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	@PP_CAJA_HOJA_EMPAQUE										+ '*-*'	+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	@PP_DIBUJO_HOJA_EMPAQUE										+ '*-*'	+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	CONVERT(VARCHAR(50),@PP_REVISION_HOJA_EMPAQUE)				+ '*-*'	+ CHAR(13) + CHAR(10)
						-- ============================											+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	CONVERT(VARCHAR(50),@PP_CANTIDAD_PATRONES)					+ '*-*'	+ CHAR(13) + CHAR(10)
						-- ============================											+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	@PP_C_HOJA_EMPAQUE											+ '*-*'	+ CHAR(13) + CHAR(10)
						-- ============================											+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	CONVERT(VARCHAR(50),@PP_K_HOJA_EMPAQUE_CAPA_DIVISION)		+ '*-*'	+ CHAR(13) + CHAR(10)
						-- ============================											+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	CONVERT(VARCHAR(50),@PP_ARRAY_N_CAPA)						+ '*-*'	+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	CONVERT(VARCHAR(50),@PP_ARRAY_N_PATR)						+ '*-*'	+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	@PP_ARRAY_RUTA_C											+ '*-*'	+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	@PP_ARRAY_RUTA_N											+ '*-*'	+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	CONVERT(VARCHAR(50),@PP_ARRAY_K_HOJA)						+ '*-*'	+ CHAR(13) + CHAR(10)
						-- ============================											+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	CONVERT(VARCHAR(50),@PP_ARRAY_K_HE_PROC)					+ '*-*'	+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	CONVERT(VARCHAR(50),@PP_ARRAY_K_PROCESO)					+ '*-*'	+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	CONVERT(VARCHAR(50),@PP_ARRAY_K_P_SIMBO)					+ '*-*'	+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	CONVERT(VARCHAR(50),@PP_ARRAY_L_PROCESO)					+ '*-*'	+ CHAR(13) + CHAR(10)
		SET	@VP_MENSAJE +=	@PP_ARRAY_D_PROCESO											+ '*-*'	+ CHAR(13) + CHAR(10)

		SELECT	@VP_MENSAJE AS MENSAJE, @PP_ITEM_NO AS CLAVE	--CONCAT(	@PP_CUS_NO,	@PP_MODELNO	,@PP_VERSIONNO )	AS CLAVE		
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
	@PP_ITEM_NO							VARCHAR(50),	-- ES EL P DEL ITEM_NO
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
		,@VP_ITEM_P						VARCHAR(50)

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
											AND		ITEM_P				=  @VP_ITEM_P			--	'PWALBRR' --
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
		SET @VP_MENSAJE='Registro no fue modificado. (0)(N)[HEU#'+CONVERT(VARCHAR(10),@PP_ITEM_NO )+']'
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
			[U_ITEM]						,
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
			[U_ITEM]						,
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
		SET @VP_MENSAJE='Registro no fue ingresado.(N)[HEU#'+CONVERT(VARCHAR(10),@PP_ITEM_NO )+ ' // ' +CONVERT(VARCHAR(10),@PP_REVISION_HOJA_EMPAQUE) + ']'
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
	@PP_ITEM_NO							VARCHAR(50),
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
		,@VP_ITEM_P						VARCHAR(50)	-- ES EL P DEL ITEM_NO

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
											AND		ITEM_NO				=  @PP_ITEM_NO			--	'PWALBRR' --
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
				SET @VP_MENSAJE='Registro no fue modificado. [HEU#'+CONVERT(VARCHAR(10),@PP_ITEM_NO )+']'
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
	@PP_ITEM_NO							VARCHAR(50),
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
			,@VP_ITEM_P					VARCHAR(50)	= LEFT(@PP_ITEM_NO,7)
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
							[ITEM_NO]					,
							-- ============================
							[K_PROCESO]					,	[K_PROCESO_SIMBOLO]		,
							[L_HOJA_EMPAQUE_PROCESO]	,
							-- ============================	
							[D_HOJA_EMPAQUE_PROCESO]	)
					VALUES
						(	@PP_CUS_NO						,	@PP_MODELNO			,	
							@PP_VERSIONNO					,
							-- ============================	
							@VP_ITEM_P						,	@PP_REVISION_HOJA_EMPAQUE + 1	,
							@PP_ITEM_NO						,
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
									[ITEM_NO]					,
									-- ============================
									[K_PROCESO]					,	[K_PROCESO_SIMBOLO]		,
									[L_HOJA_EMPAQUE_PROCESO]	,
									-- ============================	
									[D_HOJA_EMPAQUE_PROCESO]	)
							VALUES
								(	@PP_CUS_NO						,	@PP_MODELNO			,	
									@PP_VERSIONNO					,
									-- ============================	
									@VP_ITEM_P						,	@PP_REVISION_HOJA_EMPAQUE		,
									@PP_ITEM_NO						,
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
---- // STORED PROCEDURE --->	NOTIFICAR CAMBIOS HOJA_EMPAQUE
---- //							AX: 20220216
---- ////////////////////////////////////////////////////////////// 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_NOTIFICAR_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_NOTIFICAR_HOJA_EMPAQUE]
GO
--		EXECUTE  [dbo].[PG_NOTIFICAR_HOJA_EMPAQUE] 	0,139, 'MAGN03','RUA','0039'
CREATE PROCEDURE [dbo].[PG_NOTIFICAR_HOJA_EMPAQUE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_S_CUSTOMER				VARCHAR(20),
	@PP_S_MODEL					VARCHAR(20),
	@PP_NO_VERSION				VARCHAR(20)
	-- ===========================
AS
DECLARE @VP_MENSAJE NVARCHAR(MAX)
	DECLARE @VP_SUBJECT			VARCHAR(255) = '[HOJA_EMPAQUE_LIVE] '+ @PP_S_CUSTOMER +' // ' + @PP_S_MODEL + ' (Ver.# ' + @PP_NO_VERSION + ') Live'
			,@VP_RECIPIENTS		NVARCHAR(MAX)  = ''
			,@VP_BODY_HTML		NVARCHAR(MAX) 
			,@VP_K_TIPO_GRUPO_APROBADOR	VARCHAR(15)	=	7000

	SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
	FROM	BD_GENERAL.dbo.USUARIO_PEARL AS USERS  (NOLOCK) 
	INNER	JOIN	BD_GENERAL.dbo.GRUPO_APROBADOR (NOLOCK) ON GRUPO_APROBADOR.K_USUARIO	= USERS.K_USUARIO_PEARL
	WHERE	GRUPO_APROBADOR.K_TIPO_GRUPO_APROBADOR			= @VP_K_TIPO_GRUPO_APROBADOR
	AND		K_ESTATUS_GRUPO_APROBADOR						= 1

	SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))

	DECLARE	@VP_CUERPO_CORREO_01	AS NVARCHAR(MAX)	= '',
			@VP_CUERPO_CORREO_02	AS NVARCHAR(MAX)	= '',
			@VP_CUERPO_CORREO_03	AS NVARCHAR(MAX)	= ''

		IF	(	SELECT	COUNT(CUS_NO)
				FROM	HOJA_EMPAQUE_REGISTRO_CORREO	(NOLOCK)
				WHERE	CUS_NO				= @PP_S_CUSTOMER
				AND		MODELNO				= @PP_S_MODEL		
				AND		VERSIONNO			= @PP_NO_VERSION
				AND		K_TIPO_MOVIMIENTO	= 1		) <= 0
		BEGIN
			SELECT @VP_CUERPO_CORREO_01	= 'No se presentaron cambios en: los Movimientos generales de KITS.'
		END
		ELSE
		BEGIN
			SELECT @VP_CUERPO_CORREO_01	=	N'<table>' +
											N'<thead>' + 
												N'<tr>' + 
												N'<th colspan="5">Movimientos generales de KITS:</th>'			+
												N'</tr>' + 
												N'<tr>' +
												N'	<th width: 10%>   Item				</th>	
													<th width: 15%>   Customer Part		</th>	
													<th width: 30%>   Descripción		</th>
													<th width: 15%>   U Item 			</th>
													<th width: 30%>   Tipo de Cambio	</th>'		+ 
												N'</tr>' + 
											N'</thead>' + 
											N'<tbody>' + 
												CAST ( (	 SELECT td = ISNULL([ITEM_NO]				,'----'), '',  
																	td = ISNULL([CUSTOMER_ITEM_NO]		,'----'), '',  
																	td = ISNULL([D_ITEM_NO]				,'----'), '',  
																	td = ISNULL([U_ITEM]				,'----'), '',  
																	td = ISNULL([D_TIPO_CAMBIO_KIT]		,'----'), ''
															FROM	HOJA_EMPAQUE_REGISTRO_CORREO	(NOLOCK)
															WHERE	CUS_NO				= @PP_S_CUSTOMER
															AND		MODELNO				= @PP_S_MODEL		
															AND		VERSIONNO			= @PP_NO_VERSION
															AND		K_TIPO_MOVIMIENTO	= 1
														FOR XML PATH('tr'), TYPE   
												) AS NVARCHAR(MAX) ) +  
											N'</tbody>' + 
											N'</table>' 
		END

		IF	(	SELECT	COUNT(CUS_NO)
				FROM	HOJA_EMPAQUE_REGISTRO_CORREO	(NOLOCK)
				WHERE	CUS_NO				= @PP_S_CUSTOMER
				AND		MODELNO				= @PP_S_MODEL		
				AND		VERSIONNO			= @PP_NO_VERSION
				AND		K_TIPO_MOVIMIENTO	= 2		) <= 0
		BEGIN
			SELECT @VP_CUERPO_CORREO_02	= 'No se presentaron cambios en: los Movimientos de los Procesos Especiales de KITS.'
		END
		ELSE
		BEGIN
			SELECT @VP_CUERPO_CORREO_02	=	N'<table>' +
												N'<thead>' + 
													N'<tr>' + 
													N'<th colspan="5">Movimientos de los Procesos Especiales de KITS:</th>'			+
													N'</tr>' + 
													N'<tr>' +
													N'	<th width: 10%>   Item				</th>	
														<th width: 15%>   Customer Part		</th>	
														<th width: 30%>   Descripción		</th>
														<th width: 15%>   U Item 			</th>
														<th width: 30%>   Tipo de Cambio	</th>'		+ 
													N'</tr>' + 
												N'</thead>' + 
												N'<tbody>' + 
													CAST ( (	 SELECT td = RTRIM(LTRIM([ITEM_NO])), '',  
																		td = RTRIM(LTRIM([CUSTOMER_ITEM_NO])), '',  
																		td = RTRIM(LTRIM([D_ITEM_NO])), '',  
																		td = RTRIM(LTRIM([U_ITEM])), '',  
																		td = RTRIM(LTRIM([D_TIPO_CAMBIO_KIT])), ''
																FROM	HOJA_EMPAQUE_REGISTRO_CORREO	(NOLOCK)
																WHERE	K_TIPO_MOVIMIENTO	= 2
															FOR XML PATH('tr'), TYPE   
													) AS NVARCHAR(MAX) ) +  
												N'</tbody>' + 
											N'</table>'
		END

		IF	(	SELECT	COUNT(CUS_NO)
				FROM	HOJA_EMPAQUE_REGISTRO_CORREO	(NOLOCK)
				WHERE	CUS_NO				= @PP_S_CUSTOMER
				AND		MODELNO				= @PP_S_MODEL		
				AND		VERSIONNO			= @PP_NO_VERSION
				AND		K_TIPO_MOVIMIENTO	= 3		) <= 0
		BEGIN
			SELECT @VP_CUERPO_CORREO_03	= 'No se presentaron cambios en: los Movimientos de los Procesos Especiales de KITS.'
		END
		ELSE
		BEGIN
			SELECT @VP_CUERPO_CORREO_03	=	N'<table>' +
											N'<thead>' + 
												N'<tr>' + 
												N'<th colspan="1">Movimientos Cantidad de Procesos Especiales:</th>'			+
												N'</tr>' + 
												N'<tr>' +
												--N'	<th width: 10%>   Item				</th>	
												--	<th width: 15%>   Customer Part		</th>	
												--	<th width: 30%>   Descripción		</th>
												--	<th width: 15%>   U Item 			</th>
												N'	<th width: 30%>   Tipo de Cambio	</th>'		+ 
												N'</tr>' + 
											N'</thead>' + 
											N'<tbody>' + 
												CAST ( (	 SELECT --td = RTRIM(LTRIM([ITEM_NO])), '',  
																	--td = RTRIM(LTRIM([CUSTOMER_ITEM_NO])), '',  
																	--td = RTRIM(LTRIM([D_ITEM_NO])), '',  
																	--td = RTRIM(LTRIM([U_ITEM])), '',  
																	td = RTRIM(LTRIM([D_TIPO_CAMBIO_KIT])), ''
															FROM	HOJA_EMPAQUE_REGISTRO_CORREO	(NOLOCK)
															WHERE	K_TIPO_MOVIMIENTO	= 3
														FOR XML PATH('tr'), TYPE   
												) AS NVARCHAR(MAX) ) +  
											N'</tbody>' + 
											N'</table>'
		END

	
	SET @VP_BODY_HTML =
		N'<html>'+
		N'<head>'+		
		N'<style>'+
		N'table	{border: solid 1px;border-collapse:collapse; width: 50%; cellspacing="1"}'+
		N'th	{border: solid 1px;padding: 3px;text-align: "center";background:"#ADD8E6"; color:"#000000"}'+
		N'td	{border: solid 1px;padding: 3px;text-align: "center";background:"#48D1CC"; color:"#000000"}'+
		N'</style> </head>'+

		N'</head>'+
		N'<body>'+

		N'<p style="color:black; font-size:12.0pt;font-family:"Calisto MT",serif">'+
		N'A quien corresponda, <br><br>'+
		N'Se ha realizado el alta de un nuevo modelo (la información del mismo viene indicada en el asunto del presente correo), <br>' +
		N'y en el cuerpo del mensaje se presenta el detalle los movimientos de cada uno de los KITS. <br><br>'	+
		N'TOMAR LAS MEDIDAS NECESARIAS PARA ACTUALIZAR LA INFORMACIÓN FALTANTE. </p><br><br><br>' +
		
		@VP_CUERPO_CORREO_01 +
		N'<br><br><br><br>'  +
		@VP_CUERPO_CORREO_02 +
		N'<br><br><br><br>'  +
		@VP_CUERPO_CORREO_03 +
		N'<br><br><br><br>'  +

		N'</body>'+
		N'</html>';
		SET ROWCOUNT 0

		EXEC msdb.dbo.sp_send_dbmail 
		--@recipients=@VP_RECIPIENTS,
		--@blind_copy_recipients='ALEJANDROD@PEARLLEATHER.COM.MX',
		@recipients	=	'ALEJANDROD@PEARLLEATHER.COM.MX',
		@subject = @VP_SUBJECT,
		@body = @VP_BODY_HTML,  
		@body_format = 'HTML',
		@importance= 'HIGH'--@VP_IMPORTANCE
	----- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	----- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
GO


---- ///////////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> NOTIFICAR FALLA EN ACTUALIZACIÓN DE HOJAS
---- ////////////////////////////////////////////////////////////////// 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_NOTIFICAR_HOJA_NO_COPIADA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_NOTIFICAR_HOJA_NO_COPIADA]
GO
--		EXECUTE  [dbo].[PG_NOTIFICAR_HOJA_NO_COPIADA] 	0,139, 'a','b'
CREATE PROCEDURE [dbo].[PG_NOTIFICAR_HOJA_NO_COPIADA]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_PARAMETRO_01			NVARCHAR(MAX)= '' ,
	@PP_PARAMETRO_02			NVARCHAR(MAX)= '' ,
	@PP_PARAMETRO_03			NVARCHAR(MAX)= '' ,
	@PP_PARAMETRO_04			NVARCHAR(MAX)= '' ,
	@PP_PARAMETRO_05			NVARCHAR(MAX)= '' ,
	@PP_PARAMETRO_06			NVARCHAR(MAX)= '' 
	-- ===========================
AS
DECLARE @VP_MENSAJE NVARCHAR(MAX)
	DECLARE  @VP_SUBJECT				VARCHAR(255) = '[FAIL_COPY]'
			,@VP_RECIPIENTS				NVARCHAR(MAX)  = ''
			,@VP_BODY_HTML				NVARCHAR(MAX) 
			--,@VP_K_TIPO_GRUPO_APROBADOR	VARCHAR(15)	=	7000

	--SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
	--FROM	BD_GENERAL.dbo.USUARIO_PEARL AS USERS  (NOLOCK) 
	--INNER	JOIN	BD_GENERAL.dbo.GRUPO_APROBADOR (NOLOCK) ON GRUPO_APROBADOR.K_USUARIO	= USERS.K_USUARIO_PEARL
	--WHERE	GRUPO_APROBADOR.K_TIPO_GRUPO_APROBADOR			= @VP_K_TIPO_GRUPO_APROBADOR
	--AND		K_ESTATUS_GRUPO_APROBADOR						= 1

	--SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))
	
	SET @VP_BODY_HTML = 
		N'<html>'+
		N'<head>'+		
		N'<style>'+
		N'table	{border: solid 1px;border-collapse:collapse; width: 50%; cellspacing="1"}'+
		N'</style>'+
		N'<p style="color:black; font-size:12.0pt;font-family:"Calisto MT",serif">'+

		N'Error al copiar la hoja de empaque: <br><br>'+
		N'Parametro	1:	<br>' + @PP_PARAMETRO_01 +	'<br>'	+
		N'Parametro 2:	<br>' + @PP_PARAMETRO_02 +	'<br>'	+
		N'Parametro 3:	<br>' + @PP_PARAMETRO_03 +	'<br>'	+
		N'Parametro 4:	<br>' + @PP_PARAMETRO_04 +	'<br>'	+
		N'Parametro 5:	<br>' + @PP_PARAMETRO_05 +	'<br>'	+
		N'Parametro 6:	<br>' + @PP_PARAMETRO_06 +	'<br>'	+
		N'<br>'

		EXEC msdb.dbo.sp_send_dbmail 
		--@recipients=@VP_RECIPIENTS,
		--@blind_copy_recipients='ALEJANDROD@PEARLLEATHER.COM.MX',
		@recipients	=	'ALEJANDROD@PEARLLEATHER.COM.MX',
		@subject = @VP_SUBJECT,
		@body = @VP_BODY_HTML,  
		@body_format = 'HTML',
		@importance= 'NORMAL'--@VP_IMPORTANCE
	----- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	----- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
GO

--USE COT19_Cotizaciones_V9999_R0
--GO
------ ///////////////////////////////////////////////////////////////////
------ // STORED PROCEDURE ---> NOTIFICAR FALLA EN ACTUALIZACIÓN DE HOJAS
------ ////////////////////////////////////////////////////////////////// 
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_NOTIFICAR_HOJA_NO_COPIADA]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_NOTIFICAR_HOJA_NO_COPIADA]
--GO
----		EXECUTE  [dbo].[PG_NOTIFICAR_HOJA_NO_COPIADA] 	0,139, 'a','b'
--CREATE PROCEDURE [dbo].[PG_NOTIFICAR_HOJA_NO_COPIADA]
--	@PP_K_SISTEMA_EXE			INT,
--	@PP_K_USUARIO_ACCION		INT,
--	-- ===========================
--	@PP_PARAMETRO_01			NVARCHAR(MAX)= '' ,
--	@PP_PARAMETRO_02			NVARCHAR(MAX)= '' ,
--	@PP_PARAMETRO_03			NVARCHAR(MAX)= '' ,
--	@PP_PARAMETRO_04			NVARCHAR(MAX)= '' ,
--	@PP_PARAMETRO_05			NVARCHAR(MAX)= '' ,
--	@PP_PARAMETRO_06			NVARCHAR(MAX)= '' 
--	-- ===========================
--AS
--DECLARE @VP_MENSAJE NVARCHAR(MAX)
--	DECLARE  @VP_SUBJECT				VARCHAR(255) = '[FAIL_COPY]'
--			,@VP_RECIPIENTS				NVARCHAR(MAX)  = ''
--			,@VP_BODY_HTML				NVARCHAR(MAX) 
--			--,@VP_K_TIPO_GRUPO_APROBADOR	VARCHAR(15)	=	7000

--	--SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
--	--FROM	BD_GENERAL.dbo.USUARIO_PEARL AS USERS  (NOLOCK) 
--	--INNER	JOIN	BD_GENERAL.dbo.GRUPO_APROBADOR (NOLOCK) ON GRUPO_APROBADOR.K_USUARIO	= USERS.K_USUARIO_PEARL
--	--WHERE	GRUPO_APROBADOR.K_TIPO_GRUPO_APROBADOR			= @VP_K_TIPO_GRUPO_APROBADOR
--	--AND		K_ESTATUS_GRUPO_APROBADOR						= 1

--	--SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))
	
--	SET @VP_BODY_HTML = 
--		N'<html>'+
--		N'<head>'+		
--		N'<style>'+
--		N'table	{border: solid 1px;border-collapse:collapse; width: 50%; cellspacing="1"}'+
--		N'</style>'+
--		N'<p style="color:black; font-size:12.0pt;font-family:"Calisto MT",serif">'+

--		N'Error al copiar la hoja de empaque: <br><br>'+
--		N'Parametro	1:	<br>' + @PP_PARAMETRO_01 +	'<br>'	+
--		N'Parametro 2:	<br>' + @PP_PARAMETRO_02 +	'<br>'	+
--		N'Parametro 3:	<br>' + @PP_PARAMETRO_03 +	'<br>'	+
--		N'Parametro 4:	<br>' + @PP_PARAMETRO_04 +	'<br>'	+
--		N'Parametro 5:	<br>' + @PP_PARAMETRO_05 +	'<br>'	+
--		N'Parametro 6:	<br>' + @PP_PARAMETRO_06 +	'<br>'	+
--		N'<br>'

--		EXEC msdb.dbo.sp_send_dbmail 
--		--@recipients=@VP_RECIPIENTS,
--		--@blind_copy_recipients='ALEJANDROD@PEARLLEATHER.COM.MX',
--		@recipients	=	'ALEJANDROD@PEARLLEATHER.COM.MX',
--		@subject = @VP_SUBJECT,
--		@body = @VP_BODY_HTML,  
--		@body_format = 'HTML',
--		@importance= 'NORMAL'--@VP_IMPORTANCE
--	----- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--	----- ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////