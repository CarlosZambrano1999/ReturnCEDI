/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelos;

/**
 *
 * @author Administrador
 */
public class DocMaterial {
    private long numero;   // NUMERO (Doc.mat.)
    private int estado;    // ESTADO (1 = cargado / pendiente, etc.)

    public DocMaterial() {
    }

    public DocMaterial(long numero, int estado) {
        this.numero = numero;
        this.estado = estado;
    }

    public long getNumero() {
        return numero;
    }

    public void setNumero(long numero) {
        this.numero = numero;
    }

    public int getEstado() {
        return estado;
    }

    public void setEstado(int estado) {
        this.estado = estado;
    }
}