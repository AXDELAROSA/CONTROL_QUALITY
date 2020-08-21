-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			QA INSPECCION DE MATERIAL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	20/AGO/2020
-- //////////////////////////////////////////////////////////////  

USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_CONFIGURAR_MATERIAL_INSPECCIONAR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_CONFIGURAR_MATERIAL_INSPECCIONAR]
GO
/*
 EXEC	[dbo].[PG_LI_CONFIGURAR_MATERIAL_INSPECCIONAR] 0,0, '','-1', '-1'

 USE BD_GENERAL
 EXEC	[dbo].[PG_CB_PRODUCT_CATEGORY_IMCATFIL_SQL] 0,0, 0
*/


CREATE PROCEDURE [dbo].[PG_LI_CONFIGURAR_MATERIAL_INSPECCIONAR]1
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

	 SELECT	0							AS PROGRAMADO,
			LTRIM(RTRIM(ITEM_NO))		AS NUMERO_PARTE,
			LTRIM(RTRIM(ITEM_DESC_1))	AS DESCRIPCION,
			LTRIM(RTRIM(PROD_CAT))		AS PRODUCTO_CATEGORIA,
			LTRIM(RTRIM(LOC))			AS LOCACION
	-- =============================
	 FROM IMITMIDX_SQL 
	 -- =============================
	 WHERE ( ITEM_NO					LIKE '%'+@PP_BUSCAR+'%'
			OR	ITEM_DESC_1				LIKE '%'+@PP_BUSCAR+'%'
			OR	PROD_CAT				LIKE '%'+@PP_BUSCAR+'%'
			OR	LOC						LIKE '%'+@PP_BUSCAR+'%' )
	-- =============================
	AND		( @PP_CB_LOCACION = '( TODOS )'		OR	LTRIM(RTRIM(IMITMIDX_SQL.LOC)) = @PP_CB_LOCACION  )
	AND		( @PP_CB_CATEGORIA = '( TODOS )'	OR	LTRIM(RTRIM(IMITMIDX_SQL.PROD_CAT)) = @PP_CB_CATEGORIA )
	-- =============================
	AND	ACTIVITY_DT >= 20200301	-- PARA PRUEBAS FEG
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
 EXEC	[dbo].[PG_SK_CONFIGURAR_MATERIAL_INSPECCIONAR] 0,0, 'FDNPDX9'
*/


CREATE PROCEDURE [dbo].[PG_SK_CONFIGURAR_MATERIAL_INSPECCIONAR]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_NUMERO_PARTE				VARCHAR(50)
	-- ===========================
AS

	
	-- ///////////////////////////////////////////

	 SELECT	0							AS PROGRAMADO,
			LTRIM(RTRIM(ITEM_NO))		AS NUMERO_PARTE,
			LTRIM(RTRIM(ITEM_DESC_1))	AS DESCRIPCION,
			LTRIM(RTRIM(PROD_CAT))		AS PRODUCTO_CATEGORIA,
			LTRIM(RTRIM(LOC))			AS LOCACION
	 FROM	IMITMIDX_SQL 
	 WHERE	LTRIM(RTRIM(ITEM_NO)) = @PP_NUMERO_PARTE
	 AND	ACTIVITY_DT >= 20200301
	 ORDER BY ITEM_NO, PROD_CAT, LOC
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
