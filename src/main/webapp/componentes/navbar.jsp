<%-- 
    Document   : navbar
    Created on : 24 dic 2025, 11:16:38
    Author     : Administrador
--%>

<%@page import="java.util.LinkedHashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.ArrayList"%>
<%@page import="modelos.Modulo"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    List<Modulo> navModulos = (List<Modulo>) session.getAttribute("navModulos");
    if (navModulos == null) navModulos = new ArrayList<>();

    // Agrupar por categoría
    Map<String, List<Modulo>> porCategoria = new LinkedHashMap<>();
    for (Modulo m : navModulos) {
        String cat = (m.getCategoria() == null || m.getCategoria().trim().isEmpty()) ? "OTROS" : m.getCategoria();
        porCategoria.computeIfAbsent(cat, k -> new ArrayList<>()).add(m);
    }
%>
<link href="<%=request.getContextPath()%>/componentes/estilos.css" rel="stylesheet">
<link href="<%=request.getContextPath()%>/css/bootstrap-icons.css" rel="stylesheet">
<nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm sticky-top">
  <div class="container-fluid px-4">

    <a class="navbar-brand d-flex align-items-center gap-2" href="<%=ctx%>/home">
      <h3 class="rc-title mb-0"><span class="t1">Return</span><span class="t2">CEDI</span></h3>
    </a>

    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#rcNavbar">
      <span class="navbar-toggler-icon"></span>
    </button>

    <div class="collapse navbar-collapse" id="rcNavbar">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0">

        <% for (Map.Entry<String, List<Modulo>> entry : porCategoria.entrySet()) {
             String categoria = entry.getKey();
             List<Modulo> mods = entry.getValue();
        %>
          <li class="nav-item dropdown">
            <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
              <%= categoria %>
            </a>
            <ul class="dropdown-menu">
              <% for (Modulo m : mods) { %>
                <li>
                  <a class="dropdown-item" href="<%=ctx%><%=m.getRuta()%>">
                    <i class="bi <%=m.getIcono()%> me-2"></i><%=m.getTitulo()%>
                  </a>
                </li>
              <% } %>
            </ul>
          </li>
        <% } %>

      </ul>

      <ul class="navbar-nav">
        <li class="nav-item">
          <a href="<%=ctx%>/logout" class="nav-link text-danger">
            <i class="bi bi-box-arrow-right me-1"></i>Salir
          </a>
        </li>
      </ul>
    </div>
  </div>
</nav>

