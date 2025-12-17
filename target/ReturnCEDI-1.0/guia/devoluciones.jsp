<%-- 
    Document   : devoluciones
    Created on : 16 dic 2025, 15:37:34
    Author     : Administrador
--%>

<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="modelos.ComparativoDocMaterialRow"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Devoluciones - Escaneo</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.datatables.net/1.13.8/css/dataTables.bootstrap5.min.css" rel="stylesheet">

  <style>
    body { background:#f6f7fb; }
    .card { border:0; border-radius:16px; }
    .state-pill{padding:.25rem .6rem;border-radius:999px;font-weight:700;font-size:.85rem}
    .st-ok{background:rgba(25,135,84,.12);color:#198754}
    .st-f{background:rgba(220,53,69,.12);color:#dc3545}
    .st-s{background:rgba(25,135,84,.12);color:#198754}
    .st-a{background:rgba(255,193,7,.18);color:#b78103}
    tr.row-f td{background:rgba(220,53,69,.08)!important}
    tr.row-s td{background:rgba(25,135,84,.08)!important}
    tr.row-a td{background:rgba(255,193,7,.12)!important}
    #scanner{border-width:2px;font-weight:600}
  </style>
</head>
<body>
<div class="container py-4">

  <%
    Long doc = (Long) request.getAttribute("docMaterial");
    List<ComparativoDocMaterialRow> comparativo = (List<ComparativoDocMaterialRow>) request.getAttribute("comparativo");
    String msgType = (String) request.getAttribute("msgType");
    String msg = (String) request.getAttribute("msg");
    if (comparativo == null) comparativo = new ArrayList<>();
  %>

  <div class="card shadow-sm mb-3">
    <div class="card-body p-4">

      <% if (msg != null && !msg.trim().isEmpty()) { %>
        <div class="alert alert-<%= "success".equals(msgType) ? "success" : ("warning".equals(msgType) ? "warning" : "danger") %>">
          <%= msg %>
        </div>
      <% } %>

      <!-- FORM: cargar documento -->
      <form method="post" action="<%=request.getContextPath()%>/Devoluciones" class="row g-3 align-items-end">
        <input type="hidden" name="accion" value="cargarDocumento"/>

        <div class="col-md-4">
          <label class="form-label fw-semibold">Doc. Material</label>
          <input type="text" class="form-control" name="docMaterial" id="docMaterial" value="<%= doc == null ? "" : doc %>" placeholder="Ej: 4900716458">
        </div>

        <div class="col-md-2 d-grid">
          <button class="btn btn-primary" type="submit">Cargar</button>
        </div>

        <!-- FORM: escaneo (mismo action) -->
        <div class="col-md-6">
          <label class="form-label fw-semibold">Scanner (siempre en foco)</label>
          <div class="input-group">
            <input type="text" class="form-control" id="scanner" name="codigo" placeholder="Escaneá y Enter"
                   <%= (doc == null ? "disabled" : "") %> form="formScan">
          </div>
          <div class="form-text">Se guarda con action=scan. El foco vuelve aquí.</div>
        </div>
      </form>

      <!-- Form separado solo para scan, para que Enter haga POST scan -->
      <form id="formScan" method="post" action="<%=request.getContextPath()%>/Devoluciones">
        <input type="hidden" name="accion" value="scan"/>
        <input type="hidden" name="docMaterial" value="<%= doc == null ? "" : doc %>"/>
      </form>

    </div>
  </div>

  <div class="card shadow-sm">
    <div class="card-body p-4">
      <table id="tabla" class="table table-striped table-hover align-middle w-100">
        <thead>
          <tr>
            <th>Estado</th>
            <th>Código SAP</th>
            <th>Descripción</th>
            <th>FC</th>
            <th>Presentación</th>
            <th class="text-end">Esperado</th>
            <th class="text-end">Escaneado</th>
            <th class="text-end">Diferencia</th>
            <th class="text-center">Editar</th>
          </tr>
        </thead>
        <tbody>
        <%
          for (ComparativoDocMaterialRow r : comparativo) {
            String est = (r.getEstado() == null) ? "OK" : r.getEstado();
            String pill = "OK".equals(est) ? "st-ok" : ("FALTANTE".equals(est) ? "st-f" : ("SOBRANTE".equals(est) ? "st-s" : "st-a"));
            String rowCls = "FALTANTE".equals(est) ? "row-f" : ("SOBRANTE".equals(est) ? "row-s" : ("ADICIONAL".equals(est) ? "row-a" : ""));
        %>
          <tr class="<%=rowCls%>">
            <td><span class="state-pill <%=pill%>"><%=est%></span></td>
            <td><%= r.getCodigoSap() %></td>
            <td><%= r.getDescripcion() == null ? "" : r.getDescripcion() %></td>
            <td><%= r.getFactor() %></td>
            <td><%= r.getPresentacion() %></td>
            <td class="text-end"><%= r.getCantidadEsperada().intValue() %></td>
            <td class="text-end"><%= r.getCantidadEscaneada().intValue() %></td>
            <td class="text-end"><%= r.getDiferencia().intValue() %></td>
            <td class="text-center">
              <!-- Botón: abre modal o te lo hago inline después -->
              <span class="text-muted">Siguiente paso</span>
            </td>
          </tr>
        <%
          }
        %>
        </tbody>
      </table>
    </div>
  </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/dataTables.bootstrap5.min.js"></script>

<script>
  $(function(){
    $("#tabla").DataTable({
      ordering:false,
      pageLength:10,
      drawCallback: function(){ keepFocus(); }
    });

    // Mantener foco siempre en scanner si doc existe
    function keepFocus(){
      const scanner = document.getElementById("scanner");
      if (scanner && !scanner.disabled){
        scanner.focus();
        scanner.select();
      }
    }

    // Al cargar, foco al scanner si hay doc, sino al docMaterial
    setTimeout(function(){
      const scanner = document.getElementById("scanner");
      const doc = document.getElementById("docMaterial");
      if (scanner && !scanner.disabled) keepFocus();
      else if (doc) doc.focus();
    }, 50);

    document.addEventListener("click", function(){ setTimeout(keepFocus, 30); });
    document.addEventListener("keydown", function(e){ if (e.key === "Escape") keepFocus(); });

    // Enter en scanner envía el formScan
    const scanner = document.getElementById("scanner");
    if (scanner){
      scanner.addEventListener("keydown", function(e){
        if(e.key === "Enter"){
          e.preventDefault();
          document.getElementById("formScan").submit();
        }
      });
    }
  });
</script>
</body>
</html>