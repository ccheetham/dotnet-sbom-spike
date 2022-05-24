# .NET SBOM Spike

This spike creates a buildpack to generate NuGet and .NET runtime/framework SBOMS.

Status:

* NuGet SBOM(s): done
* Runtime SBOM(s): done


## Prep

enable sample builder:
```
$ pack config default-builder cnbs/sample-builder:bionic
$ pack config trusted-builders add cnbs/sample-builder:bionic
```
prepare sample apps:
```
$ bin/prepapp.sh -c etc/apps.conf
```

## Overview

to see a list of available apps, run:
```
$ bin/packapp.sh -l
```

to build and pack an app, specify the app name:
```
$ bin/packapp.sh -a webapi-net60
```

after running, SBOMs downloaded to `sboms` directory:
```
$ tree sboms/webapi-net60
sboms/webapi-net60
└── layers
    └── sbom
        └── launch
            └── spike_dotnet-sbom
                ├── microsoft_aspnetcore_app
                │   ├── sbom.cdx.json
                │   └── sbom.syft.json
                ├── microsoft_netcore_app
                │   ├── sbom.cdx.json
                │   └── sbom.syft.json
                └── webapi-net60
                    ├── sbom.cdx.json
                    └── sbom.syft.json

```

## Implementation Details

`packapp.sh` does the following:
* runs `dotnet restore`
* runs `dotnet build`
* runs `dotnet publish`
* stores deps files in the app project's `deps` dir (more details to follow)
* runs the local syft buildpack (more detailed to follow)
* downloads the image SBOMs to the `sboms/APPNAME` dir

The local syft buildpack simply iterates over the files in the `deps` dir, creating a layer and SBOMs for each.

The deps files are discovered as such:
* the NuGet deps come from the `APPNAME.deps.json` file in the `publish` dir
* the app runtimes are described in the file `APPNAME.runtimeconfig.json` in the `publish` dir
* for every runtime described, the runtime deps come from the file `DOTNET_HOME/shared/RUNTIME/VERSION/RUNTIME.deps.json`

For more details on how runtime deps can bederived, see https://github.com/dotnet/runtime/blob/main/docs/design/features/sharedfx-lookup.md
