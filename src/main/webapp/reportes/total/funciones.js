$(document).ready(function () {

    $('#tablaReporte').DataTable({
        pageLength: 25,
        lengthMenu: [10, 25, 50, 100],
        ordering: true,
        searching: true,
        responsive: false,
        scrollX: true,
        language: { url: ctx + "/js/es-ES.json" },
        dom: 'Bfrtip',
        buttons: [
            {
                extend: 'excelHtml5',
                text: 'Exportar Excel',
                className: 'btn btn-success btn-sm',
                title: 'Reporte_Unificado'
            }
        ],
        initComplete: function () {
            $('#spinnerTabla').addClass('d-none');
            $('#contenedorTabla').removeClass('d-none').hide().fadeIn(200);
        }
    });

    actualizarInputSeleccionado("panelFarmacias", "inputFarmacias");
    actualizarInputSeleccionado("panelTipoEnvio", "inputTipoEnvio");
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


