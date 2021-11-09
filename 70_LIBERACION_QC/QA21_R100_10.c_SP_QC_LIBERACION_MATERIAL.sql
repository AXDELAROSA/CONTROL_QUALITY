-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			QC LIBERACION
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	8/NOV/2021
-- //////////////////////////////////////////////////////////////  

USE [DATA_02]
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_QC_LIBERACION_MATERIAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_QC_LIBERACION_MATERIAL]
GO

/*
 EXEC	[dbo].[PG_LI_QC_LIBERACION_MATERIAL] 0,144,  '2021/11/01' , '2021/11/08' , 'IRVi02' , '( TODOS )' , -1 
 EXEC	[dbo].[PG_LI_QC_LIBERACION_MATERIAL] 0,144, '2021-11-01', '2021-11-02', 'FAUR01', 'FW2', 0
*/

CREATE PROCEDURE [dbo].[PG_LI_QC_LIBERACION_MATERIAL]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_F_INICIO						DATE,
	@PP_F_FIN							DATE,
	@PP_CLIENTE							VARCHAR(100),
	@PP_PROD_CAT						VARCHAR(100),
	@PP_TURNO							INT
AS

	-- ////SE CREA TABLA TEMPORAL PARA GUARDAR LA INFORMACION FINAL///////////////////////////////////////
	DECLARE @TBL_LIBERACION_QC	AS TABLE
	(	SERIAL			VARCHAR(50),
		CUSTOMER		VARCHAR(100),
		PROD_CAT		VARCHAR(50),
		D_PROD_CAT		VARCHAR(50),
		ITEM_NO			VARCHAR(50),
		CUS_ITEM_NO		VARCHAR(50),
		CANTIDAD		INT,
		TURNO			INT,
		N_RELOJ			INT,
		FECHA			DATE,
		HORA			INT
	)

	-- ////SE INGRESAN LOS DATOS A LA TABLA TEMPORAL///////////////////////////////////////
	INSERT INTO @TBL_LIBERACION_QC
	SELECT	SERIAL,
			LTRIM(RTRIM(ccjoblin_sql.CUSTOMER)),
			LTRIM(RTRIM(prod_cat)), 
			LTRIM(RTRIM(PROD_CAT_DESC)),
			LTRIM(RTRIM(ccjoblin_sql.item_no)),
			LTRIM(RTRIM(cccusitm_sql.cus_item_no)),			
			ccjoblin_sql.originalqty, 
			(CASE	WHEN CTIME > 2000 AND CTIME < 60002 THEN 3
					WHEN CTIME > 60001 AND CTIME < 153001 THEN 1
					ELSE 2 END ) TURNO,
			INSPECTOR,
			CONVERT(DATE, CDATE), 			
			CTIME
			-- ===========================
	FROM QCLIBERA_SQL (NOLOCK) 
	-- ===========================
	INNER JOIN ccjoblin_sql (NOLOCK) ON LTRIM(RTRIM(jobno)) + RIGHT('000'+ CONVERT(VARCHAR(5), ser_no), 3) =  SERIAL
	-- ===========================
	INNER JOIN	cccusitm_sql ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
		AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
		AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
											FROM	cccusitm_sql (NOLOCK)
											WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
											AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)
	-- ===========================
	INNER JOIN IMCATFIL_SQL (NOLOCK) ON LTRIM(RTRIM(prod_cat)) = SUBSTRING(LTRIM(RTRIM(ChangeLevel)), 1, 3)
	WHERE CONVERT(DATE, CDATE) >= @PP_F_INICIO
	AND CONVERT(DATE, CDATE) <= @PP_F_FIN
	AND CUSTOMER = (CASE WHEN @PP_CLIENTE = '( TODOS )' THEN CUSTOMER
							ELSE @PP_CLIENTE END ) 
	AND PROD_CAT = (CASE WHEN @PP_PROD_CAT = '( TODOS )' THEN PROD_CAT
							ELSE @PP_PROD_CAT END ) 

	-- ////SE MUESTRA EL RESULTADO FINAL///////////////////////////////////////
	SELECT DISTINCT SERIAL,
		   CUSTOMER,	
		   PROD_CAT,	
		   D_PROD_CAT,	
		   ITEM_NO,		
		   CUS_ITEM_NO,	
		   CANTIDAD,
		   TURNO,
		   N_RELOJ,		
		   FECHA
		   --HORA	
	FROM @TBL_LIBERACION_QC 
	WHERE TURNO = (CASE WHEN @PP_TURNO = -1 THEN TURNO
							ELSE @PP_TURNO END ) 
	ORDER BY FECHA, TURNO, CUSTOMER, PROD_CAT, ITEM_NO

	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
