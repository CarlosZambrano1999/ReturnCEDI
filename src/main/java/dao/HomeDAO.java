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
import modelos.Modulo;

/**
 *
 * @author Administrador
 */
public class HomeDAO {

    public List<Modulo> obtenerModulosHome(int idRol) throws SQLException {
        List<Modulo> list = new ArrayList<>();
        String sql = "{CALL GUIA.SP_HOME_MODULOS_POR_ROL(?)}";

        try (Connection cn = new ConexionSQLServer().getConnection();
             CallableStatement cs = cn.prepareCall(sql)) {

            cs.setInt(1, idRol);

            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    Modulo m = new Modulo();
                    m.setIdModulo(rs.getInt("ID_MODULO"));
                    m.setRuta(rs.getString("MODULO"));
                    m.setTitulo(rs.getString("TITULO"));
                    m.setDescripcion(rs.getString("DESCRIPCION"));
                    m.setIcono(rs.getString("ICONO"));
                    m.setCategoria(rs.getString("CATEGORIA"));
                    m.setOrden(rs.getInt("ORDEN"));
                    list.add(m);
                }
            }
        }
        return list;
    }
}
