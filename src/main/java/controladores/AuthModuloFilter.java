/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controladores;

import dao.AccesoDAO;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import modelos.Usuario;

/**
 *
 * @author Administrador
 */
@WebFilter("/*") // o limita a rutas: {"/Devoluciones","/Donaciones",...}
public class AuthModuloFilter implements Filter {

    private final AccesoDAO accesoDAO = new AccesoDAO();

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String path = request.getServletPath();

        // 1) Permitir recursos públicos o estáticos
        if (path.startsWith("/css") || path.startsWith("/js") || path.startsWith("/image") || path.startsWith("/fonts")
                || path.equals("/login") || path.equals("/logout") || path.equals("/componentes") || path.endsWith(".jsp")
                || path.equals("/RolesServlet") || path.equals("/AccesosServlet") || path.equals("/ModulosServlet")
                || path.endsWith(".css") || path.endsWith(".js") || path.endsWith(".json")
                ) {
            chain.doFilter(req, res);
            return;
        }

        HttpSession session = request.getSession(false);
        Usuario usuario = (session != null) ? (Usuario) session.getAttribute("usuario") : null;

        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            boolean permitido = accesoDAO.tieneAcceso(usuario.getIdRol(), path);
            if (!permitido) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }
        
        request.setAttribute("usuario_auth", usuario);

        chain.doFilter(req, res);
    }
}
