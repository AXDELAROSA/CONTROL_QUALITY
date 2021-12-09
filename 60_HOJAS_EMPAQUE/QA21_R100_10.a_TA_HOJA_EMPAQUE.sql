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
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HEADER_HOJA_EMPAQUE]') AND type in (N'U'))
	DROP TABLE [dbo].[HEADER_HOJA_EMPAQUE]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DETAILS_HOJA_EMPAQUE]') AND type in (N'U'))
	DROP TABLE [dbo].[DETAILS_HOJA_EMPAQUE]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AV_HOJA_EMPAQUE]') AND type in (N'U'))
	DROP TABLE [dbo].[AV_HOJA_EMPAQUE]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[STATUS_HOJA_EMPAQUE]') AND type in (N'U'))
	DROP TABLE [dbo].[STATUS_HOJA_EMPAQUE]
GO

-- ////////////////////////////////////////////////////////////////
-- //					AV_HOJA_EMPAQUE				 
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[AV_HOJA_EMPAQUE] (
	[K_AV_HOJA_EMPAQUE]				[INT] IDENTITY(1,1) NOT NULL,
	[D_AV_HOJA_EMPAQUE]				[VARCHAR](100)	NOT NULL,
	[C_AV_HOJA_EMPAQUE]				[VARCHAR](255)	NOT NULL,
	[S_AV_HOJA_EMPAQUE]				[VARCHAR](10)	NOT NULL,
	[O_AV_HOJA_EMPAQUE]				[INT]			NOT NULL,
	[T_AV_HOJA_EMPAQUE]				[INT]			NOT NULL,	-- ES EL TIPO DE AYUDA VISUAL DE ACUERDO AL SPECIAL PROCESS. O CARACTERÍSTICA AGREGADA.
	[L_AV_HOJA_EMPAQUE]				[INT]			NOT NULL
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[AV_HOJA_EMPAQUE]
	ADD CONSTRAINT [PK_AV_HOJA_EMPAQUE]
		PRIMARY KEY CLUSTERED ([K_AV_HOJA_EMPAQUE])
GO
CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_AV_HOJA_EMPAQUE_01_DESCRIPCION] 
	   ON [dbo].[AV_HOJA_EMPAQUE] ( [D_AV_HOJA_EMPAQUE] )
GO

-- //////////////////////////////////////////////////////////////
-- //				CI - SELECT * FROM AV_HOJA_EMPAQUE
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_AV_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_AV_HOJA_EMPAQUE]
GO
CREATE PROCEDURE [dbo].[PG_CI_AV_HOJA_EMPAQUE]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	--@PP_K_AV_HOJA_EMPAQUE				INT,
	@PP_D_AV_HOJA_EMPAQUE				VARCHAR(100),
	@PP_C_AV_HOJA_EMPAQUE				VARCHAR(255),
	@PP_S_AV_HOJA_EMPAQUE				VARCHAR(10),
	@PP_O_AV_HOJA_EMPAQUE				INT,
	@PP_T_AV_HOJA_EMPAQUE				INT,
	@PP_L_AV_HOJA_EMPAQUE				INT
AS				
	-- ===========================
--IF (
--		SELECT	COUNT(K_AV_HOJA_EMPAQUE)
--		FROM	AV_HOJA_EMPAQUE
--		WHERE	K_AV_HOJA_EMPAQUE	=	@PP_K_AV_HOJA_EMPAQUE
--	)	>= 1
--BEGIN
--	UPDATE	AV_HOJA_EMPAQUE
--	SET	
--		[D_AV_HOJA_EMPAQUE]		= @PP_D_AV_HOJA_EMPAQUE, 
--		[C_AV_HOJA_EMPAQUE]		= @PP_C_AV_HOJA_EMPAQUE, 
--		[S_AV_HOJA_EMPAQUE]		= @PP_S_AV_HOJA_EMPAQUE,
--		[O_AV_HOJA_EMPAQUE]		= @PP_O_AV_HOJA_EMPAQUE, 
--		[T_AV_HOJA_EMPAQUE]		= @PP_T_AV_HOJA_EMPAQUE,
--		[L_AV_HOJA_EMPAQUE]		= @PP_L_AV_HOJA_EMPAQUE	
--	WHERE	[K_AV_HOJA_EMPAQUE]		= @PP_K_AV_HOJA_EMPAQUE
--END
--ELSE
--BEGIN
	INSERT INTO AV_HOJA_EMPAQUE
			(	--[K_AV_HOJA_EMPAQUE], 
				[D_AV_HOJA_EMPAQUE], 
				[C_AV_HOJA_EMPAQUE], [S_AV_HOJA_EMPAQUE], 
				[O_AV_HOJA_EMPAQUE], [T_AV_HOJA_EMPAQUE],
				[L_AV_HOJA_EMPAQUE]		)
	VALUES	
			(	--@PP_K_AV_HOJA_EMPAQUE, 
				@PP_D_AV_HOJA_EMPAQUE, 
				@PP_C_AV_HOJA_EMPAQUE, @PP_S_AV_HOJA_EMPAQUE,
				@PP_O_AV_HOJA_EMPAQUE, @PP_T_AV_HOJA_EMPAQUE,
				@PP_L_AV_HOJA_EMPAQUE	 )
--END
GO															-- SELECT * FROM AV_HOJA_EMPAQUE
SET NOCOUNT ON
EXECUTE [dbo].[PG_CI_AV_HOJA_EMPAQUE] 0,0, '',								'', '',			00,0,1
-- =================================================================================
SET NOCOUNT OFF
GO


-- ////////////////////////////////////////////////////////////////
-- //					STATUS_HOJA_EMPAQUE				 
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[STATUS_HOJA_EMPAQUE] (
	[K_STATUS_HOJA_EMPAQUE]				[INT]			NOT NULL,
	[D_STATUS_HOJA_EMPAQUE]				[VARCHAR](100)	NOT NULL,
	[C_STATUS_HOJA_EMPAQUE]				[VARCHAR](255)	NOT NULL,
	[S_STATUS_HOJA_EMPAQUE]				[VARCHAR](10)	NOT NULL,
	[O_STATUS_HOJA_EMPAQUE]				[INT]			NOT NULL,
	[L_STATUS_HOJA_EMPAQUE]				[INT]			NOT NULL
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[STATUS_HOJA_EMPAQUE]
	ADD CONSTRAINT [PK_STATUS_HOJA_EMPAQUE]
		PRIMARY KEY CLUSTERED ([K_STATUS_HOJA_EMPAQUE])
GO
CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_STATUS_HOJA_EMPAQUE_01_DESCRIPCION] 
	   ON [dbo].[STATUS_HOJA_EMPAQUE] ( [D_STATUS_HOJA_EMPAQUE] )
GO

-- //////////////////////////////////////////////////////////////
-- //				CI - SELECT * FROM STATUS_HOJA_EMPAQUE
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_STATUS_HOJA_EMPAQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_STATUS_HOJA_EMPAQUE]
GO
CREATE PROCEDURE [dbo].[PG_CI_STATUS_HOJA_EMPAQUE]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_STATUS_HOJA_EMPAQUE				INT,
	@PP_D_STATUS_HOJA_EMPAQUE				VARCHAR(100),
	@PP_C_STATUS_HOJA_EMPAQUE				VARCHAR(255),
	@PP_S_STATUS_HOJA_EMPAQUE				VARCHAR(10),
	@PP_O_STATUS_HOJA_EMPAQUE				INT,
	@PP_L_STATUS_HOJA_EMPAQUE				INT
AS				
	-- ===========================
IF (
		SELECT	COUNT(K_STATUS_HOJA_EMPAQUE)
		FROM	STATUS_HOJA_EMPAQUE
		WHERE	K_STATUS_HOJA_EMPAQUE	=	@PP_K_STATUS_HOJA_EMPAQUE
	)	>= 1
BEGIN
	UPDATE	STATUS_HOJA_EMPAQUE
	SET	
		[D_STATUS_HOJA_EMPAQUE]		= @PP_D_STATUS_HOJA_EMPAQUE, 
		[C_STATUS_HOJA_EMPAQUE]		= @PP_C_STATUS_HOJA_EMPAQUE, 
		[S_STATUS_HOJA_EMPAQUE]		= @PP_S_STATUS_HOJA_EMPAQUE,
		[O_STATUS_HOJA_EMPAQUE]		= @PP_O_STATUS_HOJA_EMPAQUE, 
		[L_STATUS_HOJA_EMPAQUE]		= @PP_L_STATUS_HOJA_EMPAQUE	
	WHERE	[K_STATUS_HOJA_EMPAQUE]		= @PP_K_STATUS_HOJA_EMPAQUE
END
ELSE
BEGIN
	INSERT INTO STATUS_HOJA_EMPAQUE
			(	[K_STATUS_HOJA_EMPAQUE], [D_STATUS_HOJA_EMPAQUE], 
				[C_STATUS_HOJA_EMPAQUE], [S_STATUS_HOJA_EMPAQUE], 
				[O_STATUS_HOJA_EMPAQUE], [L_STATUS_HOJA_EMPAQUE]		)
	VALUES	
			(	@PP_K_STATUS_HOJA_EMPAQUE, @PP_D_STATUS_HOJA_EMPAQUE, 
				@PP_C_STATUS_HOJA_EMPAQUE, @PP_S_STATUS_HOJA_EMPAQUE,
				@PP_O_STATUS_HOJA_EMPAQUE, @PP_L_STATUS_HOJA_EMPAQUE	 )
END
GO															-- SELECT * FROM STATUS_HOJA_EMPAQUE
SET NOCOUNT ON
EXECUTE [dbo].[PG_CI_STATUS_HOJA_EMPAQUE] 0,0,00, 'INACTIVA',						'', 'INACT',	00,1
-- =================================================================================
EXECUTE [dbo].[PG_CI_STATUS_HOJA_EMPAQUE] 0,0,01, 'ACTIVA',							'', 'ACTIV',	10,1
-- =================================================================================
SET NOCOUNT OFF
GO


-- ////////////////////////////////////////////////////////////////
-- //					HOJA_EMPAQUE				 
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[HEADER_HOJA_EMPAQUE] (
	[K_HEADER_HOJA_EMPAQUE]			[INT] IDENTITY(1,1) NOT NULL,
	-- ============================
	[K_STATUS_HOJA_EMPAQUE]			[INT]			NOT NULL DEFAULT 1,
	-- ============================
	[CUS_NO]						[VARCHAR](6)	NOT NULL,
	----[PROGRAM]						[VARCHAR](25)	NOT NULL,
	[MODELNO]						[VARCHAR](3)	NOT NULL,
	[VERSIONNO]						[INT]			NOT NULL,
	-- ============================
	[ITEM_NO]						[VARCHAR](50)	NOT NULL,
	[COLOR]							[VARCHAR](50)	NOT NULL,
	[ITEM_P]						[VARCHAR](50)	NOT NULL,
	[CUSTOMER_ITEM_NO]				[VARCHAR](50)	NOT NULL,
	[D_ITEM_NO]						[VARCHAR](500)	NOT NULL,
	-- ============================
	[CAJA_HOJA_EMPAQUE]				[VARCHAR] (150) NULL,
	[DIBUJO_HOJA_EMPAQUE]			[VARCHAR] (150) NULL,
	[REVISION_HOJA_EMPAQUE]			[INT]			NULL,
	-- ============================
	[RUTA_AYUDA_VISUAL_HEADER]		[VARCHAR](500)	NULL,
	-- ============================
	[K_TIPO_CAMBIO_KIT]				[INT]	NOT NULL		--AX:20210920	//	#0: SIN CAMBIOS,	#1: LONGITUD,	#2: AGREGADO/ELIMINADO PROCESOS ESPECIALES,	#3: CAMBIO PROCESOS ESPECIALES
) ON [PRIMARY]
GO


--ALTER TABLE [dbo].[HEADER_HOJA_EMPAQUE]
--	ADD CONSTRAINT [PK_HEADER_HOJA_EMPAQUE]
--		PRIMARY KEY CLUSTERED ([K_HEADER_HOJA_EMPAQUE])	
--GO

ALTER TABLE [dbo].[HEADER_HOJA_EMPAQUE]
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL,
			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
			[F_CAMBIO]					[DATETIME] NOT NULL,
			[L_BORRADO]					[INT] NOT NULL,
			[K_USUARIO_BAJA]			[INT] NULL,
			[F_BAJA]					[DATETIME] NULL;
GO
--ALTER TABLE [dbo].[HEADER_HOJA_EMPAQUE]
--ADD	[ITEM_P]						[VARCHAR](50)	NOT NULL DEFAULT ''
--GO
-- //////////////////////////////////////////////////////

---- ////////////////////////////////////////////////////////////////
---- //					DETAILS_HOJA_EMPAQUE				 
---- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[DETAILS_HOJA_EMPAQUE] (
	[K_DETAILS_HOJA_EMPAQUE]				[INT] IDENTITY (1,1) NOT NULL,
	[K_HEADER_HOJA_EMPAQUE]					[INT] NOT NULL,
	-- ============================
	[O_DETAILS_HOJA_EMPAQUE]				[INT] NOT NULL DEFAULT 0,
	-- ============================
	[D_DETAILS_HOJA_EMPAQUE]				[VARCHAR](500) NULL,
	[L_AYUDA_VISUAL]						[VARCHAR](500) NOT NULL,
	[K_AV_HOJA_EMPAQUE]						[INT] NOT NULL	DEFAULT 1	-- SE LE DEJA EL 1 PORQUE SERÁ UNA TABLA CON (IDENTITY) EN LA PRIMARY_KEY
	--[RUTA_AYUDA_VISUAL_DETAILS]			[VARCHAR](500) NULL
	-- ============================
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DETAILS_HOJA_EMPAQUE]
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

