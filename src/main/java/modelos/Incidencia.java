/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelos;

/**
 *
 * @author arlom
 */
public class Incidencia {
    private int id_incidencia;
    private String incidencia;
    private int estado;

    public Incidencia() {
    }

    public Incidencia(int id_incidencia, String incidencia, int estado) {
        this.id_incidencia = id_incidencia;
        this.incidencia = incidencia;
        this.estado = estado;
    }

    public int getId_incidencia() {
        return id_incidencia;
    }

    public void setId_incidencia(int id_incidencia) {
        this.id_incidencia = id_incidencia;
    }

    public String getIncidencia() {
        return incidencia;
    }

    public void setIncidencia(String incidencia) {
        this.incidencia = incidencia;
    }

    public int getEstado() {
        return estado;
    }

    public void setEstado(int estado) {
        this.estado = estado;
    }
    
            
}
