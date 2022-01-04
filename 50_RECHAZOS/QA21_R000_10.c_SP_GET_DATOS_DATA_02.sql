-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			RECHAZOS
-- // OPERACION:		GET DATOS
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	30/NOVIEMBRE/2021
-- //////////////////////////////////////////////////////////////  

USE [DATA_02]
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO // SE CORRE EN BASE DE DATOS DATA_02 PORQUE LA FUNCION EN VB APUNTA A ESA BASE DE DATOS
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_JEFE_GRUPO_INSPECTOR_PRD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_JEFE_GRUPO_INSPECTOR_PRD]
GO

/*
 EXEC	[dbo].[PG_GET_JEFE_GRUPO_INSPECTOR_PRD] 0,0,  'JGR' -- JEFES DE GRUPO DE PRODUCCION
 EXEC	[dbo].[PG_GET_JEFE_GRUPO_INSPECTOR_PRD] 0,0,  'INS' -- INSPECTORES DE PRODUCCION
*/

CREATE PROCEDURE [dbo].[PG_GET_JEFE_GRUPO_INSPECTOR_PRD]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_S_PUESTO_TRABAJO				VARCHAR(100)
AS
	
	-- ///////////////////////////////////////////
	SELECT	CONCAT(LTRIM(RTRIM(EP_NOMBRE)), ' ', LTRIM(RTRIM(EP_APELLIDO_PATERNO)), ' ', LTRIM(RTRIM(EP_APELLIDO_MATERNO))) AS EMPLEADO
	FROM HOWE.dbo.VISTA_GAFETES (NOLOCK)
	WHERE DP_DEPTO IN (2, 6) -- DEPARTAMENTO DE PRODUCCION
	AND PT_PUESTO_TRABAJO = @PP_S_PUESTO_TRABAJO
	ORDER BY DP_DEPTO
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
