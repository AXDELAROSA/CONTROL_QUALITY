-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			EMBARQUES
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	16/11/2020
-- //////////////////////////////////////////////////////////////  

USE [DATA_02] 
GO


--	USE [DATA_02]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_ORDEN_FACTURACION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_ORDEN_FACTURACION]
GO
/*

 EXECUTE   [dbo].[PG_GET_ORDEN_FACTURACION] 0,0,  ''
*/
CREATE PROCEDURE [dbo].[PG_GET_ORDEN_FACTURACION]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_CLIENTE					VARCHAR(100)
AS
	-- ///////////////////////////////////////////
	SELECT DISTINCT LTRIM(RTRIM(OEORDLIN_SQL.Cus_No)) AS CLIENTE, 
					LTRIM(RTRIM(OEORDHDR_SQL.Ord_No)) AS ORDEN_FACTURACION
    FROM OEORDLIN_SQL INNER JOIN OEORDHDR_SQL ON OEORDLIN_SQL.ord_type = OEORDHDR_SQL.ord_type  
		AND OEORDLIN_SQL.ord_no = OEORDHDR_SQL.ord_no   
    LEFT OUTER JOIN ccitmidx_sql ON OEORDLIN_SQL.item_no = ccitmidx_sql.item_no 
		AND OEORDLIN_SQL.user_def_fld_1 = ccitmidx_sql.modver  
    LEFT OUTER JOIN ccitmidx_hst ON  OEORDLIN_SQL.item_no = ccitmidx_hst.item_no 
		AND OEORDLIN_SQL.user_def_fld_1 = ccitmidx_hst.modver
    LEFT OUTER JOIN IMITMIDX_SQL ON OEORDLIN_SQL.item_no = IMITMIDX_SQL.item_no 
    WHERE OEORDLIN_SQL.Loc = 'MFP'  
    AND OEORDHDR_SQL.Status <> 'L'   
    AND OEORDHDR_SQL.ord_type = 'O'  
    AND (OEORDLIN_SQL.Item_No LIKE 'I%' or 
    OEORDLIN_SQL.Item_No LIKE 'P%' or   
    OEORDLIN_SQL.Item_No LIKE 'U%')
	AND OEORDLIN_SQL.Cus_No = ( CASE WHEN @PP_CLIENTE <> '' THEN @PP_CLIENTE
									ELSE OEORDLIN_SQL.Cus_No END )
	ORDER BY CLIENTE, ORDEN_FACTURACION DESC
      
	-- ////////////////////////////////////////////////////////////////////
GO



--	USE [DATA_02]
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_PACKING_NO_EMBARQUE_PDF]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_PACKING_NO_EMBARQUE_PDF]
GO
/*
-- 'CHRYSLER RU AL' 
-- '2015 WK KL'     
-- '2019 JEEP JT'
-- 'WPI WD'         
-- 'YANGFENG'      
-- 'RU PINNACLE DL'

 EXECUTE   [dbo].[PG_GET_PACKING_NO_EMBARQUE_PDF] 0,0,  'XXXXXXXXXX', '2018 JEEP JL'
*/
CREATE PROCEDURE [dbo].[PG_GET_PACKING_NO_EMBARQUE_PDF]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_PACKING_NO				VARCHAR(50),
	@PP_PROGRAMA_DESCRIPCION	VARCHAR(50)
AS
	-- ///////////////////////////////////////////
	DECLARE @VP_PROGRAMA		VARCHAR(150)	= ''
	DECLARE @VP_F_PACKING		VARCHAR(150)	= CONVERT(VARCHAR(10),GETDATE(), 101)

	IF @PP_PACKING_NO = 'XXXXXXXXXX'
		BEGIN
			-- /////////////SE OBTIENE EL PRODUCT CATEGORY //////////////////////////////
			IF @PP_PROGRAMA_DESCRIPCION = 'ARMREST'
				BEGIN
					SET @VP_PROGRAMA = 'WK'
				END
			ELSE
				BEGIN
					SELECT @VP_PROGRAMA = LTRIM(RTRIM(filler_0001)) 
					FROM imcatfil_sql WHERE
					LTRIM(RTRIM(prod_cat_desc)) = @PP_PROGRAMA_DESCRIPCION
				END

			IF @VP_PROGRAMA IS NULL OR @VP_PROGRAMA = ''
				SET @PP_PACKING_NO = 'N/A'
			ELSE
				SET @PP_PACKING_NO = @VP_PROGRAMA
		END
	ELSE
		BEGIN
			SELECT TOP 1 @VP_F_PACKING = CONVERT(VARCHAR(10), F_INVENTARIO_EMBARQUE, 101) 
			FROM INVENTARIO_EMBARQUE 
			WHERE PACKING_NO = @PP_PACKING_NO
		END
	
	-- ///////////////////////////////////////////
	SELECT @PP_PACKING_NO AS PACKING_NO, @VP_F_PACKING AS F_PACKING
	-- ///////////////////////////////////////////

      
	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_DATOS_CLIENTE_PACKING]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_DATOS_CLIENTE_PACKING]
GO

/*
 EXEC [PG_GET_DATOS_CLIENTE_PACKING] 0 ,0, 'MAGN03' --'MAGN01'
*/

CREATE PROCEDURE [dbo].[PG_GET_DATOS_CLIENTE_PACKING]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_CLIENTE					VARCHAR(100)
AS

	-- ///////////////////////////////////////////

	SELECT	TOP 1	
			LTRIM(RTRIM(cus_no)) AS cus_no,
			LTRIM(RTRIM(bill_to_name)) AS bill_to_name,
			LTRIM(RTRIM(bill_to_addr_1)) AS bill_to_addr_1,
			LTRIM(RTRIM(bill_to_addr_2)) AS bill_to_addr_2,
			ISNULL(LTRIM(RTRIM(bill_to_addr_3)), '') AS bill_to_addr_3,
			RTRIM((bill_to_country)) AS bill_to_country,
			RTRIM((ship_to_name)) AS ship_to_name,
			RTRIM((ship_to_addr_1)) AS ship_to_addr_1,
			RTRIM((ship_to_addr_2)) AS ship_to_addr_2,
			ISNULL(LTRIM(RTRIM(ship_to_addr_3)), '') AS ship_to_addr_3,
			LTRIM(RTRIM(ship_to_country)) AS  ship_to_country
	FROM OEHDRHST_SQL 
	WHERE LTRIM(RTRIM(cus_no)) = @PP_CLIENTE 
	ORDER BY A4GLIdentity DESC

	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO






---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> SELECT / SE USA EN EL REPORTE RPT_PACKING_V2
---- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_DETALLE_PACKING_V2]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_DETALLE_PACKING_V2]
GO

/*
 EXEC [PG_GET_DETALLE_PACKING_V2] 0 ,0,  '238/243/245' , 'XXXXXXXXXX'
*/

CREATE PROCEDURE [dbo].[PG_GET_DETALLE_PACKING_V2]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_INVENTARIO_EMBARQUE_ARRAY	NVARCHAR(MAX),
	@PP_PACKING_NO				VARCHAR(50)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- /////////SE OBTIENE DE LOS ARRAY EL LOTE Y PIEL INGRESADOS///////////////////////////////////////////////////////////	
	DECLARE @TBL_MATERIAL_SELECCIONADO  TABLE (
			K_MATERIAL_SELECCIONADO		INT IDENTITY(1,1),
			K_INVENTARIO_EMBARQUE		INT
		)
	SET NOCOUNT ON
	
	IF @PP_PACKING_NO = 'XXXXXXXXXX'
		BEGIN
			DECLARE @VP_POSICION_K_INVENTARIO_EMBARQUE	INT
			DECLARE @VP_K_INVENTARIO_EMBARQUE_VALOR		VARCHAR(20)
							
			--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
			SET	@PP_K_INVENTARIO_EMBARQUE_ARRAY	= @PP_K_INVENTARIO_EMBARQUE_ARRAY		+ '/'		
			
			--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
			WHILE patindex('%/%' , @PP_K_INVENTARIO_EMBARQUE_ARRAY) <> 0
				BEGIN
					SELECT @VP_POSICION_K_INVENTARIO_EMBARQUE	=	patindex('%/%' , @PP_K_INVENTARIO_EMBARQUE_ARRAY)
					
					--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
					SELECT @VP_K_INVENTARIO_EMBARQUE_VALOR	= LEFT(@PP_K_INVENTARIO_EMBARQUE_ARRAY, @VP_POSICION_K_INVENTARIO_EMBARQUE - 1)

					-- /////////INSERTAMOS LA PIEL EN UNA TABLA TEMPORAL////////////////////////////////////////////////////////////
					INSERT	INTO	@TBL_MATERIAL_SELECCIONADO
							VALUES	( @VP_K_INVENTARIO_EMBARQUE_VALOR )

					--Reemplazamos lo procesado con nada con la funcion stuff
					SELECT @PP_K_INVENTARIO_EMBARQUE_ARRAY	= STUFF(@PP_K_INVENTARIO_EMBARQUE_ARRAY, 1, @VP_POSICION_K_INVENTARIO_EMBARQUE, '')

				END
		END
	ELSE
		BEGIN
			INSERT	INTO	@TBL_MATERIAL_SELECCIONADO
				SELECT K_INVENTARIO_EMBARQUE
				FROM INVENTARIO_EMBARQUE
				WHERE PACKING_NO = @PP_PACKING_NO
				ORDER BY PROD_CAT
		END

	DECLARE @TBL_DETALLE_PACKING  TABLE (
			K_DETALLE_PACKING			INT IDENTITY(1,1),
			CUS_PART_NO					VARCHAR(100),
			D_ITEM_NO					VARCHAR(150),
			PROD_CAT					VARCHAR(100),
			QTY_SHIP					INT,
			BOX							INT,
			SQFT						DECIMAL(13,2)
		)
	SET NOCOUNT ON

	INSERT INTO @TBL_DETALLE_PACKING
	SELECT	CUS_PART_NO,
			(	SELECT TOP 1 LTRIM(RTRIM(item_desc_1)) FROM IMITMIDX_SQL
				INNER JOIN  INVENTARIO_EMBARQUE INV_EMB ON LTRIM(RTRIM(IMITMIDX_SQL.item_no)) = INV_EMB.ITEM_NO
				WHERE  INV_EMB.K_INVENTARIO_EMBARQUE IN ( SELECT K_INVENTARIO_EMBARQUE FROM  @TBL_MATERIAL_SELECCIONADO)
				AND INV_EMB.CUS_PART_NO = INVENTARIO_EMBARQUE.CUS_PART_NO),
			--LTRIM(RTRIM(item_desc_1)),
			INVENTARIO_EMBARQUE.PROD_CAT,
			SUM(QTY) AS QTY_SHIP, 
			COUNT(CUS_PART_NO) AS BOX, 
			(SUM(QTY) * MAX(INVENTARIO_EMBARQUE.CUBE_WIDTH)) AS SQFT 
	FROM INVENTARIO_EMBARQUE
	--INNER JOIN PART_NO_VIEW ON cus_item_no = CUS_PART_NO 
	--INNER JOIN IMITMIDX_SQL ON IMITMIDX_SQL.item_no = PART_NO_VIEW.item_no
	WHERE K_INVENTARIO_EMBARQUE IN ( SELECT K_INVENTARIO_EMBARQUE FROM  @TBL_MATERIAL_SELECCIONADO	)
	GROUP BY INVENTARIO_EMBARQUE.PROD_CAT, CUS_PART_NO --,  --LTRIM(RTRIM(item_desc_1)) --, ITEM_NO
	ORDER BY   PROD_CAT, CUS_PART_NO

	INSERT INTO @TBL_DETALLE_PACKING
	SELECT	'  ', 'Totals:', '',
			SUM(QTY_SHIP) AS QTY_SHIP, 
			SUM(BOX) AS BOX, 
			SUM(SQFT) AS SQFT 
	FROM @TBL_DETALLE_PACKING

	SELECT	K_DETALLE_PACKING,	
			CUS_PART_NO,		
			D_ITEM_NO,
			CONVERT(VARCHAR(20), QTY_SHIP) AS QTY_SHIP,		
		    CONVERT(VARCHAR(20), BOX ) AS BOX,					
			CONVERT(VARCHAR(20), SQFT) AS SQFT,				
			CASE WHEN D_ITEM_NO = 'Totals:' THEN ' '
				ELSE CONVERT(VARCHAR(10),K_DETALLE_PACKING) END AS ID_DETALLE
	FROM @TBL_DETALLE_PACKING AS DETALLE_PACKING
	ORDER BY K_DETALLE_PACKING
	--////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO





---- //////////////////////////////////////////////////////////////
---- // STORED PROCEDURE ---> SELECT / SE USABA EN EL REPORTE RPT_PACKING
---- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_DETALLE_PACKING]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_DETALLE_PACKING]
GO

/*
 EXEC [PG_GET_DETALLE_PACKING] 0 ,0,  '238/243/245' , 'XXXXXXXXXX'
*/

CREATE PROCEDURE [dbo].[PG_GET_DETALLE_PACKING]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_INVENTARIO_EMBARQUE_ARRAY	NVARCHAR(MAX),
	@PP_PACKING_NO				VARCHAR(50)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- /////////SE OBTIENE DE LOS ARRAY EL LOTE Y PIEL INGRESADOS///////////////////////////////////////////////////////////	
	DECLARE @TBL_MATERIAL_SELECCIONADO  TABLE (
			K_MATERIAL_SELECCIONADO		INT IDENTITY(1,1),
			K_INVENTARIO_EMBARQUE		INT
		)
	SET NOCOUNT ON
	
	IF @PP_PACKING_NO = 'XXXXXXXXXX'
		BEGIN
			DECLARE @VP_POSICION_K_INVENTARIO_EMBARQUE	INT
			DECLARE @VP_K_INVENTARIO_EMBARQUE_VALOR		VARCHAR(20)
							
			--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
			SET	@PP_K_INVENTARIO_EMBARQUE_ARRAY	= @PP_K_INVENTARIO_EMBARQUE_ARRAY		+ '/'		
			
			--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
			WHILE patindex('%/%' , @PP_K_INVENTARIO_EMBARQUE_ARRAY) <> 0
				BEGIN
					SELECT @VP_POSICION_K_INVENTARIO_EMBARQUE	=	patindex('%/%' , @PP_K_INVENTARIO_EMBARQUE_ARRAY)
					
					--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
					SELECT @VP_K_INVENTARIO_EMBARQUE_VALOR	= LEFT(@PP_K_INVENTARIO_EMBARQUE_ARRAY, @VP_POSICION_K_INVENTARIO_EMBARQUE - 1)

					-- /////////INSERTAMOS LA PIEL EN UNA TABLA TEMPORAL////////////////////////////////////////////////////////////
					INSERT	INTO	@TBL_MATERIAL_SELECCIONADO
							VALUES	( @VP_K_INVENTARIO_EMBARQUE_VALOR )

					--Reemplazamos lo procesado con nada con la funcion stuff
					SELECT @PP_K_INVENTARIO_EMBARQUE_ARRAY	= STUFF(@PP_K_INVENTARIO_EMBARQUE_ARRAY, 1, @VP_POSICION_K_INVENTARIO_EMBARQUE, '')

				END
		END
	ELSE
		BEGIN
			INSERT	INTO	@TBL_MATERIAL_SELECCIONADO
				SELECT K_INVENTARIO_EMBARQUE
				FROM INVENTARIO_EMBARQUE
				WHERE PACKING_NO = @PP_PACKING_NO
		END

	DECLARE @TBL_DETALLE_PACKING  TABLE (
			K_DETALLE_PACKING			INT IDENTITY(1,1),
			CUS_PART_NO					VARCHAR(100),
			ITEM_NO						VARCHAR(100),
			QTY_SHIP					INT,
			BOX							INT,
			SQFT						DECIMAL(13,5)
		)
	SET NOCOUNT ON

	INSERT INTO @TBL_DETALLE_PACKING
	SELECT	CUS_PART_NO, 
			ITEM_NO,
			SUM(QTY) AS QTY_SHIP, 
			COUNT(CUS_PART_NO) AS BOX, 
			(SUM(QTY) * MAX(CUBE_WIDTH)) AS SQFT 
	FROM INVENTARIO_EMBARQUE
	WHERE K_INVENTARIO_EMBARQUE IN ( SELECT K_INVENTARIO_EMBARQUE FROM  @TBL_MATERIAL_SELECCIONADO	)
	GROUP BY CUS_PART_NO, ITEM_NO

	INSERT INTO @TBL_DETALLE_PACKING
	SELECT	'  ', 'Totals:',
			SUM(QTY_SHIP) AS QTY_SHIP, 
			SUM(BOX) AS BOX, 
			SUM(SQFT) AS SQFT 
	FROM @TBL_DETALLE_PACKING

	SELECT K_DETALLE_PACKING,	
		   CUS_PART_NO,		
		   ITEM_NO,	
		   CONVERT(VARCHAR(20), QTY_SHIP) AS QTY_SHIP,		
		    CONVERT(VARCHAR(20), BOX ) AS BOX,					
		   CONVERT(VARCHAR(20), SQFT) AS SQFT,				
			CASE WHEN ITEM_NO = 'Totals:' THEN ' '
				ELSE CONVERT(VARCHAR(10),K_DETALLE_PACKING) END AS ID_DETALLE
	FROM @TBL_DETALLE_PACKING
	--////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO




IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_KIT_X_PACKING]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_KIT_X_PACKING]
GO

/*
 EXEC [PG_GET_KIT_X_PACKING] 0 ,0,  'WK1208-1'
*/

CREATE PROCEDURE [dbo].[PG_GET_KIT_X_PACKING]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_PACKING_NO				VARCHAR(50)
AS

	-- ///////////////////////////////////////////
	SELECT	CUS_PART_NO, 
			ITEM_NO,
			SUM(QTY) AS QTY_SHIP
	FROM	INVENTARIO_EMBARQUE
	WHERE	PACKING_NO = @PP_PACKING_NO
	AND		K_ESTATUS_INVENTARIO_EMBARQUE = 3 -- EMBARCADO
	GROUP BY CUS_PART_NO, ITEM_NO
	
	--////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_ORDEN_FACTURACION_REQUERIMIENTO_X_MATERIAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_ORDEN_FACTURACION_REQUERIMIENTO_X_MATERIAL]
GO

/*
 EXEC [PG_GET_ORDEN_FACTURACION_REQUERIMIENTO_X_MATERIAL] 0 ,0,  'IRVI02' , '00318769' , '2532934BQW-AD' , 'PJLSFBRMCKTX7' , 60 
 EXEC [PG_GET_ORDEN_FACTURACION_REQUERIMIENTO_X_MATERIAL] 0 ,0,  'IRVI02' , '00318769' , '2536300BQW-AD' , 'PJLSFBLMCKTX7' , 60 
 EXEC [PG_GET_ORDEN_FACTURACION_REQUERIMIENTO_X_MATERIAL] 0 ,0,  'IRVI02' , '00318769' , '2546116BQW-AA' , 'PJL2RB4MCKTX7' , 60 
 EXEC [PG_GET_ORDEN_FACTURACION_REQUERIMIENTO_X_MATERIAL] 0 ,0,  'IRVI02' , '00318769' , '2546123BQW-AA' , 'PJL2RB6MCKTX7' , 60 
*/

CREATE PROCEDURE [dbo].[PG_GET_ORDEN_FACTURACION_REQUERIMIENTO_X_MATERIAL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_CLIENTE					VARCHAR(100),
	@PP_ORDEN_FACTURACION		VARCHAR(50),
	@PP_CUS_PART_NO				VARCHAR(150),
	@PP_ITEM_NO					VARCHAR(150),
	@PP_QTY_SHIP				INT
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE NVARCHAR(MAX) = ''
	DECLARE @VP_FECHA_REQUEST_DATE DATE = DATEADD(WK, DATEDIFF(WK, 0, GETDATE()), 0) 
	DECLARE @VP_FECHA_REQUEST_INT INT  =  FORMAT(@VP_FECHA_REQUEST_DATE, N'yyyyMMdd');

	-- ///////////////////////////////////////////
	DECLARE @VP_N_ORDEN_FACTURACION INT = 0
	
	SELECT	@VP_N_ORDEN_FACTURACION = COUNT(ORD_NO)
	FROM	OEORDHDR_SQL
	WHERE	RTRIM(RTRIM(ord_no)) = @PP_ORDEN_FACTURACION
	AND	LTRIM(RTRIM(ord_type)) = 'O'
	AND	LTRIM(RTRIM(CUS_NO)) = @PP_CLIENTE
	AND	LTRIM(RTRIM(STATUS)) <> 'L' --CERRADA/OBSOLETA

	IF @VP_N_ORDEN_FACTURACION IS NULL OR @VP_N_ORDEN_FACTURACION = 0
		SET @VP_MENSAJE = 'Orden de Facturación No encontrada!'

	IF @VP_MENSAJE = ''
		BEGIN
			DECLARE @VP_N_KIT_REQUERIDO INT = 0
			
			SELECT @VP_N_KIT_REQUERIDO = COUNT(A4GLIDENTITY)
			FROM	oeordlin_sql 
			WHERE	RTRIM(RTRIM(ord_no)) = @PP_ORDEN_FACTURACION
			AND	LTRIM(RTRIM(ITEM_NO)) = @PP_ITEM_NO
			AND	LTRIM(RTRIM(CUS_ITEM_NO)) = @PP_CUS_PART_NO
			AND request_dt = @VP_FECHA_REQUEST_INT

			IF @VP_N_KIT_REQUERIDO IS NULL OR @VP_N_KIT_REQUERIDO = 0
				SET @VP_MENSAJE = 'Material No requerido'

			-- ///////////////////////////////////////////
			IF @VP_MENSAJE = ''
				BEGIN
					DECLARE @VP_QTY_ORDERED DECIMAL(13,4) = 0
					DECLARE @VP_QTY_SHIPPED DECIMAL(13,4) = 0

					SELECT	@VP_QTY_ORDERED = tot_qty_ordered,
							@VP_QTY_SHIPPED	= tot_qty_shipped
					FROM	oeordlin_sql 
					WHERE	RTRIM(RTRIM(ord_no)) = @PP_ORDEN_FACTURACION
					AND	LTRIM(RTRIM(ITEM_NO)) = @PP_ITEM_NO
					AND	LTRIM(RTRIM(CUS_ITEM_NO)) = @PP_CUS_PART_NO
					AND request_dt = @VP_FECHA_REQUEST_INT

					SET @VP_QTY_SHIPPED = @VP_QTY_SHIPPED + @PP_QTY_SHIP

					IF @VP_QTY_ORDERED < @VP_QTY_SHIPPED
						SET @VP_MENSAJE = 'Material Sin Credito'

				END

		END

	--////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE = ''
		SET @VP_MENSAJE = 'CORRECTO'

	SELECT @VP_MENSAJE AS MENSAJE

	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_INVOICE_HEADER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_INVOICE_HEADER]
GO

/*
-- 552765
		 EXECUTE [DBO].[PG_LI_INVOICE_HEADER] 0,0, '00319008','554210', '20201109', '***', 'YANG03'
*/

CREATE PROCEDURE [dbo].[PG_LI_INVOICE_HEADER]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_ORDEN_FACTURACION			VARCHAR(50),
	@PP_INVOICE_NO					VARCHAR(50),
	@PP_PO_NUMBER					VARCHAR(50),
	@PP_PACKING_NO					VARCHAR(50),
	@PP_CUSTOMER					VARCHAR(50)
AS
	-- =========================================	
	
 --	SELECT CONVERT(VARCHAR(10),GETDATE(), 101)
 --	SELECT CONVERT(VARCHAR(10),GETDATE(), 6)
	
	DECLARE @VP_F_INVOICE_NO VARCHAR(10) = ''
	DECLARE @VP_F_PACKING_NO VARCHAR(10) = ''

	SELECT TOP 1 @VP_F_PACKING_NO = CONVERT(VARCHAR(10),F_INVENTARIO_EMBARQUE_LOG, 101) 
	FROM INVENTARIO_EMBARQUE_LOG 
	WHERE PACKING_NO = @PP_PACKING_NO

	-- ///////////////////////////////////////////
	IF @PP_INVOICE_NO = 'XXXXXXXX'
		BEGIN
			
			SET @VP_F_INVOICE_NO = CONVERT(VARCHAR(10),GETDATE(), 6)

			SELECT	@VP_F_INVOICE_NO AS F_INVOICE,
					@PP_INVOICE_NO AS inv_no,
					ord_type, 
					ord_no, 
					@PP_PO_NUMBER AS oe_po_no, 
					cus_no,
					bill_to_name,
					bill_to_addr_1,
					bill_to_addr_2,
					bill_to_addr_3,
					bill_to_country,
					ship_to_name,
					ship_to_addr_1,
					ship_to_addr_2,
					ship_to_addr_3,
					ship_to_country,
					ship_via_cd,
					--loctable.ship_via_desc,
					ar_terms_cd,
					OEORDHDR_SQL.slspsn_no,
					OEORDHDR_SQL.tax_cd,
					mfg_loc,loc_desc,
					curr_cd,
					@PP_PACKING_NO AS user_def_fld_5,
					@VP_F_PACKING_NO AS F_PACKING
			FROM OEORDHDR_SQL 
			INNER JOIN taxdetl_sql ON LTRIM(RTRIM(ord_no)) = @PP_ORDEN_FACTURACION 
					AND LTRIM(RTRIM(cus_no)) = @PP_CUSTOMER
					AND oeordhdr_sql.tax_cd=taxdetl_sql.tax_cd
			INNER JOIN IMLOCFIL_SQL ON mfg_loc=loc
			INNER JOIN SYCDEFIL_SQL ON ar_terms_cd=sy_terms_cd AND cd_type='A'
			INNER JOIN SYCDEFIL_SQL AS loctable ON OEORDHDR_SQL.ship_via_cd=loctable.sy_terms_cd AND loctable.cd_type='V'
			INNER JOIN ARSLMFIL_SQL ON OEORDHDR_SQL.slspsn_no=ARSLMFIL_SQL.slspsn_no
		END
	ELSE
		BEGIN
			--20201214

			--SET @VP_F_INVOICE_NO = CONVERT(VARCHAR(10),GETDATE(), 6)

			SELECT	TOP (1)
					CONVERT(VARCHAR(10),dbo.CONVERT_INT_TO_DATE(billed_dt), 6)  AS F_INVOICE ,
					inv_no,
					ord_type, 
					ord_no, 
					oe_po_no, 
					cus_no,
					bill_to_name,
					bill_to_addr_1,
					bill_to_addr_2,
					bill_to_addr_3,
					bill_to_country,
					ship_to_name,
					ship_to_addr_1,
					ship_to_addr_2,
					ship_to_addr_3,
					ship_to_country,
					ship_via_cd,
					ar_terms_cd,
					slspsn_no,
					tax_cd,
					mfg_loc,
					curr_cd,
					user_def_fld_5,
					@VP_F_PACKING_NO AS F_PACKING
			FROM	OEHDRHST_SQL
			WHERE	Inv_No = @PP_INVOICE_NO
			AND		LTRIM(RTRIM(CUS_NO)) = @PP_CUSTOMER
			AND		LTRIM(RTRIM(oe_po_no)) = @PP_PO_NUMBER
		END

	-- /////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_INVOICE_HEADER_YANFENG]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_INVOICE_HEADER_YANFENG]
GO

/*
-- 552765
		 EXECUTE [DBO].[PG_LI_INVOICE_HEADER_YANFENG] 0,0, '00319039','554461', '44180', '***', 'YANG03', '*', 'TBC'
		 EXECUTE [DBO].[PG_LI_INVOICE_HEADER_YANFENG] 0,0, '00319008','XXXXXXXX', '20201109', '***', 'YANG03', '7725 4925 4031', 'TBC'
*/

CREATE PROCEDURE [dbo].[PG_LI_INVOICE_HEADER_YANFENG]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_ORDEN_FACTURACION			VARCHAR(50),
	@PP_INVOICE_NO					VARCHAR(50),
	@PP_PO_NUMBER					VARCHAR(50),
	@PP_PACKING_NO					VARCHAR(50),
	@PP_CUSTOMER					VARCHAR(50),
	@PP_TRACKING_NUMBER				VARCHAR(50),
	@PP_LC_NUMBER					VARCHAR(50)
AS
	-- =========================================	
	
 --	SELECT CONVERT(VARCHAR(10),GETDATE(), 101)
 --	SELECT CONVERT(VARCHAR(10),GETDATE(), 6)
	
	DECLARE @VP_F_INVOICE_NO VARCHAR(10) = ''
	DECLARE @VP_F_PACKING_NO VARCHAR(10) = ''

	SELECT TOP 1 @VP_F_PACKING_NO = CONVERT(VARCHAR(10),F_INVENTARIO_EMBARQUE_LOG, 101) 
	FROM INVENTARIO_EMBARQUE_LOG 
	WHERE PACKING_NO = @PP_PACKING_NO

	-- ///////////////////////////////////////////
	IF @PP_INVOICE_NO = 'XXXXXXXX'
		BEGIN
			
			SET @VP_F_INVOICE_NO = CONVERT(VARCHAR(10),GETDATE(), 6)

			SELECT	@VP_F_INVOICE_NO AS F_INVOICE,
					@PP_INVOICE_NO AS inv_no,
					ord_type, 
					ord_no, 
					@PP_PO_NUMBER AS oe_po_no, 
					cus_no,
					bill_to_name,
					bill_to_addr_1,
					bill_to_addr_2,
					bill_to_addr_3,
					bill_to_country,
					ship_to_name,
					ship_to_addr_1,
					ship_to_addr_2,
					ship_to_addr_3,
					ship_to_country,
					ship_via_cd,
					ar_terms_cd,
					OEORDHDR_SQL.slspsn_no,
					OEORDHDR_SQL.tax_cd,
					mfg_loc,loc_desc,
					curr_cd,
					@PP_PACKING_NO		AS user_def_fld_5,
					@VP_F_PACKING_NO	AS F_PACKING,
					@PP_TRACKING_NUMBER	AS TRACKING_NUMBER,
					@PP_LC_NUMBER		AS LC_NUMBER
			FROM OEORDHDR_SQL 
			INNER JOIN taxdetl_sql ON LTRIM(RTRIM(ord_no)) = @PP_ORDEN_FACTURACION 
					AND LTRIM(RTRIM(cus_no)) = @PP_CUSTOMER
					AND oeordhdr_sql.tax_cd=taxdetl_sql.tax_cd
			INNER JOIN IMLOCFIL_SQL ON mfg_loc=loc
			INNER JOIN SYCDEFIL_SQL ON ar_terms_cd=sy_terms_cd AND cd_type='A'
			INNER JOIN SYCDEFIL_SQL AS loctable ON OEORDHDR_SQL.ship_via_cd=loctable.sy_terms_cd AND loctable.cd_type='V'
			INNER JOIN ARSLMFIL_SQL ON OEORDHDR_SQL.slspsn_no=ARSLMFIL_SQL.slspsn_no
		END
	ELSE
		BEGIN
			SELECT	TOP (1)
					CONVERT(VARCHAR(10),dbo.CONVERT_INT_TO_DATE(billed_dt), 6)  AS F_INVOICE ,
					inv_no,
					ord_type, 
					ord_no, 
					oe_po_no, 
					cus_no,
					bill_to_name,
					bill_to_addr_1,
					bill_to_addr_2,
					bill_to_addr_3,
					bill_to_country,
					ship_to_name,
					ship_to_addr_1,
					ship_to_addr_2,
					ship_to_addr_3,
					ship_to_country,
					ship_via_cd,
					ar_terms_cd,
					slspsn_no,
					tax_cd,
					mfg_loc,
					curr_cd,
					user_def_fld_5,
					@VP_F_PACKING_NO	AS F_PACKING,
					ISNULL(user_def_fld_2, 'N/A')		AS TRACKING_NUMBER,
					ISNULL(user_def_fld_4, 'N/A')		AS LC_NUMBER
			FROM	OEHDRHST_SQL
			WHERE	Inv_No = @PP_INVOICE_NO
			AND		LTRIM(RTRIM(CUS_NO)) = @PP_CUSTOMER
			AND		LTRIM(RTRIM(oe_po_no)) = @PP_PO_NUMBER
		END

	-- /////////////////////////////////////////////////////////////////////
GO



-- USE DATA_02PRUEBAS
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_INVOICE_DETAILS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_INVOICE_DETAILS]
GO
/*  '00318798','553085', 'A-47635', 'WK1208-1', 'MAGN03'
	 EXECUTE [DBO].[PG_LI_INVOICE_DETAILS] 0,0, '00318769','XXXXXXXX','JL1204-1', 'IRVI02'
*/
CREATE PROCEDURE [dbo].[PG_LI_INVOICE_DETAILS]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_ORDEN_FACTURACION			VARCHAR(50),
	@PP_INVOICE_NO					VARCHAR(50),
	@PP_PACKING_NO					VARCHAR(50),
	@PP_CUSTOMER					VARCHAR(50)
AS
	-- =========================================		
	
	IF @PP_INVOICE_NO = 'XXXXXXXX'
		BEGIN
			DECLARE @VP_CUS_PART_NO	VARCHAR(100) = ''
			DECLARE @VP_ITEM_NO		VARCHAR(100) = ''
			DECLARE @VP_QTY_SHIP	INT = 0

			DECLARE @VP_TBL_DETALLE_INVOICE TABLE(
				Item_No			VARCHAR(100),
				Item_Desc_1		VARCHAR(100),
				Cus_Item_No		VARCHAR(100),
				Qty_To_Ship		VARCHAR(20),
				UOM_MANUAL		VARCHAR(10),
				Unit_Price		VARCHAR(10),
				TOTAL_KIT		DECIMAL(13,2)
			)

			-- ///////////////////////////////////////////
			DECLARE CU_MATERIAL_A_FACTURAR CURSOR 
			FOR SELECT	CUS_PART_NO, 
						ITEM_NO,
						SUM(QTY) AS QTY_SHIP
				FROM	INVENTARIO_EMBARQUE
				WHERE	PACKING_NO = @PP_PACKING_NO
				GROUP BY CUS_PART_NO, ITEM_NO
			
			OPEN CU_MATERIAL_A_FACTURAR
			FETCH NEXT FROM CU_MATERIAL_A_FACTURAR INTO @VP_CUS_PART_NO, @VP_ITEM_NO, @VP_QTY_SHIP
			
			WHILE @@FETCH_STATUS = 0
				BEGIN
					DECLARE @VP_ITEM_DESC_1 VARCHAR(150) = ''
					DECLARE @VP_BPO_NUMBER	VARCHAR(50) = ''

					SELECT @VP_ITEM_DESC_1 = LTRIM(RTRIM(ITEM_DESC_1)),
							@VP_BPO_NUMBER = LTRIM(RTRIM(ISNULL(filler_0003, '')))
					FROM IMITMIDX_SQL 
					WHERE LTRIM(RTRIM(item_no)) = @VP_ITEM_NO

					-- ///////////////////////////////////////////
					DECLARE @VP_PRECIO_UNITARIO DECIMAL(13,2) = 0 -- REVISAR CALCULOS PORQUE EL PRECIO ESTA A 6 DECIMALES
					SELECT TOP 1 @VP_PRECIO_UNITARIO = PRC_OR_DISC_1
					FROM	OEPRCFIL_SQL 
					WHERE	LTRIM(RTRIM(filler_0001)) LIKE '%' + @VP_ITEM_NO 
					AND		LTRIM(RTRIM(filler_0001)) LIKE @PP_CUSTOMER + '%'
					ORDER BY A4GLIdentity DESC

					-- ///////////////////////////////////////////
					DECLARE @VP_TOTAL_KIT DECIMAL(13,2) = 0
					SET @VP_TOTAL_KIT = @VP_QTY_SHIP * @VP_PRECIO_UNITARIO

					INSERT INTO @VP_TBL_DETALLE_INVOICE 
						SELECT	@VP_ITEM_NO AS Item_No,
								@VP_ITEM_DESC_1 AS Item_Desc_1,
								-- =========================================
								( CASE WHEN @PP_CUSTOMER = 'FAUR01' THEN
											CONCAT(@VP_CUS_PART_NO, ' (', @VP_BPO_NUMBER, ')') 
										ELSE @VP_CUS_PART_NO END ) AS Cus_Item_No,
								-- =========================================
								@VP_QTY_SHIP AS Qty_To_Ship,
								'EA' AS UOM_MANUAL,
								@VP_PRECIO_UNITARIO AS Unit_Price,
								@VP_TOTAL_KIT AS TOTAL_KIT

					FETCH NEXT FROM CU_MATERIAL_A_FACTURAR INTO @VP_CUS_PART_NO, @VP_ITEM_NO, @VP_QTY_SHIP
	
				END
				
				CLOSE CU_MATERIAL_A_FACTURAR
				DEALLOCATE CU_MATERIAL_A_FACTURAR

				-- ///////////////////////////////////////////
				SELECT *
				FROM @VP_TBL_DETALLE_INVOICE
		END
	ELSE
		BEGIN
			SELECT	
					OELINHST_SQL.Item_No,
					OELINHST_SQL.Item_Desc_1,
					-- =========================================
					( CASE WHEN @PP_CUSTOMER = 'FAUR01' THEN
								CONCAT(LTRIM(RTRIM(OELINHST_SQL.Cus_Item_No)), ' (', LTRIM(RTRIM(ISNULL(filler_0003, ''))) , ')') 
						ELSE LTRIM(RTRIM(OELINHST_SQL.Cus_Item_No)) END ) AS Cus_Item_No,
					-- =========================================
					OELINHST_SQL.Qty_To_Ship,
					'EA'	AS UOM_MANUAL,
					OELINHST_SQL.Unit_Price,
					SLS_AMT	AS	TOTAL_KIT
			-- =========================================-- =========================================
			FROM	OELINHST_SQL
			LEFT JOIN IMITMIDX_SQL ON LTRIM(RTRIM(IMITMIDX_SQL.item_no)) = LTRIM(RTRIM(OELINHST_SQL.item_no))
			WHERE	OELINHST_SQL.Inv_No	= @PP_INVOICE_NO
			AND		LTRIM(RTRIM(CUS_NO)) = @PP_CUSTOMER
			ORDER BY OELINHST_SQL.Line_Seq_No
		END

	
	-- /////////////////////////////////////////////////////////////////////
GO




-- USE DATA_02PRUEBAS
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_INVOICE_FOOTER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_INVOICE_FOOTER]
GO
/* '00318798','553085', 'A-47635', 'WK1208-1', 'MAGN03'
	 EXECUTE [DBO].[PG_LI_INVOICE_FOOTER] 0,0,  '00318769','XXXXXXXX','JL1204-1', 'IRVI02'
*/
CREATE PROCEDURE [dbo].[PG_LI_INVOICE_FOOTER]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_ORDEN_FACTURACION			VARCHAR(50),
	@PP_INVOICE_NO					VARCHAR(50),
	@PP_PACKING_NO					VARCHAR(50),
	@PP_CUSTOMER					VARCHAR(50)
AS
	-- =========================================
	DECLARE @VP_TOTAL_INVOICE AS DECIMAL(13,2) = 0
	DECLARE @VP_N_BOX INT = 0
	DECLARE @VP_DESCUENTO_LEYENDA		VARCHAR(150) = ''
	DECLARE @VP_DESCUENTO_PORCENTAJE	DECIMAL(13,2) = 0
	DECLARE @VP_DESCUENTO_TOTAL			DECIMAL(13,2) = 0
	DECLARE @VP_DESCUENTO_TOTAL_TEXTO	VARCHAR(20) = ''
	DECLARE @VP_SUBTOTAL_INVOICE		DECIMAL(13,2) = 0

	-- /////////////////////////////////////////////////////////////////////
	SELECT	@VP_N_BOX = COUNT(CUS_PART_NO)
	FROM	INVENTARIO_EMBARQUE
	WHERE	PACKING_NO = @PP_PACKING_NO
	
	SELECT @VP_DESCUENTO_PORCENTAJE = discount_pct
	FROM OEORDHDR_SQL  
	WHERE ord_no = @PP_ORDEN_FACTURACION

	IF @VP_DESCUENTO_PORCENTAJE IS NULL
		SET @VP_DESCUENTO_PORCENTAJE = 0

	IF @PP_INVOICE_NO = 'XXXXXXXX'
		BEGIN
			DECLARE @VP_CUS_PART_NO	VARCHAR(100) = ''
			DECLARE @VP_ITEM_NO		VARCHAR(100) = ''
			DECLARE @VP_QTY_SHIP	INT = 0

			DECLARE @VP_TBL_DETALLE_INVOICE TABLE(
				Item_No			VARCHAR(100),
				Item_Desc_1		VARCHAR(100),
				Cus_Item_No		VARCHAR(100),
				Qty_To_Ship		VARCHAR(20),
				UOM_MANUAL		VARCHAR(10),
				Unit_Price		VARCHAR(20),
				TOTAL_KIT		VARCHAR(50)
			)
			
			-- /////////////////////////////////////////////////////////////////////
			DECLARE CU_MATERIAL_A_FACTURAR CURSOR 
			FOR SELECT	CUS_PART_NO, 
						ITEM_NO,
						SUM(QTY) AS QTY_SHIP
				FROM	INVENTARIO_EMBARQUE
				WHERE	PACKING_NO = @PP_PACKING_NO
				GROUP BY CUS_PART_NO, ITEM_NO
			
			OPEN CU_MATERIAL_A_FACTURAR
			FETCH NEXT FROM CU_MATERIAL_A_FACTURAR INTO @VP_CUS_PART_NO, @VP_ITEM_NO, @VP_QTY_SHIP
			
			WHILE @@FETCH_STATUS = 0
				BEGIN
					DECLARE @VP_ITEM_DESC_1 VARCHAR(150) = ''
					
					SELECT @VP_ITEM_DESC_1 = LTRIM(RTRIM(ITEM_DESC_1)) 
					FROM IMITMIDX_SQL 
					WHERE LTRIM(RTRIM(item_no)) = @VP_ITEM_NO

					-- /////////////////////////////////////////////////////////////////////
					DECLARE @VP_PRECIO_UNITARIO DECIMAL(13,2) = 0 -- REVISAR CALCULOS PORQUE EL PRECIO ESTA A 6 DECIMALES
					SELECT TOP 1 @VP_PRECIO_UNITARIO = PRC_OR_DISC_1
					FROM	OEPRCFIL_SQL 
					WHERE	LTRIM(RTRIM(filler_0001)) LIKE '%' + @VP_ITEM_NO 
					AND		LTRIM(RTRIM(filler_0001)) LIKE @PP_CUSTOMER + '%'
					ORDER BY A4GLIdentity DESC

					-- /////////////////////////////////////////////////////////////////////
					DECLARE @VP_TOTAL_KIT DECIMAL(13,2) = 0
					SET @VP_TOTAL_KIT = @VP_QTY_SHIP * @VP_PRECIO_UNITARIO

					-- /////////////////////////////////////////////////////////////////////
					INSERT INTO @VP_TBL_DETALLE_INVOICE 
						SELECT	@VP_ITEM_NO AS Item_No,
								@VP_ITEM_DESC_1 AS Item_Desc_1,
								@VP_CUS_PART_NO AS Cus_Item_No,
								@VP_QTY_SHIP AS Qty_To_Ship,
								'EA' AS UOM_MANUAL,
								@VP_PRECIO_UNITARIO AS Unit_Price,
								@VP_TOTAL_KIT AS TOTAL_KIT

					FETCH NEXT FROM CU_MATERIAL_A_FACTURAR INTO @VP_CUS_PART_NO, @VP_ITEM_NO, @VP_QTY_SHIP
	
				END
				
			CLOSE CU_MATERIAL_A_FACTURAR
			DEALLOCATE CU_MATERIAL_A_FACTURAR

			-- /////////////////////////////////////////////////////////////////////
			SELECT	@VP_TOTAL_INVOICE = SUM(CONVERT(DECIMAL(13,2),TOTAL_KIT))
			FROM @VP_TBL_DETALLE_INVOICE				

			SET @VP_SUBTOTAL_INVOICE = @VP_TOTAL_INVOICE
			SET @VP_DESCUENTO_TOTAL = ( @VP_DESCUENTO_PORCENTAJE * @VP_SUBTOTAL_INVOICE ) / 100
			SET @VP_TOTAL_INVOICE = @VP_SUBTOTAL_INVOICE - @VP_DESCUENTO_TOTAL
		END
	ELSE
		BEGIN		
			--DECLARE @VP_DESCUENTO_PORCENTAJE_INVOICE DECIMAL(13,2)= 0

			--SELECT @VP_DESCUENTO_PORCENTAJE_INVOICE = discount_pct,
			--		@VP_SUBTOTAL_INVOICE = tot_sls_amt + tot_sls_disc,
			--		@VP_DESCUENTO_TOTAL = tot_sls_disc,
			--		@VP_TOTAL_INVOICE = tot_sls_amt
			--FROM OEHDRHST_SQL 
			--WHERE  inv_no = @PP_INVOICE_NO

			--IF @VP_DESCUENTO_PORCENTAJE_INVOICE IS NULL
			--	SET @VP_DESCUENTO_PORCENTAJE_INVOICE = 0

			--IF @VP_DESCUENTO_PORCENTAJE <> @VP_DESCUENTO_PORCENTAJE_INVOICE
			--	BEGIN
			DECLARE @VP_TOTAL_DETALLE DECIMAL(13,2) = 0
			SELECT @VP_TOTAL_DETALLE = SUM(SLS_AMT)
			FROM OELINHST_SQL 
			WHERE inv_no = @PP_INVOICE_NO
			AND item_desc_2 <> 'COMPLEMENTO'

			IF @VP_TOTAL_DETALLE IS NULL
				SET @VP_TOTAL_DETALLE = 0

			DECLARE @VP_TOTAL_DETALLE_COMPLEMENTO DECIMAL(13,2) = 0
			SELECT @VP_TOTAL_DETALLE_COMPLEMENTO = SUM(SLS_AMT)
			FROM OELINHST_SQL 
			WHERE inv_no = @PP_INVOICE_NO
			AND item_desc_2 = 'COMPLEMENTO'

			IF @VP_TOTAL_DETALLE_COMPLEMENTO IS NULL
				SET @VP_TOTAL_DETALLE_COMPLEMENTO = 0
			
			SET @VP_SUBTOTAL_INVOICE = @VP_TOTAL_DETALLE
			SET @VP_DESCUENTO_TOTAL = ( @VP_DESCUENTO_PORCENTAJE * (@VP_SUBTOTAL_INVOICE) ) / 100
			SET @VP_TOTAL_INVOICE = @VP_SUBTOTAL_INVOICE - @VP_DESCUENTO_TOTAL

			UPDATE OEHDRHST_SQL
				SET discount_pct = @VP_DESCUENTO_PORCENTAJE,
					tot_sls_disc = @VP_DESCUENTO_TOTAL,
					tot_sls_amt = ( @VP_TOTAL_INVOICE + @VP_TOTAL_DETALLE_COMPLEMENTO )
			WHERE  inv_no = @PP_INVOICE_NO 
				--END
		END	
	
	--SET @VP_DESCUENTO_LEYENDA = 'WL FINANCING ' + CONVERT(VARCHAR(10), @VP_DESCUENTO_PORCENTAJE) + '%'
	SET @VP_DESCUENTO_LEYENDA = 'Financing ' + CONVERT(VARCHAR(10), @VP_DESCUENTO_PORCENTAJE) + '%:'
	SET @VP_DESCUENTO_TOTAL_TEXTO = '-' + CONVERT(VARCHAR(10), @VP_DESCUENTO_TOTAL)

	-- /////////////////////////////////////////////////////////////////////
	SELECT	@VP_DESCUENTO_LEYENDA AS LEYENDA_DESCUENTO, 
			@VP_SUBTOTAL_INVOICE  AS SUBTOTAL,
			@VP_DESCUENTO_TOTAL_TEXTO AS DESCUENTO,
			( @VP_TOTAL_INVOICE + @VP_TOTAL_DETALLE_COMPLEMENTO ) AS TOTAL_INVOICE, 
			@VP_N_BOX AS BOX
	-- /////////////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_OEHDRHST_SQL_X_FACTURA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_OEHDRHST_SQL_X_FACTURA]
GO

/*
-- 552765
		 EXECUTE [DBO].[PG_LI_OEHDRHST_SQL_X_FACTURA] 0,0, '554585'
*/

CREATE PROCEDURE [dbo].[PG_LI_OEHDRHST_SQL_X_FACTURA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_INVOICE_NO					VARCHAR(50)
AS
	-- =========================================	
	
	SELECT	TOP (1)
			CONVERT(VARCHAR(10),dbo.CONVERT_INT_TO_DATE(billed_dt), 6)  AS F_INVOICE ,
			inv_no,
			ord_type, 
			ord_no, 
			oe_po_no, 
			cus_no,
			bill_to_name,
			bill_to_addr_1,
			bill_to_addr_2,
			bill_to_addr_3,
			bill_to_country,
			ship_to_name,
			ship_to_addr_1,
			ship_to_addr_2,
			ship_to_addr_3,
			ship_to_country,
			ship_via_cd,
			ar_terms_cd,
			slspsn_no,
			tax_cd,
			mfg_loc,
			curr_cd,
			user_def_fld_5
	FROM	OEHDRHST_SQL
	WHERE	Inv_No = @PP_INVOICE_NO

	-- /////////////////////////////////////////////////////////////////////
GO






-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
