// Load club icons from
//iconPrsr();  // called in separate tab

// Method to parse Guardian icon pages.

//--------------------------------------------------------------------------------//
//--------------------------------- Method Start ---------------------------------//
//--------------------------------------------------------------------------------//

void iconPrsr() {

  // Declare local variables.
  //--------------------------------------------------------------------------------//
  String iconURL = "https://sport.guim.co.uk/football/crests/60/";
  String drctry = "C:/Users/trist/version-control/visualizations/premRelative201516/icons/";
  String iconExt = "png";
  HashMap<String, String> crests = new HashMap<String, String>();
  crests.put("Arsenal", "1006");
  crests.put("AstonVilla", "2");
  crests.put("Bournemouth", "23");
  crests.put("Chelsea", "4");
  crests.put("CrystalPalace", "5");
  crests.put("Everton", "8");
  crests.put("LeicesterCity", "29");
  crests.put("Liverpool", "9");
  crests.put("ManchesterCity", "11");
  crests.put("ManchesterUnited", "12");
  crests.put("NewcastleUnited", "31");
  crests.put("NorwichCity", "14");
  crests.put("Southampton", "18");
  crests.put("StokeCity", "38");
  crests.put("Sunderland", "39");
  crests.put("SwanseaCity", "65");
  crests.put("TottenhamHotspur", "19");
  crests.put("Watford", "41");
  crests.put("WestBromwichAlbion", "42");
  crests.put("WestHamUnited", "43");
  //--------------------------------------------------------------------------------//

  // Prse the web pages.
  //--------------------------------------------------------------------------------//
  // Itrte thrgh ea club and pop lsts.    
  for (Map.Entry crest : crests.entrySet ()) {
    PImage icon = loadImage(iconURL + crest.getValue() + "." + iconExt, iconExt);
    icon.save(drctry + crest.getKey() + "." + iconExt);
  }  // club itrtn enclsng brce
  //--------------------------------------------------------------------------------//
}  // mthd enclsng brce
//--------------------------------------------------------------------------------//
//---------------------------------- Method End ----------------------------------//
//--------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------//
//----------------------------- Functionality Start ------------------------------//
//--------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------//
//------------------------------ Functionality End -------------------------------//