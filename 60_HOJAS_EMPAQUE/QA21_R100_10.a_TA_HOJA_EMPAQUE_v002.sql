-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			HOJA_EMPAQUE
-- // OPERATION:		TABLE
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210916
-- ////////////////////////////////////////////////////////////// 

USE	[DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HOJA_EMPAQUE]') AND type in (N'U'))
	DROP TABLE [dbo].[HOJA_EMPAQUE]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HOJA_EMPAQUE_CAPA_DIVISION]') AND type in (N'U'))
	DROP TABLE [dbo].[HOJA_EMPAQUE_CAPA_DIVISION]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HOJA_EMPAQUE_CAPA]') AND type in (N'U'))
	DROP TABLE [dbo].[HOJA_EMPAQUE_CAPA]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HOJA_EMPAQUE_PROCESO]') AND type in (N'U'))
	DROP TABLE [dbo].[HOJA_EMPAQUE_PROCESO]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HOJA_EMPAQUE_PROCESO_SIMBOLO]') AND type in (N'U'))
	DROP TABLE [dbo].[HOJA_EMPAQUE_PROCESO_SIMBOLO]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TIPO_PROCESO_SIMBOLO]') AND type in (N'U'))
	DROP TABLE [dbo].[TIPO_PROCESO_SIMBOLO]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HOJA_EMPAQUE_STATUS]') AND type in (N'U'))
	DROP TABLE [dbo].[HOJA_EMPAQUE_STATUS]
GO

-- ////////////////////////////////////////////////////////////////
-- //					HOJA_EMPAQUE_STATUS				 
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[HOJA_EMPAQUE_STATUS] (
	[K_HOJA_EMPAQUE_STATUS]				[INT]			NOT NULL,
	[D_HOJA_EMPAQUE_STATUS]				[VARCHAR](100)	NOT NULL,
	[C_HOJA_EMPAQUE_STATUS]				[VARCHAR](255)	NOT NULL,
	[S_HOJA_EMPAQUE_STATUS]				[VARCHAR](10)	NOT NULL,
	[O_HOJA_EMPAQUE_STATUS]				[INT]			NOT NULL,
	[L_HOJA_EMPAQUE_STATUS]				[INT]			NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HOJA_EMPAQUE_STATUS]
	ADD CONSTRAINT [PK_HOJA_EMPAQUE_STATUS]
		PRIMARY KEY CLUSTERED ([K_HOJA_EMPAQUE_STATUS])
GO
--CREATE UNIQUE NONCLUSTERED 
--	INDEX [UN_HOJA_EMPAQUE_STATUS_01_DESCRIPCION] 
--	   ON [dbo].[HOJA_EMPAQUE_STATUS] ( [D_HOJA_EMPAQUE_STATUS] )
--GO

-- //////////////////////////////////////////////////////////////
-- //				CI - SELECT * FROM HOJA_EMPAQUE_STATUS
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_HOJA_EMPAQUE_STATUS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_HOJA_EMPAQUE_STATUS]
GO
CREATE PROCEDURE [dbo].[PG_CI_HOJA_EMPAQUE_STATUS]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_HOJA_EMPAQUE_STATUS				INT,
	@PP_D_HOJA_EMPAQUE_STATUS				VARCHAR(100),
	@PP_C_HOJA_EMPAQUE_STATUS				VARCHAR(255),
	@PP_S_HOJA_EMPAQUE_STATUS				VARCHAR(10),
	@PP_O_HOJA_EMPAQUE_STATUS				INT,
	@PP_L_HOJA_EMPAQUE_STATUS				INT
AS				
	-- ===========================
IF (
		SELECT	COUNT(K_HOJA_EMPAQUE_STATUS)
		FROM	HOJA_EMPAQUE_STATUS
		WHERE	K_HOJA_EMPAQUE_STATUS	=	@PP_K_HOJA_EMPAQUE_STATUS
	)	>= 1
BEGIN
	UPDATE	HOJA_EMPAQUE_STATUS
	SET	
		[D_HOJA_EMPAQUE_STATUS]		= @PP_D_HOJA_EMPAQUE_STATUS, 
		[C_HOJA_EMPAQUE_STATUS]		= @PP_C_HOJA_EMPAQUE_STATUS, 
		[S_HOJA_EMPAQUE_STATUS]		= @PP_S_HOJA_EMPAQUE_STATUS,
		[O_HOJA_EMPAQUE_STATUS]		= @PP_O_HOJA_EMPAQUE_STATUS, 
		[L_HOJA_EMPAQUE_STATUS]		= @PP_L_HOJA_EMPAQUE_STATUS	
	WHERE	[K_HOJA_EMPAQUE_STATUS]		= @PP_K_HOJA_EMPAQUE_STATUS
END
ELSE
BEGIN
	INSERT INTO HOJA_EMPAQUE_STATUS
			(	[K_HOJA_EMPAQUE_STATUS], [D_HOJA_EMPAQUE_STATUS], 
				[C_HOJA_EMPAQUE_STATUS], [S_HOJA_EMPAQUE_STATUS], 
				[O_HOJA_EMPAQUE_STATUS], [L_HOJA_EMPAQUE_STATUS]		)
	VALUES	
			(	@PP_K_HOJA_EMPAQUE_STATUS, @PP_D_HOJA_EMPAQUE_STATUS, 
				@PP_C_HOJA_EMPAQUE_STATUS, @PP_S_HOJA_EMPAQUE_STATUS,
				@PP_O_HOJA_EMPAQUE_STATUS, @PP_L_HOJA_EMPAQUE_STATUS	 )
END
GO															-- SELECT * FROM HOJA_EMPAQUE_STATUS
SET NOCOUNT ON
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_STATUS] 0,0,00, 'INACTIVA',						'', 'INACT',	00,1
-- =================================================================================
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_STATUS] 0,0,01, 'ACTIVA',							'', 'ACTIV',	10,1
-- =================================================================================
SET NOCOUNT OFF
GO

---- ////////////////////////////////////////////////////////////////
---- //					TIPO_PROCESO_SIMBOLO						
---- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[TIPO_PROCESO_SIMBOLO] (
	[K_TIPO_PROCESO_SIMBOLO]		[INT] NOT NULL,
	-- ============================
	[D_TIPO_PROCESO_SIMBOLO]		[VARCHAR](500) NOT NULL DEFAULT '',
	[S_TIPO_PROCESO_SIMBOLO]		[VARCHAR](10)  NOT NULL DEFAULT '', -- #1: SKVIN // #2: LAMIN // #3: PRFOR // #4: RECUT // #5: QULTN // #6: EMBOS // #7: PRSONAL
	[O_TIPO_PROCESO_SIMBOLO]		[INT] NOT NULL DEFAULT 0		
	-- ============================
	-- ============================
) ON [PRIMARY]
GO

-- //////////////////////////////////////////////////////////////
-- //				CI - SELECT * FROM TIPO_PROCESO_SIMBOLO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_TIPO_PROCESO_SIMBOLO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_TIPO_PROCESO_SIMBOLO]
GO
CREATE PROCEDURE [dbo].[PG_CI_TIPO_PROCESO_SIMBOLO]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_TIPO_PROCESO_SIMBOLO			INT,
	-- ===========================
	@PP_D_TIPO_PROCESO_SIMBOLO			VARCHAR(100),
	@PP_S_TIPO_PROCESO_SIMBOLO			VARCHAR(10),
	@PP_O_TIPO_PROCESO_SIMBOLO			INT
AS				
	-- ===========================
IF (
		SELECT	COUNT(K_TIPO_PROCESO_SIMBOLO)
		FROM	TIPO_PROCESO_SIMBOLO
		WHERE	K_TIPO_PROCESO_SIMBOLO	=	@PP_K_TIPO_PROCESO_SIMBOLO
	)	>= 1
BEGIN
	UPDATE	TIPO_PROCESO_SIMBOLO
	SET		[D_TIPO_PROCESO_SIMBOLO]		= @PP_D_TIPO_PROCESO_SIMBOLO, 
			[S_TIPO_PROCESO_SIMBOLO]		= @PP_S_TIPO_PROCESO_SIMBOLO,
			[O_TIPO_PROCESO_SIMBOLO]		= @PP_O_TIPO_PROCESO_SIMBOLO	
	WHERE	[K_TIPO_PROCESO_SIMBOLO]		= @PP_K_TIPO_PROCESO_SIMBOLO
END
ELSE
BEGIN
	INSERT INTO TIPO_PROCESO_SIMBOLO
			(	[K_TIPO_PROCESO_SIMBOLO], [D_TIPO_PROCESO_SIMBOLO], 
				[S_TIPO_PROCESO_SIMBOLO], [O_TIPO_PROCESO_SIMBOLO]		)
	VALUES	
			(	@PP_K_TIPO_PROCESO_SIMBOLO, @PP_D_TIPO_PROCESO_SIMBOLO, 
				@PP_S_TIPO_PROCESO_SIMBOLO,	@PP_O_TIPO_PROCESO_SIMBOLO	)
END
GO															-- SELECT * FROM TIPO_PROCESO_SIMBOLO		---- #1: SKVIN // #2: LAMIN // #3: PRFOR // #4: RECUT // #5: QULTN // #6: EMBOS // #7: PRSON
SET NOCOUNT ON
-- =================================================================================
EXECUTE [dbo].[PG_CI_TIPO_PROCESO_SIMBOLO] 0,0,01, 'SKIVING',			'SKVIN',	0
EXECUTE [dbo].[PG_CI_TIPO_PROCESO_SIMBOLO] 0,0,02, 'LAMINATION',		'LAMIN',	0
EXECUTE [dbo].[PG_CI_TIPO_PROCESO_SIMBOLO] 0,0,03, 'PERFORATION',		'PRFOR',	0
EXECUTE [dbo].[PG_CI_TIPO_PROCESO_SIMBOLO] 0,0,04, 'RECUT',				'RECUT',	0
EXECUTE [dbo].[PG_CI_TIPO_PROCESO_SIMBOLO] 0,0,05, 'QUILTING',			'QULTN',	0
EXECUTE [dbo].[PG_CI_TIPO_PROCESO_SIMBOLO] 0,0,06, 'EMBOSSING',			'EMBOS',	0
EXECUTE [dbo].[PG_CI_TIPO_PROCESO_SIMBOLO] 0,0,06, 'PERSONALIZADO',		'PRSON',	0
-- =================================================================================
SET NOCOUNT OFF
GO


---- ////////////////////////////////////////////////////////////////
---- //					HOJA_EMPAQUE_PROCESO_SIMBOLO								-- SELECT * FROM COT19_COTIZACIONES_V9999_R0.DBO.PROCESS
---- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[HOJA_EMPAQUE_PROCESO_SIMBOLO] (
	[K_HOJA_EMPAQUE_PROCESO_SIMBOLO]		[INT] IDENTITY (1,1) NOT NULL,
	-- ============================
	[K_TIPO_PROCESO_SIMBOLO]				[INT] NOT NULL DEFAULT 0,		-- #1: SKVIN // #2: LAMIN // #3: PRFOR // #4: RECUT // #5: QULTN // #6: EMBOS // #7: PRSONAL
	-- ============================
	[D_HOJA_EMPAQUE_PROCESO_SIMBOLO]		[VARCHAR](500) NOT NULL DEFAULT '',
	[RUTA_HOJA_EMPAQUE_PROCESO_SIMBOLO]		[VARCHAR](500) NOT NULL
	-- ============================
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HOJA_EMPAQUE_PROCESO_SIMBOLO]
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL,
			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
			[F_CAMBIO]					[DATETIME] NOT NULL;
			--[L_BORRADO]					[INT] NOT NULL,
			--[K_USUARIO_BAJA]			[INT] NULL,
			--[F_BAJA]					[DATETIME] NULL;
GO


-- //////////////////////////////////////////////////////////////
-- //				CI - SELECT * FROM HOJA_EMPAQUE_PROCESO_SIMBOLO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_HOJA_EMPAQUE_PROCESO_SIMBOLO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_HOJA_EMPAQUE_PROCESO_SIMBOLO]
GO
CREATE PROCEDURE [dbo].[PG_CI_HOJA_EMPAQUE_PROCESO_SIMBOLO]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_TIPO_PROCESO_SIMBOLO					INT,
	-- ===========================
	@PP_D_HOJA_EMPAQUE_PROCESO_SIMBOLO			VARCHAR(100),
	@PP_RUTA_HOJA_EMPAQUE_PROCESO_SIMBOLO		VARCHAR(500)
AS				
	-- ===========================
--IF (
--		SELECT	COUNT(K_TIPO_PROCESO)
--		FROM	HOJA_EMPAQUE_PROCESO_SIMBOLO
--		WHERE	K_HOJA_EMPAQUE_PROCESO_SIMBOLO	=	@PP_K_HOJA_EMPAQUE_PROCESO_SIMBOLO
--	)	>= 1
--BEGIN
--	UPDATE	HOJA_EMPAQUE_PROCESO_SIMBOLO
--	SET		[D_HOJA_EMPAQUE_PROCESO_SIMBOLO]		= @PP_D_HOJA_EMPAQUE_PROCESO_SIMBOLO, 
--	WHERE	[K_HOJA_EMPAQUE_PROCESO_SIMBOLO]		= @PP_K_HOJA_EMPAQUE_PROCESO_SIMBOLO
--END
--ELSE
--BEGIN
	INSERT INTO HOJA_EMPAQUE_PROCESO_SIMBOLO
			(	[K_TIPO_PROCESO_SIMBOLO], [D_HOJA_EMPAQUE_PROCESO_SIMBOLO],
				[RUTA_HOJA_EMPAQUE_PROCESO_SIMBOLO]	,
				[K_USUARIO_ALTA]		,	[F_ALTA]			,		
				[K_USUARIO_CAMBIO]		,	[F_CAMBIO]			)
	VALUES	
			(	@PP_K_TIPO_PROCESO_SIMBOLO, @PP_D_HOJA_EMPAQUE_PROCESO_SIMBOLO,
				@PP_RUTA_HOJA_EMPAQUE_PROCESO_SIMBOLO	,
				139						,	GETDATE()			,
				139						,	GETDATE()			)
--END
GO															-- SELECT * FROM HOJA_EMPAQUE_PROCESO_SIMBOLO		---- #1: SKVIN // #2: LAMIN // #3: PRFOR // #4: RECUT // #5: QULTN // #6: EMBOS // #7: PRSON
SET NOCOUNT ON
-- =================================================================================
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_PROCESO_SIMBOLO] 0,0,02, '','\\10.1.1.5\documents\IT\001_DEVELOPER_FILES\APQP\AV_HE_PROCESO\2.JPG'
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_PROCESO_SIMBOLO] 0,0,03, '','\\10.1.1.5\documents\IT\001_DEVELOPER_FILES\APQP\AV_HE_PROCESO\3.JPG'
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_PROCESO_SIMBOLO] 0,0,05, '','\\10.1.1.5\documents\IT\001_DEVELOPER_FILES\APQP\AV_HE_PROCESO\5.JPG'
----------------------------------------------------------------------------------------
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_PROCESO_SIMBOLO] 0,0,02, '','\\10.1.1.5\documents\IT\001_DEVELOPER_FILES\APQP\AV_HE_PROCESO\2_2.JPG'
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_PROCESO_SIMBOLO] 0,0,02, '','\\10.1.1.5\documents\IT\001_DEVELOPER_FILES\APQP\AV_HE_PROCESO\2_3.JPG'
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_PROCESO_SIMBOLO] 0,0,02, '','\\10.1.1.5\documents\IT\001_DEVELOPER_FILES\APQP\AV_HE_PROCESO\2_4.JPG'
----------------------------------------------------------------------------------------
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_PROCESO_SIMBOLO] 0,0,03, '','\\10.1.1.5\documents\IT\001_DEVELOPER_FILES\APQP\AV_HE_PROCESO\3_2.JPG'
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_PROCESO_SIMBOLO] 0,0,03, '','\\10.1.1.5\documents\IT\001_DEVELOPER_FILES\APQP\AV_HE_PROCESO\3_3.JPG'
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_PROCESO_SIMBOLO] 0,0,03, '','\\10.1.1.5\documents\IT\001_DEVELOPER_FILES\APQP\AV_HE_PROCESO\3_4.JPG'
----------------------------------------------------------------------------------------
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_PROCESO_SIMBOLO] 0,0,06, 'PATRONES CON SKIP 22mm','\\10.1.1.5\documents\IT\001_DEVELOPER_FILES\APQP\AV_HE_PROCESO\6_1.JPG'
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_PROCESO_SIMBOLO] 0,0,06, 'PATRONES CON SKIP 20mm','\\10.1.1.5\documents\IT\001_DEVELOPER_FILES\APQP\AV_HE_PROCESO\6_2.JPG'
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_PROCESO_SIMBOLO] 0,0,06, 'DIRECCION DE CORTE DE KUFNER','\\10.1.1.5\documents\IT\001_DEVELOPER_FILES\APQP\AV_HE_PROCESO\6_3.JPG'

-- =================================================================================
SET NOCOUNT OFF
GO


---- ////////////////////////////////////////////////////////////////
---- //					HOJA_EMPAQUE_PROCESO				 
---- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[HOJA_EMPAQUE_PROCESO] (
	[K_HOJA_EMPAQUE_PROCESO]			[INT] IDENTITY (1,1) NOT NULL,
	--[K_HOJA_EMPAQUE]					[INT] NOT NULL,
	[CUS_NO]							[VARCHAR](6)	NOT NULL,
	[MODELNO]							[VARCHAR](3)	NOT NULL,
	[VERSIONNO]							[INT]			NOT NULL,
	-- ============================
	[ITEM_P]							[VARCHAR](50)	NOT NULL,	-- ES EL P DEL ITEM_NO
	-- ============================
	[K_PROCESO]							[INT] NOT NULL,
	[K_HOJA_EMPAQUE_PROCESO_SIMBOLO]	[INT] NOT NULL,
	--[L_HOJA_EMPAQUE_PROCESO]			[INT] NOT NULL,
	-- ============================
	[D_HOJA_EMPAQUE_PROCESO]			[VARCHAR](500) NULL
	-- ============================
) ON [PRIMARY]
GO
--ALTER TABLE [dbo].[HOJA_EMPAQUE_PROCESO]
--	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
--			[F_ALTA]					[DATETIME] NOT NULL,
--			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
--			[F_CAMBIO]					[DATETIME] NOT NULL;
--			--[L_BORRADO]					[INT] NOT NULL,
--			--[K_USUARIO_BAJA]			[INT] NULL,
--			--[F_BAJA]					[DATETIME] NULL;
--GO


-- ////////////////////////////////////////////////////////////////
-- //					HOJA_EMPAQUE_CAPA				 
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[HOJA_EMPAQUE_CAPA] (
	[K_HOJA_EMPAQUE_CAPA]				[INT] IDENTITY(1,1) NOT NULL,
	-- ============================
	[CUS_NO]							[VARCHAR](6)	NOT NULL,
	[MODELNO]							[VARCHAR](3)	NOT NULL,
	[VERSIONNO]							[INT]			NOT NULL,
	-- ============================
	[ITEM_P]							[VARCHAR](50)	NOT NULL,	-- ES EL P DEL ITEM_NO
	-- ============================
	[N_CAPA]							[INT] NOT NULL,
	[N_PATRONES_CAPA]					[INT] NOT NULL,
	-- ============================
	[AV_HOJA_EMPAQUE_CAPA]				[VARCHAR](500)	NOT NULL		--  CLIENTE / MODELO / VERSION / REVISION / CAPA
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HOJA_EMPAQUE_CAPA]
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL,
			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
			[F_CAMBIO]					[DATETIME] NOT NULL;
			--[L_BORRADO]					[INT] NOT NULL,
			--[K_USUARIO_BAJA]			[INT] NULL,
			--[F_BAJA]					[DATETIME] NULL;
GO


-- ////////////////////////////////////////////////////////////////
-- //					HOJA_EMPAQUE_CAPA_DIVISION				 
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[HOJA_EMPAQUE_CAPA_DIVISION] (
	[K_HOJA_EMPAQUE_CAPA_DIVISION]		[INT] NOT NULL,
	-- ============================
	[D_HOJA_EMPAQUE_CAPA_DIVISION]		[VARCHAR](500)	NOT NULL,
	[TOTAL_CAPAS]						[INT] NOT NULL
	-- ============================
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////////////
-- //				CI - SELECT * FROM HOJA_EMPAQUE_CAPA_DIVISION
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_HOJA_EMPAQUE_CAPA_DIVISION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_HOJA_EMPAQUE_CAPA_DIVISION]
GO
CREATE PROCEDURE [dbo].[PG_CI_HOJA_EMPAQUE_CAPA_DIVISION]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION	INT,
	@PP_D_HOJA_EMPAQUE_CAPA_DIVISION	VARCHAR(500),
	-- ===========================
	@PP_TOTAL_CAPAS						INT
AS				
	-- ===========================
IF (
		SELECT	COUNT(K_HOJA_EMPAQUE_CAPA_DIVISION)
		FROM	HOJA_EMPAQUE_CAPA_DIVISION
		WHERE	K_HOJA_EMPAQUE_CAPA_DIVISION	=	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION
	)	>= 1
BEGIN
	UPDATE	HOJA_EMPAQUE_CAPA_DIVISION
	SET		[D_HOJA_EMPAQUE_CAPA_DIVISION]		= @PP_D_HOJA_EMPAQUE_CAPA_DIVISION,
			[TOTAL_CAPAS]						= @PP_TOTAL_CAPAS	
	WHERE	[K_HOJA_EMPAQUE_CAPA_DIVISION]		= @PP_K_HOJA_EMPAQUE_CAPA_DIVISION
END
ELSE
BEGIN
	INSERT INTO HOJA_EMPAQUE_CAPA_DIVISION
			(	[K_HOJA_EMPAQUE_CAPA_DIVISION],		[D_HOJA_EMPAQUE_CAPA_DIVISION],
				[TOTAL_CAPAS]		)
	VALUES	
			(	@PP_K_HOJA_EMPAQUE_CAPA_DIVISION,	@PP_D_HOJA_EMPAQUE_CAPA_DIVISION,
				@PP_TOTAL_CAPAS		)
END
GO															-- SELECT * FROM HOJA_EMPAQUE_CAPA_DIVISION		---- #1: SKVIN // #2: LAMIN // #3: PRFOR // #4: RECUT // #5: QULTN // #6: EMBOS // #7: PRSON
SET NOCOUNT ON
-- =================================================================================
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_CAPA_DIVISION] 0,0,01, 'DIVISIÓN #1 - 1A',		1
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_CAPA_DIVISION] 0,0,02, 'DIVISIÓN #2 - 2A',		2
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_CAPA_DIVISION] 0,0,03, 'DIVISIÓN #3 - 2B',		2
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_CAPA_DIVISION] 0,0,04, 'DIVISIÓN #4 - 3A',		3
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_CAPA_DIVISION] 0,0,05, 'DIVISIÓN #5 - 3B',		3
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_CAPA_DIVISION] 0,0,06, 'DIVISIÓN #6 - 3C',		3
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_CAPA_DIVISION] 0,0,07, 'DIVISIÓN #7 - 3D',		3
EXECUTE [dbo].[PG_CI_HOJA_EMPAQUE_CAPA_DIVISION] 0,0,08, 'DIVISIÓN #8 - 4A',		4
-- =================================================================================
SET NOCOUNT OFF
GO


-- ////////////////////////////////////////////////////////////////
-- //					HOJA_EMPAQUE				 
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[HOJA_EMPAQUE] (
	[K_HOJA_EMPAQUE]				[INT] IDENTITY(1,1) NOT NULL,
	-- ============================
	[K_HOJA_EMPAQUE_STATUS]			[INT]			NOT NULL DEFAULT 1,
	-- ============================
	[CUS_NO]						[VARCHAR](6)	NOT NULL,
	[MODELNO]						[VARCHAR](3)	NOT NULL,
	[VERSIONNO]						[INT]			NOT NULL,
	-- ============================
	[ITEM_NO]						[VARCHAR](50)	NOT NULL,	-- ES EL NOMBRE COMPLETO DEL KIT.
	[COLOR]							[VARCHAR](50)	NOT NULL,	-- ES EL COLOR AL QUE PERTENECE EL KIT
	[ITEM_P]						[VARCHAR](50)	NOT NULL,	-- ES EL P DEL ITEM_NO
	[CUSTOMER_ITEM_NO]				[VARCHAR](50)	NOT NULL,
	[D_ITEM_NO]						[VARCHAR](500)	NOT NULL,
	-- ============================
	[CAJA_HOJA_EMPAQUE]				[VARCHAR] (150) NULL,
	[DIBUJO_HOJA_EMPAQUE]			[VARCHAR] (150) NULL,		-- CLIENTE / MODELO / VERSION / REVISION
	[REVISION_HOJA_EMPAQUE]			[INT]			NULL,
	-- ============================
	[STANDAR_PACK]					[INT]			NULL,
	[CANTIDAD_PATRONES]				[INT]			NULL,
	[RUTA_AYUDA_VISUAL_HEADER]		[VARCHAR](500)	NULL,
	-- ============================
	[K_HOJA_EMPAQUE_CAPA_DIVISION]	[INT]			NOT NULL DEFAULT 2,
	-- ============================
	[K_TIPO_CAMBIO_KIT]				[INT]	NOT NULL	--AX:20211203	//	#0: SIN CAMBIOS,	#1: LONGITUD,	#2: AGREGADO/ELIMINADO PROCESOS ESPECIALES,	#3: CAMBIO PROCESOS ESPECIALES, #4 REVISIÓN
) ON [PRIMARY]
GO


--ALTER TABLE [dbo].[HOJA_EMPAQUE]
--	ADD CONSTRAINT [PK_HOJA_EMPAQUE]
--		PRIMARY KEY CLUSTERED ([K_HOJA_EMPAQUE])	
--GO

ALTER TABLE [dbo].[HOJA_EMPAQUE]
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL,
			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
			[F_CAMBIO]					[DATETIME] NOT NULL,
			[L_BORRADO]					[INT] NOT NULL,
			[K_USUARIO_BAJA]			[INT] NULL,
			[F_BAJA]					[DATETIME] NULL;
GO
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////

INSERT INTO [dbo].[HOJA_EMPAQUE] (
	-- ============================
	[ITEM_NO]						,	-- ES EL NOMBRE COMPLETO DEL KIT.
	[K_HOJA_EMPAQUE_STATUS]			,
	-- ============================
	[CUS_NO]						,
	[MODELNO]						,
	[VERSIONNO]						,
	-- ============================
	[COLOR]							,	-- ES EL COLOR AL QUE PERTENECE EL KIT
	[ITEM_P]						,	-- ES EL P DEL ITEM_NO
	[CUSTOMER_ITEM_NO]				,
	[D_ITEM_NO]						,
	-- ============================
	--[CAJA_HOJA_EMPAQUE]				,
	--[DIBUJO_HOJA_EMPAQUE]			,		-- CLIENTE / MODELO / VERSION / REVISION
	--[REVISION_HOJA_EMPAQUE]			,
	-- ============================
	[STANDAR_PACK]						,
	[CANTIDAD_PATRONES]					,
	--[RUTA_AYUDA_VISUAL_HEADER]		,
	-- ============================
	[K_TIPO_CAMBIO_KIT]				,		--AX:20211203	//	#0: SIN CAMBIOS,	#1: LONGITUD,	#2: AGREGADO/ELIMINADO PROCESOS ESPECIALES,	#3: CAMBIO PROCESOS ESPECIALES, #4 REVISIÓN
	-- ============================
	[K_USUARIO_ALTA]				,
	[F_ALTA]						,
	[K_USUARIO_CAMBIO]				,
	[F_CAMBIO]						,
	[L_BORRADO]						)	
SELECT	
	DISTINCT(CCITMIDX_SQL.ITEM_NO) AS P,
	0,
	-- ============================
	CCITMIDX_SQL.CUS_NO,
	CCITMIDX_SQL.MODELNO,
	CCITMIDX_SQL.VERSIONNO,
	-- ============================
	COLOUR,
	LEFT(CCITMIDX_SQL.ITEM_NO,7),
	CUS_ITEM_NO,
	ITEM_DESC_1,
	CCITMIDX_SQL.user_def_fld_5,
	CCITMIDX_SQL.CUBE_QTY_PER,
	0,	89,	GETDATE(),	139,	GETDATE(),	0
	-- ============================
	--*
FROM	CCITMIDX_SQL		(NOLOCK)
INNER JOIN	CCCUSITM_SQL	(NOLOCK) ON CCCUSITM_SQL.ITEM_NO	= CCITMIDX_SQL.ITEM_NO
WHERE	CCITMIDX_SQL.ITEM_NO LIKE 'P%'
AND		CCCUSITM_SQL.CUS_NO			= CCITMIDX_SQL.CUS_NO			
AND		CCCUSITM_SQL.MODELNO		= CCITMIDX_SQL.MODELNO		
AND		CCCUSITM_SQL.VERSIONNO		= CCITMIDX_SQL.VERSIONNO		
ORDER BY CCITMIDX_SQL.CUS_NO, CCITMIDX_SQL.MODELNO, CCITMIDX_SQL.VERSIONNO, P DESC



INSERT INTO [HOJA_EMPAQUE_PROCESO] (
	--[K_HOJA_EMPAQUE]					,
	-- ============================
	[ITEM_P]							,
	-- ============================
	[CUS_NO]							,	
	[MODELNO]							,
	[VERSIONNO]							,
	-- ============================
	[K_PROCESO]							,
	[K_HOJA_EMPAQUE_PROCESO_SIMBOLO]	,
	-- ============================
	[D_HOJA_EMPAQUE_PROCESO]			)
SELECT	DISTINCT	(LEFT(HOJA_EMPAQUE.ITEM_NO,7)) AS IT,
		SPITMIDX_SQL.CUS_NO,
		SPITMIDX_SQL.MODELNO,
		SPITMIDX_SQL.VERSIONNO,
		--K_HOJA_EMPAQUE,
		K_PROCESS,
		(CASE
			WHEN	K_PROCESS IN (2,8,9,11,12,13)	THEN	1
			WHEN	K_PROCESS IN (3,10)				THEN	2
			WHEN	K_PROCESS IN (5,14,15)			THEN	3
			ELSE	0
		END) AS K_HOJA_EMPAQUE_PROCESO_SIMBOLO,
		D_PROCESS
		--* 
FROM	SPITMIDX_SQL	(NOLOCK)
INNER JOIN HOJA_EMPAQUE	(NOLOCK)	ON HOJA_EMPAQUE.CUS_NO	= SPITMIDX_SQL.CUS_NO
AND		HOJA_EMPAQUE.MODELNO	= SPITMIDX_SQL.MODELNO
AND		HOJA_EMPAQUE.VERSIONNO	= SPITMIDX_SQL.VERSIONNO
AND		HOJA_EMPAQUE.ITEM_NO	= SPITMIDX_SQL.ITEM_NO_KIT
ORDER BY SPITMIDX_SQL.CUS_NO,
		SPITMIDX_SQL.MODELNO,
		SPITMIDX_SQL.VERSIONNO,
		IT DESC