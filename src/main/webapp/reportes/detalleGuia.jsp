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

    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet"> 
    <link href="<%=request.getContextPath()%>/reportes/detalles.css" rel="stylesheet"> 
    <link href="<%=request.getContextPath()%>/css/dataTables.css" rel="stylesheet"> 
    <link href="<%=request.getContextPath()%>/css/buttons.css" rel="stylesheet"> 
    <script src="<%=request.getContextPath()%>/js/bundle.js"></script>
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
            url: '<%=request.getContextPath()%>/js/es-ES.json'
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
