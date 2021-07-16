USE [DATA_02]

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_ETIQUETA_EMBARQUE_OBTENER_VALOR_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_ETIQUETA_EMBARQUE_OBTENER_VALOR_RMA]
GO

-- EXEC [dbo].[PG_RN_ETIQUETA_EMBARQUE_OBTENER_VALOR_RMA] 'RPMRAQBLNRUPD2,Q30-S11601005*184983C%MAGN03#PRA@66611','2020-03-24','E',10
-- EXEC [dbo].[PG_RN_ETIQUETA_EMBARQUE_OBTENER_VALOR_RMA] 'RUWD2TFBCNPLV5,Q30-S06259008~06258*186132A%MAGN03#WDM@12345!54321','2020-03-24','E',11
-- EXEC [dbo].[PG_RN_ETIQUETA_EMBARQUE_OBTENER_VALOR_RMA] 'RPJLFCRLMCKTX7,Q30-S11836002*2532932BQW-AD%IRVI02#JJL@33071','2020-03-24','E',11
-- EXEC [dbo].[PG_RN_ETIQUETA_EMBARQUE_OBTENER_VALOR_RMA] 'J7#34659/Q10/S34659001/*2551622/Q35/S34659004/*2551623/Q10/S34659001/*2551624/Q10/S34659001/*2551625/Q10/S34659001/*2551626/Q10/S34659001/*2551627/Q15/S34659001/*2551628/Q15/S34659001/*2551621'
--													 	  ,'2021-07-16', 'E', 1
CREATE PROCEDURE [dbo].[PG_RN_ETIQUETA_EMBARQUE_OBTENER_VALOR_RMA]
	--@PP_K_SISTEMA_EXE			INT,
	--@PP_K_USUARIO_ACCION		INT,
	-- ===========================	
	@PP_ETIQUETA_EMBARQUE		NVARCHAR(MAX),
	@PP_FECHA					DATE,
	@PP_TIPO_MOVIMIENTO			VARCHAR(10),
	@PP_NUMERO_EMBARQUE			INT
	-- ===========================	
AS	
DECLARE  @VP_MENSAJE				NVARCHAR(MAX) = ''

BEGIN TRANSACTION
BEGIN TRY
	DECLARE	 @VP_CU_ITEM_NO					VARCHAR(20) = '' 
			,@VP_CU_CANTIDAD_ENVIADA		INT			= 0
			,@VP_CU_SERIAL					VARCHAR(25) = '' 
			,@VP_CU_CUS_ITEM_NO				VARCHAR(50) = '' 
			,@VP_CU_CUS_NO					VARCHAR(20) = ''
			,@VP_CU_MODELNO					VARCHAR(20) = ''
	-- ===============================================================
			,@VP_K_HEADER_RMA				INT			= 0
	-- ===============================================================
	
	DECLARE	@TA_PF_SC TABLE 
	(	ID				[INT]	IDENTITY(1,1),
		[cdate]			[smalldatetime] NULL,
		[part_no]		[nchar](20) NULL,
		[qty]			[smallint] NULL,
		[serial1]		[nchar](20) NULL,
		[serial2]		[nchar](20) NULL,
		[type]			[char](1) NULL,
		[n_emb]			[smallint] NULL,
		[cus_part_no]	[nchar](20) NULL,
		[packing_no]	[nchar](10) NULL,
		[cdate2]		[nchar](8) NULL,
		[inv_no]		[nchar](6) NULL,
		[cus_no]		[nchar](6) NULL,
		[prod_cat]		[nchar](3) NULL,
		[lote1]			[nchar](6) NULL,
		[lote2]			[nchar](6) NULL		)

	-- ===============================================================
	DECLARE	@TA_DATOS_ETIQUETA TABLE 
	(	TA_SERIE			VARCHAR(100),
		TA_ITEM_NO			VARCHAR(100),
		TA_CUS_ITEM_NO		VARCHAR(100),
		TA_QTY				INT			)

	-- ===============================================================
	-- /////////////////////////////////////////////////////
	IF LTRIM(RTRIM(@PP_ETIQUETA_EMBARQUE)) = ''
	BEGIN
		SET @VP_MENSAJE = 'No se obtuvieron datos de la etiqueta'
		RAISERROR(@VP_MENSAJE, 16, 1)
	END
		
	-- /////////////////////////////////////////////////////
	IF SUBSTRING(@PP_ETIQUETA_EMBARQUE,1,1) <> 'J'
	BEGIN
		--SET @PP_ETIQUETA_EMBARQUE	= SUBSTRING(@PP_ETIQUETA_EMBARQUE, 2,LEN(@PP_ETIQUETA_EMBARQUE))
		SET @VP_MENSAJE = 'No es una etiqueta de RMA'
		RAISERROR(@VP_MENSAJE, 16, 1)
	END
	ELSE
	BEGIN
		DECLARE	@VP_K_RMA						INT			= 0
				,@VP_POSICION_K_RMA				INT			= 0
				,@VP_VALOR_K_RMA				VARCHAR(15)	= ''

		--patindex busca un patron en una cadena y nos devuelve su posicion
		SELECT @VP_POSICION_K_RMA	=	patindex('%/%' , @PP_ETIQUETA_EMBARQUE	)
		
		--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
		SELECT @VP_VALOR_K_RMA		= LEFT(@PP_ETIQUETA_EMBARQUE		, @VP_POSICION_K_RMA		- 1)
		
		----SET @VP_K_RMA = CONVERT( INTEGER,REPLACE(@VP_VALOR_K_RMA,'J','') )			

		--SELECT @VP_VALOR_K_RMA

		SELECT @PP_ETIQUETA_EMBARQUE	= STUFF(@PP_ETIQUETA_EMBARQUE		, 1, @VP_POSICION_K_RMA, '')
	END
	-- /////////////////////////////////////////////////////
		
	--SELECT @PP_ETIQUETA_EMBARQUE

	DECLARE  @VP_POSICION		INT
			,@VP_VALOR			VARCHAR(500)
			,@VP_CONTADOR		INT	= 1			-- PARA INSERTAR LOS REGISTROS POR RENGLON, CUANDO LLEGUE A 3 SE REINICIA.
			,@VP_CONSECUTIVO	INT	= 1			-- PARA INDICAR EL CONSECUTIVO DE LA TABLA
	--------------------------------------------
			,@VP_CANTIDAD		VARCHAR(50)		= ''
			,@VP_CUS_CLIENTE	VARCHAR(100)	= ''
			,@VP_SERIE			VARCHAR(100)	= ''

	--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
	SET	@PP_ETIQUETA_EMBARQUE		=	@PP_ETIQUETA_EMBARQUE	+ '/'
		
	--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
	WHILE patindex('%/%' , @PP_ETIQUETA_EMBARQUE ) <> 0
		BEGIN

			--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
			SELECT @VP_POSICION		=	patindex('%/%' , @PP_ETIQUETA_EMBARQUE	)
			SELECT @VP_VALOR		=	LEFT( @PP_ETIQUETA_EMBARQUE		, @VP_POSICION		- 1)

			IF @VP_CONTADOR	= 1
			BEGIN
				SET	@VP_CANTIDAD	= RIGHT( @VP_VALOR	, LEN(@VP_VALOR) - 1 )
			END

			IF @VP_CONTADOR	= 2
			BEGIN
				SET	@VP_SERIE		= RIGHT( @VP_VALOR	, LEN(@VP_VALOR) - 1 )			
			END
			
			IF @VP_CONTADOR	= 3
			BEGIN
				SET	@VP_CUS_CLIENTE	= RIGHT( @VP_VALOR	, LEN(@VP_VALOR) - 1 )

				DECLARE		@VP_I_NUMBER	VARCHAR(100)	= ''

				SELECT	@VP_I_NUMBER	= ITEM_NO
				FROM	DETAILS_RMA
				WHERE	SERIAL	= @VP_SERIE
				
				INSERT INTO	@TA_DATOS_ETIQUETA	(
						TA_SERIE			,
						TA_ITEM_NO			,
						TA_CUS_ITEM_NO		,
						TA_QTY				
				)	VALUES	(
						@VP_SERIE			,
						@VP_I_NUMBER		,
						@VP_CUS_CLIENTE		,
						@VP_CANTIDAD		)																
				IF @@ROWCOUNT = 0
				BEGIN
					SET @VP_MENSAJE='El registro no fue insertado. [SERIAL#'+ @VP_SERIE +']'
					RAISERROR (@VP_MENSAJE, 16, 1 )
				END

				SET	@VP_CONTADOR		= 0
				SET @VP_CANTIDAD		= ''
				SET @VP_CUS_CLIENTE		= ''
				SET @VP_SERIE			= ''
			END

			SET @VP_CONTADOR	+= 1	
			--Reemplazamos lo procesado con nada con la funcion stuff
			SELECT @PP_ETIQUETA_EMBARQUE		= STUFF(@PP_ETIQUETA_EMBARQUE		, 1, @VP_POSICION, '')

		END
		SELECT * FROM @TA_DATOS_ETIQUETA
			--SELECT	TOP(1) 
			--		@VP_K_HEADER_RMA	= HEADER_RMA.K_HEADER_RMA
			--FROM	DETAILS_RMA		(NOLOCK)
			--INNER JOIN	HEADER_RMA	(NOLOCK) ON HEADER_RMA.K_HEADER_RMA	= DETAILS_RMA.K_HEADER_RMA
			--WHERE	 DETAILS_RMA.K_HEADER_RMA	= @VP_K_RMA

			--UPDATE	HEADER_RMA
			--SET		K_STATUS_RMA	= 12
			--WHERE	K_HEADER_RMA	= @VP_K_HEADER_RMA
			--IF @@ROWCOUNT = 0
			--	BEGIN
			--		SET @VP_MENSAJE = '[INSERT], Verifique....'
			--		RAISERROR (@VP_MENSAJE, 16, 1 )
			--	END

	--DECLARE @VP_CDATE2 VARCHAR(8) = ''
	--	SET @VP_CDATE2 =	CONVERT(VARCHAR(8),dbo.[CONVERT_DATE_TO_INT](@PP_FECHA,'yyyyMMdd')) 


	--	DECLARE CU_PROCESO_UNICO CURSOR FOR
	--			SELECT	ITEM_NO,
	--					CANTIDAD_ENVIADA,
	--					SERIAL,
	--					CUS_ITEM_NO,
	--					CUS_NO,
	--					MODELNO
	--			FROM	DETAILS_RMA		(NOLOCK) 
	--			WHERE	K_HEADER_RMA	= 7
	--	OPEN CU_PROCESO_UNICO;  
	--	FETCH NEXT FROM CU_PROCESO_UNICO INTO @VP_CU_ITEM_NO,	@VP_CU_CANTIDAD_ENVIADA,	@VP_CU_SERIAL,	@VP_CU_CUS_ITEM_NO,	@VP_CU_CUS_NO,	@VP_CU_MODELNO
	--	WHILE @@FETCH_STATUS = 0
	--	   BEGIN			
	--		INSERT INTO @TA_PF_SC--PF_SC	
	--		(	cdate,					cdate2, 
	--			part_no,				qty, 
	--			serial1,				serial2, 
	--			cus_part_no,			cus_no,
	--			prod_cat, 
	--			lote1,					lote2, 
	--			[type],			
	--			n_emb	
	--		)		VALUES		(
	--			@PP_FECHA,					@VP_CDATE2, 
	--			@VP_CU_ITEM_NO,				@VP_CU_CANTIDAD_ENVIADA, 
	--			CONCAT('S',@VP_CU_SERIAL),	'', 
	--			@VP_CU_CUS_ITEM_NO,			@VP_CU_CUS_NO, 
	--			@VP_CU_MODELNO, 
	--			0,		0, 
	--			@PP_TIPO_MOVIMIENTO,		@PP_NUMERO_EMBARQUE		)
	--			IF @@ROWCOUNT = 0
	--			BEGIN
	--				SET @VP_MENSAJE = '[INSERT], Verifique....'
	--				RAISERROR (@VP_MENSAJE, 16, 1 )
	--			END

	--		FETCH NEXT FROM CU_PROCESO_UNICO INTO @VP_CU_ITEM_NO,	@VP_CU_CANTIDAD_ENVIADA,	@VP_CU_SERIAL,	@VP_CU_CUS_ITEM_NO,	@VP_CU_CUS_NO,	@VP_CU_MODELNO
	--		END;
	--	CLOSE		CU_PROCESO_UNICO;
	--	DEALLOCATE	CU_PROCESO_UNICO;

	--	SELECT * FROM @TA_PF_SC

		

COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	--	OCURRIÓ UN ERROR, DESHACEMOS LOS CAMBIOS
	ROLLBACK TRANSACTION
	DECLARE @ErrorMessage NVARCHAR(4000);
	SET @ErrorMessage = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR: // ' + @ErrorMessage
END CATCH		

SELECT	@VP_MENSAJE AS MENSAJE

	-- /////////////////////////////////////////////////////
GO
--SELECT	*		FROM	DETAILS_RMA		(NOLOCK)	WHERE	K_HEADER_RMA	= 7
--select * from PF_SC