/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package modelos;

/**
 *
 * @author arlom
 */
public class Farmacia {
    private String storeId;
    private String farmacia;
    private String centro;
    public Farmacia() {
    }

    public Farmacia(String storeId, String farmacia, String centro) {
        this.storeId = storeId;
        this.farmacia = farmacia;
        this.centro = centro;
    }

    public String getStoreId() {
        return storeId;
    }

    public void setStoreId(String storeId) {
        this.storeId = storeId;
    }

    public String getFarmacia() {
        return farmacia;
    }

    public void setFarmacia(String farmacia) {
        this.farmacia = farmacia;
    }

    public String getCentro() {
        return centro;
    }

    public void setCentro(String centro) {
        this.centro = centro;
    }
    
    
    
}
