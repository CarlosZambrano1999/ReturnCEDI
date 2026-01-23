/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controladores;

import dao.ModuloDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import modelos.Modulo;

/**
 *
 * @author Administrador
 */
@WebServlet("/ModulosServlet")
public class ModulosController extends HttpServlet {

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

        ModuloDAO dao = new ModuloDAO();

        try {
            switch (action) {
                case "listar": {
                    List<Modulo> modulos = dao.listar();
                    StringBuilder sb = new StringBuilder();
                    sb.append("{\"status\":\"success\",\"data\":[");
                    for (int i = 0; i < modulos.size(); i++) {
                        Modulo m = modulos.get(i);
                        if (i > 0) sb.append(",");
                        sb.append("{")
                          .append("\"idModulo\":").append(m.getIdModulo()).append(",")
                          .append("\"modulo\":\"").append(esc(m.getModulo())).append("\",")
                          .append("\"estado\":").append(m.getEstado())
                          .append("}");
                    }
                    sb.append("]}");
                    writeJson(response, sb.toString());
                    break;
                }

                case "insertar": {
                    String modulo = request.getParameter("modulo");
                    ModuloDAO.ResultadoSP res = dao.insertar(modulo);

                    String json = "{"
                            + "\"status\":\"" + esc(res.getStatus()) + "\","
                            + "\"message\":\"" + esc(res.getMessage()) + "\""
                            + "}";
                    writeJson(response, json);
                    break;
                }

                case "estado": {
                    String idModuloStr = request.getParameter("idModulo");
                    String estadoStr = request.getParameter("estado");

                    if (idModuloStr == null || estadoStr == null || idModuloStr.trim().isEmpty() || estadoStr.trim().isEmpty()) {
                        writeJson(response, "{\"status\":\"error\",\"message\":\"Parámetros incompletos.\"}");
                        return;
                    }

                    int idModulo = Integer.parseInt(idModuloStr);
                    int estado = Integer.parseInt(estadoStr);

                    ModuloDAO.ResultadoSP res = dao.cambiarEstado(idModulo, estado);

                    String json = "{"
                            + "\"status\":\"" + esc(res.getStatus()) + "\","
                            + "\"message\":\"" + esc(res.getMessage()) + "\""
                            + "}";
                    writeJson(response, json);
                    break;
                }

                case "actualizar": {
                    String idModuloStr = request.getParameter("idModulo");
                    String modulo = request.getParameter("modulo");

                    if (idModuloStr == null || idModuloStr.trim().isEmpty()) {
                        writeJson(response, "{\"status\":\"error\",\"message\":\"Falta idModulo.\"}");
                        return;
                    }

                    int idModulo = Integer.parseInt(idModuloStr);

                    ModuloDAO.ResultadoSP res = dao.actualizar(idModulo, modulo);

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
