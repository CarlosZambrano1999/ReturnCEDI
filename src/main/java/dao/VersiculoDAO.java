/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import configDB.ConexionSQLServer;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import modelos.Versiculo;

/**
 *
 * @author Administrador
 */
public class VersiculoDAO {


    public Versiculo obtenerVersiculoAleatorio() {
        String sp = "{CALL COMPONENTES.SP_OBTENER_VERSICULO_ALEATORIO}";
        Versiculo v = null;

        try (Connection cn = new ConexionSQLServer().getConnection();
             CallableStatement cs = cn.prepareCall(sp)) {

            boolean hasResult = cs.execute();
            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) {
                        v = new Versiculo();
                        v.setIdVersiculo(rs.getInt("ID_VERSICULO"));
                        v.setVersiculo(rs.getString("VERSICULO"));
                        v.setCita(rs.getString("CITA"));
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return v;
    }
}
