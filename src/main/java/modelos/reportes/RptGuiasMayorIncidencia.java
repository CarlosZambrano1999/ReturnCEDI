/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelos.reportes;

import java.math.BigDecimal;

/**
 *
 * @author Administrador
 */
public class RptGuiasMayorIncidencia {

    private Long docMaterial;

    private Integer totalRegistros;
    private Integer totalIncidencias;

    private BigDecimal porcIncidencia; // DECIMAL(10,2)

    public RptGuiasMayorIncidencia() {}

    public Long getDocMaterial() { return docMaterial; }
    public void setDocMaterial(Long docMaterial) { this.docMaterial = docMaterial; }

    public Integer getTotalRegistros() { return totalRegistros; }
    public void setTotalRegistros(Integer totalRegistros) { this.totalRegistros = totalRegistros; }

    public Integer getTotalIncidencias() { return totalIncidencias; }
    public void setTotalIncidencias(Integer totalIncidencias) { this.totalIncidencias = totalIncidencias; }

    public BigDecimal getPorcIncidencia() { return porcIncidencia; }
    public void setPorcIncidencia(BigDecimal porcIncidencia) { this.porcIncidencia = porcIncidencia; }
}