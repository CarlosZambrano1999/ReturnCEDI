package dao;

import configDB.ConexionSQLServer;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import modelos.Incidencia;

public class IncidenciaDAO {

    private ConexionSQLServer conexion = new ConexionSQLServer();

    public List<Incidencia> listarIncidencias() {
        List<Incidencia> lista = new ArrayList<>();

        String sql = "SELECT ID_INCIDENCIA, INCIDENCIA, ESTADO " +
                     "FROM GUIA.VW_LISTAR_INCIDENCIAS";

        try (Connection con = conexion.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Incidencia incidencia = new Incidencia();
                incidencia.setId_incidencia(rs.getInt("ID_INCIDENCIA"));
                incidencia.setIncidencia(rs.getString("INCIDENCIA"));
                incidencia.setEstado(rs.getInt("ESTADO"));
                lista.add(incidencia);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * Ejecuta acciones con un solo SP:
     * ACCION: INSERTAR | EDITAR | ACTIVAR | INACTIVAR
     * - INSERTAR: requiere incidencia (id puede ir null)
     * - EDITAR: requiere id + incidencia
     * - ACTIVAR/INACTIVAR: requiere id (incidencia puede ir null)
     */
    public boolean ejecutarAccion(String accion, Integer idIncidencia, String incidencia) {

        String sql = "{CALL GUIA.SP_GUIA_INCIDENCIAS_CRUD(?, ?, ?)}";

        try (Connection con = conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setString(1, accion);

            if (idIncidencia == null) {
                cs.setNull(2, java.sql.Types.INTEGER);
            } else {
                cs.setInt(2, idIncidencia);
            }

            if (incidencia == null) {
                cs.setNull(3, java.sql.Types.NVARCHAR);
            } else {
                cs.setString(3, incidencia);
            }

            // El SP retorna un SELECT con status/message/id_incidencia
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    String status = rs.getString("status"); // success | error
                    // String message = rs.getString("message");
                    // int id = rs.getInt("id_incidencia");

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
