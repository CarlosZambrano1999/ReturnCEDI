/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controladores;

import dao.HomeDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;
import modelos.Modulo;
import modelos.Usuario;

/**
 *
 * @author Administrador
 */

@WebServlet("/home")
public class HomeController extends HttpServlet {
    
    private final HomeDAO dao = new HomeDAO();
        @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
         HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            String msg = URLEncoder.encode("Inicie sesión para continuar.", "UTF-8");
            response.sendRedirect(request.getContextPath() + "/login?error=" + msg);
            return;
        }

        // (Opcional) Puedes pasar el usuario al JSP
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        request.setAttribute("usuario", usuario);

        try {
            List<Modulo> mods = dao.obtenerModulosHome(usuario.getIdRol());

            request.setAttribute("mods", mods);
            request.getRequestDispatcher("/home/home.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("msgType", "error");
            request.setAttribute("msg", "Error cargando Home: " + e.getMessage());
            request.getRequestDispatcher("/home/home.jsp").forward(request, response);
        }
    }
}
