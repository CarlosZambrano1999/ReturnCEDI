package controladores;

import dao.RptUsuarioDAO;
import modelos.Usuario;
import modelos.reportes.RptUsuario;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Date;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

@WebServlet("/IncidenciasDonaciones")
public class RptDonacionesController extends HttpServlet {

    private final RptUsuarioDAO dao = new RptUsuarioDAO();
    private static final int TIPO = 2;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Usuario usuario = (session != null) ? (Usuario) session.getAttribute("usuario") : null;
        if (usuario == null || (usuario.getIdRol() != 1 && usuario.getIdRol() != 2 && usuario.getIdRol() != 5)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        request.getRequestDispatcher("/reportes/rptUsuario.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        Map<String, Object> res = new HashMap<>();

        HttpSession sesion = request.getSession(false);
        if (sesion == null || sesion.getAttribute("usuario") == null) {
            res.put("status", "logout");
            res.put("message", "Sesión expirada. Inicia sesión nuevamente.");
            escribirJson(response, res);
            return;
        }

        Usuario usuario = (Usuario) sesion.getAttribute("usuario");
        int idUsuario = usuario.getIdUsuario();

        Date desde = null;
        Date hasta = null;

        String desdeStr = request.getParameter("desde");
        String hastaStr = request.getParameter("hasta");

        try {
            boolean tieneDesde = (desdeStr != null && !desdeStr.trim().isEmpty());
            boolean tieneHasta = (hastaStr != null && !hastaStr.trim().isEmpty());

            if (tieneDesde) {
                desde = Date.valueOf(desdeStr.trim());
            }
            if (tieneHasta) {
                hasta = Date.valueOf(hastaStr.trim());
            }

            // ✅ Si NO mandan ninguna fecha -> rango del mes actual
            if (!tieneDesde && !tieneHasta) {
                LocalDate hoy = LocalDate.now();
                LocalDate primero = hoy.withDayOfMonth(1);
                LocalDate ultimo = hoy.withDayOfMonth(hoy.lengthOfMonth());

                desde = Date.valueOf(primero);
                hasta = Date.valueOf(ultimo);
            }

            // ✅ Si mandan solo DESDE -> completar HASTA con último día de ese mes
            if (tieneDesde && !tieneHasta) {
                LocalDate ld = desde.toLocalDate();
                LocalDate ultimo = ld.withDayOfMonth(ld.lengthOfMonth());
                hasta = Date.valueOf(ultimo);
            }

            // ✅ Si mandan solo HASTA -> completar DESDE con primer día de ese mes
            if (!tieneDesde && tieneHasta) {
                LocalDate lh = hasta.toLocalDate();
                LocalDate primero = lh.withDayOfMonth(1);
                desde = Date.valueOf(primero);
            }

        } catch (IllegalArgumentException e) {
            res.put("status", "error");
            res.put("message", "Formato de fecha inválido. Usa YYYY-MM-DD.");
            escribirJson(response, res);
            return;
        }

        // ✅ por si luego querés llenar inputs en el JSP
        res.put("desde_aplicado", (desde != null ? desde.toString() : null));
        res.put("hasta_aplicado", (hasta != null ? hasta.toString() : null));

        try {
            List<RptUsuario> lista = dao.listarPorUsuarioYTipoFecha(idUsuario, TIPO, desde, hasta);

            if (lista == null || lista.isEmpty()) {
                res.put("status", "empty");
                res.put("message", "No se encontraron registros.");
                res.put("data", lista);
            } else {
                res.put("status", "success");
                res.put("data", lista);
                res.put("total", lista.size());
            }

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
