/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelos.reportes;

import java.sql.Date;

/**
 *
 * @author Administrador
 */
public class RptProductividadDiaHoraUsuario {
    
    private Date fecha;                 // CAST(FECHA_SCAN as DATE)
    private Integer hora;               // DATEPART(HOUR, FECHA_SCAN)
    private Integer idUsuario;
    private String nombre;  
    private Integer totalEscaneos;
    private Integer totalCantidad;
    private Integer conIncidencia;
    private Integer sinIncidencia;

    public RptProductividadDiaHoraUsuario() {
    }

    public Date getFecha() {
        return fecha;
    }

    public void setFecha(Date fecha) {
        this.fecha = fecha;
    }

    public Integer getHora() {
        return hora;
    }

    public void setHora(Integer hora) {
        this.hora = hora;
    }

    public Integer getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(Integer idUsuario) {
        this.idUsuario = idUsuario;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public Integer getTotalEscaneos() {
        return totalEscaneos;
    }

    public void setTotalEscaneos(Integer totalEscaneos) {
        this.totalEscaneos = totalEscaneos;
    }

    public Integer getTotalCantidad() {
        return totalCantidad;
    }

    public void setTotalCantidad(Integer totalCantidad) {
        this.totalCantidad = totalCantidad;
    }
    

    public Integer getConIncidencia() {
        return conIncidencia;
    }

    public void setConIncidencia(Integer conIncidencia) {
        this.conIncidencia = conIncidencia;
    }

    public Integer getSinIncidencia() {
        return sinIncidencia;
    }

    public void setSinIncidencia(Integer sinIncidencia) {
        this.sinIncidencia = sinIncidencia;
    }
    
}
