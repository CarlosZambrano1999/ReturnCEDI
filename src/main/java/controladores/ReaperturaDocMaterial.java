/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controladores;

import com.google.gson.Gson;
import dao.GuiasDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import modelos.Usuario;

/**
 *
 * @author Administrador
 */
@WebServlet("/reaperturarDocMaterial")
public class ReaperturaDocMaterial extends HttpServlet {

    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

        Map<String, Object> res = new HashMap<>();

        try {
            HttpSession sesion = request.getSession(false);

            if (sesion == null || sesion.getAttribute("usuario") == null) {
                res.put("status", "logout");
                res.put("message", "Sesión expirada. Inicia sesión nuevamente.");
                response.getWriter().write(gson.toJson(res));
                return;
            }

            Usuario usuario = (Usuario) sesion.getAttribute("usuario");
            int idUsuario = usuario.getIdUsuario();

            String docMaterial = request.getParameter("doc_material");

            if (docMaterial == null || docMaterial.trim().isEmpty()) {
                res.put("status", "error");
                res.put("message", "doc_material es requerido.");
                response.getWriter().write(gson.toJson(res));
                return;
            }

            GuiasDAO dao = new GuiasDAO();
            Map<String, String> r = dao.reaperturarDocMaterial(docMaterial.trim(), idUsuario);

            res.put("status", r.getOrDefault("status", "error"));
            res.put("message", r.getOrDefault("message", "Ocurrió un error."));

            response.getWriter().write(gson.toJson(res));

        } catch (Exception e) {
            res.put("status", "error");
            res.put("message", e.getMessage());
            response.getWriter().write(gson.toJson(res));
        }
    }
}