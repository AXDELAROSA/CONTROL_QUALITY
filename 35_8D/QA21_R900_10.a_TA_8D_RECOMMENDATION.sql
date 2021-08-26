-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			QC 8D_RECOMMENDATION
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	25/AGO/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[8D_RECOMMENDATION]') AND type in (N'U'))
	DROP TABLE [dbo].[8D_RECOMMENDATION]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[8D_RECOMMENDATION_EVIDENCE]') AND type in (N'U'))
	DROP TABLE [dbo].[8D_RECOMMENDATION_EVIDENCE]
GO

-- //////////////////////////////////////////////////////////////
-- // 8D_RECOMMENDATION
-- //////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[8D_RECOMMENDATION] (
	[K_8D_RECOMMENDATION]			[INT]			IDENTITY(1,1),
	-- =================================
	[K_8D]							[INT]			NOT NULL,
	[RECOMMENDATION]				VARCHAR(MAX)	NOT NULL,
	[LEARNED_LESSON]				VARCHAR(255)	NOT NULL
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[8D_RECOMMENDATION]
	ADD CONSTRAINT [PK_8D_RECOMMENDATION]
		PRIMARY KEY CLUSTERED ([K_8D_RECOMMENDATION])
GO

-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[8D_RECOMMENDATION] 
	ADD		[K_USUARIO_ALTA]				[INT]		NOT NULL,
			[F_ALTA]						[DATETIME]	NOT NULL,
			[K_USUARIO_CAMBIO]				[INT]		NOT NULL,
			[F_CAMBIO]						[DATETIME]	NOT NULL,
			[L_BORRADO]						[INT]		NOT NULL,
			[K_USUARIO_BAJA]				[INT]		NULL,
			[F_BAJA]						[DATETIME]	NULL;
GO


-- //////////////////////////////////////////////////////////////
-- // [8D_RECOMMENDATION_EVIDENCE]
-- //////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[8D_RECOMMENDATION_EVIDENCE] (
	[K_8D_RECOMMENDATION_EVIDENCE]		[INT]			IDENTITY(1,1),
	-- =================================
	[K_8D]							[INT]			NOT NULL,
	-- =================================
	[RUTA]							VARCHAR(255)	NOT NULL,
	[NOMBRE_ARCHIVO]				VARCHAR(255)	NOT NULL,
	[TIPO_ARCHIVO]					VARCHAR(50)		NOT NULL	
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[8D_RECOMMENDATION_EVIDENCE]
	ADD CONSTRAINT [PK_8D_RECOMMENDATION_EVIDENCE]
		PRIMARY KEY CLUSTERED ([K_8D_RECOMMENDATION_EVIDENCE])
GO

-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[8D_RECOMMENDATION_EVIDENCE] 
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
