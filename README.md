# .NET SBOM Spike

This spike creates a buildpack to generate NuGet and .NET runtime/framework SBOMS.

The buildpack does not alter the application being packed, e.g. it does not run `dotnet build`.
Instead, all app prepwork is expected to be done prior to packing.


Status:

    * NuGet SBOM: in progress
    * Runtime/Framework SBOM: not started

## Prep

```
$ pack config default-builder cnbs/sample-builder:bionic
$ pack config trusted-builders add cnbs/sample-builder:bionic
```

## Basic Usage

```
$ pack build IMAGE --path APPPATH --buildpack ./buildpack
```

## Overriding Syft Version

```
$ echo '0.46.1' > APPPATH/.syft-version
```

## Running Buildpack on Sample Applications

Generate sample apps:
```
$ ./genapp < apps.conf
==> generating console-net50 ...
The template "Console Application" was created successfully.
--> ... restoring ...
  Determining projects to restore...
...
--> ... building ...
Microsoft (R) Build Engine version 17.0.0+c9eb9dd64 for .NET
...
--> ... generated console-net50
...

$ ls -1 apps/
console-net50
console-net60
mvc-net50
mvc-net60
steeltoe-webapi-net50
steeltoe-webapi-net60
web-net50
web-net60
webapi-net50
webapi-net60
```

Run buildpack using a sample app:
```
$ pack build webapi-net60 --path apps/webapi-net60 --buildpack ./buildpack
```

## Downloading SBOM

```
$ pack sbom download webapi-net60
$ tree layers
layers
└── sbom
    └── launch
        └── spike_dotnet-sbom
            └── webapi-net60
                └── sbom.cdx.json
```
