/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controladores;

import dao.DocMaterialDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import modelos.DatosDocMaterial;
import modelos.InfoDocMaterial;
import modelos.ResultadoCargaDocMaterial;
import modelos.Usuario;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.DateUtil;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

/**
 *
 * @author Administrador
 */
@WebServlet(name = "CargarDocMaterialExcelServlet", urlPatterns = {"/CargarDocMaterialExcel"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 20, // 20MB
        maxRequestSize = 1024 * 1024 * 25 // 25MB
)
public class CargarDocMaterialExcelController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Usuario usuario = (session != null) ? (Usuario) session.getAttribute("usuario") : null;
        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Ruta: /guia/cargarDocMaterialExcel.jsp
        request.getRequestDispatcher("/guia/cargarDocMaterialExcel.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        
        HttpSession session = request.getSession(false);
        Usuario usuario = (session != null) ? (Usuario) session.getAttribute("usuario") : null;
        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            Part filePart = request.getPart("archivoExcel");
            if (filePart == null || filePart.getSize() == 0) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"No se recibió el archivo Excel.\"}");
                return;
            }

            String fileName = getFileName(filePart);
            if (fileName == null || (!fileName.toLowerCase().endsWith(".xlsx"))) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"Formato inválido. Solo se permite .xlsx\"}");
                return;
            }

            List<DatosDocMaterial> validas = new ArrayList<>();
            List<FilaError> invalidas = new ArrayList<>();
            Long docMaterial = null;

            try (InputStream is = filePart.getInputStream(); Workbook workbook = new XSSFWorkbook(is)) {

                Sheet sheet = workbook.getSheetAt(0);
                if (sheet == null) {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"El Excel no tiene hojas.\"}");
                    return;
                }

                // 1) Detectar encabezados y mapear índices de columnas por nombre
                Row header = sheet.getRow(sheet.getFirstRowNum());
                if (header == null) {
                    response.getWriter().write("{\"status\":\"error\",\"message\":\"No se encontró la fila de encabezados.\"}");
                    return;
                }

                Map<String, Integer> col = buildHeaderIndex(header);

                // Validar columnas mínimas necesarias (según tu mapeo)
                String[] requeridas = new String[]{
                    "Material",
                    "Texto breve de material",
                    "Centro",
                    "Almacén",
                    "Clase de movimiento",
                    "Documento material",
                    "Posición",
                    "Referencia",
                    "Texto cab.documento",
                    "Hora de entrada",
                    "Nombre del usuario",
                    "Fe.contabilización",
                    "Fe.contabilización",
                    "Ctd.en UM entrada",
                    "Importe ML"
                };

                for (String r : requeridas) {
                    if (!col.containsKey(normalize(r))) {
                        response.getWriter().write("{\"status\":\"error\",\"message\":\"Falta la columna requerida: " + escape(r) + "\"}");
                        return;
                    }
                }

                // 2) Leer filas desde la siguiente a encabezados
                int firstDataRow = header.getRowNum() + 1;
                int lastRow = sheet.getLastRowNum();

                for (int i = firstDataRow; i <= lastRow; i++) {
                    Row row = sheet.getRow(i);
                    if (row == null || isRowEmpty(row)) {
                        continue;
                    }

                    try {
                        DatosDocMaterial d = new DatosDocMaterial();

                        d.setCodigoSap(getString(row, col, "Material"));
                        d.setDescripcion(getString(row, col, "Texto breve de material"));
                        d.setCentro(getString(row, col, "Centro"));
                        d.setAlmacen(getString(row, col, "Almacén"));
                        d.setTransito(getInteger(row, col, "Clase de movimiento"));

                        Long docMatFila = getLong(row, col, "Documento material");
                        if (docMatFila != null) {
                            if (docMaterial == null) {
                                docMaterial = docMatFila;
                            }
                            if (!docMatFila.equals(docMaterial)) {
                                invalidas.add(new FilaError(i + 1, "Documento material distinto al detectado"));
                                continue; // 👈 solo marca error y sigue
                            }
                        }
                        d.setDocMaterial(docMatFila);

                        d.setPosicion(getInteger(row, col, "Posición"));
                        d.setReferencia(getString(row, col, "Referencia"));
                        d.setTexto(getString(row, col, "Texto cab.documento"));
                        d.setHora(getTime(row, col, "Hora de entrada"));
                        d.setUsuario(getString(row, col, "Nombre del usuario"));
                        d.setFechaDocumento(getDate(row, col, "Fe.contabilización"));      // ajustá si tu columna es otra
                        d.setFechaContable(getDate(row, col, "Fe.contabilización"));

                        d.setCantidad(getDecimal(row, col, "Ctd.en UM entrada"));
                        d.setImporte(getDecimal(row, col, "Importe ML"));

                        // ✅ validaciones mínimas
                        if (d.getCodigoSap() == null || d.getCodigoSap().trim().isEmpty()) {
                            invalidas.add(new FilaError(i + 1, "Material vacío"));
                            continue;
                        }
                        if (d.getTransito() == null) {
                            invalidas.add(new FilaError(i + 1, "Clase de movimiento vacía"));
                            continue;
                        }
                        if (d.getCantidad() == null) {
                            invalidas.add(new FilaError(i + 1, "Cantidad inválida"));
                            continue;
                        }

                        validas.add(d);

                    } catch (Exception ex) {
                        invalidas.add(new FilaError(i + 1, "Error leyendo fila: " + ex.getMessage()));
                    }
                }

            }

            if (docMaterial == null) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"No se pudo detectar Doc. Material\"}");
                return;
            }

            if (validas.isEmpty()) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"No hay filas válidas para cargar.\"}");
                return;
            }


            DocMaterialDAO dao = new DocMaterialDAO();
            InfoDocMaterial info = dao.obtenerInfoDocMaterial(docMaterial);

            if (info != null) {
                int estado = info.getEstado();

                if (estado == 1) {
                    response.getWriter().write(
                            "{"
                            + "\"status\":\"error\","
                            + "\"code\":\"YA_CARGADA\","
                            + "\"message\":\"La guía ya ha sido cargada.\","
                            + "\"docMaterial\":" + docMaterial + ","
                            + "\"estado\":" + estado + ","
                            + "\"info\":{"
                            + "\"almacen\":\"" + escape(info.getAlmacen()) + "\","
                            + "\"departamento\":\"" + escape(info.getDepartamento()) + "\","
                            + "\"farmacia\":\"" + escape(info.getFarmacia()) + "\""
                            + "}"
                            + "}"
                    );
                    return;
                }

                if (estado == 2) {
                    response.getWriter().write(
                            "{"
                            + "\"status\":\"error\","
                            + "\"code\":\"YA_COMPLETADA\","
                            + "\"message\":\"La guía ya fue completada.\","
                            + "\"docMaterial\":" + docMaterial + ","
                            + "\"estado\":" + estado + ","
                            + "\"info\":{"
                            + "\"almacen\":\"" + escape(info.getAlmacen()) + "\","
                            + "\"departamento\":\"" + escape(info.getDepartamento()) + "\","
                            + "\"farmacia\":\"" + escape(info.getFarmacia()) + "\""
                            + "}"
                            + "}"
                    );
                    return;
                }
            }

            // 3) Guardar en BD vía DAO + SP
            ResultadoCargaDocMaterial r = dao.cargarDocMaterialExcel(docMaterial, validas);

            if ("success".equalsIgnoreCase(r.getStatus())) {
                StringBuilder sb = new StringBuilder();
sb.append("{");
sb.append("\"status\":\"success\",");
sb.append("\"docMaterial\":").append(docMaterial).append(",");
sb.append("\"filasValidas\":").append(validas.size()).append(",");
sb.append("\"filasInvalidas\":").append(invalidas.size()).append(",");
sb.append("\"filasInsertadas\":").append(r.getFilasInsertadas()).append(",");

sb.append("\"invalidas\":[");
for (int k = 0; k < invalidas.size(); k++) {
    FilaError fe = invalidas.get(k);
    sb.append("{\"fila\":").append(fe.getFilaExcel())
      .append(",\"motivo\":\"").append(escape(fe.getMotivo())).append("\"}");
    if (k < invalidas.size() - 1) sb.append(",");
}
sb.append("]");

sb.append("}");
response.getWriter().write(sb.toString());
            } else {
                String msg = (r.getErrorMessage() != null) ? escape(r.getErrorMessage()) : "Error desconocido";
                response.getWriter().write(
                        "{"
                        + "\"status\":\"error\","
                        + "\"message\":\"" + msg + "\""
                        + "}"
                );
            }

        } catch (Exception e) {
            String msg = escape(e.getMessage());
            response.getWriter().write("{\"status\":\"error\",\"message\":\"" + msg + "\"}");
        }
    }

    // ------------------------
    // Utilidades de Excel
    // ------------------------
    private Map<String, Integer> buildHeaderIndex(Row header) {
        Map<String, Integer> map = new HashMap<>();
        DataFormatter formatter = new DataFormatter();

        for (Cell cell : header) {
            String name = formatter.formatCellValue(cell);
            if (name != null && !name.trim().isEmpty()) {
                map.put(normalize(name), cell.getColumnIndex());
            }
        }
        return map;
    }

    private String getString(Row row, Map<String, Integer> col, String headerName) {
        Integer idx = col.get(normalize(headerName));
        if (idx == null) {
            return null;
        }
        Cell c = row.getCell(idx, Row.MissingCellPolicy.RETURN_BLANK_AS_NULL);
        if (c == null) {
            return null;
        }

        DataFormatter fmt = new DataFormatter();
        String val = fmt.formatCellValue(c);
        return (val != null && !val.trim().isEmpty()) ? val.trim() : null;
    }

    private Integer getInteger(Row row, Map<String, Integer> col, String headerName) {
        String s = getString(row, col, headerName);
        if (s == null) {
            return null;
        }
        try {
            s = s.replace(",", "").trim();
            if (s.contains(".")) {
                s = s.substring(0, s.indexOf('.'));
            }
            return Integer.parseInt(s);
        } catch (Exception ex) {
            return null;
        }
    }

    private Long getLong(Row row, Map<String, Integer> col, String headerName) {
        String s = getString(row, col, headerName);
        if (s == null) {
            return null;
        }
        try {
            s = s.replace(",", "").trim();
            if (s.contains(".")) {
                s = s.substring(0, s.indexOf('.'));
            }
            return Long.parseLong(s);
        } catch (Exception ex) {
            return null;
        }
    }

    private BigDecimal getDecimal(Row row, Map<String, Integer> col, String headerName) {
        String s = getString(row, col, headerName);
        if (s == null) {
            return null;
        }

        // Limpia miles y maneja 1,123.65
        s = s.replace(",", "").trim();

        try {
            return new BigDecimal(s);
        } catch (Exception ex) {
            return null;
        }
    }

    private Date getDate(Row row, Map<String, Integer> col, String headerName) {
        Integer idx = col.get(normalize(headerName));
        if (idx == null) {
            return null;
        }

        Cell c = row.getCell(idx, Row.MissingCellPolicy.RETURN_BLANK_AS_NULL);
        if (c == null) {
            return null;
        }

        try {
            if (c.getCellType() == CellType.NUMERIC && DateUtil.isCellDateFormatted(c)) {
                java.util.Date d = c.getDateCellValue();
                return new Date(d.getTime());
            }

            // Si viene como texto dd/MM/yyyy
            String s = new DataFormatter().formatCellValue(c).trim();
            if (s.isEmpty()) {
                return null;
            }

            // dd/MM/yyyy
            String[] p = s.split("/");
            if (p.length == 3) {
                int dd = Integer.parseInt(p[0]);
                int mm = Integer.parseInt(p[1]);
                int yy = Integer.parseInt(p[2]);
                LocalDate ld = LocalDate.of(yy, mm, dd);
                return Date.valueOf(ld);
            }

        } catch (Exception ex) {
            // ignorar y retornar null
        }
        return null;
    }

    private Time getTime(Row row, Map<String, Integer> col, String headerName) {
        Integer idx = col.get(normalize(headerName));
        if (idx == null) {
            return null;
        }

        Cell c = row.getCell(idx, Row.MissingCellPolicy.RETURN_BLANK_AS_NULL);
        if (c == null) {
            return null;
        }

        try {
            if (c.getCellType() == CellType.NUMERIC && DateUtil.isCellDateFormatted(c)) {
                java.util.Date d = c.getDateCellValue();
                return new Time(d.getTime());
            }

            String s = new DataFormatter().formatCellValue(c).trim();
            if (s.isEmpty()) {
                return null;
            }

            // HH:mm:ss
            LocalTime lt = LocalTime.parse(s);
            return Time.valueOf(lt);

        } catch (Exception ex) {
            return null;
        }
    }

    private boolean isRowEmpty(Row row) {
        for (int c = row.getFirstCellNum(); c < row.getLastCellNum(); c++) {
            Cell cell = row.getCell(c, Row.MissingCellPolicy.RETURN_BLANK_AS_NULL);
            if (cell != null && cell.getCellType() != CellType.BLANK) {
                String v = new DataFormatter().formatCellValue(cell);
                if (v != null && !v.trim().isEmpty()) {
                    return false;
                }
            }
        }
        return true;
    }

    private String normalize(String s) {
        return s == null ? "" : s.trim().toLowerCase(Locale.ROOT);
    }

    private String escape(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
    }

    private String getFileName(Part part) {
        String cd = part.getHeader("content-disposition");
        if (cd == null) {
            return null;
        }
        for (String token : cd.split(";")) {
            token = token.trim();
            if (token.startsWith("filename")) {
                String fileName = token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                return fileName;
            }
        }
        return null;
    }

    public static class FilaError {

        private final int filaExcel;
        private final String motivo;

        public FilaError(int filaExcel, String motivo) {
            this.filaExcel = filaExcel;
            this.motivo = motivo;
        }

        public int getFilaExcel() {
            return filaExcel;
        }

        public String getMotivo() {
            return motivo;
        }
    }

}
