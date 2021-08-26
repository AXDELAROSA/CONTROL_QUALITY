-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			QC 8D
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	26/AGO/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO

-- ////////////////////////////////////////////////////////////// 
-- ////////////////////////////////////////////////////////////// 



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CONFIGURAR_CORREO_QC_8D]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CONFIGURAR_CORREO_QC_8D]
GO

-- EXEC [dbo].[PG_CONFIGURAR_CORREO_QC_8D] 0, 144, 3

CREATE PROCEDURE [dbo].[PG_CONFIGURAR_CORREO_QC_8D]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_8D							INT
AS

	DECLARE @VP_MENSAJE		VARCHAR(255) = ''

	-- ///////////////////////////////////////////
	DECLARE @VP_TITLE VARCHAR(MAX) = ''
	SELECT @VP_TITLE = TITLE 
	FROM [8D] 
	WHERE K_8D = @PP_K_8D

	DECLARE @VP_SUBJECT		VARCHAR(255) = '8D #'+ CONVERT(VARCHAR(50),@PP_K_8D)  + ': ' + @VP_TITLE
	DECLARE @VP_DATE		DATE = GETDATE()

	--==================================
	DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  = ''
	SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
								FROM	BD_GENERAL.dbo.USUARIO_PEARL 
								INNER	JOIN[8D_TEAM]  ON [8D_TEAM].NUMERO_RELOJ = USUARIO_PEARL.K_EMPLEADO_PEARL
								WHERE 	[K_8D] = 3
								AND ( CORREO_USUARIO_PEARL <> '' OR CORREO_USUARIO_PEARL <> 'SIN CORREO' )

	SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))

	IF RTRIM(LTRIM(@VP_RECIPIENTS)) = ''
		SET @VP_MENSAJE = 'Las personas involucradas no cuentan con correo.'

	IF @VP_MENSAJE = ''
		BEGIN
			DECLARE @VP_BODY		NVARCHAR(MAX) = ''
			SET @VP_BODY =	N'<table  border="1" align="center" cellspacing="0">' + 
									N'<thead>' + 
										N'<tr BGCOLOR="#ADD8E6">' + 
											N'<th colspan="5"> Team involved for the resolution of the 8D </th>' + 
										N'</tr>' + 
										N'<tr BGCOLOR="#48D1CC">' + 
											N'<th>ID 8D</th><th>Role</th><th>Name</th><th>Last Name</th><th>Department</th>' + 
										N'</tr>' + 
									N'</thead>' + 
									N'<tbody>' + 
											CAST ( ( SELECT td = K_8D, '',
									                td = ROL, '',  
									                td = EP_NOMBRE, '',  
									                td = EP_APELLIDO_PATERNO, '',  
									                td = DP_DESC_DEPTO, ''
									         FROM	[8D_TEAM] (NOLOCK)
											INNER JOIN  BD_GENERAL.DBO.USUARIO_PEARL (NOLOCK) ON USUARIO_PEARL.K_USUARIO_PEARL = [8D_TEAM].[K_USUARIO_CAMBIO]
											INNER JOIN	HOWE.dbo.VISTA_GAFETES (NOLOCK) ON VISTA_GAFETES.EN_NUM_EMP = [NUMERO_RELOJ]
											WHERE 	[K_8D] = @PP_K_8D
											ORDER BY ROL
									          FOR XML PATH('tr'), TYPE   
											) AS NVARCHAR(MAX) ) +  
									N'</tbody>' + 
								N'</table>' ; 
						SET ROWCOUNT 0
			 				
			EXECUTE	BD_GENERAL.[dbo].[PG_ENVIAR_CORREO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@VP_RECIPIENTS, @VP_SUBJECT, @VP_BODY
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	IF @VP_MENSAJE<>''
		BEGIN
			SET		@VP_MENSAJE = 'No es posible [Enviar] el correo a las personas del equipo para la [8D]: ' + @VP_MENSAJE 
			SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
			SET		@VP_MENSAJE = @VP_MENSAJE + '[#8D.'+CONVERT(VARCHAR(10),@PP_K_8D)+']'
			SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_8D AS CLAVE
	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
