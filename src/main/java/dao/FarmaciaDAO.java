package dao;

import configDB.ConexionSQLServer;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import modelos.Farmacia;

public class FarmaciaDAO {

    public List<Farmacia> listarFarmacias() throws SQLException {
        List<Farmacia> lista = new ArrayList<>();
        String sql = "{CALL PERSONA.SP_OBTENER_FARMACIAS()}";

        try (Connection cn = new ConexionSQLServer().getConnection();
             CallableStatement cs = cn.prepareCall(sql);
             ResultSet rs = cs.executeQuery()) {

            while (rs.next()) {
                Farmacia f = new Farmacia();
                f.setStoreId(rs.getString("STOREID"));
                f.setFarmacia(rs.getString("FARMACIA"));
                f.setCentro(rs.getString("CENTRO"));
                lista.add(f);
            }
        }
        return lista;
    }
}
