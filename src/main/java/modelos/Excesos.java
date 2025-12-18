/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelos;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 *
 * @author Administrador
 */
public class Excesos {
    private Long id;                 // ID (identity)
    private Long docMaterial;        // DOC_MATERIAL
    private String codigoSap;        // CODIGO_SAP
    private String codigo;           // CODIGO
    private String producto;         // PRODUCTO
    private String laboratorio;      // LABORATORIO
    private String presentacion;     // PRESENTACION
    private BigDecimal factor;       // FACTOR
    private Long usuarioId;          // (nuevo) ID del usuario que escaneó
    private BigDecimal cantidad;     // CANTIDAD

    private Integer incidenciaId;    // INCIDENCIA_ID
    private String observacion;      // OBSERVACION
    private Timestamp fechaScan; 

    public Excesos() {
    }

    public Excesos(Long id, Long docMaterial, String codigoSap, String codigo, String producto, String laboratorio, String presentacion, BigDecimal factor, Long usuarioId, BigDecimal cantidad, Integer incidenciaId, String observacion, Timestamp fechaScan) {
        this.id = id;
        this.docMaterial = docMaterial;
        this.codigoSap = codigoSap;
        this.codigo = codigo;
        this.producto = producto;
        this.laboratorio = laboratorio;
        this.presentacion = presentacion;
        this.factor = factor;
        this.usuarioId = usuarioId;
        this.cantidad = cantidad;
        this.incidenciaId = incidenciaId;
        this.observacion = observacion;
        this.fechaScan = fechaScan;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getDocMaterial() {
        return docMaterial;
    }

    public void setDocMaterial(Long docMaterial) {
        this.docMaterial = docMaterial;
    }

    public String getCodigoSap() {
        return codigoSap;
    }

    public void setCodigoSap(String codigoSap) {
        this.codigoSap = codigoSap;
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

    public String getLaboratorio() {
        return laboratorio;
    }

    public void setLaboratorio(String laboratorio) {
        this.laboratorio = laboratorio;
    }

    public String getPresentacion() {
        return presentacion;
    }

    public void setPresentacion(String presentacion) {
        this.presentacion = presentacion;
    }

    public BigDecimal getFactor() {
        return factor;
    }

    public void setFactor(BigDecimal factor) {
        this.factor = factor;
    }

    public Long getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(Long usuarioId) {
        this.usuarioId = usuarioId;
    }

    public BigDecimal getCantidad() {
        return cantidad;
    }

    public void setCantidad(BigDecimal cantidad) {
        this.cantidad = cantidad;
    }

    public Integer getIncidenciaId() {
        return incidenciaId;
    }

    public void setIncidenciaId(Integer incidenciaId) {
        this.incidenciaId = incidenciaId;
    }

    public String getObservacion() {
        return observacion;
    }

    public void setObservacion(String observacion) {
        this.observacion = observacion;
    }

    public Timestamp getFechaScan() {
        return fechaScan;
    }

    public void setFechaScan(Timestamp fechaScan) {
        this.fechaScan = fechaScan;
    }
    
    
}
