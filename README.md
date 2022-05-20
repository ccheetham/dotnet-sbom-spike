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

## Basic Usage Overview

prepare sample apps:
```
$ bin/prepapp.sh -c etc/apps.conf
```

pack a sample app:
```
$ bin/packapp.sh -a webapi-net60
```

## Advanced Usage

run with -h for command help:
```
$ bin/prepapp.sh -h
$ bin/packapp.sh -h
```
