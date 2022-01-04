-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			PROCESO_SIMBOLO
-- // OPERATION:		SP'S
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210916
-- ////////////////////////////////////////////////////////////// 

USE	[DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- //////		CONTENIDO DEL SP
--	[PG_LI_PROCESO_SIMBOLO]
--	[PG_SK_PROCESO_SIMBOLO]
--	[PG_IN_PROCESO_SIMBOLO]
--	[PG_UP_PROCESO_SIMBOLO]
--	[PG_DL_PROCESO_SIMBOLO]
-- //////////////////////////////////////////////////////////////


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_PROCESO_SIMBOLO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_PROCESO_SIMBOLO]
GO
--		 EXECUTE [dbo].[PG_LI_PROCESO_SIMBOLO] 0,139, -1
--		 EXECUTE [dbo].[PG_LI_PROCESO_SIMBOLO] 0,139, 50
--		 EXECUTE [dbo].[PG_LI_PROCESO_SIMBOLO] 0,139, 3	
CREATE PROCEDURE [dbo].[PG_LI_PROCESO_SIMBOLO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_TIPO_PROCESO_SIMBOLO		INT
AS	
	SELECT	D_TIPO_PROCESO_SIMBOLO,
			(CASE
				WHEN	D_PROCESO_SIMBOLO <> ''	THEN	D_PROCESO_SIMBOLO
				ELSE	'DEFINIDA POR EL MODELO'
			END) AS D_PROCESO_SIMBOLO,
			RUTA_SERVIDOR + RUTA_IMAGEN + RUTA_EXTENSION	AS RUTA_DESTINO,
			*
	FROM	[PROCESO_SIMBOLO]			(NOLOCK)
	INNER JOIN 	TIPO_PROCESO_SIMBOLO	(NOLOCK) ON TIPO_PROCESO_SIMBOLO.K_TIPO_PROCESO_SIMBOLO	= PROCESO_SIMBOLO.K_TIPO_PROCESO_SIMBOLO
	WHERE	(	@PP_K_TIPO_PROCESO_SIMBOLO	= -1 OR PROCESO_SIMBOLO.K_TIPO_PROCESO_SIMBOLO = @PP_K_TIPO_PROCESO_SIMBOLO )
	--WHERE	K_TIPO_PROCESO_SIMBOLO >= 50
	ORDER	BY PROCESO_SIMBOLO.D_PROCESO_SIMBOLO
--	-- /////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_PROCESO_SIMBOLO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_PROCESO_SIMBOLO]
GO
--		 EXECUTE [dbo].[PG_SK_PROCESO_SIMBOLO] 0,139, 10
CREATE PROCEDURE [dbo].[PG_SK_PROCESO_SIMBOLO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_PROCESO_SIMBOLO			INT
AS
	-- ///////////////////////////////////////////			
	SELECT		TOP (1)
				D_TIPO_PROCESO_SIMBOLO,
				RUTA_SERVIDOR + RUTA_IMAGEN + RUTA_EXTENSION	AS RUTA_DESTINO,
				PROCESO_SIMBOLO.*
				-- =============================	
	FROM		PROCESO_SIMBOLO			(NOLOCK) 
	INNER JOIN 	TIPO_PROCESO_SIMBOLO	(NOLOCK) ON TIPO_PROCESO_SIMBOLO.K_TIPO_PROCESO_SIMBOLO	= PROCESO_SIMBOLO.K_TIPO_PROCESO_SIMBOLO
				-- =============================
	WHERE		K_PROCESO_SIMBOLO		= @PP_K_PROCESO_SIMBOLO
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_PROCESO_SIMBOLO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_PROCESO_SIMBOLO]
GO
--		 EXECUTE [dbo].[PG_IN_PROCESO_SIMBOLO] 1,139,
CREATE PROCEDURE [dbo].[PG_IN_PROCESO_SIMBOLO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_TIPO_PROCESO_SIMBOLO		INT,
	-- ============================
	@PP_D_PROCESO_SIMBOLO			VARCHAR(500),
	@PP_RUTA_NUEVA					NVARCHAR(MAX)
	-- ============================
AS			
DECLARE  @VP_MENSAJE						NVARCHAR(MAX)
		,@VP_K_PROCESO_SIMBOLO			INT = 0
-- /////////////////////////////////////////////////////////////////////
BEGIN TRANSACTION 
BEGIN TRY
	--============================================================================
	--======================================INSERTAR EL PROCESO_SIMBOLO
	--============================================================================
		INSERT INTO PROCESO_SIMBOLO
			(	-- ============================
				[K_TIPO_PROCESO_SIMBOLO]		,
				-- ============================
				[D_PROCESO_SIMBOLO]				,
				-- ============================
				[RUTA_SERVIDOR]					,
				[RUTA_IMAGEN]					,
				[RUTA_EXTENSION]				,
				-- ============================
				[K_USUARIO_ALTA]	, [F_ALTA], 
				[K_USUARIO_CAMBIO]	, [F_CAMBIO]	)
		VALUES	
			(	-- ============================
				@PP_K_TIPO_PROCESO_SIMBOLO	,
				-- ============================
				@PP_D_PROCESO_SIMBOLO		,
				-- ============================
				''	,
				''	,
				''	,
				-- ============================
				@PP_K_USUARIO_ACCION, GETDATE(), 
				@PP_K_USUARIO_ACCION, GETDATE()	)
		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='No se generó. [PS#'+CONVERT(VARCHAR(10),@VP_K_PROCESO_SIMBOLO)+']'
			RAISERROR (@VP_MENSAJE, 16, 1 ) 
		END
		ELSE
		BEGIN
			SELECT @VP_K_PROCESO_SIMBOLO	= SCOPE_IDENTITY()

			IF	( @VP_K_PROCESO_SIMBOLO	= 0 OR @VP_K_PROCESO_SIMBOLO IS NULL )
			BEGIN
				RAISERROR ('Error en la asignación de identidad.[HDR]', 16, 1 ) 
			END
		END

		DECLARE	@VP_COUNT_K_PROCESO	INT	= 0
		
		SELECT	@VP_COUNT_K_PROCESO		= COUNT(K_PROCESO_SIMBOLO)
		FROM	PROCESO_SIMBOLO			(NOLOCK)
		WHERE	K_TIPO_PROCESO_SIMBOLO	= @PP_K_TIPO_PROCESO_SIMBOLO
		
		IF @VP_COUNT_K_PROCESO	= 0
		BEGIN
				RAISERROR ('Error en la asignación del nombre de IMAGEN para el proceso.[PS]', 16, 1 ) 
		END

		
		DECLARE	@VP_RUTA_SERVIDOR	VARCHAR(500) = '\\10.1.1.5\documents\IT\001_DEVELOPER_FILES\APQP\AV_HE_PROCESO\'
		DECLARE	@VP_RUTA_IMAGEN		VARCHAR(500) = @PP_K_TIPO_PROCESO_SIMBOLO + '_' + @VP_COUNT_K_PROCESO
		DECLARE	@VP_RUTA_EXTENSION	VARCHAR(500) = '.PNG'


		UPDATE	PROCESO_SIMBOLO
		SET		[RUTA_SERVIDOR]		= @VP_RUTA_SERVIDOR		,
				[RUTA_IMAGEN]		= @VP_RUTA_IMAGEN		,
				[RUTA_EXTENSION]	= @VP_RUTA_EXTENSION
		WHERE	K_PROCESO_SIMBOLO	= @VP_K_PROCESO_SIMBOLO
		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='No se guardó el registro. [PS#'+CONVERT(VARCHAR(10),@VP_K_PROCESO_SIMBOLO)+']'
			RAISERROR (@VP_MENSAJE, 16, 1 ) 
		END

		DECLARE @VP_RUTA_DESTINO	VARCHAR(500) = @VP_RUTA_SERVIDOR + @VP_RUTA_IMAGEN + @VP_RUTA_EXTENSION
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
	-- /////////////////////////////////////////////////////////////////////	
	IF @VP_MENSAJE<>''
	BEGIN
		SET		@VP_MENSAJE = 'No es posible [Insertar]: ' + @VP_MENSAJE 
	END
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_PROCESO_SIMBOLO AS CLAVE, @VP_RUTA_DESTINO AS RUTA_DESTINO, @PP_RUTA_NUEVA AS RUTA_ORIGEN_NUEVA
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / FICHA
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_PROCESO_SIMBOLO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_PROCESO_SIMBOLO]
GO
--		 EXECUTE [dbo].[PG_UP_PROCESO_SIMBOLO] 1,139,
CREATE PROCEDURE [dbo].[PG_UP_PROCESO_SIMBOLO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_PROCESO_SIMBOLO			INT,
	@PP_K_TIPO_PROCESO_SIMBOLO		INT,
	-- ============================
	@PP_D_PROCESO_SIMBOLO			VARCHAR(500),
	@PP_RUTA_NUEVA					NVARCHAR(MAX)
	-- ============================
AS			
DECLARE  @VP_MENSAJE						NVARCHAR(MAX)
-- /////////////////////////////////////////////////////////////////////
BEGIN TRANSACTION 
BEGIN TRY
	--/////////////////////////////////////////////////////////////
		DECLARE @VP_EXISTE_EN_HE		INT	= 0
		
		SELECT	@VP_EXISTE_EN_HE		= COUNT(K_PROCESO_SIMBOLO)
		FROM	HOJA_EMPAQUE_PROCESO	(NOLOCK)
		WHERE	K_PROCESO_SIMBOLO		= @PP_K_PROCESO_SIMBOLO
		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='No se obtuvo el registro de la [HE#'+CONVERT(VARCHAR(10),@PP_K_PROCESO_SIMBOLO)+'], verifique...'
			RAISERROR (@VP_MENSAJE, 16, 1 ) 
		END			

		IF @VP_EXISTE_EN_HE	> 0
		BEGIN
			SET @VP_MENSAJE='El [PS#'+CONVERT(VARCHAR(10),@PP_K_PROCESO_SIMBOLO)+'] no puede ser modificado ya se encuentra asignado a una HOJA de EMPAQUE, verifique...'
			RAISERROR (@VP_MENSAJE, 16, 1 ) 
		END
	--////////////////////////////////////////////////////////////

	--============================================================================
	--======================================ACTUALIZAR EL PROCESO_SIMBOLO
	--============================================================================
		UPDATE	PROCESO_SIMBOLO
		SET		[K_TIPO_PROCESO_SIMBOLO]		= @PP_K_TIPO_PROCESO_SIMBOLO	,
				-- ============================
				[D_PROCESO_SIMBOLO]				= @PP_D_PROCESO_SIMBOLO			,
				-- ============================
				[K_USUARIO_CAMBIO]				= @PP_K_USUARIO_ACCION,
				[F_CAMBIO]						= GETDATE()
		WHERE	K_PROCESO_SIMBOLO				= @PP_K_PROCESO_SIMBOLO
		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='No se actualizó del registro. [PS#'+CONVERT(VARCHAR(10),@PP_K_PROCESO_SIMBOLO)+']'
			RAISERROR (@VP_MENSAJE, 16, 1 ) 
		END
		
		DECLARE	@VP_RUTA_SERVIDOR	VARCHAR(500) = ''
		DECLARE	@VP_RUTA_IMAGEN		VARCHAR(500) = ''
		DECLARE	@VP_RUTA_EXTENSION	VARCHAR(500) = ''

		SELECT	@VP_RUTA_SERVIDOR		=	[RUTA_SERVIDOR]	,
				@VP_RUTA_IMAGEN			=	[RUTA_IMAGEN]	,
				@VP_RUTA_EXTENSION		=	[RUTA_EXTENSION]
		FROM	PROCESO_SIMBOLO
		WHERE	K_PROCESO_SIMBOLO	= @PP_K_PROCESO_SIMBOLO
		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='No se obtuvo la ruta destino del registro. [PS#'+CONVERT(VARCHAR(10),@PP_K_PROCESO_SIMBOLO)+']'
			RAISERROR (@VP_MENSAJE, 16, 1 ) 
		END

		DECLARE @VP_RUTA_DESTINO	VARCHAR(500) = @VP_RUTA_SERVIDOR + @VP_RUTA_IMAGEN + @VP_RUTA_EXTENSION
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
	-- /////////////////////////////////////////////////////////////////////	
	IF @VP_MENSAJE<>''
	BEGIN
		SET		@VP_MENSAJE = 'No es posible [Insertar]: ' + @VP_MENSAJE 
	END
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_PROCESO_SIMBOLO AS CLAVE, @VP_RUTA_DESTINO AS RUTA_DESTINO, @PP_RUTA_NUEVA AS RUTA_ORIGEN_NUEVA
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////
--	EXECUTE [dbo].[PG_DL_PROCESO_SIMBOLO] 0,139,380,2,2
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_PROCESO_SIMBOLO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_PROCESO_SIMBOLO]
GO
CREATE PROCEDURE [dbo].[PG_DL_PROCESO_SIMBOLO]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_PROCESO_SIMBOLO				INT
AS
DECLARE @VP_MENSAJE				NVARCHAR(MAX) = ''
BEGIN TRANSACTION 
BEGIN TRY
	--/////////////////////////////////////////////////////////////
		DECLARE @VP_EXISTE_EN_HE		INT	= 0
		
		SELECT	@VP_EXISTE_EN_HE		= COUNT(K_PROCESO_SIMBOLO)
		FROM	HOJA_EMPAQUE_PROCESO	(NOLOCK)
		WHERE	K_PROCESO_SIMBOLO		= @PP_K_PROCESO_SIMBOLO
		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='No se obtuvo el registro de la [HE#'+CONVERT(VARCHAR(10),@PP_K_PROCESO_SIMBOLO)+'], verifique...'
			RAISERROR (@VP_MENSAJE, 16, 1 ) 
		END			

		IF @VP_EXISTE_EN_HE	> 0
		BEGIN
			SET @VP_MENSAJE='El [PS#'+CONVERT(VARCHAR(10),@PP_K_PROCESO_SIMBOLO)+'] no puede ser eliminado ya se encuentra asignado a una HOJA de EMPAQUE, verifique...'
			RAISERROR (@VP_MENSAJE, 16, 1 ) 
		END
	--////////////////////////////////////////////////////////////

		UPDATE	PROCESO_SIMBOLO
		SET		
				[L_BORRADO]				= 1			,
				-- ====================
				[F_BAJA]				= GETDATE()	,
				[K_USUARIO_BAJA]		= @PP_K_USUARIO_ACCION
		WHERE	K_PROCESO_SIMBOLO		= @PP_K_PROCESO_SIMBOLO
		IF @@ROWCOUNT = 0
		BEGIN
			SET @VP_MENSAJE='la orden no puede ser borrada. [HDR#'+CONVERT(VARCHAR(10),@PP_K_PROCESO_SIMBOLO)+']'
		END

-- /////////////////////////////////////////////////////////////////////
COMMIT TRANSACTION 
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION
	DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
	SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
	SET @VP_MENSAJE = 'ERROR:// ' + @VP_ERROR_TRANS
END CATCH	

	-- /////////////////////////////////////////////////////////////////////	
	IF @VP_MENSAJE<>''
	BEGIN
		SET		@VP_MENSAJE = 'No es posible [ELIMINAR]: ' + @VP_MENSAJE 
	END

	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_PROCESO_SIMBOLO AS CLAVE
	-- /////////////////////////////////////////////////////////////////////	
GO
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////