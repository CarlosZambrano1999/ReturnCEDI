/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelos;

import java.util.ArrayList;
import java.util.List;
import modelos.reportes.ReporteDevolucionUnificada;

/**
 *
 * @author Administrador
 */
public class ResultadoPaginadoDevoluciones {

    private List<ReporteDevolucionUnificada> registros;
    private int totalRegistros;
    private int paginaActual;
    private int pageSize;
    private int totalPaginas;

    public ResultadoPaginadoDevoluciones() {
        this.registros = new ArrayList<>();
        this.totalRegistros = 0;
        this.paginaActual = 1;
        this.pageSize = 25;
        this.totalPaginas = 1;
    }

    public List<ReporteDevolucionUnificada> getRegistros() {
        return registros;
    }

    public void setRegistros(List<ReporteDevolucionUnificada> registros) {
        this.registros = registros;
    }

    public int getTotalRegistros() {
        return totalRegistros;
    }

    public void setTotalRegistros(int totalRegistros) {
        this.totalRegistros = totalRegistros;
    }

    public int getPaginaActual() {
        return paginaActual;
    }

    public void setPaginaActual(int paginaActual) {
        this.paginaActual = paginaActual;
    }

    public int getPageSize() {
        return pageSize;
    }

    public void setPageSize(int pageSize) {
        this.pageSize = pageSize;
    }

    public int getTotalPaginas() {
        return totalPaginas;
    }

    public void setTotalPaginas(int totalPaginas) {
        this.totalPaginas = totalPaginas;
    }
}
