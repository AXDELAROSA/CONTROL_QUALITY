-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			QA INSPECCION DE LOTE PIEL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	29/MAR/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////






-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]') AND type in (N'U'))
	DROP TABLE [dbo].[INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INSPECCION_LOTE_PIEL]') AND type in (N'U'))
	DROP TABLE [dbo].[INSPECCION_LOTE_PIEL]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INSPECCION_LOTE_PIEL_RESULTADO]') AND type in (N'U'))
	DROP TABLE [dbo].[INSPECCION_LOTE_PIEL_RESULTADO]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INSPECCION_LOTE_PIEL_RESULTADO_LOG]') AND type in (N'U'))
	DROP TABLE [dbo].[INSPECCION_LOTE_PIEL_RESULTADO_LOG]
GO



-- //////////////////////////////////////////////////////////////
-- // INSPECCION_MATERIAL_RESULTADO
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD] (
	[K_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]	[INT] IDENTITY (1,1) NOT NULL,
	-- =================================
	[K_IMPORTACION_LOTE_PIEL]				[INT]			NOT NULL,
	[K_ITEM]								[INT]			NOT NULL,
	[LOTE]									[INT]			NOT NULL,
	[POSICION_PIEL]							[INT]			NOT NULL,
	[PIEL]									[INT]			NOT NULL,
	[K_INSPECCION_MATERIAL]					[INT]			NOT NULL,
	[ZONA]									VARCHAR(10)		NOT NULL,
	[VALOR]									DECIMAL(13,2)	NOT NULL,
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]
	ADD CONSTRAINT [PK_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]
		PRIMARY KEY CLUSTERED ([K_INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD])
GO


-- //////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // INSPECCION_MATERIAL_RESULTADO
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INSPECCION_LOTE_PIEL] (
	[K_INSPECCION_LOTE_PIEL]				[INT] IDENTITY (1,1) NOT NULL,
	-- =================================
	[K_IMPORTACION_LOTE_PIEL]				[INT]			NOT NULL,
	[K_ITEM]								[INT]			NOT NULL,
	[LOTE]									[INT]			NOT NULL,
	--[PIEL]									[INT]			NOT NULL,
	[K_INSPECCION_MATERIAL]					[INT]			NOT NULL,
	[OPCION_SELECCIONADA]					VARCHAR(255)	NOT NULL,
	[ACEPTADO]								[INT]			DEFAULT 1,
	-- =================================	
	[COMENTARIO]							VARCHAR(255)	DEFAULT '',
	[F_INSPECCION]							DATE			NOT NULL
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[INSPECCION_LOTE_PIEL]
	ADD CONSTRAINT [PK_INSPECCION_LOTE_PIEL]
		PRIMARY KEY CLUSTERED ([K_INSPECCION_LOTE_PIEL])
GO


-- //////////////////////////////////////////////////////


ALTER TABLE [dbo].[INSPECCION_LOTE_PIEL] 
	ADD		[K_USUARIO_ALTA]				[INT]		NOT NULL,
			[F_ALTA]						[DATETIME]	NOT NULL,
			[K_USUARIO_CAMBIO]				[INT]		NOT NULL,
			[F_CAMBIO]						[DATETIME]	NOT NULL,
			[L_BORRADO]						[INT]		NOT NULL,
			[K_USUARIO_BAJA]				[INT]		NULL,
			[F_BAJA]						[DATETIME]	NULL;
GO





-- //////////////////////////////////////////////////////////////
-- // INSPECCION_MATERIAL_RESULTADO
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INSPECCION_LOTE_PIEL_RESULTADO] (
	[K_INSPECCION_LOTE_PIEL_RESULTADO]		[INT] IDENTITY (1,1) NOT NULL,
	-- =================================
	[K_IMPORTACION_LOTE_PIEL]				[INT]			NOT NULL,
	[K_ITEM]								[INT]			NOT NULL,
	[LOTE]									[INT]			NOT NULL,
	--[PIEL]									[INT]			NOT NULL,
	[ACEPTADO]								[INT]			NOT NULL,
	-- =================================	
	[K_USUARIO_ALTA]						[INT]			NOT NULL,
	[F_INSPECCION_LOTE_PIEL_RESULTADO]		DATE			NOT NULL
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[INSPECCION_LOTE_PIEL_RESULTADO]
	ADD CONSTRAINT [PK_INSPECCION_LOTE_PIEL_RESULTADO]
		PRIMARY KEY CLUSTERED ([K_INSPECCION_LOTE_PIEL_RESULTADO])
GO



-- //////////////////////////////////////////////////////////////
-- // [INSPECCION_LOTE_PIEL_RESULTADO_LOG]
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INSPECCION_LOTE_PIEL_RESULTADO_LOG] (
	[K_INSPECCION_LOTE_PIEL_RESULTADO_LOG]			[INT] IDENTITY (1,1) NOT NULL,
	-- =================================
	[K_TIPO_INSPECCION_MATERIAL_ORDEN_COMPRA_LOG]	[INT]			NOT NULL,
	[K_IMPORTACION_LOTE_PIEL]						[INT]			NOT NULL,
	[K_ITEM]										[INT]			NOT NULL,
	[LOTE]											[INT]			NOT NULL,
	--[PIEL]											[INT]			NOT NULL,
	[K_INSPECCION_MATERIAL]							[INT]			DEFAULT 0,
	-- =================================			
	[VALOR_ANTERIOR]								VARCHAR(150)	DEFAULT '',	
	[VALOR_NUEVO]									VARCHAR(150)	DEFAULT '',
	-- =================================
	[K_USUARIO_AUTORIZACION]						[INT]			NOT NULL,
	[COMENTARIO]									VARCHAR(255)	NOT NULL
	
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[INSPECCION_LOTE_PIEL_RESULTADO_LOG]
	ADD CONSTRAINT [PK_INSPECCION_LOTE_PIEL_RESULTADO_LOG]
		PRIMARY KEY CLUSTERED ([K_INSPECCION_LOTE_PIEL_RESULTADO_LOG])
GO


-- //////////////////////////////////////////////////////


ALTER TABLE [dbo].[INSPECCION_LOTE_PIEL_RESULTADO_LOG] 
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
