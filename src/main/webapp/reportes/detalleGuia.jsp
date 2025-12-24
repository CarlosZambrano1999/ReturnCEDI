<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String doc = request.getParameter("doc");
    if (doc == null) doc = (String) request.getAttribute("doc");

    String tipo = request.getParameter("tipo");
    if (tipo == null) tipo = (String) request.getAttribute("tipo");

    if (doc == null) doc = "";
    if (tipo == null) tipo = "";

    String endpoint = request.getContextPath() + "/DetalleGuia";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Detalle de Guía</title>

    <!-- Bootstrap -->
    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet"> 

    <!-- DataTables -->
    <link href="<%=request.getContextPath()%>/css/dataTables.css" rel="stylesheet"> 
    <link href="<%=request.getContextPath()%>/css/buttons.css" rel="stylesheet"> 

    <!-- JS -->
        <script src="<%=request.getContextPath()%>/js/jquery.js"></script>

    <script src="<%=request.getContextPath()%>/js/sweetalert2.js"></script>

    <!-- DataTables JS -->
              <script src="<%=request.getContextPath()%>/js/jqueryDataTables.js"></script>

              <script src="<%=request.getContextPath()%>/js/dataTablesBootstrap.js"></script>


    <!-- Buttons Excel -->
        <script src="<%=request.getContextPath()%>/js/dataTableButtons.js"></script>

      <script src="<%=request.getContextPath()%>/js/buttonsBootstrap.js"></script>

       <script src="<%=request.getContextPath()%>/js/jszip.js"></script>

        <script src="<%=request.getContextPath()%>/js/buttonshtml5.js"></script>


    <!-- ✅ Tema ReturnCEDI / FarmaFácil -->
    <style>
        :root{
            --rc-blue:  #00AEEF;  /* azul/cian */
            --rc-green: #00C56A;  /* verde */
            --rc-bg:    #F6F8FB;  /* fondo claro */
            --rc-text:  #0f172a;
            --rc-muted: #64748b;
            --rc-border:#e5e7eb;
        }

        body{ background: var(--rc-bg) !important; color: var(--rc-text); }

        .rc-title{
            font-weight: 800;
            letter-spacing: .2px;
            margin: 0;
            line-height: 1.1;
        }
        .rc-title .t1{ color: var(--rc-blue); }
        .rc-title .t2{ color: var(--rc-green); }

        .card{
            border: 1px solid var(--rc-border) !important;
            border-radius: 14px !important;
        }

        /* Botones con paleta */
        .btn-rc-primary{
            background: var(--rc-blue) !important;
            border-color: var(--rc-blue) !important;
            color: #fff !important;
            font-weight: 700;
            border-radius: 10px !important;
        }
        .btn-rc-primary:hover{ filter: brightness(.95); }

        .btn-rc-success{
            background: var(--rc-green) !important;
            border-color: var(--rc-green) !important;
            color: #fff !important;
            font-weight: 700;
            border-radius: 10px !important;
        }
        .btn-rc-success:hover{ filter: brightness(.95); }

        .btn-outline-rc{
            border-color: var(--rc-border) !important;
            color: var(--rc-text) !important;
            font-weight: 700;
            background: #fff !important;
            border-radius: 10px !important;
        }
        .btn-outline-rc:hover{
            border-color: var(--rc-blue) !important;
            color: var(--rc-blue) !important;
        }

        /* Tabla + encabezado */
        table.dataTable{
            border: 1px solid var(--rc-border) !important;
            border-radius: 12px;
            overflow: hidden;
        }
        #tblDetalle thead{
            background: linear-gradient(90deg, var(--rc-blue), var(--rc-green)) !important;
            color: #fff !important;
        }
        #tblDetalle thead th{
            border-color: rgba(255,255,255,.25) !important;
            vertical-align: middle;
            font-weight: 700;
            font-size: .9rem;
            white-space: nowrap;
        }
        #tblDetalle tbody td{
            border-color: var(--rc-border) !important;
            font-size: .92rem;
        }

        /* DataTables (buscador, select, paginación) */
        .dataTables_wrapper .dataTables_filter input,
        .dataTables_wrapper .dataTables_length select{
            border: 1px solid var(--rc-border) !important;
            border-radius: 10px !important;
            padding: .4rem .6rem !important;
            outline: none !important;
            box-shadow: none !important;
            background: #fff !important;
        }
        .dataTables_wrapper .dataTables_filter input:focus,
        .dataTables_wrapper .dataTables_length select:focus{
            border-color: var(--rc-blue) !important;
            box-shadow: 0 0 0 .2rem rgba(0,174,239,.15) !important;
        }
        .dataTables_wrapper .dataTables_info{ color: var(--rc-muted) !important; }

        .page-link{
            border-color: var(--rc-border) !important;
            color: var(--rc-text) !important;
            border-radius: 10px !important;
            margin: 0 .12rem;
        }
        .page-item.active .page-link{
            background: var(--rc-blue) !important;
            border-color: var(--rc-blue) !important;
            color: #fff !important;
        }
        .page-link:focus{
            box-shadow: 0 0 0 .2rem rgba(0,174,239,.15) !important;
        }

        /* Botones DataTables */
        .dt-buttons .btn{ border-radius: 10px !important; font-weight: 800 !important; }

        /* Línea de info superior */
        .rc-sub{
            color: var(--rc-muted);
            font-weight: 600;
        }
        .rc-sub strong{ color: var(--rc-text); }

        /* Centrado numéricos */
        .text-center-col{ text-align:center; }
    </style>
</head>

<body>

<div class="container py-4">

    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h3 class="rc-title mb-0">
                <span class="t1">Return</span><span class="t2">CEDI</span>
                <span class="ms-2 text-muted fw-semibold" style="font-size:.95rem;">| Detalle de Guía</span>
            </h3>
            <div class="rc-sub mt-1">
                Documento: <strong><%=doc%></strong> &nbsp;|&nbsp; Tipo: <strong><%=tipo%></strong>
            </div>
        </div>

        <a href="javascript:history.back()" class="btn btn-outline-rc">Regresar</a>
    </div>

    <div class="card shadow-sm">
        <div class="card-body">

            <div class="table-responsive">
                <table id="tblDetalle" class="table table-bordered table-striped align-middle w-100">
                    <thead>
                        <tr>
                            <th>DOC_MATERIAL</th>
                            <th>USUARIO</th>
                            <th>CODIGO_SAP</th>
                            <th>CODIGO</th>
                            <th>PRODUCTO</th>
                            <th class="text-center">ENVIADO</th>
                            <th class="text-center">RECIBIDO</th>
                            <th>FARMACIA</th>
                            <th>INCIDENCIA</th>
                            <th>OBSERVACION</th>
                            <th>FECHA_SCAN</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>

        </div>
    </div>

</div>

<script>
$(function () {

    const endpoint = "<%=endpoint%>";
    const docMaterial = "<%=doc%>";
    const tipo = "<%=tipo%>";

    // ✅ SweetAlert2 con paleta
    const Toast = Swal.mixin({
        confirmButtonColor: '#00AEEF',
        cancelButtonColor:  '#00C56A'
    });

    if (!docMaterial || !tipo) {
        Toast.fire("Error", "Faltan parámetros (doc / tipo).", "error");
        return;
    }

    const table = $('#tblDetalle').DataTable({
        paging: true,
        searching: true,
        ordering: true,
        lengthChange: true,
        responsive: false,
        language: {
            url: "https://cdn.datatables.net/plug-ins/1.13.8/i18n/es-ES.json"
        },
        dom: '<"d-flex flex-wrap gap-2 align-items-center justify-content-between mb-2"Bf>rt<"d-flex flex-wrap gap-2 align-items-center justify-content-between mt-2"lip>',
        buttons: [
            {
                extend: 'excelHtml5',
                title: 'Detalle Guía ' + docMaterial,
                text: 'Exportar a Excel',
                className: 'btn btn-rc-success'
            }
        ],
        columns: [
            { data: 'doc_material' },
            { data: 'usuario' },
            { data: 'codigo_sap' },
            { data: 'codigo' },
            { data: 'producto' },
            { data: 'enviado', className: 'text-center' },
            { data: 'recibido', className: 'text-center' },
            { data: 'farmacia' },
            { data: 'incidencia' },
            { data: 'observacion' },
            { data: 'fecha_scan' }
        ]
    });

    function cargar() {
        $.post(endpoint, { doc: docMaterial, tipo: tipo })
            .done(function (json) {

                if (!json || !json.status) {
                    table.clear().draw();
                    Swal.fire("Error", "Respuesta inválida del servidor.", "error");
                    return;
                }

                if (json.status === "logout") {
                    Swal.fire("Sesión expirada", "Inicia sesión nuevamente.", "warning")
                        .then(() => window.location.href = "<%=request.getContextPath()%>/login");
                    return;
                }

                if (json.status === "error") {
                    table.clear().draw();
                    Swal.fire("Error", json.message || "Ocurrió un error.", "error");
                    return;
                }

                if (json.status === "empty") {
                    table.clear().draw();
                    return;
                }

                if (json.status === "success") {
                    table.clear().rows.add(json.data || []).draw();
                    return;
                }

                table.clear().draw();
            })
            .fail(function () {
                table.clear().draw();
                Swal.fire("Error", "No se pudo consultar el detalle.", "error");
            });
    }

    cargar();
});
</script>

</body>
</html>
