package dao;

import configDB.ConexionSQLServer;
import modelos.reportes.Guias;

import java.sql.Connection;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GuiasDAO {

    public List<Guias> listarGuias(int idUsuario, int rol, Date desde, Date hasta) {

        List<Guias> lista = new ArrayList<>();
        String sql = "{CALL GUIA.SP_LISTAR_GUIAS(?, ?, ?, ?)}";

        ConexionSQLServer conexion = new ConexionSQLServer();

        try (
                Connection cn = conexion.getConnection(); CallableStatement cs = cn.prepareCall(sql)) {

            cs.setInt(1, idUsuario);
            cs.setInt(2, rol);

            // Fechas opcionales
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
                    Guias g = new Guias();

                    g.setId_usuario(rs.getInt("id_usuario"));
                    g.setNombre(rs.getString("nombre"));
                    g.setDoc_material(rs.getString("DOC_MATERIAL"));
                    g.setFecha_cierre(rs.getDate("FECHA_CIERRE"));
                    g.setTipo(rs.getString("TIPO"));

                    lista.add(g);
                }
            }

        } catch (SQLException e) {
            System.err.println("❌ Error en GuiasDAO.listarGuias: " + e.getMessage());
        }

        return lista;
    }

    /**
     * Método de compatibilidad sin fechas (trae todo según el rol)
     */
    public List<Guias> listarGuias(int idUsuario, int rol) {
        return listarGuias(idUsuario, rol, null, null);
    }

    public Map<String, String> reaperturarDocMaterial(String docMaterial, int idUsuario) {

        Map<String, String> resultado = new HashMap<>();
        String sql = "{CALL GUIA.SP_GUIA_REAPERTURAR_DOC_MATERIAL(?, ?)}";

        ConexionSQLServer conexion = new ConexionSQLServer();

        try (
                Connection cn = conexion.getConnection(); CallableStatement cs = cn.prepareCall(sql)) {

            cs.setString(1, docMaterial);
            cs.setInt(2, idUsuario);

            boolean hasResult = cs.execute();

            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) {
                        resultado.put("status", rs.getString("status"));
                        resultado.put("message", rs.getString("message"));
                        return resultado;
                    }
                }
            }

            // Si por alguna razón no vino resultado
            resultado.put("status", "error");
            resultado.put("message", "No se recibió respuesta del procedimiento.");
            return resultado;

        } catch (SQLException e) {
            System.err.println("❌ Error en GuiasDAO.reaperturarDocMaterial: " + e.getMessage());
            resultado.put("status", "error");
            resultado.put("message", e.getMessage());
            return resultado;
        }
    }

}
