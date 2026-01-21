/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controladores;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import modelos.Usuario;

/**
 *
 * @author Administrador
 */
public abstract class BaseSeguridadController extends HttpServlet {

  
    protected Usuario getUsuarioSesion(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        Object obj = session.getAttribute("usuario");
        return (obj instanceof Usuario) ? (Usuario) obj : null;
    }

    protected boolean requireSesion(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Usuario u = getUsuarioSesion(req);
        String ctx = req.getContextPath();

        if (u == null) {
            HttpSession s = req.getSession(true);
            s.setAttribute("msg_err", "Sesión no válida o expirada. Inicie sesión nuevamente.");
            resp.sendRedirect(ctx + "/login"); // o "/home"
            return false;
        }
        return true;
    }

    protected boolean requireRol(HttpServletRequest req, HttpServletResponse resp, int... rolesPermitidos) throws IOException {
        Usuario u = getUsuarioSesion(req);
        String ctx = req.getContextPath();
        HttpSession s = req.getSession(true);

        if (u == null) {
            s.setAttribute("msg_err", "Sesión no válida o expirada. Inicie sesión nuevamente.");
            resp.sendRedirect(ctx + "/login");
            return false;
        }

        int rolUsuario = u.getIdRol();
        boolean permitido = false;
        if (rolesPermitidos != null) {
            for (int r : rolesPermitidos) {
                if (rolUsuario == r) {
                    permitido = true;
                    break;
                }
            }
        }

        if (!permitido) {
            s.setAttribute("msg_err", "No tiene permisos para acceder a este módulo.");
            resp.sendRedirect(ctx + "/home");
            return false;
        }

        return true;
    }

    /**
     * Solo permite rol 1.
     */
    protected boolean requireRol1(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        return requireRol(req, resp, 1,2);
    }

    /**
     * Solo permite rol 1 o 2.
     */
    protected boolean requireRol1o2(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        return requireRol(req, resp, 1, 2);
    }
}