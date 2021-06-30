-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			ORDEN
-- // OPERATION:		SP'S
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210625
-- ////////////////////////////////////////////////////////////// 

USE	[DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- //////		CONTENIDO DEL SP
--	[PG_LI_DETALLE_ORDEN]
-- //////////////////////////////////////////////////////////////


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_DETALLE_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_DETALLE_ORDEN]
GO
--		 EXECUTE [dbo].[PG_LI_DETALLE_ORDEN] 34140
--		 EXECUTE [dbo].[PG_LI_DETALLE_ORDEN] 32629
CREATE PROCEDURE [dbo].[PG_LI_DETALLE_ORDEN]
	@PP_JOBNO						VARCHAR(15)
AS
	-- /////////////////////////////////////////////////////////////////////
	SELECT DISTINCT TOP (100) PERCENT 
			dbo.ccjoblin_sql.jobno, 
			dbo.ccjoblin_sql.Kit, 
			dbo.ccjoblin_sql.KitDesc, 
			dbo.cccusitm_sql.item_no, 
			dbo.ccjoblin_sql.PlannedQty, 
			dbo.ccjoblin_sql.CompletedQty,
			dbo.ccjoblin_sql.OriginalQty, 
			dbo.ccjoblin_sql.netsqmper, 
			dbo.ccjoblin_sql.stdsqmper, 
			dbo.ccjoblin_sql.customer,
			dbo.ccjoblin_sql.ChangeLevel,
			dbo.ccjoblin_sql.User_def_Fld1,
			dbo.ccjoblin_sql.Ser_No,
			dbo.cccusitm_sql.cus_item_no, 
	        dbo.ccverhdr_sql.versionno 
			--{ fn CONCAT('F', RIGHT(LTRIM(RTRIM(dbo.cccusitm_sql.item_no)), 6)) } AS COLOR, 
			--dbo.ccverhdr_sql.cus_no AS Customer, 
			--dbo.ccverhdr_sql.modelno
	FROM    dbo.ccverhdr_sql 
	INNER JOIN		dbo.cccusitm_sql ON { fn CONCAT(dbo.ccverhdr_sql.modelno, dbo.ccverhdr_sql.versionno) } = { fn CONCAT(dbo.cccusitm_sql.modelno, dbo.cccusitm_sql.versionno) } 
			AND		SUBSTRING(LTRIM(RTRIM(dbo.cccusitm_sql.item_no)),1, 1) IN ('P','I')
			AND		dbo.cccusitm_sql.cus_item_no <> '' 
	INNER JOIN		dbo.IMITMIDX_SQL ON dbo.IMITMIDX_SQL.item_no = dbo.cccusitm_sql.item_no 
	INNER JOIN		dbo.IMCATFIL_SQL ON dbo.IMITMIDX_SQL.prod_cat = dbo.IMCATFIL_SQL.prod_cat 
			AND		dbo.IMCATFIL_SQL.L_BORRADO = 0
	INNER JOIN		dbo.ccjoblin_sql ON dbo.ccjoblin_sql.Item_No	= dbo.cccusitm_sql.item_no
	WHERE			(dbo.ccverhdr_sql.specstatus = 'U') 
	AND				(dbo.ccverhdr_sql.status = 'L')
	---AND				dbo.ccjoblin_sql.jobno	= @PP_JOBNO
	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////