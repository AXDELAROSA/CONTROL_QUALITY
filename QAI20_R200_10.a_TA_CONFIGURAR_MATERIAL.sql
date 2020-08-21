-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			QA INSPECCION DE MATERIAL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	21/AGO/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////






-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CONFIGURAR_MATERIAL]') AND type in (N'U'))
	DROP TABLE [dbo].[CONFIGURAR_MATERIAL]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ESTATUS_CONFIGURAR_MATERIAL]') AND type in (N'U'))
	DROP TABLE [dbo].[ESTATUS_CONFIGURAR_MATERIAL]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TIPO_CONFIGURAR_MATERIAL]') AND type in (N'U'))
	DROP TABLE [dbo].[TIPO_CONFIGURAR_MATERIAL]
GO



-- //////////////////////////////////////////////////////////////
-- // TIPO_CONFIGURAR_MATERIAL
-- //////////////////////////////////////////////////////////////


CREATE TABLE [dbo].[TIPO_CONFIGURAR_MATERIAL] (
	[K_TIPO_CONFIGURAR_MATERIAL]	[INT]			NOT NULL,
	[D_TIPO_CONFIGURAR_MATERIAL]	[VARCHAR] (100) NOT NULL,
	[S_TIPO_CONFIGURAR_MATERIAL]	[VARCHAR] (10)	NOT NULL,
	[O_TIPO_CONFIGURAR_MATERIAL]	[INT]			NOT NULL,
	[C_TIPO_CONFIGURAR_MATERIAL]	[VARCHAR] (255) NOT NULL,
	[L_TIPO_CONFIGURAR_MATERIAL]	[INT]			NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[TIPO_CONFIGURAR_MATERIAL]
	ADD CONSTRAINT [PK_TIPO_CONFIGURAR_MATERIAL]
		PRIMARY KEY CLUSTERED ([K_TIPO_CONFIGURAR_MATERIAL])
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_TIPO_CONFIGURAR_MATERIAL_01_DESCRIPCION] 
	   ON [dbo].[TIPO_CONFIGURAR_MATERIAL] ( [D_TIPO_CONFIGURAR_MATERIAL] )
GO

-- //////////////////////////////////////////////////////////////


--ALTER TABLE [dbo].[TIPO_CONFIGURAR_MATERIAL] ADD 
--	CONSTRAINT [FK_TIPO_CONFIGURAR_MATERIAL_01] 
--		FOREIGN KEY ( [L_TIPO_CONFIGURAR_MATERIAL] ) 
--		REFERENCES [dbo].[ESTATUS_ACTIVO] ( [K_ESTATUS_ACTIVO] )
--GO


-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_TIPO_CONFIGURAR_MATERIAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_TIPO_CONFIGURAR_MATERIAL]
GO


CREATE PROCEDURE [dbo].[PG_CI_TIPO_CONFIGURAR_MATERIAL]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	-- ========================================
	@PP_K_TIPO_CONFIGURAR_MATERIAL	INT,
	@PP_D_TIPO_CONFIGURAR_MATERIAL	VARCHAR(100),
	@PP_S_TIPO_CONFIGURAR_MATERIAL	VARCHAR(10),
	@PP_O_TIPO_CONFIGURAR_MATERIAL	INT,
	@PP_C_TIPO_CONFIGURAR_MATERIAL	VARCHAR(255),
	@PP_L_TIPO_CONFIGURAR_MATERIAL	INT
AS
	-- ===============================

	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_TIPO_CONFIGURAR_MATERIAL
							FROM	TIPO_CONFIGURAR_MATERIAL
							WHERE	K_TIPO_CONFIGURAR_MATERIAL=@PP_K_TIPO_CONFIGURAR_MATERIAL

	-- ===============================

	IF @VP_K_EXISTE IS NULL
		INSERT INTO TIPO_CONFIGURAR_MATERIAL	
			(	K_TIPO_CONFIGURAR_MATERIAL,				D_TIPO_CONFIGURAR_MATERIAL, 
				S_TIPO_CONFIGURAR_MATERIAL,				O_TIPO_CONFIGURAR_MATERIAL,
				C_TIPO_CONFIGURAR_MATERIAL,
				L_TIPO_CONFIGURAR_MATERIAL				)		
		VALUES	
			(	@PP_K_TIPO_CONFIGURAR_MATERIAL,			@PP_D_TIPO_CONFIGURAR_MATERIAL,	
				@PP_S_TIPO_CONFIGURAR_MATERIAL,			@PP_O_TIPO_CONFIGURAR_MATERIAL,
				@PP_C_TIPO_CONFIGURAR_MATERIAL,
				@PP_L_TIPO_CONFIGURAR_MATERIAL			)
	ELSE
		UPDATE	TIPO_CONFIGURAR_MATERIAL
		SET		D_TIPO_CONFIGURAR_MATERIAL	= @PP_D_TIPO_CONFIGURAR_MATERIAL,	
				S_TIPO_CONFIGURAR_MATERIAL	= @PP_S_TIPO_CONFIGURAR_MATERIAL,			
				O_TIPO_CONFIGURAR_MATERIAL	= @PP_O_TIPO_CONFIGURAR_MATERIAL,
				C_TIPO_CONFIGURAR_MATERIAL	= @PP_C_TIPO_CONFIGURAR_MATERIAL,
				L_TIPO_CONFIGURAR_MATERIAL	= @PP_L_TIPO_CONFIGURAR_MATERIAL	
		WHERE	K_TIPO_CONFIGURAR_MATERIAL=@PP_K_TIPO_CONFIGURAR_MATERIAL

	-- =========================================================
GO

-- //////////////////////////////////////////////////////////////




-- ===============================================
SET NOCOUNT ON
-- ===============================================

EXECUTE [dbo].[PG_CI_TIPO_CONFIGURAR_MATERIAL] 0, 0, 1, 'OPCION MULTIPLE',							'OPC_MULT',	1, '', 1
EXECUTE [dbo].[PG_CI_TIPO_CONFIGURAR_MATERIAL] 0, 0, 2, 'CALCULO/OPERACION ',						'CAL_OPE',	2, '', 1
GO
-- ===============================================
SET NOCOUNT OFF
-- ===============================================



-- //////////////////////////////////////////////////////////////
-- // ESTATUS_CONFIGURAR_MATERIAL
-- //////////////////////////////////////////////////////////////


CREATE TABLE [dbo].[ESTATUS_CONFIGURAR_MATERIAL] (
	[K_ESTATUS_CONFIGURAR_MATERIAL]	[INT]			NOT NULL,
	[D_ESTATUS_CONFIGURAR_MATERIAL]	[VARCHAR] (100) NOT NULL,
	[S_ESTATUS_CONFIGURAR_MATERIAL]	[VARCHAR] (10)	NOT NULL,
	[O_ESTATUS_CONFIGURAR_MATERIAL]	[INT]			NOT NULL,
	[C_ESTATUS_CONFIGURAR_MATERIAL]	[VARCHAR] (255) NOT NULL,
	[L_ESTATUS_CONFIGURAR_MATERIAL]	[INT]			NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[ESTATUS_CONFIGURAR_MATERIAL]
	ADD CONSTRAINT [PK_ESTATUS_CONFIGURAR_MATERIAL]
		PRIMARY KEY CLUSTERED ([K_ESTATUS_CONFIGURAR_MATERIAL])
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_ESTATUS_CONFIGURAR_MATERIAL_01_DESCRIPCION] 
	   ON [dbo].[ESTATUS_CONFIGURAR_MATERIAL] ( [D_ESTATUS_CONFIGURAR_MATERIAL] )
GO

-- //////////////////////////////////////////////////////////////


--ALTER TABLE [dbo].[ESTATUS_CONFIGURAR_MATERIAL] ADD 
--	CONSTRAINT [FK_ESTATUS_CONFIGURAR_MATERIAL_01] 
--		FOREIGN KEY ( [L_ESTATUS_CONFIGURAR_MATERIAL] ) 
--		REFERENCES [dbo].[ESTATUS_ACTIVO] ( [K_ESTATUS_ACTIVO] )
--GO


-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_ESTATUS_CONFIGURAR_MATERIAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_ESTATUS_CONFIGURAR_MATERIAL]
GO


CREATE PROCEDURE [dbo].[PG_CI_ESTATUS_CONFIGURAR_MATERIAL]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	-- ========================================
	@PP_K_ESTATUS_CONFIGURAR_MATERIAL	INT,
	@PP_D_ESTATUS_CONFIGURAR_MATERIAL	VARCHAR(100),
	@PP_S_ESTATUS_CONFIGURAR_MATERIAL	VARCHAR(10),
	@PP_O_ESTATUS_CONFIGURAR_MATERIAL	INT,
	@PP_C_ESTATUS_CONFIGURAR_MATERIAL	VARCHAR(255),
	@PP_L_ESTATUS_CONFIGURAR_MATERIAL	INT
AS
	-- ===============================

	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_ESTATUS_CONFIGURAR_MATERIAL
							FROM	ESTATUS_CONFIGURAR_MATERIAL
							WHERE	K_ESTATUS_CONFIGURAR_MATERIAL=@PP_K_ESTATUS_CONFIGURAR_MATERIAL

	-- ===============================

	IF @VP_K_EXISTE IS NULL
		INSERT INTO ESTATUS_CONFIGURAR_MATERIAL	
			(	K_ESTATUS_CONFIGURAR_MATERIAL,				D_ESTATUS_CONFIGURAR_MATERIAL, 
				S_ESTATUS_CONFIGURAR_MATERIAL,				O_ESTATUS_CONFIGURAR_MATERIAL,
				C_ESTATUS_CONFIGURAR_MATERIAL,
				L_ESTATUS_CONFIGURAR_MATERIAL				)		
		VALUES	
			(	@PP_K_ESTATUS_CONFIGURAR_MATERIAL,			@PP_D_ESTATUS_CONFIGURAR_MATERIAL,	
				@PP_S_ESTATUS_CONFIGURAR_MATERIAL,			@PP_O_ESTATUS_CONFIGURAR_MATERIAL,
				@PP_C_ESTATUS_CONFIGURAR_MATERIAL,
				@PP_L_ESTATUS_CONFIGURAR_MATERIAL			)
	ELSE
		UPDATE	ESTATUS_CONFIGURAR_MATERIAL
		SET		D_ESTATUS_CONFIGURAR_MATERIAL	= @PP_D_ESTATUS_CONFIGURAR_MATERIAL,	
				S_ESTATUS_CONFIGURAR_MATERIAL	= @PP_S_ESTATUS_CONFIGURAR_MATERIAL,			
				O_ESTATUS_CONFIGURAR_MATERIAL	= @PP_O_ESTATUS_CONFIGURAR_MATERIAL,
				C_ESTATUS_CONFIGURAR_MATERIAL	= @PP_C_ESTATUS_CONFIGURAR_MATERIAL,
				L_ESTATUS_CONFIGURAR_MATERIAL	= @PP_L_ESTATUS_CONFIGURAR_MATERIAL	
		WHERE	K_ESTATUS_CONFIGURAR_MATERIAL=@PP_K_ESTATUS_CONFIGURAR_MATERIAL

	-- =========================================================
GO

-- //////////////////////////////////////////////////////////////




-- ===============================================
SET NOCOUNT ON
-- ===============================================


EXECUTE [dbo].[PG_CI_ESTATUS_CONFIGURAR_MATERIAL] 0, 0, 0, 'INACTIVA',		'INACTVA', 1, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_CONFIGURAR_MATERIAL] 0, 0, 1, 'ACTIVA',		'ACTVA', 2, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_CONFIGURAR_MATERIAL] 0, 0, 2, 'SUSPENDIDA',	'SUSPNDA', 3, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_CONFIGURAR_MATERIAL] 0, 0, 3, 'CANCELADA',		'CANCELADA', 4, '', 1
GO
-- ===============================================
SET NOCOUNT OFF
-- ===============================================




-- //////////////////////////////////////////////////////////////
-- // CONFIGURAR_MATERIAL
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[CONFIGURAR_MATERIAL] (
	[K_CONFIGURAR_MATERIAL]				[INT]			NOT NULL,
	-- =================================
	[K_TIPO_CONFIGURAR_MATERIAL]		[INT]			NOT NULL,
	[K_ESTATUS_CONFIGURAR_MATERIAL]		[INT]			NOT NULL,
	-- =================================	
	[NUMERO_PARTE]						VARCHAR(150)	NOT NULL,	
	[INSPECCION]						VARCHAR(255)	NOT NULL,
	[F_CONFIGURAR_MATERIAL]				DATE			NOT NULL
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[CONFIGURAR_MATERIAL]
	ADD CONSTRAINT [PK_CONFIGURAR_MATERIAL]
		PRIMARY KEY CLUSTERED ([K_CONFIGURAR_MATERIAL])
GO

-- //////////////////////////////////////////////////////////////


--ALTER TABLE [dbo].[CONFIGURAR_MATERIAL] ADD 
	--CONSTRAINT [FK_CONFIGURAR_MATERIAL_01]  
	--	FOREIGN KEY ([K_PUESTO_DESCRIPCION]) 
	--	REFERENCES [dbo].[PUESTO_DESCRIPCION] ([K_PUESTO_DESCRIPCION]),
	--CONSTRAINT [FK_CONFIGURAR_MATERIAL_02]  
	--	FOREIGN KEY ([K_TIPO_CONFIGURAR_MATERIAL]) 
	--	REFERENCES [dbo].[TIPO_CONFIGURAR_MATERIAL] ([K_TIPO_CONFIGURAR_MATERIAL]),
	--CONSTRAINT [FK_CONFIGURAR_MATERIAL_03]  
	--	FOREIGN KEY ([K_ESTATUS_CONFIGURAR_MATERIAL]) 
	--	REFERENCES [dbo].[ESTATUS_CONFIGURAR_MATERIAL] ([K_ESTATUS_CONFIGURAR_MATERIAL])
--GO


-- //////////////////////////////////////////////////////


ALTER TABLE [dbo].[CONFIGURAR_MATERIAL] 
	ADD		[K_USUARIO_ALTA]				[INT]		NOT NULL,
			[F_ALTA]						[DATETIME]	NOT NULL,
			[K_USUARIO_CAMBIO]				[INT]		NOT NULL,
			[F_CAMBIO]						[DATETIME]	NOT NULL,
			[L_BORRADO]						[INT]		NOT NULL,
			[K_USUARIO_BAJA]				[INT]		NULL,
			[F_BAJA]						[DATETIME]	NULL;
GO


--ALTER TABLE [dbo].[CONFIGURAR_MATERIAL] ADD 
--	CONSTRAINT [FK_CONFIGURAR_MATERIAL_USUARIO_ALTA]  
--		FOREIGN KEY ([K_USUARIO_ALTA]) 
--		REFERENCES [dbo].[USUARIO] ([K_USUARIO]),
--	CONSTRAINT [FK_CONFIGURAR_MATERIAL_USUARIO_CAMBIO]  
--		FOREIGN KEY ([K_USUARIO_CAMBIO]) 
--		REFERENCES [dbo].[USUARIO] ([K_USUARIO]),
--	CONSTRAINT [FK_CONFIGURAR_MATERIAL_USUARIO_BAJA]  
--		FOREIGN KEY ([K_USUARIO_BAJA]) 
--		REFERENCES [dbo].[USUARIO] ([K_USUARIO])
--GO



-- //////////////////////////////////////////////////////////////
-- // CONFIGURAR_MATERIAL_OPCION
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INSPECCION_OPCION_MULTIPLE] (
	[K_INSPECCION_OPCION_MULTIPLE]		[INT]			NOT NULL,
	-- =================================
	[K_CONFIGURAR_MATERIAL]				[INT]			NOT NULL,
	-- =================================		
	[OPCION_1]							VARCHAR(100)	DEFAULT '',
	[OPCION_2]							VARCHAR(100)	DEFAULT '',
	[OPCION_3]							VARCHAR(100)	DEFAULT '',
	[OPCION_4]							VARCHAR(100)	DEFAULT '',
	[OPCION_5]							VARCHAR(100)	DEFAULT ''
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[INSPECCION_OPCION_MULTIPLE]
	ADD CONSTRAINT [PK_INSPECCION_OPCION_MULTIPLE]
		PRIMARY KEY CLUSTERED ([K_INSPECCION_OPCION_MULTIPLE])
GO




-- //////////////////////////////////////////////////////////////
-- // CONFIGURAR_MATERIAL_CALCULO_OPERACION
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INSPECCION_OPCION_CALCULO] (
	[K_INSPECCION_OPCION_CALCULO]		[INT]			NOT NULL,
	-- =================================
	[K_CONFIGURAR_MATERIAL]				[INT]			NOT NULL,
	-- =================================		
	[OPCION_1]							VARCHAR(100)	DEFAULT '',
	[OPCION_2]							VARCHAR(100)	DEFAULT '',
	[OPCION_3]							VARCHAR(100)	DEFAULT '',
	[OPCION_4]							VARCHAR(100)	DEFAULT '',
	[OPCION_5]							VARCHAR(100)	DEFAULT ''
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[INSPECCION_OPCION_CALCULO]
	ADD CONSTRAINT [PK_INSPECCION_OPCION_CALCULO]
		PRIMARY KEY CLUSTERED ([K_INSPECCION_OPCION_CALCULO])
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
