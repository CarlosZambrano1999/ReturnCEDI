/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controladores;

import dao.GuiasDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import modelos.DocumentosPendientes;
import modelos.Usuario;

/**
 *
 * @author Administrador
 */
@WebServlet("/GuiasPendientes")
public class ListarPendientesController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) action = "view";

        // 1) Verificar sesión y obtener usuario
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("usuario") == null) {
            // Si no hay sesión, redirige a login o manda error (ajusta tu ruta)
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Usuario usuario = (Usuario) sesion.getAttribute("usuario");
        int idUsuario = usuario.getIdUsuario();

        // 2) Acción: view => enviar al JSP
        if ("view".equalsIgnoreCase(action)) {
            request.getRequestDispatcher("/reportes/guiasPendientes.jsp")
                   .forward(request, response);
            return;
        }

        // 3) Acción: data => JSON para DataTables / fetch
        if ("data".equalsIgnoreCase(action)) {
            response.setContentType("application/json;charset=UTF-8");

            try {
                GuiasDAO dao = new GuiasDAO();
                List<DocumentosPendientes> lista = dao.listarGuiasPendientes(idUsuario);

                StringBuilder json = new StringBuilder();
                json.append("{\"status\":\"success\",\"data\":[");

                for (int i = 0; i < lista.size(); i++) {
                    DocumentosPendientes d = lista.get(i);

                    String tipo = d.getTipo() == null ? "" : escapeJson(d.getTipo());
                    String nomUsuario = d.getUsuario() == null ? "" : escapeJson(d.getUsuario());
                    String fecha = (d.getFecha() == null) ? "" : d.getFecha().toString();

                    json.append("{")
                        .append("\"numero\":").append(d.getNumero()).append(",")
                        .append("\"estado\":").append(d.getEstado()).append(",")
                        .append("\"fecha\":\"").append(escapeJson(fecha)).append("\",")
                        .append("\"tipo\":\"").append(tipo).append("\",")
                        .append("\"usuario\":\"").append(nomUsuario).append("\"")
                        .append("}");

                    if (i < lista.size() - 1) json.append(",");
                }

                json.append("]}");
                response.getWriter().write(json.toString());

            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().write("{\"status\":\"error\",\"message\":\"Error: " + escapeJson(e.getMessage()) + "\"}");
            }
            return;
        }

        // 4) Si action no es válida
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"status\":\"error\",\"message\":\"Acción no válida.\"}");
    }

    private static String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
