<%-- 
    Document   : devoluciones
    Created on : 16 dic 2025, 15:37:34
    Author     : Administrador
--%>

<%@page import="modelos.InfoDocMaterial"%>
<%@page import="modelos.Incidencia"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="modelos.ComparativoDocMaterialRow"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Devoluciones - Escaneo</title>
        <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet">
        <link href="<%=request.getContextPath()%>/css/dataTables.css" rel="stylesheet">
        <link href="<%=request.getContextPath()%>/guia/estilos.css" rel="stylesheet">

    </head>
    <body>
        <div class="container py-4">

            <%
                Long doc = (Long) request.getAttribute("docMaterial");
                List<ComparativoDocMaterialRow> comparativo = (List<ComparativoDocMaterialRow>) request.getAttribute("comparativo");
                String msgType = (String) request.getAttribute("msgType");
                String msg = (String) request.getAttribute("msg");
                if (comparativo == null) {
                    comparativo = new ArrayList<>();
                }
                List<Incidencia> incidencias = (List<Incidencia>) request.getAttribute("incidencias");
                if (incidencias == null) {
                    incidencias = new ArrayList<>();
                }
                InfoDocMaterial infoDoc = (InfoDocMaterial) request.getAttribute("infoDoc");
            %>

            <h1>Devoluciones</h1>
            <div class="card shadow-sm mb-3">
                <div class="card-body p-4">

                    <% if (msg != null && !msg.trim().isEmpty()) {%>
                    <div class="alert alert-<%= "success".equals(msgType) ? "success" : ("warning".equals(msgType) ? "warning" : "danger")%>">
                        <%= msg%>
                    </div>
                    <% }%>

                    <!-- FORM: cargar documento -->
                    <form method="post" action="<%=request.getContextPath()%>/Devoluciones" class="row g-3 align-items-end">
                        <input type="hidden" name="accion" value="cargarDocumento"/>

                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Doc. Material</label>
                            <input type="text" class="form-control" name="docMaterial" id="docMaterial" value="<%= doc == null ? "" : doc%>" placeholder="Ej: 4900716458">
                        </div>

                        <div class="col-md-2 d-grid">
                            <button class="btn btn-primary" type="submit">Cargar</button>
                        </div>

                        <!-- FORM: escaneo (mismo action) -->
                        <div class="col-md-6">
                            <div class="input-group">
                                <input type="text" class="form-control" id="scanner" name="codigo" placeholder="Escanee el producto"
                                       <%= (doc == null ? "disabled" : "")%> form="formScan">
                            </div>
                        </div>
                    </form>

                    <!-- Form separado solo para scan, para que Enter haga POST scan -->
                    <form id="formScan" method="post" action="<%=request.getContextPath()%>/Devoluciones">
                        <input type="hidden" name="accion" value="scan"/>
                        <input type="hidden" name="docMaterial" value="<%= doc == null ? "" : doc%>"/>
                    </form>

                </div>
            </div>

            <div class="card shadow-sm mb-3">
                <div class="card-body">
                    <h6 class="mb-3">Información del Documento</h6>

                    <div class="row g-3">
                        <div class="col-md-4">
                            <div class="text-muted small">Almacén</div>
                            <div class="fw-bold"><%= (infoDoc == null ? "—" : infoDoc.getAlmacen())%></div>
                        </div>
                        <div class="col-md-4">
                            <div class="text-muted small">Departamento</div>
                            <div class="fw-bold"><%= (infoDoc == null ? "—" : infoDoc.getDepartamento())%></div>
                        </div>
                        <div class="col-md-4">
                            <div class="text-muted small">Farmacia</div>
                            <div class="fw-bold"><%= (infoDoc == null ? "—" : infoDoc.getFarmacia())%></div>
                        </div>
                    </div>

                </div>
            </div>
            <% if (doc != null) {%>
            <div class="d-flex justify-content-end mt-3">
                <form id="formCerrarGuia"
                      method="post"
                      action="<%=request.getContextPath()%>/Devoluciones">

                    <input type="hidden" name="accion" value="cerrarGuia">
                    <input type="hidden" name="docMaterial" value="<%= doc%>">

                    <button type="button"
                            id="btnCerrarGuia"
                            class="btn btn-danger">
                        Cerrar guía
                    </button>
                </form>
            </div>
            <% } %>

            <div class="card shadow-sm">
                <div class="card-body p-4">
                    <div class="table-responsive">
                        <table id="tabla" class="table table-hover align-middle w-100">
                            <thead>
                                <tr>
                                    <th>Estado</th>
                                    <th>Código SAP</th>
                                    <th>Descripción</th>
                                    <th>FC</th>
                                    <th>Presentación</th>
                                    <th class="text-end">Esperado</th>
                                    <th class="text-end">Escaneado</th>
                                    <th class="text-end">Diferencia</th>
                                    <th class="text-center">Editar</th>
                                    <th class="text-end"></th>

                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    for (ComparativoDocMaterialRow r : comparativo) {
                                        String est = (r.getEstado() == null) ? "OK" : r.getEstado();
                                        String pill = "OK".equals(est) ? "st-ok" : ("FALTANTE".equals(est) ? "st-f" : ("SOBRANTE".equals(est) ? "st-s" : "st-a"));
                                        String rowCls = "FALTANTE".equals(est) ? "row-f" : ("SOBRANTE".equals(est) ? "row-s" : ("ADICIONAL".equals(est) ? "row-a" : ""));
                                %>
                                <tr class="<%=rowCls%>">
                                    <td><span class="state-pill <%=pill%>"><%=est%></span></td>
                                    <td><%= r.getCodigoSap()%></td>
                                    <td><%= r.getDescripcion() == null ? "" : r.getDescripcion()%></td>
                                    <td><%= r.getFactor()%></td>
                                    <td><%= r.getPresentacion()%></td>
                                    <td class="text-end"><%= r.getCantidadEsperada().intValue()%></td>
                                    <td class="text-end"><%= r.getCantidadEscaneada().intValue()%></td>
                                    <td class="text-end"><%= r.getDiferencia().intValue()%></td>
                                    <% boolean esAdicional = "ADICIONAL".equalsIgnoreCase(r.getEstado());%>
                                    <td class="text-center">
                                        <div class="dropdown">
                                            <button class="btn btn-sm btn-outline-secondary dropdown-toggle"
                                                    type="button"
                                                    data-bs-toggle="dropdown"
                                                    aria-expanded="false"
                                                    <%= (r.getIdDevolucion() == null ? "disabled" : "")%>>
                                                Editar
                                            </button>

                                            <div class="dropdown-menu p-2" style="min-width: 260px;">
                                                <form method="post"
                                                      action="<%=request.getContextPath()%>/Devoluciones"
                                                      class="d-flex flex-column gap-2">

                                                    <input type="hidden" name="accion" value="editar">
                                                    <input type="hidden" name="docMaterial" value="<%= doc%>">
                                                    <input type="hidden" name="id" value="<%= r.getIdDevolucion() == null ? "" : r.getIdDevolucion()%>">

                                                    <div class="d-flex gap-2 justify-content-center align-items-center">
                                                        <label>Cantidad: </label>
                                                        <input type="number" step="1" name="cantidad"
                                                               class="form-control form-control-sm cell-input text-end"
                                                               value="<%= r.getCantidadEditable() == null ? "0" : r.getCantidadEditable().intValue()%>"
                                                               <%= (r.getIdDevolucion() == null ? "disabled" : "")%> >
                                                    </div>

                                                    <select name="incidenciaId" class="form-select form-select-sm cell-select"
                                                            <%= (r.getIdDevolucion() == null ? "disabled" : "")%>>

                                                        <option value="" <%= (r.getIncidenciaId() == null ? "selected" : "")%>>Sin incidencia</option>

                                                        <%
                                                            for (Incidencia inc : incidencias) {
                                                                if (inc.getEstado() != 1) {
                                                                    continue;
                                                                }

                                                                int idInc = inc.getId_incidencia();
                                                                boolean selected = (r.getIncidenciaId() != null && r.getIncidenciaId() == idInc);
                                                        %>
                                                        <option value="<%= idInc%>" <%= selected ? "selected" : ""%>>
                                                            <%= inc.getIncidencia()%>
                                                        </option>
                                                        <%
                                                            }
                                                        %>
                                                    </select>


                                                    <input type="text" name="observacion"
                                                           class="form-control form-control-sm cell-text"
                                                           value="<%= r.getObservacion() == null ? "" : r.getObservacion()%>"
                                                           placeholder="Observación..."
                                                           <%= (r.getIdDevolucion() == null ? "disabled" : "")%> >

                                                    <div class="d-flex justify-content-end">
                                                        <button type="submit"
                                                                class="btn btn-sm btn-outline-primary btn-guardar"
                                                                <%= (r.getIdDevolucion() == null ? "disabled" : "")%>>

                                                            <span class="btn-text">Guardar</span>
                                                            <span class="spinner-border spinner-border-sm d-none ms-1"
                                                                  role="status" aria-hidden="true"></span>
                                                        </button>
                                                    </div>        

                                                </form>
                                            </div>
                                        </div>

                                        <% if (r.getIdDevolucion() == null) { %>
                                        <div class="small text-muted mt-1">Escanee este Producto para habilitar edición</div>
                                        <% } %>
                                    </td>
                                    <td><% if (esAdicional && r.getIdDevolucion() != null) {%>
                                        <form method="post" action="<%=request.getContextPath()%>/Devoluciones"
                                              class="d-flex gap-2 justify-content-center align-items-center"
                                              onsubmit="return confirmarEliminar(this);">
                                            <input type="hidden" name="accion" value="eliminar">
                                            <input type="hidden" name="docMaterial" value="<%= doc%>">
                                            <input type="hidden" name="id" value="<%= r.getIdDevolucion()%>">

                                            <button type="submit" class="btn btn-sm btn-outline-danger btn-eliminar">
                                                <span class="btn-text">Eliminar</span>
                                                <span class="spinner-border spinner-border-sm d-none ms-1"
                                                      role="status" aria-hidden="true"></span>
                                            </button>
                                        </form>
                                        <% } %></td>

                                </tr>
                                <%
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

        </div>
                            
        <div id="pageSpinner" class="spinner-overlay d-none">
            <div class="spinner-border text-light" role="status" style="width: 4rem; height: 4rem;">
                <span class="visually-hidden">Cargando...</span>
            </div>
        </div>

        <script src="<%=request.getContextPath()%>/js/bundle.js"></script>
        <script src="<%=request.getContextPath()%>/js/jquery.js"></script>
        <script src="<%=request.getContextPath()%>/js/jqueryDataTables.js"></script>
        <script src="<%=request.getContextPath()%>/js/dataTablesBootstrap.js"></script>
        <script src="<%=request.getContextPath()%>/js/sweetalert2.js"></script>


        <script>
            $(function () {
                $("#tabla").DataTable({
        ordering: true,
        pageLength: 10,
        order: [], // sin orden inicial
        scrollX: true,          // ✅ clave
        autoWidth: false,       // ✅ evita cálculos raros
        responsive: false,      
        language: {
            url: '<%=request.getContextPath()%>/js/es-ES.json'
        },
        drawCallback: function () {
            keepFocus();
        }
    });

        // Mantener foco siempre en scanner si doc existe
        function keepFocus(force = false) {
            const scanner = document.getElementById("scanner");
            if (!scanner || scanner.disabled)
                return;

            // 🚫 Si está editando y no es forzado, NO mover foco
            if ((editandoFila || interactuandoTabla) && !force)
                return;

            scanner.focus();
            scanner.select();
        }


        // Al cargar, foco al scanner si hay doc, sino al docMaterial
        setTimeout(function () {
            const scanner = document.getElementById("scanner");
            const doc = document.getElementById("docMaterial");
            if (scanner && !scanner.disabled)
                keepFocus();
            else if (doc)
                doc.focus();
        }, 50);

        document.addEventListener("click", function () {
            setTimeout(keepFocus, 30);
        });
        document.addEventListener("keydown", (e) => {
            if (e.key === "Escape") {
                editandoFila = false;
                keepFocus(true);
            }
        });

        // Enter en scanner envía el formScan
        const scanner = document.getElementById("scanner");
        if (scanner) {
            scanner.addEventListener("keydown", function (e) {
                if (e.key === "Enter") {
                    e.preventDefault();
                    document.getElementById("formScan").submit();
                }
            });
        }
    });

    setTimeout(function () {
        const scanner = document.getElementById("scanner");
        if (scanner && !scanner.disabled) {
            scanner.focus();
            scanner.select();
        }
    }, 80);

    let editandoFila = false;
    let interactuandoTabla = false;

    document.addEventListener("focusin", (e) => {
        if (
                e.target.classList.contains("cell-input") ||
                e.target.classList.contains("cell-select") ||
                e.target.classList.contains("cell-text")
                ) {
            editandoFila = true;
        }
    });

    document.addEventListener("mousedown", function (e) {
        const tabla = document.getElementById("tabla");
        if (!tabla)
            return;

        if (tabla.contains(e.target)) {
            interactuandoTabla = true;
        } else {
            interactuandoTabla = false;
        }
    });

    document.addEventListener("focusout", (e) => {
        if (
                e.target.classList.contains("cell-input") ||
                e.target.classList.contains("cell-select") ||
                e.target.classList.contains("cell-text")
                ) {
            editandoFila = false;
            setTimeout(() => keepFocus(true), 80);
        }
    });

    document.addEventListener("submit", function (e) {
        const form = e.target;
        const dropdown = form.closest(".dropdown-menu");

        if (dropdown) {
            const bsDropdown = bootstrap.Dropdown.getInstance(
                    dropdown.previousElementSibling
                    );
            if (bsDropdown)
                bsDropdown.hide();
        }

        // Solo para forms de edición (guardar)
        const btn = form.querySelector(".btn-guardar");
        if (!btn)
            return;

        const spinner = btn.querySelector(".spinner-border");
        const text = btn.querySelector(".btn-text");

        // Activar spinner
        if (spinner)
            spinner.classList.remove("d-none");
        if (text)
            text.textContent = "Guardando...";

        // Deshabilitar botón para evitar doble submit
        btn.disabled = true;

        // Opcional: bloquear inputs de la fila
        const inputs = form.querySelectorAll("input, select");
        inputs.forEach(i => i.setAttribute("readonly", true));
    });

    document.addEventListener("DOMContentLoaded", function () {

        const btnCerrar = document.getElementById("btnCerrarGuia");
        const formCerrar = document.getElementById("formCerrarGuia");
        
        const form = document.querySelector("form[action$='/Excesos']");
        const spinner = document.getElementById("pageSpinner");

        if (form) {
            form.addEventListener("submit", function () {
                spinner.classList.remove("d-none");
            });
        }

        if (!btnCerrar || !formCerrar)
            return;

        btnCerrar.addEventListener("click", function () {

            Swal.fire({
                title: '¿Cerrar la guía?',
                text: 'Una vez cerrada no podrás seguir escaneando ni editando información.',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Sí, cerrar guía',
                cancelButtonText: 'Cancelar',
                reverseButtons: true
            }).then((result) => {
                if (result.isConfirmed) {

                    Swal.fire({
                        title: 'Cerrando guía...',
                        text: 'Por favor espera',
                        allowOutsideClick: false,
                        allowEscapeKey: false,
                        didOpen: () => {
                            Swal.showLoading();
                        }
                    });

                    formCerrar.submit(); // 👉 POST normal al servlet
                }
            });

        });

    });
        </script>
    </body>
</html>