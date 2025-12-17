/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controladores;

import dao.DevolucionesDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import modelos.Usuario;

/**
 *
 * @author Administrador
 */
@WebServlet(name = "DevolucionesServlet", urlPatterns = {"/Devoluciones"})
public class DevolucionesController extends HttpServlet {

    private final DevolucionesDAO dao = new DevolucionesDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/guia/devoluciones.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = request.getParameter("accion");

        // Doc actual (puede venir en cargarDocumento / scan / editar)
        long docMaterial = parseLong(request.getParameter("docMaterial"), -1);

        // ID usuario desde sesión (recomendado)
        // 0) Validar sesión
        HttpSession session = request.getSession(false);
        Usuario user = (Usuario) session.getAttribute("usuario");

        try {
            if ("cargarDocumento".equalsIgnoreCase(accion)) {
                if (docMaterial <= 0) {
                    request.setAttribute("msgType", "error");
                    request.setAttribute("msg", "Doc.Material inválido.");
                    forwardVista(request, response, null, null, -1);
                    return;
                }

                var comparativo = dao.obtenerComparativo(docMaterial);
                request.setAttribute("docMaterial", docMaterial);
                request.setAttribute("comparativo", comparativo);
                request.setAttribute("idUsuario", user.getIdUsuario());

                request.setAttribute("msgType", "success");
                request.setAttribute("msg", "Documento cargado. Ya podés escanear.");

                request.getRequestDispatcher("/guia/devoluciones.jsp").forward(request, response);
                return;
            }

            if ("scan".equalsIgnoreCase(accion)) {
                String codigo = request.getParameter("codigo");

                if (docMaterial <= 0) {
                    request.setAttribute("msgType", "error");
                    request.setAttribute("msg", "Doc.Material inválido.");
                    forwardVista(request, response, null, null, -1);
                    return;
                }
                if (codigo == null || codigo.trim().isEmpty()) {
                    request.setAttribute("msgType", "warning");
                    request.setAttribute("msg", "Código vacío.");
                } else {
                    var r = dao.registrarEscaneo(docMaterial, codigo.trim(), user.getIdUsuario(), 1.0);

                    if ("success".equalsIgnoreCase(r.getStatus())) {
                        request.setAttribute("msgType", "success");
                        request.setAttribute("msg", r.getMessage());
                    } else if ("not_found".equalsIgnoreCase(r.getStatus())) {
                        request.setAttribute("msgType", "warning");
                        request.setAttribute("msg", r.getMessage());
                    } else {
                        request.setAttribute("msgType", "error");
                        request.setAttribute("msg", r.getMessage());
                    }
                }

                var comparativo = dao.obtenerComparativo(docMaterial);
                request.setAttribute("docMaterial", docMaterial);
                request.setAttribute("comparativo", comparativo);
                request.setAttribute("idUsuario", user.getIdUsuario());

                request.getRequestDispatcher("/guia/devoluciones.jsp").forward(request, response);
                return;
            }

            if ("editar".equalsIgnoreCase(accion)) {
                long id = parseLong(request.getParameter("id"), -1);
                String cantidad = request.getParameter("cantidad");
                String incidenciaId = request.getParameter("incidenciaId");
                String observacion = request.getParameter("observacion");

                if (id <= 0) {
                    request.setAttribute("msgType", "error");
                    request.setAttribute("msg", "No se pudo editar: ID inválido (escaneá primero).");
                } else {
                    Double cant = parseDouble(cantidad);
                    Integer inc = parseIntOrNull(incidenciaId);

                    var r = dao.editarDevolucion(id, cant == null ? 0 : cant, inc, observacion);

                    request.setAttribute("msgType", "success".equalsIgnoreCase(r.getStatus()) ? "success" : "error");
                    request.setAttribute("msg", r.getMessage());
                }

                var comparativo = dao.obtenerComparativo(docMaterial);
                request.setAttribute("docMaterial", docMaterial);
                request.setAttribute("comparativo", comparativo);
                request.setAttribute("idUsuario", user.getIdUsuario());

                request.getRequestDispatcher("/guia/devoluciones.jsp").forward(request, response);
                return;
            }

            request.setAttribute("msgType", "error");
            request.setAttribute("msg", "Acción no soportada: " + accion);
            request.getRequestDispatcher("/guia/devoluciones.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("msgType", "error");
            request.setAttribute("msg", "Error servidor: " + e.getMessage());
            request.getRequestDispatcher("/guia/devoluciones.jsp").forward(request, response);
        }
    }

    private void forwardVista(HttpServletRequest request, HttpServletResponse response,
                              Object detalle, Object comparativo, long doc) throws ServletException, IOException {
        if (doc > 0) request.setAttribute("docMaterial", doc);
        if (comparativo != null) request.setAttribute("comparativo", comparativo);
        request.getRequestDispatcher("/guia/devoluciones.jsp").forward(request, response);
    }

    private int getIdUsuario(HttpServletRequest request) {
        HttpSession ses = request.getSession(false);
        if (ses != null) {
            Object o = ses.getAttribute("idUsuario");
            if (o instanceof Integer) return (Integer) o;
            if (o instanceof String) {
                try { return Integer.parseInt(((String) o).trim()); } catch (Exception ignored) {}
            }
        }
        // fallback (si querés permitirlo):
        try { return Integer.parseInt(request.getParameter("idUsuario")); } catch (Exception e) { return -1; }
    }

    private long parseLong(String s, long def) {
        try { return Long.parseLong(s.trim().replace(",", "")); } catch (Exception e) { return def; }
    }
    private Double parseDouble(String s) {
        try { return Double.parseDouble(s.trim().replace(",", "")); } catch (Exception e) { return null; }
    }
    private Integer parseIntOrNull(String s) {
        try { if (s == null || s.trim().isEmpty()) return null; return Integer.parseInt(s.trim()); } catch (Exception e) { return null; }
    }
}