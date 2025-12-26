<%-- 
    Document   : consultarPolitica
    Created on : 18 dic 2025, 09:53:14
    Author     : Administrador
--%>

<%@page import="java.util.ArrayList"%>
<%@page import="modelos.EvaluacionPolitica"%>
<%@page import="modelos.PoliticaDevolucion"%>
<%@page import="modelos.ColorPolitica"%>
<%@page import="modelos.ProveedorPolitica"%>
<%@page import="java.util.List"%>
<%@page import="modelos.Producto"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Consultar Política</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet">
  <script src="<%=request.getContextPath()%>/js/sweetalert2.js"></script>

  <style>
    body { background:#f6f7fb; }
    .card { border:0; border-radius:16px; }
    #scanner { border-width:2px; font-weight:700; }
    .pill {
      display:inline-block; padding:.25rem .6rem; border-radius:999px;
      font-weight:800; font-size:.85rem;
    }
    .pill-ok{ background: rgba(25,135,84,.12); color:#198754; }
    .pill-warn{ background: rgba(255,193,7,.18); color:#b78103; }
    .pill-bad{ background: rgba(220,53,69,.12); color:#dc3545; }
    .pill-info{ background: rgba(13,110,253,.12); color:#0d6efd; }
    .mono { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace; }
  </style>
</head>

<body>
    <jsp:include page="/componentes/navbar.jsp" />
    
    <!-- Spinner global -->
<div id="spinnerBuscar"
     class="d-none position-fixed top-0 start-0 w-100 h-100
            d-flex align-items-center justify-content-center
            bg-white bg-opacity-75"
     style="z-index: 2000;">
  <div class="text-center">
    <div class="spinner-border text-primary" role="status"></div>
    <div class="mt-3 fw-semibold text-muted">Buscando información...</div>
  </div>
</div>

<div class="container py-4">

  <%
    String msgType = (String) request.getAttribute("msgType");
    String msg = (String) request.getAttribute("msg");

    Producto producto = (Producto) request.getAttribute("producto");
    List<ProveedorPolitica> proveedores = (List<ProveedorPolitica>) request.getAttribute("proveedores");
    List<ColorPolitica> colores = (List<ColorPolitica>) request.getAttribute("colores");
    PoliticaDevolucion politica = (PoliticaDevolucion) request.getAttribute("politica");
    EvaluacionPolitica evaluacion = (EvaluacionPolitica) request.getAttribute("evaluacion");

    String codigo = (String) request.getAttribute("codigo");
    String idProveedorSel = (String) request.getAttribute("idProveedor");
    Integer idColorSel = (Integer) request.getAttribute("idColor");
    String fechaVencSel = (String) request.getAttribute("fechaVencimiento");

    if (proveedores == null) proveedores = new ArrayList<>();
    if (colores == null) colores = new ArrayList<>();
    if (codigo == null) codigo = "";
    if (idProveedorSel == null) idProveedorSel = "";
  %>

  <div class="d-flex align-items-center justify-content-between mb-3">
    <div>
      <h4 class="mb-0">Consultar Política</h4>
    </div>
  </div>

  <!-- Mensaje (SweetAlert2) -->
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
        
        const formBuscar = document.getElementById("formBuscar");
        const spinnerBuscar = document.getElementById("spinnerBuscar");

        if (formBuscar) {
          formBuscar.addEventListener("submit", function () {
            spinnerBuscar.classList.remove("d-none");
          });
        }
      });
    </script>
  <% } %>

  <!-- 1) Buscar producto -->
  <div class="card shadow-sm mb-3">
    <div class="card-body p-4">
      <form id="formBuscar" method="post" action="<%=request.getContextPath()%>/ConsultarPolitica" class="row g-3 align-items-end">
        <input type="hidden" name="accion" value="buscarProducto">

        <div class="col-md-6">
          <label class="form-label fw-semibold">Scanner</label>
          <input type="text" class="form-control" id="scanner" name="codigo"
                 placeholder="Escaneá y presioná Enter"
                 value="<%= codigo %>">
        </div>

        <div class="col-md-2 d-grid">
          <button class="btn btn-primary" type="submit">Buscar</button>
        </div>
        
        <div class="col-md-2 d-grid">
        <a class="btn btn-outline-secondary" href="<%=request.getContextPath()%>/ConsultarPolitica">
          Limpiar
        </a>
      </div>

        <div class="col-md-4">
          <div class="text-muted small">Código leído</div>
          <div class="fw-bold mono"><%= codigo.isEmpty() ? "—" : codigo %></div>
        </div>
      </form>
    </div>
  </div>

  <!-- 2) Tarjeta Producto -->
  <div class="card shadow-sm mb-3">
    <div class="card-body p-4">
      <h6 class="mb-3">Producto</h6>

      <% if (producto == null) { %>
        <div class="text-muted">Escaneá un producto para ver la información.</div>
      <% } else { %>
        <div class="row g-3">
          <div class="col-lg-6">
            <div class="text-muted small">Producto</div>
            <div class="fw-bold"><%= producto.getProducto() %></div>
            <div class="text-muted small mt-2">Código</div>
            <div class="mono fw-bold"><%= producto.getCodigo() %></div>
          </div>

          <div class="col-lg-6">
            <div class="row g-3">
              <div class="col-md-6">
                <div class="text-muted small">Código SAP</div>
                <div class="mono fw-bold"><%= producto.getCodigoSap() %></div>
              </div>
              <div class="col-md-6">
                <div class="text-muted small">Segmento</div>
                <div class="fw-bold"><%= producto.getSegmento() %></div>
              </div>

              <div class="col-md-6">
                <div class="text-muted small">Laboratorio</div>
                <div class="fw-bold"><%= producto.getLaboratorio() %></div>
              </div>

              <div class="col-md-6">
                <div class="text-muted small">Presentación</div>
                <div class="fw-bold"><%= producto.getPresentacion() %></div>
                <div class="text-muted small">Factor</div>
                <div class="mono fw-bold"><%= producto.getFactor().intValue() %></div>
              </div>
            </div>
          </div>
        </div>
      <% } %>
    </div>
  </div>

  <!-- 3) Selección Proveedor + Colores + Fecha + Consultar -->
  <div class="card shadow-sm mb-3">
    <div class="card-body p-4">
      <h6 class="mb-3">Parámetros de Política</h6>

      <div class="row g-3">
        <!-- Proveedor -->
        <div class="col-lg-4">
          <form method="post" action="<%=request.getContextPath()%>/ConsultarPolitica" id="formProveedor">
            <input type="hidden" name="accion" value="cargarColores">
            <input type="hidden" name="codigo" value="<%= codigo %>">

            <label class="form-label fw-semibold">Proveedor</label>

<div class="position-relative">
  <select name="idProveedor" id="idProveedor" class="form-select"
          <%= (producto == null ? "disabled" : "") %>>
    <option value="">-- Seleccionar --</option>
    <%
      for (ProveedorPolitica p : proveedores) {
        boolean sel = p.getIdProveedor() != null && p.getIdProveedor().equals(idProveedorSel);
    %>
      <option value="<%= p.getIdProveedor() %>" <%= sel ? "selected" : "" %>>
        <%= p.getProveedorNombre() %>
      </option>
    <% } %>
  </select>

  <!-- Spinner overlay -->
  <div id="spinnerProveedor"
       class="d-none position-absolute top-50 end-0 translate-middle-y me-3">
    <span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
  </div>
</div>

<div class="form-text">Al elegir proveedor se cargan colores.</div>
          </form>
        </div>

        <!-- Color -->
        <div class="col-lg-4">
          <form method="post" action="<%=request.getContextPath()%>/ConsultarPolitica" id="formConsultar">
            <input type="hidden" name="accion" value="consultarPolitica">
            <input type="hidden" name="codigo" value="<%= codigo %>">
            <input type="hidden" name="idProveedor" value="<%= idProveedorSel %>" id="hiddenProveedor">

            <label class="form-label fw-semibold">Color</label>
            <select name="idColor" id="idColor" class="form-select"
                    <%= (producto == null || idProveedorSel.isEmpty() ? "disabled" : "") %>>
              <option value="">-- Seleccionar --</option>
              <%
                for (ColorPolitica c : colores) {
                  boolean sel = (idColorSel != null && c.getIdColor() != null && c.getIdColor().intValue() == idColorSel.intValue());
              %>
                <option value="<%= c.getIdColor() %>" <%= sel ? "selected" : "" %>>
                  <%= c.getColor() %>
                </option>
              <% } %>
            </select>
            <div class="form-text">Solo muestra colores con política activa.</div>
        </div>

        <!-- Fecha Vencimiento -->
        <div class="col-lg-4">
            <label class="form-label fw-semibold">Fecha de vencimiento</label>
            <input type="date" class="form-control" name="fechaVencimiento" id="fechaVencimiento"
                   value="<%= (fechaVencSel == null ? "" : fechaVencSel) %>"
                   <%= (producto == null || idProveedorSel.isEmpty() ? "disabled" : "") %>>
            <div class="form-text">Obligatoria para evaluar meses.</div>
        </div>

        <div class="col-12 d-flex justify-content-end">
            <button class="btn btn-success"
                    type="submit"
                    <%= (producto == null || idProveedorSel.isEmpty() ? "disabled" : "") %>>
              Consultar política
            </button>
          </form>
        </div>
      </div>

    </div>
  </div>

  <!-- 4) Resultado -->
  <div class="card shadow-sm">
    <div class="card-body p-4">
      <h6 class="mb-3">Resultado</h6>

      <% if (evaluacion == null) { %>
        <div class="text-muted">Consultá una política para ver el resultado.</div>
      <% } else { %>

        <%
          String res = evaluacion.getResultado();
          String pillClass = "pill-info";
          if ("OK".equals(res)) pillClass = "pill-ok";
          else if ("ANTICIPADO".equals(res)) pillClass = "pill-warn";
          else if ("FUERA".equals(res)) pillClass = "pill-bad";
          else if ("NO_DEVOLUTIVO".equals(res)) pillClass = "pill-bad";
        %>

        <div class="d-flex align-items-center gap-2 mb-3">
          <span class="pill <%= pillClass %>"><%= res %></span>
          <div class="fw-bold"><%= evaluacion.getMensaje() %></div>
        </div>

        <div class="row g-3">
          <div class="col-md-4">
            <div class="text-muted small">Meses restantes (aprox)</div>
            <div class="mono fw-bold"><%= evaluacion.getMesesRestantes() %></div>
          </div>

          <div class="col-md-4">
            <div class="text-muted small">Tiempo política (meses)</div>
            <div class="mono fw-bold"><%= (politica == null ? "—" : politica.getTiempo()) %></div>
          </div>

          <div class="col-md-4">
            <div class="text-muted small">Fracciones</div>
            <div class="mono fw-bold"><%= (politica == null ? "—" : politica.getFracciones()) %></div>
          </div>

          <div class="col-12">
            <div class="text-muted small">Observaciones</div>
            <div class="fw-bold"><%= (politica == null || politica.getObservaciones() == null ? "—" : politica.getObservaciones()) %></div>
          </div>
        </div>

      <% } %>
    </div>
  </div>

</div>

<script src="<%=request.getContextPath()%>/js/bundle.js"></script>

<script>
  let interactuandoFormulario = false;

  function focusScanner(force=false){
    const sc = document.getElementById("scanner");
    if (!sc) return;

    if (interactuandoFormulario && !force) return;

    sc.focus();
    sc.select();
  }

  document.addEventListener("DOMContentLoaded", function(){

    // Foco inicial al scanner
    setTimeout(() => focusScanner(true), 80);

    // Enter en scanner -> submit buscar
    const sc = document.getElementById("scanner");
    if (sc){
      sc.addEventListener("keydown", function(e){
        if (e.key === "Enter"){
          e.preventDefault();
          document.getElementById("formBuscar").submit();
        }
      });
    }

    // Auto-submit al cambiar proveedor (para cargar colores)
    const selProv = document.getElementById("idProveedor");
    const spProv = document.getElementById("spinnerProveedor");
    if (selProv){
      selProv.addEventListener("change", function(){
        // mantener hidden proveedor del form consultar
        document.getElementById("hiddenProveedor").value = this.value;
        document.getElementById("formProveedor").submit();
      });
    }

    // Cuando el usuario interactúa con selects/fecha, no robar foco
    ["idProveedor", "idColor", "fechaVencimiento"].forEach(id => {
      const el = document.getElementById(id);
      if (!el) return;
      el.addEventListener("focusin", ()=> interactuandoFormulario = true);
      el.addEventListener("focusout", ()=> {
        interactuandoFormulario = false;
        setTimeout(()=>focusScanner(false), 120);
      });
    });

    // ESC -> volver al scanner
    document.addEventListener("keydown", function(e){
      if (e.key === "Escape"){
        interactuandoFormulario = false;
        focusScanner(true);
      }
    });

    // Click fuera de forms -> regresar scanner
    document.addEventListener("click", function(e){
      const dentro = e.target.closest("form, select, input[type='date']");
      if (!dentro){
        setTimeout(()=>focusScanner(false), 80);
      }
    });

  });
</script>

</body>
</html>