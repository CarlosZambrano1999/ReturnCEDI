<%-- 
    Document   : navbar
    Created on : 24 dic 2025, 11:16:38
    Author     : Administrador
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    String titulo = (String) request.getAttribute("titulo");
    if (titulo == null) titulo = "";

    Integer rol = (Integer) session.getAttribute("rol");

    java.util.function.BiFunction<Integer[], Integer, Boolean> canAccess =
        (rolesPermitidos, rolUsuario) -> {
            if (rolesPermitidos == null) return true;
            if (rolUsuario == null) return false;
            for (Integer r : rolesPermitidos) {
                if (r.equals(rolUsuario)) return true;
            }
            return false;
        };

    boolean esHome = request.getRequestURI().endsWith("/home") ||
                     request.getRequestURI().endsWith("/home.jsp");
%>
        <link href="<%=request.getContextPath()%>/componentes/estilos.css" rel="stylesheet">


<nav class="navbar navbar-expand-lg navbar-light bg-white shadow-sm sticky-top">
    <div class="container-fluid px-4">

        <!-- LOGO / TITULO -->
        <a class="navbar-brand d-flex align-items-center gap-2" href="<%=ctx%>/home">
            <h3 class="rc-title mb-0">
                <span class="t1">Return</span><span class="t2">CEDI</span>

                <% if (esHome && !titulo.isEmpty()) { %>
                    <span class="ms-2 text-muted fw-semibold" style="font-size:.95rem;">
                        | <%= titulo %>
                    </span>
                <% } %>
            </h3>
        </a>

        <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                data-bs-target="#rcNavbar">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="rcNavbar">

            <ul class="navbar-nav me-auto mb-2 mb-lg-0">

                <!-- ================= OPERACIÓN ================= -->
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                        Operación
                    </a>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="<%=ctx%>/CargarDocMaterialExcel">Cargar Doc. Material</a></li>
                        <li><a class="dropdown-item" href="<%=ctx%>/ConsultarPolitica" target="_blank">Consultar Política</a></li>

                        <% if (canAccess.apply(new Integer[]{1,2,3}, rol)) { %>
                            <li><a class="dropdown-item" href="<%=ctx%>/Devoluciones">Devoluciones</a></li>
                        <% } %>

                        <% if (canAccess.apply(new Integer[]{1,2,5}, rol)) { %>
                            <li><a class="dropdown-item" href="<%=ctx%>/Donaciones">Donaciones</a></li>
                        <% } %>

                        <% if (canAccess.apply(new Integer[]{1,2,4}, rol)) { %>
                            <li><a class="dropdown-item" href="<%=ctx%>/Excesos">Excesos</a></li>
                        <% } %>

                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="<%=ctx%>/RptGuias">Guías por usuario</a></li>
                    </ul>
                </li>

                <!-- ================= INCIDENCIAS ================= -->
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                        Incidencias
                    </a>
                    <ul class="dropdown-menu">
                        <% if (canAccess.apply(new Integer[]{1,2}, rol)) { %>
                            <li><a class="dropdown-item" href="<%=ctx%>/Incidencia">Administrar Incidencias</a></li>
                        <% } %>

                        <% if (canAccess.apply(new Integer[]{1,2,3}, rol)) { %>
                            <li><a class="dropdown-item" href="<%=ctx%>/IncidenciasDevoluciones">Devoluciones</a></li>
                        <% } %>

                        <% if (canAccess.apply(new Integer[]{1,2,5}, rol)) { %>
                            <li><a class="dropdown-item" href="<%=ctx%>/IncidenciasDonaciones">Donaciones</a></li>
                        <% } %>

                        <% if (canAccess.apply(new Integer[]{1,2,4}, rol)) { %>
                            <li><a class="dropdown-item" href="<%=ctx%>/IncidenciasExcesos">Excesos</a></li>
                        <% } %>
                    </ul>
                </li>

                <!-- ================= REPORTES ================= -->
                <% if (canAccess.apply(new Integer[]{1,2}, rol)) { %>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                        Reportes
                    </a>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="<%=ctx%>/Reportes/Devoluciones">Devoluciones</a></li>
                        <li><a class="dropdown-item" href="<%=ctx%>/Reportes/Donaciones">Donaciones</a></li>
                        <li><a class="dropdown-item" href="<%=ctx%>/Reportes/Excesos">Excesos</a></li>
                    </ul>
                </li>
                <% } %>

                <!-- ================= ADMIN ================= -->
                <% if (canAccess.apply(new Integer[]{1}, rol)) { %>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle text-danger" href="#" data-bs-toggle="dropdown">
                        Administración
                    </a>
                    <ul class="dropdown-menu">
                        <li><a class="dropdown-item" href="<%=ctx%>/admin">Usuarios</a></li>
                        <li><a class="dropdown-item" href="<%=ctx%>/registro">Registrar Usuario</a></li>
                    </ul>
                </li>
                <% } %>

            </ul>

            <!-- USUARIO / LOGOUT -->
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

