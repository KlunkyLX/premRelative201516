// Method to parse ea BBC report html page.
// Locate the live-text-commentary line.
// Create/ update club match and event objects.
// Init timeline keys.

//--------------------------------------------------------------------------------//
//--------------------------------- Method Start ---------------------------------//
//--------------------------------------------------------------------------------//

void prseRprt(String pageID, String[] kickOffs) {

  // Declare local variables.
  //--------------------------------------------------------------------------------//
  String url = "http://www.bbc.co.uk/sport/0/football/" + pageID;
  //String url = pageID + ".txt";  // local - delete
  String[] lines = loadStrings(url);
  String hndle = " Match ends, ";
  //--------------------------------------------------------------------------------//

  // Prse the live-text-commentary line.
  //--------------------------------------------------------------------------------//
  // Loop thrgh lines.
  for (String line : lines) {
    boolean mtchd = line.contains(hndle);
    if (mtchd) {  // the live-text-commentary line
      int hndleIndx = line.indexOf(hndle);
      line = line.substring(hndleIndx + hndle.length(), line.length());  // rmve hndke
      int rsltIndx = line.indexOf(". </p>");
      String rslt = line.substring(0, rsltIndx);
      addClubMtch(rslt, kickOffs, pageID);  // called below
      addGoal(line, url, pageID);
      //println(line);  // debug
      break;
    }
  }  // line loop enclsng brce
  //--------------------------------------------------------------------------------//
}  // mthd enclsng brce
//--------------------------------------------------------------------------------//
//---------------------------------- Method End ----------------------------------//
//--------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------//
//----------------------------- Functionality Start ------------------------------//
//--------------------------------------------------------------------------------//

// Add new club and match objects. 
//--------------------------------------------------------------------------------//
void addClubMtch(String rslt, String[] kickOffs, String pageID) {
  String[] sides = split(rslt, ",");
  String homeName = trim(sides[0].replaceAll("\\d", ""));
  String statHomeName = nameToStat(homeName);
  String awayName = trim(sides[1].replaceAll("\\d", ""));
  String statAwayName = nameToStat(awayName);
  int homeScore = int(trim(sides[0].replaceAll("\\D", "")));
  int awayScore = int(trim(sides[1].replaceAll("\\D", "")));
  boolean homeWin;
  boolean draw;
  Date kickOff = new Date();
  if (homeScore > awayScore) {
    homeWin = true;
    draw = false;
  } else if (homeScore < awayScore) {
    homeWin = false;
    draw = false;
  } else {
    homeWin = false;
    draw = true;
  }

  // Parse kickOff times from SoccerSTATS html array.
  for (int i = 0; i < kickOffs.length; i++) {
    String hndleLft = "<td>&nbsp;";
    String hndleRght = "</td>";
    Pattern pttrn = Pattern.compile("\\s*" + hndleLft + statHomeName + " - " +
      statAwayName + hndleRght + "\\s*");
    Matcher mtchr = pttrn.matcher(kickOffs[i]);
    if (mtchr.matches()) {
      String drtyDate = kickOffs[i - 2];
      String[] dates = split(drtyDate, "<td align='right'><font color='green'>");
      String drtyTime = kickOffs[i - 1];
      String[] times = split(drtyTime, "<td align='center'><font color='green' size='1'>");
      String[] hhmm = split(times[1], "<");
      kickOff = dater(dates[1], hhmm[0]);
    }
  }  // loop enclsng brce

  // Test to create a club object.
  createClub(homeName, statHomeName, pageID);
  createClub(awayName, statAwayName, pageID);

  // Test to create a match object.
  createMatch
    (pageID, homeName, awayName, homeScore, awayScore, homeWin, draw, kickOff);
}  // mthd enclsng brce
//--------------------------------------------------------------------------------//

// Test to create a club object.
//--------------------------------------------------------------------------------//
void createClub(String name, String nameSTAT, String matchID) {
  // Test to see if club already exists in hshmp.
  if (clubs.containsKey(name) == false) {
    Club club = new Club(name, nameSTAT);
    clubs.put(name, club);
  }
  // Add matchID to existing club objct.
  Club club = clubs.get(name);  // init temp local objct
  HashSet<String> matchIDs = club.getMatchIDs();
  matchIDs.add(matchID);
  club.setMatchIDs(matchIDs);
  clubs.put(name, club);  // add back into club hsh
}  // mthd enclsng brce
//--------------------------------------------------------------------------------//

// Test to create a match object.
//--------------------------------------------------------------------------------//
void createMatch(String pgeID, String homeTeam, String awayTeam, int homeScore, 
  int awayScore, boolean homeWin, boolean draw, Date kickOff) {
  // Test to see if match already exists in hshmp.
  if (matches.containsKey(pgeID) == false) {    
    Match match = new Match(pgeID, homeTeam, awayTeam, homeScore, awayScore, homeWin, draw, kickOff);
    matches.put(pgeID, match);

    // Add a 0-0 event to map.
    // At moment of kick-off both teams have one pnt ea.
    Event nilnil = new Event(pgeID + ":0-0", pgeID, kickOff, "00:00", "0:00", 0, 0, false, true);
    if (events.containsKey(kickOff) == false) {
      HashSet<Event> newGoals = new HashSet<Event>();
      newGoals.add(nilnil);
      events.put(kickOff, newGoals);
    } else {
      // Retrieve exstng hshset of event objects.
      HashSet<Event> exstngGoals = events.get(kickOff);
      exstngGoals.add(nilnil);
      // Re-populate hshmp.
      events.put(kickOff, exstngGoals);
    }
  }
}  // mthd enclsng brce
//--------------------------------------------------------------------------------//

// Method to parse goal data from live text commentary html block.
//--------------------------------------------------------------------------------//
void addGoal(String commntry, String url, String pageID) {

  // Establish extra time played in the scnd half.
  //--------------------------------------------------------------------------------//
  String extraScnd;  // scnd hlf extra time
  String[] extraScndHlf = split(commntry, "<span> 90:00  <span class='extra-info'>");
  String[] extra2 = split(extraScndHlf[1], "<span class='icon-live-text-full-time'>Full time</span></span>");
  try {
    extraScnd = trim(extra2[0].replaceAll("\\+", ""));
    // Update match objects with extraScnd time;
  }
  catch(Exception e) {
    extraScnd = "00:00";
    println("Dang, something wrong prsng scnd hlf extra time:\n" + url);  // debug
  }
  // Put mins and secs into two elmnts.
  String[] mmssScnd = split(extraScnd, ":");
  //--------------------------------------------------------------------------------//

  // Establish extra time played in the first half.
  //--------------------------------------------------------------------------------//
  String extraFrst;  // frst hlf extra time
  String[] extraFrstHlf = split(commntry, "<span class='icon-live-text-half-time'>Half time</span></span>");
  String[] extraExtra1 = split(extraFrstHlf[0], "<span> 45:00  <span class='extra-info'>");
  String[] extra1 = split(extraExtra1[extraExtra1.length - 1], "</span>");
  try {
    extraFrst = trim(extra1[0].replaceAll("\\+", ""));
  }
  catch(Exception e) {
    extraFrst = "00:00";
    println("Dang, something wrong prsng frst hlf extra time:\n" + url);  // debug
  }
  // Put mins and secs into two elmnts.
  String[] mmssFrst = split(extraFrst, ":");
  //--------------------------------------------------------------------------------//

  // Update match objcts with match end times.
  //--------------------------------------------------------------------------------//
  Match thisMatch = (Match) matches.get(pageID);  // init temp local objct
  Date kickOff = thisMatch.getKickOff();
  Date kickFinish = kickOff;  // start from time match commences
  Calendar cal = Calendar.getInstance();
  cal.setTime(kickFinish);

  cal.add(Calendar.MINUTE, 45 + int(trim(mmssFrst[0])) + 15 + 45 + int(trim(mmssScnd[0])));
  cal.add(Calendar.SECOND, int(trim(mmssFrst[1])) + int(trim(mmssScnd[1])));
  kickFinish = cal.getTime();

  // Update match with calculated new kickFinish vrble.
  thisMatch.setKickFinish(kickFinish);
  //println(kickOff + " - " + kickFinish);  // debug
  thisMatch.setAddedFrstTime(mmssFrst);  // update added frst hlf time
  thisMatch.setAddedScndTime(mmssScnd);  // update added scnd hlf time
  matches.put(pageID, thisMatch);
  //--------------------------------------------------------------------------------//

  // Call mthd below to prse both halves.
  //--------------------------------------------------------------------------------//
  String homeTeam = thisMatch.getHomeTeam();  // just use to chck corrct teams
  String awayTeam = thisMatch.getAwayTeam();

  String[] zeroExtraFrstHlf = {
    "0", "00"
  };
  goalPrsr(extraFrstHlf[0], mmssFrst, 1, pageID, kickOff, homeTeam, awayTeam);
  goalPrsr(extraFrstHlf[1], zeroExtraFrstHlf, 0, pageID, kickOff, homeTeam, awayTeam);
  //--------------------------------------------------------------------------------//
}  // mthd enclsng brce
//--------------------------------------------------------------------------------//

// Method to parse in goals for 1st and 2nd half into Evnt class.
//--------------------------------------------------------------------------------//
void goalPrsr(String cmmntryHlf, String[] mmssExtraFrst, int trueFlse, String matchID, 
  Date kickOff, String homeTeam, String awayTeam) {
  int hlftme = 15;
  boolean scndHlf;
  if (trueFlse == 1) {
    scndHlf = true;
  } else {
    scndHlf = false;
  }

  // Previous elmnt should have the time at the end.
  // Succesive elmnt should have the sides at the begining.
  //String[] goals = split(cmmntryHlf, "<span class='icon-live-text-goal'>Goal scored</span></span> </span> <p class='event'>  <span class='event-title'>  <strong>Goal!</strong>    </span>    Goal!");
  String[] goals = split(cmmntryHlf, "<span class='icon-live-text-goal'>Goal scored</span></span> </span> <p class='event'>  <span class='event-title'>  <strong>Goal!</strong>    </span>");
  if (goals.length > 1) {  // if a goal/s was scored during the half
    for (int i = 1; i < goals.length; i++) { // start at 2nd elmnt

      // Rertieve time from previous elmnt.
      //--------------------------------------------------------------------------------//
      String[] span = split(goals[i - 1], "<span>");
      String[] times = split(span[span.length - 1], "<span class='extra-info'>");
      String time = times[0];

      // Put mins and secs into two elmnts.
      String[] mmssTime = split(time, ":");
      // Check for extra time.
      String extraTime = "0.00";
      String[] mmssExTime = {
        "0.00", "0.00"
      };  // assgn default 0 vals
      Pattern pttrn = Pattern.compile("\\s*\\+\\d+:\\d+\\s*");
      Matcher mtchr = pttrn.matcher(times[1]);
      if (mtchr.matches()) {
        extraTime = trim(times[times.length - 1].replaceAll("\\+", ""));
        // Put mins and secs into two elmnts.
        mmssExTime = split(extraTime, ":");
      }
      //println(matchID + ": " + time + " + " + extraTime);  // debug
      //--------------------------------------------------------------------------------//

      // Rertieve the score time for current goal.
      //--------------------------------------------------------------------------------//
      Calendar cal = Calendar.getInstance();
      cal.setTime(kickOff);
      cal.add(Calendar.MINUTE, int(trim(mmssTime[0])) + int(trim(mmssExTime[0])));
      cal.add(Calendar.SECOND, int(trim(mmssTime[1])) + int(trim(mmssExTime[1])));
      // If scnd hlf, add 15 min break and any late strtng times.
      if (scndHlf) {
        cal.add(Calendar.MINUTE, 15 + int(trim(mmssExtraFrst[0])));
        cal.add(Calendar.SECOND, int(trim(mmssExtraFrst[1])));
      }
      Date goalTime = cal.getTime();
      //println(matchID + ": " + goalTime);  // debug
      //--------------------------------------------------------------------------------//

      // Retrieve current score.
      //--------------------------------------------------------------------------------//
      String[] crrntScore;
      goals[i] = trim(goals[i].replaceAll("Goal!", ""));
      crrntScore = split(goals[i], ".");
      String[] teamScores;
      // if begins "Own Goal"
      if (crrntScore[0].toLowerCase().substring(0, 8).equals("own goal")) {
        teamScores = split(crrntScore[1], ",");
      } else {
        teamScores = split(crrntScore[0], ",");
      }

      // Homescore
      int homeScore = 0;  // init to dflt val
      if (teamScores[0].contains(homeTeam)) {
        homeScore = int(trim(teamScores[0].replace(homeTeam, "")));
      } else {
        println("Hm, error. It looks like hme club and hme goal have conflcting names.");
      }

      // Awayscore
      int awayScore = 0;  // init to dflt val
      if (teamScores[1].contains(awayTeam)) {
        awayScore = int(trim(teamScores[1].replace(awayTeam, "")));
      } else {
        println("Hm, error. It looks like hme club and hme goal have conflcting names.");
      }
      //println(homeScore + " - " + awayScore);  // debug
      //--------------------------------------------------------------------------------//

      // Create an event object.
      //--------------------------------------------------------------------------------//
      // Test to see if date isn't alrdy a key in glbl hshmp.
      String eventID = matchID + ":" + homeScore + "-" + awayScore;   // matchID:sco-re
      if (events.containsKey(goalTime) == false) {
        // Create a new Event object.
        Event goal = new Event(eventID, matchID, goalTime, time, extraTime, 
          homeScore, awayScore, scndHlf, false);
        // Add new hsh key and objct hshset.
        HashSet<Event> noGoals = new HashSet<Event>();
        noGoals.add(goal);
        events.put(goalTime, noGoals);
      } else {  // update exstng hsh
        // Retrieve exstng hshset of event objects.
        HashSet<Event> exstngGoals = events.get(goalTime);
        // Add new goal to the list.
        Event goal = new Event(eventID, matchID, goalTime, time, extraTime, 
          homeScore, awayScore, scndHlf, false);
        exstngGoals.add(goal);
        // Re-populate hshmp.
        events.put(goalTime, exstngGoals);
      }
      //--------------------------------------------------------------------------------//
    }  // ea goal enclsng brce
  }
  //--------------------------------------------------------------------------------//
}  // mthd enclsng brce
//--------------------------------------------------------------------------------//

// Quick mthd to parse conflicting BBC names to SoccerSTAT names.
//--------------------------------------------------------------------------------//
String nameToStat(String bbcName) {
  String statName;

  if (bbcName.equals("Manchester United")) {
    statName = "Manchester Utd";
  } else if (bbcName.equals("Newcastle United")) {
    statName = "Newcastle Utd";
  } else if (bbcName.equals("Tottenham Hotspur")) {
    statName = "Tottenham";
  } else if (bbcName.equals("West Bromwich Albion")) {
    statName = "West Bromwich";
  } else if (bbcName.equals("West Ham United")) {
    statName = "West Ham Utd";
  } else {
    statName = bbcName;
  }

  return statName;
}  // mthd enclsng brce
//--------------------------------------------------------------------------------//

// This is just a quick and drty conversion to int date from STAT parsed date.
//--------------------------------------------------------------------------------//
// yyyymmdd
Date dater(String drtyDate, String hhmm) {
  Date kickOff = new Date();
  String yyyy;
  String dd;
  HashMap<String, String> mnthNo = new HashMap<String, String>();
  mnthNo.put("Jan", "01");
  mnthNo.put("Feb", "02");
  mnthNo.put("Mar", "03");
  mnthNo.put("Apr", "04");
  mnthNo.put("May", "05");
  mnthNo.put("Jun", "06");
  mnthNo.put("Jul", "07");
  mnthNo.put("Aug", "08");
  mnthNo.put("Sep", "09");
  mnthNo.put("Oct", "10");
  mnthNo.put("Nov", "11");
  mnthNo.put("Dec", "12");

  drtyDate = drtyDate.replaceAll("\\.", "");
  String[] tkns = splitTokens(drtyDate);

  if (tkns[2].equals("Jan") || tkns[2].equals("Feb") || tkns[2].equals("Mar") ||
    tkns[2].equals("Apr") || tkns[2].equals("May")) {
    yyyy = "2016";
  } else {
    yyyy = "2015";
  }

  if (tkns.length == 1) {
    dd = "0" + tkns[1];
  } else {
    dd = tkns[1];
  }

  String mm = mnthNo.get(tkns[2]);

  if (hhmm.equals("14:00")) {  // quick error fix for soccerStats page
    hhmm = "15:00";  // all 2pms are changed to 3pm kick-offs
  }
  String strngDate = yyyy + "-" + mm + "-" + dd + " " + hhmm + ":00";
  try {
    kickOff = sdf.parse(strngDate);
  } 
  catch(ParseException e) {
    e.printStackTrace();
  }
  return kickOff;
}  // mthd enclsng brce
//--------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------//
//------------------------------ Functionality End -------------------------------//
//--------------------------------------------------------------------------------//