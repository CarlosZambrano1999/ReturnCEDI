/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelos;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Time;

/**
 *
 * @author Administrador
 */
public class DatosDocMaterial {
    private String codigoSap;        // Material
    private String descripcion;      // Texto breve de material
    private String centro;           // Ce.
    private String almacen;          // Alm.
    private Integer transito;        // Cl.mov.
    private Long docMaterial;        // Doc.mat.
    private Integer posicion;        // Pos.
    private String referencia;       // Referencia
    private String texto;            // Texto
    private Time hora;               // Hora
    private String usuario;          // Usuario
    private Date fechaDocumento;     // Fecha doc.
    private Date fechaContable;      // Fe.contab.
    private BigDecimal cantidad;     // Ctd.en UM entrada (ej: 18.000)
    private BigDecimal importe;      // Importe (ej: 1123.65)

    public DatosDocMaterial() {
    }

    public DatosDocMaterial(String codigoSap, String descripcion, String centro, String almacen, Integer transito, Long docMaterial, Integer posicion, String referencia, String texto, Time hora, String usuario, Date fechaDocumento, Date fechaContable, BigDecimal cantidad, BigDecimal importe) {
        this.codigoSap = codigoSap;
        this.descripcion = descripcion;
        this.centro = centro;
        this.almacen = almacen;
        this.transito = transito;
        this.docMaterial = docMaterial;
        this.posicion = posicion;
        this.referencia = referencia;
        this.texto = texto;
        this.hora = hora;
        this.usuario = usuario;
        this.fechaDocumento = fechaDocumento;
        this.fechaContable = fechaContable;
        this.cantidad = cantidad;
        this.importe = importe;
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

    public String getCentro() {
        return centro;
    }

    public void setCentro(String centro) {
        this.centro = centro;
    }

    public String getAlmacen() {
        return almacen;
    }

    public void setAlmacen(String almacen) {
        this.almacen = almacen;
    }

    public Integer getTransito() {
        return transito;
    }

    public void setTransito(Integer transito) {
        this.transito = transito;
    }

    public Long getDocMaterial() {
        return docMaterial;
    }

    public void setDocMaterial(Long docMaterial) {
        this.docMaterial = docMaterial;
    }

    public Integer getPosicion() {
        return posicion;
    }

    public void setPosicion(Integer posicion) {
        this.posicion = posicion;
    }

    public String getReferencia() {
        return referencia;
    }

    public void setReferencia(String referencia) {
        this.referencia = referencia;
    }

    public String getTexto() {
        return texto;
    }

    public void setTexto(String texto) {
        this.texto = texto;
    }

    public Time getHora() {
        return hora;
    }

    public void setHora(Time hora) {
        this.hora = hora;
    }

    public String getUsuario() {
        return usuario;
    }

    public void setUsuario(String usuario) {
        this.usuario = usuario;
    }

    public Date getFechaDocumento() {
        return fechaDocumento;
    }

    public void setFechaDocumento(Date fechaDocumento) {
        this.fechaDocumento = fechaDocumento;
    }

    public Date getFechaContable() {
        return fechaContable;
    }

    public void setFechaContable(Date fechaContable) {
        this.fechaContable = fechaContable;
    }

    public BigDecimal getCantidad() {
        return cantidad;
    }

    public void setCantidad(BigDecimal cantidad) {
        this.cantidad = cantidad;
    }

    public BigDecimal getImporte() {
        return importe;
    }

    public void setImporte(BigDecimal importe) {
        this.importe = importe;
    }
    
    
}
