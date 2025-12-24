<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String forwardPath = (String) request.getAttribute("jakarta.servlet.forward.servlet_path");
    String servletPath = (forwardPath != null) ? forwardPath : request.getServletPath();

    String titulo = "Reporte";
    if ("/RptDevoluciones".equalsIgnoreCase(servletPath)) {
        titulo = "Reporte - Devoluciones";
    } else if ("/RptDonaciones".equalsIgnoreCase(servletPath)) {
        titulo = "Reporte - Donaciones";
    } else if ("/RptExcesos".equalsIgnoreCase(servletPath)) {
        titulo = "Reporte - Excesos";
    }

    String endpoint = request.getContextPath() + servletPath;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title><%=titulo%></title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- ✅ DataTables + Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/datatables.net-bs5@1.13.8/css/dataTables.bootstrap5.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/datatables.net-responsive-bs5@2.5.0/css/responsive.bootstrap5.min.css" rel="stylesheet">

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <!-- ✅ jQuery requerido por DataTables -->
    <script src="https://cdn.jsdelivr.net/npm/jquery@3.7.1/dist/jquery.min.js"></script>

    <!-- ✅ DataTables JS -->
    <script src="https://cdn.jsdelivr.net/npm/datatables.net@1.13.8/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/datatables.net-bs5@1.13.8/js/dataTables.bootstrap5.min.js"></script>

    <!-- ✅ Responsive -->
    <script src="https://cdn.jsdelivr.net/npm/datatables.net-responsive@2.5.0/js/dataTables.responsive.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/datatables.net-responsive-bs5@2.5.0/js/responsive.bootstrap5.min.js"></script>
</head>
<body class="bg-light">

<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 class="mb-0"><%=titulo%></h3>
        <a href="<%=request.getContextPath()%>/home" class="btn btn-secondary">Regresar</a>
    </div>

    <div class="card shadow-sm">
        <div class="card-body">

            <!-- FILTROS -->
            <div class="row g-2 align-items-end mb-3">
                <div class="col-12 col-md-3">
                    <label class="form-label mb-1">Desde</label>
                    <input type="date" class="form-control" id="desde">
                </div>

                <div class="col-12 col-md-3">
                    <label class="form-label mb-1">Hasta</label>
                    <input type="date" class="form-control" id="hasta">
                </div>

                <div class="col-12 col-md-2">
                    <button type="button" class="btn btn-primary w-100" id="btnFiltrar">
                        Filtrar
                    </button>
                </div>

                <div class="col-12 col-md-2">
                    <button type="button" class="btn btn-outline-secondary w-100" id="btnLimpiar">
                        Limpiar
                    </button>
                </div>

                <div class="col-12 col-md-2">
                    <button type="button" class="btn btn-success w-100" id="btnExcel" disabled>
                        Exportar Excel
                    </button>
                </div>
            </div>

            <!-- TABLA -->
            <div class="table-responsive">
                <table class="table table-bordered table-striped align-middle mb-0 nowrap" id="tblRpt" style="width:100%">
                    <thead class="table-dark">
                        <tr>
                            <th>DOC_MATERIAL</th>
                            <th>CODIGO_SAP</th>
                            <th>PRODUCTO</th>
                            <th class="text-center">ENVIADO</th>
                            <th class="text-center">RECIBIDO</th>
                            <th>FARMACIA</th>
                            <th>INCIDENCIA</th>
                            <th>OBSERVACION</th>
                            <th>FECHA_SCAN</th>
                        </tr>
                    </thead>

                    <!-- ✅ IMPORTANTE: tbody vacío (sin colspan) -->
                    <tbody id="tbodyRpt"></tbody>
                </table>
            </div>

        </div>
    </div>
</div>

<script>
(function () {
    const endpoint = "<%=endpoint%>";
    const titulo = "<%=titulo%>";

    function esc(v) {
        if (v === null || v === undefined) return "";
        return String(v)
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll("'", "&#039;");
    }

    function nombreArchivo() {
        const safeTitle = titulo.replaceAll(" ", "_").replaceAll("-", "_");
        const hoy = new Date();
        const yyyy = hoy.getFullYear();
        const mm = String(hoy.getMonth() + 1).padStart(2, "0");
        const dd = String(hoy.getDate()).padStart(2, "0");
        return safeTitle + "_" + yyyy + "-" + mm + "-" + dd + ".xls";
    }

    // ✅ DataTables (una sola vez)
    const dt = $("#tblRpt").DataTable({
        responsive: true,
        autoWidth: false,
        processing: true,
        pageLength: 10,
        lengthMenu: [10, 25, 50, 100],
        order: [],
        language: {
            url: "https://cdn.datatables.net/plug-ins/1.13.8/i18n/es-ES.json",
            processing: "Cargando..."
        },
        columnDefs: [
            { targets: [3,4], className: "text-center" }
        ]
    });

    function renderDataTable(data) {
        const rows = (data || []).map(r => ([
            esc(r.doc_material),
            esc(r.codigo_sap),
            esc(r.producto),
            esc(r.enviado),
            esc(r.recibido),
            esc(r.farmacia),
            esc(r.incidencia),
            esc(r.observacion),
            esc(r.fecha_scan)
        ]));

        dt.clear();
        dt.rows.add(rows);
        dt.draw();

        document.getElementById("btnExcel").disabled = (rows.length === 0);
    }

    function exportarExcel() {
        // Exporta lo filtrado en DataTables (buscador + filtros)
        const dataFiltrada = dt.rows({ search: "applied" }).data().toArray();

        if (!dataFiltrada || dataFiltrada.length === 0) {
            Swal.fire("Sin datos", "No hay registros para exportar (según filtros/búsqueda).", "info");
            return;
        }

        let html = '';
        html += '<table border="1">';
        html += '<thead><tr>'
            + '<th>DOC_MATERIAL</th>'
            + '<th>CODIGO_SAP</th>'
            + '<th>PRODUCTO</th>'
            + '<th>ENVIADO</th>'
            + '<th>RECIBIDO</th>'
            + '<th>FARMACIA</th>'
            + '<th>INCIDENCIA</th>'
            + '<th>OBSERVACION</th>'
            + '<th>FECHA_SCAN</th>'
            + '</tr></thead>';
        html += '<tbody>';

        dataFiltrada.forEach(function (row) {
            html += '<tr>'
                + '<td>' + row[0] + '</td>'
                + '<td>' + row[1] + '</td>'
                + '<td>' + row[2] + '</td>'
                + '<td>' + row[3] + '</td>'
                + '<td>' + row[4] + '</td>'
                + '<td>' + row[5] + '</td>'
                + '<td>' + row[6] + '</td>'
                + '<td>' + row[7] + '</td>'
                + '<td>' + row[8] + '</td>'
                + '</tr>';
        });

        html += '</tbody></table>';

        const blob = new Blob(
            ['\ufeff' + html],
            { type: 'application/vnd.ms-excel;charset=utf-8;' }
        );

        const link = document.createElement("a");
        link.href = URL.createObjectURL(blob);
        link.download = nombreArchivo();
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    function setLoading(on) {
        // “processing” de DT se controla internamente, pero esto ayuda UX
        document.getElementById("btnFiltrar").disabled = on;
        document.getElementById("btnLimpiar").disabled = on;
        document.getElementById("btnExcel").disabled = on || (dt.rows().count() === 0);
    }

    function cargar() {
        const desde = document.getElementById("desde").value;
        const hasta = document.getElementById("hasta").value;

        if (desde && hasta && desde > hasta) {
            Swal.fire("Rango inválido", "La fecha DESDE no puede ser mayor que HASTA.", "warning");
            return;
        }

        setLoading(true);
        dt.clear().draw(); // ✅ sin filas “colspan”

        const body = new URLSearchParams();
        if (desde) body.append("desde", desde);
        if (hasta) body.append("hasta", hasta);

        fetch(endpoint, {
            method: "POST",
            headers: {"Content-Type": "application/x-www-form-urlencoded"},
            body: body.toString()
        })
        .then(function (r) {
            return r.text().then(function (txt) {
                return {
                    status: r.status,
                    text: txt,
                    contentType: r.headers.get("content-type") || ""
                };
            });
        })
        .then(function (resp) {
            if (resp.contentType.indexOf("application/json") === -1) {
                console.log("Respuesta NO JSON:", resp);
                Swal.fire("Respuesta no válida (" + resp.status + ")", resp.text.substring(0, 300), "error");
                renderDataTable([]);
                return;
            }

            let json = null;
            try { json = JSON.parse(resp.text); } catch (e) { json = null; }

            if (!json) {
                Swal.fire("Error", "No se pudo parsear JSON.", "error");
                console.log(resp.text);
                renderDataTable([]);
                return;
            }

            if (json.status === "logout") {
                Swal.fire("Sesión expirada", json.message || "Inicia sesión nuevamente.", "warning")
                    .then(function () {
                        window.location.href = "<%=request.getContextPath()%>/login";
                    });
                return;
            }

            if (json.status === "error") {
                Swal.fire("Error", json.message || "Ocurrió un error.", "error");
                renderDataTable([]);
                return;
            }

            // ✅ llenar inputs con rango aplicado por el servlet (mes actual por defecto)
            if (json.desde_aplicado && !document.getElementById("desde").value) {
                document.getElementById("desde").value = json.desde_aplicado;
            }
            if (json.hasta_aplicado && !document.getElementById("hasta").value) {
                document.getElementById("hasta").value = json.hasta_aplicado;
            }

            if (json.status === "empty") {
                renderDataTable([]);
                return;
            }

            if (json.status === "success") {
                renderDataTable(json.data || []);
                return;
            }

            renderDataTable([]);
        })
        .catch(function (err) {
            console.error(err);
            Swal.fire("Error", "No se pudo consultar el reporte.", "error");
            renderDataTable([]);
        })
        .finally(function () {
            setLoading(false);
        });
    }

    document.getElementById("btnFiltrar").addEventListener("click", cargar);

    document.getElementById("btnLimpiar").addEventListener("click", function () {
        document.getElementById("desde").value = "";
        document.getElementById("hasta").value = "";
        cargar();
    });

    document.getElementById("btnExcel").addEventListener("click", exportarExcel);

    // Carga inicial
    cargar();
})();
</script>

</body>
</html>
