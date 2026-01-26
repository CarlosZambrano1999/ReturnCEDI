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
                m.setRuta(rs.getString("MODULO"));
                m.setEstado(rs.getInt("ESTADO"));

                // NUEVOS CAMPOS (asegurate que el SP los retorne)
                m.setTitulo(rs.getString("TITULO"));
                m.setDescripcion(rs.getString("DESCRIPCION"));
                m.setIcono(rs.getString("ICONO"));
                m.setCategoria(rs.getString("CATEGORIA"));

                // ORDEN puede ser null
                Object ord = rs.getObject("ORDEN");
                m.setOrden(ord == null ? null : ((Number) ord).intValue());

                lista.add(m);
            }
        }
        return lista;
    }

    public ResultadoSP insertar(Modulo m) throws SQLException {
        // recomendado: insertar con metadata (ruta+titulo+icono+categoria+orden)
        String sql = "{CALL GUIA.SP_MODULOS_INSERTAR(?,?,?,?,?,?)}";

        try (Connection cn = new ConexionSQLServer().getConnection();
             CallableStatement cs = cn.prepareCall(sql)) {

            cs.setString(1, m.getRuta());
            cs.setString(2, m.getTitulo());
            cs.setString(3, m.getDescripcion());
            cs.setString(4, m.getIcono());
            cs.setString(5, m.getCategoria());
            cs.setInt(6, m.getOrden());

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

    public ResultadoSP actualizar(Modulo m) throws SQLException {
        // recomendado: actualizar todo
        String sql = "{CALL GUIA.SP_MODULOS_ACTUALIZAR(?,?,?,?,?,?,?)}";

        try (Connection cn = new ConexionSQLServer().getConnection();
             CallableStatement cs = cn.prepareCall(sql)) {

            cs.setInt(1, m.getIdModulo());
            cs.setString(2, m.getRuta());
            cs.setString(3, m.getTitulo());
            cs.setString(4, m.getDescripcion());
            cs.setString(5, m.getIcono());
            cs.setString(6, m.getCategoria());
            cs.setInt(7, m.getOrden());

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
    
}