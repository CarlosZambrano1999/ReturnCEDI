/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controladores;

import dao.ConsultarPoliticaDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.Collections;
import java.util.List;
import modelos.ColorPolitica;
import modelos.EvaluacionPolitica;
import modelos.PoliticaDevolucion;
import modelos.Producto;
import modelos.ProveedorPolitica;
import modelos.Usuario;

/**
 *
 * @author Administrador
 */
@WebServlet(name = "ConsultarPoliticaServlet", urlPatterns = {"/ConsultarPolitica"})
public class ConsultarPoliticaController extends HttpServlet {

    private final ConsultarPoliticaDAO dao = new ConsultarPoliticaDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/politica/consultarPolitica.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String accion = nvl(request.getParameter("accion"), "").toLowerCase();

        // Mantener valores seleccionados
        String codigo = nvl(request.getParameter("codigo"), "");
        String idProveedor = nvl(request.getParameter("idProveedor"), "");
        String idColorStr = nvl(request.getParameter("idColor"), "");
        String fechaVencStr = nvl(request.getParameter("fechaVencimiento"), "");

        // 0) Validar sesión (igual que tu patrón)
        HttpSession session = request.getSession(false);
        Usuario user = (session == null) ? null : (Usuario) session.getAttribute("usuario");
        if (user == null) {
            setMsg(request, "error", "Sesión expirada. Volvé a iniciar sesión.");
            forward(request, response);
            return;
        }

        try {
            switch (accion) {

                case "buscarproducto": {
                    if (codigo.isEmpty()) {
                        setMsg(request, "warning", "Escaneá o ingresá un código.");
                        forward(request, response);
                        return;
                    }

                    Producto producto = dao.buscarProducto(codigo);
                    if (producto == null) {
                        setMsg(request, "warning", "Producto no encontrado.");
                        forward(request, response);
                        return;
                    }

                    request.setAttribute("producto", producto);
                    request.setAttribute("codigo", codigo);

                    // Proveedores por laboratorio
                    List<ProveedorPolitica> proveedores =
                            safeList(dao.listarProveedoresPorLaboratorio(producto.getIdLaboratorio()));
                    request.setAttribute("proveedores", proveedores);

                    // Limpia colores/política/evaluación
                    request.setAttribute("colores", Collections.emptyList());
                    request.setAttribute("politica", null);
                    request.setAttribute("evaluacion", null);

                    setMsg(request, "success", "Producto cargado. Seleccioná proveedor y color.");
                    forward(request, response);
                    return;
                }

                case "cargarcolores": {
                    // Re-consultar producto para no depender de hidden (más seguro)
                    if (codigo.isEmpty()) {
                        setMsg(request, "warning", "Primero buscá el producto.");
                        forward(request, response);
                        return;
                    }

                    Producto producto = dao.buscarProducto(codigo);
                    if (producto == null) {
                        setMsg(request, "warning", "Producto no encontrado. Volvé a escanear.");
                        forward(request, response);
                        return;
                    }

                    request.setAttribute("producto", producto);
                    request.setAttribute("codigo", codigo);

                    List<ProveedorPolitica> proveedores =
                            safeList(dao.listarProveedoresPorLaboratorio(producto.getIdLaboratorio()));
                    request.setAttribute("proveedores", proveedores);

                    if (idProveedor.isEmpty()) {
                        setMsg(request, "warning", "Seleccioná un proveedor.");
                        request.setAttribute("colores", Collections.emptyList());
                        forward(request, response);
                        return;
                    }

                    request.setAttribute("idProveedor", idProveedor);

                    List<ColorPolitica> colores =
                            safeList(dao.listarColoresPorLabProveedor(producto.getIdLaboratorio(), idProveedor));
                    request.setAttribute("colores", colores);

                    setMsg(request, "success", "Ahora seleccioná un color y la fecha de vencimiento.");
                    forward(request, response);
                    return;
                }

                case "consultarpolitica": {
                    if (codigo.isEmpty()) {
                        setMsg(request, "warning", "Primero buscá el producto.");
                        forward(request, response);
                        return;
                    }
                    if (idProveedor.isEmpty()) {
                        setMsg(request, "warning", "Seleccioná un proveedor.");
                        forward(request, response);
                        return;
                    }
                    Integer idColor = parseIntOrNull(idColorStr);
                    if (idColor == null) {
                        setMsg(request, "warning", "Seleccioná un color.");
                        forward(request, response);
                        return;
                    }
                    LocalDate fechaVenc = parseFecha(fechaVencStr);
                    if (fechaVenc == null) {
                        setMsg(request, "warning", "Ingresá una fecha de vencimiento válida (yyyy-MM-dd).");
                        forward(request, response);
                        return;
                    }

                    // Re-consultar producto
                    Producto producto = dao.buscarProducto(codigo);
                    if (producto == null) {
                        setMsg(request, "warning", "Producto no encontrado. Volvé a escanear.");
                        forward(request, response);
                        return;
                    }
                    request.setAttribute("producto", producto);
                    request.setAttribute("codigo", codigo);

                    // combos para mantener estado en pantalla
                    List<ProveedorPolitica> proveedores =
                            safeList(dao.listarProveedoresPorLaboratorio(producto.getIdLaboratorio()));
                    request.setAttribute("proveedores", proveedores);
                    request.setAttribute("idProveedor", idProveedor);

                    List<ColorPolitica> colores =
                            safeList(dao.listarColoresPorLabProveedor(producto.getIdLaboratorio(), idProveedor));
                    request.setAttribute("colores", colores);
                    request.setAttribute("idColor", idColor);
                    request.setAttribute("fechaVencimiento", fechaVencStr);

                    // consultar política
                    PoliticaDevolucion pol = dao.consultarPolitica(producto.getIdLaboratorio(), idProveedor, idColor);
                    request.setAttribute("politica", pol);

                    // evaluar
                    EvaluacionPolitica eval = evaluarPolitica(pol, fechaVenc);
                    request.setAttribute("evaluacion", eval);

                    if (pol == null) {
                        setMsg(request, "warning", "No existe una política activa para esa combinación.");
                    } else {
                        setMsg(request, "success", "Política consultada.");
                    }

                    forward(request, response);
                    return;
                }

                default:
                    setMsg(request, "error", "Acción no soportada: " + accion);
                    forward(request, response);
            }

        } catch (Exception e) {
            setMsg(request, "error", "Error servidor: " + e.getMessage());
            forward(request, response);
        }
    }

    // ------------------ Helpers ------------------

    private void forward(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/politica/consultarPolitica.jsp").forward(request, response);
    }

    private void setMsg(HttpServletRequest request, String type, String msg) {
        request.setAttribute("msgType", type);
        request.setAttribute("msg", msg);
    }

    private String nvl(String s, String def) {
        return (s == null || s.trim().isEmpty()) ? def : s.trim();
    }

    private Integer parseIntOrNull(String s) {
        try {
            if (s == null || s.trim().isEmpty()) return null;
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return null;
        }
    }

    private LocalDate parseFecha(String yyyyMMdd) {
        try {
            if (yyyyMMdd == null || yyyyMMdd.trim().isEmpty()) return null;
            // input type=date -> yyyy-MM-dd
            return LocalDate.parse(yyyyMMdd.trim(), DateTimeFormatter.ISO_LOCAL_DATE);
        } catch (Exception e) {
            return null;
        }
    }

    private <T> List<T> safeList(List<T> list) {
        return (list == null) ? Collections.emptyList() : list;
    }

    /**
     * Reglas:
     * - si no hay política -> mensaje neutro
     * - si tiempo == 0 -> NO DEVOLUTIVO
     * - mesesRestantes = meses entre hoy y vencimiento (si vencido, será <= 0)
     */
    private EvaluacionPolitica evaluarPolitica(PoliticaDevolucion pol, LocalDate fechaVenc) {
        EvaluacionPolitica ev = new EvaluacionPolitica();

        LocalDate hoy = LocalDate.now();
        long mesesRestantes = ChronoUnit.MONTHS.between(hoy.withDayOfMonth(1), fechaVenc.withDayOfMonth(1));
        ev.setMesesRestantes((int) mesesRestantes);

        if (pol == null) {
            ev.setResultado("SIN_POLITICA");
            ev.setMensaje("No hay política activa para esta combinación.");
            return ev;
        }

        Integer tiempo = pol.getTiempo();
        if (tiempo == null) tiempo = 0;

        if (tiempo == 0) {
            ev.setResultado("NO_DEVOLUTIVO");
            ev.setMensaje("Producto NO devolutivo (tiempo = 0).");
            return ev;
        }

        if (mesesRestantes > tiempo) {
            ev.setResultado("ANTICIPADO");
            ev.setMensaje("Producto enviado con mucha antelación.");
        } else if (mesesRestantes == tiempo) {
            ev.setResultado("OK");
            ev.setMensaje("Está dentro de la política.");
        } else {
            ev.setResultado("FUERA");
            ev.setMensaje("Fuera de política de devolución.");
        }

        return ev;
    }
}

