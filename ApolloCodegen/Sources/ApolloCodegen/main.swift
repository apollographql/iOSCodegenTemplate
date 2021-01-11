import Foundation
import ApolloCodegenLib

// Grab the parent folder of this file on the filesystem
let parentFolderOfScriptFile = FileFinder.findParentFolder()
CodegenLogger.log("Parent folder of script file: \(parentFolderOfScriptFile)")

// Use that to calculate the source root for both your main project and this codegen project.
// NOTE: You may need to change this if your project has a different structure than the suggested structure.
let sourceRootURL = parentFolderOfScriptFile
  .apollo.parentFolderURL() // Result: Sources folder
  .apollo.parentFolderURL() // Result: ApolloCodegen folder
  .apollo.parentFolderURL() // Result: Project source root folder
CodegenLogger.log("Source Root: \(sourceRootURL)")

// Set up the folder where you want the typescript CLI to download.
let cliFolderURL = sourceRootURL
  .apollo.childFolderURL(folderName: "ApolloCodegen")
  .apollo.childFolderURL(folderName: "ApolloCLI")

// MARK: - Download a schema

func downloadSchema() {
    do {
        // Set up the URL you want to use to download the project
        // TODO: Replace the placeholder with the GraphQL endpoint you're using to download the schema.
        let endpoint = URL(string: <#"http://localhost:8080/graphql"#>)!
        
        // Calculate where you want to create the folder where the CLI will be downloaded by the ApolloCodegenLib framework.
        // TODO: Replace the placeholder with the name of the actual folder where you want the downloaded schema saved. The default is set up to put it in your project's root.
        let folderURLForDownloadedSchema = sourceRootURL.apollo.childFolderURL(folderName: <#"MyProject"#>)
        
        try FileManager.default.apollo.createFolderIfNeeded(at: folderURLForDownloadedSchema)
        
        // Create an options object for downloading the schema. Provided code will download the schema as JSON to a file called "schema.json". For full options check out https://www.apollographql.com/docs/ios/api/ApolloCodegenLib/structs/ApolloSchemaOptions/
        let schemaDownloadOptions = ApolloSchemaOptions(endpointURL: endpoint,
                                                        outputFolderURL: folderURLForDownloadedSchema)
        
        // Actually attempt to download the schema.
        try ApolloSchemaDownloader.run(with: cliFolderURL,
                                       options: schemaDownloadOptions)
    } catch {
        CodegenLogger.log("\(error)", logLevel: .error)
        exit(1)
    }
}


// MARK: - Generate code

func generateCode() {
    do {
        // TODO: Replace the placeholder with the folder that contains the target you're generating code for.
        let targetURL = sourceRootURL.apollo.childFolderURL(folderName: <#"MyProject"#>)
        
        // This should theoretically already be created, but in case it's not:
        try FileManager.default.apollo.createFolderIfNeeded(at: targetURL)
        
        // Create the Codegen options object. This default setup assumes `schema.json` is in the target root folder, all queries are in some kind of subfolder of the target folder and will output as a single file to `API.swift` in the target folder. For alternate setup options, check out https://www.apollographql.com/docs/ios/api/ApolloCodegenLib/structs/ApolloCodegenOptions/
        let codegenOptions = ApolloCodegenOptions(targetRootURL: targetURL)
        
        
        // Actually attempt to generate code.
        try ApolloCodegen.run(from: targetURL,
                              with: cliFolderURL,
                              options: codegenOptions)
    } catch {
        CodegenLogger.log("\(error)", logLevel: .error)
        exit(1)
    }
}


// MARK: - Actually run the functions you want to

// NOTE: You probably don't want to run this on every build, so once you've got your schema downloaded, you probably want to comment this out unless you specifically _need_ to run this.
downloadSchema()

// This should be run on every build.
generateCode()
