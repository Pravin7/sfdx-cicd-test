public class Fridge implements KitchenUtility{
    
    private Integer numberInStock;
    private String modelNumber;
    public static final Integer STOCK_THRESHOLD = 5;
    public List<Fridge> SubFridge;
    
    
    public Fridge(String theModelNumber, Integer theNumberInStock) {
       modelNumber = theModelNumber;
      numberInStock = theNumberInStock;
    }
    
    public void updateStock(Integer justSold) {
        numberInStock = numberInStock - justSold;
    }
    
    public void setModelNumber(String theModelNumber) {
    modelNumber = theModelNumber;
    }

    public String getModelNumber() {
    return modelNumber;
    }
    
    public static void toDebug(Fridge aFridge) {
    System.debug ('ModelNumber = ' + aFridge.modelNumber);
    System.debug ('Number in Stock = ' + aFridge.numberInStock);
    }   
    
    public Integer ecoRating {
        get { return ecoRating; }
        set { ecoRating = value; if (ecoRating < 0) ecoRating =0; }
    }    

}