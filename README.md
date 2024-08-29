# XIA Cosmos Template
## Introduction
1. Cosmos is the root component
2. Realm represents a directory-like component holds Foundation as file-like objects
3. Foundation represents a socle on which application should run on
```mermaid
graph TD
    Cosmos -->|Contains| Realm_A
    Realm_A -->|Holds| Realm_B
    Realm_A -->|Manages| Foundation_A
    Realm_B -->|Manages| Foundation_B
    Foundation_A -->|Manages| Application_A1
    Foundation_A -->|Manages| Application_A2
    Foundation_B -->|Manages| Application_B1
    Foundation_B -->|Manages| Application_B2
```

## Usage
### Bigbang
Bigbang is the beginning of the initialization which creates the terraform backend.
`make bigbang topology=<topology> params="<key>:<value> <key>:<value>"'`

### Initialization of modules
Initialization of the module to be used in cosmos
`make init-module module_uri=<package_name>@<version>/<module_name>"`

### Activation of modules
Activation of the module to be used in foundation
`make init-module module_uri=<package_name>@<version>/<module_name>"`
