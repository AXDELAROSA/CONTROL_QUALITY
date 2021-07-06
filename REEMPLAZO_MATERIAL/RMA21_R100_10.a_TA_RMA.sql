-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			RMA
-- // OPERATION:		TABLE
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210609
-- ////////////////////////////////////////////////////////////// 

USE	[DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DETAILS_RMA]') AND type in (N'U'))
	DROP TABLE [dbo].[DETAILS_RMA]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[HEADER_RMA]') AND type in (N'U'))
	DROP TABLE [dbo].[HEADER_RMA]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[STATUS_RMA]') AND type in (N'U'))
	DROP TABLE [dbo].[STATUS_RMA]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TIPO_RMA]') AND type in (N'U'))
	DROP TABLE [dbo].[TIPO_RMA]
GO


-- ////////////////////////////////////////////////////////////////
-- //					TIPO_RMA				 
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[TIPO_RMA] (
	[K_TIPO_RMA]				[INT]			NOT NULL,
	[D_TIPO_RMA]				[VARCHAR](100)	NOT NULL,
	[C_TIPO_RMA]				[VARCHAR](255)	NOT NULL,
	[S_TIPO_RMA]				[VARCHAR](10)	NOT NULL,
	[O_TIPO_RMA]				[INT]			NOT NULL,
	[L_TIPO_RMA]				[INT]			NOT NULL
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[TIPO_RMA]
	ADD CONSTRAINT [PK_TIPO_RMA]
		PRIMARY KEY CLUSTERED ([K_TIPO_RMA])
GO
CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_TIPO_RMA_01_DESCRIPCION] 
	   ON [dbo].[TIPO_RMA] ( [D_TIPO_RMA] )
GO

-- //////////////////////////////////////////////////////////////
-- //				CI - TIPO_RMA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_TIPO_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_TIPO_RMA]
GO
CREATE PROCEDURE [dbo].[PG_CI_TIPO_RMA]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_TIPO_RMA				INT,
	@PP_D_TIPO_RMA				VARCHAR(100),
	@PP_C_TIPO_RMA				VARCHAR(255),
	@PP_S_TIPO_RMA				VARCHAR(10),
	@PP_O_TIPO_RMA				INT,
	@PP_L_TIPO_RMA				INT
AS				
	-- ===========================
IF (
		SELECT	COUNT(K_TIPO_RMA)
		FROM	TIPO_RMA
		WHERE	K_TIPO_RMA	=	@PP_K_TIPO_RMA
	)	>= 1
BEGIN
	UPDATE	TIPO_RMA
	SET	
		[D_TIPO_RMA]		= @PP_D_TIPO_RMA, 
		[C_TIPO_RMA]		= @PP_C_TIPO_RMA, 
		[S_TIPO_RMA]		= @PP_S_TIPO_RMA,
		[O_TIPO_RMA]		= @PP_O_TIPO_RMA, 
		[L_TIPO_RMA]		= @PP_L_TIPO_RMA	
	WHERE	[K_TIPO_RMA]		= @PP_K_TIPO_RMA
END
ELSE
BEGIN
	INSERT INTO TIPO_RMA
			(	[K_TIPO_RMA], [D_TIPO_RMA], 
				[C_TIPO_RMA], [S_TIPO_RMA], 
				[O_TIPO_RMA], [L_TIPO_RMA]		)
	VALUES	
			(	@PP_K_TIPO_RMA, @PP_D_TIPO_RMA, 
				@PP_C_TIPO_RMA, @PP_S_TIPO_RMA,
				@PP_O_TIPO_RMA, @PP_L_TIPO_RMA	 )
END
GO															-- SELECT * FROM TIPO_RMA
SET NOCOUNT ON
EXECUTE [dbo].[PG_CI_TIPO_RMA] 0,0,00, 'SIN DEFINIR',							'', 'SINDF',	130,0		-- SIN DEFINIR
-- =================================================================================
EXECUTE [dbo].[PG_CI_TIPO_RMA] 0,0,01, 'REEMPLAZO DE MATERIAL',					'', 'RMA',		10,1		-- RMA
-- =================================================================================
EXECUTE [dbo].[PG_CI_TIPO_RMA] 0,0,02, 'ORDEN ESPECIAL DE CORTE',				'', 'ORDEN',	20,1		-- PEDIDO ESPECIAL
---- =================================================================================
SET NOCOUNT OFF
GO


-- ////////////////////////////////////////////////////////////////
-- //					STATUS_RMA				 
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[STATUS_RMA] (
	[K_STATUS_RMA]				[INT]			NOT NULL,
	[D_STATUS_RMA]				[VARCHAR](100)	NOT NULL,
	[C_STATUS_RMA]				[VARCHAR](255)	NOT NULL,
	[S_STATUS_RMA]				[VARCHAR](10)	NOT NULL,
	[O_STATUS_RMA]				[INT]			NOT NULL,
	[L_STATUS_RMA]				[INT]			NOT NULL
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[STATUS_RMA]
	ADD CONSTRAINT [PK_STATUS_RMA]
		PRIMARY KEY CLUSTERED ([K_STATUS_RMA])
GO
CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_STATUS_RMA_01_DESCRIPCION] 
	   ON [dbo].[STATUS_RMA] ( [D_STATUS_RMA] )
GO

-- //////////////////////////////////////////////////////////////
-- //				CI - STATUS_RMA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_STATUS_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_STATUS_RMA]
GO
CREATE PROCEDURE [dbo].[PG_CI_STATUS_RMA]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_STATUS_RMA				INT,
	@PP_D_STATUS_RMA				VARCHAR(100),
	@PP_C_STATUS_RMA				VARCHAR(255),
	@PP_S_STATUS_RMA				VARCHAR(10),
	@PP_O_STATUS_RMA				INT,
	@PP_L_STATUS_RMA				INT
AS				
	-- ===========================
IF (
		SELECT	COUNT(K_STATUS_RMA)
		FROM	STATUS_RMA
		WHERE	K_STATUS_RMA	=	@PP_K_STATUS_RMA
	)	>= 1
BEGIN
	UPDATE	STATUS_RMA
	SET	
		[D_STATUS_RMA]		= @PP_D_STATUS_RMA, 
		[C_STATUS_RMA]		= @PP_C_STATUS_RMA, 
		[S_STATUS_RMA]		= @PP_S_STATUS_RMA,
		[O_STATUS_RMA]		= @PP_O_STATUS_RMA, 
		[L_STATUS_RMA]		= @PP_L_STATUS_RMA	
	WHERE	[K_STATUS_RMA]		= @PP_K_STATUS_RMA
END
ELSE
BEGIN
	INSERT INTO STATUS_RMA
			(	[K_STATUS_RMA], [D_STATUS_RMA], 
				[C_STATUS_RMA], [S_STATUS_RMA], 
				[O_STATUS_RMA], [L_STATUS_RMA]		)
	VALUES	
			(	@PP_K_STATUS_RMA, @PP_D_STATUS_RMA, 
				@PP_C_STATUS_RMA, @PP_S_STATUS_RMA,
				@PP_O_STATUS_RMA, @PP_L_STATUS_RMA	 )
END
GO															-- SELECT * FROM STATUS_RMA
SET NOCOUNT ON
EXECUTE [dbo].[PG_CI_STATUS_RMA] 0,0,00, 'CANCELADA',							'', 'CANCL',	130,1		-- ACTUALIZA QUIEN LA GENERA
-- =================================================================================
EXECUTE [dbo].[PG_CI_STATUS_RMA] 0,0,01, 'REGISTRADA',							'', 'REGIS',	10,1		-- ESTATUS INICIAL
-- =================================================================================
EXECUTE [dbo].[PG_CI_STATUS_RMA] 0,0,02, 'PENDIENTE POR GTE. DEPTO',			'', 'PNGTE-D',	20,1		-- ACTUALIZA GERENTE CALIDAD
EXECUTE [dbo].[PG_CI_STATUS_RMA] 0,0,03, 'DENEGADA POR GTE. DEPTO',				'', 'DNGTE-D',	30,1
---- =================================================================================
EXECUTE [dbo].[PG_CI_STATUS_RMA] 0,0,04, 'PENDIENTE POR GTE. PLANTA',			'', 'PNGTE-P',	40,1		-- ACTUALIZA GERENTE PLANTA
EXECUTE [dbo].[PG_CI_STATUS_RMA] 0,0,05, 'DENEGADA POR GTE. PLANTA',			'', 'DNGTE-P',	50,1
-- =================================================================================
EXECUTE [dbo].[PG_CI_STATUS_RMA] 0,0,06, 'APROBADA',							'', 'APROB',	60,1		-- ACTUALIZA GERENTE PLANTA
---- =================================================================================
EXECUTE [dbo].[PG_CI_STATUS_RMA] 0,0,07, 'EN PROCESO',							'', 'PROCS',	70,1
EXECUTE [dbo].[PG_CI_STATUS_RMA] 0,0,08, 'TERMINADA',							'', 'TERMI',	80,1
---- =================================================================================
------EXECUTE [dbo].[PG_CI_STATUS_RMA] 0,0,10, 'PENDING SEND TO VENDOR',		'', 'PNVEN', 100,1		-- ACTUALIZA FINANZAS
--EXECUTE [dbo].[PG_CI_STATUS_RMA] 0,0,11, 'PENDING TO RECEIVE',			'', 'PNRCV', 110,1		-- ACTUALIZA FINANZAS
---- =================================================================================
--EXECUTE [dbo].[PG_CI_STATUS_RMA] 0,0,12, 'COMPLETE ORDER RECEIVED',		'', 'COMPL', 110,1		-- ACTUALIZA FINANZAS
--EXECUTE [dbo].[PG_CI_STATUS_RMA] 0,0,13, 'PARTIAL ORDER RECEIVED',		'', 'PRRCV', 130,1		-- ACTUALIZA FINANZAS
--EXECUTE [dbo].[PG_CI_STATUS_RMA] 0,0,14, 'PARTIAL ORDER CLOSED',			'', 'PRCOM', 140,1		-- ACTUALIZA FINANZAS
--EXECUTE [dbo].[PG_CI_STATUS_RMA] 0,0,15, 'RETURNED ORDER',				'', 'RETUR', 150,1		-- ACTUALIZA FINANZAS
SET NOCOUNT OFF
GO


-- ////////////////////////////////////////////////////////////////
-- //					RMA				 
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[HEADER_RMA] (
	[K_HEADER_RMA]					[INT] IDENTITY(1,1) NOT NULL,			
	-- ============================
	[K_STATUS_RMA]					[INT] NOT NULL,
	[K_TIPO_RMA]					[INT] NOT NULL,
	-- ============================
	[CUS_NO]						[VARCHAR](6) NOT NULL,
	[PROGRAM]						[VARCHAR](25) NOT NULL,
	[MODELNO]						[VARCHAR](3) NOT NULL,
	-- ============================
	[F_CREACION_RMA]				[DATE] NOT NULL,
	[F_ENTREGA_RMA]					[DATE] NULL,
	-- ============================
	[CREADA_POR_RMA]				[VARCHAR] (150) NOT NULL,
	[SOLICITADA_POR_RMA]			[VARCHAR] (150) NOT NULL,
	--[K_APROBADA_POR_RMA]			[INT] NOT NULL DEFAULT 0,
	-- ============================
	[C_RMA]							[NVARCHAR](MAX) NOT NULL DEFAULT '',
	[JOBNO]							[NVARCHAR](MAX) DEFAULT '',
	-- ============================
	[L_APLICA_COBRO]				[INT] NOT NULL DEFAULT 0
) ON [PRIMARY]
GO

--ALTER TABLE	[dbo].[HEADER_RMA]				-- AX: 20210630					
--ADD
--	[L_APLICA_COBRO]				[INT] NOT NULL DEFAULT 0
--GO

ALTER TABLE [dbo].[HEADER_RMA]
	ADD CONSTRAINT [PK_HEADER_RMA]
		PRIMARY KEY CLUSTERED ([K_HEADER_RMA])	
GO

ALTER TABLE [dbo].[HEADER_RMA] ADD 
	CONSTRAINT [FK_STATUS_RMA_01] 
		FOREIGN KEY ( K_STATUS_RMA ) 
		REFERENCES [dbo].[STATUS_RMA] (K_STATUS_RMA )
GO

ALTER TABLE [dbo].[HEADER_RMA] 
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL,
			[K_USUARIO_CAMBIO]			[INT] NOT NULL,
			[F_CAMBIO]					[DATETIME] NOT NULL,
			[L_BORRADO]					[INT] NOT NULL,
			[K_USUARIO_BAJA]			[INT] NULL,
			[F_BAJA]					[DATETIME] NULL;
GO
-- //////////////////////////////////////////////////////

-- ////////////////////////////////////////////////////////////////
-- //					DETAILS_RMA				 
-- ////////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[DETAILS_RMA] (
	[K_DETAILS_RMA]					[INT] IDENTITY (1,1) NOT NULL,
	[K_HEADER_RMA]					[INT] NOT NULL,
	-- ============================
	[CUS_NO]						[VARCHAR](6) NOT NULL,
	[MODELNO]						[VARCHAR](3) NOT NULL,
	[VERSIONNO]						[VARCHAR](5) NOT NULL,
	-- ============================
	[ITEM_NO]						[VARCHAR](15) NOT NULL,
	[CUS_ITEM_NO]					[VARCHAR](25) NOT NULL,
	[NET_AREA]						[DECIMAL](16,4) NOT NULL,
	-- ============================
	[CLAVE_DEFECTO_RMA]				[VARCHAR](15) NOT NULL,
	[D_DEFECTO_RMA]					[VARCHAR](150) NOT NULL,
	-- ============================
	[CANTIDAD_ORDENADA]				[INT]	NOT NULL DEFAULT 0,
	[PRECIO_UNITARIO]				[DECIMAL] (10,4) NOT NULL,
	-- ============================
	[CANTIDAD_ENVIADA]				[INT] NOT NULL,
	-- ============================
	[JOBNO]							[INT] NOT NULL DEFAULT 0,
	[SERIAL]						[INT] NOT NULL DEFAULT 0,
	-- ============================
	[GRUPO_ORDEN]					[INT] NOT NULL DEFAULT 0
) ON [PRIMARY]
GO

--ALTER TABLE	[dbo].[DETAILS_RMA]			--AX: 20210630					
--ADD
--	[GRUPO_ORDEN]					[INT] NOT NULL DEFAULT 0
--GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////

