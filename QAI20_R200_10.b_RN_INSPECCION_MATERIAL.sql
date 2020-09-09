-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			QA INSPECCION DE MATERIAL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	29/AGO/2020
-- //////////////////////////////////////////////////////////////  

USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////


-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_BORRABLE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_INSPECCION_MATERIAL_EXISTE_EN_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_INSPECCION_MATERIAL_EXISTE_EN_ORDEN]
GO


CREATE PROCEDURE [dbo].[PG_RN_INSPECCION_MATERIAL_EXISTE_EN_ORDEN]
	@PP_K_SISTEMA_EXE				[INT],
	@PP_K_USUARIO_ACCION			[INT],
	-- ===========================		
	@PP_NUMERO_PARTE				VARCHAR(150),
	@PP_K_INSPECCION_MATERIAL		[INT],
	-- ============================	
	@OU_RESULTADO_VALIDACION		[VARCHAR] (200)		OUTPUT
AS

	DECLARE @VP_RESULTADO	VARCHAR(300)
	
	SET		@VP_RESULTADO	= ''
		
	-- /////////////////////////////////////////////////////

	
	DECLARE @VP_N_K_INSPECCION_MATERIAL INT = 0
	SELECT @VP_N_K_INSPECCION_MATERIAL = COUNT(K_INSPECCION_MATERIAL)
	FROM [INSPECCION_MATERIAL_ORDEN]
	WHERE NUMERO_PARTE = @PP_NUMERO_PARTE
	AND	K_INSPECCION_MATERIAL = @PP_K_INSPECCION_MATERIAL

	IF @VP_N_K_INSPECCION_MATERIAL IS NULL
		SET @VP_N_K_INSPECCION_MATERIAL = 0
	-- ===========================

	IF @VP_N_K_INSPECCION_MATERIAL > 0
		SET @VP_RESULTADO = 'La inspeccion ya se aplico por lo menos a una orden'
	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO



-- ====================================================================================================
-- ====================================================================================================
-- ////////////////////////////////////////////////////////////////////////////////////////////////////
-- ====================================================================================================
-- ====================================================================================================



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> VALIDACION INSERT
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_INSPECCION_MATERIAL_INSERT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_INSPECCION_MATERIAL_INSERT]
GO


CREATE PROCEDURE [dbo].[PG_RN_INSPECCION_MATERIAL_INSERT]
	@PP_K_SISTEMA_EXE					[INT],
	@PP_K_USUARIO_ACCION				[INT],
	-- ===========================	
	@PP_NUMERO_PARTE					VARCHAR(150),
	@PP_K_INSPECCION_MATERIAL			[INT],
	-- ============================	
	@OU_RESULTADO_VALIDACION			[VARCHAR] (200)		OUTPUT
AS

	DECLARE @VP_RESULTADO	VARCHAR(300)
	
	SET		@VP_RESULTADO	= ''
		
	-- ///////////////////////////////////////////

	--IF @VP_RESULTADO=''
	--		EXECUTE [dbo].[PG_RN_INSPECCION_MATERIAL_EXISTE_EN_ORDEN]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
	--																	@PP_NUMERO_PARTE, @PP_K_INSPECCION_MATERIAL,
	--																	@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	-- ///////////////////////////////////////////
	
	IF	@VP_RESULTADO<>''
		SET	@VP_RESULTADO = @VP_RESULTADO + ' //INS//'
	
	-- ///////////////////////////////////////////
		
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> VALIDACION UPDATE
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_INSPECCION_MATERIAL_UPDATE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_INSPECCION_MATERIAL_UPDATE]
GO


CREATE PROCEDURE [dbo].[PG_RN_INSPECCION_MATERIAL_UPDATE]
	@PP_K_SISTEMA_EXE					[INT],
	@PP_K_USUARIO_ACCION				[INT],
	-- ===========================		
	@PP_NUMERO_PARTE					VARCHAR(150),
	@PP_K_INSPECCION_MATERIAL			[INT],
	-- ============================	
	@OU_RESULTADO_VALIDACION			[VARCHAR] (200)		OUTPUT
AS

	DECLARE @VP_RESULTADO	VARCHAR(300)
	
	SET		@VP_RESULTADO	= ''
		
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_INSPECCION_MATERIAL_EXISTE_EN_ORDEN]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
																	@PP_NUMERO_PARTE, @PP_K_INSPECCION_MATERIAL,
																	@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	
	-- //////////////////////////////////////

	IF	@VP_RESULTADO<>''
		SET	@VP_RESULTADO = @VP_RESULTADO + ' //UPD//'
	
	-- ///////////////////////////////////////////
		
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO






-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> VALIDACION DELETE
-- //////////////////////////////////////////////////////////////


--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_INSPECCION_MATERIAL_DELETE]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_RN_INSPECCION_MATERIAL_DELETE]
--GO


--CREATE PROCEDURE [dbo].[PG_RN_INSPECCION_MATERIAL_DELETE]
--	@PP_K_SISTEMA_EXE					[INT],
--	@PP_K_USUARIO_ACCION				[INT],
--	-- ===========================		
--	@PP_K_INSPECCION_MATERIAL							[INT],	
--	-- ===========================		
--	@OU_RESULTADO_VALIDACION			[VARCHAR] (200)		OUTPUT
--AS

--	DECLARE @VP_RESULTADO	VARCHAR(300)
	
--	SET		@VP_RESULTADO	= ''
		
--	-- ///////////////////////////////////////////

--	--IF @VP_RESULTADO=''
--	--	EXECUTE [dbo].[PG_RN_DATA_ACCESO_DELETE]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
--	--													1, -- @PP_K_DATA_SISTEMA,	
--	--													@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
--	-- ///////////////////////////////////////////

--	IF @VP_RESULTADO=''
--		EXECUTE [dbo].[PG_RN_INSPECCION_MATERIAL_EXISTE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
--															@PP_K_INSPECCION_MATERIAL,	 
--															@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
--	-- ///////////////////////////////////////////

--	IF @VP_RESULTADO=''
--		EXECUTE [dbo].[PG_RN_INSPECCION_MATERIAL_ES_BORRABLE]	 @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
--															@PP_K_INSPECCION_MATERIAL,	 
--															@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
--	-- ///////////////////////////////////////////

--	IF	@VP_RESULTADO<>''
--		SET	@VP_RESULTADO = @VP_RESULTADO + ' //DEL//'
	
--	-- ///////////////////////////////////////////
		
--	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

--	-- /////////////////////////////////////////////////////
--GO



-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
