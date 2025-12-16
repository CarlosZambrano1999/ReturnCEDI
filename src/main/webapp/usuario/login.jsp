<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Inicio de Sesión</title>
        <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet">
        <link href="<%=request.getContextPath()%>/usuario/styles.css" rel="stylesheet">
        <link href="<%=request.getContextPath()%>/css/bootstrap-icons.css" rel="stylesheet">
    </head>
    <body>
    <div class="blob blob1"></div>
    <div class="blob blob2"></div>
    <div class="blob blob3"></div>

    <%
        String error = (String) request.getAttribute("error");
        String val_codigo = (String) request.getAttribute("val_codigo");
    %>

    <div class="container">
        <div class="row justify-content-center">
            <div class="col-11 col-sm-9 col-md-6 col-lg-4">

                <div class="card login-card">
                    <div class="login-header text-center">
                        <h4>Inicio de Sesión</h4>
                    </div>

                    <div class="card-body p-4">
                        <img src="<%= request.getContextPath()%>/images/logo.png"
                             alt="Logo ReturnCEDI" class="logo">


                        <% if (error != null) { %>
                        <div class="alert alert-soft text-center py-2 mb-3">
                            <i class="bi bi-exclamation-triangle-fill me-1"></i>
                            <%= error %>
                        </div>
                        <% } %>

                        <form action="<%= request.getContextPath()%>/login" method="post" autocomplete="off">

                            <!-- Usuario -->
                            <div class="mb-3">
                                <label for="codigo" class="form-label">Usuario</label>
                                <div class="input-wrap">
                                    <i class="bi bi-person"></i>
                                    <input type="text" class="form-control" id="codigo" name="codigo"
                                           value="<%= (val_codigo != null ? val_codigo : "")%>"
                                           required placeholder="Ejemplo: USER001">
                                </div>
                            </div>

                            <!-- Contraseña -->
                            <div class="mb-2">
                                <label for="password" class="form-label">Contraseña</label>
                                <div class="input-wrap">
                                    <i class="bi bi-lock"></i>
                                    <input type="password" class="form-control" id="password" name="password"
                                           required minlength="6" placeholder="••••••••">
                                </div>
                            </div>

                            <div class="d-grid mt-4">
                                <button type="submit" class="btn btn-pro text-white">
                                    <i class="bi bi-box-arrow-in-right me-1"></i>
                                    Iniciar sesión
                                </button>
                            </div>

                            <div class="footer-note">
                                FarmaFácil • CEDI • <%= java.time.Year.now() %>
                            </div>
                        </form>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <script src="<%=request.getContextPath()%>/js/bundle.js"></script>
</body>
</html>