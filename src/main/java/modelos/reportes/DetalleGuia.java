package modelos.reportes;

import java.sql.Date;

public class DetalleGuia {

    private String doc_material;
    private String usuario;
    private String codigo_sap;
    private String codigo;
    private String producto;
    private int enviado;
    private int recibido;
    private String farmacia;
    private String incidencia;
    private String observacion;
    private Date fecha_scan;

    public DetalleGuia() {
    }

    public DetalleGuia(String doc_material, String usuario, String codigo_sap, String codigo,
                       String producto, int enviado, int recibido, String farmacia,
                       String incidencia, String observacion, Date fecha_scan) {
        this.doc_material = doc_material;
        this.usuario = usuario;
        this.codigo_sap = codigo_sap;
        this.codigo = codigo;
        this.producto = producto;
        this.enviado = enviado;
        this.recibido = recibido;
        this.farmacia = farmacia;
        this.incidencia = incidencia;
        this.observacion = observacion;
        this.fecha_scan = fecha_scan;
    }

    public String getDoc_material() {
        return doc_material;
    }

    public void setDoc_material(String doc_material) {
        this.doc_material = doc_material;
    }

    public String getUsuario() {
        return usuario;
    }

    public void setUsuario(String usuario) {
        this.usuario = usuario;
    }

    public String getCodigo_sap() {
        return codigo_sap;
    }

    public void setCodigo_sap(String codigo_sap) {
        this.codigo_sap = codigo_sap;
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public String getProducto() {
        return producto;
    }

    public void setProducto(String producto) {
        this.producto = producto;
    }

    public int getEnviado() {
        return enviado;
    }

    public void setEnviado(int enviado) {
        this.enviado = enviado;
    }

    public int getRecibido() {
        return recibido;
    }

    public void setRecibido(int recibido) {
        this.recibido = recibido;
    }

    public String getFarmacia() {
        return farmacia;
    }

    public void setFarmacia(String farmacia) {
        this.farmacia = farmacia;
    }

    public String getIncidencia() {
        return incidencia;
    }

    public void setIncidencia(String incidencia) {
        this.incidencia = incidencia;
    }

    public String getObservacion() {
        return observacion;
    }

    public void setObservacion(String observacion) {
        this.observacion = observacion;
    }

    public Date getFecha_scan() {
        return fecha_scan;
    }

    public void setFecha_scan(Date fecha_scan) {
        this.fecha_scan = fecha_scan;
    }
}
