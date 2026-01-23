package controladores;

import dao.RolDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import modelos.Rol;

/**
 *
 * @author Administrador
 */
@WebServlet("/RolesServlet")
public class RolesController extends HttpServlet {

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    private void writeJson(HttpServletResponse resp, String json) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write(json);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "";

        RolDAO dao = new RolDAO();

        try {
            switch (action) {
                case "listar": {
                    List<Rol> roles = dao.listar();
                    StringBuilder sb = new StringBuilder();
                    sb.append("{\"status\":\"success\",\"data\":[");
                    for (int i = 0; i < roles.size(); i++) {
                        Rol r = roles.get(i);
                        if (i > 0) sb.append(",");
                        sb.append("{")
                          .append("\"idRol\":").append(r.getId_rol()).append(",")
                          .append("\"rol\":\"").append(esc(r.getRol())).append("\",")
                          .append("\"estado\":").append(r.getEstado())
                          .append("}");
                    }
                    sb.append("]}");
                    writeJson(response, sb.toString());
                    break;
                }

                case "insertar": {
                    String rol = request.getParameter("rol");
                    RolDAO.ResultadoSP res = dao.insertar(rol);

                    String json = "{"
                            + "\"status\":\"" + esc(res.getStatus()) + "\","
                            + "\"message\":\"" + esc(res.getMessage()) + "\""
                            + "}";
                    writeJson(response, json);
                    break;
                }

                case "estado": {
                    String idRolStr = request.getParameter("idRol");
                    String estadoStr = request.getParameter("estado");

                    if (idRolStr == null || estadoStr == null || idRolStr.trim().isEmpty() || estadoStr.trim().isEmpty()) {
                        writeJson(response, "{\"status\":\"error\",\"message\":\"Parámetros incompletos.\"}");
                        return;
                    }

                    int idRol = Integer.parseInt(idRolStr);
                    int estado = Integer.parseInt(estadoStr);

                    RolDAO.ResultadoSP res = dao.cambiarEstado(idRol, estado);

                    String json = "{"
                            + "\"status\":\"" + esc(res.getStatus()) + "\","
                            + "\"message\":\"" + esc(res.getMessage()) + "\""
                            + "}";
                    writeJson(response, json);
                    break;
                }

                default:
                    writeJson(response, "{\"status\":\"error\",\"message\":\"Acción no válida.\"}");
            }

        } catch (NumberFormatException e) {
            writeJson(response, "{\"status\":\"error\",\"message\":\"Formato numérico inválido.\"}");
        } catch (SQLException e) {
            writeJson(response, "{\"status\":\"error\",\"message\":\"Error SQL: " + esc(e.getMessage()) + "\"}");
        } catch (Exception e) {
            writeJson(response, "{\"status\":\"error\",\"message\":\"Error: " + esc(e.getMessage()) + "\"}");
        }
    }
}