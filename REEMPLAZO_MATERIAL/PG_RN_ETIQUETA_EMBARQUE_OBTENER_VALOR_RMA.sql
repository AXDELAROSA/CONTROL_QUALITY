USE [DATA_02]

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_QC_LIBERA_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_QC_LIBERA_RMA]
GO
--			EXEC [dbo].[PG_PR_QC_LIBERA_RMA] 13164,'J7#34659/Q10/S34659001/*2551622/Q35/S34659004/*2551623/Q10/S34659001/*2551624/Q10/S34659001/*2551625/Q10/S34659001/*2551626/Q10/S34659001/*2551627/Q15/S34659001/*2551628/Q15/S34659001/*2551621'
CREATE PROCEDURE [dbo].[PG_PR_QC_LIBERA_RMA]
	--@PP_K_SISTEMA_EXE			INT,
	--@PP_K_USUARIO_ACCION		INT,
	-- ===========================	
	@PP_INSPECTOR				INT,
	@PP_ETIQUETA_EMBARQUE		NVARCHAR(MAX)
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
	-- ===============================================================
	DECLARE	@TA_DATOS_ETIQUETA TABLE 
	(	CDATE				varchar(250),
		CTIME				varchar(250),
		INSPECTOR			varchar(250),
		SERIAL				varchar(250),
		SERIAL2				varchar(250),
		PART_NO				varchar(250),
		CUS_PART_NO			varchar(250),
		QTY					varchar(250)			)

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
							,@VP_K_DETALLE	VARCHAR(20)

				SELECT	@VP_I_NUMBER	= ITEM_NO	,
						@VP_K_DETALLE	= K_DETAILS_RMA
				FROM	DETAILS_RMA
				WHERE	SERIAL	= @VP_SERIE
				
				DECLARE @VP_FECHA	INT = DBO.CONVERT_DATE_TO_INT(GETDATE(), 'yyyyMMdd');
				DECLARE @VP_HORA	INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');

				IF (	SELECT	COUNT(SERIAL)
						FROM	QCLIBERA_SQL	
						WHERE	SERIAL2	= @VP_K_DETALLE	)	<=  0
				BEGIN
					INSERT INTO	QCLIBERA_SQL	(
					--INSERT INTO	@TA_DATOS_ETIQUETA	(
							CDATE				,
							CTIME				,
							INSPECTOR			,
							SERIAL				,
							SERIAL2				,
							PART_NO				,
							CUS_PART_NO			,
							QTY
					)	VALUES	(
							@VP_FECHA			,
							@VP_HORA			,
							@PP_INSPECTOR		,
							@VP_SERIE			,
							@VP_K_DETALLE		,
							@VP_I_NUMBER		,
							@VP_CUS_CLIENTE		,
							@VP_CANTIDAD		)																
					IF @@ROWCOUNT = 0
					BEGIN
						SET @VP_MENSAJE='El registro no fue insertado. [SERIAL#'+ @VP_SERIE +']'
						RAISERROR (@VP_MENSAJE, 16, 1 )
					END

					UPDATE	DETAILS_RMA
					SET		K_STATUS_RMA	= 13
					WHERE	SERIAL			= @VP_SERIE
					IF @@ROWCOUNT = 0
					BEGIN
						SET @VP_MENSAJE='El detalle no fue actualizado. [SERIAL#'+ @VP_SERIE +']'
						RAISERROR (@VP_MENSAJE, 16, 1 )
					END
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
		--SELECT * FROM @TA_DATOS_ETIQUETA
		--	--SELECT	TOP(1) 
		--	--		@VP_K_HEADER_RMA	= HEADER_RMA.K_HEADER_RMA
		--	--FROM	DETAILS_RMA		(NOLOCK)
		--	--INNER JOIN	HEADER_RMA	(NOLOCK) ON HEADER_RMA.K_HEADER_RMA	= DETAILS_RMA.K_HEADER_RMA
		--	--WHERE	 DETAILS_RMA.K_HEADER_RMA	= @VP_K_RMA

		--	--UPDATE	HEADER_RMA
		--	--SET		K_STATUS_RMA	= 12
		--	--WHERE	K_HEADER_RMA	= @VP_K_HEADER_RMA
		--	--IF @@ROWCOUNT = 0
		--	--	BEGIN
		--	--		SET @VP_MENSAJE = '[INSERT], Verifique....'
		--	--		RAISERROR (@VP_MENSAJE, 16, 1 )
		--	--	END
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