/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelos;

/**
 *
 * @author Administrador
 */
public class Versiculo {
    private int idVersiculo;
    private String versiculo;
    private String cita;

    public Versiculo() {}

    public Versiculo(int idVersiculo, String versiculo, String cita) {
        this.idVersiculo = idVersiculo;
        this.versiculo = versiculo;
        this.cita = cita;
    }

    public int getIdVersiculo() {
        return idVersiculo;
    }

    public void setIdVersiculo(int idVersiculo) {
        this.idVersiculo = idVersiculo;
    }

    public String getVersiculo() {
        return versiculo;
    }

    public void setVersiculo(String versiculo) {
        this.versiculo = versiculo;
    }

    public String getCita() {
        return cita;
    }

    public void setCita(String cita) {
        this.cita = cita;
    }
}