/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelos;

/**
 *
 * @author Administrador
 */
public class Modulo {
    private int idModulo;
    private String ruta;        // MODULO (/Devoluciones)
    private String titulo;
    private String descripcion;
    private String icono;       // bi-...
    private String categoria;   // OPERACION/INCIDENCIAS/REPORTES/ADMIN
    private int orden;
    private int estado;

    public Modulo() {
    }

    public Modulo(int idModulo, String ruta, String titulo, String descripcion, String icono, String categoria, int orden, int estado) {
        this.idModulo = idModulo;
        this.ruta = ruta;
        this.titulo = titulo;
        this.descripcion = descripcion;
        this.icono = icono;
        this.categoria = categoria;
        this.orden = orden;
        this.estado = estado;
    }

    public int getIdModulo() {
        return idModulo;
    }

    public void setIdModulo(int idModulo) {
        this.idModulo = idModulo;
    }

    public String getRuta() {
        return ruta;
    }

    public void setRuta(String ruta) {
        this.ruta = ruta;
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

    public int getOrden() {
        return orden;
    }

    public void setOrden(int orden) {
        this.orden = orden;
    }

    public int getEstado() {
        return estado;
    }

    public void setEstado(int estado) {
        this.estado = estado;
    }
}
