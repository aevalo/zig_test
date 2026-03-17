# zig_test
Different experiments with Zig

## Remove unnecessary dirs
```sh
find . -name .idea -type d -exec rm -r "{}" \; -prune -print
```
```sh
find . -name .zig-cache -type d -exec rm -r "{}" \; -prune -print
```
```sh
find . -name zig-out -type d -exec rm -r "{}" \; -prune -print
```
