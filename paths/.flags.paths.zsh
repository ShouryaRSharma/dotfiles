# Library and include paths
## zlib
export LDFLAGS="-L/opt/homebrew/opt/zlib/lib $LDFLAGS"
export CPPFLAGS="-I/opt/homebrew/opt/zlib/include $CPPFLAGS"
export PKG_CONFIG_PATH="/opt/homebrew/opt/zlib/lib/pkgconfig:$PKG_CONFIG_PATH"

## openssl@1.1
export LDFLAGS="-L$(brew --prefix openssl@1.1)/lib $LDFLAGS"
export CPPFLAGS="-I$(brew --prefix openssl@1.1)/include $CPPFLAGS"
export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl@1.1/lib/pkgconfig:$PKG_CONFIG_PATH"

## openssl@3
export LDFLAGS="$LDFLAGS -L$(brew --prefix openssl@3)/lib"
export CPPFLAGS="$CPPFLAGS -I$(brew --prefix openssl@3)/include"
export PKG_CONFIG_PATH="$(brew --prefix openssl@3)/lib/pkgconfig:$PKG_CONFIG_PATH"

## librdkafka (for confluent-kafka)
local LIBRDKAFKA_BASE_PATH="/opt/homebrew/opt/librdkafka"
export C_INCLUDE_PATH="$LIBRDKAFKA_BASE_PATH/include:$C_INCLUDE_PATH"
export LIBRARY_PATH="$LIBRDKAFKA_BASE_PATH/lib:$LIBRARY_PATH"

## openblas (for numpy)
export OPENBLAS="$(brew --prefix openblas)"

## postgresql@12 (for psycopg2)
export LDFLAGS="-L/usr/local/opt/openssl/lib -L/opt/homebrew/opt/postgresql@12/lib $LDFLAGS"
export CPPFLAGS="-I/usr/local/opt/openssl/include -I/opt/homebrew/opt/postgresql@12/include $CPPFLAGS"
export PKG_CONFIG_PATH="/opt/homebrew/opt/postgresql@12/lib/pkgconfig:$PKG_CONFIG_PATH"

## Java
export CPPFLAGS="-I/opt/homebrew/opt/openjdk@11/include -I/opt/homebrew/opt/openjdk@17/include $CPPFLAGS"

## icu4c (for pyicu)
export LDFLAGS="-L/opt/homebrew/opt/icu4c/lib $LDFLAGS"
export CPPFLAGS="-I/opt/homebrew/opt/icu4c/include $CPPFLAGS"
export PKG_CONFIG_PATH="/opt/homebrew/opt/icu4c/lib/pkgconfig:$PKG_CONFIG_PATH"

# Environment variables for grpcio
export GRPC_PYTHON_BUILD_SYSTEM_ZLIB=1


