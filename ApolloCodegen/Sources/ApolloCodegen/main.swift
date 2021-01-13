import Foundation
import ApolloCodegenLib
import ArgumentParser

// An outer structure to hold all commands and sub-commands handled by this script.
struct SwiftScript: ParsableCommand {

    static var configuration = CommandConfiguration(
            abstract: """
        A swift-based utility for performing Apollo-related tasks.
        
        NOTE: If running from a compiled binary, prefix subcommands with `swift-script`. Otherwise use `swift run ApolloCodgen [subcommand]`.
        """,
            subcommands: [GenerateCode.self, DownloadSchema.self])
    
    /// The sub-command to actually generate code.
    struct GenerateCode: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "generate",
            abstract: "Generates swift code from your schema + your operations based on information set up in the `GenerateCode` command.")
        
        mutating func run() throws {
            let fileStructure = try FileStructure()
            CodegenLogger.log("File structure: \(fileStructure)")
            
            // Create the Codegen options object. This default setup assumes `schema.json` is in the target root folder, all queries are in some kind of subfolder of the target folder and will output as a single file to `API.swift` in the target folder. For alternate setup options, check out https://www.apollographql.com/docs/ios/api/ApolloCodegenLib/structs/ApolloCodegenOptions/
            let codegenOptions = ApolloCodegenOptions(targetRootURL: fileStructure.targetRootURL)
            
            // Actually attempt to generate code.
            try ApolloCodegen.run(from: fileStructure.targetRootURL,
                                  with: fileStructure.cliFolderURL,
                                  options: codegenOptions)
        }
    }
    
    /// The sub-command to download a schema from a provided endpoint.
    struct DownloadSchema: ParsableCommand {
        static var configuration = CommandConfiguration(
            commandName: "downloadSchema",
            abstract: "Downloads the schema with the settings you've set up in the `DownloadSchema` command in `main.swift`.")
        
        mutating func run() throws {
            let fileStructure = try FileStructure()
            CodegenLogger.log("File structure: \(fileStructure)")
            
            // Set up the URL you want to use to download the project
            // TODO: Replace the placeholder with the GraphQL endpoint you're using to download the schema.
            let endpoint = URL(string: "http://localhost:8080/graphql")!
            
            // Create an options object for downloading the schema. Provided code will download the schema as JSON to a file called "schema.json". For full options check out https://www.apollographql.com/docs/ios/api/ApolloCodegenLib/structs/ApolloSchemaOptions/
            let schemaDownloadOptions = ApolloSchemaOptions(endpointURL: endpoint,
                                                            outputFolderURL: fileStructure.folderForDownloadedSchema)
            
            // Actually attempt to download the schema.
            try ApolloSchemaDownloader.run(with: fileStructure.cliFolderURL,
                                           options: schemaDownloadOptions)
        }
    }
}

// This will set up the command and parse the arguments when this executable is run.
SwiftScript.main()
