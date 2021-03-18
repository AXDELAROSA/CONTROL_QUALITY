-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			QA INSPECCION DE MATERIAL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	02/SEP/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////






-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INSPECCION_MATERIAL_ORDEN_COMPRA]') AND type in (N'U'))
	DROP TABLE [dbo].[INSPECCION_MATERIAL_ORDEN_COMPRA]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[INSPECCION_MATERIAL_ORDEN_COMPRA_RESULTADO]') AND type in (N'U'))
	DROP TABLE [dbo].[INSPECCION_MATERIAL_ORDEN_COMPRA_RESULTADO]
GO


-- //////////////////////////////////////////////////////////////
-- // INSPECCION_MATERIAL_RESULTADO
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INSPECCION_MATERIAL_ORDEN_COMPRA] (
	[K_INSPECCION_MATERIAL_ORDEN_COMPRA]	[INT]			NOT NULL,
	-- =================================
	[K_ORDEN_COMPRA]						[INT]			NOT NULL,
	[K_ORDEN_COMPRA_PEDIDO]					VARCHAR(100)	NOT NULL,
	[K_ENTREGA]								[INT]			NOT NULL,
	[K_ITEM]								INT				NOT NULL,
	[LOTE_PEARL]							INT				NOT NULL,
	[K_INSPECCION_MATERIAL]					[INT]			NOT NULL,
	[OPCION_SELECCIONADA]					VARCHAR(255)	NOT NULL,
	[ACEPTADO]								INT				DEFAULT 1,
	-- =================================	
	[COMENTARIO]							VARCHAR(255)	DEFAULT '',
	[F_ORDEN_COMPRA_INSPECCION_MATERIAL]	DATE			NOT NULL
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[INSPECCION_MATERIAL_ORDEN_COMPRA]
	ADD CONSTRAINT [PK_INSPECCION_MATERIAL_ORDEN_COMPRA]
		PRIMARY KEY CLUSTERED ([K_INSPECCION_MATERIAL_ORDEN_COMPRA])
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


ALTER TABLE [dbo].[INSPECCION_MATERIAL_ORDEN_COMPRA] 
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

CREATE TABLE [dbo].[INSPECCION_MATERIAL_ORDEN_COMPRA_RESULTADO] (
	[K_INSPECCION_MATERIAL_ORDEN_COMPRA_RESULTADO]		[INT]			NOT NULL,
	-- =================================
	[K_ORDEN_COMPRA]									[INT]			NOT NULL,
	[K_ORDEN_COMPRA_PEDIDO]								VARCHAR(50)		NOT NULL,	
	[K_ENTREGA]											INT				NOT NULL,
	[K_ITEM]											INT				NOT NULL,
	[LOTE_PEARL]										INT				NOT NULL,
	[ACEPTADO]											INT				NOT NULL,
	-- =================================	
	[K_USUARIO_ALTA]									[INT]			NOT NULL,
	[F_INSPECCION_MATERIAL_ORDEN_COMPRA_RESULTADO]		DATE			NOT NULL
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[INSPECCION_MATERIAL_ORDEN_COMPRA_RESULTADO]
	ADD CONSTRAINT [PK_INSPECCION_MATERIAL_ORDEN_COMPRA_RESULTADO]
		PRIMARY KEY CLUSTERED ([K_INSPECCION_MATERIAL_ORDEN_COMPRA_RESULTADO])
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
