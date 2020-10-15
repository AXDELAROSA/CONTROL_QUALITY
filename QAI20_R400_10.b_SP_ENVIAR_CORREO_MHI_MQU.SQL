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

USE [DATA_02] 
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
	@PP_K_ORDEN_COMPRA_PEDIDO			VARCHAR(100),
	@PP_K_ENTREGA						INT,
	@PP_K_ITEM							INT,
	@PP_PP_LOTE_PEARL					INT,
	@PP_LOCACION_DESTINO				VARCHAR(5)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_K_TIPO_GRUPO_APROBADOR VARCHAR(15)	= 180
	DECLARE @VP_SUBJECT		VARCHAR(255) = 'Material inspeccionado Liberado por calidad para disposición'
	DECLARE @VP_DATE		DATE = GETDATE()
	IF @PP_LOCACION_DESTINO = 'MQU'
		BEGIN
			SET @VP_K_TIPO_GRUPO_APROBADOR = 200
			SET @VP_SUBJECT = 'Material inspeccionado Rechazado'
		END

	DECLARE	@VP_PART_NUMBER_PEARL VARCHAR(100) = ''
	SELECT	@VP_PART_NUMBER_PEARL = LTRIM(RTRIM(PART_NUMBER_ITEM_PEARL))
	FROM	COMPRAS.dbo.ITEM 
	WHERE	K_ITEM = @PP_K_ITEM



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
									    N'<th colspan="6">Material</th>' + 
									  N'</tr>' + 
									  N'<tr BGCOLOR="#48D1CC">' + 
									    N'<th>PO</th><th>PO Pedido</th><th>Entrega</th><th>Numero Parte</th><th>Lote Pearl</th><th>Fecha</th>' + 
									  N'</tr>' + 
									N'</thead>' + 
									N'<tbody>' + 
						  N'<tr>' + 
						  N'<td>'+ CONVERT(VARCHAR(50),@PP_K_ORDEN_COMPRA) +'</td><td>'+ @PP_K_ORDEN_COMPRA_PEDIDO +'</td><td>'+ CONVERT(VARCHAR(50),@PP_K_ENTREGA) +'</td><td>'+ @VP_PART_NUMBER_PEARL +'</td><td>'+ CONVERT(VARCHAR(50),@PP_PP_LOTE_PEARL) +'</td><td>'+ CONVERT(VARCHAR(50),@VP_DATE) +'</td>' + 
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
