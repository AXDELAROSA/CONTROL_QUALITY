-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		PPMS_PEARL
-- // MODULE:			ALERTA_CALIDAD
-- // OPERATION:		TABLE
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20220322
-- ////////////////////////////////////////////////////////////// 

USE	[PPMS_PEARL]
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALERTA_CALIDAD_IMAGEN]') AND type in (N'U'))
	DROP TABLE [dbo].[ALERTA_CALIDAD_IMAGEN]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALERTA_CALIDAD_INICIAL]') AND type in (N'U'))
	DROP TABLE [dbo].[ALERTA_CALIDAD_INICIAL]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALERTA_CALIDAD_X_MODELO]') AND type in (N'U'))
	DROP TABLE [dbo].[ALERTA_CALIDAD_X_MODELO]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ALERTA_CALIDAD_X_CUS_ITEM_NO]') AND type in (N'U'))
	DROP TABLE [dbo].[ALERTA_CALIDAD_X_CUS_ITEM_NO]
GO


--ALTER TABLE [DBO].[CERTIFICACION_RPT]
--	ADD		[insp_paq]					[VARCHAR](250)	NULL default NULL,
--			[sello_certi]				[VARCHAR](3)	NULL default NULL;
--GO

-- ////////////////////////////////////////////////////////////////
-- //					ALERTA_CALIDAD_X_ITEM_NO				 
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[ALERTA_CALIDAD_X_CUS_ITEM_NO] (
	[K_ALERTA_CALIDAD_X_CUS_ITEM_NO]	[INT] IDENTITY(1,1) NOT NULL,
	-- ============================
	[CUS_NO]							[VARCHAR](250)		NOT NULL ,--DEFAULT 1,
	[MODELNO]							[VARCHAR](50)		NOT NULL ,--DEFAULT 1,
	[CUS_ITEM_NO]						[VARCHAR](50)		NOT NULL ,--DEFAULT 1,
	-- ============================
	[D_ALERTA_CALIDAD_X_CUS_ITEM_NO]	[NVARCHAR](MAX)		NOT NULL ,--DEFAULT 1,
	-- ============================
	[K_TIPO_PROCESO]					[INT]				NOT NULL ,
	[K_ALERTA_CALIDAD_IMAGEN]			[INT]				NOT NULL ,
	-- ============================
	[F_INICIAL]							[DATETIME]			NOT NULL,
	[F_FINAL]							[DATETIME]			NULL,
	-- ============================
	[L_ALERTA_CALIDAD_X_CUS_ITEM_NO]	[INT]				NOT NULL DEFAULT 1
	-- ============================
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ALERTA_CALIDAD_X_CUS_ITEM_NO]
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL,
			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
			[F_CAMBIO]					[DATETIME] NOT NULL,
			[L_BORRADO]					[INT] NOT NULL,
			[K_USUARIO_BAJA]			[INT] NULL,
			[F_BAJA]					[DATETIME] NULL;
GO


-- ////////////////////////////////////////////////////////////////
-- //					ALERTA_CALIDAD_X_MODELO				 
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[ALERTA_CALIDAD_X_MODELO] (
	[K_ALERTA_CALIDAD_X_MODELO]			[INT] IDENTITY(1,1) NOT NULL,
	-- ============================
	[CUS_NO]							[VARCHAR](250)		NOT NULL ,--DEFAULT 1,
	[MODELNO]							[VARCHAR](50)		NOT NULL ,--DEFAULT 1,
	-- ============================
	[D_ALERTA_CALIDAD_X_MODELO]			[NVARCHAR](MAX)		NOT NULL ,--DEFAULT 1,
	-- ============================
	[K_TIPO_PROCESO]					[INT]				NOT NULL ,
	[K_ALERTA_CALIDAD_IMAGEN]			[INT]				NOT NULL ,
	-- ============================
	[F_INICIAL]							[DATETIME]			NOT NULL,
	[F_FINAL]							[DATETIME]			NULL,
	-- ============================
	[L_ALERTA_CALIDAD_X_MODELO]			[INT]				NOT NULL --DEFAULT 0
	-- ============================
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ALERTA_CALIDAD_X_MODELO]
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL,
			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
			[F_CAMBIO]					[DATETIME] NOT NULL,
			[L_BORRADO]					[INT] NOT NULL,
			[K_USUARIO_BAJA]			[INT] NULL,
			[F_BAJA]					[DATETIME] NULL;
GO


-- ////////////////////////////////////////////////////////////////
-- //					ALERTA_CALIDAD_INICIAL				 
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[ALERTA_CALIDAD_INICIAL] (
	[K_ALERTA_CALIDAD_INICIAL]			[INT] IDENTITY(1,1) NOT NULL,
	-- ============================
	[K_TIPO_PROCESO]					[INT]				NOT NULL, --DEFAULT 0
	[D_ALERTA_CALIDAD_INICIAL]			[NVARCHAR](MAX)		NOT NULL ,--DEFAULT 1,
	-- ============================
	[K_ALERTA_CALIDAD_IMAGEN]			[INT]				NOT NULL ,
	-- ============================
	[F_INICIAL]							[DATETIME]			NOT NULL,
	[F_FINAL]							[DATETIME]			NULL,
	-- ============================
	--[O_ALERTA_CALIDAD_INICIAL]			[INT]				NOT NULL ,--DEFAULT 0
	[L_ALERTA_CALIDAD_INICIAL]			[INT]				NOT NULL DEFAULT 1
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ALERTA_CALIDAD_INICIAL]
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL,
			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
			[F_CAMBIO]					[DATETIME] NOT NULL,
			[L_BORRADO]					[INT] NOT NULL,
			[K_USUARIO_BAJA]			[INT] NULL,
			[F_BAJA]					[DATETIME] NULL;
GO


-- ////////////////////////////////////////////////////////////////
-- //					ALERTA_CALIDAD_IMAGEN				 
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[ALERTA_CALIDAD_IMAGEN] (
	[K_ALERTA_CALIDAD_IMAGEN]				[INT] IDENTITY(1,1) NOT NULL,
	-- ============================
	[D_ALERTA_CALIDAD_IMAGEN]				[NVARCHAR](MAX) NOT NULL,
	-- ============================
	[ALERTA_CALIDAD_RUTA_CARPETA]			[NVARCHAR](MAX) NOT NULL,
	[ALERTA_CALIDAD_IMAGEN]					[NVARCHAR](MAX) NOT NULL,
	-- ============================
	[L_ALERTA_CALIDAD_IMAGEN]				[INT]	NOT NULL --DEFAULT 0
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ALERTA_CALIDAD_IMAGEN]
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL,
			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
			[F_CAMBIO]					[DATETIME] NOT NULL,
			[L_BORRADO]					[INT] NOT NULL,
			[K_USUARIO_BAJA]			[INT] NULL,
			[F_BAJA]					[DATETIME] NULL;
GO


-- //////////////////////////////////////////////////////////////
-- //				CI - SELECT * FROM ALERTA_CALIDAD_IMAGEN
-- //////////////////////////////////////////////////////////////	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN]
GO
CREATE PROCEDURE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================	
	@PP_L_ALERTA_CALIDAD_IMAGEN			INT,
	@PP_D_ALERTA_CALIDAD_IMAGEN			NVARCHAR(MAX),
	-- ===========================
	@PP_ALERTA_CALIDAD_RUTA_CARPETA		NVARCHAR(MAX),
	@PP_ALERTA_CALIDAD_IMAGEN			NVARCHAR(MAX)
AS				
	-- ===========================
	INSERT INTO ALERTA_CALIDAD_IMAGEN
			(	
				[D_ALERTA_CALIDAD_IMAGEN]			,
				[L_ALERTA_CALIDAD_IMAGEN]			,
				[ALERTA_CALIDAD_RUTA_CARPETA]		,
				[ALERTA_CALIDAD_IMAGEN]				,
				-- ===========================
				[K_USUARIO_ALTA]	,	[F_ALTA]	,
				[K_USUARIO_CAMBIO]	,	[F_CAMBIO]	,
				[L_BORRADO]			,
				[K_USUARIO_BAJA]	,	[F_BAJA]	)
	VALUES	
			(	@PP_D_ALERTA_CALIDAD_IMAGEN			,
				@PP_L_ALERTA_CALIDAD_IMAGEN	 		,
				@PP_ALERTA_CALIDAD_RUTA_CARPETA		,
				@PP_ALERTA_CALIDAD_IMAGEN			,
				-- ===========================
				139	,	GETDATE()	,
				139	,	GETDATE()	,
				0	,
				NULL,	NULL	)

GO															-- SELECT * FROM ALERTA_CALIDAD_IMAGEN
SET NOCOUNT ON
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'AECE.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'ASDF.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'AVAS.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'BOFU.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'CAFE.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'CAL2.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'CAL7.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'CEDI.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'CFCJ.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'CFKL.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'CIFE.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'CILA.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'COGI.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'DAPE.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'DCRF.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'DITO.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'ESPE.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'FLLO.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'FTCI.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'HIDE.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'HLMR.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'LIGR.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'LKJH.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'MTMZ.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'NMPL.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'PEDA.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'PEDI.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'PLMG.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'POIU.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'QWER.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'RETO.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'SC72.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'SC74.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'SCYL.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'SDFI.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'TNFL.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'TONA.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'VATO.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'VREF.PNG'
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_IMAGEN] 0,0,1,'' ,'\\10.1.1.5\DOCUMENTS\Quality\QC\ImagenesAlertas\', 'VREQ.PNG'
-- =================================================================================
SET NOCOUNT OFF
GO


-- //////////////////////////////////////////////////////////////
-- //				CI - SELECT * FROM ALERTA_CALIDAD_INICIAL
-- //////////////////////////////////////////////////////////////	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_ALERTA_CALIDAD_INICIAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_ALERTA_CALIDAD_INICIAL]
GO
CREATE PROCEDURE [dbo].[PG_CI_ALERTA_CALIDAD_INICIAL]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_TIPO_PROCESO					INT,
	@PP_D_ALERTA_CALIDAD_INICIAL		NVARCHAR(MAX),
	@PP_K_ALERTA_CALIDAD_IMAGEN			INT,
	-- ===========================
	--@PP_O_ALERTA_CALIDAD_INICIAL		INT,
	--@PP_L_ALERTA_CALIDAD_INICIAL		INT,
	-- ===========================
	@PP_F_INICIAL						DATE,
	@PP_F_FINAL							DATE
AS				
	-- ===========================
	INSERT INTO ALERTA_CALIDAD_INICIAL
			(	K_TIPO_PROCESO				,
				[D_ALERTA_CALIDAD_INICIAL]	,	[K_ALERTA_CALIDAD_IMAGEN]	,
				--[O_ALERTA_CALIDAD_INICIAL]	,	
				--[L_ALERTA_CALIDAD_INICIAL]	,
				[F_INICIAL]					,	[F_FINAL]					,
				-- ===========================
				[K_USUARIO_ALTA]	,	[F_ALTA]	,
				[K_USUARIO_CAMBIO]	,	[F_CAMBIO]	,
				[L_BORRADO]			,
				[K_USUARIO_BAJA]	,	[F_BAJA]	)
	VALUES	
			(	@PP_K_TIPO_PROCESO				,
				@PP_D_ALERTA_CALIDAD_INICIAL	,	@PP_K_ALERTA_CALIDAD_IMAGEN	,
				--@PP_O_ALERTA_CALIDAD_INICIAL	,	
				--@PP_L_ALERTA_CALIDAD_INICIAL	,
				@PP_F_INICIAL					,	@PP_F_FINAL					,
				-- ===========================
				139	,	GETDATE()	,	139	,	GETDATE()	,	0	,
				NULL,	NULL	)

GO															-- SELECT * FROM ALERTA_CALIDAD_INICIAL
SET NOCOUNT ON
-- CERTIFICACIÓN VISUAL, LLEVA ESTA ALERTA Y DESPUES SE REVISA POR NÚMERO DE PARTE DE CLIENTE.
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_INICIAL] 0,0,1 ,'CONDICIÓN DE IMPRESIÓN DE CÓDIGO DE ETIQUETAS',	1, '2022-03-20',	null
--------------------------------------------------------------------------------------
--	EN PERFORADO NO SE VERIFICA POR NÚMERO DE PARTE DE CLIENTE.
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_INICIAL] 0,0,2 ,'REVISIÓN DE FIBRAS EXPUESTAS',						3, '2022-03-20',	null
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_INICIAL] 0,0,2 ,'SELLOS DE CALIDAD',								7, '2022-03-20',	null
EXECUTE [dbo].[PG_CI_ALERTA_CALIDAD_INICIAL] 0,0,2 ,'CONTEO DE PAQUETES',								6, '2022-03-20',	null
-- =================================================================================
SET NOCOUNT OFF
GO

-- //////////////////////////////////////////////////////////////
-- //				SELECT * FROM ALERTA_CALIDAD_X_MODELO
-- //////////////////////////////////////////////////////////////
	INSERT INTO ALERTA_CALIDAD_X_MODELO
			(	
				[MODELNO]						,
				[CUS_NO]						,	
				-- ============================
				[D_ALERTA_CALIDAD_X_MODELO]		,
				-- ============================
				[K_TIPO_PROCESO],	[K_ALERTA_CALIDAD_IMAGEN]	,
				-- ============================
				[F_INICIAL]						,	[F_FINAL]					,
				-- ============================
				[L_ALERTA_CALIDAD_X_MODELO]		,	
				-- ===========================
				[K_USUARIO_ALTA]	,	[F_ALTA]	,
				[K_USUARIO_CAMBIO]	,	[F_CAMBIO]	,
				[L_BORRADO]			,
				[K_USUARIO_BAJA]	,	[F_BAJA]	)
	SELECT
				DISTINCT(LEFT(LTRIM(RTRIM(USER_DEF_FLD_3)),3)) AS MODELNO,
				CUS_NO,	
				ALERTA,
				1	,	( SELECT TOP 1 K_ALERTA_CALIDAD_IMAGEN FROM ALERTA_CALIDAD_IMAGEN WHERE ALERTA_CALIDAD_IMAGEN = CODIGO + '.PNG' ),
				'2022-03-20',	'2023-03-20',	
				0,	-- PROVISIONALMENTE VAN A AESTAR DESHABILITADAS.
				--QC_ALERTAS.* 
				-- ===========================
				139	,	GETDATE()	,	139	,	GETDATE()	,	0	,
				NULL,	NULL
	FROM	PPMS_PEARL.DBO.QC_ALERTAS
	INNER JOIN	DATA_02.DBO.OEcusitm_SQL	ON LTRIM(RTRIM(OECUSITM_SQL.CUS_ITEM_NO))	= LTRIM(RTRIM(QC_ALERTAS.NOPARTE))
	WHERE	OEcusitm_SQL.item_no	LIKE 'P%'
	ORDER	BY MODELNO, cus_no, Alerta

-- //////////////////////////////////////////////////////////////
-- //				SELECT * FROM ALERTA_CALIDAD_X_CUS_ITEM_NO
-- //////////////////////////////////////////////////////////////
	INSERT INTO ALERTA_CALIDAD_X_CUS_ITEM_NO
			(	
				[MODELNO]						,
				[CUS_NO]						,
				[CUS_ITEM_NO]					,
				-- ============================
				[D_ALERTA_CALIDAD_X_CUS_ITEM_NO]		,
				-- ============================
				[K_TIPO_PROCESO],		[K_ALERTA_CALIDAD_IMAGEN]	,
				-- ============================
				[F_INICIAL]						,	[F_FINAL]					,
				-- ============================
				[L_ALERTA_CALIDAD_X_CUS_ITEM_NO]		,	
				-- ===========================
				[K_USUARIO_ALTA]	,	[F_ALTA]	,
				[K_USUARIO_CAMBIO]	,	[F_CAMBIO]	,
				[L_BORRADO]			,
				[K_USUARIO_BAJA]	,	[F_BAJA]	)
	SELECT
				LEFT(LTRIM(RTRIM(USER_DEF_FLD_3)),3) AS MODELNO,
				CUS_NO,	
				cus_item_no,
				ALERTA,
				1	,	( SELECT TOP 1 K_ALERTA_CALIDAD_IMAGEN FROM ALERTA_CALIDAD_IMAGEN WHERE ALERTA_CALIDAD_IMAGEN = CODIGO + '.PNG' ),
				'2022-03-20',	NULL,	1,
				--QC_ALERTAS.* 
				-- ===========================
				139	,	GETDATE()	,	139	,	GETDATE()	,	0	,
				NULL,	NULL
	FROM	PPMS_PEARL.DBO.QC_ALERTAS
	INNER JOIN	DATA_02.DBO.OEcusitm_SQL	ON LTRIM(RTRIM(OECUSITM_SQL.CUS_ITEM_NO))	= LTRIM(RTRIM(QC_ALERTAS.NOPARTE))
	WHERE	OEcusitm_SQL.item_no	LIKE 'P%'
	ORDER	BY MODELNO, cus_no, Alerta
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////