-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			QC 8D
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	16/AGO/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[8D]') AND type in (N'U'))
	DROP TABLE [dbo].[8D]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ESTATUS_8D]') AND type in (N'U'))
	DROP TABLE [dbo].[ESTATUS_8D]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[EXTERNAL_8D]') AND type in (N'U'))
	DROP TABLE [dbo].[EXTERNAL_8D]
GO

-- //////////////////////////////////////////////////////////////
-- // ESTATUS_8D
-- //////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[ESTATUS_8D] (
	[K_ESTATUS_8D]	[INT]			NOT NULL,
	[D_ESTATUS_8D]	[VARCHAR] (100) NOT NULL,
	[S_ESTATUS_8D]	[VARCHAR] (10)	NOT NULL,
	[O_ESTATUS_8D]	[INT]			NOT NULL,
	[C_ESTATUS_8D]	[VARCHAR] (255) NOT NULL,
	[L_ESTATUS_8D]	[INT]			NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////
ALTER TABLE [dbo].[ESTATUS_8D]
	ADD CONSTRAINT [PK_ESTATUS_8D]
		PRIMARY KEY CLUSTERED ([K_ESTATUS_8D])
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_ESTATUS_8D_01_DESCRIPCION] 
	   ON [dbo].[ESTATUS_8D] ( [D_ESTATUS_8D] )
GO

-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_ESTATUS_8D]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_ESTATUS_8D]
GO


CREATE PROCEDURE [dbo].[PG_CI_ESTATUS_8D]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	-- ========================================
	@PP_K_ESTATUS_8D	INT,
	@PP_D_ESTATUS_8D	VARCHAR(100),
	@PP_S_ESTATUS_8D	VARCHAR(10),
	@PP_O_ESTATUS_8D	INT,
	@PP_C_ESTATUS_8D	VARCHAR(255),
	@PP_L_ESTATUS_8D	INT
AS
	-- ===============================

	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_ESTATUS_8D
							FROM	ESTATUS_8D
							WHERE	K_ESTATUS_8D=@PP_K_ESTATUS_8D

	-- ===============================
	IF @VP_K_EXISTE IS NULL
		INSERT INTO ESTATUS_8D	
			(	K_ESTATUS_8D,				D_ESTATUS_8D, 
				S_ESTATUS_8D,				O_ESTATUS_8D,
				C_ESTATUS_8D,
				L_ESTATUS_8D				)		
		VALUES	
			(	@PP_K_ESTATUS_8D,			@PP_D_ESTATUS_8D,	
				@PP_S_ESTATUS_8D,			@PP_O_ESTATUS_8D,
				@PP_C_ESTATUS_8D,
				@PP_L_ESTATUS_8D			)
	ELSE
		UPDATE	ESTATUS_8D
		SET		D_ESTATUS_8D	= @PP_D_ESTATUS_8D,	
				S_ESTATUS_8D	= @PP_S_ESTATUS_8D,			
				O_ESTATUS_8D	= @PP_O_ESTATUS_8D,
				C_ESTATUS_8D	= @PP_C_ESTATUS_8D,
				L_ESTATUS_8D	= @PP_L_ESTATUS_8D	
		WHERE	K_ESTATUS_8D=@PP_K_ESTATUS_8D
GO
-- //////////////////////////////////////////////////////////////


-- ===============================================
SET NOCOUNT ON
-- ===============================================


EXECUTE [dbo].[PG_CI_ESTATUS_8D] 0, 0, 0, 'INACTIVA',		'INACTVA', 1, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_8D] 0, 0, 1, 'ACTIVA',			'ACTVA', 2, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_8D] 0, 0, 2, 'SUSPENDIDA',		'SUSPNDA', 3, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_8D] 0, 0, 3, 'CANCELADA',		'CANCELADA', 4, '', 1
GO-- ===============================================
SET NOCOUNT OFF
-- ===============================================


-- //////////////////////////////////////////////////////////////
-- // 8D
-- //////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[8D] (
	[K_8D]				[INT]			NOT NULL,
	-- =================================
	[K_8D_CUSTOMER]		VARCHAR(150)	DEFAULT '',
	[K_RMA]				[INT]			DEFAULT 0,
	[K_ESTATUS_8D]		[INT]			DEFAULT 1,
	-- =================================	
	[EXTERNAL_FORMAT]	[INT]			DEFAULT 0,
	-- =================================	
	[TITLE]				VARCHAR(MAX)	NOT NULL, 
	[PRODUCT_PROCESS]	VARCHAR(MAX)	NOT NULL, 
	[DATE_OPENED]		DATE			NOT NULL,	-- FECHA DE CREACION
	[LAST_UPDATE]		DATE			NOT NULL,	-- ULTIMA ACTUALIZACION
	[DUE_DATE]			DATE			NOT NULL,	-- FECHA LIMITE DE CIERRE ESTIMADO
	[DATE_CLOSED]		DATE			NULL		-- FECHA DE CIEERE
)ON [PRIMARY]	
GO

-- /////////////////////////////////////////////////////
ALTER TABLE [dbo].[8D]
	ADD CONSTRAINT [PK_8D]
		PRIMARY KEY CLUSTERED ([K_8D])
GO

-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[8D] 
	ADD		[K_USUARIO_ALTA]				[INT]		NOT NULL,
			[F_ALTA]						[DATETIME]	NOT NULL,
			[K_USUARIO_CAMBIO]				[INT]		NOT NULL,
			[F_CAMBIO]						[DATETIME]	NOT NULL,
			[L_BORRADO]						[INT]		NOT NULL,
			[K_USUARIO_BAJA]				[INT]		NULL,
			[F_BAJA]						[DATETIME]	NULL;
GO



-- //////////////////////////////////////////////////////////////
-- // [EXTERNAL_8D]
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[EXTERNAL_8D] (
	[K_EXTERNAL_8D]		[INT]			IDENTITY(1,1),
	-- =================================
	[K_8D]				[INT]			NOT NULL,
	-- =================================		
	[RUTA]				VARCHAR(255)	NOT NULL,
	-- =================================
	[NOMBRE_ARCHIVO]	VARCHAR(255)	NOT NULL
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[EXTERNAL_8D]
	ADD CONSTRAINT [PK_EXTERNAL_8D]
		PRIMARY KEY CLUSTERED ([K_EXTERNAL_8D])
GO

-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[EXTERNAL_8D] 
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
