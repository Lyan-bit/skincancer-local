	                  
import Foundation
import SwiftUI


func instanceFromJSON(typeName: String, json: String) -> AnyObject?
	{ let jdata = json.data(using: .utf8)!
	  let decoder = JSONDecoder()
	  if typeName == "String"
	  { let x = try? decoder.decode(String.self, from: jdata)
	      return x as AnyObject
	  }
  return nil
	}

class ModelFacade : ObservableObject {
		                      
	static var instance : ModelFacade? = nil
	private var modelParser : ModelParser? = ModelParser(modelFileInfo: ModelFile.modelInfo)
	var db : DB?
		
	// path of document directory for SQLite database (absolute path of db)
	let dbpath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
	var fileSystem : FileAccessor = FileAccessor()

	static func getInstance() -> ModelFacade { 
		if instance == nil
	     { instance = ModelFacade() 
	      }
	    return instance! }
	                          
	init() { 
		// init
		db = DB.obtainDatabase(path: "\(dbpath)/myDatabase.sqlite3")
		loadSkinCancer()
	}
	      
	@Published var currentSkinCancer : SkinCancerVO? = SkinCancerVO.defaultSkinCancerVO()
	@Published var currentSkinCancers : [SkinCancerVO] = [SkinCancerVO]()

	func createSkinCancer(x : SkinCancerVO) {
		  let res : SkinCancer = createByPKSkinCancer(key: x.id)
				res.id = x.id
		res.dates = x.dates
		res.images = x.images
		res.outcome = x.outcome
		  currentSkinCancer = x
		  do { try db?.createSkinCancer(skinCancervo: x) }
		  catch { print("Error creating SkinCancer") }
	}
		
	func cancelCreateSkinCancer() {
		//cancel function
	}
	
	func deleteSkinCancer(id : String) {
		  if db != nil
	      { db!.deleteSkinCancer(val: id) }
	     	currentSkinCancer = nil
	}
		
	func cancelDeleteSkinCancer() {
		//cancel function
	}
			
	func cancelEditSkinCancer() {
		//cancel function
	}

	func cancelSearchSkinCancer() {
	//cancel function
}

    func imageRecognition(x : String) -> String {
        guard let obj = getSkinCancerByPK(val: x)
        else {
            return "Please selsect valid id"
        }
        
		let dataDecoded = Data(base64Encoded: obj.images, options: .ignoreUnknownCharacters)
		let decodedimage:UIImage = UIImage(data: dataDecoded! as Data)!
        		
    	guard let pixelBuffer = decodedimage.pixelBuffer() else {
        	return "Error"
    	}
    
        // Hands over the pixel buffer to ModelDatahandler to perform inference
        let inferencesResults = modelParser?.runModel(onFrame: pixelBuffer)
        
        // Formats inferences and resturns the results
        guard let firstInference = inferencesResults else {
          return "Error"
        }
        
        obj.outcome = firstInference[0].label
        persistSkinCancer(x: obj)
        
        return firstInference[0].label
        
    }
    
	func cancelImageRecognition() {
		//cancel function
	}
	    

	func loadSkinCancer() {
		let res : [SkinCancerVO] = listSkinCancer()
		
		for (_,x) in res.enumerated() {
			let obj = createByPKSkinCancer(key: x.id)
	        obj.id = x.getId()
        obj.dates = x.getDates()
        obj.images = x.getImages()
        obj.outcome = x.getOutcome()
			}
		 currentSkinCancer = res.first
		 currentSkinCancers = res
		}
		
  		func listSkinCancer() -> [SkinCancerVO] {
			if db != nil
			{ currentSkinCancers = (db?.listSkinCancer())!
			  return currentSkinCancers
			}
			currentSkinCancers = [SkinCancerVO]()
			let list : [SkinCancer] = SkinCancerAllInstances
			for (_,x) in list.enumerated()
			{ currentSkinCancers.append(SkinCancerVO(x: x)) }
			return currentSkinCancers
		}
				
		func stringListSkinCancer() -> [String] { 
			currentSkinCancers = listSkinCancer()
			var res : [String] = [String]()
			for (_,obj) in currentSkinCancers.enumerated()
			{ res.append(obj.toString()) }
			return res
		}
				
		func getSkinCancerByPK(val: String) -> SkinCancer? {
			var res : SkinCancer? = SkinCancer.getByPKSkinCancer(index: val)
			if res == nil && db != nil
			{ let list = db!.searchBySkinCancerid(val: val)
			if list.count > 0
			{ res = createByPKSkinCancer(key: val)
			}
		  }
		  return res
		}
				
		func retrieveSkinCancer(val: String) -> SkinCancer? {
			let res : SkinCancer? = getSkinCancerByPK(val: val)
			return res 
		}
				
		func allSkinCancerids() -> [String] {
			var res : [String] = [String]()
			for (_,item) in currentSkinCancers.enumerated()
			{ res.append(item.id + "") }
			return res
		}
				
		func setSelectedSkinCancer(x : SkinCancerVO)
			{ currentSkinCancer = x }
				
		func setSelectedSkinCancer(i : Int) {
			if 0 <= i && i < currentSkinCancers.count
			{ currentSkinCancer = currentSkinCancers[i] }
		}
				
		func getSelectedSkinCancer() -> SkinCancerVO?
			{ return currentSkinCancer }
				
		func persistSkinCancer(x : SkinCancer) {
			let vo : SkinCancerVO = SkinCancerVO(x: x)
			editSkinCancer(x: vo)
		}
			
		func editSkinCancer(x : SkinCancerVO) {
			let val : String = x.id
			let res : SkinCancer? = SkinCancer.getByPKSkinCancer(index: val)
			if res != nil {
			res!.id = x.id
		res!.dates = x.dates
		res!.images = x.images
		res!.outcome = x.outcome
		}
		currentSkinCancer = x
			if db != nil
			 { db!.editSkinCancer(skinCancervo: x) }
		 }
			
	    func cancelSkinCancerEdit() {
	    	//cancel function
	    }
	    
 	func searchBySkinCancerid(val : String) -> [SkinCancerVO]
		  { 
		      if db != nil
		        { let res = (db?.searchBySkinCancerid(val: val))!
		          return res
		        }
		    currentSkinCancers = [SkinCancerVO]()
		    let list : [SkinCancer] = SkinCancerAllInstances
		    for (_,x) in list.enumerated()
		    { if x.id == val
		      { currentSkinCancers.append(SkinCancerVO(x: x)) }
		    }
		    return currentSkinCancers
		  }
		  
 	func searchBySkinCancerdates(val : String) -> [SkinCancerVO]
		  { 
		      if db != nil
		        { let res = (db?.searchBySkinCancerdates(val: val))!
		          return res
		        }
		    currentSkinCancers = [SkinCancerVO]()
		    let list : [SkinCancer] = SkinCancerAllInstances
		    for (_,x) in list.enumerated()
		    { if x.dates == val
		      { currentSkinCancers.append(SkinCancerVO(x: x)) }
		    }
		    return currentSkinCancers
		  }
		  
 	func searchBySkinCancerimages(val : String) -> [SkinCancerVO]
		  { 
		      if db != nil
		        { let res = (db?.searchBySkinCancerimages(val: val))!
		          return res
		        }
		    currentSkinCancers = [SkinCancerVO]()
		    let list : [SkinCancer] = SkinCancerAllInstances
		    for (_,x) in list.enumerated()
		    { if x.images == val
		      { currentSkinCancers.append(SkinCancerVO(x: x)) }
		    }
		    return currentSkinCancers
		  }
		  
 	func searchBySkinCanceroutcome(val : String) -> [SkinCancerVO]
		  { 
		      if db != nil
		        { let res = (db?.searchBySkinCanceroutcome(val: val))!
		          return res
		        }
		    currentSkinCancers = [SkinCancerVO]()
		    let list : [SkinCancer] = SkinCancerAllInstances
		    for (_,x) in list.enumerated()
		    { if x.outcome == val
		      { currentSkinCancers.append(SkinCancerVO(x: x)) }
		    }
		    return currentSkinCancers
		  }
		  

	}
