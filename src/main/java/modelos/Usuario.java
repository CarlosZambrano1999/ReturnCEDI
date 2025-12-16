/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelos;

/**
 *
 * @author arlom
 */
public class Usuario {

    private int idUsuario;          // [id_usuario] (INT)
    private String nombre;          // [nombre] (NVARCHAR)
    private String codigo;          // [codigo] (usuario/código único)
    private String salt;            // [salt] (Base64/hex)
    private String hashPassword;    // [hash_password]
    private int idRol;              // [id_rol] (INT/FK)
    private int estado;             // [estado] (0 = inactivo, 1 = activo)

    public Usuario() {
    }

    public Usuario(int idUsuario, String nombre, String codigo, String salt,
            String hashPassword, int idRol, int estado, String rolNombre) {
        this.idUsuario = idUsuario;
        this.nombre = nombre;
        this.codigo = codigo;
        this.salt = salt;
        this.hashPassword = hashPassword;
        this.idRol = idRol;
        this.estado = estado;
        this.rolNombre = rolNombre;
    }

    public int getIdUsuario() {
        return idUsuario;
    }

    public void setIdUsuario(int idUsuario) {
        this.idUsuario = idUsuario;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public String getSalt() {
        return salt;
    }

    public void setSalt(String salt) {
        this.salt = salt;
    }

    public String getHashPassword() {
        return hashPassword;
    }

    public void setHashPassword(String hashPassword) {
        this.hashPassword = hashPassword;
    }

    public int getIdRol() {
        return idRol;
    }

    public void setIdRol(int idRol) {
        this.idRol = idRol;
    }

    public int getEstado() {
        return estado;
    }

    public void setEstado(int estado) {
        this.estado = estado;
    }

    private String rolNombre;

    public String getRolNombre() {
        return rolNombre;
    }

    public void setRolNombre(String rolNombre) {
        this.rolNombre = rolNombre;
    }

}
