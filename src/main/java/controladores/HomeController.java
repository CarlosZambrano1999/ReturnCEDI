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
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import modelos.Usuario;

/**
 *
 * @author Administrador
 */

@WebServlet("/home")
public class HomeController extends HttpServlet {
        @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Validar sesión
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            String msg = URLEncoder.encode("Inicie sesión para continuar.", "UTF-8");
            response.sendRedirect(request.getContextPath() + "/login?error=" + msg);
            return;
        }

        // (Opcional) Puedes pasar el usuario al JSP
        Usuario usuario = (Usuario) session.getAttribute("usuario");
        request.setAttribute("usuario", usuario);

        // Enrutar al JSP
        request.getRequestDispatcher("/home/home.jsp").forward(request, response);
    }
}
