package controladores;

import dao.IncidenciaDAO;
import modelos.Incidencia;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/Incidencia")
public class IncidenciaController extends HttpServlet {

    private final IncidenciaDAO dao = new IncidenciaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            List<Incidencia> lista = dao.listarIncidencias();
            request.setAttribute("listaIncidencias", lista);
            request.getRequestDispatcher("/incidencia/incidencia.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar incidencias: " + e.getMessage());
            request.getRequestDispatcher("/home/home.jsp").forward(request, response);
        }
    }

    @Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    String accion = request.getParameter("accion");
    if (accion == null || accion.trim().isEmpty()) accion = request.getParameter("action");
    if (accion == null || accion.trim().isEmpty()) accion = "INSERTAR";
    accion = accion.trim().toUpperCase();

    String incidencia = request.getParameter("incidencia");
    String idStr = request.getParameter("id_incidencia");

    Integer idIncidencia = null;
    if (idStr != null && !idStr.trim().isEmpty()) {
        try {
            idIncidencia = Integer.parseInt(idStr.trim());
        } catch (NumberFormatException e) {
            request.getSession().setAttribute("swalIcon", "error");
            request.getSession().setAttribute("swalTitle", "ID inválido");
            request.getSession().setAttribute("swalText", "El ID de la incidencia no es válido.");
            response.sendRedirect(request.getContextPath() + "/Incidencia");
            return;
        }
    }

    // Validaciones mínimas (también con SweetAlert)
    if ("INSERTAR".equals(accion) || "EDITAR".equals(accion)) {
        if (incidencia == null || incidencia.trim().isEmpty()) {
            request.getSession().setAttribute("swalIcon", "warning");
            request.getSession().setAttribute("swalTitle", "Campo requerido");
            request.getSession().setAttribute("swalText", "La incidencia es obligatoria.");
            response.sendRedirect(request.getContextPath() + "/Incidencia");
            return;
        }
        incidencia = incidencia.trim();
    } else {
        if (idIncidencia == null || idIncidencia <= 0) {
            request.getSession().setAttribute("swalIcon", "warning");
            request.getSession().setAttribute("swalTitle", "Falta ID");
            request.getSession().setAttribute("swalText", "Debes seleccionar una incidencia válida.");
            response.sendRedirect(request.getContextPath() + "/Incidencia");
            return;
        }
        incidencia = null;
    }

    try {
        boolean ok = dao.ejecutarAccion(accion, idIncidencia, incidencia);

        if (ok) {
            request.getSession().setAttribute("swalIcon", "success");

            switch (accion) {
                case "INSERTAR":
                    request.getSession().setAttribute("swalTitle", "Guardado");
                    request.getSession().setAttribute("swalText", "Incidencia creada correctamente.");
                    break;
                case "EDITAR":
                    request.getSession().setAttribute("swalTitle", "Actualizado");
                    request.getSession().setAttribute("swalText", "Incidencia editada correctamente.");
                    break;
                case "ACTIVAR":
                    request.getSession().setAttribute("swalTitle", "Activada");
                    request.getSession().setAttribute("swalText", "Incidencia activada.");
                    break;
                case "INACTIVAR":
                    request.getSession().setAttribute("swalTitle", "Inactivada");
                    request.getSession().setAttribute("swalText", "Incidencia inactivada.");
                    break;
                default:
                    request.getSession().setAttribute("swalTitle", "Listo");
                    request.getSession().setAttribute("swalText", "Acción ejecutada.");
            }
        } else {
            request.getSession().setAttribute("swalIcon", "error");
            request.getSession().setAttribute("swalTitle", "No se pudo");
            request.getSession().setAttribute("swalText", "No se pudo ejecutar la acción: " + accion);
        }

        response.sendRedirect(request.getContextPath() + "/Incidencia");

    } catch (Exception e) {
        e.printStackTrace();
        request.getSession().setAttribute("swalIcon", "error");
        request.getSession().setAttribute("swalTitle", "Error");
        request.getSession().setAttribute("swalText", "Ocurrió un error: " + e.getMessage());
        response.sendRedirect(request.getContextPath() + "/Incidencia");
    }
}

}
