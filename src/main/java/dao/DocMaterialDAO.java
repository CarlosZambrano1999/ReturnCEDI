/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import com.microsoft.sqlserver.jdbc.SQLServerCallableStatement;
import com.microsoft.sqlserver.jdbc.SQLServerDataTable;
import com.microsoft.sqlserver.jdbc.SQLServerException;
import configDB.ConexionSQLServer;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.List;
import modelos.DatosDocMaterial;
import modelos.InfoDocMaterial;
import modelos.ResultadoCargaDocMaterial;

/**
 *
 * @author Administrador
 */
public class DocMaterialDAO {
    private final ConexionSQLServer conexion;

    public DocMaterialDAO() {
        this.conexion = new ConexionSQLServer();
    }

    public ResultadoCargaDocMaterial cargarDocMaterialExcel(long docMaterial, List<DatosDocMaterial> detalle) throws SQLServerException {

        ResultadoCargaDocMaterial resp = new ResultadoCargaDocMaterial();

        // Armamos el TVP exactamente como el TYPE: GUIA.TVP_DATOS_DOC_MATERIAL
        SQLServerDataTable tvp = new SQLServerDataTable();
        try {
            tvp.addColumnMetadata("CODIGO_SAP", Types.NVARCHAR);
            tvp.addColumnMetadata("DESCRIPCION", Types.NVARCHAR);
            tvp.addColumnMetadata("CENTRO", Types.NVARCHAR);
            tvp.addColumnMetadata("ALMACEN", Types.NVARCHAR);
            tvp.addColumnMetadata("TRANSITO", Types.INTEGER);
            tvp.addColumnMetadata("POSICION", Types.INTEGER);
            tvp.addColumnMetadata("REFERENCIA", Types.NVARCHAR);
            tvp.addColumnMetadata("TEXTO", Types.NVARCHAR);
            tvp.addColumnMetadata("HORA", Types.TIME);
            tvp.addColumnMetadata("USUARIO", Types.NVARCHAR);
            tvp.addColumnMetadata("FECHA_DOCUMENTO", Types.DATE);
            tvp.addColumnMetadata("FECHA_CONTABLE", Types.DATE);
            tvp.addColumnMetadata("CANTIDAD", Types.DECIMAL);
            tvp.addColumnMetadata("IMPORTE", Types.DECIMAL);

            if (detalle != null) {
                for (DatosDocMaterial d : detalle) {
                    tvp.addRow(
                            d.getCodigoSap(),
                            d.getDescripcion(),
                            d.getCentro(),
                            d.getAlmacen(),
                            d.getTransito(),
                            d.getPosicion(),
                            d.getReferencia(),
                            d.getTexto(),
                            d.getHora(),
                            d.getUsuario(),
                            d.getFechaDocumento(),
                            d.getFechaContable(),
                            d.getCantidad(),
                            d.getImporte()
                    );
                }
            }

        } catch (SQLException e) {
            resp.setStatus("error");
            resp.setErrorMessage("Error creando TVP: " + e.getMessage());
            return resp;
        }

        String sql = "{CALL GUIA.SP_GUIA_CARGAR_DOC_MATERIAL_EXCEL(?, ?, ?)}";

        try (Connection cn = conexion.getConnection();
             SQLServerCallableStatement cs = (SQLServerCallableStatement) cn.prepareCall(sql)) {

            cs.setLong(1, docMaterial);
            cs.setInt(2, 1); // Estado = 1 (según lo requerido)

            // Enviar TVP (Structured Parameter)
            cs.setStructured(3, "GUIA.TVP_DATOS_DOC_MATERIAL", tvp);

            boolean hasResult = cs.execute();

            if (hasResult) {
                try (ResultSet rs = cs.getResultSet()) {
                    if (rs.next()) {
                        resp.setStatus(rs.getString("status"));

                        // Si success
                        if ("success".equalsIgnoreCase(resp.getStatus())) {
                            resp.setDocMaterial(rs.getLong("docMaterial"));
                            resp.setFilasInsertadas(rs.getInt("filasInsertadas"));
                        } else {
                            // Si error (por CATCH del SP)
                            resp.setErrorNumber(rs.getInt("errorNumber"));
                            resp.setErrorMessage(rs.getString("errorMessage"));
                        }
                    } else {
                        resp.setStatus("error");
                        resp.setErrorMessage("El SP no retornó respuesta.");
                    }
                }
            } else {
                resp.setStatus("error");
                resp.setErrorMessage("El SP no retornó ResultSet (verificar SELECT final del SP).");
            }

        } catch (SQLException e) {
            resp.setStatus("error");
            resp.setErrorMessage("SQLException DAO: " + e.getMessage());
        }

        return resp;
    }
    
     public InfoDocMaterial obtenerInfoDocMaterial(long docMaterial) {
        InfoDocMaterial info = null;

        String sql = "{CALL GUIA.SP_GUIA_OBTENER_INFO_DOC_MATERIAL(?)}";

        try (Connection con = conexion.getConnection(); CallableStatement cs = con.prepareCall(sql)) {

            cs.setLong(1, docMaterial);

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    info = new InfoDocMaterial();
                    info.setAlmacen(rs.getString("ALMACEN"));
                    info.setDepartamento(rs.getString("DEPARTAMENTO"));
                    info.setFarmacia(rs.getString("FARMACIA"));
                    info.setEstado(rs.getInt("ESTADO"));
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return info;
    }
}