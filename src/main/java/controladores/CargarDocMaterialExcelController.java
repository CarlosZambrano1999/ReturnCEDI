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
import modelos.ResultadoCargaDocMaterial;
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
        fileSizeThreshold = 1024 * 1024 * 2,   // 2MB
        maxFileSize = 1024 * 1024 * 20,        // 20MB
        maxRequestSize = 1024 * 1024 * 25      // 25MB
)
public class CargarDocMaterialExcelController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Ruta: /guia/cargarDocMaterialExcel.jsp
        request.getRequestDispatcher("/guia/cargarDocMaterialExcel.jsp").forward(request, response);
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");

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

            List<DatosDocMaterial> detalle = new ArrayList<>();
            Long docMaterial = null;

            try (InputStream is = filePart.getInputStream();
                 Workbook workbook = new XSSFWorkbook(is)) {

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
                        "Ce.",
                        "Alm.",
                        "Cl.mov.",
                        "Doc.mat.",
                        "Pos.",
                        "Referencia",
                        "Texto cab.documento",
                        "Hora",
                        "Usuario",
                        "Fecha doc.",
                        "Fe.contab.",
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
                    if (row == null) continue;

                    // Si la fila está vacía, saltar
                    if (isRowEmpty(row)) continue;

                    DatosDocMaterial d = new DatosDocMaterial();

                    d.setCodigoSap(getString(row, col, "Material"));
                    d.setDescripcion(getString(row, col, "Texto breve de material"));
                    d.setCentro(getString(row, col, "Ce."));
                    d.setAlmacen(getString(row, col, "Alm."));

                    Integer clmov = getInteger(row, col, "Cl.mov.");
                    d.setTransito(clmov);

                    // Doc.mat. (lo usamos como docMaterial general)
                    Long docMatFila = getLong(row, col, "Doc.mat.");
                    if (docMatFila != null) {
                        if (docMaterial == null) docMaterial = docMatFila;
                        // si viene diferente en otra fila => error
                        if (!docMatFila.equals(docMaterial)) {
                            response.getWriter().write("{\"status\":\"error\",\"message\":\"El archivo tiene más de un Doc.mat. distinto (fila " + (i + 1) + ").\"}");
                            return;
                        }
                    }

                    d.setDocMaterial(docMatFila);
                    d.setPosicion(getInteger(row, col, "Pos."));
                    d.setReferencia(getString(row, col, "Referencia"));
                    d.setTexto(getString(row, col, "Texto cab.documento"));

                    d.setHora(getTime(row, col, "Hora"));
                    d.setUsuario(getString(row, col, "Usuario"));

                    d.setFechaDocumento(getDate(row, col, "Fecha doc."));
                    d.setFechaContable(getDate(row, col, "Fe.contab."));

                    d.setCantidad(getDecimal(row, col, "Ctd.en UM entrada"));
                    d.setImporte(getDecimal(row, col, "Importe ML"));

                    // Validación mínima por fila
                    if (d.getCodigoSap() == null || d.getCodigoSap().trim().isEmpty()) {
                        response.getWriter().write("{\"status\":\"error\",\"message\":\"Material vacío en fila " + (i + 1) + "\"}");
                        return;
                    }

                    detalle.add(d);
                }
            }

            if (docMaterial == null) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"No se pudo obtener Doc.mat. del archivo.\"}");
                return;
            }

            if (detalle.isEmpty()) {
                response.getWriter().write("{\"status\":\"error\",\"message\":\"El archivo no contiene filas de detalle.\"}");
                return;
            }

            // 3) Guardar en BD vía DAO + SP
            DocMaterialDAO dao = new DocMaterialDAO();
            ResultadoCargaDocMaterial r = dao.cargarDocMaterialExcel(docMaterial, detalle);

            if ("success".equalsIgnoreCase(r.getStatus())) {
                response.getWriter().write(
                        "{"
                                + "\"status\":\"success\","
                                + "\"docMaterial\":" + r.getDocMaterial() + ","
                                + "\"filasInsertadas\":" + r.getFilasInsertadas()
                                + "}"
                );
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
        if (idx == null) return null;
        Cell c = row.getCell(idx, Row.MissingCellPolicy.RETURN_BLANK_AS_NULL);
        if (c == null) return null;

        DataFormatter fmt = new DataFormatter();
        String val = fmt.formatCellValue(c);
        return (val != null && !val.trim().isEmpty()) ? val.trim() : null;
    }

    private Integer getInteger(Row row, Map<String, Integer> col, String headerName) {
        String s = getString(row, col, headerName);
        if (s == null) return null;
        try {
            s = s.replace(",", "").trim();
            if (s.contains(".")) s = s.substring(0, s.indexOf('.'));
            return Integer.parseInt(s);
        } catch (Exception ex) {
            return null;
        }
    }

    private Long getLong(Row row, Map<String, Integer> col, String headerName) {
        String s = getString(row, col, headerName);
        if (s == null) return null;
        try {
            s = s.replace(",", "").trim();
            if (s.contains(".")) s = s.substring(0, s.indexOf('.'));
            return Long.parseLong(s);
        } catch (Exception ex) {
            return null;
        }
    }

    private BigDecimal getDecimal(Row row, Map<String, Integer> col, String headerName) {
        String s = getString(row, col, headerName);
        if (s == null) return null;

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
        if (idx == null) return null;

        Cell c = row.getCell(idx, Row.MissingCellPolicy.RETURN_BLANK_AS_NULL);
        if (c == null) return null;

        try {
            if (c.getCellType() == CellType.NUMERIC && DateUtil.isCellDateFormatted(c)) {
                java.util.Date d = c.getDateCellValue();
                return new Date(d.getTime());
            }

            // Si viene como texto dd/MM/yyyy
            String s = new DataFormatter().formatCellValue(c).trim();
            if (s.isEmpty()) return null;

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
        if (idx == null) return null;

        Cell c = row.getCell(idx, Row.MissingCellPolicy.RETURN_BLANK_AS_NULL);
        if (c == null) return null;

        try {
            if (c.getCellType() == CellType.NUMERIC && DateUtil.isCellDateFormatted(c)) {
                java.util.Date d = c.getDateCellValue();
                return new Time(d.getTime());
            }

            String s = new DataFormatter().formatCellValue(c).trim();
            if (s.isEmpty()) return null;

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
                if (v != null && !v.trim().isEmpty()) return false;
            }
        }
        return true;
    }

    private String normalize(String s) {
        return s == null ? "" : s.trim().toLowerCase(Locale.ROOT);
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", " ");
    }

    private String getFileName(Part part) {
        String cd = part.getHeader("content-disposition");
        if (cd == null) return null;
        for (String token : cd.split(";")) {
            token = token.trim();
            if (token.startsWith("filename")) {
                String fileName = token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                return fileName;
            }
        }
        return null;
    }
}
