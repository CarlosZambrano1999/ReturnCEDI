<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="modelos.Almacen" %>

<!DOCTYPE html>
<html>
<head>
    <title>Almacenes</title>

    <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- DataTables (Bootstrap 5 + Responsive) -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/dataTables.bootstrap5.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/responsive/2.5.0/css/responsive.bootstrap5.min.css">
</head>

<body>

<div class="container mt-4">

    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3 class="m-0">Almacenes</h3>

        <button type="button" class="btn btn-primary"
                data-bs-toggle="modal" data-bs-target="#modalNuevoAlmacen">
            Nuevo Almacén
        </button>
    </div>

    <!-- (Opcional) mensajes por request cuando vienes con forward -->
    <%
        String error = (String) request.getAttribute("error");
        String success = (String) request.getAttribute("success");
        if (error != null) {
    %>
        <div class="alert alert-danger"><%= error %></div>
    <%
        }
        if (success != null) {
    %>
        <div class="alert alert-success"><%= success %></div>
    <%
        }
    %>

    <table id="tablaAlmacenes" class="table table-bordered table-hover align-middle nowrap" style="width:100%">
        <thead class="table-dark">
        <tr>
            <th style="width: 120px;">Código</th>
            <th>Departamento</th>
            <th style="width: 260px;">Estado</th>
            <th style="width: 120px;">Acciones</th>
        </tr>
        </thead>

        <tbody>
        <%
            List<Almacen> lista = (List<Almacen>) request.getAttribute("listaAlmacenes");

            if (lista != null && !lista.isEmpty()) {
                for (Almacen a : lista) {

                    String codigo = (a.getCodigo() == null) ? "" : a.getCodigo();
                    String depto  = (a.getDepartamento() == null) ? "" : a.getDepartamento();

                    String codigoSafe = codigo.replace("\"", "&quot;");
                    String deptoSafe  = depto.replace("\"", "&quot;");

                    int estado = a.getEstado();
        %>
            <tr>
                <td><%= codigo %></td>
                <td><%= depto %></td>

                <!-- Estado: botón centrado -->
                <td>
                    <div class="d-flex justify-content-center">
                        <%
                            if (estado == 1) {
                        %>
                        <form action="<%= request.getContextPath() %>/Almacen" method="post" class="m-0">
                            <input type="hidden" name="codigo" value="<%= codigoSafe %>">
                            <input type="hidden" name="accion" value="INACTIVAR">
                            <input type="hidden" name="action" value="INACTIVAR">
                            <button type="submit" class="btn btn-sm btn-outline-danger">
                                Inactivar
                            </button>
                        </form>
                        <%
                            } else {
                        %>
                        <form action="<%= request.getContextPath() %>/Almacen" method="post" class="m-0">
                            <input type="hidden" name="codigo" value="<%= codigoSafe %>">
                            <input type="hidden" name="accion" value="ACTIVAR">
                            <input type="hidden" name="action" value="ACTIVAR">
                            <button type="submit" class="btn btn-sm btn-outline-success">
                                Activar
                            </button>
                        </form>
                        <%
                            }
                        %>
                    </div>
                </td>

                <!-- Acciones: editar -->
                <td class="text-center">
                    <button type="button"
                            class="btn btn-sm btn-warning btnEditarAlmacen"
                            data-bs-toggle="modal"
                            data-bs-target="#modalEditarAlmacen"
                            data-codigo="<%= codigoSafe %>"
                            data-departamento="<%= deptoSafe %>">
                        Editar
                    </button>
                </td>
            </tr>
        <%
                }
            } else {
        %>
            <tr>
                <td colspan="4" class="text-center">No hay almacenes registrados</td>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>

</div>

<!-- ===================== MODAL NUEVO ALMACÉN ===================== -->
<div class="modal fade" id="modalNuevoAlmacen" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">

            <form action="<%= request.getContextPath() %>/Almacen" method="post">
                <input type="hidden" name="accion" value="INSERTAR">
                <input type="hidden" name="action" value="INSERTAR">

                <div class="modal-header">
                    <h5 class="modal-title">Nuevo Almacén</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Código</label>
                        <input type="text" name="codigo" class="form-control"
                               maxlength="10" placeholder="Ej: A001" required>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Departamento</label>
                        <input type="text" name="departamento" class="form-control"
                               maxlength="120" placeholder="Ej: Bodega Central" required>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Guardar</button>
                </div>
            </form>

        </div>
    </div>
</div>

<!-- ===================== MODAL EDITAR ALMACÉN ===================== -->
<div class="modal fade" id="modalEditarAlmacen" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">

            <form action="<%= request.getContextPath() %>/Almacen" method="post">
                <input type="hidden" name="accion" value="EDITAR">
                <input type="hidden" name="action" value="EDITAR">

                <div class="modal-header">
                    <h5 class="modal-title">Editar Almacén</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Código</label>
                        <input type="text" name="codigo" id="editCodigoAlmacen"
                               class="form-control" readonly>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Departamento</label>
                        <input type="text" name="departamento" id="editDepartamentoAlmacen"
                               class="form-control" maxlength="120" required>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                    <button type="submit" class="btn btn-warning">Guardar Cambios</button>
                </div>
            </form>

        </div>
    </div>
</div>

<!-- JS: Bootstrap -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- JS: jQuery + DataTables -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.datatables.net/responsive/2.5.0/js/dataTables.responsive.min.js"></script>
<script src="https://cdn.datatables.net/responsive/2.5.0/js/responsive.bootstrap5.min.js"></script>

<script>
    // Cargar datos al modal de edición
    document.addEventListener("click", function (e) {
        const btn = e.target.closest(".btnEditarAlmacen");
        if (!btn) return;

        document.getElementById("editCodigoAlmacen").value = btn.getAttribute("data-codigo");
        document.getElementById("editDepartamentoAlmacen").value = btn.getAttribute("data-departamento");
    });

    // Inicializar DataTable
    $(document).ready(function () {
        $('#tablaAlmacenes').DataTable({
            responsive: true,
            pageLength: 10,
            lengthMenu: [5, 10, 25, 50, 100],
            order: [[0, 'asc']], // Código asc
            columnDefs: [
                { orderable: false, targets: [2, 3] } // Estado y Acciones sin ordenar
            ],
            language: {
                url: "https://cdn.datatables.net/plug-ins/1.13.8/i18n/es-ES.json"
            }
        });
    });
</script>

<!-- SweetAlert2 -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<%
    String swalIcon  = (String) session.getAttribute("swalIcon");
    String swalTitle = (String) session.getAttribute("swalTitle");
    String swalText  = (String) session.getAttribute("swalText");

    String reqError = (String) request.getAttribute("error");

    session.removeAttribute("swalIcon");
    session.removeAttribute("swalTitle");
    session.removeAttribute("swalText");

    if (swalTitle != null) swalTitle = swalTitle.replace("\"", "\\\"");
    if (swalText  != null) swalText  = swalText.replace("\"", "\\\"");
    if (reqError  != null) reqError  = reqError.replace("\"", "\\\"");
%>

<script>
    <% if (swalTitle != null && swalIcon != null) { %>
    Swal.fire({
        icon: "<%= swalIcon %>",
        title: "<%= swalTitle %>",
        text: "<%= (swalText != null ? swalText : "") %>",
        confirmButtonText: "OK"
    });
    <% } %>

    <% if (reqError != null) { %>
    Swal.fire({
        icon: "error",
        title: "Error",
        text: "<%= reqError %>",
        confirmButtonText: "OK"
    });
    <% } %>
</script>

</body>
</html>
