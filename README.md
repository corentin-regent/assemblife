Conway's Game of Life in x86-64 Assembly
========================================

## Overview

The project targets Linux, is written using the Intel syntax,
and is compiled with [NASM](https://www.nasm.us/). The `FASTCALL`
calling convention is used: function arguments are passed via registers.

The game is implemented in a toroidal array: the left and right
edges are stitched together, as well as the top and bottom edges.

The user can choose the number of columns and rows in the grid
via command-line arguments.

## Running with Docker

Run the project through Docker using the following command:

```shell
docker run --rm ghcr.io/corentin-regent/assemblife:main [cols] [rows]
```

## Running manually

You can use the provided
[Development Container](https://code.visualstudio.com/docs/devcontainers/containers)
to get all tools installed effortlessly, in a Debian environment.

Then, you can build and run the project using:

```shell
make && ./main [cols] [rows]
```

## License

I made this project only to gain a deeper understanding of low-level mechanisms in computers.
Feel free to [do wtf you want](/LICENSE) with it!
