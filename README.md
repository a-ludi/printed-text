`printed-text`
==============

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat)](https://github.com/RichardLitt/standard-readme)
![GitHub](https://img.shields.io/github/license/a-ludi/printed-text)
[![DUB](https://img.shields.io/dub/v/printed-text)](https://code.dlang.org/packages/printed-text)

> Text layout engine on top of `printed` graphics package.

`printed-text` provides a text layout engine on top of the graphics context API of `printed` for creating text documents in PDF, HTML or SVG format. It is intended to provide a barebones and extensible API.


Table of Contents
-----------------

- [Install](#install)
- [Usage](#usage)
- [Maintainer](#maintainer)
- [Contributing](#contributing)
- [License](#license)


Install
-------

With `dub add printed-text`.

With `dub.sdl`:

```sdl
dependency "printed-text" version=">=0.0.0"
```

With `dub.json`:

```json
"dependencies": { "printed-text": ">=0.0.0" }
```


Usage
-----

Here is a minimal example. More examples can be found under
[`docs/exmaples`](./docs/exmaples).

```d
import printed.canvas;
import printed.text;

void loremIpsum(IRenderingContext2D renderer, ITextLayouter textLayouter)
{
    with (textLayouter)
    {
        textWidth = 150f; //mm
        fontFace = "Arial";
        fontSize = 10f; //pt

        textLayouter.group({
            fontSize = 16f; //pt
            fontWeight = FontWeight.bold;
            write("Lorem Ipsum\n");
        });
        write("\n")
        write("Lorem ipsum dolor sit amet.");
        foreach (block; layout())
            block.renderWith(renderer);
    }
}
```


Maintainer
----------

`printed-text` is being developed by Arne Ludwig &lt;<arne.ludwig@posteo.de>&gt;.


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
