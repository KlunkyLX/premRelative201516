// Method to pop hsh list with BBC match report html page IDs.

//--------------------------------------------------------------------------------//
//--------------------------------- Method Start ---------------------------------//
//--------------------------------------------------------------------------------//

HashSet<String> popPageIDs() {

  // Declare local variables.
  //--------------------------------------------------------------------------------//
  HashSet<String> pages = new HashSet<String>();  // mthd rtrn type
  //String rsltPage = "http://www.bbc.co.uk/sport/football/premier-league/results";
  String rsltPage = "http://www.bbc.co.uk/sport/football/results";  // refact?
  //String rsltPage = "results.html";  // local - delete
  //String rsltPage = "http://www.bbc.co.uk/sport/football/championship/results";
  //String rsltPage = "http://www.bbc.co.uk/sport/football/league-one/results";
  //String rsltPage = "http://www.bbc.co.uk/sport/football/league-two/results";
  //String rsltPage = "http://www.bbc.co.uk/sport/football/champions-league/results";
  String hndleLft = "<a class='report' href='/sport/football/";
  String hndleRght = "'>Report</a>";
  String[] lines = loadStrings(rsltPage);
  Pattern pttrn = Pattern.compile("\\s*" + hndleLft + "\\d+" + hndleRght + "\\s*");
  //--------------------------------------------------------------------------------//


  // Initialize pages lst.
  //--------------------------------------------------------------------------------//
  // Loop thrgh lines.
  for (String line : lines) {
    Matcher mtchr = pttrn.matcher(line);
    if (mtchr.matches()) {
      line = line.replace(hndleLft, "");
      line = trim(line.replace(hndleRght, ""));
      pages.add(line);
      //println("no game reports " + pages.size() + " id: " + line);  // debug
    }
  }  // line loop enclsng brce
  //--------------------------------------------------------------------------------//

  // For brevity, hard code last season's position here.
  //--------------------------------------------------------------------------------//
  // Teams cannot share a same position otherwise parser will break!  
  lastSeason.put("Chelsea", 1);
  lastSeason.put("Man City", 2);
  lastSeason.put("Arsenal", 3);
  lastSeason.put("Man Utd", 4);
  lastSeason.put("Spurs", 5);
  lastSeason.put("Liverpool", 6);
  lastSeason.put("Southampton", 7);
  lastSeason.put("Swansea", 8);
  lastSeason.put("Stoke", 9);
  lastSeason.put("Crystal Palace", 10);
  lastSeason.put("Everton", 11);
  lastSeason.put("West Ham", 12);
  lastSeason.put("West Brom", 13);
  lastSeason.put("Leicester", 14);
  lastSeason.put("Newcastle", 15);
  lastSeason.put("Sunderland", 16);
  lastSeason.put("Aston Villa", 17);
  lastSeason.put("Bournemouth", 18);
  lastSeason.put("Watford", 19);
  lastSeason.put("Norwich", 20);
  //--------------------------------------------------------------------------------//

  return pages;
}  // mthd enclsng brce
//--------------------------------------------------------------------------------//
//---------------------------------- Method End ----------------------------------//
//--------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------//
//----------------------------- Functionality Start ------------------------------//
//--------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------//
//------------------------------ Functionality End -------------------------------//
//--------------------------------------------------------------------------------//