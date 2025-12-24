package controladores;

import dao.DetalleGuiaDAO;
import modelos.reportes.DetalleGuia;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

@WebServlet("/DetalleGuia")
public class DetalleGuiaController extends HttpServlet {

    private final DetalleGuiaDAO dao = new DetalleGuiaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🔐 Validar sesión
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 📌 Params que vienen por URL desde el botón
        String doc = request.getParameter("doc");
        String tipo = request.getParameter("tipo");

        // Se envían al JSP (para que el JS haga POST con estos datos)
        request.setAttribute("doc", doc);
        request.setAttribute("tipo", tipo);

        request.getRequestDispatcher("/reportes/detalleGuia.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> res = new HashMap<>();

        // 🔐 Validar sesión
        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("usuario") == null) {
            res.put("status", "logout");
            res.put("message", "Sesión expirada. Inicia sesión nuevamente.");
            escribirJson(response, res);
            return;
        }

        // 📌 Leer parámetros (pueden venir del JS)
        String doc = request.getParameter("doc");
        String tipo = request.getParameter("tipo");

        if (doc == null || doc.trim().isEmpty()) {
            res.put("status", "error");
            res.put("message", "Parámetro requerido: doc (DOC_MATERIAL).");
            escribirJson(response, res);
            return;
        }

        if (tipo == null || tipo.trim().isEmpty()) {
            res.put("status", "error");
            res.put("message", "Parámetro requerido: tipo (DEVOLUCIONES, DONACIONES, EXCESOS).");
            escribirJson(response, res);
            return;
        }

        doc = doc.trim();
        tipo = tipo.trim().toUpperCase();

        if (!("DEVOLUCIONES".equals(tipo) || "DONACIONES".equals(tipo) || "EXCESOS".equals(tipo))) {
            res.put("status", "error");
            res.put("message", "Tipo inválido. Use DEVOLUCIONES, DONACIONES o EXCESOS.");
            escribirJson(response, res);
            return;
        }

        try {
            List<DetalleGuia> lista = dao.listarDetallePorDocTipo(doc, tipo);

            if (lista == null || lista.isEmpty()) {
                res.put("status", "empty");
                res.put("message", "No se encontraron registros.");
                res.put("data", lista);
            } else {
                res.put("status", "success");
                res.put("data", lista);
                res.put("total", lista.size());
            }

            res.put("doc", doc);
            res.put("tipo", tipo);

        } catch (Exception e) {
            e.printStackTrace();
            res.put("status", "error");
            res.put("message", "Ocurrió un error: " + e.getMessage());
        }

        escribirJson(response, res);
    }

    private void escribirJson(HttpServletResponse response, Map<String, Object> res) throws IOException {
        Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd").create();
        String json = gson.toJson(res);

        try (PrintWriter out = response.getWriter()) {
            out.print(json);
            out.flush();
        }
    }
}
