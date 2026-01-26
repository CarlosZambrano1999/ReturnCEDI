/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelos;

/**
 *
 * @author Administrador
 */
public class ModuloAsignacion {
    
    private int idModulo;
    private String modulo;
    private int estadoModulo;      // estado del módulo (activo/inactivo)
    private int asignado;          // 1/0
    private int estadoAsignacion;
    private String titulo;
    private String descripcion;
    private String icono;
    private String categoria;
    private Integer orden;

    public ModuloAsignacion() {
    }

    public int getIdModulo() {
        return idModulo;
    }

    public void setIdModulo(int idModulo) {
        this.idModulo = idModulo;
    }

    public String getModulo() {
        return modulo;
    }

    public void setModulo(String modulo) {
        this.modulo = modulo;
    }

    public int getEstadoModulo() {
        return estadoModulo;
    }

    public void setEstadoModulo(int estadoModulo) {
        this.estadoModulo = estadoModulo;
    }

    public int getAsignado() {
        return asignado;
    }

    public void setAsignado(int asignado) {
        this.asignado = asignado;
    }

    public int getEstadoAsignacion() {
        return estadoAsignacion;
    }

    public void setEstadoAsignacion(int estadoAsignacion) {
        this.estadoAsignacion = estadoAsignacion;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getIcono() {
        return icono;
    }

    public void setIcono(String icono) {
        this.icono = icono;
    }

    public String getCategoria() {
        return categoria;
    }

    public void setCategoria(String categoria) {
        this.categoria = categoria;
    }

    public Integer getOrden() {
        return orden;
    }

    public void setOrden(Integer orden) {
        this.orden = orden;
    }
    
    
}
