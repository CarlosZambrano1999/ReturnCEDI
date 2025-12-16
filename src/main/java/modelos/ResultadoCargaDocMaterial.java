/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelos;

/**
 *
 * @author Administrador
 */
public class ResultadoCargaDocMaterial {
    
    private String status;       // "success" | "error"
    private Long docMaterial;
    private Integer filasInsertadas;
    private Integer errorNumber;
    private String errorMessage;

    public ResultadoCargaDocMaterial() {
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Long getDocMaterial() {
        return docMaterial;
    }

    public void setDocMaterial(Long docMaterial) {
        this.docMaterial = docMaterial;
    }

    public Integer getFilasInsertadas() {
        return filasInsertadas;
    }

    public void setFilasInsertadas(Integer filasInsertadas) {
        this.filasInsertadas = filasInsertadas;
    }

    public Integer getErrorNumber() {
        return errorNumber;
    }

    public void setErrorNumber(Integer errorNumber) {
        this.errorNumber = errorNumber;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }
    
}
