<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="modelos.Incidencia" %>

<!DOCTYPE html>
<html>
    <head>
        <title>Incidencias</title>

        <!-- Bootstrap -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

        <!-- DataTables (Bootstrap 5 + Responsive) -->
        <link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/dataTables.bootstrap5.min.css">
        <link rel="stylesheet" href="https://cdn.datatables.net/responsive/2.5.0/css/responsive.bootstrap5.min.css">
    </head>

    <body>

        <div class="container mt-4">

            <div class="d-flex justify-content-between align-items-center mb-3">
                <h3 class="m-0">Incidencias</h3>

                <button type="button" class="btn btn-primary"
                        data-bs-toggle="modal" data-bs-target="#modalNuevaIncidencia">
                    Nueva Incidencia
                </button>
            </div>

            <!-- (Opcional) Alertas por request si vienes con forward -->
            <%
                String error = (String) request.getAttribute("error");
                String success = (String) request.getAttribute("success");
                if (error != null) {
            %>
            <div class="alert alert-danger"><%= error%></div>
            <%
                }
                if (success != null) {
            %>
            <div class="alert alert-success"><%= success%></div>
            <%
                }
            %>

            <table id="tablaIncidencias" class="table table-bordered table-hover align-middle nowrap" style="width:100%">
                <thead class="table-dark">
                    <tr>
                        <th style="width: 90px;">ID</th>
                        <th>Incidencia</th>
                        <th style="width: 260px;">Estado</th>
                        <th style="width: 120px;">Acciones</th>
                    </tr>
                </thead>

                <tbody>
                    <%
                        List<Incidencia> lista = (List<Incidencia>) request.getAttribute("listaIncidencias");

                        if (lista != null && !lista.isEmpty()) {
                            for (Incidencia i : lista) {

                                int id = i.getId_incidencia();
                                String nombre = (i.getIncidencia() == null) ? "" : i.getIncidencia();
                                String nombreSafe = nombre.replace("\"", "&quot;");
                                int estado = i.getEstado();
                    %>
                    <tr>
                        <td><%= id%></td>
                        <td><%= nombre%></td>

                        <!-- Estado: botón centrado -->
                        <td>
                            <div class="d-flex justify-content-center">
                                <%
                                    if (estado == 1) {
                                %>
                                <form action="<%= request.getContextPath()%>/Incidencia" method="post" class="m-0">
                                    <input type="hidden" name="id_incidencia" value="<%= id%>">
                                    <input type="hidden" name="accion" value="INACTIVAR">
                                    <input type="hidden" name="action" value="INACTIVAR">
                                    <button type="submit" class="btn btn-sm btn-outline-danger">
                                        Inactivar
                                    </button>
                                </form>
                                <%
                                } else {
                                %>
                                <form action="<%= request.getContextPath()%>/Incidencia" method="post" class="m-0">
                                    <input type="hidden" name="id_incidencia" value="<%= id%>">
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
                                    class="btn btn-sm btn-warning btnEditar"
                                    data-bs-toggle="modal"
                                    data-bs-target="#modalEditarIncidencia"
                                    data-id="<%= id%>"
                                    data-incidencia="<%= nombreSafe%>">
                                Editar
                            </button>
                        </td>
                    </tr>
                    <%
                        }
                    } else {
                    %>
                    <tr>
                        <td colspan="4" class="text-center">No hay incidencias registradas</td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>

        </div>

        <!-- ===================== MODAL NUEVA INCIDENCIA ===================== -->
        <div class="modal fade" id="modalNuevaIncidencia" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">

                    <form action="<%= request.getContextPath()%>/Incidencia" method="post">
                        <input type="hidden" name="accion" value="INSERTAR">
                        <input type="hidden" name="action" value="INSERTAR">

                        <div class="modal-header">
                            <h5 class="modal-title">Nueva Incidencia</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>

                        <div class="modal-body">
                            <div class="mb-3">
                                <label class="form-label">Incidencia</label>
                                <input type="text" name="incidencia" class="form-control"
                                       placeholder="Ingrese la incidencia" required>
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

        <!-- ===================== MODAL EDITAR INCIDENCIA ===================== -->
        <div class="modal fade" id="modalEditarIncidencia" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">

                    <form action="<%= request.getContextPath()%>/Incidencia" method="post">
                        <input type="hidden" name="accion" value="EDITAR">
                        <input type="hidden" name="action" value="EDITAR">
                        <input type="hidden" name="id_incidencia" id="editIdIncidencia">

                        <div class="modal-header">
                            <h5 class="modal-title">Editar Incidencia</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>

                        <div class="modal-body">
                            <div class="mb-3">
                                <label class="form-label">Incidencia</label>
                                <input type="text" name="incidencia" id="editIncidencia"
                                       class="form-control" required>
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
                const btn = e.target.closest(".btnEditar");
                if (!btn)
                    return;

                document.getElementById("editIdIncidencia").value = btn.getAttribute("data-id");
                document.getElementById("editIncidencia").value = btn.getAttribute("data-incidencia");
            });

            // Inicializar DataTable
            $(document).ready(function () {
                $('#tablaIncidencias').DataTable({
                    responsive: true,
                    pageLength: 10,
                    lengthMenu: [5, 10, 25, 50, 100],
                    order: [[0, 'desc']],
                    columnDefs: [
                        {orderable: false, targets: [2, 3]}
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
            String swalIcon = (String) session.getAttribute("swalIcon");
            String swalTitle = (String) session.getAttribute("swalTitle");
            String swalText = (String) session.getAttribute("swalText");

            String reqError = (String) request.getAttribute("error");

            // limpiar flash
            session.removeAttribute("swalIcon");
            session.removeAttribute("swalTitle");
            session.removeAttribute("swalText");

            if (swalTitle != null) {
                swalTitle = swalTitle.replace("\"", "\\\"");
            }
            if (swalText != null) {
                swalText = swalText.replace("\"", "\\\"");
            }
            if (reqError != null)
                reqError = reqError.replace("\"", "\\\"");
        %>

        <script>
            <% if (swalTitle != null && swalIcon != null) {%>
    Swal.fire({
        icon: "<%= swalIcon%>",
        title: "<%= swalTitle%>",
        text: "<%= (swalText != null ? swalText : "")%>",
        confirmButtonText: "OK"
    });
            <% } %>

            <% if (reqError != null) {%>
    Swal.fire({
        icon: "error",
        title: "Error",
        text: "<%= reqError%>",
        confirmButtonText: "OK"
    });
            <% }%>
        </script>

    </body>
</html>
