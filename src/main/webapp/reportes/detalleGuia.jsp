<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // ✅ Acepta tanto parámetros URL como atributos enviados por el servlet
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
        <div>
            <h4 class="mb-0">Detalle de Guía</h4>
            <small class="text-muted">
                Documento: <strong><%=doc%></strong> |
                Tipo: <strong><%=tipo%></strong>
            </small>
        </div>

        <a href="javascript:history.back()" class="btn btn-secondary">Regresar</a>
    </div>

    <div class="card shadow-sm">
        <div class="card-body">

            <div class="table-responsive">
                <table id="tblDetalle" class="table table-bordered table-striped align-middle w-100">
                    <thead class="table-dark">
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

    if (!docMaterial || !tipo) {
        Swal.fire("Error", "Faltan parámetros (doc / tipo).", "error");
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
        dom: 'Bfrtip',
        buttons: [
            {
                extend: 'excelHtml5',
                title: 'Detalle Guía ' + docMaterial,
                text: 'Exportar a Excel',
                className: 'btn btn-success'
            }
        ],
        columns: [
            { data: 'doc_material' },
            { data: 'usuario' },
            { data: 'codigo_sap' },
            { data: 'codigo' },
            { data: 'producto' },
            { data: 'enviado' },
            { data: 'recibido' },
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
