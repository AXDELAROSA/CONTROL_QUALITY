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


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INSPECCION_LOTE_PIEL_MARCA_NATURAL]') AND type in (N'U'))
	DROP TABLE [dbo].[INSPECCION_LOTE_PIEL_MARCA_NATURAL]
GO

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



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ESTATUS_INSPECCION_LOTE_PIEL]') AND type in (N'U'))
	DROP TABLE [dbo].[ESTATUS_INSPECCION_LOTE_PIEL]
GO



-- //////////////////////////////////////////////////////////////
-- // ESTATUS_INSPECCION_LOTE_PIEL
-- //////////////////////////////////////////////////////////////


CREATE TABLE [dbo].[ESTATUS_INSPECCION_LOTE_PIEL] (
	[K_ESTATUS_INSPECCION_LOTE_PIEL]	[INT]			NOT NULL,
	[D_ESTATUS_INSPECCION_LOTE_PIEL]	[VARCHAR] (100) NOT NULL,
	[S_ESTATUS_INSPECCION_LOTE_PIEL]	[VARCHAR] (10)	NOT NULL,
	[O_ESTATUS_INSPECCION_LOTE_PIEL]	[INT]			NOT NULL,
	[C_ESTATUS_INSPECCION_LOTE_PIEL]	[VARCHAR] (255) NOT NULL,
	[L_ESTATUS_INSPECCION_LOTE_PIEL]	[INT]			NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[ESTATUS_INSPECCION_LOTE_PIEL]
	ADD CONSTRAINT [PK_ESTATUS_INSPECCION_LOTE_PIEL]
		PRIMARY KEY CLUSTERED ([K_ESTATUS_INSPECCION_LOTE_PIEL])
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_ESTATUS_INSPECCION_LOTE_PIEL_01_DESCRIPCION] 
	   ON [dbo].[ESTATUS_INSPECCION_LOTE_PIEL] ( [D_ESTATUS_INSPECCION_LOTE_PIEL] )
GO

-- //////////////////////////////////////////////////////////////


--ALTER TABLE [dbo].[ESTATUS_INSPECCION_LOTE_PIEL] ADD 
--	CONSTRAINT [FK_ESTATUS_INSPECCION_LOTE_PIEL_01] 
--		FOREIGN KEY ( [L_ESTATUS_INSPECCION_LOTE_PIEL] ) 
--		REFERENCES [dbo].[ESTATUS_ACTIVO] ( [K_ESTATUS_ACTIVO] )
--GO


-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_ESTATUS_INSPECCION_LOTE_PIEL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_ESTATUS_INSPECCION_LOTE_PIEL]
GO


CREATE PROCEDURE [dbo].[PG_CI_ESTATUS_INSPECCION_LOTE_PIEL]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	-- ========================================
	@PP_K_ESTATUS_INSPECCION_LOTE_PIEL	INT,
	@PP_D_ESTATUS_INSPECCION_LOTE_PIEL	VARCHAR(100),
	@PP_S_ESTATUS_INSPECCION_LOTE_PIEL	VARCHAR(10),
	@PP_O_ESTATUS_INSPECCION_LOTE_PIEL	INT,
	@PP_C_ESTATUS_INSPECCION_LOTE_PIEL	VARCHAR(255),
	@PP_L_ESTATUS_INSPECCION_LOTE_PIEL	INT
AS
	-- ===============================

	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_ESTATUS_INSPECCION_LOTE_PIEL
							FROM	ESTATUS_INSPECCION_LOTE_PIEL
							WHERE	K_ESTATUS_INSPECCION_LOTE_PIEL=@PP_K_ESTATUS_INSPECCION_LOTE_PIEL

	-- ===============================

	IF @VP_K_EXISTE IS NULL
		INSERT INTO ESTATUS_INSPECCION_LOTE_PIEL	
			(	K_ESTATUS_INSPECCION_LOTE_PIEL,				D_ESTATUS_INSPECCION_LOTE_PIEL, 
				S_ESTATUS_INSPECCION_LOTE_PIEL,				O_ESTATUS_INSPECCION_LOTE_PIEL,
				C_ESTATUS_INSPECCION_LOTE_PIEL,
				L_ESTATUS_INSPECCION_LOTE_PIEL				)		
		VALUES	
			(	@PP_K_ESTATUS_INSPECCION_LOTE_PIEL,			@PP_D_ESTATUS_INSPECCION_LOTE_PIEL,	
				@PP_S_ESTATUS_INSPECCION_LOTE_PIEL,			@PP_O_ESTATUS_INSPECCION_LOTE_PIEL,
				@PP_C_ESTATUS_INSPECCION_LOTE_PIEL,
				@PP_L_ESTATUS_INSPECCION_LOTE_PIEL			)
	ELSE
		UPDATE	ESTATUS_INSPECCION_LOTE_PIEL
		SET		D_ESTATUS_INSPECCION_LOTE_PIEL	= @PP_D_ESTATUS_INSPECCION_LOTE_PIEL,	
				S_ESTATUS_INSPECCION_LOTE_PIEL	= @PP_S_ESTATUS_INSPECCION_LOTE_PIEL,			
				O_ESTATUS_INSPECCION_LOTE_PIEL	= @PP_O_ESTATUS_INSPECCION_LOTE_PIEL,
				C_ESTATUS_INSPECCION_LOTE_PIEL	= @PP_C_ESTATUS_INSPECCION_LOTE_PIEL,
				L_ESTATUS_INSPECCION_LOTE_PIEL	= @PP_L_ESTATUS_INSPECCION_LOTE_PIEL	
		WHERE	K_ESTATUS_INSPECCION_LOTE_PIEL=@PP_K_ESTATUS_INSPECCION_LOTE_PIEL

	-- =========================================================
GO

-- //////////////////////////////////////////////////////////////




-- ===============================================
SET NOCOUNT ON
-- ===============================================

EXECUTE [dbo].[PG_CI_ESTATUS_INSPECCION_LOTE_PIEL] 0, 0, 0, 'PENDIENTE',						'PENDIENTE', 0, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_INSPECCION_LOTE_PIEL] 0, 0, 1, 'INSPECCIONADO',					'INSPECNDO', 1, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_INSPECCION_LOTE_PIEL] 0, 0, 2, 'REVISION',							'REVISION', 2, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_INSPECCION_LOTE_PIEL] 0, 0, 3, 'ACEPTADO',							'ACEPTADO', 3, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_INSPECCION_LOTE_PIEL] 0, 0, 4, 'RECHAZADO',						'RECHAZADO', 4, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_INSPECCION_LOTE_PIEL] 0, 0, 5, 'MODIFICACION INSPECCION MANUAL',	'MODIF_MANL', 5, '', 1
GO
-- ===============================================
SET NOCOUNT OFF
-- ===============================================



-- //////////////////////////////////////////////////////////////
-- // [INSPECCION_LOTE_PIEL_MARCA_NATURAL]
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INSPECCION_LOTE_PIEL_MARCA_NATURAL] (
	[K_INSPECCION_LOTE_PIEL_MARCA_NATURAL]	[INT] IDENTITY (1,1) NOT NULL,
	-- =================================
	[K_IMPORTACION_LOTE_PIEL]				[INT]			NOT NULL,
	[K_ITEM]								[INT]			NOT NULL,
	[LOTE]									[INT]			NOT NULL,
	[PIEL]									[INT]			NOT NULL,
	[K_INSPECCION_MATERIAL]					[INT]			NOT NULL,
	[DEFECTO]								VARCHAR(255)	NOT NULL,
	[AREA_PORCENTAJE]						DECIMAL(13,2)	NOT NULL
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[INSPECCION_LOTE_PIEL_MARCA_NATURAL]
	ADD CONSTRAINT [PK_INSPECCION_LOTE_PIEL_MARCA_NATURAL]
		PRIMARY KEY CLUSTERED ([K_INSPECCION_LOTE_PIEL_MARCA_NATURAL])
GO


-- //////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // [INSPECCION_LOTE_PIEL_GROSS_SUAVIDAD]
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
-- // [INSPECCION_LOTE_PIEL]
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
	[K_ESTATUS_INSPECCION_LOTE_PIEL]		[INT]			NOT NULL,
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
	[K_ESTATUS_INSPECCION_LOTE_PIEL]				[INT]			NOT NULL,
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
