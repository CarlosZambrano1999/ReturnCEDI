package dao;

import configDB.ConexionSQLServer;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import modelos.Almacen;

public class AlmacenDAO {

    private ConexionSQLServer conexion = new ConexionSQLServer();

    public List<Almacen> listarAlmacenes() {
        List<Almacen> lista = new ArrayList<>();

        String sql = "SELECT CODIGO, DEPARTAMENTO, ESTADO FROM GUIA.VW_LISTAR_ALMACEN";

        try (Connection con = conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Almacen a = new Almacen();
                a.setCodigo(rs.getString("CODIGO"));
                a.setDepartamento(rs.getString("DEPARTAMENTO"));
                a.setEstado(rs.getInt("ESTADO"));
                lista.add(a);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }
    public boolean ejecutarAccion(String accion, String codigo, String departamento) {

    String sql = "{CALL GUIA.SP_GUIA_ALMACEN_CRUD(?, ?, ?)}";

    try (Connection con = conexion.getConnection();
         CallableStatement cs = con.prepareCall(sql)) {

        cs.setString(1, accion);

        if (codigo == null || codigo.trim().isEmpty()) {
            cs.setNull(2, java.sql.Types.NVARCHAR);
        } else {
            cs.setString(2, codigo.trim());
        }

        if (departamento == null || departamento.trim().isEmpty()) {
            cs.setNull(3, java.sql.Types.NVARCHAR);
        } else {
            cs.setString(3, departamento.trim());
        }

        // El SP retorna: status, message, codigo
        try (ResultSet rs = cs.executeQuery()) {
            if (rs.next()) {
                String status = rs.getString("status"); // success | error
                return "success".equalsIgnoreCase(status);
            }
        }

        return false;

    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}

}
