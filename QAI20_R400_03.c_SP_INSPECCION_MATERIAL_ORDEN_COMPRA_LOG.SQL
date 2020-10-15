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
						[LOTE_PEARL],									
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
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_INSPECCION_MATERIAL_ORDEN_COMPRA_LOG]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_INSPECCION_MATERIAL_ORDEN_COMPRA_LOG]
GO

/*
  EXEC	[dbo].[PG_LI_INSPECCION_MATERIAL_ORDEN_COMPRA_LOG] 0,0, '00296-00001', 1, 82, 201000001
*/

CREATE PROCEDURE [dbo].[PG_LI_INSPECCION_MATERIAL_ORDEN_COMPRA_LOG]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_K_ORDEN_COMPRA_PEDIDO		VARCHAR(100),
	@PP_K_ENTREGA					INT,
	@PP_K_ITEM						INT,
	@PP_LOTE_PEARL					INT
AS

	DECLARE @VP_MENSAJE						VARCHAR(300) = ''
	-- ///////////////////////////////////////////


	SELECT TIPO_INSPECCION_MATERIAL_ORDEN_COMPRA_LOG.D_TIPO_INSPECCION_MATERIAL_ORDEN_COMPRA_LOG, 
			INSPECCION_MATERIAL_ORDEN_COMPRA_LOG.*,
			ISNULL(INSPECCION, 'N/A') AS INSPECCION,
			BD_GENERAL.dbo.USUARIO_PEARL.D_USUARIO_PEARL AS USUARIO_AUTORIZA,
			USER_PEARL.D_USUARIO_PEARL AS USUARIO_ACCION,
			CONVERT(DATE, INSPECCION_MATERIAL_ORDEN_COMPRA_LOG.F_CAMBIO) AS F_LOG,
			-- ===========================
			PART_NUMBER_ITEM_PEARL
			-- =============================	
	FROM INSPECCION_MATERIAL_ORDEN_COMPRA_LOG
	INNER JOIN TIPO_INSPECCION_MATERIAL_ORDEN_COMPRA_LOG ON 
				INSPECCION_MATERIAL_ORDEN_COMPRA_LOG.K_TIPO_INSPECCION_MATERIAL_ORDEN_COMPRA_LOG = TIPO_INSPECCION_MATERIAL_ORDEN_COMPRA_LOG.K_TIPO_INSPECCION_MATERIAL_ORDEN_COMPRA_LOG
	INNER JOIN	COMPRAS.dbo.ITEM		ON	INSPECCION_MATERIAL_ORDEN_COMPRA_LOG.K_ITEM=ITEM.K_ITEM
	INNER JOIN	BD_GENERAL.dbo.USUARIO_PEARL ON	INSPECCION_MATERIAL_ORDEN_COMPRA_LOG.K_USUARIO_AUTORIZACION = BD_GENERAL.dbo.USUARIO_PEARL.K_USUARIO_PEARL
	INNER JOIN	BD_GENERAL.dbo.USUARIO_PEARL AS USER_PEARL ON	INSPECCION_MATERIAL_ORDEN_COMPRA_LOG.K_USUARIO_CAMBIO = USER_PEARL.K_USUARIO_PEARL
	LEFT	JOIN INSPECCION_MATERIAL ON INSPECCION_MATERIAL.K_INSPECCION_MATERIAL = INSPECCION_MATERIAL_ORDEN_COMPRA_LOG.K_INSPECCION_MATERIAL_ORDEN_COMPRA
	WHERE	K_ORDEN_COMPRA_PEDIDO = @PP_K_ORDEN_COMPRA_PEDIDO
	AND		K_ENTREGA = @PP_K_ENTREGA
	AND		INSPECCION_MATERIAL_ORDEN_COMPRA_LOG.K_ITEM	= @PP_K_ITEM
	AND		LOTE_PEARL	= @PP_LOTE_PEARL
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
