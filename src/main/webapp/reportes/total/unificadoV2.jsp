<%-- 
    Document   : unificadoV2
    Created on : 30 jun 2026, 12:51:33
    Author     : Administrador
--%>

<%@page import="modelos.ResultadoPaginadoDevoluciones"%>
<%-- 
    Document   : unificadoV2
    Versión    : Reporte unificado paginado sin DataTables
--%>

<%@page import="java.util.Arrays"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="modelos.Farmacia"%>
<%@page import="modelos.reportes.ReporteDevolucionUnificada"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    private boolean contiene(List<String> lista, String valor) {
        return lista != null && valor != null && lista.contains(valor);
    }

    private String textoSeguro(Object valor) {
        if (valor == null) {
            return "";
        }

        return String.valueOf(valor)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#039;");
    }
%>

<%
    List<Farmacia> listaFarmacias = (List<Farmacia>) request.getAttribute("listaFarmacias");
    List<String> listaTipoEnvio = (List<String>) request.getAttribute("listaTipoEnvio");
    List<String> listaLaboratorios = (List<String>) request.getAttribute("listaLaboratorios");

    List<ReporteDevolucionUnificada> listaReporte =
            (List<ReporteDevolucionUnificada>) request.getAttribute("listaReporte");

    ResultadoPaginadoDevoluciones resultado =
            (ResultadoPaginadoDevoluciones) request.getAttribute("resultado");

    if (listaFarmacias == null) {
        listaFarmacias = new ArrayList<Farmacia>();
    }

    if (listaTipoEnvio == null) {
        listaTipoEnvio = new ArrayList<String>();
    }

    if (listaLaboratorios == null) {
        listaLaboratorios = new ArrayList<String>();
    }

    if (listaReporte == null) {
        listaReporte = new ArrayList<ReporteDevolucionUnificada>();
    }

    String fechaInicial = request.getAttribute("fechaInicial") != null
            ? request.getAttribute("fechaInicial").toString()
            : "";

    String fechaFinal = request.getAttribute("fechaFinal") != null
            ? request.getAttribute("fechaFinal").toString()
            : "";

    String busqueda = request.getAttribute("busqueda") != null
            ? request.getAttribute("busqueda").toString()
            : "";

    String error = request.getAttribute("error") != null
            ? request.getAttribute("error").toString()
            : "";

    String[] farmaciasSeleccionadasArr =
            (String[]) request.getAttribute("farmaciasSeleccionadas");

    String[] tipoEnvioSeleccionadosArr =
            (String[]) request.getAttribute("tipoEnvioSeleccionados");

    String[] laboratoriosSeleccionadosArr =
            (String[]) request.getAttribute("laboratoriosSeleccionados");

    List<String> farmaciasSeleccionadas = farmaciasSeleccionadasArr != null
            ? Arrays.asList(farmaciasSeleccionadasArr)
            : java.util.Collections.emptyList();

    List<String> tipoEnvioSeleccionados = tipoEnvioSeleccionadosArr != null
            ? Arrays.asList(tipoEnvioSeleccionadosArr)
            : java.util.Collections.emptyList();

    List<String> laboratoriosSeleccionados = laboratoriosSeleccionadosArr != null
            ? Arrays.asList(laboratoriosSeleccionadosArr)
            : java.util.Collections.emptyList();

    Integer paginaActualAttr = (Integer) request.getAttribute("paginaActual");
    Integer totalPaginasAttr = (Integer) request.getAttribute("totalPaginas");
    Integer totalRegistrosAttr = (Integer) request.getAttribute("totalRegistros");
    Integer pageSizeAttr = (Integer) request.getAttribute("pageSize");

    int paginaActual = paginaActualAttr != null ? paginaActualAttr : 1;
    int totalPaginas = totalPaginasAttr != null ? totalPaginasAttr : 1;
    int totalRegistros = totalRegistrosAttr != null ? totalRegistrosAttr : 0;
    int pageSize = pageSizeAttr != null ? pageSizeAttr : 25;

    String orderBy = request.getAttribute("orderBy") != null
            ? request.getAttribute("orderBy").toString()
            : "FECHA_SCAN";

    String orderDir = request.getAttribute("orderDir") != null
            ? request.getAttribute("orderDir").toString()
            : "DESC";

    int desde = totalRegistros == 0 ? 0 : ((paginaActual - 1) * pageSize) + 1;
    int hasta = paginaActual * pageSize;

    if (hasta > totalRegistros) {
        hasta = totalRegistros;
    }

    boolean consultado = request.getAttribute("consultado") != null
            && Boolean.TRUE.equals(request.getAttribute("consultado"));
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte Unificado V2</title>

    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/css/bootstrap-icons.css" rel="stylesheet">
    <link href="<%=request.getContextPath()%>/reportes/total/estilos.css" rel="stylesheet">

    <style>
        body {
            background: #f4f6f9;
        }

        .page-wrapper {
            padding: 20px;
        }

        .main-card {
            background: #ffffff;
            border-radius: 18px;
            box-shadow: 0 8px 24px rgba(15, 23, 42, 0.08);
            overflow: hidden;
        }

        .main-header {
            padding: 22px 26px;
            background: linear-gradient(135deg, #0d6efd, #0b5ed7);
            color: #ffffff;
        }

        .main-header h2 {
            margin: 0;
            font-size: 1.4rem;
            font-weight: 700;
        }

        .main-header p {
            margin: 6px 0 0;
            opacity: 0.9;
            font-size: 0.95rem;
        }

        .content-area {
            padding: 22px;
        }

        .filters-card {
            background: #f8fafc;
            border: 1px solid #e5e7eb;
            border-radius: 16px;
            padding: 18px;
            margin-bottom: 18px;
        }

        .section-title {
            font-weight: 700;
            color: #334155;
            margin-bottom: 14px;
        }

        .btn-rounded {
            border-radius: 999px;
        }

        .summary-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            padding: 12px 16px;
            background: #f8fafc;
            border: 1px solid #e5e7eb;
            border-radius: 14px;
            margin-bottom: 16px;
        }

        .table-wrapper {
            border: 1px solid #e5e7eb;
            border-radius: 16px;
            overflow: hidden;
            background: #ffffff;
        }

        .table thead th {
            background: #111827;
            color: #ffffff;
            font-size: 0.82rem;
            white-space: nowrap;
        }

        .table tbody td {
            font-size: 0.82rem;
            vertical-align: middle;
        }

        .empty-row {
            text-align: center;
            color: #64748b;
            padding: 28px;
        }

        .pagination-area {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            padding: 14px 16px;
            background: #f8fafc;
            border-top: 1px solid #e5e7eb;
        }

        .pill-tipo {
            display: inline-block;
            border-radius: 999px;
            padding: 4px 9px;
            font-size: 0.76rem;
            font-weight: 700;
            white-space: nowrap;
        }

        .tipo-excesos {
            background: #dbeafe;
            color: #1d4ed8;
        }

        .tipo-vencer {
            background: #fef9c3;
            color: #854d0e;
        }

        .tipo-donacion {
            background: #dcfce7;
            color: #166534;
        }

        .tipo-default {
            background: #e5e7eb;
            color: #374151;
        }

        .overlay-carga {
            position: fixed;
            inset: 0;
            background: rgba(15, 23, 42, 0.45);
            z-index: 9999;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .card-carga {
            background: #ffffff;
            border-radius: 18px;
            padding: 28px 34px;
            text-align: center;
            box-shadow: 0 18px 50px rgba(15, 23, 42, 0.25);
            min-width: 260px;
        }

        .small-muted {
            color: #64748b;
            font-size: 0.83rem;
        }

        .dropdown-checkbox-panel {
            display: none;
            position: absolute;
            z-index: 3000;
            background: #ffffff;
            width: 100%;
            max-height: 320px;
            overflow-y: auto;
            border: 1px solid #dee2e6;
            border-radius: 12px;
            padding: 12px;
            box-shadow: 0 12px 30px rgba(15, 23, 42, 0.16);
            margin-top: 4px;
        }

        .dropdown-checkbox-panel.show {
            display: block;
        }

        .checkbox-option {
            padding: 3px 0;
        }

        .input-multiple {
            cursor: pointer;
            background: #ffffff;
        }
        
        .form-check-input{
            margin-left: 2px!important
        }
    </style>
</head>

<body>

<jsp:include page="/componentes/navbar.jsp" />

<div id="overlayCarga" class="overlay-carga d-none">
    <div class="card-carga">
        <div class="spinner-border text-primary mb-3" role="status">
            <span class="visually-hidden">Cargando...</span>
        </div>
        <div class="fw-bold">Procesando reporte...</div>
        <div class="text-muted small">Espere un momento, por favor.</div>
    </div>
</div>

<div class="container-fluid page-wrapper">

    <div class="main-card">

        <div class="main-header">
            <h2>
                <i class="bi bi-clipboard-data me-2"></i>
                Reporte Unificado V2
            </h2>
            <p>
                Reporte paginado desde SQL Server, sin DataTables y sin carga masiva en pantalla.
            </p>
        </div>

        <div class="content-area">

            <% if (!error.isEmpty()) { %>
                <div class="alert alert-danger">
                    <%= textoSeguro(error) %>
                </div>
            <% } %>

            <div class="filters-card">
                <div class="section-title">
                    <i class="bi bi-funnel me-2"></i>
                    Filtros de búsqueda
                </div>

                <form id="formFiltros"
                      method="post"
                      action="<%= request.getContextPath() %>/reportes/unificadoV2">

                    <input type="hidden" id="accionForm" name="accion" value="listar">
                    <input type="hidden" name="pagina" value="1">
                    <input type="hidden" name="orderBy" value="<%= textoSeguro(orderBy) %>">
                    <input type="hidden" name="orderDir" value="<%= textoSeguro(orderDir) %>">
                    <input type="hidden"
       id="tokenDescargaExcel"
       name="tokenDescargaExcel"
       value="">

                    <div class="row g-3 align-items-end">

                        <div class="col-md-3">
                            <label for="fechaInicial" class="form-label">Fecha inicial</label>
                            <input type="date"
                                   class="form-control"
                                   id="fechaInicial"
                                   name="fechaInicial"
                                   value="<%= textoSeguro(fechaInicial) %>">
                        </div>

                        <div class="col-md-3">
                            <label for="fechaFinal" class="form-label">Fecha final</label>
                            <input type="date"
                                   class="form-control"
                                   id="fechaFinal"
                                   name="fechaFinal"
                                   value="<%= textoSeguro(fechaFinal) %>">
                        </div>

                        <div class="col-md-3">
                            <label for="pageSize" class="form-label">Registros</label>
                            <select id="pageSize" name="pageSize" class="form-select">
                                <option value="25" <%= pageSize == 25 ? "selected" : "" %>>25</option>
                                <option value="50" <%= pageSize == 50 ? "selected" : "" %>>50</option>
                                <option value="100" <%= pageSize == 100 ? "selected" : "" %>>100</option>
                                <option value="200" <%= pageSize == 200 ? "selected" : "" %>>200</option>
                                <option value="500" <%= pageSize == 500 ? "selected" : "" %>>500</option>
                            </select>
                        </div>

                        <div class="col-md-3">
                            <label for="busqueda" class="form-label">Búsqueda general</label>
                            <input type="text"
                                   class="form-control"
                                   id="busqueda"
                                   name="busqueda"
                                   placeholder="Código, producto, farmacia..."
                                   value="<%= textoSeguro(busqueda) %>">
                        </div>

                        <!-- Farmacias -->
                        <div class="col-md-4 position-relative">
                            <label class="form-label">Farmacias</label>

                            <input type="text"
                                   id="inputFarmacias"
                                   class="form-control input-multiple"
                                   placeholder="Seleccione farmacia(s)"
                                   readonly
                                   onclick="togglePanel('panelFarmacias')">

                            <div id="panelFarmacias" class="dropdown-checkbox-panel">

                                <input type="text"
                                       class="form-control form-control-sm mb-2"
                                       placeholder="Buscar farmacia..."
                                       onkeyup="filtrarOpciones(this, 'panelFarmacias')">

                                <div class="d-flex gap-2 mb-2">
                                    <button type="button"
                                            class="btn btn-sm btn-outline-primary"
                                            onclick="seleccionarTodo('panelFarmacias', 'inputFarmacias')">
                                        Todos
                                    </button>

                                    <button type="button"
                                            class="btn btn-sm btn-outline-secondary"
                                            onclick="limpiarSeleccion('panelFarmacias', 'inputFarmacias')">
                                        Limpiar
                                    </button>
                                </div>

                                <%
                                    for (Farmacia f : listaFarmacias) {
                                        String farmacia = f.getFarmacia();
                                        boolean checked = contiene(farmaciasSeleccionadas, farmacia);
                                %>
                                    <div class="form-check checkbox-option">
                                        <input class="form-check-input"
                                               type="checkbox"
                                               name="farmacias"
                                               id="farmacia_<%= farmacia.hashCode() %>"
                                               value="<%= textoSeguro(farmacia) %>"
                                               onchange="actualizarInputSeleccionado('panelFarmacias', 'inputFarmacias')"
                                               <%= checked ? "checked" : "" %>>

                                        <label class="form-check-label"
                                               for="farmacia_<%= farmacia.hashCode() %>">
                                            <%= textoSeguro(farmacia) %>
                                        </label>
                                    </div>
                                <%
                                    }
                                %>
                            </div>
                        </div>

                        <!-- Tipo envío -->
                        <div class="col-md-4 position-relative">
                            <label class="form-label">Tipo envío</label>

                            <input type="text"
                                   id="inputTipoEnvio"
                                   class="form-control input-multiple"
                                   placeholder="Seleccione tipo(s)"
                                   readonly
                                   onclick="togglePanel('panelTipoEnvio')">

                            <div id="panelTipoEnvio" class="dropdown-checkbox-panel">

                                <input type="text"
                                       class="form-control form-control-sm mb-2"
                                       placeholder="Buscar tipo envío..."
                                       onkeyup="filtrarOpciones(this, 'panelTipoEnvio')">

                                <div class="d-flex gap-2 mb-2">
                                    <button type="button"
                                            class="btn btn-sm btn-outline-primary"
                                            onclick="seleccionarTodo('panelTipoEnvio', 'inputTipoEnvio')">
                                        Todos
                                    </button>

                                    <button type="button"
                                            class="btn btn-sm btn-outline-secondary"
                                            onclick="limpiarSeleccion('panelTipoEnvio', 'inputTipoEnvio')">
                                        Limpiar
                                    </button>
                                </div>

                                <%
                                    for (String tipo : listaTipoEnvio) {
                                        boolean checked = contiene(tipoEnvioSeleccionados, tipo);
                                %>
                                    <div class="form-check checkbox-option">
                                        <input class="form-check-input"
                                               type="checkbox"
                                               name="tipoEnvio"
                                               id="tipo_<%= tipo.hashCode() %>"
                                               value="<%= textoSeguro(tipo) %>"
                                               onchange="actualizarInputSeleccionado('panelTipoEnvio', 'inputTipoEnvio')"
                                               <%= checked ? "checked" : "" %>>

                                        <label class="form-check-label"
                                               for="tipo_<%= tipo.hashCode() %>">
                                            <%= textoSeguro(tipo) %>
                                        </label>
                                    </div>
                                <%
                                    }
                                %>
                            </div>
                        </div>

                        <!-- Laboratorios -->
                        <div class="col-md-4 position-relative">
                            <label class="form-label">Laboratorios</label>

                            <input type="text"
                                   id="inputLaboratorios"
                                   class="form-control input-multiple"
                                   placeholder="Seleccione laboratorio(s)"
                                   readonly
                                   onclick="togglePanel('panelLaboratorios')">

                            <div id="panelLaboratorios" class="dropdown-checkbox-panel">

                                <input type="text"
                                       class="form-control form-control-sm mb-2"
                                       placeholder="Buscar laboratorio..."
                                       onkeyup="filtrarOpciones(this, 'panelLaboratorios')">

                                <div class="d-flex gap-2 mb-2">
                                    <button type="button"
                                            class="btn btn-sm btn-outline-primary"
                                            onclick="seleccionarTodo('panelLaboratorios', 'inputLaboratorios')">
                                        Todos
                                    </button>

                                    <button type="button"
                                            class="btn btn-sm btn-outline-secondary"
                                            onclick="limpiarSeleccion('panelLaboratorios', 'inputLaboratorios')">
                                        Limpiar
                                    </button>
                                </div>

                                <%
                                    for (String laboratorio : listaLaboratorios) {
                                        boolean checked = contiene(laboratoriosSeleccionados, laboratorio);
                                %>
                                    <div class="form-check checkbox-option">
                                        <input class="form-check-input"
                                               type="checkbox"
                                               name="laboratorios"
                                               id="laboratorio_<%= laboratorio.hashCode() %>"
                                               value="<%= textoSeguro(laboratorio) %>"
                                               onchange="actualizarInputSeleccionado('panelLaboratorios', 'inputLaboratorios')"
                                               <%= checked ? "checked" : "" %>>

                                        <label class="form-check-label"
                                               for="laboratorio_<%= laboratorio.hashCode() %>">
                                            <%= textoSeguro(laboratorio) %>
                                        </label>
                                    </div>
                                <%
                                    }
                                %>
                            </div>
                        </div>

                    </div>

                    <div class="mt-3 d-flex gap-2 flex-wrap">
                        <button type="submit"
                                class="btn btn-primary btn-rounded"
                                onclick="document.getElementById('accionForm').value='listar';">
                            <i class="bi bi-search me-1"></i>
                            Consultar
                        </button>

                        <button type="submit"
                                class="btn btn-success btn-rounded"
                                onclick="document.getElementById('accionForm').value='excel';">
                            <i class="bi bi-file-earmark-excel me-1"></i>
                            Exportar Excel
                        </button>

                        <a href="<%= request.getContextPath() %>/reportes/unificadoV2"
                           class="btn btn-outline-secondary btn-rounded">
                            <i class="bi bi-arrow-clockwise me-1"></i>
                            Limpiar
                        </a>
                    </div>

                </form>
            </div>

            <div class="summary-bar">
                <div>
                    <i class="bi bi-list-ul me-1"></i>
                    Registros:
                    <strong><%= totalRegistros %></strong>
                </div>

                <div>
                    Mostrando:
                    <strong><%= desde %> - <%= hasta %></strong>
                </div>

                <div>
                    Página:
                    <strong><%= paginaActual %> de <%= totalPaginas %></strong>
                </div>
            </div>

            <div class="table-wrapper">
                <div class="table-responsive">
                    <table class="table table-striped table-bordered table-hover align-middle mb-0">
                        <thead>
                            <tr>
                                <th>Código SAP</th>
                                <th>Código</th>
                                <th>Producto</th>
                                <th>Enviado</th>
                                <th>Recibido</th>
                                <th>Farmacia</th>
                                <th>Tipo Envío</th>
                                <th>Departamento</th>
                                <th>Laboratorio</th>
                                <th>Factor</th>
                                <th>Categoría</th>
                                <th>Subcategoría</th>
                                <th>Segmento</th>
                                <th>Incidencia</th>
                                <th>Observación</th>
                                <th>Fecha Scan</th>
                            </tr>
                        </thead>

                        <tbody>
                            <%
                                if (listaReporte != null && !listaReporte.isEmpty()) {
                                    for (ReporteDevolucionUnificada r : listaReporte) {
                                        String tipo = r.getTipoEnvio() != null ? r.getTipoEnvio() : "";
                                        String claseTipo = "tipo-default";

                                        if ("EXCESOS".equalsIgnoreCase(tipo)) {
                                            claseTipo = "tipo-excesos";
                                        } else if ("PROXIMOS A VENCER".equalsIgnoreCase(tipo)) {
                                            claseTipo = "tipo-vencer";
                                        } else if ("DONACIÓN".equalsIgnoreCase(tipo) || "DONACION".equalsIgnoreCase(tipo)) {
                                            claseTipo = "tipo-donacion";
                                        }
                            %>
                                <tr>
                                    <td><%= textoSeguro(r.getCodigoSap()) %></td>
                                    <td><%= textoSeguro(r.getCodigo()) %></td>
                                    <td><%= textoSeguro(r.getProducto()) %></td>
                                    <td><%= r.getEnviado() %></td>
                                    <td><%= r.getRecibido() %></td>
                                    <td><%= textoSeguro(r.getFarmacia()) %></td>
                                    <td>
                                        <span class="pill-tipo <%= claseTipo %>">
                                            <%= textoSeguro(r.getTipoEnvio()) %>
                                        </span>
                                    </td>
                                    <td><%= textoSeguro(r.getDepartamento()) %></td>
                                    <td><%= textoSeguro(r.getLabortaorio()) %></td>
                                    <td><%= r.getFactor() %></td>
                                    <td><%= textoSeguro(r.getCategoria()) %></td>
                                    <td><%= textoSeguro(r.getSubcategoria()) %></td>
                                    <td><%= textoSeguro(r.getSegmento()) %></td>
                                    <td><%= textoSeguro(r.getIncidencia()) %></td>
                                    <td><%= textoSeguro(r.getObservacion()) %></td>
                                    <td><%= textoSeguro(r.getFechaScan()) %></td>
                                </tr>
                            <%
                                    }
                                } else {
                            %>
                                <tr>
                                    <td colspan="16" class="empty-row">
                                        <i class="bi bi-inbox fs-2 d-block mb-2"></i>
                                        No se encontraron registros con los filtros aplicados.
                                    </td>
                                </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </div>

                <div class="pagination-area">

                    <div>
                        <span class="small-muted">
                            Página <strong><%= paginaActual %></strong> de <strong><%= totalPaginas %></strong>
                        </span>
                    </div>

                    <div class="d-flex gap-2 flex-wrap">

                        <!-- Anterior -->
                        <form action="<%= request.getContextPath() %>/reportes/unificadoV2" method="post" class="m-0 form-paginacion">
                            <input type="hidden" name="accion" value="listar">
                            <input type="hidden" name="pagina" value="<%= paginaActual - 1 %>">
                            <input type="hidden" name="pageSize" value="<%= pageSize %>">
                            <input type="hidden" name="fechaInicial" value="<%= textoSeguro(fechaInicial) %>">
                            <input type="hidden" name="fechaFinal" value="<%= textoSeguro(fechaFinal) %>">
                            <input type="hidden" name="busqueda" value="<%= textoSeguro(busqueda) %>">
                            <input type="hidden" name="orderBy" value="<%= textoSeguro(orderBy) %>">
                            <input type="hidden" name="orderDir" value="<%= textoSeguro(orderDir) %>">

                            <%
                                for (String f : farmaciasSeleccionadas) {
                            %>
                                <input type="hidden" name="farmacias" value="<%= textoSeguro(f) %>">
                            <%
                                }

                                for (String t : tipoEnvioSeleccionados) {
                            %>
                                <input type="hidden" name="tipoEnvio" value="<%= textoSeguro(t) %>">
                            <%
                                }

                                for (String l : laboratoriosSeleccionados) {
                            %>
                                <input type="hidden" name="laboratorios" value="<%= textoSeguro(l) %>">
                            <%
                                }
                            %>

                            <button type="submit"
                                    class="btn btn-outline-primary btn-sm btn-rounded"
                                    <%= paginaActual <= 1 ? "disabled" : "" %>>
                                <i class="bi bi-chevron-left"></i>
                                Anterior
                            </button>
                        </form>

                        <!-- Siguiente -->
                        <form action="<%= request.getContextPath() %>/reportes/unificadoV2" method="post" class="m-0 form-paginacion">
                            <input type="hidden" name="accion" value="listar">
                            <input type="hidden" name="pagina" value="<%= paginaActual + 1 %>">
                            <input type="hidden" name="pageSize" value="<%= pageSize %>">
                            <input type="hidden" name="fechaInicial" value="<%= textoSeguro(fechaInicial) %>">
                            <input type="hidden" name="fechaFinal" value="<%= textoSeguro(fechaFinal) %>">
                            <input type="hidden" name="busqueda" value="<%= textoSeguro(busqueda) %>">
                            <input type="hidden" name="orderBy" value="<%= textoSeguro(orderBy) %>">
                            <input type="hidden" name="orderDir" value="<%= textoSeguro(orderDir) %>">

                            <%
                                for (String f : farmaciasSeleccionadas) {
                            %>
                                <input type="hidden" name="farmacias" value="<%= textoSeguro(f) %>">
                            <%
                                }

                                for (String t : tipoEnvioSeleccionados) {
                            %>
                                <input type="hidden" name="tipoEnvio" value="<%= textoSeguro(t) %>">
                            <%
                                }

                                for (String l : laboratoriosSeleccionados) {
                            %>
                                <input type="hidden" name="laboratorios" value="<%= textoSeguro(l) %>">
                            <%
                                }
                            %>

                            <button type="submit"
                                    class="btn btn-outline-primary btn-sm btn-rounded"
                                    <%= paginaActual >= totalPaginas ? "disabled" : "" %>>
                                Siguiente
                                <i class="bi bi-chevron-right"></i>
                            </button>
                        </form>

                    </div>

                </div>
            </div>

        </div>
    </div>
</div>

<script src="<%=request.getContextPath()%>/js/jquery.js"></script>
<script src="<%=request.getContextPath()%>/js/bundle.js"></script>

<script>
    function togglePanel(panelId) {
        const panel = document.getElementById(panelId);

        document.querySelectorAll(".dropdown-checkbox-panel").forEach(function (p) {
            if (p.id !== panelId) {
                p.classList.remove("show");
            }
        });

        panel.classList.toggle("show");
    }

    function actualizarInputSeleccionado(panelId, inputId) {
        const panel = document.getElementById(panelId);
        const input = document.getElementById(inputId);

        const seleccionados = Array.from(
            panel.querySelectorAll("input[type='checkbox']:checked")
        ).map(function (check) {
            return check.value;
        });

        if (seleccionados.length === 0) {
            input.value = "";
        } else if (seleccionados.length === 1) {
            input.value = seleccionados[0];
        } else {
            input.value = seleccionados.length + " seleccionados";
        }
    }

    function filtrarOpciones(inputBusqueda, panelId) {
        const texto = inputBusqueda.value.toLowerCase();
        const panel = document.getElementById(panelId);
        const opciones = panel.querySelectorAll(".checkbox-option");

        opciones.forEach(function (opcion) {
            const contenido = opcion.textContent.toLowerCase();

            if (contenido.includes(texto)) {
                opcion.style.display = "block";
            } else {
                opcion.style.display = "none";
            }
        });
    }

    function seleccionarTodo(panelId, inputId) {
        const panel = document.getElementById(panelId);

        panel.querySelectorAll("input[type='checkbox']").forEach(function (check) {
            const contenedor = check.closest(".checkbox-option");

            if (contenedor.style.display !== "none") {
                check.checked = true;
            }
        });

        actualizarInputSeleccionado(panelId, inputId);
    }

    function limpiarSeleccion(panelId, inputId) {
        const panel = document.getElementById(panelId);

        panel.querySelectorAll("input[type='checkbox']").forEach(function (check) {
            check.checked = false;
        });

        actualizarInputSeleccionado(panelId, inputId);
    }

    document.addEventListener("click", function (event) {
        const clickDentroPanel = event.target.closest(".dropdown-checkbox-panel");
        const clickInputMultiple = event.target.classList.contains("input-multiple");

        if (!clickDentroPanel && !clickInputMultiple) {
            document.querySelectorAll(".dropdown-checkbox-panel").forEach(function (panel) {
                panel.classList.remove("show");
            });
        }
    });
    
    let intervaloDescargaExcel = null;
let tiempoMaximoDescargaExcel = null;

function mostrarOverlayCarga(titulo, detalle) {
    const overlay = document.getElementById('overlayCarga');
    const overlayTitulo = document.getElementById('overlayTitulo');
    const overlayDetalle = document.getElementById('overlayDetalle');

    if (overlayTitulo) {
        overlayTitulo.textContent = titulo;
    }

    if (overlayDetalle) {
        overlayDetalle.textContent = detalle;
    }

    if (overlay) {
        overlay.classList.remove('d-none');
    }
}

function ocultarOverlayCarga() {
    const overlay = document.getElementById('overlayCarga');

    if (overlay) {
        overlay.classList.add('d-none');
    }
}

function obtenerCookie(nombre) {
    const prefijo = nombre + "=";

    const cookies = document.cookie
        .split(";")
        .map(function (cookie) {
            return cookie.trim();
        });

    for (const cookie of cookies) {
        if (cookie.startsWith(prefijo)) {
            return decodeURIComponent(cookie.substring(prefijo.length));
        }
    }

    return null;
}

function eliminarCookie(nombre) {
    const contextPath = '<%= request.getContextPath() %>';
    const cookiePath = contextPath || '/';

    document.cookie =
        nombre +
        "=; Max-Age=0; path=" +
        cookiePath +
        "; SameSite=Lax";
}

function generarTokenDescargaExcel() {
    return Date.now().toString(36)
            + "_"
            + Math.random().toString(36).substring(2, 15);
}

function iniciarControlDescargaExcel() {
    const tokenInput = document.getElementById('tokenDescargaExcel');

    if (!tokenInput) {
        return;
    }

    const token = generarTokenDescargaExcel();

    tokenInput.value = token;

    eliminarCookie('estadoDescargaExcel');

    mostrarOverlayCarga(
        'Generando archivo Excel...',
        'El reporte puede tardar dependiendo de la cantidad de registros.'
    );

    if (intervaloDescargaExcel) {
        clearInterval(intervaloDescargaExcel);
    }

    if (tiempoMaximoDescargaExcel) {
        clearTimeout(tiempoMaximoDescargaExcel);
    }

    intervaloDescargaExcel = setInterval(function () {
        const estado = obtenerCookie('estadoDescargaExcel');

        if (!estado) {
            return;
        }

        if (estado === token + "_OK") {
            clearInterval(intervaloDescargaExcel);
            clearTimeout(tiempoMaximoDescargaExcel);

            eliminarCookie('estadoDescargaExcel');
            ocultarOverlayCarga();

            tokenInput.value = "";
        }

        if (estado === token + "_ERROR") {
            clearInterval(intervaloDescargaExcel);
            clearTimeout(tiempoMaximoDescargaExcel);

            eliminarCookie('estadoDescargaExcel');
            ocultarOverlayCarga();

            tokenInput.value = "";

            alert("No se pudo generar el archivo Excel.");
        }
    }, 500);

    /*
     * Protección para que el overlay no quede abierto indefinidamente
     * ante una desconexión o error no controlado.
     */
    tiempoMaximoDescargaExcel = setTimeout(function () {
        if (intervaloDescargaExcel) {
            clearInterval(intervaloDescargaExcel);
        }

        eliminarCookie('estadoDescargaExcel');
        ocultarOverlayCarga();

        tokenInput.value = "";
    }, 30 * 60 * 1000);
}

    document.addEventListener("DOMContentLoaded", function () {
        actualizarInputSeleccionado('panelFarmacias', 'inputFarmacias');
        actualizarInputSeleccionado('panelTipoEnvio', 'inputTipoEnvio');
        actualizarInputSeleccionado('panelLaboratorios', 'inputLaboratorios');

        const formFiltros = document.getElementById('formFiltros');
        const overlayCarga = document.getElementById('overlayCarga');
        const accionForm = document.getElementById('accionForm');

        if (formFiltros && overlayCarga) {
            formFiltros.addEventListener('submit', function () {
                const accion = accionForm ? accionForm.value : 'listar';

                if (accion === 'listar') {
                    mostrarOverlayCarga(
                        'Procesando reporte...',
                        'Espere un momento, por favor.'
                    );
                }

                if (accion === 'excel') {
                    iniciarControlDescargaExcel();
                }
            });
        }
        document.querySelectorAll('.form-paginacion').forEach(function (form) {
            form.addEventListener('submit', function () {
                if (overlayCarga) {
                    overlayCarga.classList.remove('d-none');
                }
            });
        });
    });
</script>

</body>
</html>
