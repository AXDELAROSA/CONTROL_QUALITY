-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			EMBARQUES
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	16/11/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////

-- EXECUTE [PG_CB_ESTATUS_INCINSP] 001,144, 2
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_ESTATUS_INCINSP]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_ESTATUS_INCINSP]
GO

CREATE PROCEDURE [dbo].[PG_CB_ESTATUS_INCINSP]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50))
	
	IF @PP_L_CON_TODOS=0
		INSERT INTO @VP_TA_CATALOGO 
		SELECT	DISTINCT 1,
				[STATUS] 
		FROM	IncInsp_sql 
	
	IF @PP_L_CON_TODOS=1
		BEGIN
			INSERT INTO @VP_TA_CATALOGO 
			SELECT	DISTINCT 1,
					[STATUS] 
			FROM	IncInsp_sql

			INSERT INTO @VP_TA_CATALOGO
					( TA_K_CATALOGO,	TA_D_CATALOGO	)
				VALUES
					( -1,				'( TODOS )'	)
		END

	IF @PP_L_CON_TODOS=2
		INSERT INTO @VP_TA_CATALOGO
		SELECT	DISTINCT 1,
				[STATUS] 
		FROM	IncInsp_sql 
		WHERE [STATUS] <> '-'

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
				TA_D_CATALOGO	AS D_COMBOBOX 
		FROM	@VP_TA_CATALOGO
		ORDER BY  TA_D_CATALOGO 

	-- ==========================================
		
	-- ////////////////////////////////////////////////////
GO




-- EXECUTE [PG_CB_ACCEPTED_INCINSP] 001,144, 2
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_ACCEPTED_INCINSP]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_ACCEPTED_INCINSP]
GO

CREATE PROCEDURE [dbo].[PG_CB_ACCEPTED_INCINSP]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50))
	
	IF @PP_L_CON_TODOS=0
		INSERT INTO @VP_TA_CATALOGO 
		SELECT	DISTINCT 1,
				ACCEPTED 
		FROM	IncInsp_sql 
	
	IF @PP_L_CON_TODOS=1
		BEGIN
			INSERT INTO @VP_TA_CATALOGO 
			SELECT	DISTINCT 1,
					ACCEPTED 
			FROM	IncInsp_sql

			INSERT INTO @VP_TA_CATALOGO
					( TA_K_CATALOGO,	TA_D_CATALOGO	)
				VALUES
					( -1,				'( TODOS )'	)
		END

	IF @PP_L_CON_TODOS=2
		INSERT INTO @VP_TA_CATALOGO
		SELECT	DISTINCT 1,
				ACCEPTED 
		FROM	IncInsp_sql 
		WHERE ACCEPTED <> '-'

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
				TA_D_CATALOGO	AS D_COMBOBOX 
		FROM	@VP_TA_CATALOGO
		ORDER BY  TA_D_CATALOGO 

	-- ==========================================
		
	-- ////////////////////////////////////////////////////
GO




-- EXECUTE [PG_CB_DEFECTO_INCINSP] 001,144, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_DEFECTO_INCINSP]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_DEFECTO_INCINSP]
GO

CREATE PROCEDURE [dbo].[PG_CB_DEFECTO_INCINSP]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50))
	
	INSERT INTO @VP_TA_CATALOGO 
	SELECT 1,
			LTRIM(RTRIM(DEFECTO)) 
	FROM PPMS_PEARL.DBO.def 
	WHERE descripcion='NATURAL'
	
	IF @PP_L_CON_TODOS=1
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO	)
			VALUES
				( -1,				'( TODOS )'	)
		

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
				TA_D_CATALOGO	AS D_COMBOBOX 
		FROM	@VP_TA_CATALOGO
		ORDER BY  TA_D_CATALOGO 

	-- ==========================================
		
	-- ////////////////////////////////////////////////////
GO

-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////