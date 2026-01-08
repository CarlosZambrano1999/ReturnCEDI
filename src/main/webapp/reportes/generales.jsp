<%-- 
    Document   : devoluciones
    Created on : 22 dic 2025, 08:43:15
    Author     : Administrador
--%>

<%@page import="modelos.Usuario"%>
<%@page import="modelos.reportes.RptIncidenciasMasFrecuentes"%>
<%@page import="modelos.reportes.RptFarmaciasMayorIncidencia"%>
<%@page import="java.util.ArrayList"%>
<%@page import="modelos.reportes.RptGuiasMayorIncidencia"%>
<%@page import="java.util.List"%>
<%@page import="modelos.reportes.RptProductividadDiaHoraUsuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    
                <%
                String msgType = (String) request.getAttribute("msgType");
                String msg = (String) request.getAttribute("msg");

                String tab = (String) request.getAttribute("tab");
                if (tab == null || tab.trim().isEmpty()) tab = "rpt1";

                String desde = (String) request.getAttribute("desde");
                String hasta = (String) request.getAttribute("hasta");

                Integer horaMin = (Integer) request.getAttribute("horaMin");
                Integer horaMax = (Integer) request.getAttribute("horaMax");

                Integer idUsuario = (Integer) request.getAttribute("idUsuario");

                if (desde == null) desde = "";
                if (hasta == null) hasta = "";
                if (horaMin == null) horaMin = 0;
                if (horaMax == null) horaMax = 23;

                List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
                if (usuarios == null) usuarios = new ArrayList<>();

                List<RptProductividadDiaHoraUsuario> data1 =
                        (List<RptProductividadDiaHoraUsuario>) request.getAttribute("data1");
                if (data1 == null) data1 = new ArrayList<>();

                List<RptGuiasMayorIncidencia> data2 =
                        (List<RptGuiasMayorIncidencia>) request.getAttribute("data2");
                if (data2 == null) data2 = new ArrayList<>();

                List<RptFarmaciasMayorIncidencia> data3 =
                        (List<RptFarmaciasMayorIncidencia>) request.getAttribute("data3");
                if (data3 == null) data3 = new ArrayList<>();

                List<RptIncidenciasMasFrecuentes> data4 =
                        (List<RptIncidenciasMasFrecuentes>) request.getAttribute("data4");
                if (data4 == null) data4 = new ArrayList<>();

                // ---------------- KPIs ----------------
                int kpiTotalEscaneos = 0;
                int kpiTotalCantidad = 0;
                int kpiTotalIncidencias = 0;

                for (RptProductividadDiaHoraUsuario r : data1) {
                    kpiTotalEscaneos += (r.getTotalEscaneos() == null ? 0 : r.getTotalEscaneos());
                    kpiTotalCantidad += (r.getTotalCantidad() == null ? 0 : r.getTotalCantidad());
                    kpiTotalIncidencias += (r.getConIncidencia() == null ? 0 : r.getConIncidencia());
                }

                int kpiGuias = (data2 == null ? 0 : data2.size());

                // line chart agregación por hora
                int[] escPorHora = new int[24];
                int[] cantPorHora = new int[24];
                for (RptProductividadDiaHoraUsuario r : data1) {
                    int h = (r.getHora() == null ? 0 : r.getHora());
                    if (h >= 0 && h <= 23) {
                        escPorHora[h] += (r.getTotalEscaneos() == null ? 0 : r.getTotalEscaneos());
                        cantPorHora[h] += (r.getTotalCantidad() == null ? 0 : r.getTotalCantidad());
                    }
                }
                
                String baseUrl = (String) request.getAttribute("baseUrl");
                

                if (baseUrl == null) baseUrl = request.getContextPath() + "/Reportes/Devoluciones";

                String pageTitle = (String) request.getAttribute("pageTitle");
                if (pageTitle == null) pageTitle = "Dashboard Reportes";

                String pageSubtitle = (String) request.getAttribute("pageSubtitle");
                if (pageSubtitle == null) pageSubtitle = "Reportes";

                String moduloNombre = (String) request.getAttribute("moduloNombre");
                if (moduloNombre == null) moduloNombre = "Módulo";

            %>

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><%= pageTitle %></title>

        <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet">
        <link href="<%=request.getContextPath()%>/css/dataTables.css" rel="stylesheet">
        <link rel="stylesheet" href="<%=request.getContextPath()%>/css/buttons.css">
        <link rel="stylesheet" href="<%=request.getContextPath()%>/reportes/generales.css">

    </head>
    <body>
<jsp:include page="/componentes/navbar.jsp" />
        <div class="container py-4">


            <div class="d-flex align-items-center justify-content-between mb-3">
                <div>
                    <h4 class="mb-0">Dashboard de Reportes</h4>
                    <div class="text-muted"><%= pageSubtitle %></div>
                </div>
                <div class="d-flex gap-2">
                    <a class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/MenuPrincipal">Regresar</a>
                    <a class="btn btn-outline-danger" href="<%= baseUrl %>">Limpiar</a>
                </div>
            </div>

            <!-- SweetAlert2 msg -->
            <% if (msg != null && !msg.trim().isEmpty()) { %>
            <script>
                document.addEventListener("DOMContentLoaded", function(){
                    Swal.fire({
                        icon: "<%= "success".equals(msgType) ? "success" : ("warning".equals(msgType) ? "warning" : "error") %>",
                        title: "<%= "success".equals(msgType) ? "Listo" : ("warning".equals(msgType) ? "Atención" : "Error") %>",
                        text: "<%= msg.replace("\"","\\\"") %>",
                        timer: 2200,
                        showConfirmButton: false
                    });
                });
            </script>
            <% } %>

            <!-- KPI Cards -->
            <div class="row g-3 mb-3">
                <div class="col-md-3">
                    <div class="card shadow-sm kpi-card">
                        <div class="card-body d-flex justify-content-between align-items-center">
                            <div>
                                <div class="text-muted small">Total escaneos</div>
                                <div class="fs-3 fw-bold"><%=kpiTotalEscaneos%></div>
                            </div>
                            <div class="kpi-icon">
                                <span class="fw-bold text-primary">Σ</span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card shadow-sm kpi-card">
                        <div class="card-body d-flex justify-content-between align-items-center">
                            <div>
                                <div class="text-muted small">Total cantidad</div>
                                <div class="fs-3 fw-bold"><%=kpiTotalCantidad%></div>
                            </div>
                            <div class="kpi-icon" style="background: rgba(25,135,84,.12);">
                                <span class="fw-bold text-success">#</span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card shadow-sm kpi-card">
                        <div class="card-body d-flex justify-content-between align-items-center">
                            <div>
                                <div class="text-muted small">Incidencias</div>
                                <div class="fs-3 fw-bold"><%=kpiTotalIncidencias%></div>
                            </div>
                            <div class="kpi-icon" style="background: rgba(220,53,69,.12);">
                                <span class="fw-bold text-danger">!</span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card shadow-sm kpi-card">
                        <div class="card-body d-flex justify-content-between align-items-center">
                            <div>
                                <div class="text-muted small">Guías listadas</div>
                                <div class="fs-3 fw-bold"><%=kpiGuias%></div>
                            </div>
                            <div class="kpi-icon" style="background: rgba(255,193,7,.16);">
                                <span class="fw-bold text-warning">📦</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Filtros -->
            <div class="card shadow-sm mb-3">
                <div class="card-body p-4">
                    <div class="row g-3 align-items-end">

                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Desde</label>
                            <input type="date" class="form-control" id="desde" value="<%=desde%>">
                        </div>

                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Hasta</label>
                            <input type="date" class="form-control" id="hasta" value="<%=hasta%>">
                        </div>

                        <div class="col-md-2">
                            <label class="form-label fw-semibold">Hora min</label>
                            <input type="number" class="form-control" id="horaMin" min="0" max="23" step="1" value="<%=horaMin%>">
                        </div>

                        <div class="col-md-2">
                            <label class="form-label fw-semibold">Hora max</label>
                            <input type="number" class="form-control" id="horaMax" min="0" max="23" step="1" value="<%=horaMax%>">
                        </div>

                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Usuario (Productividad)</label>
                            <select class="form-select" id="idUsuario">
                                <option value="">Todos</option>
                                <% for(Usuario u : usuarios){ %>
                                <option value="<%=u.getIdUsuario()%>"
                                        <%= (idUsuario != null && idUsuario.equals(u.getIdUsuario())) ? "selected" : "" %>>
                                    <%=u.getNombre()%> (<%=u.getCodigo()%>)
                                </option>
                                <% } %>
                            </select>
                        </div>

                        <div class="col-md-4 d-grid">
                            <button class="btn btn-primary" type="button" id="btnAplicar">
                                Generar reporte (tab actual)
                            </button>
                        </div>

                    </div>

                    <div class="form-text mt-2">
                        Top se maneja como <b>MAX</b> automáticamente (sin pedirle al usuario).
                    </div>
                </div>
            </div>

            <!-- Tabs -->
            <ul class="nav nav-tabs mb-3" id="tabsReportes">
                <li class="nav-item">
                    <button class="nav-link <%= "rpt1".equals(tab) ? "active" : "" %>"
                            data-bs-toggle="tab" data-bs-target="#rpt1" type="button">1) Productividad</button>
                </li>
                <li class="nav-item">
                    <button class="nav-link <%= "rpt2".equals(tab) ? "active" : "" %>"
                            data-bs-toggle="tab" data-bs-target="#rpt2" type="button">2) Guías con incidencia</button>
                </li>
                <li class="nav-item">
                    <button class="nav-link <%= "rpt3".equals(tab) ? "active" : "" %>"
                            data-bs-toggle="tab" data-bs-target="#rpt3" type="button">3) Farmacias con incidencia</button>
                </li>
                <li class="nav-item">
                    <button class="nav-link <%= "rpt4".equals(tab) ? "active" : "" %>"
                            data-bs-toggle="tab" data-bs-target="#rpt4" type="button">4) Incidencias frecuentes</button>
                </li>
            </ul>

            <div class="tab-content">

                <!-- RPT1 -->
                <div class="tab-pane fade <%= "rpt1".equals(tab) ? "show active" : "" %>" id="rpt1">
                    <div class="card shadow-sm mb-3">
                        <div class="card-body p-4">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h6 class="mb-0">Productividad por hora (Line)</h6>
                                <div class="d-flex gap-2">
                                    <button class="btn btn-sm btn-outline-success" type="button"
                                            onclick="exportChartPNG(chart1,'productividad.png')">PNG</button>
                                    <button class="btn btn-sm btn-outline-danger" type="button"
                                            onclick="exportChartPDF(chart1,'productividad.pdf')">PDF</button>
                                </div>
                            </div>
                            <div class="chart-wrap">
                                <canvas id="chart1"></canvas>
                            </div>
                        </div>
                    </div>

                    <div class="card shadow-sm">
                        <div class="card-body p-4">
                            <div class="table-responsive">
                                <table id="t1" class="table table-hover align-middle w-100">
                                    <thead>
                                        <tr>
                                            <th>Fecha</th>
                                            <th>Hora</th>
                                            <th>ID Usuario</th>
                                            <th>Nombre</th>
                                            <th class="text-end">Total escaneos</th>
                                            <th class="text-end">Total cantidad</th>
                                            <th class="text-end">Con incidencia</th>
                                            <th class="text-end">Sin incidencia</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (RptProductividadDiaHoraUsuario r : data1) { %>
                                        <tr>
                                            <td class="mono"><%= r.getFecha()%></td>
                                            <td class="mono"><%= String.format("%02d", r.getHora())%>:00</td>
                                            <td class="mono"><%= r.getIdUsuario()%></td>
                                            <td><%= r.getNombre()%></td>
                                            <td class="text-end"><%= r.getTotalEscaneos()%></td>
                                            <td class="text-end"><%= r.getTotalCantidad()%></td>
                                            <td class="text-end"><%= r.getConIncidencia()%></td>
                                            <td class="text-end"><%= r.getSinIncidencia()%></td>
                                        </tr>
                                        <% }%>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- RPT2 -->
                <div class="tab-pane fade <%= "rpt2".equals(tab) ? "show active" : "" %>" id="rpt2">
                    <div class="card shadow-sm">
                        <div class="card-body p-4">
                            <div class="table-responsive">
                                <table id="t2" class="table table-hover align-middle w-100">
                                    <thead>
                                        <tr>
                                            <th>Doc.Material</th>
                                            <th class="text-end">Registros</th>
                                            <th class="text-end">Incidencias</th>
                                            <th class="text-end">% Incidencia</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (RptGuiasMayorIncidencia r : data2) { %>
                                        <tr>
                                            <td class="mono"><%= r.getDocMaterial()%></td>
                                            <td class="text-end"><%= r.getTotalRegistros()%></td>
                                            <td class="text-end"><%= r.getTotalIncidencias()%></td>
                                            <td class="text-end"><%= r.getPorcIncidencia()%></td>
                                        </tr>
                                        <% }%>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- RPT3 -->
                <div class="tab-pane fade <%= "rpt3".equals(tab) ? "show active" : "" %>" id="rpt3">
                    <div class="card shadow-sm">
                        <div class="card-body p-4">
                            <div class="table-responsive">
                                <table id="t3" class="table table-hover align-middle w-100">
                                    <thead>
                                        <tr>
                                            <th>Farmacia</th>
                                            <th class="text-end">Registros</th>
                                            <th class="text-end">Incidencias</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (RptFarmaciasMayorIncidencia r : data3) { %>
                                        <tr>
                                            <td><%= r.getFarmacia()%></td>
                                            <td class="text-end"><%= r.getTotalRegistros()%></td>
                                            <td class="text-end"><%= r.getTotalIncidencias()%></td>
                                        </tr>
                                        <% }%>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- RPT4 -->
                <div class="tab-pane fade <%= "rpt4".equals(tab) ? "show active" : "" %>" id="rpt4">
                    <div class="card shadow-sm">
                        <div class="card-body p-4">
                            <div class="table-responsive">
                                <table id="t4" class="table table-hover align-middle w-100">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Incidencia</th>
                                            <th class="text-end">Total</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% for (RptIncidenciasMasFrecuentes r : data4) { %>
                                        <tr>
                                            <td class="mono"><%= r.getIncidenciaId()%></td>
                                            <td><%= r.getIncidencia()%></td>
                                            <td class="text-end"><%= r.getTotal()%></td>
                                        </tr>
                                        <% }%>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

            </div><!-- tab content -->

        </div><!-- container -->

        <!-- JS -->
        <script src="<%=request.getContextPath()%>/js/jquery.js"></script>
        <script src="<%=request.getContextPath()%>/js/bundle.js"></script>

        <!-- DataTables -->
        <script src="<%=request.getContextPath()%>/js/jqueryDataTables.js"></script>
        <script src="<%=request.getContextPath()%>/js/dataTablesBootstrap.js"></script>

        <!-- DataTables Buttons -->
        <script src="<%=request.getContextPath()%>/js/dataTableButtons.js"></script>
        <script src="<%=request.getContextPath()%>/js/buttonsBootstrap.js"></script>
        <script src="<%=request.getContextPath()%>/js/jszip.js"></script>
        <script src="<%=request.getContextPath()%>/js/buttonshtml5.js"></script>
        <script src="<%=request.getContextPath()%>/js/buttonsprint.js"></script>

        <!-- Chart.js + jsPDF -->
        <script src="<%=request.getContextPath()%>/js/chart.js"></script>
        <script src="<%=request.getContextPath()%>/js/jspdf.js"></script>
        <script src="<%=request.getContextPath()%>/js/sweetalert2.js"></script>

        <script>
            // DataTables with export
            $(function () {
                ["t1", "t2", "t3", "t4"].forEach(id => {
                    const el = document.getElementById(id);
                    if (!el) return;

                    $("#" + id).DataTable({
                        ordering: true,
                        pageLength: 10,
                        order: [],
                        scrollX: true,
                        autoWidth: false,
                        dom: 'Bfrtip',
                        buttons: [
                            {extend: 'csvHtml5', text: 'CSV'},
                            {extend: 'excelHtml5', text: 'Excel'},
                            {extend: 'print', text: 'Imprimir'}
                        ],
                        language: {
                            url: '<%=request.getContextPath()%>/js/es-ES.json'
                        }
                    });
                });
            });

            // Export chart PNG/PDF
            function exportChartPNG(chart, filename) {
                if (!chart) return;
                const a = document.createElement("a");
                a.href = chart.toBase64Image();
                a.download = filename;
                a.click();
            }

            function exportChartPDF(chart, filename) {
                if (!chart) return;
                const {jsPDF} = window.jspdf;
                const pdf = new jsPDF({orientation: "landscape", unit: "pt", format: "a4"});
                const img = chart.toBase64Image();
                const w = pdf.internal.pageSize.getWidth();
                const h = pdf.internal.pageSize.getHeight();
                pdf.addImage(img, "PNG", 30, 30, w - 60, h - 60);
                pdf.save(filename);
            }

            // Post Report (actions)
            function postReporte(accion) {
                const form = document.createElement("form");
                form.method = "post";
                form.action = "<%= baseUrl %>";

                const fields = {
                    accion: accion,
                    desde: document.getElementById("desde").value,
                    hasta: document.getElementById("hasta").value,
                    horaMin: document.getElementById("horaMin").value,
                    horaMax: document.getElementById("horaMax").value,
                    idUsuario: document.getElementById("idUsuario").value
                    // TOP ya no se usa, es MAX por defecto en el servlet
                };

                Object.keys(fields).forEach(k => {
                    const inp = document.createElement("input");
                    inp.type = "hidden";
                    inp.name = k;
                    inp.value = fields[k] || "";
                    form.appendChild(inp);
                });

                document.body.appendChild(form);
                form.submit();
            }

            document.getElementById("btnAplicar").addEventListener("click", function () {
                const activeBtn = document.querySelector("#tabsReportes .nav-link.active");
                const target = activeBtn ? activeBtn.getAttribute("data-bs-target") : "#rpt1";
                const tab = (target || "#rpt1").replace("#", "");
                postReporte(tab); // accion=rpt1..rpt4
            });

            // Chart 1 - Line por hora
            const labelsHoras = Array.from({length: 24}, (_, i) => (i < 10 ? "0" + i : i) + ":00");

            const dataEsc = [
            <% for(int i=0;i<24;i++){ %>
                <%=escPorHora[i]%><%= (i<23?",":"") %>
            <% } %>
            ];

            const dataCant = [
            <% for(int i=0;i<24;i++){ %>
                <%=cantPorHora[i]%><%= (i<23?",":"") %>
            <% } %>
            ];

            let chart1 = null;

            document.addEventListener("DOMContentLoaded", function () {
                const c1 = document.getElementById("chart1");
                if (c1) {
                    chart1 = new Chart(c1, {
                        type: "line",
                        data: {
                            labels: labelsHoras,
                            datasets: [
                                {label: "Escaneos", data: dataEsc, tension: 0.25},
                                {label: "Cantidad", data: dataCant, tension: 0.25}
                            ]
                        },
                        options: {
                            responsive: true,
                            plugins: {legend: {display: true}},
                            scales: {y: {beginAtZero: true}}
                        }
                    });
                }
            });
        </script>

    </body>
</html>