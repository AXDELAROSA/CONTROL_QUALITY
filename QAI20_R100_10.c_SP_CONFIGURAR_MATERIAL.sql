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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_CONFIGURAR_MATERIAL_INSPECCIONAR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_CONFIGURAR_MATERIAL_INSPECCIONAR]
GO
/*
 EXEC	[dbo].[PG_LI_CONFIGURAR_MATERIAL_INSPECCIONAR] 0,0, '','( TODOS )', '( TODOS )'

*/


CREATE PROCEDURE [dbo].[PG_LI_CONFIGURAR_MATERIAL_INSPECCIONAR]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_BUSCAR						VARCHAR(200),
	-- ===========================
	@PP_CB_CATEGORIA				VARCHAR(10),
	@PP_CB_LOCACION					VARCHAR(10)
AS

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	
	-- ///////////////////////////////////////////

	 SELECT	(CASE WHEN (	SELECT COUNT(K_INSPECCION_MATERIAL) 
							FROM [INSPECCION_MATERIAL] 
							WHERE K_ITEM = LTRIM(RTRIM(ITEM.K_ITEM))) > 0 THEN 1
				ELSE 0 END	)						AS PROGRAMADO,
			LTRIM(RTRIM(PART_NUMBER_ITEM_PEARL))	AS NUMERO_PARTE,
			--LTRIM(RTRIM(D_ITEM))					AS DESCRIPCION,
			LTRIM(RTRIM(TRADEMARK_ITEM))			AS DESCRIPCION,
			LTRIM(RTRIM(PROD_CAT))					AS PRODUCTO_CATEGORIA,
			LTRIM(RTRIM(LOC))						AS LOCACION,
			K_ITEM									AS K_ITEM
	-- =============================
	 FROM	IMITMIDX_SQL 
	 INNER JOIN COMPRAS.dbo.ITEM ON IMITMIDX_SQL.upc_cd = ITEM.K_ITEM
	 -- =============================
	 WHERE ( ITEM_NO					LIKE '%'+@PP_BUSCAR+'%'
			OR	D_ITEM					LIKE '%'+@PP_BUSCAR+'%'
			OR	PROD_CAT				LIKE '%'+@PP_BUSCAR+'%'
			OR	LOC						LIKE '%'+@PP_BUSCAR+'%' )
	-- =============================
	AND		( @PP_CB_LOCACION = '( TODOS )'		OR	LTRIM(RTRIM(IMITMIDX_SQL.LOC)) = @PP_CB_LOCACION  )
	AND		( @PP_CB_CATEGORIA = '( TODOS )'	OR	LTRIM(RTRIM(IMITMIDX_SQL.PROD_CAT)) = @PP_CB_CATEGORIA )
	-- =============================
	AND	K_CLASS_ITEM = 2
	-- =============================
	 ORDER BY ITEM_NO, PROD_CAT, LOC
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_CONFIGURAR_MATERIAL_INSPECCIONAR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_CONFIGURAR_MATERIAL_INSPECCIONAR]
GO
/*
 EXEC	[dbo].[PG_SK_CONFIGURAR_MATERIAL_INSPECCIONAR] 0,144, 35
*/


CREATE PROCEDURE [dbo].[PG_SK_CONFIGURAR_MATERIAL_INSPECCIONAR]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_ITEM						INT
	-- ===========================
AS

	
	-- ///////////////////////////////////////////
	 SELECT	0								AS PROGRAMADO,
			LTRIM(RTRIM(ITEM_NO))			AS NUMERO_PARTE,
			--LTRIM(RTRIM(ITEM_DESC_1))		AS DESCRIPCION,
			LTRIM(RTRIM(TRADEMARK_ITEM))	AS DESCRIPCION,
			LTRIM(RTRIM(PROD_CAT))			AS PRODUCTO_CATEGORIA,
			LTRIM(RTRIM(LOC))				AS LOCACION,
			K_ITEM							AS K_ITEM
	 FROM	IMITMIDX_SQL 
	 INNER JOIN COMPRAS.dbo.ITEM ON IMITMIDX_SQL.upc_cd = ITEM.K_ITEM
	 WHERE	K_ITEM = @PP_ITEM
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
