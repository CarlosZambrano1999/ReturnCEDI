/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controladores;

import dao.ReportesDAO;
import dao.UsuarioDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import modelos.Usuario;
import modelos.reportes.RptFarmaciasMayorIncidencia;
import modelos.reportes.RptGuiasMayorIncidencia;
import modelos.reportes.RptIncidenciasMasFrecuentes;
import modelos.reportes.RptProductividadDiaHoraUsuario;

/**
 *
 * @author Administrador
 */
@WebServlet(name = "ReportesServlet", urlPatterns = {"/Reportes/Devoluciones"})
public class ReportDevolucionesController extends HttpServlet {

    private final ReportesDAO dao = new ReportesDAO();
    private final UsuarioDAO usuarioDAO = new UsuarioDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        Usuario usuario = (session != null) ? (Usuario) session.getAttribute("usuario") : null;
        if (usuario == null || usuario.getIdRol() < 2) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            request.setAttribute("usuarios", usuarioDAO.listarUsuarios());
            request.setAttribute("tab", "rpt1");
            
            setViewMeta(request);
            request.getRequestDispatcher("/reportes/generales.jsp").forward(request, response);

        } catch (SQLException ex) {
            Logger.getLogger(ReportDevolucionesController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            
            String accion = nvl(request.getParameter("accion"), "").toLowerCase();
            
            // 0) Validar sesión
            HttpSession session = request.getSession(false);
            Usuario user = (session == null) ? null : (Usuario) session.getAttribute("usuario");
            if (user == null) {
                setMsg(request, "error", "Sesión expirada. Volvé a iniciar sesión.");
                forward(request, response);
                return;
            }
            
            // 1) Filtros comunes
            Date desde = parseSqlDate(request.getParameter("desde"));
            Date hasta = parseSqlDate(request.getParameter("hasta"));
            Integer idUsuarioFiltro = parseIntOrNull(request.getParameter("idUsuario"));
            Integer horaMin = parseIntOrNull(request.getParameter("horaMin"));
            Integer horaMax = parseIntOrNull(request.getParameter("horaMax"));
            
            if (horaMin == null) horaMin = 0;
            if (horaMax == null) horaMax = 23;
            
            
            int top = parseIntOrDefault(request.getParameter("top"), 20);
            if (top <= 0) top = 20;
            
            // defaults si vienen vacíos
            if (desde == null) desde = Date.valueOf(LocalDate.now());
            if (hasta == null) hasta = Date.valueOf(LocalDate.now());
            
            // Guardar filtros para re-render en JSP
            request.setAttribute("desde", desde.toString());
            request.setAttribute("hasta", hasta.toString());
            request.setAttribute("top", top);
            request.setAttribute("idUsuario", idUsuarioFiltro);
            request.setAttribute("horaMin", horaMin);
            request.setAttribute("horaMax", horaMax);
            
// Y siempre cargar usuarios para el select
request.setAttribute("usuarios", usuarioDAO.listarUsuarios());

try {
    
    switch (accion) {
        case "rpt1": { // Productividad por día/hora/usuario
            List<RptProductividadDiaHoraUsuario> data =
                    dao.rptProductividadDiaHora(desde, hasta, horaMin, horaMax, idUsuarioFiltro);
            
            request.setAttribute("tab", "rpt1");
            request.setAttribute("data1", data);
            
            setMsg(request, "success", "Reporte 1 generado.");
            forward(request, response);
            return;
        }
        
        case "rpt2": { // Guías con mayor incidencia
            List<RptGuiasMayorIncidencia> data =
                    (List<RptGuiasMayorIncidencia>) safeList(dao.rptGuiasMayorIncidencia(desde, hasta, top));
            
            request.setAttribute("tab", "rpt2");
            request.setAttribute("data2", data);
            
            setMsg(request, "success", "Reporte 2 generado.");
            forward(request, response);
            return;
        }
        
        case "rpt3": { // Farmacias con mayor incidencia
            List<RptFarmaciasMayorIncidencia> data =
                    (List<RptFarmaciasMayorIncidencia>) safeList(dao.rptFarmaciasMayorIncidencia(desde, hasta, top));
            
            request.setAttribute("tab", "rpt3");
            request.setAttribute("data3", data);
            
            setMsg(request, "success", "Reporte 3 generado.");
            forward(request, response);
            return;
        }
        
        case "rpt4": { // Incidencias más frecuentes
            List<RptIncidenciasMasFrecuentes> data =
                    (List<RptIncidenciasMasFrecuentes>) safeList(dao.rptIncidenciasMasFrecuentes(desde, hasta, top));
            
            request.setAttribute("tab", "rpt4");
            request.setAttribute("data4", data);
            
            setMsg(request, "success", "Reporte 4 generado.");
            forward(request, response);
            return;
        }
        
        default:
            request.setAttribute("tab", "rpt1");
            setMsg(request, "error", "Acción no soportada: " + accion);
            forward(request, response);
    }
    
} catch (Exception e) {
    request.setAttribute("tab", "rpt1");
    setMsg(request, "error", "Error servidor: " + e.getMessage());
    forward(request, response);
}
        } catch (SQLException ex) {
            Logger.getLogger(ReportDevolucionesController.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    // ----------------- Helpers -----------------

    private void forward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        setViewMeta(request);
        request.getRequestDispatcher("/reportes/generales.jsp").forward(request, response);
    }

    private void setMsg(HttpServletRequest request, String type, String msg) {
        request.setAttribute("msgType", type);
        request.setAttribute("msg", msg);
    }

    private String nvl(String s, String def) {
        return (s == null || s.trim().isEmpty()) ? def : s.trim();
    }

    private List<?> safeList(List<?> list) {
        return (list == null) ? Collections.emptyList() : list;
    }

    private Integer parseIntOrNull(String s) {
        try {
            if (s == null || s.trim().isEmpty()) return null;
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return null;
        }
    }

    private int parseIntOrDefault(String s, int def) {
        try {
            if (s == null || s.trim().isEmpty()) return def;
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return def;
        }
    }

    /**
     * Espera input type="date" => yyyy-MM-dd
     */
    private Date parseSqlDate(String yyyyMMdd) {
        try {
            if (yyyyMMdd == null || yyyyMMdd.trim().isEmpty()) return null;
            LocalDate d = LocalDate.parse(yyyyMMdd.trim(), DateTimeFormatter.ISO_LOCAL_DATE);
            return Date.valueOf(d);
        } catch (Exception e) {
            return null;
        }
    }
    
    private void setViewMeta(HttpServletRequest request) {
        request.setAttribute("pageTitle", "Dashboard Reportes - Devoluciones");
        request.setAttribute("pageSubtitle", "Devoluciones · Productividad e incidencias");
        request.setAttribute("baseUrl", request.getContextPath() + "/Reportes/Devoluciones");
        request.setAttribute("moduloNombre", "Devoluciones");
    }

}