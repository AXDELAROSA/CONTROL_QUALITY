<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()>
Partial Class FO_MATERIAL_INSPECCION
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()>
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()>
    Private Sub InitializeComponent()
        Me.components = New System.ComponentModel.Container()
        Dim DataGridViewCellStyle16 As System.Windows.Forms.DataGridViewCellStyle = New System.Windows.Forms.DataGridViewCellStyle()
        Dim resources As System.ComponentModel.ComponentResourceManager = New System.ComponentModel.ComponentResourceManager(GetType(FO_MATERIAL_INSPECCION))
        Me.BT_EXPORT_EXCEL = New System.Windows.Forms.Button()
        Me.GB_FILE = New System.Windows.Forms.GroupBox()
        Me.GB_DESCRIPCION_MATERIAL = New System.Windows.Forms.GroupBox()
        Me.GB_ESPECIFICACIONES = New System.Windows.Forms.GroupBox()
        Me.CHB_OPCION_5 = New System.Windows.Forms.CheckBox()
        Me.CHB_OPCION_4 = New System.Windows.Forms.CheckBox()
        Me.CHB_OPCION_3 = New System.Windows.Forms.CheckBox()
        Me.CHB_OPCION_2 = New System.Windows.Forms.CheckBox()
        Me.CHB_OPCION_1 = New System.Windows.Forms.CheckBox()
        Me.Label8 = New System.Windows.Forms.Label()
        Me.TB_INSPECCION_PORCENTAJE = New System.Windows.Forms.TextBox()
        Me.TB_K_INSPECCION = New System.Windows.Forms.TextBox()
        Me.Label13 = New System.Windows.Forms.Label()
        Me.TB_INSPECCION = New System.Windows.Forms.TextBox()
        Me.TB_CLIENTE = New System.Windows.Forms.TextBox()
        Me.Label2 = New System.Windows.Forms.Label()
        Me.BTN_ANTERIOR = New System.Windows.Forms.Button()
        Me.TB_PROVEDOR = New System.Windows.Forms.TextBox()
        Me.Label3 = New System.Windows.Forms.Label()
        Me.TB_CANTIDAD = New System.Windows.Forms.TextBox()
        Me.TB_NUMERO_PARTE = New System.Windows.Forms.TextBox()
        Me.BTN_SIGUIENTE = New System.Windows.Forms.Button()
        Me.Label9 = New System.Windows.Forms.Label()
        Me.TB_COMENTARIO = New System.Windows.Forms.TextBox()
        Me.Label4 = New System.Windows.Forms.Label()
        Me.Label5 = New System.Windows.Forms.Label()
        Me.TB_ORDEN_COMPRA = New System.Windows.Forms.TextBox()
        Me.Label15 = New System.Windows.Forms.Label()
        Me.FL_MENU_2 = New System.Windows.Forms.FlowLayoutPanel()
        Me.BT_EXIT = New System.Windows.Forms.Button()
        Me.BT_CANCEL = New System.Windows.Forms.Button()
        Me.BT_SAVE = New System.Windows.Forms.Button()
        Me.BT_SEARCH = New System.Windows.Forms.Button()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.TB_LI_BUSCAR = New System.Windows.Forms.TextBox()
        Me.GB_LISTING = New System.Windows.Forms.GroupBox()
        Me.LI_LISTADO = New System.Windows.Forms.DataGridView()
        Me.GB_FILTERS = New System.Windows.Forms.GroupBox()
        Me.LB_RESULTADO = New System.Windows.Forms.TextBox()
        Me.GB_OPERACION = New System.Windows.Forms.GroupBox()
        Me.TI_RELOJ = New System.Windows.Forms.Timer(Me.components)
        Me.BT_EDIT = New System.Windows.Forms.Button()
        Me.FL_MENU_1 = New System.Windows.Forms.FlowLayoutPanel()
        Me.BT_NEW = New System.Windows.Forms.Button()
        Me.BT_DELETE = New System.Windows.Forms.Button()
        Me.TB_N_INSPECCION = New System.Windows.Forms.TextBox()
        Me.Label6 = New System.Windows.Forms.Label()
        Me.TB_DIAGONAL = New System.Windows.Forms.TextBox()
        Me.TB_TOTAL_INSPECCION = New System.Windows.Forms.TextBox()
        Me.GB_FILE.SuspendLayout()
        Me.GB_DESCRIPCION_MATERIAL.SuspendLayout()
        Me.GB_ESPECIFICACIONES.SuspendLayout()
        Me.FL_MENU_2.SuspendLayout()
        Me.GB_LISTING.SuspendLayout()
        CType(Me.LI_LISTADO, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.GB_FILTERS.SuspendLayout()
        Me.GB_OPERACION.SuspendLayout()
        Me.FL_MENU_1.SuspendLayout()
        Me.SuspendLayout()
        '
        'BT_EXPORT_EXCEL
        '
        Me.BT_EXPORT_EXCEL.FlatAppearance.BorderColor = System.Drawing.Color.White
        Me.BT_EXPORT_EXCEL.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.BT_EXPORT_EXCEL.Image = Global.Pearl.My.Resources.Resources.ICO_BT_EXPORTAR_EXCEL
        Me.BT_EXPORT_EXCEL.Location = New System.Drawing.Point(137, 8)
        Me.BT_EXPORT_EXCEL.Margin = New System.Windows.Forms.Padding(4)
        Me.BT_EXPORT_EXCEL.Name = "BT_EXPORT_EXCEL"
        Me.BT_EXPORT_EXCEL.Size = New System.Drawing.Size(93, 42)
        Me.BT_EXPORT_EXCEL.TabIndex = 28
        Me.BT_EXPORT_EXCEL.Tag = "Copiar al portapapeles"
        Me.BT_EXPORT_EXCEL.UseVisualStyleBackColor = True
        Me.BT_EXPORT_EXCEL.Visible = False
        '
        'GB_FILE
        '
        Me.GB_FILE.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.GB_FILE.BackColor = System.Drawing.Color.White
        Me.GB_FILE.Controls.Add(Me.GB_DESCRIPCION_MATERIAL)
        Me.GB_FILE.Enabled = False
        Me.GB_FILE.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.GB_FILE.Font = New System.Drawing.Font("Arial", 9.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.GB_FILE.Location = New System.Drawing.Point(143, 145)
        Me.GB_FILE.Margin = New System.Windows.Forms.Padding(4)
        Me.GB_FILE.Name = "GB_FILE"
        Me.GB_FILE.Padding = New System.Windows.Forms.Padding(4)
        Me.GB_FILE.Size = New System.Drawing.Size(897, 473)
        Me.GB_FILE.TabIndex = 143
        Me.GB_FILE.TabStop = False
        Me.GB_FILE.Text = "Ficha"
        '
        'GB_DESCRIPCION_MATERIAL
        '
        Me.GB_DESCRIPCION_MATERIAL.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.GB_DESCRIPCION_MATERIAL.Controls.Add(Me.GB_ESPECIFICACIONES)
        Me.GB_DESCRIPCION_MATERIAL.Controls.Add(Me.TB_CLIENTE)
        Me.GB_DESCRIPCION_MATERIAL.Controls.Add(Me.Label2)
        Me.GB_DESCRIPCION_MATERIAL.Controls.Add(Me.BTN_ANTERIOR)
        Me.GB_DESCRIPCION_MATERIAL.Controls.Add(Me.TB_PROVEDOR)
        Me.GB_DESCRIPCION_MATERIAL.Controls.Add(Me.Label3)
        Me.GB_DESCRIPCION_MATERIAL.Controls.Add(Me.TB_CANTIDAD)
        Me.GB_DESCRIPCION_MATERIAL.Controls.Add(Me.TB_NUMERO_PARTE)
        Me.GB_DESCRIPCION_MATERIAL.Controls.Add(Me.BTN_SIGUIENTE)
        Me.GB_DESCRIPCION_MATERIAL.Controls.Add(Me.Label9)
        Me.GB_DESCRIPCION_MATERIAL.Controls.Add(Me.TB_COMENTARIO)
        Me.GB_DESCRIPCION_MATERIAL.Controls.Add(Me.Label4)
        Me.GB_DESCRIPCION_MATERIAL.Controls.Add(Me.Label5)
        Me.GB_DESCRIPCION_MATERIAL.Controls.Add(Me.TB_ORDEN_COMPRA)
        Me.GB_DESCRIPCION_MATERIAL.Controls.Add(Me.Label15)
        Me.GB_DESCRIPCION_MATERIAL.Location = New System.Drawing.Point(11, 25)
        Me.GB_DESCRIPCION_MATERIAL.Margin = New System.Windows.Forms.Padding(4)
        Me.GB_DESCRIPCION_MATERIAL.Name = "GB_DESCRIPCION_MATERIAL"
        Me.GB_DESCRIPCION_MATERIAL.Padding = New System.Windows.Forms.Padding(4)
        Me.GB_DESCRIPCION_MATERIAL.Size = New System.Drawing.Size(870, 440)
        Me.GB_DESCRIPCION_MATERIAL.TabIndex = 322
        Me.GB_DESCRIPCION_MATERIAL.TabStop = False
        Me.GB_DESCRIPCION_MATERIAL.Text = "Detalle No. Parte"
        '
        'GB_ESPECIFICACIONES
        '
        Me.GB_ESPECIFICACIONES.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.GB_ESPECIFICACIONES.Controls.Add(Me.TB_TOTAL_INSPECCION)
        Me.GB_ESPECIFICACIONES.Controls.Add(Me.TB_DIAGONAL)
        Me.GB_ESPECIFICACIONES.Controls.Add(Me.Label6)
        Me.GB_ESPECIFICACIONES.Controls.Add(Me.TB_N_INSPECCION)
        Me.GB_ESPECIFICACIONES.Controls.Add(Me.CHB_OPCION_5)
        Me.GB_ESPECIFICACIONES.Controls.Add(Me.CHB_OPCION_4)
        Me.GB_ESPECIFICACIONES.Controls.Add(Me.CHB_OPCION_3)
        Me.GB_ESPECIFICACIONES.Controls.Add(Me.CHB_OPCION_2)
        Me.GB_ESPECIFICACIONES.Controls.Add(Me.CHB_OPCION_1)
        Me.GB_ESPECIFICACIONES.Controls.Add(Me.Label8)
        Me.GB_ESPECIFICACIONES.Controls.Add(Me.TB_INSPECCION_PORCENTAJE)
        Me.GB_ESPECIFICACIONES.Controls.Add(Me.TB_K_INSPECCION)
        Me.GB_ESPECIFICACIONES.Controls.Add(Me.Label13)
        Me.GB_ESPECIFICACIONES.Controls.Add(Me.TB_INSPECCION)
        Me.GB_ESPECIFICACIONES.Location = New System.Drawing.Point(15, 73)
        Me.GB_ESPECIFICACIONES.Margin = New System.Windows.Forms.Padding(4)
        Me.GB_ESPECIFICACIONES.Name = "GB_ESPECIFICACIONES"
        Me.GB_ESPECIFICACIONES.Padding = New System.Windows.Forms.Padding(4)
        Me.GB_ESPECIFICACIONES.Size = New System.Drawing.Size(834, 284)
        Me.GB_ESPECIFICACIONES.TabIndex = 1110
        Me.GB_ESPECIFICACIONES.TabStop = False
        Me.GB_ESPECIFICACIONES.Text = "Inspección a realizar"
        '
        'CHB_OPCION_5
        '
        Me.CHB_OPCION_5.AutoSize = True
        Me.CHB_OPCION_5.CheckAlign = System.Drawing.ContentAlignment.BottomCenter
        Me.CHB_OPCION_5.Location = New System.Drawing.Point(630, 128)
        Me.CHB_OPCION_5.Name = "CHB_OPCION_5"
        Me.CHB_OPCION_5.Size = New System.Drawing.Size(75, 39)
        Me.CHB_OPCION_5.TabIndex = 377
        Me.CHB_OPCION_5.Text = "Opción 5"
        Me.CHB_OPCION_5.UseVisualStyleBackColor = True
        Me.CHB_OPCION_5.Visible = False
        '
        'CHB_OPCION_4
        '
        Me.CHB_OPCION_4.AutoSize = True
        Me.CHB_OPCION_4.CheckAlign = System.Drawing.ContentAlignment.BottomCenter
        Me.CHB_OPCION_4.Location = New System.Drawing.Point(493, 128)
        Me.CHB_OPCION_4.Name = "CHB_OPCION_4"
        Me.CHB_OPCION_4.Size = New System.Drawing.Size(75, 39)
        Me.CHB_OPCION_4.TabIndex = 376
        Me.CHB_OPCION_4.Text = "Opción 4"
        Me.CHB_OPCION_4.UseVisualStyleBackColor = True
        Me.CHB_OPCION_4.Visible = False
        '
        'CHB_OPCION_3
        '
        Me.CHB_OPCION_3.AutoSize = True
        Me.CHB_OPCION_3.CheckAlign = System.Drawing.ContentAlignment.BottomCenter
        Me.CHB_OPCION_3.Location = New System.Drawing.Point(356, 128)
        Me.CHB_OPCION_3.Name = "CHB_OPCION_3"
        Me.CHB_OPCION_3.Size = New System.Drawing.Size(75, 39)
        Me.CHB_OPCION_3.TabIndex = 375
        Me.CHB_OPCION_3.Text = "Opción 3"
        Me.CHB_OPCION_3.UseVisualStyleBackColor = True
        Me.CHB_OPCION_3.Visible = False
        '
        'CHB_OPCION_2
        '
        Me.CHB_OPCION_2.AutoSize = True
        Me.CHB_OPCION_2.CheckAlign = System.Drawing.ContentAlignment.BottomCenter
        Me.CHB_OPCION_2.Location = New System.Drawing.Point(221, 128)
        Me.CHB_OPCION_2.Name = "CHB_OPCION_2"
        Me.CHB_OPCION_2.Size = New System.Drawing.Size(75, 39)
        Me.CHB_OPCION_2.TabIndex = 374
        Me.CHB_OPCION_2.Text = "Opción 2"
        Me.CHB_OPCION_2.UseVisualStyleBackColor = True
        '
        'CHB_OPCION_1
        '
        Me.CHB_OPCION_1.AutoSize = True
        Me.CHB_OPCION_1.CheckAlign = System.Drawing.ContentAlignment.BottomCenter
        Me.CHB_OPCION_1.Location = New System.Drawing.Point(81, 128)
        Me.CHB_OPCION_1.Name = "CHB_OPCION_1"
        Me.CHB_OPCION_1.Size = New System.Drawing.Size(75, 39)
        Me.CHB_OPCION_1.TabIndex = 373
        Me.CHB_OPCION_1.Text = "Opción 1"
        Me.CHB_OPCION_1.UseVisualStyleBackColor = True
        Me.CHB_OPCION_1.Visible = False
        '
        'Label8
        '
        Me.Label8.AutoSize = True
        Me.Label8.Font = New System.Drawing.Font("Segoe UI", 8.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label8.Location = New System.Drawing.Point(759, 18)
        Me.Label8.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.Label8.Name = "Label8"
        Me.Label8.Size = New System.Drawing.Size(66, 19)
        Me.Label8.TabIndex = 372
        Me.Label8.Text = "Valor(%)"
        Me.Label8.Visible = False
        '
        'TB_INSPECCION_PORCENTAJE
        '
        Me.TB_INSPECCION_PORCENTAJE.BackColor = System.Drawing.SystemColors.Control
        Me.TB_INSPECCION_PORCENTAJE.BorderStyle = System.Windows.Forms.BorderStyle.None
        Me.TB_INSPECCION_PORCENTAJE.Font = New System.Drawing.Font("Segoe UI", 10.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TB_INSPECCION_PORCENTAJE.ForeColor = System.Drawing.SystemColors.WindowText
        Me.TB_INSPECCION_PORCENTAJE.Location = New System.Drawing.Point(762, 40)
        Me.TB_INSPECCION_PORCENTAJE.Margin = New System.Windows.Forms.Padding(4)
        Me.TB_INSPECCION_PORCENTAJE.Name = "TB_INSPECCION_PORCENTAJE"
        Me.TB_INSPECCION_PORCENTAJE.ReadOnly = True
        Me.TB_INSPECCION_PORCENTAJE.Size = New System.Drawing.Size(61, 23)
        Me.TB_INSPECCION_PORCENTAJE.TabIndex = 40
        Me.TB_INSPECCION_PORCENTAJE.Visible = False
        '
        'TB_K_INSPECCION
        '
        Me.TB_K_INSPECCION.Enabled = False
        Me.TB_K_INSPECCION.Font = New System.Drawing.Font("Segoe UI", 8.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TB_K_INSPECCION.Location = New System.Drawing.Point(64, 18)
        Me.TB_K_INSPECCION.Margin = New System.Windows.Forms.Padding(4)
        Me.TB_K_INSPECCION.Name = "TB_K_INSPECCION"
        Me.TB_K_INSPECCION.ReadOnly = True
        Me.TB_K_INSPECCION.Size = New System.Drawing.Size(50, 25)
        Me.TB_K_INSPECCION.TabIndex = 10
        Me.TB_K_INSPECCION.Visible = False
        '
        'Label13
        '
        Me.Label13.AutoSize = True
        Me.Label13.Font = New System.Drawing.Font("Segoe UI", 8.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label13.Location = New System.Drawing.Point(10, 18)
        Me.Label13.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.Label13.Name = "Label13"
        Me.Label13.Size = New System.Drawing.Size(46, 19)
        Me.Label13.TabIndex = 360
        Me.Label13.Text = "#INSP"
        Me.Label13.Visible = False
        '
        'TB_INSPECCION
        '
        Me.TB_INSPECCION.BorderStyle = System.Windows.Forms.BorderStyle.None
        Me.TB_INSPECCION.Font = New System.Drawing.Font("Segoe UI", 12.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TB_INSPECCION.Location = New System.Drawing.Point(43, 59)
        Me.TB_INSPECCION.Margin = New System.Windows.Forms.Padding(4)
        Me.TB_INSPECCION.Multiline = True
        Me.TB_INSPECCION.Name = "TB_INSPECCION"
        Me.TB_INSPECCION.ReadOnly = True
        Me.TB_INSPECCION.Size = New System.Drawing.Size(709, 56)
        Me.TB_INSPECCION.TabIndex = 30
        Me.TB_INSPECCION.Tag = "1"
        Me.TB_INSPECCION.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'TB_CLIENTE
        '
        Me.TB_CLIENTE.Enabled = False
        Me.TB_CLIENTE.Font = New System.Drawing.Font("Segoe UI", 8.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TB_CLIENTE.Location = New System.Drawing.Point(127, 40)
        Me.TB_CLIENTE.Margin = New System.Windows.Forms.Padding(4)
        Me.TB_CLIENTE.Name = "TB_CLIENTE"
        Me.TB_CLIENTE.ReadOnly = True
        Me.TB_CLIENTE.Size = New System.Drawing.Size(190, 25)
        Me.TB_CLIENTE.TabIndex = 1109
        '
        'Label2
        '
        Me.Label2.AutoSize = True
        Me.Label2.Font = New System.Drawing.Font("Segoe UI", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label2.Location = New System.Drawing.Point(131, 18)
        Me.Label2.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(51, 19)
        Me.Label2.TabIndex = 1108
        Me.Label2.Text = "Cliente"
        '
        'BTN_ANTERIOR
        '
        Me.BTN_ANTERIOR.Anchor = System.Windows.Forms.AnchorStyles.None
        Me.BTN_ANTERIOR.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center
        Me.BTN_ANTERIOR.FlatAppearance.BorderColor = System.Drawing.Color.White
        Me.BTN_ANTERIOR.FlatAppearance.MouseDownBackColor = System.Drawing.Color.White
        Me.BTN_ANTERIOR.FlatAppearance.MouseOverBackColor = System.Drawing.Color.White
        Me.BTN_ANTERIOR.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.BTN_ANTERIOR.Image = Global.Pearl.My.Resources.Resources.BT_ANTERIOR
        Me.BTN_ANTERIOR.Location = New System.Drawing.Point(696, 385)
        Me.BTN_ANTERIOR.Margin = New System.Windows.Forms.Padding(0)
        Me.BTN_ANTERIOR.Name = "BTN_ANTERIOR"
        Me.BTN_ANTERIOR.Size = New System.Drawing.Size(71, 42)
        Me.BTN_ANTERIOR.TabIndex = 1107
        Me.BTN_ANTERIOR.UseVisualStyleBackColor = True
        '
        'TB_PROVEDOR
        '
        Me.TB_PROVEDOR.Enabled = False
        Me.TB_PROVEDOR.Font = New System.Drawing.Font("Segoe UI", 8.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TB_PROVEDOR.Location = New System.Drawing.Point(325, 40)
        Me.TB_PROVEDOR.Margin = New System.Windows.Forms.Padding(4)
        Me.TB_PROVEDOR.Name = "TB_PROVEDOR"
        Me.TB_PROVEDOR.ReadOnly = True
        Me.TB_PROVEDOR.Size = New System.Drawing.Size(223, 25)
        Me.TB_PROVEDOR.TabIndex = 1106
        '
        'Label3
        '
        Me.Label3.AutoSize = True
        Me.Label3.Font = New System.Drawing.Font("Segoe UI", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label3.Location = New System.Drawing.Point(328, 18)
        Me.Label3.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(65, 19)
        Me.Label3.TabIndex = 1105
        Me.Label3.Text = "Provedor"
        '
        'TB_CANTIDAD
        '
        Me.TB_CANTIDAD.Enabled = False
        Me.TB_CANTIDAD.Font = New System.Drawing.Font("Segoe UI", 8.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TB_CANTIDAD.Location = New System.Drawing.Point(763, 40)
        Me.TB_CANTIDAD.Margin = New System.Windows.Forms.Padding(4)
        Me.TB_CANTIDAD.Name = "TB_CANTIDAD"
        Me.TB_CANTIDAD.ReadOnly = True
        Me.TB_CANTIDAD.Size = New System.Drawing.Size(67, 25)
        Me.TB_CANTIDAD.TabIndex = 1104
        '
        'TB_NUMERO_PARTE
        '
        Me.TB_NUMERO_PARTE.Enabled = False
        Me.TB_NUMERO_PARTE.Font = New System.Drawing.Font("Segoe UI", 8.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TB_NUMERO_PARTE.Location = New System.Drawing.Point(552, 40)
        Me.TB_NUMERO_PARTE.Margin = New System.Windows.Forms.Padding(4)
        Me.TB_NUMERO_PARTE.Name = "TB_NUMERO_PARTE"
        Me.TB_NUMERO_PARTE.ReadOnly = True
        Me.TB_NUMERO_PARTE.Size = New System.Drawing.Size(203, 25)
        Me.TB_NUMERO_PARTE.TabIndex = 1103
        '
        'BTN_SIGUIENTE
        '
        Me.BTN_SIGUIENTE.Anchor = System.Windows.Forms.AnchorStyles.None
        Me.BTN_SIGUIENTE.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center
        Me.BTN_SIGUIENTE.FlatAppearance.BorderColor = System.Drawing.Color.White
        Me.BTN_SIGUIENTE.FlatAppearance.MouseDownBackColor = System.Drawing.Color.White
        Me.BTN_SIGUIENTE.FlatAppearance.MouseOverBackColor = System.Drawing.Color.White
        Me.BTN_SIGUIENTE.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.BTN_SIGUIENTE.Image = Global.Pearl.My.Resources.Resources.BT_SIGUIENTE
        Me.BTN_SIGUIENTE.Location = New System.Drawing.Point(767, 385)
        Me.BTN_SIGUIENTE.Margin = New System.Windows.Forms.Padding(0)
        Me.BTN_SIGUIENTE.Name = "BTN_SIGUIENTE"
        Me.BTN_SIGUIENTE.Size = New System.Drawing.Size(71, 42)
        Me.BTN_SIGUIENTE.TabIndex = 1102
        Me.BTN_SIGUIENTE.UseVisualStyleBackColor = True
        '
        'Label9
        '
        Me.Label9.AutoSize = True
        Me.Label9.Font = New System.Drawing.Font("Segoe UI", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label9.Location = New System.Drawing.Point(24, 361)
        Me.Label9.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.Label9.Name = "Label9"
        Me.Label9.Size = New System.Drawing.Size(81, 19)
        Me.Label9.TabIndex = 358
        Me.Label9.Text = "Comentario"
        '
        'TB_COMENTARIO
        '
        Me.TB_COMENTARIO.Font = New System.Drawing.Font("Segoe UI", 8.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TB_COMENTARIO.Location = New System.Drawing.Point(20, 385)
        Me.TB_COMENTARIO.Margin = New System.Windows.Forms.Padding(4)
        Me.TB_COMENTARIO.Multiline = True
        Me.TB_COMENTARIO.Name = "TB_COMENTARIO"
        Me.TB_COMENTARIO.Size = New System.Drawing.Size(672, 44)
        Me.TB_COMENTARIO.TabIndex = 357
        Me.TB_COMENTARIO.Tag = "1"
        '
        'Label4
        '
        Me.Label4.AutoSize = True
        Me.Label4.Font = New System.Drawing.Font("Segoe UI", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label4.Location = New System.Drawing.Point(556, 18)
        Me.Label4.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.Label4.Name = "Label4"
        Me.Label4.Size = New System.Drawing.Size(114, 19)
        Me.Label4.TabIndex = 162
        Me.Label4.Text = "Numero de Parte"
        '
        'Label5
        '
        Me.Label5.AutoSize = True
        Me.Label5.Font = New System.Drawing.Font("Segoe UI", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label5.Location = New System.Drawing.Point(766, 21)
        Me.Label5.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.Label5.Name = "Label5"
        Me.Label5.Size = New System.Drawing.Size(64, 19)
        Me.Label5.TabIndex = 160
        Me.Label5.Text = "Cantidad"
        '
        'TB_ORDEN_COMPRA
        '
        Me.TB_ORDEN_COMPRA.Enabled = False
        Me.TB_ORDEN_COMPRA.Font = New System.Drawing.Font("Segoe UI", 8.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TB_ORDEN_COMPRA.Location = New System.Drawing.Point(26, 40)
        Me.TB_ORDEN_COMPRA.Margin = New System.Windows.Forms.Padding(4)
        Me.TB_ORDEN_COMPRA.Name = "TB_ORDEN_COMPRA"
        Me.TB_ORDEN_COMPRA.ReadOnly = True
        Me.TB_ORDEN_COMPRA.Size = New System.Drawing.Size(93, 25)
        Me.TB_ORDEN_COMPRA.TabIndex = 10
        '
        'Label15
        '
        Me.Label15.AutoSize = True
        Me.Label15.Font = New System.Drawing.Font("Segoe UI", 8.0!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label15.Location = New System.Drawing.Point(22, 21)
        Me.Label15.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.Label15.Name = "Label15"
        Me.Label15.Size = New System.Drawing.Size(101, 19)
        Me.Label15.TabIndex = 159
        Me.Label15.Text = "Orden Compra"
        '
        'FL_MENU_2
        '
        Me.FL_MENU_2.Anchor = CType((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.FL_MENU_2.BackColor = System.Drawing.Color.White
        Me.FL_MENU_2.Controls.Add(Me.BT_EXIT)
        Me.FL_MENU_2.Controls.Add(Me.BT_CANCEL)
        Me.FL_MENU_2.Controls.Add(Me.BT_SAVE)
        Me.FL_MENU_2.Controls.Add(Me.BT_EXPORT_EXCEL)
        Me.FL_MENU_2.FlowDirection = System.Windows.Forms.FlowDirection.RightToLeft
        Me.FL_MENU_2.Location = New System.Drawing.Point(794, 9)
        Me.FL_MENU_2.Margin = New System.Windows.Forms.Padding(4)
        Me.FL_MENU_2.Name = "FL_MENU_2"
        Me.FL_MENU_2.Padding = New System.Windows.Forms.Padding(0, 4, 0, 0)
        Me.FL_MENU_2.Size = New System.Drawing.Size(513, 49)
        Me.FL_MENU_2.TabIndex = 142
        '
        'BT_EXIT
        '
        Me.BT_EXIT.Anchor = System.Windows.Forms.AnchorStyles.None
        Me.BT_EXIT.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center
        Me.BT_EXIT.FlatAppearance.BorderColor = System.Drawing.Color.White
        Me.BT_EXIT.FlatAppearance.MouseDownBackColor = System.Drawing.Color.White
        Me.BT_EXIT.FlatAppearance.MouseOverBackColor = System.Drawing.Color.White
        Me.BT_EXIT.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.BT_EXIT.Image = Global.Pearl.My.Resources.Resources.ICO_BT_SALIR
        Me.BT_EXIT.Location = New System.Drawing.Point(420, 8)
        Me.BT_EXIT.Margin = New System.Windows.Forms.Padding(0)
        Me.BT_EXIT.Name = "BT_EXIT"
        Me.BT_EXIT.Size = New System.Drawing.Size(93, 42)
        Me.BT_EXIT.TabIndex = 23
        Me.BT_EXIT.UseVisualStyleBackColor = True
        Me.BT_EXIT.Visible = False
        '
        'BT_CANCEL
        '
        Me.BT_CANCEL.Anchor = System.Windows.Forms.AnchorStyles.None
        Me.BT_CANCEL.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center
        Me.BT_CANCEL.DialogResult = System.Windows.Forms.DialogResult.Cancel
        Me.BT_CANCEL.FlatAppearance.BorderColor = System.Drawing.Color.White
        Me.BT_CANCEL.FlatAppearance.MouseDownBackColor = System.Drawing.Color.White
        Me.BT_CANCEL.FlatAppearance.MouseOverBackColor = System.Drawing.Color.White
        Me.BT_CANCEL.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.BT_CANCEL.Image = Global.Pearl.My.Resources.Resources.ICO_BT_CANCELAR
        Me.BT_CANCEL.Location = New System.Drawing.Point(327, 8)
        Me.BT_CANCEL.Margin = New System.Windows.Forms.Padding(0)
        Me.BT_CANCEL.Name = "BT_CANCEL"
        Me.BT_CANCEL.Size = New System.Drawing.Size(93, 42)
        Me.BT_CANCEL.TabIndex = 23
        Me.BT_CANCEL.UseVisualStyleBackColor = True
        '
        'BT_SAVE
        '
        Me.BT_SAVE.Anchor = System.Windows.Forms.AnchorStyles.None
        Me.BT_SAVE.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center
        Me.BT_SAVE.FlatAppearance.BorderColor = System.Drawing.Color.White
        Me.BT_SAVE.FlatAppearance.MouseDownBackColor = System.Drawing.Color.White
        Me.BT_SAVE.FlatAppearance.MouseOverBackColor = System.Drawing.Color.White
        Me.BT_SAVE.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.BT_SAVE.Image = Global.Pearl.My.Resources.Resources.ICO_BT_GUARDAR
        Me.BT_SAVE.Location = New System.Drawing.Point(234, 8)
        Me.BT_SAVE.Margin = New System.Windows.Forms.Padding(0)
        Me.BT_SAVE.Name = "BT_SAVE"
        Me.BT_SAVE.Size = New System.Drawing.Size(93, 42)
        Me.BT_SAVE.TabIndex = 23
        Me.BT_SAVE.UseVisualStyleBackColor = True
        '
        'BT_SEARCH
        '
        Me.BT_SEARCH.Anchor = System.Windows.Forms.AnchorStyles.Right
        Me.BT_SEARCH.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center
        Me.BT_SEARCH.FlatAppearance.BorderColor = System.Drawing.Color.White
        Me.BT_SEARCH.FlatAppearance.MouseDownBackColor = System.Drawing.Color.White
        Me.BT_SEARCH.FlatAppearance.MouseOverBackColor = System.Drawing.Color.White
        Me.BT_SEARCH.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.BT_SEARCH.Image = Global.Pearl.My.Resources.Resources.ICO_BT_LI_BUSCAR
        Me.BT_SEARCH.Location = New System.Drawing.Point(1158, 32)
        Me.BT_SEARCH.Margin = New System.Windows.Forms.Padding(0)
        Me.BT_SEARCH.Name = "BT_SEARCH"
        Me.BT_SEARCH.Size = New System.Drawing.Size(87, 42)
        Me.BT_SEARCH.TabIndex = 3
        Me.BT_SEARCH.TextAlign = System.Drawing.ContentAlignment.MiddleRight
        Me.BT_SEARCH.UseVisualStyleBackColor = True
        Me.BT_SEARCH.Visible = False
        '
        'Label1
        '
        Me.Label1.AutoSize = True
        Me.Label1.Font = New System.Drawing.Font("Segoe UI", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label1.Location = New System.Drawing.Point(20, 21)
        Me.Label1.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(104, 19)
        Me.Label1.TabIndex = 8
        Me.Label1.Text = "Orden Compra:"
        '
        'TB_LI_BUSCAR
        '
        Me.TB_LI_BUSCAR.Font = New System.Drawing.Font("Segoe UI", 8.25!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TB_LI_BUSCAR.Location = New System.Drawing.Point(16, 39)
        Me.TB_LI_BUSCAR.Margin = New System.Windows.Forms.Padding(4)
        Me.TB_LI_BUSCAR.Name = "TB_LI_BUSCAR"
        Me.TB_LI_BUSCAR.Size = New System.Drawing.Size(225, 26)
        Me.TB_LI_BUSCAR.TabIndex = 1
        '
        'GB_LISTING
        '
        Me.GB_LISTING.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.GB_LISTING.BackColor = System.Drawing.Color.White
        Me.GB_LISTING.Controls.Add(Me.LI_LISTADO)
        Me.GB_LISTING.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.GB_LISTING.Location = New System.Drawing.Point(18, 159)
        Me.GB_LISTING.Margin = New System.Windows.Forms.Padding(4)
        Me.GB_LISTING.Name = "GB_LISTING"
        Me.GB_LISTING.Padding = New System.Windows.Forms.Padding(4)
        Me.GB_LISTING.Size = New System.Drawing.Size(1290, 510)
        Me.GB_LISTING.TabIndex = 139
        Me.GB_LISTING.TabStop = False
        Me.GB_LISTING.Text = "Listado"
        '
        'LI_LISTADO
        '
        Me.LI_LISTADO.AllowUserToAddRows = False
        Me.LI_LISTADO.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.LI_LISTADO.BackgroundColor = System.Drawing.Color.WhiteSmoke
        DataGridViewCellStyle16.Alignment = System.Windows.Forms.DataGridViewContentAlignment.MiddleLeft
        DataGridViewCellStyle16.BackColor = System.Drawing.Color.Red
        DataGridViewCellStyle16.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        DataGridViewCellStyle16.ForeColor = System.Drawing.SystemColors.WindowText
        DataGridViewCellStyle16.SelectionBackColor = System.Drawing.SystemColors.Highlight
        DataGridViewCellStyle16.SelectionForeColor = System.Drawing.Color.Black
        DataGridViewCellStyle16.WrapMode = System.Windows.Forms.DataGridViewTriState.[True]
        Me.LI_LISTADO.ColumnHeadersDefaultCellStyle = DataGridViewCellStyle16
        Me.LI_LISTADO.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize
        Me.LI_LISTADO.Location = New System.Drawing.Point(16, 21)
        Me.LI_LISTADO.Margin = New System.Windows.Forms.Padding(16, 12, 16, 12)
        Me.LI_LISTADO.Name = "LI_LISTADO"
        Me.LI_LISTADO.RowHeadersWidth = 51
        Me.LI_LISTADO.Size = New System.Drawing.Size(1259, 473)
        Me.LI_LISTADO.TabIndex = 2
        '
        'GB_FILTERS
        '
        Me.GB_FILTERS.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.GB_FILTERS.BackColor = System.Drawing.Color.White
        Me.GB_FILTERS.Controls.Add(Me.BT_SEARCH)
        Me.GB_FILTERS.Controls.Add(Me.Label1)
        Me.GB_FILTERS.Controls.Add(Me.TB_LI_BUSCAR)
        Me.GB_FILTERS.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.GB_FILTERS.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.GB_FILTERS.Location = New System.Drawing.Point(18, 68)
        Me.GB_FILTERS.Margin = New System.Windows.Forms.Padding(4)
        Me.GB_FILTERS.Name = "GB_FILTERS"
        Me.GB_FILTERS.Padding = New System.Windows.Forms.Padding(4)
        Me.GB_FILTERS.Size = New System.Drawing.Size(1290, 85)
        Me.GB_FILTERS.TabIndex = 138
        Me.GB_FILTERS.TabStop = False
        Me.GB_FILTERS.Text = "Filtros"
        '
        'LB_RESULTADO
        '
        Me.LB_RESULTADO.Anchor = CType((((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Bottom) _
            Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.LB_RESULTADO.BackColor = System.Drawing.Color.White
        Me.LB_RESULTADO.BorderStyle = System.Windows.Forms.BorderStyle.FixedSingle
        Me.LB_RESULTADO.Enabled = False
        Me.LB_RESULTADO.Font = New System.Drawing.Font("Courier New", 6.75!, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.LB_RESULTADO.Location = New System.Drawing.Point(8, 18)
        Me.LB_RESULTADO.Margin = New System.Windows.Forms.Padding(4)
        Me.LB_RESULTADO.Multiline = True
        Me.LB_RESULTADO.Name = "LB_RESULTADO"
        Me.LB_RESULTADO.ScrollBars = System.Windows.Forms.ScrollBars.Horizontal
        Me.LB_RESULTADO.Size = New System.Drawing.Size(1269, 36)
        Me.LB_RESULTADO.TabIndex = 4
        '
        'GB_OPERACION
        '
        Me.GB_OPERACION.Anchor = CType(((System.Windows.Forms.AnchorStyles.Bottom Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.GB_OPERACION.BackColor = System.Drawing.Color.White
        Me.GB_OPERACION.Controls.Add(Me.LB_RESULTADO)
        Me.GB_OPERACION.Font = New System.Drawing.Font("Microsoft Sans Serif", 8.25!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.GB_OPERACION.Location = New System.Drawing.Point(18, 671)
        Me.GB_OPERACION.Margin = New System.Windows.Forms.Padding(4)
        Me.GB_OPERACION.Name = "GB_OPERACION"
        Me.GB_OPERACION.Padding = New System.Windows.Forms.Padding(4)
        Me.GB_OPERACION.Size = New System.Drawing.Size(1286, 64)
        Me.GB_OPERACION.TabIndex = 140
        Me.GB_OPERACION.TabStop = False
        Me.GB_OPERACION.Text = "Operación"
        '
        'BT_EDIT
        '
        Me.BT_EDIT.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center
        Me.BT_EDIT.FlatAppearance.BorderColor = System.Drawing.Color.White
        Me.BT_EDIT.FlatAppearance.MouseDownBackColor = System.Drawing.Color.White
        Me.BT_EDIT.FlatAppearance.MouseOverBackColor = System.Drawing.Color.White
        Me.BT_EDIT.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.BT_EDIT.Image = CType(resources.GetObject("BT_EDIT.Image"), System.Drawing.Image)
        Me.BT_EDIT.Location = New System.Drawing.Point(60, 4)
        Me.BT_EDIT.Margin = New System.Windows.Forms.Padding(0)
        Me.BT_EDIT.Name = "BT_EDIT"
        Me.BT_EDIT.Size = New System.Drawing.Size(60, 39)
        Me.BT_EDIT.TabIndex = 19
        Me.BT_EDIT.UseVisualStyleBackColor = True
        Me.BT_EDIT.Visible = False
        '
        'FL_MENU_1
        '
        Me.FL_MENU_1.Anchor = CType(((System.Windows.Forms.AnchorStyles.Top Or System.Windows.Forms.AnchorStyles.Left) _
            Or System.Windows.Forms.AnchorStyles.Right), System.Windows.Forms.AnchorStyles)
        Me.FL_MENU_1.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink
        Me.FL_MENU_1.BackColor = System.Drawing.Color.White
        Me.FL_MENU_1.Controls.Add(Me.BT_NEW)
        Me.FL_MENU_1.Controls.Add(Me.BT_EDIT)
        Me.FL_MENU_1.Controls.Add(Me.BT_DELETE)
        Me.FL_MENU_1.Location = New System.Drawing.Point(18, 9)
        Me.FL_MENU_1.Margin = New System.Windows.Forms.Padding(4)
        Me.FL_MENU_1.Name = "FL_MENU_1"
        Me.FL_MENU_1.Padding = New System.Windows.Forms.Padding(0, 4, 0, 0)
        Me.FL_MENU_1.Size = New System.Drawing.Size(780, 49)
        Me.FL_MENU_1.TabIndex = 141
        '
        'BT_NEW
        '
        Me.BT_NEW.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center
        Me.BT_NEW.FlatAppearance.BorderColor = System.Drawing.Color.White
        Me.BT_NEW.FlatAppearance.MouseDownBackColor = System.Drawing.Color.White
        Me.BT_NEW.FlatAppearance.MouseOverBackColor = System.Drawing.Color.White
        Me.BT_NEW.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.BT_NEW.Image = CType(resources.GetObject("BT_NEW.Image"), System.Drawing.Image)
        Me.BT_NEW.Location = New System.Drawing.Point(0, 4)
        Me.BT_NEW.Margin = New System.Windows.Forms.Padding(0)
        Me.BT_NEW.Name = "BT_NEW"
        Me.BT_NEW.Size = New System.Drawing.Size(60, 39)
        Me.BT_NEW.TabIndex = 18
        Me.BT_NEW.UseVisualStyleBackColor = True
        Me.BT_NEW.Visible = False
        '
        'BT_DELETE
        '
        Me.BT_DELETE.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Center
        Me.BT_DELETE.FlatAppearance.BorderColor = System.Drawing.Color.White
        Me.BT_DELETE.FlatAppearance.MouseDownBackColor = System.Drawing.Color.White
        Me.BT_DELETE.FlatAppearance.MouseOverBackColor = System.Drawing.Color.White
        Me.BT_DELETE.FlatStyle = System.Windows.Forms.FlatStyle.Flat
        Me.BT_DELETE.ForeColor = System.Drawing.Color.Black
        Me.BT_DELETE.Image = CType(resources.GetObject("BT_DELETE.Image"), System.Drawing.Image)
        Me.BT_DELETE.Location = New System.Drawing.Point(120, 4)
        Me.BT_DELETE.Margin = New System.Windows.Forms.Padding(0)
        Me.BT_DELETE.Name = "BT_DELETE"
        Me.BT_DELETE.Size = New System.Drawing.Size(60, 39)
        Me.BT_DELETE.TabIndex = 20
        Me.BT_DELETE.UseVisualStyleBackColor = True
        Me.BT_DELETE.Visible = False
        '
        'TB_N_INSPECCION
        '
        Me.TB_N_INSPECCION.BackColor = System.Drawing.SystemColors.ActiveCaption
        Me.TB_N_INSPECCION.BorderStyle = System.Windows.Forms.BorderStyle.None
        Me.TB_N_INSPECCION.Font = New System.Drawing.Font("Segoe UI", 12.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TB_N_INSPECCION.ForeColor = System.Drawing.SystemColors.ActiveCaption
        Me.TB_N_INSPECCION.Location = New System.Drawing.Point(384, 18)
        Me.TB_N_INSPECCION.Margin = New System.Windows.Forms.Padding(4)
        Me.TB_N_INSPECCION.Name = "TB_N_INSPECCION"
        Me.TB_N_INSPECCION.ReadOnly = True
        Me.TB_N_INSPECCION.Size = New System.Drawing.Size(61, 27)
        Me.TB_N_INSPECCION.TabIndex = 378
        Me.TB_N_INSPECCION.TextAlign = System.Windows.Forms.HorizontalAlignment.Right
        '
        'Label6
        '
        Me.Label6.AutoSize = True
        Me.Label6.Font = New System.Drawing.Font("Segoe UI", 10.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.Label6.Location = New System.Drawing.Point(275, 21)
        Me.Label6.Margin = New System.Windows.Forms.Padding(4, 0, 4, 0)
        Me.Label6.Name = "Label6"
        Me.Label6.Size = New System.Drawing.Size(98, 23)
        Me.Label6.TabIndex = 379
        Me.Label6.Text = "Inspección:"
        '
        'TB_DIAGONAL
        '
        Me.TB_DIAGONAL.BackColor = System.Drawing.SystemColors.Info
        Me.TB_DIAGONAL.BorderStyle = System.Windows.Forms.BorderStyle.None
        Me.TB_DIAGONAL.Font = New System.Drawing.Font("Segoe UI", 12.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TB_DIAGONAL.ForeColor = System.Drawing.SystemColors.Info
        Me.TB_DIAGONAL.Location = New System.Drawing.Point(453, 17)
        Me.TB_DIAGONAL.Margin = New System.Windows.Forms.Padding(4)
        Me.TB_DIAGONAL.Name = "TB_DIAGONAL"
        Me.TB_DIAGONAL.ReadOnly = True
        Me.TB_DIAGONAL.Size = New System.Drawing.Size(21, 27)
        Me.TB_DIAGONAL.TabIndex = 380
        Me.TB_DIAGONAL.TextAlign = System.Windows.Forms.HorizontalAlignment.Center
        '
        'TB_TOTAL_INSPECCION
        '
        Me.TB_TOTAL_INSPECCION.BackColor = System.Drawing.SystemColors.ActiveCaption
        Me.TB_TOTAL_INSPECCION.BorderStyle = System.Windows.Forms.BorderStyle.None
        Me.TB_TOTAL_INSPECCION.Font = New System.Drawing.Font("Segoe UI", 12.0!, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, CType(0, Byte))
        Me.TB_TOTAL_INSPECCION.ForeColor = System.Drawing.SystemColors.ActiveCaption
        Me.TB_TOTAL_INSPECCION.Location = New System.Drawing.Point(482, 18)
        Me.TB_TOTAL_INSPECCION.Margin = New System.Windows.Forms.Padding(4)
        Me.TB_TOTAL_INSPECCION.Name = "TB_TOTAL_INSPECCION"
        Me.TB_TOTAL_INSPECCION.ReadOnly = True
        Me.TB_TOTAL_INSPECCION.Size = New System.Drawing.Size(61, 27)
        Me.TB_TOTAL_INSPECCION.TabIndex = 381
        '
        'FO_MATERIAL_INSPECCION
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(8.0!, 16.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(1327, 745)
        Me.Controls.Add(Me.GB_FILE)
        Me.Controls.Add(Me.FL_MENU_2)
        Me.Controls.Add(Me.GB_LISTING)
        Me.Controls.Add(Me.GB_FILTERS)
        Me.Controls.Add(Me.GB_OPERACION)
        Me.Controls.Add(Me.FL_MENU_1)
        Me.Name = "FO_MATERIAL_INSPECCION"
        Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen
        Me.Text = "Inspeccionar Material"
        Me.GB_FILE.ResumeLayout(False)
        Me.GB_DESCRIPCION_MATERIAL.ResumeLayout(False)
        Me.GB_DESCRIPCION_MATERIAL.PerformLayout()
        Me.GB_ESPECIFICACIONES.ResumeLayout(False)
        Me.GB_ESPECIFICACIONES.PerformLayout()
        Me.FL_MENU_2.ResumeLayout(False)
        Me.GB_LISTING.ResumeLayout(False)
        CType(Me.LI_LISTADO, System.ComponentModel.ISupportInitialize).EndInit()
        Me.GB_FILTERS.ResumeLayout(False)
        Me.GB_FILTERS.PerformLayout()
        Me.GB_OPERACION.ResumeLayout(False)
        Me.GB_OPERACION.PerformLayout()
        Me.FL_MENU_1.ResumeLayout(False)
        Me.ResumeLayout(False)

    End Sub

    Public WithEvents BT_EXPORT_EXCEL As Button
    Public WithEvents GB_FILE As GroupBox
    Friend WithEvents GB_DESCRIPCION_MATERIAL As GroupBox
    Friend WithEvents Label9 As Label
    Public WithEvents TB_COMENTARIO As TextBox
    Friend WithEvents Label4 As Label
    Friend WithEvents Label5 As Label
    Public WithEvents TB_ORDEN_COMPRA As TextBox
    Friend WithEvents Label15 As Label
    Public WithEvents FL_MENU_2 As FlowLayoutPanel
    Public WithEvents BT_EXIT As Button
    Public WithEvents BT_CANCEL As Button
    Public WithEvents BT_SAVE As Button
    Public WithEvents BT_SEARCH As Button
    Friend WithEvents Label1 As Label
    Public WithEvents TB_LI_BUSCAR As TextBox
    Public WithEvents GB_LISTING As GroupBox
    Public WithEvents LI_LISTADO As DataGridView
    Public WithEvents GB_FILTERS As GroupBox
    Public WithEvents LB_RESULTADO As TextBox
    Public WithEvents GB_OPERACION As GroupBox
    Public WithEvents TI_RELOJ As Timer
    Public WithEvents BT_EDIT As Button
    Public WithEvents FL_MENU_1 As FlowLayoutPanel
    Public WithEvents BT_NEW As Button
    Public WithEvents BT_DELETE As Button
    Public WithEvents BTN_SIGUIENTE As Button
    Public WithEvents TB_PROVEDOR As TextBox
    Friend WithEvents Label3 As Label
    Public WithEvents TB_CANTIDAD As TextBox
    Public WithEvents TB_NUMERO_PARTE As TextBox
    Public WithEvents BTN_ANTERIOR As Button
    Public WithEvents TB_CLIENTE As TextBox
    Friend WithEvents Label2 As Label
    Friend WithEvents GB_ESPECIFICACIONES As GroupBox
    Friend WithEvents Label8 As Label
    Public WithEvents TB_INSPECCION_PORCENTAJE As TextBox
    Public WithEvents TB_K_INSPECCION As TextBox
    Friend WithEvents Label13 As Label
    Public WithEvents TB_INSPECCION As TextBox
    Friend WithEvents CHB_OPCION_2 As CheckBox
    Friend WithEvents CHB_OPCION_1 As CheckBox
    Friend WithEvents CHB_OPCION_3 As CheckBox
    Friend WithEvents CHB_OPCION_5 As CheckBox
    Friend WithEvents CHB_OPCION_4 As CheckBox
    Public WithEvents TB_TOTAL_INSPECCION As TextBox
    Public WithEvents TB_DIAGONAL As TextBox
    Friend WithEvents Label6 As Label
    Public WithEvents TB_N_INSPECCION As TextBox
End Class
