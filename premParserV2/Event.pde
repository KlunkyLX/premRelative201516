// Class to store data needed for ea club.
// This is basically just a list times all goals are scored.
// However, it could be refactored to include other event types like bookings
// and substitutions.

// Class name.
class Event {

  //--------------------------------------------------------------------------------//
  //--------------------------- Instance Variables Start ---------------------------//
  //--------------------------------------------------------------------------------//
  String eventID;  // matchID:sco-re
  String matchID;  // pageID
  Date goalTime;  // timestamp
  String rcrdTime;  // 90 min recrded time
  String post45mins;  // if goal scored within added time
  boolean scndHlf;
  int hmeGoals;  // no of goals when goal is scored
  int awayGoals;  // no of goals when goal is scored
  int crrntHmePoints;  // wnng-drwng-loosing
  int crrntAwayPoints;
  boolean fnlScore;  // true if this is the last goal of the match
  boolean startMatch;  // true if evnt instigated by match strtng rather than a goal (1-1)
  //--------------------------------------------------------------------------------//
  //---------------------------- Instance Variables End ----------------------------//
  //--------------------------------------------------------------------------------//

  //--------------------------------------------------------------------------------//
  //------------------------------ Constructor Start -------------------------------//
  //--------------------------------------------------------------------------------//

  Event(String newEventID, String newMatchID, Date newGoalTime, String newRcrdTime, 
    String newPost45mins, int newHomeGoals, int newAwayGoals, boolean newScndHlf, 
    boolean newStartMatch) {

    this.eventID = newEventID;
    this.matchID = newMatchID;
    this.goalTime = newGoalTime;
    this.rcrdTime = newRcrdTime;
    this.post45mins = newPost45mins;
    this.hmeGoals = newHomeGoals;
    this.awayGoals = newAwayGoals;
    this.scndHlf = newScndHlf;
    this.startMatch = newStartMatch;

    if (hmeGoals == awayGoals) {  // used for 0-0 mtches
      crrntHmePoints = 1;
      crrntAwayPoints = 1;
    } else if (hmeGoals > awayGoals) {
      crrntHmePoints = 3;
      crrntAwayPoints = 0;
    } else {
      crrntHmePoints = 0;
      crrntAwayPoints = 3;
    }

    Match newMatch = matches.get(matchID);
    if (hmeGoals == newMatch.getHomeScore() && awayGoals == newMatch.getAwayScore()) {
      fnlScore = true;
    } else {
      fnlScore = false;
    }
    //println(goalTime);  // debug - delete
    // cnstrctr enclsng crly brace
  }
  
  //--------------------------------------------------------------------------------//
  //------------------------------- Constructor End --------------------------------//
  //--------------------------------------------------------------------------------//

  //--------------------------------------------------------------------------------//
  //-------------------------------- Getters Start ---------------------------------//
  //--------------------------------------------------------------------------------//

  String getEventID() {
    return eventID;
  }
  String getMatchID() {
    return matchID;
  }
  Date getGoalTime() {
    return goalTime;
  }
  String getRcrdTime() {
    return rcrdTime;
  }
  String getPost45mins() {
    return post45mins;
  }
  int getCrrntHmePoints() {
    return crrntHmePoints;
  }
  int getCrrntAwayPoints() {
    return crrntAwayPoints;
  }
  int getHmeGoals() {
    return hmeGoals;
  }
  int getAwayGoals() {
    return awayGoals;
  }
  boolean getFnlScore() {
    return fnlScore;
  }

  //--------------------------------------------------------------------------------//
  //--------------------------------- Getters End ----------------------------------//
  //--------------------------------------------------------------------------------//

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