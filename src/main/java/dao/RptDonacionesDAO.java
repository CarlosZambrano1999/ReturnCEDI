/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import configDB.ConexionSQLServer;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
import modelos.reportes.RptFarmaciasMayorIncidencia;
import modelos.reportes.RptGuiasMayorIncidencia;
import modelos.reportes.RptIncidenciasMasFrecuentes;
import modelos.reportes.RptProductividadDiaHoraUsuario;

/**
 *
 * @author Administrador
 */
public class RptDonacionesDAO {

    private final ConexionSQLServer conexion;

    public RptDonacionesDAO() {
        this.conexion = new ConexionSQLServer();
    }

    // 1) Productividad por día/hora/usuario (con nombre)
public List<RptProductividadDiaHoraUsuario> rptProductividadDiaHora(
        Date desde, Date hasta, Integer horaMin, Integer horaMax, Integer idUsuario) {

    List<RptProductividadDiaHoraUsuario> lista = new ArrayList<>();
    String sql = "{CALL DONACIONES.SP_RPT_PRODUCTIVIDAD_DIA_HORA_USUARIO(?,?,?,?,?)}";

    try (Connection con = conexion.getConnection();
         CallableStatement cs = con.prepareCall(sql)) {

        cs.setDate(1, desde);
        cs.setDate(2, hasta);

        cs.setInt(3, horaMin == null ? 0 : horaMin);
        cs.setInt(4, horaMax == null ? 23 : horaMax);

        if (idUsuario == null) cs.setNull(5, Types.INTEGER);
        else cs.setInt(5, idUsuario);

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
        String sql = "{CALL DONACIONES.SP_RPT_GUIAS_MAYOR_INCIDENCIA(?,?,?)}";

        try (Connection con = conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {

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
        String sql = "{CALL DONACIONES.SP_RPT_FARMACIAS_MAYOR_INCIDENCIA(?,?,?)}";

        try (Connection con = conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {

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
        String sql = "{CALL DONACIONES.SP_RPT_INCIDENCIAS_MAS_FRECUENTES(?,?,?)}";

        try (Connection con = conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {

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
}
