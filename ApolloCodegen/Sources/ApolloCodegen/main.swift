import Foundation
import ApolloCodegenLib
import ArgumentParser

// An object representing the filesystem structure. Allows you to grab references to folders in the filesystem without having to pass them through as environment variables.
struct FileStructure {
    
    let sourceRootURL: URL
    let cliFolderURL: URL
    
    init() {
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
    }
}

extension FileStructure: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        Source root URL: \(self.sourceRootURL)
        CLI folder URL: \(self.cliFolderURL)
        """
    }
}

struct SwiftScript: ParsableCommand {

    static var configuration = CommandConfiguration(
            abstract: """
        A swift-based utility for performing Apollo-related tasks.
        
        NOTE: If running from a compiled binary, prefix subcommands with `swift-script`. Otherwise use `swift run ApolloCodgen [subcommand]`.
        """,
            subcommands: [GenerateCode.self, DownloadSchema.self])
    
    struct GenerateCode: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "generate",
            abstract: "Generates code with the settings you've set up")
        
        mutating func run() throws {
            CodegenLogger.log("Running code generation")
            
            let fileStructure = FileStructure()
            
            // TODO: Replace the placeholder with the folder that contains the target you're generating code for.
            let targetURL = fileStructure.sourceRootURL.apollo.childFolderURL(folderName: <#"MyProject"#>)
            
            // This should theoretically already be created, but in case it's not:
            try FileManager.default.apollo.createFolderIfNeeded(at: targetURL)
            
            // Create the Codegen options object. This default setup assumes `schema.json` is in the target root folder, all queries are in some kind of subfolder of the target folder and will output as a single file to `API.swift` in the target folder. For alternate setup options, check out https://www.apollographql.com/docs/ios/api/ApolloCodegenLib/structs/ApolloCodegenOptions/
            let codegenOptions = ApolloCodegenOptions(targetRootURL: targetURL)
            
            // Actually attempt to generate code.
            try ApolloCodegen.run(from: targetURL,
                                  with: fileStructure.cliFolderURL,
                                  options: codegenOptions)
        }
    }
    
    struct DownloadSchema: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "downloadSchema",
            abstract: "Downloads the schema with the settings you've set up")
        
        mutating func run() throws {
            let fileStructure = FileStructure()
            
            // Set up the URL you want to use to download the project
            // TODO: Replace the placeholder with the GraphQL endpoint you're using to download the schema.
            let endpoint = URL(string: <#"http://localhost:8080/graphql"#>)!
            
            // Calculate where you want to create the folder where the CLI will be downloaded by the ApolloCodegenLib framework.
            // TODO: Replace the placeholder with the name of the actual folder where you want the downloaded schema saved. The default is set up to put it in your project's root.
            let folderURLForDownloadedSchema = fileStructure.sourceRootURL.apollo.childFolderURL(folderName: <#"MyProject"#>)
            
            try FileManager.default.apollo.createFolderIfNeeded(at: folderURLForDownloadedSchema)
            
            // Create an options object for downloading the schema. Provided code will download the schema as JSON to a file called "schema.json". For full options check out https://www.apollographql.com/docs/ios/api/ApolloCodegenLib/structs/ApolloSchemaOptions/
            let schemaDownloadOptions = ApolloSchemaOptions(endpointURL: endpoint,
                                                            outputFolderURL: folderURLForDownloadedSchema)
            
            // Actually attempt to download the schema.
            try ApolloSchemaDownloader.run(with: fileStructure.cliFolderURL,
                                           options: schemaDownloadOptions)
        }
    }
}

// This will set up the command and parse the arguments when this is run.
SwiftScript.main()
