import Foundation
import SQLite3

/* Code adapted from https://www.raywenderlich.com/6620276-sqlite-with-swift-tutorial-getting-started */

class DB {
  let dbPointer : OpaquePointer?
  static let dbNAME = "skincancerApp.db"
  static let dbVERSION = 1

  static let skinCancerTABLENAME = "SkinCancer"
  static let skinCancerID = 0
  static let skinCancerCOLS : [String] = ["TableId", "id", "dates", "images", "outcome"]
  static let skinCancerNUMBERCOLS = 0

  static let skinCancerCREATESCHEMA =
    "create table SkinCancer (TableId integer primary key autoincrement" + 
        ", id VARCHAR(50) not null"  +
        ", dates VARCHAR(50) not null"  +
        ", images VARCHAR(50) not null"  +
        ", outcome VARCHAR(50) not null"  +
	"" + ")"
	
  private init(dbPointer: OpaquePointer?)
  { self.dbPointer = dbPointer }

  func createDatabase() throws
  { do 
    { 
    try createTable(table: DB.skinCancerCREATESCHEMA)
      print("Created database")
    }
    catch { print("Errors: " + errorMessage) }
  }

  static func obtainDatabase(path: String) -> DB?
  {
    var db : DB? = nil
    if FileAccessor.fileExistsAbsolutePath(filename: path)
    { print("Database already exists")
      do
      { try db = DB.open(path: path)
        if db != nil
        { print("Opened database") }
        else
        { print("Failed to open existing database") }
      }
      catch { print("Error opening existing database") 
              return nil 
            }
    }
    else
    { print("New database will be created")
      do
      { try db = DB.open(path: path)
        if db != nil
        { print("Opened new database") 
          try db!.createDatabase() 
        }
        else
        { print("Failed to open new database") }
      }
      catch { print("Error opening new database")  
              return nil }
    }
    return db
  }

  fileprivate var errorMessage: String
  { if let errorPointer = sqlite3_errmsg(dbPointer)
    { let eMessage = String(cString: errorPointer)
      return eMessage
    } 
    else 
    { return "Unknown error from sqlite." }
  }
  
  func prepareStatement(sql: String) throws -> OpaquePointer?   
  { var statement: OpaquePointer?
    guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) 
        == SQLITE_OK
    else 
    { return nil }
    return statement
  }
  
  static func open(path: String) throws -> DB? 
  { var db: OpaquePointer?
  
    if sqlite3_open(path, &db) == SQLITE_OK 
    { return DB(dbPointer: db) }
    else 
    { defer 
      { if db != nil 
        { sqlite3_close(db) }
      }
  
      if let errorPointer = sqlite3_errmsg(db)
      { let message = String(cString: errorPointer)
        print("Error opening database: " + message)
      } 
      else 
      { print("Unknown error opening database") }
      return nil
    }
  }
  
  func createTable(table: String) throws
  { let createTableStatement = try prepareStatement(sql: table)
    defer 
    { sqlite3_finalize(createTableStatement) }
    
    guard sqlite3_step(createTableStatement) == SQLITE_DONE 
    else
    { print("Error creating table") 
      return
    }
    print("table " + table + " created.")
  }

  func listSkinCancer() -> [SkinCancerVO]
  { var res : [SkinCancerVO] = [SkinCancerVO]()
    let statement = "SELECT * FROM SkinCancer "
    let queryStatement = try? prepareStatement(sql: statement)
    if queryStatement == nil { 
    	return res
    }
    
    while (sqlite3_step(queryStatement) == SQLITE_ROW)
    { //let id = sqlite3_column_int(queryStatement, 0)
      let skinCancervo = SkinCancerVO()
      
    guard let queryResultSkinCancerCOLID = sqlite3_column_text(queryStatement, 1) 
    else { return res } 
    let id = String(cString: queryResultSkinCancerCOLID) 
    skinCancervo.setId(x: id) 

    guard let queryResultSkinCancerCOLDATES = sqlite3_column_text(queryStatement, 2) 
    else { return res } 
    let dates = String(cString: queryResultSkinCancerCOLDATES) 
    skinCancervo.setDates(x: dates) 

    guard let queryResultSkinCancerCOLIMAGES = sqlite3_column_text(queryStatement, 3) 
    else { return res } 
    let images = String(cString: queryResultSkinCancerCOLIMAGES) 
    skinCancervo.setImages(x: images) 

    guard let queryResultSkinCancerCOLOUTCOME = sqlite3_column_text(queryStatement, 4) 
    else { return res } 
    let outcome = String(cString: queryResultSkinCancerCOLOUTCOME) 
    skinCancervo.setOutcome(x: outcome) 

      res.append(skinCancervo)
    }
    sqlite3_finalize(queryStatement)
    return res
  }

  func createSkinCancer(skinCancervo : SkinCancerVO) throws
  { let insertSQL : String = "INSERT INTO SkinCancer (id, dates, images, outcome) VALUES (" 
     + "'" + skinCancervo.getId() + "'" + "," 
     + "'" + skinCancervo.getDates() + "'" + "," 
     + "'" + skinCancervo.getImages() + "'" + "," 
     + "'" + skinCancervo.getOutcome() + "'"
      + ")"
    let insertStatement = try prepareStatement(sql: insertSQL)
    defer 
    { sqlite3_finalize(insertStatement)
    }
    sqlite3_step(insertStatement)
  }

  func searchBySkinCancerid(val : String) -> [SkinCancerVO]
	  { var res : [SkinCancerVO] = [SkinCancerVO]()
	    let statement : String = "SELECT * FROM SkinCancer WHERE id = " + "'" + val + "'" 
	    let queryStatement = try? prepareStatement(sql: statement)
	    
	    while (sqlite3_step(queryStatement) == SQLITE_ROW)
	    { //let id = sqlite3_column_int(queryStatement, 0)
	      let skinCancervo = SkinCancerVO()
	      
	      guard let queryResultSkinCancerCOLID = sqlite3_column_text(queryStatement, 1)
		      else { return res }	      
		      let id = String(cString: queryResultSkinCancerCOLID)
		      skinCancervo.setId(x: id)
	      guard let queryResultSkinCancerCOLDATES = sqlite3_column_text(queryStatement, 2)
		      else { return res }	      
		      let dates = String(cString: queryResultSkinCancerCOLDATES)
		      skinCancervo.setDates(x: dates)
	      guard let queryResultSkinCancerCOLIMAGES = sqlite3_column_text(queryStatement, 3)
		      else { return res }	      
		      let images = String(cString: queryResultSkinCancerCOLIMAGES)
		      skinCancervo.setImages(x: images)
	      guard let queryResultSkinCancerCOLOUTCOME = sqlite3_column_text(queryStatement, 4)
		      else { return res }	      
		      let outcome = String(cString: queryResultSkinCancerCOLOUTCOME)
		      skinCancervo.setOutcome(x: outcome)

	      res.append(skinCancervo)
	    }
	    sqlite3_finalize(queryStatement)
	    return res
	  }
	  
  func searchBySkinCancerdates(val : String) -> [SkinCancerVO]
	  { var res : [SkinCancerVO] = [SkinCancerVO]()
	    let statement : String = "SELECT * FROM SkinCancer WHERE dates = " + "'" + val + "'" 
	    let queryStatement = try? prepareStatement(sql: statement)
	    
	    while (sqlite3_step(queryStatement) == SQLITE_ROW)
	    { //let id = sqlite3_column_int(queryStatement, 0)
	      let skinCancervo = SkinCancerVO()
	      
	      guard let queryResultSkinCancerCOLID = sqlite3_column_text(queryStatement, 1)
		      else { return res }	      
		      let id = String(cString: queryResultSkinCancerCOLID)
		      skinCancervo.setId(x: id)
	      guard let queryResultSkinCancerCOLDATES = sqlite3_column_text(queryStatement, 2)
		      else { return res }	      
		      let dates = String(cString: queryResultSkinCancerCOLDATES)
		      skinCancervo.setDates(x: dates)
	      guard let queryResultSkinCancerCOLIMAGES = sqlite3_column_text(queryStatement, 3)
		      else { return res }	      
		      let images = String(cString: queryResultSkinCancerCOLIMAGES)
		      skinCancervo.setImages(x: images)
	      guard let queryResultSkinCancerCOLOUTCOME = sqlite3_column_text(queryStatement, 4)
		      else { return res }	      
		      let outcome = String(cString: queryResultSkinCancerCOLOUTCOME)
		      skinCancervo.setOutcome(x: outcome)

	      res.append(skinCancervo)
	    }
	    sqlite3_finalize(queryStatement)
	    return res
	  }
	  
  func searchBySkinCancerimages(val : String) -> [SkinCancerVO]
	  { var res : [SkinCancerVO] = [SkinCancerVO]()
	    let statement : String = "SELECT * FROM SkinCancer WHERE images = " + "'" + val + "'" 
	    let queryStatement = try? prepareStatement(sql: statement)
	    
	    while (sqlite3_step(queryStatement) == SQLITE_ROW)
	    { //let id = sqlite3_column_int(queryStatement, 0)
	      let skinCancervo = SkinCancerVO()
	      
	      guard let queryResultSkinCancerCOLID = sqlite3_column_text(queryStatement, 1)
		      else { return res }	      
		      let id = String(cString: queryResultSkinCancerCOLID)
		      skinCancervo.setId(x: id)
	      guard let queryResultSkinCancerCOLDATES = sqlite3_column_text(queryStatement, 2)
		      else { return res }	      
		      let dates = String(cString: queryResultSkinCancerCOLDATES)
		      skinCancervo.setDates(x: dates)
	      guard let queryResultSkinCancerCOLIMAGES = sqlite3_column_text(queryStatement, 3)
		      else { return res }	      
		      let images = String(cString: queryResultSkinCancerCOLIMAGES)
		      skinCancervo.setImages(x: images)
	      guard let queryResultSkinCancerCOLOUTCOME = sqlite3_column_text(queryStatement, 4)
		      else { return res }	      
		      let outcome = String(cString: queryResultSkinCancerCOLOUTCOME)
		      skinCancervo.setOutcome(x: outcome)

	      res.append(skinCancervo)
	    }
	    sqlite3_finalize(queryStatement)
	    return res
	  }
	  
  func searchBySkinCanceroutcome(val : String) -> [SkinCancerVO]
	  { var res : [SkinCancerVO] = [SkinCancerVO]()
	    let statement : String = "SELECT * FROM SkinCancer WHERE outcome = " + "'" + val + "'" 
	    let queryStatement = try? prepareStatement(sql: statement)
	    
	    while (sqlite3_step(queryStatement) == SQLITE_ROW)
	    { //let id = sqlite3_column_int(queryStatement, 0)
	      let skinCancervo = SkinCancerVO()
	      
	      guard let queryResultSkinCancerCOLID = sqlite3_column_text(queryStatement, 1)
		      else { return res }	      
		      let id = String(cString: queryResultSkinCancerCOLID)
		      skinCancervo.setId(x: id)
	      guard let queryResultSkinCancerCOLDATES = sqlite3_column_text(queryStatement, 2)
		      else { return res }	      
		      let dates = String(cString: queryResultSkinCancerCOLDATES)
		      skinCancervo.setDates(x: dates)
	      guard let queryResultSkinCancerCOLIMAGES = sqlite3_column_text(queryStatement, 3)
		      else { return res }	      
		      let images = String(cString: queryResultSkinCancerCOLIMAGES)
		      skinCancervo.setImages(x: images)
	      guard let queryResultSkinCancerCOLOUTCOME = sqlite3_column_text(queryStatement, 4)
		      else { return res }	      
		      let outcome = String(cString: queryResultSkinCancerCOLOUTCOME)
		      skinCancervo.setOutcome(x: outcome)

	      res.append(skinCancervo)
	    }
	    sqlite3_finalize(queryStatement)
	    return res
	  }
	  

  func editSkinCancer(skinCancervo : SkinCancerVO)
  { var updateStatement: OpaquePointer?
    let statement : String = "UPDATE SkinCancer SET " 
    + " dates = '"+skinCancervo.getDates() + "'" 
 + "," 
    + " images = '"+skinCancervo.getImages() + "'" 
 + "," 
    + " outcome = '"+skinCancervo.getOutcome() + "'" 
    + " WHERE id = '" + skinCancervo.getId() + "'" 

    if sqlite3_prepare_v2(dbPointer, statement, -1, &updateStatement, nil) == SQLITE_OK
    { sqlite3_step(updateStatement) }
    sqlite3_finalize(updateStatement)
  }

  func deleteSkinCancer(val : String)
  { let deleteStatementString = "DELETE FROM SkinCancer WHERE id = '" + val + "'"
    var deleteStatement: OpaquePointer?
    
    if sqlite3_prepare_v2(dbPointer, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK
    { sqlite3_step(deleteStatement) }
    sqlite3_finalize(deleteStatement)
  }


  deinit
  { sqlite3_close(self.dbPointer) }

}

