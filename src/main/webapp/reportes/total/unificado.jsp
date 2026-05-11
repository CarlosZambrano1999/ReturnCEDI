<%-- 
    Document   : unificado
    Created on : 29 abr 2026, 10:19:27
    Author     : Administrador
--%>

<%@page import="java.util.Arrays"%>
<%@page import="modelos.reportes.ReporteDevolucionUnificada"%>
<%@page import="modelos.Farmacia"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    List<Farmacia> listaFarmacias = (List<Farmacia>) request.getAttribute("listaFarmacias");
    List<String> listaTipoEnvio = (List<String>) request.getAttribute("listaTipoEnvio");
    List<String> listaLaboratorios = (List<String>) request.getAttribute("listaLaboratorios");
    List<ReporteDevolucionUnificada> listaReporte =
            (List<ReporteDevolucionUnificada>) request.getAttribute("listaReporte");

    String fechaInicial = request.getAttribute("fechaInicial") != null
            ? request.getAttribute("fechaInicial").toString()
            : "";

    String fechaFinal = request.getAttribute("fechaFinal") != null
            ? request.getAttribute("fechaFinal").toString()
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

    String error = request.getAttribute("error") != null
            ? request.getAttribute("error").toString()
            : "";
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte Unificado</title>

    <!-- Bootstrap -->
        <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet"> 


    <!-- DataTables Bootstrap -->
    <link href="<%=request.getContextPath()%>/css/dataTables.css" rel="stylesheet"> 
<link href="<%=request.getContextPath()%>/css/buttons.css" rel="stylesheet"> 

    <style>
        body {
            background: #f4f6f9;
        }

        .card {
            border: none;
            border-radius: 12px;
        }

        .input-multiple {
            cursor: pointer;
            background-color: #fff !important;
        }

        .dropdown-checkbox-panel {
            display: none;
            position: absolute;
            z-index: 1050;
            width: 100%;
            max-height: 300px;
            overflow-y: auto;
            background: #fff;
            border: 1px solid #ced4da;
            border-radius: .375rem;
            box-shadow: 0 0.5rem 1rem rgba(0,0,0,.15);
            padding: 10px;
        }

        .dropdown-checkbox-panel.show {
            display: block;
        }

        .checkbox-option {
            border-radius: 5px;
        }

        .checkbox-option:hover {
            background-color: #f1f3f5;
        }

        .table {
            font-size: 12px;
            width: 100% !important;
        }

        th, td {
            white-space: nowrap;
            vertical-align: middle;
        }

        .table-responsive-custom {
            width: 100%;
            overflow-x: auto;
            -webkit-overflow-scrolling: touch;
        }

        .dataTables_wrapper {
            width: 100%;
        }

        .dataTables_wrapper .dt-buttons {
            margin-bottom: 10px;
        }

        .dataTables_filter {
            margin-bottom: 10px;
        }

        .dataTables_filter input {
            max-width: 100%;
        }

        @media (max-width: 768px) {
            .card-body {
                padding: 12px;
            }

            h4 {
                font-size: 18px;
            }

            .table {
                font-size: 11px;
            }

            .dataTables_wrapper .dt-buttons,
            .dataTables_filter,
            .dataTables_length {
                width: 100%;
                text-align: left !important;
                margin-bottom: 8px;
            }

            .dataTables_filter label,
            .dataTables_length label {
                width: 100%;
            }

            .dataTables_filter input,
            .dataTables_length select {
                width: 100% !important;
                margin-left: 0 !important;
                margin-top: 4px;
            }

            .dt-buttons .btn {
                width: 100%;
                margin-bottom: 6px;
            }
        }
    </style>
</head>

<body>
    
    <jsp:include page="/componentes/navbar.jsp" />

<div class="container-fluid py-4">

    <div class="card shadow-sm mb-4">
        <div class="card-body">

            <h4 class="mb-4">Reporte Unificado</h4>

            <% if (!error.isEmpty()) { %>
                <div class="alert alert-danger">
                    <%= error %>
                </div>
            <% } %>

            <form method="post" action="<%= request.getContextPath() %>/reportes/unificado">

                <div class="row g-3 align-items-end">

                    <div class="col-md-3">
                        <label for="fechaInicial" class="form-label">Fecha inicial</label>
                        <input type="date"
                               class="form-control"
                               id="fechaInicial"
                               name="fechaInicial"
                               value="<%= fechaInicial %>">
                    </div>

                    <div class="col-md-3">
                        <label for="fechaFinal" class="form-label">Fecha final</label>
                        <input type="date"
                               class="form-control"
                               id="fechaFinal"
                               name="fechaFinal"
                               value="<%= fechaFinal %>">
                    </div>

                    <div class="col-md-3 position-relative">
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
                                if (listaFarmacias != null) {
                                    for (Farmacia f : listaFarmacias) {
                                        String farmacia = f.getFarmacia();
                                        boolean checked = farmaciasSeleccionadas.contains(farmacia);
                            %>
                                <div class="form-check checkbox-option">
                                    <input class="form-check-input"
                                           type="checkbox"
                                           name="farmacias"
                                           id="farmacia_<%= farmacia.hashCode() %>"
                                           value="<%= farmacia %>"
                                           onchange="actualizarInputSeleccionado('panelFarmacias', 'inputFarmacias')"
                                           <%= checked ? "checked" : "" %>>

                                    <label class="form-check-label"
                                           for="farmacia_<%= farmacia.hashCode() %>">
                                        <%= farmacia %>
                                    </label>
                                </div>
                            <%
                                    }
                                }
                            %>

                        </div>
                    </div>

                    <div class="col-md-3 position-relative">
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
                                if (listaTipoEnvio != null) {
                                    for (String tipo : listaTipoEnvio) {
                                        boolean checked = tipoEnvioSeleccionados.contains(tipo);
                            %>
                                <div class="form-check checkbox-option">
                                    <input class="form-check-input"
                                           type="checkbox"
                                           name="tipoEnvio"
                                           id="tipo_<%= tipo.hashCode() %>"
                                           value="<%= tipo %>"
                                           onchange="actualizarInputSeleccionado('panelTipoEnvio', 'inputTipoEnvio')"
                                           <%= checked ? "checked" : "" %>>

                                    <label class="form-check-label"
                                           for="tipo_<%= tipo.hashCode() %>">
                                        <%= tipo %>
                                    </label>
                                </div>
                            <%
                                    }
                                }
                            %>

                        </div>
                    </div>
                            
                     <div class="col-lg-3 col-md-4 col-sm-6 position-relative">
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
                if (listaLaboratorios != null) {
                    for (String laboratorio : listaLaboratorios) {
                        boolean checked = laboratoriosSeleccionados.contains(laboratorio);
            %>
                <div class="form-check checkbox-option">
                    <input class="form-check-input"
                           type="checkbox"
                           name="laboratorios"
                           id="laboratorio_<%= laboratorio.hashCode() %>"
                           value="<%= laboratorio %>"
                           onchange="actualizarInputSeleccionado('panelLaboratorios', 'inputLaboratorios')"
                           <%= checked ? "checked" : "" %>>

                    <label class="form-check-label"
                           for="laboratorio_<%= laboratorio.hashCode() %>">
                        <%= laboratorio %>
                    </label>
                </div>
            <%
                    }
                }
            %>

        </div>
    </div>

                </div>

                <div class="mt-3 d-flex gap-2">
                    <button type="submit" class="btn btn-primary">
                        Consultar
                    </button>

                    <a href="<%= request.getContextPath() %>/reportes/unificado"
                       class="btn btn-secondary">
                        Limpiar
                    </a>
                </div>

            </form>

        </div>
    </div>
                       
                       <div id="spinnerTabla" class="text-center my-4">
    <div class="spinner-border text-primary" role="status" style="width: 3rem; height: 3rem;">
        <span class="visually-hidden">Cargando...</span>
    </div>
    <div class="mt-2 text-muted">
        Cargando reporte, por favor espere...
    </div>
</div>

    <div id="contenedorTabla" class="card shadow-sm d-none">
    <div class="card-body">

        <div class="table-responsive">
            <table id="tablaReporte" class="table table-striped table-bordered table-hover align-middle nowrap">
                    <thead class="table-dark">
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
                        if (listaReporte != null) {
                            for (ReporteDevolucionUnificada r : listaReporte) {
                    %>
                        <tr>
                            <td><%= r.getCodigoSap() %></td>
                            <td><%= r.getCodigo() %></td>
                            <td><%= r.getProducto() %></td>
                            <td><%= r.getEnviado() %></td>
                            <td><%= r.getRecibido() %></td>
                            <td><%= r.getFarmacia() %></td>
                            <td><%= r.getTipoEnvio() %></td>
                            <td><%= r.getDepartamento() %></td>
                            <td><%= r.getLabortaorio() %></td>
                            <td><%= r.getFactor() %></td>
                            <td><%= r.getCategoria() %></td>
                            <td><%= r.getSubcategoria() %></td>
                            <td><%= r.getSegmento() %></td>
                            <td><%= r.getIncidencia() %></td>
                            <td><%= r.getObservacion() %></td>
                            <td><%= r.getFechaScan() %></td>
                        </tr>
                    <%
                            }
                        }
                    %>
                    </tbody>
                </table>
            </div>

        </div>
    </div>

</div>

<!-- jQuery -->
<script src="<%=request.getContextPath()%>/js/jquery.js"></script>

<!-- Bootstrap -->
 <script src="<%=request.getContextPath()%>/js/bundle.js"></script>
<script src="<%=request.getContextPath()%>/js/jqueryDataTables.js"></script>
    <script src="<%=request.getContextPath()%>/js/dataTablesBootstrap.js"></script>

<!-- DataTables Buttons -->
<script src="<%=request.getContextPath()%>/js/dataTableButtons.js"></script>
    <script src="<%=request.getContextPath()%>/js/buttonsBootstrap.js"></script>
    <script src="<%=request.getContextPath()%>/js/jszip.js"></script>
    <script src="<%=request.getContextPath()%>/js/buttonshtml5.js"></script>

<script>
    $(document).ready(function () {

    $('#tablaReporte').DataTable({
        pageLength: 25,
        lengthMenu: [10, 25, 50, 100],
        ordering: true,
        searching: true,
        processing: true,
        responsive: false,
        scrollX: true,
        autoWidth: false,
        deferRender: true,
        language: {
            url: '<%=request.getContextPath()%>/js/es-ES.json'
        },
        dom:
            "<'row mb-2'<'col-12 col-md-6'B><'col-12 col-md-6'f>>" +
            "<'row'<'col-12'tr>>" +
            "<'row mt-2'<'col-12 col-md-5'i><'col-12 col-md-7'p>>",
        buttons: [
            {
                extend: 'excelHtml5',
                text: 'Exportar Excel',
                className: 'btn btn-success btn-sm',
                title: 'Reporte_Unificado'
            }
        ],
        columnDefs: [
            {
                targets: '_all',
                className: 'text-nowrap'
            },
            {
                targets: [2, 14],
                className: 'text-nowrap'
            }
        ],
        initComplete: function () {
            $('#spinnerTabla').addClass('d-none');
            $('#contenedorTabla').removeClass('d-none').hide().fadeIn(200);

            this.api().columns.adjust();
        }
    });

    actualizarInputSeleccionado("panelFarmacias", "inputFarmacias");
    actualizarInputSeleccionado("panelTipoEnvio", "inputTipoEnvio");
    actualizarInputSeleccionado("panelLaboratorios", "inputLaboratorios");
});

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
</script>

</body>
</html>