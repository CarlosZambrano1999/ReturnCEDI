<%-- 
    Document   : guiasPendientes.jsp
    Created on : 23 feb 2026, 16:09:05
    Author     : Administrador
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    <title>Guías Pendientes</title>

    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet">

    <!-- DataTables Bootstrap 5 -->
    <link href="<%=request.getContextPath()%>/css/dataTables.css" rel="stylesheet">
</head>
<body>
    
        <jsp:include page="/componentes/navbar.jsp" />


<div class="container py-4">

    <div class="d-flex align-items-center justify-content-between mb-3">
        <h4 class="m-0">Guías Pendientes </h4>
        <button id="btnRecargar" class="btn btn-primary">Recargar</button>
    </div>

    <div id="loadingBox" class="alert alert-info d-none">Cargando información...</div>
    <div id="errorBox" class="alert alert-danger d-none"></div>

    <div class="card">
        <div class="card-body">
            <div class="table-responsive">
                <table id="tablaGuias" class="table table-striped table-bordered w-100">
                    <thead>
                        <tr>
                            <th>NÚMERO</th>
                            <th>ESTADO</th>
                            <th>FECHA</th>
                            <th>TIPO</th>
                            <th>USUARIO</th>
                            <th>RETOMAR</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>
    </div>

</div>

<!-- JS -->
<script src="<%=request.getContextPath()%>/js/jquery.js"></script>
<script src="<%=request.getContextPath()%>/js/dataTables.js"></script>
<script src="<%=request.getContextPath()%>/js/dataTablesBootstrap.js"></script>

<script>
const ctx = "<%=request.getContextPath()%>";
const urlData = ctx + "/GuiasPendientes?action=data";

let tabla = null;

document.addEventListener("DOMContentLoaded", () => {
    initTabla();
    cargarDatos();
});

document.getElementById("btnRecargar").addEventListener("click", () => {
    cargarDatos();
});

function mostrarLoading(mostrar) {
    const box = document.getElementById("loadingBox");
    box.classList.toggle("d-none", !mostrar);
}

function mostrarError(msg) {
    const box = document.getElementById("errorBox");
    if (!msg) {
        box.classList.add("d-none");
        box.innerText = "";
        return;
    }
    box.classList.remove("d-none");
    box.innerText = msg;
}

const rutasPorTipo = {
  "DEVOLUCIONES": "Devoluciones",
  "EXCESOS": "Excesos",
  "DONACIONES": "Donaciones",
  "ND": "NoDevolutivos",
  "RECEPCION": "Recepcion"
};

function initTabla() {
  tabla = new DataTable("#tablaGuias", {
    paging: true,
    searching: true,
    ordering: true,
    pageLength: 25,
    order: [[2, "desc"]],
    language: { url: ctx + "/js/es-ES.json" },
    columns: [
      { data: "numero" },
      { data: "estado" },
      { data: "fecha" },
      { data: "tipo" },
      { data: "usuario" },
{
  data: null,
  orderable: false,
  searchable: false,
  render: (data, type, row) => {
    const tipo = (row.tipo || "").toString().trim().toUpperCase();
    const ruta = rutasPorTipo[tipo];

    // Si no hay tipo o no hay ruta, mostramos deshabilitado
    if (!tipo || !ruta) {
      return `<button class="btn btn-sm btn-secondary" disabled title="Sin tipo/ruta">Retomar</button>`;
    }

    // Importante: mandar docMaterial como string (no parseInt)
    return `
      <button
        class="btn btn-sm btn-success btn-retomar"
        data-tipo="\${tipo}"
        data-doc="\${String(row.numero)}">
        Retomar
      </button>
    `;
  }
}
    ]
  });

  // Delegación de evento (porque los botones se crean dinámicamente)
  document.querySelector("#tablaGuias tbody").addEventListener("click", (ev) => {
    const btn = ev.target.closest(".btn-retomar");
    if (!btn) return;

    const tipo = (btn.dataset.tipo || "").trim().toUpperCase();
    const doc = btn.dataset.doc;

    retomarGuia(tipo, doc);
  });
}

function retomarGuia(tipo, docMaterial) {
  const ruta = rutasPorTipo[tipo];

  if (!ruta) {
    mostrarError(`No hay ruta configurada para el tipo: ${tipo}`);
    return;
  }

  const doc = parseInt(docMaterial, 10);
  if (!doc || doc <= 0) {
    mostrarError("Doc.Material inválido para retomar.");
    return;
  }

  // POST real (navega al servlet y te carga el documento)
  const form = document.createElement("form");
  form.method = "POST";
  form.action = ctx + "/" + ruta;

  const inpAccion = document.createElement("input");
  inpAccion.type = "hidden";
  inpAccion.name = "accion";
  inpAccion.value = "cargardocumento";

  const inpDoc = document.createElement("input");
  inpDoc.type = "hidden";
  inpDoc.name = "docMaterial";
  inpDoc.value = String(doc);

  form.appendChild(inpAccion);
  form.appendChild(inpDoc);

  document.body.appendChild(form);
  form.submit();
}

async function cargarDatos() {
    mostrarError(null);
    mostrarLoading(true);

    try {
        const resp = await fetch(urlData, { method: "GET" });

        // si el servlet redirige al login por sesión inválida, aquí podría venir HTML:
        const contentType = resp.headers.get("content-type") || "";
        if (!contentType.includes("application/json")) {
            const raw = await resp.text();
            console.log("Respuesta no JSON:", raw.substring(0, 300));
            throw new Error("La respuesta no es JSON. Verifica sesión/login o el servlet.");
        }

        const data = await resp.json();
        console.log("JSON completo:", data);

        if (!resp.ok || data.status !== "success") {
            throw new Error(data.message || "No se pudo cargar la información.");
        }

        tabla.clear();
        tabla.rows.add(data.data);
        tabla.draw();

    } catch (e) {
        console.error(e);
        mostrarError(e.message);
    } finally {
        mostrarLoading(false);
    }
}

function tipoToRuta(tipo) {
  if (!tipo) return "";
  const t = tipo.toLowerCase();              // devoluciones
  return t.charAt(0).toUpperCase() + t.slice(1); // Devoluciones
}
</script>

</body>
</html>
