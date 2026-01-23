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
import java.util.ArrayList;
import java.util.List;
import modelos.ModuloAsignacion;

/**
 *
 * @author Administrador
 */
public class AccesoDAO {

    public List<ModuloAsignacion> obtenerModulosPorRol(int idRol) throws SQLException {
        List<ModuloAsignacion> lista = new ArrayList<>();
        String sql = "{CALL GUIA.SP_ROL_MODULOS_OBTENER(?)}";

        try (Connection cn = new ConexionSQLServer().getConnection();
             CallableStatement cs = cn.prepareCall(sql)) {

            cs.setInt(1, idRol);

            try (ResultSet rs = cs.executeQuery()) {
                // OJO: si el SP retorna 'status/message' cuando error, aquí podrías detectarlo
                while (rs.next()) {
                    ModuloAsignacion ma = new ModuloAsignacion();
                    ma.setIdModulo(rs.getInt("ID_MODULO"));
                    ma.setModulo(rs.getString("MODULO"));
                    ma.setEstadoModulo(rs.getInt("ESTADO_MODULO"));
                    ma.setAsignado(rs.getInt("ASIGNADO"));
                    ma.setEstadoAsignacion(rs.getInt("ESTADO_ASIGNACION"));
                    lista.add(ma);
                }
            }
        }
        return lista;
    }

    public ResultadoSP guardarAsignacionCSV(int idRol, String modulosCsv) throws SQLException {
        String sql = "{CALL GUIA.SP_ROL_MODULOS_GUARDAR_CSV(?,?)}";

        try (Connection cn = new ConexionSQLServer().getConnection();
             CallableStatement cs = cn.prepareCall(sql)) {

            cs.setInt(1, idRol);
            cs.setString(2, modulosCsv == null ? "" : modulosCsv);

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

