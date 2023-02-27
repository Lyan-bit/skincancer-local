              
              
import SwiftUI

@main 
struct skincancerMain : App {

	var body: some Scene {
	        WindowGroup {
	            ContentView(model: ModelFacade.getInstance())
	        }
	    }
	} 
