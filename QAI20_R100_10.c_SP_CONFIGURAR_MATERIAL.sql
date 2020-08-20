-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	RH
-- // MODULO:			PUESTO DESCRIPCION
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	04/FEB/2020
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
 EXEC	[dbo].[PG_LI_CONFIGURAR_MATERIAL_INSPECCIONAR] 0,0, ''
*/


CREATE PROCEDURE [dbo].[PG_LI_CONFIGURAR_MATERIAL_INSPECCIONAR]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_BUSCAR						VARCHAR(200)
	-- ===========================
	--@PP_K_PUESTO_DESCRIPCION		INT,
	--@PP_K_AREA						INT,
	--@PP_K_ESTATUS_PUESTO			INT,
	--@PP_F_REVISON					DATE
AS

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	
	-- ///////////////////////////////////////////

	 SELECT	0							AS PROGRAMADO,
			LTRIM(RTRIM(ITEM_NO))		AS NUMERO_PARTE,
			LTRIM(RTRIM(ITEM_DESC_1))	AS DESCRIPCION,
			LTRIM(RTRIM(PROD_CAT))		AS PRODUCTO_CATEGORIA,
			LTRIM(RTRIM(LOC))			AS LOCACION
	 FROM IMITMIDX_SQL 
	 WHERE 
	 (	ITEM_NO					LIKE '%'+@PP_BUSCAR+'%'
			OR	ITEM_DESC_1				LIKE '%'+@PP_BUSCAR+'%'
			OR	PROD_CAT				LIKE '%'+@PP_BUSCAR+'%'
			OR	LOC						LIKE '%'+@PP_BUSCAR+'%' )
	 AND	ACTIVITY_DT >= 20200301
	 ORDER BY ITEM_NO, PROD_CAT, LOC
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
