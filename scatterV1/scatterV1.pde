// Sketch to create a table by looping thrgh pstns evnts to count
// no of times ea club chnge to ea pstn in the league.

// Tristan Skinner
// 30/04/2016

// Attributes
//--------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------//

// Import libraries
//--------------------------------------------------------------------------------//
import java.util.Map;
//--------------------------------------------------------------------------------//

// Global variables
//--------------------------------------------------------------------------------//
Table scatter = new Table();
//--------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------//
//--------------------------------- Setup Start ----------------------------------//
//--------------------------------------------------------------------------------//

void setup() {

  // Local variables
  //--------------------------------------------------------------------------------//
  Table evnts = loadTable("../prem1516pstns20160426.csv", "header");
  evnts.removeColumn("goalTime");
  evnts.removeRow(0);  // pstn prev season
  evnts.removeRow(0);  // pstn one sec before frst kick-off
  String[] clubNmes = {"Chelsea", "ManCity", "Arsenal", "ManUtd", "Spurs", "Liverpool", "Southampton", 
    "Swansea", "Stoke", "CrystalPalace", "Everton", "WestHam", "WestBrom", "Leicester", "Newcastle", 
    "Sunderland", "AstonVilla", "Bournemouth", "Watford", "Norwich"};
  int noRows = evnts.getRowCount();

  String pstn = "pstn";  // frst col header
  HashMap<String, Integer> prevPstns = new HashMap<String, Integer>();
  HashMap<String, HashMap> clubs = new HashMap<String, HashMap>();
  String fileDate = nf(year(), 4) + nf(month(), 2) + nf(day(), 2);
  //--------------------------------------------------------------------------------//

  // Add cols and blank rows and init frst vals for both hshmps.
  //--------------------------------------------------------------------------------//
  scatter.addColumn(pstn);
  for (int i = 0; i < clubNmes.length; i++) {
    scatter.addColumn(clubNmes[i]);

    // Initlze frst pstn for ea team
    int crrntPstn = evnts.getInt(0, clubNmes[i]);
    prevPstns.put(clubNmes[i], crrntPstn);

    // Initlze blnk hsh cntrs for ea club.
    HashMap<Integer, Integer> cntr = new HashMap<Integer, Integer>();
    for (int ii = 0; ii < clubNmes.length; ii++) {
      if (ii + 1 != crrntPstn) {
        cntr.put(ii + 1, 0);
      } else {
        cntr.put(ii + 1, 1);
      }
    }
    clubs.put(clubNmes[i], cntr);

    TableRow row = scatter.addRow();
    row.setInt(pstn, i + 1);
  }
  //println(clubs);  // debug
  // Write changed pstn to scatter table.
  updateScttr(clubs);
  evnts.removeRow(0);
  //--------------------------------------------------------------------------------//

  // Loop thrgh remaining events.
  //--------------------------------------------------------------------------------//
  for (TableRow row : evnts.rows()) {

    // Loop thrgh ea club
    for (Map.Entry prevPstn : prevPstns.entrySet()) {
      int crrntPstn = row.getInt((String) prevPstn.getKey());
      // If pstn has changed from prev pstn.
      if (crrntPstn != (int) prevPstn.getValue()) {
        //print(prevPstn.getKey() + " prev is ");  // debug - delete
        //println(prevPstn.getValue() + " and crrnt is " + crrntPstn);  // debug - delete
        // Write changed pstn to scatter table.
        updateScttrVal((String) prevPstn.getKey(), crrntPstn);
        // Updte prev hsh with new val.
        prevPstns.put((String) prevPstn.getKey(), crrntPstn);
      }
    }  // ea club loop enclsng brce
  }  // ea evnt loop enclsng brce
  //--------------------------------------------------------------------------------//

  saveTable(scatter, "../scatter" + fileDate + ".csv");

  exit();
}  // setup enclsng brce
//--------------------------------------------------------------------------------//
//---------------------------------- Setup End -----------------------------------//
//--------------------------------------------------------------------------------//

//--------------------------------------------------------------------------------//
//----------------------------- Functionality Start ------------------------------//
//--------------------------------------------------------------------------------//

// Write changed pstn to scatter table.
//--------------------------------------------------------------------------------//
void updateScttr(HashMap<String, HashMap> clubs) {

  // Itrte thrgh ea club
  for (Map.Entry club : clubs.entrySet()) {
    HashMap<Integer, Integer> pstnCntrs = new HashMap<Integer, Integer>();
    pstnCntrs = (HashMap) club.getValue();
    // Itrte thrgh ea pstn
    for (Map.Entry pstnVal : pstnCntrs.entrySet()) {
      int rowNo = (int) pstnVal.getKey();
      scatter.setInt(rowNo - 1, (String) club.getKey(), (int) pstnVal.getValue());
    }  // ea pstn enclsng brce
  }  // ea club enclsng brce
}  // mthd enclsng brce
//--------------------------------------------------------------------------------//

// Write club's changed pstn to scatter table.
//--------------------------------------------------------------------------------//
void updateScttrVal(String clubNme, int crrntPstn) {
  // Retrieve current count of pstn from the scatter table.
  int crrntCount = scatter.getInt(crrntPstn - 1, clubNme);
  // Incrmnt val up once.
  println(clubNme + " crrnt is " + crrntPstn);  // debug - delete
  scatter.setInt(crrntPstn - 1, clubNme, crrntCount + 1);
}  // mthd enclsng brce
//--------------------------------------------------------------------------------//


//--------------------------------------------------------------------------------//
//------------------------------ Functionality End -------------------------------//
//--------------------------------------------------------------------------------//