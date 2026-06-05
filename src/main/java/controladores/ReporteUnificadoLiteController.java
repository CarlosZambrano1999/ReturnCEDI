/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controladores;

import dao.FarmaciaDAO;
import dao.ReportesDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import modelos.Farmacia;
import modelos.reportes.ReporteDevolucionUnificada;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;

/**
 *
 * @author Administrador
 */
@WebServlet(name = "ReporteUnificadoLiteController", urlPatterns = {"/reportes/unificado"})
public class ReporteUnificadoLiteController extends HttpServlet {

    private final ReportesDAO reportesDAO = new ReportesDAO();
    private final FarmaciaDAO farmaciaDAO = new FarmaciaDAO();


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            cargarReportePantalla(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");

        if ("excel".equalsIgnoreCase(accion)) {
            exportarExcel(request, response);
            return;
        }

        cargarReportePantalla(request, response);
    }


    private void cargarReportePantalla(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            Date fechaInicial = parseDate(request.getParameter("fechaInicial"));
            Date fechaFinal = parseDate(request.getParameter("fechaFinal"));

            String farmacias = unirValores(request.getParameterValues("farmacias"));
            String tipoEnvio = unirValores(request.getParameterValues("tipoEnvio"));
            String laboratorios = unirValores(request.getParameterValues("laboratorios"));

            cargarCatalogos(request);

            List<ReporteDevolucionUnificada> listaCompleta =
                    reportesDAO.rptDevolucionesUnificadas(
                            fechaInicial,
                            fechaFinal,
                            farmacias,
                            tipoEnvio,
                            laboratorios
                    );

            int totalRegistros = listaCompleta != null ? listaCompleta.size() : 0;

            request.setAttribute("listaReporte", listaCompleta);
            request.setAttribute("consultado", true);
            request.setAttribute("totalRegistros", totalRegistros);
            request.setAttribute("reporteLimitado", false);

            mantenerFiltros(request);

            request.getRequestDispatcher("/reportes/total/unificado2.jsp").forward(request, response);

        } catch (SQLException e) {
            Logger.getLogger(ReporteUnificadoLiteController.class.getName()).log(Level.SEVERE, null, e);

            request.setAttribute("error", "Error al cargar el reporte unificado.");
            request.setAttribute("listaReporte", new ArrayList<ReporteDevolucionUnificada>());
            request.setAttribute("consultado", false);
            request.setAttribute("totalRegistros", 0);
            request.setAttribute("reporteLimitado", false);

            try {
                cargarCatalogos(request);
            } catch (SQLException ex) {
                Logger.getLogger(ReporteUnificadoLiteController.class.getName()).log(Level.SEVERE, null, ex);
            }

            mantenerFiltros(request);

            request.getRequestDispatcher("/reportes/total/unificado2.jsp").forward(request, response);
        }
    }

    private void exportarExcel(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Date fechaInicial = parseDate(request.getParameter("fechaInicial"));
        Date fechaFinal = parseDate(request.getParameter("fechaFinal"));
        String farmacias = unirValores(request.getParameterValues("farmacias"));
        String tipoEnvio = unirValores(request.getParameterValues("tipoEnvio"));
        String laboratorios = unirValores(request.getParameterValues("laboratorios"));
        List<ReporteDevolucionUnificada> listaReporte =
                reportesDAO.rptDevolucionesUnificadas(
                        fechaInicial,
                        fechaFinal,
                        farmacias,
                        tipoEnvio,
                        laboratorios
                );
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        response.setHeader("Content-Disposition", "attachment; filename=\"Reporte_Unificado.xlsx\"");
        try (SXSSFWorkbook workbook = new SXSSFWorkbook(100)) {
            
            Sheet sheet = workbook.createSheet("Reporte Unificado");
            
            int rowNum = 0;
            
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
            
            if (listaReporte != null) {
                for (ReporteDevolucionUnificada r : listaReporte) {
                    Row row = sheet.createRow(rowNum++);
                    
                    row.createCell(0).setCellValue(valor(r.getCodigoSap()));
                    row.createCell(1).setCellValue(valor(r.getCodigo()));
                    row.createCell(2).setCellValue(valor(r.getProducto()));
                    row.createCell(3).setCellValue(valor(r.getEnviado()));
                    row.createCell(4).setCellValue(valor(r.getRecibido()));
                    row.createCell(5).setCellValue(valor(r.getFarmacia()));
                    row.createCell(6).setCellValue(valor(r.getTipoEnvio()));
                    row.createCell(7).setCellValue(valor(r.getDepartamento()));
                    row.createCell(8).setCellValue(valor(r.getLabortaorio()));
                    row.createCell(9).setCellValue(valor(r.getFactor()));
                    row.createCell(10).setCellValue(valor(r.getCategoria()));
                    row.createCell(11).setCellValue(valor(r.getSubcategoria()));
                    row.createCell(12).setCellValue(valor(r.getSegmento()));
                    row.createCell(13).setCellValue(valor(r.getIncidencia()));
                    row.createCell(14).setCellValue(valor(r.getObservacion()));
                    row.createCell(15).setCellValue(valor(r.getFechaScan()));
                }
            }
            
            workbook.write(response.getOutputStream());
            workbook.dispose();
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

    private void mantenerFiltros(HttpServletRequest request) {
        request.setAttribute("fechaInicial", request.getParameter("fechaInicial"));
        request.setAttribute("fechaFinal", request.getParameter("fechaFinal"));
        request.setAttribute("farmaciasSeleccionadas", request.getParameterValues("farmacias"));
        request.setAttribute("tipoEnvioSeleccionados", request.getParameterValues("tipoEnvio"));
        request.setAttribute("laboratoriosSeleccionados", request.getParameterValues("laboratorios"));
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

    private String valor(Object valor) {
        return valor == null ? "" : valor.toString();
    }
}
