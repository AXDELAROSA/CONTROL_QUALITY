-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			QA INSPECCION DE MATERIAL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	02/SEP/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////






-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INSPECCION_MATERIAL_ORDEN]') AND type in (N'U'))
	DROP TABLE [dbo].[INSPECCION_MATERIAL_ORDEN]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INSPECCION_MATERIAL_ORDEN_RESULTADO]') AND type in (N'U'))
	DROP TABLE [dbo].[INSPECCION_MATERIAL_ORDEN_RESULTADO]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INSPECCION_MATERIAL_ORDEN_ESPERA_DISPOSICION]') AND type in (N'U'))
	DROP TABLE [dbo].[INSPECCION_MATERIAL_ORDEN_ESPERA_DISPOSICION]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ESTATUS_MATERIAL_DISPOSICION]') AND type in (N'U'))
	DROP TABLE [dbo].[ESTATUS_MATERIAL_DISPOSICION]
GO

-- //////////////////////////////////////////////////////////////
-- // ESTATUS_MATERIAL_DISPOSICION
-- //////////////////////////////////////////////////////////////


CREATE TABLE [dbo].[ESTATUS_MATERIAL_DISPOSICION] (
	[K_ESTATUS_MATERIAL_DISPOSICION]	[INT]			NOT NULL,
	[D_ESTATUS_MATERIAL_DISPOSICION]	[VARCHAR] (100) NOT NULL,
	[S_ESTATUS_MATERIAL_DISPOSICION]	[VARCHAR] (10)	NOT NULL,
	[O_ESTATUS_MATERIAL_DISPOSICION]	[INT]			NOT NULL,
	[C_ESTATUS_MATERIAL_DISPOSICION]	[VARCHAR] (255) NOT NULL,
	[L_ESTATUS_MATERIAL_DISPOSICION]	[INT]			NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////


ALTER TABLE [dbo].[ESTATUS_MATERIAL_DISPOSICION]
	ADD CONSTRAINT [PK_ESTATUS_MATERIAL_DISPOSICION]
		PRIMARY KEY CLUSTERED ([K_ESTATUS_MATERIAL_DISPOSICION])
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_ESTATUS_MATERIAL_DISPOSICION_01_DESCRIPCION] 
	   ON [dbo].[ESTATUS_MATERIAL_DISPOSICION] ( [D_ESTATUS_MATERIAL_DISPOSICION] )
GO

-- //////////////////////////////////////////////////////////////


--ALTER TABLE [dbo].[ESTATUS_MATERIAL_DISPOSICION] ADD 
--	CONSTRAINT [FK_ESTATUS_MATERIAL_DISPOSICION_01] 
--		FOREIGN KEY ( [L_ESTATUS_MATERIAL_DISPOSICION] ) 
--		REFERENCES [dbo].[ESTATUS_ACTIVO] ( [K_ESTATUS_ACTIVO] )
--GO


-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_ESTATUS_MATERIAL_DISPOSICION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_ESTATUS_MATERIAL_DISPOSICION]
GO


CREATE PROCEDURE [dbo].[PG_CI_ESTATUS_MATERIAL_DISPOSICION]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	-- ========================================
	@PP_K_ESTATUS_MATERIAL_DISPOSICION	INT,
	@PP_D_ESTATUS_MATERIAL_DISPOSICION	VARCHAR(100),
	@PP_S_ESTATUS_MATERIAL_DISPOSICION	VARCHAR(10),
	@PP_O_ESTATUS_MATERIAL_DISPOSICION	INT,
	@PP_C_ESTATUS_MATERIAL_DISPOSICION	VARCHAR(255),
	@PP_L_ESTATUS_MATERIAL_DISPOSICION	INT
AS
	-- ===============================

	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_ESTATUS_MATERIAL_DISPOSICION
							FROM	ESTATUS_MATERIAL_DISPOSICION
							WHERE	K_ESTATUS_MATERIAL_DISPOSICION=@PP_K_ESTATUS_MATERIAL_DISPOSICION

	-- ===============================

	IF @VP_K_EXISTE IS NULL
		INSERT INTO ESTATUS_MATERIAL_DISPOSICION	
			(	K_ESTATUS_MATERIAL_DISPOSICION,				D_ESTATUS_MATERIAL_DISPOSICION, 
				S_ESTATUS_MATERIAL_DISPOSICION,				O_ESTATUS_MATERIAL_DISPOSICION,
				C_ESTATUS_MATERIAL_DISPOSICION,
				L_ESTATUS_MATERIAL_DISPOSICION				)		
		VALUES	
			(	@PP_K_ESTATUS_MATERIAL_DISPOSICION,			@PP_D_ESTATUS_MATERIAL_DISPOSICION,	
				@PP_S_ESTATUS_MATERIAL_DISPOSICION,			@PP_O_ESTATUS_MATERIAL_DISPOSICION,
				@PP_C_ESTATUS_MATERIAL_DISPOSICION,
				@PP_L_ESTATUS_MATERIAL_DISPOSICION			)
	ELSE
		UPDATE	ESTATUS_MATERIAL_DISPOSICION
		SET		D_ESTATUS_MATERIAL_DISPOSICION	= @PP_D_ESTATUS_MATERIAL_DISPOSICION,	
				S_ESTATUS_MATERIAL_DISPOSICION	= @PP_S_ESTATUS_MATERIAL_DISPOSICION,			
				O_ESTATUS_MATERIAL_DISPOSICION	= @PP_O_ESTATUS_MATERIAL_DISPOSICION,
				C_ESTATUS_MATERIAL_DISPOSICION	= @PP_C_ESTATUS_MATERIAL_DISPOSICION,
				L_ESTATUS_MATERIAL_DISPOSICION	= @PP_L_ESTATUS_MATERIAL_DISPOSICION	
		WHERE	K_ESTATUS_MATERIAL_DISPOSICION=@PP_K_ESTATUS_MATERIAL_DISPOSICION

	-- =========================================================
GO

-- //////////////////////////////////////////////////////////////




-- ===============================================
SET NOCOUNT ON
-- ===============================================


EXECUTE [dbo].[PG_CI_ESTATUS_MATERIAL_DISPOSICION] 0, 0, 0, 'EN ESPERA',		'ESPERA', 1, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_MATERIAL_DISPOSICION] 0, 0, 1, 'EN PROCESO',		'PROCSO', 2, '', 1
EXECUTE [dbo].[PG_CI_ESTATUS_MATERIAL_DISPOSICION] 0, 0, 2, 'TERMINADO',		'TERMNDO', 3, '', 1
GO
-- ===============================================
SET NOCOUNT OFF
-- ===============================================


-- //////////////////////////////////////////////////////////////
-- // INSPECCION_MATERIAL_RESULTADO
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INSPECCION_MATERIAL_ORDEN] (
	[K_INSPECCION_MATERIAL_ORDEN]				[INT]			NOT NULL,
	-- =================================
	[K_ORDEN_COMPRA]							[INT]			NOT NULL,
	[ORDEN_COMPRA_PEDIDO]						VARCHAR(50)		NOT NULL,	
	[K_ITEM]									INT				NOT NULL,	
	[K_INSPECCION_MATERIAL]						[INT]			NOT NULL,
	[OPCION_SELECCIONADA]						VARCHAR(255)	NOT NULL,
	-- =================================	
	[COMENTARIO]								VARCHAR(255)	DEFAULT '',
	[F_INSPECCION_MATERIAL_ORDEN]				DATE			NOT NULL
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[INSPECCION_MATERIAL_ORDEN]
	ADD CONSTRAINT [PK_INSPECCION_MATERIAL_ORDEN]
		PRIMARY KEY CLUSTERED ([K_INSPECCION_MATERIAL_ORDEN])
GO

-- //////////////////////////////////////////////////////////////


--ALTER TABLE [dbo].[INSPECCION_MATERIAL_RESULTADO] ADD 
	--CONSTRAINT [FK_INSPECCION_MATERIAL_RESULTADO_01]  
	--	FOREIGN KEY ([K_PUESTO_DESCRIPCION]) 
	--	REFERENCES [dbo].[PUESTO_DESCRIPCION] ([K_PUESTO_DESCRIPCION]),
	--CONSTRAINT [FK_INSPECCION_MATERIAL_RESULTADO_02]  
	--	FOREIGN KEY ([K_TIPO_INSPECCION_MATERIAL_RESULTADO]) 
	--	REFERENCES [dbo].[TIPO_INSPECCION_MATERIAL_RESULTADO] ([K_TIPO_INSPECCION_MATERIAL_RESULTADO]),
	--CONSTRAINT [FK_INSPECCION_MATERIAL_RESULTADO_03]  
	--	FOREIGN KEY ([K_ESTATUS_INSPECCION_MATERIAL_RESULTADO]) 
	--	REFERENCES [dbo].[ESTATUS_INSPECCION_MATERIAL_RESULTADO] ([K_ESTATUS_INSPECCION_MATERIAL_RESULTADO])
--GO


-- //////////////////////////////////////////////////////


ALTER TABLE [dbo].[INSPECCION_MATERIAL_ORDEN] 
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

CREATE TABLE [dbo].[INSPECCION_MATERIAL_ORDEN_RESULTADO] (
	[K_INSPECCION_MATERIAL_ORDEN_RESULTADO]		[INT]			NOT NULL,
	-- =================================
	[K_ORDEN_COMPRA]							[INT]			NOT NULL,
	[ORDEN_COMPRA_PEDIDO]						VARCHAR(50)		NOT NULL,	
	[K_ITEM]									INT				NOT NULL,
	[PORCENTAJE_APROBATORIO]					DECIMAL(13,2)	NOT NULL,
	[TOTAL_PORCENTAJE_ACUMULADO]				DECIMAL(13,2)	NOT NULL,
	[INSPECCION_TERMINADA]						[INT]			NOT NULL,
	[APROBACION_SISTEMA]						[INT]			DEFAULT 0,
	[APROBACION_MANUAL]							[INT]			DEFAULT 0,
	[COMENTARIO]								VARCHAR(255)	DEFAULT '',
	-- =================================	
	[K_USUARIO_ALTA]							[INT]			NOT NULL,
	[F_INSPECCION_MATERIAL_ORDEN_RESULTADO]		DATE			NOT NULL
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[INSPECCION_MATERIAL_ORDEN_RESULTADO]
	ADD CONSTRAINT [PK_INSPECCION_MATERIAL_ORDEN_RESULTADO]
		PRIMARY KEY CLUSTERED ([K_INSPECCION_MATERIAL_ORDEN_RESULTADO])
GO




-- //////////////////////////////////////////////////////////////
-- // INSPECCION_MATERIAL_RESULTADO
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INSPECCION_MATERIAL_ORDEN_ESPERA_DISPOSICION] (
	[K_INSPECCION_MATERIAL_ORDEN_ESPERA_DISPOSICION]	[INT]			IDENTITY(1,1),
	-- =================================
	[K_ESTATUS_MATERIAL_DISPOSICION]					[INT]			DEFAULT 0,
	[K_ORDEN_COMPRA]									[INT]			NOT NULL,
	[ORDEN_COMPRA_PEDIDO]								VARCHAR(50)		NOT NULL,	
	[ORDEN_COMPRA_PEDIDO_ENTREGA]						INT				NOT NULL,
	[K_ITEM]											INT				NOT NULL,
	[LOCACION_DESTINO]									VARCHAR(5)		NOT NULL,	
	-- =================================	
	[K_USUARIO_ALTA]									[INT]			NOT NULL,
	[F_INSPECCION_MATERIAL_ORDEN_ESPERA_DISPOSICION]	DATETIME		NOT NULL
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[INSPECCION_MATERIAL_ORDEN_ESPERA_DISPOSICION]
	ADD CONSTRAINT [PK_INSPECCION_MATERIAL_ORDEN_ESPERA_DISPOSICION]
		PRIMARY KEY CLUSTERED ([K_INSPECCION_MATERIAL_ORDEN_ESPERA_DISPOSICION])
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
