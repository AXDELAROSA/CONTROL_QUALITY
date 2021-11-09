-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[PPMS_PEARL]
-- // MODULO:			PPM & CERTIFICACION REPORT
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	22/SEP/2021
-- //////////////////////////////////////////////////////////////  

USE [PPMS_PEARL]
GO

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////
--	USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_MATERIAL_REVISADO_CERTIFICACION_ACUMULADO_DIA_X_TURNO_X_HORA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_MATERIAL_REVISADO_CERTIFICACION_ACUMULADO_DIA_X_TURNO_X_HORA]
GO

/*
	EXEC	[dbo].[PG_LI_MATERIAL_REVISADO_CERTIFICACION_ACUMULADO_DIA_X_TURNO_X_HORA] 0, 144, '2021-11-08', 1
*/

CREATE PROCEDURE [dbo].[PG_LI_MATERIAL_REVISADO_CERTIFICACION_ACUMULADO_DIA_X_TURNO_X_HORA]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_F_FIN					DATE,
	@PP_TURNO					INT
AS
	
	-- //////SE CREA TABLA TEMPORAL//////////////////////////////////////
	DECLARE @TBL_MATERIAL_REVISADO_DIA TABLE(
	SELLO			VARCHAR(100),
	INSPECTOR		VARCHAR(100),
	MUESTRA			INT,
	DEFECTOS		INT
	)

	-- //////SE INGRESAN LOS DATOS A LA TABLA TEMPORAL//////////////////////////////////////
	INSERT INTO @TBL_MATERIAL_REVISADO_DIA
	SELECT	SELLO_PAQ	AS SELLO,
			INSPECTOR_CAL	AS INSPECTOR, 
			SUM(total)	AS REVISADAS,
			( SUM(cant1) + SUM(cant2) + SUM(cant3)) AS DEFECTOS
	FROM certificacion_rpt (NOLOCK)
	INNER JOIN personal (NOLOCK) ON sello = sello_paq
	WHERE CONVERT(DATE, fecha) = @PP_F_FIN
	AND personal.turno = @PP_TURNO
	AND insp_certi <> '' 
	GROUP BY SELLO_PAQ, INSPECTOR_CAL

	-- //////SE CREA TABLA TEMPORAL//////////////////////////////////////
	DECLARE @TBL_MATERIAL_REVISADO_X_DIA_TOTAL TABLE(
	INSPECTOR				VARCHAR(100),
	TOTAL_MUESTRA			INT,
	TOTAL_DEFECTOS			INT,
	TOTAL_PPMS				INT
	)

	-- /////////SE CALCULAS LOS TOTALES Y SE MUESTRA EL RESULTADO//////////////
	INSERT INTO @TBL_MATERIAL_REVISADO_X_DIA_TOTAL
	SELECT	--CONCAT((SUBSTRING( CONCAT(EP_NOMBRE, ' '), 1, CHARINDEX(' ', CONCAT(EP_NOMBRE, ' ')))), ' ' + EP_APELLIDO_PATERNO) AS INSPECTOR, 
			(	SELECT TOP 1 CONCAT((SUBSTRING( CONCAT(EP_NOMBRE, ' '), 1, CHARINDEX(' ', CONCAT(EP_NOMBRE, ' ')))), ' ' + EP_APELLIDO_PATERNO)
				FROM HOWE.DBO.VISTA_GAFETES (NOLOCK)
				INNER JOIN personal (NOLOCK) ON LTRIM(RTRIM(inspector_cal)) =  LTRIM(RTRIM(INSPECTOR)) AND EN_NUM_EMP = noreloj	) AS INSPECTOR,
			MUESTRA AS 'TOTAL_MUESTRA', 
			DEFECTOS AS 'TOTAL_DEFECTOS', 
			( CASE WHEN (MUESTRA) > 0 THEN CONVERT(INT, (CONVERT(DECIMAL(13,2), DEFECTOS) / CONVERT(DECIMAL(13,2), MUESTRA) * 1000000) )
				ELSE 0 END ) AS 'TOTAL_PPMS'
	FROM @TBL_MATERIAL_REVISADO_DIA
	--INNER JOIN personal (NOLOCK) ON LTRIM(RTRIM(inspector_cal)) =  INSPECTOR
	--INNER JOIN HOWE.DBO.VISTA_GAFETES (NOLOCK) ON EN_NUM_EMP = noreloj
	--WHERE DEFECTOS > 0
	--ORDER BY TOTAL_PPMS DESC

	-- /////////SE MUESTRA EL RESULTADO//////////////
	SELECT INSPECTOR,		
		   TOTAL_MUESTRA,	
		   TOTAL_DEFECTOS,	
		   TOTAL_PPMS		
	FROM @TBL_MATERIAL_REVISADO_X_DIA_TOTAL
	WHERE INSPECTOR IS NOT NULL
	ORDER BY TOTAL_PPMS DESC
	-- //////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
