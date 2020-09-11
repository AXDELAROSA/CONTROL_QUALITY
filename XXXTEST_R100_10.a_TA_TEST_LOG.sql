-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			
-- // OPERACION:		PIEL_LOG 
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	17/FEB/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////

--SELECT * FROM IMLOCFIL_SQL
--EXEC BD_GENERAL.DBO.PG_CB_IMLOCFIL_SQL 0,0,1

-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PIEL_LOG]') AND type in (N'U'))
	DROP TABLE [dbo].[PIEL_LOG]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TIPO_PIEL_LOG]') AND type in (N'U'))
	DROP TABLE [dbo].[TIPO_PIEL_LOG]
GO



-- //////////////////////////////////////////////////////////////
-- // TIPO_PIEL_LOG
-- //////////////////////////////////////////////////////////////


CREATE TABLE [dbo].[TIPO_PIEL_LOG] (
	[K_TIPO_PIEL_LOG]	[INT]			NOT NULL,
	[D_TIPO_PIEL_LOG]	[VARCHAR] (100) NOT NULL,
	[S_TIPO_PIEL_LOG]	[VARCHAR] (10)	NOT NULL,
	[O_TIPO_PIEL_LOG]	[INT]			NOT NULL,
	[C_TIPO_PIEL_LOG]	[VARCHAR] (255) NOT NULL,
	[L_TIPO_PIEL_LOG]	[INT]			NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[TIPO_PIEL_LOG]
	ADD CONSTRAINT [PK_TIPO_PIEL_LOG]
		PRIMARY KEY CLUSTERED ([K_TIPO_PIEL_LOG])
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_TIPO_PIEL_LOG_01_DESCRIPCION] 
	   ON [dbo].[TIPO_PIEL_LOG] ( [D_TIPO_PIEL_LOG] )
GO

-- //////////////////////////////////////////////////////////////


--ALTER TABLE [dbo].[TIPO_PIEL_LOG] ADD 
--	CONSTRAINT [FK_TIPO_PIEL_LOG_01] 
--		FOREIGN KEY ( [L_TIPO_PIEL_LOG] ) 
--		REFERENCES [dbo].[ESTATUS_ACTIVO] ( [K_ESTATUS_ACTIVO] )
--GO


-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_TIPO_PIEL_LOG]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_TIPO_PIEL_LOG]
GO


CREATE PROCEDURE [dbo].[PG_CI_TIPO_PIEL_LOG]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	-- ========================================
	@PP_K_TIPO_PIEL_LOG	INT,
	@PP_D_TIPO_PIEL_LOG	VARCHAR(100),
	@PP_S_TIPO_PIEL_LOG	VARCHAR(10),
	@PP_O_TIPO_PIEL_LOG	INT,
	@PP_C_TIPO_PIEL_LOG	VARCHAR(255),
	@PP_L_TIPO_PIEL_LOG	INT
AS
	-- ===============================

	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_TIPO_PIEL_LOG
							FROM	TIPO_PIEL_LOG
							WHERE	K_TIPO_PIEL_LOG=@PP_K_TIPO_PIEL_LOG

	-- ===============================

	IF @VP_K_EXISTE IS NULL
		INSERT INTO TIPO_PIEL_LOG	
			(	K_TIPO_PIEL_LOG,				D_TIPO_PIEL_LOG, 
				S_TIPO_PIEL_LOG,				O_TIPO_PIEL_LOG,
				C_TIPO_PIEL_LOG,
				L_TIPO_PIEL_LOG				)		
		VALUES	
			(	@PP_K_TIPO_PIEL_LOG,			@PP_D_TIPO_PIEL_LOG,	
				@PP_S_TIPO_PIEL_LOG,			@PP_O_TIPO_PIEL_LOG,
				@PP_C_TIPO_PIEL_LOG,
				@PP_L_TIPO_PIEL_LOG			)
	ELSE
		UPDATE	TIPO_PIEL_LOG
		SET		D_TIPO_PIEL_LOG	= @PP_D_TIPO_PIEL_LOG,	
				S_TIPO_PIEL_LOG	= @PP_S_TIPO_PIEL_LOG,			
				O_TIPO_PIEL_LOG	= @PP_O_TIPO_PIEL_LOG,
				C_TIPO_PIEL_LOG	= @PP_C_TIPO_PIEL_LOG,
				L_TIPO_PIEL_LOG	= @PP_L_TIPO_PIEL_LOG	
		WHERE	K_TIPO_PIEL_LOG=@PP_K_TIPO_PIEL_LOG

	-- =========================================================
GO

-- //////////////////////////////////////////////////////////////




-- ===============================================
SET NOCOUNT ON
-- ===============================================

EXECUTE [dbo].[PG_CI_TIPO_PIEL_LOG] 0, 0, 1, 'INGRESO A ALMACEN',				'INGRE_ALMN', 1, '', 1
EXECUTE [dbo].[PG_CI_TIPO_PIEL_LOG] 0, 0, 2, 'TRANSFERENCIA A LOCACION ',		'TRANSF_LOC', 2, '', 1
EXECUTE [dbo].[PG_CI_TIPO_PIEL_LOG] 0, 0, 3, 'FOLIO NUEVO',						'FOLIO_NUEV', 3, '', 1
EXECUTE [dbo].[PG_CI_TIPO_PIEL_LOG] 0, 0, 4, 'TRANSFERENCIA A ORDEN',			'TRANSF_ORD', 4, '', 1
EXECUTE [dbo].[PG_CI_TIPO_PIEL_LOG] 0, 0, 5, 'TRANSFERENCIA A FOLIO',			'TRANSF_FOL', 5, '', 1
EXECUTE [dbo].[PG_CI_TIPO_PIEL_LOG] 0, 0, 6, 'DEVOLUCION',						'DEVOLUCION', 6, '', 1
EXECUTE [dbo].[PG_CI_TIPO_PIEL_LOG] 0, 0, 7, 'ISSUE_OUT',						'ISSUE_OUT', 7, '', 1
EXECUTE [dbo].[PG_CI_TIPO_PIEL_LOG] 0, 0, 8, 'REIMPRESION',						'REIMPRESO', 8, '', 1
EXECUTE [dbo].[PG_CI_TIPO_PIEL_LOG] 0, 0, 9, 'FOLIO SCRAP',						'FOLIO_SCRAP', 9, '', 1
EXECUTE [dbo].[PG_CI_TIPO_PIEL_LOG] 0, 0, 10, 'TRANSFERENCIA PIEL CORTADA',		'PIEL_CORTD', 10, '', 1
GO
-- ===============================================
SET NOCOUNT OFF
-- ===============================================



-- //////////////////////////////////////////////////////////////
-- // PIEL_LOG
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[PIEL_LOG] (
	[K_PIEL_LOG]				[INT] IDENTITY (1,1)			NOT NULL,
	-- =================================
	[K_TIPO_PIEL_LOG]			[INT]			NOT NULL,
	-- =================================	
	[FOLIO_ORIGEN]				INT				NOT NULL,	
	[COLOR]						VARCHAR(20)		NOT NULL,	
	[LOTE]						INT				NOT NULL,	
	[PIEL]						INT				NOT NULL,	
	[LOCACION_ORIGEN]			VARCHAR(5)		NOT NULL,	
	[ORDEN_ORIGEN]				INT				NULL DEFAULT 0,
	[FOLIO_DESTINO]				INT				NOT NULL,
	[LOCACION_DESTINO]			VARCHAR(5)		NOT NULL,	
	[ORDEN_DESTIDO]				INT				NULL DEFAULT 0,
	[SQF]						DECIMAL(13,4)	NOT NULL,
	[F_LOG]						DATETIME		NOT NULL
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[PIEL_LOG]
	ADD CONSTRAINT [PK_PIEL_LOG]
		PRIMARY KEY CLUSTERED ([K_PIEL_LOG])
GO

-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[PIEL_LOG] ADD 
	CONSTRAINT [FK_PIEL_LOG_01]  
		FOREIGN KEY ([K_TIPO_PIEL_LOG]) 
		REFERENCES [dbo].[TIPO_PIEL_LOG] ([K_TIPO_PIEL_LOG])
	--CONSTRAINT [FK_PIEL_LOG_02]  
	--	FOREIGN KEY ([K_TIPO_PIEL_LOG]) 
	--	REFERENCES [dbo].[TIPO_PIEL_LOG] ([K_TIPO_PIEL_LOG]),
	--CONSTRAINT [FK_PIEL_LOG_03]  
	--	FOREIGN KEY ([K_ESTATUS_PIEL_LOG]) 
	--	REFERENCES [dbo].[ESTATUS_PIEL_LOG] ([K_ESTATUS_PIEL_LOG])
GO


-- //////////////////////////////////////////////////////


ALTER TABLE [dbo].[PIEL_LOG] 
	ADD		[K_USUARIO_ALTA]				[INT]		NOT NULL,
			[F_ALTA]						[DATETIME]	NOT NULL,
			[K_USUARIO_CAMBIO]				[INT]		NOT NULL,
			[F_CAMBIO]						[DATETIME]	NOT NULL,
			[L_BORRADO]						[INT]		NOT NULL,
			[K_USUARIO_BAJA]				[INT]		NULL,
			[F_BAJA]						[DATETIME]	NULL;
GO


--ALTER TABLE [dbo].[PIEL_LOG] ADD 
--	CONSTRAINT [FK_PIEL_LOG_USUARIO_ALTA]  
--		FOREIGN KEY ([K_USUARIO_ALTA]) 
--		REFERENCES [dbo].[USUARIO] ([K_USUARIO]),
--	CONSTRAINT [FK_PIEL_LOG_USUARIO_CAMBIO]  
--		FOREIGN KEY ([K_USUARIO_CAMBIO]) 
--		REFERENCES [dbo].[USUARIO] ([K_USUARIO]),
--	CONSTRAINT [FK_PIEL_LOG_USUARIO_BAJA]  
--		FOREIGN KEY ([K_USUARIO_BAJA]) 
--		REFERENCES [dbo].[USUARIO] ([K_USUARIO])
--GO





-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
