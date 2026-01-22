package controladores;

import dao.UsuarioDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

@WebServlet("/importarUsuariosExcel")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024, // 1MB
        maxFileSize = 1024 * 1024 * 15,   // 15MB
        maxRequestSize = 1024 * 1024 * 20 // 20MB
)
public class ImportarUsuariosExcelController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        Part filePart = request.getPart("archivo"); // <input type="file" name="archivo">
        if (filePart == null || filePart.getSize() == 0) {
            response.getWriter().write("{\"status\":\"error\",\"message\":\"No se recibió ningún archivo.\"}");
            return;
        }

        String fileName = filePart.getSubmittedFileName();
        if (fileName == null || !fileName.toLowerCase().endsWith(".xlsx")) {
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Solo se permite archivo .xlsx\"}");
            return;
        }

        UsuarioDAO usuarioDAO = new UsuarioDAO();

        int ok = 0, dup = 0, err = 0;
        List<Map<String, Object>> detalle = new ArrayList<>();

        try (InputStream is = filePart.getInputStream(); Workbook wb = new XSSFWorkbook(is)) {

            Sheet sheet = wb.getNumberOfSheets() > 0 ? wb.getSheetAt(0) : null;
            if (sheet == null) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"El Excel no tiene hojas.\"}");
                return;
            }

            // Encabezados fila 1 (index 0), data desde fila 2 (index 1)
            // Columnas esperadas:
            // A: NOMBRE, B: CODIGO, C: PASSWORD, D: ID_ROL, E: STORE_ID
            DataFormatter fmt = new DataFormatter();

            int lastRow = sheet.getLastRowNum();
            for (int r = 1; r <= lastRow; r++) {
                Row row = sheet.getRow(r);
                if (row == null) continue;

                String nombre   = trimOrNull(fmt.formatCellValue(row.getCell(0)));
                String codigo   = trimOrNull(fmt.formatCellValue(row.getCell(1)));
                String password = fmt.formatCellValue(row.getCell(2)); // no trim a password
                String idRolStr = trimOrNull(fmt.formatCellValue(row.getCell(3)));
                String storeId  = trimOrNull(fmt.formatCellValue(row.getCell(4))); // E

                // Saltar filas totalmente vacías
                if (isRowEmpty(nombre, codigo, password, idRolStr, storeId)) {
                    continue;
                }

                int idRol = parseIntOrDefault(idRolStr, 0);

                UsuarioDAO.ResultadoRegistro res = usuarioDAO.importarUsuarioExcel(
                        nombre, codigo, password, idRol, storeId
                );

                String st = (res.getStatus() != null) ? res.getStatus().toLowerCase() : "error";
                if ("success".equals(st)) ok++;
                else if ("duplicate".equals(st)) dup++;
                else err++;

                Map<String, Object> item = new HashMap<>();
                item.put("fila", r + 1); // humano (1-based)
                item.put("nombre", nombre);
                item.put("codigo", codigo);
                item.put("storeId", storeId);
                item.put("status", res.getStatus());
                item.put("message", res.getMessage());
                detalle.add(item);
            }

            response.getWriter().write(buildJson(ok, dup, err, detalle));

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("{\"status\":\"error\",\"message\":\"Error al procesar Excel: "
                    + escapeJson(e.getMessage()) + "\"}");
        }
    }

    private static boolean isRowEmpty(String nombre, String codigo, String password,
                                      String idRolStr, String storeId) {
        boolean passEmpty = (password == null || password.isEmpty());
        return nombre == null && codigo == null && passEmpty && idRolStr == null && storeId == null;
    }

    private static String trimOrNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    private static int parseIntOrDefault(String s, int def) {
        try {
            if (s == null || s.trim().isEmpty()) return def;
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return def;
        }
    }

    private static String buildJson(int ok, int dup, int err, List<Map<String, Object>> detalle) {
        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append("\"status\":\"success\",");
        sb.append("\"resumen\":{");
        sb.append("\"success\":").append(ok).append(",");
        sb.append("\"duplicate\":").append(dup).append(",");
        sb.append("\"error\":").append(err).append(",");
        sb.append("\"total\":").append(ok + dup + err);
        sb.append("},");
        sb.append("\"detalle\":[");
        for (int i = 0; i < detalle.size(); i++) {
            Map<String, Object> it = detalle.get(i);
            if (i > 0) sb.append(",");

            sb.append("{")
              .append("\"fila\":").append(it.get("fila")).append(",")
              .append("\"nombre\":\"").append(escapeJson(String.valueOf(it.get("nombre")))).append("\",")
              .append("\"codigo\":\"").append(escapeJson(String.valueOf(it.get("codigo")))).append("\",")
              .append("\"storeId\":\"").append(escapeJson(String.valueOf(it.get("storeId")))).append("\",")
              .append("\"status\":\"").append(escapeJson(String.valueOf(it.get("status")))).append("\",")
              .append("\"message\":\"").append(escapeJson(String.valueOf(it.get("message")))).append("\"")
              .append("}");
        }
        sb.append("]");
        sb.append("}");
        return sb.toString();
    }

    private static String escapeJson(String s) {
        if (s == null || "null".equalsIgnoreCase(s)) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
