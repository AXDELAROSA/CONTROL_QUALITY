-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			QC RECHAZOS
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	16/AGO/2021
-- //////////////////////////////////////////////////////////////  

USE [PPMS_PEARL]
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_PERFORACION_RECHAZO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_PERFORACION_RECHAZO]
GO

/*
 EXEC	[dbo].[PG_LI_PERFORACION_RECHAZO] 0,144,  '' , '( TODOS )', '2021-08-27', '2021-08-28'
 EXEC	[dbo].[PG_LI_PERFORACION_RECHAZO] 0,144,   '', 'WD2', '2021-08-27', '2021-08-27'
*/

CREATE PROCEDURE [dbo].[PG_LI_PERFORACION_RECHAZO]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_BUSCAR							VARCHAR(200),
	-- ===========================
	@PP_PROD_CAT						VARCHAR(50),
	@PP_F_INICIO						DATE,
	@PP_F_FIN							DATE
AS

	-- ///////////////////////////////////////////
	SELECT	Trans_perfo.noserie				AS SERIAL,
			orden					AS ORDEN,
			noparte					AS CUS_PART_NO,
			SUBSTRING(etiqueta, CHARINDEX('#', etiqueta) + 1, 3) AS PROD_CAT, 
			-- =============================
			Trans_perfo.estacion	AS ESTACION,
			etiqueta				AS ETIQUETA,
			-- =============================
			[DATA_02].[dbo].[CONVERT_INT_TO_DATE](Trans_perfo.fecha)	AS FECHA,
			CONVERT(VARCHAR(8),[DATA_02].[dbo].[CONVERT_INT_TO_TIME](Trans_perfo.hora))		AS HORA
			-- =============================
	FROM Trans_perfo 
	INNER JOIN Perforacion on Trans_perfo.noserie = Perforacion.noserie 
	-- =============================
	WHERE [DATA_02].[dbo].[CONVERT_INT_TO_DATE](Trans_perfo.fecha) >= @PP_F_INICIO
	AND [DATA_02].[dbo].[CONVERT_INT_TO_DATE](Trans_perfo.fecha) <= @PP_F_FIN
	AND SUBSTRING(etiqueta, CHARINDEX('#', etiqueta) + 1, 3) = ( CASE WHEN @PP_PROD_CAT = '( TODOS )' THEN  SUBSTRING(etiqueta, CHARINDEX('#', etiqueta) + 1, 3)
																	ELSE @PP_PROD_CAT END )
	AND ( Trans_perfo.noserie					LIKE '%'+@PP_BUSCAR+'%'
			OR	Trans_perfo.estacion			LIKE '%'+@PP_BUSCAR+'%'
			OR	noparte						LIKE '%'+@PP_BUSCAR+'%' )
	AND Trans_perfo.transaccion = 'rechazar'  
	-- =============================
	ORDER BY Trans_perfo.fecha, Trans_perfo.hora DESC
		
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
