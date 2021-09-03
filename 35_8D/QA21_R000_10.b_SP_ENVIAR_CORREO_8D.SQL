-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			QC 8D
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	01/SEP/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO

-- ////////////////////////////////////////////////////////////// 
-- // CORREO DE NOTIFICACION PARA COLOBORAR EN LA 8D
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
	DECLARE @VP_8D_PEARL VARCHAR(50) = ''

	SELECT	@VP_8D_PEARL = K_8D_PEARL,
			@VP_TITLE = TITLE 
	FROM [8D] (NOLOCK)
	WHERE K_8D = @PP_K_8D

	DECLARE @VP_SUBJECT		VARCHAR(255) = '8D #'+ @VP_8D_PEARL  + ': ' + @VP_TITLE

	--==================================
	DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  = ''
	SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
								FROM	BD_GENERAL.dbo.USUARIO_PEARL (NOLOCK)
								INNER	JOIN [8D_TEAM] (NOLOCK)  ON [8D_TEAM].NUMERO_RELOJ = USUARIO_PEARL.K_EMPLEADO_PEARL
								WHERE 	[K_8D] = @PP_K_8D
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
											CAST ( ( SELECT td = K_8D_PEARL, '',
									                td = ROL, '',  
									                td = EP_NOMBRE, '',  
									                td = EP_APELLIDO_PATERNO, '',  
									                td = DP_DESC_DEPTO, ''
									         FROM	[8D_TEAM] (NOLOCK)
											INNER JOIN  [8D] (NOLOCK) ON [8D].K_8D= [8D_TEAM].K_8D
											INNER JOIN	HOWE.dbo.VISTA_GAFETES (NOLOCK) ON VISTA_GAFETES.EN_NUM_EMP = [NUMERO_RELOJ]
											WHERE 	[8D_TEAM].[K_8D] = @PP_K_8D
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
-- // CORREO DE NOTIFICACION PARA COMPLETAR LA 8D 
-- ////////////////////////////////////////////////////////////// 

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_NOTIFICACION_PARA_COMPLETAR_8D]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_NOTIFICACION_PARA_COMPLETAR_8D]
GO

-- EXEC [dbo].[PG_NOTIFICACION_PARA_COMPLETAR_8D] 0, 144, 3

CREATE PROCEDURE [dbo].[PG_NOTIFICACION_PARA_COMPLETAR_8D]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_8D							INT,
	@PP_K_8D_PEARL						VARCHAR(50),
	@PP_TITULO							VARCHAR(MAX),
	@PP_PRODUCTO						VARCHAR(MAX),
	@PP_F_APERTURA						DATE,
	@PP_F_CIERRE_ESTIMADO				DATE,
	@PP_SUBJECT							VARCHAR(255),
	@PP_N_TEAM							INT
AS

	DECLARE @VP_MENSAJE		VARCHAR(255) = ''

	-- ///////////////////////////////////////////
	DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  = ''
	IF @PP_N_TEAM > 0
		BEGIN
			SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
										FROM	BD_GENERAL.dbo.USUARIO_PEARL (NOLOCK)
										INNER	JOIN [8D_TEAM] (NOLOCK)  ON [8D_TEAM].NUMERO_RELOJ = USUARIO_PEARL.K_EMPLEADO_PEARL
										WHERE 	[K_8D] = @PP_K_8D
										AND ( CORREO_USUARIO_PEARL <> '' OR CORREO_USUARIO_PEARL <> 'SIN CORREO' )

			SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))
		END
	ELSE
		BEGIN
			SELECT  @VP_RECIPIENTS	=	CORREO_USUARIO_PEARL
										FROM	BD_GENERAL.dbo.USUARIO_PEARL (NOLOCK)
										INNER	JOIN [8D] (NOLOCK)  ON [8D].K_USUARIO_ALTA = USUARIO_PEARL.K_USUARIO_PEARL
										WHERE 	[K_8D] = @PP_K_8D
										AND ( CORREO_USUARIO_PEARL <> '' OR CORREO_USUARIO_PEARL <> 'SIN CORREO' )
		END

	IF RTRIM(LTRIM(@VP_RECIPIENTS)) <> ''
		BEGIN
			DECLARE @VP_USUARIO_PEARL VARCHAR(100) = ''
			SELECT @VP_USUARIO_PEARL = D_USUARIO_PEARL
			FROM	BD_GENERAL.dbo.USUARIO_PEARL (NOLOCK)
			INNER	JOIN [8D] (NOLOCK)  ON [8D].K_USUARIO_ALTA = USUARIO_PEARL.K_USUARIO_PEARL
			WHERE 	[K_8D] = @PP_K_8D 

			DECLARE @VP_BODY		NVARCHAR(MAX) 
			SET @VP_BODY = N'<table  border="1" align="center" cellspacing="0">' + 
											N'<thead>' + 
											  N'<tr BGCOLOR="#ADD8E6">' + 
											    N'<th colspan="5">'+@PP_TITULO+'</th>' + 
											  N'</tr>' + 
											  N'<tr BGCOLOR="#48D1CC">' + 
											    N'<th>ID 8D</th><th>Product/Process</th><th>Date Opened</th><th>Due Date</th><th>Created By</th>' + 
											  N'</tr>' + 
											N'</thead>' + 
											N'<tbody>' + 
								  N'<tr>' + 
								  N'<td>'+ @PP_K_8D_PEARL +'</td><td>'+ @PP_PRODUCTO +'</td><td>'+ CONVERT(VARCHAR(10),@PP_F_APERTURA) +'</td><td>'+ CONVERT(VARCHAR(10),@PP_F_CIERRE_ESTIMADO) +'</td><td>'+ CONVERT(VARCHAR(100),@VP_USUARIO_PEARL) +'</td>' + 
								  N'</tr>' + 
								N'</tbody>' + 
							N'</table>' ;
							SET ROWCOUNT 0
			 				
			EXECUTE	BD_GENERAL.[dbo].[PG_ENVIAR_CORREO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@VP_RECIPIENTS, @PP_SUBJECT, @VP_BODY
		END
	-- ////////////////////////////////////////////////////////////////////
GO



-- ////////////////////////////////////////////////////////////// 
-- // SP PARA OBTENER LAS ORDENES ABIERTAS
-- ////////////////////////////////////////////////////////////// 

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_8D_ABIERTA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_8D_ABIERTA]
GO

-- EXEC [dbo].[PG_GET_8D_ABIERTA] 0, 144, 1

CREATE PROCEDURE [dbo].[PG_GET_8D_ABIERTA]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_ESTATUS_8D					INT
AS

	DECLARE @VP_MENSAJE		VARCHAR(255) = ''

	-- ///////////////////////////////////////////
	DECLARE @VP_N_8D_ABIERTA INT = 0
	SELECT @VP_N_8D_ABIERTA = COUNT(K_8D) 
	FROM [8D] (NOLOCK)
	WHERE K_ESTATUS_8D = @PP_K_ESTATUS_8D --#1 ACTIVA
	AND	EXTERNAL_FORMAT = 0
	AND DATE_CLOSED IS NULL

	IF @VP_N_8D_ABIERTA IS NULL
		SET @VP_N_8D_ABIERTA = 0

	IF @VP_N_8D_ABIERTA > 0
		BEGIN
			-- /////////SE DECLARAN LAS VARIABLES//////////////////////////////////
			DECLARE @VP_K_8D INT = 0, @VP_K_8D_PEARL VARCHAR(50) = '', @VP_TITULO VARCHAR(MAX) = '', @VP_F_OPENED DATE;
			DECLARE @VP_PRODUCTO VARCHAR(MAX) = '', @VP_F_ESTIMADO_CIERRE DATE, @VP_F_ACTUAL DATE = GETDATE(), @VP_SUBJECT	VARCHAR(255) = '';

			-- /////////SE CREA CURSOR PARA RECORRER LAS 8D ABIERTAS//////////////////////////////////
			DECLARE CU_8D_ABIERTA CURSOR 
			FOR SELECT	[K_8D],
						[K_8D_PEARL],
						[TITLE],
						[PRODUCT_PROCESS],
						[DATE_OPENED],
						[DUE_DATE]
				FROM	[8D]
				WHERE K_ESTATUS_8D = @PP_K_ESTATUS_8D -- ACTIVA
				AND	EXTERNAL_FORMAT = 0
				AND DATE_CLOSED IS NULL
			
			OPEN CU_8D_ABIERTA
			FETCH NEXT FROM CU_8D_ABIERTA INTO @VP_K_8D, @VP_K_8D_PEARL, @VP_TITULO, @VP_PRODUCTO, @VP_F_OPENED, @VP_F_ESTIMADO_CIERRE
			
			WHILE @@FETCH_STATUS = 0
				BEGIN
					-- /////////SE OBTIENE LA DIFERENCIA DE DIAS ENTRE LA FECHA ACTUAL Y LA FECHA DE CREACION//////////////////////////////////
					DECLARE @VP_N_DIA_ABIERTA INT = 0
					SET @VP_N_DIA_ABIERTA = DATEDIFF(DAY, @VP_F_OPENED, @VP_F_ACTUAL);

					IF @VP_N_DIA_ABIERTA > 0
						BEGIN
							-- /////////SE VALIDA QUE LAS 3 PRIMERAS SECCIONES DE LA 8D ESTEN COMPLETADAS//////////////////////////////////
							DECLARE @VP_SECCION_OBLIGATORIA_COMPLETADA INT = 1
							DECLARE @VP_N_SECCION_TEAM	INT = 0,  @VP_N_SECCION_PROBLEM	INT = 0

							DECLARE @VP_N_SECCION_SINTOMA	INT = 0
							SELECT @VP_N_SECCION_SINTOMA = COUNT([K_8D_SYMPTOM])
							FROM [8D_SYMPTOM] (NOLOCK)
							WHERE K_8D = @VP_K_8D

							IF @VP_N_SECCION_SINTOMA IS NULL OR @VP_N_SECCION_SINTOMA = 0
								SET @VP_SECCION_OBLIGATORIA_COMPLETADA = 0
								
							
							IF @VP_SECCION_OBLIGATORIA_COMPLETADA = 1
								BEGIN
									SET @VP_N_SECCION_TEAM	= 0
									SELECT @VP_N_SECCION_TEAM = COUNT([K_8D_TEAM])
									FROM [8D_TEAM] (NOLOCK)
									WHERE K_8D = @VP_K_8D

									IF @VP_N_SECCION_TEAM IS NULL OR @VP_N_SECCION_TEAM = 0
										SET @VP_SECCION_OBLIGATORIA_COMPLETADA = 0
								END

							IF @VP_SECCION_OBLIGATORIA_COMPLETADA = 1
								BEGIN
									SET @VP_N_SECCION_PROBLEM = 0
									SELECT @VP_N_SECCION_PROBLEM = COUNT([K_8D_PROBLEM])
									FROM [8D_PROBLEM] (NOLOCK)
									WHERE K_8D = @VP_K_8D

									IF @VP_N_SECCION_PROBLEM IS NULL OR @VP_N_SECCION_PROBLEM = 0
										SET @VP_SECCION_OBLIGATORIA_COMPLETADA = 0
								END
															
							-- /////////SE NOTIFICA AL LAS PERSONAS INVOLUCRADAS LA 8D NO TIENE COMPLETADA LAS 3 PRIMERAS SECCIONES O SI YA VA AVENCER EL TIEMPO ESTIMADO//////////////////////////////////
							IF @VP_SECCION_OBLIGATORIA_COMPLETADA = 0
								BEGIN
									SET @VP_SUBJECT = '8D awaiting information in the first 3 sections.'
									EXECUTE	[dbo].[PG_NOTIFICACION_PARA_COMPLETAR_8D]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																						@VP_K_8D, @VP_K_8D_PEARL, @VP_TITULO, @VP_PRODUCTO,
																						@VP_F_OPENED, @VP_F_ESTIMADO_CIERRE,
																						@VP_SUBJECT, @VP_N_SECCION_TEAM
								END
							ELSE
								BEGIN
									DECLARE @VP_N_DIA_CIERRE INT = 0
									SET @VP_N_DIA_CIERRE = DATEDIFF(DAY, @VP_F_ACTUAL, @VP_F_ESTIMADO_CIERRE);

									IF @VP_N_DIA_CIERRE < 6
										BEGIN
											SET @VP_SUBJECT = '8D open with closing date to expire.'
											EXECUTE	[dbo].[PG_NOTIFICACION_PARA_COMPLETAR_8D]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																								@VP_K_8D, @VP_K_8D_PEARL, @VP_TITULO, @VP_PRODUCTO,
																								@VP_F_OPENED, @VP_F_ESTIMADO_CIERRE,
																								@VP_SUBJECT, @VP_N_SECCION_TEAM
										END
								END
						END					

				FETCH NEXT FROM CU_8D_ABIERTA INTO  @VP_K_8D, @VP_K_8D_PEARL, @VP_TITULO, @VP_PRODUCTO, @VP_F_OPENED, @VP_F_ESTIMADO_CIERRE
				END
				
				CLOSE CU_8D_ABIERTA
				DEALLOCATE CU_8D_ABIERTA
		END
			
	-- //////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
