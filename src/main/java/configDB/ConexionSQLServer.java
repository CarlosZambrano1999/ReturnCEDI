/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package configDB;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author arlom
 */
public class ConexionSQLServer {
 
    private static final String HOST = getenvOrDefault("DB_SQL_HOST", "192.168.50.54");
    private static final String PORT = getenvOrDefault("DB_SQL_PORT", "1433");
    private static final String DB   = getenvOrDefault("DB_SQL_NAME", "ReturnCEDIDB");
    private static final String USER = getenvOrDefault("DB_SQL_USER", "sa");
    private static final String PASS = getenvOrDefault("DB_SQL_PASS", "sa$2000");
 
    private static final String URL  = String.format(
            "jdbc:sqlserver://%s:%s;databaseName=%s;encrypt=true;trustServerCertificate=true;",
            HOST, PORT, DB
    );
 
    static {
        try {
            // Cargar driver JDBC (opcional en Java moderno si está en el classpath)
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            // Si no está el driver en el classpath, esto te lo hará evidente.
            throw new RuntimeException("No se encontró el driver JDBC de SQL Server. Agrega mssql-jdbc a tu proyecto.", e);
        }
    }
 
    public Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }
 
    private static String getenvOrDefault(String key, String def) {
        String v = System.getenv(key);
        return (v == null || v.isEmpty()) ? def : v;
    }
}