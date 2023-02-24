## gomod2nix-failure-repro

This repository exists to demonstrate a build problem using `gomod2nix`.

[The `gomod2nix` bug report is here.](https://github.com/nix-community/gomod2nix/issues/110)

### dev shell
- If you have `direnv`, run `direnv allow .`
  - If you have `lorri`, then run `lorri watch --once`
- If you have flakes, run `nix develop`
- If you just have standard nix, run `nix-shell`

### repro

Building the package with `go` succeeds:

```bash
go build -o demo .
./demo
```

Building the package with `pkgs.buildGoModule` (stdlib) succeeds:

```bash
nix build .#working
./result/bin/gomod2nix-failure-repro
```

Building the package with `pkgs.buildGoApplication` (gomod2nix) fails:

```bash
nix build .#broken
```

``` shell
$ nix build .#broken
warning: Git tree '/Users/pd/code/gomod2nix-failure-repro' is dirty
error: builder for '/nix/store/92rq9r8nv8nhpdl0z9dnic98hhizmw4y-demo-0.0.1.drv' failed with exit code 1;
       last 10 log lines:
       > unpacking sources
       > unpacking source archive /nix/store/x5s2b55ans4iz9alw39n3zw95bp2515g-1bgxmfm63niqndrby5yxqb55dlm97ncz-source
       > source root is 1bgxmfm63niqndrby5yxqb55dlm97ncz-source
       > patching sources
       > updateAutotoolsGnuConfigScriptsPhase
       > configuring
       > building
       > Building subPackage .
       > vendor/go.opentelemetry.io/otel/exporters/otlp/otlptrace/exporter.go:22:2: cannot find package "." in:
       > 	/private/tmp/nix-build-demo-0.0.1.drv-0/1bgxmfm63niqndrby5yxqb55dlm97ncz-source/vendor/go.opentelemetry.io/otel/exporters/otlp/internal
       For full logs, run 'nix log /nix/store/92rq9r8nv8nhpdl0z9dnic98hhizmw4y-demo-0.0.1.drv'.
$ nix log /nix/store/92rq9r8nv8nhpdl0z9dnic98hhizmw4y-demo-0.0.1.drv
@nix { "action": "setPhase", "phase": "unpackPhase" }
unpacking sources
unpacking source archive /nix/store/x5s2b55ans4iz9alw39n3zw95bp2515g-1bgxmfm63niqndrby5yxqb55dlm97ncz-source
source root is 1bgxmfm63niqndrby5yxqb55dlm97ncz-source
@nix { "action": "setPhase", "phase": "patchPhase" }
patching sources
@nix { "action": "setPhase", "phase": "updateAutotoolsGnuConfigScriptsPhase" }
updateAutotoolsGnuConfigScriptsPhase
@nix { "action": "setPhase", "phase": "configurePhase" }
configuring
@nix { "action": "setPhase", "phase": "buildPhase" }
building
Building subPackage .
vendor/go.opentelemetry.io/otel/exporters/otlp/otlptrace/exporter.go:22:2: cannot find package "." in:
        /private/tmp/nix-build-demo-0.0.1.drv-0/1bgxmfm63niqndrby5yxqb55dlm97ncz-source/vendor/go.opentelemetry.io/otel/exporters/otlp/internal
```

### system details
I was able to reproduce this both on my macos machine and on my wsl2 machine. On macos, here are the details:

```shell
$ uname -a
Darwin pld-mbp-22 21.6.0 Darwin Kernel Version 21.6.0: Wed Aug 10 14:28:23 PDT 2022; root:xnu-8020.141.5~2/RELEASE_ARM64_T6000 arm64 arm Darwin
$ nix --version
nix (Nix) 2.12.0
$ go version
go version go1.19.5 darwin/arm64
$ go env
GO111MODULE=""
GOARCH="arm64"
GOBIN=""
GOCACHE="/Users/pd/Library/Caches/go-build"
GOENV="/Users/pd/Library/Application Support/go/env"
GOEXE=""
GOEXPERIMENT=""
GOFLAGS=""
GOHOSTARCH="arm64"
GOHOSTOS="darwin"
GOINSECURE=""
GOMODCACHE="/Users/pd/.go/pkg/mod"
GONOPROXY=""
GONOSUMDB=""
GOOS="darwin"
GOPATH="/Users/pd/.go"
GOPRIVATE=""
GOPROXY="https://proxy.golang.org,direct"
GOROOT="/nix/store/lzn1nmznnsvlm77cp6xllvs5blkvnjbp-go-1.19.5/share/go"
GOSUMDB="sum.golang.org"
GOTMPDIR=""
GOTOOLDIR="/nix/store/lzn1nmznnsvlm77cp6xllvs5blkvnjbp-go-1.19.5/share/go/pkg/tool/darwin_arm64"
GOVCS=""
GOVERSION="go1.19.5"
GCCGO="gccgo"
AR="ar"
CC="clang"
CXX="clang++"
CGO_ENABLED="1"
GOMOD="/Users/pd/code/gomod2nix-failure-repro/go.mod"
GOWORK=""
CGO_CFLAGS="-g -O2"
CGO_CPPFLAGS=""
CGO_CXXFLAGS="-g -O2"
CGO_FFLAGS="-g -O2"
CGO_LDFLAGS="-g -O2"
PKG_CONFIG="pkg-config"
GOGCCFLAGS="-fPIC -arch arm64 -pthread -fno-caret-diagnostics -Qunused-arguments -fmessage-length=0 -fdebug-prefix-map=/var/folders/2d/sv07yzkj71xfjh86ynxr3c180000gn/T/go-build945189084=/tmp/go-build -gno-record-gcc-switches -fno-common"
```
