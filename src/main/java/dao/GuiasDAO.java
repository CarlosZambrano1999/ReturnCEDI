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
import java.util.List;

public class GuiasDAO {

    /**
     * Lista guías según rol:
     * - Rol 1 o 2: retorna todas
     * - Otros roles: retorna solo las del usuario (idUsuario)
     *
     * @param idUsuario id del usuario en sesión
     * @param rol rol del usuario en sesión
     * @param desde filtro opcional (puede ser null)
     * @param hasta filtro opcional (puede ser null)
     * @return lista de guías
     */
    public List<Guias> listarGuias(int idUsuario, int rol, Date desde, Date hasta) {

        List<Guias> lista = new ArrayList<>();
        String sql = "{CALL GUIA.SP_LISTAR_GUIAS(?, ?, ?, ?)}";

        ConexionSQLServer conexion = new ConexionSQLServer();

        try (
            Connection cn = conexion.getConnection();
            CallableStatement cs = cn.prepareCall(sql)
        ) {

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
}
