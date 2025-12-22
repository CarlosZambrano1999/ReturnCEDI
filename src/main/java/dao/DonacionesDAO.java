/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import configDB.ConexionSQLServer;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import modelos.ComparativoDocMaterialRow;
import modelos.Devoluciones;
import modelos.ResultadoOperacion;

/**
 *
 * @author Administrador
 */
public class DonacionesDAO {

    private final ConexionSQLServer conexion;

    public DonacionesDAO() {
        this.conexion = new ConexionSQLServer();
    }


    public ResultadoOperacion registrarEscaneo(long docMaterial, String codigoInput, int idUsuario, double cantidad) {
        ResultadoOperacion resp = new ResultadoOperacion();

        String sql = "{CALL DONACIONES.SP_REGISTRAR_ESCANEO(?, ?, ?, ?)}";

        try (Connection cn = conexion.getConnection(); CallableStatement cs = cn.prepareCall(sql)) {

            cs.setLong(1, docMaterial);
            cs.setString(2, codigoInput);
            cs.setInt(3, idUsuario);
            cs.setBigDecimal(4, new java.math.BigDecimal(String.valueOf(cantidad)));

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    String status = rs.getString("status");
                    resp.setStatus(status);

                    // success/not_found/error
                    if ("success".equalsIgnoreCase(status)) {
                        // Podemos devolver mensaje amigable opcional
                        resp.setMessage("Escaneo registrado: " + safe(rs.getString("codigoSap")));
                    } else {
                        resp.setMessage(rs.getString("message"));
                    }
                } else {
                    resp.setStatus("error");
                    resp.setMessage("El SP no devolvió respuesta.");
                }
            }

        } catch (SQLException e) {
            resp.setStatus("error");
            resp.setMessage("SQLException: " + e.getMessage());
        }

        return resp;
    }


    public List<ComparativoDocMaterialRow> obtenerComparativoExt(long docMaterial, int idUsuario) {
        List<ComparativoDocMaterialRow> lista = new ArrayList<>();
        String sql = "{CALL DONACIONES.SP_COMPARATIVO_DOC_MATERIAL_EXT(?, ?)}";

        try (Connection cn = conexion.getConnection(); CallableStatement cs = cn.prepareCall(sql)) {

            cs.setLong(1, docMaterial);
            cs.setInt(2, idUsuario);

            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    ComparativoDocMaterialRow r = new ComparativoDocMaterialRow();
                    r.setCodigoSap(rs.getString("CODIGO_SAP"));
                    r.setDescripcion(rs.getString("DESCRIPCION"));
                    r.setCantidadEsperada(rs.getBigDecimal("CANTIDAD_ESPERADA"));
                    r.setCantidadEscaneada(rs.getBigDecimal("CANTIDAD_ESCANEADA"));
                    r.setDiferencia(rs.getBigDecimal("DIFERENCIA"));
                    r.setEstado(rs.getString("ESTADO"));
                    r.setFactor(rs.getInt("FACTOR"));
                    r.setPresentacion(rs.getString("PRESENTACION"));

                    long idDev = rs.getLong("ID_DEVOLUCION");
                    r.setIdDevolucion(rs.wasNull() ? null : idDev);

                    r.setCantidadEditable(rs.getBigDecimal("CANTIDAD_EDITABLE"));

                    int inc = rs.getInt("INCIDENCIA_ID");
                    r.setIncidenciaId(rs.wasNull() ? null : inc);

                    r.setObservacion(rs.getString("OBSERVACION"));

                    lista.add(r);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * 4) Edita un registro de GUIA.DEVOLUCIONES (cantidad, incidencia,
     * observación)
     */
    public ResultadoOperacion editarDonacion(long id, double cantidad, Integer incidenciaId, String observacion) {
        ResultadoOperacion resp = new ResultadoOperacion();

        String sql = "{CALL DONACIONES.SP_EDITAR_ESCANEO(?, ?, ?, ?)}";

        try (Connection cn = conexion.getConnection(); CallableStatement cs = cn.prepareCall(sql)) {

            cs.setLong(1, id);
            cs.setBigDecimal(2, new java.math.BigDecimal(String.valueOf(cantidad)));

            if (incidenciaId == null) {
                cs.setNull(3, Types.INTEGER);
            } else {
                cs.setInt(3, incidenciaId);
            }

            if (observacion == null || observacion.trim().isEmpty()) {
                cs.setNull(4, Types.NVARCHAR);
            } else {
                cs.setString(4, observacion.trim());
            }

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    resp.setStatus(rs.getString("status"));
                    resp.setMessage(rs.getString("message"));
                } else {
                    resp.setStatus("error");
                    resp.setMessage("El SP no devolvió respuesta.");
                }
            }

        } catch (SQLException e) {
            resp.setStatus("error");
            resp.setMessage("SQLException: " + e.getMessage());
        }

        return resp;
    }

    public Devoluciones obtenerDonacionPorSap(long docMaterial, String codigoSap, int idUsuario) {
        String sql = "SELECT TOP 1 ID, DOC_MATERIAL, CODIGO_SAP, CANTIDAD, INCIDENCIA_ID, OBSERVACION "
                + "FROM DONACIONES.TBL_DONACIONES "
                + "WHERE DOC_MATERIAL = ? AND CODIGO_SAP = ? AND ID_USUARIO = ? "
                + "ORDER BY FECHA_SCAN DESC";

        try (Connection cn = conexion.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setLong(1, docMaterial);
            ps.setString(2, codigoSap);
            ps.setInt(3, idUsuario);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Devoluciones d = new Devoluciones();
                    d.setId(rs.getLong("ID"));
                    d.setDocMaterial(rs.getLong("DOC_MATERIAL"));
                    d.setCodigoSap(rs.getString("CODIGO_SAP"));
                    d.setCantidad(rs.getBigDecimal("CANTIDAD"));
                    int inc = rs.getInt("INCIDENCIA_ID");
                    d.setIncidenciaId(rs.wasNull() ? null : inc);
                    d.setObservacion(rs.getString("OBSERVACION"));
                    return d;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private String safe(String s) {
        return s == null ? "" : s;
    }

    public ResultadoOperacion eliminarDonacionAdicional(long id, long docMaterial, int idUsuario) {
        ResultadoOperacion resp = new ResultadoOperacion();
        String sql = "{CALL DONACIONES.SP_ELIMINAR_DEVOLUCION_ADICIONAL(?, ?, ?)}";

        try (Connection cn = conexion.getConnection(); CallableStatement cs = cn.prepareCall(sql)) {

            cs.setLong(1, id);
            cs.setLong(2, docMaterial);
            cs.setInt(3, idUsuario);

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    resp.setStatus(rs.getString("status"));
                    resp.setMessage(rs.getString("message"));
                } else {
                    resp.setStatus("error");
                    resp.setMessage("El SP no devolvió respuesta.");
                }
            }

        } catch (SQLException e) {
            resp.setStatus("error");
            resp.setMessage("SQLException: " + e.getMessage());
        }

        return resp;
    }

}
