-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[PPMS_PEARL]
-- // MODULO:			PPMS PRODUCCION
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	25/ENE/2022
-- //////////////////////////////////////////////////////////////  

USE [PPMS_PEARL]
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_PPMS_PRD_HEADER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_PPMS_PRD_HEADER]
GO

/*
 EXEC	[dbo].[PG_LI_PPMS_PRD_HEADER] 0,0, '2021-11-01', '2021-11-16', 1
*/

CREATE PROCEDURE [dbo].[PG_LI_PPMS_PRD_HEADER]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT, 
	-- ===========================
	@PP_F_INICIAL						DATE,
	@PP_F_FIN							DATE,
	@PP_SECCION_DIA						INT
AS

	-- /////////SE MUESTRA EL RESULTADO//////////////
	SELECT	@PP_F_INICIAL	AS FECHA_INICIO,
			@PP_F_FIN		AS FECHA_FINAL,
			@PP_SECCION_DIA	AS SECCION_DIA
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_PPMS_ACUMULADO_ANUAL_HEADER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_PPMS_ACUMULADO_ANUAL_HEADER]
GO

/*
 EXEC	[dbo].[PG_LI_PPMS_ACUMULADO_ANUAL_HEADER] 0,0, '2021-11-01', '2021-11-16', 1
*/

CREATE PROCEDURE [dbo].[PG_LI_PPMS_ACUMULADO_ANUAL_HEADER]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT, 
	-- ===========================
	@PP_F_INICIAL						DATE,
	@PP_F_FIN							DATE,
	@PP_SECCION_DIA						INT
AS

	-- /////////SE MUESTRA EL RESULTADO//////////////
	SELECT	@PP_F_INICIAL	AS FECHA_INICIO,
			@PP_F_FIN		AS FECHA_FINAL,
			YEAR(@PP_F_INICIAL)	AS YEAR_FECHA_INICIO,
			YEAR(@PP_F_FIN)	AS YEAR_FECHA_FINAL,
			@PP_SECCION_DIA	AS SECCION_DIA
	
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_REPORT_PPMS_PRD_X_DIA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_REPORT_PPMS_PRD_X_DIA]
GO

/*
	EXEC	[dbo].[PG_REPORT_PPMS_PRD_X_DIA] 0, 144, '2022-01-01', '2022-01-25'
*/

CREATE PROCEDURE [dbo].[PG_REPORT_PPMS_PRD_X_DIA]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_F_INICIAL				DATE,
	@PP_F_FIN					DATE
AS

	-- /////////SE CREA LA TABLA PARA LOS PPMS//////////////
	DECLARE @VP_TBL_PPMS TABLE(
		FECHA			DATE,
		TOTAL_MUESTRA	INT,
		TOTAL_DEFECTOS	INT,
		TOTAL_PPMS		INT
	)

	-- /////////SE INGRESAN LOS DATOS A LA TABLA PPMS//////////////
	INSERT INTO @VP_TBL_PPMS
	SELECT	F_LIBERACION AS FECHA, 
			SUM(MUESTRA), 
			SUM(DEFECTOS),
			( CASE WHEN SUM(MUESTRA) > 0 THEN CONVERT(INT, (CONVERT(DECIMAL(13,2), SUM(DEFECTOS)) / CONVERT(DECIMAL(13,2), SUM(MUESTRA)) * 1000000) )
				ELSE 0 END ) AS 'TOTAL_PPMS'
	FROM [PPMS_PEARL].[dbo].[ORDEN_LIBERADA] (NOLOCK)
	WHERE F_LIBERACION >= @PP_F_INICIAL
	AND F_LIBERACION <= @PP_F_FIN
	--AND DEFECTOS > 0
	AND K_TIPO_ORDEN_LIBERADA = 1 --#1 NORMAL #2 FICTICIA
	GROUP BY F_LIBERACION

	-- /////////SE CALCULAN LOS TOTALES//////////////
	SELECT	FECHA, 
			TOTAL_MUESTRA, 
			TOTAL_DEFECTOS, 
			TOTAL_PPMS,
			CONVERT(INT, (40 * TOTAL_PPMS) / 100 )		AS PPMS_1ERO,
			CONVERT(INT, (37.5 * TOTAL_PPMS) / 100 )	AS PPMS_2DO,
			CONVERT(INT, (22.5 * TOTAL_PPMS) / 100 )	AS PPMS_3ERO
	FROM @VP_TBL_PPMS
	ORDER BY FECHA
	
	-- //////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_REPORT_PPMS_PRD_X_DIA_PROCESO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_REPORT_PPMS_PRD_X_DIA_PROCESO]
GO

/*
	EXEC	[dbo].[PG_REPORT_PPMS_PRD_X_DIA_PROCESO] 0, 144, '2022-01-25', '2022-01-25'
*/

CREATE PROCEDURE [dbo].[PG_REPORT_PPMS_PRD_X_DIA_PROCESO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_F_INICIAL				DATE,
	@PP_F_FIN					DATE
AS

	-- /////////SE CREA LA TABLA PARA LOS PPMS//////////////
	DECLARE @VP_TBL_PPMS TABLE(
		PROCESO			VARCHAR(50),
		TOTAL_MUESTRA	INT,
		TOTAL_DEFECTOS	INT,
		TOTAL_PPMS		INT
	)

	-- /////////SE INGRESAN LOS DATOS A LA TABLA PPMS//////////////
	INSERT INTO @VP_TBL_PPMS
	SELECT	MESA, 
			SUM(MUESTRA), 
			SUM(DEFECTOS_MESA),
			( CASE WHEN SUM(MUESTRA) > 0 THEN CONVERT(INT, (CONVERT(DECIMAL(13,2), SUM(DEFECTOS)) / CONVERT(DECIMAL(13,2), SUM(MUESTRA)) * 1000000) )
				ELSE 0 END ) AS 'TOTAL_PPMS'
	FROM [PPMS_PEARL].[dbo].[ORDEN_LIBERADA] (NOLOCK)
	WHERE F_LIBERACION >= @PP_F_INICIAL
	AND F_LIBERACION <= @PP_F_FIN
	AND K_TIPO_ORDEN_LIBERADA = 1 --#1 NORMAL #2 FICTICIA
	GROUP BY MESA

	-- /////////SE OBTIENEN LOS DEFECTOS DE LOS PROCESOS ESPECIALES//////////////
	DECLARE @VP_DEFECTO_LAMINADO INT = 0, @VP_DEFECTO_PERFORADO INT = 0;
	DECLARE @VP_DEFECTO_QUILTY INT = 0, @VP_DEFECTO_SKIVING INT = 0;

	SELECT	@VP_DEFECTO_LAMINADO = SUM(DEFECTOS_LAMINADO),
			@VP_DEFECTO_PERFORADO = SUM(DEFECTOS_PERFORADO),
			@VP_DEFECTO_QUILTY = SUM(DEFECTOS_QUILTY),
			@VP_DEFECTO_SKIVING = SUM(DEFECTOS_SKIVING)
	FROM [PPMS_PEARL].[dbo].[ORDEN_LIBERADA] (NOLOCK)
	WHERE F_LIBERACION >= @PP_F_INICIAL
	AND F_LIBERACION <= @PP_F_FIN
	AND K_TIPO_ORDEN_LIBERADA = 1 --#1 NORMAL #2 FICTICIA

	-- /////////SE INGRESAN LOS DATOS A LA TABLA PPMS//////////////
	IF @VP_DEFECTO_LAMINADO > 0
		INSERT INTO @VP_TBL_PPMS
		SELECT	'LAMINADO', 0, @VP_DEFECTO_LAMINADO, 0

	-- /////////SE INGRESAN LOS DATOS A LA TABLA PPMS//////////////
	IF @VP_DEFECTO_PERFORADO > 0
		INSERT INTO @VP_TBL_PPMS
		SELECT	'PERFORADO', 0, @VP_DEFECTO_PERFORADO, 0

	-- /////////SE INGRESAN LOS DATOS A LA TABLA PPMS//////////////
	IF @VP_DEFECTO_QUILTY > 0
		INSERT INTO @VP_TBL_PPMS
		SELECT	'QUILTY', 0, @VP_DEFECTO_QUILTY, 0
		
	-- /////////SE INGRESAN LOS DATOS A LA TABLA PPMS//////////////
	IF @VP_DEFECTO_SKIVING > 0
		INSERT INTO @VP_TBL_PPMS
		SELECT	'SKIVING', 0, @VP_DEFECTO_SKIVING, 0
		

	-- /////////SE CREA LA TABLA PARA MOSTRAR LOS RESULTADOS//////////////
	DECLARE @VP_TBL_RESULTADO TABLE(
		ID				INT IDENTITY(1,1),
		PROCESO			VARCHAR(50),
		TOTAL_MUESTRA	INT,
		TOTAL_DEFECTOS	INT,
		TOTAL_PPMS		INT,
		PPMS_1ERO		INT,
		PPMS_2DO		INT,
		PPMS_3ERO		INT
	)

	-- /////////SE INGRESAN LOS TOTALES DE LAS MESAS A LA TABLA RESULTADO//////////////
	INSERT INTO @VP_TBL_RESULTADO
	SELECT	PROCESO, 
			TOTAL_MUESTRA, 
			TOTAL_DEFECTOS, 
			TOTAL_PPMS,
			-- ===========================
			--( CASE WHEN SUBSTRING(PROCESO, 1, 1) = 'T' THEN 
			CONVERT(INT, (40 * TOTAL_PPMS) / 100 ),
				--ELSE 0 END )	AS PPMS_1ERO,
			-- ===========================
			--( CASE WHEN SUBSTRING(PROCESO, 1, 1) = 'T' THEN 
			CONVERT(INT, (37.5 * TOTAL_PPMS) / 100 ),
				--ELSE 0 END )	AS PPMS_2DO,
			-- ===========================
			--( CASE WHEN SUBSTRING(PROCESO, 1, 1) = 'T' THEN 
			CONVERT(INT, (22.5 * TOTAL_PPMS) / 100 )
				--ELSE 0 END )	AS PPMS_3ERO
			-- ===========================
	FROM @VP_TBL_PPMS
	WHERE SUBSTRING(PROCESO, 1, 1) = 'T'
	ORDER BY PROCESO 

	-- /////////SE INGRESAN LOS TOTALES DE LOS PROCESOS ESPECIALES A LA TABLA RESULTADO//////////////
	INSERT INTO @VP_TBL_RESULTADO
	SELECT	PROCESO, 0, TOTAL_DEFECTOS, 0, 0, 0, 0
	FROM @VP_TBL_PPMS
	WHERE SUBSTRING(PROCESO, 1, 1) <> 'T'
	ORDER BY PROCESO 
	
	-- /////////SE MUESTRA EL RESULTADO//////////////
	SELECT UPPER(LTRIM(RTRIM(PROCESO))) AS PROCESO,		
		   TOTAL_MUESTRA,	
		   TOTAL_DEFECTOS,	
		   TOTAL_PPMS,		
		   PPMS_1ERO,		
		   PPMS_2DO,		
		   PPMS_3ERO		
	FROM @VP_TBL_RESULTADO
	ORDER BY ID
	-- //////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_REPORT_PPMS_PRD_X_DIA_PROCESO_ESPECIAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_REPORT_PPMS_PRD_X_DIA_PROCESO_ESPECIAL]
GO

/*
	EXEC	[dbo].[PG_REPORT_PPMS_PRD_X_DIA_PROCESO_ESPECIAL] 0, 144, '2022-01-01', '2022-01-25'
*/

CREATE PROCEDURE [dbo].[PG_REPORT_PPMS_PRD_X_DIA_PROCESO_ESPECIAL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_F_INICIAL				DATE,
	@PP_F_FIN					DATE
AS


	-- /////////SE OBTIENEN LOS DEFECTOS DE LOS PROCESOS ESPECIALES//////////////
	DECLARE @VP_DEFECTO_LAMINADO INT = 0, @VP_DEFECTO_PERFORADO INT = 0;
	DECLARE @VP_DEFECTO_QUILTY INT = 0, @VP_DEFECTO_SKIVING INT = 0;

	SELECT	@VP_DEFECTO_LAMINADO = SUM(DEFECTOS_LAMINADO),
			@VP_DEFECTO_PERFORADO = SUM(DEFECTOS_PERFORADO),
			@VP_DEFECTO_QUILTY = SUM(DEFECTOS_QUILTY),
			@VP_DEFECTO_SKIVING = SUM(DEFECTOS_SKIVING)
	FROM [PPMS_PEARL].[dbo].[ORDEN_LIBERADA] (NOLOCK)
	WHERE F_LIBERACION >= @PP_F_INICIAL
	AND F_LIBERACION <= @PP_F_FIN
	AND K_TIPO_ORDEN_LIBERADA = 1 --#1 NORMAL #2 FICTICIA

	-- /////////SE CREA LA TABLA PARA LOS PPMS//////////////
	DECLARE @VP_TBL_DEFECTOS_PROCESO_ESPECIAL TABLE(
		PROCESO_ESPECIAL	VARCHAR(50),
		DEFECTO				INT
	)

	-- /////////SE INGRESAN LOS DATOS A LA TABLA PPMS//////////////
	IF @VP_DEFECTO_LAMINADO > 0
		INSERT INTO @VP_TBL_DEFECTOS_PROCESO_ESPECIAL
			SELECT	'LAMINADO', @VP_DEFECTO_LAMINADO 	

	-- /////////SE INGRESAN LOS DATOS A LA TABLA PPMS//////////////
	IF @VP_DEFECTO_PERFORADO > 0
		INSERT INTO @VP_TBL_DEFECTOS_PROCESO_ESPECIAL
			SELECT	'PERFORADO', @VP_DEFECTO_PERFORADO
		
	-- /////////SE INGRESAN LOS DATOS A LA TABLA PPMS//////////////
	IF @VP_DEFECTO_QUILTY > 0
		INSERT INTO @VP_TBL_DEFECTOS_PROCESO_ESPECIAL
			SELECT	'QUILTY', @VP_DEFECTO_QUILTY

	-- /////////SE INGRESAN LOS DATOS A LA TABLA PPMS//////////////
	IF @VP_DEFECTO_SKIVING > 0
		INSERT INTO @VP_TBL_DEFECTOS_PROCESO_ESPECIAL
			SELECT	'SKIVING', @VP_DEFECTO_SKIVING
	
	-- /////////SE MUESTRA EL RESULTADO//////////////
	SELECT UPPER(LTRIM(RTRIM(PROCESO_ESPECIAL))) AS PROCESO_ESPECIAL,		
		   DEFECTO	
	FROM @VP_TBL_DEFECTOS_PROCESO_ESPECIAL
	ORDER BY DEFECTO DESC
	-- //////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_REPORT_PRD_DEFECTO_X_MESA_FECHA_TURNO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_REPORT_PRD_DEFECTO_X_MESA_FECHA_TURNO]
GO

/*
	EXEC	[dbo].[PG_REPORT_PRD_DEFECTO_X_MESA_FECHA_TURNO] 0, 144, '2022-01-01', '2022-01-25', 3
*/

CREATE PROCEDURE [dbo].[PG_REPORT_PRD_DEFECTO_X_MESA_FECHA_TURNO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_F_INICIAL				DATE,
	@PP_F_FIN					DATE,
	@PP_TURNO					INT
AS

	-- /////////SE INGRESAN LOS DATOS A LA TABLA PPMS//////////////
	SELECT	LTRIM(RTRIM(MESA)) AS MESA,
			( CASE WHEN TURNO = 3 THEN 3
				WHEN TURNO = 2 THEN 2
				ELSE 1 END ) AS TURNO,
			COUNT(ID) AS TOTAL_DEFECTO 
	FROM [PPMS_PEARL].DBO.Rechazos (NOLOCK)
	WHERE orden IN (	SELECT ORDEN 
						FROM [PPMS_PEARL].DBO.[ORDEN_LIBERADA]  (NOLOCK)
						WHERE  K_TIPO_ORDEN_LIBERADA = 1 --#1 NORMAL #2 FICTICIA --oRDEN = 39330 
						AND F_LIBERACION >= @PP_F_INICIAL
						AND F_LIBERACION <= @PP_F_FIN
					)
	AND ( CASE WHEN TURNO = 3 THEN 3
				WHEN TURNO = 2 THEN 2
				ELSE 1 END ) = @PP_TURNO
	AND mesa NOT IN ('Table 90', 'Table 91')
	GROUP BY MESA, ( CASE WHEN TURNO = 3 THEN 3
				WHEN TURNO = 2 THEN 2
				ELSE 1 END )
	ORDER BY COUNT(ID) DESC
	
	-- //////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_REPORT_PRD_DEFECTO_X_FECHA_TURNO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_REPORT_PRD_DEFECTO_X_FECHA_TURNO]
GO

/*
	EXEC	[dbo].[PG_REPORT_PRD_DEFECTO_X_FECHA_TURNO] 0, 144, '2022-01-01', '2022-01-25', 3
*/

CREATE PROCEDURE [dbo].[PG_REPORT_PRD_DEFECTO_X_FECHA_TURNO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_F_INICIAL				DATE,
	@PP_F_FIN					DATE,
	@PP_TURNO					INT
AS

	-- //////////////////////////////////////////////////////////////
	SELECT	LTRIM(RTRIM(DEF.defecto)) AS DEFECTO,
			( CASE WHEN TURNO = 3 THEN 3
				WHEN TURNO = 2 THEN 2
				ELSE 1 END ) AS TURNO,
			COUNT(ID) AS TOTAL_DEFECTO 
	FROM [PPMS_PEARL].DBO.Rechazos (NOLOCK)
	INNER JOIN [PPMS_PEARL].[dbo].DEF (NOLOCK) ON Rechazos.defecto = clave
	WHERE orden IN (	SELECT ORDEN 
						FROM [PPMS_PEARL].DBO.[ORDEN_LIBERADA]  (NOLOCK)
						WHERE  K_TIPO_ORDEN_LIBERADA = 1 --#1 NORMAL #2 FICTICIA --oRDEN = 39330 
						AND F_LIBERACION >= @PP_F_INICIAL
						AND F_LIBERACION <= @PP_F_FIN
					)
	AND ( CASE WHEN TURNO = 3 THEN 3
				WHEN TURNO = 2 THEN 2
				ELSE 1 END ) = @PP_TURNO
	GROUP BY DEF.defecto, ( CASE WHEN TURNO = 3 THEN 3
				WHEN TURNO = 2 THEN 2
				ELSE 1 END )
	ORDER BY COUNT(ID) DESC

	-- //////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////
-- USE [PPMS_PEARL]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_REPORT_PRD_DEFECTO_X_FECHA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_REPORT_PRD_DEFECTO_X_FECHA]
GO

/*
	EXEC	[dbo].[PG_REPORT_PRD_DEFECTO_X_FECHA] 0, 144, '2022-01-01', '2022-01-25'
*/

CREATE PROCEDURE [dbo].[PG_REPORT_PRD_DEFECTO_X_FECHA]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_F_INICIAL				DATE,
	@PP_F_FIN					DATE
AS

	-- //////////////////////////////////////////////////////////////
	SELECT	LTRIM(RTRIM(DEF.defecto)) AS DEFECTO,
			COUNT(ID) AS TOTAL_DEFECTO 
	FROM [PPMS_PEARL].DBO.Rechazos (NOLOCK)
	INNER JOIN [PPMS_PEARL].[dbo].DEF (NOLOCK) ON Rechazos.defecto = clave
	WHERE orden IN (	SELECT ORDEN 
						FROM [PPMS_PEARL].DBO.[ORDEN_LIBERADA]  (NOLOCK)
						WHERE  K_TIPO_ORDEN_LIBERADA = 1 --#1 NORMAL #2 FICTICIA --oRDEN = 39330 
						AND F_LIBERACION >= @PP_F_INICIAL
						AND F_LIBERACION <= @PP_F_FIN
					)
	GROUP BY DEF.defecto
	ORDER BY COUNT(ID) DESC

	-- //////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////