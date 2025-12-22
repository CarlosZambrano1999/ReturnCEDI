/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelos.reportes;

/**
 *
 * @author Administrador
 */
public class RptFarmaciasMayorIncidencia {

    private String farmacia;

    private Integer totalRegistros;
    private Integer totalIncidencias;

    public RptFarmaciasMayorIncidencia() {}

    public String getFarmacia() { return farmacia; }
    public void setFarmacia(String farmacia) { this.farmacia = farmacia; }

    public Integer getTotalRegistros() { return totalRegistros; }
    public void setTotalRegistros(Integer totalRegistros) { this.totalRegistros = totalRegistros; }

    public Integer getTotalIncidencias() { return totalIncidencias; }
    public void setTotalIncidencias(Integer totalIncidencias) { this.totalIncidencias = totalIncidencias; }
}
