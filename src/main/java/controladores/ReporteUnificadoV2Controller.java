/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controladores;

import modelos.Farmacia;
import dao.FarmaciaDAO;
import dao.ReportesDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import modelos.ResultadoPaginadoDevoluciones;
import modelos.reportes.ReporteDevolucionUnificada;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;

/**
 *
 * @author Administrador
 */
@WebServlet(name = "ReporteUnificadoV2Controller", urlPatterns = {"/reportes/unificadoV2"})
public class ReporteUnificadoV2Controller extends HttpServlet {

    private final ReportesDAO reportesDAO = new ReportesDAO();
    private final FarmaciaDAO farmaciaDAO = new FarmaciaDAO();

    private static final String JSP_REPORTE = "/reportes/total/unificadoV2.jsp";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        cargarReportePantalla(request, response, true);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");

        if ("excel".equalsIgnoreCase(accion)) {
            exportarExcel(request, response);
            return;
        }

        cargarReportePantalla(request, response, false);
    }

    private void cargarReportePantalla(HttpServletRequest request, HttpServletResponse response, boolean cargaInicial)
            throws ServletException, IOException {

        try {
            Date fechaInicial;
            Date fechaFinal;

            if (cargaInicial) {
                LocalDate hoy = LocalDate.now();
                LocalDate inicioMes = hoy.withDayOfMonth(1);

                fechaInicial = Date.valueOf(inicioMes);
                fechaFinal = Date.valueOf(hoy);

                request.setAttribute("fechaInicial", fechaInicial.toString());
                request.setAttribute("fechaFinal", fechaFinal.toString());
            } else {
                fechaInicial = parseDate(request.getParameter("fechaInicial"));
                fechaFinal = parseDate(request.getParameter("fechaFinal"));

                request.setAttribute("fechaInicial", request.getParameter("fechaInicial"));
                request.setAttribute("fechaFinal", request.getParameter("fechaFinal"));
            }

            String farmacias = unirValores(request.getParameterValues("farmacias"));
            String tipoEnvio = unirValores(request.getParameterValues("tipoEnvio"));
            String laboratorios = unirValores(request.getParameterValues("laboratorios"));
            String busqueda = texto(request.getParameter("busqueda"));

            int pagina = parseInt(request.getParameter("pagina"), 1);
            int pageSize = parseInt(request.getParameter("pageSize"), 25);

            if (pagina < 1) {
                pagina = 1;
            }

            if (pageSize < 1) {
                pageSize = 25;
            }

            if (pageSize > 500) {
                pageSize = 500;
            }

            String orderBy = texto(request.getParameter("orderBy"));
            String orderDir = texto(request.getParameter("orderDir"));

            if (orderBy == null || orderBy.isEmpty()) {
                orderBy = "FECHA_SCAN";
            }

            if (orderDir == null || orderDir.isEmpty()) {
                orderDir = "DESC";
            }

            cargarCatalogos(request);

            ResultadoPaginadoDevoluciones resultado
                    = reportesDAO.rptDevolucionesUnificadasPaginado(
                            fechaInicial,
                            fechaFinal,
                            farmacias,
                            tipoEnvio,
                            laboratorios,
                            busqueda,
                            pagina,
                            pageSize,
                            orderBy,
                            orderDir
                    );

            request.setAttribute("resultado", resultado);
            request.setAttribute("listaReporte", resultado.getRegistros());
            request.setAttribute("consultado", true);
            request.setAttribute("totalRegistros", resultado.getTotalRegistros());
            request.setAttribute("totalPaginas", resultado.getTotalPaginas());
            request.setAttribute("paginaActual", resultado.getPaginaActual());
            request.setAttribute("pageSize", resultado.getPageSize());
            request.setAttribute("reporteLimitado", false);

            request.setAttribute("busqueda", busqueda != null ? busqueda : "");
            request.setAttribute("orderBy", orderBy);
            request.setAttribute("orderDir", orderDir);

            mantenerFiltros(request);

            if (cargaInicial) {
                request.setAttribute("farmaciasSeleccionadas", new String[0]);
                request.setAttribute("tipoEnvioSeleccionados", new String[0]);
                request.setAttribute("laboratoriosSeleccionados", new String[0]);
            }

            request.getRequestDispatcher(JSP_REPORTE).forward(request, response);

        } catch (SQLException e) {
            Logger.getLogger(ReporteUnificadoV2Controller.class.getName()).log(Level.SEVERE, null, e);

            request.setAttribute("error", "Error al cargar el reporte unificado.");
            request.setAttribute("listaReporte", new ArrayList<ReporteDevolucionUnificada>());
            request.setAttribute("consultado", false);
            request.setAttribute("totalRegistros", 0);
            request.setAttribute("totalPaginas", 1);
            request.setAttribute("paginaActual", 1);
            request.setAttribute("pageSize", 25);
            request.setAttribute("reporteLimitado", false);
            request.setAttribute("busqueda", texto(request.getParameter("busqueda")));
            request.setAttribute("orderBy", "FECHA_SCAN");
            request.setAttribute("orderDir", "DESC");

            try {
                cargarCatalogos(request);
            } catch (SQLException ex) {
                Logger.getLogger(ReporteUnificadoV2Controller.class.getName()).log(Level.SEVERE, null, ex);
            }

            mantenerFiltros(request);

            request.getRequestDispatcher(JSP_REPORTE).forward(request, response);
        }
    }

    private void exportarExcel(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Date fechaInicial = parseDate(request.getParameter("fechaInicial"));
        Date fechaFinal = parseDate(request.getParameter("fechaFinal"));

        String farmacias = unirValores(request.getParameterValues("farmacias"));
        String tipoEnvio = unirValores(request.getParameterValues("tipoEnvio"));
        String laboratorios = unirValores(request.getParameterValues("laboratorios"));
        String busqueda = texto(request.getParameter("busqueda"));

        final int TAMANO_PAGINA_EXPORTACION = 500;

        response.setContentType(
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        );

        response.setHeader(
                "Content-Disposition",
                "attachment; filename=\"Reporte_Unificado_V2.xlsx\""
        );

        try (SXSSFWorkbook workbook = new SXSSFWorkbook(100)) {

            // Comprime los archivos temporales generados por SXSSFWorkbook.
            workbook.setCompressTempFiles(true);

            Sheet sheet = workbook.createSheet("Reporte Unificado");

            int rowNum = 0;

            /*
         * Encabezados
             */
            Row header = sheet.createRow(rowNum++);

            String[] columnas = {
                "Código SAP",
                "Código",
                "Producto",
                "Enviado",
                "Recibido",
                "Farmacia",
                "Tipo Envío",
                "Departamento",
                "Laboratorio",
                "Factor",
                "Categoría",
                "Subcategoría",
                "Segmento",
                "Incidencia",
                "Observación",
                "Fecha Scan"
            };

            for (int i = 0; i < columnas.length; i++) {
                header.createCell(i).setCellValue(columnas[i]);
            }

            /*
         * Primera consulta:
         * obtiene los primeros 500 registros y el total de páginas.
             */
            ResultadoPaginadoDevoluciones primeraPagina
                    = reportesDAO.rptDevolucionesUnificadasPaginado(
                            fechaInicial,
                            fechaFinal,
                            farmacias,
                            tipoEnvio,
                            laboratorios,
                            busqueda,
                            1,
                            TAMANO_PAGINA_EXPORTACION,
                            "FECHA_SCAN",
                            "DESC"
                    );

            int totalPaginas = primeraPagina.getTotalPaginas();

            /*
         * Escribimos la primera página.
             */
            rowNum = escribirRegistrosExcel(
                    sheet,
                    primeraPagina.getRegistros(),
                    rowNum
            );

            /*
         * Consultamos y escribimos las demás páginas.
             */
            for (int pagina = 2; pagina <= totalPaginas; pagina++) {

                ResultadoPaginadoDevoluciones resultadoPagina
                        = reportesDAO.rptDevolucionesUnificadasPaginado(
                                fechaInicial,
                                fechaFinal,
                                farmacias,
                                tipoEnvio,
                                laboratorios,
                                busqueda,
                                pagina,
                                TAMANO_PAGINA_EXPORTACION,
                                "FECHA_SCAN",
                                "DESC"
                        );

                rowNum = escribirRegistrosExcel(
                        sheet,
                        resultadoPagina.getRegistros(),
                        rowNum
                );
            }

            /*
         * Anchos razonables.
         * No se usa autoSizeColumn porque puede ser costoso con muchos registros.
             */
            sheet.setColumnWidth(0, 16 * 256);
            sheet.setColumnWidth(1, 18 * 256);
            sheet.setColumnWidth(2, 45 * 256);
            sheet.setColumnWidth(3, 12 * 256);
            sheet.setColumnWidth(4, 12 * 256);
            sheet.setColumnWidth(5, 28 * 256);
            sheet.setColumnWidth(6, 24 * 256);
            sheet.setColumnWidth(7, 25 * 256);
            sheet.setColumnWidth(8, 30 * 256);
            sheet.setColumnWidth(9, 12 * 256);
            sheet.setColumnWidth(10, 24 * 256);
            sheet.setColumnWidth(11, 24 * 256);
            sheet.setColumnWidth(12, 24 * 256);
            sheet.setColumnWidth(13, 30 * 256);
            sheet.setColumnWidth(14, 45 * 256);
            sheet.setColumnWidth(15, 22 * 256);

            marcarEstadoDescargaExcel(
                    request,
                    response,
                    "OK"
            );

            workbook.write(response.getOutputStream());
            response.getOutputStream().flush();

        } catch (Exception e) {

            Logger.getLogger(
                    ReporteUnificadoV2Controller.class.getName()
            ).log(
                    Level.SEVERE,
                    "Error al exportar reporte a Excel",
                    e
            );

            if (!response.isCommitted()) {
                response.reset();

                marcarEstadoDescargaExcel(
                        request,
                        response,
                        "ERROR"
                );

                response.sendError(
                        HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                        "No se pudo generar el archivo Excel."
                );
            }
        }
    }

    private int escribirRegistrosExcel(
            Sheet sheet,
            List<ReporteDevolucionUnificada> registros,
            int rowNum) {

        if (registros == null || registros.isEmpty()) {
            return rowNum;
        }

        for (ReporteDevolucionUnificada r : registros) {

            Row row = sheet.createRow(rowNum++);

            row.createCell(0).setCellValue(valor(r.getCodigoSap()));
            row.createCell(1).setCellValue(valor(r.getCodigo()));
            row.createCell(2).setCellValue(valor(r.getProducto()));

            crearCeldaNumerica(row, 3, r.getEnviado());
            crearCeldaNumerica(row, 4, r.getRecibido());

            row.createCell(5).setCellValue(valor(r.getFarmacia()));
            row.createCell(6).setCellValue(valor(r.getTipoEnvio()));
            row.createCell(7).setCellValue(valor(r.getDepartamento()));
            row.createCell(8).setCellValue(valor(r.getLabortaorio()));

            crearCeldaNumerica(row, 9, r.getFactor());

            row.createCell(10).setCellValue(valor(r.getCategoria()));
            row.createCell(11).setCellValue(valor(r.getSubcategoria()));
            row.createCell(12).setCellValue(valor(r.getSegmento()));
            row.createCell(13).setCellValue(valor(r.getIncidencia()));
            row.createCell(14).setCellValue(valor(r.getObservacion()));
            row.createCell(15).setCellValue(valor(r.getFechaScan()));
        }

        return rowNum;
    }

    private void crearCeldaNumerica(Row row, int columna, Object valor) {

        if (valor == null) {
            row.createCell(columna).setCellValue(0);
            return;
        }

        if (valor instanceof Number) {
            Number numero = (Number) valor;
            row.createCell(columna).setCellValue(numero.doubleValue());
            return;
        }

        try {
            double numero = Double.parseDouble(valor.toString());
            row.createCell(columna).setCellValue(numero);
        } catch (NumberFormatException e) {
            row.createCell(columna).setCellValue(valor.toString());
        }
    }

    private void cargarCatalogos(HttpServletRequest request) throws SQLException {
        List<Farmacia> listaFarmacias = farmaciaDAO.listarFarmacias();
        List<String> listaLaboratorios = reportesDAO.listarLaboratorios();

        List<String> listaTipoEnvio = Arrays.asList(
                "PROXIMOS A VENCER",
                "EXCESOS",
                "DONACIÓN"
        );

        request.setAttribute("listaFarmacias", listaFarmacias);
        request.setAttribute("listaLaboratorios", listaLaboratorios);
        request.setAttribute("listaTipoEnvio", listaTipoEnvio);
    }

    private void marcarEstadoDescargaExcel(
            HttpServletRequest request,
            HttpServletResponse response,
            String estado) {

        String token = texto(
                request.getParameter("tokenDescargaExcel")
        );

        if (token == null || token.isEmpty()) {
            return;
        }

        /*
     * Seguridad básica porque el token proviene del request.
         */
        if (!token.matches("[a-zA-Z0-9_-]{5,100}")) {
            return;
        }

        String valorCookie = token + "_" + estado;

        Cookie cookie = new Cookie(
                "estadoDescargaExcel",
                valorCookie
        );

        String contextPath = request.getContextPath();

        cookie.setPath(
                contextPath == null || contextPath.isEmpty()
                ? "/"
                : contextPath
        );

        cookie.setMaxAge(30 * 60);
        cookie.setHttpOnly(false);
        cookie.setSecure(request.isSecure());

        response.addCookie(cookie);
    }

    private void mantenerFiltros(HttpServletRequest request) {
        if (request.getAttribute("fechaInicial") == null) {
            request.setAttribute("fechaInicial", request.getParameter("fechaInicial"));
        }

        if (request.getAttribute("fechaFinal") == null) {
            request.setAttribute("fechaFinal", request.getParameter("fechaFinal"));
        }

        request.setAttribute("farmaciasSeleccionadas",
                request.getParameterValues("farmacias") != null ? request.getParameterValues("farmacias") : new String[0]);

        request.setAttribute("tipoEnvioSeleccionados",
                request.getParameterValues("tipoEnvio") != null ? request.getParameterValues("tipoEnvio") : new String[0]);

        request.setAttribute("laboratoriosSeleccionados",
                request.getParameterValues("laboratorios") != null ? request.getParameterValues("laboratorios") : new String[0]);
    }

    private Date parseDate(String fecha) {
        if (fecha == null || fecha.trim().isEmpty()) {
            return null;
        }

        return Date.valueOf(fecha);
    }

    private String unirValores(String[] valores) {
        if (valores == null || valores.length == 0) {
            return null;
        }

        String resultado = Arrays.stream(valores)
                .filter(v -> v != null && !v.trim().isEmpty())
                .map(String::trim)
                .collect(Collectors.joining(","));

        return resultado.isEmpty() ? null : resultado;
    }

    private int parseInt(String valor, int defecto) {
        if (valor == null || valor.trim().isEmpty()) {
            return defecto;
        }

        try {
            return Integer.parseInt(valor.trim());
        } catch (NumberFormatException e) {
            return defecto;
        }
    }

    private String texto(String valor) {
        if (valor == null) {
            return "";
        }

        return valor.trim();
    }

    private String valor(Object valor) {
        return valor == null ? "" : valor.toString();
    }
}
