--SELECT * FROM TOOL_SET

SELECT * FROM ccprdstr_sql (NOLOCK)
SELECT * FROM [DATA_02].[DBO].IMKITFIL_SQL	WHERE	comp_item_no	= 'PWALBRRWLCPX7'


SELECT	ccprdstr_sql.item_no, ccprdstr_sql.modelno as modelo
		,ccprdstr_sql.versionno
		,ccprdstr_sql.comp_item_no
		,cus_item_no
		,ccitmidx_sql.user_def_fld_4
		,reference_1
FROM		ccverhdr_sql (NOLOCK)
INNER JOIN	ccprdstr_sql (NOLOCK)	ON ccprdstr_sql.cus_no = ccverhdr_sql.cus_no 
AND		ccprdstr_sql.modelno = ccverhdr_sql.modelno
AND		ccprdstr_sql.versionno	= ccverhdr_sql.versionno 
AND		(item_no					= 'PWLAFCRWLCPX7'	
		OR	ITEM_NO	IN (	SELECT LTRIM(RTRIM(comp_item_filler)) 
							FROM	[DATA_02].[DBO].IMKITFIL_SQL	(NOLOCK)	
							WHERE	comp_item_no	= 'PWLAFCRWLCPX7'		)	
		OR	ITEM_NO	IN (	SELECT LTRIM(RTRIM(comp_item_no)) 
							FROM	[DATA_02].[DBO].IMKITFIL_SQL	(NOLOCK)	
							WHERE	comp_item_filler	= 'PWLAFCRWLCPX7'		)
		)
AND		specstatus				= 'U'
INNER JOIN	cccusitm_sql (NOLOCK)	ON ccprdstr_sql.comp_item_no = cccusitm_sql.item_no 
AND		ccprdstr_sql.versionno	= cccusitm_sql.versionno
INNER JOIN	ccitmidx_sql (NOLOCK)	ON ccprdstr_sql.comp_item_no = ccitmidx_sql.item_no 
AND		ccprdstr_sql.versionno	= ccitmidx_sql.versionno 
ORDER	BY reference_1	,cus_item_no

SELECT	ccprdstr_sql.item_no, ccprdstr_sql.modelno as modelo
		,ccprdstr_sql.versionno
		,ccprdstr_sql.comp_item_no
		,cus_item_no
		,ccitmidx_sql.user_def_fld_4
		,reference_1
FROM		ccverhdr_sql (NOLOCK)
INNER JOIN	ccprdstr_sql (NOLOCK)	ON ccprdstr_sql.cus_no = ccverhdr_sql.cus_no 
AND		ccprdstr_sql.modelno = ccverhdr_sql.modelno
AND		ccprdstr_sql.versionno	= ccverhdr_sql.versionno 
AND		(item_no					= 'PWALBRRWLCPX7'	
		OR	ITEM_NO	IN (	SELECT TOP(1) LTRIM(RTRIM(comp_item_filler)) 
							FROM	[DATA_02].[DBO].IMKITFIL_SQL	(NOLOCK)	
							WHERE	comp_item_no	= 'PWALBRRWLCPX7'		)	
		OR	ITEM_NO	IN (	SELECT TOP(1) LTRIM(RTRIM(comp_item_no)) 
							FROM	[DATA_02].[DBO].IMKITFIL_SQL	(NOLOCK)	
							WHERE	comp_item_filler	= 'PWALBRRWLCPX7'		)
		)
AND		specstatus				= 'U'
INNER JOIN	cccusitm_sql (NOLOCK)	ON ccprdstr_sql.comp_item_no = cccusitm_sql.item_no 
AND		ccprdstr_sql.versionno	= cccusitm_sql.versionno
INNER JOIN	ccitmidx_sql (NOLOCK)	ON ccprdstr_sql.comp_item_no = ccitmidx_sql.item_no 
AND		ccprdstr_sql.versionno	= ccitmidx_sql.versionno 
ORDER	BY reference_1	,cus_item_no


SELECT	ccprdstr_sql.item_no, ccprdstr_sql.modelno as modelo
		,ccprdstr_sql.versionno
		,ccprdstr_sql.comp_item_no
		,cus_item_no
		,ccitmidx_sql.user_def_fld_4
		,reference_1
FROM		ccverhdr_sql (NOLOCK)
INNER JOIN	ccprdstr_sql (NOLOCK)	ON ccprdstr_sql.cus_no = ccverhdr_sql.cus_no 
AND		ccprdstr_sql.modelno = ccverhdr_sql.modelno
AND		ccprdstr_sql.versionno	= ccverhdr_sql.versionno 
AND		(item_no					= 'PWLAFCRWLCPX7'	
		OR	ITEM_NO	IN (	SELECT TOP(1) LTRIM(RTRIM(comp_item_filler)) 
							FROM	[DATA_02].[DBO].IMKITFIL_SQL	(NOLOCK)	
							WHERE	comp_item_no	= 'PWLAFCRWLCPX7'		)	
		OR	ITEM_NO	IN (	SELECT TOP(1) LTRIM(RTRIM(comp_item_no)) 
							FROM	[DATA_02].[DBO].IMKITFIL_SQL	(NOLOCK)	
							WHERE	comp_item_filler	= 'PWLAFCRWLCPX7'		)
		)
AND		specstatus				= 'U'
INNER JOIN	cccusitm_sql (NOLOCK)	ON ccprdstr_sql.comp_item_no = cccusitm_sql.item_no 
AND		ccprdstr_sql.versionno	= cccusitm_sql.versionno
INNER JOIN	ccitmidx_sql (NOLOCK)	ON ccprdstr_sql.comp_item_no = ccitmidx_sql.item_no 
AND		ccprdstr_sql.versionno	= ccitmidx_sql.versionno 
ORDER	BY reference_1	,cus_item_no


SELECT	ccprdstr_sql.item_no, ccprdstr_sql.modelno as modelo
		,ccprdstr_sql.versionno
		,ccprdstr_sql.comp_item_no
		,cus_item_no
		,ccitmidx_sql.user_def_fld_4
		,reference_1
FROM		ccverhdr_sql (NOLOCK)
INNER JOIN	ccprdstr_sql (NOLOCK)	ON ccprdstr_sql.cus_no = ccverhdr_sql.cus_no 
AND		ccprdstr_sql.modelno = ccverhdr_sql.modelno
AND		ccprdstr_sql.versionno	= ccverhdr_sql.versionno 
AND		(item_no					= 'UWALFBRWLCPX7'	
		OR	ITEM_NO	IN (	SELECT TOP(1) LTRIM(RTRIM(comp_item_filler)) 
							FROM	[DATA_02].[DBO].IMKITFIL_SQL	(NOLOCK)	
							WHERE	comp_item_no	= 'UWALFBRWLCPX7'		)	
		OR	ITEM_NO	IN (	SELECT TOP(1) LTRIM(RTRIM(comp_item_no)) 
							FROM	[DATA_02].[DBO].IMKITFIL_SQL	(NOLOCK)	
							WHERE	comp_item_filler	= 'UWALFBRWLCPX7'		)
		OR	ITEM_NO	IN (	SELECT TOP(1) LTRIM(RTRIM(comp_item_no))
							FROM	[DATA_02].[DBO].IMKITFIL_SQL	(NOLOCK)	
							WHERE	item_no	= 'UWALFBRWLCPX7'		)
		OR	ITEM_NO	IN (	SELECT TOP(1) LTRIM(RTRIM(comp_item_filler))
							FROM	[DATA_02].[DBO].IMKITFIL_SQL	(NOLOCK)	
							WHERE	item_no	= 'UWALFBRWLCPX7'		)		
		)
AND		specstatus				= 'U'
INNER JOIN	cccusitm_sql (NOLOCK)	ON ccprdstr_sql.comp_item_no = cccusitm_sql.item_no 
AND		ccprdstr_sql.versionno	= cccusitm_sql.versionno
INNER JOIN	ccitmidx_sql (NOLOCK)	ON ccprdstr_sql.comp_item_no = ccitmidx_sql.item_no 
AND		ccprdstr_sql.versionno	= ccitmidx_sql.versionno 
ORDER	BY reference_1	,cus_item_no

SELECT	ccprdstr_sql.item_no, ccprdstr_sql.modelno as modelo
		,ccprdstr_sql.versionno
		,ccprdstr_sql.comp_item_no
		,cus_item_no
		,ccitmidx_sql.user_def_fld_4
		,reference_1
FROM		ccverhdr_sql (NOLOCK)
INNER JOIN	ccprdstr_sql (NOLOCK)	ON ccprdstr_sql.cus_no = ccverhdr_sql.cus_no 
AND		ccprdstr_sql.modelno = ccverhdr_sql.modelno
AND		ccprdstr_sql.versionno	= ccverhdr_sql.versionno 
AND		(item_no					= 'PWLAFCRWLCPX7'	
		OR	ITEM_NO	IN (	SELECT TOP(1) LTRIM(RTRIM(comp_item_filler)) 
							FROM	[DATA_02].[DBO].IMKITFIL_SQL	(NOLOCK)	
							WHERE	comp_item_no	= 'PWLAFCRWLCPX7'		)	
		OR	ITEM_NO	IN (	SELECT TOP(1) LTRIM(RTRIM(comp_item_no)) 
							FROM	[DATA_02].[DBO].IMKITFIL_SQL	(NOLOCK)	
							WHERE	comp_item_filler	= 'PWLAFCRWLCPX7'		)
		OR	ITEM_NO	IN (	SELECT TOP(1) LTRIM(RTRIM(comp_item_no))
							FROM	[DATA_02].[DBO].IMKITFIL_SQL	(NOLOCK)	
							WHERE	item_no	= 'PWLAFCRWLCPX7'		)
		OR	ITEM_NO	IN (	SELECT TOP(1) LTRIM(RTRIM(comp_item_filler))
							FROM	[DATA_02].[DBO].IMKITFIL_SQL	(NOLOCK)	
							WHERE	item_no	= 'PWLAFCRWLCPX7'		)		
		)
AND		specstatus				= 'U'
INNER JOIN	cccusitm_sql (NOLOCK)	ON ccprdstr_sql.comp_item_no = cccusitm_sql.item_no 
AND		ccprdstr_sql.versionno	= cccusitm_sql.versionno
INNER JOIN	ccitmidx_sql (NOLOCK)	ON ccprdstr_sql.comp_item_no = ccitmidx_sql.item_no 
AND		ccprdstr_sql.versionno	= ccitmidx_sql.versionno 
ORDER	BY reference_1	,cus_item_no