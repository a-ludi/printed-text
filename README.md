`printed-text`
==============

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat)](https://github.com/RichardLitt/standard-readme)
![GitHub](https://img.shields.io/github/license/a-ludi/printed-text)
[![DUB](https://img.shields.io/dub/v/dentist)](https://code.dlang.org/packages/printed-text)

> Text layout engine on top of `printed` graphics package.

`printed-text` provides a text layout engine on top of the graphics context API of `printed` for creating text documents in PDF, HTML or SVG format. It is intended to provide a barebones and extensible API.


Table of Contents
-----------------

- [Install](#install)
- [Usage](#usage)
- [Example](#example)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Citation](#citation)
- [Maintainer](#maintainer)
- [Contributing](#contributing)
- [License](#license)


Install
-------

With `dub add printed-text`.

With `dub.sdl`:

```sdl
dependency "printed:canvas" version="~>1.0"
```

With `dub.json`:

```json
"dependencies": { "printed:canvas": "~>1.0" }
```


Usage
-----

```d
```


Maintainer
----------

DENTIST is being developed by Arne Ludwig &lt;<ludwig@mpi-cbg.de>&gt;.


Contributing
------------

Contributions are warmly welcome. Just create an [issue][gh-issues] or [pull request][gh-pr] on GitHub. If you submit a pull request please make sure that:

- the code compiles on Linux using the current release of [dmd][dmd-download],
- your code is covered with unit tests (if feasible) and
- `dub test` runs successfully.

[gh-issues]: https://github.com/a-ludi/printed-text/issues
[gh-pr]: https://github.com/a-ludi/printed-text/pulls
[dmd-download]: https://dlang.org/download.html#dmd


License
-------

This project is licensed under MIT License (see [LICENSE](./LICENSE)).
