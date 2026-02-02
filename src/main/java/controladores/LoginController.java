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
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import modelos.Modulo;

@WebServlet("/login")
public class LoginController extends HttpServlet {
    
    private final HomeDAO homeDAO = new HomeDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Muestra el formulario de login
        request.getRequestDispatcher("/usuario/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String codigo = request.getParameter("codigo");
        String password = request.getParameter("password");

        // Validaciones básicas
        if (codigo == null || codigo.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "Debes ingresar tu código de usuario y contraseña.");
            request.setAttribute("val_codigo", codigo);
            request.getRequestDispatcher("/usuario/login.jsp").forward(request, response);
            return;
        }

        // Invocar DAO para validar credenciales
        dao.UsuarioDAO usuarioDAO = new dao.UsuarioDAO();
        modelos.Usuario usuario = usuarioDAO.validarLoginPorCodigo(codigo, password);

        if (usuario != null) {
            if (usuario.getEstado() == 1) {
                // Login correcto → crear sesión
                HttpSession sesion = request.getSession();
                sesion.setAttribute("usuario", usuario);
                sesion.setAttribute("nombre", usuario.getNombre());
                sesion.setAttribute("rol", usuario.getIdRol());
                List<Modulo> modulos = null;
                try {
                    modulos = homeDAO.obtenerModulosHome(usuario.getIdRol());
                } catch (SQLException ex) {
                    Logger.getLogger(LoginController.class.getName()).log(Level.SEVERE, null, ex);
                }
                sesion.setAttribute("navModulos", modulos);

                // Redirigir al dashboard o página principal
                response.sendRedirect(request.getContextPath() + "/home");
            } else {
                // Usuario inactivo
                request.setAttribute("error", "Tu usuario está inactivo. Contacta al administrador.");
                request.setAttribute("val_codigo", codigo);
                request.getRequestDispatcher("/usuario/login.jsp").forward(request, response);
            }
        } else {
            // Credenciales inválidas
            request.setAttribute("error", "Código o contraseña incorrectos.");
            request.setAttribute("val_codigo", codigo);
            request.getRequestDispatcher("/usuario/login.jsp").forward(request, response);
        }
    }
}
