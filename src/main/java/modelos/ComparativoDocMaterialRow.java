/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelos;

import java.math.BigDecimal;

/**
 *
 * @author Administrador
 */
public class ComparativoDocMaterialRow {
    private String codigoSap;
    private String descripcion;
    private BigDecimal cantidadEsperada;
    private BigDecimal cantidadEscaneada;
    private BigDecimal diferencia;
    private int factor;
    private String presentacion;
    private String estado;
    private Long idDevolucion;
    private java.math.BigDecimal cantidadEditable;
    private Integer incidenciaId;
    private String observacion;

    public ComparativoDocMaterialRow() {
    }

    public ComparativoDocMaterialRow(String codigoSap, String descripcion, BigDecimal cantidadEsperada, BigDecimal cantidadEscaneada, BigDecimal diferencia, int factor, String presentacion, String estado, Long idDevolucion, BigDecimal cantidadEditable, Integer incidenciaId, String observacion) {
        this.codigoSap = codigoSap;
        this.descripcion = descripcion;
        this.cantidadEsperada = cantidadEsperada;
        this.cantidadEscaneada = cantidadEscaneada;
        this.diferencia = diferencia;
        this.factor = factor;
        this.presentacion = presentacion;
        this.estado = estado;
        this.idDevolucion = idDevolucion;
        this.cantidadEditable = cantidadEditable;
        this.incidenciaId = incidenciaId;
        this.observacion = observacion;
    }

    
    public String getCodigoSap() {
        return codigoSap;
    }

    public void setCodigoSap(String codigoSap) {
        this.codigoSap = codigoSap;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public BigDecimal getCantidadEsperada() {
        return cantidadEsperada;
    }

    public void setCantidadEsperada(BigDecimal cantidadEsperada) {
        this.cantidadEsperada = cantidadEsperada;
    }

    public BigDecimal getCantidadEscaneada() {
        return cantidadEscaneada;
    }

    public void setCantidadEscaneada(BigDecimal cantidadEscaneada) {
        this.cantidadEscaneada = cantidadEscaneada;
    }

    public BigDecimal getDiferencia() {
        return diferencia;
    }

    public void setDiferencia(BigDecimal diferencia) {
        this.diferencia = diferencia;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public int getFactor() {
        return factor;
    }

    public void setFactor(int factor) {
        this.factor = factor;
    }

    public String getPresentacion() {
        return presentacion;
    }

    public void setPresentacion(String presentacion) {
        this.presentacion = presentacion;
    }

    public Long getIdDevolucion() {
        return idDevolucion;
    }

    public void setIdDevolucion(Long idDevolucion) {
        this.idDevolucion = idDevolucion;
    }

    public BigDecimal getCantidadEditable() {
        return cantidadEditable;
    }

    public void setCantidadEditable(BigDecimal cantidadEditable) {
        this.cantidadEditable = cantidadEditable;
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
    
}
