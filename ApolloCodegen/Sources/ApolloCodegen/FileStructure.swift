import Foundation
import ApolloCodegenLib

// An object representing the filesystem structure. Allows you to grab references to folders in the filesystem without having to pass them through as environment variables.
struct FileStructure {
    
    let sourceRootURL: URL
    let cliFolderURL: URL
    
    let folderForDownloadedSchema: URL
    let targetRootURL: URL
    
    init() throws {
        // Grab the parent folder of this file on the filesystem
        let parentFolderOfScriptFile = FileFinder.findParentFolder()
        CodegenLogger.log("Parent folder of script file: \(parentFolderOfScriptFile)")

        // Use that to calculate the source root for both your main project and this codegen project.
        // NOTE: You may need to change this if your project has a different structure than the suggested structure.
        self.sourceRootURL = parentFolderOfScriptFile
          .apollo.parentFolderURL() // Result: Sources folder
          .apollo.parentFolderURL() // Result: ApolloCodegen folder
          .apollo.parentFolderURL() // Result: Project source root folder

        // Set up the folder where you want the typescript CLI to download.
        self.cliFolderURL = sourceRootURL
          .apollo.childFolderURL(folderName: "ApolloCodegen")
          .apollo.childFolderURL(folderName: "ApolloCLI")
        
        // Calculate where you want to create the folder where the schema will be downloaded by the ApolloCodegenLib framework.
        // TODO: Replace the placeholder with the name of the actual folder where you want the downloaded schema saved. The default is set up to put it in your project's root.
        self.folderForDownloadedSchema = self.sourceRootURL
            .apollo.childFolderURL(folderName: "MyProject")
        
        try FileManager.default.apollo.createFolderIfNeeded(at: self.folderForDownloadedSchema)
        
        // TODO: Replace the placeholder with the folder that contains the target you're generating code for. Note that the placeholder currently has this as the same as the folder for the downloaded schema, but this does not have to be the case.
        self.targetRootURL = self.sourceRootURL
            .apollo.childFolderURL(folderName: "MyProject")
        
        try FileManager.default.apollo.createFolderIfNeeded(at: self.targetRootURL)
    }
}

extension FileStructure: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        Source root URL: \(self.sourceRootURL)
        CLI folder URL: \(self.cliFolderURL)
        Folder for downloaded schema: \(self.folderForDownloadedSchema)
        Target root URL: \(self.targetRootURL)
        """
    }
}
