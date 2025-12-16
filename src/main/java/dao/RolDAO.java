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
}
