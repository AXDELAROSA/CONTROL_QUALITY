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




-- //////////////////////////////////////////////////////////////
-- // INSPECCION_MATERIAL_RESULTADO
-- //////////////////////////////////////////////////////////////

CREATE TABLE [dbo].[INSPECCION_MATERIAL_ORDEN] (
	[K_INSPECCION_MATERIAL_ORDEN]				[INT]			NOT NULL,
	-- =================================
	[K_ORDEN_COMPRA]							[INT]			NOT NULL,
	[NUMERO_PARTE]								VARCHAR(150)	NOT NULL,	
	[K_INSPECCION_MATERIAL]						[INT]			NOT NULL,
	[OPCION_SELECCIONADA]						VARCHAR(255)	NOT NULL,
	[OPCION_PORCENTAJE]							DECIMAL(13,2)	NOT NULL,
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
	[K_INSPECCION_MATERIAL_ORDEN_RESULTADO]		[INT]		NOT NULL,
	-- =================================
	[K_ORDEN_COMPRA]							[INT]				NOT NULL,
	[NUMERO_PARTE]								VARCHAR(150)	NOT NULL,
	[PORCENTAJE_APROBATORIO]					DECIMAL(13,2)	NOT NULL,
	[TOTAL_PORCENTAJE_ACUMULADO]				DECIMAL(13,2)	NOT NULL,
	[APROBACION_SISTEMA]						[INT]			NOT NULL,
	[APROBACION_MANUAL]							[INT]			DEFAULT 0,
	[COMENTARIO]								VARCHAR(255)	DEFAULT '',
	-- =================================	
	[F_INSPECCION_MATERIAL_ORDEN_RESULTADO]		DATE			NOT NULL
)ON [PRIMARY]	
GO

-- //////////////////////////////////////////////////////

ALTER TABLE [dbo].[INSPECCION_MATERIAL_ORDEN_RESULTADO]
	ADD CONSTRAINT [PK_INSPECCION_MATERIAL_ORDEN_RESULTADO]
		PRIMARY KEY CLUSTERED ([K_INSPECCION_MATERIAL_ORDEN_RESULTADO])
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
