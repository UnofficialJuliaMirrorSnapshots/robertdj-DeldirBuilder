# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "DeldirBuilder"
version = v"0.1.15"

# Collection of sources required to build DeldirBuilder
sources = [
    "https://cran.r-project.org/src/contrib/Archive/deldir/deldir_0.1-9.tar.gz" =>
    "090aba6747efc77424a44bf4aaa229dfc01fff7752720689bb70cd861df61f6a",
    "https://cran.r-project.org/src/contrib/Archive/deldir/deldir_0.1-15.tar.gz" =>
    "571011c208829f47ecd9f92a19fd94a8eb59de5a2645ab8c62e73926ade30710",

]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/deldir/src

for f in *.f; do
    ${FC} -fPIC -O2 -pipe -g -c "${f}" -o "$(basename "${f}" .f).o"
done

if [[ ${target} == *-mingw32 ]]; then
    libdir="bin"
else
    libdir="lib"
fi

mkdir -p "${prefix}/${libdir}"
${CC} -shared -o ${prefix}/${libdir}/libdeldir.${dlext} *.o
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    Linux(:aarch64, libc=:glibc),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf),
    Linux(:powerpc64le, libc=:glibc),
    Linux(:i686, libc=:musl),
    Linux(:x86_64, libc=:musl),
    Linux(:aarch64, libc=:musl),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf),
    MacOS(:x86_64),
    Windows(:i686),
    Windows(:x86_64)
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libdeldir", :libdeldir)
]

# Dependencies that must be installed before this package can be built
dependencies = [
    
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

