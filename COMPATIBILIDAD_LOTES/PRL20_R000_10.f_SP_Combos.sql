-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			LOT_COMP
-- // OPERATION:		CARGA COMBO
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210224
-- ////////////////////////////////////////////////////////////// 

--USE [DATA_02Pruebas]
GO


-- //////////////////////////////////////////////////////////////
-- //		MUESTRA LOS COLORES ACTIVOS EN EL SISTEMA
-- //		PARA LA PANTALLA DE COMPATIBILIDAD DE LOTES
-- ////////////////////////////////////////////////////////////// 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_ITEM_ACTIVOS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_ITEM_ACTIVOS]
GO
--		 EXECUTE [dbo].[PG_CB_ITEM_ACTIVOS] 1,139,0
--		 EXECUTE [dbo].[PG_CB_ITEM_ACTIVOS] 1,139,1
CREATE PROCEDURE [dbo].[PG_CB_ITEM_ACTIVOS]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS
	
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		VARCHAR(25),
					TA_D_CATALOGO		VARCHAR(50),
					TA_O_CATALOGO		INT,
					TA_L_DELETED		INT,	
					TA_L_ACTIVO			INT			 )
	
	INSERT INTO @VP_TA_CATALOGO 
	SELECT	DISTINCT	
			LTRIM(RTRIM(COLOUR))	AS TA_K_CATALOGO,
			LTRIM(RTRIM(COLOUR))	AS TA_D_CATALOGO,
			0						AS TA_O_CATALOGO,
			0						AS L_DELETED, 
			1						AS L_ACTIVO
	FROM	COLORES_ACTIVOS		(NOLOCK) 
	INNER JOIN	IMLSMST_SQL		(NOLOCK) ON	COLORES_ACTIVOS.colour=IMLSMST_SQL.item_no
	--WHERE	QTY_ON_HAND		>	0

	ORDER BY	LTRIM(RTRIM(COLOUR))

	IF @PP_L_CON_TODOS=0
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( '( TODOS )',				'( TODOS )',	-999,		   0,			 1				)

	IF @PP_L_CON_TODOS=1
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( '-1',				'( SELECCIONA )',	-999,		   0,			 1				)

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			TA_D_CATALOGO	AS D_COMBOBOX 
	FROM	@VP_TA_CATALOGO
	ORDER BY TA_O_CATALOGO, TA_D_CATALOGO 		
	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- //		LLENA LOS COMBOS CON LOS USUARIOS AUTORIZADOS
-- //		PARA REALIZAR LA COMPATIBILIDAD DE LOTES.
-- ////////////////////////////////////////////////////////////// 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_USUARIO_COMPATIBLE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_USUARIO_COMPATIBLE]
GO
--		 EXECUTE [dbo].[PG_CB_USUARIO_COMPATIBLE] 1,139,1
CREATE PROCEDURE [dbo].[PG_CB_USUARIO_COMPATIBLE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS
--Omar Decena						--	#42		PROYECTOS
--Miguel Carrasco					--	#47
--Ivan Decena						--	#48
--Jose Sanchez						--	#92
--Jorge Olegario					--	#86
--Jorge Jaramillo					--	#140
--Francisco Morales					--	#94
--Misael Sanchez					--	NO USUARIO PEARL
--Edgar Armijo						--	#102
--Leyver Roblero					--	#101	NO EXISTE
--Rodolfo Carbajal					--	#138
--Rosario Mendoza					--	#147	BAJA
--No autorizado						--	#-1		NO AUTORIZADO

	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT,
					TA_D_CATALOGO		VARCHAR(50),
					TA_O_CATALOGO		INT,
					TA_L_DELETED		INT,	
					TA_L_ACTIVO			INT			 )
	
	INSERT INTO @VP_TA_CATALOGO 
	SELECT	
			K_USUARIO_PEARL						AS TA_K_CATALOGO,
			NOMBRE + ' ' + APELLIDO_PATERNO 	AS TA_D_CATALOGO,
			0									AS TA_O_CATALOGO,
			0									AS L_DELETED, 
			1									AS L_ACTIVO
	FROM	BD_GENERAL.DBO.USUARIO_PEARL		(NOLOCK)
	WHERE	K_USUARIO_PEARL	IN	(42, 47, 48, 92, 86, 140, 94, 102, 138, 147, 170, 173)
	AND		L_BORRADO	= 0
	ORDER BY	NOMBRE, APELLIDO_PATERNO
		
	INSERT INTO @VP_TA_CATALOGO
			( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
		VALUES
			( -2,				'NO AUTORIZADO',	-2,		   0,			 1				)	
	
	IF @PP_L_CON_TODOS=1
		INSERT INTO @VP_TA_CATALOGO
				( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
			VALUES
				( -1,				'( SELECCIONA )',	-999,		   0,			 1				)

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			TA_D_CATALOGO	AS D_COMBOBOX 
	FROM	@VP_TA_CATALOGO
	ORDER BY TA_O_CATALOGO, TA_D_CATALOGO
	-- ==========================================
	-- ////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- //		MUESTRA LOS LOTES ASOCIADOS AL COLOR
-- //		Y QUE TENGAN SQFT EN LA TABLA DE IMLSMST_SQL
-- ////////////////////////////////////////////////////////////// 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_SER_LOT_NO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_SER_LOT_NO]
GO
--		 EXECUTE [dbo].[PG_CB_SER_LOT_NO] 1,139,'FWLNPX7'
CREATE PROCEDURE [dbo].[PG_CB_SER_LOT_NO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_ITEM_NO					VARCHAR(25)
AS
	
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		VARCHAR(25),
					TA_D_CATALOGO		VARCHAR(50),
					TA_O_CATALOGO		INT,
					TA_L_DELETED		INT,	
					TA_L_ACTIVO			INT			 )
	
	INSERT INTO @VP_TA_CATALOGO
	SELECT DISTINCT	
			LTRIM(RTRIM(SER_LOT_NO))	AS TA_K_CATALOGO,
			LTRIM(RTRIM(SER_LOT_NO))	AS TA_D_CATALOGO,
			0							AS TA_O_CATALOGO,
			0							AS L_DELETED, 
			1							AS L_ACTIVO
	FROM	IMLSMST_SQL		(NOLOCK)
	WHERE	QTY_ON_HAND		>	0
	AND		LTRIM(RTRIM(ITEM_NO))=@PP_ITEM_NO
	AND (		
												LOC LIKE 'T%'
											OR	LTRIM(RTRIM(LOC))	IN ('MHI')	)
	ORDER BY	LTRIM(RTRIM(SER_LOT_NO))

	INSERT INTO @VP_TA_CATALOGO
			( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
		VALUES
			( '( SELECCIONA )',				'( SELECCIONA )',	-999,		   0,			 1				)

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			TA_D_CATALOGO	AS D_COMBOBOX 
	FROM	@VP_TA_CATALOGO
	ORDER BY TA_O_CATALOGO, TA_D_CATALOGO 		
	-- ////////////////////////////////////////////////////
GO

--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_SER_LOT_NO_02]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_CB_SER_LOT_NO_02]
--GO
----		 EXECUTE [dbo].[PG_CB_SER_LOT_NO_02] 1,139,'FCMP5B8', '060062'
----		 EXECUTE [dbo].[PG_CB_SER_LOT_NO_02] 1,139,'FCNPDX9', '106111'
--CREATE PROCEDURE [dbo].[PG_CB_SER_LOT_NO_02]
--	@PP_K_SISTEMA_EXE			INT,
--	@PP_K_USUARIO				INT,
--	--============================
--	@PP_ITEM_NO					VARCHAR(25),
--	@PP_LOTE					VARCHAR(10)
--AS
	
--	DECLARE @VP_TA_CATALOGO	AS TABLE
--				(	TA_K_CATALOGO		VARCHAR(25),
--					TA_D_CATALOGO		VARCHAR(50),
--					TA_O_CATALOGO		INT,
--					TA_L_DELETED		INT,	
--					TA_L_ACTIVO			INT			 )
	
--	INSERT INTO @VP_TA_CATALOGO
--	SELECT DISTINCT	
--			LTRIM(RTRIM(SER_LOT_NO))	AS TA_K_CATALOGO,
--			LTRIM(RTRIM(SER_LOT_NO))	AS TA_D_CATALOGO,
--			0							AS TA_O_CATALOGO,
--			0							AS L_DELETED, 
--			1							AS L_ACTIVO
--	FROM	IMLSMST_SQL 
--	--WHERE	QTY_ON_HAND		<>	0
--	WHERE	QTY_ON_HAND		>	0
--	AND		LTRIM(RTRIM(ITEM_NO))		=	@PP_ITEM_NO
--	AND		LTRIM(RTRIM(SER_LOT_NO))	<>	@PP_LOTE
--	ORDER BY	LTRIM(RTRIM(SER_LOT_NO))

--	INSERT INTO @VP_TA_CATALOGO
--			( TA_K_CATALOGO,	TA_D_CATALOGO,	TA_O_CATALOGO, TA_L_DELETED, TA_L_ACTIVO	)
--		VALUES
--			( '( TODOS )',				'( TODOS )',	-999,		   0,			 1				)

--	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
--			TA_D_CATALOGO	AS D_COMBOBOX 
--	FROM	@VP_TA_CATALOGO
--	ORDER BY TA_O_CATALOGO, TA_D_CATALOGO 		
--	-- ////////////////////////////////////////////////////
--GO
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////