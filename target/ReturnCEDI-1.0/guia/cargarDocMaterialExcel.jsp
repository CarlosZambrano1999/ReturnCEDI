<%-- 
    Document   : cargarDocMaterialExcel
    Created on : 15 dic 2025, 14:26:43
    Author     : Administrador
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Cargar Doc. Material desde Excel</title>

    <!-- Bootstrap 5 -->
    <link href="<%=request.getContextPath()%>/css/bootstrap.css" rel="stylesheet">

    <!-- DataTables + Bootstrap 5 -->
    <link href="<%=request.getContextPath()%>/css/dataTables.css" rel="stylesheet">

    <style>
        body { background: #f6f7fb; }
        .card { border: 0; border-radius: 16px; }
        .muted { color: #6c757d; }
        .badge-soft {
            background: rgba(13,110,253,.1);
            color: #0d6efd;
            border: 1px solid rgba(13,110,253,.15);
        }
        .table-wrap { overflow-x: auto; }
        .progress { height: 14px; border-radius: 999px; }
        .progress-bar { border-radius: 999px; }
        tr.row-error td {
  background: rgba(220,53,69,.12) !important;
}
tr.row-ok td {
  background: rgba(25,135,84,.08) !important;
}

    </style>
</head>

<body>
<div class="container py-4">

    <div class="row justify-content-center">
        <div class="col-lg-11 col-xl-10">

            <div class="d-flex align-items-center justify-content-between mb-3">
                <div>
                    <h3 class="mb-0">Carga de Doc. Material</h3>
                </div>
            </div>

            <div class="card shadow-sm">
                <div class="card-body p-4">

                    <div class="row g-3 align-items-end">
                        <div class="col-md-7">
                            <label class="form-label fw-semibold">Archivo Excel (.xlsx)</label>
                            <input class="form-control" type="file" id="archivoExcel" accept=".xlsx" />
                            <div class="form-text">
                                Debe contener columnas como: <b>Material</b>, <b>Documento material</b>, <b>Posición</b>, <b>Hora de entrada</b>, <b>Fe.contabilización</b>, <b>Fe.contabilización</b>, <b>Ctd.en UM entrada</b>, <b>Importe ML</b>, etc.
                            </div>
                        </div>

                        <div class="col-md-5 d-flex gap-2">
                            <button class="btn btn-outline-primary w-50" id="btnPreview" type="button" disabled>
                                Previsualizar
                            </button>
                            <button class="btn btn-primary w-50" id="btnCargar" type="button" disabled>
                                Cargar
                            </button>
                        </div>
                    </div>

                    <hr class="my-4"/>

                    <div class="row g-3">
                        <div class="col-md-4">
                            <div class="p-3 bg-light rounded-3">
                                <div class="muted">Doc. Material detectado</div>
                                <div class="fs-4 fw-bold" id="docMaterialDetectado">—</div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="p-3 bg-light rounded-3">
                                <div class="muted">Filas en preview</div>
                                <div class="fs-4 fw-bold" id="filasPreview">0</div>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="p-3 bg-light rounded-3">
                                <div class="muted">Estado</div>
                                <div class="fs-6 fw-semibold" id="estadoUI">Esperando archivo…</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row g-3 mt-1">
  <div class="col-md-3">
    <div class="p-3 bg-light rounded-3">
      <div class="muted">Filas válidas</div>
      <div class="fs-4 fw-bold text-success" id="filasValidas">0</div>
    </div>
  </div>
  <div class="col-md-3">
    <div class="p-3 bg-light rounded-3">
      <div class="muted">Filas con error</div>
      <div class="fs-4 fw-bold text-danger" id="filasError">0</div>
    </div>
  </div>
  <div class="col-md-3">
    <div class="p-3 bg-light rounded-3">
      <div class="muted">Suma cantidad</div>
      <div class="fs-4 fw-bold" id="sumaCantidad">0</div>
    </div>
  </div>
  <div class="col-md-3">
    <div class="p-3 bg-light rounded-3">
      <div class="muted">Suma importe</div>
      <div class="fs-4 fw-bold" id="sumaImporte">0</div>
    </div>
  </div>
</div>

                    <!-- Progreso -->
                    <div class="mt-4">
                        <div class="d-flex justify-content-between mb-2">
                            <div class="fw-semibold">Progreso de carga</div>
                            <div class="muted" id="progressText">0%</div>
                        </div>
                        <div class="progress">
                            <div class="progress-bar" id="progressBar" role="progressbar" style="width:0%"></div>
                        </div>
                    </div>

                    <hr class="my-4"/>

                    <div class="d-flex align-items-center justify-content-between mb-2">
                        <div>
                            <h5 class="mb-0">Preview del Excel</h5>
                            <div class="muted">Se muestran las primeras filas (no afecta la carga real).</div>
                        </div>
                        <div class="muted" id="previewNote"></div>
                    </div>

                    <div class="table-wrap">
                        <table id="tablaPreview" class="table table-striped table-hover align-middle w-100">
                            <thead>
                            <tr>
                                <th>Material</th>
                                <th>Texto breve</th>
                                <th>Centro</th>
                                <th>Almacén</th>
                                <th>Clase de movimiento</th>
                                <th>Documento material</th>
                                <th>Posición</th>
                                <th>Referencia</th>
                                <th>Texto</th>
                                <th>Hora de entrada</th>
                                <th>Nombre del usuario</th>
                                <th>Fecha Documento</th>
                                <th>Fe.contabilización</th>
                                <th>Cantidad</th>
                                <th>Importe</th>
                            </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>

                </div>
            </div>

            <div class="text-center muted mt-3">
                Tip: si el preview detecta columnas faltantes, corregir los encabezados del Excel para que coincidan.
            </div>

        </div>
    </div>

</div>

<!-- Bootstrap -->
<script src="<%=request.getContextPath()%>/js/bundle.js"></script>

<!-- SweetAlert2 -->
<script src="<%=request.getContextPath()%>/js/sweetalert2.js"></script>

<!-- jQuery (DataTables lo usa) -->
<script src="<%=request.getContextPath()%>/js/jquery.js"></script>

<!-- DataTables + Bootstrap 5 -->
<script src="<%=request.getContextPath()%>/js/jqueryDataTables.js"></script>
<script src="<%=request.getContextPath()%>/js/dataTablesBootstrap.js"></script>

<!-- SheetJS (xlsx) para leer Excel en el navegador -->
<script src="<%=request.getContextPath()%>/js/xlsx.js"></script>

<script>
    // ========= CONFIG =========
    const actionUrl = "<%=request.getContextPath()%>/CargarDocMaterialExcel";
    const MAX_PREVIEW_ROWS = 50;

    // Columnas requeridas (deben existir en el Excel)
    const REQUIRED_HEADERS = [
        "Material",
        "Texto breve de material",
        "Centro",
        "Almacén",
        "Clase de movimiento",
        "Documento material",
        "Posición",
        "Referencia",
        "Texto cab.documento",
        "Hora de entrada",
        "Nombre del usuario",
        "Fe.contabilización",
        "Fe.contabilización",
        "Ctd.en UM entrada",
        "Importe ML"
    ];

    // ========= STATE =========
    let selectedFile = null;
    let previewRows = [];    // arreglo de objetos con keys = encabezados
    let docMaterial = null;
    let dt = null;

    // ========= ELEMENTS =========
    const $file = document.getElementById("archivoExcel");
    const btnPreview = document.getElementById("btnPreview");
    const btnCargar = document.getElementById("btnCargar");

    const docMaterialEl = document.getElementById("docMaterialDetectado");
    const filasPreviewEl = document.getElementById("filasPreview");
    const estadoUI = document.getElementById("estadoUI");
    const previewNote = document.getElementById("previewNote");

    const progressBar = document.getElementById("progressBar");
    const progressText = document.getElementById("progressText");

    // ========= INIT DATATABLE =========
    $(document).ready(function () {
        dt = $("#tablaPreview").DataTable({
            pageLength: 10,
            lengthMenu: [10, 25, 50],
            language: {
                search: "Buscar:",
                lengthMenu: "Mostrar _MENU_",
                info: "Mostrando _START_ a _END_ de _TOTAL_",
                paginate: { next: "Siguiente", previous: "Anterior" },
                zeroRecords: "Sin registros para mostrar"
            }
        });
    });

    // ========= HELPERS =========
    function setStatus(text, type="muted") {
        estadoUI.textContent = text;
        estadoUI.className = "fs-6 fw-semibold " + (type === "ok" ? "text-success" : type === "warn" ? "text-warning" : type === "err" ? "text-danger" : "text-dark");
    }

    function resetProgress() {
        progressBar.style.width = "0%";
        progressText.textContent = "0%";
    }

    function setProgress(pct) {
        const v = Math.max(0, Math.min(100, pct));
        progressBar.style.width = v + "%";
        progressText.textContent = v + "%";
    }

    function normalize(s) {
        return (s || "").toString().trim().toLowerCase();
    }

    function validateHeaders(headers) {
        const set = new Set(headers.map(h => normalize(h)));
        const missing = REQUIRED_HEADERS.filter(r => !set.has(normalize(r)));
        return missing;
    }
    const filasValidasEl = document.getElementById("filasValidas");
const filasErrorEl = document.getElementById("filasError");
const sumaCantidadEl = document.getElementById("sumaCantidad");
const sumaImporteEl = document.getElementById("sumaImporte");

    function toNumber(val) {
  if (val === null || val === undefined) return 0;
  let s = val.toString().trim();
  if (!s) return 0;
  s = s.replaceAll(",", ""); // miles
  const n = Number(s);
  return isNaN(n) ? 0 : n;
}

function isEmpty(val) {
  return val === null || val === undefined || (val.toString().trim() === "");
}

function renderPreview(rows) {
  dt.clear();

  let validCount = 0;
  let errorCount = 0;
  let sumCantidad = 0;
  let sumImporte = 0;

  rows.forEach((r, idx) => {
    const material = (r["Material"] ?? "").toString().trim();
    const doc = (r["Documento material"] ?? "").toString().trim();
    const pos = (r["Posición"] ?? "").toString().trim();
    const fdoc = (r["Fe.contabilización"] ?? "").toString().trim();
    const fcon = (r["Fe.contabilización"] ?? "").toString().trim();

    // Reglas mínimas (ajustables)
    const errores = [];
    if (isEmpty(material)) errores.push("Material vacío");
    if (isEmpty(doc)) errores.push("Documento material vacío");
    if (docMaterial && !isEmpty(doc) && doc !== docMaterial) errores.push("Documento material distinto");
    if (isEmpty(pos)) errores.push("Posición vacío");
    if (isEmpty(fdoc)) errores.push("Fe.contabilización vacía");
    if (isEmpty(fcon)) errores.push("Fe.contab. vacía");

    const cantidad = toNumber(r["Ctd.en UM entrada"]);
    const importe = toNumber(r["Importe ML"]);
    sumCantidad += cantidad;
    sumImporte += importe;

    const isOk = errores.length === 0;
    if (isOk) validCount++; else errorCount++;

    // Agrega fila
    const rowNode = dt.row.add([
      r["Material"] ?? "",
      r["Texto breve de material"] ?? "",
      r["Centro"] ?? "",
      r["Almacén"] ?? "",
      r["Clase de movimiento"] ?? "",
      r["Documento material"] ?? "",
      r["Posición"] ?? "",
      r["Referencia"] ?? "",
      r["Texto cab.documento"] ?? "",
      r["Hora de entrada"] ?? "",
      r["Nombre del usuario"] ?? "",
      r["Fe.contabilización"] ?? "",
      r["Fe.contabilización"] ?? "",
      r["Ctd.en UM entrada"] ?? "",
      r["Importe ML"] ?? ""
    ]).draw(false).node();

    // Colorear + tooltip con errores
    if (isOk) {
      rowNode.classList.add("row-ok");
    } else {
      rowNode.classList.add("row-error");
      rowNode.title = "Errores: " + errores.join(" | ") + " (fila preview #" + (idx + 1) + ")";
    }
  });

  filasPreviewEl.textContent = rows.length.toString();
  filasValidasEl.textContent = validCount.toString();
  filasErrorEl.textContent = errorCount.toString();

  // Formateo simple
  sumaCantidadEl.textContent = sumCantidad.toLocaleString("es-HN", { minimumFractionDigits: 3, maximumFractionDigits: 3 });
  sumaImporteEl.textContent = sumImporte.toLocaleString("es-HN", { minimumFractionDigits: 2, maximumFractionDigits: 2 });

  previewNote.textContent = rows.length ? `Mostrando primeras ${rows.length} filas` : "";

  // Bloquear carga si hay errores
  if (errorCount > 0) {
    setStatus("Preview con errores. Corregí el Excel para poder cargar.", "err");
    btnCargar.disabled = true;
  }
}


    
const err = parseInt(document.getElementById("filasError").textContent || "0");
if (err > 0) {
  Swal.fire("Preview con errores", "Hay filas con datos faltantes o inconsistentes. No se permitirá cargar hasta corregir.", "warning");
}

function detectDocMaterial(rows) {
        // toma el primer Documento material no vacío y valida que todos (si vienen) sean iguales
        let dm = null;
        for (const r of rows) {
            const v = (r["Documento material"] ?? "").toString().trim();
            if (v) { dm = v; break; }
        }
        if (!dm) return { ok: false, value: null, error: "No se detectó Documento material en el preview." };

        for (const r of rows) {
            const v = (r["Documento material"] ?? "").toString().trim();
            if (v && v !== dm) {
                return { ok: false, value: null, error: "El archivo tiene más de un Documento material distinto." };
            }
        }
        return { ok: true, value: dm, error: null };
    }

    // ========= EVENTS =========
    $file.addEventListener("change", () => {
        selectedFile = $file.files && $file.files.length ? $file.files[0] : null;

        previewRows = [];
        docMaterial = null;
        docMaterialEl.textContent = "—";
        filasPreviewEl.textContent = "0";
        resetProgress();
        renderPreview([]);
        btnPreview.disabled = !selectedFile;
        btnCargar.disabled = true;

        if (!selectedFile) {
            setStatus("Esperando archivo…");
            return;
        }

        if (!selectedFile.name.toLowerCase().endsWith(".xlsx")) {
            Swal.fire("Formato inválido", "Solo se permite .xlsx", "error");
            $file.value = "";
            selectedFile = null;
            btnPreview.disabled = true;
            setStatus("Esperando archivo…");
            return;
        }

        setStatus("Archivo listo. Presioná Previsualizar.", "ok");
    });

    btnPreview.addEventListener("click", async () => {
        if (!selectedFile) return;

        try {
            setStatus("Leyendo Excel…", "warn");
            btnPreview.disabled = true;
            btnCargar.disabled = true;

            const data = await selectedFile.arrayBuffer();
            const wb = XLSX.read(data, { type: "array" });
            const ws = wb.Sheets[wb.SheetNames[0]];

            // Convertir a JSON manteniendo headers exactos del Excel
            const json = XLSX.utils.sheet_to_json(ws, { defval: "", raw: false });

            if (!json || !json.length) {
                setStatus("El Excel no tiene filas.", "err");
                Swal.fire("Sin datos", "El Excel no contiene filas.", "warning");
                btnPreview.disabled = false;
                return;
            }

            // Validar headers: obtenemos headers del primer objeto
            const headers = Object.keys(json[0] || {});
            const missing = validateHeaders(headers);

            if (missing.length) {
                setStatus("Faltan columnas.", "err");
                Swal.fire({
                    icon: "error",
                    title: "Columnas faltantes",
                    html: "<div class='text-start'>Faltan estas columnas:<br><b>" + missing.join("</b><br><b>") + "</b></div>"
                });
                btnPreview.disabled = false;
                return;
            }

            // Tomar solo primeras filas para preview
            previewRows = json.slice(0, MAX_PREVIEW_ROWS);

            // Detectar Documento material
            const dm = detectDocMaterial(previewRows);
            if (!dm.ok) {
                docMaterialEl.textContent = "—";
                setStatus(dm.error, "err");
                Swal.fire("Documento material inválido", dm.error, "error");
                btnPreview.disabled = false;
                return;
            }

            docMaterial = dm.value;
            docMaterialEl.textContent = docMaterial;

            renderPreview(previewRows);

            setStatus("Preview listo. Ya puede subir la guía.", "ok");
            btnCargar.disabled = false;
            btnPreview.disabled = false;

        } catch (e) {
            console.error(e);
            setStatus("Error leyendo el Excel.", "err");
            Swal.fire("Error", "No se pudo leer el Excel. Verificar que sea .xlsx válido.", "error");
            btnPreview.disabled = false;
        }
    });

    btnCargar.addEventListener("click", () => {
        if (!selectedFile) return;

        Swal.fire({
            icon: "question",
            title: "¿Cargar a la base de datos?",
            html: "Se insertará el <b>Documento material</b> con estado <b>1</b> y luego el detalle.<br><br><b>Archivo:</b> " + selectedFile.name,
            showCancelButton: true,
            confirmButtonText: "Sí, cargar",
            cancelButtonText: "Cancelar"
        }).then(res => {
            if (res.isConfirmed) {
                uploadExcel();
            }
        });
    });

    function uploadExcel() {
        resetProgress();
        setStatus("Subiendo archivo…", "warn");
        btnCargar.disabled = true;
        btnPreview.disabled = true;

        const formData = new FormData();
        formData.append("archivoExcel", selectedFile);

        const xhr = new XMLHttpRequest();
        xhr.open("POST", actionUrl, true);

        xhr.upload.onprogress = function (event) {
            if (event.lengthComputable) {
                const pct = Math.round((event.loaded / event.total) * 100);
                setProgress(pct);
            }
        };

        xhr.onload = function () {
            btnPreview.disabled = false;

            try {
                const resp = JSON.parse(xhr.responseText || "{}");

                if (xhr.status >= 200 && xhr.status < 300 && resp.status === "success") {
                    setProgress(100);
                    setStatus("Carga completada.", "ok");
                    Swal.fire({
                        icon: "success",
                        title: "Carga exitosa",
                        html: "Doc.Material: <b>" + resp.docMaterial + "</b><br>Filas insertadas: <b>" + resp.filasInsertadas + "</b>"
                    });
                    
                } else {
                    setStatus("Error al cargar.", "err");
                    const msg = resp.message || "Ocurrió un error al procesar el archivo.";
                    Swal.fire("Error", msg, "error");
                    btnCargar.disabled = false;
                }

            } catch (e) {
                console.error(e);
                setStatus("Respuesta inválida del servidor.", "err");
                Swal.fire("Error", "El servidor no devolvió un JSON válido.", "error");
                btnCargar.disabled = false;
            }
        };

        xhr.onerror = function () {
            setStatus("Error de red o servidor.", "err");
            Swal.fire("Error", "No se pudo conectar con el servidor.", "error");
            btnCargar.disabled = false;
            btnPreview.disabled = false;
        };

        xhr.send(formData);
    }
</script>

</body>
</html>

