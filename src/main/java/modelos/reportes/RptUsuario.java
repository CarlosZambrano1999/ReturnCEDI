/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelos.reportes;

import java.sql.Date;

/**
 *
 * @author arlom
 */
public class RptUsuario {
    private String doc_material;
    private String codigo_sap;
    private String producto;
    private int id_usuario;
    private int enviado;
    private int recibido;
    private String farmacia;
    private String incidencia;
    private String observacion;
    private Date fecha_scan;
    private int tipo;

    public RptUsuario() {
    }

    public RptUsuario(String doc_material, String codigo_sap, String producto, int id_usuario, int enviado, int recibido, String farmacia, String incidencia, String observacion, Date fecha_scan, int tipo) {
        this.doc_material = doc_material;
        this.codigo_sap = codigo_sap;
        this.producto = producto;
        this.id_usuario = id_usuario;
        this.enviado = enviado;
        this.recibido = recibido;
        this.farmacia = farmacia;
        this.incidencia = incidencia;
        this.observacion = observacion;
        this.fecha_scan = fecha_scan;
        this.tipo = tipo;
    }

    public String getDoc_material() {
        return doc_material;
    }

    public void setDoc_material(String doc_material) {
        this.doc_material = doc_material;
    }

    public String getCodigo_sap() {
        return codigo_sap;
    }

    public void setCodigo_sap(String codigo_sap) {
        this.codigo_sap = codigo_sap;
    }

    public String getProducto() {
        return producto;
    }

    public void setProducto(String producto) {
        this.producto = producto;
    }

    public int getId_usuario() {
        return id_usuario;
    }

    public void setId_usuario(int id_usuario) {
        this.id_usuario = id_usuario;
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

    public int getTipo() {
        return tipo;
    }

    public void setTipo(int tipo) {
        this.tipo = tipo;
    }
    
    
}

