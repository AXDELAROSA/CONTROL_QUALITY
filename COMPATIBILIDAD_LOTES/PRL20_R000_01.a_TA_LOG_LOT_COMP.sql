-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			LOT_COMP
-- // OPERATION:		TABLA
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210302
-- ////////////////////////////////////////////////////////////// 

--USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SER_LOT_COMP_SQL_LOG]') AND type in (N'U'))
	DROP TABLE [dbo].[SER_LOT_COMP_SQL_LOG]
GO
-- //////////////////////////////////////////////////////////////
-- // SER_LOT_COMP_SQL_LOG
--// PARA GENERAR EL LOG DE LOTES COMPATIBLES.
-- //////////////////////////////////////////////////////////////
--	SELECT * FROM SER_LOT_COMP_SQL_LOG
CREATE TABLE [dbo].[SER_LOT_COMP_SQL_LOG] (
	[K_SER_LOT_COMP_SQL_LOG]			[INT] IDENTITY (1,1)	NOT NULL,
	[ITEM_NO]							[VARCHAR]	(25)		NOT NULL,
	[SER_LOT_NO_1]						[VARCHAR]	(10)		NOT NULL,
	[SER_LOT_NO_2]						[VARCHAR]	(10)		NOT NULL,
	[COMP]								[VARCHAR]	(10)		NOT NULL,
	[AUT1]								[VARCHAR]	(250)		NOT NULL,
	[AUT2]								[VARCHAR]	(250)		NOT NULL,
	[K_USUARIO_PEARL_01]				INT		NOT NULL,
	[K_USUARIO_PEARL_02]				INT		NOT NULL,
	[COMMENTS]							[VARCHAR]	(500)		NOT NULL,
	[ACCION_REALIZADA]					[VARCHAR]	(100)		NOT NULL
) ON [PRIMARY]
GO
-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[SER_LOT_COMP_SQL_LOG]
	ADD		[K_USUARIO_ALTA]			[INT] NOT NULL,
			[F_ALTA]					[DATETIME] NOT NULL
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
