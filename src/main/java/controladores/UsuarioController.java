/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controladores;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import modelos.Rol;

@WebServlet("/registro")
public class UsuarioController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Cargar roles activos
        try {
            dao.RolDAO rolDAO = new dao.RolDAO();
            List<Rol> roles = rolDAO.listarActivos();
            request.setAttribute("roles", roles);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "No se pudieron cargar los roles.");
            request.setAttribute("roles", java.util.Collections.emptyList());
        }

        // Enruta al JSP
        request.getRequestDispatcher("/usuario/registro.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        // 1) Leer parámetros del formulario
        String nombre     = trimOrNull(request.getParameter("nombre"));
        String codigo     = trimOrNull(request.getParameter("codigo"));
        String password   = request.getParameter("password"); // no trim a contraseñas
        String idRolStr   = request.getParameter("idRol");
        String estadoStr  = request.getParameter("estado");   // opcional (default 1)

        
        // 2) Validaciones mínimas
        if (nombre == null || codigo == null || password == null || password.isEmpty() || idRolStr == null) {
            request.setAttribute("error", "Completa los campos obligatorios: nombre, código, contraseña y rol.");
            // Devolver valores ingresados
            request.setAttribute("val_nombre", nombre);
            request.setAttribute("val_codigo", codigo);
            request.setAttribute("val_idRol", idRolStr);
            request.setAttribute("val_estado", estadoStr);
            // Recargar combos
            cargarCombos(request);
            request.getRequestDispatcher("/usuario/registro.jsp").forward(request, response);
            return;
        }

        int idRol  = parseIntOrDefault(idRolStr, 0);
        int estado = parseIntOrDefault(estadoStr, 1); // por defecto activo

        if (idRol <= 0) {
            request.setAttribute("error", "Selecciona un rol válido.");
            request.setAttribute("val_nombre", nombre);
            request.setAttribute("val_codigo", codigo);
            request.setAttribute("val_idRol", idRolStr);
            request.setAttribute("val_estado", estadoStr);
            cargarCombos(request);
            request.getRequestDispatcher("/usuario/registro.jsp").forward(request, response);
            return;
        }

        // 3) Construir modelo Usuario
        modelos.Usuario u = new modelos.Usuario();
        u.setNombre(nombre);
        u.setCodigo(codigo);
        u.setIdRol(idRol);
        u.setEstado(estado);

        // 4) Llamar al DAO (SP)
        dao.UsuarioDAO usuarioDAO = new dao.UsuarioDAO();
        dao.UsuarioDAO.ResultadoRegistro res = usuarioDAO.registrarUsuarioSP(u, password);

        // 5) Manejo de resultado
        switch (res.getStatus().toLowerCase()) {
            case "success":
                request.setAttribute("ok", "Usuario registrado correctamente (ID: " + res.getIdUsuario() + ").");
                break;
            case "duplicate":
                request.setAttribute("error", "El código de usuario ya existe. Intenta con otro.");
                break;
            default:
                request.setAttribute("error",
                        (res.getMessage() != null ? res.getMessage() : "No se pudo registrar el usuario."));
                break;
        }

        // Mantener valores del formulario (si hubo error)
        request.setAttribute("val_nombre", nombre);
        request.setAttribute("val_codigo", codigo);
        request.setAttribute("val_idRol", idRolStr);
        request.setAttribute("val_estado", estadoStr);

        // Recargar roles y farmacias para el JSP
        cargarCombos(request);
        request.getRequestDispatcher("/usuario/registro.jsp").forward(request, response);
    }

    /* ==== Helpers ==== */

    private static String trimOrNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    private static int parseIntOrDefault(String s, int def) {
        try {
            return (s == null || s.trim().isEmpty()) ? def : Integer.parseInt(s.trim());
        } catch (NumberFormatException e) {
            return def;
        }
    }

    // Método auxiliar para recargar combos
    private void cargarCombos(HttpServletRequest request) {
        try {
            dao.RolDAO rolDAO = new dao.RolDAO();
            request.setAttribute("roles", rolDAO.listarActivos());
        } catch (Exception e) {
            request.setAttribute("roles", java.util.Collections.emptyList());
        }

    }
}
