<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String titulo = "Reporte - Guías";
    String endpoint = request.getContextPath() + "/RptGuias";      // Servlet que lista guías
    String detalleBase = request.getContextPath() + "/DetalleGuia"; // ✅ Servlet detalle (para botón Ver)
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
</head>

<body class="bg-light">

<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 class="mb-0"><%=titulo%></h3>
        <a href="<%=request.getContextPath()%>/home" class="btn btn-secondary">Regresar</a>
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
                    <button type="button" class="btn btn-primary w-100" id="btnFiltrar">Filtrar</button>
                </div>
                <div class="col-12 col-md-3">
                    <button type="button" class="btn btn-outline-secondary w-100" id="btnLimpiar">Limpiar</button>
                </div>
            </div>

            <!-- Tabla -->
            <div class="table-responsive">
                <table id="tblGuias" class="table table-bordered table-striped align-middle w-100">
                    <thead class="table-dark">
                        <tr>
                            <th>ID_USUARIO</th>
                            <th>NOMBRE</th>
                            <th>DOC_MATERIAL</th>
                            <th>FECHA_CIERRE</th>
                            <th>TIPO</th>
                            <th class="text-center">ACCIONES</th> <!-- ✅ -->
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
    const detalleBase = "<%=detalleBase%>"; // ✅ aquí está la corrección

    const table = $('#tblGuias').DataTable({
        paging: true,
        searching: true,
        ordering: true,
        lengthChange: true,
        responsive: false,
        language: {
            url: "https://cdn.datatables.net/plug-ins/1.13.8/i18n/es-ES.json"
        },
        dom: 'Bfrtip',
        buttons: [
            {
                extend: 'excelHtml5',
                title: '<%=titulo%>',
                text: 'Exportar a Excel',
                className: 'btn btn-success'
            }
        ],
        columns: [
            { data: 'id_usuario' },
            { data: 'nombre' },
            { data: 'doc_material' },
            { data: 'fecha_cierre' },
            { data: 'tipo' },
            { // ✅ ACCIONES
                data: null,
                orderable: false,
                searchable: false,
                className: 'text-center',
                render: function (data, type, row) {
                    const doc = encodeURIComponent(row.doc_material || "");
                    const tipo = encodeURIComponent(row.tipo || "");
                    return '<a class="btn btn-sm btn-primary" href="' + detalleBase + '?doc=' + doc + '&tipo=' + tipo + '">Ver</a>';
                }
            }
        ]
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
