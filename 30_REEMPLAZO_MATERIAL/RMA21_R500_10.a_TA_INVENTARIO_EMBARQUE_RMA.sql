-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			EMBARQUES
-- // OPERACION:		INVENTARIO_EMBARQUE_RMA 
-- //////////////////////////////////////////////////////////////
-- // Autor:			AX
-- // Fecha creación:	20210723
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////


-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INVENTARIO_EMBARQUE_LOG_RMA]') AND type in (N'U'))
	DROP TABLE [dbo].[INVENTARIO_EMBARQUE_LOG_RMA]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INVENTARIO_EMBARQUE_RMA]') AND type in (N'U'))
	DROP TABLE [dbo].[INVENTARIO_EMBARQUE_RMA]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ESTATUS_INVENTARIO_EMBARQUE_RMA]') AND type in (N'U'))
	DROP TABLE [dbo].[ESTATUS_INVENTARIO_EMBARQUE_RMA]
GO



-- //////////////////////////////////////////////////////////////
-- // ESTATUS_INVENTARIO_EMBARQUE_RMA
-- //////////////////////////////////////////////////////////////


CREATE TABLE [dbo].[ESTATUS_INVENTARIO_EMBARQUE_RMA] (
	[K_ESTATUS_INVENTARIO_EMBARQUE_RMA]	[INT]			NOT NULL,
	[D_ESTATUS_INVENTARIO_EMBARQUE_RMA]	[VARCHAR] (100) NOT NULL,
	[S_ESTATUS_INVENTARIO_EMBARQUE_RMA]	[VARCHAR] (10)	NOT NULL,
	[O_ESTATUS_INVENTARIO_EMBARQUE_RMA]	[INT]			NOT NULL,
	[C_ESTATUS_INVENTARIO_EMBARQUE_RMA]	[VARCHAR] (255) NOT NULL,
	[L_ESTATUS_INVENTARIO_EMBARQUE_RMA]	[INT]			NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[ESTATUS_INVENTARIO_EMBARQUE_RMA]
	ADD CONSTRAINT [PK_ESTATUS_INVENTARIO_EMBARQUE_RMA]
		PRIMARY KEY CLUSTERED ([K_ESTATUS_INVENTARIO_EMBARQUE_RMA])
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_ESTATUS_INVENTARIO_EMBARQUE_RMA_01_DESCRIPCION] 
	   ON [dbo].[ESTATUS_INVENTARIO_EMBARQUE_RMA] ( [D_ESTATUS_INVENTARIO_EMBARQUE_RMA] )
GO

-- //////////////////////////////////////////////////////////////


--ALTER TABLE [dbo].[ESTATUS_INVENTARIO_EMBARQUE_RMA] ADD 
--	CONSTRAINT [FK_ESTATUS_INVENTARIO_EMBARQUE_RMA_01] 
--		FOREIGN KEY ( [L_ESTATUS_INVENTARIO_EMBARQUE_RMA] ) 
--		REFERENCES [dbo].[ESTATUS_ACTIVO] ( [K_ESTATUS_ACTIVO] )
--GO


-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_ESTATUS_INVENTARIO_EMBARQUE_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_ESTATUS_INVENTARIO_EMBARQUE_RMA]
GO


CREATE PROCEDURE [dbo].[PG_CI_ESTATUS_INVENTARIO_EMBARQUE_RMA]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	-- ========================================
	@PP_K_ESTATUS_INVENTARIO_EMBARQUE_RMA	INT,
	@PP_D_ESTATUS_INVENTARIO_EMBARQUE_RMA	VARCHAR(100),
	@PP_S_ESTATUS_INVENTARIO_EMBARQUE_RMA	VARCHAR(10),
	@PP_O_ESTATUS_INVENTARIO_EMBARQUE_RMA	INT,
	@PP_C_ESTATUS_INVENTARIO_EMBARQUE_RMA	VARCHAR(255),
	@PP_L_ESTATUS_INVENTARIO_EMBARQUE_RMA	INT
AS
	-- ===============================
	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_ESTATUS_INVENTARIO_EMBARQUE_RMA
							FROM	ESTATUS_INVENTARIO_EMBARQUE_RMA
							WHERE	K_ESTATUS_INVENTARIO_EMBARQUE_RMA=@PP_K_ESTATUS_INVENTARIO_EMBARQUE_RMA
	-- ===============================
	IF @VP_K_EXISTE IS NULL
		INSERT INTO ESTATUS_INVENTARIO_EMBARQUE_RMA	
			(	K_ESTATUS_INVENTARIO_EMBARQUE_RMA,				D_ESTATUS_INVENTARIO_EMBARQUE_RMA, 
				S_ESTATUS_INVENTARIO_EMBARQUE_RMA,				O_ESTATUS_INVENTARIO_EMBARQUE_RMA,
				C_ESTATUS_INVENTARIO_EMBARQUE_RMA,
				L_ESTATUS_INVENTARIO_EMBARQUE_RMA				)		
		VALUES	
			(	@PP_K_ESTATUS_INVENTARIO_EMBARQUE_RMA,			@PP_D_ESTATUS_INVENTARIO_EMBARQUE_RMA,	
				@PP_S_ESTATUS_INVENTARIO_EMBARQUE_RMA,			@PP_O_ESTATUS_INVENTARIO_EMBARQUE_RMA,
				@PP_C_ESTATUS_INVENTARIO_EMBARQUE_RMA,
				@PP_L_ESTATUS_INVENTARIO_EMBARQUE_RMA			)
	ELSE
		UPDATE	ESTATUS_INVENTARIO_EMBARQUE_RMA
		SET		D_ESTATUS_INVENTARIO_EMBARQUE_RMA	= @PP_D_ESTATUS_INVENTARIO_EMBARQUE_RMA,	
				S_ESTATUS_INVENTARIO_EMBARQUE_RMA	= @PP_S_ESTATUS_INVENTARIO_EMBARQUE_RMA,			
				O_ESTATUS_INVENTARIO_EMBARQUE_RMA	= @PP_O_ESTATUS_INVENTARIO_EMBARQUE_RMA,
				C_ESTATUS_INVENTARIO_EMBARQUE_RMA	= @PP_C_ESTATUS_INVENTARIO_EMBARQUE_RMA,
				L_ESTATUS_INVENTARIO_EMBARQUE_RMA	= @PP_L_ESTATUS_INVENTARIO_EMBARQUE_RMA	
		WHERE	K_ESTATUS_INVENTARIO_EMBARQUE_RMA=@PP_K_ESTATUS_INVENTARIO_EMBARQUE_RMA
	-- =========================================================
GO
-- //////////////////////////////////////////////////////////////



-- ===============================================
SET NOCOUNT ON
-- ===============================================
EXECUTE [dbo].[PG_CI_ESTATUS_INVENTARIO_EMBARQUE_RMA] 0, 0, 0, 'BAJA POR INVENTARIO',			'BAJA_INV', 0, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_INVENTARIO_EMBARQUE_RMA] 0, 0, 1, 'INGRESO A EMBARQUE',			'INGRE_EMBR', 1, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_INVENTARIO_EMBARQUE_RMA] 0, 0, 2, 'POR EMBARCAR',					'POR_EMBARQ', 2, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_INVENTARIO_EMBARQUE_RMA] 0, 0, 3, 'EMBARCADO',						'EMBARCADO', 3, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_INVENTARIO_EMBARQUE_RMA] 0, 0, 4, 'FACTURADO',						'FACTURADO', 4, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_INVENTARIO_EMBARQUE_RMA] 0, 0, 5, 'REVISION QC',					'REV_QC', 5, '', 1
GO-- ===============================================
SET NOCOUNT OFF
-- ===============================================

-- //////////////////////////////////////////////////////////////
-- // INVENTARIO_EMBARQUE_RMA
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INVENTARIO_EMBARQUE_RMA] (
	[K_INVENTARIO_EMBARQUE_RMA]				[INT] IDENTITY (1,1) NOT NULL,
	-- =================================
	[K_ESTATUS_INVENTARIO_EMBARQUE_RMA]		[INT]			NOT NULL,
	[ITEM_NO]								VARCHAR(100)	NOT NULL,		
	[QTY]									[INT]			NOT NULL,	
	[CUBE_WIDTH]							DECIMAL(13,5)	NOT NULL,
	[SERIAL_1]								VARCHAR(50)		NOT NULL,	
	[SERIAL_2]								VARCHAR(50)		NULL,
	[COLOR]									VARCHAR(100)	NOT NULL,
	[CUSTOMER]								VARCHAR(100)	NOT NULL,
	[CUS_PART_NO]							VARCHAR(100)	NOT NULL,
	[PROD_CAT]								VARCHAR(10)		NOT NULL,
	[D_PROD_CAT]							VARCHAR(100)	NOT NULL,
	-- =================================	
	[N_EMBARQUE]							[INT]			NULL DEFAULT 0,
	[TOTAL_CAJAS]							[INT]			NULL DEFAULT 0,
	[PACKING_NO]							VARCHAR(50)		NULL,
	[INVOICE_NO]							VARCHAR(50)		NULL,
	-- =================================	
	[F_INVENTARIO_EMBARQUE_RMA]				DATETIME		NOT NULL
)ON [PRIMARY]	
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[INVENTARIO_EMBARQUE_RMA]
	ADD CONSTRAINT [PK_INVENTARIO_EMBARQUE_RMA]
		PRIMARY KEY CLUSTERED ([K_INVENTARIO_EMBARQUE_RMA])
GO
-- //////////////////////////////////////////////////////////////
ALTER TABLE [dbo].[INVENTARIO_EMBARQUE_RMA] 
	ADD		[K_USUARIO_ALTA]				[INT]		NOT NULL,
			[F_ALTA]						[DATETIME]	NOT NULL,
			[K_USUARIO_CAMBIO]				[INT]		NOT NULL,
			[F_CAMBIO]						[DATETIME]	NOT NULL,
			[L_BORRADO]						[INT]		NOT NULL,
			[K_USUARIO_BAJA]				[INT]		NULL,
			[F_BAJA]						[DATETIME]	NULL;
GO


-- //////////////////////////////////////////////////////////////
-- // INVENTARIO_EMBARQUE_LOG_RMA
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INVENTARIO_EMBARQUE_LOG_RMA] (
	[K_INVENTARIO_EMBARQUE_LOG_RMA]				[INT] IDENTITY (1,1) NOT NULL,
	-- =================================
	[K_ESTATUS_INVENTARIO_EMBARQUE]			[INT]			NOT NULL,
	[ITEM_NO]								VARCHAR(100)	NOT NULL,		
	[QTY]									[INT]			NOT NULL,	
	[CUBE_WIDTH]							DECIMAL(13,5)	NOT NULL,
	[SERIAL_1]								VARCHAR(50)		NOT NULL,	
	[SERIAL_2]								VARCHAR(50)		NULL,
	[COLOR]									VARCHAR(100)	NOT NULL,
	[CUSTOMER]								VARCHAR(100)	NOT NULL,
	[CUS_PART_NO]							VARCHAR(100)	NOT NULL,
	[PROD_CAT]								VARCHAR(10)		NOT NULL,
	[D_PROD_CAT]							VARCHAR(100)	NOT NULL,
	-- =================================	
	[N_EMBARQUE]							[INT]			NULL DEFAULT 0,	
	[PACKING_NO]							VARCHAR(50)		NULL,
	[INVOICE_NO]							VARCHAR(50)		NULL,
	-- =================================	
	[F_INVENTARIO_EMBARQUE_LOG_RMA]				DATETIME		NOT NULL
)ON [PRIMARY]	
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[INVENTARIO_EMBARQUE_LOG_RMA]
	ADD CONSTRAINT [PK_INVENTARIO_EMBARQUE_LOG_RMA]
		PRIMARY KEY CLUSTERED ([K_INVENTARIO_EMBARQUE_LOG_RMA])
GO
-- //////////////////////////////////////////////////////////////

ALTER TABLE [dbo].[INVENTARIO_EMBARQUE_LOG_RMA] 
	ADD		[K_USUARIO_ALTA]				[INT]		NOT NULL,
			[F_ALTA]						[DATETIME]	NOT NULL,
			[K_USUARIO_CAMBIO]				[INT]		NOT NULL,
			[F_CAMBIO]						[DATETIME]	NOT NULL,
			[L_BORRADO]						[INT]		NOT NULL,
			[K_USUARIO_BAJA]				[INT]		NULL,
			[F_BAJA]						[DATETIME]	NULL;
GO
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
