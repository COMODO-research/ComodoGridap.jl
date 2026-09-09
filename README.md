# ComodoGridap

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://COMODO-research.github.io/ComodoGridap.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://COMODO-research.github.io/ComodoGridap.jl/dev/)
[![Build Status](https://github.com/COMODO-research/ComodoGridap.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/COMODO-research/ComodoGridap.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/COMODO-research/ComodoGridap.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/COMODO-research/ComodoGridap.jl)

**A Julia package to combine the powers of [Comodo.jl](https://github.com/COMODO-research/Comodo.jl) and [Gridap.jl](https://github.com/gridap/Gridap.jl)**

# About ComodoGridap.jl
This Julia package enables one to combine [Comodo.jl](https://github.com/COMODO-research/Comodo.jl) and [Gridap.jl]
(https://github.com/gridap/Gridap.jl). The latter is a powerful Julia library for finite element analysis, while the former offers powerful geometry processing and meshing tools. In addition, Comodo links with Makie for advanced Julia based visualisation. This library helps brings these capabilities together. Functionality provided here includes the conversion between Comodo meshes to Gridap meshes and vice versa. 