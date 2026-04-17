let interactuandoFormulario = false;

function getEl(id) {
    return document.getElementById(id);
}

function focusScanner(force = false) {
    const scanner = getEl("scanner");
    if (!scanner) return;

    if (interactuandoFormulario && !force) return;

    scanner.focus();
    scanner.select();
}

function mostrarSpinnerBuscar(mostrar) {
    const spinner = getEl("spinnerBuscar");
    if (!spinner) return;
    spinner.classList.toggle("d-none", !mostrar);
}

function mostrarSpinnerProveedor(mostrar) {
    const spinner = getEl("spinnerProveedor");
    if (!spinner) return;
    spinner.classList.toggle("d-none", !mostrar);
}

function estaDentroDelFlujo(elemento) {
    if (!elemento) return false;

    const idsPermitidos = [
        "scanner",
        "idProveedor",
        "idColor",
        "fechaVencimiento",
        "btnConsultar"
    ];

    return idsPermitidos.includes(elemento.id);
}

function limpiarSeleccionDependiente() {
    const color = getEl("idColor");
    const fecha = getEl("fechaVencimiento");

    if (color) {
        color.selectedIndex = 0;
    }

    if (fecha) {
        fecha.value = "";
    }
}

function validarConsulta() {
    const proveedorHidden = getEl("hiddenProveedor");
    const color = getEl("idColor");
    const fecha = getEl("fechaVencimiento");

    const idProveedor = proveedorHidden ? proveedorHidden.value.trim() : "";
    const idColor = color ? color.value.trim() : "";
    const fechaVenc = fecha ? fecha.value.trim() : "";

    if (!idProveedor) {
        Swal.fire({
            icon: "warning",
            title: "Atención",
            text: "Seleccioná un proveedor."
        });
        return false;
    }

    if (!idColor) {
        Swal.fire({
            icon: "warning",
            title: "Atención",
            text: "Seleccioná un color."
        });
        return false;
    }

    if (!fechaVenc) {
        Swal.fire({
            icon: "warning",
            title: "Atención",
            text: "Ingresá la fecha de vencimiento."
        });
        return false;
    }

    return true;
}

function registrarInteraccionCampo(el) {
    if (!el) return;

    el.addEventListener("focus", () => {
        interactuandoFormulario = true;
    });

    el.addEventListener("blur", () => {
        setTimeout(() => {
            const activo = document.activeElement;
            interactuandoFormulario = estaDentroDelFlujo(activo) && activo.id !== "scanner";

            if (!estaDentroDelFlujo(activo)) {
                focusScanner(false);
            }
        }, 120);
    });
}

document.addEventListener("DOMContentLoaded", () => {
    const formBuscar = getEl("formBuscar");
    const formProveedor = getEl("formProveedor");
    const formConsultar = getEl("formConsultar");

    const scanner = getEl("scanner");
    const proveedor = getEl("idProveedor");
    const color = getEl("idColor");
    const fecha = getEl("fechaVencimiento");
    const hiddenProveedor = getEl("hiddenProveedor");
    const btnConsultar = getEl("btnConsultar");

    setTimeout(() => focusScanner(true), 80);

    if (scanner && formBuscar) {
        scanner.addEventListener("keydown", (e) => {
            if (e.key === "Enter") {
                e.preventDefault();

                const codigo = scanner.value.trim();
                if (!codigo) {
                    scanner.focus();
                    return;
                }

                mostrarSpinnerBuscar(true);
                formBuscar.submit();
            }
        });
    }

    if (formBuscar) {
        formBuscar.addEventListener("submit", () => {
            mostrarSpinnerBuscar(true);
        });
    }

    if (proveedor && formProveedor) {
        proveedor.addEventListener("change", function () {
            if (hiddenProveedor) {
                hiddenProveedor.value = this.value;
            }

            limpiarSeleccionDependiente();

            if (!this.value) {
                focusScanner(false);
                return;
            }

            mostrarSpinnerProveedor(true);
            formProveedor.submit();
        });
    }

    if (formConsultar) {
        formConsultar.addEventListener("submit", (e) => {
            if (!validarConsulta()) {
                e.preventDefault();
                return;
            }

            mostrarSpinnerBuscar(true);
        });
    }

    [proveedor, color, fecha, btnConsultar].forEach((el) => {
        registrarInteraccionCampo(el);
    });

    document.addEventListener("keydown", (e) => {
        if (e.key === "Escape") {
            interactuandoFormulario = false;
            focusScanner(true);
        }
    });

    document.addEventListener("click", (e) => {
        const dentro = e.target.closest(
            "#formBuscar, #formProveedor, #formConsultar, select, input, button"
        );

        if (!dentro) {
            setTimeout(() => {
                interactuandoFormulario = false;
                focusScanner(false);
            }, 80);
        }
    });
});