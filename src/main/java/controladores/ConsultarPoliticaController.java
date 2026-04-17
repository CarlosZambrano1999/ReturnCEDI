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
 * Return
 */
@WebServlet(name = "ConsultarPoliticaServlet", urlPatterns = {"/ConsultarPolitica"})
public class ConsultarPoliticaController extends HttpServlet {

    private final ConsultarPoliticaDAO dao = new ConsultarPoliticaDAO();
    private final PoliticaEvaluatorService politicaService = new PoliticaEvaluatorService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Usuario usuario = getUsuarioSesion(request);
        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Usuario usuario = getUsuarioSesion(request);
        if (usuario == null) {
            setMsg(request, "error", "Sesión expirada. Volvé a iniciar sesión.");
            forward(request, response);
            return;
        }

        String accion = nvl(request.getParameter("accion"), "").toLowerCase();
        String codigo = nvl(request.getParameter("codigo"), "");
        String idProveedor = nvl(request.getParameter("idProveedor"), "");
        String idColorStr = nvl(request.getParameter("idColor"), "");
        String fechaVencStr = nvl(request.getParameter("fechaVencimiento"), "");

        try {
            switch (accion) {
                case "buscarproducto":
                    buscarProducto(request, codigo);
                    break;

                case "cargarcolores":
                    cargarColores(request, codigo, idProveedor);
                    break;

                case "consultarpolitica":
                    consultarPolitica(request, codigo, idProveedor, idColorStr, fechaVencStr);
                    break;

                default:
                    setMsg(request, "error", "Acción no soportada: " + accion);
                    break;
            }
        } catch (Exception e) {
            setMsg(request, "error", "Error servidor: " + e.getMessage());
        }

        forward(request, response);
    }

    private void buscarProducto(HttpServletRequest request, String codigo) {
        if (codigo.isEmpty()) {
            setMsg(request, "warning", "Escaneá o ingresá un código.");
            limpiarResultado(request);
            return;
        }

        Producto producto = dao.buscarProducto(codigo);
        if (producto == null) {
            setMsg(request, "warning", "Producto no encontrado.");
            limpiarPantalla(request, codigo);
            return;
        }

        cargarContextoProducto(request, producto, codigo);
        request.setAttribute("colores", Collections.emptyList());
        limpiarResultado(request);

        setMsg(request, "success", "Producto cargado. Seleccioná proveedor y color.");
    }

    private void cargarColores(HttpServletRequest request, String codigo, String idProveedor) {
        Producto producto = obtenerProductoValido(request, codigo);
        if (producto == null) return;

        cargarContextoProducto(request, producto, codigo);

        if (idProveedor.isEmpty()) {
            request.setAttribute("colores", Collections.emptyList());
            setMsg(request, "warning", "Seleccioná un proveedor.");
            return;
        }

        request.setAttribute("idProveedor", idProveedor);

        List<ColorPolitica> colores = safeList(
                dao.listarColoresPorLabProveedor(producto.getIdLaboratorio(), idProveedor)
        );
        request.setAttribute("colores", colores);

        limpiarResultado(request);
        setMsg(request, "success", "Ahora seleccioná un color y la fecha de vencimiento.");
    }

    private void consultarPolitica(HttpServletRequest request, String codigo, String idProveedor,
                                   String idColorStr, String fechaVencStr) {

        Producto producto = obtenerProductoValido(request, codigo);
        if (producto == null) return;

        cargarContextoProducto(request, producto, codigo);

        if (idProveedor.isEmpty()) {
            setMsg(request, "warning", "Seleccioná un proveedor.");
            return;
        }

        Integer idColor = parseIntOrNull(idColorStr);
        if (idColor == null) {
            request.setAttribute("idProveedor", idProveedor);
            cargarColoresSeleccionados(request, producto, idProveedor);
            setMsg(request, "warning", "Seleccioná un color.");
            return;
        }

        LocalDate fechaVenc = parseFecha(fechaVencStr);
        if (fechaVenc == null) {
            request.setAttribute("idProveedor", idProveedor);
            request.setAttribute("idColor", idColor);
            request.setAttribute("fechaVencimiento", fechaVencStr);
            cargarColoresSeleccionados(request, producto, idProveedor);
            setMsg(request, "warning", "Ingresá una fecha de vencimiento válida.");
            return;
        }

        request.setAttribute("idProveedor", idProveedor);
        request.setAttribute("idColor", idColor);
        request.setAttribute("fechaVencimiento", fechaVencStr);

        cargarColoresSeleccionados(request, producto, idProveedor);

        PoliticaDevolucion politica = dao.consultarPolitica(producto.getIdLaboratorio(), idProveedor, idColor);
        request.setAttribute("politica", politica);

        EvaluacionPolitica evaluacion = politicaService.evaluar(politica, fechaVenc);
        request.setAttribute("evaluacion", evaluacion);

        if (politica == null) {
            setMsg(request, "warning", "No existe una política activa para esa combinación.");
        } else {
            setMsg(request, "success", "Política consultada.");
        }
    }

    private Producto obtenerProductoValido(HttpServletRequest request, String codigo) {
        if (codigo.isEmpty()) {
            setMsg(request, "warning", "Primero buscá el producto.");
            return null;
        }

        Producto producto = dao.buscarProducto(codigo);
        if (producto == null) {
            setMsg(request, "warning", "Producto no encontrado. Volvé a escanear.");
            return null;
        }

        return producto;
    }

    private void cargarContextoProducto(HttpServletRequest request, Producto producto, String codigo) {
        request.setAttribute("producto", producto);
        request.setAttribute("codigo", codigo);

        List<ProveedorPolitica> proveedores = safeList(
                dao.listarProveedoresPorLaboratorio(producto.getIdLaboratorio())
        );
        request.setAttribute("proveedores", proveedores);
    }

    private void cargarColoresSeleccionados(HttpServletRequest request, Producto producto, String idProveedor) {
        List<ColorPolitica> colores = safeList(
                dao.listarColoresPorLabProveedor(producto.getIdLaboratorio(), idProveedor)
        );
        request.setAttribute("colores", colores);
    }

    private void limpiarPantalla(HttpServletRequest request, String codigo) {
        request.setAttribute("codigo", codigo);
        request.setAttribute("producto", null);
        request.setAttribute("proveedores", Collections.emptyList());
        request.setAttribute("colores", Collections.emptyList());
        limpiarResultado(request);
    }

    private void limpiarResultado(HttpServletRequest request) {
        request.setAttribute("politica", null);
        request.setAttribute("evaluacion", null);
    }

    private Usuario getUsuarioSesion(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return (session == null) ? null : (Usuario) session.getAttribute("usuario");
    }

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
            return (s == null || s.trim().isEmpty()) ? null : Integer.parseInt(s.trim());
        } catch (Exception e) {
            return null;
        }
    }

    private LocalDate parseFecha(String yyyyMMdd) {
        try {
            return (yyyyMMdd == null || yyyyMMdd.trim().isEmpty())
                    ? null
                    : LocalDate.parse(yyyyMMdd.trim(), DateTimeFormatter.ISO_LOCAL_DATE);
        } catch (Exception e) {
            return null;
        }
    }

    private <T> List<T> safeList(List<T> list) {
        return (list == null) ? Collections.emptyList() : list;
    }
    
    public class PoliticaEvaluatorService {

    public EvaluacionPolitica evaluar(PoliticaDevolucion pol, LocalDate fechaVenc) {
        EvaluacionPolitica ev = new EvaluacionPolitica();

        LocalDate hoy = LocalDate.now();
        long mesesRestantes = ChronoUnit.MONTHS.between(
                hoy.withDayOfMonth(1),
                fechaVenc.withDayOfMonth(1)
        );

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
}

