/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelos;

/**
 *
 * @author Administrador
 */
public class EvaluacionPolitica {
    private String resultado;       // OK / ANTICIPADO / FUERA / NO_DEVOLUTIVO
    private String mensaje;
    private Integer mesesRestantes;

    public EvaluacionPolitica() {
    }

    public String getResultado() {
        return resultado;
    }

    public void setResultado(String resultado) {
        this.resultado = resultado;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }

    public Integer getMesesRestantes() {
        return mesesRestantes;
    }

    public void setMesesRestantes(Integer mesesRestantes) {
        this.mesesRestantes = mesesRestantes;
    }
    
}
