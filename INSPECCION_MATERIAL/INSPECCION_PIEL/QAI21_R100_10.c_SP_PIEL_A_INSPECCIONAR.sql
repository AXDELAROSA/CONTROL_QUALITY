-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			QA INSPECCION DE MATERIAL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	20/AGO/2020
-- //////////////////////////////////////////////////////////////  

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_INCINSP_SQL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_INCINSP_SQL]
GO
/*
 EXEC	[dbo].[PG_LI_INCINSP_SQL] 0,0, '', '2021/03/10', '2021/03/15', '( TODOS )', '( TODOS )', '( TODOS )', '( TODOS )'
*/


CREATE PROCEDURE [dbo].[PG_LI_INCINSP_SQL]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_BUSCAR						VARCHAR(200),
	-- ===========================
	@PP_F_INICIO					DATE,
	@PP_F_FIN						DATE,
	@PP_COLOR						VARCHAR(50),
	@PP_ESTATUS						VARCHAR(10),
	@PP_ACEPTADO					VARCHAR(10),
	@PP_DEFECTO						VARCHAR(50)
AS

	-- ///////////////////////////////////////////
	SELECT	ID					AS K_INSPECCION_LOTE,
			[dbo].[CONVERT_INT_TO_DATE]([Date])	AS FECHA,
			PACKING_NO,
			[Description]		AS COLOR,
			LTRIM(RTRIM(Lot))	AS LOTE,
			Lot_size			AS CANTIDAD_LOTE,
			Sample_size			AS CANTIDAD_MUESTRA,
			[Status]			AS ESTATUS,
			Accepted			AS ACEPTADO,
			Thickness			AS THICKNESS,
			Defecto				AS DEFECTO
	FROM	IncInsp_sql
	WHERE 	( LOT				LIKE '%'+@PP_BUSCAR+'%'
			OR	PACKING_NO		LIKE '%'+@PP_BUSCAR+'%' )
	-- =============================
	AND		[DATE] >= [dbo].[CONVERT_DATE_TO_INT](@PP_F_INICIO, 'yyyyMMdd')
	AND		[DATE] <= [dbo].[CONVERT_DATE_TO_INT](@PP_F_FIN, 'yyyyMMdd') 	
	AND		( @PP_COLOR = '( TODOS )'		OR	LTRIM(RTRIM([Description])) = @PP_COLOR  )
	AND		( @PP_ESTATUS = '( TODOS )'		OR	LTRIM(RTRIM([STATUS])) = @PP_ESTATUS )
	AND		( @PP_ACEPTADO = '( TODOS )'	OR	LTRIM(RTRIM(Accepted)) = @PP_ACEPTADO )
	AND		( @PP_DEFECTO = '( TODOS )'		OR	LTRIM(RTRIM(Defecto)) = @PP_DEFECTO )
	ORDER BY	[DATE]	DESC
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_INCINSP_SQL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_INCINSP_SQL]
GO
/*
 EXEC	[dbo].[PG_SK_INCINSP_SQL] 0,0, 6456
*/


CREATE PROCEDURE [dbo].[PG_SK_INCINSP_SQL]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_INSPECCION_LOTE			INT
AS

	-- ///////////////////////////////////////////
	SELECT	ID					AS K_INSPECCION_LOTE,
			[dbo].[CONVERT_INT_TO_DATE]([Date])	AS FECHA,
			PACKING_NO,
			LTRIM(RTRIM(Lot))	AS LOTE,
			Description			AS COLOR,
			Lot_size			AS CANTIDAD_LOTE,
			Sample_size			AS CANTIDAD_MUESTRA,
			Status				AS ESTATUS,
			Accepted			AS ACEPTADO,
			Thickness			AS THICKNESS,
			Defecto				AS DEFECTO
	FROM	IncInsp_sql
	WHERE 	ID = @PP_K_INSPECCION_LOTE

	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
