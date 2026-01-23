package controladores;

import dao.GuiasDAO;
import modelos.Usuario;
import modelos.reportes.Guias;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

@WebServlet("/RptGuias")
public class GuiasController extends HttpServlet {

    private final GuiasDAO dao = new GuiasDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Vista única del reporte
        request.getRequestDispatcher("/reportes/rptGuias.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> res = new HashMap<>();

        
        Usuario user = (Usuario) request.getAttribute("usuario_auth");
        int idUsuario = user.getIdUsuario();

        // 🧩 Obtener rol desde sesión (en tu login se guarda como "rol")
        int rol = user.getIdRol();


        // 📅 Leer fechas opcionales (yyyy-mm-dd)
        Date desde = null;
        Date hasta = null;

        String desdeStr = request.getParameter("desde");
        String hastaStr = request.getParameter("hasta");

        try {
            if (desdeStr != null && !desdeStr.trim().isEmpty()) {
                desde = Date.valueOf(desdeStr.trim());
            }
            if (hastaStr != null && !hastaStr.trim().isEmpty()) {
                hasta = Date.valueOf(hastaStr.trim());
            }
        } catch (IllegalArgumentException e) {
            res.put("status", "error");
            res.put("message", "Formato de fecha inválido. Usa YYYY-MM-DD.");
            escribirJson(response, res);
            return;
        }

        // ✅ Validación de rango
        if (desde != null && hasta != null && desde.after(hasta)) {
            res.put("status", "error");
            res.put("message", "Rango inválido: DESDE no puede ser mayor que HASTA.");
            escribirJson(response, res);
            return;
        }

        // 📊 Consultar DAO
        try {
            List<Guias> lista = dao.listarGuias(idUsuario, rol, desde, hasta);

            if (lista == null || lista.isEmpty()) {
                res.put("status", "empty");
                res.put("message", "No se encontraron registros.");
                res.put("data", lista);
            } else {
                res.put("status", "success");
                res.put("data", lista);
                res.put("total", lista.size());
            }

            // Opcional: devolver info para debug
            res.put("rol", rol);

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
