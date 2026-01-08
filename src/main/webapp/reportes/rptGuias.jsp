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

    <link href="<%=request.getContextPath()%>/reportes/detalles.css" rel="stylesheet"> 
    <!-- Bootstrap -->
          <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet"> 


    <!-- DataTables -->
    <link href="<%=request.getContextPath()%>/css/dataTables.css" rel="stylesheet"> 
    <link href="<%=request.getContextPath()%>/css/buttons.css" rel="stylesheet"> 

    <!-- JS -->
    <script src="<%=request.getContextPath()%>/js/jquery.js"></script>
    <script src="<%=request.getContextPath()%>/js/sweetalert2.js"></script>

          <script src="<%=request.getContextPath()%>/js/jqueryDataTables.js"></script>
          <script src="<%=request.getContextPath()%>/js/dataTablesBootstrap.js"></script>
    <script src="<%=request.getContextPath()%>/js/dataTableButtons.js"></script>
    <script src="<%=request.getContextPath()%>/js/buttonsBootstrap.js"></script>
    <script src="<%=request.getContextPath()%>/js/jszip.js"></script>
    <script src="<%=request.getContextPath()%>/js/buttonshtml5.js"></script>

</head>

<body>
    <jsp:include page="/componentes/navbar.jsp" />

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
            <script src="<%=request.getContextPath()%>/js/bundle.js"></script>


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
            url: '<%=request.getContextPath()%>/js/es-ES.json'
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
