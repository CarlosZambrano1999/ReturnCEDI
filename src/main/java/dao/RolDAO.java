package dao;

import configDB.ConexionSQLServer;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import modelos.Rol;

public class RolDAO {

    public List<Rol> listarActivos() throws SQLException {
        List<Rol> lista = new ArrayList<>();
        String sql = "{CALL PERSONA.SP_OBTENER_ROLES_ACTIVOS()}";

        try (Connection cn = new ConexionSQLServer().getConnection();
             CallableStatement cs = cn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {

            while (rs.next()) {
                Rol r = new Rol();
                r.setId_rol(rs.getInt("id_rol"));
                r.setRol(rs.getString("rol"));
                r.setEstado(rs.getInt("estado"));
                lista.add(r);
            }
        }
        return lista;
    }
    
     public List<Rol> listar() throws SQLException {
        List<Rol> lista = new ArrayList<>();
        String sql = "{CALL PERSONA.SP_ROL_LISTAR}";

        try (Connection cn = new ConexionSQLServer().getConnection();
             CallableStatement cs = cn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {

            while (rs.next()) {
                Rol r = new Rol();
                r.setId_rol(rs.getInt("id_rol"));
                r.setRol(rs.getString("rol"));
                r.setEstado(rs.getInt("estado"));
                lista.add(r);
            }
        }
        return lista;
    }

    public ResultadoSP insertar(String rol) throws SQLException {
        String sql = "{CALL PERSONA.SP_ROL_INSERTAR(?)}";

        try (Connection cn = new ConexionSQLServer().getConnection();
             CallableStatement cs = cn.prepareCall(sql)) {

            cs.setString(1, rol);

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    return new ResultadoSP(rs.getString("status"), rs.getString("message"));
                }
            }
        }
        return new ResultadoSP("error", "No hubo respuesta del SP.");
    }

    public ResultadoSP cambiarEstado(int idRol, int estado) throws SQLException {
        String sql = "{CALL PERSONA.SP_ROL_CAMBIAR_ESTADO(?,?)}";

        try (Connection cn = new ConexionSQLServer().getConnection();
             CallableStatement cs = cn.prepareCall(sql)) {

            cs.setInt(1, idRol);
            cs.setInt(2, estado);

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
