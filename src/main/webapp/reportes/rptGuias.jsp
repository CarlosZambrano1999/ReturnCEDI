<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String titulo = "Reporte - Guías";
    String endpoint = request.getContextPath() + "/RptGuias";      // Servlet que lista guías
    String detalleBase = request.getContextPath() + "/DetalleGuia"; // Servlet detalle (para botón Ver)
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%=titulo%></title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- DataTables -->
    <link href="https://cdn.datatables.net/1.13.8/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    <link href="https://cdn.datatables.net/buttons/2.4.2/css/buttons.bootstrap5.min.css" rel="stylesheet">

    <!-- JS -->
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <!-- DataTables JS -->
    <script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.8/js/dataTables.bootstrap5.min.js"></script>

    <!-- Buttons Excel -->
    <script src="https://cdn.datatables.net/buttons/2.4.2/js/dataTables.buttons.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.4.2/js/buttons.bootstrap5.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.4.2/js/buttons.html5.min.js"></script>

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
            font-weight: 600;
        }
        .btn-rc-primary:hover{ filter: brightness(.95); }

        .btn-rc-success{
            background: var(--rc-green) !important;
            border-color: var(--rc-green) !important;
            color: #fff !important;
            font-weight: 600;
        }
        .btn-rc-success:hover{ filter: brightness(.95); }

        .btn-outline-rc{
            border-color: var(--rc-border) !important;
            color: var(--rc-text) !important;
            font-weight: 600;
            background: #fff !important;
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
        #tblGuias thead{
            background: linear-gradient(90deg, var(--rc-blue), var(--rc-green)) !important;
            color: #fff !important;
        }
        #tblGuias thead th{
            border-color: rgba(255,255,255,.25) !important;
            vertical-align: middle;
            font-weight: 700;
            font-size: .9rem;
            white-space: nowrap;
        }
        #tblGuias tbody td{
            border-color: var(--rc-border) !important;
            font-size: .92rem;
        }

        /* Inputs / labels */
        .form-label{ color: var(--rc-muted); font-weight: 600; }
        .form-control{
            border-radius: 12px !important;
            border-color: var(--rc-border) !important;
        }
        .form-control:focus{
            border-color: var(--rc-blue) !important;
            box-shadow: 0 0 0 .2rem rgba(0,174,239,.15) !important;
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

        /* Botones de DataTables (Excel) */
        .dt-buttons .btn{
            border-radius: 10px !important;
            font-weight: 700 !important;
        }
    </style>
</head>

<body>

<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 class="rc-title">
            <span class="t1">Return</span><span class="t2">CEDI</span>
            <span class="ms-2 text-muted fw-semibold" style="font-size:.95rem;">| <%=titulo%></span>
        </h3>
        <a href="<%=request.getContextPath()%>/home" class="btn btn-outline-rc">Regresar</a>
    </div>

    <div class="card shadow-sm">
        <div class="card-body">

            <!-- Filtros -->
            <div class="row g-2 align-items-end mb-3">
                <div class="col-12 col-md-3">
                    <label class="form-label mb-1">Desde</label>
                    <input type="date" class="form-control" id="desde">
                </div>
                <div class="col-12 col-md-3">
                    <label class="form-label mb-1">Hasta</label>
                    <input type="date" class="form-control" id="hasta">
                </div>
                <div class="col-12 col-md-3">
                    <button type="button" class="btn btn-rc-primary w-100" id="btnFiltrar">Filtrar</button>
                </div>
                <div class="col-12 col-md-3">
                    <button type="button" class="btn btn-outline-rc w-100" id="btnLimpiar">Limpiar</button>
                </div>
            </div>

            <!-- Tabla -->
            <div class="table-responsive">
                <table id="tblGuias" class="table table-bordered table-striped align-middle w-100">
                    <thead>
                        <tr>
                            <th>ID_USUARIO</th>
                            <th>NOMBRE</th>
                            <th>DOC_MATERIAL</th>
                            <th>FECHA_CIERRE</th>
                            <th>TIPO</th>
                            <th class="text-center">ACCIONES</th>
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
    const detalleBase = "<%=detalleBase%>";

    const table = $('#tblGuias').DataTable({
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
                title: '<%=titulo%>',
                text: 'Exportar a Excel',
                className: 'btn btn-rc-success'
            }
        ],
        columns: [
            { data: 'id_usuario' },
            { data: 'nombre' },
            { data: 'doc_material' },
            { data: 'fecha_cierre' },
            { data: 'tipo' },
            {
                data: null,
                orderable: false,
                searchable: false,
                className: 'text-center',
                render: function (data, type, row) {
                    const doc = encodeURIComponent(row.doc_material || "");
                    const tipo = encodeURIComponent(row.tipo || "");
                    return '<a class="btn btn-sm btn-rc-primary" href="' + detalleBase + '?doc=' + doc + '&tipo=' + tipo + '">Ver</a>';
                }
            }
        ]
    });

    // ✅ SweetAlert con colores del tema (opcional pero bonito)
    Swal.mixin({
        confirmButtonColor: '#00AEEF',
        cancelButtonColor:  '#00C56A'
    });

    function cargar() {
        const desde = $('#desde').val();
        const hasta = $('#hasta').val();

        if (desde && hasta && desde > hasta) {
            Swal.fire("Rango inválido", "La fecha DESDE no puede ser mayor que HASTA.", "warning");
            return;
        }

        $.post(endpoint, { desde, hasta })
            .done(function (json) {

                if (!json || !json.status) {
                    table.clear().draw();
                    Swal.fire("Error", "Respuesta inválida del servidor.", "error");
                    return;
                }

                if (json.status === "logout") {
                    Swal.fire("Sesión expirada", json.message || "Inicia sesión nuevamente.", "warning")
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
                Swal.fire("Error", "No se pudo consultar el reporte.", "error");
            });
    }

    $('#btnFiltrar').on('click', cargar);

    $('#btnLimpiar').on('click', function () {
        $('#desde').val('');
        $('#hasta').val('');
        cargar();
    });

    cargar();
});
</script>

</body>
</html>
