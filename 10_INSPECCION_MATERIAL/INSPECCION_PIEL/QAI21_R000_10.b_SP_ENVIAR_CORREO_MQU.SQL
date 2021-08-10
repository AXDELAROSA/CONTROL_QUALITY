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

USE [DATA_02PRUEBAS] 
GO

-- ////////////////////////////////////////////////////////////// 
-- ////////////////////////////////////////////////////////////// 



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CONFIGURAR_CORREO_LOTE_INSPECCIONADO_REVISION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CONFIGURAR_CORREO_LOTE_INSPECCIONADO_REVISION]
GO


CREATE PROCEDURE [dbo].[PG_CONFIGURAR_CORREO_LOTE_INSPECCIONADO_REVISION]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_LOTE_IMPORTACION				INT,
	@PP_LOTE							INT,
	@PP_COLOR							VARCHAR(50),
	@PP_CANTIDAD_PIEL					INT
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_SUBJECT		VARCHAR(255) = 'Lote inspeccionado en espera de Autorización'
	DECLARE @VP_DATE		DATE = GETDATE()

	DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  = '' -- 'franciscoe@pearlleather.com.mx:'
	SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
								FROM	BD_GENERAL.dbo.USUARIO_PEARL AS USERS
								INNER	JOIN	BD_GENERAL.dbo.GRUPO_APROBADOR GP_APROB ON GP_APROB.K_USUARIO=USERS.K_USUARIO_PEARL
								WHERE   GP_APROB.S_GRUPO_APROBADOR = 'INSPEC_BPO'
								AND		GP_APROB.K_TIPO_GRUPO_APROBADOR = 7800
								AND		K_ESTATUS_GRUPO_APROBADOR = 1

	SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))

	--==================================
	--ALEJANDROD@PEARLLEATHER.COM.MX;FRANCISCOE@PEARLLEATHER.COM.MX;MARIOS@PEARLLEATHER.COM.MX;JORGEJ@PEARLLEATHER.COM.MX;JOLEGARIO@PEARLLEATHER.COM.MX;TERESAJ.PEARL@GMAIL.COM;ALBAJ@PEARLLEATHER.COM.MX;MARLENNES.PEARL@GMAIL.COM
	--SELECT @VP_RECIPIENTS
	--==================================

	DECLARE @VP_BODY		NVARCHAR(MAX) 
	SET @VP_BODY = N'<table  border="1" align="center" cellspacing="0">' + 
									N'<thead>' + 
									  N'<tr BGCOLOR="#ADD8E6">' + 
									    N'<th colspan="5">Material</th>' + 
									  N'</tr>' + 
									  N'<tr BGCOLOR="#48D1CC">' + 
									    N'<th>ID Inspección</th><th>Color</th><th>Lote</th><th>Cantidad Piel</th><th>Fecha</th>' + 
									  N'</tr>' + 
									N'</thead>' + 
									N'<tbody>' + 
						  N'<tr>' + 
						  N'<td>'+ CONVERT(VARCHAR(50),@PP_K_LOTE_IMPORTACION) +'</td><td>'+ @PP_COLOR +'</td><td>'+ CONVERT(VARCHAR(50),@PP_LOTE) + '</td><td>'+ CONVERT(VARCHAR(50),@PP_CANTIDAD_PIEL)  +'</td><td>'+ CONVERT(VARCHAR(50),@VP_DATE) +'</td>' + 
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
