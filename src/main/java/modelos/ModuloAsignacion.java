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
    
}
