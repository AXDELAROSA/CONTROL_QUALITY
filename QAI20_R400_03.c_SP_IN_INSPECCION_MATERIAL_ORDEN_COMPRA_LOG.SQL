-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			INSPECCION MATERIAL / ORDEN COMPRA
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	09/OCT/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_INSPECCION_MATERIAL_ORDEN_COMPRA_LOG]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_INSPECCION_MATERIAL_ORDEN_COMPRA_LOG]
GO


CREATE PROCEDURE [dbo].[PG_IN_INSPECCION_MATERIAL_ORDEN_COMPRA_LOG]
	@PP_K_SISTEMA_EXE								INT,
	@PP_K_USUARIO_ACCION							INT,
	-- ===========================
	@PP_K_TIPO_INSPECCION_MATERIAL_ORDEN_COMPRA_LOG	INT,
	@PP_K_ORDEN_COMPRA								INT,
	@PP_K_ORDEN_COMPRA_PEDIDO						VARCHAR(100),
	@PP_K_ENTREGA									INT,
	@PP_K_ITEM										INT,
	@PP_LOTE_PEARL									VARCHAR(100),
	@PP_K_INSPECCION_MATERIAL_ORDEN_COMPRA			INT,
	-- ===========================
	@PP_VALOR_ANTERIOR								VARCHAR(150),
	@PP_VALOR_NUEVO									VARCHAR(150),
	-- ===========================
	@PP_K_USUARIO_AUTORIZACION						INT,
	@PP_COMENTARIO									VARCHAR(255)

AS

	INSERT INTO INSPECCION_MATERIAL_ORDEN_COMPRA_LOG	
					(					
						[K_TIPO_INSPECCION_MATERIAL_ORDEN_COMPRA_LOG],	
						[K_ORDEN_COMPRA],								
						[K_ORDEN_COMPRA_PEDIDO],							
						[K_ENTREGA],										
						[K_ITEM],										
						[K_LOTE_PEARL],									
						[K_INSPECCION_MATERIAL_ORDEN_COMPRA],
						-- =================================			
						[VALOR_ANTERIOR],			
						[VALOR_NUEVO],								
						-- =================================
						[K_USUARIO_AUTORIZACION],
						[COMENTARIO],	
						-- ===========================
						[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
						[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )	
				VALUES	
					(	
						@PP_K_TIPO_INSPECCION_MATERIAL_ORDEN_COMPRA_LOG,
						@PP_K_ORDEN_COMPRA,
						@PP_K_ORDEN_COMPRA_PEDIDO,
						@PP_K_ENTREGA,					
						@PP_K_ITEM,								
						@PP_LOTE_PEARL,									
						@PP_K_INSPECCION_MATERIAL_ORDEN_COMPRA,
						-- ===========================
						@PP_VALOR_ANTERIOR,		
						@PP_VALOR_NUEVO,							
						-- ===========================
						@PP_K_USUARIO_AUTORIZACION,				
						@PP_COMENTARIO,
						-- ===========================				
						@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
						0, NULL, NULL )	
		
		IF @@ROWCOUNT = 0
			RAISERROR ('ERROR SP: PG_IN_INSPECCION_MATERIAL_ORDEN_COMPRA_LOG', 16, 1 ) --MENSAJE - Severity -State.
	-- ///////////////////////////////////////////
		

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
