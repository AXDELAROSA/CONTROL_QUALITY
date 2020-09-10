-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			QA INSPECCION DE MATERIAL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	10/SEP/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////

--SELECT * FROM IMLOCFIL_SQL
--EXEC BD_GENERAL.DBO.PG_CB_IMLOCFIL_SQL 0,0,1

-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INSPECCION_MATERIAL_LOG]') AND type in (N'U'))
	DROP TABLE [dbo].[INSPECCION_MATERIAL_LOG]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TIPO_INSPECCION_MATERIAL_LOG]') AND type in (N'U'))
	DROP TABLE [dbo].[TIPO_INSPECCION_MATERIAL_LOG]
GO



-- //////////////////////////////////////////////////////////////
-- // TIPO_INSPECCION_MATERIAL_LOG
-- //////////////////////////////////////////////////////////////


CREATE TABLE [dbo].[TIPO_INSPECCION_MATERIAL_LOG] (
	[K_TIPO_INSPECCION_MATERIAL_LOG]	[INT]			NOT NULL,
	[D_TIPO_INSPECCION_MATERIAL_LOG]	[VARCHAR] (100) NOT NULL,
	[S_TIPO_INSPECCION_MATERIAL_LOG]	[VARCHAR] (10)	NOT NULL,
	[O_TIPO_INSPECCION_MATERIAL_LOG]	[INT]			NOT NULL,
	[C_TIPO_INSPECCION_MATERIAL_LOG]	[VARCHAR] (255) NOT NULL,
	[L_TIPO_INSPECCION_MATERIAL_LOG]	[INT]			NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[TIPO_INSPECCION_MATERIAL_LOG]
	ADD CONSTRAINT [PK_TIPO_INSPECCION_MATERIAL_LOG]
		PRIMARY KEY CLUSTERED ([K_TIPO_INSPECCION_MATERIAL_LOG])
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_TIPO_INSPECCION_MATERIAL_LOG_01_DESCRIPCION] 
	   ON [dbo].[TIPO_INSPECCION_MATERIAL_LOG] ( [D_TIPO_INSPECCION_MATERIAL_LOG] )
GO

-- //////////////////////////////////////////////////////////////


--ALTER TABLE [dbo].[TIPO_INSPECCION_MATERIAL_LOG] ADD 
--	CONSTRAINT [FK_TIPO_INSPECCION_MATERIAL_LOG_01] 
--		FOREIGN KEY ( [L_TIPO_INSPECCION_MATERIAL_LOG] ) 
--		REFERENCES [dbo].[ESTATUS_ACTIVO] ( [K_ESTATUS_ACTIVO] )
--GO


-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_TIPO_INSPECCION_MATERIAL_LOG]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_TIPO_INSPECCION_MATERIAL_LOG]
GO


CREATE PROCEDURE [dbo].[PG_CI_TIPO_INSPECCION_MATERIAL_LOG]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	-- ========================================
	@PP_K_TIPO_INSPECCION_MATERIAL_LOG	INT,
	@PP_D_TIPO_INSPECCION_MATERIAL_LOG	VARCHAR(100),
	@PP_S_TIPO_INSPECCION_MATERIAL_LOG	VARCHAR(10),
	@PP_O_TIPO_INSPECCION_MATERIAL_LOG	INT,
	@PP_C_TIPO_INSPECCION_MATERIAL_LOG	VARCHAR(255),
	@PP_L_TIPO_INSPECCION_MATERIAL_LOG	INT
AS
	-- ===============================

	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_TIPO_INSPECCION_MATERIAL_LOG
							FROM	TIPO_INSPECCION_MATERIAL_LOG
							WHERE	K_TIPO_INSPECCION_MATERIAL_LOG=@PP_K_TIPO_INSPECCION_MATERIAL_LOG

	-- ===============================

	IF @VP_K_EXISTE IS NULL
		INSERT INTO TIPO_INSPECCION_MATERIAL_LOG	
			(	K_TIPO_INSPECCION_MATERIAL_LOG,				D_TIPO_INSPECCION_MATERIAL_LOG, 
				S_TIPO_INSPECCION_MATERIAL_LOG,				O_TIPO_INSPECCION_MATERIAL_LOG,
				C_TIPO_INSPECCION_MATERIAL_LOG,
				L_TIPO_INSPECCION_MATERIAL_LOG				)		
		VALUES	
			(	@PP_K_TIPO_INSPECCION_MATERIAL_LOG,			@PP_D_TIPO_INSPECCION_MATERIAL_LOG,	
				@PP_S_TIPO_INSPECCION_MATERIAL_LOG,			@PP_O_TIPO_INSPECCION_MATERIAL_LOG,
				@PP_C_TIPO_INSPECCION_MATERIAL_LOG,
				@PP_L_TIPO_INSPECCION_MATERIAL_LOG			)
	ELSE
		UPDATE	TIPO_INSPECCION_MATERIAL_LOG
		SET		D_TIPO_INSPECCION_MATERIAL_LOG	= @PP_D_TIPO_INSPECCION_MATERIAL_LOG,	
				S_TIPO_INSPECCION_MATERIAL_LOG	= @PP_S_TIPO_INSPECCION_MATERIAL_LOG,			
				O_TIPO_INSPECCION_MATERIAL_LOG	= @PP_O_TIPO_INSPECCION_MATERIAL_LOG,
				C_TIPO_INSPECCION_MATERIAL_LOG	= @PP_C_TIPO_INSPECCION_MATERIAL_LOG,
				L_TIPO_INSPECCION_MATERIAL_LOG	= @PP_L_TIPO_INSPECCION_MATERIAL_LOG	
		WHERE	K_TIPO_INSPECCION_MATERIAL_LOG=@PP_K_TIPO_INSPECCION_MATERIAL_LOG

	-- =========================================================
GO

-- //////////////////////////////////////////////////////////////




-- ===============================================
SET NOCOUNT ON
-- ===============================================

EXECUTE [dbo].[PG_CI_TIPO_INSPECCION_MATERIAL_LOG] 0, 0, 1, 'APROBAR INSPECCION',				'APROB_INSP', 1, '', 1
EXECUTE [dbo].[PG_CI_TIPO_INSPECCION_MATERIAL_LOG] 0, 0, 2, 'RECHAZAR INSPECCION',				'RECHA_INSP', 2, '', 1
EXECUTE [dbo].[PG_CI_TIPO_INSPECCION_MATERIAL_LOG] 0, 0, 3, 'MODIFICAR INSPECCION',				'MODIF_INSP', 3, '', 1
GO
-- ===============================================
SET NOCOUNT OFF
-- ===============================================



-- //////////////////////////////////////////////////////////////
-- // INSPECCION_MATERIAL_LOG
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INSPECCION_MATERIAL_LOG] (
	[K_INSPECCION_MATERIAL_LOG]					[INT] IDENTITY (1,1) NOT NULL,
	-- =================================
	[K_TIPO_INSPECCION_MATERIAL_LOG]			[INT]	NOT NULL,
	[K_ORDEN]									[INT]	NOT NULL,
	[K_ITEM]									[INT]	NOT NULL,
	[K_INSPECCION_MATERIAL_ORDEN]				[INT]	DEFAULT 0,
	-- =================================		
	[VALOR_ANTERIOR]							VARCHAR(20)		DEFAULT '',	
	[VALOR_NUEVO]								VARCHAR(20)		DEFAULT '',	
	[APROBACION_SISTEMA_ANTERIOR]				INT				NOT NULL,
	[APROBACION_SISTEMA_NUEVO]					INT				NOT NULL,
	[APROBACION_MANUAL_ANTERIOR]				INT				NOT NULL,
	[APROBACION_MANUAL_NUEVO]					INT				NOT NULL,	
	[COMENTARIO]								VARCHAR(255)	NOT NULL,	
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[INSPECCION_MATERIAL_LOG]
	ADD CONSTRAINT [PK_INSPECCION_MATERIAL_LOG]
		PRIMARY KEY CLUSTERED ([K_INSPECCION_MATERIAL_LOG])
GO

-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[INSPECCION_MATERIAL_LOG] ADD 
	CONSTRAINT [FK_INSPECCION_MATERIAL_LOG_01]  
		FOREIGN KEY ([K_TIPO_INSPECCION_MATERIAL_LOG]) 
		REFERENCES [dbo].[TIPO_INSPECCION_MATERIAL_LOG] ([K_TIPO_INSPECCION_MATERIAL_LOG])
	--CONSTRAINT [FK_INSPECCION_MATERIAL_LOG_02]  
	--	FOREIGN KEY ([K_TIPO_INSPECCION_MATERIAL_LOG]) 
	--	REFERENCES [dbo].[TIPO_INSPECCION_MATERIAL_LOG] ([K_TIPO_INSPECCION_MATERIAL_LOG]),
	--CONSTRAINT [FK_INSPECCION_MATERIAL_LOG_03]  
	--	FOREIGN KEY ([K_ESTATUS_INSPECCION_MATERIAL_LOG]) 
	--	REFERENCES [dbo].[ESTATUS_INSPECCION_MATERIAL_LOG] ([K_ESTATUS_INSPECCION_MATERIAL_LOG])
GO


-- //////////////////////////////////////////////////////


ALTER TABLE [dbo].[INSPECCION_MATERIAL_LOG] 
	ADD		[K_USUARIO_ALTA]				[INT]		NOT NULL,
			[F_ALTA]						[DATETIME]	NOT NULL,
			[K_USUARIO_CAMBIO]				[INT]		NOT NULL,
			[F_CAMBIO]						[DATETIME]	NOT NULL,
			[L_BORRADO]						[INT]		NOT NULL,
			[K_USUARIO_BAJA]				[INT]		NULL,
			[F_BAJA]						[DATETIME]	NULL;
GO


--ALTER TABLE [dbo].[INSPECCION_MATERIAL_LOG] ADD 
--	CONSTRAINT [FK_INSPECCION_MATERIAL_LOG_USUARIO_ALTA]  
--		FOREIGN KEY ([K_USUARIO_ALTA]) 
--		REFERENCES [dbo].[USUARIO] ([K_USUARIO]),
--	CONSTRAINT [FK_INSPECCION_MATERIAL_LOG_USUARIO_CAMBIO]  
--		FOREIGN KEY ([K_USUARIO_CAMBIO]) 
--		REFERENCES [dbo].[USUARIO] ([K_USUARIO]),
--	CONSTRAINT [FK_INSPECCION_MATERIAL_LOG_USUARIO_BAJA]  
--		FOREIGN KEY ([K_USUARIO_BAJA]) 
--		REFERENCES [dbo].[USUARIO] ([K_USUARIO])
--GO





-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
