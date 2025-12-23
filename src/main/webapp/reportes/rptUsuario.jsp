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
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
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
                <table class="table table-bordered table-striped align-middle mb-0" id="tblRpt">
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
                    <tbody id="tbodyRpt">
                        <tr>
                            <td colspan="9" class="text-center text-muted">Cargando...</td>
                        </tr>
                    </tbody>
                </table>
            </div>

        </div>
    </div>
</div>

<script>
(function () {
    const endpoint = "<%=endpoint%>";
    const titulo = "<%=titulo%>";

    // Guardamos la última data cargada para exportar
    let lastData = [];

    function esc(v) {
        if (v === null || v === undefined) return "";
        return String(v)
            .replaceAll("&", "&amp;")
            .replaceAll("<", "&lt;")
            .replaceAll(">", "&gt;")
            .replaceAll('"', "&quot;")
            .replaceAll("'", "&#039;");
    }

    function renderRows(data) {
        const tbody = document.getElementById("tbodyRpt");
        tbody.innerHTML = "";

        if (!data || data.length === 0) {
            tbody.innerHTML =
                '<tr><td colspan="9" class="text-center text-muted">Sin registros</td></tr>';
            return;
        }

        let html = "";
        data.forEach(function (r) {
            html += '<tr>'
                + '<td>' + esc(r.doc_material) + '</td>'
                + '<td>' + esc(r.codigo_sap) + '</td>'
                + '<td>' + esc(r.producto) + '</td>'
                + '<td class="text-center">' + esc(r.enviado) + '</td>'
                + '<td class="text-center">' + esc(r.recibido) + '</td>'
                + '<td>' + esc(r.farmacia) + '</td>'
                + '<td>' + esc(r.incidencia) + '</td>'
                + '<td>' + esc(r.observacion) + '</td>'
                + '<td>' + esc(r.fecha_scan) + '</td>'
                + '</tr>';
        });

        tbody.innerHTML = html;
    }

    function nombreArchivo() {
        // titulo: "Reporte - Devoluciones" -> "Reporte_Devoluciones_2025-12-23.xls"
        const safeTitle = titulo.replaceAll(" ", "_").replaceAll("-", "_");
        const hoy = new Date();
        const yyyy = hoy.getFullYear();
        const mm = String(hoy.getMonth() + 1).padStart(2, "0");
        const dd = String(hoy.getDate()).padStart(2, "0");
        return safeTitle + "_" + yyyy + "-" + mm + "-" + dd + ".xls";
    }

    function exportarExcel() {
        if (!lastData || lastData.length === 0) {
            Swal.fire("Sin datos", "No hay registros para exportar.", "info");
            return;
        }

        // Armamos una tabla HTML (Excel la abre como .xls)
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

        lastData.forEach(function (r) {
            html += '<tr>'
                + '<td>' + esc(r.doc_material) + '</td>'
                + '<td>' + esc(r.codigo_sap) + '</td>'
                + '<td>' + esc(r.producto) + '</td>'
                + '<td>' + esc(r.enviado) + '</td>'
                + '<td>' + esc(r.recibido) + '</td>'
                + '<td>' + esc(r.farmacia) + '</td>'
                + '<td>' + esc(r.incidencia) + '</td>'
                + '<td>' + esc(r.observacion) + '</td>'
                + '<td>' + esc(r.fecha_scan) + '</td>'
                + '</tr>';
        });

        html += '</tbody></table>';

        const blob = new Blob(
            ['\ufeff' + html], // BOM para acentos
            { type: 'application/vnd.ms-excel;charset=utf-8;' }
        );

        const link = document.createElement("a");
        link.href = URL.createObjectURL(blob);
        link.download = nombreArchivo();
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

    function cargar() {
        const desde = document.getElementById("desde").value;
        const hasta = document.getElementById("hasta").value;

        if (desde && hasta && desde > hasta) {
            Swal.fire("Rango inválido", "La fecha DESDE no puede ser mayor que HASTA.", "warning");
            return;
        }

        document.getElementById("btnExcel").disabled = true;
        lastData = [];

        document.getElementById("tbodyRpt").innerHTML =
            '<tr><td colspan="9" class="text-center text-muted">Cargando...</td></tr>';

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
                renderRows([]);
                return;
            }

            let json = null;
            try { json = JSON.parse(resp.text); } catch (e) { json = null; }

            if (!json) {
                Swal.fire("Error", "No se pudo parsear JSON.", "error");
                console.log(resp.text);
                renderRows([]);
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
                renderRows([]);
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
                renderRows([]);
                return;
            }

            if (json.status === "success") {
                lastData = json.data || [];
                renderRows(lastData);
                document.getElementById("btnExcel").disabled = (lastData.length === 0);
                return;
            }

            renderRows([]);
        })
        .catch(function (err) {
            console.error(err);
            Swal.fire("Error", "No se pudo consultar el reporte.", "error");
            renderRows([]);
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
