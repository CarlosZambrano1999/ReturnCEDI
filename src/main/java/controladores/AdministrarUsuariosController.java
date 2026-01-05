package controladores;

import dao.UsuarioDAO;
import dao.RolDAO;
import modelos.Usuario;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import modelos.Rol;

@WebServlet("/admin")
public class AdministrarUsuariosController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        
        HttpSession session = req.getSession(false);
        Usuario usuario = (session != null) ? (Usuario) session.getAttribute("usuario") : null;
        if (usuario == null || usuario.getIdRol() != 1) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        // 1) Listar usuarios
        try {
            List<Usuario> usuarios = new UsuarioDAO().listarUsuarios();
            req.setAttribute("usuarios", usuarios);
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "No se pudieron cargar los usuarios.");
            req.setAttribute("usuarios", java.util.Collections.emptyList());
        }

        // 2) Cargar ROLES para el combo
        try {
            RolDAO rolDAO = new RolDAO();
            List<Rol> roles = rolDAO.listarActivos();
            req.setAttribute("roles", roles);
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("roles", java.util.Collections.emptyList());
        }

        // 4) Ir al JSP
        req.getRequestDispatcher("/usuario/usuarios.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        req.setCharacterEncoding("UTF-8");
        
        HttpSession session = req.getSession(false);
        Usuario usuario = (session != null) ? (Usuario) session.getAttribute("usuario") : null;
        if (usuario == null || usuario.getIdRol() != 1) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        String accion = req.getParameter("accion");

        // === EDITAR USUARIO (nombre, rol, farmacia) ===
        if ("editar".equalsIgnoreCase(accion)) {
            String idUsuarioStr = req.getParameter("id_usuario");
            String nombre = req.getParameter("nombre");
            String idRolStr = req.getParameter("idRol");
            String nuevaPwd = ""; // fuerza NO cambio de contraseña

            try {
                int idUsuario = Integer.parseInt(idUsuarioStr);
                int idRol = Integer.parseInt(idRolStr);

                Usuario u = new Usuario();
                u.setIdUsuario(idUsuario);
                u.setNombre(nombre);
                u.setIdRol(idRol);

                UsuarioDAO usuarioDAO = new UsuarioDAO();
                String resultado = usuarioDAO.actualizarUsuario(u, nuevaPwd);

                if (resultado.startsWith("OK|")) {
                    req.getSession().setAttribute("msg_ok", resultado.substring(3));
                } else {
                    req.getSession().setAttribute("msg_err",
                            resultado.length() > 4 ? resultado.substring(4) : "Error al actualizar usuario.");
                }

            } catch (Exception e) {
                e.printStackTrace();
                req.getSession().setAttribute("msg_err", "Error al actualizar usuario: " + e.getMessage());
            }

            resp.sendRedirect(req.getContextPath() + "/admin");
            return;
        }

        // === CAMBIAR CONTRASEÑA ===
        if ("cambiar_password".equalsIgnoreCase(accion)) {
            String idUsuarioStr = req.getParameter("id_usuario");
            String nuevaPwd = req.getParameter("password");
            String confirmarPwd = req.getParameter("password_confirm");

            try {
                int idUsuario = Integer.parseInt(idUsuarioStr);

                if (nuevaPwd == null || nuevaPwd.trim().isEmpty()
                        || confirmarPwd == null || confirmarPwd.trim().isEmpty()) {
                    req.getSession().setAttribute("msg_err", "Debes ingresar y confirmar la nueva contraseña.");
                } else if (!nuevaPwd.equals(confirmarPwd)) {
                    req.getSession().setAttribute("msg_err", "Las contraseñas no coinciden.");
                } else {
                    UsuarioDAO usuarioDAO = new UsuarioDAO();
                    String resultado = usuarioDAO.cambiarPassword(idUsuario, nuevaPwd);

                    if (resultado.startsWith("OK|")) {
                        req.getSession().setAttribute("msg_ok", resultado.substring(3));
                    } else {
                        req.getSession().setAttribute("msg_err",
                                resultado.length() > 4 ? resultado.substring(4) : "Error al cambiar la contraseña.");
                    }
                }

            } catch (Exception e) {
                e.printStackTrace();
                req.getSession().setAttribute("msg_err", "Error al cambiar contraseña: " + e.getMessage());
            }

            resp.sendRedirect(req.getContextPath() + "/admin");
            return;
        }

        // === ACTIVAR / INACTIVAR USUARIO ===
        if ("estado".equalsIgnoreCase(accion)) {
            String idUsuarioStr = req.getParameter("id_usuario");
            String nuevoEstadoStr = req.getParameter("nuevo_estado");

            try (Connection cn = new configDB.ConexionSQLServer().getConnection(); PreparedStatement ps = cn.prepareStatement(
                    "UPDATE PERSONA.USUARIO SET estado = ? WHERE id_usuario = ?")) {

                ps.setInt(1, Integer.parseInt(nuevoEstadoStr));
                ps.setInt(2, Integer.parseInt(idUsuarioStr));
                ps.executeUpdate();

                req.getSession().setAttribute("msg_ok", "Estado actualizado correctamente.");
            } catch (Exception e) {
                e.printStackTrace();
                req.getSession().setAttribute("msg_err", "Error al actualizar estado: " + e.getMessage());
            }

            resp.sendRedirect(req.getContextPath() + "/admin");
        }
    }

}
