// Class to store data needed for ea club.

// Class name.
class Club {

  //--------------------------------------------------------------------------------//
  //--------------------------- Instance Variables Start ---------------------------//
  //--------------------------------------------------------------------------------//
  String namePrem;
  String nameSTAT;
  HashSet<String> matchIDs = new HashSet<String>();
  Integer lstSsnPos;  // final league position last season

  HashMap<Date, Integer> crrntPoints = new HashMap<Date, Integer>();  // (points in game)
  int cumPoints = 0;
  HashMap<Date, Integer> forAccumltor = new HashMap<Date, Integer>();  // (goals in game)
  int goalsFor = 0;  // cum goals
  HashMap<Date, Integer> agnstAccumltor = new HashMap<Date, Integer>();  // (goals in game)
  int goalsAgnst = 0;  // cum goals
  HashMap<Date, Integer> goalDiff = new HashMap<Date, Integer>();  // (goal dffrnce)
  //--------------------------------------------------------------------------------//
  //---------------------------- Instance Variables End ----------------------------//
  //--------------------------------------------------------------------------------//

  //--------------------------------------------------------------------------------//
  //------------------------------ Constructor Start -------------------------------//
  //--------------------------------------------------------------------------------//

  Club(String newNamePrem, String newNameSTAT) {
    this.namePrem = newNamePrem;
    this.nameSTAT = newNameSTAT;
    this.lstSsnPos = (Integer) lastSeason.get(namePrem);
    //println(namePrem + ", " + nameSTAT + ", " + matchIDs.size() + ", " + lstSsnPos);  // debug - delete
    // cnstrctr enclsng crly brace
  }

  //--------------------------------------------------------------------------------//
  //------------------------------- Constructor End --------------------------------//
  //--------------------------------------------------------------------------------//

  //--------------------------------------------------------------------------------//
  //-------------------------------- Getters Start ---------------------------------//
  //--------------------------------------------------------------------------------//
  HashSet<String> getMatchIDs() {
    return matchIDs;
  }
  String getNamePrem() {
    return namePrem;
  }
  String getNameSTAT() {
    return nameSTAT;
  }
  int getLstSsnPos() {
    return lstSsnPos;
  }
  HashMap<Date, Integer> getCrrntPoints() {
    return crrntPoints;
  }
  int getCumPoints() {
    return cumPoints;
  }
  HashMap<Date, Integer> getForAccumltor() {
    return forAccumltor;
  }
  int getGoalsFor() {
    return goalsFor;
  }
  HashMap<Date, Integer> getAgnstAccumltor() {
    return agnstAccumltor;
  }
  int getGoalsAgnst() {
    return goalsAgnst;
  }
  HashMap<Date, Integer> getGoalDiff() {
    return goalDiff;
  }
  //--------------------------------------------------------------------------------//
  //--------------------------------- Getters End ----------------------------------//
  //--------------------------------------------------------------------------------//

  //--------------------------------------------------------------------------------//
  //-------------------------------- Setters Start ---------------------------------//
  //--------------------------------------------------------------------------------//
  void setMatchIDs(HashSet<String> newMatchIDs) {
    matchIDs = newMatchIDs;
  }
  void setCrrntPoints(HashMap<Date, Integer> newCrrntPoints) {
    crrntPoints = newCrrntPoints;
  }
  void setCumPoints(int newCumPoints) {
    cumPoints = newCumPoints;
  }
  void setForAccumltor(HashMap<Date, Integer> newForAccumltor) {
    forAccumltor = newForAccumltor;
  }
  void setGoalsFor(int newGoalsFor) {
    goalsFor = newGoalsFor;
  }
  void setAgnstAccumltor(HashMap<Date, Integer> newAgnstAccumltor) {
    agnstAccumltor = newAgnstAccumltor;
  }
  void setGoalsAgnst(int newGoalsAgnst) {
    goalsAgnst = newGoalsAgnst;
  }
  void setGoalDiff(HashMap<Date, Integer> newGoalDiff) {
    goalDiff = newGoalDiff;
  }
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