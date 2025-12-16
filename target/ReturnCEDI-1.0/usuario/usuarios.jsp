<%@page import="modelos.Rol"%>
<%@page import="modelos.Usuario"%>
<%@page import="java.util.List"%>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Administrar Usuarios</title>
        <meta charset="UTF-8">

        <!-- Bootstrap CSS -->
        <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet">

        <!-- DataTables CSS (Bootstrap 5) -->
        <link rel="stylesheet" href="<%=request.getContextPath()%>/css/dataTables.css">

        <!-- SweetAlert2 -->
        <script src="<%=request.getContextPath()%>/js/sweetalert2.js"></script>

        <style>
            .table-wrap {
                overflow-x:auto;
            }
            .page-title {
                font-weight: 700;
            }
        </style>
    </head>
    <body class="bg-light">
        
        <jsp:include page="/componentes/navbar.jsp" />


        <div class="container py-4">

            <div class="d-flex justify-content-between align-items-center mb-3">
                <h2 class="page-title m-0">Administrar Usuarios</h2>
                <!-- Aquí podrías poner un botón "Regresar" al menú principal si quieres -->
            </div>

            <!-- Mensajes de éxito / error (desde sesión) -->
            <%
                Object msgOk = session.getAttribute("msg_ok");
                Object msgErr = session.getAttribute("msg_err");
                if (msgOk != null) {
            %>
            <script>
                Swal.fire({
                    icon: 'success',
                    title: 'Éxito',
                    text: '<%= msgOk.toString()%>',
                    confirmButtonText: 'Aceptar'
                });
            </script>
            <%
            } else if (msgErr != null) {
            %>
            <script>
                Swal.fire({
                    icon: 'error',
                    title: 'Error',
                    text: '<%= msgErr.toString()%>',
                    confirmButtonText: 'Aceptar'
                });
            </script>
            <%
                }
                session.removeAttribute("msg_ok");
                session.removeAttribute("msg_err");
            %>

            <!-- Error directo en request (por carga de datos) -->
            <%
                Object err = request.getAttribute("error");
                if (err != null) {
            %>
            <div class="alert alert-danger"><%= err%></div>
            <%
                }
            %>

            <!-- Tabla de usuarios -->
            <div class="card shadow-sm">
                <div class="card-body table-wrap">
                    <table id="tablaUsuarios" class="table table-striped table-bordered align-middle" style="width:100%;">
                        <thead class="table-light">
                            <tr>
                                <th>Nombre</th>
                                <th>Código</th>
                                <th>Rol</th>
                                <th>Estado</th>
                                <th>Editar</th>
                                <th>Contraseña</th> <!-- 👈 nueva -->
                                <th>Acción</th>    <!-- Activar/Inactivar -->
                            </tr>
                        </thead>

                        <tbody>
                            <%
                                List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
                                if (usuarios != null && !usuarios.isEmpty()) {
                                    for (Usuario u : usuarios) {
                            %>
                            <tr>
                                <td><%= u.getNombre()%></td>
                                <td><%= u.getCodigo()%></td>
                                <td><%= u.getRolNombre()%></td>
                                <td><%= (u.getEstado() == 1 ? "Activo" : "Inactivo")%></td>

                                <!-- EDITAR -->
                                <td class="text-center">
                                    <button type="button"
                                            class="btn btn-sm btn-warning btn-editar-usuario"
                                            data-id="<%= u.getIdUsuario()%>"
                                            data-nombre="<%= u.getNombre()%>"
                                            data-codigo="<%= u.getCodigo()%>"
                                            data-idrol="<%= u.getIdRol()%>">
                                        Editar
                                    </button>
                                </td>

                                <!-- CAMBIAR CONTRASEÑA -->
                                <td class="text-center">
                                    <button type="button"
                                            class="btn btn-sm btn-secondary btn-cambiar-pass"
                                            data-id="<%= u.getIdUsuario()%>"
                                            data-nombre="<%= u.getNombre()%>"
                                            data-codigo="<%= u.getCodigo()%>">
                                        Cambiar
                                    </button>
                                </td>

                                <!-- ACTIVAR / INACTIVAR -->
                                <td class="text-center">
                                    <form action="<%= request.getContextPath()%>/admin" method="post" style="display:inline;">
                                        <input type="hidden" name="accion" value="estado">
                                        <input type="hidden" name="id_usuario" value="<%= u.getIdUsuario()%>">
                                        <input type="hidden" name="nuevo_estado" value="<%= (u.getEstado() == 1 ? 0 : 1)%>">
                                        <button type="submit"
                                                class="btn btn-sm <%= (u.getEstado() == 1 ? "btn-outline-danger" : "btn-outline-success")%>">
                                            <%= (u.getEstado() == 1 ? "Inactivar" : "Activar")%>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                            <%
                                }
                            } else {
                            %>
                            <tr>
                                <td colspan="8" class="text-center text-muted">No hay usuarios registrados.</td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>

                    </table>
                </div>
            </div>
        </div>

        <!-- ============= MODAL EDITAR USUARIO ============= -->
        <div class="modal fade" id="modalEditarUsuario" tabindex="-1" aria-labelledby="modalEditarUsuarioLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-scrollable">
                <div class="modal-content">
                    <form action="<%= request.getContextPath()%>/admin" method="post">
                        <input type="hidden" name="accion" value="editar">
                        <input type="hidden" name="id_usuario" id="edit_id_usuario">

                        <div class="modal-header">
                            <h5 class="modal-title" id="modalEditarUsuarioLabel">Editar usuario</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                        </div>

                        <div class="modal-body">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label class="form-label">Nombre</label>
                                    <input type="text" name="nombre" id="edit_nombre" class="form-control" required>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Código (solo lectura)</label>
                                    <input type="text" id="edit_codigo" class="form-control" readonly>
                                </div>

                                <div class="col-md-6">
                                    <label class="form-label">Rol</label>
                                    <select name="idRol" id="edit_idRol" class="form-select" required>
                                        <option value="" disabled>Seleccione rol...</option>
                                        <%
                                            List<Rol> roles = (List<Rol>) request.getAttribute("roles");
                                            if (roles != null) {
                                                for (Rol r : roles) {
                                        %>
                                        <option value="<%= r.getId_rol()%>"><%= r.getRol()%></option>
                                        <%
                                                }
                                            }
                                        %>
                                    </select>
                                </div>

                              <!-- <div class="col-md-6">
                                    <label class="form-label">Nueva contraseña (opcional)</label>
                                    <input type="password" name="password" id="edit_password" class="form-control"
                                           placeholder="Déjelo en blanco para no cambiarla">
                                </div>-->
                            </div>
                        </div>

                        <div class="modal-footer">
                            <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
                            <button type="submit" class="btn btn-primary">Guardar cambios</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <!-- MODAL: Cambiar contraseña -->
        <div class="modal fade" id="modalCambiarPassword" tabindex="-1" aria-labelledby="modalCambiarPasswordLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <form action="<%= request.getContextPath()%>/admin" method="post">
                        <input type="hidden" name="accion" value="cambiar_password">
                        <input type="hidden" name="id_usuario" id="pass_id_usuario">

                        <div class="modal-header">
                            <h5 class="modal-title" id="modalCambiarPasswordLabel">Cambiar contraseña</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
                        </div>

                        <div class="modal-body">
                            <div class="mb-2">
                                <label class="form-label mb-0">Usuario</label>
                                <input type="text" id="pass_nombre" class="form-control" readonly>
                            </div>
                            <div class="mb-3">
                                <label class="form-label mb-0">Código</label>
                                <input type="text" id="pass_codigo" class="form-control" readonly>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Nueva contraseña</label>
                                <input type="password" name="password" id="pass_password" class="form-control" required>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Confirmar contraseña</label>
                                <input type="password" name="password_confirm" id="pass_password_confirm" class="form-control" required>
                            </div>
                        </div>

                        <div class="modal-footer">
                            <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
                            <button type="submit" class="btn btn-primary">Guardar contraseña</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>


        <!-- Bootstrap JS -->
        <script src="<%=request.getContextPath()%>/js/bundle.js"></script>

        <!-- jQuery -->
        <script src="<%=request.getContextPath()%>/js/jquery.js"></script>

        <!-- DataTables JS + Bootstrap 5 -->
        <script src="<%=request.getContextPath()%>/js/dataTables.js"></script>
        <script src="<%=request.getContextPath()%>/js/dataTablesBootstrap.js"></script>

        <script>
                $(function () {
                    $('#tablaUsuarios').DataTable({
                        pageLength: 25,
                        order: [[0, 'asc']],
                        language: {
                            processing: "Procesando...",
                            search: "Buscar:",
                            lengthMenu: "Mostrar _MENU_ registros",
                            info: "Mostrando _START_ a _END_ de _TOTAL_ registros",
                            infoEmpty: "Mostrando 0 a 0 de 0 registros",
                            infoFiltered: "(filtrado de _MAX_ registros totales)",
                            loadingRecords: "Cargando...",
                            zeroRecords: "No se encontraron resultados",
                            emptyTable: "No hay datos disponibles en la tabla",
                            paginate: {
                                first: "Primero",
                                previous: "Anterior",
                                next: "Siguiente",
                                last: "Último"
                            },
                            aria: {
                                sortAscending: ": activar para ordenar la columna ascendente",
                                sortDescending: ": activar para ordenar la columna descendente"
                            }
                        }
                    });
                });

                // Rellenar modal de edición
                document.addEventListener('DOMContentLoaded', function () {
                    const editarBtns = document.querySelectorAll('.btn-editar-usuario');

                    editarBtns.forEach(btn => {
                        btn.addEventListener('click', function () {
                            const id = this.getAttribute('data-id');
                            const nombre = this.getAttribute('data-nombre');
                            const codigo = this.getAttribute('data-codigo');
                            const idRol = this.getAttribute('data-idrol');

                            document.getElementById('edit_id_usuario').value = id;
                            document.getElementById('edit_nombre').value = nombre;
                            document.getElementById('edit_codigo').value = codigo;
                            document.getElementById('edit_idRol').value = idRol;
                            

                            const modal = new bootstrap.Modal(document.getElementById('modalEditarUsuario'));
                            modal.show();
                        });
                    });
                });
        </script>
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                // Botones Cambiar contraseña
                const passBtns = document.querySelectorAll('.btn-cambiar-pass');

                passBtns.forEach(btn => {
                    btn.addEventListener('click', function () {
                        const id = this.getAttribute('data-id');
                        const nombre = this.getAttribute('data-nombre');
                        const codigo = this.getAttribute('data-codigo');

                        document.getElementById('pass_id_usuario').value = id;
                        document.getElementById('pass_nombre').value = nombre;
                        document.getElementById('pass_codigo').value = codigo;
                        document.getElementById('pass_password').value = "";
                        document.getElementById('pass_password_confirm').value = "";

                        const modal = new bootstrap.Modal(document.getElementById('modalCambiarPassword'));
                        modal.show();
                    });
                });
            });
        </script>
    </body>
</html>
