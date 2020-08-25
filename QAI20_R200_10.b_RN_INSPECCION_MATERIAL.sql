-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	RH
-- // MODULO:			PUESTO DESCRIPCION
-- // OPERACION:		REGLAS DE NEGOCIO
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	04/FEB/2020
-- ////////////////////////////////////////////////////////////// 

USE [RH]
GO

-- //////////////////////////////////////////////////////////////


-- //////////////////////////////////////////////////////////////





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_BORRABLE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_PUESTO_ES_MODIFICABLE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_PUESTO_ES_MODIFICABLE]
GO


CREATE PROCEDURE [dbo].[PG_RN_PUESTO_ES_MODIFICABLE]
	@PP_K_SISTEMA_EXE				[INT],
	@PP_K_USUARIO_ACCION			[INT],
	-- ===========================		
	@PP_K_PUESTO					[INT],
	-- ===========================		
	@OU_RESULTADO_VALIDACION		[VARCHAR] (200)		OUTPUT
AS

	DECLARE @VP_RESULTADO	VARCHAR(300)
	
	SET		@VP_RESULTADO	= ''
		
	-- /////////////////////////////////////////////////////

	DECLARE @VP_K_ESTATUS_PUESTO	INT = 0
	DECLARE @VP_D_ESTATUS_PUESTO	VARCHAR(100)

	SELECT	@VP_K_ESTATUS_PUESTO	=	PUESTO.K_ESTATUS_PUESTO,
			@VP_D_ESTATUS_PUESTO	=	D_ESTATUS_PUESTO
											FROM	PUESTO, ESTATUS_PUESTO
											WHERE	PUESTO.K_ESTATUS_PUESTO=ESTATUS_PUESTO.K_ESTATUS_PUESTO
											AND		K_PUESTO=@PP_K_PUESTO
										
	-- =============================
	
	IF @VP_RESULTADO=''
		IF (@VP_K_ESTATUS_PUESTO = 3 )
			SET @VP_RESULTADO =  'El [PUESTO] No se puede Modificar su Estatus[(#'+CONVERT(VARCHAR(10),@VP_K_ESTATUS_PUESTO)+')' + @VP_D_ESTATUS_PUESTO + '] NO lo permite.' 

	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO








-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_BORRABLE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_PUESTO_ES_BORRABLE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_PUESTO_ES_BORRABLE]
GO


CREATE PROCEDURE [dbo].[PG_RN_PUESTO_ES_BORRABLE]
	@PP_K_SISTEMA_EXE				[INT],
	@PP_K_USUARIO_ACCION			[INT],
	-- ===========================		
	@PP_K_PUESTO			[INT],
	-- ===========================		
	@OU_RESULTADO_VALIDACION		[VARCHAR] (200)		OUTPUT
AS

	DECLARE @VP_RESULTADO	VARCHAR(300)
	
	SET		@VP_RESULTADO	= ''
		
	-- /////////////////////////////////////////////////////

	DECLARE @VP_K_ESTATUS_PUESTO	INT = 0
	DECLARE @VP_D_ESTATUS_PUESTO	VARCHAR(100)

	SELECT	@VP_K_ESTATUS_PUESTO	=	PUESTO.K_ESTATUS_PUESTO,
			@VP_D_ESTATUS_PUESTO	=	D_ESTATUS_PUESTO
											FROM	PUESTO, ESTATUS_PUESTO
											WHERE	PUESTO.K_ESTATUS_PUESTO=ESTATUS_PUESTO.K_ESTATUS_PUESTO
											AND		K_PUESTO=@PP_K_PUESTO
	-- =============================
	
	IF @VP_RESULTADO=''
		IF (@VP_K_ESTATUS_PUESTO IN (1, 2))
			SET @VP_RESULTADO =  'El [PUESTO] No se puede Eliminar su Estatus[(#'+CONVERT(VARCHAR(10),@VP_K_ESTATUS_PUESTO)+')' + @VP_D_ESTATUS_PUESTO + '] NO lo permite.' 

	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_BORRABLE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_PUESTO_EXISTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_PUESTO_EXISTE]
GO


CREATE PROCEDURE [dbo].[PG_RN_PUESTO_EXISTE]
	@PP_K_SISTEMA_EXE				[INT],
	@PP_K_USUARIO_ACCION			[INT],
	-- ===========================		
	@PP_K_PUESTO			[INT],
	-- ===========================		
	@OU_RESULTADO_VALIDACION		[VARCHAR] (200)		OUTPUT
AS

	DECLARE @VP_RESULTADO	VARCHAR(300)
	
	SET		@VP_RESULTADO	= ''
		
	-- /////////////////////////////////////////////////////

	DECLARE @VP_K_PUESTO	INT
	DECLARE @VP_L_BORRADO			INT
		
	SELECT	@VP_K_PUESTO	=	PUESTO.K_PUESTO,
			@VP_L_BORRADO			=	PUESTO.L_BORRADO
									FROM	PUESTO
									WHERE	PUESTO.K_PUESTO=@PP_K_PUESTO 						

	-- ===========================

	IF @VP_RESULTADO=''
		IF ( @VP_K_PUESTO IS NULL )
			SET @VP_RESULTADO =  'El [PUESTO] no existe.' 
	
	-- ===========================

	IF @VP_RESULTADO=''
		IF @VP_L_BORRADO=1
			SET @VP_RESULTADO =  'El [PUESTO] fue dado de baja.' 
					
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


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_PUESTO_INSERT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_PUESTO_INSERT]
GO


CREATE PROCEDURE [dbo].[PG_RN_PUESTO_INSERT]
	@PP_K_SISTEMA_EXE					[INT],
	@PP_K_USUARIO_ACCION				[INT],
	-- ===========================		
	@OU_RESULTADO_VALIDACION			[VARCHAR] (200)		OUTPUT
AS

	DECLARE @VP_RESULTADO	VARCHAR(300)
	
	SET		@VP_RESULTADO	= ''
		
	-- ///////////////////////////////////////////

	--IF @VP_RESULTADO=''
	--	EXECUTE [dbo].[PG_RN_DATA_ACCESO_INSERT]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
	--												1, -- @PP_K_DATA_SISTEMA,	
	--												@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
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


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_PUESTO_UPDATE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_PUESTO_UPDATE]
GO


CREATE PROCEDURE [dbo].[PG_RN_PUESTO_UPDATE]
	@PP_K_SISTEMA_EXE					[INT],
	@PP_K_USUARIO_ACCION				[INT],
	-- ===========================		
	@PP_K_PUESTO				[INT],
	-- ===========================		
	@OU_RESULTADO_VALIDACION			[VARCHAR] (200)		OUTPUT
AS

	DECLARE @VP_RESULTADO	VARCHAR(300)
	
	SET		@VP_RESULTADO	= ''
		
	-- ///////////////////////////////////////////

	--IF @VP_RESULTADO=''
	--	EXECUTE [dbo].[PG_RN_DATA_ACCESO_UPDATE]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
	--												1, -- @PP_K_DATA_SISTEMA,	
	--												@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	-- //////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_PUESTO_EXISTE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_K_PUESTO,	 
														@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	-- //////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_PUESTO_ES_MODIFICABLE]	 @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@PP_K_PUESTO,	 
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


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_PUESTO_DELETE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_PUESTO_DELETE]
GO


CREATE PROCEDURE [dbo].[PG_RN_PUESTO_DELETE]
	@PP_K_SISTEMA_EXE					[INT],
	@PP_K_USUARIO_ACCION				[INT],
	-- ===========================		
	@PP_K_PUESTO							[INT],	
	-- ===========================		
	@OU_RESULTADO_VALIDACION			[VARCHAR] (200)		OUTPUT
AS

	DECLARE @VP_RESULTADO	VARCHAR(300)
	
	SET		@VP_RESULTADO	= ''
		
	-- ///////////////////////////////////////////

	--IF @VP_RESULTADO=''
	--	EXECUTE [dbo].[PG_RN_DATA_ACCESO_DELETE]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
	--													1, -- @PP_K_DATA_SISTEMA,	
	--													@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_PUESTO_EXISTE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_K_PUESTO,	 
															@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_PUESTO_ES_BORRABLE]	 @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_K_PUESTO,	 
															@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	-- ///////////////////////////////////////////

	IF	@VP_RESULTADO<>''
		SET	@VP_RESULTADO = @VP_RESULTADO + ' //DEL//'
	
	-- ///////////////////////////////////////////
		
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO



-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
