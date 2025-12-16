/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package utilidades;

import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/**
 *
 * @author arlom
 */
public class PasswordUtil {
    // Ajustables
    private static final int SALT_LENGTH = 16;           // 128 bits
    private static final int ITERATIONS = 100_000;       // cost
    private static final int KEY_LENGTH = 256;           // 256 bits
 
    /** Genera un salt seguro (bytes) */
    public static byte[] generateSalt() {
        SecureRandom sr = new SecureRandom();
        byte[] salt = new byte[SALT_LENGTH];
        sr.nextBytes(salt);
        return salt;
    }
 
    /** Deriva el hash PBKDF2-HmacSHA256 (bytes) */
    public static byte[] pbkdf2(char[] password, byte[] salt) {
        try {
            PBEKeySpec spec = new PBEKeySpec(password, salt, ITERATIONS, KEY_LENGTH);
            SecretKeyFactory skf = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
            return skf.generateSecret(spec).getEncoded();
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new RuntimeException("Error generando hash de contraseña", e);
        }
    }
 
    /** Genera SALT (Base64) y HASH (Base64) para guardar en BD */
    public static Result hashForStorage(String plainPassword) {
        byte[] salt = generateSalt();
        byte[] hash = pbkdf2(plainPassword.toCharArray(), salt);
        return new Result(
            Base64.getEncoder().encodeToString(salt),
            Base64.getEncoder().encodeToString(hash)
        );
    }
 
    /** Verifica una contraseña contra SALT/HASH almacenados (Base64) */
    public static boolean verify(String plainPassword, String saltB64, String hashB64) {
        byte[] salt = Base64.getDecoder().decode(saltB64);
        byte[] expectedHash = Base64.getDecoder().decode(hashB64);
        byte[] candidate = pbkdf2(plainPassword.toCharArray(), salt);
        return constantTimeEquals(expectedHash, candidate);
    }
 
    /** Comparación tiempo-constante */
    private static boolean constantTimeEquals(byte[] a, byte[] b) {
        if (a == null || b == null || a.length != b.length) return false;
        int r = 0;
        for (int i = 0; i < a.length; i++) r |= a[i] ^ b[i];
        return r == 0;
    }
 
    public static class Result {
        public final String saltB64;
        public final String hashB64;
        public Result(String saltB64, String hashB64) {
            this.saltB64 = saltB64;
            this.hashB64 = hashB64;
        }
    }
}