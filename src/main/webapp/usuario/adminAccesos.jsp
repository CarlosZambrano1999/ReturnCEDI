<%-- 
    Document   : adminAccesos
    Created on : 23 ene 2026, 10:17:31
    Author     : Administrador
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Administración - Roles y Módulos</title>

    <!-- Bootstrap -->
    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet">

    <!-- DataTables -->
    <link href="<%=request.getContextPath()%>/css/dataTables.css" rel="stylesheet">

    <!-- (Opcional) tu css -->
    <link href="<%=request.getContextPath()%>/guia/estilos.css" rel="stylesheet">
    
    <script src="<%=request.getContextPath()%>/js/bundle.js"></script>

</head>
<body>
<jsp:include page="/componentes/navbar.jsp" />

<div class="container py-4">
    <div class="d-flex align-items-center justify-content-between mb-3">
        <div>
            <h4 class="mb-0">Administración</h4>
            <small class="text-muted">Gestión de roles, módulos y accesos.</small>
        </div>
        <div class="d-flex gap-2">
            <button class="btn btn-success" id="btnOpenNuevoRol">
                + Nuevo Rol
            </button>
            <button class="btn btn-success" id="btnOpenNuevoModulo">
                + Nuevo Módulo
            </button>
        </div>
    </div>

    <div class="row g-3">
        <!-- Col izquierda: Asignación -->
        <div class="col-lg-8">
            <div class="card shadow-sm">
                <div class="card-header d-flex align-items-center justify-content-between">
                    <div>
                        <h6 class="mb-0">Accesos por Rol</h6>
                        <small class="text-muted">Selecciona un rol y marca los módulos permitidos.</small>
                    </div>
                    <div class="d-flex gap-2">
                        <button id="btnRecargarTodo" class="btn btn-outline-secondary btn-sm">Recargar</button>
                        <button id="btnGuardarPermisos" class="btn btn-primary btn-sm">Guardar permisos</button>
                    </div>
                </div>

                <div class="card-body">
                    <div class="row g-2 mb-3">
                        <div class="col-md-8">
                            <label class="form-label">Rol</label>
                            <select id="selectRol" class="form-select">
                                <option value="">Cargando roles...</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Estado del rol</label>
                            <div class="d-flex gap-2">
                                <button id="btnRolActivar" class="btn btn-outline-success w-100">Activar</button>
                                <button id="btnRolInactivar" class="btn btn-outline-danger w-100">Inactivar</button>
                            </div>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table id="tablaModulos" class="table table-bordered table-striped table-sm align-middle w-100">
                            <thead>
                                <tr>
                                    <th style="width:70px;" class="text-center">Acceso</th>
                                    <th>Módulo</th>
                                    <th style="width:120px;" class="text-center">Estado</th>
                                    <th style="width:180px;" class="text-center">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <!-- JS -->
                            </tbody>
                        </table>
                    </div>

                    <div class="mt-2 small text-muted">
                        “Acceso” = relación Rol↔Módulo. “Estado” = estado del módulo.
                    </div>
                </div>
            </div>
        </div>

        <!-- Col derecha: panel ayuda / info -->
        <div class="col-lg-4">
            <div class="card shadow-sm">
                <div class="card-header">
                    <h6 class="mb-0">Acciones rápidas</h6>
                </div>
                <div class="card-body">
                    <ul class="mb-0">
                        <li>Creá roles y módulos con los botones superiores.</li>
                        <li>Seleccioná un rol para ver sus accesos.</li>
                        <li>Marcá los módulos y guardá permisos.</li>
                        <li>Podés activar/inactivar módulos desde la tabla.</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Modal: Nuevo Rol -->
<div class="modal fade" id="modalNuevoRol" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Nuevo Rol</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>
      <div class="modal-body">
        <label class="form-label">Nombre del rol</label>
        <input type="text" class="form-control" id="txtNuevoRol" placeholder="Ej: Administrador">
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
        <button class="btn btn-success" id="btnCrearRol">Crear</button>
      </div>
    </div>
  </div>
</div>

<!-- Modal: Nuevo Módulo -->
<div class="modal fade" id="modalNuevoModulo" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Nuevo Módulo</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>

      <div class="modal-body">
        <div class="row g-3">

          <div class="col-md-6">
            <label class="form-label">Ruta (MODULO)</label>
            <input type="text" class="form-control" id="txtNuevoModuloRuta" placeholder="/Devoluciones">
            <small class="text-muted">Debe iniciar con /</small>
          </div>

          <div class="col-md-6">
            <label class="form-label">Título</label>
            <input type="text" class="form-control" id="txtNuevoModuloTitulo" placeholder="Devoluciones">
          </div>

          <div class="col-md-12">
            <label class="form-label">Descripción</label>
            <textarea class="form-control" id="txtNuevoModuloDescripcion" rows="2" placeholder="Descripción corta para el Home..."></textarea>
          </div>

          <div class="col-md-4">
            <label class="form-label">Icono (Bootstrap Icons)</label>
            <input type="text" class="form-control" id="txtNuevoModuloIcono" placeholder="bi-arrow-repeat">
            <small class="text-muted">Ej: bi-gift, bi-search, bi-bar-chart</small>
          </div>

          <div class="col-md-4">
            <label class="form-label">Categoría</label>
            <select class="form-select" id="txtNuevoModuloCategoria">
              <option value="OPERACION">OPERACION</option>
              <option value="INCIDENCIAS">INCIDENCIAS</option>
              <option value="REPORTES">REPORTES</option>
              <option value="ADMIN">ADMIN</option>
              <option value="OTROS" selected>OTROS</option>
            </select>
          </div>

          <div class="col-md-4">
            <label class="form-label">Orden</label>
            <input type="number" class="form-control" id="txtNuevoModuloOrden" placeholder="9999">
          </div>

        </div>
      </div>

      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
        <button class="btn btn-success" id="btnCrearModulo">Crear</button>
      </div>
    </div>
  </div>
</div>


<!-- Modal: Editar Módulo -->
<div class="modal fade" id="modalEditarModulo" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Editar Módulo</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>

      <div class="modal-body">
        <input type="hidden" id="editIdModulo">

        <div class="row g-3">

          <div class="col-md-6">
            <label class="form-label">Ruta (MODULO)</label>
            <input type="text" class="form-control" id="editRutaModulo" placeholder="/Devoluciones">
          </div>

          <div class="col-md-6">
            <label class="form-label">Título</label>
            <input type="text" class="form-control" id="editTituloModulo" placeholder="Devoluciones">
          </div>

          <div class="col-md-12">
            <label class="form-label">Descripción</label>
            <textarea class="form-control" id="editDescripcionModulo" rows="2"></textarea>
          </div>

          <div class="col-md-4">
            <label class="form-label">Icono</label>
            <input type="text" class="form-control" id="editIconoModulo" placeholder="bi-arrow-repeat">
          </div>

          <div class="col-md-4">
            <label class="form-label">Categoría</label>
            <select class="form-select" id="editCategoriaModulo">
              <option value="OPERACION">OPERACION</option>
              <option value="INCIDENCIAS">INCIDENCIAS</option>
              <option value="REPORTES">REPORTES</option>
              <option value="ADMIN">ADMIN</option>
              <option value="OTROS">OTROS</option>
            </select>
          </div>

          <div class="col-md-4">
            <label class="form-label">Orden</label>
            <input type="number" class="form-control" id="editOrdenModulo" placeholder="9999">
          </div>

        </div>
      </div>

      <div class="modal-footer">
        <button class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
        <button class="btn btn-primary" id="btnGuardarEditarModulo">Guardar</button>
      </div>
    </div>
  </div>
</div>


<!-- JS libs -->
<script src="<%=request.getContextPath()%>/js/jquery.js"></script>
<script src="<%=request.getContextPath()%>/js/bootstrap.js"></script>
<script src="<%=request.getContextPath()%>/js/bundle.js"></script>
<script src="<%=request.getContextPath()%>/js/dataTables.js"></script>
<script src="<%=request.getContextPath()%>/js/sweetalert2.js"></script>

<!-- TU JS -->
<script>
  // disponible para el archivo externo
  window.CTX = "<%=request.getContextPath()%>";
</script>
<script src="<%=request.getContextPath()%>/js/adminAccesos.js"></script>
</body>
</html>

