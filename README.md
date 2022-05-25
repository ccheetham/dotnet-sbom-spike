# .NET SBOM Spike

This spike looks at Syft's capabilities _vis-a-vis_ dotnet.

## Overview

to see a list of available apps, run:
```
$ bin/sbom.sh -l
```

to see Syft SBOM output for an app, run:
```
$ bin/sbom.sh -a webapi-net60
```

For more details on how dotnet deps can be derived, see https://github.com/dotnet/runtime/blob/main/docs/design/features/sharedfx-lookup.md
