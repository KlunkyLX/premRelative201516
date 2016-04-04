// Sketch to parse BBC prem html pages to get times and goals for ea match.
// I didn't bother putting in an excp handlers as I am lazy and also
// because I wanted to ensure every piece of data was correctly accrued.

// Goal times are based from the time the kick-off was scheduled. If the
// match did not kick-off on time the time of the goals will be more inaccurate.
// Because of this the score times caluculated for ea goal is probably about
// one or two minutes premature.

// Kickoff times were parsed from here:
// http://www.soccerstats.com/results.asp?league=england
// Some kickoffs show 2pm. These have been altered to 3pm. However, I think
// some games at 8pm actually kicked-off at 7.45pm so there may be further
// inaccuracies here also.

// Tristan Skinner
// 30/03/2016

// Attributes
//--------------------------------------------------------------------------------//
// Visualizing Data, Ben Fry, O'Reilly, 2008, ISBN: 978-0-596-15852-1
// http://m.premierleague.com/en-gb/scores-and-results.html
// http://www.bbc.co.uk/sport/football/premier-league/results/
// http://www.soccerstats.com/
// https://sport.guim.co.uk/football/crests/60/
//--------------------------------------------------------------------------------//

// Import libraries
//--------------------------------------------------------------------------------//
import java.util.HashSet;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.regex.PatternSyntaxException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.Calendar;
//--------------------------------------------------------------------------------//

// Global variables
//--------------------------------------------------------------------------------//
HashMap<String, Club> clubs = new HashMap<String, Club>();  // (name, objct)
HashMap<String, Integer> lastSeason = new HashMap<String, Integer>();  // (name, position)
HashMap<String, Match> matches = new HashMap<String, Match>();  // (pgeID, objct)
HashMap<Date, HashSet> events = new HashMap<Date, HashSet>();  // (timestmp, objcts)
ArrayList<Date> evntDates;  // date of ea evnt in chronological order
int noTeams = 20;

Table ptsTble = new Table();
Table leagueTble = new Table();
Date frstKickOff = new Date();  // assgnd by Match
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.ENGLISH);
int endFrstHlfIndx = 0;  // dclrd in prseRprt()

//PrintWriter writer = createWriter("C:/Users/t/version-control/premRelative201516/premParser/debugFile.csv");  // debug
//--------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------//
//--------------------------------- Setup Start ----------------------------------//
//--------------------------------------------------------------------------------//

void setup() {
  // Local variables.
  HashSet<String> rprtPages = popPageIDs();  // pop html page IDs in seperate tab
  // Load kick-off times from soccer.stats.com.
  String[] kickOffs = loadStrings("http://www.soccerstats.com/results.asp?league=england");
  //String[] kickOffs = loadStrings("soccerStatsKickOff.txt");  // local - delete

  // Parse ea rprtPage and create/ update match, club, event and timeline objects.
  //--------------------------------------------------------------------------------//
  // Itrte thrgh ea report page.
  String[] pages = loadStrings("wwwmpremListofPgesToPrse.csv");
  String url = "http://m.premierleague.com/en-gb/matches/2015-2016/epl.commentary.html/";
  //prseRprt("33744668", kickOffs, "", "");  // local - delete
  int lastTime = 1000;  // timer vrble - start after 1 sec
  for (String page : pages) {
    // Create random speed at which each report page is parsed in
    // order not to be chucked off Prem's server.
    float r = random(0.2, 0.5);  // wait between every 0.2 to 0.5 secs
    while ((millis() - lastTime) < r) {
    }
    String[] fields = split(page, ",");
    prseRprt(url + fields[0] + "-vs-" + fields[1], kickOffs, "", "");  // called in seperate tab
    lastTime = millis();
  }  // rprtPages itrtn enclsng brce
  //--------------------------------------------------------------------------------//

  // loop thrgh ea event.
  //--------------------------------------------------------------------------------//
  // Sort goal times.
  Set dateSet = events.keySet();
  evntDates = new ArrayList<Date>(dateSet);
  java.util.Collections.sort(evntDates);

  // Loop thrgh ea event.
  for (Date evntDate : evntDates) {
    // Retrieve hshset of goals for ea date.
    HashSet<Event> goals = events.get(evntDate);  // init temp local objct
    // Loop thrgh all goals.
    for (Event goal : goals) {
      Match newMatch = matches.get(goal.getMatchID());
      // Update goal and point vrbles for ea club.
      updteClub(evntDate, newMatch.getHomeTeam(), goal.getHmeGoals(), goal.getAwayGoals(), 
        goal.getCrrntHmePoints(), goal.getFnlScore());

      updteClub(evntDate, newMatch.getAwayTeam(), goal.getAwayGoals(), goal.getHmeGoals(), 
        goal.getCrrntAwayPoints(), goal.getFnlScore());
    }  // goal hshst loop enclsng brce
  }  // date loop enclsng brce
  //--------------------------------------------------------------------------------//

  // Write a points table.
  //--------------------------------------------------------------------------------//
  // One row per goal.

  // Create column for ea club.
  ptsTble.addColumn("goalTime");
  ptsTble.addColumn("epochScnds");  // millis from epoch
  // Order the colmn hdrs to correspond with team's prev end of season pstn.
  for (int i = 1; i < clubs.size () + 1; i++) {
    for (Map.Entry club : clubs.entrySet ()) {
      Club newClub = (Club) club.getValue();
      if (newClub.getLstSsnPos() == i) {
        String clubNme = (String) club.getKey();
        ptsTble.addColumn(clubNme + "\nPts");
        ptsTble.addColumn(clubNme + "\nF");
        ptsTble.addColumn(clubNme + "\nA");
        ptsTble.addColumn(clubNme + "\nGD");
      }  // itrte club enclsng brce
    }  // if club mtches prev seasons postn
  }  // loop thrgh ea postn

  // Assign zero points to ea club before frst kick-off of the season.
  //--------------------------------------------------------------------------------//
  Date lstSsnDate = new Date();  // two scnds before frst kick-off
  Date preFrstKickOff = new Date();  // one scnd before frst kick-off
  Calendar calPre = Calendar.getInstance();
  calPre.setTime(frstKickOff);  
  calPre.add(Calendar.SECOND, -2);
  lstSsnDate = calPre.getTime();
  calPre.setTime(frstKickOff);  
  calPre.add(Calendar.SECOND, -1);
  preFrstKickOff = calPre.getTime();
  // Cast goal time date into a strng.
  String lstSsn = null;
  String preKickOff = null;
  try {
    lstSsn = sdf.format(lstSsnDate);
    preKickOff = sdf.format(preFrstKickOff);
  }
  catch(Exception e) {
    e.printStackTrace();
  }
  // Calculate millis from epoch.
  Calendar calPreMilli = Calendar.getInstance();
  calPreMilli.setTime(lstSsnDate);
  int lstSsnScnds = (int) (calPreMilli.getTimeInMillis() / 1000);
  calPreMilli.setTime(preFrstKickOff);
  int scndsPre = (int) (calPreMilli.getTimeInMillis() / 1000);

  // Enter frst row with positions from last season, null other vals.
  TableRow frstRow = ptsTble.addRow();
  frstRow.setString("goalTime", lstSsn);
  frstRow.setInt("epochScnds", lstSsnScnds);  // millis from epoch
  for (Map.Entry club : clubs.entrySet ()) {
    Club newClub = (Club) club.getValue();
    String clubNme = (String) club.getKey();
    frstRow.setInt(clubNme + "\nPts", newClub.getLstSsnPos());
    frstRow.setInt(clubNme + "\nF", 0);
    frstRow.setInt(clubNme + "\nA", 0);
    frstRow.setInt(clubNme + "\nGD", 0);
  }  // itrte club enclsng brce

  // Enter scnd row with all positions bottom.
  TableRow scndRow = ptsTble.addRow();
  scndRow.setString("goalTime", preKickOff);
  scndRow.setInt("epochScnds", scndsPre);  // millis from epoch
  for (Map.Entry club : clubs.entrySet ()) {
    String clubNme = (String) club.getKey();
    scndRow.setInt(clubNme + "\nPts", noTeams);  // no of teams in league
    scndRow.setInt(clubNme + "\nF", 0);
    scndRow.setInt(clubNme + "\nA", 0);
    scndRow.setInt(clubNme + "\nGD", 0);
  }  // itrte club enclsng brce
  //--------------------------------------------------------------------------------//

  // Create a row for ea evnt timestamp.
  //--------------------------------------------------------------------------------//
  for (Date evntDate : evntDates) {
    // Cast goal time date into a strng.
    String goalDate = null;
    try {
      goalDate = sdf.format(evntDate);
    }
    catch(Exception e) {
      e.printStackTrace();
    }
    // Calculate millis from epoch.
    Calendar cal = Calendar.getInstance();
    cal.setTime(evntDate);
    int goalScnds = (int) (cal.getTimeInMillis() / 1000);

    TableRow newRow = ptsTble.addRow();
    newRow.setString("goalTime", goalDate);
    newRow.setInt("epochScnds", goalScnds);
  }  // date loop enclsng brce
  //--------------------------------------------------------------------------------//

  // Pop ea row with vals for ea club.
  //--------------------------------------------------------------------------------//
  // Itrte thrgh ea club and rtrve any updates.
  int noPtsRows = ptsTble.getRowCount();
  for (Map.Entry club : clubs.entrySet ()) {
    int prevPts = 0;
    int prevFor = 0;  // cum goals
    int prevAgnst = 0;
    int prevGD = 0;  // goal diff
    Club newClub = (Club) clubs.get(club.getKey());
    HashMap<Date, Integer> clubCrrntPts = newClub.getCrrntPoints();
    HashMap<Date, Integer> goalsFor = newClub.getForAccumltor();
    HashMap<Date, Integer> goalsAgnst = newClub.getAgnstAccumltor();
    HashMap<Date, Integer> goalDiff = newClub.getGoalDiff();
    // Loop thrgh ea row in tble.
    for (int i = 2; i < noPtsRows; i++) {  // strt at 3rd row
      TableRow row = ptsTble.getRow(i);
      Date rowDate = new Date();
      try {
        rowDate = sdf.parse(row.getString("goalTime"));
      } 
      catch(ParseException e) {
        e.printStackTrace();
      }
      if (clubCrrntPts.containsKey(rowDate)) {  // if team scrd or cnceded a goal at this timestamp
        row.setInt((String) club.getKey() + "\nPts", clubCrrntPts.get(rowDate));  // no of teams in league
        row.setInt((String) club.getKey() + "\nF", goalsFor.get(rowDate));
        row.setInt((String) club.getKey() + "\nA", goalsAgnst.get(rowDate));
        row.setInt((String) club.getKey() + "\nGD", goalDiff.get(rowDate));
        prevPts = clubCrrntPts.get(rowDate);
        prevFor = goalsFor.get(rowDate);  // cum goals
        prevAgnst = goalsAgnst.get(rowDate);
        prevGD = goalDiff.get(rowDate);  // goal diff
      } else {  // othrwse just updte fields with previous values
        row.setInt((String) club.getKey() + "\nPts", prevPts);  // no of teams in league
        row.setInt((String) club.getKey() + "\nF", prevFor);
        row.setInt((String) club.getKey() + "\nA", prevAgnst);
        row.setInt((String) club.getKey() + "\nGD", prevGD);
      }
    }  // row loop enclsng brce
  }  // itrte club enclsng brce
  //--------------------------------------------------------------------------------//

  String league = "prem1516";
  String fileDate = nf(year(), 4) + nf(month(), 2) + nf(day(), 2);
  //saveTable(ptsTble, "data/" + league + "goals" + fileDate + ".html", "html");  // debug
  saveTable(ptsTble, "data/" + league + "goals" + fileDate + ".csv", "csv");
  //--------------------------------------------------------------------------------//

  // Write pts meta table.
  //--------------------------------------------------------------------------------//
  // Loop thrgh ea row in ptsTble to calculate relative points for ea club.
  for (int i = 2; i < noPtsRows; i++) {  // strt at 3rd row
    HashMap<String, Integer> pts = new HashMap<String, Integer>();
    HashMap<String, Integer> glsF = new HashMap<String, Integer>();
    HashMap<String, Integer> glsA = new HashMap<String, Integer>();
    HashMap<String, Integer> gd = new HashMap<String, Integer>();
    TableRow ptsRow = ptsTble.getRow(i);

    // Itrte thrgh ea club and pop lsts.    
    for (Map.Entry club : clubs.entrySet ()) {
      String clbNme = (String) club.getKey();
      pts.put(clbNme, ptsRow.getInt(clbNme + "\nPts"));
      glsF.put(clbNme, ptsRow.getInt(clbNme + "\nF"));
      glsA.put(clbNme, ptsRow.getInt(clbNme + "\nA"));
      gd.put(clbNme, ptsRow.getInt(clbNme + "\nGD"));
    }  // club itrtn enclsng brce

    // Rank pstn meta.
    HashMap<String, String> rnkdF = ranker(glsF, 2, true);
    HashMap<String, String> rnkdA = ranker(glsA, 2, false);
    HashMap<String, String> rnkdGD = ranker(gd, 2, true);

    // Add pstn meta to points as decimals.
    HashMap<String, String> ptsDot = new HashMap<String, String>();
    // Cast pts to string and add a decimal point.
    for (Map.Entry club : pts.entrySet ()) {  // itrte thrgh ea club
      Integer ptsInt = (Integer) club.getValue();
      ptsDot.put((String) club.getKey(), str(ptsInt) + ".");
    }  // club itrtn enclsng brce
    HashMap<String, String> ptsMeta = addToPts(ptsDot, rnkdGD);  // rnk by this meta frst
    ptsMeta = addToPts(ptsMeta, rnkdF);  // rnk by scnd meta
    ptsMeta = addToPts(ptsMeta, rnkdA);  // rnk by thrd meta

    // Overwrite points column with new point meta vals.
    for (Map.Entry club : ptsMeta.entrySet ()) {  // itrte thrgh ea club
      ptsTble.setFloat(i, (String) club.getKey() + "\nPts", float((String) club.getValue()));
    }  // club itrtn enclsng brce
  }  // ptsTble row loop enclsng brce

  for (Map.Entry club : clubs.entrySet ()) {
    String clbNme = (String) club.getKey();
    ptsTble.removeColumn(clbNme + "\nF");
    ptsTble.removeColumn(clbNme + "\nA");
    ptsTble.removeColumn(clbNme + "\nGD");
  }  // club itrtn enclsng brce

  //saveTable(ptsTble, "data/" + league + "ptsMeta" + fileDate + ".html", "html");  // debug
  saveTable(ptsTble, "data/" + league + "ptsMeta" + fileDate + ".csv", "csv");  // debug
  //--------------------------------------------------------------------------------//

  // Write current league table.
  //--------------------------------------------------------------------------------//
  // Retrve vals from last row of previous tble.
  TableRow lastRow = ptsTble.getRow(ptsTble.lastRowIndex());
  // Pop vals arry and clubs latest vals hsh.
  HashSet<Integer> metaVals = new HashSet<Integer>();  // to cnvrt to lst
  HashMap<String, Integer> clubVals = new HashMap<String, Integer>();
  for (Map.Entry club : clubs.entrySet ()) {
    String clubNme = (String) club.getKey();
    Integer meta = lastRow.getInt(clubNme + "\nPts");
    metaVals.add(meta);
    clubVals.put(clubNme, meta);
  }
  // Put hshst into a lst.
  IntList metaDesc = new IntList();
  for (int metaVal : metaVals) {
    metaDesc.append(metaVal);
  }
  metaDesc.sortReverse();
  // Create columns for tble.
  leagueTble.addColumn("team");
  leagueTble.addColumn("pts");
  leagueTble.addColumn("f");
  leagueTble.addColumn("a");
  leagueTble.addColumn("gd");

  // Loop through desc meta vals.
  for (int metaVal : metaDesc) {
    // Itrte thrgh all the clubs to see if they have mtchng val.
    for (Map.Entry club : clubVals.entrySet ()) {
      if ((Integer) club.getValue() == metaVal) {
        addLgeTbleRow(clubs.get(club.getKey()));  // add a new row with club vals
        clubVals.remove(club);  // then delete club from hsh
      }
    }  // club hsh enclsng brce
  }  // metaDesc enclsng brce 

  saveTable(leagueTble, "../leagueTble.csv", "csv");
  //--------------------------------------------------------------------------------//

  // Write positions table.
  //--------------------------------------------------------------------------------//
  // Loop thrgh ea row in ptsMetaTble to calculate relative pstn for ea club.
  for (int i = 2; i < noPtsRows; i++) {  // strt at 3rd row
    HashMap<String, Float> pstns = new HashMap<String, Float>();
    TableRow ptsRow = ptsTble.getRow(i);

    // Itrte thrgh ea club and pop lsts.    
    for (Map.Entry club : clubs.entrySet ()) {
      String clbNme = (String) club.getKey();
      pstns.put(clbNme, ptsRow.getFloat(clbNme + "\nPts"));
    }  // club itrtn enclsng brce
    // Rank pstn meta.
    HashMap<String, String> rnkdPstns = rankerFlt(pstns, 2, false);

    // Overwrite meta points column with new relative position.
    for (Map.Entry club : rnkdPstns.entrySet ()) {  // itrte thrgh ea club
      ptsTble.setInt(i, (String) club.getKey() + "\nPts", int((String) club.getValue()));
    }  // club itrtn enclsng brce
  }  // ptsTble row loop enclsng brce

  // Remove epoch colmn. Just kept this in case it was useful.
  ptsTble.removeColumn("epochScnds");

  // Loop thrgh ea clmn ttle and remove "Pts".
  for (int i = 1; i < ptsTble.getColumnTitles().length; i++) {  // ignre dateStmp clmn
    String ttle = ptsTble.getColumnTitle(i).replaceAll("\nPts", "");
    ttle = ttle.replaceAll("\\W", "");  // rmve all whtespace or not read in D3
    ptsTble.setColumnTitle(i, ttle);
  }  // clmn loop enclsng brce

  // Save in fldr above.
  saveTable(ptsTble, "../" + league + "pstns" + fileDate + ".csv", "csv");
  // LBI
  //saveTable(ptsTble, "C:/Users/tristan skinner/version-control/premRelative201516/" + league + "pstns" + fileDate + ".csv", "csv");
  //--------------------------------------------------------------------------------//

  // Rtrve club icons.
  //iconPrsr();

  // Debug
  //--------------------------------------------------------------------------------//
  //writer.flush();
  //writer.close();
  //--------------------------------------------------------------------------------//

  exit();
}  // setup enclsng brce
//--------------------------------------------------------------------------------//
//---------------------------------- Setup End -----------------------------------//
//--------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------//
//----------------------------- Functionality Start ------------------------------//
//--------------------------------------------------------------------------------//

// Mthd to updte clubs with evnt meta.
//--------------------------------------------------------------------------------//
void updteClub(Date evntTme, String clubName, int goalsFor, int goalsAgnst, 
  int crrntRslt, boolean fnlScore) {
  Club newClub = clubs.get(clubName);

  // Get total points at end of previous game.
  int pointsNow = crrntRslt + newClub.getCumPoints();  // bug
  HashMap<Date, Integer> crrntPoints = newClub.getCrrntPoints();
  crrntPoints.put(evntTme, pointsNow);
  newClub.setCrrntPoints(crrntPoints);
  if (fnlScore == true) {
    newClub.setCumPoints(pointsNow);  // updte total points
  }

  HashMap<Date, Integer> forAccumltor = newClub.getForAccumltor();
  forAccumltor.put(evntTme, goalsFor + newClub.getGoalsFor());
  newClub.setForAccumltor(forAccumltor);

  HashMap<Date, Integer> agnstAccumltor = newClub.getAgnstAccumltor();
  agnstAccumltor.put(evntTme, goalsAgnst + newClub.getGoalsAgnst());
  newClub.setAgnstAccumltor(agnstAccumltor);

  HashMap<Date, Integer> goalDiff = newClub.getGoalDiff();
  goalDiff.put(evntTme, (goalsFor + newClub.getGoalsFor()) - (goalsAgnst + newClub.getGoalsAgnst()));
  newClub.setGoalDiff(goalDiff);

  // Call after gol diff calculated.
  if (fnlScore == true) {
    newClub.setGoalsFor(goalsFor + newClub.getGoalsFor()); // updte total goals for
    newClub.setGoalsAgnst(goalsAgnst + newClub.getGoalsAgnst()); // updte total goals agnst
  }

  clubs.put(clubName, newClub);  // put updtd club back into it's hshmap
}  // mthd enclsng brce
//--------------------------------------------------------------------------------//

// Mthd to rank vals into range within total no of teams size.
//--------------------------------------------------------------------------------//
HashMap<String, String> ranker(HashMap<String, Integer> unRnkd, int noDgt, boolean asc) {
  HashMap<String, String> rnkdHsh = new HashMap<String, String>();
  int[] sorter = new int[unRnkd.size()];

  // Itrte thrgh ea unrnkd val.
  int indx = 0;
  for (Map.Entry val : unRnkd.entrySet ()) {
    Integer toCast = (Integer) val.getValue();
    sorter[indx] = (int) toCast;
    indx++;
  }  // hsh itrtn enclsng brce
  if (asc == true) {
    sorter = sort(sorter);
  } else {
    sorter = sort(sorter);
    sorter = reverse(sorter);
  }
  // Loop thrgh ea elmnt and assgn rank into rtrn hsh.
  for (int i = 0; i < sorter.length; i++) {
    for (Map.Entry val : unRnkd.entrySet ()) {  // itrte thrgh ea club
      if (val.getValue().equals(sorter[i])) {
        rnkdHsh.put((String) val.getKey(), nf(i, noDgt));
      }
    }  // hsh itrtn enclsng brce
  }  // arry loop enclsng brce
  return rnkdHsh;
}  // mthd enclsng brce
//--------------------------------------------------------------------------------//

// Above mthd to rank vals into range within total no of teams size for floats.
//--------------------------------------------------------------------------------//
HashMap<String, String> rankerFlt(HashMap<String, Float> unRnkd, int noDgt, boolean asc) {
  HashMap<String, String> rnkdHsh = new HashMap<String, String>();
  float[] sorter = new float[unRnkd.size()];

  // Itrte thrgh ea unrnkd val.
  int indx = 0;
  for (Map.Entry val : unRnkd.entrySet ()) {
    Float toCast = (Float) val.getValue();
    sorter[indx] = (float) toCast;
    indx++;
  }  // hsh itrtn enclsng brce
  if (asc == true) {
    sorter = sort(sorter);
  } else {
    sorter = sort(sorter);
    sorter = reverse(sorter);
  }
  // Loop thrgh ea elmnt and assgn rank into rtrn hsh.
  for (int i = 0; i < sorter.length; i++) {
    for (Map.Entry val : unRnkd.entrySet ()) {  // itrte thrgh ea club
      if (val.getValue().equals(sorter[i])) {
        rnkdHsh.put((String) val.getKey(), nf(i + 1, noDgt));  // don't use 0
      }
    }  // hsh itrtn enclsng brce
  }  // arry loop enclsng brce
  return rnkdHsh;
}  // mthd enclsng brce
//--------------------------------------------------------------------------------//

// Mthd to add pstn meta as decimals to ea club's pts.
//--------------------------------------------------------------------------------//
HashMap<String, String> addToPts(HashMap<String, String> pts, HashMap<String, String> ptsMeta) {
  HashMap<String, String> ptsDec = new HashMap<String, String>();
  for (Map.Entry club : pts.entrySet ()) {  // itrte thrgh ea club
    if (ptsMeta.containsKey(club.getKey())) {
      ptsDec.put((String) club.getKey(), club.getValue() + ptsMeta.get(club.getKey()));
    }
  }  // club itrtn enclsng brce
  return ptsDec;
}  // mthd enclsng brce
//--------------------------------------------------------------------------------//

// Mthd to add new rows to write a current league table for reference.
//--------------------------------------------------------------------------------//
void addLgeTbleRow(Club club) {
  TableRow newRow = leagueTble.addRow();
  newRow.setString("team", club.getNamePrem());
  newRow.setInt("pts", club.getCumPoints());
  newRow.setInt("f", club.getGoalsFor());
  newRow.setInt("a", club.getGoalsAgnst());
  newRow.setInt("gd", club.getGoalsFor() - club.getGoalsAgnst());
}
//--------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------//
//------------------------------ Functionality End -------------------------------//
//--------------------------------------------------------------------------------//