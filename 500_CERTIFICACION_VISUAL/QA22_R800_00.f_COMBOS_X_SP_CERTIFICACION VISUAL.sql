-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		[PPMS_PEARL]
-- // MODULE:			CERTIFICACION_VISUAL
-- // OPERATION:		CARGA COMBO
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20220401
-- ////////////////////////////////////////////////////////////// 

USE [PPMS_PEARL]
GO

-- //////////////////////////////////////////////////////////////
-- ////////			CONTENIDO DEL SP	------------------------
--	[PG_CB_DEFECTOS_PPMS]


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> CB / MUESTRA LOS CLIENTES CON VERSIONES ACTIVAS EN PEARL
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_DEFECTOS_PPMS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_DEFECTOS_PPMS]
GO
--		 EXECUTE [dbo].[PG_CB_DEFECTOS_PPMS] 0,0, 0
--		 EXECUTE [dbo].[PG_CB_DEFECTOS_PPMS] 0,0, 3
CREATE PROCEDURE [dbo].[PG_CB_DEFECTOS_PPMS]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		VARCHAR(10),
					TA_D_CATALOGO		VARCHAR(150),
					TA_O_CATALOGO		INT,
					TA_L_DELETED		INT,	
					TA_L_ACTIVO			INT			 )
	IF @PP_L_CON_TODOS	IN ( 0 )
	BEGIN
		INSERT INTO @VP_TA_CATALOGO
		SELECT	CLAVE			,
				CONCAT( ( CASE 
							WHEN LEN(CLAVE) = 2 THEN CONCAT(CLAVE,' ')
							ELSE CLAVE
						END )	, ' // ' , LTRIM(RTRIM(DEFECTO)) ),
				0,	
				0,	
				1
		FROM	PPMS_PEARL.dbo.DEF	(NOLOCK)
		ORDER	BY DEFECTO
	END
	ELSE IF @PP_L_CON_TODOS	IN ( 3 )
	BEGIN
		INSERT INTO @VP_TA_CATALOGO
		SELECT	CLAVE			,
				CONCAT( ( CASE 
							WHEN TIPODEF LIKE 'PER%' THEN '(P) '
							ELSE ''
						END )	,						
						( CASE 
							WHEN LEN(CLAVE) = 2 THEN CONCAT(CLAVE,' ')
							ELSE CLAVE
						END )	, ' // ' , LTRIM(RTRIM(DEFECTO)) ),
				0,	
				0,	
				1
		FROM	PPMS_PEARL.dbo.DEF	(NOLOCK)
		ORDER	BY DEFECTO
	END

	-- ==========================================		
	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			(
				(CASE 
					WHEN (TA_L_ACTIVO=1 AND TA_L_DELETED=0) THEN '' 
					ELSE '<X> ' 
					END 
				) +		TA_D_CATALOGO 
			) AS D_COMBOBOX
	FROM	@VP_TA_CATALOGO
	ORDER BY TA_D_CATALOGO ,	TA_O_CATALOGO
	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> CB / MUESTRA LOS CLIENTES CON VERSIONES ACTIVAS EN PEARL
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_INDICAR_CANTIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_INDICAR_CANTIDAD]
GO
--		 EXECUTE [dbo].[PG_CB_INDICAR_CANTIDAD] 0,0, 0	, 10
--		 EXECUTE [dbo].[PG_CB_INDICAR_CANTIDAD] 0,0, 1	, 10
CREATE PROCEDURE [dbo].[PG_CB_INDICAR_CANTIDAD]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT,
	@PP_CANTIDAD_A_MOSTAR		INT
AS
		DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,-- IDENTITY(1,1) ,
					TA_D_CATALOGO		VARCHAR(150)
				)

	DECLARE	 @VP_CANTIDAD_MAYOR		INTEGER	= 4
			,@VP_CONTADOR			INTEGER	= 0

	--IF @PP_CANTIDAD_A_MOSTAR > 0
	--BEGIN
	--	SET	@VP_CANTIDAD_MAYOR	= @PP_CANTIDAD_A_MOSTAR
	--END
	
	WHILE	@VP_CANTIDAD_MAYOR > 0
	BEGIN
		SET @VP_CONTADOR += 1
		INSERT INTO @VP_TA_CATALOGO
		SELECT	@VP_CONTADOR , @VP_CONTADOR

		SET @VP_CANTIDAD_MAYOR-= 1
	END


	IF @PP_L_CON_TODOS IN ( 1 )
	BEGIN
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO)
			VALUES
				( -1,				'( ELEGIR )' )
	END

	-- ==========================================		
	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			TA_D_CATALOGO	AS D_COMBOBOX
	FROM	@VP_TA_CATALOGO
	ORDER BY TA_K_CATALOGO	ASC
	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> CB / MUESTRA LOS CLIENTES CON VERSIONES ACTIVAS EN PEARL
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_INDICAR_TURNO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_INDICAR_TURNO]
GO
--		 EXECUTE [dbo].[PG_CB_INDICAR_TURNO] 0,0, 0, 3
--		 EXECUTE [dbo].[PG_CB_INDICAR_TURNO] 0,0, 1, 3
CREATE PROCEDURE [dbo].[PG_CB_INDICAR_TURNO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT,
	@PP_CANTIDAD_TURNOS			INT
AS
		DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,-- IDENTITY(1,1) ,
					TA_D_CATALOGO		VARCHAR(150)
				)

	DECLARE	 @VP_CANTIDAD_A_MOSTAR	INTEGER	= 0
			,@VP_CONTADOR			INTEGER	= 0

	SET	@VP_CANTIDAD_A_MOSTAR	= @PP_CANTIDAD_TURNOS
	
	WHILE	@VP_CANTIDAD_A_MOSTAR > 0
	BEGIN
		SET @VP_CONTADOR += 1
		INSERT INTO @VP_TA_CATALOGO
		SELECT	@VP_CONTADOR , CONCAT ( CONVERT(VARCHAR(10),@VP_CONTADOR),'º')

		SET @VP_CANTIDAD_A_MOSTAR-= 1
	END


	IF @PP_L_CON_TODOS IN ( 1 )
	BEGIN
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO)
			VALUES
				( -1,				'( ELEGIR )' )
	END

	-- ==========================================		
	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			TA_D_CATALOGO	AS D_COMBOBOX
	FROM	@VP_TA_CATALOGO
	ORDER BY TA_K_CATALOGO	ASC
	-- ////////////////////////////////////////////////////
GO
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////