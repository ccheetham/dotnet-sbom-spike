# .NET SBOM Spike

This spike looks at Syft's capabilities _vis-a-vis_ .NET.

## Overview

to see a list of available apps, run:
```
$ bin/sbom.sh -l
```

to see Syft package output for an app, run:
```
$ bin/sbom.sh -a webapi-net60
```

For more details on how .NET deps can be derived, see https://github.com/dotnet/runtime/blob/main/docs/design/features/sharedfx-lookup.md
