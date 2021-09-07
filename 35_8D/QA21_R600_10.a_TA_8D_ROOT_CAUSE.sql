-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			QC 8D
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	24/AGO/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE]') AND type in (N'U'))
	DROP TABLE [dbo].[8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE]
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[8D_ROOT_CAUSE]') AND type in (N'U'))
	DROP TABLE [dbo].[8D_ROOT_CAUSE]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TIPO_ROOT_CAUSE_8D]') AND type in (N'U'))
	DROP TABLE [dbo].[TIPO_ROOT_CAUSE_8D]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CLASIFICACION_ROOT_CAUSE_8D]') AND type in (N'U'))
	DROP TABLE [dbo].[CLASIFICACION_ROOT_CAUSE_8D]
GO


-- //////////////////////////////////////////////////////////////
-- // TIPO_ROOT_CAUSE_8D
-- //////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[TIPO_ROOT_CAUSE_8D] (
	[K_TIPO_ROOT_CAUSE_8D]		[INT]			NOT NULL,
	[D_TIPO_ROOT_CAUSE_8D]		[VARCHAR] (100) NOT NULL,
	[S_TIPO_ROOT_CAUSE_8D]		[VARCHAR] (10)	NOT NULL,
	[O_TIPO_ROOT_CAUSE_8D]		[INT]			NOT NULL,
	[C_TIPO_ROOT_CAUSE_8D]		[VARCHAR] (255) NOT NULL,
	[L_TIPO_ROOT_CAUSE_8D]		[INT]			NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////
ALTER TABLE [dbo].[TIPO_ROOT_CAUSE_8D]
	ADD CONSTRAINT [PK_TIPO_ROOT_CAUSE_8D]
		PRIMARY KEY CLUSTERED ([K_TIPO_ROOT_CAUSE_8D])
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_TIPO_ROOT_CAUSE_8D_01_DESCRIPCION] 
	   ON [dbo].[TIPO_ROOT_CAUSE_8D] ( [D_TIPO_ROOT_CAUSE_8D] )
GO

-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_TIPO_ROOT_CAUSE_8D]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_TIPO_ROOT_CAUSE_8D]
GO


CREATE PROCEDURE [dbo].[PG_CI_TIPO_ROOT_CAUSE_8D]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	-- ========================================
	@PP_K_TIPO_ROOT_CAUSE_8D	INT,
	@PP_D_TIPO_ROOT_CAUSE_8D	VARCHAR(100),
	@PP_S_TIPO_ROOT_CAUSE_8D	VARCHAR(10),
	@PP_O_TIPO_ROOT_CAUSE_8D	INT,
	@PP_C_TIPO_ROOT_CAUSE_8D	VARCHAR(255),
	@PP_L_TIPO_ROOT_CAUSE_8D	INT
AS
	-- ===============================

	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_TIPO_ROOT_CAUSE_8D
							FROM	TIPO_ROOT_CAUSE_8D
							WHERE	K_TIPO_ROOT_CAUSE_8D=@PP_K_TIPO_ROOT_CAUSE_8D

	-- ===============================
	IF @VP_K_EXISTE IS NULL
		INSERT INTO TIPO_ROOT_CAUSE_8D	
			(	K_TIPO_ROOT_CAUSE_8D,				D_TIPO_ROOT_CAUSE_8D, 
				S_TIPO_ROOT_CAUSE_8D,				O_TIPO_ROOT_CAUSE_8D,
				C_TIPO_ROOT_CAUSE_8D,
				L_TIPO_ROOT_CAUSE_8D				)		
		VALUES	
			(	@PP_K_TIPO_ROOT_CAUSE_8D,			@PP_D_TIPO_ROOT_CAUSE_8D,	
				@PP_S_TIPO_ROOT_CAUSE_8D,			@PP_O_TIPO_ROOT_CAUSE_8D,
				@PP_C_TIPO_ROOT_CAUSE_8D,
				@PP_L_TIPO_ROOT_CAUSE_8D			)
	ELSE
		UPDATE	TIPO_ROOT_CAUSE_8D
		SET		D_TIPO_ROOT_CAUSE_8D	= @PP_D_TIPO_ROOT_CAUSE_8D,	
				S_TIPO_ROOT_CAUSE_8D	= @PP_S_TIPO_ROOT_CAUSE_8D,			
				O_TIPO_ROOT_CAUSE_8D	= @PP_O_TIPO_ROOT_CAUSE_8D,
				C_TIPO_ROOT_CAUSE_8D	= @PP_C_TIPO_ROOT_CAUSE_8D,
				L_TIPO_ROOT_CAUSE_8D	= @PP_L_TIPO_ROOT_CAUSE_8D	
		WHERE	K_TIPO_ROOT_CAUSE_8D=@PP_K_TIPO_ROOT_CAUSE_8D
GO
-- //////////////////////////////////////////////////////////////


-- ===============================================
SET NOCOUNT ON
-- ===============================================


EXECUTE [dbo].[PG_CI_TIPO_ROOT_CAUSE_8D] 0, 0, 1, 'WHY_1',			'WHY_1', 1, '', 1
EXECUTE [dbo].[PG_CI_TIPO_ROOT_CAUSE_8D] 0, 0, 2, 'WHY_2',			'WHY_2', 2, '', 1
EXECUTE [dbo].[PG_CI_TIPO_ROOT_CAUSE_8D] 0, 0, 3, 'WHY_3',			'WHY_3', 3, '', 1
EXECUTE [dbo].[PG_CI_TIPO_ROOT_CAUSE_8D] 0, 0, 4, 'WHY_4',			'WHY_4', 4, '', 1
EXECUTE [dbo].[PG_CI_TIPO_ROOT_CAUSE_8D] 0, 0, 5, 'WHY_5',			'WHY_5', 5, '', 1
EXECUTE [dbo].[PG_CI_TIPO_ROOT_CAUSE_8D] 0, 0, 6, 'CAUSE',			'CAUSE', 6, '', 1
EXECUTE [dbo].[PG_CI_TIPO_ROOT_CAUSE_8D] 0, 0, 7, 'CONTRIBUTION',	'CONTRIB', 7, '', 1
EXECUTE [dbo].[PG_CI_TIPO_ROOT_CAUSE_8D] 0, 0, 8, 'CAUS_ISH_1',		'CAUS_ISH_1', 8, '', 1
EXECUTE [dbo].[PG_CI_TIPO_ROOT_CAUSE_8D] 0, 0, 9, 'CAUS_ISH_2',		'CAUS_ISH_2', 9, '', 1
EXECUTE [dbo].[PG_CI_TIPO_ROOT_CAUSE_8D] 0, 0, 10, 'CAUS_ISH_3',	'CAUS_ISH_3', 10, '', 1
EXECUTE [dbo].[PG_CI_TIPO_ROOT_CAUSE_8D] 0, 0, 11, 'VAL_ISH_1',		'VAL_ISH_1', 11, '', 1
EXECUTE [dbo].[PG_CI_TIPO_ROOT_CAUSE_8D] 0, 0, 12, 'VAL_ISH_2',		'VAL_ISH_2', 12, '', 1
EXECUTE [dbo].[PG_CI_TIPO_ROOT_CAUSE_8D] 0, 0, 13, 'VAL_ISH_3',		'VAL_ISH_3', 13, '', 1
GO-- ===============================================
SET NOCOUNT OFF
-- ===============================================



-- //////////////////////////////////////////////////////////////
-- // CLASIFICACION_ROOT_CAUSE_8D
-- //////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[CLASIFICACION_ROOT_CAUSE_8D] (
	[K_CLASIFICACION_ROOT_CAUSE_8D]		[INT]			NOT NULL,
	[D_CLASIFICACION_ROOT_CAUSE_8D]		[VARCHAR] (100) NOT NULL,
	[S_CLASIFICACION_ROOT_CAUSE_8D]		[VARCHAR] (10)	NOT NULL,
	[O_CLASIFICACION_ROOT_CAUSE_8D]		[INT]			NOT NULL,
	[C_CLASIFICACION_ROOT_CAUSE_8D]		[VARCHAR] (255) NOT NULL,
	[L_CLASIFICACION_ROOT_CAUSE_8D]		[INT]			NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////
ALTER TABLE [dbo].[CLASIFICACION_ROOT_CAUSE_8D]
	ADD CONSTRAINT [PK_CLASIFICACION_ROOT_CAUSE_8D]
		PRIMARY KEY CLUSTERED ([K_CLASIFICACION_ROOT_CAUSE_8D])
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_CLASIFICACION_ROOT_CAUSE_8D_01_DESCRIPCION] 
	   ON [dbo].[CLASIFICACION_ROOT_CAUSE_8D] ( [D_CLASIFICACION_ROOT_CAUSE_8D] )
GO

-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_CLASIFICACION_ROOT_CAUSE_8D]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_CLASIFICACION_ROOT_CAUSE_8D]
GO


CREATE PROCEDURE [dbo].[PG_CI_CLASIFICACION_ROOT_CAUSE_8D]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	-- ========================================
	@PP_K_CLASIFICACION_ROOT_CAUSE_8D	INT,
	@PP_D_CLASIFICACION_ROOT_CAUSE_8D	VARCHAR(100),
	@PP_S_CLASIFICACION_ROOT_CAUSE_8D	VARCHAR(10),
	@PP_O_CLASIFICACION_ROOT_CAUSE_8D	INT,
	@PP_C_CLASIFICACION_ROOT_CAUSE_8D	VARCHAR(255),
	@PP_L_CLASIFICACION_ROOT_CAUSE_8D	INT
AS
	-- ===============================

	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_CLASIFICACION_ROOT_CAUSE_8D
							FROM	CLASIFICACION_ROOT_CAUSE_8D
							WHERE	K_CLASIFICACION_ROOT_CAUSE_8D=@PP_K_CLASIFICACION_ROOT_CAUSE_8D

	-- ===============================
	IF @VP_K_EXISTE IS NULL
		INSERT INTO CLASIFICACION_ROOT_CAUSE_8D	
			(	K_CLASIFICACION_ROOT_CAUSE_8D,				D_CLASIFICACION_ROOT_CAUSE_8D, 
				S_CLASIFICACION_ROOT_CAUSE_8D,				O_CLASIFICACION_ROOT_CAUSE_8D,
				C_CLASIFICACION_ROOT_CAUSE_8D,
				L_CLASIFICACION_ROOT_CAUSE_8D				)		
		VALUES	
			(	@PP_K_CLASIFICACION_ROOT_CAUSE_8D,			@PP_D_CLASIFICACION_ROOT_CAUSE_8D,	
				@PP_S_CLASIFICACION_ROOT_CAUSE_8D,			@PP_O_CLASIFICACION_ROOT_CAUSE_8D,
				@PP_C_CLASIFICACION_ROOT_CAUSE_8D,
				@PP_L_CLASIFICACION_ROOT_CAUSE_8D			)
	ELSE
		UPDATE	CLASIFICACION_ROOT_CAUSE_8D
		SET		D_CLASIFICACION_ROOT_CAUSE_8D	= @PP_D_CLASIFICACION_ROOT_CAUSE_8D,	
				S_CLASIFICACION_ROOT_CAUSE_8D	= @PP_S_CLASIFICACION_ROOT_CAUSE_8D,			
				O_CLASIFICACION_ROOT_CAUSE_8D	= @PP_O_CLASIFICACION_ROOT_CAUSE_8D,
				C_CLASIFICACION_ROOT_CAUSE_8D	= @PP_C_CLASIFICACION_ROOT_CAUSE_8D,
				L_CLASIFICACION_ROOT_CAUSE_8D	= @PP_L_CLASIFICACION_ROOT_CAUSE_8D	
		WHERE	K_CLASIFICACION_ROOT_CAUSE_8D=@PP_K_CLASIFICACION_ROOT_CAUSE_8D
GO
-- //////////////////////////////////////////////////////////////


-- ===============================================
SET NOCOUNT ON
-- ===============================================


EXECUTE [dbo].[PG_CI_CLASIFICACION_ROOT_CAUSE_8D] 0, 0, 1, 'OCURRENCE',		'OCURRENCE', 1, '', 1
EXECUTE [dbo].[PG_CI_CLASIFICACION_ROOT_CAUSE_8D] 0, 0, 2, 'DETECTION',		'DETECTION', 2, '', 1
EXECUTE [dbo].[PG_CI_CLASIFICACION_ROOT_CAUSE_8D] 0, 0, 3, 'SYSTEMATIC',	'SYSTEMATIC', 3, '', 1
EXECUTE [dbo].[PG_CI_CLASIFICACION_ROOT_CAUSE_8D] 0, 0, 4, 'ISHIKAWA',		'ISHIKAWA', 4, '', 1
GO-- ===============================================
SET NOCOUNT OFF
-- ===============================================


-- //////////////////////////////////////////////////////////////
-- // [8D_ROOT_CAUSE]
-- //////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[8D_ROOT_CAUSE] (
	[K_8D_ROOT_CAUSE]					[INT] IDENTITY(1,1)			NOT NULL,
	-- =================================
	[K_8D]								[INT]			NOT NULL,
	[K_CLASIFICACION_ROOT_CAUSE_8D]		[INT]			NOT NULL,
	[K_TIPO_ROOT_CAUSE_8D]				[INT]			NOT NULL,
	-- =================================	
	[VALOR]								VARCHAR(MAX)	NOT NULL
)ON [PRIMARY]	
GO

-- /////////////////////////////////////////////////////
ALTER TABLE [dbo].[8D_ROOT_CAUSE]
	ADD CONSTRAINT [PK_8D_ROOT_CAUSE]
		PRIMARY KEY CLUSTERED ([K_8D_ROOT_CAUSE])
GO

-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[8D_ROOT_CAUSE] 
	ADD		[K_USUARIO_ALTA]				[INT]		NOT NULL,
			[F_ALTA]						[DATETIME]	NOT NULL,
			[K_USUARIO_CAMBIO]				[INT]		NOT NULL,
			[F_CAMBIO]						[DATETIME]	NOT NULL,
			[L_BORRADO]						[INT]		NOT NULL,
			[K_USUARIO_BAJA]				[INT]		NULL,
			[F_BAJA]						[DATETIME]	NULL;
GO



-- //////////////////////////////////////////////////////////////
-- // [8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE]
-- //////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE] (
	[K_8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE]		[INT]			IDENTITY(1,1),
	-- =================================
	[K_8D]									[INT]			NOT NULL,
	-- =================================
	[RUTA]									VARCHAR(255)	NOT NULL,
	[NOMBRE_ARCHIVO]						VARCHAR(255)	NOT NULL,
	[TIPO_ARCHIVO]							VARCHAR(50)		NOT NULL	
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE]
	ADD CONSTRAINT [PK_8D_ROOT_CAUSE_ISHIKAWA_EVIDENCEE]
		PRIMARY KEY CLUSTERED ([K_8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE])
GO

-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[8D_ROOT_CAUSE_ISHIKAWA_EVIDENCE] 
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
