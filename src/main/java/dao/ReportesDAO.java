/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import configDB.ConexionSQLServer;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import modelos.reportes.ReporteDevolucionUnificada;
import modelos.reportes.RptFarmaciasMayorIncidencia;
import modelos.reportes.RptGuiasMayorIncidencia;
import modelos.reportes.RptIncidenciasMasFrecuentes;
import modelos.reportes.RptProductividadDiaHoraUsuario;

/**
 *
 * @author Administrador
 */
public class ReportesDAO {

    private final ConexionSQLServer conexion;

    public ReportesDAO() {
        this.conexion = new ConexionSQLServer();
    }

    // 1) Productividad por día/hora/usuario (con nombre)
    public List<RptProductividadDiaHoraUsuario> rptProductividadDiaHora(
            Date desde, Date hasta, Integer horaMin, Integer horaMax, Integer idUsuario) {

        List<RptProductividadDiaHoraUsuario> lista = new ArrayList<>();
        String sql = "{CALL GUIA.SP_RPT_PRODUCTIVIDAD_DIA_HORA_USUARIO(?,?,?,?,?)}";

        try (Connection con = conexion.getConnection(); CallableStatement cs = con.prepareCall(sql)) {

            cs.setDate(1, desde);
            cs.setDate(2, hasta);

            cs.setInt(3, horaMin == null ? 0 : horaMin);
            cs.setInt(4, horaMax == null ? 23 : horaMax);

            if (idUsuario == null) {
                cs.setNull(5, Types.INTEGER);
            } else {
                cs.setInt(5, idUsuario);
            }

            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    RptProductividadDiaHoraUsuario r = new RptProductividadDiaHoraUsuario();
                    r.setFecha(rs.getDate("FECHA"));
                    r.setHora(rs.getInt("HORA"));
                    r.setIdUsuario(rs.getInt("ID_USUARIO"));
                    r.setNombre(rs.getString("NOMBRE"));

                    r.setTotalEscaneos(rs.getInt("TOTAL_ESCANEOS"));
                    r.setTotalCantidad(rs.getInt("TOTAL_CANTIDAD"));

                    r.setConIncidencia(rs.getInt("CON_INCIDENCIA"));
                    r.setSinIncidencia(rs.getInt("SIN_INCIDENCIA"));
                    lista.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    // 2) Guías con mayor incidencia
    public List<RptGuiasMayorIncidencia> rptGuiasMayorIncidencia(Date desde, Date hasta, int top) {
        List<RptGuiasMayorIncidencia> lista = new ArrayList<>();
        String sql = "{CALL GUIA.SP_RPT_GUIAS_MAYOR_INCIDENCIA(?,?,?)}";

        try (Connection con = conexion.getConnection(); CallableStatement cs = con.prepareCall(sql)) {

            cs.setDate(1, desde);
            cs.setDate(2, hasta);
            cs.setInt(3, top);

            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    RptGuiasMayorIncidencia r = new RptGuiasMayorIncidencia();
                    r.setDocMaterial(rs.getLong("DOC_MATERIAL"));
                    r.setTotalRegistros(rs.getInt("TOTAL_REGISTROS"));
                    r.setTotalIncidencias(rs.getInt("TOTAL_INCIDENCIAS"));
                    r.setPorcIncidencia(rs.getBigDecimal("PORC_INCIDENCIA"));
                    lista.add(r);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    // 3) Farmacias con mayor incidencias
    public List<RptFarmaciasMayorIncidencia> rptFarmaciasMayorIncidencia(Date desde, Date hasta, int top) {
        List<RptFarmaciasMayorIncidencia> lista = new ArrayList<>();
        String sql = "{CALL GUIA.SP_RPT_FARMACIAS_MAYOR_INCIDENCIA(?,?,?)}";

        try (Connection con = conexion.getConnection(); CallableStatement cs = con.prepareCall(sql)) {

            cs.setDate(1, desde);
            cs.setDate(2, hasta);
            cs.setInt(3, top);

            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    RptFarmaciasMayorIncidencia r = new RptFarmaciasMayorIncidencia();
                    r.setFarmacia(rs.getString("FARMACIA"));
                    r.setTotalRegistros(rs.getInt("TOTAL_REGISTROS"));
                    r.setTotalIncidencias(rs.getInt("TOTAL_INCIDENCIAS"));
                    lista.add(r);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    // 4) Incidencia más frecuente
    public List<RptIncidenciasMasFrecuentes> rptIncidenciasMasFrecuentes(Date desde, Date hasta, int top) {
        List<RptIncidenciasMasFrecuentes> lista = new ArrayList<>();
        String sql = "{CALL GUIA.SP_RPT_INCIDENCIAS_MAS_FRECUENTES(?,?,?)}";

        try (Connection con = conexion.getConnection(); CallableStatement cs = con.prepareCall(sql)) {

            cs.setDate(1, desde);
            cs.setDate(2, hasta);
            cs.setInt(3, top);

            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    RptIncidenciasMasFrecuentes r = new RptIncidenciasMasFrecuentes();
                    r.setIncidenciaId(rs.getInt("INCIDENCIA_ID"));
                    r.setIncidencia(rs.getString("INCIDENCIA"));
                    r.setTotal(rs.getInt("TOTAL"));
                    lista.add(r);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    public List<ReporteDevolucionUnificada> rptDevolucionesUnificadas(
            Date fechaInicial,
            Date fechaFinal,
            String farmacias,
            String tipoEnvio,
            String laboratorios
    ) {

        List<ReporteDevolucionUnificada> lista = new ArrayList<>();
        String sql = "{CALL GUIA.SP_REPORTE_UNIFICADAS(?,?,?,?,?)}";

        try (Connection con = conexion.getConnection(); CallableStatement cs = con.prepareCall(sql)) {

            if (fechaInicial == null) {
                cs.setNull(1, Types.DATE);
            } else {
                cs.setDate(1, fechaInicial);
            }

            if (fechaFinal == null) {
                cs.setNull(2, Types.DATE);
            } else {
                cs.setDate(2, fechaFinal);
            }

            if (farmacias == null || farmacias.trim().isEmpty()) {
                cs.setNull(3, Types.NVARCHAR);
            } else {
                cs.setString(3, farmacias);
            }

            if (tipoEnvio == null || tipoEnvio.trim().isEmpty()) {
                cs.setNull(4, Types.NVARCHAR);
            } else {
                cs.setString(4, tipoEnvio);
            }

            if (laboratorios == null || laboratorios.trim().isEmpty()) {
                cs.setNull(5, Types.NVARCHAR);
            } else {
                cs.setString(5, laboratorios.trim());
            }

            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    ReporteDevolucionUnificada r = new ReporteDevolucionUnificada();

                    r.setCodigoSap(rs.getString("CODIGO_SAP"));
                    r.setCodigo(rs.getString("CODIGO"));
                    r.setProducto(rs.getString("PRODUCTO"));
                    r.setEnviado(rs.getInt("ENVIADO"));
                    r.setRecibido(rs.getInt("RECIBIDO"));
                    r.setFarmacia(rs.getString("FARMACIA"));

                    // Recomendado: cambiar el alias en SQL a TIPO_ENVIO para evitar problemas con tildes.
                    r.setTipoEnvio(rs.getString("TIPO ENVIO"));

                    r.setDepartamento(rs.getString("DEPARTAMENTO"));

                    // Si tu setter está escrito así en el modelo, mantenlo.
                    r.setLabortaorio(rs.getString("LABORATORIO"));

                    r.setFactor(rs.getInt("FACTOR"));
                    r.setCategoria(rs.getString("CATEGORIA"));
                    r.setSubcategoria(rs.getString("SUBCATEGORIA"));
                    r.setSegmento(rs.getString("SEGMENTO"));
                    r.setIncidencia(rs.getString("INCIDENCIA"));
                    r.setObservacion(rs.getString("OBSERVACION"));
                    r.setFechaScan(rs.getTimestamp("FECHA_SCAN"));

                    lista.add(r);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    public List<String> listarLaboratorios() {

        List<String> laboratorios = new ArrayList<>();

        String sql = " SELECT DISTINCT LABORATORIO FROM VW_LISTAR_PRODUCTOS_DZ WHERE LABORATORIO IS NOT NULL AND LTRIM(RTRIM(LABORATORIO)) <> '' ORDER BY LABORATORIO";

        try (Connection con = conexion.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                laboratorios.add(rs.getString("LABORATORIO"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return laboratorios;
    }
}
