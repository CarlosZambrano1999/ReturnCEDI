<%@page import="java.util.List"%>
<%@page import="modelos.Rol"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Registro de Usuario</title>
        <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet">
    </head>
    <body class="bg-light">
        <jsp:include page="/componentes/navbar.jsp" />


        <%
            // Variables de feedback y valores previos
            String ok = (String) request.getAttribute("ok");
            String error = (String) request.getAttribute("error");
            String val_nombre = (String) request.getAttribute("val_nombre");
            String val_codigo = (String) request.getAttribute("val_codigo");
            String val_idRol = (String) request.getAttribute("val_idRol");
            String val_estado = (String) request.getAttribute("val_estado");
        %>

        <div class="container mt-5">
            <div class="row justify-content-center">
                <div class="col-md-7 col-lg-6">
                    <div class="card shadow-lg border-0 rounded-3">
                        <div class="card-header bg-primary text-white text-center">
                            <h4 class="mb-0">Registro de Usuario</h4>
                        </div>

                        <div class="card-body">

                            <% if (ok != null) {%>
                            <div class="alert alert-success text-center"><%= ok%></div>
                            <% } else if (error != null) {%>
                            <div class="alert alert-danger text-center"><%= error%></div>
                            <% }%>

                            <form action="<%= request.getContextPath()%>/registro" method="post">

                                <!-- Nombre -->
                                <div class="mb-3">
                                    <label for="nombre" class="form-label">Nombre completo</label>
                                    <input type="text" class="form-control" id="nombre" name="nombre"
                                           value="<%= (val_nombre != null ? val_nombre : "")%>" required>
                                </div>

                                <!-- Código -->
                                <div class="mb-3">
                                    <label for="codigo" class="form-label">Usuario</label>
                                    <input type="text" class="form-control" id="codigo" name="codigo"
                                           value="<%= (val_codigo != null ? val_codigo : "")%>" required>
                                </div>

                                <!-- Contraseña -->
                                <div class="mb-3">
                                    <label for="password" class="form-label">Contraseña</label>
                                    <input type="password" class="form-control" id="password" name="password"
                                           required minlength="6">
                                </div>

                                <!-- Rol dinámico -->
                                <div class="mb-3">
                                    <label for="idRol" class="form-label">Rol</label>
                                    <select class="form-select" id="idRol" name="idRol" required>
                                        <option value="">-- Selecciona un rol --</option>
                                        <%
                                            List<Rol> roles
                                                    = (List<Rol>) request.getAttribute("roles");
                                            if (roles != null && !roles.isEmpty()) {
                                                for (Rol r : roles) {
                                                    String selected = (val_idRol != null
                                                            && val_idRol.equals(String.valueOf(r.getId_rol()))) ? "selected" : "";
                                        %>
                                        <option value="<%= r.getId_rol()%>" <%= selected%>>
                                            <%= r.getRol()%>
                                        </option>
                                        <%
                                            }
                                        } else {
                                        %>
                                        <option disabled>No hay roles disponibles</option>
                                        <%
                                            }
                                        %>
                                    </select>
                                </div>


                                <!-- Estado -->
                                <div class="mb-3">
                                    <label for="estado" class="form-label">Estado</label>
                                    <select class="form-select" id="estado" name="estado">
                                        <option value="1" <%= "1".equals(val_estado) ? "selected" : ""%>>Activo</option>
                                        <option value="0" <%= "0".equals(val_estado) ? "selected" : ""%>>Inactivo</option>
                                    </select>
                                </div>

                                <!-- Botón -->
                                <div class="d-grid">
                                    <button type="submit" class="btn btn-success btn-lg">
                                        Registrar Usuario
                                    </button>
                                </div>
                            </form>

                        </div>

                        <div class="card-footer text-center text-muted small">
                            © 2025 — Sistema de Registro | Desarrollado por <b>arlom</b>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="<%=request.getContextPath()%>/js/bundle.js"></script>
    </body>
</html>
