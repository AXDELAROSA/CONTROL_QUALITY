-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		DATA_02
-- // MODULE:			LOT_COMP
-- // OPERATION:		PROCEDIMIENTOS ESPECIFICOS
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			AX DE LA ROSA			
-- // CREATION DATE:	20210224
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas]
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> LI LOT_COMP
-- // SE UTILIZA EN:
-- //	1) LOT_COMP
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_LOTE_COMPATIBLE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_LOTE_COMPATIBLE]
GO
--		EXECUTE [dbo].[PG_LI_LOTE_COMPATIBLE]	0,139,'033101','FCMKTX7'		
--		EXECUTE [dbo].[PG_LI_LOTE_COMPATIBLE]	0,139,'033102','( TODOS )'		
--		EXECUTE [dbo].[PG_LI_LOTE_COMPATIBLE]	0,139,'','FCMKTX7'				
--		EXECUTE [dbo].[PG_LI_LOTE_COMPATIBLE]	0,139,'','( TODOS )'		

--		EXECUTE [dbo].[PG_LI_LOTE_COMPATIBLE]	0,139,''						
--		EXECUTE [dbo].[PG_LI_LOTE_COMPATIBLE]	0,139,'060031'					
CREATE PROCEDURE [dbo].[PG_LI_LOTE_COMPATIBLE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_LOTE					VARCHAR(10)
AS
	--	SELECT QUE SE ELIMINA DEL CODIGO
	--	select * from SER_LOT_COMP_SQL order by item_no,ser_lot_no1
	--DECLARE @VP_K_CUSTOMER	INT = 0
	IF @PP_LOTE	= ''
	BEGIN
		SELECT	 ID									AS K_LOTE_COMPATIBLE
			,LTRIM(RTRIM(ITEM_NO))					AS D_ITEM
			,LTRIM(RTRIM(SER_LOT_NO1))				AS S_LOTE_COMPATIBLE_01
			,LTRIM(RTRIM(SER_LOT_NO2))				AS S_LOTE_COMPATIBLE_02
			,(CASE
				WHEN	LTRIM(RTRIM(COMP))	= 'Y'	THEN	'Si'
				ELSE	'No'
			END)									AS L_LOTE_COMPATIBLE
			--,COMP									AS L_LOTE_COMPATIBLE
			,LTRIM(RTRIM(Aut1))						AS A_LOTE_COMPATIBLE_01
			,LTRIM(RTRIM(Aut2))						AS A_LOTE_COMPATIBLE_02
			,LTRIM(RTRIM(Comments))					AS C_LOTE_COMPATIBLE
			,DBO.CONVERT_INT_TO_DATE(Cdate)			AS F_LOTE_COMPATIBLE
		-- ===============================================================
		FROM	SER_LOT_COMP_SQL
		--INNER JOIN	IMLSMST_SQL ON	COLORES_ACTIVOS.colour=IMLSMST_SQL.item_no
		--INNER JOIN	COLORES_ACTIVOS	ON	COLORES_ACTIVOS.colour=IMLSMST_SQL.item_no
		-- ===============================================================
		WHERE	SER_LOT_NO1 IN (
										SELECT	DISTINCT SER_LOT_NO
										FROM	IMLSMST_SQL
										WHERE	QTY_ON_HAND	> 0.0000
										AND		ITEM_NO LIKE 'F%'
										AND (		
												LOC LIKE 'T%'
											OR	LOC	IN ('MHI')	)										
								)
		AND		SER_LOT_NO2	IN	(
										--SELECT	DISTINCT SER_LOT_NO
										--FROM	IMLSMST_SQL
										--WHERE	QTY_ON_HAND	> 0.0000
										--AND		ITEM_NO LIKE 'F%'		)
										SELECT	DISTINCT SER_LOT_NO
										FROM	IMLSMST_SQL
										WHERE	QTY_ON_HAND	> 0.0000
										AND		ITEM_NO LIKE 'F%'
										AND (		
												LOC LIKE 'T%'
											OR	LOC	IN ('MHI')	)										
								)
		ORDER BY	ITEM_NO, SER_LOT_NO1	DESC
	END
	ELSE
	BEGIN
		SELECT	 ID									AS K_LOTE_COMPATIBLE
				,LTRIM(RTRIM(ITEM_NO))					AS D_ITEM
				,LTRIM(RTRIM(SER_LOT_NO1))				AS S_LOTE_COMPATIBLE_01
				,LTRIM(RTRIM(SER_LOT_NO2))				AS S_LOTE_COMPATIBLE_02
				,(CASE
					WHEN	LTRIM(RTRIM(COMP))	= 'Y'	THEN	'Si'
					ELSE	'No'
				END)									AS L_LOTE_COMPATIBLE
				--,COMP									AS L_LOTE_COMPATIBLE
				,LTRIM(RTRIM(Aut1))						AS A_LOTE_COMPATIBLE_01
				,LTRIM(RTRIM(Aut2))						AS A_LOTE_COMPATIBLE_02
				,LTRIM(RTRIM(Comments))					AS C_LOTE_COMPATIBLE
				,DBO.CONVERT_INT_TO_DATE(Cdate)			AS F_LOTE_COMPATIBLE
		-- ===============================================================
		FROM	SER_LOT_COMP_SQL 
		-- ===============================================================
		WHERE	(		LTRIM(RTRIM(SER_LOT_NO1))	LIKE '%'+ @PP_LOTE +'%' 
					OR	LTRIM(RTRIM(SER_LOT_NO2))	LIKE '%'+ @PP_LOTE +'%'		)
		---- ===============================================================
		ORDER BY	ITEM_NO, SER_LOT_NO1	DESC
	END
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SK LOT_COMP
-- // SE UTILIZA EN:
-- //	1) LOT_COMP
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_LOTE_COMPATIBLE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_LOTE_COMPATIBLE]
GO
--		 EXECUTE [dbo].[PG_SK_LOTE_COMPATIBLE]	0,139,	70941
CREATE PROCEDURE [dbo].[PG_SK_LOTE_COMPATIBLE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ID_LOTE					INT
AS	
		SELECT	TOP(1) 
				ID										AS K_LOTE_COMPATIBLE
				,LTRIM(RTRIM(ITEM_NO))					AS D_ITEM
				,LTRIM(RTRIM(SER_LOT_NO1))				AS S_LOTE_COMPATIBLE_01
				,LTRIM(RTRIM(SER_LOT_NO2))				AS S_LOTE_COMPATIBLE_02
				,(CASE
					WHEN	LTRIM(RTRIM(COMP))	= 'Y'	THEN	1
					ELSE	0
				END)									AS L_LOTE_COMPATIBLE
				,LTRIM(RTRIM(Aut1))						AS A_LOTE_COMPATIBLE_01
				,LTRIM(RTRIM(Aut2))						AS A_LOTE_COMPATIBLE_02
				,LTRIM(RTRIM(Comments))					AS C_LOTE_COMPATIBLE
				,DBO.CONVERT_INT_TO_DATE(Cdate)			AS F_LOTE_COMPATIBLE
		-- ===============================================================
		FROM	SER_LOT_COMP_SQL 
		-- ===============================================================
		WHERE	ID		=	@PP_ID_LOTE
		---- ===============================================================
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SK LOT_COMP
-- // SE UTILIZA EN:
-- //	1) LOT_COMP
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_LOTE_COMPATIBLE_DETALLE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_LOTE_COMPATIBLE_DETALLE]
GO
--		 EXECUTE [dbo].[PG_SK_LOTE_COMPATIBLE_DETALLE]	0,139,	'019941'
CREATE PROCEDURE [dbo].[PG_SK_LOTE_COMPATIBLE_DETALLE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_LOTE					VARCHAR(10)
AS	

	SET	@PP_LOTE	= RIGHT('000000' + CONVERT(VARCHAR(10),Ltrim(Rtrim(@PP_LOTE))), 6)

	DECLARE	@PP_TABLA_LOTES				AS TABLE
			(	 TA_LOTE_ID				INT
				,TA_LOTE_SERIE			VARCHAR(10)
				,TA_LOTE_L				INT
				,TA_LOTE_AUTORIZA_01	VARCHAR(250)
				,TA_LOTE_K_USUARIO_01	VARCHAR(250)
				,TA_LOTE_AUTORIZA_02	VARCHAR(250)
				,TA_LOTE_K_USUARIO_02	VARCHAR(250)
				,TA_LOTE_C				VARCHAR(250)
				,TA_L_COMENTARIO		INT
			)
---===================================================================================================================================================
---===================================================================================================================================================
---===================================================================================================================================================
---===================================================================================================================================================	
	DECLARE	 @VP_CU_ID_LOTE_COMPATIBLE			INT
			-- =====================================================
			,@VP_CU_D_ITEM						VARCHAR(25)
			-- =====================================================
			,@VP_CU_S_LOTE_COMPATIBLE_01		VARCHAR(10)
			,@VP_CU_S_LOTE_COMPATIBLE_02		VARCHAR(10)
			-- =====================================================
			,@VP_CU_L_LOTE_COMPATIBLE			VARCHAR(10)
			,@VP_CU_A_LOTE_COMPATIBLE_01		VARCHAR(250)
			,@VP_CU_A_LOTE_COMPATIBLE_02		VARCHAR(250)
			,@VP_CU_K_LOTE_COMPATIBLE_01		INT
			,@VP_CU_K_LOTE_COMPATIBLE_02		INT
			-- =====================================================
			,@VP_CU_C_LOTE_COMPATIBLE			VARCHAR(250)


	DECLARE CU_COMPATIBLES CURSOR FOR  
		SELECT	 ID										--AS K_LOTE_COMPATIBLE		
				,LTRIM(RTRIM(ITEM_NO))					--AS D_ITEM
				,LTRIM(RTRIM(SER_LOT_NO1))				--AS S_LOTE_COMPATIBLE_01
				,LTRIM(RTRIM(SER_LOT_NO2))				--AS S_LOTE_COMPATIBLE_02
				,(CASE
					WHEN	LTRIM(RTRIM(COMP))	= 'Y'	THEN	1
					ELSE	0
				END)									--AS L_LOTE_COMPATIBLE
				,LTRIM(RTRIM(Aut1))						--AS A_LOTE_COMPATIBLE_01
				,LTRIM(RTRIM(Aut2))						--AS A_LOTE_COMPATIBLE_02
				,K_USUARIO_PEARL_01
				,K_USUARIO_PEARL_02
				,LTRIM(RTRIM(Comments))					--AS C_LOTE_COMPATIBLE
		-- ===============================================================
		FROM	SER_LOT_COMP_SQL 
		-- ===============================================================
		WHERE	(		LTRIM(RTRIM(SER_LOT_NO1))	LIKE '%'+ @PP_LOTE +'%' 
					OR	LTRIM(RTRIM(SER_LOT_NO2))	LIKE '%'+ @PP_LOTE +'%'		)
		---- ===============================================================
	OPEN			CU_COMPATIBLES;  
	FETCH NEXT FROM CU_COMPATIBLES INTO		@VP_CU_ID_LOTE_COMPATIBLE		,@VP_CU_D_ITEM
											,@VP_CU_S_LOTE_COMPATIBLE_01	,@VP_CU_S_LOTE_COMPATIBLE_02
											,@VP_CU_L_LOTE_COMPATIBLE			
											,@VP_CU_A_LOTE_COMPATIBLE_01	,@VP_CU_A_LOTE_COMPATIBLE_02		
											,@VP_CU_K_LOTE_COMPATIBLE_01	,@VP_CU_K_LOTE_COMPATIBLE_02		
											,@VP_CU_C_LOTE_COMPATIBLE		
	WHILE @@FETCH_STATUS = 0  
	   BEGIN
			DECLARE	 @VP_IN_LOTE_SERIE		VARCHAR(10)	= ''
			

			IF @PP_LOTE	= @VP_CU_S_LOTE_COMPATIBLE_01
			BEGIN
				SET	@VP_IN_LOTE_SERIE	= @VP_CU_S_LOTE_COMPATIBLE_02
			END
			ELSE IF @PP_LOTE	= @VP_CU_S_LOTE_COMPATIBLE_02
			BEGIN
				SET	@VP_IN_LOTE_SERIE	= @VP_CU_S_LOTE_COMPATIBLE_01
			END

			-- /////////////////////////////////////////////////////////////////////				
				INSERT INTO @PP_TABLA_LOTES	(
					TA_LOTE_ID		
					,TA_LOTE_SERIE	
					,TA_LOTE_L
					,TA_LOTE_AUTORIZA_01
					,TA_LOTE_K_USUARIO_01
					,TA_LOTE_AUTORIZA_02
					,TA_LOTE_K_USUARIO_02
					,TA_LOTE_C
					,TA_L_COMENTARIO						
				)	VALUES	(
					@VP_CU_ID_LOTE_COMPATIBLE
					,@VP_IN_LOTE_SERIE
					,@VP_CU_L_LOTE_COMPATIBLE
					,@VP_CU_A_LOTE_COMPATIBLE_01
					,@VP_CU_K_LOTE_COMPATIBLE_01
					,@VP_CU_A_LOTE_COMPATIBLE_02
					,@VP_CU_K_LOTE_COMPATIBLE_02
					,@VP_CU_C_LOTE_COMPATIBLE
					,0
				)
			-- /////////////////////////////////////////////////////////////////////

		FETCH NEXT FROM CU_COMPATIBLES INTO		 @VP_CU_ID_LOTE_COMPATIBLE		,@VP_CU_D_ITEM
												,@VP_CU_S_LOTE_COMPATIBLE_01	,@VP_CU_S_LOTE_COMPATIBLE_02
												,@VP_CU_L_LOTE_COMPATIBLE			
												,@VP_CU_A_LOTE_COMPATIBLE_01	,@VP_CU_A_LOTE_COMPATIBLE_02		
												,@VP_CU_K_LOTE_COMPATIBLE_01	,@VP_CU_K_LOTE_COMPATIBLE_02		
												,@VP_CU_C_LOTE_COMPATIBLE
	   END;  
	CLOSE		CU_COMPATIBLES;  
	DEALLOCATE	CU_COMPATIBLES;  

	SELECT
		TA_LOTE_ID				AS	K_LOTE_COMPATIBLE
		,TA_LOTE_SERIE			AS	S_LOTE_COMPATIBLE
		,TA_LOTE_L				AS	L_LOTE_COMPATIBLE
		,TA_LOTE_AUTORIZA_01	AS	A_LOTE_COMPATIBLE_01
		,TA_LOTE_K_USUARIO_01	AS	K_LOTE_USUARIO_01		
		,TA_LOTE_AUTORIZA_02	AS	A_LOTE_COMPATIBLE_02
		,TA_LOTE_K_USUARIO_02	AS	K_LOTE_USUARIO_02		
		,TA_LOTE_C				AS	C_LOTE_COMPATIBLE
		,TA_L_COMENTARIO		AS	L_COMENTARIO
	FROM @PP_TABLA_LOTES
	ORDER	BY		TA_LOTE_SERIE	DESC
		-- ===============================================================
		-- ===============================================================
	-- ////////////////////////////////////////////////////////////////////
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
--SELECT * FROM	SER_LOT_COMP_SQL 
-------================================================================================================================
-------================================================================================================================
-------================================================================================================================
	--SELECT	 @PP_K_USUARIO			=	K_USUARIO_PEARL
	--		,@VP_K_EMPLEADO_PEARL	=	K_EMPLEADO_PEARL
	--FROM	USUARIO_PEARL
	--WHERE	D_USUARIO_PEARL=@PP_D_USUARIO
	
	--SELECT  @VP_EXISTE_EMPLEADO=	COUNT(EN_NUM_EMP)
	--FROM    USUARIO_PEARL
	--LEFT JOIN HOWE.DBO.VISTA_GAFETES ON EN_NUM_EMP=K_EMPLEADO_PEARL
	--WHERE	EN_NUM_EMP	=	@VP_K_EMPLEADO_PEARL	--K_EMPLEADO_PEARL

	--IF @VP_EXISTE_EMPLEADO= 0
	--BEGIN
	--	SET		@VP_K_CODIGO		=-10
	--	SET		@VP_NOMBRE_APELLIDO	=NULL
	--	SET		@VP_TEMA			=NULL
	--	SET		@VP_D_USUARIO		=NULL
	--	SET		@VP_D_USUARIO_TIPO	=NULL
	--	SET		@VP_S_USUARIO_TIPO	=NULL
	--	SET		@VP_MENSAJE			= 'Hubo un Problema con la cuenta de [Usuario] informe a Sistemas...'	---'Invalid [USER] name.'
		
	--		RAISERROR (@VP_MENSAJE, 16, 1 )
	--END

-------================================================================================================================
-------================================================================================================================
-------================================================================================================================