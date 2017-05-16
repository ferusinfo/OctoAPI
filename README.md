# OctoAPI  
![CocoaPods](https://img.shields.io/cocoapods/v/OctoAPI.svg) ![license](https://img.shields.io/cocoapods/l/OctoAPI.svg) ![Platform](https://img.shields.io/cocoapods/p/OctoAPI.svg)

Octo is a JSON API abstraction layer built on top of Alamofire for your iOS projects written in Swift 3.  
It removes the usual and boring setup of API connectors with easy to use set of `Adapter`, `Connector`, `DataParser` and `Paging` classes.

## Todo  
1. Add custom logging
2. Implement error mapping to JSON on call failure
3. Unit Tests

## Installation  
1. Add `pod 'OctoAPI'` to your Podfile
2. Run `pod install`
3. Add `import OctoAPI` wherever you want to use the library

## Example  
An example for GetResponse Blog API can be found in the Example directory of the project.  
It uses no Authorization, making it perfect for testing public APIs.

## Setup  
For each of your APIs used in your project, you need to define a set of classes:

- `OctoConnector` subclass - as a shared instance that you will be calling to make your calls to API with. It implements the `Callable` protocol under the hood. If you need more configuration than the Octo class is providing, you need to implement the `Callable` protocol in your custom class.
- `Adapter` protocol class passed to the `Callable` class with all the necessary configuration of your API
- `Authorization` class if your API requires authorization (Optional) 
- `Paging` class if you want to use paging features in your API (Optional) 

## Basic Usage
If you configure all the necessary classes, the basic usage is as follows:

- You prepare your class using the `OctoRequest` class
- You call the `run` method of your Connector class with the request as a parameter
- You parse the response data with `DataParser` of your choice

```swift
var request = OctoRequest(endpoint: "examples")

ExampleConnector.sharedInstance.run(request: request) { (error, data, paging) in
    if error == nil {
        if let examples = GlossDataParser.parse(collection: data, withType: ExampleModel.self), let example = examples.first {
            //Do anything with the parsed model here
        }
    }
}
```

##Adapter
Adapter protocol class is holding the configuration for your API that is used in your project. Example:

```swift
struct ExampleAPIAdapter : Adapter {
    var productionURL: String = "PRODUCTION_URL_HERE"
    var productionVersion: String = "PRODUCTION_VERSION_HERE"
    var sandboxURL: String = "SANDBOX_URL_HERE"
    var sandboxVersion: String = "SANDBOX_VERSION HERE"
    var mode : AdapterMode = .sandbox //choose over .sandbox or .production
    var errorDomain: String = "com.example.error" //used to map errors
    
    var authorizer: Authorizable? {
        get {
            let params = ExampleAuthParameters(baseURL: versionedURL)
            return GrantTypePasswordAuthorization(parameters: params)
        }
    }
}
```

##Parsing
You can use any object-parsing library of your choice. To use a custom parser in your project, simply implement `DataParser` protocol with two following methods:

```swift
static func parse<T: Decodable>(object: Any?, withType type: T.Type) -> T?
static func parse<T: Decodable>(collection: Any?, withType type: T.Type) -> [T]?
```

The library also comes with built-in suppoort for [Gloss](https://github.com/hkellaway/Gloss) - in my opinion best JSON mapping library for Swift - make a use of it with the `GlossDataParser` class as follows:

```swift
//Object parsing
if let example = GlossDataParser.parse(object: data, withType: ExampleModel.self) {
	//Do anything with the parsed model here
}

//Collection parsing
if let examples = GlossDataParser.parse(collection: data, withType: ExampleModel.self), let example = examples.first {
	//Do anything with the parsed model here
}
```


##Paging
If your API uses paging, create a subclass of `Paging` class, override the parameters to match your API needs and add it to the `OctoBuilder` class when building a request by passing `limit` and `offset` parameters to the initializer.

Paging data parsed from the response is passed into the completion block through `paging` parameter.

You can either use the default approach where paging information is added to the HTTP Headers of the response or use your own implemenation in your `Paging` subclass by overriding the `parse(fromResponse:)` method.

##Authorization
This library has a built-in authorization support. For now the only implementation of the `Authorizable` protocol is the `GrantTypePasswordAuthorization` class with implementation of OAuth 2.0 Grant Type Password type of authorization that holds your access token in the device secure Keychain.

The implementation is calling a given API for a new Access Token if the token has expired during the request, suspending any other requests made on that Connector instance. When the new Access Token is obtained

You can either use this implementation or use your own class with other types of authorization if your application needs it.

To use the Authorization class, you need to provide set of parameters, defined in `AuthorizationParameters` protocol and pass it to the initializer like so:

```swift
struct ExampleAuthParameters : AuthorizationParameters {
    var endpoint: String = "token"
    var serviceName: String = "SERVICE_NAME" //Service name used to store your access token in the Keychain
    var clientID: String = ""
    var baseURL: String //You are most likely to use a baseURL through initializer to match with your versioned URL of the API
    
    public init(baseURL : String) {
        self.baseURL = baseURL
    }
}


let params = ExampleAuthParameters(baseURL: versionedURL)
let authorizer = GrantTypePasswordAuthorization(parameters: params)
```

To use the Authorization class you want to use, pass the object as a `authorizer` parameter to your `Adapter` class. After that, you need to perform an authorization in your project like so:

```swift
if let authorizer = ExampleAPIConnector.sharedInstance.adapter.authorizer {
	let login = ""
	let password = ""
	
	authorizer.performAuthorization(login: login, password: password, completion: { (error) in
	    if error == nil {
	        //run anything you want after the successful authorization
	    } else {
	        //catch any errors
	    }
	})
}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add your changes
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

## License
See [LICENSE](LICENSE.MD)




