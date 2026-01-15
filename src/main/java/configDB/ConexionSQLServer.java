/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package configDB;

import io.github.cdimascio.dotenv.Dotenv;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author arlom
 */
public class ConexionSQLServer {
 
    private static final Dotenv dotenv = Dotenv.configure()
            .filename(".env")          // obligatorio leer .env
            .ignoreIfMissing()         // <-- QUÍTALO si quieres que falle cuando no exista
            .load();

    private static final String HOST = required("DB_SQL_HOST");
    private static final String PORT = required("DB_SQL_PORT");
    private static final String DB   = required("DB_SQL_NAME");
    private static final String USER = required("DB_SQL_USER");
    private static final String PASS = required("DB_SQL_PASS");

    private static final String ENCRYPT = optional("DB_SQL_ENCRYPT", "true");
    private static final String TRUST   = optional("DB_SQL_TRUST_CERT", "true");

    private static final String URL = String.format(
            "jdbc:sqlserver://%s:%s;databaseName=%s;encrypt=%s;trustServerCertificate=%s;",
            HOST, PORT, DB, ENCRYPT, TRUST
    );

    static {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("No se encontró el driver JDBC de SQL Server. Agrega mssql-jdbc al proyecto.", e);
        }
    }

    public Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }

    private static String required(String key) {
        String value = dotenv.get(key);
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalStateException("Falta la variable obligatoria en .env: " + key);
        }
        return value.trim();
    }

    private static String optional(String key, String def) {
        String value = dotenv.get(key);
        return (value == null || value.trim().isEmpty()) ? def : value.trim();
    }
}