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
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Reportes</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.datatables.net/1.13.8/css/dataTables.bootstrap5.min.css" rel="stylesheet">

  <style>
    body { background:#f6f7fb; }
    .card { border:0; border-radius:16px; }
    .chart-wrap { position: relative; min-height: 320px; }
    canvas { max-height: 420px; }
    .mono { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono","Courier New", monospace; }
  </style>
</head>
<body>

<div class="container py-4">

  <%
    String msgType = (String) request.getAttribute("msgType");
    String msg = (String) request.getAttribute("msg");

    String tab = (String) request.getAttribute("tab");
    if (tab == null || tab.trim().isEmpty()) tab = "rpt1";

    String desde = (String) request.getAttribute("desde");
    String hasta = (String) request.getAttribute("hasta");
    Integer top = (Integer) request.getAttribute("top");
    Integer idUsuario = (Integer) request.getAttribute("idUsuario");

    if (desde == null) desde = "";
    if (hasta == null) hasta = "";
    if (top == null) top = 20;

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
    
    List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
    if (usuarios == null) usuarios = new ArrayList<>();
    Integer horaMin = (Integer) request.getAttribute("horaMin");
    Integer horaMax = (Integer) request.getAttribute("horaMax");
    if (horaMin == null) horaMin = 0;
    if (horaMax == null) horaMax = 23;
  %>

  <div class="d-flex align-items-center justify-content-between mb-3">
    <div>
      <h4 class="mb-0">Reportes</h4>
      <div class="text-muted">Productividad e incidencias (con tablas + gráficos exportables).</div>
    </div>
    <a class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/MenuPrincipal">Regresar</a>
  </div>

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
          <label class="form-label fw-semibold">Top</label>
          <input type="number" min="1" step="1" class="form-control" id="top" value="<%=top%>">
        </div>
<div class="col-md-2">
  <label class="form-label fw-semibold">Hora min</label>
  <input type="number" min="0" max="23" step="1" class="form-control" id="horaMin" value="<%=horaMin%>">
</div>

<div class="col-md-2">
  <label class="form-label fw-semibold">Hora max</label>
  <input type="number" min="0" max="23" step="1" class="form-control" id="horaMax" value="<%=horaMax%>">
</div>

<div class="col-md-3">
  <label class="form-label fw-semibold">Usuario</label>
  <select class="form-select" id="idUsuario">
    <option value="">Todos</option>
    <% for (Usuario u : usuarios) { %>
      <option value="<%=u.getIdUsuario()%>"
        <%= (idUsuario != null && idUsuario.equals(u.getIdUsuario())) ? "selected" : "" %>>
        <%=u.getNombre()%> (<%=u.getCodigo()%>)
      </option>
    <% } %>
  </select>
</div>
        <div class="col-md-2 d-grid">
          <button class="btn btn-outline-primary" type="button" id="btnSync">Aplicar a tab actual</button>
        </div>
      </div>
      <div class="form-text mt-2">
        Tip: Elegí el tab y luego “Aplicar”. (Los reportes 2–4 usan <b>Top</b>; el 1 usa <b>ID Usuario</b> opcional).
      </div>
    </div>
  </div>

  <!-- Tabs -->
  <ul class="nav nav-tabs mb-3" id="tabsReportes">
    <li class="nav-item">
      <button class="nav-link <%= "rpt1".equals(tab) ? "active" : "" %>" data-bs-toggle="tab" data-bs-target="#rpt1" type="button">1) Productividad</button>
    </li>
    <li class="nav-item">
      <button class="nav-link <%= "rpt2".equals(tab) ? "active" : "" %>" data-bs-toggle="tab" data-bs-target="#rpt2" type="button">2) Guías con incidencia</button>
    </li>
    <li class="nav-item">
      <button class="nav-link <%= "rpt3".equals(tab) ? "active" : "" %>" data-bs-toggle="tab" data-bs-target="#rpt3" type="button">3) Farmacias con incidencia</button>
    </li>
    <li class="nav-item">
      <button class="nav-link <%= "rpt4".equals(tab) ? "active" : "" %>" data-bs-toggle="tab" data-bs-target="#rpt4" type="button">4) Incidencias frecuentes</button>
    </li>
  </ul>

  <div class="tab-content">

    <!-- RPT1 -->
    <div class="tab-pane fade <%= "rpt1".equals(tab) ? "show active" : "" %>" id="rpt1">
      <div class="card shadow-sm mb-3">
        <div class="card-body p-4">
          <div class="d-flex justify-content-between align-items-center mb-3">
            <h6 class="mb-0">Productividad por día/hora/usuario</h6>
            <div class="d-flex gap-2">
              <button class="btn btn-sm btn-outline-success" type="button" onclick="exportChartPNG(chart1,'productividad.png')">Exportar PNG</button>
              <button class="btn btn-sm btn-outline-danger" type="button" onclick="exportChartPDF(chart1,'productividad.pdf')">Exportar PDF</button>
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
                  <td class="mono"><%= r.getFecha() %></td>
                  <td class="mono"><%= r.getHora() %></td>
                  <td class="mono"><%= r.getIdUsuario() %></td>
                  <td><%= r.getNombre() %></td>
                  <td class="text-end"><%= r.getTotalEscaneos() %></td>
                  <td class="text-end"><%= r.getTotalCantidad() %></td>
                  <td class="text-end"><%= r.getConIncidencia() %></td>
                  <td class="text-end"><%= r.getSinIncidencia() %></td>
                </tr>
              <% } %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- RPT2 -->
    <div class="tab-pane fade <%= "rpt2".equals(tab) ? "show active" : "" %>" id="rpt2">
      <div class="card shadow-sm mb-3">
        <div class="card-body p-4">
          <div class="d-flex justify-content-between align-items-center mb-3">
            <h6 class="mb-0">Guías con mayor incidencia (Top)</h6>
            <div class="d-flex gap-2">
              <button class="btn btn-sm btn-outline-success" type="button" onclick="exportChartPNG(chart2,'guias_incidencia.png')">Exportar PNG</button>
              <button class="btn btn-sm btn-outline-danger" type="button" onclick="exportChartPDF(chart2,'guias_incidencia.pdf')">Exportar PDF</button>
            </div>
          </div>
          <div class="chart-wrap">
            <canvas id="chart2"></canvas>
          </div>
        </div>
      </div>

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
                  <td class="mono"><%= r.getDocMaterial() %></td>
                  <td class="text-end"><%= r.getTotalRegistros() %></td>
                  <td class="text-end"><%= r.getTotalIncidencias() %></td>
                  <td class="text-end"><%= r.getPorcIncidencia() %></td>
                </tr>
              <% } %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- RPT3 -->
    <div class="tab-pane fade <%= "rpt3".equals(tab) ? "show active" : "" %>" id="rpt3">
      <div class="card shadow-sm mb-3">
        <div class="card-body p-4">
          <div class="d-flex justify-content-between align-items-center mb-3">
            <h6 class="mb-0">Farmacias con mayor incidencia (Top)</h6>
            <div class="d-flex gap-2">
              <button class="btn btn-sm btn-outline-success" type="button" onclick="exportChartPNG(chart3,'farmacias_incidencia.png')">Exportar PNG</button>
              <button class="btn btn-sm btn-outline-danger" type="button" onclick="exportChartPDF(chart3,'farmacias_incidencia.pdf')">Exportar PDF</button>
            </div>
          </div>
          <div class="chart-wrap">
            <canvas id="chart3"></canvas>
          </div>
        </div>
      </div>

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
                  <td><%= r.getFarmacia() %></td>
                  <td class="text-end"><%= r.getTotalRegistros() %></td>
                  <td class="text-end"><%= r.getTotalIncidencias() %></td>
                </tr>
              <% } %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- RPT4 -->
    <div class="tab-pane fade <%= "rpt4".equals(tab) ? "show active" : "" %>" id="rpt4">
      <div class="card shadow-sm mb-3">
        <div class="card-body p-4">
          <div class="d-flex justify-content-between align-items-center mb-3">
            <h6 class="mb-0">Incidencias más frecuentes (Top)</h6>
            <div class="d-flex gap-2">
              <button class="btn btn-sm btn-outline-success" type="button" onclick="exportChartPNG(chart4,'incidencias_top.png')">Exportar PNG</button>
              <button class="btn btn-sm btn-outline-danger" type="button" onclick="exportChartPDF(chart4,'incidencias_top.pdf')">Exportar PDF</button>
            </div>
          </div>
          <div class="chart-wrap">
            <canvas id="chart4"></canvas>
          </div>
        </div>
      </div>

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
                  <td class="mono"><%= r.getIncidenciaId() %></td>
                  <td><%= r.getIncidencia() %></td>
                  <td class="text-end"><%= r.getTotal() %></td>
                </tr>
              <% } %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

  </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/dataTables.bootstrap5.min.js"></script>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/jspdf@2.5.1/dist/jspdf.umd.min.js"></script>
<script src="<%=request.getContextPath()%>/js/sweetalert2.js"></script>

<script>
  // DataTables
  $(function(){
    ["t1","t2","t3","t4"].forEach(id=>{
      const el = document.getElementById(id);
      if(!el) return;
      $("#"+id).DataTable({
        ordering:true,
        pageLength:10,
        order:[],
        scrollX:true,
        autoWidth:false,
        language:{ url: "<%=request.getContextPath()%>/js/es-ES.json" }
      });
    });
  });

  // Exportar gráfico a PNG
  function exportChartPNG(chart, filename){
    if(!chart) return;
    const a = document.createElement("a");
    a.href = chart.toBase64Image();
    a.download = filename;
    a.click();
  }

  // Exportar gráfico a PDF (usando PNG)
  function exportChartPDF(chart, filename){
    if(!chart) return;
    const { jsPDF } = window.jspdf;
    const pdf = new jsPDF({orientation:"landscape", unit:"pt", format:"a4"});
    const img = chart.toBase64Image();
    const w = pdf.internal.pageSize.getWidth();
    const h = pdf.internal.pageSize.getHeight();
    pdf.addImage(img, "PNG", 30, 30, w-60, h-60);
    pdf.save(filename);
  }

  // Helper: enviar POST al servlet según tab
  function postReporte(accion){
    const form = document.createElement("form");
    form.method = "post";
    form.action = "<%=request.getContextPath()%>/Reportes";

    const fields = {
      accion: accion,
      desde: document.getElementById("desde").value,
      hasta: document.getElementById("hasta").value,
      top: document.getElementById("top").value,
      horaMin: document.getElementById("horaMin").value,
        horaMax: document.getElementById("horaMax").value,
      idUsuario: document.getElementById("idUsuario").value
    };

    Object.keys(fields).forEach(k=>{
      const inp = document.createElement("input");
      inp.type = "hidden";
      inp.name = k;
      inp.value = fields[k] || "";
      form.appendChild(inp);
    });

    document.body.appendChild(form);
    form.submit();
  }

  document.getElementById("btnSync").addEventListener("click", function(){
    // Detectar tab activo
    const activeBtn = document.querySelector("#tabsReportes .nav-link.active");
    const target = activeBtn ? activeBtn.getAttribute("data-bs-target") : "#rpt1";
    const tab = (target || "#rpt1").replace("#",""); // rpt1..rpt4
    postReporte(tab); // accion = rpt1..rpt4
  });

  // ---------------- Charts datasets desde JSP ----------------

  // Reporte 1: agrupamos por "fecha hora" y total
  const labels1 = [
    <% for (int i=0; i<data1.size(); i++) {
         RptProductividadDiaHoraUsuario r = data1.get(i);
         String lab = r.getFecha()+" "+String.format("%02d", r.getHora())+":00"+" - "+r.getNombre();
    %>
      "<%=lab%>"<%= (i < data1.size()-1 ? "," : "") %>
    <% } %>
  ];
  const values1 = [
    <% for (int i=0; i<data1.size(); i++) { %>
      <%= data1.get(i).getTotalEscaneos() %><%= (i < data1.size()-1 ? "," : "") %>
    <% } %>
  ];

  // Reporte 2
  const labels2 = [
    <% for (int i=0; i<data2.size(); i++) { %>
      "<%= data2.get(i).getDocMaterial() %>"<%= (i < data2.size()-1 ? "," : "") %>
    <% } %>
  ];
  const values2 = [
    <% for (int i=0; i<data2.size(); i++) { %>
      <%= data2.get(i).getTotalIncidencias() %><%= (i < data2.size()-1 ? "," : "") %>
    <% } %>
  ];

  // Reporte 3
  const labels3 = [
    <% for (int i=0; i<data3.size(); i++) { %>
      "<%= data3.get(i).getFarmacia().replace("\"","\\\"") %>"<%= (i < data3.size()-1 ? "," : "") %>
    <% } %>
  ];
  const values3 = [
    <% for (int i=0; i<data3.size(); i++) { %>
      <%= data3.get(i).getTotalIncidencias() %><%= (i < data3.size()-1 ? "," : "") %>
    <% } %>
  ];

  // Reporte 4
  const labels4 = [
    <% for (int i=0; i<data4.size(); i++) { %>
      "<%= data4.get(i).getIncidencia().replace("\"","\\\"") %>"<%= (i < data4.size()-1 ? "," : "") %>
    <% } %>
  ];
  const values4 = [
    <% for (int i=0; i<data4.size(); i++) { %>
      <%= data4.get(i).getTotal() %><%= (i < data4.size()-1 ? "," : "") %>
    <% } %>
  ];

  // Crear charts (sin fijar colores; Chart.js usa defaults)
  let chart1=null, chart2=null, chart3=null, chart4=null;

  function buildCharts(){
    const c1 = document.getElementById("chart1");
    if(c1){
      chart1 = new Chart(c1, {
        type: "bar",
        data: { labels: labels1, datasets: [{ label: "Total registros", data: values1 }]},
        options: { responsive:true, plugins:{ legend:{ display:true }}, scales:{ x:{ ticks:{ maxRotation: 90, minRotation: 45 } } } }
      });
    }
    const c2 = document.getElementById("chart2");
    if(c2){
      chart2 = new Chart(c2, {
        type: "bar",
        data: { labels: labels2, datasets: [{ label: "Incidencias", data: values2 }]},
        options: { responsive:true, plugins:{ legend:{ display:true }}, scales:{ x:{ ticks:{ maxRotation: 90, minRotation: 45 } } } }
      });
    }
    const c3 = document.getElementById("chart3");
    if(c3){
      chart3 = new Chart(c3, {
        type: "bar",
        data: { labels: labels3, datasets: [{ label: "Incidencias", data: values3 }]},
        options: { responsive:true, plugins:{ legend:{ display:true }}, scales:{ x:{ ticks:{ maxRotation: 90, minRotation: 45 } } } }
      });
    }
    const c4 = document.getElementById("chart4");
    if(c4){
      chart4 = new Chart(c4, {
        type: "bar",
        data: { labels: labels4, datasets: [{ label: "Total", data: values4 }]},
        options: { responsive:true, plugins:{ legend:{ display:true }}, scales:{ x:{ ticks:{ maxRotation: 90, minRotation: 45 } } } }
      });
    }
  }

  document.addEventListener("DOMContentLoaded", buildCharts);
</script>

</body>
</html>
