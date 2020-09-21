-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_Folios / Folio Transaccion
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	20/ENE/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas] 
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_INSPECCION_MATERIAL_LOG]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_INSPECCION_MATERIAL_LOG]
GO


CREATE PROCEDURE [dbo].[PG_IN_INSPECCION_MATERIAL_LOG]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_TIPO_INSPECCION_MATERIAL_LOG	INT,
	@PP_K_ORDEN_COMPRA					INT,
	@PP_ORDEN_COMPRA_PEDIDO				VARCHAR(50),
	@PP_K_ITEM							INT,
	@PP_K_INSPECCION_MATERIAL_ORDEN		INT,
	-- ===========================
	@PP_RESULTADO_ANTERIOR				VARCHAR(150),
	@PP_RESULTADO_NUEVO					VARCHAR(150),
	-- ===========================
	@PP_APROBACION_SISTEMA_ANTERIOR		INT,
	@PP_APROBACION_SISTEMA_NUEVO		INT,
	-- ===========================
	@PP_APROBACION_MANUAL_ANTERIOR		INT,
	@PP_APROBACION_MANUAL_NUEVO			INT,
	-- ===========================
	@PP_K_USUARIO_AUTORIZACION			INT,
	@PP_COMENTARIO						VARCHAR(255)

AS

	INSERT INTO INSPECCION_MATERIAL_LOG	
					(					
						[K_TIPO_INSPECCION_MATERIAL_LOG],	
						[K_ORDEN_COMPRA],							
						[ORDEN_COMPRA_PEDIDO],					
						[K_ITEM],							
						[K_INSPECCION_MATERIAL_ORDEN],				
						-- =================================
						[RESULTADO_ANTERIOR],				
						[RESULTADO_NUEVO],					
						-- =================================
						[APROBACION_SISTEMA_ANTERIOR],		
						[APROBACION_SISTEMA_NUEVO],			
						-- =================================
						[APROBACION_MANUAL_ANTERIOR],		
						[APROBACION_MANUAL_NUEVO],			
						-- =================================
						[K_USUARIO_AUTORIZACION],
						[COMENTARIO],		
						-- ===========================
						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )	
				VALUES	
					(	
						@PP_K_TIPO_INSPECCION_MATERIAL_LOG,	 
						@PP_K_ORDEN_COMPRA,							
						@PP_ORDEN_COMPRA_PEDIDO,					
						@PP_K_ITEM,							
						@PP_K_INSPECCION_MATERIAL_ORDEN,		
						-- ===========================
						@PP_RESULTADO_ANTERIOR,				
						@PP_RESULTADO_NUEVO,					
						-- ===========================
						@PP_APROBACION_SISTEMA_ANTERIOR,		
						@PP_APROBACION_SISTEMA_NUEVO,		
						-- ===========================
						@PP_APROBACION_MANUAL_ANTERIOR,		
						@PP_APROBACION_MANUAL_NUEVO,			
						-- ===========================
						@PP_K_USUARIO_AUTORIZACION,
						@PP_COMENTARIO,						
						-- ===========================				
						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
						0, NULL, NULL )	
		
		IF @@ROWCOUNT = 0
			RAISERROR ('ERROR SP: PG_IN_INSPECCION_MATERIAL_LOG', 16, 1 ) --MENSAJE - Severity -State.
	-- ///////////////////////////////////////////
		

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
