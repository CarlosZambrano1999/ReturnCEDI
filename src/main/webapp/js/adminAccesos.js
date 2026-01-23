(() => {
  const CTX = window.CTX || "";

  let dtModulos = null;

  const modalNuevoRol = () => new bootstrap.Modal(document.getElementById("modalNuevoRol"));
  const modalNuevoModulo = () => new bootstrap.Modal(document.getElementById("modalNuevoModulo"));
  const modalEditarModulo = () => new bootstrap.Modal(document.getElementById("modalEditarModulo"));

  function escHtml(text) {
    if (text == null) return "";
    return String(text)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll("\"", "&quot;")
      .replaceAll("'", "&#039;");
  }

  function showLoading(title = "Procesando...") {
    Swal.fire({
      title,
      allowOutsideClick: false,
      allowEscapeKey: false,
      didOpen: () => Swal.showLoading()
    });
  }

  function toastOk(msg) {
    Swal.fire({ icon: "success", title: "Listo", text: msg, timer: 1500, showConfirmButton: false });
  }

  function toastErr(msg) {
    Swal.fire({ icon: "error", title: "Error", text: msg || "Ocurrió un error." });
  }

  async function postForm(url, dataObj) {
    const form = new URLSearchParams();
    Object.keys(dataObj).forEach(k => form.append(k, dataObj[k] ?? ""));
    const resp = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8" },
      body: form.toString()
    });
    return await resp.json();
  }

  function initDataTable() {
    if (dtModulos) return;
    dtModulos = $("#tablaModulos").DataTable({
      pageLength: 10,
      lengthChange: true,
      searching: true,
      ordering: true,
      responsive: true
      // Si tenés archivo de idioma, lo ponemos:
      // language: { url: CTX + "/js/datatables_es.json" }
    });
  }

  async function cargarRoles(selectId = null) {
    const json = await postForm(CTX + "/RolesServlet", { action: "listar" });
    if (json.status !== "success") throw new Error(json.message || "No se pudieron cargar roles.");

    const sel = document.getElementById("selectRol");
    sel.innerHTML = '<option value="">-- Selecciona un rol --</option>';

    json.data.forEach(r => {
      const opt = document.createElement("option");
      opt.value = r.idRol;
      opt.textContent = `${r.rol} ${r.estado === 1 ? "" : "(INACTIVO)"}`;
      opt.dataset.estado = r.estado;
      sel.appendChild(opt);
    });

    if (selectId) sel.value = selectId;
  }

  function renderTablaModulos(data) {
    initDataTable();
    dtModulos.clear();

    data.forEach(m => {
      const checked = (m.asignado === 1) ? "checked" : "";
      const disabled = (m.estadoModulo !== 1) ? "disabled" : ""; // opcional: no asignar módulos inactivos

      const badgeEstado = (m.estadoModulo === 1)
        ? '<span class="badge bg-success">ACTIVO</span>'
        : '<span class="badge bg-secondary">INACTIVO</span>';

      const btnEstado = (m.estadoModulo === 1)
        ? `<button class="btn btn-sm btn-outline-danger btnModEstado" data-id="${m.idModulo}" data-estado="0">Inactivar</button>`
        : `<button class="btn btn-sm btn-outline-success btnModEstado" data-id="${m.idModulo}" data-estado="1">Activar</button>`;

      const btnEditar = `<button class="btn btn-sm btn-outline-primary btnModEditar" data-id="${m.idModulo}" data-nombre="${escHtml(m.modulo)}">Editar</button>`;

      dtModulos.row.add([
        `<div class="text-center">
           <input type="checkbox" class="chkAcceso" data-id="${m.idModulo}" ${checked} ${disabled}>
         </div>`,
        `<span>${escHtml(m.modulo)}</span>`,
        `<div class="text-center">${badgeEstado}</div>`,
        `<div class="d-flex gap-2 justify-content-center">${btnEditar}${btnEstado}</div>`
      ]);
    });

    dtModulos.draw();
  }

  async function cargarModulosPorRol() {
    const idRol = document.getElementById("selectRol").value;
    if (!idRol) {
      renderTablaModulos([]);
      return;
    }

    showLoading("Cargando módulos...");
    try {
      const json = await postForm(CTX + "/AccesosServlet", { action: "obtener", idRol });
      Swal.close();

      if (json.status !== "success") {
        toastErr(json.message || "No se pudieron cargar módulos.");
        return;
      }

      renderTablaModulos(json.data);
    } catch (e) {
      Swal.close();
      toastErr(e.message);
    }
  }

  function getModulosSeleccionadosCsv() {
    const checks = document.querySelectorAll(".chkAcceso");
    const ids = [];
    checks.forEach(chk => {
      if (chk.checked && !chk.disabled) ids.push(chk.dataset.id);
    });
    return ids.join(",");
  }

  async function guardarPermisos() {
    const idRol = document.getElementById("selectRol").value;
    if (!idRol) return toastErr("Selecciona un rol.");

    // opcional: bloquear si rol inactivo
    const opt = document.querySelector(`#selectRol option[value="${idRol}"]`);
    if (opt && String(opt.dataset.estado) === "0") {
      return toastErr("El rol está inactivo. Actívalo para gestionar accesos.");
    }

    const modulosCsv = getModulosSeleccionadosCsv();

    const confirm = await Swal.fire({
      icon: "question",
      title: "Guardar permisos",
      text: "¿Deseas guardar los accesos seleccionados para este rol?",
      showCancelButton: true,
      confirmButtonText: "Sí, guardar",
      cancelButtonText: "Cancelar"
    });
    if (!confirm.isConfirmed) return;

    showLoading("Guardando permisos...");
    try {
      const json = await postForm(CTX + "/AccesosServlet", { action: "guardar", idRol, modulosCsv });
      Swal.close();

      if (json.status === "success") {
        toastOk(json.message || "Permisos guardados.");
        await cargarModulosPorRol();
      } else {
        toastErr(json.message || "No se pudieron guardar permisos.");
      }
    } catch (e) {
      Swal.close();
      toastErr(e.message);
    }
  }

  async function crearRol() {
    const rol = (document.getElementById("txtNuevoRol").value || "").trim();
    if (!rol) return toastErr("Escribe el nombre del rol.");

    showLoading("Creando rol...");
    try {
      const json = await postForm(CTX + "/RolesServlet", { action: "insertar", rol });
      Swal.close();

      if (json.status === "success") {
        document.getElementById("txtNuevoRol").value = "";
        toastOk(json.message || "Rol creado.");
        await cargarRoles();
        bootstrap.Modal.getInstance(document.getElementById("modalNuevoRol")).hide();
      } else {
        toastErr(json.message || "No se pudo crear el rol.");
      }
    } catch (e) {
      Swal.close();
      toastErr(e.message);
    }
  }

  async function crearModulo() {
    const modulo = (document.getElementById("txtNuevoModulo").value || "").trim();
    if (!modulo) return toastErr("Escribe el nombre del módulo.");

    showLoading("Creando módulo...");
    try {
      const json = await postForm(CTX + "/ModulosServlet", { action: "insertar", modulo });
      Swal.close();

      if (json.status === "success") {
        document.getElementById("txtNuevoModulo").value = "";
        toastOk(json.message || "Módulo creado.");
        await cargarModulosPorRol();
        bootstrap.Modal.getInstance(document.getElementById("modalNuevoModulo")).hide();
      } else {
        toastErr(json.message || "No se pudo crear el módulo.");
      }
    } catch (e) {
      Swal.close();
      toastErr(e.message);
    }
  }

  async function cambiarEstadoRol(estado) {
    const idRol = document.getElementById("selectRol").value;
    if (!idRol) return toastErr("Selecciona un rol.");

    const txt = (estado === 1) ? "activar" : "inactivar";
    const confirm = await Swal.fire({
      icon: "warning",
      title: `Confirmar ${txt}`,
      text: `¿Deseas ${txt} el rol seleccionado?`,
      showCancelButton: true,
      confirmButtonText: "Sí",
      cancelButtonText: "Cancelar"
    });
    if (!confirm.isConfirmed) return;

    showLoading("Actualizando rol...");
    try {
      const json = await postForm(CTX + "/RolesServlet", { action: "estado", idRol, estado });
      Swal.close();

      if (json.status === "success") {
        toastOk(json.message || "Rol actualizado.");
        const keep = idRol;
        await cargarRoles(keep);
        await cargarModulosPorRol();
      } else {
        toastErr(json.message || "No se pudo actualizar el rol.");
      }
    } catch (e) {
      Swal.close();
      toastErr(e.message);
    }
  }

  async function cambiarEstadoModulo(idModulo, estado) {
    const txt = (estado === 1) ? "activar" : "inactivar";

    const confirm = await Swal.fire({
      icon: "warning",
      title: `Confirmar ${txt}`,
      text: `¿Deseas ${txt} este módulo?`,
      showCancelButton: true,
      confirmButtonText: "Sí",
      cancelButtonText: "Cancelar"
    });
    if (!confirm.isConfirmed) return;

    showLoading("Actualizando módulo...");
    try {
      const json = await postForm(CTX + "/ModulosServlet", { action: "estado", idModulo, estado });
      Swal.close();

      if (json.status === "success") {
        toastOk(json.message || "Módulo actualizado.");
        await cargarModulosPorRol();
      } else {
        toastErr(json.message || "No se pudo actualizar el módulo.");
      }
    } catch (e) {
      Swal.close();
      toastErr(e.message);
    }
  }

  function openEditarModulo(id, nombre) {
    document.getElementById("editIdModulo").value = id;
    // nombre viene ya “html-escapado” en dataset, pero aquí lo dejamos tal cual
    // por seguridad, lo cargamos como texto real:
    const tmp = document.createElement("textarea");
    tmp.innerHTML = nombre;
    document.getElementById("editNombreModulo").value = tmp.value;

    modalEditarModulo().show();
  }

  async function guardarEditarModulo() {
    const idModulo = document.getElementById("editIdModulo").value;
    const modulo = (document.getElementById("editNombreModulo").value || "").trim();
    if (!idModulo) return toastErr("Falta idModulo.");
    if (!modulo) return toastErr("Escribe el nombre del módulo.");

    showLoading("Guardando cambios...");
    try {
      const json = await postForm(CTX + "/ModulosServlet", { action: "actualizar", idModulo, modulo });
      Swal.close();

      if (json.status === "success") {
        toastOk(json.message || "Módulo actualizado.");
        bootstrap.Modal.getInstance(document.getElementById("modalEditarModulo")).hide();
        await cargarModulosPorRol();
      } else {
        toastErr(json.message || "No se pudo actualizar.");
      }
    } catch (e) {
      Swal.close();
      toastErr(e.message);
    }
  }

  function bindEvents() {
    document.getElementById("btnOpenNuevoRol").addEventListener("click", () => {
      document.getElementById("txtNuevoRol").value = "";
      modalNuevoRol().show();
    });

    document.getElementById("btnOpenNuevoModulo").addEventListener("click", () => {
      document.getElementById("txtNuevoModulo").value = "";
      modalNuevoModulo().show();
    });

    document.getElementById("btnCrearRol").addEventListener("click", crearRol);
    document.getElementById("btnCrearModulo").addEventListener("click", crearModulo);
    document.getElementById("btnGuardarEditarModulo").addEventListener("click", guardarEditarModulo);

    document.getElementById("selectRol").addEventListener("change", cargarModulosPorRol);
    document.getElementById("btnRecargarTodo").addEventListener("click", async () => {
      const keep = document.getElementById("selectRol").value;
      await cargarRoles(keep);
      await cargarModulosPorRol();
    });

    document.getElementById("btnGuardarPermisos").addEventListener("click", guardarPermisos);

    document.getElementById("btnRolActivar").addEventListener("click", () => cambiarEstadoRol(1));
    document.getElementById("btnRolInactivar").addEventListener("click", () => cambiarEstadoRol(0));

    // Delegación en tabla: activar/inactivar + editar
    document.getElementById("tablaModulos").addEventListener("click", (ev) => {
      const btnEstado = ev.target.closest(".btnModEstado");
      if (btnEstado) {
        cambiarEstadoModulo(btnEstado.dataset.id, parseInt(btnEstado.dataset.estado, 10));
        return;
      }

      const btnEditar = ev.target.closest(".btnModEditar");
      if (btnEditar) {
        openEditarModulo(btnEditar.dataset.id, btnEditar.dataset.nombre);
        return;
      }
    });
  }

  async function init() {
    try {
      initDataTable();
      renderTablaModulos([]);
      await cargarRoles();
    } catch (e) {
      toastErr(e.message);
    }
  }

  document.addEventListener("DOMContentLoaded", () => {
    bindEvents();
    init();
  });

})();
