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
public class Guias {
    private int id_usuario;
    private String nombre;
    private String doc_material;
    private Date fecha_cierre;
    private String tipo;

    public Guias() {
    }

    public Guias(int id_usuario, String nombre, String doc_material, Date fecha_cierre, String tipo) {
        this.id_usuario = id_usuario;
        this.nombre = nombre;
        this.doc_material = doc_material;
        this.fecha_cierre = fecha_cierre;
        this.tipo = tipo;
    }

    public int getId_usuario() {
        return id_usuario;
    }

    public void setId_usuario(int id_usuario) {
        this.id_usuario = id_usuario;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDoc_material() {
        return doc_material;
    }

    public void setDoc_material(String doc_material) {
        this.doc_material = doc_material;
    }

    public Date getFecha_cierre() {
        return fecha_cierre;
    }

    public void setFecha_cierre(Date fecha_cierre) {
        this.fecha_cierre = fecha_cierre;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }
    
}
