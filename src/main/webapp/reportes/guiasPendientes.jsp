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

function initTabla() {
    tabla = new DataTable("#tablaGuias", {
        paging: true,
        searching: true,
        ordering: true,
        pageLength: 25,
        order: [[2, "desc"]], // FECHA desc
        language: {
            url: '<%=request.getContextPath()%>/js/es-ES.json'
        },
        columns: [
            { data: "numero" },
            { data: "estado" },
            { data: "fecha" },
            { data: "tipo" },
            { data: "usuario" }
        ]
    });
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
