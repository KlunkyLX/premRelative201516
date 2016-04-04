// Class to store data from each match from BBC html report pages.

// Class name.
class Match {

  //--------------------------------------------------------------------------------//
  //--------------------------- Instance Variables Start ---------------------------//
  //--------------------------------------------------------------------------------//
  String pgeID;
  String homeTeam;
  String awayTeam;
  int homeScore;
  int awayScore;
  boolean homeWin;
  boolean draw;
  Date kickOff = new Date();  // yyyymmdd HH:mm:ss
  Date kickFinish = new Date();  // yyyymmdd HH:mm:ss
  String[] addedFrstTime;  // mins added to frst 45 mins
  String[] addedScndTime;  // mins added to scnd 45 mins

  StringList timeLine = new StringList();
  //--------------------------------------------------------------------------------//
  //---------------------------- Instance Variables End ----------------------------//
  //--------------------------------------------------------------------------------//

  //--------------------------------------------------------------------------------//
  //------------------------------ Constructor Start -------------------------------//
  //--------------------------------------------------------------------------------//

  Match(String newPgeID, String newHomeTeam, String newAwayTeam, int newHomeScore, 
    int newAwayScore, boolean newHomeWin, boolean newDraw, Date newKickOff) {

    this.pgeID = newPgeID;
    this.homeTeam = newHomeTeam;
    this.awayTeam = newAwayTeam;
    this.homeScore = newHomeScore;
    this.awayScore = newAwayScore;
    this.homeWin = newHomeWin;
    this.draw = newDraw;
    this.kickOff = newKickOff;

    // Soft coded error hndling.
    //--------------------------------------------------------------------------------//
    // The page parsed for match times has some historic matches kicking off at 2pm.
    // These have been altered to 3pm, not sure if that's correct or otherwise but
    // my poor judgment suggests conformity may be most appropriate here.
    SimpleDateFormat sdfTime = new SimpleDateFormat("HH:mm:ss");
    String kickOffTime = sdfTime.format(kickOff);    
    if (kickOffTime.equals("14:00:00")) {
      kickOffTime = "15:00:00";

      SimpleDateFormat sdfDate = new SimpleDateFormat("yyyy-MM-dd");
      String kickOffDate = sdfDate.format(kickOff);
      String strngDate = kickOffDate + " " + kickOffTime;

      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.ENGLISH);
      try {
        kickOff = sdf.parse(strngDate);
      } 
      catch(ParseException e) {
        e.printStackTrace();
      }
    }
    //--------------------------------------------------------------------------------//

    // Test to see if kick-off is the first kick-off of the season.
    Calendar calLcl = Calendar.getInstance();
    calLcl.setTime(kickOff);
    Calendar calGlbl = Calendar.getInstance();
    calGlbl.setTime(frstKickOff);
    if (calLcl.before(calGlbl)) {
      frstKickOff = kickOff;  // place val into glbl vrble
    }
    //println(pgeID + ", " + homeTeam + ", " + awayTeam + ", " + homeScore + ", " + awayScore +
    //", " + homeWin + ", " + draw + ", " + kickOff);  // debug - delete
    // Debug
    //--------------------------------------------------------------------------------//
    // Write this file for a club if live txt cmmntry suspctd missing.
    // Un-comment glbl vrble and flsh/ close in setup().
    /*String suspctdClb = "Southampton";
     if (homeTeam.equals(suspctdClb) || awayTeam.equals(suspctdClb)) {
     writer.println(kickOff + "," + homeTeam + "," + homeScore + "," + awayScore + "," + awayTeam);
     }*/
    //--------------------------------------------------------------------------------//

    // cnstrctr enclsng crly brace
  }

  //--------------------------------------------------------------------------------//
  //------------------------------- Constructor End --------------------------------//
  //--------------------------------------------------------------------------------//

  //--------------------------------------------------------------------------------//
  //-------------------------------- Getters Start ---------------------------------//
  //--------------------------------------------------------------------------------//

  Date getKickOff() {
    return kickOff;
  }  
  Date getKickFinish() {
    return kickFinish;
  }
  String getHomeTeam() {
    return homeTeam;
  }
  String getAwayTeam() {
    return awayTeam;
  }
  int getHomeScore() {
    return homeScore;
  }
  int getAwayScore() {
    return awayScore;
  }

  //--------------------------------------------------------------------------------//
  //--------------------------------- Getters End ----------------------------------//
  //--------------------------------------------------------------------------------//

  void setKickFinish(Date newKickFinish) {
    kickFinish = newKickFinish;
  }
  void setAddedFrstTime(String[] newAddedFrstTime) {
    addedFrstTime = newAddedFrstTime;
  }
  void setAddedScndTime(String[] newAddedScndTime) {
    addedScndTime = newAddedScndTime;
  }

  //--------------------------------------------------------------------------------//
  //-------------------------------- Setters Start ---------------------------------//
  //--------------------------------------------------------------------------------//
  //--------------------------------------------------------------------------------//
  //--------------------------------- Setters End ----------------------------------//
  //--------------------------------------------------------------------------------//

  //--------------------------------------------------------------------------------//
  //----------------------------- Functionality Start ------------------------------//
  //--------------------------------------------------------------------------------//
  //--------------------------------------------------------------------------------//
  //------------------------------ Functionality End -------------------------------//
  //--------------------------------------------------------------------------------//

  // Class enclsng crly brace
}