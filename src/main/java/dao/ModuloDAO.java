/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import configDB.ConexionSQLServer;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import modelos.Modulo;

/**
 *
 * @author Administrador
 */
public class ModuloDAO {

    public List<Modulo> listar() throws SQLException {
        List<Modulo> lista = new ArrayList<>();
        String sql = "{CALL GUIA.SP_MODULOS_LISTAR}";

        try (Connection cn = new ConexionSQLServer().getConnection();
             CallableStatement cs = cn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {

            while (rs.next()) {
                Modulo m = new Modulo();
                m.setIdModulo(rs.getInt("ID_MODULO"));
                m.setModulo(rs.getString("MODULO"));
                m.setEstado(rs.getInt("ESTADO"));
                lista.add(m);
            }
        }
        return lista;
    }

    public ResultadoSP insertar(String modulo) throws SQLException {
        String sql = "{CALL GUIA.SP_MODULOS_INSERTAR(?)}";

        try (Connection cn = new ConexionSQLServer().getConnection();
             CallableStatement cs = cn.prepareCall(sql)) {

            cs.setString(1, modulo);

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    return new ResultadoSP(rs.getString("status"), rs.getString("message"));
                }
            }
        }
        return new ResultadoSP("error", "No hubo respuesta del SP.");
    }

    public ResultadoSP cambiarEstado(int idModulo, int estado) throws SQLException {
        String sql = "{CALL GUIA.SP_MODULOS_CAMBIAR_ESTADO(?,?)}";

        try (Connection cn = new ConexionSQLServer().getConnection();
             CallableStatement cs = cn.prepareCall(sql)) {

            cs.setInt(1, idModulo);
            cs.setInt(2, estado);

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    return new ResultadoSP(rs.getString("status"), rs.getString("message"));
                }
            }
        }
        return new ResultadoSP("error", "No hubo respuesta del SP.");
    }

    public ResultadoSP actualizar(int idModulo, String modulo) throws SQLException {
        String sql = "{CALL GUIA.SP_MODULOS_ACTUALIZAR(?,?)}";

        try (Connection cn = new ConexionSQLServer().getConnection();
             CallableStatement cs = cn.prepareCall(sql)) {

            cs.setInt(1, idModulo);
            cs.setString(2, modulo);

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    return new ResultadoSP(rs.getString("status"), rs.getString("message"));
                }
            }
        }
        return new ResultadoSP("error", "No hubo respuesta del SP.");
    }

    public static class ResultadoSP {
        private final String status;
        private final String message;

        public ResultadoSP(String status, String message) {
            this.status = status;
            this.message = message;
        }

        public String getStatus() { return status; }
        public String getMessage() { return message; }
    }
    
    public boolean tieneAcceso(int idRol, String ruta) throws SQLException {
        String sql = "{CALL GUIA.SP_VALIDAR_ACCESO_MODULO(?,?)}";

        try (Connection cn = new ConexionSQLServer().getConnection();
             CallableStatement cs = cn.prepareCall(sql)) {

            cs.setInt(1, idRol);
            cs.setString(2, ruta);

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("TIENE_ACCESO") == 1;
                }
            }
        }
        return false;
    }

}