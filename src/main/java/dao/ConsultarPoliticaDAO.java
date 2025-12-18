/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import configDB.ConexionSQLServer;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import modelos.ColorPolitica;
import modelos.PoliticaDevolucion;
import modelos.Producto;
import modelos.ProveedorPolitica;

/**
 *
 * @author Administrador
 */
public class ConsultarPoliticaDAO {
    private final ConexionSQLServer conexion;

    public ConsultarPoliticaDAO() {
        this.conexion = new ConexionSQLServer();
    }

   
    public Producto buscarProducto(String codigo) {
        String sql = "{CALL dbo.SP_BUSCAR_PRODUCTO(?)}";

        try (Connection con = conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setString(1, codigo);

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    Producto p = new Producto();
                    p.setCodigo(rs.getString("CODIGO"));
                    p.setProducto(rs.getString("PRODUCTO"));
                    p.setIdLaboratorio(rs.getString("ID_LABORATORIO"));
                    p.setLaboratorio(rs.getString("LABORATORIO"));
                    p.setPactivo(rs.getString("PACTIVO"));
                    p.setCodigoSap(rs.getString("CODIGO_SAP"));
                    p.setPresentacion(rs.getString("PRESENTACION"));
                    p.setFactor(rs.getBigDecimal("FACTOR"));
                    p.setSegmento(rs.getString("SEGMENTO"));
                    return p;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    public List<ProveedorPolitica> listarProveedoresPorLaboratorio(String idLaboratorio) {
        List<ProveedorPolitica> lista = new ArrayList<>();
        String sql = "{CALL POLITICA.SP_LISTAR_PROVEEDORES_POR_LAB_EXT(?)}";

        try (Connection con = conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setString(1, idLaboratorio);

            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    ProveedorPolitica p = new ProveedorPolitica();
                    p.setIdProveedor(rs.getString("id_proveedor"));
                    p.setProveedorNombre(rs.getString("proveedor_nombre"));
                    lista.add(p);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * 3) Listar colores disponibles para laboratorio + proveedor.
     * Llama wrapper en ReturnCEDIDB que consulta DevolCEDIDB.
     */
    public List<ColorPolitica> listarColoresPorLabProveedor(String idLaboratorio, String idProveedor) {
        List<ColorPolitica> lista = new ArrayList<>();
        String sql = "{CALL POLITICA.SP_LISTAR_COLORES_POR_LAB_PROV_EXT(?, ?)}";

        try (Connection con = conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setString(1, idLaboratorio);
            cs.setString(2, idProveedor);

            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    ColorPolitica c = new ColorPolitica();
                    c.setIdColor(rs.getInt("id_color"));
                    c.setColor(rs.getString("color"));
                    lista.add(c);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return lista;
    }

    /**
     * 4) Consultar política (laboratorio + proveedor + color).
     * Llama wrapper en ReturnCEDIDB que ejecuta el SP real de DevolCEDIDB.
     */
    public PoliticaDevolucion consultarPolitica(String idLaboratorio, String idProveedor, int idColor) {
        String sql = "{CALL POLITICA.SP_CONSULTAR_POLITICA_EXT(?, ?, ?)}";

        try (Connection con = conexion.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {

            cs.setString(1, idLaboratorio);
            cs.setString(2, idProveedor);
            cs.setInt(3, idColor);

            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    PoliticaDevolucion pol = new PoliticaDevolucion();
                    pol.setIdPolitica(rs.getLong("id_politica"));
                    pol.setTiempo(rs.getInt("tiempo"));
                    pol.setFracciones(rs.getInt("fracciones"));
                    pol.setObservaciones(rs.getString("observaciones"));
                    pol.setEstado(rs.getInt("estado"));
                    return pol;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }
}
