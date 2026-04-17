<%-- 
    Document   : consultarPolitica
    Created on : 18 dic 2025, 09:53:14
    Author     : Administrador
--%>

<%@page import="java.util.ArrayList"%>
<%@page import="modelos.EvaluacionPolitica"%>
<%@page import="modelos.PoliticaDevolucion"%>
<%@page import="modelos.ColorPolitica"%>
<%@page import="modelos.ProveedorPolitica"%>
<%@page import="java.util.List"%>
<%@page import="modelos.Producto"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <title>Consultar Política</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet">
        <script src="<%=request.getContextPath()%>/js/sweetalert2.js"></script>
        <link href="<%=request.getContextPath()%>/politica/consultar/estilos.css" rel="stylesheet">

        <style>
            .compact-card .card-body {
                padding: 0.75rem 1rem;
            }
            .compact-label {
                font-size: 0.82rem;
                margin-bottom: 0.2rem;
            }
            .product-summary {
                font-size: 0.9rem;
            }
            .product-summary .label {
                color: #6c757d;
                font-size: 0.78rem;
                display: block;
                line-height: 1.1;
            }
            .product-summary .value {
                font-weight: 600;
                line-height: 1.2;
            }
            .mono {
                font-family: Consolas, Monaco, monospace;
            }
        </style>
    </head>
    <body>

        <jsp:include page="/componentes/navbar.jsp" />

        <div id="spinnerBuscar"
             class="d-none position-fixed top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center bg-white bg-opacity-75"
             style="z-index: 2000;">
            <div class="text-center">
                <div class="spinner-border text-primary" role="status"></div>
                <div class="mt-2 fw-semibold text-muted">Buscando información...</div>
            </div>
        </div>

        <div class="container-fluid py-3">

            <%
                String msgType = (String) request.getAttribute("msgType");
                String msg = (String) request.getAttribute("msg");

                Producto producto = (Producto) request.getAttribute("producto");
                List<ProveedorPolitica> proveedores = (List<ProveedorPolitica>) request.getAttribute("proveedores");
                List<ColorPolitica> colores = (List<ColorPolitica>) request.getAttribute("colores");
                PoliticaDevolucion politica = (PoliticaDevolucion) request.getAttribute("politica");
                EvaluacionPolitica evaluacion = (EvaluacionPolitica) request.getAttribute("evaluacion");

                String codigo = (String) request.getAttribute("codigo");
                String idProveedorSel = (String) request.getAttribute("idProveedor");
                Integer idColorSel = (Integer) request.getAttribute("idColor");
                String fechaVencSel = (String) request.getAttribute("fechaVencimiento");

                if (proveedores == null) {
                    proveedores = new ArrayList<>();
                }
                if (colores == null) {
                    colores = new ArrayList<>();
                }
                if (codigo == null) {
                    codigo = "";
                }
                if (idProveedorSel == null) {
                    idProveedorSel = "";
                }
                if (fechaVencSel == null) {
                    fechaVencSel = "";
                }

                boolean productoCargado = (producto != null);
                boolean proveedorSeleccionado = !idProveedorSel.isEmpty();
            %>

            <% if (msg != null && !msg.trim().isEmpty()) {%>
            <script>
                document.addEventListener("DOMContentLoaded", function () {
                    Swal.fire({
                        icon: "<%= "success".equals(msgType) ? "success" : ("warning".equals(msgType) ? "warning" : "error")%>",
                        title: "<%= "success".equals(msgType) ? "Listo" : ("warning".equals(msgType) ? "Atención" : "Error")%>",
                        text: "<%= msg.replace("\"", "\\\"")%>",
                        timer: 2200,
                        showConfirmButton: false
                    });
                });
            </script>
            <% }%>

            <!-- Formularios base -->
            <form id="formBuscar" method="post" action="<%=request.getContextPath()%>/ConsultarPolitica">
                <input type="hidden" name="accion" value="buscarProducto">
            </form>

            <form id="formProveedor" method="post" action="<%=request.getContextPath()%>/ConsultarPolitica">
                <input type="hidden" name="accion" value="cargarColores">
                <input type="hidden" name="codigo" value="<%= codigo%>">
            </form>

            <form id="formConsultar" method="post" action="<%=request.getContextPath()%>/ConsultarPolitica">
                <input type="hidden" name="accion" value="consultarPolitica">
                <input type="hidden" name="codigo" value="<%= codigo%>">
                <input type="hidden" name="idProveedor" value="<%= idProveedorSel%>" id="hiddenProveedor">
            </form>

            <!-- Barra superior compacta -->
            <div class="card shadow-sm compact-card mb-2">
                <div class="card-body">
                    <div class="d-flex flex-column flex-lg-row align-items-lg-end justify-content-between gap-2 mb-2">
                        <div>
                            <h5 class="mb-0">Consultar Política</h5>
                            <div class="text-muted small">Escaneá un producto, elegí proveedor, color y fecha para evaluar.</div>
                        </div>
                        <% if (!codigo.isEmpty()) {%>
                        <span class="badge bg-secondary">Código: <%= codigo%></span>
                        <% }%>
                    </div>

                    <!-- Fila 1 -->
                    <div class="row g-2 align-items-end mb-2">
                        <div class="col-md-9 col-lg-9">
                            <label class="form-label fw-semibold compact-label" for="scanner">Scanner</label>
                            <input type="text"
                                   class="form-control form-control-sm"
                                   id="scanner"
                                   name="codigo"
                                   form="formBuscar"
                                   placeholder="Escaneá y presioná Enter"
                                   autocomplete="off"
                                   value="<%= codigo%>">
                        </div>

                        <div class="col-md-3 col-lg-3 d-grid">
                            <button class="btn btn-sm btn-primary" type="submit" form="formBuscar">
                                Buscar
                            </button>
                        </div>
                    </div>

                    <!-- Fila 2 -->
                    <div class="row g-2 align-items-end">
                        <div class="col-md-4 col-lg-4">
                            <label class="form-label fw-semibold compact-label" for="idProveedor">Proveedor</label>
                            <div class="position-relative">
                                <select name="idProveedor"
                                        id="idProveedor"
                                        class="form-select form-select-sm"
                                        form="formProveedor"
                                        <%= !productoCargado ? "disabled" : ""%>>
                                    <option value="">-- Seleccionar --</option>
                                    <%
                                        for (ProveedorPolitica p : proveedores) {
                                            boolean sel = p.getIdProveedor() != null && p.getIdProveedor().equals(idProveedorSel);
                                    %>
                                    <option value="<%= p.getIdProveedor()%>" <%= sel ? "selected" : ""%>>
                                        <%= p.getProveedorNombre()%>
                                    </option>
                                    <% }%>
                                </select>

                                <div id="spinnerProveedor"
                                     class="d-none position-absolute top-50 end-0 translate-middle-y me-3">
                                    <span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
                                </div>
                            </div>
                        </div>

                        <div class="col-md-3 col-lg-3">
                            <label class="form-label fw-semibold compact-label" for="idColor">Color</label>
                            <select name="idColor"
                                    id="idColor"
                                    class="form-select form-select-sm"
                                    form="formConsultar"
                                    <%= (!productoCargado || !proveedorSeleccionado) ? "disabled" : ""%>>
                                <option value="">-- Seleccionar --</option>
                                <%
                                    for (ColorPolitica c : colores) {
                                        boolean sel = (idColorSel != null && c.getIdColor() == idColorSel);
                                %>
                                <option value="<%= c.getIdColor()%>" <%= sel ? "selected" : ""%>>
                                    <%= c.getColor()%>
                                </option>
                                <% }%>
                            </select>
                        </div>

                        <div class="col-md-2 col-lg-2">
                            <label class="form-label fw-semibold compact-label" for="fechaVencimiento">Vencimiento</label>
                            <input type="date"
                                   class="form-control form-control-sm"
                                   id="fechaVencimiento"
                                   name="fechaVencimiento"
                                   form="formConsultar"
                                   value="<%= fechaVencSel%>"
                                   <%= (!productoCargado || !proveedorSeleccionado) ? "disabled" : ""%>>
                        </div>

                        <div class="col-md-2 col-lg-2 d-grid">
                            <button class="btn btn-sm btn-success"
                                    id="btnConsultar"
                                    type="submit"
                                    form="formConsultar"
                                    <%= (!productoCargado || !proveedorSeleccionado) ? "disabled" : ""%>>
                                Consultar
                            </button>
                        </div>

                        <div class="col-md-1 col-lg-1 d-grid">
                            <a class="btn btn-sm btn-outline-secondary"
                               href="<%=request.getContextPath()%>/ConsultarPolitica"
                               title="Limpiar">
                                ↺
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Resumen producto -->
            <div class="card shadow-sm compact-card mb-2">
                <div class="card-body">
                    <% if (!productoCargado) { %>
                    <div class="text-muted small">Escaneá un producto para ver la información.</div>
                    <% } else {%>
                    <div class="row g-2 product-summary">
                        <div class="col-md-4 col-lg-4">
                            <span class="label">Producto</span>
                            <div class="value"><%= producto.getProducto()%></div>
                        </div>

                        <div class="col-md-2 col-lg-2">
                            <span class="label">Código</span>
                            <div class="value mono"><%= producto.getCodigo()%></div>
                        </div>

                        <div class="col-md-2 col-lg-2">
                            <span class="label">Código SAP</span>
                            <div class="value mono"><%= producto.getCodigoSap()%></div>
                        </div>

                        <div class="col-md-2 col-lg-2">
                            <span class="label">Laboratorio</span>
                            <div class="value"><%= producto.getLaboratorio()%></div>
                        </div>

                        <div class="col-md-1 col-lg-1">
                            <span class="label">Factor</span>
                            <div class="value mono"><%= producto.getFactor() == null ? "—" : producto.getFactor().intValue()%></div>
                        </div>

                        <div class="col-md-1 col-lg-1">
                            <span class="label">Segmento</span>
                            <div class="value"><%= producto.getSegmento() == null ? "—" : producto.getSegmento()%></div>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>

            <!-- Resultado -->
            <div class="card shadow-sm compact-card" id="bloqueResultado">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <h6 class="mb-0">Resultado</h6>
                    </div>

                    <% if (evaluacion == null) { %>
                    <div class="text-muted small">Consultá una política para ver el resultado.</div>
                    <% } else { %>
                    <%
                        String res = evaluacion.getResultado();
                        String pillClass = "pill-info";

                        if ("OK".equals(res))
                            pillClass = "pill-ok";
                        else if ("ANTICIPADO".equals(res))
                            pillClass = "pill-warn";
                        else if ("FUERA".equals(res))
                            pillClass = "pill-bad";
                        else if ("NO_DEVOLUTIVO".equals(res))
                            pillClass = "pill-bad";
                    %>

                    <!-- Cabecera del resultado -->
                    <div class="d-flex flex-column flex-md-row align-items-md-center justify-content-between gap-2 mb-3">
                        <div class="d-flex flex-wrap align-items-center gap-2">
                            <span class="pill <%= pillClass%>"><%= res%></span>
                            <div class="fw-bold"><%= evaluacion.getMensaje()%></div>
                        </div>

                        <div class="text-muted small">
                            Política aplicada:
                            <span class="fw-semibold">
                                <%= (politica == null || politica.getTiempo() == null) ? "—" : politica.getTiempo()%> meses
                            </span>
                        </div>
                    </div>

                    <!-- Resumen compacto -->
                    <div class="row g-2">
                        <div class="col-6 col-md-2">
                            <div class="border rounded-3 px-2 py-2 h-100 bg-light-subtle">
                                <div class="text-muted small">Meses</div>
                                <div class="fw-bold mono fs-6"><%= evaluacion.getMesesRestantes()%></div>
                            </div>
                        </div>

                        <div class="col-6 col-md-2">
                            <div class="border rounded-3 px-2 py-2 h-100 bg-light-subtle">
                                <div class="text-muted small">Tiempo</div>
                                <div class="fw-bold mono fs-6"><%= (politica == null ? "—" : politica.getTiempo())%></div>
                            </div>
                        </div>

                        <div class="col-6 col-md-2">
                            <div class="border rounded-3 px-2 py-2 h-100 bg-light-subtle">
                                <div class="text-muted small">Fracciones</div>
                                <div class="fw-bold mono fs-6"><%= (politica == null ? "—" : politica.getFracciones())%></div>
                            </div>
                        </div>

                        <div class="col-12 col-md-6">
                            <div class="border rounded-3 px-2 py-2 h-100">
                                <div class="text-muted small">Observaciones</div>
                                <div class="fw-semibold small">
                                    <%= (politica == null || politica.getObservaciones() == null || politica.getObservaciones().trim().isEmpty())
                                            ? "—"
                                            : politica.getObservaciones()%>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% }%>
                </div>
            </div>

        </div>

        <script src="<%=request.getContextPath()%>/js/bundle.js"></script>
        <script src="<%=request.getContextPath()%>/politica/funciones.js"></script>

    </body>
</html>