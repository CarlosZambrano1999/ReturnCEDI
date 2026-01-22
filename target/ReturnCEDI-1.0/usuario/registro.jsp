<%@page import="java.util.List"%>
<%@page import="modelos.Rol"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Registro de Usuario</title>
        <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet">

        <!-- SweetAlert2 -->
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
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
            String val_storeId = (String) request.getAttribute("val_storeId");
        %>

        <div class="container mt-5">
            <div class="row justify-content-center">

                <!-- =======================================
                     CARD 1: REGISTRO NORMAL (tu formulario)
                     ======================================= -->
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
                                            java.util.List<modelos.Rol> roles
                                                    = (java.util.List<modelos.Rol>) request.getAttribute("roles");
                                            if (roles != null && !roles.isEmpty()) {
                                                for (modelos.Rol r : roles) {
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

                                <!-- Farmacia (datalist) -->
                                <div class="mb-3">
                                    <label for="storeId" class="form-label">Farmacia</label>
                                    <input list="farmaciaList" class="form-control" id="storeId" name="storeId"
                                           value="<%= (val_storeId != null ? val_storeId : "")%>"
                                           required placeholder="Busca o selecciona una farmacia">

                                    <datalist id="farmaciaList">
                                        <%
                                            java.util.List<modelos.Farmacia> farmacias
                                                    = (java.util.List<modelos.Farmacia>) request.getAttribute("farmacias");
                                            if (farmacias != null && !farmacias.isEmpty()) {
                                                for (modelos.Farmacia f : farmacias) {
                                        %>
                                        <option value="<%= f.getStoreId()%>"><%= f.getCentro() + " " + f.getFarmacia()%> </option>
                                        <%
                                                }
                                            }
                                        %>
                                    </datalist>
                                </div>

                                <!-- Estado -->
                                <div class="mb-3">
                                    <label for="estado" class="form-label">Estado</label>
                                    <select class="form-select" id="estado" name="estado">
                                        <option value="1" <%= "1".equals(val_estado) ? "selected" : ""%>>Activo</option>
                                        <option value="0" <%= "0".equals(val_estado) ? "selected" : ""%>>Inactivo</option>
                                    </select>
                                </div>

                                <!-- Botón Registrar -->
                                <div class="d-grid">
                                    <button type="submit" class="btn btn-success btn-lg">
                                        Registrar Usuario
                                    </button>
                                </div>

                                <!-- Botón abrir modal importación -->
                                <div class="d-grid mt-3">
                                    <button type="button" class="btn btn-dark btn-lg"
                                            data-bs-toggle="modal" data-bs-target="#modalImportUsuarios">
                                        Importar Usuarios desde Excel
                                    </button>
                                </div>

                            </form>

                        </div>
                    </div>
                </div>

            </div>
        </div>

        <!-- ===========================
             MODAL IMPORTAR USUARIOS EXCEL
             =========================== -->
        <div class="modal fade" id="modalImportUsuarios" tabindex="-1" aria-labelledby="modalImportUsuariosLabel" aria-hidden="true">
            <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
                <div class="modal-content border-0 shadow-lg">

                    <div class="modal-header bg-dark text-white">
                        <h5 class="modal-title" id="modalImportUsuariosLabel">Importar usuarios desde Excel</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                    </div>

                    <div class="modal-body">

                        <div class="alert alert-info mb-3">
                            <b>Formato esperado (Hoja 1)</b><br>
                            Columnas: <code>NOMBRE | CODIGO | PASSWORD | ID_ROL | STORE_ID | ESTADO</code><br>
                        </div>

                        <div class="row g-3 align-items-end">
                            <div class="col-md-8">
                                <label class="form-label">Selecciona Excel</label>
                                <input type="file" id="archivoExcel" class="form-control" accept=".xlsx">
                            </div>
                            <div class="col-md-4 d-grid">
                                <button type="button" class="btn btn-primary btn-lg" id="btnImportarExcel">
                                    Procesar
                                </button>
                            </div>
                        </div>

                        <hr>

                        <!-- Resumen -->
                        <div id="panelResumen" class="d-none">
                            <div class="row g-2">
                                <div class="col-6 col-md-3">
                                    <div class="p-2 bg-success text-white rounded text-center">
                                        <div class="fw-bold">Success</div>
                                        <div id="r_ok" style="font-size: 20px;">0</div>
                                    </div>
                                </div>
                                <div class="col-6 col-md-3">
                                    <div class="p-2 bg-warning text-dark rounded text-center">
                                        <div class="fw-bold">Duplicate</div>
                                        <div id="r_dup" style="font-size: 20px;">0</div>
                                    </div>
                                </div>
                                <div class="col-6 col-md-3">
                                    <div class="p-2 bg-danger text-white rounded text-center">
                                        <div class="fw-bold">Error</div>
                                        <div id="r_err" style="font-size: 20px;">0</div>
                                    </div>
                                </div>
                                <div class="col-6 col-md-3">
                                    <div class="p-2 bg-secondary text-white rounded text-center">
                                        <div class="fw-bold">Total</div>
                                        <div id="r_total" style="font-size: 20px;">0</div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Tabla detalle -->
                        <div class="table-responsive mt-3 d-none" id="panelDetalle">
                            <table class="table table-striped table-bordered align-middle">
                                <thead class="table-dark">
                                    <tr>
                                        <th style="width: 70px;">Fila</th>
                                        <th>Nombre</th>
                                        <th>Código</th>
                                        <th>Store</th>
                                        <th style="width: 120px;">Status</th>
                                        <th>Mensaje</th>
                                    </tr>
                                </thead>
                                <tbody id="tbodyImport"></tbody>
                            </table>
                        </div>

                    </div>

                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
                    </div>

                </div>
            </div>
        </div>

        <!-- Bootstrap JS (tu bundle) -->
        <script src="<%=request.getContextPath()%>/js/bundle.js"></script>

        <!-- JS Importación (MISMA LÓGICA) -->
        <script>
            const contextPath = "<%=request.getContextPath()%>";

            const inpExcel = document.getElementById("archivoExcel");
            const btnImport = document.getElementById("btnImportarExcel");

            const panelResumen = document.getElementById("panelResumen");
            const panelDetalle = document.getElementById("panelDetalle");
            const tbodyImport = document.getElementById("tbodyImport");

            const r_ok = document.getElementById("r_ok");
            const r_dup = document.getElementById("r_dup");
            const r_err = document.getElementById("r_err");
            const r_total = document.getElementById("r_total");

            btnImport.addEventListener("click", async () => {
                try {
                    if (!inpExcel.files || inpExcel.files.length === 0) {
                        Swal.fire("Falta archivo", "Selecciona un Excel .xlsx", "warning");
                        return;
                    }

                    const f = inpExcel.files[0];
                    if (!String(f.name).toLowerCase().endsWith(".xlsx")) {
                        Swal.fire("Archivo inválido", "Solo se permite .xlsx", "error");
                        return;
                    }

                    const fd = new FormData();
                    fd.append("archivo", f);

                    btnImport.disabled = true;
                    btnImport.textContent = "Importando...";

                    const resp = await fetch(contextPath + "/importarUsuariosExcel", {
                        method: "POST",
                        body: fd
                    });

                    const text = await resp.text();
                    let data;
                    try {
                        data = JSON.parse(text);
                    } catch (e) {
                        console.error("Respuesta no JSON:", text);
                        Swal.fire("Error", "El servidor no devolvió un JSON válido.", "error");
                        return;
                    }

                    if (!data || data.status !== "success") {
                        Swal.fire("Error", (data && data.message) ? data.message : "No se pudo importar.", "error");
                        return;
                    }

                    // Resumen
                    panelResumen.classList.remove("d-none");
                    r_ok.textContent = (data.resumen && data.resumen.success != null) ? data.resumen.success : 0;
                    r_dup.textContent = (data.resumen && data.resumen.duplicate != null) ? data.resumen.duplicate : 0;
                    r_err.textContent = (data.resumen && data.resumen.error != null) ? data.resumen.error : 0;
                    r_total.textContent = (data.resumen && data.resumen.total != null) ? data.resumen.total : 0;

                    // Detalle
                    tbodyImport.innerHTML = "";

                    (data.detalle || []).forEach(it => {
                        const fila   = (it && it.fila != null) ? it.fila : "";
                        const nombre = (it && it.nombre != null) ? it.nombre : "";
                        const codigo = (it && it.codigo != null) ? it.codigo : "";
                        const store  = (it && it.storeId != null) ? it.storeId : "";
                        const status = (it && it.status != null) ? it.status : "";
                        const msg    = (it && it.message != null) ? it.message : "";

                        const st = String(status).toLowerCase();
                        const badge =
                            st === "success" ? "bg-success" :
                            st === "duplicate" ? "bg-warning text-dark" :
                            "bg-danger";

                        const tr = document.createElement("tr");

                        tr.innerHTML =
                            '<td class="text-center">' + escapeHtml(fila) + '</td>' +
                            '<td>' + escapeHtml(nombre) + '</td>' +
                            '<td><b>' + escapeHtml(codigo) + '</b></td>' +
                            '<td>' + escapeHtml(store) + '</td>' +
                            '<td class="text-center"><span class="badge ' + badge + '">' + escapeHtml(status) + '</span></td>' +
                            '<td>' + escapeHtml(msg) + '</td>';

                        tbodyImport.appendChild(tr);
                    });

                    panelDetalle.classList.remove("d-none");

                    Swal.fire("Listo", "Importación finalizada.", "success");

                } catch (e) {
                    console.error(e);
                    Swal.fire("Error", "Ocurrió un error al importar.", "error");
                } finally {
                    btnImport.disabled = false;
                    btnImport.textContent = "Procesar";
                }
            });

            function escapeHtml(str) {
                if (str === null || str === undefined) return "";
                return String(str)
                    .replaceAll("&", "&amp;")
                    .replaceAll("<", "&lt;")
                    .replaceAll(">", "&gt;")
                    .replaceAll("\"", "&quot;")
                    .replaceAll("'", "&#039;");
            }
        </script>

    </body>
</html>
