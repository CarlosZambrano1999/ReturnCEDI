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
import java.io.IOException;
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
        
        Usuario user = (Usuario) request.getAttribute("usuario_auth");

        try {
            List<Modulo> mods = dao.obtenerModulosHome(user.getIdRol());

            request.setAttribute("mods", mods);
            request.getRequestDispatcher("/home/home.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("msgType", "error");
            request.setAttribute("msg", "Error cargando Home: " + e.getMessage());
            request.getRequestDispatcher("/home/home.jsp").forward(request, response);
        }
    }
}
