-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		PPMS_PEARL
-- // MODULE:			CERTIFICACIÓN_VISUAL_ADICIONALES
-- // OPERATION:		SP'S
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20220421
-- ////////////////////////////////////////////////////////////// 

USE	[PPMS_PEARL]
GO

-- //////////////////////////////////////////////////////////////
-- //////		CONTENIDO DEL SP
--	[PG_LI_CARGAR_ORDENES]
--	[PG_LI_CARGAR_ORDENES_PENDIENTES_LIBERAR]
-- //////////////////////////////////////////////////////////////


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> PARA CARGAR LAS ORDENES
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_CARGAR_ORDENES]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_CARGAR_ORDENES]
GO
--		 EXECUTE [dbo].[PG_LI_CARGAR_ORDENES] 0,139
CREATE PROCEDURE [dbo].[PG_LI_CARGAR_ORDENES]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT
	-- ===========================
AS

	SELECT	DISTINCT	PERFORACION.ORDEN,	RECHAZOS.NOSERIE,	PERFORACION.NOPARTE, SEARCH_DESC 
	FROM	PERFORACION,	RECHAZOS, DATA_02.DBO.IMITMIDX_SQL 
	WHERE	PERFORACION.NOPARTE	= IMITMIDX_SQL.LANDED_COST_CD 
	AND		RECHAZOS.NOSERIE	= CONVERT(INT,PERFORACION.NOSERIE) 
	AND		(PERFORACION.STATUS	<>'FINALIZADO'  
	AND		PERFORACION.STATUS<>'INSPECCION') 
	AND		PERFORACION.NOPARTE<>'' 
	ORDER	BY PERFORACION.ORDEN

 --	//////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> PARA CARGAR LAS ORDENES
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_CARGAR_ORDENES_PENDIENTES_LIBERAR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_CARGAR_ORDENES_PENDIENTES_LIBERAR]
GO
--		 EXECUTE [dbo].[PG_LI_CARGAR_ORDENES_PENDIENTES_LIBERAR] 0,139
CREATE PROCEDURE [dbo].[PG_LI_CARGAR_ORDENES_PENDIENTES_LIBERAR]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT
	-- ===========================
AS

--DECLARE		@VP_MENSAJE				NVARCHAR(MAX) = ''
--BEGIN TRANSACTION 
--BEGIN TRY

DECLARE	@PP_TABLE AS TABLE 
(	TA_ORDEN		NVARCHAR(MAX),
	TA_FECHA		NVARCHAR(MAX),
	TA_HORA			NVARCHAR(MAX),
	TA_INSPECTOR	NVARCHAR(MAX),
	TA_MESA			NVARCHAR(MAX),
	TA_SERIE		NVARCHAR(MAX),
	TA_ESTADO		INT	)
--	/////////////////////////////////////////////////////////////
DECLARE	 @VP_CU_ORDEN			NVARCHAR(MAX)
		,@VP_CU_FECHA			NVARCHAR(MAX)
		,@VP_CU_HORA			NVARCHAR(MAX)
		,@VP_CU_INSPECTOR		NVARCHAR(MAX)
		,@VP_CU_MESA			NVARCHAR(MAX)
		,@VP_CU_SERIE			NVARCHAR(MAX)

	DECLARE CU_CURSOR	CURSOR LOCAL STATIC READ_ONLY FORWARD_ONLY FOR
		SELECT	ORDEN,				
				--FECHA,
				CONVERT(varchar(10),		CONVERT(DATETIME,CONVERT(VARCHAR(10),FECHA)),103)	,--AS FECHA_DDMMYYYY,
				--HORA_ESCANEO AS HORA_ESCANEO_INT,
				CONCAT(
						( CASE
							WHEN	LEN(LTRIM(RTRIM(HORA_ESCANEO))) = 5 THEN	LEFT(LTRIM(RTRIM(HORA_ESCANEO)),1)
							ELSE	LEFT(LTRIM(RTRIM(HORA_ESCANEO)),2)
						END), ':',
						LEFT(RIGHT(LTRIM(RTRIM(HORA_ESCANEO)),4),2)
						)	,--AS HORA_ESCANEO,
				--RIGHT(LTRIM(RTRIM(HORA_ESCANEO)),2),
				INSPECTOR_CAL,	
				MACHINE	AS MESA,	NOSERIE  
		FROM	PENDIENTE_LIBERAR			(NOLOCK),	
				DATA_02.DBO.CCJOBHDR_SQL	(NOLOCK),	
				PERSONAL					(NOLOCK)
		WHERE	ORDEN					=	JOBNO 
		AND		PENDIENTE_LIBERAR.SELLO =	PERSONAL.SELLO 
		ORDER	BY ORDEN
	OPEN CU_CURSOR
		FETCH NEXT FROM  CU_CURSOR INTO	 @VP_CU_ORDEN		,@VP_CU_FECHA		,@VP_CU_HORA		
										,@VP_CU_INSPECTOR	,@VP_CU_MESA		,@VP_CU_SERIE
		WHILE @@FETCH_STATUS=0					
		BEGIN
		DECLARE	@VP_ESTADO AS INTEGER	= 0
		-- ====================================================================================
		--	VERIFICAR SI PASO POR LIBERACION FINAL
		IF	(	SELECT	COUNT(ID)
				FROM	DATA_02.DBO.QCLIBERA_SQL	(NOLOCK) 
				WHERE	SERIAL	=	@VP_CU_SERIE	) > 0
		BEGIN
			SET @VP_ESTADO	= 1
			GOTO INSERTAR_REGISTRO
		END
		-- ====================================================================================
		--	VERIFICAR SI PASO POR CERTIFICACION
		IF	(	SELECT	COUNT(ID)
				FROM	CERTIFICACION_RPT 			(NOLOCK)
				--WHERE	LTRIM(RTRIM(NOSERIE_CAJA))	=	@VP_CU_SERIE	) > 0
				WHERE	NOSERIE_CAJA	=	@VP_CU_SERIE	) > 0
		BEGIN
			SET @VP_ESTADO	= 2
			GOTO INSERTAR_REGISTRO
		END
		
		DECLARE	@VP_STATUS_PERFO	INT = 0
		-- ====================================================================================
		--	VERIFICAR SI PASO POR PERFORACION
		SELECT	@VP_STATUS_PERFO			= ISNULL(	(	CASE
																WHEN	[STATUS]	= 'FINALIZADO'	THEN	3
																WHEN	[STATUS]	= 'PROCESO'		THEN	4
																WHEN	[STATUS]	= 'ESPERA'		THEN	4
																WHEN	[STATUS]	= 'RECHAZADO'	THEN	5
																WHEN	[STATUS]	= 'INSPECCION'	THEN	6
														END ), 0)
		FROM	PERFORACION			(NOLOCK)
		--WHERE	LTRIM(RTRIM(NOSERIE))		=	@VP_CU_SERIE
		WHERE	NOSERIE		=	@VP_CU_SERIE

		IF @VP_STATUS_PERFO <> 0
		BEGIN
			SET	@VP_ESTADO	= @VP_STATUS_PERFO
			GOTO INSERTAR_REGISTRO
		END
		-- ====================================================================================
		IF	(	SELECT	COUNT(DESCRIPCION)
				FROM	ENGOMADO 	(NOLOCK)
				--WHERE	LTRIM(RTRIM(NOSERIE))	=	@VP_CU_SERIE	) > 0
				WHERE	NOSERIE	=	@VP_CU_SERIE	) > 0
		BEGIN
			SET @VP_ESTADO	= 2
			GOTO INSERTAR_REGISTRO
		END

INSERTAR_REGISTRO:
		INSERT INTO	@PP_TABLE
		(	TA_ORDEN		,TA_FECHA		,TA_HORA		,TA_INSPECTOR		,TA_MESA		,TA_SERIE		,TA_ESTADO	)
		VALUES
		(	@VP_CU_ORDEN	,@VP_CU_FECHA	,@VP_CU_HORA	,@VP_CU_INSPECTOR	,@VP_CU_MESA	,@VP_CU_SERIE	,@VP_ESTADO )


		FETCH NEXT FROM  CU_CURSOR INTO	 @VP_CU_ORDEN		,@VP_CU_FECHA		,@VP_CU_HORA		
										,@VP_CU_INSPECTOR	,@VP_CU_MESA		,@VP_CU_SERIE
	END
	CLOSE		CU_CURSOR
	DEALLOCATE	CU_CURSOR


--COMMIT TRANSACTION 
--END TRY

--BEGIN CATCH
--	ROLLBACK TRANSACTION
--	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
--	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
--	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
--END CATCH	

--	-- /////////////////////////////////////////////////////////////////////	
--	IF @VP_MENSAJE<>''
--	BEGIN
--		SET		@VP_MENSAJE = 'No es posible [COPIAR]: ' + @VP_MENSAJE 
--	END

--	SELECT	@VP_MENSAJE AS MENSAJE
	SELECT	TA_ORDEN			AS ORDEN			,
			TA_FECHA			AS FECHA_DDMMYYYY	,
			TA_HORA				AS HORA_ESCANEO		,
			TA_INSPECTOR		AS INSPECTOR_CAL	,
			TA_MESA				AS MESA				,
			TA_SERIE			AS NOSERIE			,
			TA_ESTADO			AS ESTADO
	FROM	@PP_TABLE
	ORDER	BY ORDEN	DESC
	-- /////////////////////////////////////////////////////////////////////
GO

 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_ORDEN_PENDIENTE_X_LIBERAR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_ORDEN_PENDIENTE_X_LIBERAR]
GO
--		 EXECUTE [dbo].[PG_SK_ORDEN_PENDIENTE_X_LIBERAR] 0,139
CREATE PROCEDURE [dbo].[PG_SK_ORDEN_PENDIENTE_X_LIBERAR]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT
	-- ===========================
AS
	SELECT	COUNT(ORDEN)	AS CANTIDAD 
	FROM	PENDIENTE_LIBERAR
 --	//////////////////////////////////////////////////////////////
GO

 --	//////////////////////////////////////////////////////////////
 --	//////////////////////////////////////////////////////////////
 --	//////////////////////////////////////////////////////////////


 