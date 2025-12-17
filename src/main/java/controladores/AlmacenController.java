package controladores;

import dao.AlmacenDAO;
import modelos.Almacen;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/Almacen")
public class AlmacenController extends HttpServlet {

    private final AlmacenDAO dao = new AlmacenDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            List<Almacen> lista = dao.listarAlmacenes();
            request.setAttribute("listaAlmacenes", lista);

            request.getRequestDispatcher("/almacen/almacen.jsp").forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Error al cargar almacenes: " + e.getMessage());
            request.getRequestDispatcher("/home/home.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // leer accion/action
        String accion = request.getParameter("accion");
        if (accion == null || accion.trim().isEmpty()) accion = request.getParameter("action");
        if (accion == null || accion.trim().isEmpty()) accion = "INSERTAR";
        accion = accion.trim().toUpperCase();

        String codigo = request.getParameter("codigo");
        String departamento = request.getParameter("departamento");

        // Validaciones mínimas (para no ir a BD por gusto)
        if ("INSERTAR".equals(accion)) {
            if (codigo == null || codigo.trim().isEmpty()) {
                setSwal(request, "warning", "Campo requerido", "El código es obligatorio.");
                response.sendRedirect(request.getContextPath() + "/Almacen");
                return;
            }
            if (departamento == null || departamento.trim().isEmpty()) {
                setSwal(request, "warning", "Campo requerido", "El departamento es obligatorio.");
                response.sendRedirect(request.getContextPath() + "/Almacen");
                return;
            }
        }

        if ("EDITAR".equals(accion)) {
            if (codigo == null || codigo.trim().isEmpty()) {
                setSwal(request, "warning", "Campo requerido", "El código es obligatorio para editar.");
                response.sendRedirect(request.getContextPath() + "/Almacen");
                return;
            }
            if (departamento == null || departamento.trim().isEmpty()) {
                setSwal(request, "warning", "Campo requerido", "El departamento es obligatorio para editar.");
                response.sendRedirect(request.getContextPath() + "/Almacen");
                return;
            }
        }

        if ("ACTIVAR".equals(accion) || "INACTIVAR".equals(accion)) {
            if (codigo == null || codigo.trim().isEmpty()) {
                setSwal(request, "warning", "Falta código", "Debes seleccionar un almacén válido.");
                response.sendRedirect(request.getContextPath() + "/Almacen");
                return;
            }
            departamento = null; // no se usa en estas acciones
        }

        try {
            boolean ok = dao.ejecutarAccion(accion, codigo, departamento);

            if (ok) {
                switch (accion) {
                    case "INSERTAR":
                        setSwal(request, "success", "Guardado", "Almacén creado correctamente.");
                        break;
                    case "EDITAR":
                        setSwal(request, "success", "Actualizado", "Almacén editado correctamente.");
                        break;
                    case "ACTIVAR":
                        setSwal(request, "success", "Activado", "Almacén activado.");
                        break;
                    case "INACTIVAR":
                        setSwal(request, "success", "Inactivado", "Almacén inactivado.");
                        break;
                    default:
                        setSwal(request, "success", "Listo", "Acción ejecutada.");
                        break;
                }
            } else {
                setSwal(request, "error", "No se pudo", "No se pudo ejecutar la acción: " + accion);
            }

            response.sendRedirect(request.getContextPath() + "/Almacen");

        } catch (Exception e) {
            e.printStackTrace();
            setSwal(request, "error", "Error", "Ocurrió un error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/Almacen");
        }
    }

    private void setSwal(HttpServletRequest request, String icon, String title, String text) {
        request.getSession().setAttribute("swalIcon", icon);
        request.getSession().setAttribute("swalTitle", title);
        request.getSession().setAttribute("swalText", text);
    }
}
