Public Class FO_MATERIAL_INSPECCION

#Region "VARIABLES & CONSTANTS"
    Public VM_TABLE_NAME As String = ""
    Public VM_IN_OPERATION_MODE As Integer = 0
#End Region

#Region "SUBS INITIALS"
    ''' <summary>
    ''' WHEN THE FORM IS LOAD, CALL THIS SUB. SET INITIAL FORM SETTINGS
    ''' </summary>
    ''' 

    Private Sub Catalogo_T1_Load(sender As Object, e As EventArgs) Handles MyBase.Load
        PM_FORMA_SetUp(Me)
    End Sub

    Public Sub PM_LIST_SetUp()
        PM_LISTADO_Format(LI_LISTADO)
    End Sub

    Public Sub PM_COMBOBOX_INITIALS()
        REM --------------------------------------------------------------------LISTADO
        'Codigo_PEARL.PG_CONTROL_Style_CBX(CB_LI_ESTATUS_ORDEN)
        'Codigo_PEARL.PG_COMBOBOX_LOAD_X_TABLE_SELECT(VG_BD_DATA_02, CB_LI_ESTATUS_ORDEN, "ESTATUS_ORDEN", "D_ESTATUS_ORDEN", "K_ESTATUS_ORDEN")

        REM --------------------------------------------------------------------FICHA
        'Codigo_PEARL.PG_CONTROL_Style_CBX(CB_LOCACION)
        'Codigo_PEARL.PG_COMBOBOX_LOAD_X_SP(VG_BD_GENERAL, CB_LOCACION, "PG_CB_IMLOCFIL_SQL", 7)

    End Sub

    Public Sub PM_TEXTBOX_INITIALS()
        REM --------------------------------- INICIALIZA LOS CONTROLES CON UN FORMATO PREDEFINIDO
        'Codigo_PEARL.PG_CONTROL_TB_CHARACTER_DIGIT_NO_SPACE(TB_COMENTARIO)
        'Codigo_PEARL.PG_CONTROL_TB_CHARACTER_DIGIT_NO_SPACE(TB_LI_BUSCAR)
        'Codigo_PEARL.PG_CONTROL_TB_CHARACTER_DIGIT_NO_SPACE(TB_S_DESCRIPCION_PUESTO)

    End Sub

    Public Sub PM_TOOLTIP_INITIALS()
        Codigo_Tooltip.PG_FRM_TOOLTIP_Init(Me)
    End Sub

    Public Sub PM_FILE_INIT(ByVal PP_BD_INDEX As Integer, ByVal PP_ID As String, ByVal PP_LISTADO As DataGridView)
        'Dim VP_SP As String = "[PG_SK_INSPECCION_MATERIAL_X_NUMERO_PARTE_CON_OPCION]"
        'If PP_ID <> "" Then
        '    Codigo_PEARL.PG_BUTTON_SEARCH_QUICK(PP_BD_INDEX, Me, PP_LISTADO, PP_ID, VP_SP)
        'Else
        '    Codigo_PEARL.PG_BUTTON_SEARCH_QUICK(PP_BD_INDEX, Me, PP_LISTADO, 0, VP_SP)
        'End If

        PG_FI_OBTENER_INSPECCION(1, 1)
    End Sub
#End Region

#Region "FUNCTIONS"
    Public Function FM_ID_SELECTED(ByRef PP_LI_LISTADO As DataGridView, ByRef PP_ROW As Integer) As String
        Dim VP_ID As String = ""
        VP_ID = Codigo_PEARL.FG_DG_CELLS_READ(PP_LI_LISTADO, PP_ROW, "ORDEN_COMPRA")
        Return VP_ID
    End Function

    Public Function FM_DESC_SELECTED(ByRef PP_LI_LISTADO As DataGridView, ByRef PP_ROW As Integer) As String
        Dim VP_ID As String = ""
        VP_ID = Codigo_PEARL.FG_DG_CELLS_READ(PP_LI_LISTADO, PP_ROW, "NUMERO_PARTE")
        Return VP_ID
    End Function

    Public Function FM_K_DETAILS_PURCHASE_ORDER(ByRef PP_LI_LISTADO As DataGridView, ByRef PP_ROW As Integer) As String
        Dim VP_ID As String = ""
        VP_ID = Codigo_PEARL.FG_DG_CELLS_READ(PP_LI_LISTADO, PP_ROW, "K_DETAILS_PURCHASE_ORDER")
        Return VP_ID
    End Function

    Public Function FM_VALIDATE_CAPTURE_FILE(ByRef PP_MENSAJE_VALIDACION As String) As Boolean
        Dim VP_VALIDACION As Boolean
        Codigo_PEARL.PG_CONTROL_GB_VALIDATE_FIELDS(GB_FILE, VP_VALIDACION, PP_MENSAJE_VALIDACION)
        'Codigo_PEARL.PG_CONTROL_TB_VALIDATE_NOT_EMPTY_TEXT(PP_MENSAJE_VALIDACION, TB_COMENTARIO)

        VP_VALIDACION = (PP_MENSAJE_VALIDACION = "")
        Return VP_VALIDACION
    End Function

    Public Function FM_SQL_PARAMETER_FOR_SAVED() As String
        Dim VP_PARAMETROS As String = ""

        If (VM_IN_OPERATION_MODE = MOP_Modo_Operacion.MOP4_Editar) Then
            Codigo_PEARL.PG_CONTROL_PARAMETRO(VP_PARAMETROS, TB_ORDEN_COMPRA, True)
        End If

        'Dim VP_LOCACION As String = Codigo_PEARL.FG_COMBOBOX_ITEM_TEXT(CB_LOCACION)
        'Dim VP_COLOR As String = Codigo_PEARL.FG_COMBOBOX_ITEM_TEXT(CB_COLOR)
        'Dim VP_CLIENTE As String = Codigo_PEARL.FG_COMBOBOX_ITEM_TEXT(CB_CLIENTE)

        'Codigo_PEARL.PG_CONTROL_PARAMETRO(VP_PARAMETROS, VP_COLOR, True)
        'Codigo_PEARL.PG_CONTROL_PARAMETRO(VP_PARAMETROS, VP_LOCACION, True)
        'Codigo_PEARL.PG_CONTROL_PARAMETRO(VP_PARAMETROS, VP_CLIENTE, True)
        'Codigo_PEARL.PG_CONTROL_PARAMETRO(VP_PARAMETROS, TB_COMENTARIO, True)
        Return VP_PARAMETROS
    End Function

    Public Function FM_SQL_PARAMETER_FOR_SEARCH() As String
        Dim VP_PARAMETROS As String = ""

        Codigo_PEARL.PG_CONTROL_PARAMETRO(VP_PARAMETROS, TB_LI_BUSCAR, True)

        REM --------------------------------------------------------------------

        Return VP_PARAMETROS
    End Function
#End Region

#Region "FUNCTIONS ADICIONAL"
#End Region

#Region "SUBS"

    ''' <summary>
    ''' TO LOAD PARAMETERS TO FILE
    ''' THIS SUB IS CALLED FROM THE FOLLOWING SUBS:
    ''' A) PG_ACTION_DG_DOUBLE_CLICK
    ''' B) PG_BUTTON_CLONE_CLICK
    ''' C) PG_BUTTON_EDIT_CLICK
    ''' D) PG_BUTTON_INSERT_CLICK
    ''' ALL EXISTS ON CODIGO_PEARL
    ''' </summary>
    Public Sub PM_FILE_Show(ByVal PP_BD_INDEX As Integer, ByVal PP_ID As String, ByVal PP_LISTADO As DataGridView)
        Dim VP_PARAMETROS As String = ""
        Dim ROW As Integer = Codigo_PEARL.FG_DG_CurrentRow_Index(LI_LISTADO)
        Dim VP_K_DETALLE_ORDEN As String = FM_K_DETAILS_PURCHASE_ORDER(LI_LISTADO, ROW)

        Codigo_PEARL.PG_CONTROL_PARAMETRO(VP_PARAMETROS, PP_ID)
        Codigo_PEARL.PG_CONTROL_PARAMETRO(VP_PARAMETROS, VP_K_DETALLE_ORDEN)

        Codigo_PEARL.PG_ACTION_FILE_LOAD_X_ID(PP_BD_INDEX, Me, VP_PARAMETROS, GB_FILE, PP_LISTADO, "PG_SK_NUMERO_PARTE_X_K_DETALLE_ORDEN")

        TB_DIAGONAL.Text = "/"
        TB_N_INSPECCION.Text = "1"
        PM_FILE_INIT(PP_BD_INDEX, "1", LI_LISTADO)
        TB_N_INSPECCION.BackColor = Color.SkyBlue
        TB_DIAGONAL.BackColor = Color.SkyBlue
        TB_TOTAL_INSPECCION.BackColor = Color.SkyBlue

        TB_COMENTARIO.Select()
    End Sub

    Public Sub PM_FILE_Load(ByVal PP_ROW As DataRow, ByVal PP_LISTADO As DataGridView)
        If VM_IN_OPERATION_MODE <> MOP_Modo_Operacion.MOP5_Clon Then
            Codigo_PEARL.PG_CONTROL_DATA_LOAD("ORDEN_COMPRA", TB_ORDEN_COMPRA, PP_ROW)
        End If

        Codigo_PEARL.PG_CONTROL_DATA_LOAD("CLIENTE", TB_CLIENTE, PP_ROW)
        Codigo_PEARL.PG_CONTROL_DATA_LOAD("PROVEDOR", TB_PROVEDOR, PP_ROW)
        Codigo_PEARL.PG_CONTROL_DATA_LOAD("PART_NUMBER_ITEM_PEARL", TB_NUMERO_PARTE, PP_ROW)
        Codigo_PEARL.PG_CONTROL_DATA_LOAD("QUANTITY", TB_CANTIDAD, PP_ROW)

        Codigo_PEARL.PG_CONTROL_DATA_LOAD("TOTAL_INSPECCION", TB_TOTAL_INSPECCION, PP_ROW)

    End Sub

    Public Sub PM_FO_SHOW(ByRef PP_NOMBRE_TABLA As String, ByVal PP_BD_Index As String)
        VM_TABLE_NAME = PP_NOMBRE_TABLA
        VG_BD_DATA_02 = PP_BD_Index
        Me.Show()
    End Sub

    Private Sub PM_FORMA_SetUp(ByRef PP_FORMA As Object)
        Codigo_PEARL.PG_FORM_SETUP(VG_BD_DATA_02, PP_FORMA)
    End Sub
#End Region

#Region "FORMAT LISTING"
    Private Sub PM_LISTADO_Format(ByRef PP_LI_LISTADO As DataGridView)
        Codigo_PEARL.PG_DG_FORMAT_SETUP(PP_LI_LISTADO, 12, 18)
        Codigo_PEARL.PG_DG_COLUMN_Add_K_Value(PP_LI_LISTADO, "ORDEN_COMPRA", "PO")
        Codigo_PEARL.PG_DG_COLUMN_Add_D_Value(PP_LI_LISTADO, "PROVEDOR", "Provedor", 5)
        Codigo_PEARL.PG_DG_COLUMN_Add_S_Value(PP_LI_LISTADO, "S_UNIT_OF_MEASURE", "Unidad Medida")
        Codigo_PEARL.PG_DG_COLUMN_Add_Text(PP_LI_LISTADO, "PART_NUMBER_ITEM_PEARL", "Numero Parte", 2)
        Codigo_PEARL.PG_DG_COLUMN_Add_Text(PP_LI_LISTADO, "D_ITEM", "Descripción", 15)
        Codigo_PEARL.PG_DG_COLUMN_Add_Decimal(PP_LI_LISTADO, "QUANTITY", "Cantidad", 1)
        Codigo_PEARL.PG_DG_COLUMN_Add_Integer(PP_LI_LISTADO, "K_DETAILS_PURCHASE_ORDER", "K_DETALLE_ORDEN", 1,, 0)
        ' --------------------------------------------------------------
    End Sub

    Public Sub PM_LISTADO_LoadRow(ByRef PP_LISTADO As DataGridView, ByRef PP_ROW_DATA As DataRow)
        Dim VP_COLUMNA As Integer = 0
        Dim VP_ROW As Integer = PP_LISTADO.Rows.Count - 1
        ' --------------------------------------------------------------
        Codigo_PEARL.PG_DG_CELL_WRITE_SECUENCIAL(PP_LISTADO, VP_ROW, VP_COLUMNA, PP_ROW_DATA, "ORDEN_COMPRA")
        Codigo_PEARL.PG_DG_CELL_WRITE_SECUENCIAL(PP_LISTADO, VP_ROW, VP_COLUMNA, PP_ROW_DATA, "PROVEDOR")
        Codigo_PEARL.PG_DG_CELL_WRITE_SECUENCIAL(PP_LISTADO, VP_ROW, VP_COLUMNA, PP_ROW_DATA, "S_UNIT_OF_MEASURE")
        Codigo_PEARL.PG_DG_CELL_WRITE_SECUENCIAL(PP_LISTADO, VP_ROW, VP_COLUMNA, PP_ROW_DATA, "PART_NUMBER_ITEM_PEARL")
        Codigo_PEARL.PG_DG_CELL_WRITE_SECUENCIAL(PP_LISTADO, VP_ROW, VP_COLUMNA, PP_ROW_DATA, "D_ITEM")
        Codigo_PEARL.PG_DG_CELL_WRITE_SECUENCIAL(PP_LISTADO, VP_ROW, VP_COLUMNA, PP_ROW_DATA, "QUANTITY")
        Codigo_PEARL.PG_DG_CELL_WRITE_SECUENCIAL(PP_LISTADO, VP_ROW, VP_COLUMNA, PP_ROW_DATA, "K_DETAILS_PURCHASE_ORDER")
    End Sub
#End Region

#Region "SUBS SPECIALS"
    ''' <summary>
    ''' Set form additionals buttons settings
    ''' </summary>
    ''' 

    Public Sub PG_FI_OBTENER_INSPECCION(PP_PRIMER_INSPECCION As Integer, PP_TIPO_MOVIMIENTO As Integer)
        Dim VP_NUMERO_PARTE As String = ""
        Dim VP_PARAMETROS As String = ""
        Dim VP_K_INSPECCION_MATERIAL_REVISION As String = "0"
        Try

            CHB_OPCION_1.Checked = False
            CHB_OPCION_2.Checked = False
            CHB_OPCION_3.Checked = False
            CHB_OPCION_4.Checked = False
            CHB_OPCION_5.Checked = False

            VP_NUMERO_PARTE = Trim(TB_NUMERO_PARTE.Text)

            If TB_K_INSPECCION.Text <> "" Then
                VP_K_INSPECCION_MATERIAL_REVISION = TB_K_INSPECCION.Text
            End If

            Codigo_PEARL.PG_CONTROL_PARAMETRO(VP_PARAMETROS, VP_NUMERO_PARTE, True)
            Codigo_PEARL.PG_CONTROL_PARAMETRO(VP_PARAMETROS, VP_K_INSPECCION_MATERIAL_REVISION)
            Codigo_PEARL.PG_CONTROL_PARAMETRO(VP_PARAMETROS, PP_PRIMER_INSPECCION)
            Codigo_PEARL.PG_CONTROL_PARAMETRO(VP_PARAMETROS, PP_TIPO_MOVIMIENTO)
            Dim VP_TABLA As Data.DataTable
            VP_TABLA = Codigo_PEARL.FG_ACTION_EXECUTE_DATATABLE(VG_BD_DATA_02, "[PG_SK_INSPECCION_MATERIAL_X_NUMERO_PARTE_CON_OPCION]", VP_PARAMETROS, True)

            Dim VP_N_REGISTROS As Integer
            VP_N_REGISTROS = VP_TABLA.Rows.Count()

            If VP_N_REGISTROS > 0 Then
                If PP_TIPO_MOVIMIENTO = 1 And PP_PRIMER_INSPECCION = 0 Then
                    TB_N_INSPECCION.Text = CInt(TB_N_INSPECCION.Text) + 1
                End If

                If PP_TIPO_MOVIMIENTO = 0 And PP_PRIMER_INSPECCION = 0 Then
                    TB_N_INSPECCION.Text = CInt(TB_N_INSPECCION.Text) - 1
                End If

                Dim VP_K_INSPECCION_MATERIAL As String = Codigo_PEARL.FG_DG_DATAROW_READ_STRING(VP_TABLA.Rows(0), "K_INSPECCION_MATERIAL")
                    Dim VP_K_TIPO_INSPECCION_MATERIAL As String = Codigo_PEARL.FG_DG_DATAROW_READ_STRING(VP_TABLA.Rows(0), "K_TIPO_INSPECCION_MATERIAL")
                    Dim VP_INSPECCION As String = Trim(Codigo_PEARL.FG_DG_DATAROW_READ_STRING(VP_TABLA.Rows(0), "INSPECCION"))
                    Dim VP_INSPECCION_PORCENTAJE As Decimal = Codigo_PEARL.FG_DG_DATAROW_READ_DECIMAL(VP_TABLA.Rows(0), "INSPECCION_PORCENTAJE", 0.00)
                    Dim VP_OPCION_1 As String = Trim(Codigo_PEARL.FG_DG_DATAROW_READ_STRING(VP_TABLA.Rows(0), "OPCION_1"))
                    Dim VP_OPCION_1_PORCENTAJE As Decimal = Codigo_PEARL.FG_DG_DATAROW_READ_DECIMAL(VP_TABLA.Rows(0), "OPCION_1_PORCENTAJE", 0.00)
                    Dim VP_OPCION_2 As String = Trim(Codigo_PEARL.FG_DG_DATAROW_READ_STRING(VP_TABLA.Rows(0), "OPCION_2"))
                    Dim VP_OPCION_2_PORCENTAJE As Decimal = Codigo_PEARL.FG_DG_DATAROW_READ_DECIMAL(VP_TABLA.Rows(0), "OPCION_2_PORCENTAJE", 0.00)
                    Dim VP_OPCION_3 As String = Trim(Codigo_PEARL.FG_DG_DATAROW_READ_STRING(VP_TABLA.Rows(0), "OPCION_3"))
                    Dim VP_OPCION_3_PORCENTAJE As Decimal = Codigo_PEARL.FG_DG_DATAROW_READ_DECIMAL(VP_TABLA.Rows(0), "OPCION_3_PORCENTAJE", 0.00)
                    Dim VP_OPCION_4 As String = Trim(Codigo_PEARL.FG_DG_DATAROW_READ_STRING(VP_TABLA.Rows(0), "OPCION_4"))
                    Dim VP_OPCION_4_PORCENTAJE As Decimal = Codigo_PEARL.FG_DG_DATAROW_READ_DECIMAL(VP_TABLA.Rows(0), "OPCION_4_PORCENTAJE", 0.00)
                    Dim VP_OPCION_5 As String = Trim(Codigo_PEARL.FG_DG_DATAROW_READ_STRING(VP_TABLA.Rows(0), "OPCION_5"))
                    Dim VP_OPCION_5_PORCENTAJE As Decimal = Codigo_PEARL.FG_DG_DATAROW_READ_DECIMAL(VP_TABLA.Rows(0), "OPCION_5_PORCENTAJE", 0.00)

                    TB_K_INSPECCION.Text = VP_K_INSPECCION_MATERIAL
                    TB_INSPECCION.Text = VP_INSPECCION
                    TB_INSPECCION_PORCENTAJE.Text = VP_INSPECCION_PORCENTAJE

                    If VP_OPCION_1 <> "" Then
                        CHB_OPCION_1.Text = VP_OPCION_1
                        CHB_OPCION_1.Visible = True
                    End If

                    If VP_OPCION_2 <> "" Then
                        CHB_OPCION_2.Text = VP_OPCION_2
                        CHB_OPCION_2.Visible = True
                    End If

                    If VP_OPCION_3 <> "" Then
                        CHB_OPCION_3.Text = VP_OPCION_3
                        CHB_OPCION_3.Visible = True
                    End If

                    If VP_OPCION_4 <> "" Then
                        CHB_OPCION_4.Text = VP_OPCION_4
                        CHB_OPCION_4.Visible = True
                    End If

                    If VP_OPCION_5 <> "" Then
                        CHB_OPCION_5.Text = VP_OPCION_5
                        CHB_OPCION_5.Visible = True
                    End If
                End If
        Catch ex As Exception
            Codigo_PEARL.PG_MESSAGE_ERROR_VS(0, "PG_FI_OBTENER_INSPECCION")
        End Try
    End Sub
#End Region

#Region "BUTTONS SUBS"
    Private Sub PM_BT_AGREGAR_CLICK(ByRef PP_FORMA As Object)
        Codigo_PEARL.PG_BUTTON_INSERT_CLICK(VG_BD_DATA_02, PP_FORMA, LI_LISTADO)
    End Sub

    Public Sub PM_BT_SEARCH_CLICK(ByVal PP_BD_Index As Integer, ByRef PP_FORMA As Object, ByVal PP_LI_LISTADO As DataGridView)
        PM_LISTADO_Format(PP_LI_LISTADO)
        Codigo_PEARL.PG_BUTTON_SEARCH_CLICK(VG_BD_DATA_02, PP_FORMA, PP_LI_LISTADO, "[PG_LI_NUMERO_PARTE_X_K_ORDEN_COMPRA]", True, True)

        If LI_LISTADO.Rows.Count = 0 Then
            Codigo_PEARL.PG_MESSAGE_NOTICE(0, "NO se encontraron registros para la busqueda.")
        End If
    End Sub

    Private Sub PM_BT_CANCELAR_CLICK(ByRef PP_FORMA As Object)
        Codigo_PEARL.PG_BUTTON_CANCEL_CLICK(PP_FORMA, GB_FILE)
    End Sub

    Private Sub PM_BT_SALIR_CLICK(ByRef PP_FORMA As Object)
        Codigo_PEARL.PG_BUTTON_EXIT_CLICK(PP_FORMA)
    End Sub

    Private Sub PM_BT_EDITAR_CLICK(ByRef PP_FORMA As Object, ByVal PP_LI_LISTADO As DataGridView)
        Codigo_PEARL.PG_BUTTON_EDIT_CLICK(VG_BD_DATA_02, PP_FORMA, PP_LI_LISTADO)
    End Sub

    Public Sub PM_BT_GUARDAR_CLICK(ByRef PP_FORMA As Object, ByRef PP_LI_LISTADO As DataGridView)
        Dim VP_SP As String = "[PG_IN_ORDEN_GERBER]"

        If VM_IN_OPERATION_MODE = MOP_Modo_Operacion.MOP4_Editar Then
            VP_SP = "[PG_UP_ORDEN_GERBER]"
        End If

        Codigo_PEARL.PG_BUTTON_SAVE_CLICK(VG_BD_DATA_02, PP_FORMA, PP_LI_LISTADO, VP_SP)
    End Sub

    Public Sub PM_BT_ELIMINAR_CLICK(ByRef PP_FORMA As Object, ByRef PP_LI_LISTADO As DataGridView)
        Codigo_PEARL.PG_BUTTON_DELETE_CLICK(VG_BD_DATA_02, PP_FORMA, PP_LI_LISTADO)
    End Sub

    Private Sub PM_BT_EXPORTAR_EXCEL_CLICK(ByRef PP_LI_LISTADO As DataGridView)
        Codigo_Excel.PG_BT_EXPORTAR_EXCEL_DATAGRIDVIEW(VG_BD_DATA_02, PP_LI_LISTADO)
    End Sub

    Public Sub PM_LI_SAVE(ByRef PP_FORMA As Object, ByRef PP_LI_LISTADO As DataGridView)
        PM_BT_SEARCH_CLICK(VG_BD_DATA_02, PP_FORMA, PP_LI_LISTADO)
    End Sub

    Private Sub PM_BT_CLONAR_CLICK(ByRef PP_FORMA As Object, ByRef PP_LI_LISTADO As DataGridView)
        Codigo_PEARL.PG_BUTTON_CLONE_CLICK(VG_BD_DATA_02, PP_FORMA, PP_LI_LISTADO)
    End Sub

#End Region

#Region "EVENTOS"
    Private Sub BT_AGREGAR_Click(sender As Object, e As EventArgs) Handles BT_NEW.Click
        PM_BT_AGREGAR_CLICK(Me)
    End Sub

    Private Sub BT_SEARCH_CLICK(sender As Object, e As EventArgs) Handles BT_SEARCH.Click
        PM_BT_SEARCH_CLICK(VG_BD_DATA_02, Me, LI_LISTADO)
    End Sub

    Private Sub BT_CANCELAR_Click(sender As Object, e As EventArgs) Handles BT_CANCEL.Click
        PM_BT_CANCELAR_CLICK(Me)
    End Sub

    Private Sub BT_SALIR_Click(sender As Object, e As EventArgs) Handles BT_EXIT.Click
        PM_BT_SALIR_CLICK(Me)
    End Sub

    Private Sub BT_GUARDAR_Click(sender As Object, e As EventArgs) Handles BT_SAVE.Click
        PM_BT_GUARDAR_CLICK(Me, LI_LISTADO)
    End Sub

    Private Sub BT_EDITAR_Click(sender As Object, e As EventArgs) Handles BT_EDIT.Click
        If Codigo_PEARL.FG_DG_ROW_SELECTED(LI_LISTADO) Then
            PM_BT_EDITAR_CLICK(Me, LI_LISTADO)
        End If
    End Sub

    Private Sub BT_ELIMINAR_Click(sender As Object, e As EventArgs) Handles BT_DELETE.Click
        'PM_BT_ELIMINAR_CLICK(Me, LI_LISTADO)
    End Sub

    Private Sub BT_EXPORTAR_EXCEL_Click(sender As Object, e As EventArgs) Handles BT_EXPORT_EXCEL.Click
        PM_BT_EXPORTAR_EXCEL_CLICK(LI_LISTADO)
    End Sub

    Private Sub BT_CLONAR_Click(sender As Object, e As EventArgs)
        PM_BT_CLONAR_CLICK(Me, LI_LISTADO)
    End Sub

    Private Sub LI_LISTADO_CellDoubleClick(sender As Object, e As DataGridViewCellEventArgs) Handles LI_LISTADO.CellDoubleClick
        If Codigo_PEARL.FG_DG_ROW_SELECTED(LI_LISTADO) Then
            PM_BT_EDITAR_CLICK(Me, LI_LISTADO)
        End If
    End Sub

    Private Sub TB_LI_BUSCAR_TextChanged(sender As Object, e As System.Windows.Forms.KeyPressEventArgs) Handles TB_LI_BUSCAR.KeyPress
        Try
            If e.KeyChar = Microsoft.VisualBasic.ChrW(13) Then
                If TB_LI_BUSCAR.Text = "" Then
                    Codigo_PEARL.PG_MESSAGE_NOTICE(0, "Ingrese una busqueda valida")
                    Exit Sub
                End If

                PM_BT_SEARCH_CLICK(VG_BD_DATA_02, Me, LI_LISTADO)
            End If
        Catch ex As Exception
            Codigo_PEARL.PG_MESSAGE_ERROR_VS(0, "TB_LI_BUSCAR.KeyPress")
        End Try
    End Sub

    Private Sub BTN_SIGUIENTE_Click(sender As Object, e As EventArgs) Handles BTN_SIGUIENTE.Click
        PG_FI_OBTENER_INSPECCION(0, 1)
    End Sub

    Private Sub BTN_ANTERIOR_Click(sender As Object, e As EventArgs) Handles BTN_ANTERIOR.Click
        PG_FI_OBTENER_INSPECCION(0, 0)
    End Sub

    Private Sub CHB_OPCION_1_CheckedChanged(sender As Object, e As EventArgs) Handles CHB_OPCION_1.CheckedChanged
        If CHB_OPCION_1.Checked = True Then
            CHB_OPCION_2.Checked = False
            CHB_OPCION_3.Checked = False
            CHB_OPCION_4.Checked = False
            CHB_OPCION_5.Checked = False
        End If
    End Sub

    Private Sub CHB_OPCION_2_CheckedChanged(sender As Object, e As EventArgs) Handles CHB_OPCION_2.CheckedChanged
        If CHB_OPCION_2.Checked = True Then
            CHB_OPCION_1.Checked = False
            CHB_OPCION_3.Checked = False
            CHB_OPCION_4.Checked = False
            CHB_OPCION_5.Checked = False
        End If
    End Sub

    Private Sub CHB_OPCION_3_CheckedChanged(sender As Object, e As EventArgs) Handles CHB_OPCION_3.CheckedChanged
        If CHB_OPCION_3.Checked = True Then
            CHB_OPCION_1.Checked = False
            CHB_OPCION_2.Checked = False
            CHB_OPCION_4.Checked = False
            CHB_OPCION_5.Checked = False
        End If
    End Sub

    Private Sub CHB_OPCION_4_CheckedChanged(sender As Object, e As EventArgs) Handles CHB_OPCION_4.CheckedChanged
        If CHB_OPCION_4.Checked = True Then
            CHB_OPCION_1.Checked = False
            CHB_OPCION_2.Checked = False
            CHB_OPCION_3.Checked = False
            CHB_OPCION_5.Checked = False
        End If
    End Sub

    Private Sub CHB_OPCION_5_CheckedChanged(sender As Object, e As EventArgs) Handles CHB_OPCION_5.CheckedChanged
        If CHB_OPCION_5.Checked = True Then
            CHB_OPCION_1.Checked = False
            CHB_OPCION_2.Checked = False
            CHB_OPCION_3.Checked = False
            CHB_OPCION_4.Checked = False
        End If
    End Sub
#End Region
End Class