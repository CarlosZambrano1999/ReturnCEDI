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

/**
 *
 * @author Administrador
 */
@WebServlet(name = "ReporteUnificadoServlet", urlPatterns = {"/reportes/unificado2"})
public class ReporteUnificadoController extends HttpServlet {

    private final ReportesDAO reportesDAO = new ReportesDAO();
    private final FarmaciaDAO farmaciaDAO = new FarmaciaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        cargarPantalla(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        cargarPantalla(request, response);
    }

    private void cargarPantalla(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            Date fechaInicial = parseDate(request.getParameter("fechaInicial"));
            Date fechaFinal = parseDate(request.getParameter("fechaFinal"));

            String farmacias = unirValores(request.getParameterValues("farmacias"));
            String tipoEnvio = unirValores(request.getParameterValues("tipoEnvio"));
            String laboratorios = unirValores(request.getParameterValues("laboratorios"));

            List<Farmacia> listaFarmacias = farmaciaDAO.listarFarmacias();
            List<String> listaLaboratorios = reportesDAO.listarLaboratorios();

            List<String> listaTipoEnvio = Arrays.asList(
                    "PROXIMOS A VENCER",
                    "EXCESOS",
                    "DONACIÓN"
            );

            List<ReporteDevolucionUnificada> listaReporte =
                    reportesDAO.rptDevolucionesUnificadas(
                            fechaInicial,
                            fechaFinal,
                            farmacias,
                            tipoEnvio,
                            laboratorios
                    );

            request.setAttribute("listaFarmacias", listaFarmacias);
            request.setAttribute("listaLaboratorios", listaLaboratorios);
            request.setAttribute("listaTipoEnvio", listaTipoEnvio);
            request.setAttribute("listaReporte", listaReporte);

            request.setAttribute("fechaInicial", request.getParameter("fechaInicial"));
            request.setAttribute("fechaFinal", request.getParameter("fechaFinal"));

            request.setAttribute("farmaciasSeleccionadas", request.getParameterValues("farmacias"));
            request.setAttribute("tipoEnvioSeleccionados", request.getParameterValues("tipoEnvio"));
            request.setAttribute("laboratoriosSeleccionados", request.getParameterValues("laboratorios"));

            request.getRequestDispatcher("/reportes/total/unificado.jsp").forward(request, response);

        } catch (SQLException e) {
            Logger.getLogger(ReporteUnificadoController.class.getName()).log(Level.SEVERE, null, e);

            request.setAttribute("error", "Error al cargar el reporte unificado.");

            try {
                request.setAttribute("listaFarmacias", farmaciaDAO.listarFarmacias());
            } catch (SQLException ex) {
                Logger.getLogger(ReporteUnificadoController.class.getName()).log(Level.SEVERE, null, ex);
                request.setAttribute("listaFarmacias", new ArrayList<Farmacia>());
            }

            request.setAttribute("listaLaboratorios", reportesDAO.listarLaboratorios());

            request.setAttribute("listaTipoEnvio", Arrays.asList(
                    "PROXIMOS A VENCER",
                    "EXCESOS",
                    "DONACIÓN"
            ));

            request.setAttribute("listaReporte", new ArrayList<ReporteDevolucionUnificada>());

            request.setAttribute("fechaInicial", request.getParameter("fechaInicial"));
            request.setAttribute("fechaFinal", request.getParameter("fechaFinal"));
            request.setAttribute("farmaciasSeleccionadas", request.getParameterValues("farmacias"));
            request.setAttribute("tipoEnvioSeleccionados", request.getParameterValues("tipoEnvio"));
            request.setAttribute("laboratoriosSeleccionados", request.getParameterValues("laboratorios"));

            request.getRequestDispatcher("/reportes/total/unificado.jsp").forward(request, response);
        }
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
}