-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			QC ORDEN_LIBERADA
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	16/AGO/2021
-- ////////////////////////////////////////////////////////////// 

USE [PPMS_PEARL]
GO

-- //////////////////////////////////////////////////////////////
-- // DROPs
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ORDEN_LIBERADA]') AND type in (N'U'))
	DROP TABLE [dbo].[ORDEN_LIBERADA]
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TIPO_ORDEN_LIBERADA]') AND type in (N'U'))
	DROP TABLE [dbo].[TIPO_ORDEN_LIBERADA]
GO



-- //////////////////////////////////////////////////////////////
-- // TIPO_ORDEN_LIBERADA
-- //////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[TIPO_ORDEN_LIBERADA] (
	[K_TIPO_ORDEN_LIBERADA]	[INT]			NOT NULL,
	[D_TIPO_ORDEN_LIBERADA]	[VARCHAR] (100) NOT NULL,
	[S_TIPO_ORDEN_LIBERADA]	[VARCHAR] (10)	NOT NULL,
	[O_TIPO_ORDEN_LIBERADA]	[INT]			NOT NULL,
	[C_TIPO_ORDEN_LIBERADA]	[VARCHAR] (255) NOT NULL,
	[L_TIPO_ORDEN_LIBERADA]	[INT]			NOT NULL
) ON [PRIMARY]
GO


-- //////////////////////////////////////////////////////////////
ALTER TABLE [dbo].[TIPO_ORDEN_LIBERADA]
	ADD CONSTRAINT [PK_TIPO_ORDEN_LIBERADA]
		PRIMARY KEY CLUSTERED ([K_TIPO_ORDEN_LIBERADA])
GO


CREATE UNIQUE NONCLUSTERED 
	INDEX [UN_TIPO_ORDEN_LIBERADA_01_DESCRIPCION] 
	   ON [dbo].[TIPO_ORDEN_LIBERADA] ( [D_TIPO_ORDEN_LIBERADA] )
GO

-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CI_TIPO_ORDEN_LIBERADA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CI_TIPO_ORDEN_LIBERADA]
GO


CREATE PROCEDURE [dbo].[PG_CI_TIPO_ORDEN_LIBERADA]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	-- ========================================
	@PP_K_TIPO_ORDEN_LIBERADA	INT,
	@PP_D_TIPO_ORDEN_LIBERADA	VARCHAR(100),
	@PP_S_TIPO_ORDEN_LIBERADA	VARCHAR(10),
	@PP_O_TIPO_ORDEN_LIBERADA	INT,
	@PP_C_TIPO_ORDEN_LIBERADA	VARCHAR(255),
	@PP_L_TIPO_ORDEN_LIBERADA	INT
AS
	-- ===============================

	DECLARE @VP_K_EXISTE	INT

	SELECT	@VP_K_EXISTE =	K_TIPO_ORDEN_LIBERADA
							FROM	TIPO_ORDEN_LIBERADA
							WHERE	K_TIPO_ORDEN_LIBERADA=@PP_K_TIPO_ORDEN_LIBERADA

	-- ===============================
	IF @VP_K_EXISTE IS NULL
		INSERT INTO TIPO_ORDEN_LIBERADA	
			(	K_TIPO_ORDEN_LIBERADA,				D_TIPO_ORDEN_LIBERADA, 
				S_TIPO_ORDEN_LIBERADA,				O_TIPO_ORDEN_LIBERADA,
				C_TIPO_ORDEN_LIBERADA,
				L_TIPO_ORDEN_LIBERADA				)		
		VALUES	
			(	@PP_K_TIPO_ORDEN_LIBERADA,			@PP_D_TIPO_ORDEN_LIBERADA,	
				@PP_S_TIPO_ORDEN_LIBERADA,			@PP_O_TIPO_ORDEN_LIBERADA,
				@PP_C_TIPO_ORDEN_LIBERADA,
				@PP_L_TIPO_ORDEN_LIBERADA			)
	ELSE
		UPDATE	TIPO_ORDEN_LIBERADA
		SET		D_TIPO_ORDEN_LIBERADA	= @PP_D_TIPO_ORDEN_LIBERADA,	
				S_TIPO_ORDEN_LIBERADA	= @PP_S_TIPO_ORDEN_LIBERADA,			
				O_TIPO_ORDEN_LIBERADA	= @PP_O_TIPO_ORDEN_LIBERADA,
				C_TIPO_ORDEN_LIBERADA	= @PP_C_TIPO_ORDEN_LIBERADA,
				L_TIPO_ORDEN_LIBERADA	= @PP_L_TIPO_ORDEN_LIBERADA	
		WHERE	K_TIPO_ORDEN_LIBERADA=@PP_K_TIPO_ORDEN_LIBERADA
GO
-- //////////////////////////////////////////////////////////////


-- ===============================================
SET NOCOUNT ON
-- ===============================================


EXECUTE [dbo].[PG_CI_TIPO_ORDEN_LIBERADA] 0, 0, 1, 'NORMAL',		'NORMAL', 1, '', 1
EXECUTE [dbo].[PG_CI_TIPO_ORDEN_LIBERADA] 0, 0, 2, 'FICTICIA',		'FICTICIA', 1, '', 1
GO-- ===============================================
SET NOCOUNT OFF
-- ===============================================


-- //////////////////////////////////////////////////////////////
-- // ORDEN_LIBERADA
-- //////////////////////////////////////////////////////////////
CREATE TABLE [dbo].[ORDEN_LIBERADA] (
	[K_ORDEN_LIBERADA]			[INT]	IDENTITY(1, 1)	NOT NULL,
	-- =================================
	[K_TIPO_ORDEN_LIBERADA]		[INT]		NOT NULL,
	-- =================================
	[ORDEN]						[INT] 		NOT NULL,
	[MESA]						VARCHAR(50)	NOT NULL,
	[MUESTRA]					[INT] 		NOT NULL,
	[DEFECTOS]					[INT] 		NOT NULL,
	[PPMS]						[INT] 		NOT NULL,
	-- =================================
	[DEFECTOS_LAMINADO]			[INT] 		NOT NULL,
	[DEFECTOS_PERFORADO]		[INT] 		NOT NULL,
	[DEFECTOS_QUILTY]			[INT] 		NOT NULL,
	[DEFECTOS_SKIVING]			[INT] 		NOT NULL,	   
	[DEFECTOS_MESA]				[INT] 		NOT NULL,	   
	-- =================================
	[INSPECTOR_CALIDAD]			VARCHAR(150)	NOT NULL,
	[JEFE_GRUPO]				VARCHAR(150)	NOT NULL,
	-- =================================	
	[F_LIBERACION]				DATE		NOT NULL,
	-- =================================	
)ON [PRIMARY]	
GO

-- /////////////////////////////////////////////////////
ALTER TABLE [dbo].[ORDEN_LIBERADA]
	ADD CONSTRAINT [PK_ORDEN_LIBERADA]
		PRIMARY KEY CLUSTERED ([K_ORDEN_LIBERADA])
GO

-- //////////////////////////////////////////////////////
ALTER TABLE [dbo].[ORDEN_LIBERADA] 
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
