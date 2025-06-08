# chisel3-docker

This repo provides a chisel3 dev container which also includes [Redcrafter/verilog2factorio](https://github.com/Redcrafter/verilog2factorio). You can use it to implement bespoke computer designs in Factorio by specifying them in Scala and Chisel3.

## How to use interactively
`docker run -it -v $(pwd):/chisel rizaudo/chisel3-docker /bin/bash`
and then `sbt test` or something you want.
