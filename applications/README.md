# Unity Marketplace Example

This folder contains an example "Application Catalog".  The management console requires that the repository contain a top-level folder called "applications" which contains applications in folders with specific versions

## Overview

This catalog makes use of the Terraform Modules defined in this repository via the `module-registry.json` at the top-level.  This file is not required in an Application Catalog and can optional be installed in the MC workdir, but for documentation purposes a simple example is given in this repository.


## Architecture

Note, the S3 module contains a lot of potential features, but has not been validated.  This Application catalog has a simple use shown by the figure below

```
┌─────────────────┐   
│   User Uploads  │   
│   S3 Bucket     │   
│                 │   
│ - User content  │   
│ - Versioned     │   
│ - Encrypted     │   
└─────────────────┘   
```

## Files Structure

```
applications/
├── README.md                        # This file
├── mainifest.json.                  # Cat of the various `metadata.json` file in each app
├── unity-config-marketplace.yaml    # Example `unity.yaml` config
├── simple-demo                      # An Application
    ├── metadata.json                # Metadata for this app
    ├── terraform/                   # Direct Terraform usage examples
         ├── main.tf                 # Main Terraform configuration
         ├── variables.tf            # Input variables
         └── outputs.tf              # Output values
```