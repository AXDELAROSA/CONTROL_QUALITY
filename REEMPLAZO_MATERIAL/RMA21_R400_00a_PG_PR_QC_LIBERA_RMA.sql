-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			RMA
-- // OPERATION:		SP'S
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210715
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
GO

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
		SET @VP_MENSAJE = 'No es una etiqueta de Reemplazo... Verifique'
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

				DECLARE		 @VP_I_NUMBER		VARCHAR(100)	= ''
							,@VP_K_DETALLE		VARCHAR(20)
							,@VP_NET_AREA		DECIMAL(19,4)
							,@VP_S_COLOR_RMA	VARCHAR(50)
							,@VP_CUS_NO			VARCHAR(50)
							,@VP_MODELNO		VARCHAR(50)
							,@VP_D_MODELNO		VARCHAR(250)

				SELECT	@VP_I_NUMBER	= ITEM_NO		,
						@VP_K_DETALLE	= K_DETAILS_RMA	,
						@VP_NET_AREA	= NET_AREA		,
						@VP_S_COLOR_RMA	= S_COLOR_RMA	,
						@VP_CUS_NO		= CUS_NO		,
						@VP_MODELNO		= MODELNO
				FROM	DETAILS_RMA		(NOLOCK)
				WHERE	SERIAL			= @VP_SERIE

				SELECT	@VP_D_MODELNO				= D_ARCUSFIL_PROGRAM_MODEL 
				FROM	ARCUSFIL_PROGRAM_MODEL		(NOLOCK)	
				WHERE	S_ARCUSFIL_PROGRAM_MODEL	= @VP_MODELNO

				IF	( @VP_D_MODELNO	= '' ) OR ( @VP_D_MODELNO = NULL )
				BEGIN
					SET @VP_D_MODELNO	= 'XXXXX'
				END
				
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

						INSERT INTO	INVENTARIO_EMBARQUE_RMA
						(
							[K_ESTATUS_INVENTARIO_EMBARQUE_RMA],
							[ITEM_NO]		,		[QTY]			,
							[CUBE_WIDTH]	,		[SERIAL_1]		,
							[SERIAL_2]		,		[COLOR]			,
							[CUSTOMER]		,		[CUS_PART_NO]	,
							[PROD_CAT]		,		[D_PROD_CAT]	,
							-- =================================	
							[N_EMBARQUE]	,		[PACKING_NO]	,
							[INVOICE_NO]	,		[F_INVENTARIO_EMBARQUE_RMA]	,
							-- ============================
							[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
							[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]		)			
						VALUES	(
							5,
							@VP_I_NUMBER	,		@VP_CANTIDAD	,
							@VP_NET_AREA	,		@VP_SERIE		,
							@VP_K_DETALLE	,		@VP_S_COLOR_RMA	,
							@VP_CUS_NO		,		@VP_CUS_CLIENTE	,
							@VP_MODELNO		,		@VP_D_MODELNO,
							-- =================================	
							0				,		NULL			,
							NULL			,		GETDATE(),
							-- ============================
							0, GETDATE(),	0, GETDATE(),
							0, NULL, NULL			)
						IF @@ROWCOUNT = 0
						BEGIN
							SET @VP_MENSAJE='El registro no fue insertado [EMBQ]. [SERIAL#'+ @VP_SERIE +']'
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