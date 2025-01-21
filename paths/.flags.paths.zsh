# Library and include paths
## zlib
export LDFLAGS="-L$(brew --prefix zlib)/lib $LDFLAGS"
export CPPFLAGS="-I$(brew --prefix zlib)/include $CPPFLAGS"
export PKG_CONFIG_PATH="$(brew --prefix zlib)/lib/pkgconfig:$PKG_CONFIG_PATH"

## openssl@1.1
export LDFLAGS="-L$(brew --prefix openssl@1.1)/lib $LDFLAGS"
export CPPFLAGS="-I$(brew --prefix openssl@1.1)/include $CPPFLAGS"
export PKG_CONFIG_PATH="$(brew --prefix openssl@1.1)/lib/pkgconfig:$PKG_CONFIG_PATH"

## openssl@3
export LDFLAGS="$LDFLAGS -L$(brew --prefix openssl@3)/lib"
export CPPFLAGS="$CPPFLAGS -I$(brew --prefix openssl@3)/include"
export PKG_CONFIG_PATH="$(brew --prefix openssl@3)/lib/pkgconfig:$PKG_CONFIG_PATH"

## librdkafka (for confluent-kafka)
export C_INCLUDE_PATH="$(brew --prefix librdkafka)/include:$C_INCLUDE_PATH"
export LIBRARY_PATH="$(brew --prefix librdkafka)/lib:$LIBRARY_PATH"

## openblas (for numpy)
export OPENBLAS="$(brew --prefix openblas)"

## postgresql@12 (for psycopg2)
export LDFLAGS="-L$(brew --prefix openssl)/lib -L$(brew --prefix postgresql@12)/lib $LDFLAGS"
export CPPFLAGS="-I$(brew --prefix openssl)/include -I$(brew --prefix postgresql@12)/include $CPPFLAGS"
export PKG_CONFIG_PATH="$(brew --prefix postgresql@12)/lib/pkgconfig:$PKG_CONFIG_PATH"

## Java
export CPPFLAGS="-I$(brew --prefix openjdk@11)/include -I$(brew --prefix openjdk@17)/include $CPPFLAGS"

## icu4c (for pyicu)
export LDFLAGS="-L$(brew --prefix icu4c)/lib $LDFLAGS"
export CPPFLAGS="-I$(brew --prefix icu4c)/include $CPPFLAGS"
export PKG_CONFIG_PATH="$(brew --prefix icu4c)/lib/pkgconfig:$PKG_CONFIG_PATH"

# Environment variables for grpcio
export GRPC_PYTHON_BUILD_SYSTEM_ZLIB=1
