/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controladores;

import dao.AccesoDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import modelos.ModuloAsignacion;

/**
 *
 * @author Administrador
 */
@WebServlet("/AccesosServlet")
public class AccesosController extends HttpServlet {

    private static String esc(String s) {
        if (s == null) {
            return "";
        }
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
        if (action == null) {
            action = "";
        }

        AccesoDAO dao = new AccesoDAO();

        try {
            switch (action) {

                case "obtener": {
                    String idRolStr = request.getParameter("idRol");
                    if (idRolStr == null || idRolStr.trim().isEmpty()) {
                        writeJson(response, "{\"status\":\"error\",\"message\":\"Falta idRol.\"}");
                        return;
                    }

                    int idRol = Integer.parseInt(idRolStr);

                    List<ModuloAsignacion> lista = dao.obtenerModulosPorRol(idRol);

                    StringBuilder sb = new StringBuilder();
                    sb.append("{\"status\":\"success\",\"data\":[");
                    for (int i = 0; i < lista.size(); i++) {
                        ModuloAsignacion m = lista.get(i);
                        if (i > 0) {
                            sb.append(",");
                        }

                        sb.append("{")
                                .append("\"idModulo\":").append(m.getIdModulo()).append(",")
                                .append("\"modulo\":\"").append(esc(m.getModulo())).append("\",")
                                .append("\"estadoModulo\":").append(m.getEstadoModulo()).append(",")
                                .append("\"titulo\":\"").append(esc(m.getTitulo())).append("\",")
                                .append("\"descripcion\":\"").append(esc(m.getDescripcion())).append("\",")
                                .append("\"icono\":\"").append(esc(m.getIcono())).append("\",")
                                .append("\"categoria\":\"").append(esc(m.getCategoria())).append("\",")
                                .append("\"orden\":").append(m.getOrden() == null ? "null" : m.getOrden()).append(",")
                                .append("\"asignado\":").append(m.getAsignado()).append(",")
                                .append("\"estadoAsignacion\":").append(m.getEstadoAsignacion())
                                .append("}");
                    }
                    sb.append("]}");

                    writeJson(response, sb.toString());
                    break;
                }

                case "guardar": {
                    String idRolStr = request.getParameter("idRol");
                    String modulosCsv = request.getParameter("modulosCsv"); // puede venir "" para quitar todo

                    if (idRolStr == null || idRolStr.trim().isEmpty()) {
                        writeJson(response, "{\"status\":\"error\",\"message\":\"Falta idRol.\"}");
                        return;
                    }

                    int idRol = Integer.parseInt(idRolStr);

                    AccesoDAO.ResultadoSP res = dao.guardarAsignacionCSV(idRol, modulosCsv);

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
            
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.removeAttribute("allowedPaths");
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
