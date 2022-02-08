-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[PPMS_PEARL]
-- // MODULO:			RN LIBERAR ORDEN
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	02/FEB/2022
-- //////////////////////////////////////////////////////////////  

USE [PPMS_PEARL]
GO

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_BORRABLE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDA_KIT_LIBERADO_X_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDA_KIT_LIBERADO_X_ORDEN]
GO

/*
	EXEC [dbo].[PG_RN_VALIDA_KIT_LIBERADO_X_ORDEN] 0, 144, '53190' 
	EXEC [dbo].[PG_RN_VALIDA_KIT_LIBERADO_X_ORDEN] 0, 144, '51467' 
*/

CREATE PROCEDURE [dbo].[PG_RN_VALIDA_KIT_LIBERADO_X_ORDEN]
	@PP_K_SISTEMA_EXE				[INT],
	@PP_K_USUARIO_ACCION			[INT],
	-- ===========================		
	@PP_ORDEN						[VARCHAR](20),
	-- ============================	
	@OU_RESULTADO_VALIDACION		[VARCHAR] (255)		OUTPUT
AS

	DECLARE @VP_RESULTADO	VARCHAR(300) = ''
	
	-- /////////SE VALIDA SI ESTA LIGADA A OTRA ORDEN///////////////////////////////////////
	DECLARE @VP_ORDEN_COMPLEMENTO VARCHAR(20) = '', @VP_VALIDAR_PROCESO INT = 1;

	SELECT @VP_ORDEN_COMPLEMENTO = ISNULL(lotno, '') 
	FROM DATA_02.[dbo].ccjobhdr_sql 
	WHERE jobno = @PP_ORDEN

	IF @VP_ORDEN_COMPLEMENTO IS NULL 
		SET @VP_ORDEN_COMPLEMENTO = ''
	
	IF @VP_ORDEN_COMPLEMENTO <> ''
		BEGIN
			IF CONVERT( INT, @PP_ORDEN ) < CONVERT( INT, @VP_ORDEN_COMPLEMENTO )
				BEGIN
					DECLARE @VP_N_ORDEN_LIBERADA INT = 0
					SELECT @VP_N_ORDEN_LIBERADA = COUNT([K_ORDEN_LIBERADA])
					FROM [PPMS_PEARL].DBO.[ORDEN_LIBERADA] (NOLOCK)
					WHERE ORDEN = @VP_ORDEN_COMPLEMENTO

					IF ( @VP_N_ORDEN_LIBERADA IS NULL OR @VP_N_ORDEN_LIBERADA = 0 )
						BEGIN
							SELECT @VP_N_ORDEN_LIBERADA = COUNT(ID) 
							FROM [PPMS_PEARL].[dbo].[QC] 
							WHERE Order_No = @VP_ORDEN_COMPLEMENTO

							IF ( @VP_N_ORDEN_LIBERADA IS NULL OR @VP_N_ORDEN_LIBERADA = 0 )
								SET @VP_RESULTADO = 'Debe liberar primero su orden complemento: ' + @VP_ORDEN_COMPLEMENTO
						END
				END 
			ELSE
				BEGIN
					SET @VP_VALIDAR_PROCESO = 0
				END
		END

	IF ( @VP_RESULTADO = '' AND @VP_VALIDAR_PROCESO = 1 )
		BEGIN
			-- /////////SE CREA EL CURSOR PARA RECORRER LOS KITS EN LA ORDEN///////////////////////////////////////
			DECLARE @VP_ITEM_NO VARCHAR(50) = '', @VP_MODELO VARCHAR(50) = '', @VP_VERSION VARCHAR(50) = '', @VP_SERIAL VARCHAR(50) = '';
			DECLARE CU_KIT_TERMINADO CURSOR 
			FOR
				SELECT	LTRIM(RTRIM(ccjoblin_sql.item_no)), 
						LEFT(LTRIM(RTRIM(ChangeLevel)), 3),
						RIGHT(LTRIM(RTRIM(ChangeLevel)), 4),
						CONCAT(LTRIM(RTRIM(ccjoblin_sql.jobno)) , RIGHT('000' + CONVERT(VARCHAR(5), ccjoblin_sql.Ser_No), 3))
				FROM DATA_02.DBO.ccjoblin_sql  (NOLOCK)
				WHERE LTRIM(RTRIM(ccjoblin_sql.jobno)) = @PP_ORDEN
				ORDER BY Ser_No

			OPEN CU_KIT_TERMINADO
			FETCH NEXT FROM CU_KIT_TERMINADO INTO @VP_ITEM_NO, @VP_MODELO, @VP_VERSION, @VP_SERIAL

			WHILE @@FETCH_STATUS = 0 AND @VP_RESULTADO = ''
				BEGIN
					DECLARE @VP_N_KIT_PERFORADO INT = 0
					SELECT	@VP_N_KIT_PERFORADO = COUNT(KIT_RUTA.K_KIT_RUTA_EVENTO) 
					FROM DATA_02.DBO.KIT_RUTA (NOLOCK)
					INNER JOIN DATA_02.DBO.KIT_RUTA_EVENTO (NOLOCK) ON KIT_RUTA_EVENTO.K_KIT_RUTA_EVENTO = KIT_RUTA.K_KIT_RUTA_EVENTO
					WHERE KIT_RUTA.ITEM_NO = @VP_ITEM_NO
					AND KIT_RUTA.MODELNO = @VP_MODELO
					AND KIT_RUTA.VERSIONNO = @VP_VERSION
					AND KIT_RUTA.K_KIT_RUTA_EVENTO = 230 -- #230 PERFORACION
					
					DECLARE @VP_N_EXISTE INT = 0
					IF @VP_N_KIT_PERFORADO > 0
						BEGIN			
							--SELECT @VP_N_EXISTE = COUNT([K_MATERIAL_PROGRAMADO_LOG])
							--FROM DATA_02.DBO.[MATERIAL_PROGRAMADO_LOG] (NOLOCK) 
							--WHERE SERIAL = @VP_SERIAL
							--AND K_TIPO_EVENTO_KIT = 300 --#300 INSP. PERFO.

							SELECT @VP_N_EXISTE = COUNT(orden) 
							FROM [PPMS_PEARL].[dbo].Perforacion (NOLOCK)
							WHERE orden = @PP_ORDEN 
							AND noserie = @VP_SERIAL
							AND [status] = 'FINALIZADO'

							IF ( @VP_N_EXISTE IS NULL OR @VP_N_EXISTE = 0 )
								SET @VP_RESULTADO = 'El serial: ' + @VP_SERIAL + ' no ha pasado por Inspección de Perforación!'
						END
					ELSE
						BEGIN
							SELECT @VP_N_EXISTE = COUNT([K_MATERIAL_PROGRAMADO_LOG])
							FROM DATA_02.DBO.[MATERIAL_PROGRAMADO_LOG] (NOLOCK) 
							WHERE SERIAL = @VP_SERIAL
							AND K_TIPO_EVENTO_KIT = 400 --#400 CERTIFICACION

							IF ( @VP_N_EXISTE IS NULL OR @VP_N_EXISTE = 0 )
								BEGIN
									SELECT @VP_N_EXISTE = COUNT(id) 
									FROM [PPMS_PEARL].[dbo].certificacion_rpt 
									WHERE noserie_caja = @VP_SERIAL

									IF ( @VP_N_EXISTE IS NULL OR @VP_N_EXISTE = 0 )
										SET @VP_RESULTADO = 'El serial: ' + @VP_SERIAL + ' no ha pasado por Certificación!'
								END
						END				

					FETCH NEXT FROM CU_KIT_TERMINADO INTO @VP_ITEM_NO, @VP_MODELO, @VP_VERSION, @VP_SERIAL
				END
				
			CLOSE CU_KIT_TERMINADO
			DEALLOCATE CU_KIT_TERMINADO
		END
	-- /////////////////////////////////////////////////////
	
	--SELECT @VP_RESULTADO
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO



-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
