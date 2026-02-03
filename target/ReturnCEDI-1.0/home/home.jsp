<%-- 
    Document   : home
    Created on : 12 dic 2025, 11:52:06
    Author     : Administrador
--%>

<%@page import="modelos.Modulo"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.*"%>

<%
    String ctx = request.getContextPath();

    // Si tu nombre/rol lo guardás en session:
    String nombre = (String) session.getAttribute("nombre");

    List<Modulo> mods = (List<Modulo>) request.getAttribute("mods");
    if (mods == null) mods = new ArrayList<>();

    // Agrupar por categoría
    Map<String, List<Modulo>> porCat = new LinkedHashMap<>();
    for (Modulo m : mods) {
        String cat = (m.getCategoria() == null) ? "OTROS" : m.getCategoria().toUpperCase().trim();
        porCat.computeIfAbsent(cat, k -> new ArrayList<>()).add(m);
    }

    // Ordenar dentro de cada categoría por ORDEN y TITULO (por si acaso)
    for (List<Modulo> lista : porCat.values()) {
        lista.sort((a,b) -> {
            int c = Integer.compare(a.getOrden(), b.getOrden());
            if (c != 0) return c;
            String ta = (a.getTitulo() == null) ? "" : a.getTitulo();
            String tb = (b.getTitulo() == null) ? "" : b.getTitulo();
            return ta.compareToIgnoreCase(tb);
        });
    }

    // Helpers de estilo por categoría (colores de tu ejemplo)
    class CatStyle {
        String title;
        String bg;    // fondo icon-wrap (rgba...)
        String color; // color del icono
        CatStyle(String t, String b, String c) { title=t; bg=b; color=c; }
    }

    Map<String, CatStyle> styles = new HashMap<>();
    styles.put("OPERACION",   new CatStyle("OPERACIÓN",   "rgba(13,110,253,.12)", "#0d6efd"));
    styles.put("INCIDENCIAS", new CatStyle("INCIDENCIAS", "rgba(111,66,193,.12)", "#6f42c1"));
    styles.put("REPORTES",    new CatStyle("REPORTES",    "rgba(25,135,84,.12)",  "#198754"));
    styles.put("ADMIN",       new CatStyle("ADMIN",       "rgba(220,53,69,.12)",  "#dc3545"));
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    <title>Home · ReturnCEDI</title>

    <link href="<%=ctx%>/css/bootstrap.css" rel="stylesheet">
    <link href="<%=ctx%>/css/bootstrap-icons.css" rel="stylesheet">
    <link href="<%=ctx%>/home/estilos.css" rel="stylesheet">
    <script src="<%=ctx%>/js/bundle.js"></script>

</head>

<body>
<jsp:include page="/componentes/navbar.jsp" />
<div class="container py-4">

    <!-- HEADER -->
    <div class="hero p-4 mb-4">
        <div class="d-flex flex-wrap align-items-center justify-content-between gap-3">
            <div>
                <h3 class="mb-1">Bienvenido, <%= (nombre != null ? nombre : "") %> 👋</h3>
                <div class="opacity-75">Seleccioná un módulo para comenzar</div>
            </div>
            <a href="<%=ctx%>/logout" class="btn btn-outline-light btn-sm rounded-pill">
                <i class="bi bi-box-arrow-right me-1"></i> Cerrar sesión
            </a>
        </div>
    </div>

    <%
        // Render por categorías en orden fijo (como tu home actual)
        String[] ordenCats = new String[]{"OPERACION","INCIDENCIAS","REPORTES","ADMIN","OTROS"};

        for (String catKey : ordenCats) {
            List<Modulo> lista = porCat.get(catKey);
            if (lista == null || lista.isEmpty()) continue;

            CatStyle st = styles.getOrDefault(catKey, new CatStyle(catKey, "rgba(108,117,125,.12)", "#6c757d"));
    %>

    <div class="row g-3 mb-4">
        <%
            for (Modulo m : lista) {
                String icon = (m.getIcono() == null || m.getIcono().trim().isEmpty()) ? "bi-grid" : m.getIcono().trim();
                String titulo = (m.getTitulo() == null) ? "" : m.getTitulo();
                String desc = (m.getDescripcion() == null) ? "" : m.getDescripcion();
                String ruta = (m.getRuta() == null) ? "" : m.getRuta(); // ej "/Devoluciones"
                String urlFinal = ctx + ruta; // se arma como en tu código (ctx + "/Devoluciones")
        %>
        <div class="col-md-6 col-xl-4">
            <div class="card card-mod position-relative">
                <div class="card-body p-4">
                    <div class="d-flex align-items-center gap-3">
                        <div class="icon-wrap" style="background:<%=st.bg%>;color:<%=st.color%>;">
                            <i class="bi <%=icon%>"></i>
                        </div>
                        <div class="flex-grow-1">
                            <div class="fw-semibold"><%=titulo%></div>
                            <div class="muted small-note"><%=desc%></div>
                        </div>
                        <i class="bi bi-arrow-right text-muted"></i>
                    </div>
                    <a href="<%=urlFinal%>" class="stretched-link"></a>
                </div>
            </div>
        </div>
        <%
            }
        %>
    </div>

    <%
        } // fin categorías
    %>

    <div class="text-center muted mt-4 small">
        ReturnCEDI · Home
    </div>
</div>

</body>
</html>
