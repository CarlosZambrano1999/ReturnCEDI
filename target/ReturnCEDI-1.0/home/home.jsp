<%-- 
    Document   : home
    Created on : 12 dic 2025, 11:52:06
    Author     : Administrador
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    String nombre = (String) session.getAttribute("nombre");
    Integer rol = (Integer) session.getAttribute("rol");

    // Función inline para validar acceso por rol
    java.util.function.BiFunction<Integer[], Integer, Boolean> canAccess
            = ( rolesPermitidos,   
                rolUsuario) -> {
            if (rolesPermitidos == null) {
                    return true; // libre
                }
                if (rolUsuario == null) {
                    return false;
                }
                for (Integer r : rolesPermitidos) {
                    if (r.equals(rolUsuario)) {
                        return true;
                    }
                }
                return false;
            };
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Home · ReturnCEDI</title>

        <link href="<%=ctx%>/css/bootstrap.css" rel="stylesheet">
        <link href="<%=ctx%>/css/bootstrap-icons.css" rel="stylesheet">
        <link href="<%=ctx%>/home/estilos.css" rel="stylesheet">

        <style>
        </style>
    </head>

    <body>
        <jsp:include page="/componentes/navbar.jsp" />
        <div class="container py-4">

            <!-- HEADER -->
            <div class="hero p-4 mb-4">
                <div class="d-flex flex-wrap align-items-center justify-content-between gap-3">
                    <div>
                        <h3 class="mb-1">Bienvenido, <%= nombre%> 👋</h3>
                        <div class="opacity-75">Seleccioná un módulo para comenzar</div>
                    </div>
                    <a href="<%=ctx%>/logout" class="btn btn-outline-light btn-sm rounded-pill">
                        <i class="bi bi-box-arrow-right me-1"></i> Cerrar sesión
                    </a>
                </div>
            </div>

            <%
                class Mod {

                    String titulo, desc, url, icon;
                    Integer[] roles;

                    Mod(String t, String d, String u, String i, Integer[] r) {
                        titulo = t;
                        desc = d;
                        url = u;
                        icon = i;
                        roles = r;
                    }
                }
            %>

            <!-- ================= OPERACIÓN ================= -->
            <div class="row g-3 mb-4">
                <%
                    java.util.List<Mod> operacion = new java.util.ArrayList<>();
                    operacion.add(new Mod("Cargar Doc. Material Excel",
                            "Subir el documento material y generá el documento base.",
                            ctx + "/CargarDocMaterialExcel",
                            "bi-file-earmark-arrow-up",
                            null));

                    operacion.add(new Mod("Consultar Política",
                            "Escanear producto y validar política de vencimiento.",
                            ctx + "/ConsultarPolitica",
                            "bi-search",
                            null));

                    operacion.add(new Mod("Devoluciones",
                            "Registrar productos como devolutivos.",
                            ctx + "/Devoluciones",
                            "bi-arrow-repeat",
                            new Integer[]{1, 2, 3}));

                    operacion.add(new Mod("Donaciones",
                            "Registrar productos como donaciones.",
                            ctx + "/Donaciones",
                            "bi-gift",
                            new Integer[]{1, 2, 5}));

                    operacion.add(new Mod("Excesos",
                            "Registrar productos como excedentes.",
                            ctx + "/Excesos",
                            "bi-exclamation-triangle",
                            new Integer[]{1, 2, 4}));

                    operacion.add(new Mod("Guías por usuario",
                            "Listado general de guías realizadas.",
                            ctx + "/RptGuias",
                            "bi-journal-text",
                            null));

                    for (Mod m : operacion) {
                        if (!canAccess.apply(m.roles, rol))
                            continue;
                %>
                <div class="col-md-6 col-xl-4">
                    <div class="card card-mod position-relative">
                        <div class="card-body p-4">
                            <div class="d-flex align-items-center gap-3">
                                <div class="icon-wrap"><i class="bi <%=m.icon%>"></i></div>
                                <div class="flex-grow-1">
                                    <div class="fw-semibold"><%=m.titulo%></div>
                                    <div class="muted small-note"><%=m.desc%></div>
                                </div>
                                <i class="bi bi-arrow-right text-muted"></i>
                            </div>
                            <a href="<%=m.url%>" class="stretched-link"></a>
                        </div>
                    </div>
                </div>
                <%
                    }
                %>
            </div>

            <!-- ================= INCIDENCIAS ================= -->
            <div class="row g-3 mb-4">
                <%
                    java.util.List<Mod> incid = new java.util.ArrayList<>();
                    incid.add(new Mod("Administrar Incidencias",
                            "Configuración general de incidencias.",
                            ctx + "/Incidiencia",
                            "bi-gear",
                            new Integer[]{1, 2}));

                    incid.add(new Mod("Incidencias - Devoluciones",
                            "Listado de incidencias en devoluciones.",
                            ctx + "/IncidenciasDevoluciones",
                            "bi-clipboard-data",
                            new Integer[]{1, 2, 3}));

                    incid.add(new Mod("Incidencias - Donaciones",
                            "Listado de incidencias en donaciones.",
                            ctx + "/IncidenciasDonaciones",
                            "bi-clipboard-heart",
                            new Integer[]{1, 2, 5}));

                    incid.add(new Mod("Incidencias - Excesos",
                            "Listado de incidencias en excesos.",
                            ctx + "/IncidenciasExcesos",
                            "bi-clipboard-x",
                            new Integer[]{1, 2, 4}));

                    for (Mod m : incid) {
                        if (!canAccess.apply(m.roles, rol))
                            continue;
                %>
                <div class="col-md-6 col-xl-4">
                    <div class="card card-mod position-relative">
                        <div class="card-body p-4">
                            <div class="d-flex align-items-center gap-3">
                                <div class="icon-wrap" style="background:rgba(111,66,193,.12);color:#6f42c1;">
                                    <i class="bi <%=m.icon%>"></i>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="fw-semibold"><%=m.titulo%></div>
                                    <div class="muted small-note"><%=m.desc%></div>
                                </div>
                                <i class="bi bi-arrow-right text-muted"></i>
                            </div>
                            <a href="<%=m.url%>" class="stretched-link"></a>
                        </div>
                    </div>
                </div>
                <%
                    }
                %>
            </div>

            <!-- ================= REPORTES ================= -->
            <div class="row g-3 mb-4">
                <%
                    java.util.List<Mod> reportes = new java.util.ArrayList<>();
                    reportes.add(new Mod("Dashboard - Devoluciones",
                            "KPIs y gráficos de devoluciones.",
                            ctx + "/Reportes/Devoluciones",
                            "bi-graph-up",
                            new Integer[]{1, 2}));

                    reportes.add(new Mod("Dashboard - Donaciones",
                            "KPIs y gráficos de donaciones.",
                            ctx + "/Reportes/Donaciones",
                            "bi-graph-up-arrow",
                            new Integer[]{1, 2}));

                    reportes.add(new Mod("Dashboard - Excesos",
                            "KPIs y gráficos de excesos.",
                            ctx + "/Reportes/Excesos",
                            "bi-bar-chart",
                            new Integer[]{1, 2}));

                    for (Mod m : reportes) {
                        if (!canAccess.apply(m.roles, rol))
                            continue;
                %>
                <div class="col-md-6 col-xl-4">
                    <div class="card card-mod position-relative">
                        <div class="card-body p-4">
                            <div class="d-flex align-items-center gap-3">
                                <div class="icon-wrap" style="background:rgba(25,135,84,.12);color:#198754;">
                                    <i class="bi <%=m.icon%>"></i>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="fw-semibold"><%=m.titulo%></div>
                                    <div class="muted small-note"><%=m.desc%></div>
                                </div>
                                <i class="bi bi-arrow-right text-muted"></i>
                            </div>
                            <a href="<%=m.url%>" class="stretched-link"></a>
                        </div>
                    </div>
                </div>
                <%
                    }
                %>
            </div>

            <!-- ================= ADMIN ================= -->
            <div class="row g-3">
                <%
                    java.util.List<Mod> admin = new java.util.ArrayList<>();
                    admin.add(new Mod("Administrar usuarios",
                            "Gestión completa de usuarios.",
                            ctx + "/admin",
                            "bi-people",
                            new Integer[]{1}));

                    admin.add(new Mod("Registro de usuarios",
                            "Alta de nuevos usuarios.",
                            ctx + "/registro",
                            "bi-person-plus",
                            new Integer[]{1}));

                    for (Mod m : admin) {
                        if (!canAccess.apply(m.roles, rol))
                            continue;
                %>
                <div class="col-md-6 col-xl-4">
                    <div class="card card-mod position-relative">
                        <div class="card-body p-4">
                            <div class="d-flex align-items-center gap-3">
                                <div class="icon-wrap" style="background:rgba(220,53,69,.12);color:#dc3545;">
                                    <i class="bi <%=m.icon%>"></i>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="fw-semibold"><%=m.titulo%></div>
                                    <div class="muted small-note"><%=m.desc%></div>
                                </div>
                                <i class="bi bi-arrow-right text-muted"></i>
                            </div>
                            <a href="<%=m.url%>" class="stretched-link"></a>
                        </div>
                    </div>
                </div>
                <%
                    }
                %>
            </div>

            <div class="text-center muted mt-4 small">
                ReturnCEDI · Home
            </div>

        </div>

        <script src="<%=ctx%>/js/bundle.js"></script>
    </body>
</html>
