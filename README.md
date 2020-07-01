# build_ffi_generator

Use this package to generate `dart:ffi` bindings.

## Types

The following types are supported:

- `opaque struct`
- `int<N>`, where `N` is one of `8, 16, 32, 64`.
- `uint<N>`, where `N` is one of `8, 16, 32, 64`.
- `float`
- `double`
- `int`, which is equivalent to `int32`
- `size_t`

## TODO

- Don't require argument names
