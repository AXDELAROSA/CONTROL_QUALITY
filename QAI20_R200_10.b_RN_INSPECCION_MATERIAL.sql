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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_INSPECCION_MATERIAL_VALIDA_PORCENTAJE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_INSPECCION_MATERIAL_VALIDA_PORCENTAJE]
GO


CREATE PROCEDURE [dbo].[PG_RN_INSPECCION_MATERIAL_VALIDA_PORCENTAJE]
	@PP_K_SISTEMA_EXE				[INT],
	@PP_K_USUARIO_ACCION			[INT],
	-- ===========================		
	@PP_INSPECCION_PORCENTAJE			DECIMAL(13,2),
	-- ============================		
	@PP_OPCION_1_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_2_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_3_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_4_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_5_PORCENTAJE				DECIMAL(13,2),
	-- ============================	
	@OU_RESULTADO_VALIDACION		[VARCHAR] (200)		OUTPUT
AS

	DECLARE @VP_RESULTADO	VARCHAR(300)
	
	SET		@VP_RESULTADO	= ''
		
	-- /////////////////////////////////////////////////////

	-- ===========================

	IF @VP_RESULTADO=''
		IF ( @PP_INSPECCION_PORCENTAJE <  @PP_OPCION_1_PORCENTAJE )
			SET @VP_RESULTADO =  'El (%) de la opcion 1 no puede ser mayor al (%) de la inspeccion.' 
	-- ===========================

	IF @VP_RESULTADO=''
		IF ( @PP_INSPECCION_PORCENTAJE <  @PP_OPCION_2_PORCENTAJE )
			SET @VP_RESULTADO =  'El (%) de la opcion 2 no puede ser mayor al (%) de la inspeccion.' 
	-- ===========================
	
	IF @VP_RESULTADO=''
		IF ( @PP_INSPECCION_PORCENTAJE <  @PP_OPCION_3_PORCENTAJE )
			SET @VP_RESULTADO =  'El (%) de la opcion 3 no puede ser mayor al (%) de la inspeccion.' 
	-- ===========================

	IF @VP_RESULTADO=''
		IF ( @PP_INSPECCION_PORCENTAJE <  @PP_OPCION_4_PORCENTAJE )
			SET @VP_RESULTADO =  'El (%) de la opcion 4 no puede ser mayor al (%) de la inspeccion.' 
	-- ===========================

	IF @VP_RESULTADO=''
		IF ( @PP_INSPECCION_PORCENTAJE <  @PP_OPCION_5_PORCENTAJE )
			SET @VP_RESULTADO =  'El (%) de la opcion 5 no puede ser mayor al (%) de la inspeccion.' 
	-- ===========================
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
	@PP_INSPECCION_PORCENTAJE			DECIMAL(13,2),
	-- ============================		
	@PP_OPCION_1_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_2_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_3_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_4_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_5_PORCENTAJE				DECIMAL(13,2),
	-- ============================	
	@OU_RESULTADO_VALIDACION			[VARCHAR] (200)		OUTPUT
AS

	DECLARE @VP_RESULTADO	VARCHAR(300)
	
	SET		@VP_RESULTADO	= ''
		
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_INSPECCION_MATERIAL_VALIDA_PORCENTAJE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
																	PP_INSPECCION_PORCENTAJE, @PP_OPCION_1_PORCENTAJE,
																	@PP_OPCION_2_PORCENTAJE, @PP_OPCION_3_PORCENTAJE,
																	@PP_OPCION_4_PORCENTAJE, @PP_OPCION_5_PORCENTAJE,
																	@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
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
	@PP_INSPECCION_PORCENTAJE			DECIMAL(13,2),
	-- ============================		
	@PP_OPCION_1_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_2_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_3_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_4_PORCENTAJE				DECIMAL(13,2),
	@PP_OPCION_5_PORCENTAJE				DECIMAL(13,2),
	-- ===========================		
	@OU_RESULTADO_VALIDACION			[VARCHAR] (200)		OUTPUT
AS

	DECLARE @VP_RESULTADO	VARCHAR(300)
	
	SET		@VP_RESULTADO	= ''
		
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_INSPECCION_MATERIAL_VALIDA_PORCENTAJE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
																	PP_INSPECCION_PORCENTAJE, @PP_OPCION_1_PORCENTAJE,
																	@PP_OPCION_2_PORCENTAJE, @PP_OPCION_3_PORCENTAJE,
																	@PP_OPCION_4_PORCENTAJE, @PP_OPCION_5_PORCENTAJE,
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
