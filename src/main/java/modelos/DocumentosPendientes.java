/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelos;

import java.sql.Timestamp;

/**
 *
 * @author Administrador
 */
public class DocumentosPendientes {
    
    private long numero;
    private int estado;
    private Timestamp fecha;
    private String tipo;
    private String usuario;

    public DocumentosPendientes() {}

    public DocumentosPendientes(long numero, int estado, Timestamp fecha, String tipo, String usuario) {
        this.numero = numero;
        this.estado = estado;
        this.fecha = fecha;
        this.tipo = tipo;
        this.usuario = usuario;
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

    public Timestamp getFecha() {
        return fecha;
    }

    public void setFecha(Timestamp fecha) {
        this.fecha = fecha;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getUsuario() {
        return usuario;
    }

    public void setUsuario(String usuario) {
        this.usuario = usuario;
    }
}
