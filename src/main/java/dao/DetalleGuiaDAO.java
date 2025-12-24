package dao;

import configDB.ConexionSQLServer;
import modelos.reportes.DetalleGuia;

import java.sql.Connection;
import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DetalleGuiaDAO {

    /**
     * Trae el detalle de una guía según DOC_MATERIAL y TIPO
     * @param docMaterial Documento material (obligatorio)
     * @param tipo DEVOLUCIONES | DONACIONES | EXCESOS
     * @return lista de detalle
     */
    public List<DetalleGuia> listarDetallePorDocTipo(String docMaterial, String tipo) {

        List<DetalleGuia> lista = new ArrayList<>();
        String sql = "{CALL GUIA.SP_DETALLE_GUIA_POR_DOC_TIPO(?, ?)}";

        ConexionSQLServer conexion = new ConexionSQLServer();

        try (
            Connection cn = conexion.getConnection();
            CallableStatement cs = cn.prepareCall(sql)
        ) {

            cs.setString(1, docMaterial);
            cs.setString(2, tipo);

            try (ResultSet rs = cs.executeQuery()) {

                while (rs.next()) {
                    DetalleGuia d = new DetalleGuia();

                    d.setDoc_material(rs.getString("DOC_MATERIAL"));
                    d.setUsuario(rs.getString("USUARIO"));
                    d.setCodigo_sap(rs.getString("CODIGO_SAP"));
                    d.setCodigo(rs.getString("CODIGO"));
                    d.setProducto(rs.getString("PRODUCTO"));

                    d.setEnviado(rs.getInt("ENVIADO"));
                    d.setRecibido(rs.getInt("RECIBIDO"));

                    d.setFarmacia(rs.getString("FARMACIA"));
                    d.setIncidencia(rs.getString("INCIDENCIA"));
                    d.setObservacion(rs.getString("OBSERVACION"));
                    d.setFecha_scan(rs.getDate("FECHA_SCAN"));

                    lista.add(d);
                }
            }

        } catch (SQLException e) {
            System.err.println("❌ Error en DetalleGuiaDAO.listarDetallePorDocTipo: " + e.getMessage());
        }

        return lista;
    }
}
