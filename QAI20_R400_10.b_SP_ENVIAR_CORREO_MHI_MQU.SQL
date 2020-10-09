-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			QA INSPECCION DE MATERIAL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	17/SEP/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas] 
GO

-- ////////////////////////////////////////////////////////////// 
-- ////////////////////////////////////////////////////////////// 



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CONFIGURAR_CORREO_MATERIAL_INSPECCIONADO_DISPOSICION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CONFIGURAR_CORREO_MATERIAL_INSPECCIONADO_DISPOSICION]
GO


CREATE PROCEDURE [dbo].[PG_CONFIGURAR_CORREO_MATERIAL_INSPECCIONADO_DISPOSICION]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_ORDEN_COMPRA					INT,
	@PP_K_ORDEN_COMPRA_PEDIDO			VARCHAR(50),
	@PP_K_ENTREGA						INT,
	@PP_K_ITEM							INT,
	@PP_LOCACION_DESTINO				VARCHAR(5)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_K_TIPO_GRUPO_APROBADOR VARCHAR(15)	= 180
	DECLARE @VP_SUBJECT		VARCHAR(255) = 'Material inspeccionado liberado por calidad para disposición'

	IF @PP_LOCACION_DESTINO = 'MQU'
		BEGIN
			SET @VP_K_TIPO_GRUPO_APROBADOR = 200
			SET @VP_SUBJECT = 'Material inspeccionado rechazado por calidad'
		END

	DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  = ''
	SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
								FROM	BD_GENERAL.dbo.USUARIO_PEARL AS USERS
								INNER	JOIN	BD_GENERAL.dbo.GRUPO_APROBADOR GP_APROB ON GP_APROB.K_USUARIO=USERS.K_USUARIO_PEARL
								WHERE   GP_APROB.S_GRUPO_APROBADOR = 'MHI_MQU_LR'
								AND		GP_APROB.K_TIPO_GRUPO_APROBADOR = @VP_K_TIPO_GRUPO_APROBADOR
								AND		K_ESTATUS_GRUPO_APROBADOR = 1

	SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))
		
	DECLARE @VP_BODY		NVARCHAR(MAX) 
	SET @VP_BODY = N'<table  border="1" align="center" cellspacing="0">' + 
									N'<thead>' + 
									  N'<tr BGCOLOR="#ADD8E6">' + 
									    N'<th colspan="8">Material</th>' + 
									  N'</tr>' + 
									  N'<tr BGCOLOR="#48D1CC">' + 
									    N'<th>PO</th><th>PO Pedido</th><th>Numero Parte</th><th>Lote Pearl</th><th>Cantidad</th><th>Unidad Medida</th><th>Proveedor</th><th>Cliente</th><th>Fecha</th>' + 
									  N'</tr>' + 
									N'</thead>' + 
									N'<tbody>' + 
									  N'<tr>' + 
										CAST ( ( SELECT DISTINCT td = RTRIM(LTRIM(DETAILS_BPO_RECIBO.K_HEADER_PURCHASE_ORDER)),'',  
													td = RTRIM(LTRIM(DETAILS_BPO_RECIBO.K_ORDEN_COMPRA_PEDIDO)), '',  
													td = RTRIM(LTRIM(PART_NUMBER_ITEM_PEARL)), '',  
													td = RTRIM(LTRIM(LOTE_PEARL)), '', 
													td = RTRIM(LTRIM(QUANTITY_RECEIVED)), '',  
													td = RTRIM(LTRIM(S_UNIT_OF_MEASURE)), '', 
													td = D_VENDOR, '',  
													td = cus_no, '',  
													td = CONVERT(DATE,GETDATE())  
												FROM	COMPRAS.dbo.DETAILS_BPO_RECIBO
												INNER JOIN	COMPRAS.dbo.HEADER_BPO_PEDIDO  ON	DETAILS_BPO_RECIBO.K_HEADER_PURCHASE_ORDER=HEADER_BPO_PEDIDO.K_HEADER_PURCHASE_ORDER
												INNER JOIN	COMPRAS.dbo.ITEM		ON	DETAILS_BPO_RECIBO.K_ITEM=ITEM.K_ITEM
												INNER JOIN	BD_GENERAL.DBO.UNIT_OF_MEASURE ON ITEM.K_UNIT_OF_ITEM = UNIT_OF_MEASURE.K_UNIT_OF_MEASURE
												INNER JOIN	COMPRAS.dbo.VENDOR ON HEADER_BPO_PEDIDO.K_VENDOR = VENDOR.K_VENDOR 
												INNER JOIN	ARCUSFIL_SQL ON HEADER_BPO_PEDIDO.K_CUSTOMER = ARCUSFIL_SQL.A4GLIdentity
															-- =============================
												WHERE	DETAILS_BPO_RECIBO.K_HEADER_PURCHASE_ORDER = @PP_K_ORDEN_COMPRA
												AND		DETAILS_BPO_RECIBO.K_ORDEN_COMPRA_PEDIDO = @PP_K_ORDEN_COMPRA_PEDIDO
												AND		DETAILS_BPO_RECIBO.K_ENTREGA= @PP_K_ENTREGA
												AND		DETAILS_BPO_RECIBO.K_ITEM = @PP_K_ITEM		
								          FOR XML PATH('tr'), TYPE   
										) AS NVARCHAR(MAX) ) +  
								  N'</tr>' + 
									N'</tbody>' + 
								N'</table>' ; 
					SET ROWCOUNT 0
		 				
	EXECUTE	BD_GENERAL.[dbo].[PG_ENVIAR_CORREO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@VP_RECIPIENTS, @VP_SUBJECT, @VP_BODY

	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
