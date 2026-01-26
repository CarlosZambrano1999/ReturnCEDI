/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controladores;

import dao.DevolucionesDAO;
import dao.IncidenciaDAO;
import dao.RecepcionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import modelos.InfoDocMaterial;
import modelos.ResultadoOperacion;
import modelos.Usuario;

/**
 *
 * @author Administrador
 */
@WebServlet(name = "RecepcionServlet", urlPatterns = {"/Recepcion"})
public class RecepcionController extends HttpServlet {

    private final DevolucionesDAO dao = new DevolucionesDAO();
    private final RecepcionDAO recepcionDAO = new RecepcionDAO();
    private final IncidenciaDAO incidenciaDAO = new IncidenciaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Carga mínima para vista
        request.setAttribute("incidencias", incidenciaDAO.listarIncidencias());
        request.getRequestDispatcher("/guia/recepcion.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = nvl(request.getParameter("accion"), "");
        long docMaterial = parseLong(request.getParameter("docMaterial"), -1);
        
        Usuario user = (Usuario) request.getAttribute("usuario_auth");
        int idUsuario = user.getIdUsuario();

        try {
            switch (accion.toLowerCase()) {

                case "cargardocumento": {
                    if (docMaterial <= 0) {
                        setMsg(request, "error", "Doc.Material inválido.");
                        render(request, response, -1, idUsuario);
                        return;
                    }
                    InfoDocMaterial info = dao.obtenerInfoDocMaterial(docMaterial);

                    if (info == null) {
                        setMsg(request, "error", "Documento no encontrado o sin datos.");
                        render(request, response, -1, idUsuario);
                        return;
                    }

                    if (info.getEstado() == 2) {
                        // Guía cerrada -> NO traer datos
                        setMsg(request, "warning", "Esta guía ya fue completada y está cerrada.");
                        // Ojo: no mandamos docMaterial, comparativo, infoDoc
                        render(request, response, -1, idUsuario);
                        return;
                    }
                    
                    if (info.getCentro() == null ? user.getCentro() != null : !info.getCentro().equals(user.getCentro())) {
                        setMsg(request, "warning", "Esta guía pertenece a otra farmacia distinta a su centro." + user.getCentro() + " " + info.getCentro());
                        render(request, response, -1, idUsuario);
                        return;
                    }

                    // Si está abierta, sí mandamos todo
                    request.setAttribute("infoDoc", info);

                    setMsg(request, "success", "Documento cargado. Ya podés escanear.");
                    render(request, response, docMaterial, idUsuario);
                    return;
                }

                case "scan": {
                    if (docMaterial <= 0) {
                        setMsg(request, "error", "Doc.Material inválido.");
                        render(request, response, -1, idUsuario);
                        return;
                    }

                    String codigo = request.getParameter("codigo");
                    if (codigo == null || codigo.trim().isEmpty()) {
                        setMsg(request, "warning", "Código vacío.");
                        render(request, response, docMaterial, idUsuario);
                        return;
                    }

                    ResultadoOperacion r = recepcionDAO.registrarEscaneo(docMaterial, codigo.trim(), idUsuario, 1.0);

                    if ("success".equalsIgnoreCase(r.getStatus())) {
                        setMsg(request, "success", r.getMessage());
                    } else if ("not_found".equalsIgnoreCase(r.getStatus())
                            || "not_in_doc".equalsIgnoreCase(r.getStatus())) {
                        setMsg(request, "warning", r.getMessage());
                    } else {
                        setMsg(request, "error", r.getMessage());
                    }


                    render(request, response, docMaterial, idUsuario);
                    return;
                }

                case "editar": {
                    if (docMaterial <= 0) {
                        setMsg(request, "error", "Doc.Material inválido.");
                        render(request, response, -1, idUsuario);
                        return;
                    }

                    long id = parseLong(request.getParameter("id"), -1);
                    if (id <= 0) {
                        setMsg(request, "error", "No se pudo editar: ID inválido (escaneá primero).");
                        render(request, response, docMaterial, idUsuario);
                        return;
                    }

                    
                    Integer cantidadInt = parseIntOrNull(request.getParameter("cantidad"));
                    if (cantidadInt == null || cantidadInt < 0) {
                        setMsg(request, "error", "La cantidad debe ser un número entero válido.");
                        render(request, response, docMaterial, idUsuario);
                        return;
                    }

                    String obs = request.getParameter("observacion");

                    ResultadoOperacion r = recepcionDAO.editarRecepcion(id, obs, cantidadInt);

                    setMsg(request,
                            "success".equalsIgnoreCase(r.getStatus()) ? "success" : "error",
                            r.getMessage());

                    render(request, response, docMaterial, idUsuario);
                    return;
                }

                case "eliminar": {
                    if (docMaterial <= 0) {
                        setMsg(request, "error", "Doc.Material inválido.");
                        render(request, response, -1, idUsuario);
                        return;
                    }

                    long id = parseLong(request.getParameter("id"), -1);
                    if (id <= 0) {
                        setMsg(request, "error", "ID inválido para eliminar.");
                        render(request, response, docMaterial, idUsuario);
                        return;
                    }

                    ResultadoOperacion r = recepcionDAO.eliminarExcesoAdicional(id, docMaterial, idUsuario);

                    setMsg(request,
                            "success".equalsIgnoreCase(r.getStatus()) ? "success" : "error",
                            r.getMessage());

                    render(request, response, docMaterial, idUsuario);
                    return;
                }
                
                case "cerrarguia": {
                    if (docMaterial <= 0) {
                        setMsg(request, "error", "Doc.Material inválido.");
                        render(request, response, -1, idUsuario);
                        return;
                    }

                    ResultadoOperacion r = recepcionDAO.cerrarGuia(docMaterial, idUsuario);

                    setMsg(request,
                            "success".equalsIgnoreCase(r.getStatus()) ? "success" :
                            "warning".equalsIgnoreCase(r.getStatus()) ? "warning" : "error",
                            r.getMessage());

                    // Si cerró, ya no mostramos datos (queda bloqueado)
                    if ("success".equalsIgnoreCase(r.getStatus()) || "warning".equalsIgnoreCase(r.getStatus())) {
                        render(request, response, -1, idUsuario);
                    } else {
                        render(request, response, docMaterial, idUsuario);
                    }
                    return;
                }
                
                case "limpiar": {
                    if (docMaterial <= 0) {
                        setMsg(request, "error", "Doc.Material inválido.");
                        render(request, response, -1, idUsuario);
                        return;
                    }

                    long id = parseLong(request.getParameter("id"), -1);
                    if (id <= 0) {
                        setMsg(request, "error", "ID inválido para limpiar.");
                        render(request, response, docMaterial, idUsuario);
                        return;
                    }

                    ResultadoOperacion r = recepcionDAO.limpiarCantidadEscaneada(id, docMaterial, idUsuario);

                    setMsg(request,
                        "success".equalsIgnoreCase(r.getStatus()) ? "success" : "error",
                        r.getMessage());

                    render(request, response, docMaterial, idUsuario);
                    return;
                }



                default: {
                    setMsg(request, "error", "Acción no soportada: " + accion);
                    render(request, response, docMaterial, idUsuario);
                }
            }

        } catch (Exception e) {
            setMsg(request, "error", "Error servidor: " + e.getMessage());
            render(request, response, docMaterial, idUsuario);
        }
    }


    private void render(HttpServletRequest request, HttpServletResponse response, long docMaterial, Integer idUsuario)
            throws ServletException, IOException {

        // Siempre incidencias
        request.setAttribute("incidencias", incidenciaDAO.listarIncidencias());

        // Si hay doc, cargamos info + comparativo
        if (docMaterial > 0) {
            request.setAttribute("docMaterial", docMaterial);

            // InfoDocMaterial
            InfoDocMaterial info = dao.obtenerInfoDocMaterial(docMaterial);
            request.setAttribute("infoDoc", info);

            if (idUsuario != null) {
                request.setAttribute("idUsuario", idUsuario);
                request.setAttribute("comparativo", recepcionDAO.obtenerComparativoExt(docMaterial, idUsuario));
            }
        }

        request.getRequestDispatcher("/guia/recepcion.jsp").forward(request, response);
    }

    private void setMsg(HttpServletRequest request, String type, String msg) {
        request.setAttribute("msgType", type);
        request.setAttribute("msg", msg);
    }

    private String nvl(String s, String def) {
        return (s == null || s.trim().isEmpty()) ? def : s.trim();
    }

    private long parseLong(String s, long def) {
        try { return Long.parseLong(s.trim().replace(",", "")); } catch (Exception e) { return def; }
    }

    private Integer parseIntOrNull(String s) {
        try {
            if (s == null || s.trim().isEmpty()) return null;
            return Integer.parseInt(s.trim().replace(",", ""));
        } catch (Exception e) {
            return null;
        }
    }
}

