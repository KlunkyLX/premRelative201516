// Method to parse ea BBC report html page.
// Locate the live-text-commentary line.
// Create/ update club match and event objects.
// Init timeline keys.

//--------------------------------------------------------------------------------//
//--------------------------------- Method Start ---------------------------------//
//--------------------------------------------------------------------------------//

void prseRprt(String pageID, String[] kickOffs, String hmeScre, String awyScre) {
String hmeClb = "";  // nme of club
String awyClb = "";  // nme of club
  // Declare local variables.
  //--------------------------------------------------------------------------------//
  //String url = "http://www.bbc.co.uk/sport/0/football/" + pageID;
  String url = pageID + ".txt";  // local - delete
  String[] lines = loadStrings(url);
  //--------------------------------------------------------------------------------//

  // Prse the live-text-commentary line.
  //--------------------------------------------------------------------------------//
  // Loop thrgh lines.
  for (String line : lines) {
    if (line.contains("<div class=\"hometitle\">")) {
      String[] hmeLine1 = split(line, "<div class=\"hometitle\">");
      String[] hmeLine2 = split(hmeLine1[1], "\">");
      String[] hmeLine3 = split(hmeLine2[1], "</a>");
      hmeClb = trim(hmeLine3[0]);
      //println(hmeClb);  // debug - delete
    } else if (line.contains("<p class=\"countscore\"><strong>")) {
      String[] screLine1 = split(line, "<p class=\"countscore\"><strong>");
      String[] screLine2 = split(screLine1[1], " - ");
      hmeScre = trim(screLine2[0]);
      String[] screLine3 = split(screLine2[1], "<");
      awyScre = trim(screLine3[0]);
    } else if (line.contains("<div class=\"awaytitle\">")) {
      String[] awyLine1 = split(line, "<div class=\"awaytitle\">");
      String[] awyLine2 = split(awyLine1[1], "\">");
      String[] awyLine3 = split(awyLine2[1], "</a>");
      awyClb = trim(awyLine3[0]);
      //println(awyClb);  // debug - delete
    }
  }  // line loop enclsng brce
  //println(hmeClb + " " +  hmeScre + ", " + awyClb + " " + awyScre);  // debug
  addClubMtch(hmeClb, awyClb, hmeScre, awyScre, kickOffs, pageID);  // called below
  addGoal(lines, pageID);
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
void addClubMtch(String hmeClb, String awyClb, String hmeScre, String awyScre, 
  String[] kickOffs, String pageID) {
  String statHomeName = nameToStat(hmeClb);
  String statAwayName = nameToStat(awyClb);
  boolean homeWin;
  boolean draw;
  Date kickOff = new Date();
  if (int (hmeScre) > int (awyScre)) {
    homeWin = true;
    draw = false;
  } else if (int (hmeScre) < int (awyScre)) {
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
      // Udapte times that appar too late.
      if (hhmm[0].equals("20:45")) {
        hhmm[0] = "19:45";
      } else if (hhmm[0].equals("21:00")) {
        hhmm[0] = "20:00";
      }
      kickOff = dater(dates[1], hhmm[0]);
    }
  }  // loop enclsng brce

  // Test to create a club object.
  createClub(hmeClb, statHomeName, pageID);
  createClub(awyClb, statAwayName, pageID);

  // Test to create a match object.
  createMatch(pageID, hmeClb, awyClb, int(hmeScre), int(awyScre), 
    homeWin, draw, kickOff);
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

// Method to parse goal data from Prem html page.
//--------------------------------------------------------------------------------//
void addGoal(String[] lines, String pageID) {
  String extraTme = "00:00";  // dflt val
  String[] mmssScnd = {"00", "00"};    // dflt val
  String extraFrst = "00:00";  // dflt val
  String[] mmssFrst = {"00", "00"};    // dflt val

  // Loop thrgh lines.
  for (int i = 0; i < lines.length; i++) {

    // Establish extra time played in the scnd half.
    //--------------------------------------------------------------------------------//
    if (lines[i].contains("<div class=\"comment tabular-cell\">Second Half ends,")) {
      extraTme = trim(lines[i - 1].replaceAll("<div class=\"time tabular-cell\">90:00", ""));
      extraTme = extraTme.replaceAll("</div>", "");
      if (extraTme.contains("+")) {
        extraTme = trim(extraTme.replaceAll("\\+", ""));
      }
      // Put mins and secs into two elmnts.
      mmssScnd = split(extraTme, ":");
    }
    //--------------------------------------------------------------------------------//

    // Establish extra time played in the frst half.
    //--------------------------------------------------------------------------------//
    if (lines[i].contains("<div class=\"comment tabular-cell\">First Half ends,")) {
      endFrstHlfIndx = i;  // glbl vrble
      extraFrst = trim(lines[i -1].replaceAll("<div class=\"time tabular-cell\">45:00", ""));
      extraFrst = trim(extraFrst.replaceAll("</div>", ""));
      if (extraFrst.contains("+")) {
        extraFrst = trim(extraFrst.replaceAll("\\+", ""));
      }
      // Put mins and secs into two elmnts.
      mmssFrst = split(extraFrst, ":");
    }
  }  // line loop enclsng brce
  //--------------------------------------------------------------------------------//

  // Update match objcts with match end times.
  //--------------------------------------------------------------------------------//
  Match thisMatch = (Match) matches.get(pageID);  // init temp local objct
  Date kickOff = thisMatch.getKickOff();
  Date kickFinish = kickOff;  // start from time match commences
  Calendar cal = Calendar.getInstance();
  cal.setTime(kickFinish);

  cal.add(Calendar.MINUTE, 45 + int(trim(mmssFrst[0])) + 15 + 45 + int(trim(mmssScnd[0])));
  cal.add(Calendar.SECOND, int(trim(mmssFrst[1])) + int(trim(mmssScnd[1])));  // delete
  kickFinish = cal.getTime();

  // Update match with calculated new kickFinish vrble.
  thisMatch.setKickFinish(kickFinish);
  //println(kickOff + " - " + kickFinish);  // debug
  thisMatch.setAddedFrstTime(mmssFrst);  // update added frst hlf time
  thisMatch.setAddedScndTime(mmssScnd);  // update added scnd hlf time
  matches.put(pageID, thisMatch);
  //--------------------------------------------------------------------------------//

  goalPrsr(lines, mmssFrst, pageID, kickOff);
}  // mthd enclsng brce
//--------------------------------------------------------------------------------//

// Method to parse in goals for 1st and 2nd half into Evnt class.
//--------------------------------------------------------------------------------//
void goalPrsr(String[] lines, String[] mmssFrst, 
  String matchID, Date kickOff) {
  String[] mmss = {"00", "00"};
  String[] mmssX = {"00", "00"};
  String homeGoals = "";  // intlze frthr down
  String awayGoals = "";  // intlze frthr down

  // Establish goal time.
  //--------------------------------------------------------------------------------//
  // Loop thrgh lines.
  for (int i = 0; i < lines.length; i++) {
    // Goal found.
    if (lines[i].contains("<div class=\"GOAL comment-row tabular-row borderBottomBlue \">")) {
      boolean scndHlf = true;
      if (i > endFrstHlfIndx) {
        scndHlf = false;  // if 2nd hlf add on 15 mins + and 1st hlf added on
      }
      String mins = trim(lines[i+ 1].replaceAll("<div class=\"time tabular-cell\">", ""));
      mins = trim(mins.replaceAll("</div>", ""));
      if (mins.contains("+") == false) {  // no added time
        String[] mmssTme = trim(split(mins, ":"));
        mmss[0] = trim(mmssTme[0]);  // mins
        mmss[1] = trim(mmssTme[1]);  // secs
      } else {
        String[] mmssTmeX = trim(split(mins, "+"));
        String[] mmssTme = trim(split(mmssTmeX[0], ":"));
        mmss[0] = trim(mmssTme[0]);  // mins
        mmss[1] = trim(mmssTme[1]);  // secs
        String[] mmssTmeXX = trim(split(mmssTmeX[1], ":"));
        mmssX[0] = trim(mmssTmeXX[0]);  // mins
        mmssX[1] = trim(mmssTmeXX[1]);  // secs
      }
      //--------------------------------------------------------------------------------//

      // Create calndr objct current goal time.
      //--------------------------------------------------------------------------------//
      Calendar cal = Calendar.getInstance();
      cal.setTime(kickOff);
      cal.add(Calendar.MINUTE, int(mmss[0]) + int(mmssX[0]));
      cal.add(Calendar.SECOND, int(mmss[1]) + int(mmssX[1]));
      // If scnd hlf, add 15 min break and any frst hlf extra time.
      if (scndHlf) {
        cal.add(Calendar.MINUTE, 15 + int(trim(mmssFrst[0])));
        cal.add(Calendar.SECOND, int(trim(mmssFrst[1])));
      }
      Date goalTime = cal.getTime();
      println(int(mmss[0]) + ", " + int(mmss[1]));  // debug - delete
      println(int(mmssX[0]) + ", " + int(mmssX[1]));  // debug - delete
      println(matchID + ": " + goalTime);  // debug
      //--------------------------------------------------------------------------------//

      // Retrieve current new score.
      //--------------------------------------------------------------------------------//
      // Quickly nest loop further couple of lines.
      for (int ii = 0; ii < 30; ii++) {  // arbtry param
        if (lines[ii].contains("<div class=\"comment tabular-cell\">Goal!")) { 
          String score = trim(lines[ii].replaceAll("<div class=\"comment tabular-cell\">Goal!", ""));
          score = trim(score.replaceAll(".", ""));
          String[] halves = trim(split(score, ","));
          String[] home = trim(split(halves[0], " "));
          homeGoals = home[1];
          String[] away = trim(split(halves[1], " "));
          awayGoals = away[1];
        }  // if scoreline found enclsng brce
      }  // scoreline loop enclsng brce
      //--------------------------------------------------------------------------------//

      // Create an event object.
      //--------------------------------------------------------------------------------//
      String eventID = matchID + ":" + homeGoals + "-" + awayGoals;   // matchID:sco-re
      String time = "";  // kludge - debug - delete
      String extraTime = "";  // kludge - debug - delete
      if (events.containsKey(goalTime) == false) {
        // Create a new Event object.
        Event goal = new Event(eventID, matchID, goalTime, time, extraTime, 
          int(homeGoals), int(awayGoals), scndHlf, false);
        // Add new hsh key and objct hshset.
        HashSet<Event> noGoals = new HashSet<Event>();
        noGoals.add(goal);
        events.put(goalTime, noGoals);
      } else {  // update exstng hsh
        // Retrieve exstng hshset of event objects.
        HashSet<Event> exstngGoals = events.get(goalTime);
        // Add new goal to the list.
        Event goal = new Event(eventID, matchID, goalTime, time, extraTime, 
          int(homeGoals), int(awayGoals), scndHlf, false);
        exstngGoals.add(goal);
        // Re-populate hshmp.
        events.put(goalTime, exstngGoals);
      }
      //--------------------------------------------------------------------------------//
    }  // if a goal is found enclsng brce
  }  // line loop enclsng brce
  //--------------------------------------------------------------------------------//
}  // goal prsr mthd enclsng brce
//--------------------------------------------------------------------------------//

// Quick mthd to parse conflicting BBC names to SoccerSTAT names.
//--------------------------------------------------------------------------------//
String nameToStat(String premName) {
  String statName;

  if (premName.equals("Man Untd")) {
    statName = "Manchester Utd";
  } else if (premName.equals("Newcastle")) {
    statName = "Newcastle Utd";
  } else if (premName.equals("Spurs")) {
    statName = "Tottenham";
  } else if (premName.equals("Stoke")) {
    statName = "Stoke City";
  } else if (premName.equals("Leicester")) {
    statName = "Leicester City";
  } else if (premName.equals("West Brom")) {
    statName = "West Bromwich";
  } else if (premName.equals("Norwich")) {
    statName = "Norwich";
  } else if (premName.equals("Swansea")) {
    statName = "Swansea City";
  } else if (premName.equals("West Ham")) {
    statName = "West Ham Utd";
  } else if (premName.equals("Man City")) {
    statName = "Manchester City";
  } else {
    statName = premName;
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