<%-- 
    Document   : devoluciones
    Created on : 16 dic 2025, 15:37:34
    Author     : Administrador
--%>

<%@page import="modelos.Versiculo"%>
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
        <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
        <title>Recepción - Escaneo</title>
        <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet">
        <link href="<%=request.getContextPath()%>/css/dataTables.css" rel="stylesheet">
        <link href="<%=request.getContextPath()%>/guia/estilos.css" rel="stylesheet">

    </head>
    <body>
        <jsp:include page="/componentes/navbar.jsp" />
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

            <h1>Recepción</h1>
            <div class="card shadow-sm mb-3">
                <div class="card-body p-4">

                    <% if (msg != null && !msg.trim().isEmpty()) {%>
                    <div class="alert alert-<%= "success".equals(msgType) ? "success" : ("warning".equals(msgType) ? "warning" : "danger")%>">
                        <%= msg%>
                    </div>
                    <% }%>

                    <form method="post" action="<%=request.getContextPath()%>/Recepcion" class="row g-3 align-items-end">
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

                    <form id="formScan" method="post" action="<%=request.getContextPath()%>/Recepcion">
                        <input type="hidden" name="accion" value="scan"/>
                        <input type="hidden" name="docMaterial" value="<%= doc == null ? "" : doc%>"/>
                    </form>

                </div>
            </div>

            <!--div class="card shadow-sm mb-3">
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
            </div -->
            <% if (doc != null) {%>
            <div class="d-flex justify-content-end mt-3">
                <form id="formCerrarGuia"
                      method="post"
                      action="<%=request.getContextPath()%>/Recepcion">

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

            <div class="card shadow-sm" id="cardPrincipal">
                <div class="card-body p-4">
                    <div class="table-responsive">
                        <table id="tabla" class="table table-hover align-middle w-100">
                            <thead>
                                <tr>
                                    <th>Estado</th>
                                    <th>EAN</th>
                                    <th>Código Sap</th>
                                    <th>Descripción</th>
                                    <th>FC</th>
                                    <th>Presentación</th>
                                    <th class="text-end">Enviado</th>
                                    <!--th class="text-end">Recibido</th>
                                    <th class="text-end">Diferencia</th-->
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
                                    <td><%= r.getCodigo()%></td>
                                    <td><%= r.getDescripcion() == null ? "" : r.getDescripcion()%></td>
                                    <td><%= r.getFactor()%></td>
                                    <td><%= r.getPresentacion()%></td>
                                    <td class="text-end"><%= r.getCantidadEsperada().intValue()%></td>
                                    <!--td class="text-end"><%= r.getCantidadEscaneada().intValue()%></td>
                                    <td class="text-end"><%= r.getDiferencia().intValue()%></td-->
                                    <% boolean esAdicional = "ADICIONAL".equalsIgnoreCase(r.getEstado());%>
                                    <td class="text-center">
                                        <%
                                            boolean ocultarEditar = r.getFactor() == 1;
                                        %>
                                        
                                        <div class="dropdown">
                                            <button class="btn btn-sm btn-outline-secondary dropdown-toggle"
                                                    type="button"
                                                    data-bs-toggle="dropdown"
                                                    aria-expanded="false"
                                                    <%= (r.getIdDevolucion() == null ? "disabled" : "")%>>
                                                Editar
                                            </button>

                                            <div class="dropdown-menu p-2" style="min-width: 260px;">
                                                
                                                <% if (!ocultarEditar) {%>
                                                <form method="post"
                                                      action="<%=request.getContextPath()%>/Recepcion"
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
                                                 <% } %>
                                            <% if (ocultarEditar) {%>
                                                <form method="post"
                                                      action="<%=request.getContextPath()%>/Recepcion"
                                                      class="d-flex flex-column gap-2">

                                                    <input type="hidden" name="accion" value="editar2">
                                                    <input type="hidden" name="docMaterial" value="<%= doc%>">
                                                    <input type="hidden" name="id" value="<%= r.getIdDevolucion() == null ? "" : r.getIdDevolucion()%>">

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
                                                 <% } %>            

                                                <form method="post" action="<%=request.getContextPath()%>/Recepcion"
                                                      onsubmit="return confirmarLimpiar(this);">
                                                    <input type="hidden" name="accion" value="limpiar">
                                                    <input type="hidden" name="docMaterial" value="<%= doc%>">
                                                    <input type="hidden" name="id" value="<%= r.getIdDevolucion()%>">

                                                    <button type="submit" class="btn btn-sm btn-outline-warning w-100">
                                                        Limpiar escaneo (0)
                                                    </button>
                                                </form>

                                            </div>
                                        </div>
                                        

                                        <% if (r.getIdDevolucion() == null) { %>
                                        <div class="small text-muted mt-1"></div>
                                        <% } %>
                                   
                                    </td>
                                    <td><% if (esAdicional && r.getIdDevolucion() != null) {%>
                                        <form method="post" action="<%=request.getContextPath()%>/Recepcion"
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
                            
                            <%
                Versiculo v = (Versiculo) request.getAttribute("versiculoDelDia");
            %>

            <% if (v != null) {%>
            </br>
            <div class="card p-4 text-center">
                <div class="fst-italic mb-2"><%= v.getVersiculo()%></div>
                <div class="fw-bold text-muted"><%= v.getCita()%></div>
            </div>
            <% }%>

        </div>
                            
                            <!-- Overlay Spinner -->
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
            
            let editandoFila = false;
    let interactuandoTabla = false;
    let dropdownAbierto = false;
    let inputCantidadActivo = null;
    let swalAbierto = false;
    
    function haySweetAlertAbierto() {
        return swalAbierto || !!document.querySelector(".swal2-container.swal2-shown");
      }
    
    function keepFocus(force = false) {
        if (haySweetAlertAbierto()) return;
        
  const scanner = document.getElementById("scanner");
  if (!scanner || scanner.disabled) return;

  // ✅ Si hay dropdown abierto, el foco DEBE quedarse en cantidad
  if (dropdownAbierto) {
    if (inputCantidadActivo && !inputCantidadActivo.disabled) {
      inputCantidadActivo.focus({ preventScroll: true });
      inputCantidadActivo.select?.();
    }
    return;
  }

  if ((editandoFila || interactuandoTabla) && !force) return;

  scanner.focus({ preventScroll: true });
  scanner.select?.();
}
            
            const LAST_CODIGO = "<%= request.getAttribute("lastCodigo") == null ? "" : request.getAttribute("lastCodigo").toString() %>";
            $(function () {
                $("#tabla").DataTable({
        ordering: true,
        pageLength: 50,
        order: [], // sin orden inicial
        scrollX: true,          // ✅ clave
        autoWidth: false,       // ✅ evita cálculos raros
        responsive: false,      
        language: {
            url: '<%=request.getContextPath()%>/js/es-ES.json'
        },
        drawCallback: function () {
             forzarScrollDerecha();
            keepFocus();
        }
    });

        
        setTimeout(function () {
            const scanner = document.getElementById("scanner");
            const doc = document.getElementById("docMaterial");
            if (scanner && !scanner.disabled)
                keepFocus();
            else if (doc)
                doc.focus();
        }, 50);

        document.addEventListener("click", function () {
            if (dropdownAbierto) return;
            if (haySweetAlertAbierto()) return;
            setTimeout(keepFocus, 30);
        });
        
        document.getElementById("scanner")?.addEventListener("focus", () => {
            if (!dropdownAbierto) return;

            if (inputCantidadActivo && !inputCantidadActivo.disabled) {
              inputCantidadActivo.focus({ preventScroll: true });
              inputCantidadActivo.select?.();
            }
          });
        document.addEventListener("keydown", (e) => {
            if (e.key === "Escape") {
                editandoFila = false;
                keepFocus(true);
            }
        });

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
        const card = document.getElementById("cardPrincipal");
        if (!tabla)
            return;

        if (tabla.contains(e.target) || card.contains(e.target)) {
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

          // ✅ si dropdown está abierto, NO regreses al scanner
          if (dropdownAbierto) return;

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

        const btn = form.querySelector(".btn-guardar");
        if (!btn)
            return;

        const spinner = btn.querySelector(".spinner-border");
        const text = btn.querySelector(".btn-text");

        if (spinner)
            spinner.classList.remove("d-none");
        if (text)
            text.textContent = "Guardando...";

        btn.disabled = true;

        const inputs = form.querySelectorAll("input, select");
        inputs.forEach(i => i.setAttribute("readonly", true));
    });

    document.addEventListener("DOMContentLoaded", function () {

        const btnCerrar = document.getElementById("btnCerrarGuia");
        const formCerrar = document.getElementById("formCerrarGuia");
        const form = document.querySelector("form[action$='/Recepcion']");
        const spinner = document.getElementById("pageSpinner");

        document.querySelectorAll("form[action$='/Recepcion']").forEach(f => {
            f.addEventListener("submit", function () {
              const accion = (f.querySelector("input[name='accion']")?.value || "").toLowerCase();

              // ✅ Solo mostrar overlay en acciones pesadas
              const accionesConOverlay = ["cargardocumento", "cerrarguia"];

              if (accionesConOverlay.includes(accion)) {
                spinner.classList.remove("d-none");
              }
            });
          });

        if (!btnCerrar || !formCerrar)
            return;

        btnCerrar.addEventListener("click", function () {

    // 1) Detectar si hay estados NO OK
    const estadosNoOK = Array.from(document.querySelectorAll("#tabla tbody .state-pill"))
        .map(el => (el.textContent || "").trim().toUpperCase())
        .filter(txt => txt && txt !== "OK");

    const hayNoOK = estadosNoOK.length > 0;

    // 2) (Opcional) Contar por tipo para mostrarlo bonito
    const conteo = estadosNoOK.reduce((acc, s) => {
        acc[s] = (acc[s] || 0) + 1;
        return acc;
    }, {});

    const detalle = Object.keys(conteo)
        .sort()
        .map(k => `${k}: ${conteo[k]}`)
        .join(" • ");

    // 3) Configurar el mensaje según el caso
    const config = hayNoOK
        ? {
            title: '¿Cerrar la guía con incidencias?',
            html:
                '⚠️ Hay productos con estado <b>FALTANE o SOBRANTE</b>.<br>' +
                (detalle ? `<div class="mt-2 small text-muted">${detalle}</div>` : '') +
                '<div class="mt-2">Si cierras la guía, no podrás seguir escaneando ni editando información.</div>',
            icon: 'warning'
        }
        : {
            title: '¿Cerrar la guía?',
            text: 'Una vez cerrada no podrás seguir escaneando ni editando información.',
            icon: 'warning'
        };

    // 4) Mostrar la alerta (una sola, con contenido dinámico)
    Swal.fire({
        ...config,
        showCancelButton: true,
        confirmButtonColor: '#d33',
        cancelButtonColor: '#6c757d',
        confirmButtonText: 'Sí, cerrar guía',
        cancelButtonText: 'Cancelar',
        reverseButtons: true,
        didOpen: () => { swalAbierto = true; },
  didClose: () => { swalAbierto = false; setTimeout(() => keepFocus(true), 80); }
    }).then((result) => {
        if (result.isConfirmed) {

            Swal.fire({
                title: 'Cerrando guía...',
                text: 'Por favor espera',
                allowOutsideClick: false,
                allowEscapeKey: false,
                didOpen: () => {
                    swalAbierto = true;
                    Swal.showLoading();
                },
            didClose: () => {
              swalAbierto = false;
              setTimeout(() => keepFocus(true), 80);
            }
            });

            formCerrar.submit(); // POST normal al servlet
        }
    });

});

if (!LAST_CODIGO) return;

    const tabla = document.querySelector("#tabla tbody");
    if (!tabla) return;

    // Buscar la fila cuyo "Código EAN" (2da columna) coincida con el escaneo
    const filas = Array.from(tabla.querySelectorAll("tr"));

    const fila = filas.find(tr => {
        const tds = tr.querySelectorAll("td");
        if (tds.length < 4) return false;

        const codigoTabla = (tds[1].textContent || "").trim(); // col 2: Código EAN
        return codigoTabla === LAST_CODIGO.trim();
    });

    if (!fila) return;

    // Leer FC (col 4)
    const tds = fila.querySelectorAll("td");
    const fcTxt = (tds[4].textContent || "").trim(); // col 4: FC
    const fc = Number(fcTxt);

    // Scroll a la fila (opcional)
    fila.scrollIntoView({ behavior: "smooth", block: "center" });
    
    function dtScrollBody() {
    return document.querySelector("#tabla_wrapper .dataTables_scrollBody");
    }

    function forzarScrollDerecha() {
    const sb = dtScrollBody();
    if (!sb) return;

    // al final (lado derecho)
    sb.scrollLeft = sb.scrollWidth;
    }

    // ✅ 1) al cargar
    setTimeout(forzarScrollDerecha, 0);
    setTimeout(forzarScrollDerecha, 50);
    setTimeout(forzarScrollDerecha, 150);

    // ✅ 2) cada vez que DataTables redibuja (paginación, filtro, order, etc.)
    $(document).on("draw.dt", "#tabla", function () {
    // esperar un tick para que DataTables termine de ajustar anchos
    requestAnimationFrame(() => forzarScrollDerecha());
    });

    // ✅ 3) al cambiar tamaño (móvil rota, etc.)
    window.addEventListener("resize", () => {
    clearTimeout(window.__dtR);
    window.__dtR = setTimeout(forzarScrollDerecha, 120);
    });

    // Si FC es distinto de 1 → abrir dropdown y enfocar cantidad
    if (!Number.isNaN(fc) && fc !== 1) {

        const btnToggle = fila.querySelector(".dropdown .dropdown-toggle");
        if (!btnToggle || btnToggle.disabled) return;

        // Abrir dropdown Bootstrap 5
        const dd = bootstrap.Dropdown.getOrCreateInstance(btnToggle);
        dd.show();

        // Esperar a que se pinte el menú y enfocar input cantidad
        setTimeout(() => {
            const inputCantidad = fila.querySelector('.dropdown-menu input[name="cantidad"]');
            if (inputCantidad && !inputCantidad.disabled) {
                inputCantidad.focus();
                inputCantidad.select(); // opcional: selecciona el valor para escribir rápido
            }
        }, 50);
    }
    });
    
        document.addEventListener("shown.bs.dropdown", function (e) {
            dropdownAbierto = true;

            const btn = e.target;        // toggle
            const tr = btn.closest("tr");
            if (!tr) return;

            inputCantidadActivo = tr.querySelector('.dropdown-menu input[name="cantidad"]');

            if (inputCantidadActivo && !inputCantidadActivo.disabled) {
              requestAnimationFrame(() => {
                requestAnimationFrame(() => {
                  inputCantidadActivo.focus({ preventScroll: true });
                  inputCantidadActivo.select?.();
                });
              });
            }
          });

document.addEventListener("hidden.bs.dropdown", function (e) {
  const btn = e.target;
  const tr = btn.closest("tr");
  if (tr) tr.classList.remove("no-hover");
  dropdownAbierto = false;
  inputCantidadActivo = null;
  setTimeout(() => keepFocus(true), 30);
});

document.addEventListener("mouseover", function (e) {
  const menu = e.target.closest(".dropdown-menu");
  if (!menu) return;
  const tr = menu.closest("tr");
  if (tr) tr.classList.add("no-hover");
});

document.addEventListener("mouseleave", function (e) {
  const menu = e.target.closest(".dropdown-menu");
  if (!menu) return;
  const tr = menu.closest("tr");
  if (tr) tr.classList.remove("no-hover");
});

function confirmarLimpiar(form){
  Swal.fire({
    title: '¿Limpiar a 0?',
    text: 'Esto dejará la cantidad escaneada en cero para este producto.',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, limpiar',
    cancelButtonText: 'Cancelar',
    didOpen: () => { swalAbierto = true; },
    didClose: () => { swalAbierto = false; setTimeout(() => keepFocus(true), 80); }
  }).then(r => { if(r.isConfirmed) form.submit(); });
  return false;
}
    
        </script>
    </body>
</html>