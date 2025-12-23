package dao;

import configDB.ConexionSQLServer;
import modelos.reportes.RptUsuario;

import java.sql.Connection;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class RptUsuarioDAO {

    /**
     * Lista incidencias por usuario, tipo y rango de fechas (opcionales)
     *
     * @param idUsuario ID del usuario
     * @param tipo 1=Devoluciones, 2=Donaciones, 3=Excesos
     * @param desde Fecha desde (puede ser null)
     * @param hasta Fecha hasta (puede ser null)
     * @return Lista de incidencias
     */
    public List<RptUsuario> listarPorUsuarioYTipoFecha(int idUsuario, int tipo, Date desde, Date hasta) {

        List<RptUsuario> lista = new ArrayList<>();
        String sql = "{CALL REPORTES.SP_LISTAR_INCIDENCIAS_POR_USUARIO(?, ?, ?, ?)}";

        ConexionSQLServer conexion = new ConexionSQLServer();

        try (
                Connection cn = conexion.getConnection(); CallableStatement cs = cn.prepareCall(sql)) {

            cs.setInt(1, idUsuario);
            cs.setInt(2, tipo);

            // ✅ Parámetros opcionales de fechas
            if (desde != null) {
                cs.setDate(3, desde);
            } else {
                cs.setNull(3, Types.DATE);
            }

            if (hasta != null) {
                cs.setDate(4, hasta);
            } else {
                cs.setNull(4, Types.DATE);
            }

            try (ResultSet rs = cs.executeQuery()) {

                while (rs.next()) {
                    RptUsuario r = new RptUsuario();

                    r.setDoc_material(rs.getString("DOC_MATERIAL"));
                    r.setCodigo_sap(rs.getString("CODIGO_SAP"));
                    r.setProducto(rs.getString("PRODUCTO"));
                    r.setId_usuario(rs.getInt("ID_USUARIO"));

                    r.setEnviado(rs.getInt("ENVIADO"));
                    r.setRecibido(rs.getInt("RECIBIDO"));

                    r.setFarmacia(rs.getString("FARMACIA"));
                    r.setIncidencia(rs.getString("INCIDENCIA"));
                    r.setObservacion(rs.getString("OBSERVACION"));
                    r.setFecha_scan(rs.getDate("FECHA_SCAN"));

                    r.setTipo(tipo);

                    lista.add(r);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace(); // ✅ esto es clave
            System.err.println("❌ Error en listarPorUsuarioYTipoFecha: " + e.getMessage());
        }

        return lista;
    }

    /**
     * Método anterior (sin fechas) -> ahora llama al nuevo con null/null
     */
    public List<RptUsuario> listarPorUsuarioYTipo(int idUsuario, int tipo) {
        return listarPorUsuarioYTipoFecha(idUsuario, tipo, null, null);
    }
}
