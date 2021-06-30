-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			LOT_COMP
-- // OPERATION:		PROCEDIMIENTOS ESPECIFICOS
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210224
-- ////////////////////////////////////////////////////////////// 

--USE [DATA_02Pruebas]
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> LI LOT_COMP
-- // SE UTILIZA EN:
-- //	1) LOT_COMP
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_LOTE_COMPATIBLE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_LOTE_COMPATIBLE]
GO
--		EXECUTE [dbo].[PG_LI_LOTE_COMPATIBLE]	0,139,'033101','FCMKTX7'		
--		EXECUTE [dbo].[PG_LI_LOTE_COMPATIBLE]	0,139,'033102','( TODOS )'		
--		EXECUTE [dbo].[PG_LI_LOTE_COMPATIBLE]	0,139,'','FCMKTX7'				
--		EXECUTE [dbo].[PG_LI_LOTE_COMPATIBLE]	0,139,'','( TODOS )'		

--		EXECUTE [dbo].[PG_LI_LOTE_COMPATIBLE]	0,139,''						
--		EXECUTE [dbo].[PG_LI_LOTE_COMPATIBLE]	0,139,'401031'					
CREATE PROCEDURE [dbo].[PG_LI_LOTE_COMPATIBLE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_LOTE					VARCHAR(10)
AS

	IF @PP_LOTE	= ''
	BEGIN
		SELECT	 ID									AS K_LOTE_COMPATIBLE
			,LTRIM(RTRIM(ITEM_NO))					AS D_ITEM
			,LTRIM(RTRIM(SER_LOT_NO1))				AS S_LOTE_COMPATIBLE_01
			,LTRIM(RTRIM(SER_LOT_NO2))				AS S_LOTE_COMPATIBLE_02
			,(CASE
				WHEN	LTRIM(RTRIM(COMP))	= 'Y'	THEN	'Si'
				ELSE	'No'
			END)									AS L_LOTE_COMPATIBLE
			--,COMP									AS L_LOTE_COMPATIBLE
			,LTRIM(RTRIM(Aut1))						AS A_LOTE_COMPATIBLE_01
			,LTRIM(RTRIM(Aut2))						AS A_LOTE_COMPATIBLE_02
			,LTRIM(RTRIM(Comments))					AS C_LOTE_COMPATIBLE
			,F_ALTA									AS F_LOTE_COMPATIBLE
		-- ===============================================================
		FROM	SER_LOT_COMP_SQL		(NOLOCK)
		-- ===============================================================
		WHERE	LTRIM(RTRIM(SER_LOT_NO1)) IN (
										SELECT	DISTINCT LTRIM(RTRIM(SER_LOT_NO))
										FROM	IMLSMST_SQL			(NOLOCK)
										WHERE	QTY_ON_HAND	> 0.0000
										AND		LTRIM(RTRIM(ITEM_NO))	LIKE 'F%'
												--ITEM_NO LIKE 'F%'
										AND (		LOC LIKE 'T%'
												OR	LTRIM(RTRIM(LOC))	IN ('MHI')				)
											)
		AND		LTRIM(RTRIM(SER_LOT_NO2))	IN	(
										SELECT	DISTINCT LTRIM(RTRIM(SER_LOT_NO))
										FROM	IMLSMST_SQL			(NOLOCK)
										WHERE	QTY_ON_HAND	> 0.0000
										AND		LTRIM(RTRIM(ITEM_NO))	LIKE 'F%'
												--ITEM_NO LIKE 'F%'
										AND (		LOC LIKE 'T%'
												OR	LTRIM(RTRIM(LOC))	IN ('MHI')				)								
											)
		ORDER BY	ITEM_NO		ASC, SER_LOT_NO1	DESC, SER_LOT_NO2	DESC
	END
	ELSE
	BEGIN
	
		SET	@PP_LOTE	= RIGHT('000000' + CONVERT(VARCHAR(10),Ltrim(Rtrim(@PP_LOTE))), 6)
		
		SELECT	 ID									AS K_LOTE_COMPATIBLE
				,LTRIM(RTRIM(ITEM_NO))					AS D_ITEM
				,LTRIM(RTRIM(SER_LOT_NO1))				AS S_LOTE_COMPATIBLE_01
				,LTRIM(RTRIM(SER_LOT_NO2))				AS S_LOTE_COMPATIBLE_02
				,(CASE
					WHEN	LTRIM(RTRIM(COMP))	= 'Y'	THEN	'Si'
					ELSE	'No'
				END)									AS L_LOTE_COMPATIBLE
				--,COMP									AS L_LOTE_COMPATIBLE
				,LTRIM(RTRIM(Aut1))						AS A_LOTE_COMPATIBLE_01
				,LTRIM(RTRIM(Aut2))						AS A_LOTE_COMPATIBLE_02
				,LTRIM(RTRIM(Comments))					AS C_LOTE_COMPATIBLE
				,F_ALTA									AS F_LOTE_COMPATIBLE
		-- ===============================================================
		FROM	SER_LOT_COMP_SQL					(NOLOCK)
		-- ===============================================================
		WHERE	(		LTRIM(RTRIM(SER_LOT_NO1))	= @PP_LOTE 
					OR	LTRIM(RTRIM(SER_LOT_NO2))	= @PP_LOTE		)
		---- ===============================================================
		ORDER BY	ITEM_NO, SER_LOT_NO1	DESC
	END
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SK LOT_COMP
-- // SE UTILIZA EN:
-- //	1) LOT_COMP
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_LOTE_COMPATIBLE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_LOTE_COMPATIBLE]
GO
--		 EXECUTE [dbo].[PG_SK_LOTE_COMPATIBLE]	0,139,	70941
CREATE PROCEDURE [dbo].[PG_SK_LOTE_COMPATIBLE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ID_LOTE					INT
AS	
		SELECT	TOP(1) 
				ID										AS K_LOTE_COMPATIBLE
				,LTRIM(RTRIM(ITEM_NO))					AS D_ITEM
				,LTRIM(RTRIM(SER_LOT_NO1))				AS S_LOTE_COMPATIBLE_01
				,LTRIM(RTRIM(SER_LOT_NO2))				AS S_LOTE_COMPATIBLE_02
				,(CASE
					WHEN	LTRIM(RTRIM(COMP))	= 'Y'	THEN	1
					ELSE	0
				END)									AS L_LOTE_COMPATIBLE
				,LTRIM(RTRIM(Aut1))						AS A_LOTE_COMPATIBLE_01
				,LTRIM(RTRIM(Aut2))						AS A_LOTE_COMPATIBLE_02
				,LTRIM(RTRIM(Comments))					AS C_LOTE_COMPATIBLE
				,DBO.CONVERT_INT_TO_DATE(Cdate)			AS F_LOTE_COMPATIBLE
		-- ===============================================================
		FROM	SER_LOT_COMP_SQL			(NOLOCK)
		-- ===============================================================
		WHERE	ID		=	@PP_ID_LOTE
		---- ===============================================================
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SK LOT_COMP, PARA OBTENER TODOS LOS 
-- //						LOTES COMPATIBLES CON @PP_LOTE
-- // SE UTILIZA EN:
-- //	1) LOT_COMP
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_LOTE_COMPATIBLE_DETALLE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_LOTE_COMPATIBLE_DETALLE]
GO
--		 EXECUTE [dbo].[PG_SK_LOTE_COMPATIBLE_DETALLE]	0,139,	'401031','401071'
CREATE PROCEDURE [dbo].[PG_SK_LOTE_COMPATIBLE_DETALLE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_LOTE					VARCHAR(10),
	@PP_LOTE_02					VARCHAR(10)

AS	

	SET	@PP_LOTE	= RIGHT('000000' + CONVERT(VARCHAR(10),Ltrim(Rtrim(@PP_LOTE))), 6)
	SET	@PP_LOTE_02	= RIGHT('000000' + CONVERT(VARCHAR(10),Ltrim(Rtrim(@PP_LOTE_02))), 6)

	DECLARE	@PP_TABLA_LOTES				AS TABLE
			(	 TA_LOTE_ID				INT
				,TA_LOTE_SERIE			VARCHAR(10)
				,TA_LOTE_L				INT
				,TA_LOTE_AUTORIZA_01	VARCHAR(250)
				,TA_LOTE_K_USUARIO_01	VARCHAR(250)
				,TA_LOTE_AUTORIZA_02	VARCHAR(250)
				,TA_LOTE_K_USUARIO_02	VARCHAR(250)
				,TA_LOTE_C				VARCHAR(250)
				,TA_L_COMENTARIO		INT
			)
---===================================================================================================================================================
---===================================================================================================================================================
---===================================================================================================================================================
---===================================================================================================================================================	
	DECLARE	 @VP_CU_ID_LOTE_COMPATIBLE			INT
			-- =====================================================
			,@VP_CU_D_ITEM						VARCHAR(25)
			-- =====================================================
			,@VP_CU_S_LOTE_COMPATIBLE_01		VARCHAR(10)
			,@VP_CU_S_LOTE_COMPATIBLE_02		VARCHAR(10)
			-- =====================================================
			,@VP_CU_L_LOTE_COMPATIBLE			VARCHAR(10)
			,@VP_CU_A_LOTE_COMPATIBLE_01		VARCHAR(250)
			,@VP_CU_A_LOTE_COMPATIBLE_02		VARCHAR(250)
			,@VP_CU_K_LOTE_COMPATIBLE_01		INT
			,@VP_CU_K_LOTE_COMPATIBLE_02		INT
			-- =====================================================
			,@VP_CU_C_LOTE_COMPATIBLE			VARCHAR(250)


	DECLARE CU_COMPATIBLES CURSOR FOR  
		SELECT	 ID										--AS K_LOTE_COMPATIBLE		
				,LTRIM(RTRIM(ITEM_NO))					--AS D_ITEM
				,LTRIM(RTRIM(SER_LOT_NO1))				--AS S_LOTE_COMPATIBLE_01
				,LTRIM(RTRIM(SER_LOT_NO2))				--AS S_LOTE_COMPATIBLE_02
				,(CASE
					WHEN	LTRIM(RTRIM(COMP))	= 'Y'	THEN	1
					ELSE	0
				END)									--AS L_LOTE_COMPATIBLE
				,LTRIM(RTRIM(Aut1))						--AS A_LOTE_COMPATIBLE_01
				,LTRIM(RTRIM(Aut2))						--AS A_LOTE_COMPATIBLE_02
				,K_USUARIO_PEARL_01
				,K_USUARIO_PEARL_02
				,LTRIM(RTRIM(Comments))					--AS C_LOTE_COMPATIBLE
		-- ===============================================================
		FROM	SER_LOT_COMP_SQL					(NOLOCK)
		-- ===============================================================
		WHERE	(		LTRIM(RTRIM(SER_LOT_NO1))	= @PP_LOTE  
					OR	LTRIM(RTRIM(SER_LOT_NO2))	= @PP_LOTE 		)
		--AND		(		LTRIM(RTRIM(SER_LOT_NO1))	= @PP_LOTE  
		--			OR	LTRIM(RTRIM(SER_LOT_NO2))	= @PP_LOTE_02 		)
		---- ===============================================================
	OPEN			CU_COMPATIBLES;  
	FETCH NEXT FROM CU_COMPATIBLES INTO		@VP_CU_ID_LOTE_COMPATIBLE		,@VP_CU_D_ITEM
											,@VP_CU_S_LOTE_COMPATIBLE_01	,@VP_CU_S_LOTE_COMPATIBLE_02
											,@VP_CU_L_LOTE_COMPATIBLE			
											,@VP_CU_A_LOTE_COMPATIBLE_01	,@VP_CU_A_LOTE_COMPATIBLE_02		
											,@VP_CU_K_LOTE_COMPATIBLE_01	,@VP_CU_K_LOTE_COMPATIBLE_02		
											,@VP_CU_C_LOTE_COMPATIBLE		
	WHILE @@FETCH_STATUS = 0  
	   BEGIN
			DECLARE	 @VP_IN_LOTE_SERIE		VARCHAR(10)	= ''
			

			IF @PP_LOTE	= @VP_CU_S_LOTE_COMPATIBLE_01
			BEGIN
				SET	@VP_IN_LOTE_SERIE	= @VP_CU_S_LOTE_COMPATIBLE_02
			END
			ELSE IF @PP_LOTE	= @VP_CU_S_LOTE_COMPATIBLE_02
			BEGIN
				SET	@VP_IN_LOTE_SERIE	= @VP_CU_S_LOTE_COMPATIBLE_01
			END

			-- /////////////////////////////////////////////////////////////////////				
				INSERT INTO @PP_TABLA_LOTES	(
					TA_LOTE_ID		
					,TA_LOTE_SERIE	
					,TA_LOTE_L
					,TA_LOTE_AUTORIZA_01
					,TA_LOTE_K_USUARIO_01
					,TA_LOTE_AUTORIZA_02
					,TA_LOTE_K_USUARIO_02
					,TA_LOTE_C
					,TA_L_COMENTARIO						
				)	VALUES	(
					@VP_CU_ID_LOTE_COMPATIBLE
					,@VP_IN_LOTE_SERIE
					,@VP_CU_L_LOTE_COMPATIBLE
					,@VP_CU_A_LOTE_COMPATIBLE_01
					,@VP_CU_K_LOTE_COMPATIBLE_01
					,@VP_CU_A_LOTE_COMPATIBLE_02
					,@VP_CU_K_LOTE_COMPATIBLE_02
					,@VP_CU_C_LOTE_COMPATIBLE
					,0
				)
			-- /////////////////////////////////////////////////////////////////////

		FETCH NEXT FROM CU_COMPATIBLES INTO		 @VP_CU_ID_LOTE_COMPATIBLE		,@VP_CU_D_ITEM
												,@VP_CU_S_LOTE_COMPATIBLE_01	,@VP_CU_S_LOTE_COMPATIBLE_02
												,@VP_CU_L_LOTE_COMPATIBLE			
												,@VP_CU_A_LOTE_COMPATIBLE_01	,@VP_CU_A_LOTE_COMPATIBLE_02		
												,@VP_CU_K_LOTE_COMPATIBLE_01	,@VP_CU_K_LOTE_COMPATIBLE_02		
												,@VP_CU_C_LOTE_COMPATIBLE
	   END;  
	CLOSE		CU_COMPATIBLES;  
	DEALLOCATE	CU_COMPATIBLES;  

	SELECT
		 TA_LOTE_ID				AS	K_LOTE_COMPATIBLE
		,TA_LOTE_SERIE			AS	S_LOTE_COMPATIBLE
		,TA_LOTE_L				AS	L_LOTE_COMPATIBLE
		,TA_LOTE_AUTORIZA_01	AS	A_LOTE_COMPATIBLE_01
		,TA_LOTE_K_USUARIO_01	AS	K_LOTE_USUARIO_01		
		,TA_LOTE_AUTORIZA_02	AS	A_LOTE_COMPATIBLE_02
		,TA_LOTE_K_USUARIO_02	AS	K_LOTE_USUARIO_02		
		,TA_LOTE_C				AS	C_LOTE_COMPATIBLE
		,TA_L_COMENTARIO		AS	L_COMENTARIO
	FROM @PP_TABLA_LOTES	
	WHERE	(		LTRIM(RTRIM(TA_LOTE_SERIE))	<> @PP_LOTE_02	)
	ORDER	BY		TA_LOTE_SERIE	DESC
		-- ===============================================================
		-- ===============================================================
	-- ////////////////////////////////////////////////////////////////////
GO


-- ////////////////////////////////////////////////////////////////
-- //	PARA INSERTAR EL LOG DE COMPATIBILIDAD EN EL SISTEMA.
-- ///////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_SER_LOT_COMP_SQL_LOG]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_SER_LOT_COMP_SQL_LOG]
GO
CREATE PROCEDURE [dbo].[PG_IN_SER_LOT_COMP_SQL_LOG]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_ITEM_NO							VARCHAR	(25),
	@PP_SER_LOT_NO_1					VARCHAR	(10),
	@PP_SER_LOT_NO_2					VARCHAR	(10),
	@PP_COMP							VARCHAR	(10),
	@PP_AUT1							VARCHAR	(250),
	@PP_AUT2							VARCHAR	(250),
	@PP_K_USUARIO_PEARL_01				INT,
	@PP_K_USUARIO_PEARL_02				INT,
	@PP_COMMENTS						VARCHAR	(500),
	@PP_ACCION_REALIZADA				VARCHAR (100)		
AS
DECLARE		 @VP_MENSAJE				NVARCHAR(MAX) = ''
	-- /////////////////////////////////////////////////////////////////////
	--		SE REALIZA EL INSERT DE REGISTROS
	INSERT INTO [dbo].[SER_LOT_COMP_SQL_LOG] 
	(
		[ITEM_NO]							,
		[SER_LOT_NO_1]						,
		[SER_LOT_NO_2]						,
		[COMP]								,
		[AUT1]								,
		[AUT2]								,
		[K_USUARIO_PEARL_01]				,
		[K_USUARIO_PEARL_02]				,
		[COMMENTS]							,
		[ACCION_REALIZADA]					
		-- ===========================
		,[K_USUARIO_ALTA]	,[F_ALTA]		)
		VALUES	(
		@PP_ITEM_NO							,
		@PP_SER_LOT_NO_1					,
		@PP_SER_LOT_NO_2					,
		@PP_COMP							,
		@PP_AUT1							,
		@PP_AUT2							,
		@PP_K_USUARIO_PEARL_01				,
		@PP_K_USUARIO_PEARL_02				,
		@PP_COMMENTS						,
		@PP_ACCION_REALIZADA				,
		-- ===========================
		@PP_K_USUARIO_ACCION	,GETDATE()
	)
			
	IF @@ROWCOUNT = 0
	BEGIN
		SET @VP_MENSAJE='El LOG del registro no fue ingresado. Lotes: ' + @PP_SER_LOT_NO_1	+ ' y '+	@PP_SER_LOT_NO_2 + ', para el ITEM [' + @PP_ITEM_NO + ']'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
GO

-- ////////////////////////////////////////////////////////////////
-- //	CUERPO DEL MENSAJA A ENVIAR CUANDO UN MATERIAL
-- //	SE LE HA REALIZADO LA COMPATIBILIDAD O MODIFICADO LA MISMA.
-- ///////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CORREO_COMPATIBILIDAD_LOTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CORREO_COMPATIBILIDAD_LOTE]
GO
CREATE PROCEDURE [dbo].[PG_CORREO_COMPATIBILIDAD_LOTE]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_ITEM_NO							VARCHAR(25),
	@PP_LOTE							VARCHAR(25),
	@TBL_LOTE_COMPATIBLES				TB_Lotes	READONLY
AS
	-- ///////////////////////////////////////////
	DECLARE @VP_SUBJECT					VARCHAR(255) = '[COMPATIBILIDAD LOTE] Item: '+ @PP_ITEM_NO +' // LOTE: ' + @PP_LOTE
			,@VP_RECIPIENTS				NVARCHAR(MAX)	= ''
			,@VP_BODY_HTML				NVARCHAR(MAX)	= ''
			,@VP_K_TIPO_GRUPO_APROBADOR	VARCHAR(15)	=	9200

	IF @PP_K_SISTEMA_EXE=0
	BEGIN
		SET @VP_K_TIPO_GRUPO_APROBADOR	= 0			--	 AQUI VAN LOS USUARIOS DE CALIDAD
	END

	SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
								FROM	BD_GENERAL.dbo.USUARIO_PEARL			(NOLOCK)	AS USERS
								INNER	JOIN	BD_GENERAL.dbo.GRUPO_APROBADOR	(NOLOCK)	ON GRUPO_APROBADOR.K_USUARIO=USERS.K_USUARIO_PEARL
								WHERE	GRUPO_APROBADOR.K_TIPO_GRUPO_APROBADOR = @VP_K_TIPO_GRUPO_APROBADOR
								AND		K_ESTATUS_GRUPO_APROBADOR = 1

	SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))

	DECLARE  @PP_AUTORIZA_01	VARCHAR(250)
			,@PP_AUTORIZA_02	VARCHAR(250)
		
		SELECT TOP(1) @PP_AUTORIZA_01=	AUTORIZA_01 FROM @TBL_LOTE_COMPATIBLES
		SELECT TOP(1) @PP_AUTORIZA_02=	AUTORIZA_02 FROM @TBL_LOTE_COMPATIBLES

	SET @VP_BODY_HTML = 
		N'<html>'+
		N'<head>'+
		--N'<style type="text/css">'+
		--N'table{border: solid 1px;border-collapse:collapse;} td{text-align:"center";}.izq{text-align:left}'+
		--N'th{text-align:"center";  background:"#ADD8E6"; color:"#ffffff";}'+
		--N'tr{text-align:"center";  background:"#48D1CC"; color:"#ffffff";}</style>' +
		
		N'<style>'+
		N'table	{border: solid 1px;border-collapse:collapse; width: 75%; cellspacing="1"}'+
		N'th	{border: solid 1px;padding: 3px;text-align: "center";background:"#ADD8E6"; color:"#000000"}'+
		N'td	{border: solid 1px;padding: 3px;text-align: "center";background:"#48D1CC"; color:"#000000"}'+
		N'</style>'+
				
		N'</head>'+
		N'<body>'+

		N'<p style="color:black; font-size:14.0pt;font-family:"Calisto MT",serif">'+
		N'Se ha realizado una adición/modificación de compatibilidad de Lotes, del [ITEM] indicado en el asunto del correo.<br>'+		
		N'La autorización la han realizado los usuarios: <br>'+		

		N'<ul>'	+
			N'<li><b>' +  @PP_AUTORIZA_01 +
			N'</b></li>' +
			N'<li><b>' + @PP_AUTORIZA_02 +
			N'</b></li>' +
		N'</ul>' +

		N'<table>' +
			N'<thead>' + 
			  N'<tr>' + 
			    N'<th colspan="4">Registros Afectados:</th>' + 
			  N'</tr>' + 
			  N'<tr>' +
				N'	<th width: 20%>   Lote(s)				</th>	
					<th width: 10%>   Es Compatible			</th>
					<th width: 10%>   Acción Realizada		</th>
					<th width: 35%>   Comentario			</th>' + 
					--<th width: 25%>   Usario Autoriza 01	</th>
					--<th width: 25%>   Usario Autoriza 02	</th>	
			  N'</tr>' + 
			N'</thead>' + 
			N'<tbody>' + 
				--N'<tr>'+	
				CAST ( (	SELECT	
								td	= LOTE_02			,	'        ',
								td	= (CASE	
										WHEN	COMPATIBLE = 1	THEN	'SI'
										ELSE	'NO'
										END)			,'        ',
								--td	= AUTORIZA_01		+ '      ','        ',
								--td	= AUTORIZA_02		+ '      ','        ',
								td	= ACCIÓN_REALIZADA	,	'        ',
								td	= COMENTARIO
							FROM		@TBL_LOTE_COMPATIBLES
			         FOR XML PATH('tr'), elements, TYPE   
				) AS NVARCHAR(MAX) ) +  
				--N'</tr>' + 
			N'</tbody>' + 
		N'</table>'+
		N'</body>'+
		N'</html>';
			SET ROWCOUNT 0
		 				
		DECLARE @VP_IMPORTANCE	VARCHAR(50)


		EXEC msdb.dbo.sp_send_dbmail @recipients=@VP_RECIPIENTS,
		--@blind_copy_recipients='ALEJANDROD@PEARLLEATHER.COM.MX',
		@subject = @VP_SUBJECT,
		@body = @VP_BODY_HTML,  
		@body_format = 'HTML',
		@importance= 'NORMAL'
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> IN_LOTE_COMPATIBLE PRINCIPAL
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_ENVIAR_CORREO_X_INSERT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_ENVIAR_CORREO_X_INSERT]
GO
--		 EXECUTE [dbo].[PG_ENVIAR_CORREO_X_INSERT]	0,139,	'019941'
CREATE PROCEDURE [dbo].[PG_ENVIAR_CORREO_X_INSERT]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ITEM_NO					VARCHAR(25),
	@PP_LOTE_01					VARCHAR(10),
	@PP_LOTE_02					VARCHAR(10),
	-- ===========================
	@PP_L_COMPATIBLE			INT,
	@PP_COMENTARIO				VARCHAR(500),
	-- ===========================
	@PP_D_USUARIO_01			VARCHAR(250),
	@PP_D_USUARIO_02			VARCHAR(250),
	@PP_K_USUARIO_01			INT,
	@PP_K_USUARIO_02			INT,
	@PP_PASS_USUARIO_01			VARCHAR(25),
	@PP_PASS_USUARIO_02			VARCHAR(25),
	-- ===========================
	@PP_L_AGREGAR_MULTIPLES		INT,
	@PP_ARRAY_LOTE_02			NVARCHAR(MAX),
	@PP_ARRAY_COMPATI			NVARCHAR(MAX),
	@PP_ARRAY_COMENTA			NVARCHAR(MAX)
AS
	---============================================================
	--	SE CREA LA TABLA PARA INGRESAR LOS REGISTROS AGREGADOS A COMPATIBILIDAD DE LOTE.
	IF (    SELECT COUNT(*) FROM sys.table_types
	        WHERE name = 'TB_Lotes' AND schema_id = 1    ) = 0
	BEGIN
	        CREATE TYPE TB_Lotes	AS TABLE(	LOTE_02					VARCHAR(25),
												COMPATIBLE				VARCHAR(10),
												AUTORIZA_01				VARCHAR(250),
												AUTORIZA_02				VARCHAR(250),		
												COMENTARIO				VARCHAR(500),		
												ACCIÓN_REALIZADA		VARCHAR(50)			)
	END
	--DECLARE @PP_L_COMPATIBLE_CORREO	AS VARCHAR(10)	= 'NO'
	--IF @PP_L_COMPATIBLE	= 1
		--	SET	@PP_L_COMPATIBLE_CORREO	= 'SI'
	
	IF	@PP_L_AGREGAR_MULTIPLES	= 0
	BEGIN
		DECLARE @TBL_LOTE_COMPATIBLES		AS	TB_Lotes
		
		INSERT INTO  @TBL_LOTE_COMPATIBLES
		VALUES
		(	@PP_LOTE_02,	@PP_L_COMPATIBLE,	@PP_D_USUARIO_01,	@PP_D_USUARIO_02,	@PP_COMENTARIO,		'Agregado.'	)
	END
	ELSE IF @PP_L_AGREGAR_MULTIPLES	= 1
	BEGIN
	---===================================================================================================================================================
	---===================================================================================================================================================
	---===================================================================================================================================================	
		DECLARE  @VP_POSICION_LOTE_02		INT
				,@VP_POSICION_COMPATI		INT
				,@VP_POSICION_COMENTA		INT 
		DECLARE  @VP_VALOR_LOTE_02			VARCHAR(500)
				,@VP_VALOR_COMPATI			VARCHAR(500)
				,@VP_VALOR_COMENTA			VARCHAR(500)
		--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
		SET	@PP_ARRAY_LOTE_02		= @PP_ARRAY_LOTE_02		+ '/'
		SET	@PP_ARRAY_COMPATI		= @PP_ARRAY_COMPATI		+ '/'
		SET	@PP_ARRAY_COMENTA		= @PP_ARRAY_COMENTA		+ '/'	
	
		--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
		WHILE patindex('%/%' , @PP_ARRAY_LOTE_02) <> 0
			BEGIN
				SELECT @VP_POSICION_LOTE_02	=	patindex('%/%' , @PP_ARRAY_LOTE_02	)
				SELECT @VP_POSICION_COMPATI	=	patindex('%/%' , @PP_ARRAY_COMPATI	)
				SELECT @VP_POSICION_COMENTA	=	patindex('%/%' , @PP_ARRAY_COMENTA	)
	
				--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
				SELECT @VP_VALOR_LOTE_02		= LEFT(@PP_ARRAY_LOTE_02		, @VP_POSICION_LOTE_02	- 1)
				SELECT @VP_VALOR_COMPATI		= LEFT(@PP_ARRAY_COMPATI		, @VP_POSICION_COMPATI	- 1)
				SELECT @VP_VALOR_COMENTA		= LEFT(@PP_ARRAY_COMENTA		, @VP_POSICION_COMENTA	- 1)
					
					---- /////////////////////////////////////////////////////////////////////
					-- SE DA FORMATO AL LOTE PARA INCLUIR LOS 0 FALTANTES. Y ASIGNAR EL VALOR A LA COMPATIBILIDAD.(DE INT A VARCHAR)
					SET	@VP_VALOR_LOTE_02	= RIGHT('000000' + CONVERT(VARCHAR(10),Ltrim(Rtrim(@VP_VALOR_LOTE_02))), 6)
					
					---- /////////////////////////////////////////////////////////////////////
					--		SE REALIZA EL INSERT DE REGISTROS
						INSERT INTO  @TBL_LOTE_COMPATIBLES
						VALUES
						(	@VP_VALOR_LOTE_02,	@VP_VALOR_COMPATI,	@PP_D_USUARIO_01,	@PP_D_USUARIO_02,	@VP_VALOR_COMENTA,		'Agregado.'	)
					---- /////////////////////////////////////////////////////////////////////
	
				--Reemplazamos lo procesado con nada con la funcion stuff
				SELECT @PP_ARRAY_LOTE_02= STUFF(@PP_ARRAY_LOTE_02 , 1, @VP_POSICION_LOTE_02, '')
				SELECT @PP_ARRAY_COMPATI= STUFF(@PP_ARRAY_COMPATI , 1, @VP_POSICION_COMPATI, '')
				SELECT @PP_ARRAY_COMENTA= STUFF(@PP_ARRAY_COMENTA , 1, @VP_POSICION_COMENTA, '')
			END
	END
---===================================================================================================================================================
---===================================================================================================================================================
---===================================================================================================================================================
	EXECUTE		[dbo].[PG_CORREO_COMPATIBILIDAD_LOTE]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
														-- ===========================
														@PP_ITEM_NO,		@PP_LOTE_01,		@TBL_LOTE_COMPATIBLES
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> IN_LOTE_COMPATIBLE PRINCIPAL
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_ENVIAR_CORREO_X_UPDATE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_ENVIAR_CORREO_X_UPDATE]
GO
--		 EXECUTE [dbo].[PG_ENVIAR_CORREO_X_UPDATE]	0,139,														
 --				'71066' , 'FWLNPX7' , '401031' , '401071' , '1' , 'no compatibles' ,				
 --				'OMAR ALBERTO DECENA' , 'RODOLFO CARBAJAL' , '42' , '138' , '12340' , '79130' ,			
 --				'0' , '0' , '0' , '0' , '1' , '71067' , '401401' , '0' , 'COMPATIBLE'			


CREATE PROCEDURE [dbo].[PG_ENVIAR_CORREO_X_UPDATE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ITEM_NO					VARCHAR(25),
	@PP_LOTE_01					VARCHAR(10),
	@PP_LOTE_02					VARCHAR(10),
	-- ===========================
	@PP_L_COMPATIBLE			INT,
	@PP_COMENTARIO				VARCHAR(500),
	-- ===========================
	@PP_D_USUARIO_01			VARCHAR(250),
	@PP_D_USUARIO_02			VARCHAR(250),
	@PP_K_USUARIO_01			INT,
	@PP_K_USUARIO_02			INT,
	@PP_PASS_USUARIO_01			VARCHAR(25),
	@PP_PASS_USUARIO_02			VARCHAR(25),
	-- ===========================
	@PP_L_AGREGAR_MULTIPLES		INT,
	@PP_ARRAY_LOTE_02			NVARCHAR(MAX),
	@PP_ARRAY_COMPATI			NVARCHAR(MAX),
	@PP_ARRAY_COMENTA			NVARCHAR(MAX),
	-- ===========================
	@PP_L_MODIFICAR_COMPATIBLE	INT,
	@PP_ARRAY_K_ID_LOTE			NVARCHAR(MAX),
	@PP_ARRAY_S_LOTE_02			NVARCHAR(MAX),
	@PP_ARRAY_L_COMPATI			NVARCHAR(MAX),
	@PP_ARRAY_D_COMENTA			NVARCHAR(MAX)
AS
	---============================================================
	--	SE CREA LA TABLA PARA INGRESAR LOS REGISTROS AGREGADOS A COMPATIBILIDAD DE LOTE.
	IF (    SELECT COUNT(*) FROM sys.table_types
	        WHERE name = 'TB_Lotes' AND schema_id = 1    ) = 0
	BEGIN
	        CREATE TYPE TB_Lotes AS TABLE(	LOTE_02					VARCHAR(25),
											COMPATIBLE				VARCHAR(10),
											AUTORIZA_01				VARCHAR(250),
											AUTORIZA_02				VARCHAR(250),		
											COMENTARIO				VARCHAR(500),		
											ACCIÓN_REALIZADA		VARCHAR(50)			)
	END
	
	--drop type tb_lotes
	--DECLARE @PP_L_COMPATIBLE_CORREO	AS VARCHAR(10)	= 'NO'
	--IF @PP_L_COMPATIBLE	= 1
		--	SET	@PP_L_COMPATIBLE_CORREO	= 'SI'
	
	DECLARE @TBL_LOTE_COMPATIBLES		AS	TB_Lotes
	
	INSERT INTO  @TBL_LOTE_COMPATIBLES
	VALUES
	(	@PP_LOTE_02,	@PP_L_COMPATIBLE,	@PP_D_USUARIO_01,	@PP_D_USUARIO_02,	@PP_COMENTARIO,		'Modificado.'	)
---===================================================================================================================================================
---===================================================================================================================================================
---===================================================================================================================================================	
	IF @PP_L_AGREGAR_MULTIPLES	= 1
	BEGIN
		DECLARE  @VP_POSICION_LOTE_02		INT
				,@VP_POSICION_COMPATI		INT
				,@VP_POSICION_COMENTA		INT 
		DECLARE  @VP_VALOR_LOTE_02			VARCHAR(500)
				,@VP_VALOR_COMPATI			VARCHAR(500)
				,@VP_VALOR_COMENTA			VARCHAR(500)
		--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
		SET	@PP_ARRAY_LOTE_02		= @PP_ARRAY_LOTE_02		+ '/'
		SET	@PP_ARRAY_COMPATI		= @PP_ARRAY_COMPATI		+ '/'
		SET	@PP_ARRAY_COMENTA		= @PP_ARRAY_COMENTA		+ '/'	
	
		--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
		WHILE patindex('%/%' , @PP_ARRAY_LOTE_02) <> 0
			BEGIN
				SELECT @VP_POSICION_LOTE_02	=	patindex('%/%' , @PP_ARRAY_LOTE_02	)
				SELECT @VP_POSICION_COMPATI	=	patindex('%/%' , @PP_ARRAY_COMPATI	)
				SELECT @VP_POSICION_COMENTA	=	patindex('%/%' , @PP_ARRAY_COMENTA	)
	
				--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
				SELECT @VP_VALOR_LOTE_02		= LEFT(@PP_ARRAY_LOTE_02		, @VP_POSICION_LOTE_02	- 1)
				SELECT @VP_VALOR_COMPATI		= LEFT(@PP_ARRAY_COMPATI		, @VP_POSICION_COMPATI	- 1)
				SELECT @VP_VALOR_COMENTA		= LEFT(@PP_ARRAY_COMENTA		, @VP_POSICION_COMENTA	- 1)
					
					---- /////////////////////////////////////////////////////////////////////
					-- SE DA FORMATO AL LOTE PARA INCLUIR LOS 0 FALTANTES. Y ASIGNAR EL VALOR A LA COMPATIBILIDAD.(DE INT A VARCHAR)
					SET	@VP_VALOR_LOTE_02	= RIGHT('000000' + CONVERT(VARCHAR(10),Ltrim(Rtrim(@VP_VALOR_LOTE_02))), 6)
					
					---- /////////////////////////////////////////////////////////////////////
					--		SE REALIZA EL INSERT DE REGISTROS
						INSERT INTO  @TBL_LOTE_COMPATIBLES
						VALUES
						(	@VP_VALOR_LOTE_02,	@VP_VALOR_COMPATI,	@PP_D_USUARIO_01,	@PP_D_USUARIO_02,	@VP_VALOR_COMENTA,		'Agregado.'	)
					---- /////////////////////////////////////////////////////////////////////
	
				--Reemplazamos lo procesado con nada con la funcion stuff
				SELECT @PP_ARRAY_LOTE_02= STUFF(@PP_ARRAY_LOTE_02 , 1, @VP_POSICION_LOTE_02, '')
				SELECT @PP_ARRAY_COMPATI= STUFF(@PP_ARRAY_COMPATI , 1, @VP_POSICION_COMPATI, '')
				SELECT @PP_ARRAY_COMENTA= STUFF(@PP_ARRAY_COMENTA , 1, @VP_POSICION_COMENTA, '')
			END
	END
---===================================================================================================================================================
---===================================================================================================================================================
---===================================================================================================================================================	
	IF @PP_L_MODIFICAR_COMPATIBLE	= 1
	BEGIN
		DECLARE  @VP_POSICION_S_ID_LOTE		INT
				,@VP_POSICION_L_COMPATI		INT
				,@VP_POSICION_D_COMENTA		INT 
		DECLARE  @VP_VALOR_S_ID_LOTE			VARCHAR(500)
				,@VP_VALOR_L_COMPATI			VARCHAR(500)
				,@VP_VALOR_D_COMENTA			VARCHAR(500)
		--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
		SET	@PP_ARRAY_S_LOTE_02		= @PP_ARRAY_S_LOTE_02		+ '/'
		SET	@PP_ARRAY_L_COMPATI		= @PP_ARRAY_L_COMPATI		+ '/'
		SET	@PP_ARRAY_D_COMENTA		= @PP_ARRAY_D_COMENTA		+ '/'	
	
		--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
		WHILE patindex('%/%' , @PP_ARRAY_S_LOTE_02) <> 0
			BEGIN
				SELECT @VP_POSICION_S_ID_LOTE	=	patindex('%/%' , @PP_ARRAY_S_LOTE_02	)
				SELECT @VP_POSICION_L_COMPATI	=	patindex('%/%' , @PP_ARRAY_L_COMPATI	)
				SELECT @VP_POSICION_D_COMENTA	=	patindex('%/%' , @PP_ARRAY_D_COMENTA	)
	
				--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
				SELECT @VP_VALOR_S_ID_LOTE		= LEFT(@PP_ARRAY_S_LOTE_02		, @VP_POSICION_S_ID_LOTE	- 1)
				SELECT @VP_VALOR_L_COMPATI		= LEFT(@PP_ARRAY_L_COMPATI		, @VP_POSICION_L_COMPATI	- 1)
				SELECT @VP_VALOR_D_COMENTA		= LEFT(@PP_ARRAY_D_COMENTA		, @VP_POSICION_D_COMENTA	- 1)
					
					-- /////////////////////////////////////////////////////////////////////
					-- SE DA FORMATO AL LOTE PARA INCLUIR LOS 0 FALTANTES. Y ASIGNAR EL VALOR A LA COMPATIBILIDAD.(DE INT A VARCHAR)
					SET	@VP_VALOR_S_ID_LOTE	= RIGHT('000000' + CONVERT(VARCHAR(10),Ltrim(Rtrim(@VP_VALOR_S_ID_LOTE))), 6)
					
					---- /////////////////////////////////////////////////////////////////////
					--		SE REALIZA EL INSERT DE REGISTROS
						INSERT INTO  @TBL_LOTE_COMPATIBLES
						VALUES
						(	@VP_VALOR_S_ID_LOTE,	@VP_VALOR_L_COMPATI,	@PP_D_USUARIO_01,	@PP_D_USUARIO_02,	@VP_VALOR_D_COMENTA,	'Modificado.'	)
					-- /////////////////////////////////////////////////////////////////////
	
				--Reemplazamos lo procesado con nada con la funcion stuff
				SELECT @PP_ARRAY_S_LOTE_02= STUFF(@PP_ARRAY_S_LOTE_02 , 1, @VP_POSICION_S_ID_LOTE, '')
				SELECT @PP_ARRAY_L_COMPATI= STUFF(@PP_ARRAY_L_COMPATI , 1, @VP_POSICION_L_COMPATI, '')
				SELECT @PP_ARRAY_D_COMENTA= STUFF(@PP_ARRAY_D_COMENTA , 1, @VP_POSICION_D_COMENTA, '')
			END
	END
---===================================================================================================================================================
---===================================================================================================================================================
---===================================================================================================================================================
	EXECUTE		[dbo].[PG_CORREO_COMPATIBILIDAD_LOTE]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
														-- ===========================
														@PP_ITEM_NO,		@PP_LOTE_01,		@TBL_LOTE_COMPATIBLES
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> IN_LOTE_COMPATIBLE PRINCIPAL
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_ENVIAR_CORREO_X_DELETE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_ENVIAR_CORREO_X_DELETE]
GO
--		 EXECUTE [dbo].[PG_ENVIAR_CORREO_X_DELETE]	0,139,	'019941'
CREATE PROCEDURE [dbo].[PG_ENVIAR_CORREO_X_DELETE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ITEM_NO					VARCHAR(25),
	@PP_LOTE_01					VARCHAR(10),
	@PP_LOTE_02					VARCHAR(10),
	-- ===========================
	@PP_L_COMPATIBLE			INT,
	@PP_COMENTARIO				VARCHAR(500),
	-- ===========================
	@PP_D_USUARIO_01			VARCHAR(250),
	@PP_D_USUARIO_02			VARCHAR(250),
	@PP_K_USUARIO_01			INT,
	@PP_K_USUARIO_02			INT
AS
	---============================================================
	--	SE CREA LA TABLA PARA INGRESAR LOS REGISTROS AGREGADOS A COMPATIBILIDAD DE LOTE.
	IF (    SELECT COUNT(*) FROM sys.table_types
	        WHERE name = 'TB_Lotes' AND schema_id = 1    ) = 0
	BEGIN
	        CREATE TYPE TB_Lotes	AS TABLE(	LOTE_02					VARCHAR(25),
												COMPATIBLE				VARCHAR(10),
												AUTORIZA_01				VARCHAR(250),
												AUTORIZA_02				VARCHAR(250),		
												COMENTARIO				VARCHAR(500),		
												ACCIÓN_REALIZADA		VARCHAR(50)			)
	END

		DECLARE @TBL_LOTE_COMPATIBLES		AS	TB_Lotes
		
		INSERT INTO  @TBL_LOTE_COMPATIBLES
		VALUES
		(	@PP_LOTE_02,	@PP_L_COMPATIBLE,	@PP_D_USUARIO_01,	@PP_D_USUARIO_02,	@PP_COMENTARIO,		'Eliminado.'	)
---===================================================================================================================================================
---===================================================================================================================================================
---===================================================================================================================================================
	EXECUTE		[dbo].[PG_CORREO_COMPATIBILIDAD_LOTE]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
														-- ===========================
														@PP_ITEM_NO,		@PP_LOTE_01,		@TBL_LOTE_COMPATIBLES
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> VERIFICA PASSWORD DE USUARIOS
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_VERIFICA_PASSWORD_COMPATIBILIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_VERIFICA_PASSWORD_COMPATIBILIDAD]
GO
--		 EXECUTE [dbo].[PG_VERIFICA_PASSWORD_COMPATIBILIDAD]	0,139,	'019941'
CREATE PROCEDURE [dbo].[PG_VERIFICA_PASSWORD_COMPATIBILIDAD]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_USUARIO				INT,
	@PP_D_USUARIO				VARCHAR(250),
	@PP_PASS_USUARIO			VARCHAR(25)
AS
	DECLARE		 @VP_MENSAJE				NVARCHAR(MAX) = ''
			,@VP_USUARIO_CORRECTO		INT
			,@VP_K_EMPLEADO_PEARL		INT
	---============================================================
	--	SE VERIFICA QUE LOS USUARIOS QUE AUTORIZAN SE ENCUENTRAN REGISTRADOS EN EL SISTEMA Y ESTAN ACTUALMENTE ACTIVOS.
	SELECT	@VP_K_EMPLEADO_PEARL			=	K_EMPLEADO_PEARL
	FROM	BD_GENERAL.DBO.USUARIO_PEARL	(NOLOCK)
	WHERE	K_USUARIO_PEARL					= @PP_K_USUARIO

		IF	(	SELECT  COUNT(EN_NUM_EMP)
				FROM    BD_GENERAL.DBO.USUARIO_PEARL	(NOLOCK)
				LEFT JOIN HOWE.DBO.VISTA_GAFETES		(NOLOCK)	ON EN_NUM_EMP=K_EMPLEADO_PEARL
				WHERE	EN_NUM_EMP	=	@VP_K_EMPLEADO_PEARL					)	= 0
		BEGIN		
			SET		@VP_MENSAJE			= 'Hubo un Problema con la cuenta de [Usuario]. [' + @PP_D_USUARIO +']'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END

	SELECT	@VP_USUARIO_CORRECTO			= COUNT(K_USUARIO_PEARL)
	FROM	BD_GENERAL.DBO.USUARIO_PEARL	(NOLOCK)
	WHERE	K_USUARIO_PEARL					= @PP_K_USUARIO
	AND		PASSWORD_USUARIO_PEARL			= @PP_PASS_USUARIO

	IF @VP_USUARIO_CORRECTO <= 0
	BEGIN
		SET @VP_MENSAJE='La contraseña del usuario [' +	@PP_D_USUARIO	+ '] es incorrecta, verifique y vuelva a intentar...'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> VERIFICA COMPATIBILIDAD USUARIOS
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_VERIFICA_LOTE_COMPATIBILIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_VERIFICA_LOTE_COMPATIBILIDAD]
GO
--		 EXECUTE [dbo].[PG_VERIFICA_LOTE_COMPATIBILIDAD]	0,139,	'019941'
CREATE PROCEDURE [dbo].[PG_VERIFICA_LOTE_COMPATIBILIDAD]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ITEM_NO					VARCHAR(25),
	@PP_LOTE_01					VARCHAR(10),
	@PP_LOTE_02					VARCHAR(10)
AS
DECLARE		 @VP_MENSAJE				NVARCHAR(MAX) = ''
			,@VP_EXISTE_COMPATIBLE		INT
	---============================================================
	IF	LTRIM(RTRIM(@PP_LOTE_01))	= LTRIM(RTRIM(@PP_LOTE_02))
	BEGIN
		SET @VP_MENSAJE='Los LOTES no pueden ser iguales. ' +	@PP_LOTE_01	+ ' y '+	@PP_LOTE_02 + ', verifique y vuelva a intentar...'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
	
	---============================================================
	--	SE REALIZA LA VALIDACIÓN PARA VERIFICAR SI EXISTE LA COMBINACIÓN DE LOTES EN EL SISTEMA.
	SELECT	@VP_EXISTE_COMPATIBLE	=	COUNT(ID)	
	FROM	SER_LOT_COMP_SQL		(NOLOCK)
	WHERE	(		LTRIM(RTRIM(SER_LOT_NO1))	=@PP_LOTE_01 
			AND		LTRIM(RTRIM(SER_LOT_NO2))	=@PP_LOTE_02 )
	OR		(		LTRIM(RTRIM(SER_LOT_NO1))	=@PP_LOTE_02 
			AND		LTRIM(RTRIM(SER_LOT_NO2))	=@PP_LOTE_01 )
	AND		LTRIM(RTRIM(ITEM_NO))	= @PP_ITEM_NO

	IF @VP_EXISTE_COMPATIBLE >= 1
	BEGIN
		SET @VP_MENSAJE='Ya existe compatibilidad entre los lotes. ' +	@PP_LOTE_01	+ ' y '+	@PP_LOTE_02 + ', para el ITEM [' + @PP_ITEM_NO + ']'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
GO

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> IN_LOTE_COMPATIBLE ADICIONALES
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_LOTE_COMPATIBLE_ADICIONALES]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_LOTE_COMPATIBLE_ADICIONALES]
GO
--		 EXECUTE [dbo].[PG_IN_LOTE_COMPATIBLE_ADICIONALES]	0,139,	'019941'
CREATE PROCEDURE [dbo].[PG_IN_LOTE_COMPATIBLE_ADICIONALES]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ITEM_NO					VARCHAR(25),
	@PP_LOTE_01					VARCHAR(10),
	-- ===========================
	@PP_D_USUARIO_01			VARCHAR(250),
	@PP_D_USUARIO_02			VARCHAR(250),
	@PP_K_USUARIO_01			INT,
	@PP_K_USUARIO_02			INT,
	-- ===========================
	@PP_ARRAY_LOTE_02			NVARCHAR(MAX),
	@PP_ARRAY_COMPATI			NVARCHAR(MAX),
	@PP_ARRAY_COMENTA			NVARCHAR(MAX)
AS	
DECLARE		 @VP_MENSAJE				NVARCHAR(MAX) = ''
			,@VP_EXISTE_COMPATIBLE		INT			
---===================================================================================================================================================
---===================================================================================================================================================
---===================================================================================================================================================	
	DECLARE  @VP_POSICION_LOTE_02		INT
			,@VP_POSICION_COMPATI		INT
			,@VP_POSICION_COMENTA		INT 
	DECLARE  @VP_VALOR_LOTE_02			VARCHAR(500)
			,@VP_VALOR_COMPATI			VARCHAR(500)
			,@VP_VALOR_COMENTA			VARCHAR(500)
	--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
	SET	@PP_ARRAY_LOTE_02		= @PP_ARRAY_LOTE_02		+ '/'
	SET	@PP_ARRAY_COMPATI		= @PP_ARRAY_COMPATI		+ '/'
	SET	@PP_ARRAY_COMENTA		= @PP_ARRAY_COMENTA		+ '/'	

	--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
	WHILE patindex('%/%' , @PP_ARRAY_LOTE_02) <> 0
		BEGIN
			SELECT @VP_POSICION_LOTE_02	=	patindex('%/%' , @PP_ARRAY_LOTE_02	)
			SELECT @VP_POSICION_COMPATI	=	patindex('%/%' , @PP_ARRAY_COMPATI	)
			SELECT @VP_POSICION_COMENTA	=	patindex('%/%' , @PP_ARRAY_COMENTA	)

			--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
			SELECT @VP_VALOR_LOTE_02		= LEFT(@PP_ARRAY_LOTE_02		, @VP_POSICION_LOTE_02	- 1)
			SELECT @VP_VALOR_COMPATI		= LEFT(@PP_ARRAY_COMPATI		, @VP_POSICION_COMPATI	- 1)
			SELECT @VP_VALOR_COMENTA		= LEFT(@PP_ARRAY_COMENTA		, @VP_POSICION_COMENTA	- 1)
				
				DECLARE  @VP_BOOLEAN_COMPATIBLE		VARCHAR(1)	='N'
						,@VP_K_LOTE_COMPATIBLE		INT
				---- /////////////////////////////////////////////////////////////////////
				-- SE DA FORMATO AL LOTE PARA INCLUIR LOS 0 FALTANTES. Y ASIGNAR EL VALOR A LA COMPATIBILIDAD.(DE INT A VARCHAR)
				SET	@VP_VALOR_LOTE_02	= RIGHT('000000' + CONVERT(VARCHAR(10),Ltrim(Rtrim(@VP_VALOR_LOTE_02))), 6)

				IF @VP_VALOR_COMPATI	= '1'
				BEGIN
					SET	@VP_BOOLEAN_COMPATIBLE	= 'Y'
				END
				---============================================================
				--	SE REALIZA LA VALIDACIÓN PARA VERIFICAR SI EXISTE LA COMBINACIÓN DE LOTES EN EL SISTEMA.
				EXECUTE	[dbo].[PG_VERIFICA_LOTE_COMPATIBILIDAD]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
																-- ===========================
																@PP_ITEM_NO,		@PP_LOTE_01,
																@VP_VALOR_LOTE_02
				
				---- /////////////////////////////////////////////////////////////////////
				--		SE REALIZA EL INSERT DE REGISTROS
					INSERT INTO [dbo].[SER_LOT_COMP_SQL]
					(		[ITEM_NO]
					       ,[SER_LOT_NO1]			,[SER_LOT_NO2]
							-- ===========================
					       ,[COMP]
							-- ===========================
					       ,[AUT1]					,[AUT2]
							-- ===========================
					       ,[COMMENTS]				,[F_ALTA]
							-- ===========================
					       ,[K_USUARIO_PEARL_01]	,[K_USUARIO_PEARL_02]
							-- ===========================
					       ,[F_CAMBIO]			)
					 VALUES
					 (		@PP_ITEM_NO					
							,CONCAT('         ',@PP_LOTE_01)			,CONCAT('         ',@VP_VALOR_LOTE_02)
							-- =========================
							,@VP_BOOLEAN_COMPATIBLE		--,@VP_VALOR_COMPATI
							-- =========================
							,@PP_D_USUARIO_01		,@PP_D_USUARIO_02
							-- =========================
							,@VP_VALOR_COMENTA			,GETDATE()
							-- =========================
							,@PP_K_USUARIO_01		,@PP_K_USUARIO_02
							-- ===========================
							,GETDATE()			)
					
					IF @@ROWCOUNT = 0
					BEGIN
						SET @VP_MENSAJE='El registro no fue ingresado. Lotes: ' + @PP_LOTE_01	+ ' y '+	@VP_VALOR_LOTE_02 + ', para el ITEM [' + @PP_ITEM_NO + ']'
						RAISERROR (@VP_MENSAJE, 16, 1 )
					END
					ELSE
					BEGIN
						SELECT @VP_K_LOTE_COMPATIBLE=SCOPE_IDENTITY()
			
						IF @VP_K_LOTE_COMPATIBLE=NULL
						BEGIN
							SET @VP_MENSAJE='El registro no fue ingresado.(identity) Lotes: ' + @PP_LOTE_01	+ ' y '+	@VP_VALOR_LOTE_02 + ', para el ITEM [' + @PP_ITEM_NO + ']'
							RAISERROR (@VP_MENSAJE, 16, 1 )
						END
					END
					
					EXECUTE [dbo].[PG_IN_SER_LOT_COMP_SQL_LOG]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
																-- ===========================
																@PP_ITEM_NO,		
																@PP_LOTE_01,		@VP_VALOR_LOTE_02,	
																-- =========================
																@VP_BOOLEAN_COMPATIBLE,
																-- =========================
																@PP_D_USUARIO_01,		@PP_D_USUARIO_02,
																@PP_K_USUARIO_01,		@PP_K_USUARIO_02,
																-- =========================
																@VP_VALOR_COMENTA,		'AGREGADO'
																-- =========================
				---- /////////////////////////////////////////////////////////////////////

			--Reemplazamos lo procesado con nada con la funcion stuff
			SELECT @PP_ARRAY_LOTE_02= STUFF(@PP_ARRAY_LOTE_02 , 1, @VP_POSICION_LOTE_02, '')
			SELECT @PP_ARRAY_COMPATI= STUFF(@PP_ARRAY_COMPATI , 1, @VP_POSICION_COMPATI, '')
			SELECT @PP_ARRAY_COMENTA= STUFF(@PP_ARRAY_COMENTA , 1, @VP_POSICION_COMENTA, '')
		END
---===================================================================================================================================================
---===================================================================================================================================================
---===================================================================================================================================================
-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> IN_LOTE_COMPATIBLE PRINCIPAL
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_LOTE_COMPATIBLE_PRINCIPAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_LOTE_COMPATIBLE_PRINCIPAL]
GO

--		 EXECUTE [dbo].[PG_IN_LOTE_COMPATIBLE_PRINCIPAL]	0,139,	'019941'
CREATE PROCEDURE [dbo].[PG_IN_LOTE_COMPATIBLE_PRINCIPAL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ITEM_NO					VARCHAR(25),
	@PP_LOTE_01					VARCHAR(10),
	@PP_LOTE_02					VARCHAR(10),
	-- ===========================
	@PP_L_COMPATIBLE			INT,
	@PP_COMENTARIO				VARCHAR(500),
	-- ===========================
	@PP_D_USUARIO_01			VARCHAR(250),
	@PP_D_USUARIO_02			VARCHAR(250),
	@PP_K_USUARIO_01			INT,
	@PP_K_USUARIO_02			INT
	-- ===========================
AS	
DECLARE		 @VP_MENSAJE				NVARCHAR(MAX) = ''
			,@VP_EXISTE_COMPATIBLE		INT
			,@VP_K_LOTE_COMPATIBLE		INT
			,@VP_BOOLEAN_COMPATIBLE		VARCHAR(1)	='N'

	IF @PP_L_COMPATIBLE	= 1
	BEGIN
		SET	@VP_BOOLEAN_COMPATIBLE	= 'Y'
	END

	---============================================================
	--	SE REALIZA LA VALIDACIÓN PARA VERIFICAR SI EXISTE LA COMBINACIÓN DE LOTES EN EL SISTEMA.

	EXECUTE	[dbo].[PG_VERIFICA_LOTE_COMPATIBILIDAD]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
													-- ===========================
													@PP_ITEM_NO,		@PP_LOTE_01,
													@PP_LOTE_02

	---============================================================
	--		SE REALIZA EL INSERT DEL REGISTRO PRINCIPAL
	---- /////////////////////////////////////////////////////////////////////
		INSERT INTO [dbo].[SER_LOT_COMP_SQL]
		(		[ITEM_NO]
		       ,[SER_LOT_NO1]			,[SER_LOT_NO2]
				-- ===========================
		       ,[COMP]
				-- ===========================
		       ,[AUT1]					,[AUT2]
				-- ===========================
		       ,[COMMENTS]				,[F_ALTA]
				-- ===========================
		       ,[K_USUARIO_PEARL_01]	,[K_USUARIO_PEARL_02]
				-- ===========================
		       ,[F_CAMBIO]				)
		 VALUES
		 (		@PP_ITEM_NO					
				,CONCAT('         ',@PP_LOTE_01)			,CONCAT('         ',@PP_LOTE_02)
				-- =========================
				,@VP_BOOLEAN_COMPATIBLE	--,@PP_L_COMPATIBLE
				-- =========================
				,@PP_D_USUARIO_01		,@PP_D_USUARIO_02
				-- =========================
				,@PP_COMENTARIO			,GETDATE()
				-- =========================
				,@PP_K_USUARIO_01		,@PP_K_USUARIO_02
				-- ===========================
				,GETDATE()				)
		
		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='El registro no fue ingresado. Lotes:' + @PP_LOTE_01	+ 'y'+	@PP_LOTE_02 + ', para el ITEM [' + @PP_ITEM_NO + ']'
			RAISERROR (@VP_MENSAJE, 16, 1 )
		END
		ELSE
		BEGIN
			SELECT @VP_K_LOTE_COMPATIBLE=SCOPE_IDENTITY()

			IF @VP_K_LOTE_COMPATIBLE=NULL
			BEGIN
				SET @VP_MENSAJE='El registro no fue ingresado.(identity) Lotes:' + @PP_LOTE_01	+ 'y'+	@PP_LOTE_02 + ', para el ITEM [' + @PP_ITEM_NO + ']'
				RAISERROR (@VP_MENSAJE, 16, 1 )
			END
		END
	
		EXECUTE [dbo].[PG_IN_SER_LOT_COMP_SQL_LOG]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
													-- ===========================
													@PP_ITEM_NO,		
													@PP_LOTE_01,		@PP_LOTE_02,	
													-- =========================
													@VP_BOOLEAN_COMPATIBLE,
													-- =========================
													@PP_D_USUARIO_01,		@PP_D_USUARIO_02,
													@PP_K_USUARIO_01,		@PP_K_USUARIO_02,
													-- =========================
													@PP_COMENTARIO,		'AGREGADO'
													-- =========================
-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> IN_LOTE_COMPATIBLE PRINCIPAL
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_LOTE_COMPATIBLE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_LOTE_COMPATIBLE]
GO
--EXECUTE [dbo].[PG_IN_LOTE_COMPATIBLE] 1,139,  'FWSPAT5' , '402751' , '( SELECCIONA )' , '1' , 'compatible' , 'JORGE IVAN JARAMILLO' , 'PEDRO MISAEL SANCHEZ' , '140' , '173' , '1803' , '7422' , '1' , '402611/402621' , '1/1' , 'compatible/compatible' 

CREATE PROCEDURE [dbo].[PG_IN_LOTE_COMPATIBLE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ITEM_NO					VARCHAR(25),
	@PP_LOTE_01					VARCHAR(10),
	@PP_LOTE_02					VARCHAR(10),
	-- ===========================
	@PP_L_COMPATIBLE			INT,
	@PP_COMENTARIO				VARCHAR(500),
	-- ===========================
	@PP_D_USUARIO_01			VARCHAR(250),
	@PP_D_USUARIO_02			VARCHAR(250),
	@PP_K_USUARIO_01			INT,
	@PP_K_USUARIO_02			INT,
	@PP_PASS_USUARIO_01			VARCHAR(25),
	@PP_PASS_USUARIO_02			VARCHAR(25),
	-- ===========================
	@PP_L_AGREGAR_MULTIPLES		INT,
	@PP_ARRAY_LOTE_02			NVARCHAR(MAX),
	@PP_ARRAY_COMPATI			NVARCHAR(MAX),
	@PP_ARRAY_COMENTA			NVARCHAR(MAX)
AS	
DECLARE		 @VP_MENSAJE				NVARCHAR(MAX) = ''

BEGIN TRANSACTION 
BEGIN TRY	
	---============================================================
	SET	@PP_LOTE_01	= RIGHT('000000' + CONVERT(VARCHAR(10),Ltrim(Rtrim(@PP_LOTE_01))), 6)
	SET	@PP_LOTE_02	= RIGHT('000000' + CONVERT(VARCHAR(10),Ltrim(Rtrim(@PP_LOTE_02))), 6)
	---============================================================
	--	SE VERIFICA QUE LOS USUARIOS QUE AUTORIZAN SE ENCUENTRAN REGISTRADOS EN EL SISTEMA Y ESTAN ACTUALMENTE ACTIVOS.
	EXECUTE	[dbo].[PG_VERIFICA_PASSWORD_COMPATIBILIDAD]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
														-- ===========================
														@PP_K_USUARIO_01,		@PP_D_USUARIO_01,
														@PP_PASS_USUARIO_01
	
	EXECUTE	[dbo].[PG_VERIFICA_PASSWORD_COMPATIBILIDAD]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
														-- ===========================
														@PP_K_USUARIO_02,		@PP_D_USUARIO_02,
														@PP_PASS_USUARIO_02


	IF	@PP_L_AGREGAR_MULTIPLES	= 0
	BEGIN
	---============================================================
	--	SE REALIZA EL INSERT DE LOS REGISTROS.
	EXECUTE	[dbo].[PG_IN_LOTE_COMPATIBLE_PRINCIPAL]	@PP_K_SISTEMA_EXE,		@PP_K_USUARIO_ACCION,
													-- ===========================
													@PP_ITEM_NO,
													@PP_LOTE_01,			@PP_LOTE_02,
													-- ===========================
													@PP_L_COMPATIBLE,		@PP_COMENTARIO,
													-- ===========================
													@PP_D_USUARIO_01,		@PP_D_USUARIO_02,
													@PP_K_USUARIO_01,		@PP_K_USUARIO_02
													
	END
	ELSE IF	@PP_L_AGREGAR_MULTIPLES	= 1
	BEGIN
	
		EXECUTE	[dbo].[PG_IN_LOTE_COMPATIBLE_ADICIONALES]	@PP_K_SISTEMA_EXE,		@PP_K_USUARIO_ACCION,
														-- ===========================
														@PP_ITEM_NO,
														@PP_LOTE_01,
														-- ===========================
														@PP_D_USUARIO_01,		@PP_D_USUARIO_02,
														@PP_K_USUARIO_01,		@PP_K_USUARIO_02,
														-- ===========================
														@PP_ARRAY_LOTE_02,		@PP_ARRAY_COMPATI,
														@PP_ARRAY_COMENTA
	
	END
-- /////////////////////////////////////////////////////////////////////
		EXECUTE	[dbo].[PG_ENVIAR_CORREO_X_INSERT]	@PP_K_SISTEMA_EXE,		@PP_K_USUARIO_ACCION,
													-- ===========================
													@PP_ITEM_NO,
													@PP_LOTE_01,			@PP_LOTE_02,
													-- ===========================
													@PP_L_COMPATIBLE,		@PP_COMENTARIO	,
													-- ===========================
													@PP_D_USUARIO_01,		@PP_D_USUARIO_02,
													@PP_K_USUARIO_01,		@PP_K_USUARIO_02,
													@PP_PASS_USUARIO_01,	@PP_PASS_USUARIO_02,
													-- ===========================
													@PP_L_AGREGAR_MULTIPLES,
													@PP_ARRAY_LOTE_02,		@PP_ARRAY_COMPATI,
													@PP_ARRAY_COMENTA		

-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	/* Ocurrió un error, deshacemos los cambios*/ 
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH
	
	IF @VP_MENSAJE<>''
	BEGIN
		SET	@VP_MENSAJE = '!!!! ' + @VP_MENSAJE 
	END

	SELECT	@VP_MENSAJE AS MENSAJE, @PP_LOTE_01 AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> IN_LOTE_COMPATIBLE ADICIONALES
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_LOTE_COMPATIBLE_ADICIONALES]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_LOTE_COMPATIBLE_ADICIONALES]
GO
--			  EXECUTE [dbo].[PG_UP_LOTE_COMPATIBLE_ADICIONALES]	0,139,	
CREATE PROCEDURE [dbo].[PG_UP_LOTE_COMPATIBLE_ADICIONALES]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_D_USUARIO_01			VARCHAR(250),
	@PP_D_USUARIO_02			VARCHAR(250),
	@PP_K_USUARIO_01			INT,
	@PP_K_USUARIO_02			INT,
	-- ===========================
	@PP_ARRAY_K_ID_LOTE			NVARCHAR(MAX),
	@PP_ARRAY_L_COMPATI			NVARCHAR(MAX),
	@PP_ARRAY_D_COMENTA			NVARCHAR(MAX)
AS	
DECLARE		 @VP_MENSAJE				NVARCHAR(MAX) = ''
---===================================================================================================================================================
---===================================================================================================================================================
---===================================================================================================================================================	
	DECLARE  @VP_POSICION_K_ID_LOTE		INT
			,@VP_POSICION_L_COMPATI		INT
			,@VP_POSICION_D_COMENTA		INT 
	DECLARE  @VP_VALOR_K_ID_LOTE			VARCHAR(500)
			,@VP_VALOR_L_COMPATI			VARCHAR(500)
			,@VP_VALOR_D_COMENTA			VARCHAR(500)
	--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
	SET	@PP_ARRAY_K_ID_LOTE		= @PP_ARRAY_K_ID_LOTE		+ '/'
	SET	@PP_ARRAY_L_COMPATI		= @PP_ARRAY_L_COMPATI		+ '/'
	SET	@PP_ARRAY_D_COMENTA		= @PP_ARRAY_D_COMENTA		+ '/'	

	--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
	WHILE patindex('%/%' , @PP_ARRAY_K_ID_LOTE) <> 0
		BEGIN
			SELECT @VP_POSICION_K_ID_LOTE	=	patindex('%/%' , @PP_ARRAY_K_ID_LOTE	)
			SELECT @VP_POSICION_L_COMPATI	=	patindex('%/%' , @PP_ARRAY_L_COMPATI	)
			SELECT @VP_POSICION_D_COMENTA	=	patindex('%/%' , @PP_ARRAY_D_COMENTA	)

			--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
			SELECT @VP_VALOR_K_ID_LOTE		= LEFT(@PP_ARRAY_K_ID_LOTE		, @VP_POSICION_K_ID_LOTE	- 1)
			SELECT @VP_VALOR_L_COMPATI		= LEFT(@PP_ARRAY_L_COMPATI		, @VP_POSICION_L_COMPATI	- 1)
			SELECT @VP_VALOR_D_COMENTA		= LEFT(@PP_ARRAY_D_COMENTA		, @VP_POSICION_D_COMENTA	- 1)
				
				DECLARE @VP_BOOLEAN_COMPATIBLE		VARCHAR(1)	='N'
				---- /////////////////////////////////////////////////////////////////////
				IF @VP_VALOR_L_COMPATI	= '1'
				BEGIN
					SET	@VP_BOOLEAN_COMPATIBLE	= 'Y'
				END
				
				---- /////////////////////////////////////////////////////////////////////
				---============================================================
				--		SE REALIZA EL UPDATE DEL REGISTRO PRINCIPAL
				UPDATE	[dbo].[SER_LOT_COMP_SQL]
				SET	-- ===========================
					 [COMP]					= @VP_BOOLEAN_COMPATIBLE
					-- ===========================		
					,[AUT1]					= @PP_D_USUARIO_01
					,[AUT2]					= @PP_D_USUARIO_02
					-- ===========================		
					,[COMMENTS]				= @VP_VALOR_D_COMENTA
					-- ===========================		
					,[K_USUARIO_PEARL_01]	= @PP_K_USUARIO_01
					,[K_USUARIO_PEARL_02]	= @PP_K_USUARIO_02
					-- ===========================		
					,[F_CAMBIO]				= GETDATE()
				WHERE		ID				= @VP_VALOR_K_ID_LOTE
					
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE='El registro no fue actualizado. ID: [' + CONVERT(VARCHAR(10),@VP_VALOR_K_ID_LOTE) + ']'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END							
				---- /////////////////////////////////////////////////////////////////////
				DECLARE @PP_ITEM_NO		VARCHAR(25),	@PP_LOTE_01	VARCHAR(10),	@PP_LOTE_02		VARCHAR(10)

				SELECT	@PP_ITEM_NO		= ITEM_NO,
						@PP_LOTE_01		= SER_LOT_NO1,
						@PP_LOTE_02		= SER_LOT_NO2
				FROM	SER_LOT_COMP_SQL	(NOLOCK)
				WHERE		ID				= @VP_VALOR_K_ID_LOTE
				
				EXECUTE [dbo].[PG_IN_SER_LOT_COMP_SQL_LOG]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
															-- ===========================
															@PP_ITEM_NO,		
															@PP_LOTE_01,		@PP_LOTE_02,	
															-- =========================
															@VP_BOOLEAN_COMPATIBLE,
															-- =========================
															@PP_D_USUARIO_01,		@PP_D_USUARIO_02,
															@PP_K_USUARIO_01,		@PP_K_USUARIO_02,
															-- =========================
															@VP_VALOR_D_COMENTA,		'MODIFICADO'
															-- =========================
			--Reemplazamos lo procesado con nada con la funcion stuff
			SELECT @PP_ARRAY_K_ID_LOTE= STUFF(@PP_ARRAY_K_ID_LOTE , 1, @VP_POSICION_K_ID_LOTE, '')
			SELECT @PP_ARRAY_L_COMPATI= STUFF(@PP_ARRAY_L_COMPATI , 1, @VP_POSICION_L_COMPATI, '')
			SELECT @PP_ARRAY_D_COMENTA= STUFF(@PP_ARRAY_D_COMENTA , 1, @VP_POSICION_D_COMENTA, '')
		END
---===================================================================================================================================================
---===================================================================================================================================================
---===================================================================================================================================================
-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> IN_LOTE_COMPATIBLE PRINCIPAL
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_LOTE_COMPATIBLE_PRINCIPAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_LOTE_COMPATIBLE_PRINCIPAL]
GO
--		 EXECUTE [dbo].[PG_UP_LOTE_COMPATIBLE_PRINCIPAL]	0,139,	'019941'
CREATE PROCEDURE [dbo].[PG_UP_LOTE_COMPATIBLE_PRINCIPAL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_ID_LOTE				INT,
	-- ===========================
	@PP_L_COMPATIBLE			INT,
	@PP_COMENTARIO				VARCHAR(500),
	-- ===========================
	@PP_D_USUARIO_01			VARCHAR(250),
	@PP_D_USUARIO_02			VARCHAR(250),
	@PP_K_USUARIO_01			INT,
	@PP_K_USUARIO_02			INT
	-- ===========================
AS	
DECLARE		 @VP_MENSAJE				NVARCHAR(MAX) = ''
			,@VP_BOOLEAN_COMPATIBLE		VARCHAR(1)	='N'

	IF @PP_L_COMPATIBLE	= 1
	BEGIN
		SET	@VP_BOOLEAN_COMPATIBLE	= 'Y'
	END

	---============================================================
	--		SE REALIZA EL UPDATE DEL REGISTRO PRINCIPAL
	---- /////////////////////////////////////////////////////////////////////
	UPDATE	[dbo].[SER_LOT_COMP_SQL]
	SET	-- ===========================
		 [COMP]					= @VP_BOOLEAN_COMPATIBLE
		-- ===========================		
		,[AUT1]					= @PP_D_USUARIO_01
		,[AUT2]					= @PP_D_USUARIO_02
		-- ===========================		
		,[COMMENTS]				= @PP_COMENTARIO
		-- ===========================		
		,[K_USUARIO_PEARL_01]	= @PP_K_USUARIO_01
		,[K_USUARIO_PEARL_02]	= @PP_K_USUARIO_02
		-- ===========================		
		,[F_CAMBIO]				= GETDATE()
	WHERE		ID				= @PP_K_ID_LOTE
		
	IF @@ROWCOUNT = 0
	BEGIN
		SET @VP_MENSAJE='El registro no fue actualizado. ID: [' + CONVERT(VARCHAR(10),@PP_K_ID_LOTE) + ']'
		RAISERROR (@VP_MENSAJE, 16, 1 )
	END
	---- /////////////////////////////////////////////////////////////////////
	DECLARE @PP_ITEM_NO		VARCHAR(25),	@PP_LOTE_01	VARCHAR(10),	@PP_LOTE_02		VARCHAR(10)
	
	SELECT	@PP_ITEM_NO		= ITEM_NO,
			@PP_LOTE_01		= SER_LOT_NO1,
			@PP_LOTE_02		= SER_LOT_NO2
	FROM	SER_LOT_COMP_SQL	(NOLOCK)
	WHERE		ID				= @PP_K_ID_LOTE
	
	EXECUTE [dbo].[PG_IN_SER_LOT_COMP_SQL_LOG]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
												-- ===========================
												@PP_ITEM_NO,		
												@PP_LOTE_01,		@PP_LOTE_02,	
												-- =========================
												@VP_BOOLEAN_COMPATIBLE,
												-- =========================
												@PP_D_USUARIO_01,		@PP_D_USUARIO_02,
												@PP_K_USUARIO_01,		@PP_K_USUARIO_02,
												-- =========================
												@PP_COMENTARIO,		'MODIFICADO'
												-- =========================
-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> IN_LOTE_COMPATIBLE PRINCIPAL
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_LOTE_COMPATIBLE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_LOTE_COMPATIBLE]
GO
--				EXECUTE [dbo].[PG_UP_LOTE_COMPATIBLE]	0,139,																				
 --				'71066' , 'FWLNPX7' , '401031' , '401071' , '1' , 'no compatibles' ,				
 --				'OMAR ALBERTO DECENA' , 'RODOLFO CARBAJAL' , '42' , '138' , '12340' , '79130' ,			
 --				'0' , '0' , '0' , '0' , '1' , '71067' , '401401' , '0' , 'COMPATIBLE'					
CREATE PROCEDURE [dbo].[PG_UP_LOTE_COMPATIBLE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_K_ID_LOTE				INT,
	-- ===========================
	@PP_ITEM_NO					VARCHAR(25),
	@PP_LOTE_01					VARCHAR(10),
	@PP_LOTE_02					VARCHAR(10),
	-- ===========================
	@PP_L_COMPATIBLE			INT,
	@PP_COMENTARIO				VARCHAR(500),
	-- ===========================
	@PP_D_USUARIO_01			VARCHAR(250),
	@PP_D_USUARIO_02			VARCHAR(250),
	@PP_K_USUARIO_01			INT,
	@PP_K_USUARIO_02			INT,
	@PP_PASS_USUARIO_01			VARCHAR(25),
	@PP_PASS_USUARIO_02			VARCHAR(25),
	-- ===========================
	@PP_L_AGREGAR_MULTIPLES		INT,
	@PP_ARRAY_LOTE_02			NVARCHAR(MAX),
	@PP_ARRAY_COMPATI			NVARCHAR(MAX),
	@PP_ARRAY_COMENTA			NVARCHAR(MAX),
	-- ===========================
	@PP_L_MODIFICAR_COMPATIBLE	INT,
	@PP_ARRAY_K_ID_LOTE			NVARCHAR(MAX),
	@PP_ARRAY_S_LOTE_02			NVARCHAR(MAX),
	@PP_ARRAY_L_COMPATI			NVARCHAR(MAX),
	@PP_ARRAY_D_COMENTA			NVARCHAR(MAX)
AS	
DECLARE		 @VP_MENSAJE				NVARCHAR(MAX) = ''

BEGIN TRANSACTION 
BEGIN TRY
	SET	@PP_LOTE_01	= RIGHT('000000' + CONVERT(VARCHAR(10),Ltrim(Rtrim(@PP_LOTE_01))), 6)
	SET	@PP_LOTE_02	= RIGHT('000000' + CONVERT(VARCHAR(10),Ltrim(Rtrim(@PP_LOTE_02))), 6)

	---============================================================
	--	SE VERIFICA QUE LOS USUARIOS QUE AUTORIZAN SE ENCUENTRAN REGISTRADOS EN EL SISTEMA Y ESTAN ACTUALMENTE ACTIVOS.
	EXECUTE	[dbo].[PG_VERIFICA_PASSWORD_COMPATIBILIDAD]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
														-- ===========================
														@PP_K_USUARIO_01,		@PP_D_USUARIO_01,
														@PP_PASS_USUARIO_01
	
	EXECUTE	[dbo].[PG_VERIFICA_PASSWORD_COMPATIBILIDAD]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
														-- ===========================
														@PP_K_USUARIO_02,		@PP_D_USUARIO_02,
														@PP_PASS_USUARIO_02
	
	-- EL REGISTRO PRINCIPAL SIEMPRE SERÁ MODIFICADO AL GUARDAR LA FICHA.
	EXECUTE	[dbo].[PG_UP_LOTE_COMPATIBLE_PRINCIPAL]	@PP_K_SISTEMA_EXE,		@PP_K_USUARIO_ACCION,
													-- ===========================
													@PP_K_ID_LOTE,
													-- ===========================
													@PP_L_COMPATIBLE,		@PP_COMENTARIO,
													-- ===========================
													@PP_D_USUARIO_01,		@PP_D_USUARIO_02,
													@PP_K_USUARIO_01,		@PP_K_USUARIO_02
	
	IF	@PP_L_AGREGAR_MULTIPLES	= 1
	BEGIN
	
		EXECUTE	[dbo].[PG_IN_LOTE_COMPATIBLE_ADICIONALES]	@PP_K_SISTEMA_EXE,		@PP_K_USUARIO_ACCION,
														-- ===========================
														@PP_ITEM_NO,
														@PP_LOTE_01,
														-- ===========================
														@PP_D_USUARIO_01,		@PP_D_USUARIO_02,
														@PP_K_USUARIO_01,		@PP_K_USUARIO_02,
														-- ===========================
														@PP_ARRAY_LOTE_02,		@PP_ARRAY_COMPATI,
														@PP_ARRAY_COMENTA
	
	END

	IF	@PP_L_MODIFICAR_COMPATIBLE	= 1
	BEGIN
	
		EXECUTE	[dbo].[PG_UP_LOTE_COMPATIBLE_ADICIONALES]	@PP_K_SISTEMA_EXE,		@PP_K_USUARIO_ACCION,
														-- ===========================
														@PP_D_USUARIO_01,		@PP_D_USUARIO_02,
														@PP_K_USUARIO_01,		@PP_K_USUARIO_02,
														-- ===========================
														@PP_ARRAY_K_ID_LOTE,	@PP_ARRAY_L_COMPATI,
														@PP_ARRAY_D_COMENTA
	END
-- /////////////////////////////////////////////////////////////////////
		EXECUTE	[dbo].[PG_ENVIAR_CORREO_X_UPDATE]	@PP_K_SISTEMA_EXE,		@PP_K_USUARIO_ACCION,
													-- ===========================
													@PP_ITEM_NO,
													@PP_LOTE_01,			@PP_LOTE_02,
													-- ===========================
													@PP_L_COMPATIBLE,		@PP_COMENTARIO	,
													-- ===========================
													@PP_D_USUARIO_01,		@PP_D_USUARIO_02,
													@PP_K_USUARIO_01,		@PP_K_USUARIO_02,
													@PP_PASS_USUARIO_01,	@PP_PASS_USUARIO_02,
													-- ===========================
													@PP_L_AGREGAR_MULTIPLES,
													@PP_ARRAY_LOTE_02,		@PP_ARRAY_COMPATI,
													@PP_ARRAY_COMENTA,
													-- ===========================
													@PP_L_MODIFICAR_COMPATIBLE,
													@PP_ARRAY_K_ID_LOTE,	@PP_ARRAY_S_LOTE_02,
													@PP_ARRAY_L_COMPATI,	@PP_ARRAY_D_COMENTA
-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	/* Ocurrió un error, deshacemos los cambios*/ 
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH
	
	IF @VP_MENSAJE<>''
	BEGIN
		SET	@VP_MENSAJE = '!!!! ' + @VP_MENSAJE 
	END

	SELECT	@VP_MENSAJE AS MENSAJE, @PP_LOTE_01 AS CLAVE
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////
--  EXECUTE [dbo].[PG_SA4GLIdentity] 0,139,9
--	EXECUTE [dbo].[PG_DL_ARCUSFIL] 0,139,9
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_LOTE_COMPATIBLE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_LOTE_COMPATIBLE]
GO

CREATE PROCEDURE [dbo].[PG_DL_LOTE_COMPATIBLE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_ID_LOTE						INT
AS
DECLARE @VP_MENSAJE				NVARCHAR(MAX) = ''
BEGIN TRANSACTION 
BEGIN TRY
--/////////////////////////////////////////////////////////////
	-- VARIABLES PARA EL LOG Y PARA ENVIAR EL CORREO.
	DECLARE	@PP_ITEM_NO					VARCHAR(25),
			@PP_LOTE_01					VARCHAR(10),
			@PP_LOTE_02					VARCHAR(10),
			-- ===========================
			@VP_BOOLEAN_COMPATIBLE		VARCHAR(10),
			@PP_COMENTARIO				VARCHAR(500),
			-- ===========================
			@PP_D_USUARIO_01			VARCHAR(250),
			@PP_D_USUARIO_02			VARCHAR(250),
			@PP_K_USUARIO_01			INT,
			@PP_K_USUARIO_02			INT,
			@PP_PASS_USUARIO_01			VARCHAR(25),
			@PP_PASS_USUARIO_02			VARCHAR(25)

--/////////////////////////////////////////////////////////////
	SELECT	@PP_ITEM_NO					= Item_No				,
			@PP_LOTE_01					= ser_lot_no1			,
			@PP_LOTE_02					= ser_lot_no2			,
			-- =========================				  
			@VP_BOOLEAN_COMPATIBLE			= comp				,
			@PP_COMENTARIO				= Comments				,
			-- =========================						
			@PP_D_USUARIO_01			= Aut1					,
			@PP_D_USUARIO_02			= Aut2					,
			@PP_K_USUARIO_01			= K_USUARIO_PEARL_01	,
			@PP_K_USUARIO_02			= K_USUARIO_PEARL_02
	FROM	SER_LOT_COMP_SQL			(NOLOCK)
	WHERE	ID=			@PP_ID_LOTE

	DECLARE @PP_L_COMPATIBLE	INT	= 1

	IF @VP_BOOLEAN_COMPATIBLE	= 'N'
		SET @PP_L_COMPATIBLE	= 0

	EXECUTE [dbo].[PG_IN_SER_LOT_COMP_SQL_LOG]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
												-- ===========================
												@PP_ITEM_NO,		
												@PP_LOTE_01,		@PP_LOTE_02,	
												-- =========================
												@VP_BOOLEAN_COMPATIBLE,
												-- =========================
												@PP_D_USUARIO_01,		@PP_D_USUARIO_02,
												@PP_K_USUARIO_01,		@PP_K_USUARIO_02,
												-- =========================
												@PP_COMENTARIO,		'ELIMINADO'
												-- =========================		
	
	DELETE		SER_LOT_COMP_SQL
	WHERE		ID=			@PP_ID_LOTE
	
	IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='No se borró ningún registro, informe a sistemas...'
			RAISERROR (@VP_MENSAJE, 16, 1 ) 
		END

	EXECUTE	[dbo].[PG_ENVIAR_CORREO_X_DELETE]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
												-- ===========================
												@PP_ITEM_NO	,
												@PP_LOTE_01	,		@PP_LOTE_02	,
												-- ===========================
												@PP_L_COMPATIBLE,	@PP_COMENTARIO	,
												-- ===========================
												@PP_D_USUARIO_01,	@PP_D_USUARIO_02,
												@PP_K_USUARIO_01,	@PP_K_USUARIO_02
	-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	/* Ocurrió un error, deshacemos los cambios*/ 
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH
	
	IF @VP_MENSAJE<>''
		BEGIN
			SET	@VP_MENSAJE = '!!!! ' + @VP_MENSAJE 
		END

	SELECT	@VP_MENSAJE AS MENSAJE, @PP_ID_LOTE AS CLAVE
	-- //////////////////////////////////////////////////////////////	
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--SELECT * FROM	SER_LOT_COMP_SQL 
-------================================================================================================================
-------================================================================================================================
-------================================================================================================================
	--SELECT	 @PP_K_USUARIO			=	K_USUARIO_PEARL
	--		,@VP_K_EMPLEADO_PEARL	=	K_EMPLEADO_PEARL
	--FROM	USUARIO_PEARL
	--WHERE	D_USUARIO_PEARL=@PP_D_USUARIO
	
	--SELECT  @VP_EXISTE_EMPLEADO=	COUNT(EN_NUM_EMP)
	--FROM    USUARIO_PEARL
	--LEFT JOIN HOWE.DBO.VISTA_GAFETES ON EN_NUM_EMP=K_EMPLEADO_PEARL
	--WHERE	EN_NUM_EMP	=	@VP_K_EMPLEADO_PEARL	--K_EMPLEADO_PEARL

	--IF @VP_EXISTE_EMPLEADO= 0
	--BEGIN
	--	SET		@VP_K_CODIGO		=-10
	--	SET		@VP_NOMBRE_APELLIDO	=NULL
	--	SET		@VP_TEMA			=NULL
	--	SET		@VP_D_USUARIO		=NULL
	--	SET		@VP_D_USUARIO_TIPO	=NULL
	--	SET		@VP_S_USUARIO_TIPO	=NULL
	--	SET		@VP_MENSAJE			= 'Hubo un Problema con la cuenta de [Usuario] informe a Sistemas...'	---'Invalid [USER] name.'
		
	--		RAISERROR (@VP_MENSAJE, 16, 1 )
	--END

-------================================================================================================================
-------================================================================================================================
-------================================================================================================================