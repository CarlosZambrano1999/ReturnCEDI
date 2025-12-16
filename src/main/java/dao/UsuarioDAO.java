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
import modelos.Usuario;

/**
 *
 * @author arlom
 */
public class UsuarioDAO {

    private ConexionSQLServer conexion;

    // Constructor que inicializa la conexión
    public UsuarioDAO() {
        conexion = new ConexionSQLServer();
    }

    public java.util.List<modelos.Usuario> listarUsuarios() throws SQLException {
        java.util.List<modelos.Usuario> lista = new java.util.ArrayList<>();

        String sql
                = "SELECT id_usuario, nombre, codigo, id_rol, FARMACIA, rol_nombre, estado"
                + "FROM PERSONA.VW_USUARIOS_LISTA "
                + "ORDER BY nombre ASC";

        try (Connection cn = conexion.getConnection(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                modelos.Usuario u = new modelos.Usuario();
                u.setIdUsuario(rs.getInt("id_usuario"));   // <- lo traemos para editar (en JSP lo ocultas)
                u.setNombre(rs.getString("nombre"));
                u.setCodigo(rs.getString("codigo"));
                u.setIdRol(rs.getInt("id_rol"));           // <- lo traemos para editar (en JSP lo ocultas si quieres)
                u.setRolNombre(rs.getString("rol_nombre"));
                u.setEstado(rs.getInt("estado"));// nombre del rol (para mostrar)

                lista.add(u);
            }
        }
        return lista;
    }

    public ResultadoRegistro registrarUsuarioSP(Usuario u, String plainPwd) {
        Connection cn = null;
        CallableStatement cs = null;
        ResultSet rs = null;

        if (u == null || u.getNombre() == null || u.getCodigo() == null || plainPwd == null) {
            return new ResultadoRegistro("error", "Parámetros inválidos.");
        }

        try {
            utilidades.PasswordUtil.Result sec = utilidades.PasswordUtil.hashForStorage(plainPwd);

            cn = conexion.getConnection();
            String sql = "{CALL PERSONA.SP_INSERTAR_USUARIO(?, ?, ?, ?, ?, ?, ?)}";
            cs = cn.prepareCall(sql);

            // Parámetros IN
            cs.setString(1, u.getNombre());
            cs.setString(2, u.getCodigo());
            cs.setString(3, sec.saltB64);     // Salt generado
            cs.setString(4, sec.hashB64);     // Hash generado
            cs.setInt(5, u.getIdRol());
            cs.setInt(6, u.getEstado());

            // Parámetro OUT
            cs.registerOutParameter(7, java.sql.Types.INTEGER);

            boolean tieneRs = cs.execute();
            String status = "error";
            int idGenerado = 0;

            if (tieneRs) {
                rs = cs.getResultSet();
                if (rs.next()) {
                    status = rs.getString("message");
                    if ("success".equalsIgnoreCase(status)) {
                        idGenerado = rs.getInt("id_usuario");
                    }
                }
            }

            // Verificar valor OUT (por seguridad)
            int idOut = cs.getInt(7);
            if (idGenerado == 0 && idOut > 0) {
                idGenerado = idOut;
            }

            // Si el SP devuelve duplicado o success
            if ("duplicate".equalsIgnoreCase(status)) {
                return new ResultadoRegistro("duplicate", "El código de usuario ya existe.");
            } else if ("success".equalsIgnoreCase(status)) {
                return new ResultadoRegistro("success", "Usuario registrado correctamente.", idGenerado);
            } else {
                return new ResultadoRegistro("error", "No se pudo insertar el usuario.");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return new ResultadoRegistro("error", "Error SQL: " + e.getMessage());
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
            } catch (Exception ignored) {
            }
            try {
                if (cs != null) {
                    cs.close();
                }
            } catch (Exception ignored) {
            }
            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (Exception ignored) {
            }
        }
    }

    public String actualizarUsuario(Usuario u, String nuevaPassword) {
        if (u == null || u.getIdUsuario() <= 0) {
            return "ERR|Usuario inválido.";
        }

        Connection cn = null;
        PreparedStatement ps = null;

        try {
            cn = conexion.getConnection();

            boolean cambiarPassword = (nuevaPassword != null && !nuevaPassword.trim().isEmpty());

            if (cambiarPassword) {
                // Generar nuevo salt + hash
                utilidades.PasswordUtil.Result sec = utilidades.PasswordUtil.hashForStorage(nuevaPassword);

                String sql = "UPDATE PERSONA.USUARIO "
                        + "SET nombre = ?, id_rol = ?, salt = ?, hash_password = ? "
                        + "WHERE id_usuario = ?";

                ps = cn.prepareStatement(sql);
                ps.setString(1, u.getNombre());
                ps.setInt(2, u.getIdRol());
                ps.setString(3, sec.saltB64);
                ps.setString(4, sec.hashB64);
                ps.setInt(5, u.getIdUsuario());

            } else {
                // Sin cambiar contraseña
                String sql = "UPDATE PERSONA.USUARIO "
                        + "SET nombre = ?, id_rol = ?"
                        + "WHERE id_usuario = ?";

                ps = cn.prepareStatement(sql);
                ps.setString(1, u.getNombre());
                ps.setInt(2, u.getIdRol());
                ps.setInt(3, u.getIdUsuario());
            }

            int filas = ps.executeUpdate();
            if (filas > 0) {
                return "OK|Usuario actualizado correctamente.";
            } else {
                return "ERR|No se encontró el usuario a actualizar.";
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return "ERR|Error SQL al actualizar usuario: " + e.getMessage();
        } finally {
            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (Exception ignore) {
            }
            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (Exception ignore) {
            }
        }
    }

    public class ResultadoRegistro {

        private String status;
        private String message;
        private int idUsuario;

        public ResultadoRegistro() {
        }

        public ResultadoRegistro(String status, String message) {
            this(status, message, 0);
        }

        public ResultadoRegistro(String status, String message, int idUsuario) {
            this.status = status;
            this.message = message;
            this.idUsuario = idUsuario;
        }

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        public String getMessage() {
            return message;
        }

        public void setMessage(String message) {
            this.message = message;
        }

        public int getIdUsuario() {
            return idUsuario;
        }

        public void setIdUsuario(int idUsuario) {
            this.idUsuario = idUsuario;
        }

        @Override
        public String toString() {
            return "ResultadoRegistro{"
                    + "status='" + status + '\''
                    + ", message='" + message + '\''
                    + ", idUsuario=" + idUsuario
                    + '}';
        }
    }


    public modelos.Usuario validarLoginPorCodigo(String codigo, String plainPassword) {
        if (codigo == null || plainPassword == null) {
            return null;
        }

        String sql = "SELECT id_usuario, nombre, codigo, salt, hash_password, id_rol, estado "
                + "FROM PERSONA.USUARIO WHERE codigo = ?";

        try (Connection cn = conexion.getConnection(); PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, codigo.trim());

            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                String saltB64 = rs.getString("salt");
                String hashB64 = rs.getString("hash_password");

                boolean valido = utilidades.PasswordUtil.verify(plainPassword, saltB64, hashB64);
                if (!valido) {
                    return null;
                }

                // Si deseas solo usuarios activos, habilita este guard:
                // if (rs.getInt("estado") != 1) return null;
                modelos.Usuario u = new modelos.Usuario();
                u.setIdUsuario(rs.getInt("id_usuario"));
                u.setNombre(rs.getString("nombre"));
                u.setCodigo(rs.getString("codigo"));
                u.setIdRol(rs.getInt("id_rol"));
                u.setEstado(rs.getInt("estado"));
                return u;
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    public String cambiarPassword(int idUsuario, String nuevaPassword) {
        if (idUsuario <= 0) {
            return "ERR|ID de usuario inválido.";
        }
        if (nuevaPassword == null || nuevaPassword.trim().isEmpty()) {
            return "ERR|La nueva contraseña no puede estar vacía.";
        }

        Connection cn = null;
        PreparedStatement ps = null;

        try {
            // Generar nuevo salt + hash
            utilidades.PasswordUtil.Result sec = utilidades.PasswordUtil.hashForStorage(nuevaPassword);

            cn = conexion.getConnection();
            String sql = "UPDATE PERSONA.USUARIO "
                    + "SET salt = ?, hash_password = ? "
                    + "WHERE id_usuario = ?";

            ps = cn.prepareStatement(sql);
            ps.setString(1, sec.saltB64);
            ps.setString(2, sec.hashB64);
            ps.setInt(3, idUsuario);

            int filas = ps.executeUpdate();
            if (filas > 0) {
                return "OK|Contraseña actualizada correctamente.";
            } else {
                return "ERR|No se encontró el usuario para cambiar la contraseña.";
            }

        } catch (SQLException e) {
            e.printStackTrace();
            return "ERR|Error SQL al cambiar contraseña: " + e.getMessage();
        } finally {
            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (Exception ignore) {
            }
            try {
                if (cn != null) {
                    cn.close();
                }
            } catch (Exception ignore) {
            }
        }
    }

}
